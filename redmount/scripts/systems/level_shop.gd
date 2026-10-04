## LevelShop — parkur içi büfe / tezgâh.
##
## Bölüm ortasında duran satış noktası. Oyuncu yanındayken büfeye DOKUNULUR
## (klavyede `interact` / E): oyun durur ve ürün paneli açılır. Panelde ürüne
## dokunmak o koşuda toplanan coin'le satın alır; alınan şey pickup olarak
## oyuncunun üstüne düşer, yani mevcut toplama akışı aynen çalışır.
class_name LevelShop
extends Node2D

const FACADE := preload("res://assets/environment/mahalle/shop_interior.png")
const AWNING := preload("res://assets/environment/mahalle/market_awning_v2.png")
const WORKSHOP := preload("res://assets/environment/shop_haddehane.png")
const UNDERGROUND := preload("res://assets/environment/shop_underground.png")
const FORTRESS := preload("res://assets/environment/shop_fortress.png")
const ICON := preload("res://scripts/pickups/pickup_icon.gd")
const CATALOG := {
	"can": {
		"label": "CAN", "price": 15, "icon": "health",
		"scene": preload("res://scenes/pickups/HealthPickup.tscn"),
	},
	"cephane": {
		"label": "CEPHANE", "price": 18, "icon": "ammo",
		"scene": preload("res://scenes/pickups/AmmoPickup.tscn"),
	},
	"sopa": {
		"label": "SOPA", "price": 22, "icon": "bat",
		"scene": preload("res://scenes/pickups/BatPickup.tscn"),
	},
	"bicak": {
		"label": "BIÇAK", "price": 30, "icon": "knife",
		"scene": preload("res://scenes/pickups/KnifePickup.tscn"),
	},
	"zirh": {
		"label": "ZIRH", "price": 45, "icon": "armor",
		"scene": preload("res://scenes/pickups/ArmorPickup.tscn"),
	},
	"tabanca": {
		"label": "TABANCA", "price": 60, "icon": "pistol",
		"scene": preload("res://scenes/pickups/PistolPickup.tscn"),
	},
}

## Oyuncu büfeye bu kadar yakınken dokunuş paneli açar (px).
const REACH := Vector2(360.0, 300.0)

@export var items: PackedStringArray = PackedStringArray(["can", "cephane"])
@export var title: String = "BÜFE"
@export_enum("street", "workshop", "underground", "fortress") var style: String = "street"
@export var accent: Color = Color("ff5d5d")
@export var facade_texture: Texture2D

## O an açık olan büfe paneli (yoksa null). Main dokunmatik düğmeleri buna göre gizler.
static var open_shop: LevelShop = null

var _t: float = 0.0
var _near := false
var _opened_ms := 0
var _panel: CanvasLayer


func _ready() -> void:
	z_index = 2
	# Panel açıkken dünya durur; büfe girdiyi dinlemeye devam etmeli.
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _exit_tree() -> void:
	if open_shop == self:
		open_shop = null
		get_tree().paused = false


static func is_any_open() -> bool:
	return open_shop != null and is_instance_valid(open_shop)


func is_open() -> bool:
	return _panel != null


func _process(delta: float) -> void:
	_t += delta
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	_near = player != null and absf(player.global_position.x - _center_x()) < REACH.x \
		and absf(player.global_position.y - global_position.y) < REACH.y
	if _near and not is_open() and not get_tree().paused and Input.is_action_just_pressed(&"interact"):
		open()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if is_open():
		if event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"interact"):
			close()
			get_viewport().set_input_as_handled()
		return
	if not _near or get_tree().paused:
		return
	var screen_pos := Vector2.INF
	if event is InputEventScreenTouch and event.pressed:
		screen_pos = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		screen_pos = event.position
	if screen_pos == Vector2.INF or _on_touch_pad(screen_pos):
		return
	var local := to_local(get_canvas_transform().affine_inverse() * screen_pos)
	if _tap_rect().has_point(local):
		open()
		get_viewport().set_input_as_handled()


## Ekrandaki hareket / saldırı düğmelerinin bölgesi: oraya basmak büfeyi açmaz.
func _on_touch_pad(screen_pos: Vector2) -> bool:
	if not TouchControls.active_on_device():
		return false
	var size := get_viewport().get_visible_rect().size
	if screen_pos.y < 100.0 and absf(screen_pos.x - size.x * 0.5) < 60.0:
		return true  # duraklat düğmesi
	return screen_pos.y > size.y - 330.0 and (screen_pos.x < 420.0 or screen_pos.x > size.x - 340.0)


