## Player — Redmount. Dan the Man tarzı: hızlı koşu, değişken zıplama, duvar zıplaması,
## 4 vuruşluk kombo, uçan tekme (isabette sekip tekrar), ÖZEL (uçan diz), sopa ve tabanca.
## Düşmana doğru yürü = TUT (VUR diz · ZIPLA aparkat · geri+VUR fırlat);
## VUR basılı tut = GÜÇLÜ YUMRUK (dolum süresiyle güçlenir).
## Tabanca ayrı ATEŞ düğmesiyle sıkılır; silah elindeyken de yumruk atılır (Dan the Man düzeni).
class_name Player
extends CharacterBody2D

enum S { MOVE, ATTACK, AIR_ATTACK, SPECIAL, HURT, DEAD, GRAB, CHARGE, UPPER }

const RUN := 560.0
const ACCEL := 5200.0
const FRICTION := 4800.0
const AIR_ACCEL := 3400.0
const GRAVITY := 2800.0
const FALL_MULT := 1.4
const JUMP_V := 1180.0
const JUMP_CUT := 0.45
const MAX_FALL := 1600.0
const COYOTE := 0.1
const BUFFER := 0.13
const WALL_SLIDE := 240.0
const WALL_JUMP := Vector2(380, -1100)
const BODY := Vector2(56, 176)
const GRAB_RANGE := 105.0 ## Bu mesafede düşmana doğru yürümek onu tutar.
const GRAB_PUSH := 0.08 ## Yanlışlıkla tutmamak için kısa dayanma süresi.
const GRAB_TIME := 1.3 ## Bu süre sonunda tutulan düşman kurtulur.
const CHARGE_START := 0.4 ## VUR bu kadar basılı kalınca dolum başlar.
const CHARGE_FULL := 0.6 ## Dolumun tamamlanma süresi.
const AIR_CHAIN := 2 ## İsabetli uçan tekmeden sonra en fazla bu kadar ek tekme.

const ANIMS := {
	"idle": ["idle", 7, true], "run": ["run", 17, true],
	"jump": ["jump", 14, false, [1, 2]], "fall": ["jump", 8, true, [3]],
	"land": ["jump", 24, false, [4]], "crouch": ["crouch", 14, false, [0]],
	"wall": ["jump", 8, true, [4]], "hurt": ["crouch", 8, false, [1]],
	"dead": ["crouch", 8, false, [0]],
	"hit1": ["fight", 22, false], "hit2": ["combo_a", 26, false],
	"hit3": ["punch", 28, false], "hit4": ["knee", 17, false],
	"airkick": ["airknee", 14, false, [1, 2, 3]], "special": ["knee", 14, false, [1, 2, 3, 3, 3]],
	"bat_idle": ["bat_idle", 7, true], "bat_run": ["bat_walk", 20, true],
	"bat1": ["bat_attack", 24, false], "bat2": ["bat_attack2", 22, false],
	"pistol_idle": ["pistol_idle", 7, true], "pistol_run": ["pistol_walk", 20, true],
	"pistol_shoot": ["pistol_shoot", 18, false],
	# Tutma / güçlü yumruk: özel şeritler çizilene kadar mevcut karelerden kurulur.
	"grab": ["fight", 8, true, [1]], "grab_knee": ["knee", 20, false, [1, 2, 3, 3, 1]],
	"throw": ["combo_a", 18, false, [2, 3, 3, 4]], "uppercut": ["punch", 16, false, [2, 3, 3, 3]],
	"charge": ["fight", 5, true, [0, 1]], "power": ["punch", 20, false, [1, 1, 2, 3, 3, 4, 5]],
}

## Saldırı tanımları: aktif kareler, hasar, menzil, geri itme, zincire geçiş karesi.
const ATTACKS := {
	"hit1": {"active": [2], "dmg": 8, "reach": 150, "kb": 140, "chain": 2, "lunge": 90},
	"hit2": {"active": [3], "dmg": 9, "reach": 150, "kb": 150, "chain": 3, "lunge": 110},
	"hit3": {"active": [2], "dmg": 11, "reach": 160, "kb": 170, "chain": 3, "lunge": 120},
	"hit4": {"active": [2, 3], "dmg": 18, "reach": 150, "kb": 520, "chain": 99, "lunge": 260, "down": true},
	"bat1": {"active": [3, 4], "dmg": 22, "reach": 200, "kb": 300, "chain": 5, "lunge": 120},
	"bat2": {"active": [4], "dmg": 30, "reach": 210, "kb": 560, "chain": 99, "lunge": 140, "down": true},
	"power": {"active": [2], "dmg": 24, "reach": 190, "kb": 640, "chain": 99, "lunge": 380, "down": true},
}
const COMBO := ["hit1", "hit2", "hit3", "hit4"]

