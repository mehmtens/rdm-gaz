## BreakableWall — kırılabilir duvar / gizli alan kapısı (Görev 9).
##
## StaticBody2D olarak yolu kapatır; Redmount'un saldırıları (Hurtbox üzerinden
## `apply_hit`) veya mermileri birkaç kez vurunca çöker ve arkasındaki ödül
## erişilebilir olur (ana plan md. 15: kırılabilir duvarda hafif çatlak).
extends StaticBody2D

const WALL_ART := preload("res://assets/environment/mahalle/wall_broken.png")
@export var hits_to_break: int = 4

@onready var _vis: Polygon2D = $Vis
@onready var _col: CollisionShape2D = $CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox

var _hp: int = 0
var _skin: Sprite2D


func _ready() -> void:
	_hp = hits_to_break
	_vis.hide()
	_skin = Sprite2D.new()
	_skin.texture = WALL_ART
	_skin.region_enabled = true
	_skin.region_rect = Rect2(36, 0, 40, 160)
	_skin.position = Vector2(0, -100)
	_skin.scale.y = 1.25
	add_child(_skin)


## Redmount'un Hitbox'ı / mermisi değince çağrılır (saldıran taraf çağırır).
func apply_hit(_damage: int, _dir: Vector2, _knockback: float) -> void:
	if _hp <= 0:
		return
	_hp -= 1
	Sfx.play(&"hit", 0.8)
	Combat.shake(2.0)
	# İlerleyen çatlak: karar koyulaşır.
	_skin.modulate = Color.WHITE.darkened(0.18 * float(hits_to_break - _hp))
	var t := create_tween()
	t.tween_property(_skin, ^"position:x", _skin.position.x + 3.0, 0.03)
	t.tween_property(_skin, ^"position:x", _skin.position.x, 0.05)
	if _hp <= 0:
		_break()


func _break() -> void:
	Sfx.play(&"armor_break")
	Combat.shake(5.0)
	_col.set_deferred(&"disabled", true)
	_hurtbox.set_deferred(&"monitorable", false)
	var t := create_tween()
	t.tween_property(_skin, ^"modulate:a", 0.0, 0.15)
	t.tween_property(_skin, ^"scale", Vector2(1.0, 0.05), 0.1)
	t.tween_callback(queue_free)
