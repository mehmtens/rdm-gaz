## Otonom bölüm testi — her bölümü "sağa koş + zıpla + tıkanınca dash + yakın
## düşmana saldır" botuyla oynatır, ilerlemeyi ve bitişi raporlar.
extends Node

var _main: Node
var _player: CharacterBody2D
var _level_idx := 0
var _max_x := -1e9
var _stuck_t := 0.0
var _last_x := 0.0
var _run_t := 0.0
var _report: Array = []
var _respawns := 0
var _prev_x := 0.0
var _time_limit := 360.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_main = load("res://scenes/Main.tscn").instantiate()
	add_child(_main)
	await get_tree().process_frame
	_player = _main.get_node(^"Redmount")
	var probe_level := OS.get_environment("REDMOUNT_PROBE_LEVEL")
	_start_level(probe_level.to_int() if not probe_level.is_empty() else 0)


func _start_level(idx: int) -> void:
	_level_idx = idx
	GameState.level_index = idx
	_main._load_current_level()
	var probe_x := OS.get_environment("REDMOUNT_PROBE_X")
	if not probe_x.is_empty():
		_player.global_position = Vector2(probe_x.to_float(), -40.0)
	_max_x = -1e9
	_stuck_t = 0.0
	_run_t = 0.0
	_last_x = _player.global_position.x
	get_tree().paused = false


func _physics_process(delta: float) -> void:
	if _player == null:
		return
	_run_t += delta
	for i in range(_release_queue.size() - 1, -1, -1):
		if _run_t >= _release_queue[i][1]:
			Input.action_release(_release_queue[i][0])
			_release_queue.remove_at(i)
	var x := _player.global_position.x
	var y := _player.global_position.y
	if _player.get_health() <= 0:
		_main._respawn_player()
		_respawns += 1
		return
	if x < _prev_x - 150.0:
		_respawns += 1
	_prev_x = x
	_max_x = maxf(_max_x, x)

	# diyalog kutusu açıksa geç
	var db = _main.get_node_or_null(^"DialogueBox")
	if db != null and db.is_active():
		db._advance()
		return

	# bitiş?
	if get_tree().paused or _main._finished:
		_finish_level("CLEARED @%.0f  t=%.1fs" % [_max_x, _run_t])
		return
	if fmod(_run_t, 4.0) < delta:
		var hit := _player.get_last_slide_collision()
		var blocker := str(hit.get_collider().get_path()) if hit != null else "-"
		print("  L%d t=%.0f x=%.0f y=%.0f vx=%.0f floor=%s hit=%s maxx=%.0f hp=%d respawns=%d" % [
			_level_idx + 1, _run_t, x, y, _player.velocity.x, _player.is_on_floor(), blocker,
			_max_x, _player.get_health(), _respawns])
	if _run_t > _time_limit:
		_finish_level("TIMEOUT maxx=%.0f" % _max_x)
		return

	var on_floor: bool = _player.is_on_floor()

	# yakın düşman: dön + yaklaş + vur (duvara koşmayı bırak)
	var foe: Node2D = null
	var foe_dx := 0.0
	var seek_radius := 155.0
	for arena in get_tree().get_nodes_in_group(&"battle_arena"):
		if arena.get("_active") and not arena.get("_done"):
			seek_radius = 1400.0
			break
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		if not is_instance_valid(e) or (e.has_method(&"is_dead") and e.is_dead()):
			continue
		var dx: float = e.global_position.x - x
		if absf(dx) < seek_radius and absf(e.global_position.y - y) < 90.0:
			if foe == null or absf(dx) < absf(foe_dx):
				foe = e
				foe_dx = dx
	if foe != null:
		Input.action_release(&"run")
		if foe_dx > 14.0:
			Input.action_press(&"move_right"); Input.action_release(&"move_left")
		elif foe_dx < -14.0:
			Input.action_press(&"move_left"); Input.action_release(&"move_right")
		else:
			Input.action_release(&"move_right"); Input.action_release(&"move_left")
		if absf(foe_dx) < 76.0:
			_tap(&"attack")
		return

	# girdi botu
	Input.action_release(&"move_left")
	Input.action_press(&"move_right")
	Input.action_press(&"run")

	if absf(x - _last_x) < 3.0:
		_stuck_t += delta
	else:
		_stuck_t = 0.0
	_last_x = x

	# kenar-farkında zıplama
	if on_floor and _ground_at(x + 8.0, y) and not _ground_at(x + 66.0, y):
		_tap(&"jump")
	elif on_floor and not _ground_at(x + 20.0, y):
		_tap(&"jump")
	# duvara yapıştıysa (havada) duvar-zıplaması
	elif _player.is_on_wall() and not on_floor:
		_tap(&"jump")
	# tıkandıysa dash + zıpla
	if _stuck_t > 0.3:
		_tap(&"dash")
		_tap(&"jump")
		_stuck_t = 0.0


## Ayak kotuna yakın zemin var mı? Daha aşağıdaki platform boşluğu gizlememeli.
func _ground_at(px: float, y: float) -> bool:
	var space := _player.get_world_2d().direct_space_state
	var q := PhysicsRayQueryParameters2D.create(
		Vector2(px, y - 10.0), Vector2(px, y + 42.0), 1)
	q.exclude = [_player.get_rid()]
	return not space.intersect_ray(q).is_empty()


var _release_queue: Array = []

func _tap(a: StringName) -> void:
	if Input.is_action_pressed(a):
		return
	Input.action_press(a)
	# zıplama tuşunu uzun tut (erken bırakınca jump_cut ile cılız hop olur)
	_release_queue.append([a, _run_t + (0.24 if a == &"jump" else 0.06)])


func _finish_level(msg: String) -> void:
	print("PROBE Bölüm %d: %s" % [_level_idx + 1, msg])
	Input.action_release(&"move_right")
	Input.action_release(&"run")
	if not OS.get_environment("REDMOUNT_PROBE_LEVEL").is_empty():
		get_tree().quit()
		return
	if _level_idx < 4:
		_start_level(_level_idx + 1)
	else:
		print("PROBE DONE")
		get_tree().quit()
