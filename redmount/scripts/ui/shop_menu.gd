## ShopMenu — piksel art mağaza ekranı.
##
## Tek panel, üç sekme: HAREKETLER (`Shop.ITEMS`, tek seferlik), GELİŞTİRMELER
## (`Shop.UPGRADES`, 3 kademe) ve KOSTÜMLER (`Shop.COSTUMES`, al → giy). Her ürün bir kart: ad, açıklama, kademe baklavaları,
## sağda coin ikonlu fiyat düğmesi. `Save.total_coins` ile satın alınır; etkileri
## Main koşu başında uygular. Klavye / gamepad ile gezilir, ESC menüye döner.
extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const COIN := preload("res://assets/ui/pixel/coin.png")
const LOCK := preload("res://assets/ui/pixel/kilit.png")
const PIP_ON := preload("res://assets/ui/pixel/pip_dolu.png")
const PIP_OFF := preload("res://assets/ui/pixel/pip_bos.png")
const IDLE_SHEET := preload("res://assets/anim/redmount/idle.png")
## Kostüm önizlemesi: idle sayfasının ilk karesinden gövde bölgesi (200×240 hücre);
## üstte başlığa (kaptan şapkası) yer bırakılır.
const PREVIEW_REGION := Rect2(52, 18, 100, 218)
## Oyundaki rig ölçeğiyle aynı (Redmount.tscn Rig 0.6) → sahadakiyle aynı pikseller.
const PREVIEW_SCALE := 0.6
const GOLD := Color(1.0, 0.82, 0.45)
const CREAM := Color(0.96, 0.92, 0.84)
const MUTED := Color(0.72, 0.68, 0.74)
const RED := Color(0.95, 0.55, 0.42)

var _t := 0.0
var _tab := 0
var _tabs: Array[Button] = []
var _coins: Label
var _grid: GridContainer
var _back: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Music.play("menu")
	theme = UIStyle.menu_theme()
	for ch in get_children():
		ch.queue_free()

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", PixelUI.box("panel", 24))
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 40
	panel.offset_right = -40
	panel.offset_top = 24
	panel.offset_bottom = -24
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 12)
	panel.add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", 12)
	col.add_child(head)
	var title := _label("MAĞAZA", GOLD)
	title.add_theme_font_size_override(&"font_size", 36)
	head.add_child(title)
	var wallet := PanelContainer.new()
	wallet.add_theme_stylebox_override(&"panel", PixelUI.box("panel_hud", 20))
	head.add_child(wallet)
	var wrow := HBoxContainer.new()
	wrow.add_theme_constant_override(&"separation", 10)
	wallet.add_child(wrow)
	wrow.add_child(_icon(COIN))
	_coins = _label("", GOLD)
	wrow.add_child(_coins)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	for i in 3:
		var tab := Button.new()
		tab.text = ["HAREKETLER", "GELİŞTİRMELER", "KOSTÜMLER"][i]
		tab.custom_minimum_size = Vector2(210, 48)
		tab.pressed.connect(_select.bind(i))
		tab.focus_entered.connect(_select.bind(i))
		head.add_child(tab)
		_tabs.append(tab)

	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override(&"h_separation", 14)
	_grid.add_theme_constant_override(&"v_separation", 12)
	_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_grid)

	_back = Button.new()
	_back.text = "GERİ"
	_back.custom_minimum_size = Vector2(200, 48)
	_back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_back.pressed.connect(func() -> void: Transition.go(MENU_SCENE))
	col.add_child(_back)

	_select(0)
	_tabs[0].call_deferred(&"grab_focus")


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	UIStyle.draw_city_bg(self, get_viewport_rect().size, _t)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		Transition.go(MENU_SCENE)


func _select(i: int) -> void:
	if i == _tab and _grid.get_child_count() > 0:
		return
	_tab = i
	for k in _tabs.size():
		var sel := k == i
		for st in ["normal", "hover", "pressed"]:
			_tabs[k].add_theme_stylebox_override(st, PixelUI.box("sekme_secili" if sel else "sekme", 10))
		_tabs[k].add_theme_color_override(&"font_color", GOLD if sel else MUTED)
	_rebuild()


func _rebuild() -> void:
	_coins.text = "%d" % Save.total_coins
	for ch in _grid.get_children():
		ch.queue_free()
	if _tab == 0:
		for it in Shop.ITEMS:
			_grid.add_child(_item_card(it))
	elif _tab == 1:
		for it in Shop.UPGRADES:
			_grid.add_child(_upgrade_card(it))
	else:
		for it in Shop.COSTUMES:
			_grid.add_child(_costume_card(it))


## Tek seferlik hareket / özellik kartı.
func _item_card(it: Dictionary) -> Control:
	var required := int(it.get("unlock_level", 0))
	var card := _card(String(it.name), String(it.desc))
	var right: HBoxContainer = card.get_meta(&"right")
	if Save.unlocked_level < required:
		right.add_child(_icon(LOCK))
		right.add_child(_label("BÖLÜM %d" % required, MUTED))
	elif Save.owns(String(it.id)):
		right.add_child(_label("ALINDI", GOLD))
	else:
		var b := _price(int(it.cost))
		b.pressed.connect(_buy.bind(String(it.id), int(it.cost)))
		right.add_child(b)
	return card


