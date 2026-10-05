## EnemyBase — tüm düşmanların ortak tabanı (Görev 3).
##
## Sağlık, hurtbox/hitbox, geri itme, hasar-alma tepkileri (hurt / knockdown /
## getup / death), yerçekimi, devriye, oyuncuyu fark etme ve üç fazlı yakın
## dövüş saldırısı burada. Her düşman türü yalnızca bir `EnemyConfig` kaynağı +
## `SpriteFrames` verir (ana plan md. 18.1).
##
## Redmount ile simetrik imza: apply_hit(damage, dir, knockback).
## Durum sistemi: tek enum + `match` (ana plan: küçük mimari, node FSM yok).
class_name EnemyBase
extends CharacterBody2D

enum State {
	IDLE, PATROL, ALERT, CHASE, ATTACK, RETREAT, DASH, RANGED,
	BLOCK, LEAP, EVADE, ARMOR_BREAK, HURT, KNOCKDOWN, DEAD,
}
enum Phase { WINDUP, ACTIVE, RECOVERY }

## Tüm sayısal değerler. Bkz. enemy_config.gd
@export var config: EnemyConfig
## ESKİ — kullanılmıyor (Görev 21'de rig'e geçildi). Eski sahneler bozulmasın diye duruyor.
@export var frames: SpriteFrames
## Devriye yarıçapı (px). 0 -> yerinde bekler.
@export var patrol_distance: float = 0.0
## Rig görünüm stili — her düşman sahnesi ayarlar (Görev 21).
@export_enum("thug", "knife", "rifle", "bruiser", "assassin", "miniboss", "elite", "karahanli") \
	var rig_style: String = "thug"

## Main skor / kalan düşman sayımı için dinler.
signal defeated(enemy: Node)
## Sadece `config.is_boss` düşmanlar yayar -> HUD boss can barı (Görev 10).
signal boss_health_changed(current: int, maximum: int)

@onready var sprite: Node2D = $Rig
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _hitbox: Area2D = $AttackHitbox
@onready var _hitbox_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var _muzzle: Marker2D = $Muzzle

var _state: State = State.IDLE
var _facing: int = -1
var _health: int = 0
var _home_x: float = 0.0
var _patrol_dir: int = -1
var _player: Node2D

var _phase: Phase = Phase.WINDUP
var _phase_timer: float = 0.0
var _attack_cd: float = 0.0
## Aktif saldırı fazının toplam süresi (ilerleme oranı için).
var _phase_full: float = 0.2
var _alert_timer: float = 0.0
var _hurt_timer: float = 0.0
var _knockdown_timer: float = 0.0
var _getup_timer: float = 0.0
var _getting_up: bool = false
var _hit_player_this_swing: bool = false
var _defeated_sent: bool = false

var _retreat_timer: float = 0.0
var _dash_timer: float = 0.0
var _dash_preparing: bool = false
var _dash_dir: int = -1

var _shoot_cd: float = 0.0
var _aiming: bool = false
var _aim_timer: float = 0.0
var _burst_left: int = 0
var _burst_timer: float = 0.0

var _attack_heavy: bool = false
var _block_timer: float = 0.0
var _block_cd: float = 0.0
var _leap_struck: bool = false
var _leap_timer: float = 0.0
var _evade_timer: float = 0.0
var _evade_dir: int = 1
var _spawn_y: float = 0.0

var _hits_taken: int = 0
var _armor_break_timer: float = 0.0
var _slam_done: bool = false
var _thrown_timer: float = 0.0
var _thrown_damage: int = 0
var _thrown_hits: Array[Node] = []

