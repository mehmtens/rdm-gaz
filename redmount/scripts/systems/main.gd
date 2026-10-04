## Main — oyun kökü (Görev 11).
##
## Redmount + HUD kalıcıdır; bölüm sahnesi `LevelHolder` altına dinamik yüklenir
## (GameState.LEVELS sırası). Kontrol noktası son spawn'ı belirler. Bölüm bitiş
## noktasına ulaşınca oyun duraklar; `R` sonraki bölüme geçer (son bölümdeyse
## sonuç ekranı + koşuyu baştan başlatır). Aksi hâlde `R` = son kontrol noktası.
extends Node2D

@onready var _player: CharacterBody2D = $Redmount
@onready var _debug_label: Label = $UI/DebugLabel
@onready var _hud := $UI/HUD
@onready var _holder: Node2D = $LevelHolder
@onready var _dialogue := $DialogueBox
@onready var _pause_menu: PauseMenu = $PauseMenu
@onready var _touch: TouchControls = $TouchControls

var _story_card: StoryCard
## Hikâye kartı en son hangi bölüm için gösterildi (yeniden denemede tekrarlanmaz).
var _story_shown_for := -1

var _level: Node = null
var _spawn: Marker2D
var _respawn_pos: Vector2
var _fall_y: float = 900.0

var _enemy_total: int = 0
var _enemy_defeated: int = 0
var _elapsed: float = 0.0
var _finished: bool = false
var _ending_in_progress := false
var _coins_at_level_start: int = 0

# --- Rank (Görev 20) ---
var _hits_taken: int = 0
var _last_health: int = 0
var _coins_available: int = 0
var _coin_pickups_at_start: int = 0
var _par_time: float = 75.0

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const BAT := preload("res://resources/weapons/bat.tres")
const KNIFE := preload("res://resources/weapons/knife.tres")
const PISTOL := preload("res://resources/weapons/pistol.tres")
const RIFLE := preload("res://resources/weapons/rifle.tres")
const BODY_ARMOR := preload("res://resources/armor/body_armor.tres")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player.process_mode = Node.PROCESS_MODE_PAUSABLE
	_hud.process_mode = Node.PROCESS_MODE_ALWAYS

	_player.health_changed.connect(_hud.set_health)
	_player.health_changed.connect(_on_health_changed)
	_player.weapon_changed.connect(_hud.set_weapon)
	_player.ammo_changed.connect(_hud.set_ammo)
	_player.powerups_changed.connect(_hud.set_powerups)
	_player.armor_changed.connect(_hud.set_armor)
	_player.died.connect(_hud.show_death)

	_pause_menu.checkpoint_requested.connect(_respawn_player)
	_pause_menu.restart_requested.connect(func() -> void:
		get_tree().paused = false
		_load_current_level())
	_pause_menu.menu_requested.connect(func() -> void:
		get_tree().paused = false
		Transition.go(MENU_SCENE))
	_pause_menu.armory_requested.connect(_on_armory_requested)
	_touch.pause_requested.connect(_on_touch_pause)
	_touch.retry_requested.connect(_respawn_player)
	_touch.next_requested.connect(_advance_after_clear)
	_touch.menu_requested.connect(_go_to_menu)
	_story_card = StoryCard.new()
	add_child(_story_card)
	get_viewport().size_changed.connect(_apply_safe_area)
	_apply_safe_area()
	if _touch.is_enabled():
		_hud.get_node(^"ResultsPanel/Hint").visible = false
		_hud.get_node(^"DeathLabel").text = "ÖLDÜN"

	GameState.start_run()  # bölüm indeksini menü belirler
	GameState.coin_multiplier = 2 if Save.owns("double_coin") else 1
	_debug_label.visible = OS.get_environment("REDMOUNT_DEBUG_HUD") == "1"
	_load_current_level()


func _process(_delta: float) -> void:
	if not _touch.is_enabled():
		return
	_touch.set_context(_player.has_gun(), _player.can_throw_nearby())
	if _pause_menu.is_open() or _story_card.is_active() or LevelShop.is_any_open():
		_touch.set_mode("hidden")
	elif _dialogue.is_active():
		_touch.set_mode("dialogue")
	elif _ending_in_progress:
		_touch.set_mode("hidden")
	elif _finished:
		_touch.set_mode("results" if _hud.get_node(^"ResultsPanel").visible else "hidden",
			GameState.has_next_level())
	elif _player.get_health() <= 0:
		_touch.set_mode("dead")
	else:
		_touch.set_mode("play")


func _on_touch_pause() -> void:
	if not _finished and not _ending_in_progress and not _dialogue.is_active() \
			and not _story_card.is_active() and not LevelShop.is_any_open():
		_pause_menu.toggle()


