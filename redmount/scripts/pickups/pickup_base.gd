## PickupBase — tüm toplanabilirlerin ortak tabanı (Görev 4).
##
## Area2D; yalnızca oyuncu gövdesini (grup "player") algılar. Hafifçe süzülür
## (bob), oyuncu değince `_collect()` (alt sınıf doldurur) çağrılır ve kısa bir
## büyüyüp-sönme efektiyle yok olur (ana plan md. 11 / 18.1).
class_name PickupBase
extends Area2D

## ESKİ — kullanılmıyor (Görev 22 prosedürel ikona geçildi).
@export var icon: Texture2D
## Prosedürel ikon türü. Bkz. pickup_icon.gd. Alt sahne ayarlar.
@export var kind: String = ""
## Süzülme genliği (px) ve hızı.
@export var bob_height: float = 5.0
@export var bob_speed: float = 3.0
## Oyuncu bu yarıçapa girince pickup ona doğru uçar (Görev 19 — mıknatıs hissi).
## 0 = kapalı. Coin'lerde açık, can/silah/zırhta kapalı (istenmeden alınmasın).
@export var magnet_radius: float = 0.0
@export var magnet_speed: float = 640.0

@onready var _sprite: Node2D = $Sprite2D

var _t: float = 0.0
var _base_y: float = 0.0
var _collected: bool = false
var _player: Node2D


func _ready() -> void:
	if kind != "" and "kind" in _sprite:
		_sprite.kind = kind
	_base_y = _sprite.position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta * bob_speed
	_sprite.position.y = _base_y + sin(_t) * bob_height

	if _collected or magnet_radius <= 0.0:
		return
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group(&"player")
		if _player == null:
			return
	var to: Vector2 = _player.global_position + Vector2(0, -60) - global_position
	var d := to.length()
	if d < magnet_radius:
		var pull := magnet_speed * (1.0 - d / magnet_radius)
		global_position += to.normalized() * pull * delta


func _on_body_entered(body: Node) -> void:
	if _collected or not body.is_in_group(&"player"):
		return
	_collected = true
	_collect(body)
	_despawn()


## Alt sınıf doldurur.
func _collect(_player: Node) -> void:
	pass


func _despawn() -> void:
	set_deferred(&"monitoring", false)
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(_sprite, ^"scale", _sprite.scale * 1.6, 0.12)
	t.tween_property(_sprite, ^"modulate:a", 0.0, 0.12)
	t.chain().tween_callback(queue_free)
