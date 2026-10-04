## TrainingDummy — dövüş prototipini test etmek için kum torbası (Görev 2).
##
## Gerçek düşman YOK (plan gereği sonraki görevler). Bu düğüm sadece:
##   * apply_hit() ile hasar alır, geri savrulur, yanıp söner, canı biterse
##     kısa süre "K.O." olur ve sonra dolu canla geri gelir.
##   * belirli aralıkla kısa bir "jab" yapar (ContactHitbox açılır) -> Redmount'un
##     hasar alma / knockdown / ölüm tepkilerini test etmeyi sağlar.
##
## Redmount ile simetrik imza: apply_hit(damage, dir, knockback) ve
## get_contact_damage().
extends CharacterBody2D

@export var max_health: int = 40
## Can bitince ne kadar sonra dolu canla döner (sn).
@export var respawn_delay: float = 2.5
## Redmount'a değince verdiği hasar.
@export var contact_damage: int = 9
## İki jab arası süre (sn).
@export var attack_interval: float = 2.0
## Jab öncesi hazırlık (sn) — ContactHitbox henüz kapalı.
@export var attack_windup: float = 0.35
## Jab teması (sn) — ContactHitbox açık.
@export var attack_active: float = 0.12
## Bu düşman jab atsın mı? (kapatınca sadece pasif kum torbası olur.)
@export var attacks_back: bool = true
@export var gravity: float = 1400.0

@onready var _visual: Node2D = $Visual
@onready var _label: Label = $Label
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _contact: Area2D = $ContactHitbox
@onready var _contact_shape: CollisionShape2D = $ContactHitbox/CollisionShape2D

var _health: int = 0
var _downed: bool = false
var _respawn_timer: float = 0.0
var _attack_timer: float = 0.0
var _attack_phase: int = 0 # 0 bekleme, 1 hazırlık, 2 temas
var _facing: int = -1
var _player: Node2D


func _ready() -> void:
	_health = max_health
	_attack_timer = attack_interval
	_player = get_tree().get_first_node_in_group(&"player")
	_set_contact_enabled(false)
	_hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	_refresh_label()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, 1200.0)
	velocity.x = move_toward(velocity.x, 0.0, 1600.0 * delta)
	move_and_slide()

	if _downed:
		_respawn_timer -= delta
		if _respawn_timer <= 0.0:
			_revive()
		return

	_face_player()
	if attacks_back and _player != null:
		_tick_attack(delta)


func _face_player() -> void:
	if _player == null:
		return
	var d := signf(_player.global_position.x - global_position.x)
	if not is_zero_approx(d):
		_facing = int(d)
	_visual.scale.x = -1.0 if _facing < 0 else 1.0
	_contact.position.x = absf(_contact.position.x) * _facing


func _tick_attack(delta: float) -> void:
	_attack_timer -= delta
	match _attack_phase:
		0:
			if _attack_timer <= 0.0:
				_attack_phase = 1
				_attack_timer = attack_windup
				_visual.modulate = Color(1.4, 1.1, 0.6) # hazırlık parlaması
		1:
			if _attack_timer <= 0.0:
				_attack_phase = 2
				_attack_timer = attack_active
				_visual.modulate = Color(1, 1, 1)
				_set_contact_enabled(true)
		2:
			if _attack_timer <= 0.0:
				_attack_phase = 0
				_attack_timer = attack_interval
				_set_contact_enabled(false)


## Redmount'un Hitbox'ı bu Hurtbox'a değince çağrılır (Redmount tarafından).
func apply_hit(damage: int, dir: Vector2, knockback: float) -> void:
	if _downed:
		return
	_health = maxi(_health - damage, 0)
	_refresh_label()
	velocity.x = signf(dir.x) * knockback
	velocity.y = -140.0
	_flash()
	if _health == 0:
		_down()


func get_contact_damage() -> int:
	return contact_damage


func _on_hurtbox_area_entered(_area: Area2D) -> void:
	# Redmount tarafı apply_hit() çağırır; burada bir şey yapmaya gerek yok.
	pass


func _down() -> void:
	_downed = true
	_respawn_timer = respawn_delay
	_attack_phase = 0
	_attack_timer = attack_interval
	_set_contact_enabled(false)
	_hurtbox.set_deferred(&"monitoring", false)
	_hurtbox.set_deferred(&"monitorable", false)
	_visual.modulate = Color(0.35, 0.35, 0.4)
	_visual.rotation_degrees = 90.0 * _facing
	_label.text = "K.O."


func _revive() -> void:
	_downed = false
	_health = max_health
	_hurtbox.set_deferred(&"monitoring", true)
	_hurtbox.set_deferred(&"monitorable", true)
	_visual.modulate = Color(1, 1, 1)
	_visual.rotation_degrees = 0.0
	_refresh_label()


func _flash() -> void:
	_visual.modulate = Color(2, 2, 2)
	var t := create_tween()
	t.tween_property(_visual, ^"modulate", Color(1, 1, 1), 0.12)


func _set_contact_enabled(on: bool) -> void:
	_contact.set_deferred(&"monitoring", on)
	_contact_shape.set_deferred(&"disabled", not on)


func _refresh_label() -> void:
	_label.text = "DUMMY  %d/%d" % [_health, max_health]
