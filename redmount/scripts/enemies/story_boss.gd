## StoryBoss — kitap sonu boss'ları (Karahanlı, Ana Vana Muhafızı) için faz deseni.
##
## Dan the Man boss'ları gibi okunabilir iki evre:
##  1. evre: türün normal dövüşü.
##  2. evre (can yarıya inince): "ÖFKE" — kısa duraksama + kırmızı nabız, hız ve
##     saldırı sıklığı artar, iki yardımcı çağırır (arena sayacına katılır) ve her
##     ~6 sn'de "!" uyarılı yere vurma şok dalgası atar (zıplayarak kaçılır).
extends EnemyBase

## Öfke evresinde çağrılan yardımcılar (sahnede ayarlanır).
@export var adds: Array[PackedScene] = []

var _raged := false
var _slam_t := 0.0
var _warn := 0.0


func _ready() -> void:
	config = config.duplicate()
	super._ready()


func apply_hit(damage: int, dir: Vector2, knockback: float) -> void:
	super.apply_hit(damage, dir, knockback)
	if not _raged and not is_dead() and _health <= config.max_health / 2:
		_enter_rage()


func _enter_rage() -> void:
	_raged = true
	config.move_speed *= 1.35
	config.attack_cooldown *= 0.65
	config.heavy_attack_chance = minf(config.heavy_attack_chance + 0.2, 0.8)
	_slam_t = 2.5
	Combat.shake(10.0)
	Combat.flash(Color(1, 0.3, 0.2, 0.35), 0.15)
	Sfx.play(&"heavy_hit", 0.5, 4.0)
	Fx.ring(global_position + Vector2(0, -70), Color(1.0, 0.35, 0.25), 10.0, 220.0, 0.45, 5.0)
	Fx.popup(global_position + Vector2(0, -170), "ÖFKE!", Color(1.0, 0.35, 0.25), 40)
	# Vuruş fizik sorgusu içinde gelir; yardımcının alanları sorgu bitince eklenir.
	for i in adds.size():
		_call_add.call_deferred(adds[i], -1.0 if i % 2 == 0 else 1.0)


## Yardımcıyı ekran kenarından getirir; aktif arenanın sayacına ekler.
func _call_add(scene: PackedScene, side: float) -> void:
	if scene == null:
		return
	var e: Node2D = scene.instantiate()
	get_parent().add_child(e)
	var x := global_position.x + side * 420.0
	for a in get_tree().get_nodes_in_group(&"battle_arena"):
		if a.get("_active") and not a.get("_done"):
			x = clampf(x, float(a.gate_left_x) + 90.0, float(a.gate_right_x) - 90.0)
			if e.has_signal(&"defeated"):
				e.defeated.connect(a._on_enemy_down)
			(a.get("_alive") as Array).append(e)
			a.enemy_spawned.emit(e)
			a.wave_changed.emit(a.get("_wave_idx"), (a.get("_waves") as Array).size(), (a.get("_alive") as Array).size())
	e.global_position = Vector2(x, global_position.y - 24.0)
	Fx.ring(e.global_position + Vector2(0, -70), Color(1.0, 0.55, 0.3), 8.0, 74.0, 0.35)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not _raged or is_dead():
		return
	# Öfke nabzı: gövde kırmızıya çalar.
	sprite.self_modulate = Color(1.0, 0.72 + 0.18 * sin(Time.get_ticks_msec() * 0.008), 0.72)
	if _warn > 0.0:
		_warn -= delta
		if _warn <= 0.0:
			for d in [-1, 1]:
				Shockwave.spawn(get_parent(), global_position, d, config.slam_damage, config.slam_knockback, true)
			Combat.shake(8.0)
			Sfx.play(&"heavy_hit", 0.6)
			Fx.dust(global_position, 0.0, 10)
		return
	_slam_t -= delta
	if _slam_t <= 0.0 and is_on_floor() and _state in [State.CHASE, State.IDLE, State.ALERT]:
		_slam_t = 6.0
		_warn = 0.6
		velocity.x = 0.0
		_telegraph(true, _warn, 170.0)
