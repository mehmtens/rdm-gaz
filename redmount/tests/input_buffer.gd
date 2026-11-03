## Meşgulken basılan girdi yutulmasın (telefon testi: "animasyon oynanışı bozmasın").
## Saldırının hazırlık/vuruş fazında, atılmada ve sersemlemede basılan zıplama ve atılma
## tuşu, meşguliyet bitince (ya da geri dönüş fazı başlayınca) yerine getirilmeli.
## Her senaryo: oyuncu yerde, eylem başlar, koşul sağlanınca tuşa tek kare dokunulur,
## en çok 120 kare içinde tepki (zıplama hızı ya da DASH durumu) beklenir. Basış anı
## kare sayısıyla değil fazla seçilir: hitstop (zaman ölçeği 0) kareleri uzatır.
extends Node

const ST_HURT := 7
const ST_DASH := 11

var _p: CharacterBody2D
var _fails := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Save._path = "user://input_buffer_test.cfg"
	GameState.level_index = 0
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	main._load_current_level()
	for i in 60:
		await get_tree().process_frame
		if Cutscene.active != null:
			Cutscene.active._skip = true
	while Cutscene.active != null:
		await get_tree().process_frame
	get_tree().paused = false
	_p = main.get_node(^"Redmount")
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		e.queue_free()

	var heavy := func(): _p._start_attack(_p.Attack.HEAVY)
	# Ağır yumruk: hazırlık 0,18 + vuruş 0,07 sn; tuş vuruş fazının ilk karesinde.
	await _case("ağır yumruk vuruşu → zıpla", heavy, _phase_is.bind(1), &"jump", _jumped)
	await _case("ağır yumruk vuruşu → atıl", heavy, _phase_is.bind(1), &"dash", _dashed)
	# Üçüncü combo vuruşu (en uzun hazırlık): tuş vuruş fazında.
	await _case("combo 3 vuruşu → zıpla", func():
		_p._combo_index = 2
		_p._start_attack(_p.Attack.COMBO), _phase_is.bind(1), &"jump", _jumped)
	# Atılmanın son karelerinde zıplama: atılma biter bitmez zıplamalı.
	await _case("atılma sonu → zıpla", func(): _p._start_dash(1.0), _dash_left.bind(0.06), &"jump", _jumped)
	# Hafif sersemleme 0,28 sn; tuş son 0,08 sn'de.
	await _case("sersemleme sonu → zıpla", func(): _p.apply_hit(1, Vector2(1, 0), 0.0),
		_hurt_left.bind(0.08), &"jump", _jumped)
	await _case("sersemleme sonu → atıl", func(): _p.apply_hit(1, Vector2(1, 0), 0.0),
		_hurt_left.bind(0.08), &"dash", _dashed)
	# Taban: geri dönüş fazında basılan zıplama zaten çalışıyordu, bozulmamalı.
	await _case("geri dönüş → zıpla (taban)", heavy, _phase_is.bind(2), &"jump", _jumped)
	# Erken basış saklanmamalı: hazırlığın ilk karesinde basılan zıplama, ağır yumruğun
	# 0,25 sn'lik hazırlık+vuruşundan sonra artık eski (0,16 sn) → yutulmalı.
	await _case("çok erken basış saklanmaz", heavy, func(): return true, &"jump", _jumped, false)

	print("INPUT BUFFER: %s" % ("PASS" if _fails == 0 else "FAIL %d" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _jumped() -> bool:
	return _p.velocity.y < -300.0


func _dashed() -> bool:
	return int(_p._state) == ST_DASH


func _phase_is(ph: int) -> bool:
	return int(_p._phase) == ph


func _dash_left(t: float) -> bool:
	return int(_p._state) == ST_DASH and _p._dash_timer <= t


func _hurt_left(t: float) -> bool:
	return int(_p._state) == ST_HURT and _p._hurt_timer <= t


func _case(label: String, begin: Callable, press_when: Callable, action: StringName,
		ok: Callable, expect := true) -> void:
	# Sıfırla: yerde, hareketsiz, sersemlik ve bekleme süreleri bitmiş.
	_p.global_position = Vector2(400, -20)
	_p.velocity = Vector2.ZERO
	_p.set(&"_invuln_timer", 0.0)
	_p.set(&"_dash_cd", 0.0)
	for i in 60:
		get_tree().paused = false
		await get_tree().physics_frame
	_p._health = _p.get_max_health()
	begin.call()
	var hit := -1
	var pressed_at := -1
	for f in 120:
		if pressed_at < 0 and press_when.call():
			Input.action_press(action)
			pressed_at = f
		elif pressed_at >= 0 and f == pressed_at + 1:
			Input.action_release(action)
		get_tree().paused = false
		await get_tree().physics_frame
		if pressed_at >= 0 and f > pressed_at and ok.call():
			hit = f - pressed_at
			break
	Input.action_release(action)
	var good := (hit >= 0) == expect
	if not good:
		_fails += 1
	print("%s  %s: %s" % ["OK  " if good else "HATA", label,
		("%d kare sonra" % hit) if hit >= 0 else ("basılmadı" if pressed_at < 0 else "yutuldu")])
