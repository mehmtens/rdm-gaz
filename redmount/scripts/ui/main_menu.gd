## MainMenu — piksel art ana menü.
##
## Üç sayfa: ana sayfa (logo, görev satırı, dikey düğmeler, istatistik paneli,
## çatıda Redmount ile Gazelle), bölüm seçimi (Kitap 1/2/3 sekmeleri, 12'şer
## bölüm kartı: ad, en iyi skor, kilit) ve ayarlar (ses, kaydı sıfırla). Bütün
## parçalar piksel art (assets/ui/pixel, tools/gen_pixel_menu.py). Klavye ve
## gamepad ile gezilir; ESC / geri bir önceki sayfaya döner.
extends Control

const GAME_SCENE := "res://scenes/Main.tscn"
const SURVIVAL_SCENE := "res://scenes/Survival.tscn"
const SHOP_SCENE := "res://scenes/Shop.tscn"
const LOGO := preload("res://assets/ui/pixel/logo.png")
const LOGO_SUB := preload("res://assets/ui/pixel/logo_alt.png")
const LOCK := preload("res://assets/ui/pixel/kilit.png")
const COIN := preload("res://assets/ui/pixel/coin.png")
const STAR_FULL_S := preload("res://assets/ui/pixel/yildiz_dolu_kucuk.png")
const STAR_EMPTY_S := preload("res://assets/ui/pixel/yildiz_bos_kucuk.png")
const ROOF := preload("res://assets/environment/mahalle/roof_a.png")
const REDMOUNT_FRAMES := preload("res://resources/anim/redmount_frames.tres")
const GAZELLE_FRAMES := preload("res://resources/gazelle_frames.tres")
const GOLD := Color(1.0, 0.82, 0.45)
const CREAM := Color(0.96, 0.92, 0.84)
const MUTED := Color(0.72, 0.68, 0.74)
## Uyarı tonu (kopan seri).
const FIRE := Color(1.0, 0.5, 0.32)
const PER_BOOK := 12

var _t := 0.0
var _home: Control
var _levels: Control
var _settings: Control
var _archive: Control
var _arch_book := 0
var _arch_tabs: Array[Button] = []
var _arch_grid: GridContainer
var _book := 0
var _tabs: Array[Button] = []
var _grid: GridContainer
var _book_title: Label
var _first_button: Button
var _wipe_armed := false
var _wipe_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Music.play("menu")
	theme = UIStyle.menu_theme()
	for ch in get_children():
		ch.queue_free()
	_build_scenery()
	_home = _build_home()
	_levels = _build_levels()
	_settings = _build_settings()
	_archive = _build_archive()
	_show(_home)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	UIStyle.draw_city_bg(self, get_viewport_rect().size, _t)
	# Ön planda koyu bir çatı sırası: karakterler bunun üstünde durur.
	var vs := get_viewport_rect().size
	var y := vs.y - 118.0
	var x := vs.x * 0.56
	while x < vs.x + 40.0:
		draw_texture_rect(ROOF, Rect2(x, y, 220.0, 46.0), false, Color(0.55, 0.42, 0.42))
		x += 210.0
	draw_rect(Rect2(vs.x * 0.56, y + 40.0, vs.x * 0.44 + 40.0, 120.0), Color(0.08, 0.05, 0.08))
	# Alt şerit: kontrol ipucu.
	draw_rect(Rect2(0, vs.y - 34.0, vs.x, 34.0), Color(0.05, 0.03, 0.06, 0.85))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not _home.visible:
		_show(_home)
		get_viewport().set_input_as_handled()


# --- Sayfalar -------------------------------------------------------------------

func _show(page: Control) -> void:
	for p in [_home, _levels, _settings, _archive]:
		p.visible = p == page
	_wipe_armed = false
	if _wipe_button != null:
		_wipe_button.text = "KAYDI SIFIRLA"
	var focus: Control = _first_button
	if page == _levels:
		_select_book(_book)
		focus = _tabs[_book]
	elif page == _archive:
		_select_arch(_arch_book)
		focus = _arch_tabs[_arch_book]
	elif page == _settings:
		focus = page.find_child("Volume", true, false)
	if focus != null:
		focus.call_deferred(&"grab_focus")


