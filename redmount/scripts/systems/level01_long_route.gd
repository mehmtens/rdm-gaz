## Bölüm 1'in uzun rota uzantısı.
## Elle bestelenmiş dört set parçasını kurar; rastgele üretim kullanılmaz.
extends Node2D

const STREET := preload("res://scenes/enemies/StreetThug.tscn")
const KNIFE := preload("res://scenes/enemies/KnifeAgent.tscn")
const COIN := preload("res://scenes/pickups/Coin.tscn")
const HEALTH := preload("res://scenes/pickups/HealthPickup.tscn")
const ARMOR := preload("res://scenes/pickups/ArmorPickup.tscn")
const BAT_PICKUP := preload("res://scenes/pickups/BatPickup.tscn")
const KNIFE_PICKUP := preload("res://scenes/pickups/KnifePickup.tscn")
const PISTOL_PICKUP := preload("res://scenes/pickups/PistolPickup.tscn")
const RIFLE_PICKUP := preload("res://scenes/pickups/RiflePickup.tscn")
const CHECKPOINT := preload("res://scenes/systems/Checkpoint.tscn")
const GOAL := preload("res://scenes/systems/LevelGoal.tscn")
const DIALOGUE := preload("res://scenes/systems/DialogueTrigger.tscn")
const ONEWAY := preload("res://scenes/systems/OneWayPlatform.tscn")
const MOVING := preload("res://scenes/systems/MovingPlatform.tscn")
const COLLAPSING := preload("res://scenes/systems/CollapsingPlatform.tscn")
const SPIKES := preload("res://scenes/systems/Spikes.tscn")
const ARENA := preload("res://scenes/systems/BattleArena.tscn")
const HINT := preload("res://scenes/systems/HintTrigger.tscn")
const BREAKABLE_WALL := preload("res://scenes/systems/BreakableWall.tscn")
const PROP := preload("res://scripts/systems/breakable_prop.gd")
const SHOP := preload("res://scripts/systems/level_shop.gd")

const ASPHALT := Color(0.22, 0.27, 0.35)
const BRICK := Color(0.38, 0.22, 0.29)
const METAL := Color(0.25, 0.34, 0.39)

var _serial := 0


func _ready() -> void:
	_remove_legacy_opening()
	_build_opening_district()
	_build_dolmus_stop()
	_build_scaffolds()
	_build_flood_canal()
	_build_convoy_yard()
	_build_night_market()
	_build_power_station()
	_build_rooftop_chase()
	_build_hotel_finale()


func _remove_legacy_opening() -> void:
	# Level01.tscn içindeki eski prototip parkur LongRoute düğümünden sonra gelir.
	# Hikâye denetleyicilerini koruyup bu dikdörtgen prototipi yeni rota ile değiştiririz.
	var level := get_parent()
	var found_route := false
	for child in level.get_children():
		if child == self:
			found_route = true
			continue
		if found_route:
			_disable_legacy_branch(child)
			child.call_deferred(&"queue_free")


