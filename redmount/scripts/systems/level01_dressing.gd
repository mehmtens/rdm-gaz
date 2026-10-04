## Bölüm 1: aynı ölçekte mahalle cepheleri ve sakin şehir katmanı.
## Dekor çarpışma üretmez; yürünebilir yüzeyleri LongRoute çizer.
extends Node2D

const CITY := preload("res://assets/backgrounds/level01_urban_dusk.png")
const HOUSES := [preload("res://assets/environment/mahalle/house_a.png"),
	preload("res://assets/environment/mahalle/house_b.png"),
	preload("res://assets/environment/mahalle/house_c.png")]
const SHOP := preload("res://assets/environment/mahalle/shop_interior.png")
const AWNING := preload("res://assets/environment/mahalle/market_awning_v2.png")
const TREE := preload("res://assets/environment/mahalle/tree_pot.png")
const AMBER := Color("ffd584")
const INK := Color("242339")
const STOREFRONTS := {
	0: ["KÖŞE ÇAY", "tea", Color("d87564")],
	3: ["MAHALLE BERBERİ", "barber", Color("668c9e")],
	6: ["TAŞ FIRIN", "bakery", Color("bc764f")],
	10: ["SİMİTÇİ", "simit", Color("c39455")],
	13: ["NALBUR", "hardware", Color("638b84")],
	17: ["KARDEŞLER TAMİR", "garage", Color("8993a3")],
}
var _camera: Camera2D
var _block := -999

func _ready() -> void:
	z_index = -5
	add_child(CityLayer.new())
	queue_redraw()

func _process(_delta: float) -> void:
	_camera = get_viewport().get_camera_2d()
	if _camera == null:
		return
	var next_block := floori(_camera.get_screen_center_position().x / 420.0)
	if next_block != _block:
		_block = next_block
		queue_redraw()

func _draw() -> void:
	# Yalnız kameranın çevresindeki cepheler çizilir; uzun rota boyunca sabit bütçe.
	var center := _block if _block != -999 else 0
	for i in range(center - 3, center + 5):
		var x := float(i * 420)
		var texture: Texture2D = HOUSES[posmod(i, 3)]
		var height := 360.0 + float(posmod(i, 4)) * 24.0
		var width := height * texture.get_width() / texture.get_height()
		draw_texture_rect(texture, Rect2(x, -height - 16, width, height), false, Color("b9b1c9"))
		draw_rect(Rect2(x - 6, -18, 418, 18), INK)
		if STOREFRONTS.has(i):
			var shop: Array = STOREFRONTS[i]
			_storefront(x + 20, shop[0], shop[1], shop[2])
		else:
			_lamp(Vector2(x + 355, 0))
			if posmod(i, 4) == 1:
				draw_texture_rect(TREE, Rect2(x + 306, -95, 54, 95), false, Color("bab8c5"))
		var wire := PackedVector2Array()
		for k in 9:
			wire.append(Vector2(x + k * 53, -310 + sin(k * PI / 8) * 26))
		draw_polyline(wire, Color("25243a"), 3)
		if posmod(i, 4) == 1:
			for k in 4:
				draw_rect(Rect2(x + 110 + k * 45, -291, 24, 32 + k % 2 * 8),
					Color("8f809a") if k % 2 else Color("b89281"))

func _storefront(x: float, title: String, kind: String, accent: Color) -> void:
	draw_texture_rect(SHOP, Rect2(x, -172, 320, 160), false, Color("c8b6a9"))
	draw_rect(Rect2(x - 4, -216, 328, 46), INK)
	draw_rect(Rect2(x, -212, 320, 3), accent)
	var px := 3.0 if PixelText.width(title, 3.0) <= 296.0 else 2.0
	PixelText.draw_centered(self, x + 160, -193.0 - PixelText.height(px) * 0.5, title, px,
		AMBER, Color("17131f"))
	draw_texture_rect_region(AWNING, Rect2(x - 8, -174, 336, 42), Rect2(6, 147, 2161, 320))
	draw_rect(Rect2(x + 24, -54, 272, 41), Color("67484a"))
	draw_rect(Rect2(x + 20, -58, 280, 7), Color("b68965"))
	for k in 6:
		draw_rect(Rect2(x + 42 + k * 38, -71, 9, 12), AMBER.darkened(0.2))
	match kind:
		"tea":
			for k in 3:
				draw_rect(Rect2(x + 70 + k * 60, -84, 17, 14), Color("b45737"))
				draw_rect(Rect2(x + 68 + k * 60, -88, 21, 4), Color("e4d5b7"))
		"barber":
			draw_rect(Rect2(x + 286, -146, 15, 85), Color("eee0c6"))
			for k in 4:
				draw_rect(Rect2(x + 287, -140 + k * 20, 13, 10), Color("a94e55") if k % 2 else Color("56899b"))
		"bakery":
			for k in 4:
				draw_rect(Rect2(x + 65 + k * 54, -88, 34, 19), Color("d39a5b"))
				draw_rect(Rect2(x + 70 + k * 54, -85, 24, 4), Color("f2c682"))
		"simit":
			for k in 5:
				draw_arc(Vector2(x + 60 + k * 45, -94), 12, 0, TAU, 12, Color("d59b52"), 6)
		"hardware":
			for k in 3:
				draw_rect(Rect2(x + 76 + k * 71, -116, 7, 52), Color("a4a8a4"))
				draw_rect(Rect2(x + 62 + k * 71, -71, 35, 8), Color("5e7484"))
		"garage":
			draw_rect(Rect2(x + 47, -140, 235, 112), Color("242b36"))
			for k in 5:
				draw_rect(Rect2(x + 47, -134 + k * 22, 235, 4), Color("727b85"))

func _lamp(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(-4, -250), Vector2(8, 250)), INK)
	draw_rect(Rect2(p + Vector2(-10, -8), Vector2(20, 8)), Color("615777"))
	draw_rect(Rect2(p + Vector2(-4, -252), Vector2(43, 7)), INK)
	draw_colored_polygon(PackedVector2Array([p + Vector2(20, -250),
		p + Vector2(43, -250), p + Vector2(65, -235), p + Vector2(2, -235)]), INK)
	draw_rect(Rect2(p + Vector2(17, -235), Vector2(30, 7)), AMBER)
	draw_colored_polygon(PackedVector2Array([p + Vector2(17, -228),
		p + Vector2(47, -228), p + Vector2(118, -16), p + Vector2(-57, -16)]),
		Color(1.0, 0.76, 0.43, 0.045))

class CityLayer extends Node2D:
	var camera: Camera2D
	func _ready() -> void:
		z_index = -90
		z_as_relative = false
	func _process(_delta: float) -> void:
		camera = get_viewport().get_camera_2d()
		if camera != null:
			global_position = camera.get_screen_center_position()
			queue_redraw()
	func _draw() -> void:
		if camera == null:
			return
		var pan := fposmod(camera.get_screen_center_position().x * 0.08, 1700.0)
		for i in range(-1, 2):
			draw_texture_rect(CITY, Rect2(-850 + i * 1700 - pan, -560, 1700, 956), false, Color("888ba9"))
		draw_rect(Rect2(-1000, -650, 2000, 1300), Color(0.17, 0.15, 0.27, 0.25))