func _build_scenery() -> void:
	# Çatıda Redmount ve Gazelle (oyunun karakter sanatı, nefes alan idle).
	var vs := get_viewport_rect().size
	var rm := AnimatedSprite2D.new()
	rm.sprite_frames = REDMOUNT_FRAMES
	rm.material = Shop.costume_material(Save.costume)
	rm.animation = &"idle"
	rm.scale = Vector2(0.9, 0.9)
	rm.position = Vector2(vs.x * 0.80, vs.y - 118.0)
	rm.offset = Vector2(0, -REDMOUNT_FRAMES.get_frame_texture(&"idle", 0).get_height() * 0.5)
	rm.flip_h = true
	rm.play()
	add_child(rm)
	CostumeAccessory.apply(rm, Save.costume)
	var gz := AnimatedSprite2D.new()
	gz.sprite_frames = GAZELLE_FRAMES
	var anims := GAZELLE_FRAMES.get_animation_names()
	gz.animation = &"freed" if anims.has("freed") else StringName(anims[0])
	gz.scale = Vector2(0.82, 0.82)
	gz.position = Vector2(vs.x * 0.70, vs.y - 118.0)
	gz.offset = Vector2(0, -GAZELLE_FRAMES.get_frame_texture(gz.animation, 0).get_height() * 0.5)
	gz.play()
	add_child(gz)

	var hint := Label.new()
	hint.text = ("Sol: hareket · Sağ: zıpla, vur, ağır, ateş · Büfeye dokun: etkileşim · II: duraklat"
		if TouchControls.active_on_device() else
		"A/D yürü · Shift koş · Boşluk zıpla · J vur · K ağır · L ateş · Ctrl atıl · ESC duraklat · gamepad destekli")
	hint.add_theme_color_override(&"font_color", MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -32
	hint.offset_bottom = -2
	add_child(hint)


func _build_home() -> Control:
	var page := Control.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(page)

	var logo := TextureRect.new()
	logo.texture = LOGO
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	logo.stretch_mode = TextureRect.STRETCH_SCALE
	logo.size = LOGO.get_size() * 5.0
	logo.position = Vector2(48, 34)
	page.add_child(logo)
	var sub := TextureRect.new()
	sub.texture = LOGO_SUB
	sub.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sub.stretch_mode = TextureRect.STRETCH_SCALE
	sub.size = LOGO_SUB.get_size() * 3.0
	sub.position = Vector2(62, 34 + LOGO.get_height() * 5.0 + 6.0)
	page.add_child(sub)

	var goal := Label.new()
	goal.text = _objective()
	goal.add_theme_color_override(&"font_color", Color(0.95, 0.55, 0.42))
	goal.position = Vector2(64, 230)
	page.add_child(goal)

	var col := VBoxContainer.new()
	col.position = Vector2(56, 270)
	col.custom_minimum_size = Vector2(430, 0)
	col.add_theme_constant_override(&"separation", 8)
	page.add_child(col)
	var finished := Save.best_score(GameState.level_count() - 1) > 0
	var cont := _button(col, "SON BÖLÜMÜ TEKRAR OYNA" if finished else "DEVAM ET", 52)
	cont.pressed.connect(func() -> void: _start(Save.unlocked_level))
	_first_button = cont
	if not finished:
		var where := Label.new()
		var u := clampi(Save.unlocked_level, 0, GameState.level_count() - 1)
		where.text = "Bölüm %d · %s" % [u + 1, GameState.LEVEL_NAMES[u]]
		where.add_theme_color_override(&"font_color", GOLD)
		where.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(where)
	_button(col, "BÖLÜM SEÇ").pressed.connect(func() -> void: _show(_levels))
	# Survival ve Günün Dalgası aynı arenayı kullanır; yan yana (sütun 720'ye sığsın).
	var modes := HBoxContainer.new()
	modes.add_theme_constant_override(&"separation", 8)
	col.add_child(modes)
	var surv := _button(modes, "SURVIVAL")
	surv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	surv.pressed.connect(func() -> void:
		GameState.daily_run = false
		Transition.go(SURVIVAL_SCENE))
	var today := DailyWave.today()
	var daily := _button(modes, "GÜNLÜK %d/%d" % [Save.daily_waves, DailyWave.WAVES]
		if Save.daily_attempted(today) else "GÜNÜN DALGASI")
	daily.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	daily.tooltip_text = DailyWave.plan(today).rule.name
	daily.pressed.connect(func() -> void:
		GameState.daily_run = true
		Transition.go(SURVIVAL_SCENE))
	_button(col, "MAĞAZA").pressed.connect(func() -> void: Transition.go(SHOP_SCENE))
	_button(col, "KANIT ARŞİVİ").pressed.connect(func() -> void: _show(_archive))
	_button(col, "AYARLAR").pressed.connect(func() -> void: _show(_settings))
	if not OS.has_feature("web"):
		_button(col, "ÇIKIŞ").pressed.connect(get_tree().quit)

	# İstatistik paneli: coin, ilerleme, survival rekoru.
	var stats := PanelContainer.new()
	stats.add_theme_stylebox_override(&"panel", PixelUI.box("panel_hud", 16))
	stats.position = Vector2(get_viewport_rect().size.x - 560, 24)
	page.add_child(stats)
	# Seri rozeti (istatistik panelinin altında; ana sütunu uzatmasın): canlı seri varsa
	# gün sayısı ve sıradaki seri ödülü — yarın geri dönme sebebi.
	# Seri yeni koptuysa aynı yerde uyarı: kaybı söyle, bugün yeniden başlamaya çağır.
	var alive := DailyWave.streak_alive(Save.daily_clear_day, today) and Save.daily_streak > 0
	var broken := DailyWave.streak_broken(Save.daily_clear_day, today, Save.daily_streak)
	if alive or broken:
		var badge := PanelContainer.new()
		badge.name = "StreakBadge"
		badge.add_theme_stylebox_override(&"panel", PixelUI.box("panel_hud", 16))
		badge.position = stats.position + Vector2(0, 62)
		page.add_child(badge)
		var badge_text := Label.new()
		if alive:
			var next := DailyWave.next_streak_reward(Save.daily_streak)
			badge_text.text = "SERİ %d GÜN · %d. günde +%d coin" % [Save.daily_streak, next[0], next[1]]
			badge_text.add_theme_color_override(&"font_color", GOLD)
		else:
			badge_text.text = "SERİ KOPTU (%d GÜN) · yeniden başla" % Save.daily_streak
			badge_text.add_theme_color_override(&"font_color", FIRE)
		badge.add_child(badge_text)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 18)
	stats.add_child(row)
	var ci := TextureRect.new()
	ci.texture = COIN
	ci.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ci.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	row.add_child(ci)
	row.add_child(_label("%d" % Save.total_coins, GOLD))
	row.add_child(_label("·", MUTED))
	row.add_child(_label("BÖLÜM %d/%d" % [mini(Save.unlocked_level + 1, GameState.level_count()), GameState.level_count()], CREAM))
	row.add_child(_label("·", MUTED))
	row.add_child(_label("SURVIVAL %d" % Save.survival_best_wave, CREAM))
	return page


