## Silah görevleri (GÖREVLER üçüncü dilim): ALET EDEVAT / HER TELDEN gerçek oyun kodundan
## (Main sahnesi, gerçek düşmanlar, oyuncunun vuruş ve mermi yolu) sayılıyor mu.
##
##  godot --headless --path . res://tests/weapon_achievements.tscn
extends Node

const PATH := "user://weapon_achievements_test.cfg"
const ATTACK_WEAPON := 4  ## Redmount.Attack.WEAPON

var _fails := 0


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	_ids()
	await _in_level()
	_persistence()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("WEAPON ACHIEVEMENTS: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


## Her silah dosyası ayrı bir kimlik verir; hedef sayısı klasörle aynı.
func _ids() -> void:
	var ids := {}
	for f in DirAccess.get_files_at("res://resources/weapons"):
		if f.ends_with(".tres"):
			ids[Achievements.weapon_id(load("res://resources/weapons/" + f))] = true
	_check(ids.size() == Achievements.WEAPON_COUNT,
		"silah sayısı %d, hedef %d" % [ids.size(), Achievements.WEAPON_COUNT])
	_check(Achievements.weapon_id(null) == &"", "silahsız kimlik boş")


func _in_level() -> void:
	GameState.level_index = 0
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	for node in main._level.get_children():
		if node is Cutscene:
			node._started = true
	await get_tree().physics_frame
	var player = main._player

	## Yumrukla biten düşman sayılmaz.
	var fist := _spawn("StreetThug", player.global_position + Vector2(40, -10), main)
	await get_tree().physics_frame
	player._attack = 1
	player._hit_this_swing.clear()
	fist.apply_hit(9999, Vector2(1, 0), 0.0)
	_check(fist.is_dead() and Save.stat_weapon_kills == 0, "yumruk sayılmaz")

	## Sopayla son darbe: sayılır, etiket darbeden sonra silinir.
	player.equip_weapon(load("res://resources/weapons/bat.tres"))
	var a := _spawn("StreetThug", player.global_position + Vector2(40, -10), main)
	await get_tree().physics_frame
	a._health = 1
	player._attack = ATTACK_WEAPON
	player._hit_this_swing.clear()
	player._deal_attack_hit(a)
	_check(a.is_dead() and Save.stat_weapon_kills == 1, "sopa öldürmesi sayıldı: %d" % Save.stat_weapon_kills)
	_check(a.weapon_hit == &"", "etiket darbeden sonra silindi")
	_check(Save.stat_weapon_kinds == ["bat"], "tür: %s" % str(Save.stat_weapon_kinds))

	## Silahla ama ölmeyen darbe sayılmaz; sonra yumrukla biterse de sayılmaz.
	var b := _spawn("StreetThug", player.global_position + Vector2(40, -10), main)
	await get_tree().physics_frame
	b._health = 500
	player._hit_this_swing.clear()
	player._deal_attack_hit(b)
	_check(not b.is_dead() and Save.stat_weapon_kills == 1, "ölmeyen silah darbesi sayılmaz")
	b.apply_hit(9999, Vector2(1, 0), 0.0)
	_check(b.is_dead() and Save.stat_weapon_kills == 1, "silahsız son darbe sayılmaz")

	## Boru anahtarı blok delen yoldan (apply_guard_break_hit) da sayılır.
	player.equip_weapon(load("res://resources/weapons/anahtar.tres"))
	var c := _spawn("ShieldGuard", player.global_position + Vector2(40, -10), main)
	await get_tree().physics_frame
	c._health = 1
	player._attack = ATTACK_WEAPON
	player._hit_this_swing.clear()
	player._deal_attack_hit(c)
	_check(c.is_dead() and "anahtar" in Save.stat_weapon_kinds, "anahtar (kalkan delme) sayıldı")

	## Oyuncu mermisi: silah kimliği mermiyle taşınır.
	player.equip_gun(load("res://resources/weapons/kaldirim_tasi.tres"))
	var d := _spawn("StreetThug", player.global_position + Vector2(200, -10), main)
	await get_tree().physics_frame
	d._health = 1
	var shot := Projectile.spawn(main, d.global_position, Vector2.RIGHT, 10.0, 5, 0.0, false, player)
	shot.weapon_id = Achievements.weapon_id(player._gun)
	shot._on_area_entered(d._hurtbox)
	_check(d.is_dead() and "kaldirim_tasi" in Save.stat_weapon_kinds, "taş isabeti sayıldı")

	## Düşman mermisi (kimliksiz) sayılmaz.
	var before := Save.stat_weapon_kills
	var e := _spawn("StreetThug", player.global_position + Vector2(-200, -10), main)
	await get_tree().physics_frame
	e._health = 1
	var stray := Projectile.spawn(main, e.global_position, Vector2.LEFT, 10.0, 5, 0.0, false, null)
	stray._on_area_entered(e._hurtbox)
	_check(e.is_dead() and Save.stat_weapon_kills == before, "kimliksiz mermi sayılmaz")
	_check(Save.stat_weapon_kills == 3 and Save.stat_weapon_kinds.size() == 3,
		"toplam 3 öldürme / 3 tür: %d / %d" % [Save.stat_weapon_kills, Save.stat_weapon_kinds.size()])
	main.queue_free()
	await get_tree().process_frame


func _persistence() -> void:
	Save.save_game()
	Save.load_game()
	_check(Save.stat_weapon_kills == 3 and Save.stat_weapon_kinds.size() == 3, "sayaçlar kayıtta")
	## Aynı tür ikinci kez listeye girmez; 7 tür HER TELDEN'i, 50 öldürme ALET EDEVAT'ı bitirir.
	Save.count_weapon_kill(&"bat")
	_check(Save.stat_weapon_kinds.size() == 3, "tür tekrarsız")
	for id in ["knife", "pistol", "rifle", "semsiye"]:
		Save.count_weapon_kill(StringName(id))
	_check(Achievements.is_done(Achievements.find("her_telden")), "7 türde HER TELDEN")
	_check("her_telden" in Save.achievements_seen, "HER TELDEN duyuruldu")
	while Save.stat_weapon_kills < 50:
		Save.count_weapon_kill(&"bat")
	_check(Achievements.is_done(Achievements.find("alet_edevat")), "50'de ALET EDEVAT")
	## Eski kayıt (yeni anahtarlar yok) boş okunur.
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "total_coins", 7)
	cfg.save(PATH)
	Save.load_game()
	_check(Save.stat_weapon_kills == 0 and Save.stat_weapon_kinds.is_empty(), "eski kayıtta silah sayaçları boş")


func _spawn(scene_name: String, at: Vector2, main: Node) -> Node2D:
	var e: Node2D = (load("res://scenes/enemies/%s.tscn" % scene_name) as PackedScene).instantiate()
	main._level.add_child(e)
	e.global_position = at
	e.config = e.config.duplicate()
	e.config.block_chance = 0.0
	e.config.evade_chance = 0.0
	return e