## Çentik / yuvarlak köşe payı: HUD'u ekranın güvenli alanına çeker.
func _apply_safe_area() -> void:
	var insets := TouchControls.safe_insets(get_viewport())
	_hud.offset_left = insets.x
	_hud.offset_right = -insets.y


func _go_to_menu() -> void:
	get_tree().paused = false
	Transition.go(MENU_SCENE)


func _advance_after_clear() -> void:
	if not _finished or _ending_in_progress:
		return
	get_tree().paused = false
	if GameState.has_next_level():
		GameState.advance_level()
	else:
		GameState.reset_run()
	_load_current_level()


func _load_current_level() -> void:
	get_tree().paused = false

	if _level != null and is_instance_valid(_level):
		_level.queue_free()
	_level = load(GameState.level_path()).instantiate()
	_holder.add_child(_level)
	_level.process_mode = Node.PROCESS_MODE_PAUSABLE

	# Yalnızca yeni bölümün alt ağacını tara (eski bölüm bu kare sonunda silinir).
	_enemy_total = 0
	_enemy_defeated = 0
	var has_boss := false
	for enemy in _in_group(_level, &"enemy_ai"):
		_enemy_total += 1
		enemy.defeated.connect(_on_enemy_defeated)
		if enemy.config != null and enemy.config.is_boss:
			has_boss = true
			enemy.boss_health_changed.connect(_hud.set_boss_health)
			_hud.get_node(^"BossBar/BossLabel").text = enemy.config.display_name
			_hud.set_boss_health(enemy.get_health(), enemy.config.max_health)
	if not has_boss:
		_hud.set_boss_health(0, 0)

	_coins_available = _in_group(_level, &"coin").size()

	for cp in _in_group(_level, &"checkpoint"):
		cp.activated.connect(_on_checkpoint)
	for hz in _in_group(_level, &"hazard"):
		hz.touched.connect(_on_hazard)
	for dt in _in_group(_level, &"dialogue_trigger"):
		dt.triggered.connect(_on_dialogue)
	for sp in _in_group(_level, &"story_place"):
		sp.entered.connect(_hud.show_place)
	for ar in _in_group(_level, &"battle_arena"):
		ar.enemy_spawned.connect(_register_arena_enemy)
	var goals := _in_group(_level, &"level_goal")
	if not goals.is_empty():
		goals[0].reached.connect(_on_goal_reached)

	_spawn = _level.get_node(^"PlayerSpawn")
	_respawn_pos = _spawn.global_position

	if _level is Level:
		var lv: Level = _level
		_fall_y = lv.fall_respawn_y
		_par_time = lv.par_time
		_player.set_camera_limits(lv.camera_limit_left, lv.camera_limit_top,
			lv.camera_limit_right, lv.camera_limit_bottom)
		_apply_biome_grade(lv.biome)
		if has_boss and goals.is_empty():
			Music.play("boss")   # LevelGoal'suz story-boss bölümü (Kale finali)
		else:
			Music.play_for_biome(lv.biome)

	_coins_at_level_start = GameState.coins
	_coin_pickups_at_start = GameState.coin_pickups
	_hits_taken = 0
	_last_health = _player.get_max_health()
	_elapsed = 0.0
	_finished = false
	_ending_in_progress = false
	_hud.hide_results()
	_respawn_player()
	_play_story_intro()


## Bölüm başı hikâye kartı — kapanana kadar dünya durur.
func _play_story_intro() -> void:
	var index := GameState.level_index
	if not GameState.story_scenes or _story_shown_for == index or not StoryData.has(index):
		return
	_story_shown_for = index
	var title: String = (_level as Level).display_name if _level is Level else ""
	_story_card.present(StoryData.header(index), title, StoryData.brief(index), StoryData.goal(index))
	# Kamera ve arka plan yerine otursun diye duraklatmadan önce iki kare bekle.
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_inside_tree() or not _story_card.is_active():
		return
	get_tree().paused = true
	await _story_card.finished
	if not is_inside_tree() or GameState.level_index != index:
		return
	_elapsed = 0.0
	if not _dialogue.is_active() and not _pause_menu.is_open():
		get_tree().paused = false


func _on_health_changed(current: int, _maximum: int) -> void:
	if current < _last_health and not _finished:
		_hits_taken += 1
	_last_health = current


## Rank: S/A/B/C — süre + hasarsızlık + düşman + coin toplama.
func _compute_rank() -> String:
	var s := 40.0
	if _hits_taken == 0: s += 26.0
	elif _hits_taken <= 2: s += 16.0
	elif _hits_taken <= 5: s += 6.0
	if _enemy_total > 0:
		s += 18.0 * (float(_enemy_defeated) / float(_enemy_total))
	else:
		s += 18.0
	var got := GameState.coin_pickups - _coin_pickups_at_start
	if _coins_available > 0:
		s += 14.0 * clampf(float(got) / float(_coins_available), 0.0, 1.0)
	else:
		s += 7.0
	if _elapsed <= _par_time:
		s += 12.0
	elif _elapsed <= _par_time * 1.4:
		s += 6.0
	if s >= 92.0: return "S"
	if s >= 76.0: return "A"
	if s >= 58.0: return "B"
	return "C"


