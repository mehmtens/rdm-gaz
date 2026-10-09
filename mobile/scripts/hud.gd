## Hud — portre + can/özel barı, coin, silah, kombo sayacı, afiş, ipucu;
## duraklat menüsü, yenilgi ve bölüm sonu ekranları. Tamamı koddan kurulur.
class_name Hud
extends CanvasLayer

const GOLD := Color(1, 0.84, 0.3)
const INK := Color(0.05, 0.03, 0.08)

var level: Level

var _hp_bar: Control
var _coin_label: Label
var _coin_icon: TextureRect
var _weapon_icon: TextureRect
var _weapon_label: Label
var _combo_label: Label
var _banner: Label
var _hint: Label
var _hint_t := 0.0
var _flash: ColorRect
var _go: Label
var _shown_hp := 100.0
var _lag_hp := 100.0
var _overlay: Control


func _ready() -> void:
	layer = 10
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_flash = ColorRect.new()
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color(1, 1, 1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_flash)

	# Portre çerçevesi.
	var frame := Panel.new()
	frame.position = Vector2(18, 14)
	frame.size = Vector2(92, 92)
	frame.add_theme_stylebox_override("panel", _box(Color(0.12, 0.08, 0.16), GOLD, 4, 10))
	root.add_child(frame)
	var portrait := TextureRect.new()
	portrait.texture = load("res://art/items/portrait.png")
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.position = Vector2(8, 8)
	portrait.size = Vector2(76, 76)
	frame.add_child(portrait)

	_hp_bar = Control.new()
	_hp_bar.position = Vector2(118, 22)
	_hp_bar.size = Vector2(300, 60)
	_hp_bar.draw.connect(_draw_bars)
	root.add_child(_hp_bar)

	_weapon_icon = TextureRect.new()
	_weapon_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_weapon_icon.position = Vector2(122, 70)
	_weapon_icon.size = Vector2(40, 40)
	root.add_child(_weapon_icon)
	_weapon_label = _label(26, Color.WHITE)
	_weapon_label.position = Vector2(166, 72)
	root.add_child(_weapon_label)

	# Coin sayacı (üst orta).
	_coin_icon = TextureRect.new()
	_coin_icon.texture = load("res://art/items/coin.png")
	_coin_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_coin_icon.size = Vector2(44, 44)
	_coin_icon.pivot_offset = Vector2(22, 22)
	_coin_icon.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_coin_icon.position = Vector2(-70, 18)
	root.add_child(_coin_icon)
	_coin_label = _label(40, GOLD)
	_coin_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_coin_label.position = Vector2(-18, 14)
	root.add_child(_coin_label)

	# Duraklat düğmesi (sağ üst).
	var pause := Button.new()
	pause.text = "II"
	pause.focus_mode = Control.FOCUS_NONE
	pause.add_theme_font_size_override("font_size", 34)
	pause.add_theme_stylebox_override("normal", _box(Color(0.1, 0.07, 0.14, 0.75), GOLD, 3, 14))
	pause.add_theme_stylebox_override("hover", _box(Color(0.2, 0.14, 0.26, 0.85), GOLD, 3, 14))
	pause.add_theme_stylebox_override("pressed", _box(Color(0.3, 0.2, 0.36, 0.9), GOLD, 3, 14))
	pause.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause.position = Vector2(-96, 16)
	pause.size = Vector2(78, 72)
	pause.pressed.connect(open_pause)
	root.add_child(pause)

	_combo_label = _label(54, Color(1, 0.55, 0.25))
	_combo_label.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_combo_label.position = Vector2(-330, -170)
	_combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_combo_label.size = Vector2(300, 80)
	_combo_label.pivot_offset = Vector2(300, 40)
	root.add_child(_combo_label)

	_banner = _label(88, Color.WHITE)
	_banner.set_anchors_preset(Control.PRESET_CENTER)
	_banner.size = Vector2(1000, 120)
	_banner.position = Vector2(-500, -210)
	_banner.pivot_offset = Vector2(500, 60)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.modulate.a = 0
	root.add_child(_banner)

	_hint = _label(30, Color(1, 0.97, 0.88))
	_hint.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_hint.size = Vector2(1000, 50)
	_hint.position = Vector2(-500, 118)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.modulate.a = 0
	root.add_child(_hint)

	_go = _label(64, GOLD)
	_go.text = "İLERLE ▶"
	_go.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_go.position = Vector2(-330, -40)
	_go.visible = false
	root.add_child(_go)