func _ready() -> void:
	if config == null:
		config = EnemyConfig.new()
		push_warning("%s: 'config' bağlı değil, varsayılan EnemyConfig." % name)
	_setup_rig()
	# Tek yön platformlar (katman 8 / değer 128) da zemin sayılır: çatıya, tenteye,
	# iskeleye yerleştirilen düşman orada durur, kenarda geri döner.
	set_collision_mask_value(8, true)

	_health = config.max_health
	_home_x = global_position.x
	_spawn_y = global_position.y
	_player = get_tree().get_first_node_in_group(&"player")
	add_to_group(&"enemy_ai")

	_set_hitbox_enabled(false)
	_hitbox.area_entered.connect(_on_hitbox_area_entered)

	if config.is_boss:
		boss_health_changed.emit(_health, config.max_health)

	_set_state(State.PATROL if patrol_distance > 0.0 else State.IDLE)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + config.gravity * delta, 1400.0)
	_attack_cd = maxf(_attack_cd - delta, 0.0)
	_block_cd = maxf(_block_cd - delta, 0.0)

	# Bir yerlere düşüp kaybolursa (ör. suikastçı boşluğa sıçradı) sessizce yok ol.
	if _state != State.DEAD and global_position.y > _spawn_y + 1400.0:
		queue_free()
		return

	match _state:
		State.IDLE: _do_idle(delta)
		State.PATROL: _do_patrol(delta)
		State.ALERT: _do_alert(delta)
		State.CHASE: _do_chase(delta)
		State.ATTACK: _do_attack(delta)
		State.RETREAT: _do_retreat(delta)
		State.DASH: _do_dash(delta)
		State.RANGED: _do_ranged(delta)
		State.BLOCK: _do_block(delta)
		State.LEAP: _do_leap(delta)
		State.EVADE: _do_evade(delta)
		State.ARMOR_BREAK: _do_armor_break(delta)
		State.HURT, State.KNOCKDOWN: _do_stagger(delta)
		State.DEAD: _do_dead(delta)

	_apply_separation()
	if not is_finite(velocity.x) or not is_finite(velocity.y):
		velocity = Vector2.ZERO
	if not is_finite(global_position.x) or not is_finite(global_position.y):
		push_warning("Non-finite enemy position: %s %s" % [name, global_position])
		queue_free()
		return
	if is_on_floor() and absf(velocity.x) > 1.0 and not _safe_to_step(signf(velocity.x)):
		velocity.x = 0.0
	move_and_slide()
	_tick_thrown_collision(delta)
	sprite.facing = _facing
	_hitbox.position.x = absf(_hitbox.position.x) * _facing
	_muzzle.position.x = absf(_muzzle.position.x) * _facing
	sprite.set_anim(
		State.keys()[_state],
		("HEAVY" if _attack_heavy else "COMBO") if _state == State.ATTACK else "",
		int(_phase),
		clampf(1.0 - _phase_timer / _phase_full, 0.0, 1.0),
		0, _facing, "",
	)


## Rig görünümünü stile göre kur (Görev 21).
func _setup_rig() -> void:
	if frames != null and sprite is AnimatedSprite2D:
		(sprite as AnimatedSprite2D).sprite_frames = frames
	var s: Dictionary = _RIG_STYLES.get(rig_style, _RIG_STYLES["thug"])
	sprite.palette = s.pal
	sprite.head_style = s.head
	sprite.hold_rifle = s.get("rifle", false)
	sprite.body_scale = s.get("scale", 1.0)
	var sh := get_node_or_null(^"BlobShadow")
	if sh != null:
		sh.radius *= float(s.get("scale", 1.0))


