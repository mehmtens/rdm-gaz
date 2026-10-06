extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 1500.0
	await super._ready()


func _finish_level(msg: String) -> void:
	assert(msg.begins_with("CLEARED"), "Kitap 2 finali tamamlanamadı: %s" % msg)
	assert(_max_x > 286000.0, "Bozdoğan Kemeri kulesine ulaşılamadı")
	_assert_no_stall()
	assert(_run_t >= 1080.0 and _run_t <= 1320.0, "Final süresi 18–22 dakika dışına çıktı: %.1f" % _run_t)
	var boss_cleared := false
	for node in get_tree().get_nodes_in_group(&"battle_arena"):
		var arena := node as BattleArena
		if arena != null and arena.wave3.size() == 1 and arena._done:
			boss_cleared = true
	assert(boss_cleared, "Ana Vana Muhafızı yenilmedi")
	super._finish_level(msg)
