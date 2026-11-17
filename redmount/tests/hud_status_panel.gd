## HUD durum plakası (Tur 215): her bölümde görünür, görünen satırları (can, coin, silah,
## mermi, zırh, güç) çerçeve payıyla sarar; boş satır plakayı uzatmaz; mahallede portre
## can çubuğuna binmez.
##
##  godot --headless --path . res://tests/hud_status_panel.tscn
extends Node

var _fails := 0


func _ready() -> void:
	var hud: Node = load("res://scenes/ui/HUD.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame
	for idx in [0, 5, 29]:
		hud.set_level_context(idx)
		hud.set_ammo(18, 54, true)
		hud.set_armor("Zırh", 5, 6)
		await get_tree().process_frame
		var panel: Control = hud._neighborhood_panel
		_check(panel.visible, "Bölüm %d: plaka görünür" % (idx + 1))
		var pr := Rect2(panel.position, panel.size)
		for c: Control in [hud.get_node(^"HealthBg"), hud._coins, hud._ammo, hud._armor]:
			var cr := Rect2(c.position, c.get_combined_minimum_size())
			_check(pr.grow(-8.0).encloses(cr), "Bölüm %d: %s plakanın içinde (%s ⊄ %s)" % [idx + 1, c.name, cr, pr])
		if idx == 0:
			var p: Control = hud._neighborhood_portrait
			_check(p.position.x + p.size.x * p.scale.x <= hud.get_node(^"HealthBg").position.x,
				"portre can çubuğuna binmiyor")
		var full_h := panel.size.y
		hud.set_armor("", 0, 0)
		hud.set_ammo(0, 0, false)
		await get_tree().process_frame
		_check(panel.size.y < full_h - 30.0, "Bölüm %d: boş satırlar plakayı kısaltır" % (idx + 1))
	print("HUD STATUS PANEL: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BAŞARISIZ: " + what)
