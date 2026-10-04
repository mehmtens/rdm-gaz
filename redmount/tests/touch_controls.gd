extends SceneTree

class ThrowDummy extends Node2D:
	func can_be_thrown() -> bool:
		return true


func _initialize() -> void:
	OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "1")
	call_deferred(&"_run")


func _run() -> void:
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	var touch: TouchControls = main.get_node(^"TouchControls")
	assert(touch.is_enabled())
	assert(touch.get_node(^"attack").visible)
	assert(not touch.get_node(^"fire").visible, "Silah yokken ATEŞ düğmesi görünmemeli")
	assert(touch.get_node(^"move_left").action == "move_left")

	_touch(touch.get_node(^"move_left"), 0, true)
	_touch(touch.get_node(^"attack"), 1, true)
	await process_frame
	assert(Input.is_action_pressed(&"move_left"), "Sol hareket dokunması kayboldu")
	assert(Input.is_action_pressed(&"attack"), "Eş zamanlı saldırı dokunması kayboldu")
	_touch(touch.get_node(^"attack"), 1, false)
	_touch(touch.get_node(^"move_left"), 0, false)
	await process_frame
	assert(not Input.is_action_pressed(&"attack"))
	assert(not Input.is_action_pressed(&"move_left"))
	var throwable := ThrowDummy.new()
	throwable.add_to_group(&"enemy_ai")
	main.add_child(throwable)
	throwable.global_position = main._player.global_position + Vector2(40, 0)
	await process_frame
	assert(main._player.can_throw_nearby())
	assert(touch._labels["heavy_attack"].text == "FIRLAT",
		"Mobil ağır saldırı düğmesi yakındaki sersemlemiş düşmanı göstermeli")
	throwable.queue_free()
	main._player.equip_gun(load("res://resources/weapons/pistol.tres"))
	await process_frame
	assert(touch.get_node(^"fire").visible, "Silah alınınca ATEŞ düğmesi görünmeli")

	touch.set_mode("results")
	assert(touch.get_node(^"next").visible)
	assert(not touch.get_node(^"attack").visible)
	touch.set_mode("play")
	_touch(touch.get_node(^"pause"), 0, true)
	await process_frame
	assert(main.get_node(^"PauseMenu").is_open())
	await process_frame
	assert(not touch.get_node(^"attack").visible)
	_touch(touch.get_node(^"pause"), 0, false)
	main.get_node(^"PauseMenu").close()
	main._finished = true
	main.get_node(^"UI/HUD/ResultsPanel").visible = true
	touch.set_mode("results")
	paused = true
	_touch(touch.get_node(^"next"), 0, true)
	await process_frame
	assert(main._level.scene_file_path == "res://scenes/levels/Level06.tscn",
		"Dokunmatik sonuç düğmesi sonraki bölüme geçmedi")
	assert(not paused)
	_touch(touch.get_node(^"next"), 0, false)
	main._player._health = 0
	touch.set_mode("dead")
	_touch(touch.get_node(^"retry"), 0, true)
	await process_frame
	assert(main._player.get_health() > 0, "Dokunmatik yeniden deneme oyuncuyu canlandırmadı")
	_touch(touch.get_node(^"retry"), 0, false)
	main.queue_free()
	await process_frame
	print("TOUCH CONTROLS OK")
	quit(0)


func _touch(button: TouchScreenButton, finger: int, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = finger
	event.pressed = pressed
	event.position = button.position + button.texture_normal.get_size() / 2.0
	Input.parse_input_event(event)
