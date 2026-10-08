## Örnek bölümü (Balat Sokakları) otonom botla baştan sona oynatır.
##
##  godot --headless --path . --fixed-fps 60 res://tests/ornek_play.tscn
extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 400.0
	OS.set_environment("REDMOUNT_LEVEL_PATH", "res://scenes/levels/OrnekBolum.tscn")
	OS.set_environment("REDMOUNT_PROBE_LEVEL", "0")
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Örnek bölüm tamamlanamadı: %s" % msg)
	_assert_no_stall(30.0)
	super._finish_level(msg)
