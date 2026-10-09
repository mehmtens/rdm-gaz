## Oynanış botu: gerçek girdi eylemleriyle (Input.action_press) bölümü oynar.
## Sağa koşar; önünde düşman/kırılabilir varsa VUR, duvar/çukur/basamak varsa ZIPLA,
## duvar dibinde duvar zıplaması dener, ÖZEL dolunca kullanır. Her saniye durum yazar.
## Kullanım: godot --headless --fixed-fps 60 --path . res://tests/bot.tscn -- [süre_sn]
extends Node

var _level: Level
var _t := 0.0
var _limit := 400.0
var _log_t := 0.0
var _held: Dictionary = {}
var _stuck_x := 0.0
var _stuck_t := 0.0
var _max_x := 0.0
var _frames := 0
var _shots := ""
var _shot_i := 0


func _ready() -> void:
	Game.testing = true
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_limit = float(args[0])
	if args.size() > 1:
		_shots = args[1]
		DirAccess.make_dir_recursive_absolute(_shots)
	Game.level_index = 0
	Game.run = {"coins": 0, "collected": {}, "cleared": {}, "secrets": {}, "kills": 0, "time": 0.0, "deaths": 0, "checkpoint": null}
	_load_level()


func _load_level() -> void:
	if _level:
		_level.queue_free()
	_level = load("res://scenes/levels/Level01.tscn").instantiate()
	add_child(_level)


func _press(a: String, on: bool) -> void:
	if on and not _held.get(a, false):
		Input.action_press(a)
	elif not on and _held.get(a, false):
		Input.action_release(a)
	_held[a] = on


var _pending: Array = []
var _auto_release: Dictionary = {} ## action -> kalan kare; VUR basılı kalırsa güçlü yumruğa dolar.

func _tap(a: String, hold_frames := 0) -> void:
	# Gerçek parmak gibi: bu kare bırak, sonraki kare bas (hold_frames > 0 ise sonra bırak).
	Input.action_release(a)
	_held[a] = false
	if not a in _pending:
		_pending.append(a)
	if hold_frames > 0:
		_auto_release[a] = hold_frames


