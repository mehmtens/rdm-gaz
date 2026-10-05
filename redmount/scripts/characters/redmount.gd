## Redmount — oyuncu karakteri (Görev 2: hareket + silahsız dövüş prototipi).
##
## Görev 1: sola/sağa hareket, koşma, zıplama, yerçekimi, düşme, iniş,
## zemin + duvar çarpışması, sola giderken yatay çevrilme.
##
## Görev 2 (bu sürüm):
##   * Silahsız ikili yumruk kombosu (J), yükseltmeyle üçüncü vuruş — hazırlık → temas → geri dönüş fazları,
##     temas fazında Hitbox açılır. Faz içinde tekrar J -> zincir devam eder.
##   * Ağır yumruk (K) — tek, zincirsiz, yüksek hasar + geri itme.
##   * Hava diz darbesi (havada J) — inişe kadar sürer.
##   * Hasar alma: Hurtbox düşman Hitbox'ına değince apply_hit() çağrılır.
##     Düşük hasar -> hit_light; eşik üstü -> knockdown -> getup.
##   * Ölüm: can 0 -> dead; Main.revive() ile geri gelir.
##
## Durum sistemi basit tutulur: tek enum + `match` (ana plan: küçük mimari).
extends CharacterBody2D

enum State { IDLE, MOVE, RUN, JUMP, FALL, LAND, ATTACK, HURT, KNOCKDOWN, DEAD, CROUCH, DASH, WALLSLIDE }
enum Attack { NONE, COMBO, HEAVY, AIR_KNEE, WEAPON }
## Saldırı fazları.
enum Phase { WINDUP, ACTIVE, RECOVERY }

## Tüm hareket değerleri buradan gelir. Bkz. movement_config.gd
@export var movement: MovementConfig
## Tüm dövüş / can değerleri buradan gelir. Bkz. combat_config.gd
@export var combat: CombatConfig

## Parçalara ayrılmış prosedürel iskelet (Görev 21). Bkz. char_rig.gd
@onready var rig: Node2D = $Rig
@onready var _hitbox: Area2D = $Hitbox
@onready var _hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _muzzle: Marker2D = $Muzzle

## HUD / Main bunları dinler.
signal health_changed(current: int, maximum: int)
signal died
## Silah kuşanınca / kırılınca. name boşsa silahsız. (Görev 4)
signal weapon_changed(display_name: String, uses: int, max_uses: int)
## Ateşli silah / cephane değişince. has_gun false ise menzilli silah yok. (Görev 7)
signal ammo_changed(mag: int, reserve: int, has_gun: bool)
## Aktif güçlendirmeler değişince. Her eleman: {name, left, total, kind}. (Görev 8)
signal powerups_changed(active: Array)
## Zırh kuşanınca / kırılınca. name boşsa zırhsız. (Görev 8)
signal armor_changed(display_name: String, hp: int, max_hp: int)

## Aktif durum. Sadece _set_state() ile değiştirilir.
var _state: State = State.IDLE
## +1 sağa, -1 sola bakıyor.
var _facing: int = 1
## Bir önceki fizik karesinde zeminde miydik? (iniş tespiti için)
var _was_on_floor: bool = true
## Tente fırlatmasıyla yükseliyor (zıplama kesmesi uygulanmaz).
var _bouncing: bool = false
## "land" durumunda kalan süre.
var _land_timer: float = 0.0
## Adım sesi sayacı (yürürken/koşarken).
var _step_timer: float = 0.0
## Prosedürel animasyon: serbest zaman sayacı.
var _anim_t: float = 0.0
## Toz/adım için koşu toz sayacı.
var _dust_timer: float = 0.0
## Fizik motoruna geçersiz bir vektör ulaşırsa kameranın dünyadan kopmasını önler.
var _last_safe_position: Vector2 = Vector2.ZERO

# --- Parkur (Görev 15) ---
## Dash kalan süresi / bekleme / havada kalan dash hakkı.
var _dash_timer: float = 0.0
var _dash_cd: float = 0.0
var _air_dashes_left: int = 0
## Çift-basma dash tespiti.
var _tap_dir: int = 0
var _tap_time: float = 0.0
## Duvar zıplamasından sonra yatay kontrol kilidi.
var _wall_lock: float = 0.0
var _wall_dir: int = 0
## Tek yön (one-way) platformdan iniş: maske biti kapalı kalan süre.
var _drop_timer: float = 0.0
## Çömeliyor mu (collision profili küçültülür).
var _crouching: bool = false
## Gövde çarpışma şeklinin normal boyu (çömelmede yarıya iner).
var _body_full_h: float = 180.0
## Zeminden ayrıldıktan sonra hâlâ zıplayabilme süresi.
var _coyote_timer: float = 0.0
## Erken basılan zıplama tuşunun hafızada tutulma süresi.
var _jump_buffer_timer: float = 0.0

## Mevcut can.
var _health: int = 0
## Mağaza yükseltmesinden gelen ek azami can (Görev 14).
var _bonus_health: int = 0
## Darbe sonrası dokunulmazlık sayacı.
var _invuln_timer: float = 0.0

## Aktif saldırı türü.
var _attack: Attack = Attack.NONE
var _special_move: String = ""
## Aktif saldırı fazı.
var _phase: Phase = Phase.WINDUP
## Aktif fazın kalan süresi.
var _phase_timer: float = 0.0
## Combo sırası (0..2).
var _combo_index: int = 0
## Faz sırasında J'ye tekrar basıldı -> bir sonraki combo vuruşu kuyruğa alındı.
var _queued_next: bool = false
## Erken basılan saldırı girişi hafızada tutulur (Görev 19 — input buffer).
var _attack_buffer: float = 0.0
## Bu temas penceresinde vurulan hedefler (çift sayımı önler).
var _hit_this_swing: Array = []
## İnişten hemen önceki dikey hız (sert iniş tespiti).
var _land_impact: float = 0.0

## Kuşanılan silah (null = silahsız). Bkz. weapon_config.gd (Görev 4)
var _weapon: WeaponConfig
## Kuşanılan silahın kalan savuruşu.
var _weapon_uses: int = 0
## Silahsız yumruk hitbox'ının sahnedeki temel ölçüsü / ileri ofseti.
var _punch_reach: Vector2 = Vector2(96, 96)
var _punch_offset: float = 55.0
var _muzzle_offset: float = 40.0

## Ateşli silah (null = yok). Bkz. gun_config.gd (Görev 7)
var _gun: GunConfig
var _mag: int = 0
var _reserve: int = 0
var _fire_cd: float = 0.0
var _reload_timer: float = 0.0
var _reloading: bool = false

## Aktif güçlendirmeler: kind -> {left, total, mag, name}. Bkz. powerup_config.gd (Görev 8)
var _pu: Dictionary = {}
## Kuşanılan zırh (null = yok). Bkz. armor_config.gd (Görev 8)
var _armor: ArmorConfig
var _armor_hp: int = 0

