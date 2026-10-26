## HUD — oyun arayüzü (Görev 4: can çubuğu + coin sayacı + silah göstergesi + ölüm).
##
## Ana plan md. 13'teki tam HUD (zırh, skor, bonus ikonları, boss barı) sonraki
## görevlerde. Coin sayacı GameState'i doğrudan dinler; can ve silah Main tarafından
## Redmount sinyallerine bağlanır.
extends Control

@onready var _fill: ColorRect = $HealthBg/HealthFill
@onready var _label: Label = $HealthBg/HealthLabel
@onready var _coins: Label = $CoinLabel
@onready var _weapon: Label = $WeaponLabel
@onready var _ammo: Label = $AmmoLabel
@onready var _armor: Label = $ArmorLabel
@onready var _powerups: Label = $PowerupLabel
@onready var _death: Label = $DeathLabel
@onready var _boss_bar: ColorRect = $BossBar
@onready var _boss_fill: ColorRect = $BossBar/BossFill
@onready var _boss_label: Label = $BossBar/BossLabel

var _boss_bar_width: float = 628.0
var _boss_ratio: float = 1.0
@onready var _results: ColorRect = $ResultsPanel
@onready var _results_stats: Label = $ResultsPanel/Stats
@onready var _results_title: Label = $ResultsPanel/Title
@onready var _results_hint: Label = $ResultsPanel/Hint
@onready var _results_rank: Label = $ResultsPanel/Rank
@onready var _stage: Label = $StageLabel
## Bölüm sonu istatistiğine eklenen satır (Main doldurur): "Gizli alan: 2 / 3".
var secrets_line := ""
## Bu koşudan önce kayıtta olan yıldız maskesi (Main doldurur); kartta soluk gösterilir.
var earned_stars := 0

const STAR_FULL := preload("res://assets/ui/pixel/yildiz_dolu.png")
const STAR_EMPTY := preload("res://assets/ui/pixel/yildiz_bos.png")
## Önceki koşuda kazanılmış, bu koşuda alınmamış yıldız: sönük okra (kalıcı olduğu okunsun).
const STAR_FAINT := preload("res://assets/ui/pixel/yildiz_soluk.png")
## Sonuç kartındaki yıldızlar: (bit, alt yazı) — soldan sağa açılış sırası.
const STARS := [[1, "HIZ"], [2, "HASARSIZ"], [4, "GİZLİ ALAN"]]
## Yıldız ölçeği (sanat pikseli -> ekran), açılış gecikmesi ve aralığı (sn).
const STAR_SCALE := 4.0
const STAR_DELAY := 0.45
const STAR_STEP := 0.32
@onready var _combo: Label = $ComboLabel

## Düşük can uyarısı: can oranı bunun altına inince ekran kenarı kızarır ve nabız gibi atar;
## KRİTİK altında nabız hızlanır. Mevcut can çubuğu renk eşiğiyle (0,3) aynı.
const DANGER_RATIO := 0.3
const DANGER_CRITICAL := 0.15
## Nabız periyodu (sn): normal / kritik. İkinci atış ilkinden DANGER_BEAT2 sn sonra.
const DANGER_PERIOD := 1.0
const DANGER_PERIOD_CRITICAL := 0.62
const DANGER_BEAT2 := 0.17
const DANGER_EDGE := preload("res://assets/ui/pixel/tehlike_kenar.png")
var _danger: TextureRect
var _hp_ratio := 1.0
var _danger_t := 0.0

var _bar_width: float = 256.0

var _coin_bump: float = 0.0
var _place: _PlaceBanner
var _combo_pulse: float = 0.0
## Üst bant öğesi → taban (offset_top, offset_bottom); telsiz açıkken üstüne `_top_inset` eklenir.
var _top_band := {}
var _top_inset := 0.0
var _neighborhood_panel: Panel
var _neighborhood_portrait: TextureRect
var _neighborhood_name: Label
var _arena_panel: PanelContainer
var _arena_label: Label
var _costume_badge: PanelContainer
var _costume_icon: TextureRect
var _costume_name: Label
var _costume_bonus: Label


