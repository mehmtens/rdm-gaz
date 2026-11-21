## Dokunmatik düzen ayarı (tur 339): oyuncu duraklat menüsünden oyun düğmelerinin
## boyunu (KÜÇÜK/NORMAL/BÜYÜK) ve saydamlığını (TAM/%70/%45) seçer; kayda yazılır.
##
##  godot --headless --path . res://tests/touch_layout.tscn
extends Node

const TEST_PATH := "user://touch_layout_test.cfg"

var _fails := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "1")
	Save._path = TEST_PATH
	_save_compat()
	await _layout_steps()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	print("TOUCH LAYOUT: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _save_compat() -> void:
	# Eski kayıt: anahtar yok → NORMAL boy, TAM görünürlük.
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "total_coins", 5)
	cfg.save(TEST_PATH)
	Save.touch_size = 2
	Save.touch_alpha = 2
	Save.load_game()
	_check(Save.touch_size == 1 and Save.touch_alpha == 0, "eski kayıtta NORMAL/TAM varsayılmalı")
	# Yazılıp geri okunur; bozuk değer sınırlanır.
	Save.set_touch_layout(2, 1)
	Save.touch_size = 0
	Save.touch_alpha = 0
	Save.load_game()
	_check(Save.touch_size == 2 and Save.touch_alpha == 1, "düzen ayarı kayda yazılıp okunmalı")
	cfg.load(TEST_PATH)
	cfg.set_value("settings", "touch_size", 9)
	cfg.save(TEST_PATH)
	Save.load_game()
	_check(Save.touch_size == 2, "taşan kademe sınırlanmalı")
	Save.set_touch_layout(1, 0)


func _layout_steps() -> void:
	GameState.level_index = 0
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	for node in main._level.get_children():
		if node is Cutscene:
			node._started = true
	await get_tree().process_frame
	var touch: TouchControls = main.get_node(^"TouchControls")
	_check(touch.is_enabled(), "dokunmatik kontroller açık olmalı")
	touch.set_context(true, true, true)
	var vp := get_viewport().get_visible_rect()
	var base_attack: float = touch._buttons["attack"].scale.x
	var base_pause: float = touch._buttons["pause"].scale.x

	# Duraklat menüsündeki döngü düğmeleri (dokunmatikte görünür).
	var menu: PauseMenu = main.get_node(^"PauseMenu")
	# Menü oluşturulduktan sonra değişen ayar açılışta yazıya yansımalı.
	Save.set_touch_layout(2, 0)
	menu.open()
	await get_tree().process_frame
	var size_btn := menu._root.get_node_or_null(^"TouchSize") as Button
	var alpha_btn := menu._root.get_node_or_null(^"TouchAlpha") as Button
	_check(size_btn != null and alpha_btn != null, "duraklat menüsünde boy/saydamlık düğmeleri olmalı")
	if size_btn == null or alpha_btn == null:
		return
	_check(size_btn.text == "DÜĞME BOYU: BÜYÜK", "açılışta güncel kademe yazılmalı (%s)" % size_btn.text)
	Save.set_touch_layout(1, 0)
	menu._refresh_touch_texts()
	_check(size_btn.text == "DÜĞME BOYU: NORMAL", "boy düğmesi yazısı (%s)" % size_btn.text)

	# Her boy kademesinde: oran doğru, düğmeler çakışmıyor ve ekranda kalıyor.
	for step in 3:
		menu.cycle_touch_size()  # NORMAL → BÜYÜK → KÜÇÜK → NORMAL
		var want: float = TouchControls.SIZE_STEPS[Save.touch_size]
		var ratio: float = touch._buttons["attack"].scale.x / base_attack
		_check(absf(ratio - want) < 0.01, "VUR ölçeği kademeyle oranlı (%.2f / %.2f)" % [ratio, want])
		_check(is_equal_approx(touch._buttons["pause"].scale.x, base_pause), "duraklat düğmesi sabit kalmalı")
		_check(size_btn.text.ends_with(String(TouchControls.SIZE_NAMES[Save.touch_size])), "boy yazısı güncellenmeli")
		var circles: Array = []
		for c in touch.touch_circles():
			if c[0] in TouchControls.GAMEPLAY_ACTIONS:
				circles.append(c)
		for i in circles.size():
			var ci: Vector2 = circles[i][1]
			var ri: float = circles[i][2]
			_check(vp.grow(1.0).encloses(Rect2(ci - Vector2.ONE * ri, Vector2.ONE * ri * 2.0)),
				"%s ekranda kalmalı (kademe %d)" % [circles[i][0], Save.touch_size])
			# Üst bant (HUD, telsiz) boş kalır.
			_check(ci.y - ri > vp.size.y * 0.28, "%s üst bandı örtmemeli (kademe %d)" % [circles[i][0], Save.touch_size])
			for j in range(i + 1, circles.size()):
				var cj: Vector2 = circles[j][1]
				var rj: float = circles[j][2]
				_check(ci.distance_to(cj) > (ri + rj) * 0.98,
					"%s ↔ %s çakışmamalı (kademe %d)" % [circles[i][0], circles[j][0], Save.touch_size])
	_check(Save.touch_size == 1, "üç döngü sonunda NORMAL'e dönmeli")

	# Saydamlık: oyun düğmeleri soluk, duraklat tam; basılı düğme tam görünür.
	menu.cycle_touch_alpha()
	menu.cycle_touch_alpha()
	_check(Save.touch_alpha == 2, "iki döngüde %45 kademesi")
	_check(is_equal_approx(touch._buttons["jump"].modulate.a, 0.45), "ZIPLA soluk olmalı (%.2f)" % touch._buttons["jump"].modulate.a)
	_check(is_equal_approx(touch._labels["jump"].modulate.a, 0.45), "ZIPLA yazısı da soluk olmalı")
	_check(is_equal_approx(touch._buttons["pause"].modulate.a, 1.0), "duraklat düğmesi tam görünür kalmalı")
	touch._on_press("jump")
	_check(is_equal_approx(touch._buttons["jump"].modulate.a, 1.0), "basılı düğme tam görünür olmalı")
	touch._on_release("jump")
	_check(is_equal_approx(touch._buttons["jump"].modulate.a, 0.45), "bırakınca yeniden soluk")
	menu.cycle_touch_alpha()
	_check(Save.touch_alpha == 0 and alpha_btn.text == "DÜĞME SAYDAMLIĞI: TAM", "döngü TAM'a dönmeli")
	_check(is_equal_approx(touch._buttons["jump"].modulate.a, 1.0), "TAM kademede opak")
	menu.close()
	main.queue_free()
	await get_tree().process_frame