## HURT durumunda kalan süre.
var _hurt_timer: float = 0.0
## KNOCKDOWN: yerde yatma kalan süre.
var _knockdown_timer: float = 0.0
## KNOCKDOWN: ayağa kalkma kalan süre.
var _getup_timer: float = 0.0
## KNOCKDOWN: "getup" fazına geçildi mi?
var _getting_up: bool = false

func _ready() -> void:
	if movement == null:
		movement = MovementConfig.new()
		push_warning("Redmount: 'movement' ayarı bağlı değil, varsayılan MovementConfig kullanılıyor.")
	if combat == null:
		combat = CombatConfig.new()
		push_warning("Redmount: 'combat' ayarı bağlı değil, varsayılan CombatConfig kullanılıyor.")

	_bonus_health = 15 * Save.upgrade_level("max_health")
	_health = get_max_health()
	_last_safe_position = global_position
	health_changed.emit(_health, get_max_health())

	_punch_offset = absf(_hitbox.position.x)
	_muzzle_offset = absf(_muzzle.position.x)
	if _hitbox_shape.shape is RectangleShape2D:
		_punch_reach = (_hitbox_shape.shape as RectangleShape2D).size

	_set_hitbox_enabled(false)
	_hitbox.area_entered.connect(_on_hitbox_area_entered)
	_hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	set_collision_mask_value(8, true)  # tek yön (one-way) platformlar
	_air_dashes_left = movement.air_dashes
	if $CollisionShape2D.shape is RectangleShape2D:
		_body_full_h = ($CollisionShape2D.shape as RectangleShape2D).size.y

	weapon_changed.emit("", 0, 0)
	ammo_changed.emit(0, 0, false)
	powerups_changed.emit([])
	armor_changed.emit("", 0, 0)
	_set_state(State.IDLE)


func _physics_process(delta: float) -> void:
	if not global_position.is_finite() or not velocity.is_finite():
		_recover_invalid_motion()
		return
	_invuln_timer = maxf(_invuln_timer - delta, 0.0)
	_anim_t += delta
	_dash_cd = maxf(_dash_cd - delta, 0.0)
	_wall_lock = maxf(_wall_lock - delta, 0.0)
	_attack_buffer = maxf(_attack_buffer - delta, 0.0)
	if Input.is_action_just_pressed(&"attack"):
		_attack_buffer = 0.16
	if _drop_timer > 0.0:
		_drop_timer -= delta
		if _drop_timer <= 0.0:
			set_collision_mask_value(8, true)
	_tick_powerups(delta)
	_update_invuln_flash()

	match _state:
		State.DEAD:
			_process_dead(delta)
		State.HURT, State.KNOCKDOWN:
			_process_stagger(delta)
		State.ATTACK:
			_process_attack(delta)
		State.DASH:
			_process_dash(delta)
		_:
			_process_normal(delta)

	if not global_position.is_finite() or not velocity.is_finite():
		_recover_invalid_motion()
		return
	if is_on_floor():
		_last_safe_position = global_position

	_apply_proc_anim(delta)


# --- Prosedürel iskelet animasyonu (Görev 21) ---------------------------
##
## Durumu char_rig'e aktarır (rig kol/bacak/gövde kemiklerini kendi kore eder)
## ve [[fx]] ile toz / hayalet iz spawn eder.
func _apply_proc_anim(delta: float) -> void:
	rig.facing = _facing
	var attack_name: String = _special_move.to_upper() if not _special_move.is_empty() else Attack.keys()[_attack]
	rig.set_anim(
		State.keys()[_state],
		attack_name if _state == State.ATTACK else "",
		int(_phase), _phase_progress(), _combo_index, _facing,
		_weapon.anim_prefix if _weapon != null else "",
		_gun.anim_prefix if _gun != null else "",
	)
	match _state:
		State.MOVE, State.RUN:
			_emit_run_dust(delta, _state == State.RUN)
		State.WALLSLIDE:
			_emit_wall_dust(delta)
		_:
			pass


## Aktif fazın süresi (windup/active/recovery). _phase_progress için.
func _windup_time() -> float:
	match _attack:
		Attack.COMBO: return combat.combo_windup[_combo_index] * _combo_time_multiplier()
		Attack.HEAVY: return combat.heavy_windup
		Attack.WEAPON: return _weapon.windup if _weapon != null else 0.1
		Attack.AIR_KNEE: return combat.air_knee_windup
		_: return 0.1


func _phase_progress() -> float:
	var full: float = _windup_time() if _phase == Phase.WINDUP \
		else (_active_time() if _phase == Phase.ACTIVE else _recovery_time())
	if full <= 0.0:
		return 1.0
	return clampf(1.0 - _phase_timer / full, 0.0, 1.0)


## ACTIVE fazına geçince temas yayı efekti.
func _spawn_attack_slash() -> void:
	var origin := global_position + Vector2(_facing * 18.0, -60.0)
	match _attack:
		Attack.COMBO:
			var big := _combo_index >= 2
			Fx.slash(origin, _facing, 36.0 if not big else 50.0, 1.9 if not big else 2.6,
				Color(1, 1, 1, 0.8), 0.11 if not big else 0.16)
		Attack.HEAVY:
			Fx.slash(origin + Vector2(_facing * 4, 0), _facing, 56.0, 2.8, Color(1, 0.8, 0.5, 0.9), 0.18)
			Combat.shake(2.0)
		Attack.WEAPON:
			var kn := _weapon != null and _weapon.anim_prefix.begins_with("knife")
			Fx.slash(origin, _facing, 38.0 if kn else 60.0, 2.0 if kn else 3.0,
				Color(0.9, 0.95, 1, 0.9) if kn else Color(1, 0.95, 0.85, 0.9),
				0.1 if kn else 0.2)
		Attack.AIR_KNEE:
			Fx.slash(origin + Vector2(0, 10), _facing, 32.0, 1.6, Color(1, 1, 1, 0.7), 0.12)
		_:
			pass


func _emit_run_dust(delta: float, fast: bool) -> void:
	if not is_on_floor():
		return
	_dust_timer -= delta
	if _dust_timer <= 0.0:
		_dust_timer = 0.14 if fast else 0.26
		Fx.dust(global_position + Vector2(-_facing * 10.0, -4.0), _facing, 3)
		if fast and _pu.has(PowerupConfig.Kind.SPEED):
			rig.ghost(Color(1.0, 0.85, 0.4, 0.5))


func _emit_wall_dust(delta: float) -> void:
	_dust_timer -= delta
	if _dust_timer <= 0.0:
		_dust_timer = 0.08
		Fx.dust(global_position + Vector2(_wall_dir * 22.0, -60.0), -_wall_dir, 2)


# --- Normal hareket (Görev 1) ---------------------------------------------