var level: Node
var state: S = S.MOVE
var facing := 1
var max_hp := 100
var hp := 100
var meter := 0.0 ## 0..100, ÖZEL 50 harcar.
var weapon := "" ## "", "bat", "pistol"
var weapon_uses := 0
var controls_enabled := true

var _coyote := 0.0
var _buffer := 0.0
var _attack_buffer := 0.0
var _shoot_buffer := 0.0
var _invuln := 0.0
var _state_t := 0.0
var _input_lock := 0.0
var _drop_t := 0.0
var _combo_i := 0
var _combo_gap := 0.0
var _air_kick_used := false
var _cur_attack := ""
var _hit_done: Dictionary = {}
var _was_on_floor := true
var _wall_dir := 0
var _wall_grace := 0.0
var _safe_pos := Vector2.ZERO
var _safe_t := 0.0
var _step_t := 0.0
var _rising := false
var _air_chain := 0
var _grab: Enemy = null
var _grab_hits := 0
var _push_t := 0.0
var _hold_t := 0.0
var _charge := 0.0

@onready var sprite: AnimatedSprite2D = SpriteLib.make_sprite("redmount", ANIMS)


func _ready() -> void:
	add_to_group("player")
	collision_layer = Game.L_PLAYER
	collision_mask = Game.L_WORLD | Game.L_ONEWAY | Game.L_ARENA
	floor_snap_length = 12.0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = BODY
	shape.shape = rect
	shape.position = Vector2(0, -BODY.y / 2)
	add_child(shape)
	add_child(sprite)
	sprite.frame_changed.connect(_on_frame)
	sprite.animation_finished.connect(_on_anim_done)
	sprite.play("idle")
	_safe_pos = position


func hurt_rect() -> Rect2:
	return Rect2(position.x - BODY.x / 2, position.y - BODY.y, BODY.x, BODY.y)


func is_invulnerable() -> bool:
	return _invuln > 0.0 or state == S.SPECIAL or state == S.DEAD


# --- Ana döngü --------------------------------------------------------------

func _physics_process(dt: float) -> void:
	_tick(dt)
	var dir := 0.0
	if _input_lock <= 0.0 and state != S.DEAD:
		dir = Input.get_axis("left", "right")
	var on_floor := is_on_floor()
	if on_floor:
		_coyote = COYOTE
		_air_kick_used = false
		_air_chain = 0
	if Input.is_action_just_pressed("jump"):
		_buffer = BUFFER
	if Input.is_action_just_pressed("attack"):
		_attack_buffer = 0.2
	if Input.is_action_just_pressed("shoot"):
		_shoot_buffer = 0.2
	if not controls_enabled:
		dir = 0.0
		_buffer = 0.0
		_attack_buffer = 0.0
		_shoot_buffer = 0.0
	if Input.is_action_pressed("attack") and controls_enabled:
		_hold_t += dt
	else:
		if state == S.CHARGE:
			_release_charge(controls_enabled)
		_hold_t = 0.0

	match state:
		S.MOVE:
			_move(dir, on_floor, dt)
		S.ATTACK:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * 0.6 * dt)
			if _attack_buffer > 0.0 and sprite.frame >= _chain_frame():
				_next_attack()
		S.AIR_ATTACK:
			if on_floor:
				velocity.x *= 0.3
				_set_state(S.MOVE)
				sprite.play("land")
				Fx.dust(level.fx_layer, position)
		S.SPECIAL:
			_special_tick()
		S.HURT:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * 0.5 * dt)
			if _state_t > 0.32 and on_floor:
				_set_state(S.MOVE)
		S.DEAD:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * 0.3 * dt)
		S.GRAB:
			_grab_tick(dir)
		S.CHARGE:
			_charge_tick(dir, dt)
		S.UPPER:
			if _state_t > 0.3:
				_set_state(S.MOVE)

	# Yerçekimi (tepe noktasında hafif süzülme, düşerken daha ağır).
	if state != S.SPECIAL:
		var g := GRAVITY * (FALL_MULT if velocity.y > 0.0 else 1.0)
		if absf(velocity.y) < 120.0 and Input.is_action_pressed("jump"):
			g *= 0.6
		velocity.y = minf(velocity.y + g * dt, MAX_FALL)
		if _wall_dir != 0 and velocity.y > WALL_SLIDE and state == S.MOVE:
			velocity.y = WALL_SLIDE

	move_and_slide()
	_after_move(dt)


