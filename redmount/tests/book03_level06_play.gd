extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 780.0
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Kitap 3 Bölüm 6 tamamlanamadı: %s" % msg)
	assert(_max_x > 110000.0, "Beylerbeyi arşivinin çıkışına ulaşılamadı")
	assert(_run_t >= 420.0 and _run_t <= 600.0, "Oynanış süresi 7–10 dakika dışına çıktı: %.1f" % _run_t)
	_assert_no_stall()
	super._finish_level(msg)