func _process_normal(delta: float) -> void:
	var input_dir := Input.get_axis(&"move_left", &"move_right")
	var wants_run := Input.is_action_pressed(&"run") or (TouchControls.active_on_device() and not is_zero_approx(input_dir))
	var wants_crouch := Input.is_action_pressed(&"crouch") and is_on_floor()

	# Saldırı başlatma girişi (buffer'lı — erken basış birkaç kare hafızada tutulur).
	if _attack_buffer > 0.0:
		_attack_buffer = 0.0
		if not is_on_floor() and Input.is_action_pressed(&"crouch") and Save.owns("ground_slam"):
			_start_attack(Attack.HEAVY, "ground_slam")
		elif not is_on_floor():
			_start_attack(Attack.AIR_KNEE)
		elif wants_crouch and Save.owns("low_kick"):
			_start_attack(Attack.HEAVY, "low_kick")
		elif Input.is_action_pressed(&"jump") and Save.owns("uppercut"):
			_start_attack(Attack.HEAVY, "uppercut")
		elif _weapon != null:
			_start_attack(Attack.WEAPON)
		else:
			_start_attack(Attack.COMBO)
		return
	if Input.is_action_just_pressed(&"heavy_attack") and is_on_floor():
		if _try_throw():
			return
		# Silah kuşanıkken de ağır yumruk atılır (silah kullanımını harcamaz).
		_start_attack(Attack.HEAVY)
		return

	# Çömelirken zıpla + aşağı = tek yön platformdan in.
	if wants_crouch and Input.is_action_just_pressed(&"jump"):
		_drop_through()
		return

	# Dash: özel tuş veya yön tuşuna çift basma.
	if _can_dash() and (Input.is_action_just_pressed(&"dash") or _double_tapped(input_dir)):
		_start_dash(input_dir)
		return

	_set_crouch(wants_crouch and is_zero_approx(input_dir))

	_update_timers(delta)
	_apply_gravity(delta)
	if _wall_lock > 0.0:
		# Duvar zıplaması sonrası kısa süre yatay kontrol kilitli.
		velocity.x = move_toward(velocity.x, 0.0, movement.air_acceleration * 0.3 * delta)
	elif _crouching:
		velocity.x = move_toward(velocity.x, 0.0, movement.friction * delta)
	else:
		_apply_horizontal(delta, input_dir, wants_run)
	_try_jump()
	# Değişken zıplama yüksekliği: yükselirken tuş bırakılınca dikey hızı kes.
	if _bouncing and (velocity.y >= 0.0 or is_on_floor()):
		_bouncing = false
	if Input.is_action_just_released(&"jump") and velocity.y < 0.0 and not is_on_floor() and not _bouncing:
		velocity.y *= movement.jump_cut
	_tick_gun(delta)

	# Duvar kayması: havada, düşerken, duvara dayalı ve duvara doğru basılıyken.
	var sliding := false
	if not is_on_floor() and velocity.y > 0.0 and is_on_wall_only():
		var wn := get_wall_normal().x
		if not is_zero_approx(input_dir) and signf(input_dir) == -signf(wn):
			_wall_dir = int(-signf(wn))
			velocity.y = minf(velocity.y, movement.wall_slide_speed)
			sliding = true
			if Input.is_action_just_pressed(&"jump"):
				_wall_jump()
				return

	_was_on_floor = is_on_floor()
	if not _was_on_floor:
		_land_impact = velocity.y
	move_and_slide()

	if not sliding:
		_update_facing(input_dir)
	if is_on_floor():
		_air_dashes_left = movement.air_dashes
	_update_state(input_dir, wants_run, sliding)
	_tick_footsteps(delta, wants_run)


# --- Parkur: dash / duvar / çömelme (Görev 15) --------------------------

func _can_dash() -> bool:
	if _dash_cd > 0.0:
		return false
	if is_on_floor():
		return true
	return _air_dashes_left > 0


func _double_tapped(input_dir: float) -> bool:
	if movement.double_tap_time <= 0.0 or is_zero_approx(input_dir):
		return false
	var d := 1 if input_dir > 0.0 else -1
	var now := _anim_t
	var hit := false
	if Input.is_action_just_pressed(&"move_left") or Input.is_action_just_pressed(&"move_right"):
		if _tap_dir == d and now - _tap_time <= movement.double_tap_time:
			hit = true
		_tap_dir = d
		_tap_time = now
	return hit


func _start_dash(input_dir: float) -> void:
	var d := _facing
	if not is_zero_approx(input_dir):
		d = 1 if input_dir > 0.0 else -1
	_facing = d
	_update_hitbox_side()
	_dash_timer = movement.dash_duration
	_dash_cd = movement.dash_cooldown + movement.dash_duration
	if not is_on_floor():
		_air_dashes_left -= 1
	if movement.dash_invuln > 0.0:
		_invuln_timer = maxf(_invuln_timer, movement.dash_invuln)
	velocity = Vector2(d * movement.dash_speed, 0.0)
	_set_crouch(false)
	_cancel_attack()
	_set_state(State.DASH)
	Sfx.play(&"jump", 1.4, -3.0)
	Fx.dust(global_position + Vector2(-d * 14.0, -4.0), d, 6)


func _process_dash(delta: float) -> void:
	if _attack_buffer > 0.0 and Save.owns("dash_strike"):
		_attack_buffer = 0.0
		_start_attack(Attack.HEAVY, "dash_strike")
		return
	_dash_timer -= delta
	_dust_timer -= delta
	if _dust_timer <= 0.0:
		_dust_timer = 0.035
		rig.ghost(Color(0.55, 0.8, 1.15, 0.55))
	velocity.y = 0.0
	_was_on_floor = is_on_floor()
	move_and_slide()
	if _dash_timer <= 0.0 or is_on_wall():
		velocity.x *= 0.35
		_set_state(State.FALL if not is_on_floor() else State.IDLE)


func _wall_jump() -> void:
	var away := -_wall_dir
	velocity = Vector2(away * movement.wall_jump_push, movement.jump_velocity)
	_facing = away
	_update_hitbox_side()
	_wall_lock = movement.wall_jump_lock
	_air_dashes_left = movement.air_dashes
	_set_state(State.JUMP)
	Sfx.play(&"jump", 1.1)
	Fx.dust(global_position + Vector2(_wall_dir * 20.0, -50.0), _wall_dir, 4)


## Tente / esnek yüzey sıçraması (AwningBounce çağırır). Zıplama tuşu basılıysa
## daha yükseğe fırlar; yatay hız korunur, havada atılma hakkı yenilenir.
func bounce(strength: float, boosted_strength: float) -> void:
	if _state == State.DEAD or _state == State.KNOCKDOWN:
		return
	velocity.y = -(boosted_strength if Input.is_action_pressed(&"jump") else strength)
	# Tente fırlatması zıplama tuşunu bırakınca kesilmez (kısa zıplama yalnız kendi zıplayışında).
	_bouncing = true
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_air_dashes_left = movement.air_dashes
	_set_state(State.JUMP)
	Sfx.play(&"jump", 0.75)
	Fx.dust(global_position + Vector2(0, -2), 0, 5)


