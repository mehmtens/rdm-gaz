## Bölüm denetimi: kampanya bölümlerini yükleyip geometriyi ve yerleşimi tarar.
##
##  godot --headless --path . res://tests/level_audit.tscn
##  AUDIT_LEVELS=0,12  → yalnız bu indeksler (boşsa tümü)
##
## Bildirilen sorunlar:
##  ENEMY_AIR     düşman doğduğu yerde katı zemin yok (tek yön platformu göremez, düşer)
##  ENEMY_SOLID   düşman katı gövdenin içinde doğuyor
##  ITEM_SOLID    coin / ödül katı gövdenin içinde
##  ITEM_HIGH     coin / ödül altındaki her yüzeyden 250 px'ten yüksekte (alınamaz)
##  PLAT_UNREACH  platforma hiçbir yüzeyden zıplanarak çıkılamıyor
##  PLAT_INSIDE   tek yön platform katı gövdenin içinde
## Ayrıca bölüm başına özet: uzunluk, düşman sayısı, düşman yoğunluğu, en uzun düşmansız
## düz koşu, tehlike (diken / boşluk / hareketli) sayısı.
extends Node

const JUMP_UP := 125.0
const JUMP_ACROSS := 250.0
const ITEM_REACH := 250.0

var _out: Array = []


func _ready() -> void:
	await get_tree().process_frame
	var gs: Node = GameState
	var only := OS.get_environment("AUDIT_LEVELS")
	var indices: Array = []
	if only.is_empty():
		indices = range(gs.LEVELS.size())
	else:
		for s in only.split(","):
			indices.append(int(s))
	for i in indices:
		gs.level_index = i
		var lvl: Node = load(gs.LEVELS[i]).instantiate()
		add_child(lvl)
		await get_tree().process_frame
		await get_tree().physics_frame
		var start := {}
		for e in get_tree().get_nodes_in_group(&"enemy_ai"):
			if lvl.is_ancestor_of(e):
				start[e] = (e as Node2D).global_position
		_audit(i, lvl)
		# Dinamik doğrulama: 1,5 sn fizik; 60 px'ten fazla düşen düşman gerçekten havadaydı.
		for k in 90:
			await get_tree().physics_frame
		for e in start:
			if is_instance_valid(e) and (e as Node2D).global_position.y - start[e].y > 60.0:
				print("   ENEMY_FELL x=%d y=%d -> y=%d %s" % [start[e].x, start[e].y, (e as Node2D).global_position.y, _name(e)])
		lvl.queue_free()
		await get_tree().process_frame
	get_tree().quit()


func _audit(idx: int, lvl: Node) -> void:
	var solids: Array = []   # Rect2
	var ones: Array = []     # [Rect2, node]
	var hazards := 0
	var bounces: Array = []  # tente sıçrayış yüzeyleri (~345 px fırlatır)
	var enemies: Array = []
	var items: Array = []
	for n in _all(lvl):
		if not _active(n):
			continue
		if n is AnimatableBody2D:
			hazards += 1
			# Hareketli platform yolunun tamamı basılabilir alan sayılır.
			var travel: Vector2 = n.get("travel") if n.get("travel") != null else Vector2.ZERO
			for r in _rects(n):
				ones.append([r.merge(Rect2(r.position + travel, r.size)), n])
			continue
		if n is StaticBody2D:
			var sb := n as StaticBody2D
			if sb is AwningBounce:
				for r in _rects(sb):
					bounces.append(r)
			for r in _rects(sb):
				if sb.collision_layer & 1:
					solids.append(r)
				elif sb.collision_layer & 128:
					ones.append([r, n])
			continue
		if n.is_in_group(&"hazard"):
			hazards += 1
		if n.is_in_group(&"enemy_ai"):
			enemies.append(n)
		elif n.is_in_group(&"coin") or (n is Area2D and n.has_method(&"_on_body_entered") and n.get_script() != null \
				and str(n.get_script().resource_path).contains("pickups")):
			items.append(n)
	var issues: Array = []
	# AUDIT_PROBE="x,y;x,y": bu noktaları kapsayan / 150 px yakınındaki gövdeleri yaz.
	for spec in OS.get_environment("AUDIT_PROBE").split(";", false):
		var q := Vector2(float(spec.split(",")[0]), float(spec.split(",")[1]))
		for n in _all(lvl):
			if n is CollisionObject2D and _active(n):
				for r in _rects(n):
					if r.grow(150.0).has_point(q):
						print("   PROBE %s -> %s %s layer=%d rect=%s" % [q, n.name, n.get_parent().name, (n as CollisionObject2D).collision_layer, r])
	# Düşmanlar
	for e in enemies:
		var p: Vector2 = (e as Node2D).global_position
		if _inside(solids, p + Vector2(0, -40)):
			issues.append("ENEMY_SOLID x=%d y=%d %s" % [p.x, p.y, _name(e)])
		elif not _floor_below(solids, p, 24.0) and not _floor_below(ones.map(func(o): return o[0]), p, 24.0):
			issues.append("ENEMY_AIR x=%d y=%d %s" % [p.x, p.y, _name(e)])
	# Ödüller
	var surfaces: Array = solids.duplicate()
	for o in ones:
		surfaces.append(o[0])
	for it in items:
		var p: Vector2 = (it as Node2D).global_position
		if _inside(solids, p):
			issues.append("ITEM_SOLID x=%d y=%d %s" % [p.x, p.y, _name(it)])
			continue
		# Coin dizileri iki platform arasındaki sıçrayış yayını çizer: ±150 px içindeki
		# yüzeylerden ulaşılabiliyorsa sorun yok.
		var below := _surface_below(surfaces, p, 150.0)
		if _bounce_reach(bounces, p):
			continue
		if below == INF:
			issues.append("ITEM_HIGH x=%d y=%d %s (altında yüzey yok)" % [p.x, p.y, _name(it)])
		elif below - p.y > ITEM_REACH:
			issues.append("ITEM_HIGH x=%d y=%d %s (%d px)" % [p.x, p.y, _name(it), below - p.y])
	# Platformlar
	for o in ones:
		var r: Rect2 = o[0]
		var node: Node = o[1]
		if node is AnimatableBody2D:
			continue
		if _overlaps_solid(solids, r):
			issues.append("PLAT_INSIDE x=%d y=%d w=%d" % [r.get_center().x, r.position.y, r.size.x])
		if not _reachable(r, surfaces) and not _bounce_reach(bounces, r.position + Vector2(r.size.x * 0.5, 0)):
			issues.append("PLAT_UNREACH x=%d y=%d w=%d" % [r.get_center().x, r.position.y, r.size.x])
	# Özet
	var left: float = lvl.camera_limit_left
	var right: float = lvl.camera_limit_right
	var xs: Array = []
	for e in enemies:
		xs.append((e as Node2D).global_position.x)
	xs.sort()
	var longest := 0.0
	var prev := left
	for x in xs:
		longest = maxf(longest, x - prev)
		prev = x
	longest = maxf(longest, right - prev)
	var arenas := 0
	for n in _all(lvl):
		if n is BattleArena:
			arenas += 1
	print("AUDIT %02d %-28s len=%6d enemies=%3d (1/%5d px) arenas=%d hazards=%d longest_empty=%6d ones=%d issues=%d" % [
		idx + 1, lvl.get("display_name"), right - left, enemies.size(),
		int((right - left) / maxf(enemies.size(), 1)), arenas, hazards, longest, ones.size(), issues.size()])
	for s in issues:
		print("   ", s)


