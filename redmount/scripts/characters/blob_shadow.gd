## BlobShadow — karakterin ayağının altına yumuşak, basık gölge çizer.
## "yere basıyor" hissi verir; ayrı sanat gerektirmez. z_index -1 → Rig'in altında.
extends Node2D

const GOLGE := preload("res://assets/environment/pixel/golge.png")

@export var radius: float = 24.0
@export var squash: float = 0.3
@export var alpha: float = 0.32

var _a := 0.32


func _ready() -> void:
	z_index = -1
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_a = alpha


func _process(_delta: float) -> void:
	var p := get_parent()
	var target := alpha
	if p != null and p.has_method(&"is_on_floor") and not p.is_on_floor():
		target = alpha * 0.35
	_a = lerpf(_a, target, 0.25)
	queue_redraw()


func _draw() -> void:
	# Piksel art dither gölge (assets/environment/pixel/golge.png), yarıçapa ölçekli.
	var w := radius * 2.0
	var h := w * GOLGE.get_height() / GOLGE.get_width()
	draw_texture_rect(GOLGE, Rect2(-w * 0.5, -h * 0.5, w, h), false, Color(1, 1, 1, _a / 0.32))
