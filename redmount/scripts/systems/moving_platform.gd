## MovingPlatform — iki nokta arasında gidip gelen platform (Görev 15).
##
## `AnimatableBody2D` (sync_to_physics) — üstündeki Redmount'u taşır. `travel`
## başlangıç konumuna göre ofset, `period` tam gidiş-dönüş süresi. `width` görsel
## + çarpışma genişliği. Dünya `PAUSABLE` olduğundan bölüm duraklayınca durur.
extends AnimatableBody2D

const PALLET := preload("res://assets/environment/mahalle/scaffold_deck_v2.png")
const RAIL := preload("res://assets/environment/underground_ground.png")
const FORTRESS_PLATFORM := preload("res://assets/environment/fortress_platform.png")
const CORRIDOR := preload("res://assets/environment/corridor_ground.png")

## Başlangıç konumuna göre uç nokta ofseti (px).
@export var travel: Vector2 = Vector2(220, 0)
## Bir tam salınım (git + dön) süresi (sn).
@export var period: float = 3.4
## Platform genişliği (px).
@export var width: float = 150.0
@export_enum("pallet", "rail", "fortress", "corridor") var style: String = "pallet"
## Başlangıçta faz kaydırma (0..1) — birden çok platformu ofsetlemek için.
@export_range(0.0, 1.0) var phase_offset: float = 0.0

@onready var _col: CollisionShape2D = $CollisionShape2D
@onready var _vis: Polygon2D = $Vis

var _start: Vector2
var _t: float = 0.0


func _ready() -> void:
	_start = position
	_t = phase_offset * period
	var s := _col.shape
	if s is RectangleShape2D:
		var r := (s as RectangleShape2D).duplicate() as RectangleShape2D
		r.size = Vector2(width, 20.0)
		_col.shape = r
	var hw := width * 0.5
	_vis.polygon = PackedVector2Array([
		Vector2(-hw, -10), Vector2(hw, -10), Vector2(hw, 10), Vector2(-hw, 10),
	])
	var trim := get_node_or_null(^"Trim")
	if trim is Line2D:
		(trim as Line2D).points = PackedVector2Array([Vector2(-hw, -10), Vector2(hw, -10)])
		(trim as Line2D).visible = false
	_vis.visible = false
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()


func _physics_process(delta: float) -> void:
	_t += delta
	var safe_period := maxf(period, 0.1)
	var a := (1.0 - cos(_t / safe_period * TAU)) * 0.5  # 0→1→0 yumuşak gidip gelme
	position = _start + travel * a


func _draw() -> void:
	var hw := width * 0.5
	if style == "fortress":
		draw_line(Vector2(-hw + 12, -10), Vector2(-hw + 12, -55), Color("8c7155"), 4)
		draw_line(Vector2(hw - 12, -10), Vector2(hw - 12, -55), Color("8c7155"), 4)
		draw_texture_rect(FORTRESS_PLATFORM, Rect2(-hw, -10, width, 36), true)
		draw_line(Vector2(-hw, -10), Vector2(hw, -10), Color("ac9990"), 5)
		return
	if style == "corridor":
		for x in [-hw + 12.0, hw - 12.0]:
			draw_line(Vector2(x, 24), Vector2(x, 160), Color("414653"), 5)
		draw_line(Vector2(-hw + 12, 160), Vector2(hw - 12, 24), Color("616672"), 3)
		draw_texture_rect(CORRIDOR, Rect2(-hw, -10, width, 36), true)
		draw_line(Vector2(-hw, -10), Vector2(hw, -10), Color("a2a7b7"), 5)
		return
	if style == "rail":
		draw_line(Vector2(-hw + 18, -52), Vector2(hw - 18, -52), Color("414c56"), 5)
		for x in [-hw + 18.0, hw - 18.0]:
			draw_line(Vector2(x, -52), Vector2(x, -10), Color("8d785d"), 4)
			draw_circle(Vector2(x, 15), 8, Color("27313d"))
		draw_texture_rect(RAIL, Rect2(-hw, -10, width, 32), true)
		return
	# Vinç halatları ve iskele paleti aynı malzeme dilini taşır.
	draw_line(Vector2(-hw + 18, 12), Vector2(-hw + 18, -72), Color("a48c68"), 4)
	draw_line(Vector2(hw - 18, 12), Vector2(hw - 18, -72), Color("a48c68"), 4)
	draw_line(Vector2(-hw + 18, -72), Vector2(hw - 18, -72), Color("5e5140"), 5)
	draw_texture_rect_region(PALLET, Rect2(-hw, -10, width, 55), Rect2(26, 148, 1931, 535))