func _disable_legacy_branch(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_DISABLED
	if node is CanvasItem:
		(node as CanvasItem).visible = false
	for group in node.get_groups():
		node.remove_from_group(group)
	for child in node.get_children():
		_disable_legacy_branch(child)


func _build_opening_district() -> void:
	# 00.000–01.600 — Köşe çaycısının yaşadığı, düz ve hızlı okunan sokak.
	_ground(350, 1100, 0, ASPHALT)
	# Öğretici: her hareket ilk gerektiği yerde, kendi düğmesiyle anlatılır.
	_hint(190, "Yürü. Minibüsün izi bu sokaktan kuzeye gidiyor.", "move")
	_hint(400, "Yumruk at. Üst üste basarsan kombo yaparsın.", "attack")
	_hint(640, "Ağır vuruş: yavaş ama sert, düşmanı savurur.", "heavy_attack")
	_hint(1100, "Zıpla. Basılı tutarsan daha yükseğe çıkarsın.", "jump")
	_hint(1340, "Platformdan aşağı inmek için eğilip zıpla.", "crouch")
	_hint(1900, "Üst yollar zorunlu değil; coin ve silah saklar.", "")
	_hint(2440, "Sopayı aldın. Vuruşların artık daha uzağa yetişir.", "attack")
	_hint(2700, "Bayrak kontrol noktasıdır. Düşersen buradan devam edersin.", "")
	_hint(3230, "Atıl: boşlukları hızla geç, saldırılardan sıyrıl.", "dash")
	_hint(4480, "Coin biriktir. İleride büfelerde can ve cephane alırsın.", "")
	_hint(5000, "Bulutlar bir saniye sonra dağılır. Üstünde bekleme!", "jump")
	_enemy(STREET, 460, 0)
	_enemy(STREET, 720, 0)
	_coin_line(450, 4, 95, -55)
	_prop("vazo", 880, 0, null, 3)
	_vehicle(1040, 0, 250, Color("d7c590"), Color("9d3f3f"))
	_ground(1450, 650, 0, ASPHALT)
	_oneway(1230, -145, 150, "awning") # çaycı tentesine çıkan kısa bonus dalı
	_coin_line(1230, 3, 105, -205)

	# 01.600–03.050 — Apartman önü ana yol; yangın merdiveni ödüllü üst rota.
	_ground(2180, 1250, 0, BRICK)
	_oneway(1780, -105, 150)
	_oneway(1980, -175, 160)
	_oneway(2200, -245, 170)
	_oneway(2440, -315, 180)
	_coin_line(1780, 4, 220, -370)
	_enemy(STREET, 2200, -270)
	_pickup(BAT_PICKUP, 2440, -370)
	# Yangın merdiveni dalının tepesinde sandık var: tırmanmanın karşılığı ödül.
	_prop("sandik", 2440, -315)
	_enemy(KNIFE, 2700, 0)
	_checkpoint(2700)

	# 03.050–04.450 — Yol çalışması: çukur üstünde kalaslar, üst üste blok yok.
	_sign(3320, -250, "YOL ÇALIŞMASI", Color(1.0, 0.72, 0.24),
		"Minibüs barikatı devirip geçmiş. Yolu Karahanlı'nın adamları bilerek kazdırmış.")
	_ground(3200, 530, 0, ASPHALT)
	_platform(3510, 45, 170, 30, METAL)
	_collapsing(3710, 20, 165, 1.0)
	_platform(3910, -5, 170, 30, METAL)
	_coin_arc(3440, 5, 120, -120)
	_ground(4290, 600, 0, ASPHALT)
	_enemy(STREET, 4320, 0)

	# 04.450–06.150 — Mahalle pazarı: zeminde koridor, tente üstünde hızlı rota.
	_ground(5150, 1400, 0, BRICK)
	for p in [[4660, -70], [4950, -115], [5240, -75], [5530, -125]]:
		_oneway(float(p[0]), float(p[1]), 230, "awning")
	_coin_arc(4620, 7, 160, -210)
	_enemy(STREET, 4950, -140)
	_enemy(KNIFE, 5600, 0)
	_prop_row("vazo", 5320, 3, 86)
	# Tente rotasından ayrılan gizli bulut merdiveni; ana yol için zorunlu değil.
	_cloud(5090, -205, 150)
	_cloud(5300, -270, 155)
	_cloud(5515, -335, 165)
	_coin_line(5090, 3, 212, -395)
	_prop("sandik", 5515, -341, ARMOR)
	# Bulut hattının sonunda cepheyle aynı sıvada, uzaktan sıradan görünen duvar.
	# Kıran oyuncu küçük çatı odasında coin ve tek bir güçlendirme bulur.
	# Ana yol zemini odanın altından kesintisiz sürer; gizli oda üstte kalır.
	_landmark(6120, "secret_room")
	_platform(6120, 26, 560, 52, BRICK, false)
	_platform(6120, -178, 560, 52, BRICK, false)
	_platform(6120, -408, 560, 42, BRICK, false)
	_platform(6380, -314, 42, 180, BRICK, false)
	_secret_wall(5850, -144)
	_coin_line(5980, 4, 72, -260)
	_pickup(ARMOR, 6280, -260)
	_checkpoint(6060)

	# 06.150–07.800 — Tamirhane avlusu: kapısız, iki seviyeli kısa çatışma.
	_sign(6550, -285, "TAMİR SOKAĞI", Color(0.25, 0.9, 0.78),
		"Gazelle kasetlerini bu sokaktaki tamirciye yaptırırdı. Kepenkler bu gece erkenden inmiş.")
	_ground(6860, 1760, 0, METAL)
	_oneway(6500, -105, 270)
	_oneway(6840, -170, 270)
	_enemy(STREET, 6500, -132)
	_enemy(KNIFE, 6820, 0)
	_enemy(STREET, 7140, 0)
	_coin_line(6500, 4, 170, -235)
	_dialogue(7330, "REDMOUNT", "Gazelle'in bana hazırladığı kaset... Turkuaz bandı hâlâ kapağında. Bunu kendi isteğiyle bırakmazdı.", "cassette")
	_pickup(HEALTH, 7480, -55)
	# İlk büfe: o ana kadar kırılan kapların coin'i burada ilk kez harcanır.
	_hint(7480, "Büfeye dokun: coin ile can ve cephane al.", "shop")
	_shop(7660, "KONTROL BÜFESİ", PackedStringArray(["can", "cephane"]), Color("ff5d5d"))

	# 07.800–09.200 — Depoya geçiş: sabit servis rampası ve tek vinç paleti.
	_ground(7950, 650, 0, ASPHALT)
	_prop_row("tup", 7900, 2, 70)
	_platform(8290, -55, 250, 38, METAL)
	_platform(8600, -115, 250, 38, METAL)
	_moving(8900, -115, Vector2(0, 100), 180, 4.2)
	_coin_line(8290, 4, 205, -185)
	_ground(9220, 520, 0, ASPHALT)
	_checkpoint(9200)


# Her bölge 25–45 saniyelik bir mekân vignette'ıdır: okunaklı ana yol,
# ödüllü üst dal, mekâna ait tek bir hareketli fikir ve kısa bir çatışma.
# Platformların tamamı çatı, tente, araç, iskele veya bakım geçidi olarak okunur.
func _build_dolmus_stop() -> void:
	_landmark(11100, "dolmus_stop", 175)
	_sign(9550, -255, "DOLMUŞ DURAĞI", Color(1.0, 0.72, 0.32),
		"Mahalleli Gazelle'i en son bu durakta görmüş. Durak şimdi bomboş.")
	_ground(9700, 1000, 0, ASPHALT)
	_street_steps(10200, [35, 70, 105, 140, 175])
	_ground(11250, 700, 175, ASPHALT)
	_street_steps(11600, [140, 105, 70, 35, 0])
	_checkpoint(9350)
	_enemy(STREET, 9700, 0)
	_coin_line(9480, 4, 120, -55)
	_prop("vazo", 9980, 0, null, 2)
	_prop("kasa", 10060)
	# Alt sokak durağın önünden iner; üst dal doğrudan resimdeki dolmuş çatılarından geçer.
	_oneway(10150, -60, 190, "roof")
	_oneway(10360, -120, 185, "roof")
	_platform(10740, -152, 300, 46, BRICK, false)
	_platform(11110, -127, 320, 46, BRICK, false)
	_platform(11490, -132, 300, 46, BRICK, false)
	_cloud(11030, -235, 160)
	_cloud(11245, -305, 175)
	_coin_arc(10770, 6, 100, -365)
	_enemy(STREET, 11110, -150)
	_pickup(BAT_PICKUP, 11245, -355)
	_prop("sandik", 11030, -235)
	_cloud(11450, -375, 155)
	_cloud(11665, -440, 170)
	_coin_line(11450, 2, 215, -495)
	_prop("vazo", 11665, -440, HEALTH)
	_ground(12800, 1000, 0, ASPHALT)
	_enemy(KNIFE, 12080, 35)
	_prop_row("kasa", 12230, 2, 92)
	# Tek hareketli unsur: servis platformu. Altında ölüm çukuru yok.
	_moving(12510, -62, Vector2(260, 0), 180, 4.2)
	_platform(12920, -70, 360, 42, METAL)
	_coin_line(12620, 4, 135, -145)
	_ground(13650, 1200, 0, ASPHALT)
	_checkpoint(13220)
	_enemy(STREET, 13520, 0)
	_enemy(STREET, 13830, 0)


func _build_scaffolds() -> void:
	_landmark(16350, "construction")
	_dialogue(14600, "REDMOUNT", "Durak boş. Lastik izleri yarım kalmış inşaata dönüyor.")
	_sign(14900, -280, "İNŞAAT 47", Color(1.0, 0.72, 0.24),
		"Karahanlı'nın paravan şantiyesi. Lastik izleri iskelelerin arasına giriyor.")
	_ground(13840, 920, 0, METAL)
	_street_steps(14300, [35, 70, 105, 140])
	_ground(15140, 560, 140, METAL)
	_street_steps(15420, [105, 70, 35, 0])
	_ground(16350, 740, 0, METAL)
	_prop_row("tup", 14820, 3, 66, 140)
	_enemy(KNIFE, 15100, 140)
	# Zemin kattaki güvenli geçiş ile iskele üstündeki coin rotası aynı anda görünür.
	_oneway(15480, 20, 170)
	for p in [[15680, -80], [15960, -145], [16240, -210], [16520, -210], [16800, -145]]:
		_oneway(float(p[0]), float(p[1]), 210, "scaffold")
	_coin_line(15680, 7, 185, -285)
	_enemy(STREET, 16240, -235)
	_pickup(HEALTH, 16520, -265)
	_prop("sandik", 16800, -145)
	_ground(17080, 720, 0, ASPHALT)
	_checkpoint(17020)
	_shop(17240, "ŞANTİYE KANTİNİ",
		PackedStringArray(["can", "cephane", "sopa"]), Color("ffb020"))
	# Vinç paleti bir ödül dalıdır; ilerlemek için beklemek gerekmez.
	_moving(17490, -170, Vector2(0, 125), 175, 3.8)
	_pickup(PISTOL_PICKUP, 17490, -235)
	_ground(18150, 1160, 0, ASPHALT)
	_enemy(STREET, 18020, 0)
	_enemy(KNIFE, 18320, 0)
	for p in [[18700, -45], [19000, -105], [19300, -165], [19600, -105]]:
		_platform(float(p[0]), float(p[1]), 220, 38, METAL)
	_coin_arc(18640, 8, 110, -245)
	_ground(20220, 1050, 0, ASPHALT)
	_enemy(STREET, 20100, 0)
	_checkpoint(20520)


func _build_flood_canal() -> void:
	_landmark(22600, "canal")
	_sign(21100, -245, "TAHLİYE KANALI", Color(0.25, 0.9, 0.78),
		"Konvoy ana caddede görünmemek için eski kanal yolunu kullanmış.")
	_ground(21320, 890, 0, METAL)
	_checkpoint(21100)
	_enemy(STREET, 21450, 0)
	# Su üstündeki eski bakım döşemeleri: kısa, bağışlayıcı ve bağlama uygun.
	for i in 6:
		_collapsing(21820 + i * 178, -12 - (i % 2) * 18, 155, 0.85)
	_coin_line(21820, 6, 178, -92)
	_ground(23280, 900, 0, METAL)
	_enemy(KNIFE, 23380, 0)
	_prop("varil", 23180)
	_prop("kasa", 23520)
	# Menfez üstü opsiyonel servis köprüsü.
	_oneway(23780, -105, 165)
	_oneway(24000, -175, 165)
	_oneway(24220, -245, 165)
	_coin_line(23780, 3, 220, -300)
	_pickup(ARMOR, 24220, -300)
	_prop("sandik", 24000, -175)
	_ground(24480, 1240, 0, ASPHALT)
	_enemy(STREET, 24500, 0)
	_prop_row("vazo", 24620, 2, 72)
	_checkpoint(24900)
	# Drenaj kapağı çevresinde iki seviyeli çatışma.
	_platform(25280, -45, 280, 40, METAL)
	_platform(25620, -100, 280, 40, METAL)
	_enemy(STREET, 25280, -115)
	_enemy(KNIFE, 25720, 0)
	_ground(26200, 900, 0, METAL)
	_moving(26720, -85, Vector2(260, -35), 180, 4.5)
	_coin_arc(26560, 5, 120, -190)
	_ground(27450, 1650, 0, ASPHALT)
	_enemy(STREET, 27350, 0)
	_enemy(KNIFE, 27700, 0)


func _build_convoy_yard() -> void:
	_landmark(30500, "convoy")
	_dialogue(29200, "REDMOUNT", "Konvoyun motoru hâlâ sıcak. Gazelle birkaç dakika önde.")
	_sign(29400, -280, "KONVOY AVLUSU", Color(1.0, 0.35, 0.32),
		"Araçların toplandığı avlu. Motorlar hâlâ sıcak; Gazelle birkaç dakika önde.")
	_ground(29450, 4220, 0, ASPHALT)
	_checkpoint(29100)
	_enemy(STREET, 29450, 0)
	_prop_row("kasa", 29620, 3, 88)
	# Dolmuş ve kamyonet tavanları; zeminden yürümek de mümkündür.
	# Dolmuşların çizimi ve çatı çarpışmaları aynı zemin kotunu kullanır.
	for p in [[29810, 0], [30305, 0], [30800, 0], [31295, 0]]:
		_vehicle(float(p[0]), float(p[1]), 300, Color.WHITE, Color.WHITE, true)
	_coin_arc(29980, 8, 205, -185)
	_enemy(KNIFE, 30720, -82)
	_pickup(KNIFE_PICKUP, 31440, -118)
	_ground(32050, 980, 0, METAL)
	_enemy(STREET, 31920, 0)
	_enemy(KNIFE, 32240, 0)
	# Konvoy kargosu: üst üste değil, yan yana — dövüş alanını kapatmaz.
	_prop_row("kasa", 31640, 3, 88)
	_checkpoint(32400)
	# Açık bagaj rampası üst kata çıkar; palet yalnızca kısayoldur.
	_oneway(32780, -45, 260)
	_oneway(33110, -110, 260)
	_oneway(33440, -175, 260)
	_moving(33780, -165, Vector2(0, 105), 180, 4.0)
	_coin_line(32780, 6, 200, -240)
	_pickup(HEALTH, 33780, -225)
	_ground(34500, 2200, 0, ASPHALT)
	_checkpoint(34000)
	_prop("tup", 34180)
	_enemy(STREET, 34420, 0)
	_enemy(KNIFE, 34800, 0)
	_enemy(STREET, 35200, 0)
	_shop(35480, "KONVOY BÜFESİ",
		PackedStringArray(["can", "zirh"]), Color("4de3c1"))
	_dialogue(35900, "REDMOUNT", "Sevkiyat fişi: Kuzey Hanı. Gazelle'i oraya götürüyorlar.")


func _build_night_market() -> void:
	_landmark(38900, "market", 140)
	_sign(37000, -270, "GECE PAZARI", Color(1.0, 0.35, 0.72),
		"Esnaf susturulmuş. Tezgâhların arasında Karahanlı'nın gözcüleri dolaşıyor.")
	_ground(36100, 2400, 0, BRICK)
	_street_steps(37300, [35, 70, 105, 140])
	_ground(38480, 1240, 140, BRICK)
	_street_steps(39100, [105, 70, 35, 0])
	_checkpoint(36800)
	# Pazar tezgâhlarının testi/saksı sırası — bölümün en yoğun kap kümesi.
	_prop_row("vazo", 36980, 3, 74)
	_prop("saksi", 37220)
	_enemy(STREET, 37100, 0)
	# Tezgâh arası ana koridor ve tente üstünde kesintisiz bonus hattı.
	var awnings := [[37720, -55], [38020, -90], [38320, -125], [38620, -90],
		[38920, -55], [39220, -105], [39520, -65]]
	for p in awnings:
		_oneway(float(p[0]), float(p[1]), 245, "awning")
	_coin_arc(37680, 11, 180, -205)
	_enemy(KNIFE, 38620, -115)
	_pickup(ARMOR, 39520, -120)
	_ground(40150, 1220, 0, ASPHALT)
	_enemy(STREET, 40000, 0)
	_enemy(KNIFE, 40340, 0)
	_checkpoint(40700)
	# Bölümün ana dükkânı: dört kalem, en geniş seçim.
	_shop(39840, "GECE PAZARI",
		PackedStringArray(["can", "cephane", "bicak", "zirh"]), Color("ff5dab"))
	# Kapalı arena yerine kahvehane önü: alçak masa/tezgâhlarla katmanlı dövüş.
	_ground(41600, 1600, 0, BRICK)
	_oneway(41220, -92, 250)
	_oneway(41600, -155, 280)
	_oneway(42010, -92, 250)
	_enemy(STREET, 41220, -118)
	_enemy(KNIFE, 41650, 0)
	_enemy(STREET, 42010, -118)
	_coin_line(41220, 5, 195, -220)
	_prop_row("saksi", 41310, 3, 78)
	_cloud(41480, -245, 155)
	_cloud(41700, -310, 165)
	_cloud(41930, -375, 175)
	_coin_line(41480, 3, 225, -430)
	_prop("sandik", 41930, -381, PISTOL_PICKUP)
	_prop("sandik", 41600, -155)
	_ground(43350, 1800, 0, ASPHALT)
	_enemy(KNIFE, 43150, 0)
	_prop_row("vazo", 42900, 2, 76)


func _build_power_station() -> void:
	_landmark(46200, "power")
	_dialogue(44500, "REDMOUNT", "Telsiz sesi yakında. Kuzey hattını izlemeliyim.")
	_sign(44900, -275, "KUZEY TRAFO", Color(0.35, 0.9, 1.0),
		"Mahallenin elektriği buradan kesildi. Telsiz sesleri içeriden geliyor.")
	_checkpoint(44500)
	_ground(44800, 1000, 0, METAL)
	_prop_row("varil", 44420, 2, 78)
	_enemy(STREET, 44900, 0)
	_prop_row("tup", 45050, 2, 68)
	# Elektrik tehlikesi zemindeki dar bir kanal; üstte sabit bakım geçidi var.
	_spikes(45680, 360)
	_oneway(45430, -55, 240)
	_oneway(45730, -110, 240)
	_oneway(46030, -55, 240)
	_coin_line(45430, 4, 200, -175)
	_ground(46650, 1370, 0, ASPHALT)
	_enemy(KNIFE, 46650, 0)
	_enemy(STREET, 46940, 0)
	_checkpoint(47200)
	_ground(48000, 1300, 0, ASPHALT)
	# Zikzak bakım geçidi coin/tüfek ödüllü üst rotadır; alt koridor kesintisizdir.
	var switchbacks := [[47580, -55], [47880, -110], [48180, -165],
		[48480, -110], [48780, -55]]
	for p in switchbacks:
		_oneway(float(p[0]), float(p[1]), 230)
	_coin_arc(47520, 8, 185, -285)
	_pickup(RIFLE_PICKUP, 48180, -250)
	_prop("sandik", 47880, -110)
	_ground(49800, 2300, 0, BRICK)
	_enemy(STREET, 49500, 0)
	_enemy(KNIFE, 49900, 0)
	_enemy(STREET, 50320, 0)
	_prop("varil", 50150)
	_moving(50780, -150, Vector2(0, 115), 180, 4.0)
	_pickup(HEALTH, 50780, -215)
	_ground(51400, 800, 0, ASPHALT)


func _build_rooftop_chase() -> void:
	_landmark(54000, "rooftops")
	_sign(52200, -300, "KUZEY ÇATILARI", Color(0.75, 0.58, 1.0),
		"Sokaklar tutulmuş. Hana giden tek açık yol çatılar.")
	_checkpoint(51900)
	_ground(52150, 700, 0, ASPHALT)
	_enemy(KNIFE, 52100, 0)
	_prop("saksi", 51920)
	# Birbirine yaklaşan apartman çatıları, balkonlar ve su deposu.
	for p in [[52620, -45], [52940, -90], [53260, -140], [53580, -90], [53900, -45]]:
		_platform(float(p[0]), float(p[1]), 245, 44, BRICK)
	_coin_arc(52580, 8, 190, -235)
	_enemy(KNIFE, 53260, -168)
	# Çatı saksıları: kap kırma ritmi yüksek rotada da sürer.
	_prop("saksi", 52940, -112)
	_prop("saksi", 53580, -112)
	_oneway(53780, -205, 170)
	_oneway(54010, -270, 170)
	_pickup(ARMOR, 54010, -325)
	_prop("sandik", 53780, -205)
	# Çamaşırhane yük sepeti üst rotayı yere bağlar; zorunlu değildir.
	_moving(54320, -160, Vector2(0, 120), 180, 4.3)
	_ground(55080, 1860, 0, BRICK)
	_enemy(STREET, 54880, 0)
	_enemy(KNIFE, 55240, 0)
	_prop_row("saksi", 55400, 3, 72)
	_checkpoint(55850)
	_ground(56900, 1930, 0, METAL)
	_oneway(56300, -105, 260)
	_oneway(56640, -170, 260)
	_enemy(STREET, 56640, -198)
	_enemy(KNIFE, 57000, 0)
	_coin_line(56300, 5, 170, -235)
	_ground(58600, 1500, 0, ASPHALT)
	_enemy(STREET, 58400, 0)
	_enemy(KNIFE, 58800, 0)


func _build_hotel_finale() -> void:
	_landmark(62600, "hotel")
	_dialogue(60000, "REDMOUNT", "Kuzey Hanı göründü. Kasetin kopmuş turkuaz bandı kapıya takılmış.")
	_sign(60400, -310, "KUZEY HANI", Color(1.0, 0.72, 0.22),
		"Karahanlı'nın mahalledeki karargâhı. Gazelle bu kapıdan geçirildi.")
	_checkpoint(59850)
	_ground(60300, 1900, 0, BRICK)
	_prop_row("vazo", 59700, 2, 78)
	_enemy(STREET, 60350, 0)
	_enemy(KNIFE, 60700, 0)
	_prop_row("vazo", 60600, 2, 74)
	# Hanın ahşap balkonları avlunun üst rotasıdır; alt avlu açık kalır.
	_ground(62050, 1600, 0, BRICK)
	var balconies := [[61080, -70], [61400, -130], [61720, -195],
		[62040, -195], [62360, -130], [62680, -70]]
	for p in balconies:
		_oneway(float(p[0]), float(p[1]), 245)
	_coin_arc(61040, 9, 200, -285)
	_enemy(STREET, 61720, -222)
	_pickup(HEALTH, 62360, -185)
	# Balkon dalının tepesindeki sandık zırh verir: arenaya hazırlık ödülü.
	_prop("sandik", 62040, -195, ARMOR)
	_ground(63750, 1800, 0, ASPHALT)
	_checkpoint(63400)
	_shop(63200, "HAN TEZGÂHI",
		PackedStringArray(["can", "cephane", "zirh", "tabanca"]), Color("d6a54a"))
	_enemy(KNIFE, 63700, 0)
	_enemy(STREET, 64100, 0)
	# Son yaklaşımda han tabelası ve sundurmalar, soyut slalom değil.
	_oneway(64720, -55, 280)
	_oneway(65070, -110, 280)
	_oneway(65420, -55, 280)
	_enemy(KNIFE, 65070, -152)
	_coin_line(64720, 4, 230, -190)
	_prop("sandik", 65420, -55, RIFLE_PICKUP)
	_ground(66700, 2700, 0, METAL)
	_prop_row("varil", 65900, 2, 80)
	_arena(66700, 66100, 67400,
		_wave(STREET, KNIFE),
		_wave(KNIFE, STREET),
		_wave(STREET, KNIFE), HEALTH, true)
	_dialogue(67700, "REDMOUNT", "Geçit kapanmadan içeri girmeliyim. Gazelle burada.")
	_goal(68100)
	_wall(68450)


# --- İnşa yardımcıları -----------------------------------------------------

func _ground(x: float, width: float, surface: float, color: Color) -> void:
	_platform(x, surface + 110.0, width, 220.0, color)


func _street_steps(start_x: float, depths: Array[int]) -> void:
	for i in depths.size():
		_ground(start_x + i * 140.0 + 70.0, 140.0, float(depths[i]), ASPHALT)


func _platform(x: float, y: float, width: float, height: float, color: Color, visible_art := true) -> void:
	_serial += 1
	var body := StaticBody2D.new()
	body.name = "RouteSolid%d" % _serial
	body.position = Vector2(x, y)
	var col := CollisionShape2D.new()
	col.name = "Col"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	col.shape = shape
	body.add_child(col)
	if visible_art:
		var vis := Polygon2D.new()
		vis.name = "Vis"
		var half := Vector2(width, height) * 0.5
		var visual_bottom := -half.y + minf(height, 64.0)
		vis.polygon = PackedVector2Array([
			Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
			Vector2(half.x, visual_bottom), Vector2(-half.x, visual_bottom),
		])
		vis.color = color.darkened(0.22) if height >= 100.0 else color
		body.add_child(vis)
		body.add_child(_RouteSurface.new(width, height, color))
	add_child(body)


func _vehicle(x: float, ground_y: float, width: float, body_color: Color, stripe: Color,
		_background_only := false) -> void:
	_serial += 1
	var body := StaticBody2D.new()
	body.name = "ClimbableDolmus%d" % _serial
	body.position = Vector2(x, ground_y - 39.0)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width - 18.0, 26.0)
	col.shape = shape
	col.position = Vector2(0, -38)
	body.add_child(col)
	body.add_child(_RouteVehicle.new(width, body_color, stripe))
	add_child(body)


