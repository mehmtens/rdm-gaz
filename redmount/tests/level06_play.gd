extends "res://_autoplay.gd"
## Bölüm 6 uçtan uca: bot ana rotayı bitirir, 45 sn'den uzun takılmaz.


func _ready() -> void:
	Save.purchased = []
	_time_limit = 480.0
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Bölüm 6 ana rota tamamlanamadı: %s" % msg)
	_assert_no_stall()
	super._finish_level(msg)