func _facade_rect() -> Rect2:
	if facade_texture != null:
		var height := 400.0 * facade_texture.get_height() / facade_texture.get_width()
		return Rect2(-200, -height, 400, height)
	if style == "street":
		return Rect2(-100, -260, 400, 260)
	return Rect2(-90, -310, 380, 310)


func _tap_rect() -> Rect2:
	return _facade_rect().grow_individual(30, 90, 30, 10)


func _center_x() -> float:
	return global_position.x + _facade_rect().get_center().x


func open() -> void:
	if is_open() or is_any_open():
		return
	open_shop = self
	_opened_ms = Time.get_ticks_msec()
	get_tree().paused = true
	Sfx.play(&"checkpoint", 1.05, -5.0)
	_panel = _Panel.new(self)
	add_child(_panel)


func close() -> void:
	# Paneli açan dokunuşun kendisi (taklit fare olayı) paneli geri kapatmasın.
	if not is_open() or Time.get_ticks_msec() - _opened_ms < 250:
		return
	_panel.queue_free()
	_panel = null
	if open_shop == self:
		open_shop = null
	get_tree().paused = false


## Ürünü satın al: coin yeterse pickup oyuncunun üstüne düşer.
func buy(id: String) -> bool:
	var data: Dictionary = CATALOG[id]
	if not GameState.spend_coins(int(data["price"])):
		Sfx.play(&"weapon_break", 1.6, -8.0)
		return false
	Sfx.play(&"coin", 0.8)
	var item: Node2D = data["scene"].instantiate()
	get_parent().add_child(item)
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	item.global_position = (player.global_position + Vector2(0, -40)) if player != null \
		else global_position + Vector2(0, -60)
	return true


func _draw() -> void:
	var facade := _facade_rect()
	if facade_texture != null:
		draw_texture_rect(facade_texture, facade, false)
	elif style == "street":
		draw_texture_rect(FACADE, facade, false)
		draw_texture_rect_region(AWNING, Rect2(-110, -265, 420, 64), Rect2(6, 147, 2161, 320))
	else:
		var art := WORKSHOP if style == "workshop" else FORTRESS if style == "fortress" else UNDERGROUND
		draw_texture_rect(art, facade, false)
	var center := facade.get_center().x
	var board := PixelText.sign_board(self, Vector2(center, facade.position.y - 34.0), title, accent, 3.0, false)
	if not _near or is_open():
		return
	# Yakındayken tabelanın üstünde zıplayan "dokun" rozeti.
	var bob := roundf(sin(_t * 5.0) * 4.0)
	var hint := "DOKUN" if TouchControls.active_on_device() else "E"
	var tag_w := PixelText.width(hint, 3.0) + 24.0
	var tag := Rect2(roundf(center - tag_w * 0.5), board.position.y - 56.0 + bob, tag_w, 40.0)
	draw_rect(tag.grow(3.0), Color("17131f"))
	draw_rect(tag, Color("ffc857"))
	draw_rect(Rect2(tag.position.x, tag.end.y - 6.0, tag.size.x, 6.0), Color("d18b2c"))
	draw_rect(Rect2(center - 6.0, tag.end.y + 3.0, 12.0, 6.0), Color("17131f"))
	PixelText.draw_centered(self, center, tag.position.y + 2.0, hint, 3.0, Color("2a1c12"))


## Ürün paneli — tam ekran, dokunmatik. Ürün kartına dokun: satın al.
class _Panel extends CanvasLayer:
	const CARD := Vector2(190.0, 230.0)

	var _shop: LevelShop
	var _coins: Label
	var _cards: Array = []

	func _init(shop: LevelShop) -> void:
		_shop = shop

	func _ready() -> void:
		layer = 9
		process_mode = Node.PROCESS_MODE_ALWAYS
		var dim := ColorRect.new()
		dim.color = Color(0.03, 0.03, 0.06, 0.72)
		dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		dim.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed:
				_shop.close())
		add_child(dim)

		var center := CenterContainer.new()
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(center)

		var frame := PanelContainer.new()
		frame.add_theme_stylebox_override(&"panel", _box(Color("2a2036"), Color("8a5c3c"), 6, 22))
		center.add_child(frame)
		var column := VBoxContainer.new()
		column.add_theme_constant_override(&"separation", 16)
		frame.add_child(column)

		var heading := _Heading.new(_shop.title)
		column.add_child(heading)

		_coins = Label.new()
		_coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_coins.add_theme_font_size_override(&"font_size", 22)
		_coins.add_theme_color_override(&"font_color", Color("ffc857"))
		column.add_child(_coins)

		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override(&"separation", 14)
		column.add_child(row)
		for id in _shop.items:
			if not LevelShop.CATALOG.has(id):
				push_warning("LevelShop: bilinmeyen ürün '%s'" % id)
				continue
			var card := _Card.new(_shop, id)
			card.bought.connect(_refresh)
			row.add_child(card)
			_cards.append(card)

		var back := Button.new()
		back.text = "KAPAT"
		back.custom_minimum_size = Vector2(220, 58)
		back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		back.add_theme_font_size_override(&"font_size", 22)
		back.add_theme_stylebox_override(&"normal", _box(Color("5a3a2a"), Color("d9b36a"), 3, 8))
		back.add_theme_stylebox_override(&"hover", _box(Color("7a4d33"), Color("ffd98a"), 3, 8))
		back.add_theme_stylebox_override(&"pressed", _box(Color("3a2419"), Color("d9b36a"), 3, 8))
		back.pressed.connect(_shop.close)
		column.add_child(back)
		_refresh()

	func _refresh() -> void:
		_coins.text = "COIN  %d" % GameState.coins
		for card in _cards:
			card.queue_redraw()

	static func _box(fill: Color, border: Color, border_w: int, margin: int) -> StyleBoxFlat:
		var sb := StyleBoxFlat.new()
		sb.bg_color = fill
		sb.border_color = border
		sb.set_border_width_all(border_w)
		sb.set_content_margin_all(margin)
		sb.anti_aliasing = false
		return sb