func _drop_through() -> void:
	set_collision_mask_value(8, false)
	_drop_timer = 0.28
	position.y += 2.0
	velocity.y = maxf(velocity.y, 40.0)


func _set_crouch(on: bool) -> void:
	if on == _crouching:
		return
	_crouching = on
	var col := $CollisionShape2D
	if col.shape is RectangleShape2D:
		var s := col.shape as RectangleShape2D
		s.size.y = _body_full_h * (0.55 if on else 1.0)
		col.position.y = -s.size.y * 0.5
	if on:
		_set_state(State.CROUCH)


func _tick_footsteps(delta: float, wants_run: bool) -> void:
	var moving := is_on_floor() and absf(velocity.x) > movement.run_speed * 0.25
	if not moving:
		_step_timer = 0.0
		return
	_step_timer -= delta
	if _step_timer <= 0.0:
		_step_timer = 0.24 if wants_run else 0.34
		Sfx.play(&"step", 1.0, -6.0)


func _tick_gun(delta: float) -> void:
	if _gun == null:
		return
	_fire_cd = maxf(_fire_cd - delta, 0.0)

	if _reloading:
		_reload_timer -= delta
		if _reload_timer <= 0.0:
			_finish_reload()
		return

	if Input.is_action_just_pressed(&"fire"):
		if _mag > 0:
			_fire_gun()
		elif _reserve > 0:
			_start_reload()


func _fire_gun() -> void:
	if _fire_cd > 0.0:
		return
	_mag -= 1
	_fire_cd = _gun.fire_interval
	velocity.x -= _facing * _gun.recoil
	Projectile.spawn(
		get_tree().current_scene, _muzzle.global_position,
		Vector2(_facing, 0.0), _gun.projectile_speed,
		_gun_damage(), _gun.projectile_knockback, false, self,
	)
	Sfx.play(&"shoot")
	Combat.shake(2.5)
	_play(_gun.shoot_anim)
	ammo_changed.emit(_mag, _reserve, true)

	if _mag == 0:
		if _reserve > 0:
			_start_reload()
		else:
			_drop_gun()


func _start_reload() -> void:
	if _reserve <= 0 or _mag == _gun.mag_size:
		return
	_reloading = true
	_reload_timer = _gun.reload_time
	Sfx.play(&"reload")
	_play(&"reload")


func _finish_reload() -> void:
	_reloading = false
	var need := _gun.mag_size - _mag
	var take := mini(need, _reserve)
	_mag += take
	_reserve -= take
	ammo_changed.emit(_mag, _reserve, true)


## Yerden tabanca alınınca (WeaponPickup benzeri).
func equip_gun(cfg: GunConfig) -> void:
	if cfg == null:
		return
	_gun = cfg
	_mag = cfg.mag_size
	_reserve = int(roundf(float(cfg.starting_reserve) * _weapon_capacity_multiplier()))
	_reloading = false
	_fire_cd = 0.0
	ammo_changed.emit(_mag, _reserve, true)


## Cephane takviyesi (AmmoPickup).
func add_ammo(amount: int) -> void:
	if _gun == null:
		return
	_reserve += amount
	ammo_changed.emit(_mag, _reserve, true)


func _drop_gun() -> void:
	_gun = null
	_mag = 0
	_reserve = 0
	_reloading = false
	ammo_changed.emit(0, 0, false)


func has_gun() -> bool:
	return _gun != null


# --- Güçlendirme / zırh (Görev 8) --------------------------------------

func _tick_powerups(delta: float) -> void:
	if _pu.is_empty():
		return
	var expired := false
	for k in _pu.keys():
		_pu[k].left -= delta
		if _pu[k].left <= 0.0:
			_pu.erase(k)
			expired = true
	_emit_powerups()
	if expired:
		Sfx.play(&"powerup", 0.6)


func _emit_powerups() -> void:
	var arr: Array = []
	for k in _pu.keys():
		arr.append({
			"kind": k, "name": _pu[k].name,
			"left": _pu[k].left, "total": _pu[k].total,
		})
	powerups_changed.emit(arr)


## Yerden güçlendirme alınınca (PowerupPickup).
func apply_powerup(cfg: PowerupConfig) -> void:
	if cfg == null:
		return
	_pu[cfg.kind] = {
		"left": cfg.duration, "total": cfg.duration,
		"mag": cfg.magnitude, "name": cfg.display_name,
	}
	_emit_powerups()
	Sfx.play(&"powerup")


func equip_armor(cfg: ArmorConfig) -> void:
	if cfg == null:
		return
	_armor = cfg
	_armor_hp = cfg.durability
	armor_changed.emit(cfg.display_name, _armor_hp, cfg.durability)
	Sfx.play(&"powerup", 0.8)


func is_invisible() -> bool:
	return _pu.has(PowerupConfig.Kind.INVISIBILITY)


func _damage_mult() -> float:
	return _pu[PowerupConfig.Kind.DAMAGE_X2].mag if _pu.has(PowerupConfig.Kind.DAMAGE_X2) else 1.0


func _speed_mult() -> float:
	var m := 1.0
	if _pu.has(PowerupConfig.Kind.SPEED):
		m = _pu[PowerupConfig.Kind.SPEED].mag
	if _armor != null:
		m *= 1.0 - clampf(_armor.speed_penalty, 0.0, 0.9)
	return m


func _update_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = movement.coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer_timer = movement.jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

	if _land_timer > 0.0:
		_land_timer = maxf(_land_timer - delta, 0.0)


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	var g := movement.gravity
	if velocity.y > 0.0:
		g *= movement.fall_gravity_multiplier
	velocity.y = minf(velocity.y + g * delta, movement.max_fall_speed)


func _apply_horizontal(delta: float, input_dir: float, wants_run: bool) -> void:
	var target_speed := input_dir * (movement.run_speed if wants_run else movement.walk_speed) * _speed_mult()
	var rate: float
	if is_on_floor():
		rate = movement.acceleration if not is_zero_approx(input_dir) else movement.friction
	else:
		rate = movement.air_acceleration
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)


func _try_jump() -> void:
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		var grounded := is_on_floor()
		# Tentenin üstünde zıplamak normal zıplama değil, tam güç fırlatmadır
		# (aksi hâlde inişte basılan tuş fırlatmayı yutardı).
		var awning := _floor_awning() if grounded else null
		if awning != null:
			bounce(awning.strength, awning.boosted_strength)
			return
		velocity.y = movement.jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		Sfx.play(&"jump")
		if grounded:
			Fx.dust(global_position + Vector2(0, -2), 0, 4)


