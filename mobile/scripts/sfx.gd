## Sfx — isimle tek seferlik ses; küçük oynatıcı havuzu (autoload).
extends Node

const DIR := "res://audio/sfx/"
const CLIPS: PackedStringArray = ["armor_break", "boss_slam", "checkpoint", "coin", "dash",
	"enemy_down", "enemy_hurt", "goal", "heal", "heavy_hit", "hit", "jump", "land",
	"player_death", "player_hurt", "powerup", "reload", "shield", "shoot", "step", "swing",
	"weapon_break"]
const TRIM := {"step": -11.0, "coin": -9.0, "swing": -6.0, "shoot": -4.0, "jump": -5.0,
	"land": -6.0, "hit": -1.0, "heavy_hit": 1.0, "goal": 1.0}

var _streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 14:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)
	for c in CLIPS:
		var path := DIR + c + ".wav"
		if ResourceLoader.exists(path):
			_streams[c] = load(path)


func play(clip: String, pitch: float = 1.0, db: float = 0.0) -> void:
	var s: AudioStream = _streams.get(clip)
	if s == null:
		return
	var p := _pool[_next]
	_next = (_next + 1) % _pool.size()
	p.stream = s
	p.pitch_scale = clampf(pitch * randf_range(0.93, 1.07), 0.4, 2.5)
	p.volume_db = db - 3.0 + float(TRIM.get(clip, 0.0))
	p.play()
