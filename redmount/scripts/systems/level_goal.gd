## LevelGoal — bölüm bitiş noktası (Görev 5).
##
## Oyuncu buraya ulaşınca `reached` yayılır; Main sonuç ekranını açar
## (ana plan md. 21: bölüm sonu sonuç ekranı).
## Görünüm: düz renk kutu yerine piksel sanat taş kemerli çıkış nişi.
extends Area2D

signal reached

const ARCH := preload("res://assets/environment/kit/wall_niche.png")

var _done: bool = false


func _ready() -> void:
	add_to_group(&"level_goal")
	body_entered.connect(_on_body_entered)
	# Eski yarı saydam dikdörtgen; Level._beautify onu gri bloğa çeviriyordu.
	var vis := get_node_or_null(^"Vis")
	if vis != null:
		remove_child(vis)
		vis.queue_free()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = -2
	queue_redraw()


func _draw() -> void:
	var size := Vector2(ARCH.get_width(), ARCH.get_height()) * 1.15
	draw_texture_rect(ARCH, Rect2(Vector2(-size.x * 0.5, -size.y), size), false)


func _on_body_entered(body: Node) -> void:
	if _done or not body.is_in_group(&"player"):
		return
	_done = true
	reached.emit()
