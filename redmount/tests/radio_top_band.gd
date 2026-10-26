## Telsiz paneli üst bandı örtmez (tasarım denetimi Bölüm 16, 26 Ekim): telsiz konuşurken
## dalga rozeti, kombo, yer afişi ve boss çubuğu panelin altına kayar, bitince geri döner.
##
##  godot --headless --path . res://tests/radio_top_band.tscn
extends Node

var _fails := 0


func _ready() -> void:
	var hud: Control = load("res://scenes/ui/HUD.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame
	hud.set_arena_wave(1, 3, 4)
	hud.show_place("FİLM RULOSU 1 / 3", "deneme", Color("ffd34e"))
	hud._flash_big_combo(5, 45)
	await _frames(3)
	var arena: Control = hud._arena_panel
	var combo: Control = hud._combo
	var place: Control = hud._place
	var base_arena := arena.offset_top
	RadioPanel.say(get_tree(), "redmount", "REDMOUNT", "Kâğıt kokusu artık barut kokusu.")
	await _frames(40)
	var panel: Control = RadioPanel._instance._panel
	_check(panel.modulate.a > 0.99, "telsiz açıldı")
	var bottom := panel.get_global_rect().end.y
	for pair in [[arena, "dalga rozeti"], [combo, "kombo"], [place, "yer afişi"]]:
		var c: Control = pair[0]
		_check(c.get_global_rect().position.y >= bottom,
			"%s panelin altında (%.0f ≥ %.0f)" % [pair[1], c.get_global_rect().position.y, bottom])
	# Telsiz kapanınca taban yerine döner.
	await _frames(400)
	_check(panel.modulate.a < 0.01, "telsiz kapandı")
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
