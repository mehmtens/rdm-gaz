## Hazard — ölümcül zemin tuzağı: dikenler / lav / elektrik (Görev 15).
##
## Area2D; Redmount değince `touched` yayar. Main bunu dinleyip oyuncuyu son
## kontrol noktasına döndürür (düşme çukuruyla aynı ceza). Grup: "hazard".
## Ana plan md. 15: ölümcül alanlar kamera + zemin diliyle açıkça sezdirilmeli
## (kırmızı diken silueti).
extends Area2D

## Tuzak genişliği (px).
@export var width: float = 120.0
## Diken yüksekliği (px).
@export var height: float = 26.0

signal touched

@onready var _col: CollisionShape2D = $CollisionShape2D
@onready var _vis: Polygon2D = $Vis


func _ready() -> void:
	add_to_group(&"hazard")
	var s := _col.shape
	if s is RectangleShape2D:
		var r := (s as RectangleShape2D).duplicate() as RectangleShape2D
		r.size = Vector2(width, height)
		_col.shape = r
		_col.position = Vector2(0, -height * 0.5)
	# Testere dişi silüet.
	var pts := PackedVector2Array()
	var teeth := maxi(2, int(width / 20.0))
	var step := width / float(teeth)
	pts.append(Vector2(-width * 0.5, 0))
	for i in teeth:
		var x0 := -width * 0.5 + i * step
		pts.append(Vector2(x0 + step * 0.5, -height))
		pts.append(Vector2(x0 + step, 0))
	_vis.polygon = pts


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(&"player"):
		touched.emit()
