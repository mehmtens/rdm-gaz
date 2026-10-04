## PauseMenu — bölüm içi duraklat menüsü (Görev 27).
##
## `pause` girdisi (ESC / gamepad Start) ile Main açar/kapatır. Dünyayı
## `get_tree().paused` ile dondurur; kendisi PROCESS_MODE_ALWAYS. Devam,
## kontrol noktası, bölüm başı, ses kaydırıcısı, ana menü.
class_name PauseMenu
extends CanvasLayer

signal checkpoint_requested
signal restart_requested
signal menu_requested
signal armory_requested(item_id: String)

var _open: bool = false
var _root: VBoxContainer
var _first_btn: Button
var _armory_coins: Label
var _armory_status: Label


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()


func is_open() -> bool:
	return _open


func toggle() -> void:
	if _open:
		close()
	else:
		open()


func open() -> void:
	if _open:
		return
	_open = true
	visible = true
	get_tree().paused = true
	Sfx.play(&"checkpoint", 1.4, -6.0)
	_refresh_armory_coins(GameState.coins)
	_first_btn.grab_focus()


func close() -> void:
	if not _open:
		return
	_open = false
	visible = false
	get_tree().paused = false


# --- kurulum ---------------------------------------------------------

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.05, 0.82)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	add_child(center)

	_root = VBoxContainer.new()
	_root.theme = UIStyle.menu_theme()
	_root.add_theme_constant_override(&"separation", 12)
	_root.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(_root)

	var title := Label.new()
	title.text = "DURAKLATILDI"
	title.add_theme_font_size_override(&"font_size", 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(title)
	_root.add_child(HSeparator.new())

	_first_btn = _mk_btn("DEVAM ET", close)
	_mk_btn("KONTROL NOKTASINA DÖN", func() -> void:
		close()
		checkpoint_requested.emit())
	_mk_btn("BÖLÜMÜ BAŞTAN", func() -> void:
		close()
		restart_requested.emit())

	_root.add_child(HSeparator.new())
	var armory_title := Label.new()
	armory_title.text = "Cep cephaneliği"
	armory_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	armory_title.add_theme_font_size_override(&"font_size", 23)
	_root.add_child(armory_title)
	_armory_coins = Label.new()
	_armory_coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_armory_coins.add_theme_color_override(&"font_color", Color(1.0, 0.82, 0.32))
	_root.add_child(_armory_coins)

	var weapon_row := HBoxContainer.new()
	weapon_row.alignment = BoxContainer.ALIGNMENT_CENTER
	weapon_row.add_theme_constant_override(&"separation", 8)
	_root.add_child(weapon_row)
	_armory_button(weapon_row, "Yumruk", "fists")
	_armory_button(weapon_row, "Sopa · 20", "bat")
	_armory_button(weapon_row, "Bıçak · 25", "knife")
	_armory_button(weapon_row, "Tabanca · 40", "pistol")
	_armory_button(weapon_row, "Tüfek · 60", "rifle")
	_armory_button(weapon_row, "Zırh · 30", "armor")

	_armory_status = Label.new()
	_armory_status.text = "Silahlar bu can için geçerlidir; ölünce yumruğa dönersin."
	_armory_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_armory_status.add_theme_font_size_override(&"font_size", 13)
	_armory_status.add_theme_color_override(&"font_color", Color(0.75, 0.8, 0.86))
	_root.add_child(_armory_status)
	GameState.coins_changed.connect(_refresh_armory_coins)

	var vol_row := HBoxContainer.new()
	vol_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vol_row.add_theme_constant_override(&"separation", 12)
	var vl := Label.new()
	vl.text = "Ses"
	vol_row.add_child(vl)
	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(240, 0)
	slider.min_value = -40.0
	slider.max_value = 6.0
	slider.step = 1.0
	slider.value = Save.master_volume_db
	slider.value_changed.connect(func(v: float) -> void: Save.set_volume_db(v))
	vol_row.add_child(slider)
	_root.add_child(vol_row)

	_root.add_child(HSeparator.new())
	_mk_btn("ANA MENÜ", func() -> void:
		close()
		menu_requested.emit())


func _mk_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 0)
	b.focus_mode = Control.FOCUS_ALL
	b.pressed.connect(cb)
	_root.add_child(b)
	return b


func _armory_button(row: HBoxContainer, text: String, item_id: String) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(112, 38)
	button.pressed.connect(func() -> void: armory_requested.emit(item_id))
	row.add_child(button)


func _refresh_armory_coins(total: int) -> void:
	if _armory_coins != null:
		_armory_coins.text = "Bu bölümdeki coin: %d" % total


func show_armory_status(text: String, success := false) -> void:
	if _armory_status == null:
		return
	_armory_status.text = text
	_armory_status.modulate = Color(0.35, 0.95, 0.78) if success else Color(1.0, 0.55, 0.42)
