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

const BOSS_BAR_WIDTH: float = 628.0
@onready var _results: ColorRect = $ResultsPanel
@onready var _results_stats: Label = $ResultsPanel/Stats
@onready var _results_title: Label = $ResultsPanel/Title
@onready var _results_hint: Label = $ResultsPanel/Hint
@onready var _results_rank: Label = $ResultsPanel/Rank
@onready var _stage: Label = $StageLabel

const RANK_COLOR := {
	"S": Color(1.0, 0.85, 0.3), "A": Color(0.8, 0.85, 0.95),
	"B": Color(0.85, 0.6, 0.4), "C": Color(0.6, 0.62, 0.68),
}
@onready var _combo: Label = $ComboLabel

const BAR_WIDTH: float = 256.0

var _coin_bump: float = 0.0
var _place: _PlaceBanner
var _combo_pulse: float = 0.0


func _ready() -> void:
	_style()
	if GameState.level_index == 0:
		_style_neighborhood()
	_death.visible = false
	_stage.visible = false  # bölüm / kitap numarası oyun içinde gösterilmez
	_results.visible = false
	_results_rank.visible = false
	_boss_bar.visible = false
	_combo.visible = false
	GameState.coins_changed.connect(_on_coins_changed)
	Combat.combo_changed.connect(_on_combo_changed)
	Combat.combo_finished.connect(_on_combo_finished)
	_on_coins_changed(GameState.coins)


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
	track.color = Color(0.17, 0.06, 0.07, 1.0)
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
	var panel := Panel.new()
	panel.position = Vector2(20, 20)
	panel.size = Vector2(378, 118)
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
	var portrait := TextureRect.new()
	portrait.texture = preload("res://assets/environment/mahalle/portrait.png")
	portrait.position = Vector2(30, 34)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.size = Vector2(64, 80)
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)
	portrait.scale = Vector2(0.42, 0.42)
	var name_label := Label.new()
	name_label.text = "REDMOUNT"
	name_label.position = Vector2(108, 25)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color("ffd584"))
	add_child(name_label)
	$HealthBg.position = Vector2(108, 49)
	_coins.position = Vector2(108, 84)
	_coins.add_theme_font_size_override("font_size", 16)
	_weapon.position = Vector2(108, 108)
	_weapon.add_theme_font_size_override("font_size", 14)
	_ammo.position.y = 143
	_armor.position.y = 165
	_powerups.position.y = 187
	_stage.add_theme_color_override("font_color", Color("ffd584"))


func _process(delta: float) -> void:
	_tick_reveal(delta)
	if _coin_bump > 0.0:
		_coin_bump = maxf(_coin_bump - delta * 4.0, 0.0)
		_coins.scale = Vector2.ONE * (1.0 + _coin_bump * 0.5)
		_coins.pivot_offset = Vector2(20, 11)
	if _combo.visible and _combo_pulse > 0.0:
		_combo_pulse = maxf(_combo_pulse - delta * 5.0, 0.0)
		_combo.scale = Vector2.ONE * (1.0 + _combo_pulse * 0.6)
		_combo.pivot_offset = _combo.size * Vector2(1.0, 0.5)


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
	_fill.size.x = BAR_WIDTH * ratio
	_fill.color = Color(0.83, 0.24, 0.24) if ratio > 0.3 else Color(0.95, 0.5, 0.15)
	_label.text = "CAN  %d / %d" % [current, maximum]


func set_weapon(display_name: String, uses: int, max_uses: int) -> void:
	if display_name.is_empty():
		_weapon.text = "Silah: Yumruk"
	else:
		_weapon.text = "Silah: %s  (%d/%d)" % [display_name, uses, max_uses]


func set_ammo(mag: int, reserve: int, has_gun: bool) -> void:
	_ammo.text = "Mermi: %d | %d" % [mag, reserve] if has_gun else ""


