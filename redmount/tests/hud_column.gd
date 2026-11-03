## HUD sol sütunu (tur 121): boş satır yer tutmaz. Yakın silah yokken mermi satırı silah
## satırının yerine çıkar; silah alınınca satırlar eski yerlerine döner. Mahalle paneli ve
## sokak yerleşiminin ikisinde de denenir.
##
##  godot --headless --path . res://tests/hud_column.tscn
extends Node

var _fails := 0


func _ready() -> void:
	var hud: Control = load("res://scenes/ui/HUD.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame
	var weapon := hud.get_node(^"WeaponLabel") as Label
	var ammo := hud.get_node(^"AmmoLabel") as Label
	var armor := hud.get_node(^"ArmorLabel") as Label
	for level: int in [3, 0]:
		GameState.level_index = level
		hud.set_level_context(level)
		hud.set_weapon("Sopa", 3, 10)
		hud.set_ammo(6, 18, true)
		hud.set_armor("Yelek", 2, 6)
		var w0 := weapon.position
		var a0 := ammo.position
		var r0 := armor.position
		_check(a0.y > w0.y and r0.y > a0.y, "B%d: dolu sütun sıralı" % level)
		hud.set_weapon("", 0, 0)
		_check(weapon.text.is_empty(), "B%d: silahsız satır boş" % level)
		_check(ammo.position == w0, "B%d: mermi silah satırına çıktı (%s)" % [level, ammo.position])
		_check(armor.position == a0, "B%d: zırh bir satır yukarı (%s)" % [level, armor.position])
		hud.set_ammo(0, 0, false)
		_check(armor.position == w0, "B%d: yalnız zırh ilk satırda" % level)
		hud.set_weapon("Sopa", 3, 10)
		hud.set_ammo(6, 18, true)
		_check(weapon.position == w0 and ammo.position == a0 and armor.position == r0,
			"B%d: satırlar eski yerine döndü" % level)
	print("HUD COLUMN: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