func _tick(dt: float) -> void:
	_state_t += dt
	_coyote -= dt
	_buffer -= dt
	_attack_buffer -= dt
	_shoot_buffer -= dt
	_input_lock -= dt
	_wall_grace -= dt
	_combo_gap -= dt
	if _invuln > 0.0:
		_invuln -= dt
		sprite.visible = fmod(_invuln, 0.12) > 0.05 or state == S.SPECIAL
		if _invuln <= 0.0:
			sprite.visible = true
	if _drop_t > 0.0:
		_drop_t -= dt
		if _drop_t <= 0.0:
			collision_mask |= Game.L_ONEWAY


func _move(dir: float, on_floor: bool, dt: float) -> void:
	var accel := ACCEL if on_floor else AIR_ACCEL
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * RUN, accel * dt)
		facing = 1 if dir > 0.0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0.0, (FRICTION if on_floor else AIR_ACCEL * 0.5) * dt)

	# Duvar kayması: havada, duvara doğru basarken.
	_wall_dir = 0
	if not on_floor and is_on_wall() and velocity.y > 0.0:
		var n := get_wall_normal()
		if dir != 0.0 and signf(dir) == -signf(n.x):
			_wall_dir = int(-signf(n.x))
			_wall_grace = 0.12
			facing = -_wall_dir

	# Aşağı + zıpla: tek yönlü platformdan in.
	if _buffer > 0.0 and on_floor and Input.is_action_pressed("down") and _on_oneway():
		_buffer = 0.0
		collision_mask &= ~Game.L_ONEWAY
		_drop_t = 0.25
		position.y += 4
	elif _buffer > 0.0 and (_coyote > 0.0):
		_jump()
	elif _buffer > 0.0 and _wall_grace > 0.0 and not on_floor:
		_buffer = 0.0
		_wall_grace = 0.0
		var away := facing
		velocity = Vector2(away * WALL_JUMP.x, WALL_JUMP.y)
		_rising = true
		_input_lock = 0.1
		Sfx.play("jump", 1.15)
		Fx.dust(level.fx_layer, position + Vector2(-away * 30, -80), 0.8)

	# Değişken zıplama: yükselirken tuş bırakıldıysa bir kez kes.
	if _rising:
		if velocity.y >= 0.0:
			_rising = false
		elif not Input.is_action_pressed("jump"):
			velocity.y *= JUMP_CUT
			_rising = false

	if _shoot_buffer > 0.0 and weapon == "pistol":
		_shoot_buffer = 0.0
		_attack_buffer = 0.0
		_start_attack("pistol_shoot")
	elif _attack_buffer > 0.0:
		_attack_buffer = 0.0
		if on_floor:
			_next_attack()
		elif not _air_kick_used:
			_air_kick()
	elif Input.is_action_just_pressed("special") and controls_enabled:
		_try_special()

	if state == S.MOVE and on_floor and weapon != "bat" and _hold_t >= CHARGE_START:
		_start_charge()
	elif state == S.MOVE and on_floor and dir != 0.0:
		var e := _grab_candidate()
		_push_t = _push_t + dt if e != null else 0.0
		if e != null and _push_t >= GRAB_PUSH:
			_start_grab(e)
	else:
		_push_t = 0.0

	if state == S.MOVE:
		_anim_move(on_floor, dir)


func _jump() -> void:
	_buffer = 0.0
	_coyote = 0.0
	velocity.y = -JUMP_V
	_rising = true
	Sfx.play("jump")
	Fx.dust(level.fx_layer, position, 0.8)
	sprite.play("jump")


