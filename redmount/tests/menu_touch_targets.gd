extends Node
## Telefonda ana menü dokunma hedefleri (tur 390): dokunmatik cihazda her menü düğmesi en az
## TOUCH_BUTTON_H yüksek, düğmeler çakışmıyor, sütun alt ipucu şeridinin üstünde bitiyor.
## Masaüstü düzeni (46 px, tek sütun) değişmiyor. Bitmiş ve bitmemiş kayıt ("Bölüm N" satırı
## sütunu uzatır), 16:9 ve 20:9 için. Tur 391: duraklat menüsü de (kostüm rozeti açıkken, en
## uzun hâli) dokunmatikte ≥ 56 px düğme ve ekrana sığan panel. Tur 392: mağazanın üç sekmesi
## (sekme / satın al / GİY / GERİ) dokunmatikte 56 px ve GERİ panelin içinde. Tur 393: kanıt arşivi
## kitap sekmesi 20:9'da 3, 16:9'da 2 sütun ve ızgara kaydırma alanına sığıyor. Tur 394: sonuç kartı
## telefonda (ipucu satırı boş) istatistiklerin altında biter, masaüstünde tam boy kalır.

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
	var saved_costume := Save.costume
	Save.costume = "kizil"
	for touch in [true, false]:
		OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "1" if touch else "0")
		await _check_pause(touch)
	Save.costume = saved_costume
	for touch in [true, false]:
		OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "1" if touch else "0")
		await _check_shop(touch)
	for touch in [true, false]:
		OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "1" if touch else "0")
		await _check_results(touch)
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
	if finished:
		menu._show(menu._archive)
		for i in 4:
			await get_tree().process_frame
		var vw := get_viewport().get_visible_rect().size.x
		var want_cols := 3 if vw >= 1560.0 else 2
		var grid: GridContainer = menu._arch_grid
		var scroll: Control = grid.get_parent()
		if grid.columns != want_cols:
			_report("%s: arşiv %d sütun (genişlik %.0f, beklenen %d)" % [tag, grid.columns, vw, want_cols])
		if grid.get_combined_minimum_size().x > scroll.size.x + 0.5:
			_report("%s: arşiv ızgarası %.0f > kaydırma alanı %.0f" % [tag, grid.get_combined_minimum_size().x, scroll.size.x])
		print("  %s: arşiv %d sütun, ızgara %.0f / alan %.0f" % [tag, grid.columns,
			grid.get_combined_minimum_size().x, scroll.size.x])
	menu.queue_free()
	await get_tree().process_frame


func _check_pause(touch: bool) -> void:
	var pause := PauseMenu.new()
	add_child(pause)
	pause.open()
	for i in 4:
		await get_tree().process_frame
	var tag := "duraklat/%s" % ("dokunmatik" if touch else "masaüstü")
	var want: float = PauseMenu.TOUCH_BUTTON_H if touch else 46.0
	var n := 0
	for b in pause._root.get_children():
		if b is Button:
			n += 1
			var h: float = (b as Control).size.y
			if absf(h - want) > 0.5:
				_report("%s: '%s' yüksekliği %.0f (beklenen %.0f)" % [tag, b.text, h, want])
	var panel: Control = pause._root.get_parent()
	var r := panel.get_global_rect()
	var vh := get_viewport().get_visible_rect().size.y
	if r.position.y < 0.0 or r.end.y > vh:
		_report("%s: panel ekrandan taşıyor (%.0f–%.0f, ekran %.0f)" % [tag, r.position.y, r.end.y, vh])
	if not pause._costume_badge.visible:
		_report("%s: kostüm rozeti görünmüyor (en uzun hâl denenmedi)" % tag)
	print("  %s: %d düğme, panel %.0f–%.0f" % [tag, n, r.position.y, r.end.y])
	pause.close()
	get_tree().paused = false
	pause.queue_free()
	await get_tree().process_frame


func _check_shop(touch: bool) -> void:
	var shop: Node = load("res://scenes/Shop.tscn").instantiate()
	add_child(shop)
	var want: float = shop.TOUCH_BUTTON_H if touch else 48.0
	for tab in 3:
		shop._select(tab)
		for i in 4:
			await get_tree().process_frame
		var tag := "mağaza/%s/sekme %d" % ["dokunmatik" if touch else "masaüstü", tab + 1]
		var n := 0
		for b in shop.find_children("*", "Button", true, false):
			if not (b as Control).is_visible_in_tree():
				continue
			n += 1
			var h: float = (b as Control).size.y
			if h < want - 0.5:
				_report("%s: '%s' yüksekliği %.0f (beklenen ≥ %.0f)" % [tag, b.text, h, want])
		var panel: Control = shop.get_child(shop.get_child_count() - 1)
		for c in shop.get_children():
			if c is PanelContainer:
				panel = c
		var back: Rect2 = shop._back.get_global_rect()
		## Panel ekranın 24 px alt payında biter; içerik sığmazsa panel kendiliğinden uzar.
		var limit := get_viewport().get_visible_rect().size.y - 24.0
		if panel.get_global_rect().end.y > limit + 0.5:
			_report("%s: panel alt paya taşıyor (%.0f > %.0f)" % [tag, panel.get_global_rect().end.y, limit])
		print("  %s: %d düğme, GERİ dibi %.0f, panel dibi %.0f" % [tag, n, back.end.y, panel.get_global_rect().end.y])
	shop.queue_free()
	await get_tree().process_frame


func _check_results(touch: bool) -> void:
	var hud: Node = load("res://scenes/ui/HUD.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame
	hud.show_results(42, 11, 14, 95.0, 6420, "BÖLÜM 1 TAMAMLANDI", 5, 3)
	await get_tree().process_frame
	var tag := "sonuç/%s" % ("dokunmatik" if touch else "masaüstü")
	var card: Control = hud._results_card
	var stats: Label = hud._results_stats
	var card_end := card.get_global_rect().end.y
	var text_end := stats.get_global_rect().position.y + stats.get_minimum_size().y
	if text_end > card_end - 16.0:
		_report("%s: istatistik satırları kart dışına taşıyor (%.0f > %.0f)" % [tag, text_end, card_end - 16.0])
	if touch and card.offset_bottom > hud.RESULTS_CARD_BOTTOM - 60:
		_report("%s: kart küçülmedi (alt %.0f)" % [tag, card.offset_bottom])
	if not touch and not is_equal_approx(card.offset_bottom, hud.RESULTS_CARD_BOTTOM):
		_report("%s: masaüstü kartı değişti (alt %.0f)" % [tag, card.offset_bottom])
	print("  %s: kart altı %.0f, yazı dibi %.0f / kart dibi %.0f" % [tag, card.offset_bottom, text_end, card_end])
	hud.queue_free()
	await get_tree().process_frame


func _report(msg: String) -> void:
	_fail += 1
	push_error(msg)
	print("FAIL " + msg)