func _ready() -> void:
	_style()
	_style_neighborhood()
	if TouchControls.active_on_device():
		_style_mobile()
	set_level_context(GameState.level_index)
	_death.visible = false
	_stage.visible = false  # bölüm / kitap numarası oyun içinde gösterilmez
	_results.visible = false
	_results_rank.visible = false
	_build_results_card()
	_build_star_row()
	_build_costume_badge()
	_build_arena_counter()
	_build_danger_edge()
	_boss_bar.visible = false
	_combo.visible = false
	for c in [_arena_panel, _combo, _boss_bar]:
		_top_band[c] = Vector2(c.offset_top, c.offset_bottom)
	GameState.coins_changed.connect(_on_coins_changed)
	Combat.combo_changed.connect(_on_combo_changed)
	Combat.combo_finished.connect(_on_combo_finished)


## Tüm HUD'a okunaklı, tutarlı görünüm — dünya dokusu üstünde net dursun.
func _style() -> void:
	var th := Theme.new()
	th.default_font_size = 16
	th.set_color(&"font_color", &"Label", Color(0.95, 0.96, 0.98))
	th.set_color(&"font_outline_color", &"Label", Color(0, 0, 0, 0.9))
	th.set_constant(&"outline_size", &"Label", 5)
	theme = th

	_stage.add_theme_font_size_override(&"font_size", 18)
	_coins.add_theme_color_override(&"font_color", Color(1.0, 0.82, 0.32))
	_coins.add_theme_font_size_override(&"font_size", 19)

	# Can çubuğu: koyu track + fill üstünde, ince alt-çerçeve hissi.
	($HealthBg as ColorRect).color = Color(0.05, 0.05, 0.08, 0.92)
	var track := ColorRect.new()
	track.name = "Track"
	track.color = Color(0, 0, 0, 0)  # piksel çerçeve HealthBg'den gelir
	track.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	track.offset_left = 4
	track.offset_top = 4
	track.offset_right = -4
	track.offset_bottom = -4
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fill.get_parent().add_child(track)
	_fill.get_parent().move_child(track, 0)

	_boss_label.add_theme_font_size_override(&"font_size", 15)
	_results_title.add_theme_font_size_override(&"font_size", 30)
	_results_stats.add_theme_font_size_override(&"font_size", 19)


func _style_neighborhood() -> void:
	var mobile := TouchControls.active_on_device()
	var panel := Panel.new()
	panel.position = Vector2(16, 16) if mobile else Vector2(20, 20)
	panel.size = Vector2(320, 112) if mobile else Vector2(378, 118)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := StyleBoxFlat.new()
	box.bg_color = Color("242339ed")
	box.border_color = Color("b88a60")
	box.set_border_width_all(2)
	box.shadow_color = Color(0, 0, 0, 0.3)
	box.shadow_size = 5
	panel.add_theme_stylebox_override("panel", box)
	add_child(panel)
	move_child(panel, 0)
	_neighborhood_panel = panel
	var portrait := TextureRect.new()
	portrait.texture = preload("res://assets/environment/mahalle/portrait.png")
	portrait.position = Vector2(22, 39) if mobile else Vector2(30, 34)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.size = Vector2(64, 80)
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)
	portrait.scale = Vector2(0.48, 0.48) if mobile else Vector2(0.42, 0.42)
	_neighborhood_portrait = portrait
	var name_label := Label.new()
	name_label.text = "REDMOUNT"
	name_label.position = Vector2(82, 27) if mobile else Vector2(108, 25)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color("ffd584"))
	add_child(name_label)
	_neighborhood_name = name_label
	$HealthBg.position = Vector2(82, 52) if mobile else Vector2(108, 49)
	_coins.position = Vector2(82, 86) if mobile else Vector2(108, 84)
	_coins.add_theme_font_size_override("font_size", 16)
	_weapon.position = Vector2(20, 130) if mobile else Vector2(108, 108)
	_weapon.add_theme_font_size_override("font_size", 14)
	_ammo.position.y = 158 if mobile else 143
	_armor.position.y = 186 if mobile else 165
	_powerups.position.y = 214 if mobile else 187
	_stage.add_theme_color_override("font_color", Color("ffd584"))