func _anim_move(on_floor: bool, dir: float) -> void:
	sprite.flip_h = facing < 0
	var pre := "" if weapon == "" else weapon + "_"
	if on_floor:
		if sprite.animation == "land" and sprite.is_playing():
			return
		if absf(velocity.x) > 40.0 or dir != 0.0:
			_play(pre + "run" if pre != "" else "run")
		elif Input.is_action_pressed("down") and weapon == "":
			_play("crouch")
		else:
			_play(pre + "idle" if pre != "" else "idle")
	else:
		if _wall_dir != 0:
			_play("wall")
		elif velocity.y < 0.0:
			if sprite.animation != "jump":
				_play("jump")
		else:
			_play("fall")


func _play(a: String) -> void:
	if sprite.animation != a:
		sprite.play(a)


func _after_move(dt: float) -> void:
	var on_floor := is_on_floor()
	if on_floor and not _was_on_floor and state == S.MOVE:
		sprite.play("land")
		Sfx.play("land")
		Fx.dust(level.fx_layer, position, 0.6)
	_was_on_floor = on_floor
	if on_floor and absf(velocity.x) > 200.0 and state == S.MOVE:
		_step_t -= dt
		if _step_t <= 0.0:
			_step_t = 0.26
			Sfx.play("step")
	# Güvenli zemin kaydı (çukura düşünce buraya dönülür).
	if on_floor and state == S.MOVE:
		_safe_t += dt
		if _safe_t > 0.25 and _ground_under(-50) and _ground_under(50):
			_safe_pos = position
	else:
		_safe_t = 0.0
	if position.y > level.kill_y and state != S.DEAD:
		_fell_in_pit()


func _ground_under(dx: float) -> bool:
	var q := PhysicsRayQueryParameters2D.create(position + Vector2(dx, -10), position + Vector2(dx, 30), Game.L_WORLD | Game.L_ONEWAY)
	return not get_world_2d().direct_space_state.intersect_ray(q).is_empty()


func _on_oneway() -> bool:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var o := c.get_collider()
		if o is CollisionObject2D and (o.collision_layer & Game.L_ONEWAY) and c.get_normal().y < -0.5:
			return true
	return false


func _fell_in_pit() -> void:
	take_hit(20, position.x, false, true)
	if state != S.DEAD:
		position = _safe_pos
		velocity = Vector2.ZERO
		_invuln = 1.2
		level.snap_camera()


# --- Saldırı ----------------------------------------------------------------

func _next_attack() -> void:
	_attack_buffer = 0.0
	if weapon == "bat":
		var a := "bat2" if _cur_attack == "bat1" and state == S.ATTACK else "bat1"
		_start_attack(a)
		return
	if _combo_gap <= 0.0 and state != S.ATTACK:
		_combo_i = 0
	var a2: String = COMBO[_combo_i % COMBO.size()]
	_combo_i = (_combo_i + 1) % COMBO.size()
	_start_attack(a2)


func _chain_frame() -> int:
	return int(ATTACKS.get(_cur_attack, {}).get("chain", 99))


func _start_attack(a: String) -> void:
	var dir := Input.get_axis("left", "right")
	if dir != 0.0:
		facing = 1 if dir > 0.0 else -1
	sprite.flip_h = facing < 0
	_cur_attack = a
	_hit_done.clear()
	_set_state(S.ATTACK)
	sprite.play(a)
	var def: Dictionary = ATTACKS.get(a, {})
	velocity.x = facing * float(def.get("lunge", 0.0))
	if a != "pistol_shoot":
		Sfx.play("swing", 1.0 + _combo_i * 0.06)


func _air_kick() -> void:
	_air_kick_used = true
	_cur_attack = "air"
	_hit_done.clear()
	_set_state(S.AIR_ATTACK)
	sprite.play("airkick")
	velocity = Vector2(facing * 700.0, maxf(velocity.y, 120.0) * 0.5 + 260.0)
	Sfx.play("dash", 1.1)


func _try_special() -> void:
	if meter < 50.0:
		Fx.text(level.fx_layer, position + Vector2(0, -230), "ÖZEL DOLMADI", Color(0.6, 0.8, 1), 0.7)
		return
	meter -= 50.0
	_cur_attack = "special"
	_hit_done.clear()
	_set_state(S.SPECIAL)
	sprite.play("special")
	velocity = Vector2(facing * 1300.0, -120.0)
	Sfx.play("powerup", 1.2)
	Fx.ring(level.fx_layer, position + Vector2(0, -100), Color(0.4, 0.8, 1), 1.2)
	level.shake(10.0)