func _physics_process(delta: float) -> void:
	if _finished or _ending_in_progress:
		return

	_elapsed += delta
	if _level.has_node(^"Karahanli"):
		_hud.get_node(^"BossBar").visible = _player.global_position.x >= 237000.0
	if _player.global_position.y > _fall_y:
		_respawn_player()

	_debug_label.text = "J: saldırı  K: ağır  L: ateş  Ctrl: dash  ESC: duraklat  R: %s\n" % (
			"sonraki bölüm" if _finished else "kontrol noktası"
		) + "Bölüm %d/%d   Durum: %s   Can: %d/%d   Düşman: %d/%d   Süre: %.1f" % [
			GameState.level_index + 1, GameState.level_count(),
			_player.get_state_name(), _player.get_health(), _player.get_max_health(),
			_enemy_defeated, _enemy_total, _elapsed,
		]


func _unhandled_input(event: InputEvent) -> void:
	if _ending_in_progress:
		return
	if event.is_action_pressed(&"pause") and not _finished and not _dialogue.is_active() \
			and not _story_card.is_active() and not LevelShop.is_any_open():
		_pause_menu.toggle()
		get_viewport().set_input_as_handled()
		return
	if _pause_menu.is_open():
		return

	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if event.keycode == KEY_M and _finished:
		_go_to_menu()
		return

	if event.keycode != KEY_R:
		return
	if _finished:
		_advance_after_clear()
	else:
		_respawn_player()


func _on_enemy_defeated(enemy: Node) -> void:
	_enemy_defeated += 1
	if enemy.config != null:
		GameState.add_score(enemy.config.score_value)
		if enemy.config.is_story_boss and not _finished:
			_trigger_ending()


## Kilitli arena bir düşman spawn edince (Görev 18) — sayaç + skora bağla.
func _register_arena_enemy(enemy: Node) -> void:
	_enemy_total += 1
	enemy.defeated.connect(_on_enemy_defeated)
	if enemy.config != null and enemy.config.is_boss:
		enemy.boss_health_changed.connect(_hud.set_boss_health)
		_hud.get_node(^"BossBar/BossLabel").text = enemy.config.display_name
		_hud.set_boss_health(enemy.get_health(), enemy.config.max_health)


## Karahanlı yenildi -> Gazelle kurtarılır, kısa an sonra oyun-sonu ekranı.
func _trigger_ending() -> void:
	_finished = true
	_player.velocity = Vector2.ZERO
	_player.set_physics_process(false)
	Sfx.play(&"goal")
	Music.play("victory", 0.5)
	var g := _in_group(_level, &"gazelle")
	if not g.is_empty():
		g[0].rescue()
	await get_tree().create_timer(1.4, true, false, true).timeout
	if not is_inside_tree():
		return
	get_tree().paused = true
	_dialogue.play([
		{"speaker": "GAZELLE", "text": "Geleceğini biliyordum."},
		{"speaker": "REDMOUNT", "text": "Bir daha kimse seni buradan alamayacak. Gidelim."},
	])
	await _dialogue.finished
	if not is_inside_tree():
		return
	get_tree().paused = false
	await get_tree().create_timer(1.0, true, false, true).timeout
	if not is_inside_tree():
		return
	_bank_level_clear()
	get_tree().paused = true
	_hud.show_results(GameState.coins, _enemy_defeated, _enemy_total, _elapsed,
		GameState.score, "GAZELLE KURTARILDI", _compute_rank(), _hits_taken)


## Biome'a göre ekran-kenarı vinyet rengi (ruh hâli).
const _VIGNETTE_TINT := [
	Color(0.06, 0.02, 0.08),   # Street — mor gece
	Color(0.09, 0.05, 0.02),   # Industrial — pas/duman
	Color(0.02, 0.04, 0.10),   # Fortress — soğuk mavi
	Color(0.09, 0.03, 0.03),   # Keep — koyu kızıl
]

func _apply_biome_grade(biome: int) -> void:
	var v := $FxLayer/Vignette
	if v.material is ShaderMaterial:
		var m: ShaderMaterial = v.material
		m.set_shader_parameter(&"tint", _VIGNETTE_TINT[clampi(biome, 0, 3)])
		m.set_shader_parameter(&"strength", 0.22 if GameState.level_index == 0 else 0.55)


func _on_checkpoint(global_pos: Vector2) -> void:
	_respawn_pos = global_pos