func _build_levels() -> Control:
	var page := Control.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(page)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", PixelUI.box("panel", 24))
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 40
	panel.offset_right = -40
	panel.offset_top = 24
	panel.offset_bottom = -44
	page.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 12)
	panel.add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", 10)
	col.add_child(head)
	var title := _label("BÖLÜM SEÇ", GOLD)
	title.add_theme_font_size_override(&"font_size", 36)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	## Toplam yıldız: bütün kampanyada kazanılan / kazanılabilir.
	var star := TextureRect.new()
	star.texture = STAR_FULL_S
	star.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	star.custom_minimum_size = STAR_FULL_S.get_size() * 3.0
	head.add_child(star)
	var total := _label("%d/%d" % [Save.total_stars(), GameState.level_count() * Save.STARS_PER_LEVEL], CREAM)
	total.custom_minimum_size.x = 120
	head.add_child(total)
	for b in 3:
		var tab := Button.new()
		tab.text = "KİTAP %d" % (b + 1)
		tab.custom_minimum_size = Vector2(150, 48)
		tab.pressed.connect(_select_book.bind(b))
		tab.focus_entered.connect(_select_book.bind(b))
		head.add_child(tab)
		_tabs.append(tab)

	_book_title = _label("", Color(0.95, 0.55, 0.42))
	col.add_child(_book_title)

	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.add_theme_constant_override(&"h_separation", 14)
	_grid.add_theme_constant_override(&"v_separation", 14)
	_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_grid)

	var back := _button(col, "GERİ", 48)
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.custom_minimum_size = Vector2(200, 48)
	back.pressed.connect(func() -> void: _show(_home))
	return page