func _special_tick() -> void:
	velocity.y = 0.0 if _state_t < 0.28 else velocity.y + GRAVITY * get_physics_process_delta_time()
	if int(_state_t * 60.0) % 3 == 0:
		_ghost()
	_resolve_hits(Rect2(position.x - 90, position.y - 190, 180, 190), 30, 700, true, "special")
	if _state_t > 0.34:
		velocity.x *= 0.25
		_set_state(S.MOVE)


func _ghost() -> void:
	var g := Sprite2D.new()
	g.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	g.flip_h = sprite.flip_h
	g.offset = sprite.offset
	g.position = position
	g.modulate = Color(0.4, 0.8, 1.0, 0.6)
	g.z_index = -1
	level.fx_layer.add_child(g)
	var tw := g.create_tween()
	tw.tween_property(g, "modulate:a", 0.0, 0.22)
	tw.tween_callback(g.queue_free)


func _on_frame() -> void:
	if state == S.ATTACK:
		if _cur_attack == "pistol_shoot":
			if sprite.frame == 3:
				_fire()
			return
		var def: Dictionary = ATTACKS.get(_cur_attack, {})
		if sprite.frame in def.get("active", []):
			var reach := float(def["reach"])
			var r := Rect2(position.x + (0.0 if facing > 0 else -reach), position.y - 175, reach, 150)
			var dmg := int(def["dmg"])
			var kb := float(def["kb"])
			if _cur_attack == "power":
				dmg = int(dmg * (1.0 + _charge))
				kb *= 1.0 + 0.4 * _charge
			_resolve_hits(r, dmg, kb, bool(def.get("down", false)), _cur_attack)
	elif state == S.GRAB and sprite.animation == "grab_knee" and sprite.frame == 2:
		_knee_hit()


func _process(_dt: float) -> void:
	# Uçan tekme her karede temas arar (hızlı hareket ediyor).
	if state == S.AIR_ATTACK and sprite.frame >= 1:
		var r2 := Rect2(position.x + (0.0 if facing > 0 else -140.0), position.y - 150, 140, 150)
		_resolve_hits(r2, 16, 480, true, "air")


func _resolve_hits(r: Rect2, dmg: int, kb: float, knock: bool, tag: String) -> void:
	var landed := false
	for t in get_tree().get_nodes_in_group("hittable"):
		if _hit_done.has(t) or not t.has_method("take_hit") or not t.can_be_hit():
			continue
		if r.intersects(t.hurt_rect()):
			_hit_done[t] = true
			var d := dmg
			if tag.begins_with("bat"):
				weapon_uses -= 1
			t.take_hit(d, facing, kb, knock)
			landed = true
			if t.is_in_group("enemies"):
				meter = minf(100.0, meter + 7.0)
				level.add_combo()
			var p: Vector2 = t.hurt_rect().get_center()
			Fx.spark(level.fx_layer, Vector2(lerpf(p.x, position.x, 0.35), p.y - 20), knock)
	if landed:
		var heavy := knock or tag.begins_with("bat")
		Sfx.play("heavy_hit" if heavy else "hit", 0.9 + randf() * 0.2)
		Game.hitstop(70 if heavy else 40)
		level.shake(9.0 if heavy else 4.0)
		if tag == "air":
			velocity = Vector2(-facing * 260.0, -520.0) # sekme
			_set_state(S.MOVE)
			if _air_chain < AIR_CHAIN:
				_air_chain += 1
				_air_kick_used = false # isabet ettiyse bir tekme daha
		elif tag == "power":
			Game.hitstop(110)
			level.shake(14.0)
			Fx.ring(level.fx_layer, position + Vector2(facing * 120, -110), Color(1, 0.6, 0.25), 1.1)
		if weapon == "bat" and weapon_uses <= 0:
			_break_weapon()


func _fire() -> void:
	weapon_uses -= 1
	Sfx.play("shoot")
	var b := Bullet.new()
	b.from_player = true
	b.dir = facing
	b.dmg = 20
	b.position = position + Vector2(facing * 95, -128)
	level.fx_layer.add_child(b)
	Fx.spark(level.fx_layer, b.position, false)
	velocity.x = -facing * 120.0
	if weapon_uses <= 0:
		Fx.text(level.fx_layer, position + Vector2(0, -230), "MERMİ BİTTİ", Color(1, 0.8, 0.4), 0.7)
		weapon = ""


