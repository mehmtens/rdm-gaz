extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 780.0
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Kitap 2 Bölüm 6 tamamlanamadı: %s" % msg)
	assert(_max_x > 114000.0, "Han çatısına ulaşılamadı")
	assert(_run_t >= 420.0 and _run_t <= 600.0, "Oynanış süresi 7–10 dakika dışına çıktı: %.1f" % _run_t)
	_assert_no_stall()
	var finale_cleared := false
	for node in get_tree().get_nodes_in_group(&"battle_arena"):
		var arena := node as BattleArena
		if arena != null and arena.wave3.size() == 2 and arena._done:
			finale_cleared = true
	assert(finale_cleared, "Üç dalgalı han finali tamamlanmadı")
	super._finish_level(msg)