const _RIG_STYLES := {
	"thug": {
		"head": "beanie",
		"pal": {"hair": Color(0.14, 0.1, 0.08), "hair_hi": Color(0.26, 0.18, 0.12),
			"skin": Color(0.82, 0.6, 0.44), "skin_sh": Color(0.66, 0.46, 0.33),
			"jacket": Color(0.16, 0.17, 0.19), "jacket_hi": Color(0.26, 0.27, 0.3),
			"pants": Color(0.18, 0.2, 0.24), "pants_hi": Color(0.26, 0.28, 0.32),
			"shoe": Color(0.4, 0.4, 0.44), "cloth": Color(0.2, 0.22, 0.25)},
	},
	"knife": {
		"head": "hood",
		"pal": {"hair": Color(0.1, 0.1, 0.11), "hair_hi": Color(0.2, 0.2, 0.22),
			"skin": Color(0.8, 0.58, 0.42), "skin_sh": Color(0.6, 0.42, 0.3),
			"jacket": Color(0.1, 0.1, 0.12), "jacket_hi": Color(0.18, 0.18, 0.2),
			"pants": Color(0.11, 0.11, 0.13), "pants_hi": Color(0.17, 0.17, 0.19),
			"shoe": Color(0.15, 0.15, 0.17), "cloth": Color(0.12, 0.12, 0.14)},
	},
	"rifle": {
		"head": "helmet", "rifle": true,
		"pal": {"hair": Color(0.12, 0.12, 0.12), "hair_hi": Color(0.2, 0.2, 0.2),
			"skin": Color(0.8, 0.58, 0.42), "skin_sh": Color(0.6, 0.42, 0.3),
			"jacket": Color(0.2, 0.22, 0.2), "jacket_hi": Color(0.3, 0.32, 0.3),
			"pants": Color(0.18, 0.2, 0.18), "pants_hi": Color(0.26, 0.28, 0.26),
			"shoe": Color(0.16, 0.16, 0.16), "metal": Color(0.28, 0.3, 0.34)},
	},
	"bruiser": {
		"head": "helmet", "scale": 1.18,
		"pal": {"hair": Color(0.1, 0.1, 0.1), "hair_hi": Color(0.18, 0.18, 0.18),
			"skin": Color(0.78, 0.56, 0.4), "skin_sh": Color(0.58, 0.4, 0.28),
			"jacket": Color(0.22, 0.22, 0.25), "jacket_hi": Color(0.34, 0.34, 0.38),
			"pants": Color(0.2, 0.2, 0.23), "pants_hi": Color(0.3, 0.3, 0.33),
			"shoe": Color(0.15, 0.15, 0.16), "metal": Color(0.32, 0.33, 0.37)},
	},
	"assassin": {
		"head": "hood",
		"pal": {"hair": Color(0.09, 0.09, 0.1), "hair_hi": Color(0.16, 0.16, 0.18),
			"skin": Color(0.8, 0.58, 0.42), "skin_sh": Color(0.6, 0.42, 0.3),
			"jacket": Color(0.13, 0.14, 0.17), "jacket_hi": Color(0.2, 0.22, 0.26),
			"pants": Color(0.12, 0.13, 0.16), "pants_hi": Color(0.18, 0.19, 0.22),
			"shoe": Color(0.14, 0.14, 0.16), "cloth": Color(0.14, 0.15, 0.18)},
	},
	"miniboss": {
		"head": "helmet", "scale": 1.35,
		"pal": {"hair": Color(0.1, 0.08, 0.08), "hair_hi": Color(0.5, 0.15, 0.12),
			"skin": Color(0.76, 0.54, 0.38), "skin_sh": Color(0.56, 0.38, 0.26),
			"jacket": Color(0.2, 0.19, 0.22), "jacket_hi": Color(0.34, 0.32, 0.36),
			"pants": Color(0.18, 0.17, 0.2), "pants_hi": Color(0.28, 0.27, 0.3),
			"shoe": Color(0.14, 0.14, 0.15), "metal": Color(0.3, 0.28, 0.32)},
	},
	"elite": {
		"head": "helmet", "rifle": true,
		"pal": {"hair": Color(0.1, 0.1, 0.1), "hair_hi": Color(0.18, 0.18, 0.18),
			"skin": Color(0.8, 0.58, 0.42), "skin_sh": Color(0.6, 0.42, 0.3),
			"jacket": Color(0.12, 0.12, 0.14), "jacket_hi": Color(0.7, 0.55, 0.2),
			"pants": Color(0.12, 0.12, 0.14), "pants_hi": Color(0.2, 0.2, 0.22),
			"shoe": Color(0.1, 0.1, 0.11), "metal": Color(0.22, 0.22, 0.26)},
	},
	"karahanli": {
		"head": "slick", "scale": 1.12,
		"pal": {"hair": Color(0.1, 0.09, 0.09), "hair_hi": Color(0.22, 0.2, 0.2),
			"skin": Color(0.78, 0.56, 0.4), "skin_sh": Color(0.56, 0.38, 0.28),
			"jacket": Color(0.08, 0.08, 0.09), "jacket_hi": Color(0.16, 0.16, 0.18),
			"pants": Color(0.08, 0.08, 0.09), "pants_hi": Color(0.14, 0.14, 0.16),
			"shoe": Color(0.06, 0.06, 0.07)},
	},
}


# --- AI durumları --------------------------------------------------------

func _do_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
	if _sees_player() or _hears_combat():
		_enter_alert()
	elif patrol_distance > 0.0:
		_set_state(State.PATROL)


func _do_patrol(_delta: float) -> void:
	if _sees_player() or _hears_combat():
		_enter_alert()
		return
	var target_x := _home_x + _patrol_dir * patrol_distance
	if absf(global_position.x - target_x) < 6.0 or is_on_wall() or not _safe_to_step(_patrol_dir):
		_patrol_dir = -_patrol_dir
	_facing = _patrol_dir
	velocity.x = _patrol_dir * config.patrol_speed