func _break_weapon() -> void:
	Sfx.play("weapon_break")
	Fx.shards(level.fx_layer, position + Vector2(facing * 60, -110), Color(0.6, 0.38, 0.2), 8)
	Fx.text(level.fx_layer, position + Vector2(0, -230), "SOPA KIRILDI", Color(1, 0.8, 0.4), 0.7)
	weapon = ""


func equip(w: String, uses: int) -> void:
	weapon = w
	weapon_uses = uses
	Sfx.play("reload" if w == "pistol" else "powerup")


func _on_anim_done() -> void:
	if state == S.GRAB:
		if sprite.animation == "grab_knee":
			if _grab_hits >= 3:
				_grab_release_forward()
			else:
				sprite.play("grab")
	elif state == S.ATTACK:
		_combo_gap = 0.35
		if _combo_i == 0:
			_combo_gap = 0.0
		_set_state(S.MOVE)
	elif sprite.animation == "land":
		sprite.play("idle")


func _set_state(s: S) -> void:
	state = s
	_state_t = 0.0


# --- Tutma (Dan the Man "grab") ---------------------------------------------

func _grab_candidate() -> Enemy:
	for n in get_tree().get_nodes_in_group("enemies"):
		var e := n as Enemy
		if e == null or not e.can_grab():
			continue
		var dx := e.position.x - position.x
		if signf(dx) == float(facing) and absf(dx) < GRAB_RANGE and absf(e.position.y - position.y) < 40.0:
			return e
	return null


func _start_grab(e: Enemy) -> void:
	_push_t = 0.0
	_grab = e
	_grab_hits = 0
	e.grab()
	velocity.x = 0.0
	_set_state(S.GRAB)
	sprite.flip_h = facing < 0
	sprite.play("grab")
	Sfx.play("swing", 0.7)
	Fx.text(level.fx_layer, position + Vector2(0, -230), "TUT!", Color(1, 0.85, 0.4), 0.7)


func _grab_tick(dir: float) -> void:
	velocity.x = 0.0
	if not is_instance_valid(_grab) or _grab.state != Enemy.S.GRABBED:
		_end_grab()
		return
	_grab.hold_at(position + Vector2(facing * 82.0, 0.0), -facing)
	if sprite.animation == "grab_knee" and sprite.is_playing():
		return
	if _buffer > 0.0:
		_buffer = 0.0
		_uppercut()
	elif _attack_buffer > 0.0:
		_attack_buffer = 0.0
		if dir != 0.0 and signf(dir) != float(facing):
			_throw()
		else:
			_grab_hits += 1
			sprite.play("grab_knee")
			Sfx.play("swing", 1.1)
	elif _state_t > GRAB_TIME:
		_grab.escape()
		_end_grab()


func _knee_hit() -> void:
	if not is_instance_valid(_grab) or _grab.state != Enemy.S.GRABBED:
		return
	var p := _grab.hurt_rect().get_center()
	_grab.grab_hit(9, facing)
	meter = minf(100.0, meter + 7.0)
	level.add_combo()
	Fx.spark(level.fx_layer, Vector2(lerpf(p.x, position.x, 0.35), p.y), false)
	Sfx.play("hit", 0.9 + randf() * 0.2)
	Game.hitstop(45)
	level.shake(4.0)


## Üçüncü dizden sonra düşman öne savrulur.
func _grab_release_forward() -> void:
	var e := _grab
	_end_grab()
	if is_instance_valid(e) and e.state == Enemy.S.GRABBED:
		e.launch(6, Vector2(facing * 560.0, -600.0), true)
		Sfx.play("heavy_hit")
		Game.hitstop(60)
		level.shake(8.0)


## Geri + VUR: düşmanı omuzdan arkaya fırlat; uçan gövde yoldakileri devirir.
func _throw() -> void:
	var e := _grab
	_grab = null
	facing = -facing
	sprite.flip_h = facing < 0
	e.position.x = position.x + facing * 40.0
	e.launch(14, Vector2(facing * 900.0, -640.0), true)
	_cur_attack = "throw"
	_hit_done.clear()
	_set_state(S.ATTACK)
	sprite.play("throw")
	meter = minf(100.0, meter + 10.0)
	level.add_combo()
	Sfx.play("heavy_hit", 0.85)
	Game.hitstop(70)
	level.shake(9.0)


