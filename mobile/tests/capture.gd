## Görsel doğrulama: bölümü açar, oyuncuyu noktalara ışınlar, ekran görüntüsü alır.
## Kullanım: godot --path . res://tests/capture.tscn -- out_dir x1,y1 x2,y2 ...
extends Node

var _points: Array = []
var _out := "user://shots"
var _level: Node
var _i := 0
var _wait := 0


func _ready() -> void:
	Game.testing = true
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	for a in args.slice(1):
		var p: PackedStringArray = a.split(",")
		_points.append(Vector2(float(p[0]), float(p[1])))
	DirAccess.make_dir_recursive_absolute(_out)
	Game.run = {"coins": 0, "collected": {}, "cleared": {"a1": true, "a2": true}, "secrets": {}, "kills": 0, "time": 0.0, "deaths": 0, "checkpoint": null}
	if _points.is_empty():
		var menu: Node = load("res://scenes/Menu.tscn").instantiate()
		add_child(menu)
		_wait = 40
		return
	_level = load("res://scenes/levels/Level01.tscn").instantiate()
	add_child(_level)
	_wait = 30


func _process(_dt: float) -> void:
	_wait -= 1
	if _wait > 0:
		return
	if _points.is_empty():
		get_viewport().get_texture().get_image().save_png(_out + "/menu.png")
		get_tree().quit()
		return
	if _i > 0:
		get_viewport().get_texture().get_image().save_png("%s/shot_%02d_x%d.png" % [_out, _i - 1, int(_points[_i - 1].x)])
	if _i >= _points.size():
		get_tree().quit()
		return
	var p: Player = _level.player
	p.position = _points[_i]
	p.velocity = Vector2.ZERO
	_level.snap_camera()
	_i += 1
	_wait = 45
