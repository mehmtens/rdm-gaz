extends Node

## BattleArena arena sonu silahı testi (tur 258).
## Eli boş oyuncuya bir yakın silah düşer; elinde ya da yedeğinde silah olana,
## veya özellik kapalı arenada düşmez. Sahne testi (Fx autoload gerekir).

class StubPlayer extends Node2D:
	var armed := false
	var stashed := false
	func has_weapon() -> bool:
		return armed
	func has_stash() -> bool:
		return stashed


func _count_weapons() -> int:
	var n := 0
	for c in get_children():
		if c.get_script() != null and c.get(&"weapon") != null:
			n += 1
	return n


func _arena(enabled := true) -> BattleArena:
	var a := BattleArena.new()
	a.gate_left_x = 0.0
	a.gate_right_x = 640.0
	a.empty_hand_weapon = enabled
	add_child(a)
	return a


func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func _ready() -> void:
	var player := StubPlayer.new()
	player.add_to_group(&"player")
	add_child(player)

	## 1) Eli boş: tek silah, arena içinde.
	_arena()._maybe_weapon_drop()
	await _settle()
	assert(_count_weapons() == 1, "Eli boş oyuncuya arena sonu silahı düşmeliydi")

	## 2) Elinde silah var: düşmez.
	player.armed = true
	_arena()._maybe_weapon_drop()
	await _settle()
	assert(_count_weapons() == 1, "Silahlı oyuncuya ikinci silah düşmemeli")

	## 3) Yalnız yedekte silah var: düşmez.
	player.armed = false
	player.stashed = true
	_arena()._maybe_weapon_drop()
	await _settle()
	assert(_count_weapons() == 1, "Yedeği dolu oyuncuya silah düşmemeli")

	## 4) Kapalı arena: düşmez.
	player.stashed = false
	_arena(false)._maybe_weapon_drop()
	await _settle()
	assert(_count_weapons() == 1, "Kapalı arenada silah düşmemeli")

	print("ARENA WEAPON DROP: PASS")
	get_tree().quit(0)
