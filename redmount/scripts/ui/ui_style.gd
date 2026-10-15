## UIStyle — menü/mağaza gibi tam-ekran arayüzler için ortak tema + arka plan.
## Görev 24: ana menü ve mağaza aynı görünümü paylaşsın.
class_name UIStyle
extends RefCounted

const ACCENT := Color(1.0, 0.65, 0.4)


## Ortak menü teması — piksel yazı + piksel çerçeveli düğmeler (PixelUI).
static func menu_theme() -> Theme:
	return PixelUI.theme()


const MENU_BG := preload("res://assets/backgrounds/level01_urban_dusk.png")
const EMBER := preload("res://assets/environment/pixel/fener_hale.png")


## Menü arka planı: oyunun boyalı piksel İstanbul manzarası (yavaş kayar),
## alt kısım koyulaşır, piksel kıvılcımlar yükselir. Control'ün `_draw`'undan çağır.
static func draw_city_bg(ci: CanvasItem, size: Vector2, t: float) -> void:
	var tex_size := MENU_BG.get_size()
	var k := maxf(size.x / tex_size.x, size.y / tex_size.y) * 1.08
	var w := tex_size.x * k
	var h := tex_size.y * k
	var drift := sin(t * 0.05) * (w - size.x) * 0.5
	ci.draw_texture_rect(MENU_BG, Rect2((size.x - w) * 0.5 + drift, (size.y - h) * 0.5, w, h), false,
		Color(0.78, 0.74, 0.82))
	# Alt kısımda menünün okunması için piksel adımlı karartma (kademeli bantlar).
	for i in 8:
		var y := size.y * (0.45 + i * 0.07)
		ci.draw_rect(Rect2(0, y, size.x, size.y), Color(0.05, 0.03, 0.07, 0.09))
	# Yükselen piksel kıvılcımlar (fener halesinin 3x3 çekirdeği).
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for i in 36:
		var px := fposmod(rng.randf() * size.x + t * rng.randf_range(4, 16), size.x)
		var py := fposmod(rng.randf() * size.y - t * rng.randf_range(6, 20) + size.y, size.y)
		ci.draw_texture_rect_region(EMBER, Rect2(roundf(px / 3.0) * 3.0, roundf(py / 3.0) * 3.0, 6, 6),
			Rect2(22, 22, 4, 4), Color(1.0, 0.8, 0.5, 0.8))