func _style_mobile() -> void:
	_bar_width = 218.0
	$HealthBg.size = Vector2(226, 30)
	_boss_bar.anchor_top = 0.0
	_boss_bar.anchor_bottom = 0.0
	_boss_bar.anchor_left = 0.0
	_boss_bar.anchor_right = 0.0
	_boss_bar.offset_top = 96.0
	_boss_bar.offset_bottom = 122.0
	resized.connect(_layout_mobile_boss_bar)
	_layout_mobile_boss_bar()


func set_level_context(index: int) -> void:
	var neighborhood := index == 0
	var mobile := TouchControls.active_on_device()
	_neighborhood_panel.visible = neighborhood
	_neighborhood_portrait.visible = neighborhood
	_neighborhood_name.visible = neighborhood
	if not neighborhood:
		$HealthBg.position = Vector2(16, 20 if mobile else 44)
		_coins.position = Vector2(16, 62 if mobile else 80)
		_weapon.position = Vector2(16, 90 if mobile else 104)
		_ammo.position = Vector2(16, 118 if mobile else 128)
		_armor.position = Vector2(16, 146 if mobile else 152)
		_powerups.position = Vector2(16, 174 if mobile else 176)
	else:
		$HealthBg.position = Vector2(82, 52) if mobile else Vector2(108, 49)
		_coins.position = Vector2(82, 86) if mobile else Vector2(108, 84)
		_weapon.position = Vector2(20, 130) if mobile else Vector2(108, 108)
		_ammo.position.y = 158 if mobile else 143
		_armor.position.y = 186 if mobile else 165
		_powerups.position.y = 214 if mobile else 187
	if mobile:
		_layout_mobile_boss_bar()
	_on_coins_changed(GameState.coins)


func _layout_mobile_boss_bar() -> void:
	var hud_edge := 340.0 if GameState.level_index == 0 else 260.0
	var width := minf(560.0, maxf(220.0, size.x - hud_edge - 16.0))
	_boss_bar.offset_right = size.x - 16.0
	_boss_bar.offset_left = _boss_bar.offset_right - width
	_boss_bar_width = width - 12.0
	_boss_label.offset_right = width - 8.0
	_boss_fill.size.x = _boss_bar_width * _boss_ratio


func _process(delta: float) -> void:
	_tick_reveal(delta)
	_tick_danger(delta)
	_follow_radio()
	if _coin_bump > 0.0:
		_coin_bump = maxf(_coin_bump - delta * 4.0, 0.0)
		_coins.scale = Vector2.ONE * (1.0 + _coin_bump * 0.5)
		_coins.pivot_offset = Vector2(20, 11)
	if _combo.visible and _combo_pulse > 0.0:
		_combo_pulse = maxf(_combo_pulse - delta * 5.0, 0.0)
		_combo.scale = Vector2.ONE * (1.0 + _combo_pulse * 0.6)
		_combo.pivot_offset = _combo.size * Vector2(1.0, 0.5)


## Telsiz konuşurken üst bant öğeleri panelin altına kayar (panel açılıp kapanırken birlikte);
## dalga sayacı, kombo, yer afişi ve boss çubuğu hiçbir zaman telsizin altında kalmaz.
func _follow_radio() -> void:
	var inset := roundf(RadioPanel.top_inset())
	if inset == _top_inset:
		return
	_top_inset = inset
	for c: Control in _top_band:
		var base: Vector2 = _top_band[c]
		c.offset_top = base.x + inset
		c.offset_bottom = base.y + inset


