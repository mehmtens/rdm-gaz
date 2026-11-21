## BattleArena — tempoyu yükselten kilitli dövüş kapısı (Görev 18).
##
## Oyuncu tetik alanına girince: iki yanda parlayan bariyer belirir (fiziksel +
## görsel), kamera arenaya kilitlenir, düşman dalgaları sırayla spawn olur.
## Hepsi temizlenince bariyerler düşer, kamera açılır, `cleared` yayılır ve
## (varsa) ödül düşer. Grup: "battle_arena". Spawn edilen düşmanları Main
## `enemy_spawned` ile sayaca bağlar.
class_name BattleArena
extends Area2D

const PARMAKLIK := preload("res://assets/environment/pixel/parmaklik.png")
const PARMAKLIK_TEPE := preload("res://assets/environment/pixel/parmaklik_tepe.png")

signal cleared
signal enemy_spawned(enemy: Node)
## HUD göstergesi için: kaçıncı dalga / toplam dalga / o dalgada kalan düşman.
signal wave_changed(wave: int, total: int, remaining: int)

## Bariyerlerin dünya-x konumları (arena genişliği).
@export var gate_left_x: float = 0.0
@export var gate_right_x: float = 640.0
## Zemin y'si + bariyer yüksekliği.
@export var floor_y: float = 0.0
@export var gate_height: float = 440.0
## İsteğe bağlı mekâna ait piksel kapı dokusu.
@export var gate_texture: Texture2D
## Yalnız kepenk/avlu/kapı mantığı olan mekânlarda fiziksel kapı kurulur.
@export var use_gates: bool = true
## Kamerayı arenaya kilitle.
@export var lock_camera: bool = true
## Düşman dalgaları — her biri PackedScene dizisi (Inspector'dan / tscn'den).
@export var wave1: Array[PackedScene] = []
@export var wave2: Array[PackedScene] = []
@export var wave3: Array[PackedScene] = []
## Dalga arası bekleme (sn).
@export var wave_delay: float = 0.9
## Temizlenince düşecek ödül (opsiyonel — HealthPickup / Coin vb).
@export var reward: PackedScene
## Adlı rakip: `named_wave` (1 tabanlı) dalgasının ilk düşmanı bu adla boss olur
## (HUD can çubuğu + ad, canı `named_health_mult` katı). Boşsa yok.
@export var named_title: String = ""
@export var named_wave: int = 0
@export var named_health_mult: float = 2.5
## Dalga arası "nefes" ödülü: oyuncu düşük canla bir dalgayı kapatınca, bir
## sonraki dalga gelmeden küçük bir can yemeği düşer (DTM arenalarındaki merhamet
## düşüşü gibi). Arena başına bir kez, yalnız can %MERCY_HP_FRAC altındayken;
## tam canlı oyuncuya hiç çıkmaz, farmlanamaz. İnce tasarıma zarar vermemesi için
## bölüm bazında kapatılabilir.
@export var mercy_between_waves: bool = true

## Arena bitişinde eli boş oyuncuya yakın silah: DTM arenaları dövüşü bitiren
## oyuncuyu sıradaki kalabalığa silahla yollar. Yalnız elinde de yedekte de silah
## yokken; silahlı oyuncuya ikinci silah düşmez (ekonomi şişmez). Bölüm bazında
## kapatılabilir.
@export var empty_hand_weapon: bool = true

const MERCY_PICKUP := preload("res://scenes/pickups/HealthPickup.tscn")
## Eli boş oyuncuya arena sonu silahı — kırılabilir yakın silahlar (atış/anahtar yok).
const EMPTY_HAND_WEAPONS: Array[PackedScene] = [
	preload("res://scenes/pickups/BatPickup.tscn"),
	preload("res://scenes/pickups/KnifePickup.tscn"),
	preload("res://scenes/pickups/SemsiyePickup.tscn"),
]
## Eşik ve iyileşme insan testi gelene kadar hipotez (bkz. tur günlüğü).
const MERCY_HP_FRAC := 0.35

var _active := false
var _done := false
var _alive: Array = []
var _waves: Array = []
var _wave_idx := 0
var _gates: Array = []
var _accent := Color(1.0, 0.42, 0.32)
var _saved_cam := Vector2.ZERO
var _pull_t := 0.0
var _mercy_dropped := false

