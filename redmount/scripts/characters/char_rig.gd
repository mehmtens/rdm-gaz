## CharRig — parçalara ayrılmış prosedürel karakter iskeleti (Görev 21).
##
## Tek kare sprite yerine: gövde / kafa / iki üst kol + iki alt kol + iki uyluk +
## iki baldır ayrı "kemik". `_draw` ileri kinematikle her kemiği yuvarlak kapsül
## olarak çizer. `set_anim(state, ...)` durum + faz bilgisini alıp pozları hesaplar
## — kollar/bacaklar GERÇEKTEN sallanır. Tüm karakterler aynı ölçekte; renk
## paleti dışarıdan verilir (oyuncu / düşman ayrımı palet + boyut oranıyla).
##
## Origin = ayakların orta-altı (128×256 sprite geleneğiyle uyumlu).
extends Node2D

# --- Ölçüler (px) — tüm karakterlerde ortak, tıknaz arcade oranları ---
const HIP_Y := -84.0
const TORSO_LEN := 44.0
const NECK_LEN := 6.0
const HEAD_R := 13.0
const UPARM := 26.0
const LOARM := 24.0
const THIGH := 40.0
const SHIN := 38.0
const ARM_W := 15.0
const LEG_W := 19.0
const TORSO_W := 42.0

var facing: int = 1
var palette: Dictionary = {
	"hair": Color(0.17, 0.12, 0.09), "hair_hi": Color(0.30, 0.21, 0.14),
	"skin": Color(0.86, 0.62, 0.44), "skin_sh": Color(0.70, 0.47, 0.33),
	"jacket": Color(0.13, 0.13, 0.16), "jacket_hi": Color(0.24, 0.24, 0.28),
	"pants": Color(0.16, 0.17, 0.21), "pants_hi": Color(0.24, 0.25, 0.30),
	"shoe": Color(0.9, 0.9, 0.92), "accent": Color(0.8, 0.2, 0.2),
}
## Gövde ölçek çarpanı (mini-boss vb. iri düşmanlar için 1'den büyük).
var body_scale: float = 1.0
## Kafa stili: "hair" / "hood" / "helmet" / "beanie" / "cap" / "slick".
var head_style: String = "hair"
## Sürekli silah tut (tüfekli muhafız) — kollar öne, elde tüfek çizilir.
var hold_rifle: bool = false

# state adı redmount.gd State enum'undan gelir (string olarak)
var _state: String = "IDLE"
var _attack: String = ""
var _phase: int = 0       # 0 windup 1 active 2 recovery
var _pp: float = 0.0      # faz ilerlemesi
var _combo: int = 0
var _t: float = 0.0
var _walk: float = 0.0
var _facef: float = 1.0   # yumuşatılmış facing (dönüş)
var _weapon_prefix: String = ""

# hesaplanan poz (mutlak açı, rad; 0 = aşağı, + = öne)
var _p: Dictionary = {}


func _ready() -> void:
	_p = _rest_pose()
	set_process(true)


func set_anim(state: String, attack: String, phase: int, pp: float, combo: int,
		fdir: int, weapon_prefix: String) -> void:
	_state = state
	_attack = attack
	_phase = phase
	_pp = pp
	_combo = combo
	facing = fdir
	_weapon_prefix = weapon_prefix


const _MOVE_STATES := ["MOVE", "RUN", "DASH", "PATROL", "CHASE", "RETREAT", "EVADE"]
const _RUN_STATES := ["RUN", "CHASE", "EVADE"]


func _process(delta: float) -> void:
	_t += delta
	_facef = move_toward(_facef, float(facing), delta * 12.0)
	if _state in _MOVE_STATES:
		_walk += delta * (17.0 if _state in _RUN_STATES else 11.0)
	var target := _target_pose()
	var k := clampf(delta * 16.0, 0.0, 1.0)
	if _state in ["ATTACK", "HURT", "DASH"]:
		k = clampf(delta * 26.0, 0.0, 1.0)
	for key in target:
		_p[key] = lerp_angle(_p.get(key, 0.0), target[key], k)
	_p["hipy"] = lerpf(_p.get("hipy", 0.0), target.get("hipy", 0.0), k)
	_p["lean"] = lerpf(_p.get("lean", 0.0), target.get("lean", 0.0), k)
	_p["root_rot"] = lerp_angle(_p.get("root_rot", 0.0), target.get("root_rot", 0.0), clampf(delta * 10.0, 0.0, 1.0))
	queue_redraw()