func _on_combo_changed(count: int) -> void:
	if count < 2:
		_combo.visible = false
		return
	_combo.visible = true
	var tier := "İYİ" if count < 5 else ("HARİKA" if count < 10 else "EFSANE")
	_combo.text = "%s  x%d" % [tier, count]
	_combo.modulate = (Color(1, 0.9, 0.4) if count < 5 else
		Color(1, 0.55, 0.3) if count < 10 else Color(0.75, 0.45, 1.0))
	_combo_pulse = 1.0


func _on_combo_finished(count: int, bonus: int) -> void:
	_combo.visible = false
	if bonus > 0:
		_flash_big_combo(count, bonus)


func _flash_big_combo(count: int, bonus: int) -> void:
	_combo.visible = true
	_combo.text = "COMBO x%d   +%d" % [count, bonus]
	_combo.modulate = Color(1, 0.85, 0.35)
	_combo_pulse = 1.4
	await get_tree().create_timer(1.1, false).timeout
	if _combo.text.begins_with("COMBO"):
		_combo.visible = false


func set_health(current: int, maximum: int) -> void:
	var ratio := 0.0 if maximum <= 0 else clampf(float(current) / float(maximum), 0.0, 1.0)
	if ratio <= DANGER_RATIO and _hp_ratio > DANGER_RATIO:
		_danger_t = 0.0  # tehlikeye girerken ilk atış hemen
	_hp_ratio = ratio
	_fill.size.x = _bar_width * ratio
	# Piksel dolgu (PixelUIBoot): asıl ColorRect saydam, renk piksel dolguya verilir.
	_fill.color = Color(0, 0, 0, 0)
	if _fill.get_child_count() > 0:
		(_fill.get_child(0) as CanvasItem).self_modulate = Color.WHITE if ratio > 0.3 else Color(1.0, 0.75, 0.3)
	_label.text = "CAN  %d / %d" % [current, maximum]


## Tam ekran piksel kenar (HUD öğelerinin arkasında, dokunuşu engellemez).
func _build_danger_edge() -> void:
	_danger = TextureRect.new()
	_danger.name = "DangerEdge"
	_danger.texture = DANGER_EDGE
	_danger.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_danger.stretch_mode = TextureRect.STRETCH_SCALE
	_danger.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_danger.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_danger.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_danger.modulate.a = 0.0
	add_child(_danger)
	move_child(_danger, 0)


## Kalp atışı gibi çift vuruş: atışta kenar parlar, sonra söner. Can 0'da (ölüm) ve
## tehlike dışında yavaşça kaybolur.
func _tick_danger(delta: float) -> void:
	if _danger == null:
		return
	var active := _hp_ratio > 0.0 and _hp_ratio <= DANGER_RATIO and not _results.visible \
		and not get_tree().paused
	if not active:
		_danger.modulate.a = move_toward(_danger.modulate.a, 0.0, delta * 2.5)
		return
	var period := DANGER_PERIOD_CRITICAL if _hp_ratio <= DANGER_CRITICAL else DANGER_PERIOD
	var prev := _danger_t
	_danger_t = fmod(_danger_t + delta, period)
	var p := _danger_t
	var beat := maxf(exp(-p * 9.0), exp(-maxf(p - DANGER_BEAT2, 0.0) * 11.0) * 0.7 if p >= DANGER_BEAT2 else 0.0)
	var base := 0.3 if _hp_ratio > DANGER_CRITICAL else 0.45
	_danger.modulate.a = base + (1.0 - base) * beat
	if _fill.get_child_count() > 0:
		(_fill.get_child(0) as CanvasItem).self_modulate = Color(1.0, 0.75, 0.3).lerp(Color(1.0, 0.35, 0.3), beat)
	if p < prev or (prev == 0.0 and p > 0.0 and p < delta * 1.5):
		Sfx.play(&"land", 0.55, -14.0)  # kalp atışı


func set_weapon(display_name: String, uses: int, max_uses: int) -> void:
	# Yumruk varsayılan, yazmaya gerek yok; silah kısa biçimde (dokunmatikle aynı).
	_weapon.text = "" if display_name.is_empty() else "%s  %d/%d" % [display_name, uses, max_uses]


