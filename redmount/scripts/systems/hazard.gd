## Hazard — ölümcül zemin tuzağı: dikenler / lav / elektrik (Görev 15).
##
## Area2D; Redmount değince `touched` yayar. Main bunu dinleyip oyuncuyu son
## kontrol noktasına döndürür (düşme çukuruyla aynı ceza). Grup: "hazard".
## Ana plan md. 15: ölümcül alanlar kamera + zemin diliyle açıkça sezdirilmeli
## (piksel art paslı çivi şeridi, uçları kırmızı).
extends Area2D

## Tuzak genişliği (px).
@export var width: float = 120.0
## Diken yüksekliği (px).
@export var height: float = 26.0

signal touched

@onready var _col: CollisionShape2D = $CollisionShape2D
@onready var _vis: Polygon2D = $Vis

const PIX_SPIKES := preload("res://assets/environment/pixel/diken.png")


func _ready() -> void:
	add_to_group(&"hazard")
	var s := _col.shape
	if s is RectangleShape2D:
		var r := (s as RectangleShape2D).duplicate() as RectangleShape2D
		r.size = Vector2(width, height)
		_col.shape = r
		_col.position = Vector2(0, -height * 0.5)
	# Piksel art çivi şeridi (20x10 sanat, 3x); eski çokgen gizli kalır.
	_vis.visible = false
	var spr := Sprite2D.new()
	spr.texture = PIX_SPIKES
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	spr.region_enabled = true
	spr.region_rect = Rect2(0, 0, roundf(width / 3.0), PIX_SPIKES.get_height())
	spr.scale = Vector2(3, 3)
	spr.centered = false
	spr.position = Vector2(-roundf(width / 3.0) * 1.5, -PIX_SPIKES.get_height() * 3.0 + 2.0)
	add_child(spr)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(&"player"):
		touched.emit()
