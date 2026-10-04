## ParkourLayer — kampanya bölümlerinin boş kalan düz sokaklarına İstanbul parkur
## setleri (ParkourSet) yerleştirir. Dan the Man'in "her ekranda bir fikir"
## yoğunluğunu, bölümlerin mevcut rotasını ve hikâye/dövüş düzenini bozmadan verir.
##
## Kurallar:
##  * Yalnız aynı yükseklikte kesintisiz zeminin üstüne kurulur (ölümcül boşluk yok).
##  * Düşman, arena, kontrol noktası, dükkân, ipucu, diyalog, toplanabilir ve diğer
##    platformların çevresine (KEEP_OUT) girmez; bölüm başı ve bitiş kapısı boş kalır.
##  * Gökyüzü görünmeyen iç mekânlarda (ParkourInteriors) dış mahalle setleri
##    yerine sandık, iskele ve taş direk setleri kurulur.
##  * Set türleri kitap/perde ilerledikçe açılır: önce tente + duvar, sonra çatı
##    zinciri, sekme zinciri ve isteğe bağlı baca tırmanışı (öğret → uygula → birleştir).
##  * Yerleşim deterministiktir: aynı bölüm her açılışta aynı düzeni kurar.
class_name ParkourLayer
extends Node2D

const KEEP_OUT := 420.0
const START_CLEAR := 1400.0
const MIN_GAP := 1500.0
## Bölüm uzunluğunun kaç pikselinde bir set hedeflenir.
const DENSITY := 4200.0
const MIN_GROUND_W := 800.0

## Perdeye göre açılan set havuzu (perde indeksi: 0..11).
const ACT_POOLS := [
	["tente_duvar", "balkon"],                          # Kitap 1 / Perde I — öğretim
	["tente_duvar", "balkon", "cati"],                  # Perde II
	["tente_duvar", "cati", "sekme", "balkon"],         # Perde III
	["cati", "sekme", "baca", "tente_duvar", "balkon"], # Perde IV
	["tente_duvar", "balkon", "cati", "sekme"],         # Kitap 2
	["cati", "sekme", "balkon", "baca"],
	["sekme", "cati", "baca", "tente_duvar"],
	["cati", "baca", "sekme", "balkon", "tente_duvar"],
	["balkon", "cati", "sekme", "tente_duvar"],         # Kitap 3
	["sekme", "baca", "cati", "balkon"],
	["cati", "sekme", "baca", "tente_duvar", "balkon"],
	["sekme", "cati", "baca", "balkon"],
]

var placed: Array = []  # [{kind, x}] — testler ve hata ayıklama için


## Level._ready sonunda çağrılır; bölümün tüm düğümleri kurulmuş olur.
func build(level: Level, level_index: int) -> void:
	var grounds := _ground_spans(level)
	var blocked := _blocked_spans(level)
	var goal_x := INF
	for g in _descendants(level):
		if g.is_in_group(&"level_goal"):
			goal_x = minf(goal_x, (g as Node2D).global_position.x)
	var left := float(level.camera_limit_left) + START_CLEAR
	var right := minf(float(level.camera_limit_right) - 600.0, goal_x - 900.0)
	var budget := maxi(int((right - left) / DENSITY), 1)
	# Perde = üç bölümde bir (GameState.act_index ile aynı hesap).
	var pool: Array = ACT_POOLS[clampi(floori(level_index / 3.0), 0, ACT_POOLS.size() - 1)]
	var pick := level_index * 7
	var pick_in := level_index * 5
	var next_x := left
	for span in grounds:
		var g_left: float = maxf(span.x, left)
		var g_right: float = minf(span.y, right)
		var top: float = span.z
		var x := maxf(g_left, next_x)
		while x < g_right and placed.size() < budget:
			var kind: String = pool[pick % pool.size()]
			var w := ParkourSet.width_of(kind)
			var indoor := ParkourInteriors.is_interior(level_index, x, x + w)
			if indoor:
				# Han, hamam, sarnıç, depo: ev/tente yerine sandık, iskele, taş direk.
				kind = ParkourSet.INTERIOR_KINDS[pick_in % ParkourSet.INTERIOR_KINDS.size()]
				w = ParkourSet.width_of(kind)
			var hit := _first_overlap(blocked, x, x + w)
			if x + w > g_right:
				break
			if hit >= 0.0:
				x = hit
				continue
			var p := ParkourSet.new()
			p.kind = kind
			p.variant = level_index + placed.size()
			p.position = Vector2(x, top) - global_position
			add_child(p)
			placed.append({"kind": kind, "x": x})
			if indoor:
				pick_in += 1
			else:
				pick += 1
			x += w + MIN_GAP
			next_x = x


