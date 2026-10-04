## BlobShadow — karakterin ayağının altına yumuşak, basık gölge çizer.
## "yere basıyor" hissi verir; ayrı sanat gerektirmez. z_index -1 → Rig'in altında.
extends Node2D

@export var radius: float = 24.0
@export var squash: float = 0.3
@export var alpha: float = 0.32

var _a := 0.32


func _ready() -> void:
	z_index = -1
	_a = alpha


func _process(_delta: float) -> void:
	var p := get_parent()
	var target := alpha
	if p != null and p.has_method(&"is_on_floor") and not p.is_on_floor():
		target = alpha * 0.35
	_a = lerpf(_a, target, 0.25)
	queue_redraw()


func _draw() -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var ang := TAU * float(i) / 20.0
		pts.append(Vector2(cos(ang) * radius, sin(ang) * radius * squash))
	draw_colored_polygon(pts, Color(0, 0, 0, _a))