func _select_book(b: int) -> void:
	_book = b
	for i in _tabs.size():
		var sel := i == b
		for st in ["normal", "hover", "pressed"]:
			_tabs[i].add_theme_stylebox_override(st, PixelUI.box("sekme_secili" if sel else "sekme", 10))
		_tabs[i].add_theme_color_override(&"font_color", GOLD if sel else MUTED)
	_book_title.text = "KİTAP %d · %s" % [b + 1, GameState.BOOK_NAMES[b]]
	for ch in _grid.get_children():
		ch.queue_free()
	for k in PER_BOOK:
		_grid.add_child(_card(b * PER_BOOK + k))


## Bölüm kartı: üstte numara, ortada ad, altta en iyi süre + gizli alan ya da kilit;
## sağ üstte 3 yıldız (hız, hasarsız, gizli alan), üçü birden "%100".
func _card(i: int) -> Button:
	var locked := i > Save.unlocked_level
	var card := Button.new()
	card.custom_minimum_size = Vector2(278, 112)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.disabled = locked
	var kind := "kart_kilitli" if locked else "kart"
	for st in ["normal", "disabled"]:
		card.add_theme_stylebox_override(st, PixelUI.box(kind, 14))
	card.add_theme_stylebox_override(&"hover", PixelUI.box("kart", 14))
	card.add_theme_stylebox_override(&"pressed", PixelUI.box("kart", 14))
	card.pressed.connect(_start.bind(i))

	var v := VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 16
	v.offset_right = -12
	v.offset_top = 4
	v.offset_bottom = -8
	v.add_theme_constant_override(&"separation", 2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)
	var num := _label("BÖLÜM %d" % (i + 1), GOLD if not locked else MUTED)
	v.add_child(num)
	var name := _label(GameState.LEVEL_NAMES[i] if not locked else "? ? ?", CREAM if not locked else MUTED)
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(name)
	if locked:
		var lk := TextureRect.new()
		lk.texture = LOCK
		lk.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		lk.position = Vector2(232, 14)
		lk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(lk)
	else:
		var best := Save.best_score(i)
		var sec: Array = Save.secrets_of(i)
		var secs := Save.best_time(i)
		var line := ("%d:%02d" % [floori(secs / 60.0), int(secs) % 60] if secs > 0.0
			else "KOŞU REKORU %d" % best if best > 0 else "YENİ")
		var mask := Save.stars_of(i)
		for k in Save.STARS_PER_LEVEL:
			var st := TextureRect.new()
			st.texture = STAR_FULL_S if mask & (1 << k) else STAR_EMPTY_S
			st.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			st.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			st.size = STAR_FULL_S.get_size() * 3.0
			st.position = Vector2(170 + k * 32, 10)
			st.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(st)
		if Save.is_complete(i):
			var full := _label("%100", Color(1.0, 0.85, 0.3))
			full.position = Vector2(206, 52)
			full.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_child(full)
		if sec.size() == 2:
			line += " · GİZLİ %d/%d" % [int(sec[0]), int(sec[1])]
		v.add_child(_label(line, Color(0.95, 0.55, 0.42) if line == "YENİ" else MUTED))
	for ch in v.get_children():
		ch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return card


## Kanıt Arşivi: her bölümün gizli alanlarından toplanan film ruloları (3 fotoğraf).
func _build_archive() -> Control:
	var page := Control.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(page)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", PixelUI.box("panel", 24))
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 40
	panel.offset_right = -40
	panel.offset_top = 24
	panel.offset_bottom = -44
	page.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 10)
	panel.add_child(col)
	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", 10)
	col.add_child(head)
	var title := _label("KANIT ARŞİVİ", GOLD)
	title.add_theme_font_size_override(&"font_size", 36)
	head.add_child(title)
	var total := 0
	for i in GameState.level_count():
		var sec: Array = Save.secrets_of(i)
		if sec.size() == 2:
			total += int(sec[0])
	var count := _label("%d / %d" % [total, GameState.level_count() * 3], MUTED)
	count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(count)
	for b in 3:
		var tab := Button.new()
		tab.text = "KİTAP %d" % (b + 1)
		tab.custom_minimum_size = Vector2(150, 48)
		tab.pressed.connect(_select_arch.bind(b))
		tab.focus_entered.connect(_select_arch.bind(b))
		head.add_child(tab)
		_arch_tabs.append(tab)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_arch_grid = GridContainer.new()
	_arch_grid.columns = 2
	_arch_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_arch_grid.add_theme_constant_override(&"h_separation", 24)
	_arch_grid.add_theme_constant_override(&"v_separation", 10)
	scroll.add_child(_arch_grid)
	var back := _button(col, "GERİ", 46)
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.custom_minimum_size = Vector2(200, 46)
	back.pressed.connect(func() -> void: _show(_home))
	return page


