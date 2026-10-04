## Crusher — tavandan periyodik inen ezici blok (Görev 25).
##
## AnimatableBody2D; `drop_height` kadar aşağı iner, kısa bekler, geri çıkar.
## İnmeden hemen önce titreyerek telegraph verir. Alt yüzünde hasar Area2D'si —
## oyuncuyu yakalarsa `damage` + yukarı-yana savurma. Zamanla koşarak altından
## geçme ritmi. Dünya PAUSABLE olduğundan bölüm duraklayınca donar.
class_name Crusher
extends AnimatableBody2D

@export var width: float = 90.0
@export var thickness: float = 60.0
## Ne kadar aşağı iner (px).
@export var drop_height: float = 150.0
## Tam döngü süresi (sn).
@export var period: float = 3.0
## Döngüde ne kadar erken telegraph başlar (sn).
@export var telegraph: float = 0.5
@export var damage: int = 16
@export var phase_offset: float = 0.0

var _col: CollisionShape2D
var _vis: Polygon2D
var _hit: Area2D
var _base: Vector2
var _t: float = 0.0
var _hit_lock: float = 0.0


func _ready() -> void:
	sync_to_physics = false
	_base = position
	_t = phase_offset * period

	_col = CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(width, thickness)
	_col.shape = r
	add_child(_col)

	var hw := width * 0.5
	var ht := thickness * 0.5
	_vis = Polygon2D.new()
	_vis.polygon = PackedVector2Array([
		Vector2(-hw, -ht), Vector2(hw, -ht), Vector2(hw, ht), Vector2(-hw, ht)])
	_vis.color = Color(0.26, 0.24, 0.28)
	add_child(_vis)
	# alt kenar dişleri
	var teeth := Polygon2D.new()
	var pts := PackedVector2Array()
	var n := maxi(3, int(width / 18.0))
	for i in n:
		var x0 := -hw + width * float(i) / float(n)
		pts.append(Vector2(x0, ht))
		pts.append(Vector2(x0 + width / float(n) * 0.5, ht + 12.0))
		pts.append(Vector2(x0 + width / float(n), ht))
	teeth.polygon = pts
	teeth.color = Color(0.5, 0.13, 0.12)
	add_child(teeth)

	_hit = Area2D.new()
	_hit.collision_layer = 0
	_hit.collision_mask = 2
	var hc := CollisionShape2D.new()
	var hr := RectangleShape2D.new()
	hr.size = Vector2(width + 6.0, thickness + 24.0)
	hc.shape = hr
	hc.position = Vector2(0, 10.0)
	_hit.add_child(hc)
	add_child(_hit)


func _physics_process(delta: float) -> void:
	_t = fmod(_t + delta, period)
	_hit_lock = maxf(_hit_lock - delta, 0.0)
	var f := _t / period
	var down := 0.0
	# 0..tel: bekle (üstte, telegraph titremesi son kısmında)
	# tel..tel+0.12: hızlı in
	# tel+0.12..tel+0.5: aşağıda bekle
	# tel+0.5..1: yukarı çık
	var slam_start := telegraph / period
	var slam_dur := 0.12
	var hold_dur := 0.34
	if f < slam_start:
		down = 0.0
		var to_slam := slam_start - f
		if to_slam < 0.28:
			_vis.position.x = sin(_t * 90.0) * 2.0
		else:
			_vis.position.x = 0.0
	elif f < slam_start + slam_dur:
		down = ((f - slam_start) / slam_dur)
		down = down * down
	elif f < slam_start + slam_dur + hold_dur:
		down = 1.0
	else:
		var up_f := (f - slam_start - slam_dur - hold_dur) / maxf(0.0001, 1.0 - slam_start - slam_dur - hold_dur)
		down = 1.0 - clampf(up_f, 0.0, 1.0)

	position = _base + Vector2(0, drop_height * down)

	if down >= 0.98 and _hit_lock <= 0.0:
		for b in _hit.get_overlapping_bodies():
			if b.is_in_group(&"player") and b.has_method(&"apply_hit"):
				b.apply_hit(damage, Vector2(0.0, 1.0), 260.0)
				_hit_lock = period * 0.9
				Combat.shake(5.0)
				Fx.dust(global_position + Vector2(0, drop_height * 0 + thickness * 0.5), 0, 6)
