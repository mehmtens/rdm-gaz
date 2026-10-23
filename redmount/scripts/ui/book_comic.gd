## BookComic — kitap sonunda 4 karelik piksel çizgi roman şeridi (Dan the Man'in
## bölüm arası çizgi roman sahneleri gibi).
##
## `present(level_index)` kitabın son bölümü bitince çağrılır (Main yönetir; dünya
## duraklatılmıştır). Kareler soldan sağa sırayla "çakılır"; dokunma / `attack` /
## `jump` / Enter bir sonraki kareyi hemen getirir, hepsi açıkken kapatır. Duraklat
## tuşu şeridi atlar. Kare resimleri: tools/gen_comic_panels.py -> assets/ui/comic/.
class_name BookComic
extends CanvasLayer

signal finished

## Kitabın son bölüm indeksi -> kitap numarası (1 tabanlı).
const BOOK_END := {11: 1, 23: 2, 35: 3}
## Her kitabın 4 karesinin alt yazısı ve şeridin sonundaki "sıradaki" satırı.
const PAGES := {
	1: {
		"captions": [
			"Taht salonunda dans bitti. Karahanlı düştü.",
			"Zincir kırıldı. Gazelle özgür; söz tutuldu, biraz geç de olsa.",
			"Film rulosu ve bir sevkiyat defteri: Karahanlı tek halkaydı.",
			"Defterin ilk adresi Haliç kıyısı. Bu sefer ikisi birlikte.",
		],
		"next": "SIRADAKİ  ·  KİTAP 2 · HALİÇ'İN İZİ",
	},
	2: {
		"captions": [
			"Anahtar çevrildi. Bozdoğan Kemeri'nden su yeniden aktı.",
			"İstanbul susuz uyanmadı.",
			"Masada mürekkepli bir not: 'Kâğıt bitti. Şimdi ses.'",
			"Mühür Cağaloğlu'ndaki eski bir matbaayı gösteriyor.",
		],
		"next": "SIRADAKİ  ·  KİTAP 3 · İSTANBUL'UN SESİ",
	},
	3: {
		"captions": [
			"Yayın kesilmedi. Kayıtları bütün kıyı duydu.",
			"Nüzhet Hanım tutuklandı; Gazelle'in adı temize çıktı.",
			"İlk vapur kalkarken iki yorgun yolcu kıyıda.",
			"Balat'ta bir simit. Telefon bu kez tamamen kapalı.",
		],
		"next": "SON  ·  TEŞEKKÜRLER",
	},
}
## Kare resmi 100x60 sanat pikseli; 3x NEAREST -> 300x180 (dört kare 1280'e sığar).
const SCALE := 3
const PANEL_SIZE := Vector2(100, 60) * SCALE
const GAP := 12
## Kareler arası otomatik akış ve tek karenin çakılma süresi (sn).
const STEP := 1.1
const SLAM := 0.18
## Son kare açıldıktan sonra yanlışlıkla (basılı tuşla) kapanmasın diye bekleme.
const MIN_CLOSE := 0.5

var _root: Control
var _header: Label
var _next: Label
var _hint: Label
var _cells: Array[Control] = []
var _captions: Array[Label] = []
var _textures: Array[TextureRect] = []
var _active := false
var _shown := 0
var _t := 0.0
var _since := 0.0


static func has_page(level_index: int) -> bool:
	return BOOK_END.has(level_index)