func _rest_pose() -> Dictionary:
	return {
		"thigh_b": 0.04, "shin_b": 0.02, "thigh_f": -0.04, "shin_f": 0.04,
		"uparm_b": 0.14, "loarm_b": 0.26, "uparm_f": -0.08, "loarm_f": 0.30,
		"hipy": 0.0, "lean": 0.04, "root_rot": 0.0,
	}


# -- poz hedefleri --------------------------------------------------

func _target_pose() -> Dictionary:
	var d := _rest_pose()
	match _state:
		"IDLE", "CROUCH":
			var br := sin(_t * 2.6) * 0.02
			d.lean = 0.03 + br
			d.uparm_f = -0.08 + br
			d.uparm_b = 0.10 - br
			if _state == "CROUCH":
				d.hipy = 26.0
				d.thigh_f = -1.1; d.shin_f = 1.6
				d.thigh_b = -1.0; d.shin_b = 1.5
				d.lean = 0.4
		"MOVE", "RUN", "PATROL", "CHASE", "RETREAT", "EVADE":
			var fast := _state in _RUN_STATES
			var amp: float = 0.62 if fast else 0.42
			var s := sin(_walk)
			var s2 := sin(_walk + PI)
			d.thigh_f = -s * amp
			d.shin_f = clampf(0.2 + maxf(s, 0.0) * 1.1, 0.0, 1.4)
			d.thigh_b = -s2 * amp
			d.shin_b = clampf(0.2 + maxf(s2, 0.0) * 1.1, 0.0, 1.4)
			d.uparm_f = s2 * (0.7 if fast else 0.45)
			d.loarm_f = 0.4 + (0.5 if fast else 0.2)
			d.uparm_b = s * (0.7 if fast else 0.45)
			d.loarm_b = 0.4 + (0.5 if fast else 0.2)
			d.hipy = -absf(sin(_walk * 2.0)) * (5.0 if fast else 3.0)
			d.lean = 0.28 if fast else 0.12
		"DASH":
			d.lean = 0.5
			d.thigh_f = -0.9; d.shin_f = 0.5
			d.thigh_b = 0.7; d.shin_b = 0.9
			d.uparm_f = 1.4; d.loarm_f = 0.2
			d.uparm_b = -1.0; d.loarm_b = 0.3
			d.hipy = 6.0
		"JUMP":
			d.thigh_f = -0.7; d.shin_f = 1.0
			d.thigh_b = -0.3; d.shin_b = 0.7
			d.uparm_f = -1.3; d.loarm_f = 0.4
			d.uparm_b = -1.5; d.loarm_b = 0.4
			d.lean = 0.1
		"FALL", "WALLSLIDE":
			d.thigh_f = -0.35; d.shin_f = 0.5
			d.thigh_b = 0.35; d.shin_b = 0.5
			d.uparm_f = -0.7; d.loarm_f = 0.5
			d.uparm_b = 0.7; d.loarm_b = 0.5
			d.lean = -0.06
			if _state == "WALLSLIDE":
				d.lean = -0.2
				d.uparm_f = -1.2; d.uparm_b = -1.4
		"LAND":
			d.hipy = 16.0; d.lean = 0.2
			d.thigh_f = -0.5; d.shin_f = 0.9
			d.thigh_b = -0.5; d.shin_b = 0.9
			d.uparm_f = -0.5; d.uparm_b = -0.6
		"ATTACK":
			_attack_pose(d)
		"ALERT":
			d.lean = 0.08
			d.uparm_f = -0.3; d.loarm_f = 0.8
			d.uparm_b = 0.3; d.loarm_b = 0.7
		"RANGED", "AIM":
			d.lean = 0.05
			d.uparm_f = -1.45; d.loarm_f = 0.15
			d.uparm_b = -1.2; d.loarm_b = 0.5
			d.thigh_f = -0.3; d.shin_f = 0.35
			d.thigh_b = 0.35; d.shin_b = 0.4
		"BLOCK":
			d.lean = 0.12
			d.uparm_f = -1.5; d.loarm_f = 1.7
			d.uparm_b = -1.3; d.loarm_b = 1.6
			d.thigh_f = -0.35; d.shin_f = 0.4
			d.thigh_b = 0.35; d.shin_b = 0.45
			d.hipy = 4.0
		"ARMOR_BREAK":
			d.lean = -0.15 + sin(_t * 26.0) * 0.08
			d.uparm_f = -1.7; d.uparm_b = -1.5
			d.loarm_f = 0.4; d.loarm_b = 0.4
			d.hipy = 6.0
		"LEAP":
			d.thigh_f = -1.5; d.shin_f = 1.7
			d.thigh_b = -0.6; d.shin_b = 1.0
			d.uparm_f = -1.9; d.uparm_b = -1.6
			d.lean = 0.15
		"HURT":
			d.lean = -0.35
			d.uparm_f = -1.4; d.loarm_f = 0.2
			d.uparm_b = -1.6; d.loarm_b = 0.2
			d.thigh_f = 0.5; d.shin_f = 0.3
			d.thigh_b = -0.4; d.shin_b = 0.7
			d.hipy = -4.0
		"KNOCKDOWN":
			# sırtüstü yerde — gövde neredeyse yatay, kalça yere yakın
			d.lean = 1.35
			d.hipy = 62.0
			d.thigh_f = -1.9; d.shin_f = 0.8
			d.thigh_b = -1.5; d.shin_b = 1.4
			d.uparm_f = -0.6; d.loarm_f = 0.4
			d.uparm_b = 0.4; d.loarm_b = 0.4
		"DEAD":
			d.lean = 1.5
			d.hipy = 66.0
			d.thigh_f = -1.7; d.thigh_b = -1.3
			d.shin_f = 0.5; d.shin_b = 1.1
			d.uparm_f = -1.0; d.uparm_b = 0.9
			d.loarm_f = 0.2; d.loarm_b = 0.2
	return d