func _oneway(x: float, y: float, width: float, style: String = "metal") -> void:
	var node := ONEWAY.instantiate()
	node.position = Vector2(x, y)
	node.set("width", width)
	node.set("style", style)
	add_child(node)


## Gizli bonus dalı basamağı: bulut stilinde tek yön platform. Ana yolun üstünde
## durur, ilerlemek için gerekmez; tepesinde coin yığını veya sandık vardır.
func _cloud(x: float, y: float, width: float) -> void:
	var node := ONEWAY.instantiate()
	node.position = Vector2(x, y)
	node.set("width", width)
	node.set("style", "cloud")
	add_child(node)


func _moving(x: float, y: float, travel: Vector2, width: float, period: float, phase := 0.0) -> void:
	var node := MOVING.instantiate()
	node.position = Vector2(x, y)
	node.set("travel", travel)
	node.set("width", width)
	node.set("period", period)
	node.set("phase_offset", phase)
	add_child(node)


func _collapsing(x: float, y: float, width: float, delay: float) -> void:
	var node := COLLAPSING.instantiate()
	node.position = Vector2(x, y)
	node.set("width", width)
	node.set("fall_delay", delay)
	add_child(node)


func _spikes(x: float, width: float) -> void:
	var node := SPIKES.instantiate()
	node.position = Vector2(x, 130)
	node.set("width", width)
	add_child(node)