## `label` boşsa "MERMİ". Tek atımlık fırlatılan silah (TAŞ) toplam adet gösterir.
func set_ammo(mag: int, reserve: int, has_gun: bool, label := "") -> void:
	if not has_gun:
		_ammo.text = ""
		return
	var unit := label if label != "" else "MERMİ"
	if unit != "MERMİ":
		_ammo.text = ("%s %d" if TouchControls.active_on_device() else "%s: %d") % [
			unit if TouchControls.active_on_device() else unit.capitalize(), mag + reserve]
		return
	_ammo.text = ("MERMİ %d/%d" if TouchControls.active_on_device() else "Mermi: %d | %d") % [mag, reserve]


func set_armor(display_name: String, hp: int, max_hp: int) -> void:
	_armor.text = ("ZIRH %d/%d" % [hp, max_hp] if TouchControls.active_on_device() else
		"Zırh: %s %d/%d · hasar -%%50 · hız -%%15" % [display_name, hp, max_hp]) if not display_name.is_empty() else ""


func set_powerups(active: Array) -> void:
	if active.is_empty():
		_powerups.text = ""
		return
	var parts: PackedStringArray = []
	for e in active:
		parts.append("%s %.1fs" % [e.name, maxf(e.left, 0.0)])
	_powerups.text = "  ".join(parts)


func set_boss_health(current: int, maximum: int) -> void:
	if current <= 0 or maximum <= 0:
		_boss_bar.visible = false
		return
	_boss_bar.visible = true
	_boss_ratio = clampf(float(current) / float(maximum), 0.0, 1.0)
	_boss_fill.size.x = _boss_bar_width * _boss_ratio


## Kilitli arena göstergesi: ekranın üst ortasında piksel çerçeveli dalga sayacı.
func _build_arena_counter() -> void:
	_arena_panel = PanelContainer.new()
	_arena_panel.add_theme_stylebox_override(&"panel", PixelUI.box("panel_hud", 20))
	_arena_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arena_panel.anchor_left = 0.5
	_arena_panel.anchor_right = 0.5
	_arena_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_arena_panel.offset_top = 12.0
	_arena_panel.visible = false
	_arena_label = Label.new()
	_arena_label.add_theme_font_size_override(&"font_size", 24)
	_arena_label.add_theme_color_override(&"font_color", Color(1.0, 0.72, 0.42))
	_arena_panel.add_child(_arena_label)
	add_child(_arena_panel)


## wave 0 → gösterge gizlenir (arena temizlendi / bölüm değişti).
func set_arena_wave(wave: int, total: int, remaining: int) -> void:
	if wave <= 0 or total <= 0:
		_arena_panel.visible = false
		return
	_arena_panel.visible = true
	# Dalga arası (kalan 0, sırada dalga var): "0 DÜŞMAN" arena bitti sanılırdı → sıradakini duyur.
	var between := remaining <= 0 and wave < total
	_arena_label.text = ("DALGA %d/%d GELİYOR!" % [wave + 1, total] if between
		else "DALGA %d/%d  ·  %d DÜŞMAN" % [wave, total, remaining])
	_arena_label.add_theme_color_override(&"font_color",
		Color(1.0, 0.9, 0.55) if between else Color(1.0, 0.72, 0.42))
	# Ortalanmış kalsın: piksel yazı teması uygulandıktan sonra metne göre ölç.
	_fit_arena_panel.call_deferred()


func _fit_arena_panel() -> void:
	var w := _arena_panel.get_combined_minimum_size().x
	_arena_panel.offset_left = -w * 0.5
	_arena_panel.offset_right = w * 0.5


func show_death() -> void:
	_death.visible = true


func hide_death() -> void:
	_death.visible = false


func set_stage(current: int, total: int, display_name: String) -> void:
	_stage.text = ("KİTAP 3 · BÖLÜM %d — %s" % [current - 24, display_name]
		if current > 24 else "KİTAP 2 · BÖLÜM %d — %s" % [current - 12, display_name]
		if current > 12 else "BÖLÜM %d/12 — %s" % [current, display_name])


