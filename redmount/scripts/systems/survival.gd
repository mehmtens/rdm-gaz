class_name SurvivalMode
extends Node2D

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const THUG := preload("res://scenes/enemies/StreetThug.tscn")
const KNIFE := preload("res://scenes/enemies/KnifeAgent.tscn")
const RIFLE := preload("res://scenes/enemies/RifleGuard.tscn")
const BRUISER := preload("res://scenes/enemies/ArmoredBruiser.tscn")
const ELITE := preload("res://scenes/enemies/EliteGuard.tscn")
const MINIBOSS := preload("res://scenes/enemies/MiniBoss.tscn")
const BAT := preload("res://resources/weapons/bat.tres")
const KNIFE_WEAPON := preload("res://resources/weapons/knife.tres")
const PISTOL := preload("res://resources/weapons/pistol.tres")
const RIFLE_WEAPON := preload("res://resources/weapons/rifle.tres")
const BODY_ARMOR := preload("res://resources/armor/body_armor.tres")
## Günün Dalgası planındaki düşman adları → sahne.
const DAILY_SCENES := {
	"thug": THUG, "knife": KNIFE, "rifle": RIFLE, "bruiser": BRUISER,
	"elite": ELITE, "miniboss": MINIBOSS,
}
const SPOTS: Array[float] = [-650.0, -480.0, -310.0, -140.0, 140.0, 310.0, 480.0, 650.0]

@onready var _player: CharacterBody2D = $Redmount
@onready var _hud = $UI/HUD
@onready var _pause: PauseMenu = $PauseMenu
@onready var _touch: TouchControls = $TouchControls

var _wave := 0
var _living := 0
var _dead := false
var _between_waves := false
var _cleared_wave := 0
var _banked := false
## Günün Dalgası (GameState.daily_run): plan, günün tarihi, puanlı mı (günün ilk
## denemesi) ve son dalga temizlenince bitti mi.
var _daily := false
var _plan: Dictionary = {}
var _day := ""
var _scored := false
var _finished := false
var _defeated := 0
var _started_ms := 0
## DtmLevel gökyüzü/arka sıra katmanlarının okuduğu alanlar (`level` = bu düğüm).
var sky_atlas: Texture2D = preload("res://assets/backgrounds/level06_backstreets_atlas.png")
var sky_cells: Array = [[0, -100000.0]]
var sky_grid := 2
var sky_tint := Color(0.86, 0.84, 0.92)
var sky_shade := Color(0.08, 0.07, 0.1)
var back_tint := Color(0.34, 0.36, 0.5)
var back_row_skip: Array = []
var camera_limit_right := 820


static func enemy_count_for_wave(wave: int) -> int:
	if wave > 0 and wave % 10 == 0:
		return 1
	return mini(2 + maxi(wave, 1), 8)


static func reward_for_wave(wave: int) -> int:
	return 3 + maxi(wave, 1) * 2


static func armory_cost(item_id: String) -> int:
	return int({"bat": 20, "knife": 25, "pistol": 40, "rifle": 60, "armor": 30}.get(item_id, -1))


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_arena()
	_player.set_camera_limits(-820, -720, 820, 180)
	_player.health_changed.connect(_hud.set_health)
	_player.weapon_changed.connect(_hud.set_weapon)
	_player.ammo_changed.connect(_hud.set_ammo)
	_player.powerups_changed.connect(_hud.set_powerups)
	_player.armor_changed.connect(_hud.set_armor)
	_player.died.connect(_on_death)
	_pause.checkpoint_requested.connect(_restart)
	_pause.restart_requested.connect(_restart)
	_pause.menu_requested.connect(_menu)
	_pause.armory_requested.connect(_on_armory_requested)
	_touch.pause_requested.connect(_pause.toggle)
	_touch.retry_requested.connect(_restart)
	_touch.menu_requested.connect(_menu)
	get_viewport().size_changed.connect(_apply_safe_area)
	_apply_safe_area()
	GameState.start_run()
	_hud.set_level_context(-1)
	GameState.coin_multiplier = 2 if Save.owns("double_coin") else 1
	_hud.set_health(_player.get_health(), _player.get_max_health())
	_hud.set_boss_health(0, 0)
	_hud.get_node(^"DeathLabel").text = "SURVIVAL BİTTİ"
	_started_ms = Time.get_ticks_msec()
	if GameState.daily_run:
		_setup_daily()
	Music.play_for_biome(0)
	_start_next_wave()