## Kapı dışında kalan takipçi: bu kadar yakın (px) ve zemin bandındaysa içeri alınır.
const PULL_RANGE := 640.0
const PULL_BAND := 200.0
const PULL_EVERY := 0.4


func _ready() -> void:
	add_to_group(&"battle_arena")
	body_entered.connect(_on_body_entered)
	for w in [wave1, wave2, wave3]:
		if not w.is_empty():
			_waves.append(w)


## Oyuncu şu an kapıları kapalı bir arenanın içinde dövüşüyor mu (dalga arası dahil)?
## Kapısız arenada oyuncu çıkıp gidebildiği için konum da aranır.
static func player_in_combat(tree: SceneTree) -> bool:
	var p := tree.get_first_node_in_group(&"player") as Node2D
	if p == null:
		return false
	var x := p.global_position.x
	for a in tree.get_nodes_in_group(&"battle_arena"):
		if a._active and not a._done and x >= a.gate_left_x - 40.0 and x <= a.gate_right_x + 40.0:
			return true
	return false


func _on_body_entered(b: Node) -> void:
	if _active or _done or not b.is_in_group(&"player"):
		return
	_active = true
	set_deferred(&"monitoring", false)
	# Fizik sorgu akışı sırasında (body_entered) fiziksel gövde eklemek hata verir.
	call_deferred(&"_activate")


func _activate() -> void:
	if use_gates:
		_raise_gates()
	_lock_camera()
	Combat.shake(3.5)
	Combat.hitstop(0.06)
	Sfx.play(&"armor_break", 0.7)
	Music.battle_start()
	_spawn_wave()
	_pull_pursuers()


func _physics_process(delta: float) -> void:
	if not _active or _done:
		return
	_pull_t -= delta
	if _pull_t <= 0.0:
		_pull_t = PULL_EVERY
		_pull_pursuers()


# --- Takipçiler (Bölüm 22 denetimi) -------------------------------------

## Oyuncuyu kovalarken kapı kapanınca dışarıda kalan düşman, kapının ardından
## (çoğu zaman ekran dışından) ateş ediyor ama ne vurulabiliyor ne sayaçta
## görünüyordu. Kapı dışında, çatışmadaki her düşman kapanan kapıdan içeri
## alınır ve o dalganın sayacına eklenir.
func _pull_pursuers() -> void:
	if not use_gates:
		return   # fiziksel kapı yoksa takipçi zaten yürüyerek girer
	for n in get_tree().get_nodes_in_group(&"enemy_ai"):
		if not (n is EnemyBase) or n.has_method(&"_call_add") or _alive.has(n):
			continue
		var e := n as EnemyBase
		if not e.is_engaged() or absf(e.global_position.y - floor_y) > PULL_BAND:
			continue
		var x := e.global_position.x
		var out := gate_left_x - x if x < gate_left_x else x - gate_right_x
		if out <= 0.0 or out > PULL_RANGE:
			continue
		_pull_in(e, x < gate_left_x)


func _pull_in(e: EnemyBase, from_left: bool) -> void:
	var gx := gate_left_x + 70.0 if from_left else gate_right_x - 70.0
	e.global_position = Vector2(gx, floor_y - 24.0)
	e.velocity = Vector2.ZERO
	if not e.defeated.is_connected(_on_enemy_down):
		e.defeated.connect(_on_enemy_down)
	_alive.append(e)
	Fx.ring(e.global_position + Vector2(0, -70), _accent, 8, 74, 0.35)
	wave_changed.emit(_wave_idx, _waves.size(), _alive.size())


# --- Bariyerler --------------------------------------------------------

func _raise_gates() -> void:
	_gates.append(_make_gate(gate_left_x))
	_gates.append(_make_gate(gate_right_x))


func _make_gate(x: float) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.global_position = Vector2(x, floor_y)
	var col := CollisionShape2D.new()
	var s := RectangleShape2D.new()
	s.size = Vector2(24.0, gate_height)
	col.shape = s
	col.position = Vector2(0, -gate_height * 0.5)
	body.add_child(col)
	body.add_child(_GateVis.new(gate_height, _accent, gate_texture))
	get_parent().add_child(body)
	return body


