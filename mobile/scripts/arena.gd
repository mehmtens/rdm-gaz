## Arena — Dan the Man tarzı kilitli dövüş: kamera ve duvarlar kilitlenir,
## düşmanlar dalgalar halinde iki yandan koşarak gelir. Temizlenince kilit açılır.
class_name Arena
extends Node2D

var id := ""
var x0 := 0.0
var x1 := 0.0
var floor_y := 0.0
var waves: Array = [] ## [[["thug", -1], ["knife", 1]], ...] (-1 sol, 1 sağ)
var level: Node

var active := false
var done := false
var _wave := -1
var _alive := 0
var _walls: Array[StaticBody2D] = []


func try_start(px: float) -> void:
	if active or done or px < x0 + 220.0 or px > x1 - 100.0:
		return
	active = true
	level.lock_camera(x0, x1)
	for x in [x0, x1]:
		var b := StaticBody2D.new()
		b.collision_layer = Game.L_ARENA
		var cs := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(40, 2400)
		cs.shape = r
		b.position = Vector2(x + (-20.0 if x == x0 else 20.0), floor_y - 1000)
		b.add_child(cs)
		level.add_child(b)
		_walls.append(b)
	level.banner("DÖVÜŞ!", Color(1, 0.35, 0.25))
	Sfx.play("boss_slam", 1.3)
	Music.play("boss")
	_next_wave()


func _next_wave() -> void:
	_wave += 1
	if _wave >= waves.size():
		_finish()
		return
	var list: Array = waves[_wave]
	_alive = list.size()
	var i := 0
	for entry in list:
		var side: int = entry[1]
		var x: float = (x0 - 120.0 - i * 90.0) if side < 0 else (x1 + 120.0 + i * 90.0)
		var e: Enemy = level.add_enemy(entry[0], Vector2(x, floor_y - 10), "", true)
		e.defeated.connect(_on_defeated)
		i += 1


func _on_defeated(_e: Enemy) -> void:
	_alive -= 1
	if _alive <= 0:
		get_tree().create_timer(0.9).timeout.connect(_next_wave)


func _finish() -> void:
	active = false
	done = true
	Game.run["cleared"][id] = true
	for w in _walls:
		w.queue_free()
	_walls.clear()
	level.unlock_camera()
	level.banner("TEMİZ!", Color(0.5, 1, 0.6))
	Sfx.play("goal", 1.2)
	Music.play("street")
	level.show_go_arrow()