func _label(size: int, c: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", c)
	l.add_theme_color_override("font_outline_color", INK)
	l.add_theme_constant_override("outline_size", maxi(8, size / 5))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func _box(bg: Color, border: Color, bw: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(radius)
	return sb


func _process(dt: float) -> void:
	var p := level.player
	if p == null:
		return
	_shown_hp = lerpf(_shown_hp, p.hp, 1.0 - exp(-dt * 18.0))
	_lag_hp = maxf(_shown_hp, _lag_hp - 40.0 * dt) if _lag_hp > _shown_hp else _shown_hp
	_hp_bar.queue_redraw()
	_coin_label.text = str(Game.run.get("coins", 0))
	if p.weapon == "":
		_weapon_icon.texture = null
		_weapon_label.text = ""
	else:
		_weapon_icon.texture = load("res://art/items/%s.png" % p.weapon)
		_weapon_label.text = "x%d" % p.weapon_uses
	if _hint_t > 0.0:
		_hint_t -= dt
		_hint.modulate.a = minf(1.0, _hint.modulate.a + dt * 4.0)
	else:
		_hint.modulate.a = maxf(0.0, _hint.modulate.a - dt * 3.0)
	if _go.visible:
		_go.modulate.a = 0.55 + 0.45 * sin(Time.get_ticks_msec() / 150.0)


func _draw_bars() -> void:
	var p := level.player
	var w := 290.0
	# Can barı: koyu çerçeve, gecikmeli beyaz iz, kırmızı dolgu, segment çizgileri.
	_hp_bar.draw_rect(Rect2(-4, -4, w + 8, 34), INK)
	_hp_bar.draw_rect(Rect2(0, 0, w, 26), Color(0.25, 0.08, 0.1))
	_hp_bar.draw_rect(Rect2(0, 0, w * _lag_hp / p.max_hp, 26), Color(1, 0.95, 0.85))
	var hc := Color(0.92, 0.2, 0.18) if p.hp > 30 else Color(1, 0.35 + 0.3 * sin(Time.get_ticks_msec() / 90.0), 0.2)
	_hp_bar.draw_rect(Rect2(0, 0, w * _shown_hp / p.max_hp, 26), hc)
	_hp_bar.draw_rect(Rect2(0, 0, w * _shown_hp / p.max_hp, 7), Color(1, 1, 1, 0.25))
	for i in range(1, 10):
		_hp_bar.draw_line(Vector2(w * i / 10.0, 0), Vector2(w * i / 10.0, 26), Color(0, 0, 0, 0.35), 2)
	# ÖZEL barı: iki segment (her biri bir kullanım).
	var mw := 210.0
	_hp_bar.draw_rect(Rect2(-3, 33, mw + 6, 18), INK)
	var ready := p.meter >= 50.0
	var mc := Color(0.35, 0.8, 1) if not ready else Color(0.55, 0.95, 1).lerp(Color.WHITE, 0.35 * absf(sin(Time.get_ticks_msec() / 160.0)))
	_hp_bar.draw_rect(Rect2(0, 36, mw * p.meter / 100.0, 12), mc)
	_hp_bar.draw_line(Vector2(mw / 2, 36), Vector2(mw / 2, 48), INK, 3)


# --- Olay gösterimleri ------------------------------------------------------

func coin_pulse() -> void:
	var tw := _coin_icon.create_tween()
	_coin_icon.scale = Vector2(1.35, 1.35)
	tw.tween_property(_coin_icon, "scale", Vector2.ONE, 0.15)


func show_combo(n: int) -> void:
	if n < 2:
		var tw0 := _combo_label.create_tween()
		tw0.tween_property(_combo_label, "modulate:a", 0.0, 0.3)
		return
	_combo_label.text = "%d KOMBO" % n
	_combo_label.modulate.a = 1.0
	_combo_label.scale = Vector2(1.3, 1.3)
	_combo_label.create_tween().tween_property(_combo_label, "scale", Vector2.ONE, 0.12)


func banner(text: String, c: Color, dur := 1.1) -> void:
	_banner.text = text
	_banner.add_theme_color_override("font_color", c)
	_banner.scale = Vector2(1.6, 1.6)
	_banner.modulate.a = 0.0
	var tw := _banner.create_tween()
	tw.tween_property(_banner, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_banner, "modulate:a", 1.0, 0.1)
	tw.tween_interval(dur)
	tw.tween_property(_banner, "modulate:a", 0.0, 0.3)


func show_hint(text: String) -> void:
	_hint.text = text
	_hint_t = 0.25


func flash(c: Color) -> void:
	_flash.color = c
	_flash.create_tween().tween_property(_flash, "color:a", 0.0, 0.25)


func go_arrow() -> void:
	_go.visible = true
	get_tree().create_timer(3.0).timeout.connect(func(): _go.visible = false)


# --- Katmanlar: duraklat / yenilgi / sonuç ----------------------------------

func _make_overlay(dim := 0.6) -> VBoxContainer:
	if _overlay:
		_overlay.queue_free()
	_overlay = Control.new()
	_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.06, dim)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(box)
	return box


func _button(box: Control, text: String, cb: Callable, primary := false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(420, 84)
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_font_size_override("font_size", 36)
	var bgc := Color(0.78, 0.2, 0.16) if primary else Color(0.16, 0.11, 0.2)
	b.add_theme_stylebox_override("normal", _box(bgc, GOLD, 4, 16))
	b.add_theme_stylebox_override("hover", _box(bgc.lightened(0.12), GOLD, 4, 16))
	b.add_theme_stylebox_override("pressed", _box(bgc.darkened(0.2), GOLD, 4, 16))
	b.add_theme_stylebox_override("focus", _box(Color(0, 0, 0, 0), Color.WHITE, 3, 16))
	b.pressed.connect(func():
		Sfx.play("swing", 1.4)
		cb.call())
	box.add_child(b)
	return b


func _title(box: Control, text: String, c: Color, size := 72) -> Label:
	var l := _label(size, c)
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l)
	return l


func open_pause() -> void:
	if get_tree().paused or level.finished or level.player.state == Player.S.DEAD:
		return
	get_tree().paused = true
	var box := _make_overlay()
	_title(box, "DURAKLATILDI", GOLD)
	var first := _button(box, "DEVAM", close_pause, true)
	_button(box, "BAŞTAN BAŞLA", func(): Game.start_level(Game.level_index))
	_button(box, "ANA MENÜ", func(): Game.goto("res://scenes/Menu.tscn"))
	first.grab_focus()


func close_pause() -> void:
	get_tree().paused = false
	if _overlay:
		_overlay.queue_free()
		_overlay = null


func _unhandled_input(e: InputEvent) -> void:
	if get_tree().paused and e.is_action_pressed("pause"):
		close_pause()
		get_viewport().set_input_as_handled()


func show_death() -> void:
	var box := _make_overlay(0.45)
	_title(box, "YERE SERİLDİN", Color(1, 0.35, 0.3), 80)
	var l := _label(32, Color.WHITE)
	l.text = "Kontrol noktasından devam ediliyor…"
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(l)


func show_results(stars: int) -> void:
	var box := _make_overlay(0.7)
	_title(box, "BÖLÜM TAMAM!", GOLD, 80)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var star_labels: Array[Label] = []
	for i in 3:
		var s := _label(110, Color(0.3, 0.26, 0.34))
		s.text = "★"
		s.pivot_offset = Vector2(40, 60)
		row.add_child(s)
		star_labels.append(s)
	# Arcade puan tablosu: satırlar sırayla gelir, toplam sayarak yükselir.
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 48)
	grid.add_theme_constant_override("v_separation", 4)
	box.add_child(grid)
	var rows: Array = level.score_rows()
	var row_labels: Array = []
	var total := 0
	for row in rows:
		var cells: Array[Label] = []
		for i in 3:
			var l := _label(30, Color.WHITE if i < 2 else GOLD)
			l.text = [row[0], row[1], "%+d" % int(row[2])][i]
			if i == 2 and int(row[2]) < 0:
				l.add_theme_color_override("font_color", Color(1, 0.4, 0.35))
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if i > 0 else HORIZONTAL_ALIGNMENT_LEFT
			l.modulate.a = 0.0
			grid.add_child(l)
			cells.append(l)
		row_labels.append(cells)
		total += int(row[2])
	total = maxi(0, total)
	var total_label := _label(44, GOLD)
	total_label.text = "TOPLAM  0"
	total_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(total_label)
	var first := _button(box, "TEKRAR OYNA", func(): Game.start_level(Game.level_index), true)
	_button(box, "ANA MENÜ", func(): Game.goto("res://scenes/Menu.tscn"))
	first.grab_focus()
	var tw := create_tween()
	var running := [0]
	for k in row_labels.size():
		tw.tween_interval(0.22)
		tw.tween_callback(func():
			for c in row_labels[k]:
				c.modulate.a = 1.0
			running[0] += int(rows[k][2])
			total_label.text = "TOPLAM  %d" % maxi(0, running[0])
			Sfx.play("coin", 0.7 + k * 0.08, -4.0))
	tw.tween_callback(func(): total_label.text = "TOPLAM  %d" % total)
	for i in stars:
		tw.tween_interval(0.35)
		tw.tween_callback(func():
			star_labels[i].add_theme_color_override("font_color", GOLD)
			star_labels[i].scale = Vector2(1.8, 1.8)
			star_labels[i].create_tween().tween_property(star_labels[i], "scale", Vector2.ONE, 0.2)
			Sfx.play("coin", 0.8 + i * 0.2, 6.0))
