## MovingPlatform — iki nokta arasında gidip gelen platform (Görev 15).
##
## `AnimatableBody2D` (sync_to_physics) — üstündeki Redmount'u taşır. `travel`
## başlangıç konumuna göre ofset, `period` tam gidiş-dönüş süresi. `width` görsel
## + çarpışma genişliği. Dünya `PAUSABLE` olduğundan bölüm duraklayınca durur.
extends AnimatableBody2D

const PALLET := preload("res://assets/environment/mahalle/scaffold_deck_v2.png")
const HALAT := preload("res://assets/environment/pixel/halat.png")
const RAIL := preload("res://assets/environment/underground_ground.png")
const FORTRESS_PLATFORM := preload("res://assets/environment/fortress_platform.png")
const CORRIDOR := preload("res://assets/environment/corridor_ground.png")
const ZINCIR := preload("res://assets/environment/pixel/zincir.png")
const MAKARA := preload("res://assets/environment/pixel/makara.png")
const _OWP := preload("res://scripts/systems/one_way_platform.gd")

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
		# Kale asansörü yukarıdan iki zincirle asılı.
		for x in [-hw + 12.0, hw - 12.0]:
			_OWP.tile_down(self, ZINCIR, Rect2(x - 6.0, -58.0, 12.0, 48.0))
		draw_texture_rect(FORTRESS_PLATFORM, Rect2(-hw, -10, width, 36), true)
		_OWP.tile_across(self, _OWP.KENAR_TAS, Rect2(-hw, -13.0, width, 6.0))
		return
	if style == "corridor":
		_OWP.tile_across(self, _OWP.KUSAK_CELIK, Rect2(-hw + 12.0, 88.0, width - 24.0, 8.0))
		for x in [-hw + 12.0, hw - 12.0]:
			_OWP.tile_down(self, _OWP.DIKME_CELIK, Rect2(x - 5.0, 24.0, 10.0, 136.0))
		draw_texture_rect(CORRIDOR, Rect2(-hw, -10, width, 36), true)
		_OWP.tile_across(self, _OWP.KENAR_CELIK, Rect2(-hw, -13.0, width, 6.0))
		return
	if style == "rail":
		_OWP.tile_across(self, _OWP.KUSAK_CELIK, Rect2(-hw + 14.0, -56.0, width - 28.0, 8.0))
		for x in [-hw + 18.0, hw - 18.0]:
			_OWP.tile_down(self, _OWP.DIKME_CELIK, Rect2(x - 5.0, -50.0, 10.0, 40.0))
			draw_texture_rect(MAKARA, Rect2(x - 9.0, 13.0, 18.0, 18.0), false)
		draw_texture_rect(RAIL, Rect2(-hw, -10, width, 32), true)
		return
	# Vinç halatları ve iskele paleti aynı malzeme dilini taşır.
	# Vinç halatları: piksel art halat dokusu (çizgi değil), palet köşelerinden yukarı.
	for hx in [-hw + 14.0, hw - 22.0]:
		var yy := -72.0
		while yy < 12.0:
			draw_texture_rect(HALAT, Rect2(hx, yy, 9.0, minf(24.0, 12.0 - yy)), false)
			yy += 24.0
	draw_texture_rect_region(PALLET, Rect2(-hw, -10, width, 55), Rect2(26, 148, 1931, 535))