## Diyalog tetiği — süresince dünyayı duraklat, bitince devam et.
func _on_dialogue(lines: Array) -> void:
	if _finished or _dialogue.is_active():
		return
	if _story_card.is_active():
		await _story_card.finished
		if not is_inside_tree() or _finished or _dialogue.is_active():
			return
	get_tree().paused = true
	_dialogue.play(lines)
	await _dialogue.finished
	if is_inside_tree() and not _finished:
		get_tree().paused = false


## Diken / ölümcül alan — düşme çukuruyla aynı ceza (son kontrol noktası).
func _on_hazard() -> void:
	if _finished:
		return
	Fx.spark(_player.global_position + Vector2(0, -40), Vector2(0, -1), 12, Color(1, 0.4, 0.3), 1.4)
	Combat.shake(5.0)
	Sfx.play(&"player_hurt")
	_respawn_player()


func _on_goal_reached() -> void:
	if _finished or _ending_in_progress:
		return
	if _level.has_method(&"play_ending"):
		_ending_in_progress = true
		_player.velocity = Vector2.ZERO
		_player.set_physics_process(false)
		_hud.visible = false
		await _level.play_ending(_dialogue)
		if not is_inside_tree():
			return
		_hud.visible = true
		_ending_in_progress = false
	elif GameState.story_scenes and not StoryData.outro(GameState.level_index).is_empty():
		# Bölümün hikâye sonucu: ne bulundu, iz nereye gidiyor.
		_ending_in_progress = true
		get_tree().paused = true
		_dialogue.play(StoryData.outro(GameState.level_index))
		await _dialogue.finished
		if not is_inside_tree():
			return
		_ending_in_progress = false
	_finished = true
	Sfx.play(&"goal")
	Music.stop(0.7)
	_bank_level_clear()
	get_tree().paused = true
	var rank := _compute_rank()
	if GameState.has_next_level():
		_hud.show_stage_clear(GameState.level_index + 1, rank, _elapsed,
			_enemy_defeated, _enemy_total, _hits_taken)
	else:
		var title := ("KİTAP 3 · BÖLÜM %d TAMAMLANDI" % (GameState.level_index - 23)
			if GameState.level_index >= 24 else
			"KİTAP 2 · BÖLÜM %d TAMAMLANDI" % (GameState.level_index - 11)
			if GameState.level_index >= 12 else "OYUN TAMAMLANDI")
		title = str(_level.get_meta(&"completion_title", title))
		_hud.show_results(GameState.coins, _enemy_defeated, _enemy_total, _elapsed,
			GameState.score, title, rank, _hits_taken)


func _bank_level_clear() -> void:
	Save.record_level_clear(
		GameState.level_index, GameState.coins - _coins_at_level_start, GameState.score,
	)


func _respawn_player() -> void:
	_player.set_physics_process(true)
	_player.global_position = _respawn_pos
	for arena in _in_group(_level, &"battle_arena"):
		if arena._active and not arena._done and arena.use_gates:
			_player.global_position = Vector2(arena.gate_left_x + 100.0, arena.floor_y - 40.0)
			break
	_player.revive()
	_hud.hide_death()


func _on_armory_requested(item_id: String) -> void:
	if item_id == "fists":
		_player.select_fists()
		_pause_menu.show_armory_status("Yakın dövüş: Yumruk", true)
		return
	var cost: int = int({"bat": 20, "knife": 25, "pistol": 40, "rifle": 60, "armor": 30}.get(item_id, -1))
	if cost < 0 or not GameState.spend_coins(cost):
		_pause_menu.show_armory_status("Yeterli coin yok.")
		return
	match item_id:
		"bat":
			_player.equip_weapon(BAT)
			_pause_menu.show_armory_status("Sopa kuşanıldı. J ile savur.", true)
		"knife":
			_player.equip_weapon(KNIFE)
			_pause_menu.show_armory_status("Bıçak kuşanıldı. Hızlı ama kısa menzilli.", true)
		"pistol":
			_player.equip_gun(PISTOL)
			_pause_menu.show_armory_status("Tabanca kuşanıldı. L ile ateş et.", true)
		"rifle":
			_player.equip_gun(RIFLE)
			_pause_menu.show_armory_status("Tüfek kuşanıldı. L ile seri ateş et.", true)
		"armor":
			_player.equip_armor(BODY_ARMOR)
			_pause_menu.show_armory_status("Zırh: hasar -%50, hız -%15, 6 darbe.", true)


## `root` alt ağacında `group` grubundaki düğümleri toplar.
func _in_group(root: Node, group: StringName) -> Array:
	var out: Array = []
	if root.is_in_group(group):
		out.append(root)
	for child in root.get_children():
		out.append_array(_in_group(child, group))
	return out
