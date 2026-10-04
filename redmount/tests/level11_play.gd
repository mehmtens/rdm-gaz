extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Bölüm 11 ana rota tamamlanamadı: %s" % msg)
	assert(_max_x > 49300.0, "Bölüm 11 çıkışına ulaşılamadı")
	super._finish_level(msg)