func set_armor(display_name: String, hp: int, max_hp: int) -> void:
	_armor.text = "Zırh: %s %d/%d · hasar -%%50 · hız -%%15" % [display_name, hp, max_hp] if not display_name.is_empty() else ""


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
	_boss_fill.size.x = BOSS_BAR_WIDTH * clampf(float(current) / float(maximum), 0.0, 1.0)


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
	_place.present(title, story, accent)


func show_stage_clear(current: int, rank: String = "", seconds: float = 0.0,
		defeated: int = 0, enemy_total: int = 0, hits: int = 0) -> void:
	_results_title.text = ("KİTAP 3 · BÖLÜM %d TAMAMLANDI" % (current - 24)
		if current > 24 else "KİTAP 2 · BÖLÜM %d TAMAMLANDI" % (current - 12)
		if current > 12 else "BÖLÜM %d TAMAMLANDI" % current)
	_results_stats.text = "Süre: %d:%02d      Düşman: %d/%d      Hasar: %d\nCoin: %d      Skor: %d" % [
		int(seconds) / 60, int(seconds) % 60, defeated, enemy_total, hits,
		GameState.coins, GameState.score,
	]
	_results_hint.text = "R — sonraki bölüm     ·     M — ana menü"
	if current <= 5 and not Save.owns(Shop.ITEMS[current - 1].id):
		_results_hint.text = "Yeni vuruş mağazada!  M — menü/mağaza     ·     R — sonraki bölüm"
	_reveal(rank)


func show_results(coins: int, defeated: int, enemy_total: int, seconds: float, score: int,
		title: String = "OYUN TAMAMLANDI", rank: String = "", hits: int = 0) -> void:
	_results_title.text = title
	_results_stats.text = "Süre: %d:%02d\nCoin: %d\nDüşman: %d / %d\nHasar: %d\n\nSkor: %d" % [
		int(seconds) / 60, int(seconds) % 60, coins, defeated, enemy_total, hits, score,
	]
	_results_hint.text = ("R — sonraki bölüm     ·     M — ana menü"
		if GameState.has_next_level() else "R — baştan başla     ·     M — ana menü")
	_reveal(rank)


var _reveal_t: float = 0.0
var _reveal_rank: String = ""


func _reveal(rank: String) -> void:
	_results.visible = true
	_results.modulate.a = 0.0
	_reveal_t = 0.0
	_reveal_rank = rank
	_combo.visible = false
	if rank.is_empty():
		_results_rank.visible = false
	else:
		_results_rank.visible = true
		_results_rank.text = rank
		_results_rank.modulate = RANK_COLOR.get(rank, Color.WHITE)
		_results_rank.pivot_offset = _results_rank.size * 0.5
		_results_rank.scale = Vector2(4.0, 4.0)


func _tick_reveal(delta: float) -> void:
	if not _results.visible:
		return
	_reveal_t += delta
	_results.modulate.a = minf(_results.modulate.a + delta * 5.0, 1.0)
	if _reveal_rank.is_empty():
		return
	if _reveal_t > 0.35:
		var k := clampf((_reveal_t - 0.35) * 3.5, 0.0, 1.0)
		_results_rank.scale = Vector2.ONE * lerpf(4.0, 1.0, ease(k, 0.32))
		# hafif "nefes" — yerine oturduktan sonra sürekli küçük pulse
		if k >= 1.0:
			_results_rank.scale = Vector2.ONE * (1.0 + sin(_reveal_t * 4.0) * 0.03)


func hide_results() -> void:
	_results.visible = false
	_results.modulate.a = 1.0
	_results_rank.visible = false


func _on_coins_changed(total: int) -> void:
	_coins.text = (("COIN  %03d" if GameState.level_index == 0 else "COIN  %d  ·  II: CEPHANELİK")
		if TouchControls.active_on_device() else
		("COIN  %03d" if GameState.level_index == 0 else "COIN  %d  ·  ESC: CEPHANELİK")) % total
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
