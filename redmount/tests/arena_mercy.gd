extends Node

## BattleArena dalga arası "nefes" ödülü testi (tur 250).
## Düşük canlı oyuncu bir dalgayı kapatınca arena bir kez can yemeği düşürür;
## tam canlı oyuncuya veya ikinci kez düşmez. Sahne testi (Fx autoload gerekir).

class StubPlayer extends Node2D:
	var hp := 20
	func get_health() -> int:
		return hp
	func get_max_health() -> int:
		return 115
	func heal(_a: int) -> void:
		pass


func _count_food() -> int:
	var n := 0
	for c in get_children():
		if c is Node2D and String(c.name).begins_with("HealthPickup"):
			n += 1
	return n


func _ready() -> void:
	var player := StubPlayer.new()
	player.add_to_group(&"player")
	add_child(player)

	var arena := BattleArena.new()
	arena.gate_left_x = 0.0
	arena.gate_right_x = 640.0
	arena.floor_y = 0.0
	## İki sahte dalga: ilk dalga kapandığında sıradaki beklediği için nefes penceresi açık.
	arena._waves = [[], []]
	arena._wave_idx = 1
	arena._alive = []
	add_child(arena)

	## 1) Düşük canla (20/115 ≈ %17 < %35) tek düşüş.
	player.hp = 20
	arena._maybe_mercy_drop()
	await get_tree().process_frame
	await get_tree().process_frame
	assert(_count_food() == 1, "Düşük canlı oyuncuya nefes yemeği düşmeliydi")

	## 2) Aynı arenada ikinci kez düşmez.
	arena._maybe_mercy_drop()
	await get_tree().process_frame
	assert(_count_food() == 1, "Arena başına en fazla bir nefes yemeği düşmeli")

	## 3) Yeni arena + tam can: hiç düşmez.
	var arena2 := BattleArena.new()
	arena2.gate_left_x = 0.0
	arena2.gate_right_x = 640.0
	arena2._waves = [[], []]
	arena2._wave_idx = 1
	arena2._alive = []
	add_child(arena2)
	player.hp = 115
	arena2._maybe_mercy_drop()
	await get_tree().process_frame
	await get_tree().process_frame
	assert(_count_food() == 1, "Tam canlı oyuncuya nefes yemeği düşmemeli")

	## 4) Kapalıyken düşmez.
	var arena3 := BattleArena.new()
	arena3.gate_left_x = 0.0
	arena3.gate_right_x = 640.0
	arena3._waves = [[], []]
	arena3._wave_idx = 1
	arena3._alive = []
	arena3.mercy_between_waves = false
	add_child(arena3)
	player.hp = 10
	arena3._maybe_mercy_drop()
	await get_tree().process_frame
	await get_tree().process_frame
	assert(_count_food() == 1, "Kapalı arenada nefes yemeği düşmemeli")

	print("ARENA MERCY: PASS")
	get_tree().quit(0)
