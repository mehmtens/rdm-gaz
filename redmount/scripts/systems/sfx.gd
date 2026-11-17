## Sfx — ses efekti autoload'u (Görev 5).
##
## İsimle tek seferlik ses çalar. Küçük bir AudioStreamPlayer havuzuyla sesler
## üst üste binebilir; her çalışta hafif rastgele perde kaydırılır (aynı sesin
## tekrarında monotonluğu azaltır).
## project.godot -> [autoload] altında "Sfx". Sesler placeholder; gerçek mix sonra.
extends Node

const AUDIO_DIR := "res://assets/audio/"
const POOL_SIZE := 12
const CLIP_NAMES: PackedStringArray = [
	"step", "jump", "land", "swing", "dash", "hit", "heavy_hit", "weapon_break",
	"shoot", "reload", "shield", "armor_break", "powerup", "boss_slam",
	"coin", "heal", "enemy_hurt", "enemy_down",
	"player_hurt", "player_death", "checkpoint", "goal",
	"ui_move", "ui_select", "ui_deny",
]

## Kaba mix dengesi — sık/keskin sesler kısılır, önemli olaylar korunur (dB).
const TRIM := {
	"step": -11.0, "coin": -5.0, "swing": -5.0, "shoot": -4.0, "dash": -3.0,
	"jump": -3.0, "land": -2.0, "reload": -3.0, "hit": -1.0,
	"heavy_hit": 1.0, "enemy_down": 0.0, "player_death": 2.0, "boss_slam": 2.0,
	"goal": 1.0, "checkpoint": -1.0, "powerup": -1.0,
	"ui_move": -9.0, "ui_select": -5.0, "ui_deny": -4.0,
}
## Ses önceliği (tur 265, ses denetimi): havuz doluyken yeni ses yalnız kendinden düşük ya da
## eşit öncelikli çalan sesi keser. Eskiden körlemesine sıradaki oyuncu çalınıyordu; Bölüm 1 bot
## koşusunda çalışların %14'ü çalan bir sesi kesiyordu (sancak, düşman yıkılışı, zırh/silah kırılması
## dahil). Listede olmayan ses 1 (orta) sayılır.
const PRIORITY := {
	"step": 0, "ui_move": 0, "coin": 0, "land": 0, "jump": 0, "swing": 0,
	"player_death": 3, "goal": 3, "checkpoint": 3, "boss_slam": 3,
	"player_hurt": 2, "enemy_down": 2, "armor_break": 2, "weapon_break": 2,
	"powerup": 2, "heal": 2,
}
## Aynı karede aynı ses ikinci kez istenirse yeni ses açılmaz; ilk sesin düzeyi bu kadar artar
## (bir kez). Çoklu hedef vuruşunda 2–3 özdeş "heavy_hit" üst üste binip faz/ani ses tepesi yapıyordu.
const STACK_BOOST_DB := 2.0
## Bir sesten bu kadar kısa süre sonra gelen odak tıkı yutulur (ms): sayfa açılışındaki
## programatik `grab_focus` seçim/açılış sesinin üstüne ikinci bir tık bindirmesin.
const UI_MOVE_QUIET_MS := 140
## Bu meta'yı taşıyan düğme genel menü sesini almaz (kendi sesini çalan düğmeler için).
const QUIET_META := &"sfx_quiet"
## Sesler üst üste binince clip'lenmesin diye genel başlık payı.
const HEADROOM := -3.0

var _streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
## Oyuncu başına çalan sesin adı ve başladığı kare (öncelik/birleştirme kararı için).
var _voice_name: Array[StringName] = []
var _voice_frame: Array[int] = []
var _voice_boosted: Array[bool] = []
## Test sayaçları: kaç ses çalan bir sesi kesti / öncelik yüzünden düştü / birleştirildi.
var stolen_count: int = 0
var dropped_count: int = 0
var merged_count: int = 0
var _last_play_ms: int = -100000
## Düğme kendi geri bildirim sesini (coin, ui_deny, duraklat açılışı) aynı karede çaldıysa
## genel seçim sesi susar: kare sonunda karar verilir, bağlantı sırası önemli olmaz.
var _feedback_frame: int = -1
var _select_pending: bool = false
## Son çalınan sesin adı (testler için).
var last_played: StringName = &""


