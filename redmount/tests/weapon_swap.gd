## Silah değiştirme (oyun testi geri bildirimi, 3 Kasım): yeni silah alınınca eldeki
## yedeğe geçer, swap_weapon yer değiştirir, kırılınca yedek ele gelir, ölümde silinir.
##
##  godot --headless --path . res://tests/weapon_swap.tscn
extends Node

var _fails := 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _ready() -> void:
	var bat: WeaponConfig = load("res://resources/weapons/bat.tres")
	var knife: WeaponConfig = load("res://resources/weapons/knife.tres")
	var p: Node = (load("res://scenes/characters/Redmount.tscn") as PackedScene).instantiate()
	add_child(p)
	await get_tree().process_frame
	var stashed: Array = []
	p.stash_changed.connect(func(n: String) -> void: stashed.append(n))
	p.equip_weapon(bat)
	_check(not p.has_stash(), "ilk silah yedeğe düşmez")
	p.equip_weapon(knife)
	_check(p._weapon == knife and p._stash == bat, "yeni silah ele, eski yedeğe")
	_check(stashed.back() == bat.display_name, "HUD yedeği öğrenmeli")
	p._weapon_uses = 3
	p.swap_weapon()
	_check(p._weapon == bat and p._stash == knife and p._stash_uses == 3, "değiştir yer değiştirir, kullanım korunur")
	p.swap_weapon()
	_check(p._weapon == knife and p._weapon_uses == 3, "geri değiştir")
	p._drop_weapon(true)
	_check(p._weapon == bat and not p.has_stash(), "kırılınca yedek ele gelir")
	p.swap_weapon()
	_check(p._weapon == null and p._stash == bat, "yedeksiz değiştir: yumruğa dön, silah yedekte")
	p.revive()
	_check(p._weapon == null and not p.has_stash(), "yeniden doğuşta yedek silinir")
	print("WEAPON SWAP: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)
