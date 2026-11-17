extends Node
## Tepe asılması: basılı zıplamada tepede yerçekimi yarıya iner — havada kalış
## birkaç kare uzar, tepe yüksekliği neredeyse değişmez (bölüm aralıkları bozulmaz).


func _ready() -> void:
	call_deferred(&"_run")


## [tepe yüksekliği (px), havada kare sayısı]
func _jump(mult: float) -> Vector2:
	var world := Node2D.new()
	add_child(world)
	var body := StaticBody2D.new()
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(800, 40)
	col.shape = shape
	col.position = Vector2(0, 20)
	body.add_child(col)
	world.add_child(body)
	var p: CharacterBody2D = load("res://scenes/characters/Redmount.tscn").instantiate()
	p.movement = p.movement.duplicate()
	p.movement.apex_gravity_multiplier = mult
	world.add_child(p)
	p.global_position = Vector2(0, -1)
	for i in 10:
		await get_tree().physics_frame
	var y0 := p.global_position.y
	var top := y0
	var air := 0
	Input.action_press(&"jump")
	for i in 120:
		await get_tree().physics_frame
		top = minf(top, p.global_position.y)
		if not p.is_on_floor():
			air += 1
		elif air > 0:
			break
	Input.action_release(&"jump")
	world.queue_free()
	await get_tree().process_frame
	return Vector2(y0 - top, air)


func _run() -> void:
	var off := await _jump(1.0)
	var on := await _jump(0.5)
	print("apex kapalı: %s  açık: %s" % [off, on])
	assert(on.y >= off.y + 3.0, "Tepe asılması havada kalışı en az 3 kare uzatmalı")
	assert(absf(on.x - off.x) < 4.0, "Tepe yüksekliği 4 px'ten fazla değişmemeli")
	print("APEX HANG OK")
	get_tree().quit(0)