func _do_alert(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
	_face_player()
	_alert_timer -= delta
	if _alert_timer <= 0.0:
		_set_state(State.CHASE)


func _do_chase(delta: float) -> void:
	if not _sees_player(config.give_up_range):
		_set_state(State.PATROL if patrol_distance > 0.0 else State.IDLE)
		return
	if config.is_ranged:
		_set_state(State.RANGED)
		return
	_face_player()

	var dx: float = _player.global_position.x - global_position.x
	var dy: float = absf(_player.global_position.y - global_position.y)
	var adx := absf(dx)

	if adx <= config.attack_range and dy <= config.attack_band and _attack_cd <= 0.0:
		if _has_melee_turn():
			_start_attack()
		else:
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
		return

	# Çevik Suikastçı: menzile girince oyuncuya sıçra + havadan in.
	if config.is_agile and _attack_cd <= 0.0 and is_on_floor() \
			and adx <= config.leap_range and adx > config.attack_range * 0.9:
		_start_leap()
		return

	# Bıçaklı Ajan tarzı: menzile girince geri çekil + dash.
	if config.uses_dash and _attack_cd <= 0.0 and adx <= config.dash_trigger_range \
			and dy <= config.sight_band:
		if adx < config.retreat_range:
			_retreat_timer = config.retreat_time
			_set_state(State.RETREAT)
		else:
			_enter_dash_prepare()
		return

	# Saldırı menziline kadar yaklaş.
	if adx > config.attack_range * 0.85:
		var chase_dir := signf(dx)
		velocity.x = chase_dir * config.move_speed if _safe_to_step(chase_dir) else 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)


func _do_retreat(delta: float) -> void:
	if not _sees_player(config.give_up_range):
		_recover()
		return
	_face_player()
	var dx: float = _player.global_position.x - global_position.x
	var retreat_dir := -signf(dx)
	velocity.x = retreat_dir * config.retreat_speed if _safe_to_step(retreat_dir) else 0.0
	_retreat_timer -= delta
	if _retreat_timer <= 0.0 or absf(dx) >= config.retreat_range or is_on_wall():
		_enter_dash_prepare()


func _do_ranged(delta: float) -> void:
	if not _sees_player(config.give_up_range):
		_aiming = false
		_burst_left = 0
		_recover()
		return
	_face_player()
	_shoot_cd = maxf(_shoot_cd - delta, 0.0)

	var dx: float = _player.global_position.x - global_position.x
	var dy: float = absf(_player.global_position.y - global_position.y)
	var adx := absf(dx)

	# Çok yakın -> dipçik (yakın dövüş).
	if adx < config.panic_range and dy <= config.attack_band and _attack_cd <= 0.0 \
			and _has_melee_turn():
		_aiming = false
		_burst_left = 0
		_start_attack()
		return

	var busy := _aiming or _burst_left > 0
	if busy:
		velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
	elif adx < config.ranged_preferred_distance * 0.75:
		velocity.x = -signf(dx) * config.move_speed        # geri çekil
	elif adx > config.ranged_preferred_distance * 1.3:
		velocity.x = signf(dx) * config.move_speed * 0.7   # biraz yaklaş
	else:
		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)

	if not busy:
		_play(&"walk" if absf(velocity.x) > 20.0 else &"aim")

	if _burst_left > 0:
		_burst_timer -= delta
		if _burst_timer <= 0.0:
			_fire_one()
			_burst_left -= 1
			_burst_timer = config.burst_interval
			if _burst_left <= 0:
				_shoot_cd = config.shoot_cooldown
				_play(&"aim")
	elif _aiming:
		_aim_timer -= delta
		if _aim_timer <= 0.0:
			_aiming = false
			_burst_left = maxi(config.burst_count, 1)
			_burst_timer = 0.0
	elif _shoot_cd <= 0.0 and adx <= config.ranged_fire_range and dy <= config.sight_band:
		_aiming = true
		_aim_timer = config.aim_time
		_play(&"aim")
		Fx.popup(global_position + Vector2(0, -115), "!", Color(1.0, 0.35, 0.2), 28)


func _fire_one() -> void:
	_play(&"shoot")
	Projectile.spawn(
		get_tree().current_scene, _muzzle.global_position,
		Vector2(_facing, 0.0), config.projectile_speed,
		config.projectile_damage, config.projectile_knockback, true, self,
	)
	Sfx.play(&"shoot", 0.9)
	Combat.shake(2.0)


func _enter_dash_prepare() -> void:
	_dash_preparing = true
	_dash_timer = config.dash_prepare_time
	_hit_player_this_swing = false
	velocity.x = 0.0
	_face_player()
	_set_hitbox_enabled(false)
	_set_state(State.DASH)
	Fx.popup(global_position + Vector2(0, -115), "!", Color(1.0, 0.55, 0.2), 28)


