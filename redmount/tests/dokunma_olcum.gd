## Dokunma ölçümü (insan testi): boş / kaçan / düzeltme basış sayaçları ve bölüm sonu CSV.
##
##  godot --headless --path . res://tests/dokunma_olcum.tscn
extends Node

const LOG := "user://dokunma_olcum_test.csv"

var _fails := 0


func _ready() -> void:
	OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "1")
	Save._path = "user://dokunma_olcum_test.cfg"
	Save.wipe()
	_remove(LOG)
	_unit()
	_neighbors()
	await _controls()
	Save.wipe()
	_remove(LOG)
	_remove("user://dokunma_olcum_test.cfg")
	print("DOKUNMA OLCUM: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _unit() -> void:
	var s := TouchStats.new()
	s.log_path = LOG
	s.reset(0)
	var circles := [["attack", Vector2(100, 100), 50.0], ["jump", Vector2(300, 100), 50.0]]
	s.on_touch(Vector2(110, 90), circles)  # düğmenin içinde
	_check(s.empty == 0, "düğmeye değen basış boş sayılmamalı")
	s.on_touch(Vector2(100, 170), circles)  # kenardan 20 px (≤ 0,6 × 50) → kaçan
	s.on_touch(Vector2(700, 600), circles)  # uzak → yalnız boş
	_check(s.empty == 2 and s.total_near() == 1 and s.near.get("attack", 0) == 1,
		"boş 2 / kaçan 1 (VUR) olmalı (boş %d, kaçan %s)" % [s.empty, s.near])

	var nb := {"jump": ["attack"], "attack": ["jump"]}
	s.on_press("jump", 1000, nb)
	s.on_release("jump", 1080)  # 80 ms: kısa dokunuş
	s.on_press("attack", 1200, nb)  # 120 ms sonra komşuya geçiş → düzeltme
	s.on_release("attack", 1500)
	s.on_press("jump", 1600, nb)  # VUR uzun basıştı → düzeltme değil
	s.on_release("jump", 1900)
	s.on_press("attack", 2100, nb)
	_check(s.total_fixes() == 1 and s.fixes.get("jump>attack", 0) == 1,
		"yalnız kısa ZIPLA → VUR geçişi düzeltme sayılmalı (%s)" % s.fixes)
	s.on_release("attack", 2150)
	s.on_press("attack", 2600, nb)  # 450 ms sonra: düzeltme penceresi geçti
	_check(s.total_fixes() == 1, "250 ms sonra komşu basış düzeltme sayılmamalı")
	s.on_release("attack", 2700)
	s.on_press("dash", 2710, nb)  # komşu değil
	_check(s.total_fixes() == 1, "komşu olmayan düğmeye geçiş düzeltme sayılmamalı")

	var line := s.flush("Bolum01", 1, 62000)
	_check(line.contains(";Bolum01;1;62;") and line.contains("attack 1") and line.contains("jump>attack 1"),
		"CSV satırı sahne/süre/ayrıntı taşımalı (%s)" % line)
	_check(s.is_empty() and s.started_ms == 62000, "flush sayaçları sıfırlamalı")
	_check(s.flush("Bolum01", 1, 63000) == "", "boş kesit yazılmamalı")
	var rows := FileAccess.get_file_as_string(LOG).strip_edges().split("\n")
	_check(rows.size() == 2 and rows[0].strip_edges() == TouchStats.HEADER,
		"CSV başlık + tek satır olmalı (%d satır)" % rows.size())
	s.on_press("jump", 70000, nb)
	s.flush("Bolum02", 2, 80000)
	rows = FileAccess.get_file_as_string(LOG).strip_edges().split("\n")
	_check(rows.size() == 3, "ikinci kesit dosyanın sonuna eklenmeli (%d satır)" % rows.size())


func _neighbors() -> void:
	var map := TouchControls.neighbor_map()
	_check("attack" in map["jump"] and "jump" in map["attack"], "ZIPLA ve VUR komşu olmalı")
	_check("move_right" not in map["move_left"], "ok çifti düzeltme sayılmamalı")
	_check("attack" not in map["move_left"], "farklı ekran yarısı komşu olmamalı")
	_check(not map.has("pause") and not map.has("retry"), "menü düğmeleri ölçüme girmemeli")


func _controls() -> void:
	GameState.level_index = 0
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	for node in main._level.get_children():
		if node is Cutscene:
			node._started = true
	await get_tree().process_frame
	var touch: TouchControls = main.get_node(^"TouchControls")
	touch.stats.log_path = LOG
	_check(touch.is_enabled(), "dokunmatik kontroller açık olmalı")
	var circles := touch.touch_circles()
	var keys := circles.map(func(c: Array) -> String: return c[0])
	_check("jump" in keys and "slide" in keys and "retry" not in keys,
		"oyunda görünür düğmelerin dokunma daireleri (%s)" % [keys])

	# Ekranın ortası (oyun alanı): boş basış.
	var ev := InputEventScreenTouch.new()
	ev.pressed = true
	ev.position = get_viewport().get_visible_rect().size * 0.5
	touch._input(ev)
	# ZIPLA düğmesinin hemen dışı (kenardan 10 px aşağı-dışa): kaçan.
	for c in circles:
		if c[0] == "jump":
			ev.position = c[1] + Vector2(0, -(c[2] + 10.0))
	touch._input(ev)
	_check(touch.stats.empty == 2 and touch.stats.near.get("jump", 0) == 1,
		"oyunda boş 2 / kaçan ZIPLA 1 (boş %d, kaçan %s)" % [touch.stats.empty, touch.stats.near])
	touch._on_press("jump")
	touch._on_release("jump")
	touch._on_press("attack")
	touch._on_release("attack")
	_check(touch.stats.fixes.get("jump>attack", 0) == 1, "oyunda ZIPLA → VUR düzeltmesi sayılmalı")

	touch.set_mode("results")
	var text := FileAccess.get_file_as_string(LOG)
	_check(text.contains(";%s;1;" % main._level.name) and text.contains("jump>attack 1"),
		"sonuç ekranına geçişte bölüm satırı yazılmalı (%s)" % text)
	_check(touch.stats.is_empty(), "kesit kapanınca sayaçlar sıfırlanmalı")
	touch._input(ev)
	_check(touch.stats.empty == 0, "sonuç ekranındaki basışlar sayılmamalı")
	main.queue_free()
	await get_tree().process_frame
