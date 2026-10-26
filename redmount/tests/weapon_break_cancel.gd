## Son kullanımlık savuruş dash/zıplama/hasarla kesilse de silah kırılır; dayanıklılık eksiye
## inmez (tasarım denetimi Bölüm 33, 26 Ekim: HUD "Sopa -2/12" gösteriyordu).
##
##  godot --headless --path . res://tests/weapon_break_cancel.tscn
extends Node

var _fails := 0


func _ready() -> void:
	var player: CharacterBody2D = load("res://scenes/characters/Redmount.tscn").instantiate()
	player.add_to_group(&"player")
	add_child(player)
	await get_tree().process_frame
	var shown := []
	player.weapon_changed.connect(func(_n: String, uses: int, _m: int) -> void: shown.append(uses))
	player.equip_weapon(load("res://resources/weapons/bat.tres"))
	player._weapon_uses = 1
	player._start_attack(player.Attack.WEAPON)
	_check(player._weapon_uses == 0, "son savuruş kullanımı düşürdü (%d)" % player._weapon_uses)
	player._cancel_attack()
	_check(player._weapon == null, "kesilen son savuruşta silah kırıldı")
	_check(player._weapon_uses == 0, "kullanım 0'da kaldı (%d)" % player._weapon_uses)
	_check(shown.all(func(u: int) -> bool: return u >= 0), "HUD'a eksi değer gitmedi %s" % str(shown))
	# Kullanımı kalan silah kesilince elde kalır.
	player.equip_weapon(load("res://resources/weapons/bat.tres"))
	player._weapon_uses = 5
	player._start_attack(player.Attack.WEAPON)
	player._cancel_attack()
	_check(player._weapon != null and player._weapon_uses == 4, "kullanımı kalan silah elde kalır")
	print("WEAPON BREAK CANCEL: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("WEAPON BREAK CANCEL FAIL: " + what)