func _enemy(scene: PackedScene, x: float, y: float) -> void:
	var node := scene.instantiate()
	node.position = Vector2(x, y)
	add_child(node)


func _pickup(scene: PackedScene, x: float, y: float) -> void:
	var node := scene.instantiate()
	node.position = Vector2(x, y)
	add_child(node)


func _checkpoint(x: float) -> void:
	var node := CHECKPOINT.instantiate()
	node.position = Vector2(x, 0)
	add_child(node)


## Kırılabilir kap. `y` zemin kotudur (platform üstüne konurken platformun y'si).
func _prop(kind: String, x: float, y: float = 0.0, reward: PackedScene = null, hits: int = 0) -> void:
	var node: BreakableProp = PROP.new()
	node.kind = kind
	node.hits_override = hits
	if kind == "saksi":
		node.art = preload("res://assets/environment/mahalle/plant_small.png")
	node.reward = reward
	node.position = Vector2(x, y)
	add_child(node)


func _prop_row(kind: String, x: float, count: int, spacing: float, y: float = 0.0) -> void:
	for i in count:
		_prop(kind, x + float(i) * spacing, y, null, i % 3 + 1 if kind == "vazo" else 0)


func _shop(x: float, title: String, items: PackedStringArray, accent: Color) -> void:
	var node: LevelShop = SHOP.new()
	node.title = title
	node.items = items
	node.accent = accent
	node.position = Vector2(x, 0)
	add_child(node)


