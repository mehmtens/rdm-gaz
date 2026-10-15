## Bölüm 1 (Balat Sokakları) otonom bot testi: hikâye sahneleri geçilir, bölüm
## takılmadan bitmelidir.
##
##  godot --headless --path . --fixed-fps 60 res://tests/level01_play.tscn
extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 400.0
	OS.set_environment("REDMOUNT_PROBE_LEVEL", "0")
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Bölüm 1 tamamlanamadı: %s" % msg)
	assert(_max_x > 8400.0, "Kuzey Hanı kapısına ulaşılamadı")
	_assert_no_stall(30.0)
	super._finish_level(msg)