func _floor_awning() -> AwningBounce:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_normal().y < -0.7 and c.get_collider() is AwningBounce:
			return c.get_collider() as AwningBounce
	return null


func _update_facing(input_dir: float) -> void:
	if is_zero_approx(input_dir):
		return
	_facing = 1 if input_dir > 0.0 else -1
	_update_hitbox_side()


func _update_state(input_dir: float, wants_run: bool, sliding: bool = false) -> void:
	# Duvara basılı tutulduğunda istek hızı yüksek kalabilir; animasyonu gerçek
	# yer değiştirmeye bağla ki karakter koşu bandında gibi görünmesin.
	var moving := absf(get_real_velocity().x) > movement.move_threshold and not is_zero_approx(input_dir)

	if sliding:
		_set_state(State.WALLSLIDE)
		return

	if not is_on_floor():
		_set_state(State.JUMP if velocity.y < 0.0 else State.FALL)
		return

	if not _was_on_floor:
		_land_timer = movement.land_duration
		_set_state(State.LAND)
		Sfx.play(&"land")
		var hard: float = clampf(_land_impact / 780.0, 0.0, 1.6)  # 0..1.6
		Fx.dust(global_position + Vector2(0, -2), 0, int(5 + hard * 6))
		Combat.shake(1.2 + hard * 3.0)
		if hard > 0.6:
			Combat.dip(Vector2(0, 5.0 + hard * 5.0))
			Fx.ring(global_position + Vector2(0, -4), Color(0.8, 0.78, 0.7, 0.45), 5, 22 + hard * 16, 0.2, 2.0)
		return

	if _land_timer > 0.0:
		_set_state(State.LAND)
		return

	if _crouching:
		_set_state(State.CROUCH)
		return

	if moving:
		_set_state(State.RUN if wants_run else State.MOVE)
	else:
		_set_state(State.IDLE)


# --- Dövüş (Görev 2) -----------------------------------------------------

func _start_attack(kind: Attack, special_move: String = "") -> void:
	_set_crouch(false)
	_attack = kind
	_special_move = special_move
	_phase = Phase.WINDUP
	_queued_next = false
	_hit_this_swing.clear()
	_set_hitbox_enabled(false)
	_hitbox.position.y = -58.0

	if kind == Attack.COMBO:
		_apply_hitbox_profile(_punch_reach, _punch_offset)
		_phase_timer = _windup_time()
		_facing_to_input()
		velocity.x = _facing * combat.combo_step_forward
		_play("punch_%d" % (_combo_index + 1))
	elif kind == Attack.HEAVY:
		var reach := _punch_reach
		if special_move == "low_kick":
			reach = Vector2(112, 46)
			_hitbox.position.y = -28.0
		elif special_move == "uppercut":
			reach = Vector2(86, 132)
			_hitbox.position.y = -85.0
		elif special_move == "dash_strike":
			reach = Vector2(120, 98)
		_apply_hitbox_profile(reach, _punch_offset)
		_combo_index = 0
		_phase_timer = 0.10 if not special_move.is_empty() else combat.heavy_windup
		_facing_to_input()
		velocity.x = _facing * (360.0 if special_move == "dash_strike" else combat.heavy_step_forward)
		if special_move == "ground_slam":
			velocity.y = maxf(velocity.y, 780.0)
		_play(&"air_knee" if special_move == "ground_slam" else &"heavy")
	elif kind == Attack.WEAPON:
		_apply_hitbox_profile(_weapon.reach, _weapon.reach_offset)
		_combo_index = 0
		_phase_timer = _weapon.windup
		_facing_to_input()
		velocity.x = _facing * _weapon.step_forward
		_weapon_uses -= 1
		weapon_changed.emit(_weapon.display_name, _weapon_uses, _weapon_max_uses())
		_play(&"weapon_swing")
	else: # AIR_KNEE
		_apply_hitbox_profile(_punch_reach, _punch_offset)
		_combo_index = 0
		_phase_timer = combat.air_knee_windup
		_play(&"air_knee")

	Sfx.play(&"swing", 0.8 if kind == Attack.WEAPON else 1.0)
	_update_hitbox_side()
	_set_state(State.ATTACK)


## Saldırıya başlarken: basılı yön varsa ona dön; yoksa menzildeki en yakın
## düşmana otomatik dön (beat'em up "yüz yüze dövüş" hissi — Görev 25).
func _facing_to_input() -> void:
	var d := Input.get_axis(&"move_left", &"move_right")
	if not is_zero_approx(d):
		_facing = 1 if d > 0.0 else -1
		return
	var best_dx := 150.0
	var target_dir := 0
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		if not is_instance_valid(e):
			continue
		if e.has_method(&"is_dead") and e.is_dead():
			continue
		var ex: float = e.global_position.x - global_position.x
		if absf(e.global_position.y - global_position.y) > 90.0:
			continue
		if absf(ex) < best_dx and not is_zero_approx(ex):
			best_dx = absf(ex)
			target_dir = 1 if ex > 0.0 else -1
	if target_dir != 0:
		_facing = target_dir


func _process_attack(delta: float) -> void:
	if _special_move == "ground_slam":
		velocity.y = maxf(velocity.y, 780.0)
		move_and_slide()
		if is_on_floor():
			_slam_impact()
			_finish_attack()
		return
	# Combo zinciri girişi: temas/geri dönüş sırasında J -> sıradaki vuruş kuyruğa.
	if _attack == Attack.COMBO and _combo_index < _combo_limit() - 1:
		if Input.is_action_just_pressed(&"attack"):
			_queued_next = true

	# Geri dönüş fazında dash / zıplama saldırıyı iptal eder; kontrol akıcı kalır.
	if _phase == Phase.RECOVERY:
		if _can_dash() and Input.is_action_just_pressed(&"dash"):
			_cancel_attack()
			_start_dash(Input.get_axis(&"move_left", &"move_right"))
			return
		if Input.is_action_just_pressed(&"jump") and is_on_floor():
			_cancel_attack()
			_jump_buffer_timer = movement.jump_buffer_time
			_coyote_timer = movement.coyote_time
			_set_state(State.IDLE)
			return

	# Yatay: yerde sürtünmeyle dur, havada momentum korunur.
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, movement.friction * delta)
	_apply_gravity(delta)
	_was_on_floor = is_on_floor()
	move_and_slide()

	# Hava dizi inişte biter.
	if _attack == Attack.AIR_KNEE and _phase != Phase.WINDUP and is_on_floor():
		_finish_attack()
		return

	_phase_timer -= delta
	if _phase_timer > 0.0:
		return

	match _phase:
		Phase.WINDUP:
			_phase = Phase.ACTIVE
			_phase_timer = _active_time()
			_hit_this_swing.clear()
			_set_hitbox_enabled(_special_move != "throw")
			_spawn_attack_slash()
		Phase.ACTIVE:
			_phase = Phase.RECOVERY
			_phase_timer = _recovery_time()
			_set_hitbox_enabled(false)
		Phase.RECOVERY:
			_finish_attack()


