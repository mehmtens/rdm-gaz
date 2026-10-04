## Kitap 3 finali — Son Yayın / İstanbul'un Sesi.
## Kıyı -> üç yayın bağlantısı -> tek boss -> yayın -> şafak.
extends "res://scripts/systems/book03_level01.gd"

const SHORE := preload("res://assets/backgrounds/book03_final_shore_atlas.png")
const BROADCAST := preload("res://assets/backgrounds/book03_final_broadcast_atlas.png")
const DAWN := preload("res://assets/backgrounds/book03_final_dawn_atlas.png")
const SURFACES := preload("res://assets/environment/book03_final_surfaces.png")
const SUPPLIES := preload("res://assets/environment/book03_final_supplies.png")
const DIRECTOR := preload("res://scenes/enemies/BroadcastDirector.tscn")
const CUTS := [24000.0, 48000.0, 72000.0, 96000.0, 120000.0, 144000.0,
	168000.0, 192000.0, 216000.0, 252000.0, 260000.0]
const PLACES := ["Göksu Kayıkçı Yolu", "Tekne Ustasının Atölyesi", "Yükleme İskelesi",
	"Mavna Ana Güvertesi", "Kablo Geçidi", "Yedek Dinamo", "Emir Kasetleri Arşivi",
	"Canlı Yayın Odası", "Anten Güvertesi", "Son Düello", "Sessiz Kumanda", "İstanbul'un Sabahı"]

var relays_cut := 0
var boss_defeated := false
var ending_seen := false
var boss_phases_seen: Array[int] = []
var boss_attack_phases: Array[int] = []
var _final_goal: Area2D
var _objective: Label
var _place: Label
var _zone := -1
var _player: Node2D
var _duel: BattleArena


func _build_chapter() -> void:
	_spawn_marker()
	add_child(_FinalBackdrop.new())
	set_meta("completion_title", "İSTANBUL'UN SESİ\nÜÇ KİTAP · SON")
	_intro("GAZELLE", "Hisarın kumandası kapalı. Mavnanın kendi gücü var. Üç bağlantıyı kes; ben emir kasetlerini yayına hazırlayacağım.")
	# Sığ kot farkları; boşluklar yalnız altı kısa iskele ekinde.
	for i in 68:
		var x := 2000.0 + i * 4000.0
		var width := 4000.0
		if i in [8, 16, 28, 34, 46, 52]:
			x -= 55.0
			width = 3890.0
		elif i in [9, 17, 29, 35, 47, 53]:
			x += 55.0
			width = 3890.0
		_ground(x, width, _surface_y(x))
	_shore_route()
	_boarding_route()
	_power_route()
	_archive_route()
	_final_route()
	_goal(270500, 0)
	_final_goal = get_child(get_child_count() - 1)
	_final_goal.monitoring = false
	_build_wayfinding()


func _surface_y(x: float) -> float:
	var segment := int(x / 4000.0)
	return 60.0 if segment in [3, 4, 13, 14, 25, 26, 37, 38, 49, 50] else -60.0 if segment in [19, 20, 31, 32, 43, 44] else 0.0


