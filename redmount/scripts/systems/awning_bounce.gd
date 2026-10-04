## AwningBounce — çarşı tentesi sıçrama yüzeyi (Dan the Man tarzı parkur, İstanbul yorumu).
##
## Tezgâhın çizgili kumaş tentesi yalnız üstten basılır; Redmount üstüne indiği an
## gerilen kumaş onu yukarı fırlatır. Zıplama tuşu basılı tutulursa daha yükseğe
## çıkar. Görünüm tamamen mahalle setindeki piksel sanattan gelir: iki ahşap direk,
## altta sandık yığını, üstte kırmızı-beyaz tente.
class_name AwningBounce
extends StaticBody2D

const AWNING := preload("res://assets/environment/mahalle/market_awning_v2.png")
const AWNING_SRC := Rect2(6, 147, 2161, 320)
const POST := preload("res://assets/environment/kit/scaffold_post.png")
const CRATE := preload("res://assets/environment/mahalle/crate_wood_v2.png")

## Normal sıçrama hızı (~240 px yükselir) ve tuş basılıyken (~345 px).
@export var strength: float = 820.0
@export var boosted_strength: float = 985.0
@export var width: float = 180.0
## Tente yüzeyinin zeminden yüksekliği (px, pozitif).
@export var height: float = 64.0

var _squash := 0.0
var _sensor: Area2D


func _ready() -> void:
	# Tezgâh (sandık yığını + tente) katı bir bloktur: önce üstüne çıkılır,
	# sonra kumaş fırlatır. Koşan oyuncu altından geçip duvara çarpmaz.
	collision_layer = 1
	collision_mask = 0
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width - 12.0, height)
	col.shape = shape
	col.position = Vector2(0, -height * 0.5)
	add_child(col)
	_sensor = Area2D.new()
	_sensor.collision_layer = 0
	_sensor.collision_mask = 2  # player
	var s_col := CollisionShape2D.new()
	var s_shape := RectangleShape2D.new()
	s_shape.size = Vector2(width - 16.0, 14.0)
	s_col.shape = s_shape
	s_col.position = Vector2(0, -height - 8.0)
	_sensor.add_child(s_col)
	add_child(_sensor)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = -1


func _physics_process(delta: float) -> void:
	if _squash > 0.0:
		_squash = maxf(_squash - delta * 4.0, 0.0)
		queue_redraw()
	for body in _sensor.get_overlapping_bodies():
		if body is CharacterBody2D and body.is_in_group(&"player") and body.has_method(&"bounce"):
			var cb := body as CharacterBody2D
			if cb.is_on_floor() and cb.velocity.y >= 0.0:
				cb.bounce(strength, boosted_strength)
				_squash = 1.0
				queue_redraw()


func _draw() -> void:
	var hw := width * 0.5
	# Tezgâh altı: sandık yığını, direkler.
	var crate_h := minf(height - 14.0, 54.0)
	var crate_w := crate_h * CRATE.get_width() / CRATE.get_height()
	var cx := -hw + 14.0
	while cx + crate_w <= hw - 10.0:
		draw_texture_rect(CRATE, Rect2(cx, -crate_h, crate_w, crate_h), false, Color("c9b8a6"))
		cx += crate_w + 4.0
	var post_h := height + 4.0
	var post_w := post_h * POST.get_width() / POST.get_height() * 0.55
	for px in [-hw + 2.0, hw - post_w - 2.0]:
		draw_texture_rect(POST, Rect2(px, -post_h, post_w, post_h), false)
	# Kumaş: inişte hafifçe esner (yalnız çizim; çarpışma sabit kalır).
	var sag := 7.0 * _squash
	var cloth_h := 30.0 - sag * 0.4
	draw_texture_rect_region(AWNING, Rect2(-hw - 6.0, -height - 4.0 + sag, width + 12.0, cloth_h + 10.0),
		AWNING_SRC)