func _finish_attack() -> void:
	_set_hitbox_enabled(false)

	if _attack == Attack.COMBO and _queued_next \
			and _combo_index < _combo_limit() - 1:
		_combo_index += 1
		_start_attack(Attack.COMBO)
		return

	var broke := _attack == Attack.WEAPON and _weapon_uses <= 0

	_attack = Attack.NONE
	_special_move = ""
	_combo_index = 0
	_queued_next = false

	if broke:
		_drop_weapon()
	# Bir sonraki normal karede _update_state doğru duruma geçirir.
	_set_state(State.FALL if not is_on_floor() else State.IDLE)


func _combo_limit() -> int:
	return combat.combo_damage.size() if Save.owns("combo_finish") else mini(2, combat.combo_damage.size())


func _try_throw() -> bool:
	var target := _find_throw_target()
	if target == null:
		return false
	var side := signf(target.global_position.x - global_position.x)
	if not is_zero_approx(side):
		_facing = int(side)
	_start_attack(Attack.HEAVY, "throw")
	target.throw_by(Vector2(_facing * 560.0, -360.0), int(roundf(16.0 * _melee_damage_multiplier())))
	Combat.hitstop(combat.hitstop_seconds * 1.7)
	Combat.shake(combat.shake_on_heavy)
	Combat.rumble(0.65)
	Combat.combo_hit()
	Sfx.play(&"heavy_hit")
	Fx.popup(target.global_position + Vector2(0, -85), "FIRLAT!", Color(1.0, 0.65, 0.2), 20)
	return true


func can_throw_nearby() -> bool:
	return _find_throw_target() != null


func _find_throw_target() -> Node2D:
	var target: Node2D
	var nearest := INF
	for enemy in get_tree().get_nodes_in_group(&"enemy_ai"):
		if not is_instance_valid(enemy) or not enemy.has_method(&"can_be_thrown") \
				or not enemy.can_be_thrown():
			continue
		var distance := global_position.distance_squared_to(enemy.global_position)
		if distance < nearest and distance <= 95.0 * 95.0:
			target = enemy
			nearest = distance
	return target


func _slam_impact() -> void:
	Combat.shake(8.0)
	Sfx.play(&"heavy_hit")
	Fx.ring(global_position, Color("e7a449"), 12.0, 125.0, 0.35)
	Fx.dust(global_position, _facing, 12)
	for target in get_tree().get_nodes_in_group(&"enemy_ai"):
		if not is_instance_valid(target) or not target.has_method(&"apply_hit"):
			continue
		if absf(target.global_position.x - global_position.x) > 125.0 \
				or absf(target.global_position.y - global_position.y) > 85.0:
			continue
		if target.has_method(&"break_guard"):
			target.break_guard()
		var push := 1.0 if target.global_position.x >= global_position.x else -1.0
		target.apply_hit(int(roundf(18.0 * _melee_damage_multiplier())), Vector2(push, 0.0), 300.0)


func _cancel_attack() -> void:
	_set_hitbox_enabled(false)
	_attack = Attack.NONE
	_special_move = ""
	_combo_index = 0
	_queued_next = false
	_hit_this_swing.clear()


func _active_time() -> float:
	match _attack:
		Attack.COMBO: return combat.combo_active[_combo_index]
		Attack.HEAVY: return combat.heavy_active
		Attack.WEAPON: return _weapon.active
		_: return combat.air_knee_active


func _recovery_time() -> float:
	match _attack:
		Attack.COMBO: return combat.combo_recovery[_combo_index] * _combo_time_multiplier()
		Attack.HEAVY: return combat.heavy_recovery
		Attack.WEAPON: return _weapon.recovery
		_: return combat.air_knee_recovery


func _current_damage() -> int:
	var damage := 0
	if _special_move == "low_kick": damage = 8
	elif _special_move == "uppercut": damage = 12
	elif _special_move == "dash_strike": damage = 14
	else:
		match _attack:
			Attack.COMBO: damage = combat.combo_damage[_combo_index]
			Attack.HEAVY: damage = combat.heavy_damage
			Attack.WEAPON: damage = _weapon.damage
			_: damage = combat.air_knee_damage
	if _attack == Attack.WEAPON:
		damage = int(roundf(float(damage) * _weapon_damage_multiplier()))
	else:
		damage = int(roundf(float(damage) * _melee_damage_multiplier()))
	if _attack == Attack.COMBO and _combo_index >= 2:
		damage = int(roundf(float(damage) * _finisher_damage_multiplier()))
	return damage


func _melee_damage_multiplier() -> float:
	return 1.0 + 0.12 * float(Save.upgrade_level("fist_power"))


func _finisher_damage_multiplier() -> float:
	return 1.0 + 0.25 * float(Save.upgrade_level("finisher_power"))


func _combo_time_multiplier() -> float:
	return 1.0 - 0.06 * float(Save.upgrade_level("combo_speed"))


func _weapon_capacity_multiplier() -> float:
	return 1.0 + 0.20 * float(Save.upgrade_level("weapon_capacity"))


func _weapon_damage_multiplier() -> float:
	return 1.0 + 0.15 * float(Save.upgrade_level("weapon_power"))


func _firearm_damage_multiplier() -> float:
	return 1.0 + 0.15 * float(Save.upgrade_level("firearm_power"))


func _gun_damage() -> int:
	return int(roundf(float(_gun.damage) * _damage_mult() * _firearm_damage_multiplier()))


func _weapon_max_uses() -> int:
	return maxi(1, int(roundf(float(_weapon.durability) * _weapon_capacity_multiplier())))


func _current_knockback() -> float:
	if _special_move == "low_kick": return 230.0
	if _special_move == "uppercut": return 180.0
	if _special_move == "dash_strike": return 320.0
	match _attack:
		Attack.COMBO: return combat.combo_knockback[_combo_index]
		Attack.HEAVY: return combat.heavy_knockback
		Attack.WEAPON: return _weapon.knockback
		_: return combat.air_knee_knockback


func _set_hitbox_enabled(on: bool) -> void:
	# Fizik sorgusu sırasında doğrudan değiştirmek hata verebilir -> deferred.
	_hitbox.set_deferred(&"monitoring", on)
	_hitbox_shape.set_deferred(&"disabled", not on)


func _update_hitbox_side() -> void:
	_hitbox.position.x = absf(_hitbox.position.x) * _facing
	_muzzle.position.x = _muzzle_offset * _facing


func _on_hitbox_area_entered(area: Area2D) -> void:
	var target := _resolve_owner(area)
	if target == null or target == self or target in _hit_this_swing:
		return
	if not target.has_method(&"apply_hit"):
		return
	_deal_attack_hit(target)


