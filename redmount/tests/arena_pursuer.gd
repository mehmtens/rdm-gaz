## Kapı dışında kalan takipçi içeri alınır (tasarım denetimi Bölüm 22, 26 Ekim): oyuncuyu
## kovalayan Seçkin Muhafız kilitli arenanın kapısı dışında kalıp ateş ediyordu; ne
## vurulabiliyor ne sayaçta görünüyordu. Çatışmadaki yakın takipçi kapıdan içeri alınıp
## sayaca eklenir; boştaki ya da uzaktaki düşmana dokunulmaz.
##
##  godot --headless --path . --fixed-fps 60 res://tests/arena_pursuer.tscn
extends Node

const ARENA := preload("res://scenes/systems/BattleArena.tscn")

class _Target extends Node2D:
	func get_health() -> int:
		return 100

var _fails := 0


func _ready() -> void:
	var floor := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(6000, 40)
	shape.shape = rect
	floor.position = Vector2(0, 20)
	floor.add_child(shape)
	add_child(floor)
	var target := _Target.new()
	target.add_to_group(&"player")
	target.position = Vector2(520, -24)
	add_child(target)
	# Kapıya 150 px kala oyuncuyu gören takipçi; sağda uzak, oyuncuyu görmeyen nişancı;
	# 1100 px geride boştaki serseri.
	var chaser := _enemy("EliteGuard", 250.0)
	var idle_right := _enemy("RifleGuard", 1500.0)
	var far_back := _enemy("StreetThug", -700.0)
	for i in 20:
		await get_tree().physics_frame
	_check(chaser.is_engaged(), "takipçi oyuncuyu fark etti")
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(700, 0)
	arena.gate_left_x = 400
	arena.gate_right_x = 1000
	arena.floor_y = 0
	arena.wave1 = [load("res://scenes/enemies/KnifeAgent.tscn") as PackedScene]
	var badge := [0, 0, 0]
	arena.wave_changed.connect(func(w: int, t: int, r: int) -> void: badge.assign([w, t, r]))
	add_child(arena)
	arena._active = true
	arena._activate()
	for i in 60:
		await get_tree().physics_frame
	_check(chaser.global_position.x > 400.0 and chaser.global_position.x < 1000.0,
		"takipçi kapının içinde (x %.0f)" % chaser.global_position.x)
	_check(arena._alive.has(chaser), "takipçi arena sayacında")
	_check(badge[2] == 2, "rozet 2 düşman gösteriyor (%d)" % badge[2])
	_check(idle_right.global_position.x > 1400.0, "boştaki uzak nişancı yerinde (x %.0f)" % idle_right.global_position.x)
	_check(far_back.global_position.x < -600.0, "geride boştaki serseri yerinde (x %.0f)" % far_back.global_position.x)
	print("ARENA PURSUER: %s" % ["PASS" if _fails == 0 else "FAIL (%d)" % _fails])
	get_tree().quit(0 if _fails == 0 else 1)


func _enemy(scene_name: String, x: float) -> EnemyBase:
	var e: EnemyBase = (load("res://scenes/enemies/%s.tscn" % scene_name) as PackedScene).instantiate()
	e.position = Vector2(x, -24)
	add_child(e)
	return e


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("ARENA PURSUER FAIL: " + what)
