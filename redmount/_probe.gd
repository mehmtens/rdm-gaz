extends Node
var _shot := 0
var _main: Node
var _player: CharacterBody2D
var _lvl := 0
var _godmode := true
var _since_break := 0.0
var _start_x := 0.0   # >0 ise oyuncu yüklendikten sonra oraya ışınlanır (arena bypass)

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://_showcase")
	_main = load("res://scenes/Main.tscn").instantiate()
	add_child(_main)
	await get_tree().process_frame
	_player = _main.get_node(^"Redmount")
	GameState.level_index = _lvl
	_main._load_current_level()
	get_tree().paused = false
	await _w(0.3)
	if _start_x > 0.0:
		_player.global_position.x = _start_x
		await _w(0.2)
	var db := _main.get_node(^"DialogueBox")
	Input.action_press("move_right")
	Input.action_press("run")
	var t := 0.0
	var maxt := 80.0
	var last_x := 0.0
	var stuck := 0.0
	while t < maxt:
		await get_tree().physics_frame
		var dt := get_physics_process_delta_time()
		t += dt
		if db.is_active():
			db._advance(); continue
		if _jh > 0.0:
			_jh -= dt
			if _jh <= 0.0: Input.action_release("jump")
		var x: float = _player.global_position.x
		var y: float = _player.global_position.y
		# tıkanma → dur, saldır, zıpla; uzun tıkanma → dash ile zorla geç
		if absf(x - last_x) < 2.0:
			stuck += dt
		else:
			stuck = maxf(stuck - dt * 2.0, 0.0)
		last_x = x
		_since_break += dt
		if stuck > 0.6 and _since_break > 0.5:
			_since_break = 0.0
			Input.action_press("attack")
			await get_tree().physics_frame
			Input.action_release("attack")
			_jump()
			if stuck > 1.6:
				Input.action_press("dash")
				await get_tree().physics_frame
				Input.action_release("dash")
				await get_tree().create_timer(0.25, true, false, true).timeout
		if _player.is_on_floor() and _g(x+8,y) and not _g(x+70,y): _jump()
		elif _player.is_on_floor() and not _g(x+24,y): _jump()
		elif _player.is_on_wall() and not _player.is_on_floor(): _jump()
		# PARKUR doğrulama modu: dövüş becerisini değil YOL'u test et — canı tut.
		if _godmode and _player.get_health() < 70 and _player.has_method(&"heal"):
			_player.heal(120)
		if _player.get_health() <= 0:
			stuck += dt
			if stuck > 3.0: break
		if fmod(t, 3.0) < dt:
			await _snap("l%02d_%02d_x%05.0f_y%04.0f" % [_lvl+1, _shot, x, y])
	await _snap("l%02d_final_x%05.0f" % [_lvl+1, _player.global_position.x])
	print("PROBE lvl=%d x=%.0f y=%.0f hp=%d state=%s" % [_lvl+1, _player.global_position.x, _player.global_position.y, _player.get_health(), _player.get_state_name()])
	get_tree().quit()

var _jh := 0.0
func _jump() -> void:
	if _jh > 0.0: return
	Input.action_press("jump"); _jh = 0.24

func _g(px: float, y: float) -> bool:
	var s := _player.get_world_2d().direct_space_state
	var q := PhysicsRayQueryParameters2D.create(Vector2(px, y-10), Vector2(px, y+110), 1)
	q.exclude = [_player.get_rid()]
	return not s.intersect_ray(q).is_empty()

func _w(s: float) -> void:
	await get_tree().create_timer(s, true, false, true).timeout

func _snap(nm: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://_showcase/%s.png" % nm)
	_shot += 1
