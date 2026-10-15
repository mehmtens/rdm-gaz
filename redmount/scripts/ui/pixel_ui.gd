## PixelUI — oyunun bütün arayüzünü piksel art yapan ortak kaynaklar.
##
## Yazı: assets/ui/redmount_pixel.ttf (tools/gen_pixel_font.py) — antialias yok,
## 12 px ızgara, yalnız tam sayı katlarla büyür (24 / 36 / 48 ...).
## Çerçeveler: assets/ui/pixel/*.png (tools/gen_pixel_ui.py, 3x kaydedilmiş 9 parça).
## PixelUIBoot autoload'u bunları her arayüz düğümüne kendiliğinden uygular.
class_name PixelUI
extends RefCounted

const FONT_PATH := "res://assets/ui/redmount_pixel.ttf"
## Piksel yazının temel ızgarası (em = 12 px).
const GRID := 12
## Okunurluk için en küçük boy: 2x (cap yüksekliği 14 px).
const MIN_SIZE := 24

static var _font: FontFile
static var _boxes := {}


static func font() -> FontFile:
	if _font == null:
		_font = load(FONT_PATH) as FontFile
		_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		_font.hinting = TextServer.HINTING_NONE
		_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		_font.fixed_size = GRID
		_font.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_INTEGER_ONLY
		_font.force_autohinter = false
	return _font


## İstenen boyu piksel ızgarasının tam katına yuvarlar (en az 2x).
static func snap(size: int) -> int:
	return maxi(MIN_SIZE, int(ceil(float(size) / GRID - 0.25)) * GRID)


## 9 parçalı piksel çerçeve. kind: panel / panel_hud / button_normal / button_hover /
## button_pressed / button_disabled / balon / cubuk_zemin / cubuk_dolgu
static func box(kind: String, pad := 18) -> StyleBoxTexture:
	var key := "%s:%d" % [kind, pad]
	if _boxes.has(key):
		return _boxes[key]
	var sb := StyleBoxTexture.new()
	sb.texture = load("res://assets/ui/pixel/%s.png" % kind)
	var m := 24 if kind.begins_with("panel") else (12 if kind.begins_with("button") or kind == "balon" else 9)
	sb.texture_margin_left = m
	sb.texture_margin_right = m
	sb.texture_margin_top = m
	sb.texture_margin_bottom = m
	sb.content_margin_left = pad
	sb.content_margin_right = pad
	sb.content_margin_top = maxi(6, pad - 6)
	sb.content_margin_bottom = maxi(6, pad - 6)
	sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	_boxes[key] = sb
	return sb


## Menü teması: piksel yazı + piksel düğme/panel.
static func theme() -> Theme:
	var th := Theme.new()
	th.default_font = font()
	th.default_font_size = MIN_SIZE
	th.set_stylebox(&"panel", &"Panel", box("panel"))
	th.set_stylebox(&"panel", &"PanelContainer", box("panel"))
	for st in ["normal", "hover", "pressed", "disabled"]:
		th.set_stylebox(st, &"Button", box("button_" + st, 14))
	th.set_stylebox(&"focus", &"Button", StyleBoxEmpty.new())
	th.set_color(&"font_color", &"Button", Color(0.96, 0.92, 0.84))
	th.set_color(&"font_hover_color", &"Button", Color.WHITE)
	th.set_color(&"font_pressed_color", &"Button", Color(1.0, 0.86, 0.6))
	th.set_color(&"font_disabled_color", &"Button", Color(0.5, 0.48, 0.52))
	th.set_color(&"font_shadow_color", &"Label", Color(0.05, 0.03, 0.06, 0.9))
	th.set_constant(&"shadow_offset_x", &"Label", 3)
	th.set_constant(&"shadow_offset_y", &"Label", 3)
	return th
