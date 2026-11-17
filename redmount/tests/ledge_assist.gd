extends Node
## Kenar tırmanma yardımı: havada kenara doğru basarken ayaklar kenarın birkaç
## piksel altındaysa oyuncu kenara çıkar; derin farkta ve ayar kapalıyken düşer.

const LEDGE_TOP := -150.0
const LEDGE_X := 30.0


func _ready() -> void:
	call_deferred(&"_run")


func _block(parent: Node, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	col.position = rect.get_center()
	body.add_child(col)
	parent.add_child(body)


## Ayakları kenarın `below` px altında, kenara 2 px mesafede havada başlatır;
## sağa basılı 40 kare sonra son konumu döner.
func _case(below: float, reach: int) -> Vector2:
	var world := Node2D.new()
	add_child(world)
	_block(world, Rect2(-400, 0, 1000, 40))
	_block(world, Rect2(LEDGE_X, LEDGE_TOP, 400, -LEDGE_TOP))
	var p: CharacterBody2D = load("res://scenes/characters/Redmount.tscn").instantiate()
	p.movement = p.movement.duplicate()
	p.movement.ledge_assist = reach
	world.add_child(p)
	p.global_position = Vector2(LEDGE_X - 21.0, LEDGE_TOP + below)
	Input.action_press(&"move_right")
	for i in 40:
		await get_tree().physics_frame
	Input.action_release(&"move_right")
	var pos := p.global_position
	world.queue_free()
	await get_tree().process_frame
	return pos


func _run() -> void:
	var r := await _case(5.0, 8)
	assert(r.x > LEDGE_X + 10.0 and r.y <= LEDGE_TOP + 1.0,
		"5 px altta: kenara çıkmalı (%s)" % r)
	r = await _case(20.0, 8)
	assert(r.x < LEDGE_X and r.y > LEDGE_TOP + 15.0, "20 px altta: düşmeli (%s)" % r)
	r = await _case(5.0, 0)
	assert(r.x < LEDGE_X and r.y > LEDGE_TOP + 4.0, "Ayar kapalı: düşmeli (%s)" % r)
	print("LEDGE ASSIST OK")
	get_tree().quit(0)