func _process(_delta: float) -> void:
	if not _touch.is_enabled():
		return
	_touch.set_mode("hidden" if _pause.is_open() else "dead" if _dead or _finished else "play")


## Günün kuralını uygular; günün ilk denemesiyse hakkı hemen kullanır (yarıda
## bırakmak yeniden denemeye çevrilemesin).
func _setup_daily() -> void:
	_daily = true
	_day = DailyWave.today()
	_plan = DailyWave.plan(_day)
	_scored = not Save.daily_attempted(_day)
	if _scored:
		Save.begin_daily(_day)
	var rule: Dictionary = _plan.rule
	match String(rule.weapon):
		"bat": _player.equip_weapon(BAT)
		"pistol": _player.equip_gun(PISTOL)
	if rule.armor:
		_player.equip_armor(BODY_ARMOR)
	_hud.get_node(^"DeathLabel").text = "GÜNÜN DALGASI BİTTİ"
	# Kural tabelası (mekân pankartı, 5,5 sn): oyuncu ilk dalga başlarken kuralı okur.
	_hud.show_place(rule.name, "Günün dalgası · %s" % rule.desc if _scored
		else "Antrenman · %s · ödül yarın" % rule.desc,
		Color(1.0, 0.78, 0.34) if _scored else Color(0.6, 0.75, 0.9))


func _apply_safe_area() -> void:
	var insets := TouchControls.safe_insets(get_viewport())
	var vertical := TouchControls.safe_vertical_insets(get_viewport())
	_hud.offset_left = insets.x
	_hud.offset_right = -insets.y
	_hud.offset_top = vertical.x
	_hud.offset_bottom = -vertical.y


func _notification(what: int) -> void:
	if what != NOTIFICATION_APPLICATION_PAUSED and what != NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		return
	TouchControls.release_gameplay_inputs()
	if is_node_ready() and not _dead and not get_tree().paused and not _pause.is_open():
		_pause.open()


func _build_arena() -> void:
	# Zemin bölümlerdeki gibi 520 px derin: kamera altı (y=180) taş dolguyla dolu kalır.
	var floor_body := _static_box(Vector2(0, 260), Vector2(1800, 520))
	floor_body.add_child(DtmLevel._Art.new(DtmLevel._Art.A_TERRAIN, Vector2(1800, 520)))
	_static_box(Vector2(-840, -320), Vector2(40, 720))
	_static_box(Vector2(840, -320), Vector2(40, 720))
	_dress_arena()


## Balat arka sokağı (piksel art): boyalı akşam gökyüzü + karartılmış arka sıra
## evler (DtmLevel katmanları, `level` olarak bu düğüm) + fenerler ve süsler.
## Günün dalgası pazar sokağında geçer: iki kip ilk bakışta ayırt edilsin.
func _dress_arena() -> void:
	if GameState.daily_run:
		sky_cells = [[1, -100000.0]]
	var sky := DtmLevel._Sky.new()
	sky.level = self
	add_child(sky)
	var row := DtmLevel._BackRow.new()
	row.level = self
	add_child(row)
	for x in [-620.0, 0.0, 620.0]:
		var lamp := DtmLevel._Lantern.new()
		lamp.position = Vector2(x, -170.0)
		add_child(lamp)
	_deco(DtmLevel.BUFE, -400.0, 0.62)
	_deco(DtmLevel.TREE_POT, -230.0, 1.0)
	_deco(DtmLevel.PLANT, 210.0, 0.9)
	_deco(DtmLevel.POTS, 300.0, 1.0)
	_deco(DtmLevel.TREE_POT, 470.0, 0.9)
	var night := CanvasModulate.new()
	night.color = Color(0.7, 0.7, 0.86).lerp(Color.WHITE, 0.4)
	add_child(night)