func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)
		_voice_name.append(&"")
		_voice_frame.append(-1)
		_voice_boosted.append(false)

	for clip in CLIP_NAMES:
		var path := AUDIO_DIR + clip + ".wav"
		if ResourceLoader.exists(path):
			_streams[StringName(clip)] = load(path)

	# Menü sesleri (DTM'deki "her dokunuş duyulur" katmanı): ağaca giren her düğme
	# odak alınca tık, basılınca seçim sesi çalar — her menüyü tek tek elden geçirmeden.
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	var b := node as BaseButton
	# Yeniden ebeveynlenen düğme ağaca ikinci kez girer; çift bağlantı olmasın.
	if b == null or b.has_meta(&"_sfx_hooked"):
		return
	b.set_meta(&"_sfx_hooked", true)
	b.focus_entered.connect(_on_button_focus.bind(b))
	b.pressed.connect(_on_button_pressed.bind(b))


func _on_button_focus(b: BaseButton) -> void:
	if b.has_meta(QUIET_META):
		return
	# Fare/dokunuşla tıklamada odak basışla birlikte gelir; seçim sesi yeter.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	if Time.get_ticks_msec() - _last_play_ms < UI_MOVE_QUIET_MS:
		return
	play(&"ui_move")


func _on_button_pressed(b: BaseButton) -> void:
	if b.has_meta(QUIET_META) or b.disabled:
		return
	if not _select_pending:
		_select_pending = true
		_flush_select.call_deferred(Engine.get_process_frames())


func _flush_select(press_frame: int) -> void:
	_select_pending = false
	if _feedback_frame == press_frame:
		return
	play(&"ui_select")


## `name` sesini çal. `pitch` temel perde; üstüne ±%6 rastgele eklenir.
func play(name: StringName, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	var stream: AudioStream = _streams.get(name)
	if stream == null:
		return
	var frame := Engine.get_process_frames()
	_last_play_ms = Time.get_ticks_msec()
	last_played = name
	if name != &"ui_select" and name != &"ui_move":
		_feedback_frame = frame
	var vol := volume_db + HEADROOM + float(TRIM.get(String(name), 0.0))
	# Aynı karede aynı ses zaten başladıysa: yeni ses yok, ilkini biraz güçlendir.
	for i in POOL_SIZE:
		if _voice_frame[i] == frame and _voice_name[i] == name and _pool[i].playing:
			if not _voice_boosted[i]:
				_voice_boosted[i] = true
				_pool[i].volume_db = maxf(_pool[i].volume_db, vol) + STACK_BOOST_DB
			merged_count += 1
			return
	var idx := _pick_voice(int(PRIORITY.get(String(name), 1)))
	if idx < 0:
		dropped_count += 1
		return
	var p := _pool[idx]
	if p.playing:
		stolen_count += 1
	p.stream = stream
	p.pitch_scale = clampf(pitch * randf_range(0.94, 1.06), 0.5, 2.0)
	p.volume_db = vol
	p.play()
	_voice_name[idx] = name
	_voice_frame[idx] = frame
	_voice_boosted[idx] = false


## Boş oyuncu varsa onu; yoksa en düşük öncelikli, eşitlikte en eski başlayan çalan sesi
## döndürür. O ses yeni sesten yüksek öncelikliyse -1 (yeni ses düşer, önemli ses kesilmez).
func _pick_voice(prio: int) -> int:
	var best := -1
	var best_prio := 99
	var best_frame := 0
	for i in POOL_SIZE:
		if not _pool[i].playing:
			return i
		var vp := int(PRIORITY.get(String(_voice_name[i]), 1))
		if vp < best_prio or (vp == best_prio and _voice_frame[i] < best_frame):
			best = i
			best_prio = vp
			best_frame = _voice_frame[i]
	if best_prio > prio:
		return -1
	return best


func _exit_tree() -> void:
	# Kapanışta havuzdaki ses akışı referanslarını bırak (temiz çıkış).
	for p in _pool:
		p.stop()
		p.stream = null
	_streams.clear()
