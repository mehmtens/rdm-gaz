## Duvar-zıplama bacası tırmanılabilir mi? Oyuncuyu bacanın dibine koyar, gerçek
## girdiyle (yöne bas, düşerken duvardayken zıpla, yön değiştir) tırmandırır.
##
##  REDMOUNT_PROBE_LEVEL=25 REDMOUNT_CLIMB="7670:-10:-470" godot --headless --path . --fixed-fps 60 res://tests/climb_probe.tscn
extends Node

var _player: CharacterBody2D
var _dir := 1
var _t := 0.0
var _best := 0.0
var _goal := 0.0
var _go := false
var _flip := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_physics_priority = -100
	var f := OS.get_environment("REDMOUNT_CLIMB").split(":")
	GameState.level_index = OS.get_environment("REDMOUNT_PROBE_LEVEL").to_int()
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	GameState.level_index = OS.get_environment("REDMOUNT_PROBE_LEVEL").to_int()
	main._load_current_level()
	await get_tree().process_frame
	for a in get_tree().get_nodes_in_group(&"battle_arena"):
		a.queue_free()
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		e.queue_free()
	_player = main.get_node(^"Redmount")
	for i in 60:
		await get_tree().process_frame
		if Cutscene.active != null:
			Cutscene.active._skip = true
	while Cutscene.active != null:
		await get_tree().process_frame
	_player.global_position = Vector2(f[0].to_float(), f[1].to_float())
	_player.velocity = Vector2.ZERO
	_best = _player.global_position.y
	_goal = f[2].to_float()
	for i in 20:
		await get_tree().physics_frame
	get_tree().paused = false
	_go = true
	Input.action_press(&"jump")
	Input.action_press(&"move_right")


func _physics_process(delta: float) -> void:
	if not _go:
		return
	_t += delta
	_best = minf(_best, _player.global_position.y)
	if _player.global_position.y <= _goal + 2.0 and _player.is_on_floor():
		print("CLIMB OK t=%.1fs" % _t)
		get_tree().quit(0)
		return
	if _t > 8.0:
		print("CLIMB FAIL best_y=%.0f goal=%.0f" % [_best, _goal])
		get_tree().quit(1)
		return
	if Input.is_action_pressed(&"jump"):
		if _flip and _player.velocity.y < 0.0:
			# Duvar zıplaması gerçekleşti: şimdi karşı duvara yönel.
			Input.action_release(&"move_right" if _dir > 0 else &"move_left")
			_dir = -_dir
			Input.action_press(&"move_right" if _dir > 0 else &"move_left")
			_flip = false
		if _player.velocity.y > 0.0 and not _flip:
			Input.action_release(&"jump")
		return
	if not _player.is_on_floor() and _player.velocity.y > 0.0 and _player.is_on_wall_only():
		var wn := _player.get_wall_normal().x
		if signf(wn) == -float(_dir):
			Input.action_press(&"jump")
			_flip = true
			print("WJ at %s" % _player.global_position)