## ZIPLA: aparkat — düşmanı havaya diker, Redmount da yükselir; havada tekmeyle devam edilir.
func _uppercut() -> void:
	var e := _grab
	_grab = null
	var p := e.hurt_rect().get_center()
	e.launch(20, Vector2(facing * 140.0, -1250.0), false)
	velocity = Vector2(facing * 120.0, -1000.0)
	_air_kick_used = false
	_air_chain = 0
	_set_state(S.UPPER)
	sprite.play("uppercut")
	meter = minf(100.0, meter + 10.0)
	level.add_combo()
	Fx.spark(level.fx_layer, Vector2(lerpf(p.x, position.x, 0.35), p.y - 40), true)
	Sfx.play("heavy_hit", 1.1)
	Sfx.play("jump", 0.9)
	Game.hitstop(80)
	level.shake(10.0)


func _end_grab() -> void:
	_grab = null
	if state == S.GRAB:
		_set_state(S.MOVE)


# --- Güçlü yumruk (VUR basılı tut) -------------------------------------------

func _start_charge() -> void:
	_charge = 0.0
	_set_state(S.CHARGE)
	sprite.play("charge")
	Sfx.play("powerup", 0.6)


func _charge_tick(dir: float, dt: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, FRICTION * dt)
	if dir != 0.0:
		facing = 1 if dir > 0.0 else -1
		sprite.flip_h = facing < 0
	var was_full := _charge >= 1.0
	_charge = minf(1.0, _charge + dt / CHARGE_FULL)
	var m := sprite.material as ShaderMaterial
	m.set_shader_parameter("flash", (0.12 + 0.4 * _charge) * (0.5 + 0.5 * sin(_state_t * 30.0)))
	if fmod(_state_t, 0.16) < dt:
		Fx.ring(level.fx_layer, position + Vector2(0, -100), Color(1, 0.55, 0.2), 0.3 + 0.5 * _charge)
	if _charge >= 1.0 and not was_full:
		Sfx.play("shield", 1.3)
		Fx.spark(level.fx_layer, position + Vector2(facing * 40, -130), true)


func _release_charge(fire: bool) -> void:
	(sprite.material as ShaderMaterial).set_shader_parameter("flash", 0.0)
	if not fire or _charge < 0.25:
		_set_state(S.MOVE)
		return
	_start_attack("power")
	velocity.x = facing * (300.0 + 260.0 * _charge)
	Sfx.play("dash", 0.8)
	level.shake(5.0)


# --- Hasar ------------------------------------------------------------------

func take_hit(dmg: int, from_x: float, knock := false, ignore_invuln := false) -> void:
	if state == S.DEAD or (is_invulnerable() and not ignore_invuln):
		return
	hp = maxi(0, hp - dmg)
	Game.run["damage"] = int(Game.run.get("damage", 0)) + dmg
	_invuln = 1.0
	if is_instance_valid(_grab):
		_grab.escape()
	_grab = null
	var dir := 1.0 if position.x >= from_x else -1.0
	velocity = Vector2(dir * (420.0 if knock else 300.0), -380.0 if knock else -160.0)
	_combo_i = 0
	_set_state(S.HURT)
	sprite.play("hurt")
	var m := sprite.material as ShaderMaterial
	m.set_shader_parameter("flash", 1.0)
	create_tween().tween_method(func(v): m.set_shader_parameter("flash", v), 1.0, 0.0, 0.18)
	Sfx.play("player_hurt")
	Game.hitstop(60)
	level.shake(12.0)
	level.flash_screen(Color(1, 0.1, 0.1, 0.25))
	if hp <= 0:
		_die()


func heal(n: int) -> void:
	hp = mini(max_hp, hp + n)
	Sfx.play("heal")
	Fx.text(level.fx_layer, position + Vector2(0, -230), "+%d" % n, Color(0.5, 1, 0.5))


func _die() -> void:
	_set_state(S.DEAD)
	sprite.play("dead")
	sprite.visible = true
	Sfx.play("player_death")
	var tw := create_tween()
	tw.tween_property(sprite, "rotation", -facing * PI / 2.0, 0.35).set_trans(Tween.TRANS_BOUNCE)
	tw.parallel().tween_property(sprite, "position:y", 30.0, 0.35)
	level.on_player_died()
