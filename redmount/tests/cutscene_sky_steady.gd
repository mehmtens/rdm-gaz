## Hikâye sahnesi sırasında arka plan değişmesin (tur 389).
## Tetikli her hikâye sahnesine koşarak yaklaşır, sahneyi oynatır ve sahne boyunca gökyüzü
## hedef hücresinin değişip değişmediğini yazar. Sahne kamerası kayınca eşik aşılıyor, perde
## konuşmanın ortasında süpürüyordu (Bölüm 13, 18, 24, 35, 36'da 7 sahne). Varsayılan bu
## bölümler; `PROBE_LEVELS=0,1,...` (0 tabanlı) ya da `PROBE_LEVELS=all` ile genişler.
## Sahne başında zaten süren geçişin bitmesi (GECISTE) hata sayılmaz.
extends Node

const DEFAULT_LEVELS := [12, 17, 23, 34, 35]

var _sky: Node
var _bad := 0


func _find_sky(n: Node) -> Node:
	if n.has_method("target_cell") and n.has_method("settled"):
		return n
	for c in n.get_children():
		var r := _find_sky(c)
		if r != null:
			return r
	return null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var only := OS.get_environment("PROBE_LEVELS")
	var levels: Array = DEFAULT_LEVELS.duplicate()
	if only == "all":
		levels = range(GameState.LEVELS.size())
	elif only != "":
		levels = []
		for s in only.split(","):
			levels.append(int(s))
	Save._path = "user://_cutscene_sky_steady.cfg"
	for li in levels:
		await _probe(li)
	if _bad == 0:
		print("CUTSCENE SKY STEADY: PASS")
	else:
		print("CUTSCENE SKY STEADY: FAIL (%d sahne)" % _bad)
	get_tree().quit(1 if _bad > 0 else 0)


func _probe(li: int) -> void:
	GameState.level_path_override = GameState.LEVELS[li]
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	var player: Node2D = main.get_node(^"Redmount")
	for i in 30:
		await get_tree().process_frame
		if Cutscene.active != null:
			Cutscene.active._skip = true
	while Cutscene.active != null:
		await get_tree().process_frame
	for a in get_tree().get_nodes_in_group(&"battle_arena"):
		a.queue_free()
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		e.queue_free()
	player.set_physics_process(false)
	_sky = _find_sky(main)
	var cells: Array = _sky.level.sky_cells
	var scenes: Array = []
	for c in _sky.level.get_children():
		if c is Cutscene and c.trigger_x >= 0.0:
			scenes.append(c)
	scenes.sort_custom(func(a, b): return a.trigger_x < b.trigger_x)
	for cs in scenes:
		var y: float = player.global_position.y
		player.global_position = Vector2(cs.trigger_x - 420.0, y)
		for i in 200:
			await get_tree().process_frame
		## Koşarak yaklaş (~340 px/sn, koşu hızı).
		var px: float = cs.trigger_x - 420.0
		while px < cs.trigger_x - 1.0:
			px = minf(px + 5.6, cs.trigger_x - 1.0)
			player.global_position = Vector2(px, y)
			await get_tree().process_frame
		var pre_to: int = _sky._to
		var pre_settled: bool = _sky.settled()
		cs.force_start = true
		player.global_position = Vector2(cs.trigger_x + 1.0, y)
		var started := false
		var changes: Array = []
		var lo := INF
		var hi := -INF
		var last: int = _sky._to
		var frames := 0
		var trans_frames := 0
		for i in 6000:
			await get_tree().process_frame
			if Cutscene.active == cs:
				started = true
				frames += 1
				var cx: float = _sky.global_position.x
				lo = minf(lo, cx)
				hi = maxf(hi, cx)
				if not _sky.settled():
					trans_frames += 1
				if _sky._to != last:
					changes.append("%d->%d@%d(f%d)" % [last, _sky._to, int(cx), frames])
					last = _sky._to
			elif started:
				break
		var thr := []
		for k in cells.size():
			var t: float = float(cells[k][1]) - 120.0
			if t > lo - 600 and t < hi + 600:
				thr.append(int(cells[k][1]))
		var flag := "OK"
		if changes.size() > 0:
			flag = "DEGISIYOR"
			_bad += 1
		elif trans_frames > 0:
			flag = "GECISTE"
		print("B%02d sahne@%d %s kamera %d..%d kare %d gecis %d pre_settled=%s esikler %s %s" % [li + 1, int(cs.trigger_x), flag, int(lo), int(hi), frames, trans_frames, pre_settled, str(thr), str(changes)])
	main.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
