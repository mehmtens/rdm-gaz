extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 600.0
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Kitap 2 Bölüm 3 tamamlanamadı: %s" % msg)
	assert(_max_x > 113000.0, "Zeyrek terasına ulaşılamadı")
	assert(_run_t >= 420.0 and _run_t <= 540.0, "Oynanış süresi 7–9 dakika dışına çıktı: %.1f" % _run_t)
	super._finish_level(msg)
