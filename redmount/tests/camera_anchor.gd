extends Node
## Dikey kamera çapası: sıradan zıplamada kamera yerinde kalır (DTM tarzı), yüksek
## kulede alttaki zemin kadrajda görünür, ışınlanmada çapa anında gövdeye oturur.


func _ready() -> void:
	call_deferred(&"_run")


func _block(world: Node2D, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	col.position = rect.get_center()
	body.add_child(col)
	world.add_child(body)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame


func _run() -> void:
	var world := Node2D.new()
	add_child(world)
	_block(world, Rect2(-800, 0, 2400, 40))
	## Kule tepesi: zeminin 300 px üstünde dar blok.
	_block(world, Rect2(900, -300, 200, 20))
	var p: CharacterBody2D = load("res://scenes/characters/Redmount.tscn").instantiate()
	world.add_child(p)
	p.global_position = Vector2(0, -1)
	var cam: Camera2D = p.get_node(^"Camera2D")
	await _frames(20)
	var ground_cam := cam.global_position.y
	assert(absf(ground_cam - (p.global_position.y - 95.0)) < 2.0, "yerde kamera -95'te olmalı")

	## 1) Sıradan zıplama: tepe ~125 px, kamera hedefi en çok ~15 px yükselir.
	var top_cam := ground_cam
	var top_body := p.global_position.y
	Input.action_press(&"jump")
	for i in 90:
		await _frames(1)
		top_cam = minf(top_cam, cam.global_position.y)
		top_body = minf(top_body, p.global_position.y)
	Input.action_release(&"jump")
	await _frames(30)
	var rise := -top_body + p.global_position.y
	var cam_rise := ground_cam - top_cam
	print("CAMERA ANCHOR: zıplama %.0f px, kamera hedefi %.0f px yükseldi" % [rise, cam_rise])
	assert(rise > 100.0, "zıplama ölçülemedi")
	assert(cam_rise < 25.0, "sıradan zıplamada kamera yerinde kalmalı")

	## 2) Kule tepesi: alttaki zemin (y=0) görünür kadrajda kalmalı.
	p.global_position = Vector2(1000, -301)
	p.velocity = Vector2.ZERO
	await _frames(90)
	assert(p.is_on_floor() and p.global_position.y < -290.0, "oyuncu kuleye oturmalı")
	## Oyundaki görünüm: 720 px yükseklik, DTM bölüm yakınlaştırması 1.12.
	var half := float(ProjectSettings.get_setting("display/window/size/viewport_height")) * 0.5 / 1.12
	var bottom := cam.get_screen_center_position().y + half
	print("CAMERA ANCHOR: kulede ekran altı y=%.0f (zemin 0)" % bottom)
	assert(bottom > 10.0, "kuledeyken yer görünmeli")

	## 3) Işınlanma: zemine geri, kamera çapası anında oturur.
	p.global_position = Vector2(0, -1)
	await _frames(2)
	assert(absf(cam.position.y - (-95.0)) < 2.0, "ışınlanmada çapa sıfırlanmalı")
	print("CAMERA ANCHOR: PASS")
	get_tree().quit(0)
