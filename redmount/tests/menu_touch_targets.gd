extends Node
## Telefonda ana menü dokunma hedefleri (tur 390): dokunmatik cihazda her menü düğmesi en az
## TOUCH_BUTTON_H yüksek, düğmeler çakışmıyor, sütun alt ipucu şeridinin üstünde bitiyor.
## Masaüstü düzeni (46 px, tek sütun) değişmiyor. Bitmiş ve bitmemiş kayıt ("Bölüm N" satırı
## sütunu uzatır), 16:9 ve 20:9 için.

var _fail := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Save._path = "user://test_menu_touch_targets.cfg"
	var saved_unlocked := Save.unlocked_level
	var saved_scores := Save.best_scores.duplicate()
	for touch in [true, false]:
		OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "1" if touch else "0")
		for finished in [true, false]:
			Save.best_scores = saved_scores.duplicate()
			if finished:
				Save.best_scores[GameState.level_count() - 1] = maxi(1, Save.best_score(GameState.level_count() - 1))
			else:
				Save.best_scores.erase(GameState.level_count() - 1)
				Save.unlocked_level = 3
			for width in [1280, 1600]:
				get_window().size = Vector2i(width, 720)
				await _check_home(touch, finished, width)
	Save.unlocked_level = saved_unlocked
	Save.best_scores = saved_scores
	OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "")
	print("MENU TOUCH TARGETS: %s" % ("PASS" if _fail == 0 else "FAIL (%d)" % _fail))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Save._path))
	get_tree().quit(0 if _fail == 0 else 1)


func _check_home(touch: bool, finished: bool, width: int) -> void:
	var menu: Node = load("res://scenes/MainMenu.tscn").instantiate()
	add_child(menu)
	for i in 4:
		await get_tree().process_frame
	var tag := "%s/%s/%d" % ["dokunmatik" if touch else "masaüstü",
		"bitmiş" if finished else "bitmemiş", width]
	var col: Control = menu.find_child("HomeColumn", true, false)
	var buttons: Array[Rect2] = []
	for b in col.find_children("*", "Button", true, false):
		var r: Rect2 = (b as Control).get_global_rect()
		var want: float = menu.TOUCH_BUTTON_H if touch else 46.0
		if touch and r.size.y < want - 0.5 or not touch and absf(r.size.y - want) > 0.5 \
				and b != menu._first_button:
			_report("%s: '%s' yüksekliği %.0f (beklenen %s %.0f)" % [tag, b.text, r.size.y,
				"≥" if touch else "=", want])
		for o in buttons:
			if o.grow(-1.0).intersects(r):
				_report("%s: '%s' başka düğmeyle çakışıyor" % [tag, b.text])
		buttons.append(r)
	var bottom := col.get_global_rect().end.y
	var vh := get_viewport().get_visible_rect().size.y
	if bottom > vh - 40.0:
		_report("%s: sütun alt şeride taşıyor (%.0f > %.0f)" % [tag, bottom, vh - 40.0])
	if touch and col.get_global_rect().end.x > get_viewport().get_visible_rect().size.x * 0.5:
		_report("%s: sütun ekranın sağ yarısına taşıyor (karakterler)" % tag)
	print("  %s: %d düğme, sütun dibi %.0f" % [tag, buttons.size(), bottom])
	menu.queue_free()
	await get_tree().process_frame


func _report(msg: String) -> void:
	_fail += 1
	push_error(msg)
	print("FAIL " + msg)
