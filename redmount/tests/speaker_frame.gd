## Sinematikte konuşan kadrajda: 36 bölümün bütün hikâye sahneleri hızlandırılmış oynatılır,
## her repliğin balonu çıktığı anda konuşan aktörün (kafa noktası) görünür alanda olup
## olmadığı ölçülür (tur 204). REDMOUNT_FRAME_OFF=1 ile düzeltme kapatılıp taban ölçülür.
##
##  godot --headless --path . res://tests/speaker_frame.tscn
extends Node

const SPEED := 16.0

var _says := 0
var _out := 0
var _fails := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.size = Vector2i(1280, 720)
	Cutscene.auto_frame = OS.get_environment("REDMOUNT_FRAME_OFF") != "1"
	Save._path = "user://speaker_frame.cfg"
	Engine.time_scale = SPEED
	## REDMOUNT_FRAME_LEVEL=n tek bölüm; REDMOUNT_FRAME_RANGE=a-b (0 tabanlı, dahil) paralel koşu parçası.
	var only := OS.get_environment("REDMOUNT_FRAME_LEVEL")
	var lo := 0
	var hi := 35
	var rng := OS.get_environment("REDMOUNT_FRAME_RANGE")
	if not only.is_empty():
		lo = int(only)
		hi = lo
	elif rng.contains("-"):
		lo = int(rng.get_slice("-", 0))
		hi = int(rng.get_slice("-", 1))
	for i in range(lo, hi + 1):
		var t0 := Time.get_ticks_msec()
		await _level(i)
		print("  (Bölüm %d: %.0f sn)" % [i + 1, (Time.get_ticks_msec() - t0) / 1000.0])
	Engine.time_scale = 1.0
	print("SPEAKER FRAME: %d replik, %d kadraj dışı (düzeltme %s)" % [_says, _out,
		"açık" if Cutscene.auto_frame else "kapalı"])
	var ok := _out == 0 or not Cutscene.auto_frame
	print("SPEAKER FRAME: %s" % ("PASS" if ok and _fails == 0 else "FAIL"))
	get_tree().quit(0 if ok and _fails == 0 else 1)


func _level(i: int) -> void:
	GameState.level_path_override = "res://scenes/levels/Bolum%02d.tscn" % (i + 1)
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	var player := main.get_node_or_null(^"Redmount") as Node2D
	var scenes: Array = []
	for n in main.find_children("*", "Cutscene", true, false):
		scenes.append(n)
	scenes.sort_custom(func(a, b): return a.trigger_x < b.trigger_x)
	for a in get_tree().get_nodes_in_group(&"battle_arena"):
		a.queue_free()
	for cs in scenes:
		if not is_instance_valid(cs) or cs._started:
			continue
		var tx: float = cs.trigger_x
		if player != null and tx >= 0.0:
			# Sahne kamera oyuncuya yetişmeden başlamasın: tetik geçici olarak uzağa.
			cs.trigger_x = 1.0e9
			player.global_position = _ground(main, tx + 4.0)
			if player is CharacterBody2D:
				(player as CharacterBody2D).velocity = Vector2.ZERO
			var pc := get_viewport().get_camera_2d()
			for k in 3:
				await get_tree().process_frame
				if pc != null and is_instance_valid(pc):
					pc.reset_smoothing()
			for k in 20:
				await get_tree().process_frame
			cs.trigger_x = tx
		cs.force_start = true
		# Kamera oyuncuya yetişsin, sonra sahne başlasın.
		var waited := 0
		while Cutscene.active != cs and waited < 600 and is_instance_valid(cs) and not cs._started:
			await get_tree().process_frame
			waited += 1
		var last := ""
		var guard := 0
		while is_instance_valid(cs) and Cutscene.active == cs and guard < 20000:
			await get_tree().process_frame
			guard += 1
			var sid: String = cs.speaking_id
			if sid.is_empty():
				last = ""
				continue
			if sid == last:
				continue
			# Balon bu karede çıktı mı? (çerçeveleme kaydırması bitince eklenir)
			if cs._ui == null or cs._ui.get_child_count() == 0:
				continue
			last = sid
			var a: Node2D = cs.get_actor(sid)
			if a == null:
				continue
			_says += 1
			var cam: Camera2D = cs._cam
			var half := get_viewport().get_visible_rect().size * 0.5 / cam.zoom
			var c := cam.get_screen_center_position()
			var head := 210.0 if a.get_meta(&"kind") == "bus" else (0.0 if a.get_meta(&"kind") == "voice" else 150.0)
			var p := a.position
			var inside := absf(p.x - c.x) <= half.x - 40.0 and p.y - head >= c.y - half.y + Cutscene.LETTERBOX / cam.zoom.y \
				and p.y - 40.0 <= c.y + half.y - Cutscene.LETTERBOX / cam.zoom.y
			if not inside:
				_out += 1
				print("  Bölüm %d x%d: %s kadraj dışı (aktör %s, kamera %s)" % [i + 1, int(cs.trigger_x), sid, p.round(), c.round()])
		if guard >= 20000:
			_fails += 1
			print("HATA: Bölüm %d sahne x%d bitmedi" % [i + 1, int(cs.trigger_x)])
	get_tree().paused = false
	main.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame


## x noktasında zeminin üstü (yukarıdan aşağı ışın).
func _ground(main: Node, x: float) -> Vector2:
	var space := (main as Node2D).get_world_2d().direct_space_state if main is Node2D else get_viewport().world_2d.direct_space_state
	var q := PhysicsRayQueryParameters2D.create(Vector2(x, -1200), Vector2(x, 1500), 1)
	var hit := space.intersect_ray(q)
	return (hit.position as Vector2) + Vector2(0, -2) if not hit.is_empty() else Vector2(x, -40)
