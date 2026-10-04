## Parkur parçası test pisti: düz sokak üstüne her ParkourSet türünü sırayla dizer.
extends Level

const GOAL := preload("res://scenes/systems/LevelGoal.tscn")
const KINDS := ["tente_duvar", "balkon", "cati", "baca", "sekme", "kasa", "iskele", "direk"]


func _ready() -> void:
	var spawn := Marker2D.new()
	spawn.name = "PlayerSpawn"
	spawn.position = Vector2(80, -40)
	add_child(spawn)
	var ground := StaticBody2D.new()
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(13000, 200)
	col.shape = shape
	ground.position = Vector2(6300, 100)
	ground.add_child(col)
	var vis := Polygon2D.new()
	vis.name = "Vis"
	vis.polygon = PackedVector2Array([Vector2(-6500, -100), Vector2(6500, -100), Vector2(6500, 100), Vector2(-6500, 100)])
	ground.add_child(vis)
	add_child(ground)
	var x := 500.0
	for k in KINDS:
		var p := ParkourSet.new()
		p.kind = k
		p.variant = 1
		p.position = Vector2(x, 0)
		add_child(p)
		print("SET %s x=%.0f..%.0f" % [k, x, x + ParkourSet.width_of(k)])
		x += ParkourSet.width_of(k) + 400.0
	var goal := GOAL.instantiate()
	goal.position = Vector2(x + 200, 0)
	add_child(goal)
	camera_limit_right = int(x + 600)
	super._ready()
