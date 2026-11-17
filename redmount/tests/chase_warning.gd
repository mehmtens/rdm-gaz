extends Node
## Kovalamaca uyarısı HUD duyuru plakasına gider (tur 232): dünya yazısı 0,7 sn'de
## sönüp kırmızı bayrağın üstünde okunmuyordu.

const DtmLevel := preload("res://scripts/systems/dtm_level.gd")



class _StubHud extends Node:
	var calls: Array = []
	func show_place(title: String, story: String, accent: Color) -> void:
		calls.append([title, story, accent])


func _ready() -> void:
	var hud := _StubHud.new()
	hud.add_to_group(&"hud")
	add_child(hud)
	var p := Node2D.new()
	p.add_to_group(&"player")
	p.global_position = Vector2(100, 0)
	add_child(p)
	var c = DtmLevel._Chaser.new()
	c.x0 = 50.0
	c.x1 = 2000.0
	c.title = "MİNİBÜS! KOŞ!"
	c.story = "durma!"
	add_child(c)
	for i in 3:
		await get_tree().physics_frame
	var ok: bool = hud.calls.size() == 1 and hud.calls[0][0] == "MİNİBÜS! KOŞ!" and hud.calls[0][1] == "durma!"
	print("CHASE WARNING: ", "PASS" if ok else "FAIL %s" % [hud.calls])
	get_tree().quit(0 if ok else 1)
