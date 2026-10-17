## PixelUIBoot (autoload) — arayüzün tamamını piksel art'a çevirir.
##
## * Varsayılan yazı tipi: piksel font (ThemeDB fallback), boy 24.
## * Sahneye giren her Label / Button / RichTextLabel / LineEdit: piksel fontu alır,
##   yazı boyu piksel ızgarasına (24/36/48..) yuvarlanır, vektör kontur yerine
##   piksel gölge kullanılır.
## * Düz renkli (StyleBoxFlat) panel ve düğme stilleri piksel çerçeveyle değişir.
## Böylece eski arayüz kodu tek tek elden geçmeden aynı piksel dile oturur.
extends Node


func _ready() -> void:
	ThemeDB.fallback_font = PixelUI.font()
	ThemeDB.fallback_font_size = PixelUI.MIN_SIZE
	get_tree().node_added.connect(_on_node_added)
	# Ana sahne bu autoload'dan önce ağaca girmiş olabilir: mevcut düğümleri de tara.
	_walk.call_deferred(get_tree().root)


func _walk(n: Node) -> void:
	if n is Control:
		_pixelize(n)
	for ch in n.get_children(true):
		_walk(ch)


func _on_node_added(n: Node) -> void:
	if n is Control:
		# Düğümün kendi _ready'sindeki stil ayarlarından sonra uygula.
		_pixelize.call_deferred(n)


func _pixelize(c: Control) -> void:
	if not is_instance_valid(c):
		return
	var f := PixelUI.font()
	if c is Label or c is Button or c is LineEdit:
		c.add_theme_font_override(&"font", f)
		c.add_theme_font_size_override(&"font_size", PixelUI.snap(c.get_theme_font_size(&"font_size")))
		if c is Label:
			var outline := c.get_theme_constant(&"outline_size")
			if outline > 0:
				# Vektör kontur yerine sert piksel gölge (3 px = 1 sanat pikseli).
				c.add_theme_constant_override(&"outline_size", 0)
				c.add_theme_color_override(&"font_shadow_color", c.get_theme_color(&"font_outline_color"))
				c.add_theme_constant_override(&"shadow_offset_x", 3)
				c.add_theme_constant_override(&"shadow_offset_y", 3)
	elif c is RichTextLabel:
		for slot in [&"normal_font", &"bold_font", &"italics_font"]:
			c.add_theme_font_override(slot, f)
		for slot in [&"normal_font_size", &"bold_font_size", &"italics_font_size"]:
			c.add_theme_font_size_override(slot, PixelUI.snap(c.get_theme_font_size(slot)))
	if c is PanelContainer or c is Panel:
		var sb := c.get_theme_stylebox(&"panel")
		if sb is StyleBoxFlat:
			var flat := sb as StyleBoxFlat
			c.add_theme_stylebox_override(&"panel", PixelUI.box("panel_hud" if flat.bg_color.a < 0.9 else "panel"))
	if c is Slider:
		c.add_theme_stylebox_override(&"slider", PixelUI.box("cubuk_zemin", 3))
		c.add_theme_stylebox_override(&"grabber_area", PixelUI.box("cubuk_dolgu", 3))
		c.add_theme_stylebox_override(&"grabber_area_highlight", PixelUI.box("cubuk_dolgu", 3))
		var knob := load("res://assets/ui/pixel/tutamac.png")
		c.add_theme_icon_override(&"grabber", knob)
		c.add_theme_icon_override(&"grabber_highlight", knob)
	if c is ScrollBar:
		c.add_theme_stylebox_override(&"scroll", PixelUI.box("cubuk_zemin", 3))
		for st in [&"grabber", &"grabber_highlight", &"grabber_pressed"]:
			c.add_theme_stylebox_override(st, PixelUI.box("button_normal", 3))
	if c is ProgressBar:
		c.add_theme_stylebox_override(&"background", PixelUI.box("cubuk_zemin", 3))
		if c.get_theme_stylebox(&"fill") is StyleBoxFlat:
			c.add_theme_stylebox_override(&"fill", PixelUI.box("cubuk_dolgu", 3))
	if c is ColorRect and not c.has_meta(&"pixel_done"):
		_pixel_rect(c as ColorRect)
	if c is Button:
		for st in ["normal", "hover", "pressed", "disabled"]:
			var sb2 := c.get_theme_stylebox(st)
			if sb2 is StyleBoxFlat:
				c.add_theme_stylebox_override(st, PixelUI.box("button_" + st, 14))
		if c.get_theme_stylebox(&"focus") is StyleBoxFlat:
			c.add_theme_stylebox_override(&"focus", PixelUI.box("odak", 0))


## Düz renkli HUD dikdörtgenleri: dolgu -> piksel dolgu, çubuk zemini -> piksel
## çerçeve, panel -> piksel panel. Asıl ColorRect boyut/animasyon için kalır, görünmez olur.
func _pixel_rect(r: ColorRect) -> void:
	r.set_meta(&"pixel_done", true)
	var n := String(r.name)
	var kind := ""
	if n.contains("Fill"):
		kind = "cubuk_dolgu"
	elif n.contains("Bg") or n.contains("Bar"):
		kind = "cubuk_zemin"
	elif n.contains("Panel"):
		kind = "panel"
	if kind == "":
		return
	var tint := r.color
	r.color = Color(0, 0, 0, 0)
	var p := Panel.new()
	p.set_meta(&"pixel_done", true)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.set_anchors_preset(Control.PRESET_FULL_RECT)
	p.show_behind_parent = true
	var sb := PixelUI.box(kind, 3)
	p.add_theme_stylebox_override(&"panel", sb)
	if kind == "cubuk_dolgu":
		# Dolgu rengini koru (can kırmızı, boss mor vb.).
		p.self_modulate = Color(tint.r * 1.6, tint.g * 1.6, tint.b * 1.6, tint.a).clamp() if tint.v < 0.6 else Color(1, 1, 1, tint.a)
	elif kind == "panel":
		p.self_modulate = Color(1, 1, 1, maxf(tint.a, 0.85))
	r.add_child(p)
	r.move_child(p, 0)