func _hint(x: float, text: String, button := "") -> void:
	var node := HINT.instantiate()
	node.position = Vector2(x, -60)
	node.set("text", text)
	node.set("button", button)
	add_child(node)


func _dialogue(x: float, speaker: String, text: String, clue_visual := "") -> void:
	var node := DIALOGUE.instantiate()
	node.position = Vector2(x, -70)
	node.set("speakers", PackedStringArray([speaker]))
	node.set("texts", PackedStringArray([text]))
	if not clue_visual.is_empty():
		node.set("clue_visual", clue_visual)
	add_child(node)


func _goal(x: float) -> void:
	var node := GOAL.instantiate()
	node.position = Vector2(x, 0)
	add_child(node)


func _wall(x: float) -> void:
	_platform(x, -120, 60, 520, BRICK)


func _secret_wall(x: float, y: float) -> void:
	var node := BREAKABLE_WALL.instantiate()
	node.position = Vector2(x, y)
	add_child(node)


func _coin_line(start_x: float, count: int, spacing: float, y: float) -> void:
	for i in count:
		_pickup(COIN, start_x + i * spacing, y)


func _coin_arc(start_x: float, count: int, spacing: float, top_y: float) -> void:
	for i in count:
		var t := float(i) / maxf(float(count - 1), 1.0)
		var y := top_y + absf(t - 0.5) * 130.0
		_pickup(COIN, start_x + i * spacing, y)