func _select_arch(b: int) -> void:
	_arch_book = b
	for i in _arch_tabs.size():
		var sel := i == b
		for st in ["normal", "hover", "pressed"]:
			_arch_tabs[i].add_theme_stylebox_override(st, PixelUI.box("sekme_secili" if sel else "sekme", 10))
		_arch_tabs[i].add_theme_color_override(&"font_color", GOLD if sel else MUTED)
	for ch in _arch_grid.get_children():
		ch.queue_free()
	for k in PER_BOOK:
		var i := b * PER_BOOK + k
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override(&"separation", 2)
		var found := 0
		var sec: Array = Save.secrets_of(i)
		if sec.size() == 2:
			found = int(sec[0])
		var known := i <= Save.unlocked_level
		cell.add_child(_label("%d. %s" % [i + 1, GameState.LEVEL_NAMES[i] if known else "? ? ?"], CREAM if known else MUTED))
		var row := HBoxContainer.new()
		row.add_theme_constant_override(&"separation", 8)
		cell.add_child(row)
		for p in 3:
			var tr := TextureRect.new()
			tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.custom_minimum_size = Vector2(148, 100)
			tr.texture = load("res://assets/ui/photos/b%02d_%d.png" % [i + 1, p]) if p < found 				else load("res://assets/ui/photos/kilitli.png")
			row.add_child(tr)
		_arch_grid.add_child(cell)


func _build_settings() -> Control:
	var page := Control.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(page)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", PixelUI.box("panel", 30))
	panel.custom_minimum_size = Vector2(620, 0)
	panel.position = Vector2(56, 200)
	page.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 16)
	panel.add_child(col)
	var title := _label("AYARLAR", GOLD)
	title.add_theme_font_size_override(&"font_size", 36)
	col.add_child(title)

	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 16)
	col.add_child(row)
	row.add_child(_label("SES", CREAM))
	var vol := HSlider.new()
	vol.name = "Volume"
	vol.min_value = -40.0
	vol.max_value = 6.0
	vol.step = 1.0
	vol.value = Save.master_volume_db
	vol.custom_minimum_size = Vector2(380, 32)
	vol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vol.value_changed.connect(func(val: float) -> void: Save.set_volume_db(val))
	row.add_child(vol)

	_wipe_button = _button(col, "KAYDI SIFIRLA")
	_wipe_button.add_theme_color_override(&"font_color", Color(0.95, 0.55, 0.42))
	_wipe_button.pressed.connect(_on_wipe)
	_button(col, "GERİ").pressed.connect(func() -> void: _show(_home))
	return page


# --- Yardımcılar ------------------------------------------------------------------

func _button(parent: Control, text: String, h := 46) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, h)
	parent.add_child(b)
	return b


func _label(text: String, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override(&"font_color", color)
	return l


func _objective() -> String:
	var u := clampi(Save.unlocked_level, 0, GameState.level_count() - 1)
	if Save.best_score(GameState.level_count() - 1) > 0:
		return "ÜÇ KİTAP TAMAMLANDI · ŞEHİR UYANDI"
	var book := u / PER_BOOK
	return "KİTAP %d · %s" % [book + 1, GameState.BOOK_NAMES[book]]


func _start(index: int) -> void:
	GameState.level_index = clampi(index, 0, GameState.level_count() - 1)
	GameState.story_scenes = true
	Transition.go(GAME_SCENE)


## İki aşamalı: ilk basış uyarır, ikincisi siler.
func _on_wipe() -> void:
	if not _wipe_armed:
		_wipe_armed = true
		_wipe_button.text = "EMİN MİSİN? TEKRAR BAS"
		return
	Save.wipe()
	get_tree().reload_current_scene()
