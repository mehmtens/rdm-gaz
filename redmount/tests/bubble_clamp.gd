## Sinematik konuşma balonu ekranda kalır: çatıdaki/kenardaki konuşanın balonu sinema
## şeridinin altına ya da ekran dışına kaymaz (tur 201). Ortadaki balon hiç kaymaz.
##
##  godot --headless --path . res://tests/bubble_clamp.tscn
extends Node

var _fails := 0


func _ready() -> void:
	get_tree().root.size = Vector2i(1280, 720)
	var cam := Camera2D.new()
	cam.zoom = Vector2(1.12, 1.12)
	add_child(cam)
	cam.make_current()
	var layer := CanvasLayer.new()
	layer.follow_viewport_enabled = true
	add_child(layer)
	await get_tree().process_frame
	await get_tree().process_frame
	var vs := Vector2(1280, 720)
	# Ekran koordinatında hedef (balonun kuyruk ucu); dünyaya çevrilip balon oraya konur.
	var cases := [["orta", Vector2(640, 520), true], ["çatı", Vector2(640, 150), false],
		["sol", Vector2(40, 500), false], ["sağ", Vector2(1250, 500), false],
		["sol üst köşe", Vector2(-200, 40), false]]
	for c in cases:
		var b: Node2D = Cutscene._Bubble.new()
		b.speaker = "REDMOUNT"
		b.text = "Duydum seni! Pazar meydanı... geliyorum, dayan biraz daha."
		b.position = (c[1] - vs * 0.5) / cam.zoom + cam.get_screen_center_position()
		layer.add_child(b)
		await get_tree().process_frame
		var font := PixelUI.font()
		var full := font.get_multiline_string_size(b.text, HORIZONTAL_ALIGNMENT_LEFT, 420.0, 24)
		var h := roundf((full.y + 66.0) / 3.0) * 3.0
		var local := Rect2(-228.0, -h - 27.0, 456.0, h + 12.0)
		var shift: Vector2 = b.call(&"_keep_on_screen", local)
		var xf := b.get_global_transform_with_canvas()
		var scr := Rect2(xf * (local.position + shift), local.size * xf.get_scale())
		var inside := scr.position.x >= 0.0 and scr.end.x <= vs.x \
			and scr.position.y >= Cutscene.LETTERBOX and scr.end.y <= vs.y - Cutscene.LETTERBOX
		_check(inside, "%s: balon %s" % [c[0], scr])
		if c[2]:
			_check(shift == Vector2.ZERO, "%s: kaymamalı (%s)" % [c[0], shift])
		_check(fmod(shift.x, 3.0) == 0.0 and fmod(shift.y, 3.0) == 0.0, "%s: piksel ızgarası" % c[0])
		b.queue_free()
	print("BUBBLE CLAMP: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		print("HATA: " + what)