## Kesintisiz zemin aralıkları: Vector3(sol, sağ, üst_y), soldan sağa.
func _ground_spans(level: Level) -> Array:
	var raw: Array = []
	for n in _descendants(level):
		if not (n is StaticBody2D) or n is AnimatableBody2D or not _active(n):
			continue
		var body := n as StaticBody2D
		if body.collision_layer & 1 == 0:
			continue
		for r in _body_rects(body):
			if r.size.x >= MIN_GROUND_W and r.size.y >= 60.0:
				raw.append(Vector3(r.position.x, r.end.x, r.position.y))
	raw.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.x < b.x)
	var merged: Array = []
	for g in raw:
		if not merged.is_empty():
			var last: Vector3 = merged[-1]
			if absf(last.z - g.z) < 2.0 and g.x <= last.y + 2.0:
				merged[-1] = Vector3(last.x, maxf(last.y, g.y), last.z)
				continue
		merged.append(g)
	return merged


## Dokunulmaması gereken yatay aralıklar: Vector2(sol, sağ).
func _blocked_spans(level: Level) -> Array:
	var spans: Array = []
	var ground_ids := {}
	for n in _descendants(level):
		if n == self or is_ancestor_of(n) or not _active(n):
			continue
		var node := n as Node2D
		if node == null:
			continue
		if n is BattleArena:
			var a := n as BattleArena
			spans.append(Vector2(minf(a.gate_left_x, node.global_position.x) - KEEP_OUT,
				maxf(a.gate_right_x, node.global_position.x) + KEEP_OUT))
			continue
		if n is StaticBody2D:
			for r in _body_rects(n as StaticBody2D):
				# Zemin gövdeleri engel değildir; üstlerine kurulur.
				if r.size.x >= MIN_GROUND_W and r.size.y >= 60.0 and (n as StaticBody2D).collision_layer & 1 != 0:
					continue
				spans.append(Vector2(r.position.x - KEEP_OUT, r.end.x + KEEP_OUT))
			continue
		if n is Area2D and n.get_parent() is CharacterBody2D:
			continue  # düşmanın kendi vuruş/hasar alanları
		if n is CharacterBody2D or n is Area2D or n is AnimatableBody2D or n is LevelShop \
				or n is StoryPlace or n is BreakableProp:
			var px := node.global_position.x
			spans.append(Vector2(px - _reach(n), px + _reach(n)))
	spans.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	return spans


## Düğüm türüne göre güvenlik payı: coin dizileri seti yalnız üst üste binmeyecek
## kadar iter; düşman, kontrol noktası ve dükkân çevresi geniş tutulur.
func _reach(n: Node) -> float:
	if n.is_in_group(&"coin"):
		return 70.0
	if n is LevelShop:
		return KEEP_OUT + 260.0
	if n is CharacterBody2D:
		# Devriye düşmanı setin kenarında durabilir; duvarın içinde kalmasın yeter.
		return 280.0
	if n.is_in_group(&"checkpoint") or n is AnimatableBody2D:
		return KEEP_OUT
	if n.is_in_group(&"hint") or n.is_in_group(&"dialogue_trigger") or n is StoryPlace:
		return 260.0
	return 180.0


## [x0, x1] ile çakışan ilk engelin sağ ucu; çakışma yoksa -1.
func _first_overlap(spans: Array, x0: float, x1: float) -> float:
	var best := -1.0
	for s in spans:
		if s.x < x1 and s.y > x0:
			best = maxf(best, s.y)
	return best


func _body_rects(body: StaticBody2D) -> Array:
	var out: Array = []
	for c in body.get_children():
		if not (c is CollisionShape2D):
			continue
		var cs := c as CollisionShape2D
		if cs.disabled or not (cs.shape is RectangleShape2D):
			continue
		var size := (cs.shape as RectangleShape2D).size * cs.global_scale.abs()
		var center := cs.global_position
		out.append(Rect2(center - size * 0.5, size))
	return out


func _active(n: Node) -> bool:
	if n.process_mode == Node.PROCESS_MODE_DISABLED:
		return false
	if n is CanvasItem and not (n as CanvasItem).is_visible_in_tree():
		return false
	return not n.is_queued_for_deletion()


func _descendants(root: Node) -> Array:
	var out: Array = []
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for c in n.get_children():
			out.append(c)
			stack.append(c)
	return out
