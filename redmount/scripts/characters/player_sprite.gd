## PlayerSprite — Redmount'un kare-kare sprite görseli (Görev 23).
##
## char_rig (prosedürel iskelet) yerine gerçek çizim sprite sayfaları.
## redmount.gd her fizik karesinde `set_anim(...)` çağırır; burada durum + silah
## öneki + saldırı fazı bir animasyon adına eşlenir ve `play()` edilir.
## Eksik durumlar (hurt/knockdown/dead/wallslide için özel sayfa yok) en yakın
## kareyle + kod-güdümlü eğim/renk ile taklit edilir.
##
## Origin = ayakların orta-altı (sprite hücresi 200×240, altta 6px pad).
extends AnimatedSprite2D

const CELL_H := 240.0
const FOOT_PAD := 6.0

var facing: int = 1:
	set(v):
		facing = signi(v) if v != 0 else facing
		flip_h = facing < 0

var _state := "IDLE"
var _attack := ""
var _phase := 0
var _pp := 0.0
var _combo := 0
var _prefix := ""          # "" | bat | knife | pistol | rifle
var _rot := 0.0            # yumuşatılmış gövde eğimi (hurt/dead)
var _t := 0.0
var _action_override: StringName = &""
var _action_until_ms: int = 0


func _ready() -> void:
	centered = true
	offset = Vector2(0, -(CELL_H * 0.5 - FOOT_PAD))
	animation_finished.connect(_on_anim_finished)
	play(&"idle")


## redmount.gd _apply_proc_anim'den. weapon_prefix: yakın dövüş silahı öneki;
## gun_prefix: ateşli silah öneki ("pistol"/"rifle"); ikisi de boşsa silahsız.
func set_anim(state: String, attack: String, phase: int, pp: float, combo: int,
		fdir: int, weapon_prefix: String, gun_prefix := "") -> void:
	_state = state
	_attack = attack
	_phase = phase
	_pp = pp
	_combo = combo
	facing = fdir
	var melee := state == "ATTACK" and attack in ["COMBO", "HEAVY", "WEAPON", "AIR_KNEE", "LOW_KICK", "UPPERCUT", "DASH_STRIKE", "GROUND_SLAM"]
	if melee and weapon_prefix != "":
		_prefix = weapon_prefix
	else:
		_prefix = gun_prefix if gun_prefix != "" else weapon_prefix
	_refresh()


func _p(base: String) -> String:
	## Silah önekli varyant varsa onu, yoksa silahsız adı döndür.
	if _prefix != "":
		var cand := "%s_%s" % [_prefix, base]
		if sprite_frames != null and sprite_frames.has_animation(cand):
			return cand
	if sprite_frames != null and sprite_frames.has_animation(base):
		return base
	return "idle"


func _refresh() -> void:
	var want := "idle"
	var loop_from_start := true
	var spd := 1.0
	match _state:
		"IDLE", "CROUCH":
			want = _p("crouch") if _state == "CROUCH" else _p("idle")
		"MOVE":
			want = _p("walk")
		"RUN":
			want = _p("run") if _prefix == "" else _p("walk")
			spd = 1.0 if _prefix == "" else 1.5
		"DASH":
			want = _p("run")
			spd = 2.0
		"JUMP", "WALLSLIDE":
			want = _p("jump")
			loop_from_start = false
		"FALL":
			want = _p("jump")
			loop_from_start = false
		"LAND":
			want = _p("land") if sprite_frames.has_animation(_p_raw("land")) else _p("crouch")
			loop_from_start = false
		"ATTACK":
			want = _attack_anim()
			loop_from_start = false
			spd = 0.0
		"HURT":
			# gerçek "vuruş yeme" karesi yok → dövüş duruşunda kasılma (dönüş YOK)
			want = "fight" if _has("fight") else _p("idle")
			loop_from_start = false
		"KNOCKDOWN", "DEAD":
			# havada savrulurken diz-çekik "jump", yerde kıvrık "crouch" karesi (dönüşle yatar)
			var airborne: bool = owner != null and owner.has_method(&"is_on_floor") and not owner.is_on_floor()
			if airborne and _has("jump"):
				want = "jump"
			elif _has("crouch"):
				want = "crouch"
			else:
				want = "fight" if _has("fight") else _p("idle")
			loop_from_start = false
	if _action_override != &"" and Time.get_ticks_msec() < _action_until_ms:
		var action_name := _p(String(_action_override))
		if _has(action_name):
			want = action_name
			loop_from_start = false
			spd = 1.0
	else:
		_action_override = &""

	speed_scale = spd
	if animation != want or (loop_from_start and not is_playing()):
		play(want)
	elif not loop_from_start and animation != want:
		play(want)
	if _state == "ATTACK" and _action_override == &"" and sprite_frames != null:
		var count := sprite_frames.get_frame_count(animation)
		if count > 0:
			frame = _attack_phase_frame(count)


