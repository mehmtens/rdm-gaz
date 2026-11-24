## Kilitli arenada kameranın gezebildiği aralıkta (kapı ± yarım ekran) arka plan resmi
## değişmemeli: dövüşün ortasında resim değişince oyuncu "hangi yerdeyim" okumasını kaybeder,
## kamera eşiğin üstünde durursa (tur 388: Bölüm 24 servis kulesi) iki resim gidip gelir.
## Tur 37 yalnız son arenaları, tur 387 tek bölümü düzeltmişti; bu test her arenayı tarar.
##
##  godot --headless --path . res://tests/arena_sky_split.tscn
extends Node

const SKY_BLEND := 240.0


func _cell(cells: Array, x: float) -> int:
	var cur := 0
	for k in cells.size():
		if x >= float(cells[k][1]) - SKY_BLEND * 0.5:
			cur = k
	return cur


func _ready() -> void:
	var bad := 0
	var checked := 0
	for i in GameState.LEVELS.size():
		var lvl: Node = (load(GameState.LEVELS[i]) as PackedScene).instantiate()
		add_child(lvl)
		await get_tree().process_frame
		var cells: Array = lvl.sky_cells
		var hw := 320.0
		var p := get_tree().get_first_node_in_group(&"player")
		if p != null and p.get_node_or_null(^"Camera2D") != null:
			hw = 640.0 / (p.get_node(^"Camera2D") as Camera2D).zoom.x
		for a in get_tree().get_nodes_in_group(&"battle_arena"):
			if not lvl.is_ancestor_of(a) or not a.lock_camera:
				continue
			var lo: float = a.gate_left_x + hw
			var hi: float = a.gate_right_x - hw
			if lo > hi:
				lo = (a.gate_left_x + a.gate_right_x) * 0.5
				hi = lo
			checked += 1
			if cells.size() > 1 and _cell(cells, lo) != _cell(cells, hi):
				bad += 1
				print("BÖLÜNMÜŞ: Bölüm %d arena %d–%d (kamera %d–%d)" % [i + 1, int(a.gate_left_x), int(a.gate_right_x), int(lo), int(hi)])
		lvl.free()
	if checked == 0 or bad > 0:
		print("ARENA SKY SPLIT: FAIL (%d arena, %d bölünmüş)" % [checked, bad])
		get_tree().quit(1)
	else:
		print("ARENA SKY SPLIT: PASS (%d arena)" % checked)
		get_tree().quit(0)