func _drop_gates() -> void:
	for g in _gates:
		if is_instance_valid(g):
			var v: Node = g.get_child(1)
			if v != null:
				(v as _GateVis).dissolve()
			g.get_child(0).set_deferred(&"disabled", true)
			g.get_tree().create_timer(0.35).timeout.connect(g.queue_free)
	_gates.clear()


# --- Kamera -----------------------------------------------------------

func _lock_camera() -> void:
	if not lock_camera:
		return
	var p := get_tree().get_first_node_in_group(&"player")
	if p == null:
		return
	var cam: Camera2D = p.get_node_or_null(^"Camera2D")
	if cam == null:
		return
	_saved_cam = Vector2(cam.limit_left, cam.limit_right)
	cam.limit_left = int(gate_left_x)
	cam.limit_right = int(gate_right_x)


func _unlock_camera() -> void:
	if not lock_camera or _saved_cam == Vector2.ZERO:
		return
	var p := get_tree().get_first_node_in_group(&"player")
	if p == null:
		return
	var cam: Camera2D = p.get_node_or_null(^"Camera2D")
	if cam == null:
		return
	cam.limit_left = int(_saved_cam.x)
	cam.limit_right = int(_saved_cam.y)


# --- Dalgalar --------------------------------------------------------

func _spawn_wave() -> void:
	if _wave_idx >= _waves.size():
		_finish()
		return
	var w: Array = _waves[_wave_idx]
	_wave_idx += 1
	var n: int = maxi(w.size(), 1)
	for i in w.size():
		if w[i] == null:
			continue
		var e: Node2D = w[i].instantiate()
		var frac := (float(i) + 0.5) / float(n)
		var x := lerpf(gate_left_x + 80.0, gate_right_x - 80.0, frac)
		e.global_position = Vector2(x, floor_y - 24.0)
		if i == 0 and _wave_idx == named_wave and named_title != "" and e is EnemyBase:
			(e as EnemyBase).make_named(named_title, named_health_mult)
		get_parent().add_child(e)
		if e.has_signal(&"defeated"):
			e.defeated.connect(_on_enemy_down)
		_alive.append(e)
		enemy_spawned.emit(e)
		Fx.ring(e.global_position + Vector2(0, -70), _accent, 8, 74, 0.35)
	Fx.spark(Vector2((gate_left_x + gate_right_x) * 0.5, floor_y - 80.0), Vector2.ZERO, 7, _accent)
	wave_changed.emit(_wave_idx, _waves.size(), _alive.size())


func _on_enemy_down(e: Node) -> void:
	_alive.erase(e)
	wave_changed.emit(_wave_idx, _waves.size(), _alive.size())
	if not _alive.is_empty():
		return
	if _wave_idx < _waves.size():
		_maybe_mercy_drop()
		await get_tree().create_timer(wave_delay, false).timeout
		if is_instance_valid(self):
			_spawn_wave()
	else:
		_finish()


## Dalga kapandı, sıradaki geliyor: oyuncu düşük canlıysa bir kez can yemeği düşür.
func _maybe_mercy_drop() -> void:
	if not mercy_between_waves or _mercy_dropped:
		return
	var p := get_tree().get_first_node_in_group(&"player") as Node2D
	if p == null or not p.has_method(&"get_health") or not p.has_method(&"get_max_health"):
		return
	var maxhp: int = p.get_max_health()
	if maxhp <= 0 or float(p.get_health()) / float(maxhp) >= MERCY_HP_FRAC:
		return
	_mercy_dropped = true
	var food: Node2D = MERCY_PICKUP.instantiate()
	## Oyuncunun biraz önüne, arena içinde kalacak şekilde; kenara taşarsa ortala.
	var fx: float = clampf(p.global_position.x + 60.0, gate_left_x + 40.0, gate_right_x - 40.0)
	food.global_position = Vector2(fx, floor_y - 60.0)
	get_parent().add_child.call_deferred(food)
	Fx.popup(Vector2(fx, floor_y - 150.0), "NEFES AL!", Color(0.5, 0.95, 0.55), 22)


