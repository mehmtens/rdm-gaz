## Parkur sahnesi denetimi (Kitap 2–3): her sahnenin nöbetçisi, kontrol noktası ve
## arena ilişkisi. Sahne olarak çalışır (autoload gerekir):
##
##  godot --headless --path . res://tests/encounter_check.tscn
##
## Bildirilen sorunlar:
##  GUARD_LEFT     nöbetçi 2 sn fizikte sahnesinin dışına çıktı / düştü
##  CP_IN_ARENA    kontrol noktası kilitli arenanın kapıları arasında
##  CP_CROWDED     iki kontrol noktası 700 px'ten yakın
##  NO_CP          sahneden önceki 2.500 px'de kontrol noktası yok
##  SET_IN_ARENA   sahne arena kapılarıyla çakışıyor
extends Node


func _ready() -> void:
	await get_tree().process_frame
	var gs: Node = GameState
	var issues_total := 0
	var kinds := {}
	for i in range(12, gs.LEVELS.size()):
		gs.level_index = i
		var lvl: Node = load(gs.LEVELS[i]).instantiate()
		add_child(lvl)
		await get_tree().process_frame
		await get_tree().physics_frame
		var sets: Array = []
		var cps: Array = []
		var arenas: Array = []
		for c in lvl.get_children():
			if c is ParkourSet:
				sets.append(c)
				kinds[c.kind] = int(kinds.get(c.kind, 0)) + 1
			elif c.is_in_group(&"checkpoint"):
				cps.append((c as Node2D).global_position.x)
			elif c is BattleArena:
				arenas.append(c)
		cps.sort()
		# Her sahnenin nöbetçileri: sahnenin x aralığındaki düşmanlar.
		var guards := {}
		for e in get_tree().get_nodes_in_group(&"enemy_ai"):
			if not lvl.is_ancestor_of(e):
				continue
			var p: Vector2 = (e as Node2D).global_position
			for s in sets:
				var sx: float = (s as Node2D).global_position.x
				if p.x >= sx and p.x <= sx + ParkourSet.width_of(s.kind):
					guards[e] = [s, p]
		for k in 120:
			await get_tree().physics_frame
		var issues: Array = []
		for e in guards:
			var s: ParkourSet = guards[e][0]
			var p0: Vector2 = guards[e][1]
			if not is_instance_valid(e):
				continue
			var p: Vector2 = (e as Node2D).global_position
			var sx: float = s.global_position.x
			if p.y - p0.y > 30.0 or p.x < sx - 60.0 or p.x > sx + ParkourSet.width_of(s.kind) + 60.0:
				issues.append("GUARD_LEFT %s@%d (%d,%d)->(%d,%d)" % [s.kind, sx, p0.x, p0.y, p.x, p.y])
		for a in arenas:
			var b: BattleArena = a
			for cx in cps:
				if cx > b.gate_left_x and cx < b.gate_right_x:
					issues.append("CP_IN_ARENA cp=%d arena=%d..%d" % [cx, b.gate_left_x, b.gate_right_x])
			for s in sets:
				var sx: float = (s as Node2D).global_position.x
				if sx < b.gate_right_x and sx + ParkourSet.width_of(s.kind) > b.gate_left_x:
					issues.append("SET_IN_ARENA %s@%d arena=%d..%d" % [s.kind, sx, b.gate_left_x, b.gate_right_x])
		for j in range(1, cps.size()):
			if cps[j] - cps[j - 1] < 700.0:
				issues.append("CP_CROWDED %d %d" % [cps[j - 1], cps[j]])
		for s in sets:
			var sx: float = (s as Node2D).global_position.x
			var ok := false
			for cx in cps:
				if cx <= sx and cx >= sx - 2500.0:
					ok = true
			if not ok and sx > 2500.0:
				issues.append("NO_CP %s@%d" % [s.kind, sx])
		var seq: Array = []
		for s in sets:
			seq.append(s.kind)
		print("ENC %02d %-34s sets=%d guards=%d cps=%d issues=%d  %s" % [i + 1, lvl.get("display_name"),
			sets.size(), guards.size(), cps.size(), issues.size(), ",".join(seq)])
		for t in issues:
			print("   ", t)
		issues_total += issues.size()
		lvl.queue_free()
		await get_tree().process_frame
	print("ENC kinds=", kinds, " issues_total=", issues_total)
	get_tree().quit()
