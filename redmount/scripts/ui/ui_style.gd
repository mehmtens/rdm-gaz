## UIStyle — menü/mağaza gibi tam-ekran arayüzler için ortak tema + arka plan.
## Görev 24: ana menü ve mağaza aynı görünümü paylaşsın.
class_name UIStyle
extends RefCounted

const ACCENT := Color(1.0, 0.65, 0.4)


## Ortak menü teması — outline'lı etiketler + yuvarlatılmış/hover'lı düğmeler.
static func menu_theme() -> Theme:
	var th := Theme.new()
	th.default_font_size = 17
	th.set_color(&"font_color", &"Label", Color(0.92, 0.93, 0.96))
	th.set_color(&"font_outline_color", &"Label", Color(0, 0, 0, 0.78))
	th.set_constant(&"outline_size", &"Label", 4)
	for st in ["normal", "hover", "pressed", "disabled"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = {
			"normal": Color(0.16, 0.14, 0.18, 0.92),
			"hover": Color(0.55, 0.24, 0.16, 0.95),
			"pressed": Color(0.4, 0.16, 0.12, 0.95),
			"disabled": Color(0.12, 0.12, 0.14, 0.6),
		}[st]
		sb.set_corner_radius_all(6)
		sb.set_border_width_all(2)
		sb.border_color = Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.8 if st == "hover" else 0.35)
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 8
		sb.content_margin_bottom = 8
		th.set_stylebox(st, &"Button", sb)
	th.set_color(&"font_color", &"Button", Color(0.96, 0.95, 0.94))
	th.set_color(&"font_hover_color", &"Button", Color.WHITE)
	th.set_color(&"font_disabled_color", &"Button", Color(0.5, 0.5, 0.55))
	return th


## Prosedürel gece-şehir arka planı — bir Control'ün `_draw`'undan çağır.
static func draw_city_bg(ci: CanvasItem, size: Vector2, t: float) -> void:
	var top := Color(0.09, 0.10, 0.18)
	var bot := Color(0.34, 0.16, 0.20)
	var steps := 40
	for i in steps:
		var f := float(i) / steps
		ci.draw_rect(Rect2(0, size.y * f, size.x, size.y / steps + 1.0),
			top.lerp(bot, ease(f, 1.5)))
	for r in 5:
		ci.draw_circle(Vector2(size.x * 0.5, size.y * 1.05), size.x * (0.32 + 0.09 * r),
			Color(1.0, 0.55, 0.35, 0.035))
	var rng := RandomNumberGenerator.new()
	for layer in 2:
		rng.seed = 20 + layer
		var col := Color(0.10, 0.10, 0.16) if layer == 0 else Color(0.055, 0.055, 0.09)
		var base_y := size.y * (0.62 if layer == 0 else 0.72)
		var x := -20.0
		while x < size.x + 20.0:
			var bw := rng.randf_range(46, 120)
			var bh := rng.randf_range(80, 300) * (0.8 if layer == 0 else 1.15)
			ci.draw_rect(Rect2(x, base_y - bh, bw, bh + size.y), col)
			if layer == 0:
				var wy := base_y - bh + 16
				while wy < base_y - 14:
					var wx := x + 8
					while wx < x + bw - 8:
						if rng.randf() < 0.22:
							ci.draw_rect(Rect2(wx, wy, 5, 7), Color(1.0, 0.8, 0.45, 0.5))
						wx += 14
					wy += 18
			x += bw + rng.randf_range(-8, 10)
	rng.seed = 99
	for i in 40:
		var px := fposmod(rng.randf() * size.x + t * rng.randf_range(4, 16), size.x)
		var py := fposmod(rng.randf() * size.y - t * rng.randf_range(6, 20) + size.y, size.y)
		ci.draw_circle(Vector2(px, py), rng.randf_range(0.8, 2.0), Color(1.0, 0.75, 0.5, 0.35))