func _finish() -> void:
	if _done:
		return
	_done = true
	if use_gates:
		_drop_gates()
	_unlock_camera()
	Music.battle_end()
	Combat.shake(2.5)
	Fx.popup(Vector2((gate_left_x + gate_right_x) * 0.5, floor_y - 130.0), "TEMİZ!", _accent, 30)
	if reward != null:
		var r: Node2D = reward.instantiate()
		var rpos := Vector2((gate_left_x + gate_right_x) * 0.5, floor_y - 60.0)
		r.global_position = rpos
		# _finish() fizik sorgu akışı sırasında (düşman ölümü) çağrılabilir —
		# Area2D ödülü doğrudan eklemek "flushing queries" hatası verir.
		get_parent().add_child.call_deferred(r)
		# Parlak sur arka planında tek pickup az fark ediliyor; sıcak altın halka
		# + kıvılcım ödülü düştüğü yeri duyurur ("TEMİZ!" vurgusuyla uyumlu ton,
		# additive değil okunur). Gecikmeli: ödül bir frame sonra ekleniyor.
		_announce_reward.call_deferred(rpos)
	_maybe_weapon_drop()
	cleared.emit()


## Eli boş oyuncuya arena sonunda bir yakın silah (ödülün sağında, arena içinde).
## Seçim arenanın konumundan türetilir: aynı arena her oynayışta aynı silahı verir.
func _maybe_weapon_drop() -> void:
	if not empty_hand_weapon:
		return
	var p := get_tree().get_first_node_in_group(&"player") as Node2D
	if p == null or not p.has_method(&"has_weapon") or p.has_weapon():
		return
	if p.has_method(&"has_stash") and p.has_stash():
		return
	var idx := absi(int(gate_left_x / 64.0)) % EMPTY_HAND_WEAPONS.size()
	var w: Node2D = EMPTY_HAND_WEAPONS[idx].instantiate()
	var mid := (gate_left_x + gate_right_x) * 0.5
	var wx := clampf(mid + 90.0, gate_left_x + 40.0, gate_right_x - 40.0)
	w.global_position = Vector2(wx, floor_y - 60.0)
	get_parent().add_child.call_deferred(w)


## Ödül düşüş vurgusu: genişleyen altın halka + yukarı kıvılcım patlaması.
func _announce_reward(at: Vector2) -> void:
	Fx.ring(at, Color(1.0, 0.86, 0.46), 12.0, 78.0, 0.42, 5.0)
	Fx.spark(at, Vector2.UP, 12, Color(1.0, 0.9, 0.58), 1.3)


# --- Bariyer görseli -------------------------------------------------

class _GateVis extends Node2D:
	var _h: float
	var _col: Color
	var _t := 0.0
	var _fade := 1.0
	var _dying := false
	var _texture: Texture2D

	func _init(h: float, col: Color, tex: Texture2D = null) -> void:
		_h = h
		_col = col
		_texture = tex
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func dissolve() -> void:
		_dying = true

	func _process(delta: float) -> void:
		_t += delta
		if _dying:
			_fade = maxf(_fade - delta * 3.0, 0.0)
		queue_redraw()

	func _draw() -> void:
		if _texture != null:
			draw_texture_rect(_texture, Rect2(-12, -_h - (1.0 - _fade) * 80, 24, _h), false, Color(1, 1, 1, _fade))
			return
		# Piksel art demir parmaklık: yukarıdan iner, açılırken geri çekilir.
		var drop := (1.0 - _fade) * 120.0
		var tint := Color(1, 1, 1, _fade)
		var tw := 36.0
		var th := 72.0
		var y := -_h - drop
		draw_texture_rect(PARMAKLIK_TEPE, Rect2(-tw * 0.5, y - 30.0, tw, 30.0), false, tint)
		while y < -drop - 0.5:
			var hh := minf(th, -drop - y)
			## 18×36 çizim 2x (tur 338: eski 12 sütun/3x bölge ikinci çubuğu kırpıyordu).
			draw_texture_rect_region(PARMAKLIK, Rect2(-tw * 0.5, y, tw, hh),
				Rect2(0, 0, PARMAKLIK.get_width(), hh / 2.0), tint)
			y += th