func _wave(a: PackedScene, b: PackedScene, c: PackedScene = null) -> Array[PackedScene]:
	var result: Array[PackedScene] = [a, b]
	if c != null:
		result.append(c)
	return result


func _empty_wave() -> Array[PackedScene]:
	return []


func _arena(x: float, left: float, right: float, first: Array[PackedScene],
		second: Array[PackedScene], third: Array[PackedScene], reward_scene: PackedScene,
		locked := false) -> void:
	var node: BattleArena = ARENA.instantiate()
	node.position = Vector2(x, 0)
	node.gate_left_x = left
	node.gate_right_x = right
	node.floor_y = 0
	node.wave1 = first
	node.wave2 = second
	node.wave3 = third
	node.wave_delay = 0.65
	node.reward = reward_scene
	node.use_gates = locked
	node.lock_camera = locked
	add_child(node)


func _landmark(x: float, kind: String, y: float = 0.0) -> void:
	var landmark := _RouteLandmark.new(kind)
	landmark.position = Vector2(x, y)
	landmark.z_index = -3
	add_child(landmark)


## Mekân tabelası. `story` verilirse oyuncu tabelaya vardığında ekranda mekânın
## adı ve hikâyedeki yeri kısa bir pankartla gösterilir.
func _sign(x: float, y: float, text: String, color: Color, story := "") -> void:
	var sign := _RouteSign.new(text, color)
	sign.position = Vector2(x, y)
	add_child(sign)
	if not story.is_empty():
		var place := StoryPlace.new()
		place.title = text
		place.story = story
		place.accent = color
		place.position = Vector2(x, 0)
		add_child(place)


class _RouteSign extends Node2D:
	var _text: String
	var _color: Color

	func _init(text: String, color: Color) -> void:
		_text = text
		_color = color

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _draw() -> void:
		PixelText.sign_board(self, Vector2.ZERO, _text, _color)


class _RouteSurface extends Node2D:
	const PAVING := preload("res://assets/environment/mahalle/ground_long.png")
	const STONE := preload("res://assets/environment/mahalle/stone_fill.png")
	const LEDGE := preload("res://assets/environment/mahalle/ledge_l.png")
	const ROOF := preload("res://assets/environment/mahalle/roof_a.png")
	var _width: float
	var _height: float
	var _color: Color

	func _init(width: float, height: float, color: Color) -> void:
		_width = width
		_height = height
		_color = color

	func _ready() -> void:
		z_index = 1

	func _draw() -> void:
		var left := -_width * 0.5
		var top := -_height * 0.5
		if _height >= 100:
			draw_texture_rect(STONE, Rect2(left, top + 32, _width, _height - 32), true, Color("7b768e"))
			draw_texture_rect(PAVING, Rect2(left, top, _width, 90), true, Color("c8bbc3"))
		else:
			var texture: Texture2D = ROOF if _color.r > _color.g else LEDGE
			draw_texture_rect(texture, Rect2(left, top, _width, _height + 18), false)


class _RouteVehicle extends Node2D:
	const BUS := preload("res://assets/environment/mahalle/bus.png")
	var _width: float
	func _init(width: float, _body_color: Color, _stripe: Color) -> void:
		_width = width
	func _ready() -> void:
		z_index = -1
	func _draw() -> void:
		# Çatı zeminden 90 px yukarıda: başlangıç zıplamasıyla erişilir.
		draw_texture_rect(BUS, Rect2(-_width * 0.5, -51, _width, 90), false)


