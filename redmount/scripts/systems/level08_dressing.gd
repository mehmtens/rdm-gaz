extends Node2D

const ATLAS := preload("res://assets/backgrounds/level08_rail_atlas.png")
const CUTS := [5000.0, 10000.0, 15000.0]
var _camera: Camera2D


func _ready() -> void:
	z_index = -80
	z_as_relative = false


func _process(_delta: float) -> void:
	if _camera == null:
		_camera = get_viewport().get_camera_2d()
		if _camera == null:
			return
	global_position = _camera.get_screen_center_position()
	queue_redraw()


func _draw() -> void:
	var x := global_position.x
	var scene := 0
	for cut in CUTS:
		if x >= cut:
			scene += 1
	_draw_scene(scene, 1.0)
	if scene < CUTS.size() and x > CUTS[scene] - 300.0:
		_draw_scene(scene + 1, clampf((x - CUTS[scene] + 300.0) / 300.0, 0.0, 1.0))


func _draw_scene(scene: int, alpha: float) -> void:
	var cell := Vector2i(scene % 2, scene / 2)
	draw_texture_rect_region(ATLAS, Rect2(-960, -620, 1920, 900),
		Rect2(cell.x * 887 + 2, cell.y * 443 + 2, 883, 439), Color(1, 1, 1, alpha))
