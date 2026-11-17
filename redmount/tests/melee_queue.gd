## Yakın dövüşçüler sıraya girer (tur 272, denetim Bölüm 15/30): aynı taraftan gelen üç
## yakın dövüşçü oyuncunun önünde tek noktaya yığılmaz; öndeki saldırır, arkadakiler
## aralıklı bekler, öndeki düşünce sıradaki ilerler.
##
##  godot --headless --path . --fixed-fps 60 res://tests/melee_queue.tscn
extends Node

class _Target extends Node2D:
	func get_health() -> int:
		return 100

var _fails := 0


func _ready() -> void:
	var floor := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(4000, 40)
	shape.shape = rect
	floor.position = Vector2(0, 20)
	floor.add_child(shape)
	add_child(floor)
	var target := _Target.new()
	target.add_to_group(&"player")
	target.position = Vector2(0, -24)
	add_child(target)
	var kinds := ["StreetThug", "ArmoredBruiser", "StreetThug"]
	var crowd: Array[Node2D] = []
	for i in kinds.size():
		var e: Node2D = (load("res://scenes/enemies/%s.tscn" % kinds[i]) as PackedScene).instantiate()
		e.position = Vector2(380.0 + i * 25.0, -24)
		add_child(e)
		crowd.append(e)
	for i in 300:
		await get_tree().physics_frame
		if OS.has_environment("QUEUE_TRACE") and i % 30 == 0:
			print("t%d  %s" % [i, ", ".join(crowd.map(func(e): return "%.0f s%d" % [e.global_position.x, e._state]))])
	var xs := _sorted_x(crowd)
	var g1: float = xs[1] - xs[0]
	var g2: float = xs[2] - xs[1]
	_check(xs[0] < 90.0, "öndeki oyuncuya ulaştı (x %.0f)" % xs[0])
	_check(g1 >= 48.0 and g2 >= 48.0, "sıra aralıkları ≥ 48 px (%.0f, %.0f)" % [g1, g2])
	_check(xs[2] < 300.0, "sıra dağılmadı, arkadaki yakında (x %.0f)" % xs[2])
	# Öndeki düşer: sıradaki boşluğu kapatıp oyuncuya ulaşır.
	var front := _front(crowd)
	crowd.erase(front)
	front.queue_free()
	for i in 180:
		await get_tree().physics_frame
	var after := _sorted_x(crowd)
	_check(after[0] < 90.0, "sıradaki ilerledi (x %.0f)" % after[0])
	print("MELEE QUEUE: %s (aralık %.0f/%.0f px, sonra ön %.0f)" % [
		"PASS" if _fails == 0 else "FAIL (%d)" % _fails, g1, g2, after[0]])
	get_tree().quit(0 if _fails == 0 else 1)


func _sorted_x(crowd: Array[Node2D]) -> Array:
	var xs := []
	for e in crowd:
		xs.append(e.global_position.x)
	xs.sort()
	return xs


func _front(crowd: Array[Node2D]) -> Node2D:
	var best: Node2D = crowd[0]
	for e in crowd:
		if e.global_position.x < best.global_position.x:
			best = e
	return best


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("MELEE QUEUE FAIL: " + what)
