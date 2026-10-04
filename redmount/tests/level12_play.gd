extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 1500.0
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Bölüm 12 tamamlanamadı: %s" % msg)
	assert(_max_x > 238000.0, "Karahanlı'ya ulaşılamadı")
	super._finish_level(msg)