func _shore_route() -> void:
	_coin_line(550, 6, 180, -55)
	_enemy(STREET, 2400, 0)
	_prop("kasa", 3800, 0, AMMO)
	_enemy(KNIFE, 5200, 0)
	_reward_path(6700, ARMOR)
	_checkpoint(9400, 0)
	_coin_line(11900, 4, 300, -70)
	_enemy(RIFLE, 13600, 60)
	_oneway(14400, -25, 320)
	_prop("sandik", 14400, -31, PISTOL)
	_enemy(KNIFE, 17800, 60)
	_checkpoint(20500, 0)
	_arena(22100, 0, 21300, 22900, _wave(STREET, KNIFE), _wave(RIFLE, STREET), HEALTH)
	_dialogue(23700, "REDMOUNT", "Cağaloğlu'nda bastıkları yalanı bu gece bütün şehir duyacak. Kendi seslerinden.")
	_enemy(ASSASSIN, 26000, 0)
	_oneway(28400, -80, 320)
	_oneway(28800, -155, 360)
	_prop("sandik", 28800, -161, ARMOR)
	_coin_line(28350, 4, 180, -215)
	_enemy(BRUISER, 30700, 0)
	_checkpoint(34500, 0)
	_crossing(36000)
	_enemy(KNIFE, 38400, 0)
	_shop(40400, "KAYIKÇININ ERZAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(41100, 0)
	_arena(44400, 0, 43600, 45200, _wave(KNIFE, RIFLE), _wave(ASSASSIN, STREET), HEALTH)
	_coin_line(45900, 5, 230, -55)


func _boarding_route() -> void:
	_enemy(RIFLE, 49500, 0)
	_reward_path(51300, AMMO)
	_enemy(ELITE, 54800, 60)
	_coin_line(56300, 5, 240, 5)
	_checkpoint(59200, 60)
	_arena(62000, 0, 61200, 62800, _wave(KNIFE, STREET), _wave(RIFLE, BRUISER), HEALTH)
	_checkpoint(65400, 0)
	_crossing(68000)
	_dialogue(71000, "GAZELLE", "İskele hattı mavnaya bağlı. Kablo kapısındaki nöbeti dağıtırsan ilk bağlantıyı ayırabilirim.")
	_enemy(KNIFE, 73700, 0)
	_enemy(RIFLE, 76200, -60)
	_reward_path(78600, ARMOR)
	_checkpoint(83500, 0)
	_relay(86800, "KIYI HATTI KESİLDİ", _wave(RIFLE, KNIFE), _wave(ELITE, STREET))
	_dialogue(88900, "GAZELLE", "Birinci hat kapalı. Artık karadan emir alamıyorlar. Dinamoya ilerle.")
	_shop(91300, "GÜVERTE İLK YARDIMI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(92300, 0)
	_coin_line(93900, 5, 250, -55)


func _power_route() -> void:
	_enemy(ASSASSIN, 98100, 0)
	_enemy(RIFLE, 102500, 60)
	_coin_line(104400, 5, 220, 5)
	_oneway(105800, -25, 320)
	_oneway(106150, -100, 320)
	_prop("sandik", 106150, -106, RIFLE_PICKUP)
	_enemy(BRUISER, 109800, 0)
	_checkpoint(112700, 0)
	_crossing(116000)
	_arena(118200, 0, 117400, 119000, _wave(KNIFE, RIFLE), _wave(ELITE, KNIFE), HEALTH)
	_dialogue(120600, "YAYIN ŞEFİ", "Matbaayı aldınız, suyu açtınız. Sabah hangi habere inanacaklarını yine ben söylerim.")
	_enemy(ELITE, 123600, 0)
	_reward_path(126000, ARMOR)
	_enemy(RIFLE, 130100, -60)
	_checkpoint(133500, 0)
	_relay(136000, "YEDEK GÜÇ AYRILDI", _wave(BRUISER, KNIFE), _wave(RIFLE, ASSASSIN))
	_crossing(140000)
	_checkpoint(141000, 0)
	_pickup(HEALTH, 141600, -50)
	_dialogue(142800, "REDMOUNT", "Gücünüzü kesiyoruz. Ama mikrofonu kırmayacağız.")


func _archive_route() -> void:
	_enemy(KNIFE, 146000, 0)
	_coin_line(148400, 5, 230, 5)
	_enemy(RIFLE, 151500, 60)
	_oneway(153000, -25, 320)
	_oneway(153360, -110, 360)
	_prop("sandik", 153360, -116, AMMO)
	_enemy(ELITE, 156200, 0)
	_checkpoint(158700, 0)
	_arena(161000, 0, 160200, 161800, _wave(ASSASSIN, KNIFE), _wave(BRUISER, RIFLE), HEALTH)
	_dialogue(163200, "GAZELLE", "Asılları buldum. Su kesintisi, susturulan matbaalar, sevkiyatlar... Hepsinin emri aynı kayıtta. Kopyalar kıyıya ulaştı.")
	_shop(165000, "ARŞİV GÖREVLİSİNİN ÇANTASI", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(166000, 0)
	_enemy(RIFLE, 169500, 0)
	_reward_path(172300, PISTOL)
	_enemy(KNIFE, 175800, -60)
	_enemy(ELITE, 179200, -60)
	_checkpoint(181800, 0)
	_relay(184000, "SUSTURUCU DEVRE DIŞI", _wave(RIFLE, ASSASSIN), _wave(ELITE, BRUISER))
	_crossing(188000)
	_dialogue(190800, "GAZELLE", "Üç bağlantı da kesildi. Yalnız bizim yayın açık. Anten güvertesini tut; kaydı başlatıyorum.")


func _final_route() -> void:
	_enemy(RIFLE, 194600, 0)
	_reward_path(196700, ARMOR)
	_enemy(ASSASSIN, 199300, 60)
	_coin_line(201000, 5, 220, 5)
	_checkpoint(204400, 0)
	_arena(206400, 0, 205600, 207200, _wave(KNIFE, RIFLE), _wave(ASSASSIN, ELITE), HEALTH)
	_dialogue(207650, "GAZELLE", "Kaset dönüyor. Anten bağlantısına geliyorlar; şu son geçidi tut!")
	_checkpoint(208300, 0)
	_arena(209500, 0, 208700, 210300, _wave(STREET, KNIFE), _wave(RIFLE, BRUISER), HEALTH)
	_crossing(212000)
	_dialogue(214500, "GAZELLE · CANLI YAYIN", "İstanbul, bu bir emir değil. Dinleyeceğiniz kayıtlar suyumuzu kesenlerin, haberimizi susturanların kendi sesleri.")
	_enemy(ELITE, 218800, 0)
	_reward_path(221200, AMMO)
	_enemy(BRUISER, 224000, 0)
	_checkpoint(226200, 0)
	_arena(228400, 0, 227600, 229200, _wave(RIFLE, KNIFE), _wave(ELITE, ASSASSIN), HEALTH)
	_dialogue(231000, "YAYIN ŞEFİ", "Bir kaseti durdurmak için bir düğme yeter.")
	_dialogue(232400, "REDMOUNT", "Kasetin kopyaları bütün kıyıda. Burada susturacağın kimse kalmadı.")
	_enemy(KNIFE, 234800, 0)
	_coin_line(236600, 5, 240, -55)
	_shop(238500, "GAZELLE'İN SON İKMALİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(240000, 0)
	_pickup(HEALTH, 240700, -50)
	_pickup(ARMOR, 241100, -50)
	_pickup(AMMO, 241500, -50)
	_dialogue(243000, "GAZELLE", "Yayın kıyıya ulaştı. Önündeki adam son kez saldıracak. Hamlesini gör, boşluğunu yakala. Ben buradayım.")
	_checkpoint(245500, 0)
	_duel = ARENA.instantiate()
	_duel.name = "FinalDuel"
	_duel.position = Vector2(247000, 0)
	_duel.gate_left_x = 246200
	_duel.gate_right_x = 247800
	_duel.gate_texture = _gate_texture()
	_duel.wave1 = _wave(DIRECTOR)
	_duel.reward = HEALTH
	_duel.enemy_spawned.connect(_director_spawned)
	_duel.cleared.connect(_director_defeated)
	add_child(_duel)
	_dialogue(250000, "GAZELLE", "Bitti. Yayın kesilmedi. Kıyıdan cevap geliyor; kayıtları herkes duydu.")
	_dialogue(253500, "REDMOUNT", "Artık kimsenin bir sonraki emri beklemesine gerek yok.")
	_coin_line(255000, 8, 170, -55)
	_dialogue(258200, "GAZELLE", "Cağaloğlu yeniden basıyor. Su hattı açık. Bu kez haberi saklayamayacaklar.")
	# Son bölümde ölüm tuzağı yok: oyuncu şehre kendi adımlarıyla döner.
	_dialogue(263500, "REDMOUNT", "Seni almaya çıktığım gece bu kadar yolu görememiştim.")
	_dialogue(266500, "GAZELLE", "O yolu tek başına yürümedin. Hadi. Çay soğumadan.")


func _crossing(x: float) -> void:
	_checkpoint(x - 950, 0)
	_oneway(x, -45, 260)
	_coins_arc(x - 230, 5, 115, -145)
	_checkpoint(x + 950, 0)


func _relay(x: float, message: String, first: Array[PackedScene], second: Array[PackedScene]) -> void:
	_arena(x, 0, x - 800, x + 800, first, second, HEALTH)
	var arena: BattleArena = get_child(get_child_count() - 1)
	arena.cleared.connect(func() -> void:
		relays_cut += 1
		Fx.popup(Vector2(x, -175), message, Color("b5e4d0"), 25)
		_update_objective()
	)
	_checkpoint(x + 1200, 0)


func _gate_texture() -> AtlasTexture:
	var tex := AtlasTexture.new()
	tex.atlas = SURFACES
	tex.region = Rect2(30, SURFACES.get_height() * 0.5 + 4, 48, SURFACES.get_height() * 0.5 - 8)
	return tex


func _arena(x: float, floor_y: float, left: float, right: float,
		first: Array[PackedScene], second: Array[PackedScene], reward_scene: PackedScene = null) -> void:
	super._arena(x, floor_y, left, right, first, second, reward_scene)
	get_child(get_child_count() - 1).gate_texture = _gate_texture()


func _director_spawned(enemy: Node) -> void:
	Music.play("boss", 0.7)
	boss_phases_seen.append(0)
	enemy.defeated.connect(_record_boss_attacks)
	enemy.boss_health_changed.connect(func(_health: int, _maximum: int) -> void:
		# Faz değişimi apply_hit'in sonunda; bir sonraki karede doğrula.
		call_deferred(&"_record_boss_phase", enemy)
	)


func _record_boss_phase(enemy: Node) -> void:
	if is_instance_valid(enemy) and not boss_phases_seen.has(enemy.phase):
		boss_phases_seen.append(enemy.phase)


func _record_boss_attacks(enemy: Node) -> void:
	boss_attack_phases.assign(enemy.attack_phases)


func _director_defeated() -> void:
	boss_defeated = true
	_final_goal.set_deferred(&"monitoring", relays_cut == 3)
	Music.play("victory", 1.2)
	_update_objective()


func _build_wayfinding() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 3
	add_child(ui)
	_place = Label.new()
	_place.position = Vector2(440, 22)
	_place.add_theme_font_size_override(&"font_size", 19)
	_place.add_theme_color_override(&"font_color", Color("ead5a6"))
	_place.add_theme_color_override(&"font_outline_color", Color("101321"))
	_place.add_theme_constant_override(&"outline_size", 5)
	ui.add_child(_place)
	_objective = Label.new()
	_objective.position = Vector2(440, 52)
	_objective.add_theme_font_size_override(&"font_size", 15)
	_objective.add_theme_constant_override(&"outline_size", 5)
	ui.add_child(_objective)
	_update_objective()


func _update_objective() -> void:
	if _objective == null:
		return
	_objective.text = "Yayın güvende · Kıyıya dön" if boss_defeated else "Gazelle yayında · Son güverteye ulaş" if relays_cut == 3 else "Yayın bağlantıları: %d / 3" % relays_cut


func _process(_delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group(&"player")
		return
	var zone := 0
	for cut in CUTS:
		if _player.global_position.x >= cut:
			zone += 1
	if zone != _zone:
		_zone = zone
		_place.text = "%02d · %s" % [zone + 1, PLACES[zone]]


func play_ending(dialogue: Node) -> void:
	assert(boss_defeated and relays_cut == 3)
	_place.get_parent().visible = false
	var curtain := CanvasLayer.new()
	curtain.layer = 4
	add_child(curtain)
	var picture := TextureRect.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = DAWN
	var half := DAWN.get_size() * 0.5
	atlas.region = Rect2(half + Vector2(2, 2), half - Vector2(4, 4))
	picture.texture = atlas
	picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	curtain.add_child(picture)
	get_tree().paused = true
	dialogue.play([
		{"speaker": "İSTANBUL · SABAH", "text": "Kayıtlar çoğaltıldı. Su kesintisini ve susturma emirlerini verenlerin adları, sabah baskısıyla sokaklara çıktı."},
		{"speaker": "GAZELLE", "text": "İlk vapur kalkıyor. Bu sesleri özlemişim."},
		{"speaker": "REDMOUNT", "text": "Ben de. Bugün bir yere yetişmemiz gerekmiyor."},
		{"speaker": "SON", "text": "Üç kitap. Bir şehir. Susturulamayan binlerce ses.\nREDMOUNT — İstanbul'un Sesi"},
	])
	await dialogue.finished
	ending_seen = true
	curtain.queue_free()


func _material_at(x: float) -> int:
	return 0 if x < 24000 or x >= 260000 else 1 if x < 72000 else 3 if x >= 144000 and x < 192000 or x >= 252000 else 2


func _shop(x: float, title: String, items: PackedStringArray) -> void:
	super._shop(x, title, items)
	var shop: LevelShop = get_child(get_child_count() - 1)
	var atlas := AtlasTexture.new()
	atlas.atlas = SUPPLIES
	var region := 0 if x < 72000 else 1 if x < 144000 else 2 if x < 192000 else 3
	atlas.region = [Rect2(78, 81, 636, 454), Rect2(823, 69, 698, 464),
		Rect2(43, 580, 680, 398), Rect2(833, 630, 662, 343)][region]
	shop.facade_texture = atlas
	shop.z_index = -2
	shop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _platform(x: float, y: float, width: float, height: float) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(x, y)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	col.shape = shape
	body.add_child(col)
	body.add_child(_Surface.new(width, height, _material_at(x)))
	add_child(body)


func _oneway(x: float, y: float, width: float) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(x, y)
	body.collision_layer = 128
	body.collision_mask = 0
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 12)
	col.shape = shape
	col.one_way_collision = true
	body.add_child(col)
	var art := _Surface.new(width, 44, 1 if x < 72000 else 2)
	art.position.y = 16
	art.support_height = maxf(_surface_y(x) - y - 38, 0)
	body.add_child(art)
	add_child(body)


class _Surface extends Node2D:
	var width: float
	var height: float
	var tile: int
	var support_height := 0.0

	func _init(w: float, h: float, cell: int) -> void:
		width = w
		height = h
		tile = cell

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _draw() -> void:
		var half := SURFACES.get_size() * 0.5
		var origin := Vector2(tile % 2, tile / 2) * half + Vector2(2, 2)
		var slice_h := 90.0 if height < 60 else half.y - 4.0
		var tile_width := 460.0
		if support_height > 0:
			for side in [-1, 1]:
				draw_texture_rect_region(SURFACES,
					Rect2(side * (width * 0.5 - 26) - 10, height * 0.5, 20, support_height),
					Rect2(half.x + 32, 122, 70, half.y - 126))
		for i in ceili(width / tile_width):
			var w := minf(tile_width, width - i * tile_width)
			draw_texture_rect_region(SURFACES,
				Rect2(-width * 0.5 + i * tile_width, -height * 0.5, w, height),
				Rect2(origin, Vector2((half.x - 4) * w / tile_width, slice_h)))


class _FinalBackdrop extends Node2D:
	var _camera: Camera2D

	func _ready() -> void:
		z_index = -80
		z_as_relative = false
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _process(_delta: float) -> void:
		if _camera == null or not is_instance_valid(_camera):
			_camera = get_viewport().get_camera_2d()
			if _camera == null:
				return
		global_position = _camera.get_screen_center_position()
		queue_redraw()

	func _draw() -> void:
		var scene := 0
		for cut in CUTS:
			if global_position.x >= cut:
				scene += 1
		_draw_scene(scene, 1.0)
		if scene < CUTS.size() and global_position.x > CUTS[scene] - 900:
			_draw_scene(scene + 1, clampf((global_position.x - CUTS[scene] + 900) / 900, 0, 1))

	func _draw_scene(scene: int, alpha: float) -> void:
		var atlas: Texture2D = SHORE if scene < 4 else BROADCAST if scene < 8 else DAWN
		var local_scene := scene % 4
		var half := atlas.get_size() * 0.5
		var cell := Vector2(local_scene % 2, local_scene / 2) * half
		# Hafif paralaks: sanat ile karakter aynı hızda kaymaz.
		var drift := fposmod(global_position.x, 24000.0) / 24000.0 * 70.0
		draw_texture_rect_region(atlas, Rect2(-995 - drift, -600, 2060, 1200),
			Rect2(cell + Vector2(2, 2), half - Vector2(4, 4)), Color(1, 1, 1, alpha))