func _p_raw(base: String) -> String:
	return "%s_%s" % [_prefix, base] if _prefix != "" else base


func _has(name: String) -> bool:
	return sprite_frames != null and sprite_frames.has_animation(name)


func _attack_anim() -> String:
	match _attack:
		"COMBO":
			if _prefix in ["bat", "knife"]:
				return _p("attack") if _combo % 2 == 0 else _p("attack2")
			if _prefix in ["pistol", "rifle"]:
				return _p("shoot")
			# silahsız üçlü combo: jab-düz / kroşe / dönüşlü kroşe
			return "combo_a" if _combo % 3 == 1 else "combo_b"
		"HEAVY":
			if _prefix in ["bat", "knife"]:
				return _p("attack2")
			return "combo_b"
		"LOW_KICK", "GROUND_SLAM":
			return "knee" if _has("knee") else "combo_b"
		"UPPERCUT":
			return "combo_b"
		"DASH_STRIKE":
			return "combo_a"
		"WEAPON":
			return _p("attack")
		"AIR_KNEE":
			return "knee" if _has("knee") else "combo_b"
		"SHOOT":
			return _p("shoot")
	return _p("idle")


func _attack_phase_frame(count: int) -> int:
	var first_contact := clampi(int(ceil(count * 0.30)), 1, count - 1)
	var last_contact := clampi(int(ceil(count * 0.65)), first_contact, count - 1)
	match _phase:
		0:
			return clampi(int(round(lerpf(0.0, float(first_contact - 1), _pp))), 0, count - 1)
		1:
			return clampi(int(round(lerpf(float(first_contact), float(last_contact), _pp))), 0, count - 1)
		_:
			return clampi(int(round(lerpf(float(last_contact), float(count - 1), _pp))), 0, count - 1)


func play_action(base: StringName, duration := 0.18) -> void:
	var action_name := _p(String(base))
	if not _has(action_name):
		return
	_action_override = base
	_action_until_ms = Time.get_ticks_msec() + int(duration * 1000.0)
	_refresh()


func _on_anim_finished() -> void:
	# tek-sefer animasyonlar bitince son karede kalsın (varsayılan davranış);
	# jump biterse fall gibi asılı dursun.
	pass


func reset_visual_state() -> void:
	rotation = 0.0
	skew = 0.0
	position = Vector2.ZERO
	_rot = 0.0
	modulate = Color.WHITE
	self_modulate = Color.WHITE
	visible = true
	_action_override = &""
	play(&"idle")


func _process(delta: float) -> void:
	_t += delta
	var target_rot := 0.0
	var target_skew := 0.0
	var target_pos := Vector2.ZERO
	var rot_k := 12.0
	match _state:
		# HURT: dönüş YOK — geri kaykılma + kısa sarsıntı (hacıyatmaz efekti kalktı)
		"HURT":
			target_skew = deg_to_rad(9.0 * facing)
			target_pos = Vector2(-facing * 5.0, -2.0)
		"KNOCKDOWN":
			target_rot = deg_to_rad(-84.0 * facing)
			rot_k = 16.0
		"DEAD":
			target_rot = deg_to_rad(-90.0 * facing)
			rot_k = 9.0
		"DASH":
			target_skew = deg_to_rad(-10.0 * facing)
		"RUN":
			target_skew = deg_to_rad(-4.0 * facing)
		"WALLSLIDE":
			target_skew = deg_to_rad(8.0 * facing)
	_rot = lerp_angle(_rot, target_rot, clampf(delta * rot_k, 0.0, 1.0))
	rotation = _rot
	skew = lerp_angle(skew, target_skew, clampf(delta * 10.0, 0.0, 1.0))
	position = position.lerp(target_pos, clampf(delta * 14.0, 0.0, 1.0))


## Hız izi / dash trail — mevcut kareyi sabit noktada soluk bırakır.
func ghost(color: Color) -> void:
	var scene := get_tree().current_scene
	if scene == null or sprite_frames == null:
		return
	var g := Sprite2D.new()
	g.texture = sprite_frames.get_frame_texture(animation, frame)
	g.centered = centered
	g.offset = offset
	g.flip_h = flip_h
	g.global_position = global_position
	g.rotation = rotation
	g.scale = scale
	g.skew = skew
	g.self_modulate = color
	g.z_index = z_index - 1
	scene.add_child(g)
	var tw := g.create_tween()
	tw.tween_property(g, "self_modulate:a", 0.0, 0.22)
	tw.tween_callback(g.queue_free)
