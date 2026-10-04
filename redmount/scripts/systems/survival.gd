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
	GameState.start_run()
	GameState.coin_multiplier = 2 if Save.owns("double_coin") else 1
	_hud.set_health(_player.get_health(), _player.get_max_health())
	_hud.set_boss_health(0, 0)
	_hud.get_node(^"DeathLabel").text = "SURVIVAL BİTTİ"
	Music.play_for_biome(0)
	_start_next_wave()


func _process(_delta: float) -> void:
	if not _touch.is_enabled():
		return
	_touch.set_mode("hidden" if _pause.is_open() else "dead" if _dead else "play")


func _draw() -> void:
	draw_rect(Rect2(-900, -720, 1800, 800), Color("111522"))
	draw_rect(Rect2(-900, -30, 1800, 110), Color("30283b"))
	for x in range(-800, 801, 160):
		draw_line(Vector2(x, -30), Vector2(x + 80, -110), Color(0.6, 0.25, 0.2, 0.3), 5.0)


func _build_arena() -> void:
	_static_box(Vector2(0, 40), Vector2(1640, 80))
	_static_box(Vector2(-840, -320), Vector2(40, 720))
	_static_box(Vector2(840, -320), Vector2(40, 720))


func _static_box(at: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = at
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)


func _start_next_wave() -> void:
	if _dead:
		return
	_between_waves = false
	_wave += 1
	_living = enemy_count_for_wave(_wave)
	_hud.set_boss_health(0, 0)
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
	var spots := [-650.0, -480.0, -310.0, -140.0, 140.0, 310.0, 480.0, 650.0]
	for i in _living:
		var enemy: EnemyBase = pool[(i + _wave) % pool.size()].instantiate()
		enemy.position = Vector2(spots[i], 0)
		enemy.defeated.connect(_on_enemy_defeated)
		add_child(enemy)
		if enemy.config.is_boss:
			enemy.boss_health_changed.connect(_hud.set_boss_health)
			_hud.get_node(^"BossBar/BossLabel").text = enemy.config.display_name
			_hud.set_boss_health(enemy.get_health(), enemy.config.max_health)


func _on_enemy_defeated(enemy: Node) -> void:
	_living -= 1
	if enemy.config != null:
		GameState.add_score(enemy.config.score_value)
	if _living > 0 or _dead:
		return
	_cleared_wave = _wave
	_between_waves = true
	var before := GameState.coins
	GameState.add_coins(reward_for_wave(_wave))
	Save.record_survival(_cleared_wave, 0)
	_player.heal(10)
	Fx.popup(Vector2(0, -130), "DALGA TEMİZ · +%d COIN · II: CEPHANELİK" % (GameState.coins - before), Color(0.45, 1.0, 0.6), 24)
	await get_tree().create_timer(4.0, false).timeout
	_start_next_wave()


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
	get_tree().paused = false
	Transition.go(MENU_SCENE)


func _bank_run() -> void:
	if _banked:
		return
	_banked = true
	Save.record_survival(_cleared_wave, GameState.coins)


func _on_armory_requested(item_id: String) -> void:
	if item_id == "fists":
		_player.select_fists()
		_pause.show_armory_status("Yakın dövüş: Yumruk", true)
		return
	if not _between_waves:
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
	if event.is_action_pressed(&"pause") and not _dead:
		_pause.toggle()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and _dead:
			_restart()
		elif event.keycode == KEY_M and _dead:
			_menu()
