extends Node
## Tavan köşesi düzeltmesi: kafa bir çıkıntının köşesine birkaç piksel değince
## zıplama ölmez (gövde yana kayar); derin örtüşmede ve ayar kapalıyken düzeltme yok.

const HEAD_GAP := 18.0 ## kafa ile çıkıntı altı arası (px)


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


## Çıkıntıyı soldan (side=-1) ya da sağdan (side=1) `overlap` px örtecek
## kurar, zıplatır; [ulaşılan en yüksek y, x kayması] döner.
func _jump_case(overlap: float, side: int, reach: int) -> Vector2:
	var world := Node2D.new()
	add_child(world)
	_block(world, Rect2(-400, 0, 800, 40))
	var bottom := -112.0 - HEAD_GAP
	var inner := -19.0 + overlap if side < 0 else 19.0 - overlap
	if side < 0:
		_block(world, Rect2(inner - 200.0, bottom - 16.0, 200.0, 16.0))
	else:
		_block(world, Rect2(inner, bottom - 16.0, 200.0, 16.0))
	var p: CharacterBody2D = load("res://scenes/characters/Redmount.tscn").instantiate()
	p.movement = p.movement.duplicate()
	p.movement.corner_correction = reach
	world.add_child(p)
	p.global_position = Vector2(0, -1)
	for i in 10:
		await get_tree().physics_frame
	var x0 := p.global_position.x
	var top := p.global_position.y
	Input.action_press(&"jump")
	for i in 50:
		await get_tree().physics_frame
		top = minf(top, p.global_position.y)
	Input.action_release(&"jump")
	var dx := p.global_position.x - x0
	world.queue_free()
	await get_tree().process_frame
	return Vector2(top, dx)


func _run() -> void:
	var r := await _jump_case(6.0, -1, 10)
	assert(r.x < -60.0, "Soldan 6 px köşe: zıplama geçmeli (y=%s)" % r.x)
	assert(r.y > 0.0, "Soldan köşe: gövde sağa kaymalı (dx=%s)" % r.y)
	r = await _jump_case(6.0, 1, 10)
	assert(r.x < -60.0, "Sağdan 6 px köşe: zıplama geçmeli (y=%s)" % r.x)
	assert(r.y < 0.0, "Sağdan köşe: gövde sola kaymalı (dx=%s)" % r.y)
	r = await _jump_case(26.0, -1, 10)
	assert(r.x > -30.0, "26 px derin örtüşme: tavan durdurmalı (y=%s)" % r.x)
	assert(is_zero_approx(r.y), "Derin örtüşmede yana kayma olmamalı (dx=%s)" % r.y)
	r = await _jump_case(6.0, -1, 0)
	assert(r.x > -30.0, "Ayar kapalı: köşe zıplamayı durdurmalı (y=%s)" % r.x)
	print("CORNER CORRECTION OK")
	get_tree().quit(0)
