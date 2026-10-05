extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 780.0
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Kitap 3 Bölüm 10 tamamlanamadı: %s" % msg)
	assert(_max_x > 110000.0, "Kandilli vericisinin çıkışına ulaşılamadı")
	assert(_run_t >= 420.0 and _run_t <= 660.0, "Oynanış süresi 7–11 dakika dışına çıktı: %.1f" % _run_t)
	super._finish_level(msg)