func _do_dash(delta: float) -> void:
	_dash_timer -= delta

	if _dash_preparing:
		velocity.x = move_toward(velocity.x, 0.0, 1400.0 * delta)
		if _dash_timer <= 0.0:
			_dash_preparing = false
			_dash_timer = config.dash_duration
			_face_player()
			_dash_dir = _facing
			_hit_player_this_swing = false
			_set_hitbox_enabled(true)
			Sfx.play(&"dash")
		return

	velocity.x = _dash_dir * config.dash_speed
	if _dash_timer <= 0.0 or is_on_wall() or not _safe_to_step(_dash_dir, 42.0):
		_set_hitbox_enabled(false)
		_attack_cd = config.dash_cooldown
		_set_state(State.CHASE)


func _start_attack() -> void:
	_attack_heavy = config.heavy_attack_chance > 0.0 and randf() < config.heavy_attack_chance
	_slam_done = false
	_phase = Phase.WINDUP
	_phase_timer = config.heavy_attack_windup if _attack_heavy else config.attack_windup
	_phase_full = maxf(_phase_timer, 0.01)
	_hit_player_this_swing = false
	velocity.x = 0.0
	_face_player()
	_set_hitbox_enabled(false)
	_set_state(State.ATTACK)
	_play(config.heavy_attack_anim if _attack_heavy else config.attack_anim)
	Fx.popup(global_position + Vector2(0, -115), "!",
		Color(1.0, 0.25, 0.15) if _attack_heavy else Color(1.0, 0.75, 0.25),
		30 if _attack_heavy else 22)
	Sfx.play(&"swing", 0.7 if _attack_heavy else 0.9)


func _has_melee_turn() -> bool:
	if config.is_boss or _player == null:
		return true
	for enemy in get_tree().get_nodes_in_group(&"enemy_ai"):
		if enemy == self or not is_instance_valid(enemy):
			continue
		if enemy._state in [State.ATTACK, State.DASH, State.LEAP] \
				and enemy.global_position.distance_squared_to(_player.global_position) <= 320.0 * 320.0:
			return false
	return true


