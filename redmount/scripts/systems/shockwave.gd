## Shockwave — yerde yayılan darbe dalgası (Görev 10).
##
## Ağır Zırhlı mini-boss'un yere vuruşunda (`ground_slam`) oluşur; zeminde hızla
## genişler ve alçak kaldığı için oyuncu **zıplayarak** kaçabilir. Bkz. enemy_base.gd
class_name Shockwave
extends Area2D

const SCENE_PATH := "res://scenes/systems/Shockwave.tscn"
const WORLD := 1
const PLAYER_HURTBOX := 32
const ENEMY_HURTBOX := 64

@onready var _shape: CollisionShape2D = $CollisionShape2D
@onready var _vis: Polygon2D = $Vis

var _damage: int = 12
var _knockback: float = 260.0
var _dir: int = 1
var _speed: float = 640.0
var _life: float = 0.5
var _max_half_width: float = 240.0
var _half_width: float = 8.0
var _hit: Array = []


static func spawn(world: Node, pos: Vector2, dir: int, damage: int, knockback: float,
		hostile_to_player: bool) -> void:
	if world == null:
		return
	var s: Shockwave = load(SCENE_PATH).instantiate()
	s._damage = damage
	s._knockback = knockback
	s._dir = 1 if dir >= 0 else -1
	s.collision_mask = (PLAYER_HURTBOX if hostile_to_player else ENEMY_HURTBOX)
	world.add_child(s)
	s.global_position = pos


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	area_entered.connect(_on_area_entered)
	Sfx.play(&"boss_slam")
	Combat.shake(9.0)


func _physics_process(delta: float) -> void:
	_half_width = minf(_half_width + _speed * delta, _max_half_width)
	# Dalga öne doğru büyür (origin'den ileri).
	var rect := _shape.shape as RectangleShape2D
	if rect != null:
		rect.size.x = _half_width
	_shape.position.x = _dir * _half_width * 0.5
	_vis.scale.x = _dir * _half_width / 40.0

	_life -= delta
	if _life <= 0.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	var target: Node = area.owner if area.owner != null else area.get_parent()
	if target == null or target in _hit or not target.has_method(&"apply_hit"):
		return
	_hit.append(target)
	target.apply_hit(_damage, Vector2(_dir, 0.0), _knockback)