func _physics_process(dt: float) -> void:
	_t += dt
	_frames += 1
	for a in _auto_release.keys():
		if a in _pending:
			continue
		_auto_release[a] -= 1
		if _auto_release[a] <= 0:
			_auto_release.erase(a)
			_press(a, false)
	for a in _pending:
		Input.action_press(a)
		_held[a] = true
	_pending.clear()
	var p := _level.player
	if p == null:
		return
	if _shots != "" and _frames % 150 == 0:
		get_viewport().get_texture().get_image().save_png("%s/g_%03d.png" % [_shots, _shot_i])
		_shot_i += 1
	if _level.finished:
		if _shots != "" and not _held.get("res", false):
			_held["res"] = true
			get_tree().create_timer(2.5).timeout.connect(func():
				get_viewport().get_texture().get_image().save_png("%s/results.png" % _shots)
				get_tree().quit())
			return
		elif _shots != "":
			return
		print("BOT: BÖLÜM BİTTİ t=%.1f coins=%d/%d kills=%d secrets=%d/%d deaths=%d hp=%d" % [_t, Game.run["coins"], _level.totals["coins"], Game.run["kills"], Game.run["secrets"].size(), _level.totals["secrets"], Game.run["deaths"], p.hp])
		get_tree().quit()
		return
	if p.state == Player.S.DEAD:
		for a in ["left", "right", "jump", "attack", "special"]:
			_press(a, false)
		if not _held.get("dead_logged", false):
			_held["dead_logged"] = true
			print("BOT: ÖLDÜ x=%d t=%.1f" % [p.position.x, _t])
			get_tree().create_timer(1.0).timeout.connect(func():
				Game.run["deaths"] += 1
				_held["dead_logged"] = false
				_load_level())
		return
	if _t > _limit:
		print("BOT: SÜRE DOLDU x=%d max_x=%d" % [p.position.x, _max_x])
		get_tree().quit()
		return

	var ahead := _nearest_target(p)
	var fight := ahead != null
	var arena_active := false
	for a in _level.arenas:
		if a.active:
			arena_active = true
	# Hareket: dövüşte hedefe dön, yoksa sağa koş.
	var go_right := true
	if fight:
		go_right = ahead.hurt_rect().get_center().x > p.position.x
		var dist := absf(ahead.hurt_rect().get_center().x - p.position.x)
		_press("right", go_right and dist > 110)
		_press("left", not go_right and dist > 110)
		if dist < 190 and _frames % 7 == 0:
			_tap("attack", 4)
		if p.meter >= 50.0 and dist < 400 and _frames % 30 == 0:
			_tap("special", 4)
	elif arena_active:
		_press("right", false)
		_press("left", false)
	else:
		_press("right", true)
		_press("left", false)
		if p.weapon == "pistol" and _frames % 20 == 0 and _enemy_in_line(p):
			_tap("shoot", 4)

	# Zıplama kararları (gerçek fizik sorgularıyla).
	if p.is_on_floor():
		var dirx := 1.0 if go_right else -1.0
		var wall := _hit(p.position + Vector2(0, -60), p.position + Vector2(dirx * 120, -60))
		var gap := not _hit(p.position + Vector2(dirx * 140, -10), p.position + Vector2(dirx * 140, 300))
		var step := _hit(p.position + Vector2(0, -20), p.position + Vector2(dirx * 90, -20))
		if (wall or gap or step) and not fight:
			_press("jump", true)
			_held["jump_t"] = 0.0
	elif _held.get("jump", false):
		_held["jump_t"] = float(_held.get("jump_t", 0.0)) + dt
		# Duvar zıplaması: duvara yapışıp kayıyorsa bırak-bas.
		if p.is_on_wall() and p.velocity.y > 0 and float(_held.get("jump_t", 0.0)) > 0.15:
			_tap("jump")
			_held["jump_t"] = 0.0
		elif float(_held["jump_t"]) > 0.35:
			_press("jump", false)
	if p.is_on_floor() and not _held.get("jump", false) == false and float(_held.get("jump_t", 0.0)) > 0.1:
		_press("jump", false)

	# Takılma tespiti: 3 sn ilerleme yoksa zıplayarak sars.
	if absf(p.position.x - _stuck_x) > 40:
		_stuck_x = p.position.x
		_stuck_t = 0.0
	else:
		_stuck_t += dt
		if _stuck_t > 3.0 and not arena_active and not fight:
			_press("jump", false)
			_tap("jump")
			_stuck_t = 1.5
	_max_x = maxf(_max_x, p.position.x)

	_log_t += dt
	if _log_t >= 2.0:
		_log_t = 0.0
		var tg := _nearest_target(p)
		if tg:
			print("   hedef: %s %s rect=%s st=%s" % [tg.get_class(), tg.get("kind"), tg.hurt_rect(), tg.get("state")])
		print("   anim=%s f=%d playing=%s ts=%.2f" % [p.sprite.animation, p.sprite.frame, p.sprite.is_playing(), Engine.time_scale])
		print("t=%5.1f x=%6d y=%5d hp=%3d coin=%3d kill=%2d weapon=%s meter=%3d arena=%s st=%s" % [_t, p.position.x, p.position.y, p.hp, Game.run["coins"], Game.run["kills"], p.weapon, p.meter, arena_active, Player.S.keys()[p.state]])


func _hit(a: Vector2, b: Vector2) -> bool:
	var q := PhysicsRayQueryParameters2D.create(a, b, Game.L_WORLD | Game.L_ARENA)
	return not _level.get_world_2d().direct_space_state.intersect_ray(q).is_empty()


func _nearest_target(p: Player) -> Node:
	var best: Node = null
	var bd := 1e9
	for t in get_tree().get_nodes_in_group("hittable"):
		if not t.can_be_hit():
			continue
		var c: Vector2 = t.hurt_rect().get_center()
		var d := absf(c.x - p.position.x)
		var dy := absf(c.y - (p.position.y - 90))
		var limit := 600.0 if t is Enemy else 220.0
		if d < limit and dy < 160 and d < bd:
			bd = d
			best = t
	return best


func _enemy_in_line(p: Player) -> bool:
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.position.x > p.position.x and e.position.x - p.position.x < 900 and absf(e.position.y - p.position.y) < 100:
			return true
	return false
