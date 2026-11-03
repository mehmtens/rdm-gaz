## Kirişe bağlı pres: kolun üst ucu döngü boyunca kirişte kalır, başlığa değer;
## `ceiling_y` verilmeyen pres eski uzun kolu korur.
extends Node

const CRUSHER := preload("res://scenes/systems/Crusher.tscn")


func _ready() -> void:
	var beam := -339.0
	var c: Crusher = CRUSHER.instantiate()
	c.ceiling_y = beam
	c.drop_height = 165.0
	c.period = 1.0
	c.position = Vector2(0, -195.0)
	add_child(c)
	var old: Crusher = CRUSHER.instantiate()
	old.position = Vector2(300, -195.0)
	add_child(old)
	var ok := true
	var lowest := -1e9
	for i in 70:
		await get_tree().physics_frame
		var rod: Sprite2D = c._rod
		var top := c.position.y + rod.position.y
		var bottom := top + rod.region_rect.size.y * 3.0
		var head_top := c.position.y - c.thickness * 0.5
		lowest = maxf(lowest, c.position.y)
		if absf(top - beam) > 3.01 or absf(bottom - head_top) > 0.01:
			print("FAIL kare %d: kol %.1f..%.1f, başlık %.1f" % [i, top, bottom, head_top])
			ok = false
	if lowest < -195.0 + 160.0:
		print("FAIL pres inmedi (en alt %.1f)" % lowest)
		ok = false
	if old._rod.region_rect.size.y != 240.0:
		print("FAIL eski pres kolu değişti")
		ok = false
	print("CRUSHER BEAM: PASS" if ok else "CRUSHER BEAM: FAIL")
	get_tree().quit(0 if ok else 1)