func _attack_pose(d: Dictionary) -> void:
	# faz: 0 windup, 1 active (temas), 2 recovery
	var wind := _phase == 0
	var act := _phase == 1
	var rec := _phase == 2
	d.thigh_f = -0.25; d.shin_f = 0.25   # hafif duruş (öne adım)
	d.thigh_b = 0.30; d.shin_b = 0.35
	match _attack:
		"COMBO":
			match _combo:
				0:  # jab — ön kol düz ileri
					if wind:
						d.uparm_f = -0.4 - _pp * 0.3; d.loarm_f = 1.4
						d.uparm_b = -0.6; d.loarm_b = 0.6
						d.lean = 0.05
					elif act:
						d.uparm_f = lerpf(-0.7, -1.55, ease(_pp, 0.2)); d.loarm_f = lerpf(1.4, 0.05, ease(_pp, 0.3))
						d.uparm_b = 0.4; d.loarm_b = 0.5
						d.lean = 0.16
					else:
						d.uparm_f = lerpf(-1.55, -0.5, _pp); d.loarm_f = lerpf(0.05, 0.9, _pp)
				1:  # gövde kroşesi — dip + dönüş, dirsek bükük
					if wind:
						d.uparm_f = 0.5; d.loarm_f = 1.7
						d.lean = -0.12; d.hipy = 3.0
					elif act:
						d.uparm_f = lerpf(0.5, -1.1, ease(_pp, 0.2)); d.loarm_f = lerpf(1.7, 0.9, _pp)
						d.lean = lerpf(-0.12, 0.28, ease(_pp, 0.3))
						d.uparm_b = 0.7
					else:
						d.uparm_f = lerpf(-1.1, -0.3, _pp); d.lean = lerpf(0.28, 0.05, _pp)
				_:  # dönüşlü sağ kroşe — büyük savruluş
					if wind:
						d.uparm_f = 1.3; d.loarm_f = 0.8
						d.uparm_b = -1.4; d.lean = -0.3
						d.root_rot = -0.15 * _pp
					elif act:
						d.uparm_f = lerpf(1.3, -1.7, ease(_pp, 0.15)); d.loarm_f = 0.3
						d.lean = lerpf(-0.3, 0.4, ease(_pp, 0.2))
						d.root_rot = lerpf(-0.15, 0.15, _pp)
					else:
						d.uparm_f = lerpf(-1.7, -0.4, _pp); d.lean = lerpf(0.4, 0.05, _pp)
						d.root_rot = lerpf(0.15, 0.0, _pp)
		"HEAVY":
			if wind:
				d.uparm_f = lerpf(0.0, 1.7, ease(_pp, 0.4)); d.loarm_f = 0.9
				d.uparm_b = -1.5; d.lean = lerpf(0.0, -0.4, _pp)
				d.thigh_b = 0.6; d.shin_b = 0.2
				d.hipy = 4.0
			elif act:
				d.uparm_f = lerpf(1.7, -1.6, ease(_pp, 0.12)); d.loarm_f = 0.15
				d.lean = lerpf(-0.4, 0.5, ease(_pp, 0.15))
				d.thigh_f = -0.6; d.shin_f = 0.3
			else:
				d.uparm_f = lerpf(-1.6, -0.4, ease(_pp, 0.6)); d.lean = lerpf(0.5, 0.05, _pp)
		"WEAPON":
			# sopa/bıçak savuruşu — iki el gövdenin önünde, yukarıdan aşağı ark
			var kn := _weapon_prefix.begins_with("knife")
			if wind:
				d.uparm_f = lerpf(0.0, -2.3, ease(_pp, 0.4)); d.loarm_f = -0.6
				d.uparm_b = lerpf(0.0, -2.0, ease(_pp, 0.4)); d.loarm_b = -0.4
				d.lean = lerpf(0.0, -0.25, _pp)
			elif act:
				var e := ease(_pp, 0.12 if not kn else 0.2)
				d.uparm_f = lerpf(-2.3, 1.2, e); d.loarm_f = lerpf(-0.6, 0.3, e)
				d.uparm_b = lerpf(-2.0, 0.9, e); d.loarm_b = lerpf(-0.4, 0.3, e)
				d.lean = lerpf(-0.25, 0.35, e)
			else:
				d.uparm_f = lerpf(1.2, -0.3, _pp); d.uparm_b = lerpf(0.9, 0.1, _pp)
				d.lean = lerpf(0.35, 0.05, _pp)
		"AIR_KNEE":
			d.thigh_f = -1.7; d.shin_f = 2.0
			d.thigh_b = 0.4; d.shin_b = 0.9
			d.uparm_f = -1.0; d.uparm_b = -1.4
			d.lean = 0.2