## Mekâna varış pankartı: piksel tabela + hikâyedeki yerini anlatan tek cümle.
func show_place(title: String, story: String, accent: Color = Color("ffc857")) -> void:
	if _place == null:
		_place = _PlaceBanner.new()
		add_child(_place)
		_top_band[_place] = Vector2(_place.offset_top, _place.offset_bottom)
		_top_inset = -1.0  # yeni öğe de hemen yerini alsın
	_place.present(title, story, accent)


func show_stage_clear(current: int, stars: int = -1, seconds: float = 0.0,
		defeated: int = 0, enemy_total: int = 0, hits: int = 0,
		stage_score: int = 0) -> void:
	_results_title.text = ("KİTAP 3 · BÖLÜM %d TAMAMLANDI" % (current - 24)
		if current > 24 else "KİTAP 2 · BÖLÜM %d TAMAMLANDI" % (current - 12)
		if current > 12 else "BÖLÜM %d TAMAMLANDI" % current)
	_results_stats.text = "Süre: %d:%02d      Düşman: %d/%d      Hasar: %d\nCoin: %d\nBölüm skoru: %d      Toplam: %d" % [
		int(seconds) / 60, int(seconds) % 60, defeated, enemy_total, hits,
		GameState.coins, stage_score, GameState.score,
	]
	if secrets_line != "":
		_results_stats.text += "\n" + secrets_line
	_results_hint.text = "R — sonraki bölüm     ·     M — ana menü"
	for it in Shop.ITEMS:
		if int(it.get("unlock_level", 0)) == current and not Save.owns(it.id):
			_results_hint.text = "Yeni vuruş mağazada!  M — mağaza  ·  R — devam"
	_reveal(stars)


func show_results(coins: int, defeated: int, enemy_total: int, seconds: float, score: int,
		title: String = "OYUN TAMAMLANDI", stars: int = -1, hits: int = 0,
		stage_score: int = -1) -> void:
	_results_title.text = title
	if TouchControls.active_on_device():
		_results_stats.text = "Süre: %d:%02d   Düşman: %d/%d\nCoin: %d   Hasar: %d\nToplam skor: %d" % [
			int(seconds) / 60, int(seconds) % 60, defeated, enemy_total, coins, hits, score,
		]
	else:
		_results_stats.text = "Süre: %d:%02d\nCoin: %d\nDüşman: %d / %d\nHasar: %d\n\nSkor: %d" % [
			int(seconds) / 60, int(seconds) % 60, coins, defeated, enemy_total, hits, score,
		]
	if stage_score >= 0:
		_results_stats.text += "  ·  Bölüm: %d" % stage_score
	if secrets_line != "":
		_results_stats.text += "\n" + secrets_line
	_results_hint.text = ("R — sonraki bölüm     ·     M — ana menü"
		if GameState.has_next_level() else "R — baştan başla     ·     M — ana menü")
	_reveal(stars)


var _reveal_t: float = 0.0
## Bu koşunun yıldız maskesi; -1 = yıldız gösterme (ör. survival).
var _reveal_stars: int = -1
var _star_row: Control
var _star_icons: Array[TextureRect] = []
var _star_lit: Array[bool] = []


func _reveal(stars: int) -> void:
	_results.visible = true
	_results.modulate.a = 0.0
	_reveal_t = 0.0
	_reveal_stars = stars
	_combo.visible = false
	_results_rank.visible = false
	_refresh_costume_badge()
	_star_row.visible = stars >= 0
	for k in _star_icons.size():
		var before := (earned_stars & int(STARS[k][0])) != 0
		_star_icons[k].texture = STAR_FAINT if before else STAR_EMPTY
		_star_icons[k].scale = Vector2.ONE
		_star_lit[k] = false
	earned_stars = 0


