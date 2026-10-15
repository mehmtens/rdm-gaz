## Checkpoint — kontrol noktası (Görev 5).
##
## Oyuncu değince yeni spawn noktası olur (ana plan md. 19: ara kayıt yerine
## kontrol noktası). Bir kez tetiklenir. Görünüm: piksel art Osmanlı sancağı
## (assets/environment/pixel/sancak.png, tools/gen_pixel_props.py): pasifken gri
## ve sarkık, tetiklenince kırmızı-altın açılır ve rüzgârda dalgalanır.
extends Area2D

signal activated(global_pos: Vector2)

const SANCAK := preload("res://assets/environment/pixel/sancak.png")
const SCALE := 3.0
const FRAMES := 5

var _used: bool = false
var _sprite: Sprite2D
var _t := 0.0


func _ready() -> void:
	add_to_group(&"checkpoint")
	body_entered.connect(_on_body_entered)
	for n in [&"Pole", &"Flag"]:
		var old := get_node_or_null(NodePath(n))
		if old != null:
			old.queue_free()
	_sprite = Sprite2D.new()
	_sprite.texture = SANCAK
	_sprite.hframes = FRAMES
	_sprite.frame = 0
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2(SCALE, SCALE)
	# Direk sanat x=5'te, kaidenin altı y=80'de: ikisi de düğümün kökene otursun.
	var fw := SANCAK.get_width() / FRAMES
	_sprite.position = Vector2((fw * 0.5 - 5.0) * SCALE, -(80.0 - SANCAK.get_height() * 0.5) * SCALE)
	_sprite.z_index = -2
	add_child(_sprite)
	set_process(false)


func _process(delta: float) -> void:
	_t += delta
	_sprite.frame = 1 + int(_t * 8.0) % 4


func _on_body_entered(body: Node) -> void:
	if _used or not body.is_in_group(&"player"):
		return
	_used = true
	set_process(true)
	Sfx.play(&"checkpoint")
	Fx.spark(global_position + Vector2(20, -190), Vector2.ZERO, 10, Color(1.0, 0.85, 0.4), 1.0)
	activated.emit(global_position)