class _RouteLandmark extends Node2D:
	var _kind: String
	const FADE := preload("res://shaders/landmark_fade.gdshader")
	const LOCATION_ATLAS := preload("res://assets/backgrounds/level01_turkish_locations_atlas.png")
	const CONVOY_ART := preload("res://assets/backgrounds/level01_convoy_yard_v2.png")
	const SECRET_A := preload("res://assets/environment/mahalle/house_a.png")
	const SECRET_C := preload("res://assets/environment/mahalle/house_c.png")
	const BUS := preload("res://assets/environment/mahalle/bus.png")
	const INK := Color("17162b")
	const PLASTER := Color("3c4350")
	const BLUE := Color("596d7c")
	const TILE := Color("a9503e")
	const AMBER := Color("ffc857")
	const TURQUOISE := Color("43b9ac")
	const MUNICIPAL := Color("e2ad3f")
	const WOOD := Color("76503b")

	func _init(kind: String) -> void:
		_kind = kind

	func _ready() -> void:
		var fade := ShaderMaterial.new()
		fade.shader = FADE
		material = fade

	func _draw() -> void:
		if _kind == "secret_room":
			draw_texture_rect(SECRET_A, Rect2(-280, -430, 280, 430), false)
			draw_texture_rect(SECRET_C, Rect2(0, -430, 280, 430), false)
			return
		if _kind == "convoy":
			draw_texture_rect(CONVOY_ART, Rect2(-960, -620, 1920, 620), false)
			return
		var cells := {
			"dolmus_stop": Vector2i(1, 1), "construction": Vector2i(1, 0),
			"canal": Vector2i(0, 1), "market": Vector2i(0, 2),
			"power": Vector2i(1, 2), "rooftops": Vector2i(0, 3),
			"hotel": Vector2i(1, 3),
		}
		if cells.has(_kind):
			var cell: Vector2i = cells[_kind]
			draw_texture_rect_region(LOCATION_ATLAS, Rect2(-960, -620, 1920, 620),
				Rect2(cell.x * 768 + 5, cell.y * 256 + 5, 758, 230))
			return
		match _kind:
			"dolmus_stop": _dolmus_stop()
			"construction": _construction()
			"canal": _canal()
			"convoy": _convoy()
			"market": _market()
			"power": _power()
			"rooftops": _rooftops()
			"hotel": _hotel()

	func _dolmus_stop() -> void:
		# Küçük bilet gişesi ve sefer panosu; mahalle dokusu arkada görünür kalır.
		draw_rect(Rect2(-760, -280, 520, 280), Color("252d3b"))
		draw_rect(Rect2(-735, -255, 470, 170), Color("6b8790"))
		for x in range(-710, -280, 110):
			draw_rect(Rect2(x, -245, 75, 120), Color("30485a"))
		draw_rect(Rect2(-810, -315, 640, 42), TURQUOISE)
		for x in range(-810, -170, 80):
			draw_rect(Rect2(x, -315, 40, 42), Color("e7d2a5"))
		draw_rect(Rect2(-640, -225, 230, 48), INK)
		draw_string(ThemeDB.fallback_font, Vector2(-625, -192), "DOLMUŞ DURAĞI", HORIZONTAL_ALIGNMENT_CENTER, 200, 20, AMBER)
		draw_rect(Rect2(-90, -260, 250, 230), Color("2b3441"))
		draw_rect(Rect2(-72, -241, 214, 40), MUNICIPAL)
		draw_string(ThemeDB.fallback_font, Vector2(-62, -213), "SEFERLER", HORIZONTAL_ALIGNMENT_CENTER, 194, 18, INK)
		for i in 3:
			draw_rect(Rect2(-62, -178 + i * 46, 175, 7), Color("e8dfc7"))
		for x in [-540.0, -120.0, 280.0]:
			draw_rect(Rect2(x, -105, 18, 105), Color("4e4650"))
		draw_texture_rect(BUS, Rect2(210, -117, 335, 117), false)
		draw_texture_rect(BUS, Rect2(555, -103, 295, 103), false, Color("b7b9c5"))
		_lamp(-810, -310); _lamp(900, -310)

	func _construction() -> void:
		# Belediye bariyerleri, kaba tuğla katlar ve platform işlevi gören iskeleler.
		draw_rect(Rect2(-860, -330, 1720, 330), Color("343744"))
		for x in range(-820, 821, 205):
			draw_line(Vector2(x, -530), Vector2(x, 0), Color("706555"), 12)
		for y in range(-480, -30, 90):
			draw_line(Vector2(-850, y), Vector2(850, y), Color("9a6a3e"), 10)
		for i in 7:
			var x := -780.0 + i * 250.0
			draw_rect(Rect2(x, -48, 190, 48), MUNICIPAL)
			for stripe in 3:
				draw_colored_polygon(PackedVector2Array([Vector2(x + stripe * 64, -48), Vector2(x + stripe * 64 + 28, -48), Vector2(x + stripe * 64 + 58, 0), Vector2(x + stripe * 64 + 30, 0)]), Color("f2eee0"))
		draw_line(Vector2(-700, -530), Vector2(540, -650), Color("be7540"), 18)
		draw_line(Vector2(390, -650), Vector2(390, -500), Color("be7540"), 8)
		draw_rect(Rect2(-170, -220, 340, 52), Color("272837"))
		draw_string(ThemeDB.fallback_font, Vector2(-150, -187), "İNŞAAT ALANI", HORIZONTAL_ALIGNMENT_CENTER, 300, 22, AMBER)

	func _canal() -> void:
		# Kesme taş duvar, yosun, menfezler, bakım merdiveni ve akan su.
		draw_colored_polygon(PackedVector2Array([Vector2(-1050, -280), Vector2(-690, 20), Vector2(690, 20), Vector2(1050, -280), Vector2(1050, 90), Vector2(-1050, 90)]), Color("60666d"))
		for y in range(-250, 10, 38):
			for x in range(-940, 941, 92):
				draw_rect(Rect2(x + (45 if (y / 38 as int) % 2 else 0), y, 72, 6), Color("383e48"))
		for x in [-530.0, 0.0, 530.0]:
			draw_rect(Rect2(x - 72, -90, 144, 110), INK)
			draw_colored_polygon(PackedVector2Array([Vector2(x - 72, -90), Vector2(x, -146), Vector2(x + 72, -90)]), INK)
			for sx in range(-55, 56, 22):
				draw_rect(Rect2(x + sx, -10, 14, 70), Color("2b8092"))
		for y in range(-230, -15, 32):
			draw_line(Vector2(760, y), Vector2(850, y), Color("b6a274"), 7)
		draw_line(Vector2(780, -250), Vector2(780, 20), Color("b6a274"), 7)
		draw_line(Vector2(835, -250), Vector2(835, 20), Color("b6a274"), 7)

	func _convoy() -> void:
		# Her araç farklı park açısında/renkte: Türk minibüsü, panelvan, eski kamyonet.
		draw_rect(Rect2(-980, -300, 1960, 300), Color("343845"))
		for bx in [-760.0, -260.0, 240.0, 740.0]:
			draw_rect(Rect2(bx - 90, -282, 180, 120), Color("4b5260"))
			_pixel_window(Rect2(bx - 58, -254, 48, 48), false)
			_pixel_window(Rect2(bx + 14, -254, 48, 48), int(bx) % 2 == 0)
		_van(-690, Color("d9d2be"), TURQUOISE)
		_van(-195, Color("c7c9c1"), Color("416d9b"))
		_van(300, Color("e3dcc7"), TILE)
		_van(795, Color("b8b6a8"), MUNICIPAL)
		draw_rect(Rect2(-245, -355, 490, 58), Color("282837"))
		draw_string(ThemeDB.fallback_font, Vector2(-225, -318), "DOLMUŞ · KUZEY HATTI", HORIZONTAL_ALIGNMENT_CENTER, 450, 23, AMBER)

	func _market() -> void:
		# Renkli brandalar altında gerçek tezgâhlar; ürün kasaları ve simit arabası.
		draw_rect(Rect2(-1050, -260, 2100, 260), Color("34313e"))
		for i in 6:
			var x := -900.0 + i * 340.0
			var c := TILE if i % 3 == 0 else (TURQUOISE if i % 3 == 1 else MUNICIPAL)
			_stall(x, c)
		for x in range(-880, 900, 80):
			draw_rect(Rect2(x, -36, 58, 36), WOOD)
			draw_rect(Rect2(x + 8, -29, 12, 10), Color("86a34d"))
			draw_rect(Rect2(x + 30, -29, 12, 10), Color("c84d45"))
		# Simit arabası.
		draw_rect(Rect2(710, -92, 190, 72), Color("c84545"))
		draw_rect(Rect2(730, -145, 150, 53), Color("f0ede2"))
		for x in range(748, 865, 30):
			draw_rect(Rect2(x, -130, 18, 18), Color("cf8a35"), false, 5)
		draw_rect(Rect2(755, -182, 100, 36), Color("84343d"))
		draw_string(ThemeDB.fallback_font, Vector2(765, -158), "SİMİT", HORIZONTAL_ALIGNMENT_CENTER, 80, 18, Color("f5e2bd"))

	func _power() -> void:
		# Mahalle trafo bahçesi: tel örgü, porselen izolatör, uyarı levhası ve sarmaşık.
		draw_rect(Rect2(-1030, -300, 2060, 300), Color("2b3039"))
		for x in range(-1000, 1001, 54):
			draw_line(Vector2(x, -250), Vector2(x + 180, 0), Color("687079"), 3)
			draw_line(Vector2(x + 180, -250), Vector2(x, 0), Color("687079"), 3)
		for px in [-620.0, 0.0, 620.0]:
			draw_line(Vector2(px - 120, 0), Vector2(px, -500), Color("555b63"), 14)
			draw_line(Vector2(px + 120, 0), Vector2(px, -500), Color("555b63"), 14)
			draw_line(Vector2(px - 130, -350), Vector2(px + 130, -350), WOOD, 12)
			for ix in [-90.0, 0.0, 90.0]:
				for iy in range(-400, -350, 12):
					draw_rect(Rect2(px + ix - 9, iy, 18, 7), Color("d5c9a8"))
		draw_rect(Rect2(-145, -222, 290, 150), MUNICIPAL)
		draw_colored_polygon(PackedVector2Array([Vector2(0, -200), Vector2(-48, -112), Vector2(48, -112)]), INK)
		draw_string(ThemeDB.fallback_font, Vector2(-112, -88), "DİKKAT", HORIZONTAL_ALIGNMENT_CENTER, 224, 25, INK)

	func _rooftops() -> void:
		# Kiremitler, su depoları, çamaşırlar, güvercinlik ve birbirinden farklı apartmanlar.
		for i in 7:
			var h := 190.0 + float((i * 67) % 180)
			var x := -1040.0 + i * 325.0
			var c := Color("485362") if i % 2 == 0 else Color("544753")
			draw_rect(Rect2(x, -h, 285, h), c)
			_tile_roof(x - 18, -h, 321)
			for wy in range(int(-h + 55), -25, 74):
				_pixel_window(Rect2(x + 38, wy, 54, 42), (wy / 74 as int) % 2 == 0)
				_pixel_window(Rect2(x + 178, wy, 54, 42), (wy / 74 as int) % 3 == 0)
		# Su deposu, uydu çanakları ve çamaşır ipi.
		draw_rect(Rect2(-420, -520, 170, 110), Color("64717a"))
		draw_rect(Rect2(-438, -536, 206, 20), INK)
		draw_rect(Rect2(-390, -410, 16, 80), INK); draw_rect(Rect2(-300, -410, 16, 80), INK)
		draw_line(Vector2(210, -410), Vector2(800, -350), Color("242430"), 4)
		for x in range(290, 760, 90):
			draw_rect(Rect2(x, -390 + (x % 4) * 5, 48, 58), TILE if x % 180 == 0 else TURQUOISE)

	func _hotel() -> void:
		# Osmanlı pastişi değil; Cumhuriyet dönemi şehir hanı, avlulu ve yaşanmış.
		draw_rect(Rect2(-980, -620, 1960, 620), Color("776452"))
		_tile_roof(-1020, -620, 2040)
		for y in [-520.0, -405.0, -290.0]:
			for x in range(-835, 836, 210):
				_pixel_window(Rect2(x, y, 92, 72), (x + int(y)) % 3 == 0)
		# Ahşap çıkmalar ve bitkili balkon korkuluğu.
		for side_value in [-1.0, 1.0]:
			var side: float = float(side_value)
			var x: float = side * 600.0
			draw_rect(Rect2(x - 140, -355, 280, 185), Color("554236"))
			draw_rect(Rect2(x - 160, -178, 320, 18), WOOD)
			for bx in range(int(x - 145), int(x + 146), 32):
				draw_line(Vector2(bx, -178), Vector2(bx, -125), Color("302a2b"), 5)
		# Kemerli ana kapı ve sıcak avlu girişi.
		draw_rect(Rect2(-225, -232, 450, 232), INK)
		draw_colored_polygon(PackedVector2Array([Vector2(-225, -232), Vector2(0, -390), Vector2(225, -232)]), INK)
		draw_rect(Rect2(-170, -205, 340, 205), Color("7f4f36"))
		draw_rect(Rect2(-330, -475, 660, 70), Color("372b31"))
		draw_string(ThemeDB.fallback_font, Vector2(-300, -430), "KUZEY HANI", HORIZONTAL_ALIGNMENT_CENTER, 600, 34, AMBER)
		_lamp(-270, -250); _lamp(270, -250)

	func _pixel_window(rect: Rect2, curtain: bool) -> void:
		draw_rect(rect, INK)
		draw_rect(rect.grow(-7), Color(AMBER, 0.72))
		draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.5 - 3, 7), Vector2(6, rect.size.y - 14)), Color("5a3d3e"))
		if curtain:
			draw_rect(Rect2(rect.position + Vector2(7, 7), Vector2(12, rect.size.y - 14)), TILE)

	func _tile_roof(x: float, y: float, width: float) -> void:
		draw_colored_polygon(PackedVector2Array([Vector2(x, y), Vector2(x + width * 0.5, y - 72), Vector2(x + width, y)]), Color("713b3a"))
		for tx in range(int(x + 18), int(x + width - 18), 34):
			draw_rect(Rect2(tx, y - 18, 24, 14), TILE)

	func _lamp(x: float, y: float) -> void:
		draw_rect(Rect2(x - 5, y, 10, 300), Color("272733"))
		draw_rect(Rect2(x - 26, y - 12, 52, 18), Color("272733"))
		draw_rect(Rect2(x - 18, y + 6, 36, 30), Color(AMBER, 0.75))

	func _van(x: float, body: Color, stripe: Color) -> void:
		draw_rect(Rect2(x - 155, -137, 310, 115), body)
		draw_colored_polygon(PackedVector2Array([Vector2(x + 42, -202), Vector2(x + 135, -137), Vector2(x - 35, -137)]), body)
		draw_rect(Rect2(x - 126, -119, 242, 24), stripe)
		for wx in [-92.0, -34.0, 36.0, 92.0]:
			draw_rect(Rect2(x + wx - 22, -182, 44, 42), Color("34445a"))
		draw_rect(Rect2(x - 105, -34, 58, 34), INK); draw_rect(Rect2(x + 65, -34, 58, 34), INK)

	func _stall(x: float, color: Color) -> void:
		draw_rect(Rect2(x - 140, -152, 280, 152), Color("302b35"))
		draw_colored_polygon(PackedVector2Array([Vector2(x - 165, -152), Vector2(x + 165, -152), Vector2(x + 120, -225), Vector2(x - 120, -225)]), color)
		for sx in range(-120, 121, 60):
			draw_colored_polygon(PackedVector2Array([Vector2(x + sx, -218), Vector2(x + sx + 30, -218), Vector2(x + sx + 60, -152), Vector2(x + sx + 30, -152)]), color.lightened(0.22))
