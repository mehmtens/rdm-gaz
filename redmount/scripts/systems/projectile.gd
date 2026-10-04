## Projectile — mermi / fırlatılan nesne (Görev 7).
##
## Area2D; verilen yönde sabit hızla uçar, bir hurtbox'a veya duvara değince
## hasar verip yok olur. Hem Redmount hem düşmanlar kullanır (`hostile_to_player`
## taraf belirler). Bkz. gun_config.gd / enemy_config.gd menzilli alanları.
class_name Projectile
extends Area2D

const SCENE_PATH := "res://scenes/systems/Bullet.tscn"

# Çarpışma maskesi bitleri (project.godot [layer_names]).
const WORLD := 1
const ENEMY_HURTBOX := 64
const PLAYER_HURTBOX := 32

var _velocity: Vector2 = Vector2.ZERO
var _damage: int = 6
var _knockback: float = 120.0
var _life: float = 2.5
var _shooter: Node = null


## Bir mermi oluştur ve `world` altına ekle.
static func spawn(world: Node, pos: Vector2, dir: Vector2, speed: float,
		damage: int, knockback: float, hostile_to_player: bool, shooter: Node) -> void:
	if world == null:
		return
	var b: Projectile = load(SCENE_PATH).instantiate()
	b.setup(dir, speed, damage, knockback, hostile_to_player, shooter)
	world.add_child(b)
	b.global_position = pos


func setup(dir: Vector2, speed: float, damage: int, knockback: float,
		hostile_to_player: bool, shooter: Node) -> void:
	_velocity = dir.normalized() * speed
	_damage = damage
	_knockback = knockback
	_shooter = shooter
	rotation = _velocity.angle()
	collision_layer = 0
	collision_mask = WORLD | (PLAYER_HURTBOX if hostile_to_player else ENEMY_HURTBOX)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += _velocity * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	var target: Node = area.owner if area.owner != null else area.get_parent()
	if target == _shooter:
		return
	if target != null and target.has_method(&"apply_hit"):
		target.apply_hit(_damage, Vector2(signf(_velocity.x), 0.0), _knockback)
		Sfx.play(&"hit", 1.2)
		Combat.shake(2.0)
	queue_free()


func _on_body_entered(_body: Node) -> void:
	queue_free()
