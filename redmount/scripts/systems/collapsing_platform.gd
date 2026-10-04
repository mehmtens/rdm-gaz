## CollapsingPlatform — üstüne basınca çöken platform (Görev 25).
##
## StaticBody2D + üstte algı Area2D. Oyuncu basınca kısa süre sallanır, sonra
## çarpışma kapanır ve görsel aşağı düşer; `respawn_time` sonra yerine döner.
## Çukur üstüne dizilince "durma, ritimle koş" hissi verir (tuzak).
class_name CollapsingPlatform
extends StaticBody2D

## Platform genişliği (px).
@export var width: float = 120.0
## Basıldıktan sonra çökene kadar geçen süre (sn).
@export var fall_delay: float = 0.5
## Çöktükten sonra yeniden belirene kadar (sn).
@export var respawn_time: float = 2.8

enum _S { SOLID, SHAKING, GONE }

var _col: CollisionShape2D
var _vis: Polygon2D
var _sensor: Area2D
var _state: int = _S.SOLID
var _timer: float = 0.0
var _base_x: float = 0.0


func _ready() -> void:
	add_to_group(&"collapsing")
	_col = CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(width, 20.0)
	_col.shape = r
	add_child(_col)

	var hw := width * 0.5
	_vis = Polygon2D.new()
	_vis.polygon = PackedVector2Array([
		Vector2(-hw, -10), Vector2(hw, -10), Vector2(hw, 10), Vector2(-hw, 10)])
	_vis.color = Color(0.34, 0.3, 0.24)
	add_child(_vis)
	var crack := Line2D.new()
	crack.points = PackedVector2Array([Vector2(-hw * 0.3, -10), Vector2(hw * 0.1, 10),
		Vector2(hw * 0.5, -10)])
	crack.width = 2.0
	crack.default_color = Color(0.15, 0.13, 0.1)
	_vis.add_child(crack)

	_sensor = Area2D.new()
	_sensor.collision_layer = 0
	_sensor.collision_mask = 2  # player
	var sc := CollisionShape2D.new()
	var sr := RectangleShape2D.new()
	sr.size = Vector2(width - 8.0, 26.0)
	sc.shape = sr
	sc.position = Vector2(0, -18.0)
	_sensor.add_child(sc)
	add_child(_sensor)
	_sensor.body_entered.connect(_on_step)

	_base_x = position.x


func _on_step(body: Node) -> void:
	if _state == _S.SOLID and body.is_in_group(&"player"):
		_state = _S.SHAKING
		_timer = fall_delay
		Sfx.play(&"weapon_break", 1.4, -8.0)


func _physics_process(delta: float) -> void:
	match _state:
		_S.SHAKING:
			_timer -= delta
			position.x = _base_x + sin(_timer * 60.0) * 2.4
			if _timer <= 0.0:
				_collapse()
		_S.GONE:
			_timer -= delta
			_vis.position.y = lerpf(_vis.position.y, 60.0, clampf(delta * 6.0, 0.0, 1.0))
			_vis.modulate.a = maxf(_vis.modulate.a - delta * 1.5, 0.0)
			if _timer <= 0.0:
				_restore()


func _collapse() -> void:
	_state = _S.GONE
	_timer = respawn_time
	position.x = _base_x
	_col.set_deferred(&"disabled", true)
	Fx.dust(global_position, 0, 6)
	Sfx.play(&"land", 0.6, -4.0)


func _restore() -> void:
	_state = _S.SOLID
	_col.set_deferred(&"disabled", false)
	_vis.position.y = 0.0
	_vis.modulate.a = 1.0
	Fx.spark(global_position + Vector2(0, -6), Vector2.ZERO, 5, Color(0.7, 0.65, 0.5))