## Çarpışmasız süs: zemine (y=0) oturan, arka planda kalan piksel sprite.
func _deco(tex: Texture2D, cx: float, scale_f: float) -> void:
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2(scale_f, scale_f)
	s.position = Vector2(cx, -tex.get_height() * scale_f * 0.5)
	s.z_index = -6
	add_child(s)


func _static_box(at: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = at
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)
	return body


func _start_next_wave() -> void:
	if _dead:
		return
	_between_waves = false
	_wave += 1
	_hud.set_boss_health(0, 0)
	if _daily:
		_spawn_daily_wave()
		return
	_living = enemy_count_for_wave(_wave)
	_hud.get_node(^"StageLabel").text = "SURVIVAL · DALGA %d · REKOR %d" % [_wave, Save.survival_best_wave]
	var boss_wave := _wave % 10 == 0
	Fx.popup(Vector2(0, -170), "BOSS DALGASI" if boss_wave else "DALGA %d" % _wave,
		Color(1.0, 0.35, 0.2) if boss_wave else Color(1.0, 0.72, 0.25), 30)
	var pool: Array[PackedScene] = []
	pool.append(MINIBOSS if boss_wave else THUG)
	if not boss_wave and _wave >= 2: pool.append(KNIFE)
	if not boss_wave and _wave >= 3: pool.append(RIFLE)
	if not boss_wave and _wave >= 5: pool.append(BRUISER)
	if not boss_wave and _wave >= 7: pool.append(ELITE)
	for i in _living:
		_spawn(pool[(i + _wave) % pool.size()], SPOTS[i])


## Günün planındaki dalga: düşmanlar iki kenardan dönüşümlü doğar (oyuncu ortada).
func _spawn_daily_wave() -> void:
	var list: Array = _plan.waves[_wave - 1]
	_living = list.size()
	var boss_wave := _wave == DailyWave.WAVES
	_hud.get_node(^"StageLabel").text = "GÜNÜN DALGASI · %s%s" % [
		_plan.rule.name, "" if _scored else " · ANTRENMAN"]
	_hud.set_arena_wave(_wave, DailyWave.WAVES, _living)
	Fx.popup(Vector2(0, -170), "SON DALGA · BOSS" if boss_wave else "DALGA %d/%d" % [_wave, DailyWave.WAVES],
		Color(1.0, 0.35, 0.2) if boss_wave else Color(1.0, 0.72, 0.25), 30)
	var order := [0, 7, 1, 6, 2, 5, 3, 4]
	for i in _living:
		_spawn(DAILY_SCENES[String(list[i])], SPOTS[order[i]])


func _spawn(scene: PackedScene, x: float) -> void:
	var enemy: EnemyBase = scene.instantiate()
	enemy.position = Vector2(x, 0)
	enemy.defeated.connect(_on_enemy_defeated)
	add_child(enemy)
	if enemy.config.is_boss:
		enemy.boss_health_changed.connect(_hud.set_boss_health)
		_hud.get_node(^"BossBar/BossLabel").text = enemy.config.display_name
		_hud.set_boss_health(enemy.get_health(), enemy.config.max_health)


func _on_enemy_defeated(enemy: Node) -> void:
	_living -= 1
	_defeated += 1
	if enemy.config != null:
		GameState.add_score(enemy.config.score_value)
	if _daily and not _dead:
		_hud.set_arena_wave(_wave, DailyWave.WAVES, _living)
	if _living > 0 or _dead:
		return
	_cleared_wave = _wave
	_between_waves = true
	var before := GameState.coins
	GameState.add_coins(reward_for_wave(_wave))
	if _daily:
		if _scored:
			Save.record_daily_wave(_cleared_wave)
		if _wave >= DailyWave.WAVES:
			_finish_daily()
			return
	else:
		Save.record_survival(_cleared_wave, 0)
	var heal := int(_plan.rule.heal) if _daily else 10
	if heal > 0:
		_player.heal(heal)
	var shop := "" if _daily and not _plan.rule.armory else " · II: CEPHANELİK"
	Fx.popup(Vector2(0, -130), "DALGA TEMİZ · +%d COIN%s" % [GameState.coins - before, shop], Color(0.45, 1.0, 0.6), 24)
	await get_tree().create_timer(4.0, false).timeout
	_start_next_wave()