# -- çizim (ileri kinematik) --------------------------------------

func _dir(a: float) -> Vector2:
	# 0 = aşağı, + = öne (facing yönü). Yerel uzayda "öne" = +x.
	return Vector2(sin(a), cos(a))


func _draw() -> void:
	var f := signf(_facef) if not is_zero_approx(_facef) else 1.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(f, 1.0) * body_scale)

	var pal := palette
	var hip := Vector2(0.0, HIP_Y + _p.get("hipy", 0.0))
	var lean: float = _p.get("lean", 0.0)

	var shoulder := hip + _dir(PI + lean) * TORSO_LEN
	var head_c := shoulder + _dir(PI + lean) * (NECK_LEN + HEAD_R * 0.8)

	var knee_b := hip + _dir(_p.thigh_b) * THIGH
	var foot_b := knee_b + _dir(_p.thigh_b + _p.shin_b) * SHIN
	var knee_f := hip + _dir(_p.thigh_f) * THIGH
	var foot_f := knee_f + _dir(_p.thigh_f + _p.shin_f) * SHIN

	var elb_b := shoulder + _dir(_p.uparm_b) * UPARM
	var hand_b := elb_b + _dir(_p.uparm_b + _p.loarm_b) * LOARM
	var elb_f := shoulder + _dir(_p.uparm_f) * UPARM
	var hand_f := elb_f + _dir(_p.uparm_f + _p.loarm_f) * LOARM

	var d28 := func(c: Color) -> Color: return c.darkened(0.4)

	# ARKA uzuvlar (koyu, biraz geride)
	_leg(hip, knee_b, foot_b, d28.call(pal.pants), d28.call(pal.shoe))
	_arm(shoulder, elb_b, hand_b, d28.call(pal.jacket), d28.call(pal.skin))

	# GÖVDE — tıknaz kapsül ceket
	_capsule(hip + Vector2(0, -3), shoulder, TORSO_W, pal.jacket)
	_capsule(shoulder + _dir(PI + lean) * -2.0, shoulder + _dir(PI + lean) * 4.0,
		TORSO_W * 1.05, pal.jacket_hi)  # omuz vurgusu
	draw_line(hip, shoulder, pal.jacket_hi.darkened(0.15), 3.0, true)  # fermuar

	# ÖN bacak
	_leg(hip, knee_f, foot_f, pal.pants, pal.shoe)

	# KAFA
	_head(head_c, lean, pal)

	# ÖN kol (en üstte)
	_arm(shoulder, elb_f, hand_f, pal.jacket, pal.skin)

	if hold_rifle:
		var rd := (hand_f - elb_f).normalized()
		if rd.length() < 0.1:
			rd = Vector2(1, 0)
		draw_line(hand_b, hand_f + rd * 34.0, Color(0.15, 0.15, 0.17), 6.0, true)
		draw_line(hand_f + rd * 6.0, hand_f + rd * 12.0, Color(0.1, 0.1, 0.12), 10.0)
	if _weapon_prefix != "" and _state == "ATTACK" and _attack == "WEAPON":
		_weapon(elb_f, hand_f)


