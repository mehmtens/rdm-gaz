extends Node
## Survival ölüm kartı + sonsuz dalga sayacı (tur 237).


func _ready() -> void:
	Save._path = "user://test_survival_card.cfg"
	Save.survival_best_wave = 2
	GameState.daily_run = false
	var mode: Node = load("res://scenes/Survival.tscn").instantiate()
	add_child(mode)
	await get_tree().process_frame
	var hud = mode.get_node(^"UI/HUD")
	## Sonsuz mod: kesirsiz sayaç, dalga arası sıradakini duyurur.
	assert(hud._arena_panel.visible)
	assert(hud._arena_label.text.begins_with("DALGA 1  ·  "))
	hud.set_arena_wave(7, -1, 0)
	assert(hud._arena_label.text == "DALGA 8 GELİYOR!")
	hud.set_arena_wave(3, 5, 2)
	assert(hud._arena_label.text == "DALGA 3/5  ·  2 DÜŞMAN")
	hud.set_arena_wave(0, 0, 0)
	assert(not hud._arena_panel.visible)
	## Rekoru geçen ölüm: kart açılır, madalyada temizlenen dalga, R/M ipucu.
	mode._cleared_wave = 4
	mode._show_run_card()
	assert(hud._results.visible)
	assert(hud._results_rank.text == "4")
	assert("YENİ REKOR" in hud._results_stats.text and "eski: 2" in hud._results_stats.text)
	assert("tekrar dene" in hud._results_hint.text)
	assert(mode._finished)
	print("SURVIVAL CARD OK")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Save._path))
	get_tree().quit(0)
