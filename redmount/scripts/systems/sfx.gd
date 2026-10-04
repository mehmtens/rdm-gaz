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
]

## Kaba mix dengesi — sık/keskin sesler kısılır, önemli olaylar korunur (dB).
const TRIM := {
	"step": -11.0, "coin": -5.0, "swing": -5.0, "shoot": -4.0, "dash": -3.0,
	"jump": -3.0, "land": -2.0, "reload": -3.0, "hit": -1.0,
	"heavy_hit": 1.0, "enemy_down": 0.0, "player_death": 2.0, "boss_slam": 2.0,
	"goal": 1.0, "checkpoint": -1.0, "powerup": -1.0,
}
## Sesler üst üste binince clip'lenmesin diye genel başlık payı.
const HEADROOM := -3.0

var _streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _next: int = 0


func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)

	for clip in CLIP_NAMES:
		var path := AUDIO_DIR + clip + ".wav"
		if ResourceLoader.exists(path):
			_streams[StringName(clip)] = load(path)


## `name` sesini çal. `pitch` temel perde; üstüne ±%6 rastgele eklenir.
func play(name: StringName, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	var stream: AudioStream = _streams.get(name)
	if stream == null:
		return
	var p := _pool[_next]
	_next = (_next + 1) % POOL_SIZE
	p.stream = stream
	p.pitch_scale = clampf(pitch * randf_range(0.94, 1.06), 0.5, 2.0)
	p.volume_db = volume_db + HEADROOM + float(TRIM.get(String(name), 0.0))
	p.play()


func _exit_tree() -> void:
	# Kapanışta havuzdaki ses akışı referanslarını bırak (temiz çıkış).
	for p in _pool:
		p.stop()
		p.stream = null
	_streams.clear()
