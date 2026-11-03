## Beceri görevleri (GÖREVLER ikinci dilim): oyuncu fırlatışı, havada biten düşman ve
## hasarsız patron gerçek oyun kodundan (Main sahnesi, gerçek düşmanlar) sayılıyor mu.
##
##  godot --headless --path . res://tests/skill_achievements.tscn
extends Node

const PATH := "user://skill_achievements_test.cfg"

var _fails := 0


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	await _in_level()
	_persistence()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("SKILL ACHIEVEMENTS: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _in_level() -> void:
	GameState.level_index = 0
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	for node in main._level.get_children():
		if node is Cutscene:
			node._started = true
	await get_tree().physics_frame
	var player = main._player
	_check(player.hits_taken == 0, "oyuncu darbe sayacı 0 başlar")

	## Fırlatma: sersemlemiş eşkıya yanında.
	var thug := _spawn("StreetThug", player.global_position + Vector2(40, 0), main)
	await get_tree().physics_frame
	thug.apply_hit(1, Vector2(1, 0), 0.0)
	_check(thug.can_be_thrown(), "darbe yiyen eşkıya fırlatılabilir")
	_check(player._try_throw(), "oyuncu fırlattı")
	_check(Save.stat_throws == 1, "fırlatma sayıldı: %d" % Save.stat_throws)

	## Havada bitirme: kaldırılan düşman yere değmeden biterse sayılır, yerdeki sayılmaz.
	var air := _spawn("StreetThug", player.global_position + Vector2(300, -10), main)
	var ground := _spawn("StreetThug", player.global_position + Vector2(-300, -10), main)
	for i in 30:
		await get_tree().physics_frame
	var before := Save.stat_air_kills
	air.launch(420.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_check(air.can_be_juggled(), "kaldırılan düşman havada")
	air.apply_hit(9999, Vector2(1, 0), 0.0)
	_check(air.is_dead() and Save.stat_air_kills == before + 1, "havada biten sayıldı")
	ground.apply_hit(9999, Vector2(1, 0), 0.0)
	_check(ground.is_dead() and Save.stat_air_kills == before + 1, "yerde biten sayılmaz")

	## Hasarsız patron: dövüş başından ölüme kadar oyuncu darbe almadıysa.
	var boss := _spawn("MiniBoss", player.global_position + Vector2(600, -10), main)
	await get_tree().physics_frame
	boss.apply_hit(1, Vector2(1, 0), 0.0)
	boss.apply_hit(99999, Vector2(1, 0), 0.0)
	_check(boss.is_dead() and Save.stat_flawless_bosses == 1, "hasarsız patron sayıldı")
	_check("temiz_is" in Save.achievements_seen, "TEMİZ İŞ duyuruldu")

	var boss2 := _spawn("MiniBoss", player.global_position + Vector2(600, -10), main)
	await get_tree().physics_frame
	boss2.apply_hit(1, Vector2(1, 0), 0.0)
	player._invuln_timer = 0.0
	player.apply_hit(5, Vector2(-1, 0), 0.0)
	_check(player.hits_taken == 1, "oyuncu darbesi sayıldı")
	boss2.apply_hit(99999, Vector2(1, 0), 0.0)
	_check(boss2.is_dead() and Save.stat_flawless_bosses == 1, "darbe yiyince hasarsız sayılmaz")

	## Patron olmayan düşman hiç işaret almaz.
	_check(thug._boss_mark == -1, "sıradan düşmanda patron işareti yok")
	main.queue_free()
	await get_tree().process_frame


func _persistence() -> void:
	Save.save_game()
	var t := Save.stat_throws
	Save.load_game()
	_check(Save.stat_throws == t and Save.stat_flawless_bosses == 1 and Save.stat_air_kills >= 1, "sayaçlar kayıtta")
	## Eski kayıt (yeni anahtarlar yok) sıfırla okunur.
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "total_coins", 7)
	cfg.save(PATH)
	Save.load_game()
	_check(Save.stat_throws == 0 and Save.stat_air_kills == 0 and Save.stat_flawless_bosses == 0,
		"eski kayıtta beceri sayaçları 0")
	for i in 15:
		Save.count_throw()
	_check(Achievements.is_done(Achievements.find("firlatici")), "15 fırlatışta HAMAL KOLU")


func _spawn(scene_name: String, at: Vector2, main: Node) -> Node2D:
	var e: Node2D = (load("res://scenes/enemies/%s.tscn" % scene_name) as PackedScene).instantiate()
	main._level.add_child(e)
	e.global_position = at
	## Rastgele blok testi bozmasın.
	e.config = e.config.duplicate()
	e.config.block_chance = 0.0
	e.config.evade_chance = 0.0
	return e
