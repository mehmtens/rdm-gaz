## Uzak katman kamerayı aynı karede izliyor mu, yeniden doğmada kamera kesiyor mu?
## (Tur 187: Bölüm 32 sonunda hızlı kaymada ekranın kenarı resimsiz gri bant kalıyordu;
## `_Sky` kameradan bir kare geride çiziliyordu ve yeniden doğmada kamera ölüm
## noktasından kontrol noktasına binlerce piksel kayarak dönüyordu.)
##  godot --headless --path . res://tests/sky_follow.tscn  → "SKY FOLLOW: PASS"
extends Node

var _fail := 0
var _windowed := DisplayServer.get_name() != "headless"


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_fail += 1
		print("  FAIL: ", msg)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Save._path = "user://_sky_follow.cfg"
	Save.load_game()
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	GameState.level_index = 31
	main._load_current_level()
	await _settle()
	for a in get_tree().get_nodes_in_group(&"battle_arena"):
		a.queue_free()
	var player := main.get_node(^"Redmount") as CharacterBody2D
	var cam := player.get_node(^"Camera2D") as Camera2D
	var sky: Node2D = null
	for c in main._level.get_children():
		if c.get_script() != null and c.has_method(&"target_cell"):
			sky = c
	_check(sky != null, "uzak katman (_Sky) bulunamadı")
	if sky == null:
		_finish()
		return

	# 1) Hızlı kayan kamera: oyuncu her karede 300 px ilerletilir; uzak katman aynı
	# karede kameranın ekran merkezinde olmalı (bir kare geride kalırsa kenarda boşluk).
	player.set_physics_process(false)
	player.global_position = Vector2(3000, -40)
	cam.reset_smoothing()
	await _settle()
	var worst := 0.0
	for i in 12:
		player.global_position.x += 300.0
		await get_tree().process_frame
		if _windowed:
			await RenderingServer.frame_post_draw
		# Işınlanma hikâye sahnesini tetikleyebilir: uzak katman o an GEÇERLİ kamerayı izlemeli.
		# Başsızda çizim (frame_pre_draw) yok: sinematik kamerası tween ile kaydığından o
		# karelerde yalnız pencereli koşu ölçülür.
		var cur := get_viewport().get_camera_2d()
		if Cutscene.active == null or _windowed:
			worst = maxf(worst, absf(sky.global_position.x - cur.get_screen_center_position().x))
	print("  uzak katman / kamera en büyük fark: %.1f px" % worst)
	_check(worst < 1.0, "uzak katman kameradan geride (%.1f px)" % worst)
	player.set_physics_process(true)
	await _settle()

	# 2) Yeniden doğma: kamera kontrol noktasına kesmeli, binlerce piksel kaymamalı.
	player.global_position = Vector2(9200, -40)
	cam.reset_smoothing()
	await _settle()
	_check(cam.is_current(), "oyuncu kamerası geçerli değil (hikâye sahnesi sürüyor)")
	main._respawn_pos = Vector2(4000, -40)
	main._respawn_player()
	await get_tree().process_frame
	await get_tree().process_frame
	var gap := absf(cam.get_screen_center_position().x - player.global_position.x)
	print("  yeniden doğma sonrası kamera-oyuncu farkı: %.1f px" % gap)
	_check(gap < 200.0, "yeniden doğmada kamera kontrol noktasına kaymadan kesmedi (%.1f px)" % gap)
	_finish()


## Birkaç kare bekler; açılan hikâye sahnelerini atlatıp bitmelerini bekler.
func _settle() -> void:
	for i in 40:
		await get_tree().process_frame
		if Cutscene.active != null:
			Cutscene.active._skip = true
	while Cutscene.active != null:
		Cutscene.active._skip = true
		await get_tree().process_frame
	for i in 5:
		await get_tree().process_frame


func _finish() -> void:
	print("SKY FOLLOW: ", "PASS" if _fail == 0 else "FAIL (%d)" % _fail)
	get_tree().quit(0 if _fail == 0 else 1)