func _capsule(a: Vector2, b: Vector2, w: float, col: Color) -> void:
	draw_line(a, b, col, w, true)
	draw_circle(a, w * 0.5, col)
	draw_circle(b, w * 0.5, col)


func _arm(sh: Vector2, elb: Vector2, hand: Vector2, col: Color, skin: Color) -> void:
	_capsule(sh, elb, ARM_W, col)
	_capsule(elb, hand, ARM_W * 0.86, col)
	draw_circle(hand, ARM_W * 0.62, skin)  # yumruk


func _leg(hip: Vector2, knee: Vector2, ankle: Vector2, col: Color, shoe: Color) -> void:
	_capsule(hip, knee, LEG_W, col)
	_capsule(knee, ankle, LEG_W * 0.82, col)
	# ayakkabı — öne uzanan kapsül
	var down := (ankle - knee).normalized()
	var fwd := Vector2(down.y, -down.x)  # 90° — öne
	if fwd.x < 0:
		fwd = -fwd
	_capsule(ankle + Vector2(0, 2), ankle + fwd * 15.0 + Vector2(0, 3), LEG_W * 0.7, shoe)


func _head(c: Vector2, _lean: float, pal: Dictionary) -> void:
	var R := HEAD_R
	var hc: Color = pal.hair
	# yüz tabanı
	draw_circle(c, R, pal.skin)
	draw_circle(c + Vector2(R * 0.7, R * 0.2), R * 0.5, pal.skin)
	draw_circle(c + Vector2(R * 0.3, R * 0.62), R * 0.5, pal.skin_sh)
	draw_circle(c + Vector2(-R * 0.35, R * 0.05), R * 0.26, pal.skin_sh)

	match head_style:
		"hood":
			var col: Color = pal.get("cloth", hc)
			draw_circle(c + Vector2(-R * 0.4, -R * 0.35), R * 1.45, col)
			draw_circle(c + Vector2(-R * 0.1, -R * 1.0), R * 0.95, col)
			draw_circle(c + Vector2(-R * 1.1, -R * 0.1), R * 0.75, col)
			draw_circle(c + Vector2(R * 0.25, -R * 0.2), R * 0.75, col)  # yüzü gölgele
			draw_circle(c + Vector2(R * 0.55, -R * 0.05), 2.0, Color(0.9, 0.4, 0.3))  # gözler parlar
		"helmet":
			var col: Color = pal.get("metal", Color(0.3, 0.32, 0.36))
			draw_circle(c + Vector2(-R * 0.15, -R * 0.35), R * 1.25, col)
			draw_rect(Rect2(c.x - R * 0.2, c.y - R * 0.15, R * 1.3, R * 0.5), col.darkened(0.2))  # vizör
			draw_circle(c + Vector2(-R * 0.1, -R * 0.6), R * 0.35, col.lightened(0.2))
		"beanie":
			draw_circle(c + Vector2(-R * 0.55, -R * 0.25), R * 1.05, hc)  # ense saçı
			var col: Color = pal.get("cloth", Color(0.2, 0.22, 0.25))
			draw_circle(c + Vector2(-R * 0.05, -R * 0.55), R * 1.15, col)
			draw_rect(Rect2(c.x - R * 1.05, c.y - R * 0.55, R * 2.1, R * 0.45), col.darkened(0.15))
			draw_circle(c + Vector2(R * 0.5, -R * 0.05), 2.4, Color(0.08, 0.08, 0.1))
		"slick":  # Karahanlı — geriye taralı koyu saç
			draw_circle(c + Vector2(-R * 0.5, -R * 0.35), R * 1.05, hc)
			draw_circle(c + Vector2(0.0, -R * 0.85), R * 0.8, hc)
			draw_circle(c + Vector2(R * 0.45, -R * 0.65), R * 0.45, hc)
			draw_circle(c + Vector2(R * 0.5, -R * 0.05), 2.4, Color(0.08, 0.08, 0.1))
			draw_line(c + Vector2(R * 0.2, -R * 0.4), c + Vector2(R * 0.85, -R * 0.3), Color(0.1, 0.08, 0.07), 3.0)
		_:  # "hair" / "cap"
			draw_circle(c + Vector2(-R * 0.55, -R * 0.25), R * 1.15, hc)
			draw_circle(c + Vector2(-R * 0.15, -R * 0.95), R * 0.85, hc)
			draw_circle(c + Vector2(R * 0.35, -R * 0.9), R * 0.62, hc)
			draw_circle(c + Vector2(-R * 1.0, -R * 0.15), R * 0.55, hc)
			draw_circle(c + Vector2(-R * 0.2, -R * 1.05), R * 0.26, pal.hair_hi)
			if head_style == "cap":
				var col: Color = pal.get("cloth", Color(0.2, 0.2, 0.23))
				draw_circle(c + Vector2(-R * 0.1, -R * 0.7), R * 1.05, col)
				draw_line(c + Vector2(R * 0.1, -R * 0.55), c + Vector2(R * 1.4, -R * 0.35), col.darkened(0.15), 6.0)
			draw_circle(c + Vector2(R * 0.5, -R * 0.1), 2.5, Color(0.08, 0.08, 0.1))
			draw_line(c + Vector2(R * 0.2, -R * 0.42), c + Vector2(R * 0.82, -R * 0.32),
				Color(0.12, 0.09, 0.07), 3.0)