func _tick_reveal(delta: float) -> void:
	if not _results.visible:
		return
	_reveal_t += delta
	_results.modulate.a = minf(_results.modulate.a + delta * 5.0, 1.0)
	if _reveal_stars < 0:
		return
	## Kazanılan yıldızlar sırayla "çakılır": büyükten yerine oturur + coin sesi.
	for k in _star_icons.size():
		if (_reveal_stars & int(STARS[k][0])) == 0:
			continue
		var t := _reveal_t - STAR_DELAY - STAR_STEP * k
		if t < 0.0:
			continue
		var icon := _star_icons[k]
		if not _star_lit[k]:
			_star_lit[k] = true
			icon.texture = STAR_FULL
			Sfx.play(&"coin")
		var e := clampf(t * 5.0, 0.0, 1.0)
		icon.scale = Vector2.ONE * lerpf(1.8, 1.0, ease(e, 0.4))
		if e >= 1.0:
			icon.scale = Vector2.ONE * (1.0 + sin((_reveal_t - k * 0.5) * 4.0) * 0.04)


## Sonuç kartının üstündeki üç yıldız yuvası + alt yazıları (piksel doku, NEAREST).
func _build_star_row() -> void:
	_star_row = Control.new()
	_star_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_star_row.set_anchors_preset(Control.PRESET_CENTER)
	_star_row.visible = false
	_results.add_child(_star_row)
	var art := STAR_FULL.get_size() * STAR_SCALE
	for k in STARS.size():
		var x := (k - 1) * 165.0
		## orta yıldız bir tık yukarıda: yay biçimli dizilim
		var y := -130.0 if k == 1 else -122.0
		var icon := TextureRect.new()
		icon.texture = STAR_EMPTY
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_SCALE
		icon.size = art
		icon.position = Vector2(x - art.x * 0.5, y)
		icon.pivot_offset = art * 0.5
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_star_row.add_child(icon)
		_star_icons.append(icon)
		_star_lit.append(false)
		var cap := Label.new()
		cap.text = String(STARS[k][1])
		cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cap.add_theme_font_override(&"font", PixelUI.font())
		cap.add_theme_font_size_override(&"font_size", PixelUI.snap(16))
		cap.add_theme_color_override(&"font_color", Color(0.86, 0.78, 0.62))
		cap.size = Vector2(164, 24)
		cap.position = Vector2(x - 82.0, -122.0 + art.y + 2.0)
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_star_row.add_child(cap)


## Bölüm sonu kartı: ekranın ortasında piksel panel, rütbe harfi madalya
## çerçevesinde, ipucu satırı düğme biçiminde. Etiketler sahnedeki yerlerinde kalır.
func _build_results_card() -> void:
	var card := Panel.new()
	card.set_meta(&"pixel_done", true)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override(&"panel", PixelUI.box("panel", 24))
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -330
	card.offset_right = 330
	card.offset_top = -230
	card.offset_bottom = 250
	_results.add_child(card)
	_results.move_child(card, 0)
	var medal := Panel.new()
	medal.set_meta(&"pixel_done", true)
	medal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	medal.add_theme_stylebox_override(&"panel", PixelUI.box("kart", 14))
	medal.set_anchors_preset(Control.PRESET_CENTER)
	medal.offset_left = -270
	medal.offset_right = 270
	medal.offset_top = -148
	medal.offset_bottom = -12
	_results.add_child(medal)
	_results.move_child(medal, 1)
	_results_title.add_theme_color_override(&"font_color", Color(1.0, 0.82, 0.45))
	_results_title.offset_left = -310
	_results_title.offset_right = 310
	_results_hint.add_theme_stylebox_override(&"normal", PixelUI.box("button_normal", 14))
	_results_hint.offset_left = -300
	_results_hint.offset_right = 300
	_results_hint.offset_top = 186
	_results_hint.offset_bottom = 232
	_results_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