## Panel başlığı — büfenin adı, tabelayla aynı piksel yazıyla.
class _Heading extends Control:
	var _text: String

	func _init(text: String) -> void:
		_text = text
		custom_minimum_size = Vector2(PixelText.width(text, 4.0) + 24.0, PixelText.height(4.0) + 4.0)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		PixelText.draw_centered(self, size.x * 0.5, 0.0, _text, 4.0, Color("f4e6c8"), Color("17131f"))


## Tek ürün kartı: ikon + ad + fiyat. Dokununca satın alır.
class _Card extends Button:
	signal bought

	var _shop: LevelShop
	var _id: String
	var _data: Dictionary
	var _flash := 0.0
	var _bought_t := 0.0

	func _init(shop: LevelShop, id: String) -> void:
		_shop = shop
		_id = id
		_data = LevelShop.CATALOG[id]
		custom_minimum_size = _Panel.CARD
		focus_mode = Control.FOCUS_NONE
		for state in [&"normal", &"hover", &"pressed", &"focus", &"disabled"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())

	func _ready() -> void:
		var icon: Node2D = LevelShop.ICON.new()
		icon.kind = _data["icon"]
		icon.position = Vector2(_Panel.CARD.x * 0.5, 96.0)
		icon.scale = Vector2(1.6, 1.6)
		add_child(icon)
		pressed.connect(_on_pressed)

	func _process(delta: float) -> void:
		if _flash > 0.0 or _bought_t > 0.0:
			_flash = maxf(_flash - delta * 2.4, 0.0)
			_bought_t = maxf(_bought_t - delta * 1.6, 0.0)
			queue_redraw()

	func _on_pressed() -> void:
		if _shop.buy(_id):
			_bought_t = 1.0
		else:
			_flash = 1.0
		bought.emit()
		queue_redraw()

	func _draw() -> void:
		var price: int = _data["price"]
		var afford := GameState.coins >= price
		var ink := Color("17131f")
		var body := Rect2(Vector2.ZERO, size)
		draw_rect(body, ink)
		draw_rect(body.grow(-4.0), Color("3b2d49") if afford else Color("2c2633"))
		draw_rect(Rect2(4, 4, size.x - 8, 4), Color("5d4a70") if afford else Color("3b3444"))
		if _bought_t > 0.0:
			draw_rect(body.grow(-4.0), Color(0.45, 0.95, 0.55, _bought_t * 0.35))
		if _flash > 0.0:
			draw_rect(body.grow(-4.0), Color(1.0, 0.25, 0.25, _flash * 0.4))
		PixelText.draw_centered(self, size.x * 0.5, 14.0, _data["label"], 3.0, Color("f4e6c8"), ink)
		# Fiyat etiketi — karşılanamıyorsa kırmızı okunur.
		var tag := Rect2(22, size.y - 62.0, size.x - 44.0, 44.0)
		var tone := Color("ffc857") if afford else Color("b94a4a")
		draw_rect(tag, ink)
		draw_rect(tag.grow(-3.0), tone)
		draw_rect(Rect2(tag.position.x + 3, tag.end.y - 9.0, tag.size.x - 6.0, 6.0), tone.darkened(0.25))
		PixelText.draw_centered(self, size.x * 0.5, tag.position.y + 4.0, "%d C" % price, 3.0, Color("2a1c12"))
