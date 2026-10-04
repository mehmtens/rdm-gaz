## EnemySprite — düşmanların kare-kare sprite görseli (Görev 23).
## char_rig yerine gerçek çizim sayfaları. enemy_base.gd `set_anim(...)` çağırır.
## Eksik durumlar en yakın kareyle + kod eğimiyle taklit edilir.
extends AnimatedSprite2D

const CELL_H := 240.0
const FOOT_PAD := 6.0
## Atlas hücresi 200×240 → uzak arcade ölçeği (karakter ~120px ekran boyu).
const RIG_SCALE := 0.6

var facing: int = 1:
	set(v):
		facing = signi(v) if v != 0 else facing
		flip_h = facing < 0   # atlas sağa bakar (Redmount ile aynı) → sola bakınca aynala

# char_rig ile uyum için — enemy_base._setup_rig bunları set eder, sessizce yut
var palette: Dictionary = {}
var head_style: String = ""
var hold_rifle: bool = false
var body_scale: float = 1.0:
	set(v):
		body_scale = v
		scale = Vector2(v, v) * RIG_SCALE

var _state := "IDLE"
var _rot := 0.0
## Bu durum için gerçek çizilmiş "yere düşme" karesi var mı? (varsa kod eğimi uygulama)
var _has_down_frame := false


func _ready() -> void:
	centered = true
	offset = Vector2(0, -(CELL_H * 0.5 - FOOT_PAD))
	if is_equal_approx(scale.x, 1.0):
		scale = Vector2(RIG_SCALE, RIG_SCALE)
	if sprite_frames != null:
		play(&"idle")


func set_anim(state: String, attack: String, _phase: int, _pp: float, _combo: int,
		fdir: int, _prefix := "") -> void:
	_state = state
	facing = fdir
	if sprite_frames == null:
		return
	var want := "idle"
	var spd := 1.0
	match state:
		"IDLE", "ALERT":
			want = "idle"
		"PATROL", "CHASE", "RETREAT", "DASH", "EVADE", "LEAP":
			want = _pick(state.to_lower(), "walk")
			if state in ["CHASE", "DASH"]:
				spd = 1.4
		"ATTACK":
			if attack == "HEAVY":
				want = _pick("attack_heavy", "attack")
			else:
				want = _pick("attack2", "attack") if _combo % 2 == 1 else _pick("attack", "idle")
		"RANGED":
			want = _pick("shoot", "aim", "attack")
		"BLOCK":
			want = _pick("block", "idle")
		"ARMOR_BREAK":
			want = _pick("guard_break", "special", "hurt")
		"HURT":
			want = _pick("hurt", "idle")
		"KNOCKDOWN":
			want = _pick("knockdown", "dead", "hurt")
			_has_down_frame = want == "knockdown" or want == "dead"
		"DEAD":
			want = _pick("dead", "knockdown", "hurt")
			_has_down_frame = want == "dead" or want == "knockdown"
	speed_scale = spd
	if animation != want:
		play(want)
	elif not sprite_frames.get_animation_loop(want) and not is_playing():
		pass  # tek-sefer bitti, son karede kal


func _pick(a: String, b := "", c := "") -> String:
	for n in [a, b, c]:
		if n != "" and sprite_frames != null and sprite_frames.has_animation(n):
			return n
	return "idle"


func _process(delta: float) -> void:
	if sprite_frames == null:
		return
	var tr := 0.0
	match _state:
		"HURT":
			tr = deg_to_rad(12.0 * facing)
		"KNOCKDOWN":
			tr = 0.0 if _has_down_frame else deg_to_rad(78.0 * facing)
		"DEAD":
			tr = 0.0 if _has_down_frame else deg_to_rad(82.0 * facing)
	_rot = lerp_angle(_rot, tr, clampf(delta * 11.0, 0.0, 1.0))
	rotation = _rot


func ghost(_color: Color) -> void:
	pass