## Bıçaklı ajanın aktif dash hitbox'ı ile aktif yumruk aynı anda buluşursa
## oyuncunun zamanlaması kazanır. Bu yalnız o dash'i bozar; AI cooldown sonrası
## aynı saldırıyı yeniden deneyebilir.
func is_punch_counter_active() -> bool:
	return _state == State.ATTACK and _attack == Attack.COMBO and _phase == Phase.ACTIVE


func land_dash_counter(target: Node) -> void:
	if not is_punch_counter_active() or target == null:
		return
	_deal_attack_hit(target, true)


func _deal_attack_hit(target: Node, dash_counter := false) -> void:
	if target in _hit_this_swing or not target.has_method(&"apply_hit"):
		return
	_hit_this_swing.append(target)

	var finisher := _attack == Attack.COMBO and _combo_index >= 2
	var juggle: bool = _attack == Attack.AIR_KNEE and target.has_method(&"can_be_juggled") \
		and target.can_be_juggled()
	var heavy: bool = _attack == Attack.HEAVY or _attack == Attack.WEAPON or finisher or juggle
	var dmg := int(roundf(_current_damage() * _damage_mult()))
	target.apply_hit(dmg, Vector2(_facing, 0.0), _current_knockback())
	if target.has_method(&"launch"):
		if juggle:
			target.launch(340.0)
			velocity.y = -250.0
		elif _special_move == "uppercut":
			target.launch(430.0)
		elif finisher:
			target.launch(260.0)

	# Ağırlık hissi: hitstop hasarla ölçeklenir, ağır darbede zoom + parlama.
	Combat.hitstop(combat.hitstop_seconds * (1.7 if heavy else 1.0))
	Combat.shake(6.0 if dash_counter else (combat.shake_on_heavy if heavy else combat.shake_on_hit))
	Combat.rumble(0.55 if heavy else 0.18)
	Combat.combo_hit()
	if heavy:
		Combat.zoom_punch(0.045)
		Combat.flash(Color(1, 1, 1, 0.42), 0.07)
		Combat.dip(Vector2(_facing * 4.0, 0.0))
	Sfx.play(&"heavy_hit" if heavy else &"hit")

	var impact := Vector2(global_position.x + _facing * 30.0, global_position.y - 60.0)
	Fx.spark(impact, Vector2(_facing, -0.2), 12 if heavy else 7,
		Color(1, 0.85, 0.4) if not heavy else Color(1, 0.6, 0.3), 1.7 if heavy else 1.0)
	var boosted := _damage_mult() > 1.0
	Fx.popup(impact + Vector2(0, -16), str(dmg), Color(1, 0.4, 0.35) if boosted else Color(1, 0.95, 0.7))
	if finisher:
		Fx.popup(impact + Vector2(0, -42), "BİTİRİCİ!", Color(1.0, 0.65, 0.2), 20)
	if juggle:
		Fx.popup(impact + Vector2(0, -42), "HAVA TAKİBİ!", Color(0.45, 0.85, 1.0), 20)
	if dash_counter:
		Fx.popup(impact + Vector2(0, -42), "KARŞILIK!", Color(0.3, 0.95, 0.85), 20)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if _state == State.DEAD or _invuln_timer > 0.0:
		return
	var src := _resolve_owner(area)
	var damage := 8
	if src != null and src.has_method(&"get_contact_damage"):
		damage = src.get_contact_damage()
	var dir_x := 1.0
	if src != null:
		dir_x = signf(global_position.x - src.global_position.x)
		if is_zero_approx(dir_x):
			dir_x = -_facing
	apply_hit(damage, Vector2(dir_x, 0.0), combat.knockback_from_hit)


## Düşman (veya test kaynağı) Redmount'a vurunca çağırır. Enemy'lerle simetrik
## imza: apply_hit(damage, dir, knockback).
func apply_hit(damage: int, dir: Vector2, _knockback: float) -> void:
	if _state == State.DEAD or _invuln_timer > 0.0:
		return

	# Kalkan: bir sonraki darbeyi tamamen engeller (tek kullanımlık).
	if _pu.has(PowerupConfig.Kind.SHIELD):
		_pu.erase(PowerupConfig.Kind.SHIELD)
		_emit_powerups()
		_invuln_timer = combat.invuln_after_hit
		Sfx.play(&"shield")
		Combat.shake(4.0)
		return

	# Zırh: hasarı azalt + dayanıklılık düş; bitince kırılır.
	if _armor != null:
		damage = maxi(1, int(ceil(damage * (1.0 - clampf(_armor.damage_reduction, 0.0, 0.95)))))
		_armor_hp -= 1
		if _armor_hp <= 0:
			_armor = null
			armor_changed.emit("", 0, 0)
			Sfx.play(&"armor_break")
		else:
			armor_changed.emit(_armor.display_name, _armor_hp, _armor.durability)

	_health = maxi(_health - damage, 0)
	health_changed.emit(_health, get_max_health())
	_invuln_timer = combat.invuln_after_hit
	_cancel_attack()
	_set_crouch(false)
	_dash_timer = 0.0
	Combat.combo_break()

	var push_dir := signf(dir.x) if not is_zero_approx(dir.x) else float(-_facing)
	# Vurulunca saldırgana dön (sırtı dönük kalmasın — Görev 25).
	if not is_zero_approx(push_dir):
		_facing = int(-signf(push_dir))
		_update_hitbox_side()
	Fx.spark(global_position + Vector2(0, -60), Vector2(push_dir, -0.4), 8, Color(1, 0.5, 0.45))

	if _health == 0:
		velocity = Vector2(push_dir * 230.0, -270.0)  # teatral savrulma
		Combat.hitstop(0.09)
		Combat.shake(7.0)
		Combat.flash(Color(0.9, 0.1, 0.1, 0.4), 0.18)
		Fx.spark(global_position + Vector2(0, -60), Vector2(push_dir, -0.5), 16, Color(1, 0.4, 0.35), 1.6)
		if _weapon != null:
			_weapon = null
			_weapon_uses = 0
			weapon_changed.emit("", 0, 0)
		if _gun != null:
			_drop_gun()
		if not _pu.is_empty():
			_pu.clear()
			_emit_powerups()
		if _armor != null:
			_armor = null
			armor_changed.emit("", 0, 0)
		_set_state(State.DEAD)
		_play(&"dead")
		Sfx.play(&"player_death")
		died.emit()
		return

	var heavy := damage >= combat.knockdown_damage_threshold
	velocity.x = push_dir * combat.knockback_from_hit * (1.6 if heavy else 1.0)
	velocity.y = combat.knockback_up_from_hit

	if heavy:
		_knockdown_timer = combat.knockdown_duration
		_getup_timer = combat.getup_duration
		_getting_up = false
		_set_state(State.KNOCKDOWN)
	else:
		_hurt_timer = combat.hit_light_duration
		_set_state(State.HURT)

	Combat.hitstop(combat.hitstop_seconds)
	Combat.shake(combat.shake_on_heavy if heavy else combat.shake_on_hit)
	Combat.rumble(0.75 if heavy else 0.4)
	Sfx.play(&"player_hurt")


