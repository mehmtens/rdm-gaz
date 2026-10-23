## Dokunmatik kontrol cilası (Yol haritası 8): piksel art düğme dokuları + piksel
## yazı tipi, KAY (kayma tekmesi) kısayolu, titreşim ayarı ve kayıt uyumu.
##
##  godot --headless --path . res://tests/touch_polish.tscn
extends Node

var _fails := 0


func _ready() -> void:
	OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "1")
	Save._path = "user://touch_polish_test.cfg"
	Save.wipe()
	_save_compat()
	await _controls()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://touch_polish_test.cfg"))
	print("TOUCH POLISH: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _save_compat() -> void:
	Save.set_vibration(false)
	Save.vibration = true
	Save.load_game()
	_check(not Save.vibration, "titreşim ayarı kayda yazılıp okunmalı")
	# Eski kayıt: settings/vibration anahtarı yok → açık varsayılır.
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "total_coins", 7)
	cfg.save(Save._path)
	Save.vibration = false
	Save.load_game()
	_check(Save.vibration and Save.total_coins == 7, "eski kayıtta titreşim açık varsayılmalı")


func _controls() -> void:
	GameState.level_index = 0
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	for node in main._level.get_children():
		if node is Cutscene:
			node._started = true
	await get_tree().process_frame
	var touch: TouchControls = main.get_node(^"TouchControls")
	_check(touch.is_enabled(), "dokunmatik kontroller açık olmalı")
	for key in touch._buttons:
		var b: TouchScreenButton = touch._buttons[key]
		_check(b.texture_normal.resource_path.contains("/ui/pixel/touch_"), key + ": piksel art doku")
		_check(b.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, key + ": NEAREST filtre")
		_check(touch._labels[key].get_theme_font("font") == PixelUI.font(), key + ": piksel yazı tipi")
	_check(touch._icons["move_left"].texture != null and touch._icons["pause"].texture != null,
		"ok ve duraklat düğmeleri piksel ikon taşımalı")
	var slide: TouchScreenButton = touch.get_node(^"slide")
	_check(slide.visible and slide.action == "slide", "KAY düğmesi oyunda görünmeli ve slide eylemine bağlı olmalı")
	# Ekrandaki boyut: yarıçap 46 → ~92 px (0.85–1.2 ölçek aralığında).
	var shown := slide.texture_normal.get_width() * slide.scale.x
	_check(shown > 70.0 and shown < 115.0, "KAY düğmesi beklenen boyutta (%.0f px)" % shown)
	touch.set_mode("results")
	_check(not slide.visible, "sonuç ekranında KAY gizlenmeli")
	touch.set_mode("play")

	# KAY: duran oyuncu yerdeyken kayma tekmesi başlar.
	var player = main._player
	for i in 90:
		await get_tree().physics_frame
		if player.is_on_floor():
			break
	_check(player.is_on_floor(), "oyuncu yere inmeli")
	Input.action_press(&"slide")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(&"slide")
	_check(player._special_move == "slide_kick", "KAY kayma tekmesi başlatmalı (%s)" % player._special_move)

	var pause: PauseMenu = main.get_node(^"PauseMenu")
	var vib := pause._root.get_node_or_null(^"Vibration") as Button
	_check(vib != null, "duraklatma menüsünde titreşim ayarı olmalı")
	if vib:
		Save.vibration = true
		pause.toggle_vibration()
		_check(not Save.vibration and vib.text == "TİTREŞİM: KAPALI", "titreşim düğmesi ayarı kapatmalı")
	main.queue_free()
	await get_tree().process_frame
