## Telsiz paneli üst bandı örtmez (tasarım denetimi Bölüm 16, 26 Ekim): telsiz konuşurken
## dalga rozeti, kombo, yer afişi ve boss çubuğu panelin altına kayar, bitince geri döner.
##
## Telsizin kapanması zaman-tabanlı (saniye); kampanya testleri gibi sabit kareyle çalıştır,
## yoksa headless'ta kare-başına delta çok küçük kalıp telsiz dolmaz:
##  godot --headless --path . --fixed-fps 60 res://tests/radio_top_band.tscn
extends Node

var _fails := 0


func _ready() -> void:
	var hud: Control = load("res://scenes/ui/HUD.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame
	hud.set_arena_wave(1, 3, 4)
	hud.show_place("FİLM RULOSU 1 / 3", "deneme", Color("ffd34e"))
	# Görev/film-rulosu tostu da üst-orta banttadır (Bölüm 34 denetimi, tur 296): telsiz +
	# mekân afişi + toast aynı anda görünürken toast ne telsizin altında kaybolmalı ne de
	# afişin üstüne binmelidir.
	hud.show_achievement("ilk_adim")
	hud._flash_big_combo(5, 45)
	await _frames(3)
	var arena: Control = hud._arena_panel
	var combo: Control = hud._combo
	var place: Control = hud._place
	var ach: Control = hud._ach
	# Telsiz kapanınca _follow_radio üyeyi kayıtlı tabanına döndürür; karşılaştırmayı o kanonik
	# tabana yap (canlı offset_top, duyuru gösterilince anlık inset durumuna göre oynayabilir).
	var base_arena: float = hud._top_band[arena].x
	var boss: Control = hud._boss_bar
	var base_boss := boss.offset_top
	RadioPanel.say(get_tree(), "redmount", "REDMOUNT", "Kâğıt kokusu artık barut kokusu.")
	await _frames(40)
	var panel: Control = RadioPanel._instance._panel
	_check(panel.modulate.a > 0.99, "telsiz açıldı")
	var bottom := panel.get_global_rect().end.y
	for pair in [[arena, "dalga rozeti"], [combo, "kombo"], [place, "yer afişi"], [ach, "görev tostu"]]:
		var c: Control = pair[0]
		_check(c.get_global_rect().position.y >= bottom,
			"%s panelin altında (%.0f ≥ %.0f)" % [pair[1], c.get_global_rect().position.y, bottom])
	# Toast ile mekân afişi aynı anda görünürken üst üste binmemeli (ikisi de okunmalı).
	_check(ach.visible and ach.modulate.a > 0.5, "görev tostu görünür")
	_check(not ach.get_global_rect().intersects(place.get_global_rect()),
		"görev tostu afişle çakışmıyor (toast %s, afiş %s)" %
		[ach.get_global_rect(), place.get_global_rect()])
	# Masaüstünde boss çubuğu alta sabitli: telsiz onu ekrandan dışarı itmemeli.
	if boss.anchor_top == 1.0:
		_check(is_equal_approx(boss.offset_top, base_boss),
			"alttaki boss çubuğu kaymadı (%.0f)" % boss.offset_top)
	# Telsiz kapanınca taban yerine döner. Sabit delta altında birkaç saniyede kapanır; kare
	# sayısına değil koşula bağlı bekle. HUD'un UYGULADIĞI inseti (_top_inset) izle: ham
	# top_inset() 0'a inse de _follow_radio o kareyi henüz işlememiş olabilir, dalga rozeti
	# tabandan birkaç px şaşar.
	var guard := 0
	while hud._top_inset != 0.0 and guard < 2000:
		await get_tree().process_frame
		guard += 1
	_check(panel.modulate.a < 0.05, "telsiz kapandı")
	_check(is_equal_approx(arena.offset_top, base_arena),
		"dalga rozeti yerine döndü (%.0f)" % arena.offset_top)
	_finish()


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("RADIO TOP BAND FAIL: " + what)


func _finish() -> void:
	print("RADIO TOP BAND: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)
