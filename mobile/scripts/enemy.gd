## Enemy — sokak eşkıyası / bıçaklı ajan / tüfekli muhafız.
## Kovala → hazırlık (okunur telegraf) → vuruş; darbe alınca sendele, 4. vuruşta yere yık.
class_name Enemy
extends CharacterBody2D

signal defeated(enemy: Enemy)

enum S { IDLE, CHASE, ATTACK, AIM, RELOAD, HURT, AIR, DOWN, GETUP, DEAD }

const GRAVITY := 2800.0

const TYPES := {
	"thug": {
		"char": "street_thug", "hp": 42, "speed": 200.0, "dmg": 10, "range": 135.0,
		"cool": [0.8, 1.7], "coins": 3, "active": 3, "body": Vector2(64, 160),
		"anims": {
			"idle": ["idle", 7, true], "walk": ["walk", 11, true],
			"attack": ["attack", 9, false, [2, 2, 1, 0, 0, 1]],
			"hurt": ["hurt", 10, false, [0]], "air": ["hurt", 10, false, [1, 2]],
			"down": ["dead", 16, false, [2, 3, 4]], "getup": ["knockdown", 11, false],
			"dead": ["dead", 12, false, [2, 3, 4, 5, 6]],
		},
	},
	"knife": {
		"char": "knife_agent", "hp": 36, "speed": 280.0, "dmg": 14, "range": 170.0,
		"cool": [0.6, 1.3], "coins": 4, "active": 4, "lunge": 520.0, "body": Vector2(60, 160),
		"anims": {
			"idle": ["idle", 7, true], "walk": ["walk", 13, true],
			"attack": ["attack", 15, false],
			"hurt": ["dead", 10, false, [0]], "air": ["dead", 10, false, [0, 1]],
			"down": ["dead", 16, false, [2, 3, 4]], "getup": ["knockdown", 12, false],
			"dead": ["dead", 12, false, [2, 3, 4, 5]],
		},
	},
	"rifle": {
		"char": "rifle_guard", "hp": 30, "speed": 150.0, "dmg": 12, "range": 820.0,
		"cool": [1.2, 2.0], "coins": 5, "active": 1, "ranged": true, "body": Vector2(70, 140),
		"anims": {
			"idle": ["idle", 7, true], "walk": ["walk", 11, true],
			"aim": ["aim", 6, false], "attack": ["shoot", 12, false, [0, 1, 0]],
			"reload": ["reload", 12, false],
			"hurt": ["hurt", 10, false, [0]], "air": ["hurt", 10, false, [0]],
			"down": ["hurt", 12, false, [1, 2, 3]], "getup": ["aim", 10, false, [0, 1]],
			"dead": ["dead", 4, false],
		},
	},
}

var kind := "thug"
var level: Node
var id := ""
var aggro := false
var state: S = S.IDLE
var facing := -1
var hp := 40
var max_hp := 40
var def: Dictionary

var _t := 0.0
var _cool := 1.0
var _shots := 0
var _hit_player := false
var _bar_t := 0.0
var _has_token := false
var _flash_m: ShaderMaterial
var sprite: AnimatedSprite2D
var _warn: Label


func _ready() -> void:
	def = TYPES[kind]
	hp = int(def["hp"])
	max_hp = hp
	add_to_group("enemies")
	add_to_group("hittable")
	collision_layer = Game.L_ENEMY
	collision_mask = Game.L_WORLD | Game.L_ONEWAY
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(50, 150)
	shape.shape = rect
	shape.position = Vector2(0, -75)
	add_child(shape)
	sprite = SpriteLib.make_sprite(def["char"], def["anims"])
	_flash_m = sprite.material
	add_child(sprite)
	sprite.frame_changed.connect(_on_frame)
	sprite.animation_finished.connect(_on_anim_done)
	sprite.play("idle")
	_warn = Label.new()
	_warn.text = "!"
	_warn.add_theme_font_size_override("font_size", 64)
	_warn.add_theme_color_override("font_color", Color(1, 0.3, 0.2))
	_warn.add_theme_color_override("font_outline_color", Color.BLACK)
	_warn.add_theme_constant_override("outline_size", 12)
	_warn.position = Vector2(-12, -def["body"].y - 110)
	_warn.visible = false
	add_child(_warn)
	_cool = randf_range(0.4, 1.0)
	if aggro:
		state = S.CHASE