## Kartın hemen altında "giyili" kostüm künyesi: başlık ikonu + ad + bonus. Koşunun
## hangi bonusla oynandığı sonuçla birlikte okunsun (duraklat menüsündeki rozetin
## tek satırlık eşi). Kart içi istatistik satırları değişken uzunlukta olduğundan
## rozet kartın dışında, alt kenara yaslı; bonussuz sokak ceketinde gizli.
func _build_costume_badge() -> void:
	var holder := CenterContainer.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.set_anchors_preset(Control.PRESET_CENTER)
	holder.offset_left = -330
	holder.offset_right = 330
	holder.offset_top = 258
	holder.offset_bottom = 318
	_results.add_child(holder)
	_costume_badge = PanelContainer.new()
	_costume_badge.name = "Costume"
	_costume_badge.set_meta(&"pixel_done", true)
	_costume_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_costume_badge.add_theme_stylebox_override(&"panel", PixelUI.box("panel_hud", 20))
	holder.add_child(_costume_badge)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override(&"separation", 14)
	_costume_badge.add_child(hb)
	_costume_icon = TextureRect.new()
	_costume_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_costume_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_costume_icon.custom_minimum_size = Vector2(72, 44)
	_costume_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(_costume_icon)
	_costume_name = Label.new()
	_costume_bonus = Label.new()
	for l: Label in [_costume_name, _costume_bonus]:
		l.add_theme_font_override(&"font", PixelUI.font())
		l.add_theme_font_size_override(&"font_size", PixelUI.snap(16))
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hb.add_child(l)
	_costume_name.add_theme_color_override(&"font_color", Color(0.86, 0.78, 0.62))
	_costume_bonus.add_theme_color_override(&"font_color", Color(1.0, 0.82, 0.45))
	_refresh_costume_badge()


func _refresh_costume_badge() -> void:
	var it := Shop.costume(Save.costume)
	var bonus := Shop.costume_bonus_text(it.id)
	_costume_badge.visible = bonus != ""
	_costume_name.text = "GİYİLİ: %s  ·" % String(it.name)
	_costume_bonus.text = bonus
	var acc := String(it.get("accessory", ""))
	_costume_icon.texture = load("res://assets/anim/costume_acc/%s.png" % acc) if acc != "" else null


func hide_results() -> void:
	_results.visible = false
	_results.modulate.a = 1.0
	_results_rank.visible = false


func _on_coins_changed(total: int) -> void:
	# Cephanelik ipucu yalnız oyuncu duraklatmayı bir kez açana kadar (Bölüm 1'de hiç).
	var hint := not TouchControls.active_on_device() and GameState.level_index != 0 and not Save.armory_seen
	_coins.text = ("COIN  %d  ·  ESC: CEPHANELİK" if hint else "COIN  %03d") % total
	_coin_bump = 1.0


## Üst ortada kısa süre görünen mekân pankartı (oyunu durdurmaz).
class _PlaceBanner extends Control:
	const HOLD := 5.5
	const PX := 3.0

	var _title := ""
	var _accent := Color("ffc857")
	var _story: Label
	var _t := 0.0

	func _init() -> void:
		set_anchors_preset(Control.PRESET_CENTER_TOP)
		offset_left = -400.0
		offset_right = 400.0
		offset_top = 96.0
		offset_bottom = 220.0
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		visible = false
		_story = Label.new()
		_story.set_anchors_preset(Control.PRESET_TOP_WIDE)
		_story.offset_top = 62.0
		_story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_story.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_story.add_theme_font_size_override(&"font_size", 20)
		_story.add_theme_color_override(&"font_color", Color(1.0, 0.95, 0.84))
		_story.add_theme_constant_override(&"outline_size", 7)
		add_child(_story)

	func present(title: String, story: String, accent: Color) -> void:
		_title = title
		_accent = accent
		_story.text = story
		_t = 0.0
		visible = true
		queue_redraw()

	func _process(delta: float) -> void:
		if not visible:
			return
		_t += delta
		modulate.a = clampf(minf(_t * 3.0, (HOLD - _t) * 2.0), 0.0, 1.0)
		if _t >= HOLD:
			visible = false

	func _draw() -> void:
		PixelText.sign_board(self, Vector2(size.x * 0.5, 26.0), _title, _accent, PX, false)