## Üç kademeli geliştirme kartı: kademe baklavaları + bir sonraki fiyat.
func _upgrade_card(it: Dictionary) -> Control:
	var level := Save.upgrade_level(String(it.id))
	var costs: Array = it.costs
	var card := _card(String(it.name), String(it.desc))
	var right: HBoxContainer = card.get_meta(&"right")
	var pips := HBoxContainer.new()
	pips.add_theme_constant_override(&"separation", 4)
	for k in costs.size():
		pips.add_child(_icon(PIP_ON if k < level else PIP_OFF))
	right.add_child(pips)
	var requirement := String(it.get("requires", ""))
	if not requirement.is_empty() and not Save.owns(requirement):
		right.add_child(_icon(LOCK))
	elif level >= costs.size():
		right.add_child(_label("TAM", GOLD))
	else:
		var cost := int(costs[level])
		var b := _price(cost)
		b.pressed.connect(_upgrade.bind(String(it.id), cost, costs.size()))
		right.add_child(b)
	return card


## Kostüm kartı: solda kostümle boyanmış Redmount, sağda fiyat / GİY / GİYİLDİ.
func _costume_card(it: Dictionary) -> Control:
	var id := String(it.id)
	var card := _card(String(it.name), String(it.desc))
	var row: HBoxContainer = card.get_child(0)
	var preview := TextureRect.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = IDLE_SHEET
	atlas.region = PREVIEW_REGION
	preview.texture = atlas
	preview.material = Shop.costume_material(id)
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = PREVIEW_REGION.size * PREVIEW_SCALE
	preview.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(preview)
	row.move_child(preview, 0)
	_preview_accessory(preview, id)
	var right: HBoxContainer = card.get_meta(&"right")
	var required := int(it.get("unlock_level", 0))
	if Save.costume == id:
		right.add_child(_label("GİYİLDİ", GOLD))
	elif Save.owns_costume(id):
		var b := Button.new()
		b.text = "GİY"
		b.custom_minimum_size = Vector2(120, 48)
		b.pressed.connect(_wear.bind(id))
		right.add_child(b)
	elif Save.unlocked_level < required:
		right.add_child(_icon(LOCK))
		right.add_child(_label("BÖLÜM %d" % required, MUTED))
	else:
		var b := _price(int(it.cost))
		b.pressed.connect(_buy_costume.bind(id, int(it.cost)))
		right.add_child(b)
	return card


func _card(title: String, desc: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override(&"panel", PixelUI.box("kart", 14))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 104)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 12)
	card.add_child(row)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override(&"separation", 2)
	row.add_child(text)
	text.add_child(_label(title.to_upper(), GOLD))
	var d := _label(desc, CREAM)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_child(d)
	var right := HBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_END
	right.add_theme_constant_override(&"separation", 10)
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(right)
	card.set_meta(&"right", right)
	return card


## Fiyat düğmesi: coin ikonu + tutar; parası yetmiyorsa soluk.
func _price(cost: int) -> Button:
	var b := Button.new()
	b.text = "%d" % cost
	b.icon = COIN
	b.custom_minimum_size = Vector2(120, 48)
	b.disabled = Save.total_coins < cost
	return b


func _icon(tex: Texture2D) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	r.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return r


func _label(text: String, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override(&"font_color", color)
	return l


func _buy(item_id: String, cost: int) -> void:
	if Save.buy(item_id, cost):
		Sfx.play(&"coin")
		_rebuild()
		_back.grab_focus()


func _upgrade(item_id: String, cost: int, max_level: int) -> void:
	if Save.buy_upgrade(item_id, cost, max_level):
		Sfx.play(&"coin")
		_rebuild()
		_back.grab_focus()


func _buy_costume(id: String, cost: int) -> void:
	if Save.buy_costume(id, cost):
		Sfx.play(&"coin")
		# Alınan kostüm hemen giyilir; oyuncu sonucu bir sonraki koşuda görür.
		Save.set_costume(id)
		_rebuild()
		_back.grab_focus()


func _wear(id: String) -> void:
	if Save.set_costume(id):
		Sfx.play(&"coin")
		_rebuild()
		_back.grab_focus()


## Önizlemenin üstüne kostümün başlığı: idle ilk karesinin baş çapası, önizleme ölçeğinde.
func _preview_accessory(preview: TextureRect, id: String) -> void:
	var tex := CostumeAccessory.texture_for(id)
	var a := CostumeAccessory.anchor("idle", 0)
	if tex == null or a.is_empty():
		return
	var p := CostumeAccessory.attach_point(a, String(Shop.costume(id).get("attach", "crown")))
	var hat := TextureRect.new()
	hat.texture = tex
	hat.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hat.size = tex.get_size() * PREVIEW_SCALE
	hat.position = (p - PREVIEW_REGION.position - CostumeAccessory.PIVOT) * PREVIEW_SCALE
	hat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.add_child(hat)