func _do_attack(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
	_phase_timer -= delta
	if _phase_timer > 0.0:
		return
	match _phase:
		Phase.WINDUP:
			_phase = Phase.ACTIVE
			_phase_timer = config.heavy_attack_active if _attack_heavy else config.attack_active
			_phase_full = maxf(_phase_timer, 0.01)
			_set_hitbox_enabled(true)
			var so := global_position + Vector2(_facing * 20.0, -60.0)
			Fx.slash(so, _facing, 46.0 if _attack_heavy else 34.0,
				2.6 if _attack_heavy else 1.9,
				Color(1, 0.7, 0.5, 0.85) if _attack_heavy else Color(0.9, 0.9, 1, 0.75),
				0.16 if _attack_heavy else 0.11)
			if _attack_heavy and config.slam_on_heavy and not _slam_done:
				_slam_done = true
				Shockwave.spawn(
					get_tree().current_scene, global_position, _facing,
					config.slam_damage, config.slam_knockback, true,
				)
		Phase.ACTIVE:
			_phase = Phase.RECOVERY
			_phase_timer = config.heavy_attack_recovery if _attack_heavy else config.attack_recovery
			_phase_full = maxf(_phase_timer, 0.01)
			_set_hitbox_enabled(false)
		Phase.RECOVERY:
			_set_hitbox_enabled(false)
			_attack_cd = config.attack_cooldown
			_set_state(State.CHASE)


# --- Blok / sıçrama / kaçınma (Görev 9) -------------------------------

func _start_block() -> void:
	_block_timer = config.block_windup + config.block_duration
	_block_cd = 1.6
	velocity.x = 0.0
	_face_player()
	_set_hitbox_enabled(false)
	_set_state(State.BLOCK)
	Sfx.play(&"shield", 0.8)


func _do_block(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 1400.0 * delta)
	_face_player()
	_block_timer -= delta
	if _block_timer <= 0.0:
		_recover()


func _start_leap() -> void:
	_leap_struck = false
	_leap_timer = 1.8
	_hit_player_this_swing = false
	_face_player()
	velocity.y = config.leap_jump_velocity
	velocity.x = _facing * config.leap_h_speed
	_set_hitbox_enabled(false)
	_set_state(State.LEAP)
	Sfx.play(&"dash", 1.1)


func _do_leap(delta: float) -> void:
	_leap_timer -= delta
	# Düşüşte pençe/bıçak aktif (drop strike).
	if velocity.y > 60.0 and not _leap_struck:
		_leap_struck = true
		_hit_player_this_swing = false
		_set_hitbox_enabled(true)
	if is_on_wall():
		velocity.x = move_toward(velocity.x, 0.0, 40.0)
	if is_on_floor() or _leap_timer <= 0.0:
		_set_hitbox_enabled(false)
		_attack_cd = config.leap_cooldown
		_set_state(State.CHASE)


func _start_evade(away_dir: float) -> void:
	_evade_dir = int(signf(away_dir)) if not is_zero_approx(away_dir) else -_facing
	_evade_timer = config.evade_time
	velocity.x = _evade_dir * config.evade_speed
	velocity.y = -180.0
	_facing = -_evade_dir
	_set_hitbox_enabled(false)
	_set_state(State.EVADE)


func _do_evade(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
	_evade_timer -= delta
	if _evade_timer <= 0.0 and is_on_floor():
		_recover()


func _enter_armor_break() -> void:
	_armor_break_timer = config.armor_break_duration
	velocity.x = 0.0
	_set_hitbox_enabled(false)
	_set_state(State.ARMOR_BREAK)
	Sfx.play(&"armor_break")
	Combat.shake(6.0)


func break_guard() -> void:
	if _state != State.DEAD and config.armor_break_hits > 0:
		_enter_armor_break()


func _do_armor_break(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
	_armor_break_timer -= delta
	if _armor_break_timer <= 0.0:
		_recover()


func _do_stagger(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 700.0 * delta)

	if _state == State.HURT:
		_hurt_timer -= delta
		if _hurt_timer <= 0.0:
			_recover()
		return

	if _knockdown_timer > 0.0:
		_knockdown_timer -= delta
		return
	if not is_on_floor():
		return
	if not _getting_up:
		_getting_up = true
		_play(&"getup")
	_getup_timer -= delta
	if _getup_timer <= 0.0:
		_getting_up = false
		_recover()


func _do_dead(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)


func _recover() -> void:
	if _sees_player(config.give_up_range):
		_set_state(State.CHASE)
	else:
		_set_state(State.PATROL if patrol_distance > 0.0 else State.IDLE)


# --- Hasar alma --------------------------------------------------------

## Redmount'un Hitbox'ı bu düşmanın Hurtbox'ına değince Redmount tarafından çağrılır.
func apply_hit(damage: int, dir: Vector2, knockback: float) -> void:
	if _state == State.DEAD:
		return

	var push := signf(dir.x)
	if is_zero_approx(push):
		push = -_facing

	# Blok aktifken darbe tamamen boşa gider.
	if _state == State.BLOCK:
		Sfx.play(&"shield", 1.1)
		Combat.shake(2.0)
		return

	var in_break := _state == State.ARMOR_BREAK

	# Zırh kırık değilken: kalıcı zırh hasarı azaltır + bloka geçme şansı.
	if not in_break:
		damage = maxi(1, int(roundf(damage * config.damage_taken_mult)))
		if config.block_chance > 0.0 and _block_cd <= 0.0 and _health > damage \
				and _state in [State.CHASE, State.ALERT, State.RANGED] \
				and randf() < config.block_chance:
			_face_player()
			_start_block()
			return

	_health = maxi(_health - damage, 0)
	_flash()
	_set_hitbox_enabled(false)
	_dash_preparing = false
	_aiming = false
	_burst_left = 0

	Fx.spark(global_position + Vector2(0, -58), Vector2(push, -0.3),
		9 if _health == 0 else 6, Color(1, 0.85, 0.45))

	if not in_break:
		velocity.x = push * knockback * (1.0 - clampf(config.knockback_resist, 0.0, 1.0))
		velocity.y = -120.0
		_facing = int(-push)

	if _health == 0:
		_emit_boss_health()
		_set_state(State.DEAD)
		_play(&"death")
		Sfx.play(&"enemy_down")
		Fx.spark(global_position + Vector2(0, -56), Vector2.ZERO, 12, Color(1, 0.7, 0.4), 1.3)
		Fx.dust(global_position, 0.0, 6)
		_hurtbox.set_deferred(&"monitorable", false)
		# Yerde kısa süre yat, sonra sön ve temizlen (ceset yığılmasın).
		var fade := create_tween()
		fade.tween_interval(1.15)
		fade.tween_property(sprite, ^"modulate:a", 0.0, 0.45)
		fade.tween_callback(queue_free)
		if not _defeated_sent:
			_defeated_sent = true
			defeated.emit(self)
		return

	_emit_boss_health()

	# Zırh kırık pencerede: tam hasar aldı, tepki yok, pencere devam ediyor.
	if in_break:
		return

	Sfx.play(&"enemy_hurt")

	# Mini-boss: yeterli isabet -> zırh kırıl, kısa süre savunmasız.
	if config.armor_break_hits > 0:
		_hits_taken += 1
		if _hits_taken >= config.armor_break_hits:
			_hits_taken = 0
			_enter_armor_break()
			return

	# Çevik Suikastçı: hurt yerine geri kaç.
	if config.evade_chance > 0.0 and is_on_floor() and randf() < config.evade_chance:
		_start_evade(push)
		return

	if damage >= config.knockdown_damage_threshold:
		_knockdown_timer = config.knockdown_duration
		_getup_timer = config.getup_duration
		_getting_up = false
		_set_state(State.KNOCKDOWN)
	else:
		_hurt_timer = config.hurt_duration
		_set_state(State.HURT)


## Aparkat ve kombo bitiricilerinin ortak havaya savurma tepkisi.
func launch(upward_speed: float) -> void:
	if _state in [State.DEAD, State.BLOCK, State.ARMOR_BREAK]:
		return
	velocity.y = -absf(upward_speed) * (1.0 - clampf(config.knockback_resist, 0.0, 0.75))
	_knockdown_timer = config.knockdown_duration
	_getup_timer = config.getup_duration
	_getting_up = false
	_set_hitbox_enabled(false)
	_set_state(State.KNOCKDOWN)


func can_be_thrown() -> bool:
	return _state in [State.HURT, State.KNOCKDOWN] and config.knockback_resist < 0.5


func can_be_juggled() -> bool:
	return _state == State.KNOCKDOWN and not is_on_floor()


func throw_by(throw_velocity: Vector2, damage: int) -> void:
	if not can_be_thrown():
		return
	_thrown_timer = 0.75
	_thrown_damage = maxi(8, int(damage / 2))
	_thrown_hits.clear()
	apply_hit(damage, Vector2(signf(throw_velocity.x), 0.0), absf(throw_velocity.x))
	if _state == State.DEAD:
		velocity = throw_velocity
		return
	velocity = throw_velocity
	_knockdown_timer = config.knockdown_duration
	_getup_timer = config.getup_duration
	_getting_up = false
	_set_hitbox_enabled(false)
	_set_state(State.KNOCKDOWN)


func _tick_thrown_collision(delta: float) -> void:
	if _thrown_timer <= 0.0:
		return
	_thrown_timer = maxf(_thrown_timer - delta, 0.0)
	if velocity.length_squared() < 160.0 * 160.0:
		return
	for other in get_tree().get_nodes_in_group(&"enemy_ai"):
		if other == self or other in _thrown_hits or not is_instance_valid(other) \
				or not other.has_method(&"apply_hit"):
			continue
		if global_position.distance_squared_to(other.global_position) > 62.0 * 62.0:
			continue
		_thrown_hits.append(other)
		var direction := signf(velocity.x)
		other.apply_hit(_thrown_damage, Vector2(direction, 0.0), 360.0)
		Combat.hitstop(0.06)
		Combat.shake(5.0)
		Combat.rumble(0.55)
		Fx.spark(global_position + Vector2(0, -45), Vector2(direction, -0.2), 10, Color(1.0, 0.55, 0.25), 1.4)
		Sfx.play(&"heavy_hit")
		break


func _on_hitbox_area_entered(area: Area2D) -> void:
	if _hit_player_this_swing:
		return
	var target := area.owner if area.owner != null else area.get_parent()
	if target == null or not target.has_method(&"apply_hit"):
		return
	if _state == State.DASH and not _dash_preparing \
			and target.has_method(&"is_punch_counter_active") \
			and target.is_punch_counter_active():
		_set_hitbox_enabled(false)
		_dash_preparing = false
		velocity.x = 0.0
		_attack_cd = config.dash_cooldown
		target.land_dash_counter(self)
		return
	_hit_player_this_swing = true
	var dmg := config.heavy_attack_damage if (_state == State.ATTACK and _attack_heavy) else config.attack_damage
	var kb := config.heavy_attack_knockback if (_state == State.ATTACK and _attack_heavy) else config.attack_knockback
	target.apply_hit(dmg, Vector2(_facing, 0.0), kb)
	Combat.hitstop(0.05 if _attack_heavy else 0.04)
	Combat.shake(4.5 if _attack_heavy else 3.0)


# --- Yardımcılar --------------------------------------------------------

## Aynı noktada üst üste binmeyi engelle — yakın düşmanları yatayda iterek ayır.
## Düşmanlar oyuncuyu kuşatır ama iç içe geçmez.
const _SEP_X := 40.0
const _SEP_Y := 60.0
const _SEP_PUSH := 150.0

func _apply_separation() -> void:
	if _state in [State.DEAD, State.KNOCKDOWN, State.LEAP, State.DASH, State.EVADE]:
		return
	var push := 0.0
	for other in get_tree().get_nodes_in_group(&"enemy_ai"):
		if other == self or not is_instance_valid(other):
			continue
		if other.has_method(&"is_dead") and other.is_dead():
			continue
		var dx: float = global_position.x - other.global_position.x
		var dy: float = global_position.y - other.global_position.y
		if not is_finite(dx) or not is_finite(dy):
			continue
		if absf(dx) >= _SEP_X or absf(dy) >= _SEP_Y:
			continue
		var strength := 1.0 - absf(dx) / _SEP_X
		if absf(dx) < 1.0:
			push += (1.0 if (get_instance_id() > other.get_instance_id()) else -1.0) * strength
		else:
			push += signf(dx) * strength
	if not is_zero_approx(push):
		velocity.x += clampf(push, -1.5, 1.5) * _SEP_PUSH


func _sees_player(range_override: float = -1.0) -> bool:
	if _player == null or not is_instance_valid(_player):
		return false
	if _player.has_method(&"get_health") and _player.get_health() <= 0:
		return false
	if _player.has_method(&"is_invisible") and _player.is_invisible():
		return false
	var r := config.sight_range if range_override < 0.0 else range_override
	var dx: float = absf(_player.global_position.x - global_position.x)
	var dy: float = absf(_player.global_position.y - global_position.y)
	return dx <= r and dy <= config.sight_band


## Görüş alanı dışında olsa bile: oyuncu yakında saldırıyorsa ya da yandaki bir
## dost zaten dövüşüyorsa uyan (beat'em up "grup halinde saldır" hissi — Görev 25).
func _hears_combat() -> bool:
	if _player == null or not is_instance_valid(_player):
		return false
	var dx := absf(_player.global_position.x - global_position.x)
	var dy := absf(_player.global_position.y - global_position.y)
	if dx > config.sight_range * 1.5 or dy > config.sight_band * 1.6:
		return false
	if _player.has_method(&"get_state_name") and _player.get_state_name() == "ATTACK":
		return true
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		if e == self or not is_instance_valid(e):
			continue
		var es: int = e._state
		if es in [State.CHASE, State.ATTACK, State.RANGED, State.ALERT, State.RETREAT, State.DASH] \
				and absf(e.global_position.x - global_position.x) < 320.0:
			return true
	return false


func _face_player() -> void:
	if _player == null:
		return
	var d := signf(_player.global_position.x - global_position.x)
	if not is_zero_approx(d):
		_facing = int(d)


## Düşmanların oyuncuyu bir boşluğun karşısından görüp intihar etmesini önler.
## Ayakların biraz önünden aşağı ışın atılır; zemin yoksa yatay hareket kesilir.
func _safe_to_step(direction: float, ahead := 30.0) -> bool:
	if is_zero_approx(direction) or not is_on_floor():
		return true
	var foot_x := global_position.x + signf(direction) * ahead
	var query := PhysicsRayQueryParameters2D.create(
		Vector2(foot_x, global_position.y - 8.0),
		Vector2(foot_x, global_position.y + 72.0), 1 | 128)
	query.exclude = [get_rid()]
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _enter_alert() -> void:
	_alert_timer = config.alert_time
	velocity.x = 0.0
	_face_player()
	_set_state(State.ALERT)


func _set_hitbox_enabled(on: bool) -> void:
	_hitbox.set_deferred(&"monitoring", on)
	_hitbox_shape.set_deferred(&"disabled", not on)


func _flash() -> void:
	sprite.modulate = Color(2.4, 2.4, 2.4)
	var t := create_tween()
	t.tween_property(sprite, ^"modulate", Color(1, 1, 1), 0.14)


func _set_state(new_state: State) -> void:
	if new_state == _state:
		return
	_state = new_state
	# Görsel = char_rig (durum-güdümlü).


## Eski API — görsel artık rig'de, no-op.
func _play(_anim: StringName) -> void:
	pass


func _emit_boss_health() -> void:
	if config.is_boss:
		boss_health_changed.emit(_health, config.max_health)


func get_state_name() -> String:
	return State.keys()[_state]


func get_health() -> int:
	return _health


func is_dead() -> bool:
	return _state == State.DEAD
