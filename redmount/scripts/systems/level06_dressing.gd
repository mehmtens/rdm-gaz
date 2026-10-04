## Arka Sokak İzi: İstanbul mahalleleri, çarşı, dere ve konvoy güzergâhı.
extends Node2D

const ATLAS := preload("res://assets/backgrounds/level01_turkish_locations_atlas.png")
const BACKSTREETS := preload("res://assets/backgrounds/level06_backstreets_atlas.png")
const NIGHT_MARKET := preload("res://assets/backgrounds/level07_night_market_atlas.png")
const CONVOY := preload("res://assets/backgrounds/level01_convoy_yard_v2.png")
@export_enum("backstreets", "night_market") var route := "backstreets"


func _ready() -> void:
	z_index = -5
	queue_redraw()


func _draw() -> void:
	# Her 1.920px panel rota sekansıyla eşleşir: mahalle → çarşı → garaj →
	# dere → avlu → pazar → depo. Atlasın ayırıcı çizgileri kaynakta kesilir.
	var cells := _night_market_cells() if route == "night_market" else _backstreet_cells()
	for i in cells.size():
		if route == "night_market":
			_night_market_cell(i * 1920.0, cells[i], i == 0)
		else:
			_atlas_cell(Vector2(960.0 + i * 1920.0, 0), cells[i])


func _backstreet_cells() -> Array[Vector2i]:
	return [
		Vector2i(0, 0), Vector2i(0, 3), Vector2i(0, 0),
		Vector2i(0, 3), Vector2i(0, 0), Vector2i(1, 0),
		Vector2i(0, 2), Vector2i(1, 0), Vector2i(0, 2),
		Vector2i(1, 1), Vector2i(1, 1), Vector2i(0, 1),
		Vector2i(1, 1), Vector2i(0, 1), Vector2i(0, 3),
		Vector2i(1, 3), Vector2i(0, 0), Vector2i(0, 2),
		Vector2i(1, 0), Vector2i(0, 2), Vector2i(1, 1),
		Vector2i(2, 0), Vector2i(2, 0), Vector2i(0, 1),
		Vector2i(2, 0), Vector2i(0, 1),
	]


func _night_market_cells() -> Array[Vector2i]:
	return [
		Vector2i(0, 0), Vector2i(0, 2), Vector2i(0, 0),
		Vector2i(0, 2), Vector2i(0, 0), Vector2i(1, 0),
		Vector2i(1, 0), Vector2i(1, 3), Vector2i(1, 0),
		Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 1),
		Vector2i(0, 1), Vector2i(1, 3), Vector2i(0, 0),
		Vector2i(0, 2), Vector2i(1, 0), Vector2i(1, 1),
		Vector2i(0, 3), Vector2i(1, 1), Vector2i(1, 0),
		Vector2i(1, 3), Vector2i(1, 1), Vector2i(0, 1),
		Vector2i(1, 1), Vector2i(0, 1),
	]


func _atlas_cell(pos: Vector2, cell: Vector2i) -> void:
	if cell.x == 2:
		draw_texture_rect(CONVOY, Rect2(pos.x - 960, -620, 1920, 770), false)
	elif cell.y < 2:
		var source := Rect2(cell.x * 768 + 2, cell.y * 512 + 2, 764, 508)
		draw_texture_rect_region(BACKSTREETS, Rect2(pos.x - 960, -740, 1920, 920), source)
	else:
		var source := Rect2(cell.x * 768 + 5, cell.y * 256 + 5, 758, 246)
		draw_texture_rect_region(ATLAS, Rect2(pos.x - 960, -620, 1920, 770), source)


func _night_market_cell(x: float, cell: Vector2i, first: bool) -> void:
	var texture: Texture2D = NIGHT_MARKET if cell.y < 2 else ATLAS
	var source := (Rect2(cell.x * 1024 + 2, cell.y * 384 + 2, 1020, 380)
		if cell.y < 2 else Rect2(cell.x * 768 + 5, cell.y * 256 + 5, 758, 246))
	if first:
		draw_texture_rect_region(texture, Rect2(x, -620, 2048, 770), source)
		return
	# Önceki panel 128 px uzar; yeni paneli aynı bölgede kademeli aç.
	for strip in 16:
		var offset := strip * 8.0
		var src_x := source.position.x + source.size.x * offset / 2048.0
		var src_w := source.size.x * 8.0 / 2048.0
		draw_texture_rect_region(texture, Rect2(x + offset, -620, 8, 770),
			Rect2(src_x, source.position.y, src_w, source.size.y),
			Color(1, 1, 1, float(strip) / 15.0))
	var cut := source.size.x * 128.0 / 2048.0
	draw_texture_rect_region(texture, Rect2(x + 128, -620, 1920, 770),
		Rect2(source.position.x + cut, source.position.y, source.size.x - cut, source.size.y))