## Son dalga temiz: puanlı denemede tamamlama ödülü + seri, sonuç kartı.
func _finish_daily() -> void:
	_finished = true
	_hud.set_arena_wave(0, 0, 0)
	_hud.set_boss_health(0, 0)
	if _hud._place != null:
		_hud._place.visible = false
	var bonus := DailyWave.CLEAR_BONUS if _scored else 0
	_bank_run()
	var seconds := (Time.get_ticks_msec() - _started_ms) / 1000.0
	_hud.secrets_line = ""
	_hud.show_results(GameState.coins + bonus, _defeated, _defeated, seconds, GameState.score,
		"GÜNÜN DALGASI TAMAM")
	# Madalya çerçevesinde rütbe harfi yerine dalga sayısı; istatistikler kısa tutulur
	# (kart 4 satırdan fazlasını ipucu düğmesinin altına taşırıyor).
	_hud._results_rank.text = "%d/%d" % [_cleared_wave, DailyWave.WAVES]
	_hud._results_rank.visible = true
	_hud._results_stats.text = "%s  ·  Süre: %d:%02d  ·  Düşman: %d\n" % [
		_plan.rule.name, int(seconds) / 60, int(seconds) % 60, _defeated]
	if _scored:
		_hud._results_stats.text += "Coin: %d + %d tamamlama\nSeri: %d gün  ·  Skor: %d" % [
			GameState.coins, bonus, Save.daily_streak, GameState.score]
	else:
		_hud._results_stats.text += "Antrenman: coin yazılmadı\nYarın yeni dalga  ·  Skor: %d" % GameState.score
	_hud._results_hint.text = "R — antrenman     ·     M — ana menü"
	Sfx.play(&"powerup")


func _on_death() -> void:
	_dead = true
	_bank_run()
	_hud.show_death()


func _restart() -> void:
	_bank_run()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _menu() -> void:
	_bank_run()
	GameState.daily_run = false
	get_tree().paused = false
	Transition.go(MENU_SCENE)


func _bank_run() -> void:
	if _banked:
		return
	_banked = true
	if not _daily:
		Save.record_survival(_cleared_wave, GameState.coins)
	elif _scored:
		var cleared := _cleared_wave >= DailyWave.WAVES
		Save.finish_daily(_day, GameState.coins + (DailyWave.CLEAR_BONUS if cleared else 0), cleared)


func _on_armory_requested(item_id: String) -> void:
	if item_id == "fists":
		_player.select_fists()
		_pause.show_armory_status("Yakın dövüş: Yumruk", true)
		return
	if _daily and not _plan.rule.armory:
		_pause.show_armory_status("Bugünün kuralı: cephanelik kapalı.")
		return
	if not _between_waves or _finished:
		_pause.show_armory_status("Cephanelik yalnız dalga aralarında açık.")
		return
	var cost := armory_cost(item_id)
	if cost < 0 or not GameState.spend_coins(cost):
		_pause.show_armory_status("Yeterli Survival coini yok.")
		return
	match item_id:
		"bat": _player.equip_weapon(BAT)
		"knife": _player.equip_weapon(KNIFE_WEAPON)
		"pistol": _player.equip_gun(PISTOL)
		"rifle": _player.equip_gun(RIFLE_WEAPON)
		"armor": _player.equip_armor(BODY_ARMOR)
	_pause.show_armory_status("Kuşanıldı: %s" % item_id.capitalize(), true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and not _dead and not _finished:
		_pause.toggle()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and (_dead or _finished):
			_restart()
		elif event.keycode == KEY_M and (_dead or _finished):
			_menu()
