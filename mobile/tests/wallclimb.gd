## Ölçüm: duvar dibinde sağa basılı, duvara değip düşerken ZIPLA'ya yeniden basar. En yüksek noktayı yazar.
extends Node
var _level: Level
var _f := 0
var _best := 0.0
var _press_next := false
var _hold := 0

func _ready() -> void:
	Game.testing = true
	Game.run = {"coins": 0, "collected": {}, "cleared": {}, "secrets": {}, "kills": 0, "time": 0.0, "deaths": 0, "checkpoint": Vector2(3440, -180)}
	_level = load("res://scenes/levels/Level01.tscn").instantiate()
	add_child(_level)

func _physics_process(_dt: float) -> void:
	_f += 1
	var p := _level.player
	Input.action_press("right")
	_hold -= 1
	if _press_next:
		Input.action_press("jump")
		_press_next = false
		_hold = 10
	elif _f == 20:
		Input.action_press("jump")
	elif _hold <= 0 and p.is_on_wall() and p.velocity.y > 0 and not p.is_on_floor():
		Input.action_release("jump")
		_press_next = true
	_best = minf(_best, p.position.y)
	if _f % 10 == 0:
		print("f=%d y=%.0f vy=%.0f wall=%s jp=%s rising=%s" % [_f, p.position.y, p.velocity.y, p.is_on_wall(), Input.is_action_pressed("jump"), p._rising])
	if _f > 360 or p.position.y <= -520:
		print("SONUÇ: en yüksek y=%.0f (hedef -520)  x=%.0f" % [_best, p.position.x])
		get_tree().quit()
