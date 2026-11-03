## Gizli alanların ulaşılırlığı (3 Kasım oyun testi: "gizli alanlar ulaşılamaz"): 36 bölümde
## her gizli bölgenin zeminine yerden tek zıplamalarla çıkılabilmeli (duvar zıplaması
## zinciri gerekmez). Ölçüt `DtmLevel._reachable_surfaces` ile aynı; bölüm sınıfından
## bağımsız olsun diye burada yeniden hesaplanır.
##
##  godot --headless --path . res://tests/secret_reach.tscn   (REACH_LEVEL=<0 tabanlı> tek bölüm)
extends Node

const RISE := 115.0
const GAP := 220.0
const BOUNCE_RISE := 250.0

var _fails := 0


func _ready() -> void:
	var only := OS.get_environment("REACH_LEVEL")
	var total := 0
	for i in GameState.LEVELS.size():
		if only != "" and int(only) != i:
			continue
		var lvl: Node = load(GameState.LEVELS[i]).instantiate()
		add_child(lvl)
		await get_tree().process_frame
		await get_tree().process_frame
		total += _audit(i + 1, lvl)
		lvl.queue_free()
		await get_tree().process_frame
	print("SECRET REACH: %s (%d sır)" % ["PASS" if _fails == 0 else "FAIL (%d)" % _fails, total])
	get_tree().quit(0 if _fails == 0 else 1)


func _surfaces(root: Node) -> Array:
	var out: Array = []
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		stack.append_array(n.get_children())
		if n is StaticBody2D and not n is AnimatableBody2D:
			for sh in n.get_children():
				if sh is CollisionShape2D and sh.shape is RectangleShape2D and not sh.disabled:
					var sz: Vector2 = sh.shape.size
					var p: Vector2 = (sh as Node2D).global_position
					out.append({"x0": p.x - sz.x * 0.5, "x1": p.x + sz.x * 0.5, "top": p.y - sz.y * 0.5,
						"bounce": n is AwningBounce, "ok": p.y - sz.y * 0.5 >= -20.0})
	return out


func _audit(no: int, lvl: Node) -> int:
	var surf := _surfaces(lvl)
	var queue: Array = []
	for s in surf:
		if s.ok:
			queue.append(s)
	while not queue.is_empty():
		var a: Dictionary = queue.pop_front()
		var rise := BOUNCE_RISE if a.bounce else RISE
		for b in surf:
			if b.ok:
				continue
			var dx := maxf(0.0, maxf(float(b.x0) - float(a.x1), float(a.x0) - float(b.x1)))
			var dy: float = float(a.top) - float(b.top)
			if (dy >= 0.0 and dy <= rise and dx <= GAP) or (dy < 0.0 and dx <= GAP + 100.0):
				b.ok = true
				queue.append(b)
	var count := 0
	for z in get_tree().get_nodes_in_group(&"secret_zone"):
		if not lvl.is_ancestor_of(z):
			continue
		count += 1
		# Film rulosu bölge tabanının 34 px üstünde; altındaki en yüksek yüzey sırrın zemini.
		var roll: Vector2 = (z as Node2D).global_position + z.roll_at
		var floor_y := roll.y + 34.0
		var best: Dictionary = {}
		for s in surf:
			if roll.x >= float(s.x0) - 10.0 and roll.x <= float(s.x1) + 10.0 \
					and float(s.top) >= floor_y - 40.0 and float(s.top) <= floor_y + 60.0:
				if best.is_empty() or float(s.top) < float(best.top):
					best = s
		if best.is_empty() or not best.ok:
			_fails += 1
			push_error("BASARISIZ: Bölüm %d sırrı (x=%.0f, zemin %.0f) yerden ulaşılamıyor" % [no, roll.x, floor_y])
	return count
