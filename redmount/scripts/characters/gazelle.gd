## Gazelle — kaçırılmış sivil, kurtarılmayı bekleyen "prenses" (Görev 12).
##
## Dövüşmez, hareket etmez. Yalnızca esaret ve kurtarılma animasyonları
## (ana plan md. 8 / character-animation-bible "Gazelle"). Karahanlı yenilince
## Main `rescue()` çağırır.
extends Node2D

signal freed

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _rescued: bool = false


func _ready() -> void:
	add_to_group(&"gazelle")
	_sprite.play(&"bound_idle")


func rescue() -> void:
	if _rescued:
		return
	_rescued = true
	_sprite.play(&"rescue_react")
	Sfx.play(&"powerup", 0.9)
	var t := create_tween()
	t.tween_interval(0.7)
	t.tween_callback(func() -> void: _sprite.play(&"freed"))
	t.tween_interval(0.9)
	t.tween_callback(func() -> void: _sprite.play(&"rescue_pose"))
	t.tween_callback(func() -> void: freed.emit())
