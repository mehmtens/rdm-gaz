## Kostümler (OYNANIS-KALITE P1-6): kayıt uyumu, satın alma/giyme, palet malzemesi,
## bonusların oyuncuya uygulanması ve mağazanın KOSTÜMLER sekmesi.
##
##  godot --headless --path . res://tests/costumes.tscn
extends Node

const PATH := "user://costumes_test.cfg"

var _fails := 0


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	_legacy_save()
	_buy_and_wear()
	_pants_mask()
	await _player_bonus()
	await _shop_tab()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("COSTUMES: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


## Kostüm alanı olmayan eski kayıt ve bilinmeyen id varsayılana düşmeli.
func _legacy_save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "total_coins", 30)
	cfg.save(PATH)
	Save.load_game()
	_check(Save.costume == Shop.DEFAULT_COSTUME, "eski kayıtta varsayılan kostüm")
	_check(Shop.costume_material(Save.costume) == null, "varsayılan kostüm malzemesiz")
	_check(Shop.costume_bonus("max_health") == 0.0, "varsayılanda bonus yok")
	Save.costume = "gelecekte_eklenen"
	_check(Shop.costume("gelecekte_eklenen").id == Shop.DEFAULT_COSTUME, "bilinmeyen id varsayılana düşmeli")
	Save.costume = Shop.DEFAULT_COSTUME


func _buy_and_wear() -> void:
	Save.total_coins = 100
	_check(not Save.buy_costume("vapurcu", 120), "coin yetmezse alınamaz")
	_check(not Save.set_costume("vapurcu"), "sahip olunmayan giyilemez")
	Save.total_coins = 500
	_check(Save.buy_costume("vapurcu", 120) and Save.total_coins == 380, "satın alma coin düşmeli")
	_check(not Save.buy_costume("vapurcu", 120), "iki kez alınamaz")
	_check(Save.set_costume("vapurcu"), "alınan giyilir")
	Save.load_game()
	_check(Save.costume == "vapurcu" and Save.owns_costume("vapurcu"), "kostüm kayıttan okunmalı")
	_check(Save.set_costume(Shop.DEFAULT_COSTUME), "varsayılan her zaman giyilebilir")
	Save.set_costume("vapurcu")
	var mat := Shop.costume_material("vapurcu")
	_check(mat != null and mat.shader != null and mat.get_meta(&"costume") == "vapurcu", "palet malzemesi")
	# Gece sahnesinde (dtm_level._rim_player) kontur kostüm malzemesinde açılır.
	mat.set_shader_parameter(&"rim_enabled", true)
	_check(mat.get_shader_parameter(&"rim_enabled") == true, "kostüm shader'ı gece konturunu taşımalı")
	for it in Shop.COSTUMES:
		_check(String(it.desc).length() <= 48, "kart açıklaması kısa kalmalı: %s" % it.id)


## İkinci dilim: pantolon sayfada alfa 254 ile işaretli, malzeme ikinci rampayı taşır.
func _pants_mask() -> void:
	var img := (load("res://assets/anim/redmount/idle.png") as Texture2D).get_image()
	if img.is_compressed():
		img.decompress()
	var top := 0
	var legs := 0
	for y in 240:
		for x in 200:
			var a := img.get_pixel(x, y).a8
			if a == 254:
				if y < 120:
					top += 1
				elif y >= 170:
					legs += 1
	_check(legs > 1000, "idle karesinde bacaklar işaretli: %d" % legs)
	_check(top == 0, "baş/omuz işaretsiz kalmalı: %d" % top)
	for it in Shop.COSTUMES:
		var mat := Shop.costume_material(it.id)
		if mat == null:
			continue
		_check(mat.get_shader_parameter(&"pants_light") == it.get("pants_light", it.light), "pantolon rampası: %s" % it.id)
	var v := Shop.costume("vapurcu")
	_check(v.pants_light != v.light, "vapurcu ceket ile pantolon ayrı renk")


func _player_bonus() -> void:
	var p: Node = (load("res://scenes/characters/Redmount.tscn") as PackedScene).instantiate()
	add_child(p)
	await get_tree().process_frame
	var rig: CanvasItem = p.get_node(^"Rig")
	_check(rig.material is ShaderMaterial and rig.material.get_meta(&"costume") == "vapurcu", "rig kostüm malzemesi")
	_check(p.get_max_health() == p.combat.max_health + 10, "vapurcu +10 can: %d" % p.get_max_health())
	p.queue_free()
	Save.buy_costume("kizil", 240)
	Save.set_costume("kizil")
	_check(is_equal_approx(Shop.costume_bonus("fist"), 0.08), "kızıl yumruk bonusu")
	p = (load("res://scenes/characters/Redmount.tscn") as PackedScene).instantiate()
	add_child(p)
	await get_tree().process_frame
	_check(is_equal_approx(p._melee_damage_multiplier(), 1.08), "yumruk çarpanı 1.08")
	_check(p.get_max_health() == p.combat.max_health, "kızılda can bonusu yok")
	p.queue_free()


func _shop_tab() -> void:
	Save.unlocked_level = 35
	Save.total_coins = 1000
	var shop: Control = (load("res://scenes/Shop.tscn") as PackedScene).instantiate()
	add_child(shop)
	await get_tree().process_frame
	shop._select(2)
	await get_tree().process_frame
	_check(shop._grid.get_child_count() == Shop.COSTUMES.size(), "her kostüme bir kart")
	var coins_before := Save.total_coins
	shop._buy_costume("hamal", 150)
	_check(Save.costume == "hamal" and Save.total_coins == coins_before - 150, "mağazadan alınca giyilir")
	shop._wear("vapurcu")
	_check(Save.costume == "vapurcu", "GİY düğmesi kostümü değiştirir")
	shop.queue_free()
	await get_tree().process_frame
