## LevelGoal — bölüm bitiş noktası (Görev 5).
##
## Oyuncu buraya ulaşınca `reached` yayılır; Main sonuç ekranını açar
## (ana plan md. 21: bölüm sonu sonuç ekranı).
extends Area2D

signal reached

var _done: bool = false


func _ready() -> void:
	add_to_group(&"level_goal")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _done or not body.is_in_group(&"player"):
		return
	_done = true
	reached.emit()
