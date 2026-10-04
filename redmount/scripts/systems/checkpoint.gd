## Checkpoint — kontrol noktası (Görev 5).
##
## Oyuncu değince yeni spawn noktası olur (ana plan md. 19: ara kayıt yerine
## kontrol noktası). Bir kez tetiklenir; bayrak rengi değişir.
extends Area2D

signal activated(global_pos: Vector2)

@onready var _flag: Polygon2D = $Flag

var _used: bool = false


func _ready() -> void:
	add_to_group(&"checkpoint")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _used or not body.is_in_group(&"player"):
		return
	_used = true
	_flag.color = Color(0.4, 0.85, 0.45)
	Sfx.play(&"checkpoint")
	activated.emit(global_position)
