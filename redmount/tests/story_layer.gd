extends SceneTree

## Hikâye katmanı testi: bölüm başı kartı, HUD hedef satırı ve bitiş konuşması.
## REDMOUNT_CAPTURE_DIR verilirse (pencereli çalıştırmada) ekran görüntüsü de alır.

const LEVEL := 13  # Kitap 2 · Bölüm 2 — Sahte Mühür


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var state := root.get_node(^"GameState")
	state.level_index = LEVEL
	state.story_scenes = true
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	for i in 30:
		await process_frame

	var card: StoryCard = main._story_card
	assert(card.is_active(), "Bölüm başında hikâye kartı açılmalı")
	assert(paused, "Hikâye kartı açıkken dünya durmalı")
	assert(card._brief.text == StoryData.brief(LEVEL))
	await _capture("story-card")

	_tap()
	await process_frame
	assert(card.is_active(), "Kart ilk anda yanlışlıkla kapanmamalı")
	await create_timer(1.0).timeout
	_tap()
	await process_frame
	assert(not card.is_active(), "Dokunuş hikâye kartını kapatmalı")
	assert(not paused, "Kart kapanınca oyun devam etmeli")
	for i in 20:
		await process_frame
	await _capture("story-objective")

	main._load_current_level()
	await process_frame
	assert(not card.is_active(), "Yeniden denemede kart tekrar açılmamalı")

	main._on_goal_reached()
	await process_frame
	assert(main._dialogue.is_active(), "Bitişte hikâye konuşması oynamalı")
	assert(not main._finished, "Sonuç ekranı konuşmadan sonra gelmeli")
	await create_timer(1.5).timeout
	await _capture("story-outro")
	var guard := 0
	while main._dialogue.is_active() and guard < 20:
		main._dialogue._advance()
		guard += 1
	await process_frame
	assert(main._finished, "Konuşma bitince bölüm tamamlanmalı")
	assert(main.get_node(^"UI/HUD/ResultsPanel").visible)

	paused = false
	state.story_scenes = false
	main.queue_free()
	await process_frame
	print("STORY LAYER OK")
	quit(0)


func _tap() -> void:
	var event := InputEventScreenTouch.new()
	event.pressed = true
	event.position = Vector2(400, 300)
	Input.parse_input_event(event)


func _capture(name: String) -> void:
	var folder := OS.get_environment("REDMOUNT_CAPTURE_DIR")
	if folder.is_empty():
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder.path_join(name + ".png"))
