extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 780.0
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Kitap 2 Bölüm 3 tamamlanamadı: %s" % msg)
	assert(_max_x > 113000.0, "Zeyrek terasına ulaşılamadı")
	assert(_run_t >= 420.0 and _run_t <= 600.0, "Oynanış süresi 7–10 dakika dışına çıktı: %.1f" % _run_t)
	assert(_longest_stall <= 45.0, "%.0f sn ilerlemesiz takılma (x=%.0f)" % [_longest_stall, _stall_at])
	super._finish_level(msg)
