## Arena dalga doğma noktası taraması (tur 370).
## `BattleArena._spawn_wave` dalganın düşmanlarını gate_left_x+80…gate_right_x−80 arasına
## eşit aralıkla, floor_y−24'e koyar. Arena içinde tezgâh, sandık, iskele ayağı ya da
## yükselen zemin varsa düşman katı cismin içinde doğar (tur 367'deki donmuş düşman sınıfı)
## ya da altında zemin yoksa çukura düşer. 36 bölümün bütün arenaları, bütün dalgaları için
## doğma gövdesi (24×50) katı cisimle ve altındaki 260 px zemin varlığıyla sorgulanır;
## arena sonu ödülü ve eli boş silahı düşme noktası da gömülülük için sorgulanır.
extends Node

const SETTLE_FRAMES := 30


func _ready() -> void:
	Save._path = "user://_arena_spawn_clear.cfg"
	var bad := 0
	var total := 0
	for i in GameState.LEVELS.size():
		var level: Node = load(GameState.LEVELS[i]).instantiate()
		add_child(level)
		for f in SETTLE_FRAMES:
			await get_tree().physics_frame
		var space := (level as Node2D).get_world_2d().direct_space_state
		for n in _all(level):
			if not (n is BattleArena):
				continue
			var a := n as BattleArena
			## Arena sonu ödülü (orta) ve eli boş silahı (orta+90), floor_y−60'ta 16×16.
			var mid := (a.gate_left_x + a.gate_right_x) * 0.5
			var drops := [Vector2(mid, a.floor_y - 60.0),
					Vector2(clampf(mid + 90.0, a.gate_left_x + 40.0, a.gate_right_x - 40.0), a.floor_y - 60.0)]
			for d in drops:
				total += 1
				var dh := _solid_at(space, d, Vector2(16, 16))
				if dh != "":
					bad += 1
					print("ARENA ODUL GOMULU bolum=%d arena=%s p=%s -> %s" % [i + 1, a.name, d, dh])
			var waves := [a.wave1, a.wave2, a.wave3]
			for wi in waves.size():
				var w: Array = waves[wi]
				var cnt: int = maxi(w.size(), 1)
				for k in w.size():
					if w[k] == null:
						continue
					total += 1
					var frac := (float(k) + 0.5) / float(cnt)
					var x := lerpf(a.gate_left_x + 80.0, a.gate_right_x - 80.0, frac)
					var p := Vector2(x, a.floor_y - 24.0)
					var hit := _solid_at(space, p + Vector2(0, -27), Vector2(24, 50))
					if hit != "":
						bad += 1
						print("ARENA GOMULU bolum=%d arena=%s dalga=%d k=%d p=%s -> %s" % [
								i + 1, a.name, wi + 1, k, p, hit])
						continue
					var rq := PhysicsRayQueryParameters2D.create(p, p + Vector2(0, 260), 1)
					if space.intersect_ray(rq).is_empty():
						bad += 1
						print("ARENA ZEMINSIZ bolum=%d arena=%s dalga=%d k=%d p=%s" % [
								i + 1, a.name, wi + 1, k, p])
		level.queue_free()
		await get_tree().process_frame
	print("ARENA DOGMA: %d dogma, %d sorunlu" % [total, bad])
	print("ARENA SPAWN CLEAR: PASS" if bad == 0 else "ARENA SPAWN CLEAR: FAIL")
	get_tree().quit(0 if bad == 0 else 1)


func _solid_at(space: PhysicsDirectSpaceState2D, center: Vector2, size: Vector2) -> String:
	var shape := RectangleShape2D.new()
	shape.size = size
	var q := PhysicsShapeQueryParameters2D.new()
	q.shape = shape
	q.transform = Transform2D(0.0, center)
	q.collision_mask = 1
	q.collide_with_areas = false
	for h in space.intersect_shape(q, 8):
		var col: Node = h.collider
		if col is CharacterBody2D or col is RigidBody2D or col is AnimatableBody2D:
			continue
		return String(col.name)
	return ""


func _all(n: Node) -> Array:
	var out := [n]
	for c in n.get_children():
		out.append_array(_all(c))
	return out
