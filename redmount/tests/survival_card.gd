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
	## Semtler: 5 dalgada bir sıradaki atlas hücresi, ilk dalgada değişmez.
	assert(SurvivalMode.stage_for_wave(1) == 0 and SurvivalMode.stage_for_wave(5) == 0)
	assert(SurvivalMode.stage_for_wave(6) == 1 and SurvivalMode.stage_for_wave(21) == 0)
	var before: int = mode.sky_cells.size()
	mode._enter_stage_for(4)
	assert(mode.sky_cells.size() == before)
	mode._enter_stage_for(6)
	assert(mode.sky_cells.size() == before + 1 and int(mode.sky_cells.back()[0]) == 2)
	assert(hud._place != null and hud._place.visible)
	print("SURVIVAL CARD OK")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Save._path))
	get_tree().quit(0)