func hurt_rect() -> Rect2:
	var b: Vector2 = def["body"]
	if state == S.DOWN or state == S.AIR:
		return Rect2(position.x - b.x, position.y - b.y * 0.6, b.x * 2, b.y * 0.6)
	return Rect2(position.x - b.x / 2, position.y - b.y, b.x, b.y)


func can_be_hit() -> bool:
	return state != S.DOWN and state != S.GETUP and state != S.DEAD


func _player() -> Player:
	return get_tree().get_first_node_in_group("player")


func _physics_process(dt: float) -> void:
	_t += dt
	_cool -= dt
	_bar_t -= dt
	var p := _player()
	var on_floor := is_on_floor()
	match state:
		S.IDLE:
			velocity.x = 0
			_play("idle")
			if p and absf(p.position.x - position.x) < 900.0 and absf(p.position.y - position.y) < 350.0:
				aggro = true
				state = S.CHASE
		S.CHASE:
			_chase(p, dt)
		S.ATTACK, S.AIM, S.RELOAD:
			velocity.x = move_toward(velocity.x, 0.0, 2400.0 * dt)
			if state == S.AIM and _t > 0.75:
				_go_state(S.ATTACK)
				sprite.play("attack")
		S.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 1800.0 * dt)
			if _t > 0.3:
				_go_state(S.CHASE)
		S.AIR:
			if on_floor and _t > 0.1:
				velocity.x *= 0.2
				level.shake(5.0)
				Fx.dust(level.fx_layer, position, 1.3)
				Sfx.play("land", 0.7)
				if hp <= 0:
					_die()
				else:
					_go_state(S.DOWN)
					sprite.play("down")
		S.DOWN:
			velocity.x = move_toward(velocity.x, 0.0, 2400.0 * dt)
			if _t > 0.75:
				_go_state(S.GETUP)
				sprite.play("getup")
		S.GETUP:
			velocity.x = 0
		S.DEAD:
			velocity.x = move_toward(velocity.x, 0.0, 2400.0 * dt)
	velocity.y = minf(velocity.y + GRAVITY * dt, 1600.0)
	move_and_slide()
	sprite.flip_h = facing < 0
	_warn.visible = state == S.AIM or (state == S.ATTACK and sprite.frame < int(def["active"]) and not def.has("ranged"))
	if position.y > level.kill_y and state != S.DEAD:
		hp = 0
		_die()
	queue_redraw()


func _chase(p: Player, dt: float) -> void:
	if p == null or p.state == Player.S.DEAD:
		velocity.x = 0
		_play("idle")
		return
	var dx := p.position.x - position.x
	var dy := p.position.y - position.y
	facing = 1 if dx > 0 else -1
	var rng := float(def["range"])
	var want := 0.0
	if def.has("ranged"):
		var dist := absf(dx)
		if dist < 420.0:
			want = -signf(dx) # geri çekil
		elif dist > rng:
			want = signf(dx)
		if dist <= rng and absf(dy) < 220.0 and _cool <= 0.0:
			_go_state(S.AIM)
			sprite.play("aim")
			return
	else:
		# Oyuncunun kendi tarafındaki noktaya git; kalabalıkta birbirinden ayrış.
		var target := p.position.x - signf(dx) * rng * 0.75
		var tdx := target - position.x
		if absf(tdx) > 20.0:
			want = signf(tdx)
		if absf(dx) <= rng + 10.0 and absf(dy) < 140.0 and _cool <= 0.0 and level.take_token(self):
			_has_token = true
			_attack()
			return
	for e in get_tree().get_nodes_in_group("enemies"):
		if e != self and absf(e.position.x - position.x) < 70.0 and e.state != S.DEAD:
			want += signf(position.x - e.position.x + 0.01) * 0.6
	# Kenardan düşme.
	if want != 0.0 and is_on_floor() and not _ground_at(signf(want) * 50.0):
		want = 0.0
	var spd := float(def["speed"])
	velocity.x = move_toward(velocity.x, clampf(want, -1, 1) * spd, 2400.0 * dt)
	_play("walk" if absf(velocity.x) > 20.0 else "idle")


func _ground_at(dx: float) -> bool:
	var q := PhysicsRayQueryParameters2D.create(position + Vector2(dx, -10), position + Vector2(dx, 60), Game.L_WORLD | Game.L_ONEWAY)
	return not get_world_2d().direct_space_state.intersect_ray(q).is_empty()


func _attack() -> void:
	_go_state(S.ATTACK)
	_hit_player = false
	sprite.play("attack")


