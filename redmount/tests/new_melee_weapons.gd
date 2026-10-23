## Yeni yakın silahlar (OYNANIS-KALITE P1): Boru Anahtarı bloğu/kalkanı deler,
## Şemsiye düşmanı havaya kaldırır; piksel sanat sayfaları sopa karelerinden
## türetilip PlayerSprite'a eklenir; bölüm/dükkân/sandık bağlantıları.
##
##  godot --headless --path . res://tests/new_melee_weapons.tscn
extends Node

const WRENCH := preload("res://resources/weapons/anahtar.tres")
const UMBRELLA := preload("res://resources/weapons/semsiye.tres")
const BAT := preload("res://resources/weapons/bat.tres")

var _fails := 0


func _ready() -> void:
	Save._path = "user://new_melee_weapons_test.cfg"
	Save.wipe()
	_resources()
	await _in_level()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://new_melee_weapons_test.cfg"))
	print("NEW MELEE WEAPONS: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _resources() -> void:
	_check(WRENCH.guard_break and WRENCH.launch_speed == 0.0, "anahtar yalnız blok deler")
	_check(UMBRELLA.launch_speed > 0.0 and not UMBRELLA.guard_break, "şemsiye yalnız havaya kaldırır")
	_check(not BAT.guard_break and BAT.launch_speed == 0.0, "eski silahlar varsayılanla okunur")
	_check(WRENCH.damage > BAT.damage and WRENCH.windup > BAT.windup, "anahtar sopadan ağır ve yavaş")
	_check(UMBRELLA.reach.x > BAT.reach.x and UMBRELLA.damage < BAT.damage, "şemsiye uzun ama hafif")
	for k in ["anahtar", "semsiye"]:
		var scene: PackedScene = load("res://scenes/pickups/%s%sPickup.tscn" % [k[0].to_upper(), k.substr(1)])
		var p = scene.instantiate()
		_check(p.kind == k and p.weapon != null, k + ": pickup sahnesi")
		p.free()
		var icon: Texture2D = load("res://assets/pickups/placeholder_%s.png" % k)
		_check(icon != null and icon.get_width() == 48, k + ": 48 px piksel ikon")
		_check(LevelShop.CATALOG.has(k), k + ": dükkân kataloğunda")
	var sandik: Array = BreakableProp.LOOT["sandik"]["scenes"]
	_check(sandik.has("res://scenes/pickups/AnahtarPickup.tscn") and sandik.has("res://scenes/pickups/SemsiyePickup.tscn"),
		"sandık ganimetinde yeni silahlar")


func _in_level() -> void:
	GameState.level_index = 3  # Bölüm 4: kalkanlı tanıtımı + anahtar
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	for node in main._level.get_children():
		if node is Cutscene:
			node._started = true
	await get_tree().process_frame
	var found := false
	for node in main._level.get_children():
		if node is PickupBase and node.get("weapon") == WRENCH:
			found = true
	_check(found, "Bölüm 4'te elle konmuş boru anahtarı")

	var player = main._player
	var sprite = player.rig
	for k in ["anahtar", "semsiye"]:
		for base in ["idle", "walk", "attack", "attack2"]:
			var anim := "%s_%s" % [k, base]
			_check(sprite.sprite_frames.has_animation(anim)
				and sprite.sprite_frames.get_frame_count(anim) == sprite.sprite_frames.get_frame_count("bat_" + base),
				anim + ": sopa kareleriyle aynı sayıda")
	sprite.set_anim("ATTACK", "WEAPON", 1, 0.5, 0, 1, "anahtar")
	_check(sprite.animation == &"anahtar_attack", "anahtar savuruşu kendi sayfasını oynatmalı (%s)" % sprite.animation)
	# Sayfası olmayan "weapon_swing" eylemi savuruşu silahsız duruşla örtmemeli.
	sprite.play_action(&"weapon_swing")
	sprite.set_anim("ATTACK", "WEAPON", 0, 0.2, 0, 1, "semsiye")
	_check(sprite.animation == &"semsiye_attack", "hazırlık karesi silahlı kalmalı (%s)" % sprite.animation)
	sprite.set_anim("IDLE", "", 0, 0.0, 0, 1, "semsiye")
	_check(sprite.animation == &"semsiye_idle", "şemsiye duruşu")

	var origin: Vector2 = player.global_position
	# Kalkanlı Zabıta: önden hafif darbe kalkana çarpar, anahtar deler.
	var shield = _spawn("ShieldGuard", origin + Vector2(80, 0), main)
	await get_tree().physics_frame
	shield._facing = -1
	shield._state = shield.State.CHASE
	var hp: int = shield._health
	shield.apply_hit(10, Vector2(1, 0), 100.0)
	_check(shield._health == hp, "önden hafif darbe kalkana çarpmalı")
	var pierced: bool = shield.apply_guard_break_hit(10, Vector2(1, 0), 100.0)
	_check(pierced and shield._health < hp, "anahtar kalkanı delip hasar vermeli")
	_check(shield._shield_down > 0.0, "delinen kalkan inmeli")

	# Blok duruşundaki Elit Muhafız: normal darbe boşa, anahtar geçer.
	var elite = _spawn("EliteGuard", origin + Vector2(140, 0), main)
	await get_tree().physics_frame
	elite._start_block()
	hp = elite._health
	elite.apply_hit(10, Vector2(1, 0), 100.0)
	_check(elite._health == hp, "blok normal darbeyi yutmalı")
	player._attack = player.Attack.WEAPON
	player._weapon = WRENCH
	player._hit_this_swing.clear()
	player._deal_attack_hit(elite)
	_check(elite._health < hp and elite._state != elite.State.BLOCK, "anahtar bloğu delmeli")

	# Şemsiye: isabet düşmanı havaya kaldırır (hava dizine açık).
	var thug = _spawn("StreetThug", origin + Vector2(200, 0), main)
	for i in 30:
		await get_tree().physics_frame
		if thug.is_on_floor():
			break
	player._weapon = UMBRELLA
	player._hit_this_swing.clear()
	player._deal_attack_hit(thug)
	_check(thug.velocity.y < -100.0 and thug._state == thug.State.KNOCKDOWN, "şemsiye düşmanı havaya kaldırmalı (vy=%.0f)" % thug.velocity.y)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_check(thug.can_be_juggled(), "kaldırılan düşman hava dizine açık olmalı")

	# Eşya alma ipucu.
	player.equip_weapon(WRENCH)
	_check(player.has_weapon(), "anahtar kuşanılmalı")
	main.queue_free()
	await get_tree().process_frame


func _spawn(scene_name: String, at: Vector2, main: Node) -> Node2D:
	var e: Node2D = (load("res://scenes/enemies/%s.tscn" % scene_name) as PackedScene).instantiate()
	main._level.add_child(e)
	e.global_position = at
	return e
