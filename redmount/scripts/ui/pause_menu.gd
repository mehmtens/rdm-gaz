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
var _costume_badge: PanelContainer
var _costume_icon: TextureRect
var _costume_name: Label
var _costume_bonus: Label


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
	refresh_costume()
	_first_btn.grab_focus()


func close() -> void:
	if not _open:
		return
	_open = false
	visible = false
	get_tree().paused = false


# --- kurulum ---------------------------------------------------------

const ICONS := {
	"fists": preload("res://assets/ui/pixel/ikon_yumruk.png"),
	"bat": preload("res://assets/pickups/placeholder_bat.png"),
	"knife": preload("res://assets/pickups/placeholder_knife.png"),
	"anahtar": preload("res://assets/pickups/placeholder_anahtar.png"),
	"semsiye": preload("res://assets/pickups/placeholder_semsiye.png"),
	"tas": preload("res://assets/pickups/placeholder_tas.png"),
	"pistol": preload("res://assets/pickups/placeholder_pistol.png"),
	"rifle": preload("res://assets/ui/pixel/ikon_tufek.png"),
	"armor": preload("res://assets/pickups/placeholder_armor.png"),
}
## Cep cephaneliği — TEK KAYNAK: Main ve Survival aynı kartları, fiyatları ve
## kuşanma notunu kullanır. Sıra kart sırasıdır; `res` WeaponConfig, GunConfig
## veya ArmorConfig (yumrukta null).
const ARMORY := [
	{"id": "fists", "label": "Yumruk", "cost": 0, "res": null,
		"note": "Yakın dövüş: Yumruk"},
	{"id": "bat", "label": "Sopa", "cost": 20, "res": preload("res://resources/weapons/bat.tres"),
		"note": "Sopa kuşanıldı. J ile savur."},
	{"id": "knife", "label": "Bıçak", "cost": 25, "res": preload("res://resources/weapons/knife.tres"),
		"note": "Bıçak kuşanıldı. Hızlı ama kısa menzilli."},
	{"id": "anahtar", "label": "Anahtar", "cost": 30, "res": preload("res://resources/weapons/anahtar.tres"),
		"note": "Boru anahtarı: yavaş, kalkanı ve bloğu deler."},
	{"id": "semsiye", "label": "Şemsiye", "cost": 25, "res": preload("res://resources/weapons/semsiye.tres"),
		"note": "Şemsiye: uzun menzil, düşmanı havaya kaldırır."},
	{"id": "tas", "label": "Taş", "cost": 15, "res": preload("res://resources/weapons/kaldirim_tasi.tres"),
		"note": "Kaldırım taşı: 3 atış, L ile yay çizerek fırlat."},
	{"id": "pistol", "label": "Tabanca", "cost": 40, "res": preload("res://resources/weapons/pistol.tres"),
		"note": "Tabanca kuşanıldı. L ile ateş et."},
	{"id": "rifle", "label": "Tüfek", "cost": 60, "res": preload("res://resources/weapons/rifle.tres"),
		"note": "Tüfek kuşanıldı. L ile seri ateş et."},
	{"id": "armor", "label": "Zırh", "cost": 30, "res": preload("res://resources/armor/body_armor.tres"),
		"note": "Zırh: hasar -%50, hız -%15, 6 darbe."},
]
const COIN_ICON := preload("res://assets/ui/pixel/coin.png")
const GOLD := Color(1.0, 0.82, 0.45)
const MUTED := Color(0.72, 0.68, 0.74)


## İki piksel panel yan yana: solda duraklat menüsü (devam / kontrol noktası /
## baştan / ses / ana menü), sağda cep cephaneliği (ikonlu silah kartları).
func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.05, 0.78)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_meta(&"pixel_done", true)
	add_child(dim)

	var center := CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.theme = UIStyle.menu_theme()
	add_child(center)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 18)
	center.add_child(row)

	# --- Sol: menü ---
	var left := PanelContainer.new()
	left.add_theme_stylebox_override(&"panel", PixelUI.box("panel", 26))
	row.add_child(left)
	_root = VBoxContainer.new()
	_root.add_theme_constant_override(&"separation", 10)
	_root.custom_minimum_size = Vector2(380, 0)
	left.add_child(_root)
	var title := Label.new()
	title.text = "DURAKLATILDI"
	title.add_theme_font_size_override(&"font_size", 36)
	title.add_theme_color_override(&"font_color", GOLD)
	_root.add_child(title)
	_build_costume_badge()
	_first_btn = _mk_btn("DEVAM ET", close)
	_mk_btn("KONTROL NOKTASINA DÖN", func() -> void:
		close()
		checkpoint_requested.emit())
	_mk_btn("BÖLÜMÜ BAŞTAN", func() -> void:
		close()
		restart_requested.emit())
	var vol_row := HBoxContainer.new()
	vol_row.add_theme_constant_override(&"separation", 12)
	var vl := Label.new()
	vl.text = "SES"
	vol_row.add_child(vl)
	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(260, 32)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = -40.0
	slider.max_value = 6.0
	slider.step = 1.0
	slider.value = Save.master_volume_db
	slider.value_changed.connect(func(v: float) -> void: Save.set_volume_db(v))
	vol_row.add_child(slider)
	_root.add_child(vol_row)
	# Titreşim yalnız dokunmatik cihazda anlamlı; masaüstünde düğme gösterilmez.
	if TouchControls.active_on_device():
		var vib := _mk_btn(_vibration_text(), toggle_vibration)
		vib.name = "Vibration"
	_mk_btn("ANA MENÜ", func() -> void:
		close()
		menu_requested.emit())

	# --- Sağ: cep cephaneliği ---
	var right := PanelContainer.new()
	right.add_theme_stylebox_override(&"panel", PixelUI.box("panel", 26))
	row.add_child(right)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 10)
	col.custom_minimum_size = Vector2(420, 0)
	right.add_child(col)
	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", 10)
	col.add_child(head)
	var at := Label.new()
	at.text = "CEP CEPHANELİĞİ"
	at.add_theme_color_override(&"font_color", GOLD)
	at.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(at)
	var ci := TextureRect.new()
	ci.texture = COIN_ICON
	ci.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ci.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	head.add_child(ci)
	_armory_coins = Label.new()
	_armory_coins.add_theme_color_override(&"font_color", GOLD)
	head.add_child(_armory_coins)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 10)
	grid.add_theme_constant_override(&"v_separation", 10)
	col.add_child(grid)
	for item in ARMORY:
		_armory_button(grid, item.label, item.id, item.cost)
	_armory_status = Label.new()
	_armory_status.text = "Silahlar bu can için geçerli; ölünce yumruğa dönersin."
	_armory_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_armory_status.custom_minimum_size = Vector2(400, 0)
	_armory_status.add_theme_color_override(&"font_color", MUTED)
	col.add_child(_armory_status)
	GameState.coins_changed.connect(_refresh_armory_coins)