func _process_stagger(delta: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, movement.friction * delta)
	_apply_gravity(delta)
	_was_on_floor = is_on_floor()
	move_and_slide()

	if _state == State.HURT:
		_hurt_timer -= delta
		if _hurt_timer <= 0.0:
			_set_state(State.IDLE)
		return

	# KNOCKDOWN -> (yere değince) getup -> normal
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
		_set_state(State.IDLE)


func _process_dead(delta: float) -> void:
	# Görsel yatma/savrulma char_rig DEAD pozunda; burada sadece fizik.
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, movement.friction * delta * 0.5)
	_apply_gravity(delta)
	move_and_slide()


## Main, spawn'a döndürürken çağırır (R tuşu / düşme).
func revive() -> void:
	_health = get_max_health()
	health_changed.emit(_health, get_max_health())
	_invuln_timer = 0.0
	_hurt_timer = 0.0
	_knockdown_timer = 0.0
	_getup_timer = 0.0
	_getting_up = false
	_reloading = false
	_fire_cd = 0.0
	_cancel_attack()
	_set_crouch(false)
	_dash_timer = 0.0
	_dash_cd = 0.0
	_wall_lock = 0.0
	_drop_timer = 0.0
	_attack_buffer = 0.0
	_air_dashes_left = movement.air_dashes
	set_collision_mask_value(8, true)
	if _weapon != null:
		_drop_weapon(false)
	if _gun != null:
		_drop_gun()
	_armor = null
	_armor_hp = 0
	armor_changed.emit("", 0, 0)
	_apply_hitbox_profile(_punch_reach, _punch_offset)
	velocity = Vector2.ZERO
	_last_safe_position = global_position
	rig.visible = true
	rig.modulate = Color.WHITE
	rig.self_modulate = Color.WHITE
	if rig.has_method(&"reset_visual_state"):
		rig.reset_visual_state()
	weapon_changed.emit(
		_weapon.display_name if _weapon != null else "",
		_weapon_uses,
		_weapon.durability if _weapon != null else 0,
	)
	ammo_changed.emit(_mag, _reserve, _gun != null)
	_emit_powerups()
	armor_changed.emit(
		_armor.display_name if _armor != null else "",
		_armor_hp, _armor.durability if _armor != null else 0,
	)
	_set_state(State.IDLE)


func _recover_invalid_motion() -> void:
	global_position = _last_safe_position
	velocity = Vector2.ZERO
	_cancel_attack()
	_set_crouch(false)
	_set_state(State.IDLE)
	var camera := get_node_or_null(^"Camera2D") as Camera2D
	if camera != null:
		camera.offset = Vector2.ZERO
		camera.reset_smoothing()


# --- Yardımcılar ---------------------------------------------------------

func _update_invuln_flash() -> void:
	if _state == State.DEAD:
		return
	var base_a := 0.4 if is_invisible() else 1.0
	if _invuln_timer > 0.0:
		# ~20 Hz yanıp sönme (görünmezlik tabanının üstünde).
		rig.modulate.a = base_a * 0.4 if int(_invuln_timer * 20.0) % 2 == 0 else base_a
	elif not is_equal_approx(rig.modulate.a, base_a):
		rig.modulate.a = base_a


## Area2D -> ait olduğu ana düğüm (Hurtbox/Hitbox alt düğüm olabilir).
func _resolve_owner(area: Area2D) -> Node:
	if area.owner != null:
		return area.owner
	return area.get_parent()


func _set_state(new_state: State) -> void:
	if new_state == _state:
		return
	_state = new_state
	# Görsel = char_rig (durum-güdümlü); ayrı "anim oynat" gerekmez.


func _apply_hitbox_profile(reach: Vector2, offset: float) -> void:
	if _hitbox_shape.shape is RectangleShape2D:
		(_hitbox_shape.shape as RectangleShape2D).size = reach
	_hitbox.position.x = offset * _facing


# --- Silah / iyileşme (Görev 4) ----------------------------------------

## Yerden silah alınınca çağrılır (WeaponPickup).
func equip_weapon(cfg: WeaponConfig) -> void:
	if cfg == null:
		return
	_cancel_attack()
	_weapon = cfg
	_weapon_uses = _weapon_max_uses()
	weapon_changed.emit(cfg.display_name, _weapon_uses, _weapon_max_uses())
	Fx.ring(global_position + Vector2(0, -58), Color(1, 0.9, 0.5), 5, 24, 0.25)


func _drop_weapon(play_break_sound := true) -> void:
	_weapon = null
	_weapon_uses = 0
	_apply_hitbox_profile(_punch_reach, _punch_offset)
	weapon_changed.emit("", 0, 0)
	if play_break_sound:
		Sfx.play(&"weapon_break")


func select_fists() -> void:
	if _weapon != null:
		_drop_weapon(false)


## Can takviyesi (HealthPickup).
func heal(amount: int) -> void:
	if _state == State.DEAD:
		return
	_health = mini(_health + amount, get_max_health())
	health_changed.emit(_health, get_max_health())
	Sfx.play(&"heal")


func has_weapon() -> bool:
	return _weapon != null


func _play(anim: StringName) -> void:
	if rig.has_method(&"play_action"):
		var duration := 0.18
		if anim == &"reload" and _gun != null:
			duration = _gun.reload_time
		rig.play_action(anim, duration)


## Dışarıdan okunabilir durum adı (debug / HUD için).
func get_state_name() -> String:
	if _state == State.ATTACK:
		var kind: String = Attack.keys()[_attack]
		if _attack == Attack.COMBO:
			kind = "COMBO%d" % (_combo_index + 1)
		return "ATTACK:%s:%s" % [kind, Phase.keys()[_phase]]
	return State.keys()[_state]


func get_health() -> int:
	return _health


func get_max_health() -> int:
	return combat.max_health + _bonus_health


## Mağaza "sağlam gövde" yükseltmesi — azami cana eklenir (Görev 14).
func set_bonus_health(amount: int) -> void:
	_bonus_health = maxi(amount, 0)
	if _health > 0:
		_health = mini(_health, get_max_health())
		health_changed.emit(_health, get_max_health())


## Main, bölüm yüklerken kamerayı bölüm sınırlarına kilitler (Görev 11).
func set_camera_limits(left: int, top: int, right: int, bottom: int) -> void:
	var cam := $Camera2D
	cam.limit_left = left
	cam.limit_top = top
	cam.limit_right = right
	cam.limit_bottom = bottom
	cam.reset_smoothing()
