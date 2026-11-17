extends Node
## Android geri tuşu yönlendirmesi (tur 241): uygulama kapanmaz, ESC akışı +
## sahne başına `handle_back`.


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Save._path = "user://test_back_button.cfg"
	assert(not ProjectSettings.get_setting("application/config/quit_on_go_back", true))
	assert(get_node_or_null(^"/root/BackButton") != null)

	## Ana menü: alt sayfada geri → anasayfa (çıkış değil).
	var menu: Node = load("res://scenes/MainMenu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	menu._show(menu._levels)
	assert(not menu.handle_back())
	await _back()
	assert(menu._home.visible)
	menu.queue_free()
	await get_tree().process_frame

	## Bölüm: oyun sırasında geri → duraklat, tekrar geri → devam.
	GameState.level_index = 0
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	main._load_current_level()
	for i in 60:
		await get_tree().process_frame
		if Cutscene.active != null:
			Cutscene.active._skip = true
	while Cutscene.active != null:
		await get_tree().process_frame
	get_tree().paused = false
	await get_tree().process_frame
	assert(not main.handle_back())
	await _back()
	assert(main._pause_menu.is_open() and get_tree().paused)
	await _back()
	assert(not main._pause_menu.is_open() and not get_tree().paused)
	## Bitmiş ama kart açılmamış (final kurtarma anı): menüye atlamaz.
	main._finished = true
	main._hud.get_node(^"ResultsPanel").visible = false
	assert(not main.handle_back())
	main._finished = false
	main.queue_free()
	await get_tree().process_frame

	## Survival: dalga sırasında üstlenmez (ESC duraklatır).
	GameState.daily_run = false
	var surv: Node = load("res://scenes/Survival.tscn").instantiate()
	add_child(surv)
	await get_tree().process_frame
	assert(not surv.handle_back())
	await _back()
	assert(surv._pause.is_open())
	await _back()
	assert(not surv._pause.is_open())

	## Çift bildirim tek basış sayılır.
	BackButton._last_ms = -100000
	assert(BackButton.request_back() == "esc")
	assert(BackButton.request_back() == "ignored")
	print("BACK BUTTON OK")
	get_tree().paused = false
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Save._path))
	get_tree().quit(0)


## Gerçek yol: pencere bildirimi → BackButton → ESC olayı → sahne girdisi.
func _back() -> void:
	BackButton._last_ms = -100000
	BackButton.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	for i in 3:
		await get_tree().process_frame
