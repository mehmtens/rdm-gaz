## MainMenu — ana menü (Görev 13).
##
## Devam et / bölüm seç / ses ayarı / çıkış. Bölüm seçim düğmeleri yalnızca
## `Save.unlocked_level`'e kadar açıktır. Seçim `GameState.level_index`'i ayarlar
## ve oyun sahnesine (Main.tscn) geçer.
extends Control

const GAME_SCENE := "res://scenes/Main.tscn"
const SURVIVAL_SCENE := "res://scenes/Survival.tscn"

@onready var _info: Label = $Root/Info
@onready var _continue: Button = $Root/Continue
@onready var _levels_box: HBoxContainer = $Root/LevelsScroll/Levels
@onready var _volume: HSlider = $Root/VolumeRow/Volume


var _t := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Music.play("menu")
	_style()
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_continue.pressed.connect(func() -> void: _start(Save.unlocked_level))
	$Root/SurvivalButton.pressed.connect(func() -> void: Transition.go(SURVIVAL_SCENE))
	$Root/ShopButton.pressed.connect(func() -> void:
		Transition.go("res://scenes/Shop.tscn"))
	$Root/Quit.pressed.connect(get_tree().quit)
	$Root/Wipe.pressed.connect(_on_wipe)

	for i in GameState.level_count():
		var b := Button.new()
		b.text = "K3-%d" % (i - 23) if i >= 24 else "K2-%d" % (i - 11) if i >= 12 else str(i + 1)
		b.custom_minimum_size = Vector2(56, 44)
		b.disabled = i > Save.unlocked_level
		b.pressed.connect(_start.bind(i))
		_levels_box.add_child(b)

	_volume.min_value = -40.0
	_volume.max_value = 6.0
	_volume.step = 1.0
	_volume.value = Save.master_volume_db
	_volume.value_changed.connect(func(v: float) -> void: Save.set_volume_db(v))

	_refresh()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	UIStyle.draw_city_bg(self, get_viewport_rect().size, _t)


