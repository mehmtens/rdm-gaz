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
	_pants_leaks("run")
	_pants_leaks("walk")
	_weapon_mask()


## Silah işareti (alfa 252): tabanca/tüfek koyu gri ama giysi değil, kostüm boyamamalı.
## Her karede silah işaretli olmalı (takip kaçarsa kare boş kalır); silahsız sayfada hiç yok.
func _weapon_mask() -> void:
	var need := {"pistol_aim": 100, "pistol_idle": 100, "pistol_shoot": 100, "pistol_walk": 100,
		"rifle_aim": 600, "rifle_idle": 600, "rifle_shoot": 600, "rifle_walk": 600, "idle": 0}
	for sheet in need:
		var img := (load("res://assets/anim/redmount/%s.png" % sheet) as Texture2D).get_image()
		if img.is_compressed():
			img.decompress()
		for cell in img.get_width() / 200:
			var n := 0
			for y in 240:
				for x in 200:
					if img.get_pixel(cell * 200 + x, y).a8 == 252:
						n += 1
			if need[sheet] == 0:
				_check(n == 0, "%s/%d silah işareti olmamalı: %d" % [sheet, cell, n])
			else:
				_check(n >= need[sheet], "%s/%d silah işaretli: %d" % [sheet, cell, n])
	## Yakın silahlar: sopa/anahtar/şemsiye sopa farkıyla, bıçak ağız kenarıyla işaretli.
	## Silahın görünmediği kareler var (savuruşta arkada), bu yüzden sayfa toplamı; kare
	## başına üst sınır ceketin/pantolonun işarete karışmadığını gösterir.
	var melee := {"bat": [1500, 1000], "anahtar": [1500, 1000], "semsiye": [1500, 1000], "knife": [100, 400]}
	for w in melee:
		for s in ["idle", "walk", "attack", "attack2"]:
			var img := (load("res://assets/anim/redmount/%s_%s.png" % [w, s]) as Texture2D).get_image()
			if img.is_compressed():
				img.decompress()
			var total := 0
			for cell in img.get_width() / 200:
				var n := 0
				for y in 240:
					for x in 200:
						if img.get_pixel(cell * 200 + x, y).a8 == 252:
							n += 1
				_check(n <= melee[w][1], "%s_%s/%d silah işareti fazla: %d" % [w, s, cell, n])
				total += n
			_check(total >= melee[w][0], "%s_%s silah işaretli: %d" % [w, s, total])
	## Şarjör değiştirme: kare başına çokgen. Alt sınır her karede silah (ya da elde şarjör)
	## işaretli, üst sınır ceketin çokgene karışmadığını gösterir.
	var reload := {"pistol_reload": [150, 450], "rifle_reload": [200, 1800]}
	for sheet in reload:
		var img := (load("res://assets/anim/redmount/%s.png" % sheet) as Texture2D).get_image()
		if img.is_compressed():
			img.decompress()
		for cell in img.get_width() / 200:
			var n := 0
			for y in 240:
				for x in 200:
					if img.get_pixel(cell * 200 + x, y).a8 == 252:
						n += 1
			_check(n >= reload[sheet][0] and n <= reload[sheet][1], "%s/%d silah işareti: %d" % [sheet, cell, n])
	## Bıçağın elle çokgenli kareleri: bele inen ağız pantolon (254) sayılmamalı, omuz üstündeki
	## bıçak işaretli olmalı. Kutu: sayfa, kare, x0, y0, x1, y1, en az silah işareti.
	for b in [["knife_walk", 5, 96, 139, 127, 159, 110], ["knife_walk", 6, 89, 139, 116, 158, 70],
			["knife_walk", 7, 105, 142, 129, 159, 100], ["knife_attack2", 0, 34, 124, 50, 138, 40]]:
		var img := (load("res://assets/anim/redmount/%s.png" % b[0]) as Texture2D).get_image()
		if img.is_compressed():
			img.decompress()
		var weapon := 0
		var pants := 0
		for y in range(b[3], b[5]):
			for x in range(b[2], b[4]):
				var a: int = img.get_pixel(b[1] * 200 + x, y).a8
				weapon += int(a == 252)
				pants += int(a == 254)
		_check(weapon >= b[6] and pants <= 1, "%s/%d bıçak: silah %d, pantolon %d" % [b[0], b[1], weapon, pants])


## Kaçaklar: koşuda ceketin parlak yamaları pantolon sayılmamalı (eski maskede bir karede
## 387 piksel), gölgedeki arka bacak da ceket kalmamalı (alt dörtte birin ≥ %68'i pantolon).
func _pants_leaks(sheet: String) -> void:
	var img := (load("res://assets/anim/redmount/%s.png" % sheet) as Texture2D).get_image()
	if img.is_compressed():
		img.decompress()
	for cell in img.get_width() / 200:
		var top := 240
		var bot := 0
		for y in 240:
			for x in 200:
				if img.get_pixel(cell * 200 + x, y).a8 >= 128:
					top = mini(top, y)
					bot = maxi(bot, y)
		var mid := top + int((bot - top) * 0.45)
		var low := top + int((bot - top) * 0.75)
		var upper := 0
		var legs := 0
		var opaque := 0
		for y in range(top, bot + 1):
			for x in 200:
				var a := img.get_pixel(cell * 200 + x, y).a8
				if y < mid and a == 254:
					upper += 1
				elif y >= low and a >= 128:
					opaque += 1
					if a == 254:
						legs += 1
		_check(upper <= 10, "%s/%d gövdede pantolon kaçağı: %d" % [sheet, cell, upper])
		_check(legs * 100 >= opaque * 68, "%s/%d bacaklar pantolon: %d/%d" % [sheet, cell, legs, opaque])


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
