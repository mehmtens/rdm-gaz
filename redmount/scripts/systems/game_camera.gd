## GameCamera — Redmount'u takip eden kamera + geri bildirim (Görev 2 / Görev 19).
##
## Takip/yumuşatma ve seviye sınırları sahnede (Redmount.tscn) ayarlıdır.
## `Combat` autoload sinyalleriyle: rastgele sarsıntı + yön belirli "dip" + kısa
## zoom "punch". Hepsi zamanla nötre döner.
extends Camera2D

@export var shake_decay: float = 40.0
## Bakış yönünde ne kadar öne bakılsın (px).
@export var look_ahead: float = 64.0
## Düşerken aşağı kayma (px).
@export var fall_look: float = 40.0

var _shake: float = 0.0
var _dip: Vector2 = Vector2.ZERO
var _zoom_extra: float = 0.0
var _base_zoom: Vector2 = Vector2.ONE
var _lead: Vector2 = Vector2.ZERO
@onready var _body: CharacterBody2D = get_parent() as CharacterBody2D


func _ready() -> void:
	_base_zoom = zoom
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
			target.x = signf(_body.velocity.x) * look_ahead
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

	if _zoom_extra > 0.001:
		_zoom_extra = move_toward(_zoom_extra, 0.0, delta * 0.6)
	zoom = _base_zoom * (1.0 + _zoom_extra)
