## Final: okunabilir üç dövüş evresi; temel yumrukla da kazanılabilir.
extends EnemyBase

var phase := 0
var _swing := 0
var attack_phases: Array[int] = []


func _ready() -> void:
	config = config.duplicate()
	super._ready()
	sprite.self_modulate = Color("b7c8de")


func apply_hit(damage: int, dir: Vector2, knockback: float) -> void:
	var committed := _state
	var old_velocity := velocity
	var old_facing := _facing
	var preparing := _dash_preparing
	var hitbox_active := not _hitbox_shape.disabled
	super.apply_hit(damage, dir, knockback)
	if is_dead():
		return
	# Hasar işler; sıradan yumruk hazırlanmış hamleyi iptal etmez.
	# Beş isabetlik zırh kırılması ve kalıcı hareketler bu direnci aşar.
	if committed in [State.ATTACK, State.DASH] and _state == State.HURT:
		_set_state(committed)
		velocity = old_velocity
		_facing = old_facing
		_dash_preparing = preparing
		_set_hitbox_enabled(hitbox_active)
	var next_phase := 2 if _health <= config.max_health / 3 else 1 if _health <= config.max_health * 2 / 3 else 0
	if next_phase <= phase:
		return
	phase = next_phase
	config.uses_dash = phase == 1
	config.move_speed = 115.0 if phase == 1 else 90.0
	config.damage_taken_mult = 0.85 if phase == 1 else 1.0
	config.attack_recovery = 0.65 if phase == 1 else 0.85
	config.heavy_attack_recovery = 1.0
	break_guard()
	Fx.popup(global_position + Vector2(0, -180),
		"II · HAT KOPTU" if phase == 1 else "III · SON EMİR", Color("efc47d"), 25)


func _start_attack() -> void:
	if not attack_phases.has(phase):
		attack_phases.append(phase)
	_swing += 1
	# Sabit ritim: üçüncü darbede dalga; son evrede her ikinci darbede.
	config.heavy_attack_chance = 1.0 if _swing % (2 if phase == 2 else 3) == 0 else 0.0
	super._start_attack()


func _enter_dash_prepare() -> void:
	if not attack_phases.has(phase):
		attack_phases.append(phase)
	super._enter_dash_prepare()