func _ready() -> void:
	layer = 8
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.05, 0.94)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)

	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 22)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(col)

	_header = _label(col, 36, UIStyle.ACCENT)
	_header.add_theme_color_override(&"font_outline_color", Color(0.3, 0.06, 0.08))
	_header.add_theme_constant_override(&"outline_size", 6)

	var strip := HBoxContainer.new()
	strip.add_theme_constant_override(&"separation", GAP)
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(strip)
	for i in 4:
		# Hücre sabit boyutlu; içindeki kutu çakılma animasyonu için serbestçe oynar.
		var cell := Control.new()
		cell.custom_minimum_size = Vector2(PANEL_SIZE.x, PANEL_SIZE.y + 104)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strip.add_child(cell)
		var inner := VBoxContainer.new()
		inner.size = cell.custom_minimum_size
		inner.pivot_offset = PANEL_SIZE * 0.5
		inner.add_theme_constant_override(&"separation", 8)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(inner)
		var tex := TextureRect.new()
		tex.custom_minimum_size = PANEL_SIZE
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_SCALE
		tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(tex)
		var box := PanelContainer.new()
		box.add_theme_stylebox_override(&"panel", PixelUI.box("balon", 12))
		box.custom_minimum_size = Vector2(0, 88)  # üç satır; kutular eşit boyda dursun
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(box)
		var cap := Label.new()
		cap.custom_minimum_size = Vector2(PANEL_SIZE.x - 24, 0)
		cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cap.add_theme_font_override(&"font", PixelUI.font())
		cap.add_theme_font_size_override(&"font_size", 24)
		cap.add_theme_color_override(&"font_color", Color(0.16, 0.09, 0.1))
		cap.add_theme_constant_override(&"shadow_offset_x", 0)
		cap.add_theme_constant_override(&"shadow_offset_y", 0)
		box.add_child(cap)
		_cells.append(inner)
		_textures.append(tex)
		_captions.append(cap)

	_next = _label(col, 24, Color(1.0, 0.84, 0.4))
	_hint = _label(col, 24, Color(0.75, 0.75, 0.8))


func _label(parent: Control, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override(&"font", PixelUI.font())
	label.add_theme_font_size_override(&"font_size", font_size)
	label.add_theme_color_override(&"font_color", color)
	parent.add_child(label)
	return label


func is_active() -> bool:
	return _active


## Gösterilen kare sayısı (test için).
func shown_count() -> int:
	return _shown


func present(level_index: int) -> void:
	var book: int = BOOK_END.get(level_index, 0)
	if book == 0:
		finished.emit()
		return
	var page: Dictionary = PAGES[book]
	_header.text = "KİTAP %d SONU  ·  %s" % [book, GameState.BOOK_NAMES[book - 1]]
	for i in 4:
		_textures[i].texture = load("res://assets/ui/comic/k%d_%d.png" % [book, i])
		_captions[i].text = page["captions"][i]
		_cells[i].modulate.a = 0.0
	_next.text = page["next"]
	_next.modulate.a = 0.0
	_hint.text = ""
	_shown = 0
	_t = 0.0
	_since = 0.0
	_active = true
	visible = true
	_reveal_next()


func _reveal_next() -> void:
	if _shown >= 4:
		return
	var cell := _cells[_shown]
	cell.position.y = 14.0
	cell.scale = Vector2(1.08, 1.08)
	var tw := create_tween().set_parallel()
	tw.tween_property(cell, ^"modulate:a", 1.0, SLAM)
	tw.tween_property(cell, ^"position:y", 0.0, SLAM).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(cell, ^"scale", Vector2.ONE, SLAM).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	Sfx.play(&"land", 0.9 + 0.08 * _shown)
	_shown += 1
	_t = 0.0
	_since = 0.0
	if _shown == 4:
		create_tween().tween_property(_next, ^"modulate:a", 1.0, 0.4).set_delay(0.35)


func _process(delta: float) -> void:
	if not _active:
		return
	_t += delta
	_since += delta
	if _shown < 4 and _t >= STEP:
		_reveal_next()
	if _shown == 4 and _since >= MIN_CLOSE:
		_hint.text = "▸  DEVAM ETMEK İÇİN DOKUN" if TouchControls.active_on_device() else "▸  Enter / J"
		_hint.modulate.a = 0.6 + 0.4 * sin(_since * 4.0)


func _input(event: InputEvent) -> void:
	if not _active:
		return
	if event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		_close()
		return
	var pressed: bool = (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or event.is_action_pressed(&"attack") or event.is_action_pressed(&"jump") \
		or event.is_action_pressed(&"ui_accept")
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	advance()


## Bir sonraki kareyi hemen getirir; hepsi açıksa (ve kısa bekleme geçtiyse) kapatır.
func advance() -> void:
	if _shown < 4:
		_reveal_next()
	elif _since >= MIN_CLOSE:
		_close()


func _close() -> void:
	_active = false
	visible = false
	finished.emit()