func _weapon(elbow: Vector2, hand: Vector2) -> void:
	var dir := (hand - elbow).normalized()
	if dir.length() < 0.1:
		dir = Vector2(1, 0)
	if _weapon_prefix.begins_with("knife"):
		draw_line(hand, hand + dir * 26.0, Color(0.82, 0.84, 0.9), 4.0, true)
	else:
		draw_line(hand - dir * 6.0, hand + dir * 58.0, Color(0.45, 0.30, 0.18), 12.0, true)
		draw_circle(hand + dir * 58.0, 7.0, Color(0.5, 0.34, 0.2))


## Mevcut pozun tek-renk silüetini sabit noktada bırakır (hız izi / dash trail).
func ghost(color: Color) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var g := _Ghost.new()
	g.pose = _p.duplicate()
	g.f = signf(_facef) if not is_zero_approx(_facef) else 1.0
	g.bscale = body_scale
	g.col = color
	g.global_position = global_position
	g.z_index = z_index - 1
	scene.add_child(g)


class _Ghost extends Node2D:
	var pose: Dictionary
	var f: float = 1.0
	var bscale: float = 1.0
	var col: Color = Color(0.6, 0.8, 1.1, 0.5)
	var _t: float = 0.0
	const DUR := 0.22

	func _process(delta: float) -> void:
		_t += delta
		if _t >= DUR:
			queue_free()
			return
		queue_redraw()

	func _d(a: float) -> Vector2:
		return Vector2(sin(a), cos(a))

	func _draw() -> void:
		var a := col.a * (1.0 - _t / DUR)
		var c := Color(col.r, col.g, col.b, a)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(f, 1.0) * bscale)
		var hip := Vector2(0.0, -84.0 + pose.get("hipy", 0.0))
		var lean: float = pose.get("lean", 0.0)
		var sh := hip + _d(PI + lean) * 44.0
		var kb := hip + _d(pose.thigh_b) * 40.0
		var fb := kb + _d(pose.thigh_b + pose.shin_b) * 38.0
		var kf := hip + _d(pose.thigh_f) * 40.0
		var ff := kf + _d(pose.thigh_f + pose.shin_f) * 38.0
		var eb := sh + _d(pose.uparm_b) * 26.0
		var hb := eb + _d(pose.uparm_b + pose.loarm_b) * 24.0
		var ef := sh + _d(pose.uparm_f) * 26.0
		var hf := ef + _d(pose.uparm_f + pose.loarm_f) * 24.0
		for seg in [[hip, kb], [kb, fb], [hip, kf], [kf, ff], [sh, eb], [eb, hb],
				[sh, ef], [ef, hf], [hip, sh]]:
			draw_line(seg[0], seg[1], c, 14.0, true)
		draw_circle(sh + _d(PI + lean) * 20.0, 15.0, c)