func _style() -> void:
	if has_node(^"BG"):
		$BG.queue_free()

	var title: Label = $Root/Title
	title.add_theme_font_size_override(&"font_size", 68)
	title.add_theme_color_override(&"font_color", Color(0.98, 0.9, 0.82))
	title.add_theme_color_override(&"font_outline_color", Color(0.5, 0.1, 0.12))
	title.add_theme_constant_override(&"outline_size", 10)
	title.add_theme_color_override(&"font_shadow_color", Color(0, 0, 0, 0.5))
	title.add_theme_constant_override(&"shadow_offset_y", 4)

	var sub := Label.new()
	sub.text = ("ÜÇ KİTAP TAMAMLANDI · İSTANBUL'UN SESİ" if Save.best_score(35) > 0 else
		"SON YAYIN · GÖKSU MAVNASINA ULAŞ" if Save.unlocked_level >= 35 else
		"KİTAP 3 · BÖLÜM 11 TAMAMLANDI" if Save.best_score(34) > 0 else
		"HİSARDAKİ SON KUMANDAYI KES" if Save.unlocked_level >= 34 else
		"KİTAP 3 · BÖLÜM 10 TAMAMLANDI" if Save.best_score(33) > 0 else
		"KANDİLLİ VERİCİSİNİ DURDUR" if Save.unlocked_level >= 33 else
		"KİTAP 3 · BÖLÜM 9 TAMAMLANDI" if Save.best_score(32) > 0 else
		"VANİKÖY GECE SEVKİYATINI BUL" if Save.unlocked_level >= 32 else
		"KİTAP 3 · BÖLÜM 8 TAMAMLANDI" if Save.best_score(31) > 0 else
		"KULELİ GÖZETLEME HATTINI KES" if Save.unlocked_level >= 31 else
		"KİTAP 3 · BÖLÜM 7 TAMAMLANDI" if Save.best_score(30) > 0 else
		"ÇENGELKÖY SAHİL KONAĞINA GİR" if Save.unlocked_level >= 30 else
		"KİTAP 3 · BÖLÜM 6 TAMAMLANDI" if Save.best_score(29) > 0 else
		"BEYLERBEYİ İSKELE ARŞİVİNE GİR" if Save.unlocked_level >= 29 else
		"KİTAP 3 · BÖLÜM 5 TAMAMLANDI" if Save.best_score(28) > 0 else
		"KUZGUNCUK KIYI DEPOSUNU BUL" if Save.unlocked_level >= 28 else
		"KİTAP 3 · BÖLÜM 4 TAMAMLANDI" if Save.best_score(27) > 0 else
		"ÜSKÜDAR YEDEK HATTINI KES" if Save.unlocked_level >= 27 else
		"KİTAP 3 · BÖLÜM 3 TAMAMLANDI" if Save.best_score(26) > 0 else
		"GALATA TELGRAFINI DURDUR" if Save.unlocked_level >= 26 else
		"KİTAP 3 · BÖLÜM 2 TAMAMLANDI" if Save.best_score(25) > 0 else
		"SİRKECİ SEVKİYATINI İZLE" if Save.unlocked_level >= 25 else
		"KİTAP 3 · İLK BÖLÜM TAMAMLANDI" if Save.best_score(24) > 0 else
		"CAĞALOĞLU MATBAASINI BUL" if Save.unlocked_level >= 24 else
		"KİTAP 2 TAMAMLANDI" if Save.best_score(23) > 0 else
		"BOZDOĞAN KEMERİNE YETİŞ" if Save.unlocked_level >= 23 else
		"SARAÇHANE VANASINI DURDUR" if Save.unlocked_level >= 22 else
		"AKSARAY SU HATTINI KORU" if Save.unlocked_level >= 21 else
		"YENİKAPI GECE VARDİYASI" if Save.unlocked_level >= 20 else
		"SAMATYA SEVKİYATINI İZLE" if Save.unlocked_level >= 19 else
		"KÜLHANIN İZİNİ SÜR" if Save.unlocked_level >= 18 else
		"KAYIP KAYDI İZLE" if Save.unlocked_level >= 15 else
		"HALİÇ'TEKİ İZİ SÜR" if Save.unlocked_level >= 12 else "GAZELLE'İ KURTAR")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override(&"font_color", Color(0.95, 0.55, 0.4))
	sub.add_theme_constant_override(&"outline_size", 5)
	sub.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.8))
	$Root.add_child(sub)
	$Root.move_child(sub, 1)

	theme = UIStyle.menu_theme()

	var controls := Label.new()
	controls.text = ("Sol: hareket ve eğilme · Sağ: zıpla, vur, ağır, ateş · EYLEM: etkileşim · II: duraklat"
		if TouchControls.active_on_device() else
		"A / D · Shift koş · Boşluk zıpla · J saldır · K ağır · L ateş · Ctrl dash · S çömel · ESC duraklat        —  gamepad destekli")
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.add_theme_font_size_override(&"font_size", 13)
	controls.add_theme_color_override(&"font_color", Color(0.82, 0.82, 0.88, 0.6))
	controls.add_theme_constant_override(&"outline_size", 3)
	controls.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
	$Root.add_child(controls)


func _refresh() -> void:
	var best := ""
	for i in GameState.level_count():
		if Save.best_score(i) > 0:
			best += "  B%d:%d" % [i + 1, Save.best_score(i)]
	_info.text = "Toplam coin: %d      Açık bölüm: %d / %d      Survival rekoru: %d\nEn iyi skorlar:%s" % [
		Save.total_coins, Save.unlocked_level + 1, GameState.level_count(),
		Save.survival_best_wave,
		best if not best.is_empty() else "  —",
	]
	_continue.text = ("SON BÖLÜMÜ TEKRAR OYNA" if Save.best_score(GameState.level_count() - 1) > 0
		else "DEVAM ET  (Bölüm %d · %s)" % [
			Save.unlocked_level + 1, GameState.act_name(Save.unlocked_level),
		])


func _start(index: int) -> void:
	GameState.level_index = clampi(index, 0, GameState.level_count() - 1)
	GameState.story_scenes = true
	Transition.go(GAME_SCENE)


func _on_wipe() -> void:
	Save.wipe()
	for i in _levels_box.get_child_count():
		_levels_box.get_child(i).disabled = i > Save.unlocked_level
	_refresh()
