## İki nişancı üst üste durmaz (tasarım denetimi Bölüm 10, 26 Ekim): oyuncu çok yakınken geri
## çekilen iki Tüfekli Muhafız arkadaki duvara (arena kapısı) yaslanıp yığılmaz, kademeli
## hatta açılır; ikisi de ayrı okunur.
##
##  godot --headless --path . --fixed-fps 60 res://tests/ranged_spacing.tscn
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
	# Arena kapısı gibi arkadaki duvar.
	var wall := StaticBody2D.new()
	var wshape := CollisionShape2D.new()
	var wrect := RectangleShape2D.new()
	wrect.size = Vector2(40, 400)
	wshape.shape = wrect
	wall.position = Vector2(460, -180)
	wall.add_child(wshape)
	add_child(wall)
	var target := _Target.new()
	target.add_to_group(&"player")
	target.position = Vector2(180, -24)
	add_child(target)
	var scene := load("res://scenes/enemies/RifleGuard.tscn") as PackedScene
	var guards: Array[Node2D] = []
	for i in 2:
		var g: Node2D = scene.instantiate()
		g.position = Vector2(330.0 + i * 30.0, -24)
		add_child(g)
		guards.append(g)
	for i in 300:
		await get_tree().physics_frame
		if OS.has_environment("SPACING_TRACE") and i % 30 == 0:
			print("t%d  %.0f s%d  %.0f s%d" % [i, guards[0].global_position.x, guards[0]._state,
				guards[1].global_position.x, guards[1]._state])
	var gap := absf(guards[0].global_position.x - guards[1].global_position.x)
	_check(gap >= 56.0, "iki nişancı arası ≥ 56 px (%.0f)" % gap)
	for g in guards:
		_check(g.global_position.x > 200.0 and g.global_position.x < 440.0,
			"nişancı menzilde kaldı (x %.0f)" % g.global_position.x)
	print("RANGED SPACING: %s (aralık %.0f px)" % ["PASS" if _fails == 0 else "FAIL (%d)" % _fails, gap])
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("RANGED SPACING FAIL: " + what)