func _reachable(r: Rect2, surfaces: Array) -> bool:
	for s in surfaces:
		if s == r:
			continue
		var rise: float = s.position.y - r.position.y   # >0: s daha aşağıda
		var gap: float = maxf(0.0, maxf(s.position.x - r.end.x, r.position.x - s.end.x))
		if rise <= 0.0 and gap <= JUMP_ACROSS:
			return true   # aynı seviyede ya da yukarıdan inilebilir
		if rise > 0.0 and rise <= 90.0 and gap <= JUMP_ACROSS:
			return true
		if rise > 90.0 and rise <= JUMP_UP and gap <= 160.0:
			return true
	return false


## Tente sıçrayışıyla ulaşılır mı: yakın bir tentenin 360 px üstüne kadar.
func _bounce_reach(bounces: Array, p: Vector2) -> bool:
	for b in bounces:
		if p.x > b.position.x - 280.0 and p.x < b.end.x + 280.0 and p.y >= b.position.y - 360.0 and p.y < b.position.y:
			return true
	return false


func _floor_below(solids: Array, p: Vector2, tol: float) -> bool:
	for s in solids:
		if p.x >= s.position.x - 4.0 and p.x <= s.end.x + 4.0 and absf(s.position.y - p.y) <= tol:
			return true
	return false


func _surface_below(surfaces: Array, p: Vector2, half_w: float) -> float:
	var best := INF
	for s in surfaces:
		if s.end.x >= p.x - half_w and s.position.x <= p.x + half_w and s.position.y >= p.y - 4.0:
			best = minf(best, s.position.y)
	return best


func _inside(solids: Array, p: Vector2) -> bool:
	for s in solids:
		if s.grow(-6.0).has_point(p):
			return true
	return false


func _overlaps_solid(solids: Array, r: Rect2) -> bool:
	for s in solids:
		if s.grow(-8.0).intersects(r.grow(-2.0)):
			return true
	return false


func _rects(body: CollisionObject2D) -> Array:
	var out: Array = []
	for c in body.get_children():
		if c is CollisionShape2D and not (c as CollisionShape2D).disabled and (c as CollisionShape2D).shape is RectangleShape2D:
			var cs := c as CollisionShape2D
			var size := (cs.shape as RectangleShape2D).size * cs.global_scale.abs()
			out.append(Rect2(cs.global_position - size * 0.5, size))
	return out


func _name(n: Node) -> String:
	var s = n.get_script()
	if n.scene_file_path != "":
		return n.scene_file_path.get_file().get_basename()
	return str(s.resource_path.get_file().get_basename()) if s else n.get_class()


func _active(n: Node) -> bool:
	if n.process_mode == Node.PROCESS_MODE_DISABLED or n.is_queued_for_deletion():
		return false
	return not (n is CanvasItem) or (n as CanvasItem).is_visible_in_tree()


func _all(root_node: Node) -> Array:
	var out: Array = []
	var stack: Array = [root_node]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for c in n.get_children():
			out.append(c)
			stack.append(c)
	return out
