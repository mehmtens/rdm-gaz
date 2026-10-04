## Music — döngüsel parça, yumuşak geçiş (autoload).
extends Node

const DIR := "res://audio/music/mus_"
const BASE_DB := -10.0

var _player: AudioStreamPlayer
var _current := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	add_child(_player)


func play(track: String) -> void:
	if track == _current:
		return
	_current = track
	var path := DIR + track + ".wav"
	if not ResourceLoader.exists(path):
		return
	var s: AudioStreamWAV = load(path)
	if track != "victory":
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = int(s.get_length() * s.mix_rate)
	var tw := create_tween()
	if _player.playing:
		tw.tween_property(_player, "volume_db", -40.0, 0.4)
	tw.tween_callback(func():
		_player.stream = s
		_player.volume_db = -40.0
		_player.play())
	tw.tween_property(_player, "volume_db", BASE_DB, 0.6)
