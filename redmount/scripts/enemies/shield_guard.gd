## ShieldGuard — Kalkanlı Zabıta (Dan the Man'in kalkanlı polisi).
##
## Önden gelen hafif darbeler (yumruk combosu, silah vuruşu) çevik kuvvet kalkanına
## çarpıp boşa gider; vuran oyuncu geri itilir. Kalkanı aşmanın yolları:
##  * arkadan vur (üstünden zıpla, dolan),
##  * alçaktan vur: çömel tekmesi / kayma tekmesi kalkanın altından girer,
##  * ağır darbe (ağır yumruk, dash vuruşu, patlama) kalkanı düşürür: kısa süre açık,
##  * kendi kalkan darbesinin toparlanmasında kalkan iner.
## Görsel: düşmanın önünde piksel art kalkan (assets/environment/pixel/kalkan*.png).
extends EnemyBase

const SHIELD_TEX := preload("res://assets/environment/pixel/kalkan.png")
const SHIELD_BROKEN_TEX := preload("res://assets/environment/pixel/kalkan_kirik.png")
## Bu eşiklerden birini geçen önden darbe kalkanı düşürür.
const BREAK_DAMAGE := 14
const BREAK_KNOCKBACK := 300.0
const SHIELD_DOWN_TIME := 1.6

var _shield: Sprite2D
var _shield_down := 0.0
var _blocks := 0


func _ready() -> void:
	super._ready()
	_shield = Sprite2D.new()
	_shield.texture = SHIELD_TEX
	_shield.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_shield.scale = Vector2(3, 3)
	_shield.z_index = 1
	add_child(_shield)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _shield == null:
		return
	_shield_down = maxf(_shield_down - delta, 0.0)
	var up := _shield_up()
	_shield.visible = _state != State.DEAD
	_shield.texture = SHIELD_TEX if up else SHIELD_BROKEN_TEX
	_shield.flip_h = _facing < 0
	# Kalkan yukarıdayken gövdenin önünde dik; inikken yana sarkık.
	var target := Vector2(_facing * 22.0, -56.0) if up else Vector2(_facing * 8.0, -34.0)
	if _state == State.ATTACK:
		# Kalkan darbesi: hazırlıkta geri çekilir, vuruşta öne fırlar.
		target = Vector2(_facing * (6.0 if _phase == Phase.WINDUP else 46.0), -58.0)
		_shield.texture = SHIELD_TEX
		_shield.visible = true
	_shield.position = _shield.position.lerp(target, clampf(delta * 14.0, 0.0, 1.0))
	_shield.rotation = lerp_angle(_shield.rotation, 0.0 if up else deg_to_rad(28.0 * _facing), clampf(delta * 10.0, 0.0, 1.0))


func _shield_up() -> bool:
	return _shield_down <= 0.0 and _state in [State.IDLE, State.PATROL, State.ALERT, State.CHASE, State.HURT]


func apply_hit(damage: int, dir: Vector2, knockback: float) -> void:
	if _state == State.DEAD or not _shield_up():
		super.apply_hit(damage, dir, knockback)
		return
	var from_front := signf(dir.x) == -float(_facing) or is_zero_approx(dir.x)
	if not from_front:
		super.apply_hit(damage, dir, knockback)
		return
	var player := get_tree().get_first_node_in_group(&"player")
	var low := player != null and String(player.get("_special_move")) in ["low_kick", "slide_kick"]
	if low:
		# Alçak tekme kalkanın altından girer.
		super.apply_hit(damage, dir, knockback)
		return
	if damage >= BREAK_DAMAGE or knockback >= BREAK_KNOCKBACK:
		_shield_down = SHIELD_DOWN_TIME
		_blocks = 0
		Sfx.play(&"weapon_break", 0.8)
		Combat.shake(5.0)
		Fx.spark(global_position + Vector2(_facing * 24.0, -60.0), Vector2(-_facing, -0.4), 14, Color(0.75, 0.85, 1.0), 1.3)
		Fx.popup(global_position + Vector2(0, -130), "KALKAN DÜŞTÜ!", Color(1.0, 0.82, 0.45), 22)
		super.apply_hit(int(roundf(damage * 0.5)), dir, knockback * 0.5)
		return
	# Hafif önden darbe: kalkana çarpar, vuran geri itilir.
	_blocks += 1
	Sfx.play(&"shield", 1.0)
	Combat.shake(2.0)
	Fx.spark(global_position + Vector2(_facing * 26.0, -62.0), Vector2(-_facing, -0.3), 7, Color(0.8, 0.9, 1.0))
	if player is CharacterBody2D:
		(player as CharacterBody2D).velocity.x = float(_facing) * 240.0
	velocity.x = -float(_facing) * 40.0
	# Üç darbe karşıladıktan sonra hemen kalkan darbesiyle karşılık verir.
	if _blocks >= 3 and _attack_cd > 0.0:
		_attack_cd = 0.0
		_blocks = 0