func _on_frame() -> void:
	if state != S.ATTACK:
		return
	var p := _player()
	if p == null:
		return
	if sprite.frame == int(def["active"]) - 1 and def.has("lunge"):
		velocity.x = facing * float(def["lunge"])
	if sprite.frame == int(def["active"]):
		if def.has("ranged"):
			var b := Bullet.new()
			b.dir = facing
			b.dmg = int(def["dmg"])
			b.position = position + Vector2(facing * 90, -88)
			level.fx_layer.add_child(b)
			Sfx.play("shoot", 0.8)
			Fx.spark(level.fx_layer, b.position, false)
		elif not _hit_player:
			var reach := float(def["range"]) + 20.0
			var r := Rect2(position.x + (0.0 if facing > 0 else -reach), position.y - 160, reach, 130)
			if r.intersects(p.hurt_rect()) and not p.is_invulnerable():
				_hit_player = true
				p.take_hit(int(def["dmg"]), position.x, kind == "knife")


func _on_anim_done() -> void:
	match state:
		S.ATTACK:
			_release_token()
			var c: Array = def["cool"]
			_cool = randf_range(c[0], c[1])
			if def.has("ranged"):
				_shots += 1
				if _shots >= 2:
					_shots = 0
					_go_state(S.RELOAD)
					sprite.play("reload")
					Sfx.play("reload", 0.9)
					return
			_go_state(S.CHASE)
		S.RELOAD:
			_go_state(S.CHASE)
		S.GETUP:
			_cool = 0.5
			_go_state(S.CHASE)
		S.DEAD:
			var tw := create_tween()
			tw.tween_interval(0.5)
			tw.tween_property(self, "modulate:a", 0.0, 0.4)
			tw.tween_callback(queue_free)


func take_hit(dmg: int, dir: int, kb: float, knock: bool) -> void:
	if not can_be_hit():
		return
	_release_token()
	hp -= dmg
	_bar_t = 2.5
	aggro = true
	facing = -dir
	_flash_m.set_shader_parameter("flash", 1.0)
	create_tween().tween_method(func(v): _flash_m.set_shader_parameter("flash", v), 1.0, 0.0, 0.16)
	Sfx.play("enemy_hurt")
	Fx.text(level.fx_layer, position + Vector2(randf_range(-20, 20), -def["body"].y - 30), str(dmg), Color(1, 0.9, 0.5), 0.8)
	if hp <= 0 or knock or state == S.AIR:
		var juggle := state == S.AIR
		_go_state(S.AIR)
		sprite.play("air")
		velocity = Vector2(dir * maxf(kb, 380.0), -460.0 if juggle else -620.0)
		if hp <= 0:
			velocity.x = dir * maxf(kb, 520.0)
	else:
		_go_state(S.HURT)
		sprite.play("hurt")
		velocity.x = dir * kb


func _die() -> void:
	if state == S.DEAD:
		return
	_release_token()
	_go_state(S.DEAD)
	sprite.play("dead")
	Sfx.play("enemy_down")
	remove_from_group("hittable")
	level.spawn_coins(position + Vector2(0, -60), int(def["coins"]))
	Game.run["kills"] = int(Game.run.get("kills", 0)) + 1
	if id != "":
		Game.run["collected"][id] = true
	defeated.emit(self)


func _release_token() -> void:
	if _has_token:
		_has_token = false
		level.release_token(self)


func _go_state(s: S) -> void:
	state = s
	_t = 0.0


func _play(a: String) -> void:
	if sprite.animation != a:
		sprite.play(a)


func _draw() -> void:
	# Hasar alınca başının üstünde kısa süre can çubuğu.
	if _bar_t > 0.0 and state != S.DEAD:
		var w := 90.0
		var y: float = -def["body"].y - 40.0
		draw_rect(Rect2(-w / 2 - 3, y - 3, w + 6, 16), Color(0.05, 0.03, 0.08, 0.85))
		draw_rect(Rect2(-w / 2, y, w * clampf(float(hp) / max_hp, 0, 1), 10), Color(0.95, 0.25, 0.2))
	# Tüfekli muhafız nişan alırken kırmızı lazer.
	if state == S.AIM:
		var a := 0.3 + 0.5 * absf(sin(_t * 18.0))
		draw_line(Vector2(facing * 90, -88), Vector2(facing * 1400, -88), Color(1, 0.15, 0.1, a), 3.0)