## Kart kaydı; bilinmeyen kimlikte boş sözlük.
## "Giyili" rozeti: başlık ikonu + kostüm adı + bonusu. Kostüm bonusu sahada
## görünmez; duraklatınca oyuncu neyi taşıdığını hatırlasın. Bonussuz sokak
## ceketinde rozet gizlenir.
func _build_costume_badge() -> void:
	_costume_badge = PanelContainer.new()
	_costume_badge.name = "Costume"
	_costume_badge.add_theme_stylebox_override(&"panel", PixelUI.box("panel_hud", 22))
	_root.add_child(_costume_badge)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override(&"separation", 12)
	_costume_badge.add_child(hb)
	_costume_icon = TextureRect.new()
	_costume_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_costume_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_costume_icon.custom_minimum_size = Vector2(72, 44)
	_costume_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(_costume_icon)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override(&"separation", 2)
	vb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(vb)
	_costume_name = Label.new()
	_costume_name.add_theme_color_override(&"font_color", MUTED)
	vb.add_child(_costume_name)
	_costume_bonus = Label.new()
	_costume_bonus.add_theme_color_override(&"font_color", GOLD)
	vb.add_child(_costume_bonus)
	refresh_costume()


func refresh_costume() -> void:
	if _costume_badge == null:
		return
	var it := Shop.costume(Save.costume)
	var bonus := Shop.costume_bonus_text(it.id)
	_costume_badge.visible = bonus != ""
	_costume_name.text = "GİYİLİ: " + String(it.name)
	_costume_bonus.text = bonus
	var acc := String(it.get("accessory", ""))
	_costume_icon.texture = load("res://assets/anim/costume_acc/%s.png" % acc) if acc != "" else null


static func armory_item(item_id: String) -> Dictionary:
	for item in ARMORY:
		if item.id == item_id:
			return item
	return {}


## Fiyat; bilinmeyen kimlikte -1.
static func armory_cost(item_id: String) -> int:
	var item := armory_item(item_id)
	return int(item.cost) if not item.is_empty() else -1


## Kartın kaynağını türüne göre kuşandırır (yumruk ayrı: select_fists).
static func armory_equip(player: Node, item: Dictionary) -> void:
	var res: Resource = item.get("res")
	if res is WeaponConfig:
		player.equip_weapon(res)
	elif res is GunConfig:
		player.equip_gun(res)
	elif res is ArmorConfig:
		player.equip_armor(res)


func toggle_vibration() -> void:
	Save.set_vibration(not Save.vibration)
	(_root.get_node(^"Vibration") as Button).text = _vibration_text()
	TouchControls.haptic_tick()


static func _vibration_text() -> String:
	return "TİTREŞİM: AÇIK" if Save.vibration else "TİTREŞİM: KAPALI"


func _mk_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 46)
	b.focus_mode = Control.FOCUS_ALL
	b.pressed.connect(cb)
	_root.add_child(b)
	return b


## Silah kartı: piksel ikon + ad + fiyat.
func _armory_button(parent: Container, text: String, item_id: String, cost: int) -> void:
	var button := Button.new()
	button.text = "%s · %d" % [text, cost] if cost > 0 else text
	button.icon = ICONS.get(item_id)
	button.expand_icon = false
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(205, 60)
	button.add_theme_constant_override(&"h_separation", 8)
	button.pressed.connect(func() -> void: armory_requested.emit(item_id))
	parent.add_child(button)


func _refresh_armory_coins(total: int) -> void:
	if _armory_coins != null:
		_armory_coins.text = "%d" % total


func show_armory_status(text: String, success := false) -> void:
	if _armory_status == null:
		return
	_armory_status.text = text
	_armory_status.modulate = Color(0.35, 0.95, 0.78) if success else Color(1.0, 0.55, 0.42)
