## Yeniden yapılan (DtmLevel) bölümlerin ortak bot testi. Bölüm, GameState.LEVELS
## indeksiyle verilir; hikâye sahneleri geçilir, bölüm takılmadan bitmelidir.
##
##  REDMOUNT_PROBE_LEVEL=1 godot --headless --path . --fixed-fps 60 res://tests/bolum_play.tscn
extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 480.0
	assert(not OS.get_environment("REDMOUNT_PROBE_LEVEL").is_empty(), "REDMOUNT_PROBE_LEVEL verilmeli")
	await super._ready()


func _finish_level(msg: String) -> void:
	_note_stall()
	if not msg.begins_with("CLEARED") or _longest_stall > 30.0:
		push_error("BASARISIZ Bölüm %d: %s  stall=%.0fs@%.0f" % [_level_idx + 1, msg, _longest_stall, _stall_at])
		get_tree().quit(1)
		return
	super._finish_level(msg)
