## ShopMenu — mağaza ekranı (Görev 14).
##
## `Shop.ITEMS` listesini gösterir; `Save.total_coins` ile satın alınır.
## Ürün etkileri Main tarafından koşu başında uygulanır (Save.owns).
extends Control

const MENU_SCENE := "res://scenes/MainMenu.tscn"

@onready var _coins: Label = $Root/Coins
@onready var _list: HBoxContainer = $Root/List


var _t := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Music.play("menu")
	$Root/Back.pressed.connect(func() -> void: Transition.go(MENU_SCENE))
	if has_node(^"BG"):
		$BG.queue_free()
	theme = UIStyle.menu_theme()
	var title: Label = $Root/Title
	title.add_theme_font_size_override(&"font_size", 52)
	title.add_theme_color_override(&"font_color", Color(0.98, 0.9, 0.82))
	title.add_theme_color_override(&"font_outline_color", Color(0.5, 0.1, 0.12))
	title.add_theme_constant_override(&"outline_size", 8)
	_coins.add_theme_color_override(&"font_color", UIStyle.ACCENT)
	_coins.add_theme_font_size_override(&"font_size", 20)
	_build()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	UIStyle.draw_city_bg(self, get_viewport_rect().size, _t)


func _build() -> void:
	for c in _list.get_children():
		c.queue_free()
	_coins.text = "Coin: %d" % Save.total_coins
	var moves := _column("HAREKETLER")
	var upgrades := _column("GELİŞTİRMELER")

	for it in Shop.ITEMS:
		var required_level := int(it.get("unlock_level", 0))
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 46)
		row.add_theme_constant_override(&"separation", 12)

		var lbl := Label.new()
		lbl.text = "%s  —  %s  (%d)" % [it.name, it.desc, it.cost]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		if Save.unlocked_level < required_level:
			var locked := Label.new()
			locked.text = "BÖLÜM %d SONRASI" % required_level
			row.add_child(locked)
		elif Save.owns(it.id):
			var owned := Label.new()
			owned.text = "SAHİP"
			row.add_child(owned)
		else:
			var b := Button.new()
			b.text = "SATIN AL"
			b.custom_minimum_size = Vector2(120, 0)
			b.disabled = Save.total_coins < int(it.cost)
			b.pressed.connect(_buy.bind(String(it.id), int(it.cost)))
			row.add_child(b)

		moves.add_child(row)

	for it in Shop.UPGRADES:
		var level := Save.upgrade_level(String(it.id))
		var costs: Array = it.costs
		var max_level := costs.size()
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 46)
		row.add_theme_constant_override(&"separation", 12)
		var lbl := Label.new()
		lbl.text = "%s  %d/%d — %s" % [it.name, level, max_level, it.desc]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		var requirement := String(it.get("requires", ""))
		if not requirement.is_empty() and not Save.owns(requirement):
			var locked := Label.new()
			locked.text = "ÖNCE ÜÇÜNCÜ VURUŞ"
			row.add_child(locked)
		elif level >= max_level:
			var complete := Label.new()
			complete.text = "MAKSİMUM"
			row.add_child(complete)
		else:
			var cost := int(costs[level])
			var b := Button.new()
			b.text = "YÜKSELT · %d" % cost
			b.custom_minimum_size = Vector2(130, 0)
			b.disabled = Save.total_coins < cost
			b.pressed.connect(_upgrade.bind(String(it.id), cost, max_level))
			row.add_child(b)
		upgrades.add_child(row)


func _column(title: String) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override(&"separation", 4)
	var heading := Label.new()
	heading.text = title
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_color_override(&"font_color", UIStyle.ACCENT)
	heading.add_theme_font_size_override(&"font_size", 20)
	column.add_child(heading)
	_list.add_child(column)
	return column


func _buy(item_id: String, cost: int) -> void:
	if Save.buy(item_id, cost):
		Sfx.play(&"coin")
		_build()


func _upgrade(item_id: String, cost: int, max_level: int) -> void:
	if Save.buy_upgrade(item_id, cost, max_level):
		Sfx.play(&"coin")
		_build()
