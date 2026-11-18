## GameCamera — Redmount'u takip eden kamera + geri bildirim (Görev 2 / Görev 19).
##
## Takip/yumuşatma ve seviye sınırları sahnede (Redmount.tscn) ayarlıdır.
## `Combat` autoload sinyalleriyle: rastgele sarsıntı + yön belirli "dip" + kısa
## zoom "punch". Hepsi zamanla nötre döner.
extends Camera2D

@export var shake_decay: float = 40.0
## Bakış yönünde ne kadar öne bakılsın (px).
@export var look_ahead: float = 64.0
@export var mobile_look_ahead: float = 88.0
## Düşerken aşağı kayma (px).
@export var fall_look: float = 40.0
## Dikey çapa (DTM tarzı platforma oturan kamera): sıradan zıplamada kamera yerinde
## kalır; oyuncu kalkış seviyesinin bu kadar üstüne çıkınca (duvar tırmanışı) izler.
@export var rise_margin: float = 110.0
## Yüksek zeminde (kule, iskele üstü) alttaki yer görünsün: altındaki zemine uzaklığın
## `high_from` px'i aşan kısmının `high_bias` katı kadar kadraj aşağı kayar (en çok `high_max`).
@export var high_from: float = 160.0
@export var high_bias: float = 0.75
@export var high_max: float = 140.0

var _shake: float = 0.0
var _dip: Vector2 = Vector2.ZERO
var _zoom_extra: float = 0.0
var _base_zoom: Vector2 = Vector2.ONE
var _lead: Vector2 = Vector2.ZERO
var _base_y: float = 0.0
var _anchor_y: float = NAN
var _prev_y: float = NAN
var _high: float = 0.0
@onready var _body: CharacterBody2D = get_parent() as CharacterBody2D


func _ready() -> void:
	_base_zoom = zoom
	_base_y = position.y
	Combat.shake_requested.connect(func(s: float) -> void: _shake = maxf(_shake, s))
	Combat.dip_requested.connect(func(o: Vector2) -> void: _dip += o)
	Combat.zoom_requested.connect(func(a: float) -> void: _zoom_extra = maxf(_zoom_extra, a))


func _process(delta: float) -> void:
	if not _lead.is_finite() or not _dip.is_finite():
		_lead = Vector2.ZERO
		_dip = Vector2.ZERO
	var off := Vector2.ZERO

	# Bakış yönü + düşüş öngörüsü — hızlı platformda ileriyi/aşağıyı göster.
	if _body != null and _body.global_position.is_finite() and _body.velocity.is_finite():
		var target := Vector2.ZERO
		if absf(_body.velocity.x) > 20.0:
			target.x = signf(_body.velocity.x) * (mobile_look_ahead if TouchControls.active_on_device() else look_ahead)
		if not _body.is_on_floor() and _body.velocity.y > 120.0:
			target.y = fall_look
		_lead = _lead.lerp(target, clampf(delta * 3.5, 0.0, 1.0))
		off += _lead

	if _shake > 0.0:
		off += Vector2(randf_range(-_shake, _shake), randf_range(-_shake, _shake))
		_shake = move_toward(_shake, 0.0, shake_decay * delta)

	if _dip.length() > 0.5:
		off += _dip
		_dip = _dip.lerp(Vector2.ZERO, clampf(delta * 9.0, 0.0, 1.0))
	else:
		_dip = Vector2.ZERO

	offset = off if off.is_finite() else Vector2.ZERO
	_frame_vertical(delta)

	if _zoom_extra > 0.001:
		_zoom_extra = move_toward(_zoom_extra, 0.0, delta * 0.6)
	zoom = _base_zoom * (1.0 + _zoom_extra)


## Dikey çapa: kameranın yerel konumu, gövde yerine çapayı izleyecek şekilde kaydırılır;
## Camera2D yumuşatması bu hedefe uygulanır (offset'e yazılsaydı yumuşatmayla çakışırdı).
func _frame_vertical(delta: float) -> void:
	if _body == null or not _body.global_position.is_finite():
		return
	var y := _body.global_position.y
	# İlk kare veya ışınlanma (yeniden doğma, kontrol noktası): çapa doğrudan gövdeye.
	if is_nan(_anchor_y) or is_nan(_prev_y) or absf(y - _prev_y) > 240.0:
		_anchor_y = y
		_high = 0.0
	elif _body.is_on_floor():
		_anchor_y = y
	elif y > _anchor_y:
		_anchor_y = y
	elif y < _anchor_y - rise_margin:
		_anchor_y = y + rise_margin
	_prev_y = y
	var high_target := 0.0
	if _body.is_on_floor():
		high_target = _ground_gap_bias()
	elif _high > 0.0 and y <= _anchor_y:
		high_target = _high
	_high = move_toward(_high, high_target, 220.0 * delta)
	position.y = _base_y + (_anchor_y - y) + _high


func _ground_gap_bias() -> float:
	var space := _body.get_world_2d().direct_space_state
	if space == null:
		return 0.0
	var from := _body.global_position + Vector2(0, 6)
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, high_from + high_max / high_bias + 40.0), _body.collision_mask, [_body.get_rid()])
	var hit := space.intersect_ray(q)
	var gap: float = (hit.position.y - from.y) if not hit.is_empty() else 0.0
	return clampf((gap - high_from) * high_bias, 0.0, high_max)
