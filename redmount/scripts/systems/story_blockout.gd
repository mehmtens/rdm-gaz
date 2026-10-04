## StoryBlockout — 12 bölümlük kampanyanın yeni bağlayıcı parkurları.
##
## Bu sahneler rastgele üretilmez. Her `chapter` için aşağıdaki düzen elle
## bestelenmiştir: güvenli okuma -> parkur fikri -> çatışmalı uygulama -> arena
## -> nefes/gizli rota -> çıkış. Geometri blockout seviyesindedir; sanat geçişi
## Level'in biome kaplaması tarafından yapılır.
class_name StoryBlockout
extends Level

@export_range(1, 7) var chapter: int = 1

const STREET := preload("res://scenes/enemies/StreetThug.tscn")
const KNIFE := preload("res://scenes/enemies/KnifeAgent.tscn")
const RIFLE := preload("res://scenes/enemies/RifleGuard.tscn")
const BRUISER := preload("res://scenes/enemies/ArmoredBruiser.tscn")
const ASSASSIN := preload("res://scenes/enemies/AgileAssassin.tscn")
const ELITE := preload("res://scenes/enemies/EliteGuard.tscn")

const COIN := preload("res://scenes/pickups/Coin.tscn")
const HEALTH := preload("res://scenes/pickups/HealthPickup.tscn")
const BAT := preload("res://scenes/pickups/BatPickup.tscn")
const KNIFE_PICKUP := preload("res://scenes/pickups/KnifePickup.tscn")
const PISTOL := preload("res://scenes/pickups/PistolPickup.tscn")
const RIFLE_PICKUP := preload("res://scenes/pickups/RiflePickup.tscn")
const AMMO := preload("res://scenes/pickups/AmmoPickup.tscn")
const ARMOR := preload("res://scenes/pickups/ArmorPickup.tscn")

const CHECKPOINT := preload("res://scenes/systems/Checkpoint.tscn")
const GOAL := preload("res://scenes/systems/LevelGoal.tscn")
const DIALOGUE := preload("res://scenes/systems/DialogueTrigger.tscn")
const ONEWAY := preload("res://scenes/systems/OneWayPlatform.tscn")
const MOVING := preload("res://scenes/systems/MovingPlatform.tscn")
const SPIKES := preload("res://scenes/systems/Spikes.tscn")
const ARENA := preload("res://scenes/systems/BattleArena.tscn")
const PROP := preload("res://scripts/systems/breakable_prop.gd")
const SHOP := preload("res://scripts/systems/level_shop.gd")

var _serial := 0


func _ready() -> void:
	_build_chapter()
	super._ready()


func _build_chapter() -> void:
	_spawn_marker()
	match chapter:
		1: _chapter_backstreets()
		2: _chapter_night_market()
		3: _chapter_railway()
		4: _chapter_foundry()
		5: _chapter_underground()
		6: _chapter_north_walls()
		_: _chapter_silent_corridor()


func _spawn_marker() -> void:
	var marker := Marker2D.new()
	marker.name = "PlayerSpawn"
	marker.position = Vector2(80, -40)
	add_child(marker)


# Perde I / Bölüm 2 — düşman şehri kapatmadan Gazelle'in aracının izini sür.
func _chapter_backstreets() -> void:
	_intro("REDMOUNT", "Lastik izi kuzeye dönüyor. Ana cadde yem; arka sokaklardan gideceğim.")
	_ground(380, 920)
	_prop("saksi", 130)
	_pickup(BAT, 220, -45)
	_enemy(STREET, 500, 0)
	_enemy(STREET, 720, 0)
	_prop("kasa", 840)
	_roof_chain(1050, [0, -55, -15, -90, -35])
	_coins_arc(960, 5, 245, -130)
	_prop("sandik", 1670, -105, ARMOR)
	_checkpoint(1780, -125)
	_ground(2240, 760)
	_enemy(KNIFE, 2150, 0)
	_enemy(STREET, 2420, 0)
	_shop(2510, "ARA SOKAK BÜFESİ", PackedStringArray(["can", "sopa", "bicak"]))
	_spike_gap(2790, 300, 130)
	_moving(2710, -35, Vector2(220, 0), 170)
	_ground(3300, 720)
	_prop("varil", 3090)
	_prop("tup", 3470)
	_arena(3300, 0, 2980, 3620, _wave(STREET, KNIFE), _wave(STREET, STREET, KNIFE))
	_checkpoint(3600, 0)
	_platform(3860, -65, 300, 32)
	_platform(4180, -135, 260, 32)
	_platform(4510, -70, 300, 32)
	_cloud(3900, -265, 155)
	_cloud(4180, -335, 165)
	_cloud(4460, -275, 155)
	_coins_arc(3870, 4, 195, -385)
	_ground(5080, 860)
	_enemy(KNIFE, 4930, 0)
	_prop("vazo", 5050)
	_shop(5250, "DOLMUŞ DURAĞI", PackedStringArray(["can", "cephane", "zirh"]))
	_pickup(HEALTH, 5200, -45)
	_checkpoint(5400, 0)
	_dialogue(5520, "REDMOUNT", "Konvoy yeni ayrılmış. Lastik izi yokuştaki ara sokağa dönüyor.")
	_chapter_backstreets_extension()


func _chapter_backstreets_extension() -> void:
	# 05.500–10.200 — Yokuşlu mahalle: alçak ana yol, çatılarda ödüllü rota.
	_ground(6200, 1400)
	_prop("saksi", 5760); _prop("vazo", 5840)
	_enemy(STREET, 6070, 0); _enemy(KNIFE, 6480, 0)
	_ground(7040, 260, 35)
	_ground(7370, 250, 70)
	_ground(7700, 250, 105)
	_ground(8030, 250, 70)
	_ground(8360, 260, 35)
	_coin_line(7040, 5, 330, -120)
	_prop("sandik", 7700, 105, PISTOL)
	_ground(9150, 1500)
	_enemy(STREET, 8820, 0); _enemy(STREET, 9180, 0); _enemy(KNIFE, 9510, 0)
	_shop(9550, "YOKUŞ BAKKALI", PackedStringArray(["can", "sopa", "cephane"]))
	_checkpoint(9820, 0)

	# 10.200–15.600 — Kapalı çarşı arkası: tenteler ana rota, bulutlar gizli üst rota.
	_ground(10450, 1100)
	_prop("kasa", 10120); _prop("kasa", 10680)
	_platform(11200, -35, 280, 50)
	_platform(11540, -105, 270, 50)
	_platform(11880, -35, 280, 50)
	_platform(12220, -105, 270, 50)
	_platform(12560, -35, 280, 50)
	for i in 5:
		_ground(11205 + i * 340, 340, 70 + (2 - absi(i - 2)) * 35)
	_cloud(11300, -270, 150); _cloud(11530, -340, 160); _cloud(11770, -270, 150)
	_coin_line(11280, 4, 165, -405)
	_pickup(KNIFE_PICKUP, 11770, -318)
	_ground(14000, 2500)
	_enemy(KNIFE, 13180, 0); _enemy(STREET, 13520, 0)
	_arena(14200, 0, 13400, 15050, _wave(STREET, KNIFE), _wave(STREET, STREET, KNIFE), HEALTH)
	_prop("varil", 14900)
	_checkpoint(15220, 0)

	# 15.600–20.900 — Dolmuş garajı: araç çatıları ve iki seviyeli çatışma.
	_ground(16000, 1400)
	_platform(16900, -15, 360, 90)
	_platform(17300, -75, 340, 90)
	_platform(17700, -15, 360, 90)
	_platform(18100, -85, 340, 90)
	_platform(18500, -15, 360, 90)
	_coins_arc(16920, 6, 325, -170)
	_enemy(STREET, 17390, -140); _enemy(KNIFE, 18160, -150)
	_ground(19850, 2100)
	_prop("tup", 19100); _prop("varil", 19420); _prop("sandik", 20100, 0, ARMOR)
	_shop(20450, "GARAJ KANTİNİ", PackedStringArray(["can", "bicak", "zirh"]))
	_checkpoint(20750, 0)

	# 20.900–26.200 — Dere altgeçidi: sabit bakım iskeleleri; hareketli platform zorunlu değil.
	_ground(21550, 1200)
	_enemy(STREET, 21400, 0); _enemy(KNIFE, 21900, 0)
	_spike_gap(22800, 1250, 150)
	_platform(22310, -35, 260, 34)
	_platform(22620, -95, 250, 34)
	_platform(22920, -155, 250, 34)
	_platform(23220, -95, 250, 34)
	_platform(23530, -35, 260, 34)
	_coins_arc(22280, 5, 310, -225)
	_ground(24750, 2600)
	_enemy(KNIFE, 24250, 0); _enemy(STREET, 24700, 0); _enemy(KNIFE, 25200, 0)
	_prop("vazo", 25500); _prop("kasa", 25700)
	_checkpoint(25900, 0)

	# 26.200–32.100 — Apartman avluları: ana yol güvenli, yangın merdiveni değerli kestirme.
	_ground(26800, 1500)
	_oneway(27450, -90, 170); _oneway(27680, -175, 170); _oneway(27910, -260, 170)
	_oneway(28140, -175, 170); _oneway(28370, -90, 170)
	_ground(27825, 550)
	_coin_line(27450, 5, 230, -315)
	_pickup(RIFLE_PICKUP, 27910, -310)
	_ground(29400, 2600)
	_enemy(STREET, 28700, 0); _enemy(KNIFE, 29100, 0)
	_pickup(HEALTH, 28950, -45)
	_checkpoint(29150, 0)
	_arena(30000, 0, 29200, 30800, _wave(KNIFE, STREET), _wave(KNIFE, KNIFE, STREET), AMMO)
	_shop(31200, "AVLU BÜFESİ", PackedStringArray(["can", "cephane", "tabanca"]))
	_ground(31250, 1100)
	_checkpoint(31600, 0)

	# 32.100–38.000 — Gece pazarı: tente ritmi, kırılabilir tezgâhlar ve gizli çatı.
	_ground(32600, 2100)
	_prop("saksi", 32150); _prop("vazo", 32310); _prop("kasa", 32900)
	_platform(33800, -40, 300, 46)
	_platform(34170, -115, 280, 46)
	_platform(34520, -40, 300, 46)
	_platform(34890, -115, 280, 46)
	_platform(35240, -40, 300, 46)
	for i in 5:
		_ground(33825 + i * 350, 350, 70 + (2 - absi(i - 2)) * 35)
	_cloud(34050, -290, 160); _cloud(34300, -365, 170); _cloud(34560, -290, 160)
	_prop("sandik", 34300, -365, ARMOR)
	_coin_line(33980, 5, 155, -425)
	_ground(36600, 2400)
	_enemy(STREET, 35900, 0); _enemy(KNIFE, 36300, 0); _enemy(STREET, 36900, 0)
	_prop("varil", 37400); _prop("tup", 37600)
	_checkpoint(37700, 0)

	# 38.000–43.700 — Konvoy deposu: geniş dövüş cebi ve iki rota.
	_ground(38800, 1700)
	_platform(39850, -15, 380, 110)
	_platform(40250, -75, 340, 110)
	_platform(40650, -15, 360, 110)
	_cloud(40100, -300, 160); _cloud(40350, -375, 170); _cloud(40610, -300, 160)
	_pickup(HEALTH, 40350, -425)
	_ground(42100, 2400)
	_enemy(KNIFE, 41400, 0); _enemy(STREET, 41800, 0)
	_arena(42500, 0, 41700, 43300, _wave(STREET, KNIFE, STREET), _wave(KNIFE, KNIFE, STREET), KNIFE_PICKUP)
	_shop(43500, "KONVOY TEZGÂHI", PackedStringArray(["can", "cephane", "zirh"]))
	_ground(43575, 550)
	_checkpoint(43700, 0)

	# 43.700–48.700 — Tamirhane finali: önce keşif, sonra son pusu ve hikâye çıkışı.
	_ground(44700, 1700)
	_prop("kasa", 44150); _prop("varil", 44400); _prop("sandik", 45100, 0, HEALTH)
	_ground(45750, 400, 35)
	_ground(46150, 340, 70)
	_ground(46550, 360, 35)
	_ground(47800, 2200)
	_enemy(STREET, 47050, 0); _enemy(KNIFE, 47400, 0)
	_arena(48000, 0, 47200, 48600, _wave(STREET, STREET, KNIFE), _wave(KNIFE, KNIFE, STREET), HEALTH)
	_dialogue(48620, "REDMOUNT", "Konvoy raylara çıkmış. Şimdi önlerini kesebilirim.")
	_goal(48800, 0)


# Perde I / Bölüm 3 — pazar meydanında ilk örgütlü pusu.
func _chapter_night_market() -> void:
	_intro("GAZELLE", "Redmount... beni duyuyorsan limana gitme. Bizi dağa götürüyorlar.")
	_ground(430, 1020)
	_prop("saksi", 160); _prop("vazo", 260)
	_enemy(STREET, 420, 0)
	_enemy(KNIFE, 700, 0)
	_oneway(1080, -95, 210)
	_oneway(1340, -175, 190)
	_ground(1165, 450)
	_ground(1640, 500)
	_checkpoint(1640, 0)
	_spike_gap(2020, 360, 130)
	_moving(1900, -20, Vector2(250, -65), 155)
	_moving(2120, -95, Vector2(210, 70), 155, 0.5)
	_ground(2550, 680)
	_enemy(KNIFE, 2450, 0)
	_enemy(KNIFE, 2670, 0)
	_coins_arc(2320, 6, 105, -95)
	_prop("kasa", 2760)
	_ground(3480, 920)
	_arena(3480, 0, 3090, 3880, _wave(STREET, STREET, KNIFE), _wave(KNIFE, KNIFE, STREET), HEALTH)
	_checkpoint(3920, 0)
	_roof_chain(4200, [-20, -90, -155, -85])
	_enemy(KNIFE, 4830, -195)
	_ground(5350, 780)
	_pickup(HEALTH, 5200, -45)
	_checkpoint(5480, 0)
	_dialogue(5600, "REDMOUNT", "Pazarın çıkışlarını tutmuşlar. Tezgâhların arasından dolanacağım.")
	_chapter_night_market_extension()


func _chapter_night_market_extension() -> void:
	# 05.700–10.500 — Baharatçılar sokağı: ana yol ve tente üstü ödül rotası.
	_ground(6400, 1400)
	_prop("vazo", 5900); _prop("vazo", 6000); _prop("kasa", 6700)
	_enemy(STREET, 6250, 0); _enemy(KNIFE, 6720, 0)
	_platform(7280, -15, 340, 70)
	_platform(7680, -75, 340, 70)
	_platform(8080, -15, 340, 70)
	_platform(8480, -85, 340, 70)
	_platform(8880, -15, 340, 70)
	for i in 5:
		_ground(7300 + i * 380, 380, 100 + (2 - absi(i - 2)) * 35)
	_coins_arc(7200, 6, 335, -180)
	_cloud(7550, -300, 160); _cloud(7800, -370, 170); _cloud(8050, -300, 160)
	_prop("sandik", 7800, -370, ARMOR)
	_ground(9700, 1600)
	_enemy(STREET, 9300, 0); _enemy(KNIFE, 9750, 0)
	_shop(10100, "BAHARATÇI BÜFESİ", PackedStringArray(["can", "sopa", "bicak"]))
	_checkpoint(10300, 0)

	# 10.500–16.000 — Han avlusu: balkonlara çıkan isteğe bağlı dikey halka.
	_ground(11200, 1400)
	_prop("saksi", 10700); _prop("saksi", 10800); _prop("vazo", 11600)
	_oneway(11980, -90, 170); _oneway(12210, -175, 170); _oneway(12440, -260, 170)
	_oneway(12670, -175, 170); _oneway(12900, -90, 170)
	_ground(12750, 1700)
	_coin_line(11980, 5, 230, -315)
	_pickup(PISTOL, 12440, -315)
	_ground(14800, 2400)
	_enemy(KNIFE, 13800, 0); _enemy(STREET, 14200, 0)
	_pickup(HEALTH, 14350, -45)
	_checkpoint(14500, 0)
	_arena(15100, 0, 14400, 15800, _wave(STREET, KNIFE), _wave(KNIFE, STREET, KNIFE), AMMO)

	# 16.000–20.600 — Balık hali ve soğuk depo: kasalar siper ve ödül kaynağıdır.
	_ground(16900, 1800)
	_prop("kasa", 16250); _prop("kasa", 16400); _prop("varil", 17300)
	_enemy(STREET, 16800, 0); _enemy(KNIFE, 17400, 0)
	_ground(19200, 2800)
	_platform(18150, -80, 300, 40); _platform(18520, -145, 300, 40)
	_platform(18890, -80, 300, 40)
	_coin_line(18150, 3, 370, -205)
	_enemy(KNIFE, 18520, -165)
	_prop("tup", 19500); _prop("sandik", 19900, 0, KNIFE_PICKUP)
	_shop(20200, "HAL KANTİNİ", PackedStringArray(["can", "cephane", "zirh"]))
	_checkpoint(20450, 0)

	# 20.600–26.600 — Tramvay servis geçidi: sabit platform ritmi, üstte cephane.
	_ground(21400, 1600)
	_enemy(STREET, 21100, 0); _enemy(KNIFE, 21600, 0)
	_platform(22400, -15, 360, 90)
	_platform(22800, -75, 340, 90)
	_platform(23200, -15, 360, 90)
	_platform(23600, -85, 340, 90)
	_platform(24000, -15, 360, 90)
	_platform(24280, -15, 240, 90)
	_cloud(22800, -300, 160); _cloud(23050, -375, 170); _cloud(23300, -300, 160)
	_pickup(AMMO, 23050, -425)
	_coins_arc(22350, 6, 335, -180)
	_ground(25500, 2200)
	_enemy(KNIFE, 24800, 0); _enemy(STREET, 25400, 0); _enemy(KNIFE, 26000, 0)
	_prop("varil", 26300)
	_checkpoint(26450, 0)

	# 26.600–32.900 — Kapalı çarşı çatısı: tenteler arasında kesintisiz yüksel-alçal.
	_ground(27600, 2000)
	_prop("vazo", 26900); _prop("kasa", 27800)
	_platform(28800, -15, 360, 70)
	_platform(29200, -75, 340, 70)
	_platform(29600, -135, 340, 70)
	_platform(30000, -75, 340, 70)
	_platform(30400, -15, 360, 70)
	for i in 5:
		_ground(28828 + i * 416, 416, 100 + (2 - absi(i - 2)) * 35)
	_coins_arc(28750, 6, 335, -210)
	_enemy(KNIFE, 29600, -170)
	_ground(31800, 2200)
	_enemy(STREET, 31200, 0); _enemy(KNIFE, 31700, 0)
	_shop(32300, "ÇARŞI ECZANESİ", PackedStringArray(["can", "cephane", "tabanca"]))
	_checkpoint(32700, 0)

	# 32.900–38.000 — Meydan baskını: geniş savaş alanı ve simit arabası sırrı.
	_ground(34000, 2200)
	_prop("saksi", 33100); _prop("vazo", 33300); _prop("kasa", 33700)
	_pickup(HEALTH, 33750, -45)
	_checkpoint(33850, 0)
	_arena(34500, 0, 33700, 35300, _wave(STREET, STREET, KNIFE), _wave(KNIFE, KNIFE, STREET), ARMOR)
	_ground(35360, 520)
	_platform(35800, -15, 360, 70)
	_platform(36200, -75, 340, 70)
	_platform(36600, -15, 360, 70)
	_platform(37000, -75, 340, 70)
	_platform(37400, -15, 360, 70)
	_platform(37740, -15, 320, 70)
	for i in 6:
		_ground(35810 + i * 380, 380, 90 + mini(mini(i, 5 - i), 2) * 35)
	_coin_line(35800, 5, 400, -150)

	# 38.000–42.500 — Kuzey Hanı çevresi: avlu üstü gizli bulut hattı.
	_ground(39000, 2200)
	_enemy(STREET, 38300, 0); _enemy(KNIFE, 38900, 0); _enemy(STREET, 39500, 0)
	_cloud(38600, -245, 160); _cloud(38850, -320, 170); _cloud(39100, -245, 160)
	_coin_line(38550, 4, 190, -380)
	_prop("sandik", 38850, -320, RIFLE_PICKUP)
	_ground(41300, 2400)
	_enemy(KNIFE, 40500, 0); _enemy(KNIFE, 41100, 0)
	_pickup(HEALTH, 41600, -45)
	_checkpoint(41800, 0)
	_arena(42100, 0, 41400, 42800, _wave(KNIFE, STREET, KNIFE), _wave(STREET, KNIFE, STREET), HEALTH)

	# 42.500–48.800 — Yükleme alanı: son pusu, dükkân ve hikâye çıkışı.
	_ground(43600, 2200)
	_prop("varil", 42900); _prop("tup", 43100); _prop("kasa", 44000)
	_shop(44300, "GECE NÖBETÇİSİ", PackedStringArray(["can", "cephane", "zirh"]))
	_platform(45000, -15, 380, 90)
	_platform(45420, -75, 360, 90)
	_platform(45840, -15, 380, 90)
	_platform(46260, -85, 360, 90)
	_platform(46680, -15, 380, 90)
	_ground(48000, 2400)
	_enemy(STREET, 47200, 0); _enemy(KNIFE, 47600, 0)
	_checkpoint(47500, 0)
	_arena(48200, 0, 47500, 48900, _wave(STREET, KNIFE, STREET), _wave(KNIFE, KNIFE, STREET), HEALTH)
	_dialogue(48920, "REDMOUNT", "Karahanlı şehri boşaltmıyor; şahitleri topluyor. Bu yalnızca bir kaçırma değil.")
	_goal(49000, 0)


# Perde II / Bölüm 5 — yük treninin üstünden sanayi kuşağına sız.
func _chapter_railway() -> void:
	_intro("REDMOUNT", "Vagon mühürleri Karahanlı'nın. Gazelle bu hattan geçirilmiş.")
	_ground(390, 940)
	_pickup(PISTOL, 210, -45)
	_enemy(RIFLE, 620, 0)
	_ground(1630, 1600, 155)
	_platform(1110, -25, 300, 90)
	_platform(1510, -65, 300, 90)
	_platform(1910, -25, 300, 90)
	_enemy(RIFLE, 1510, -110)
	_moving(2150, -110, Vector2(230, 0), 180)
	_ground(2400, 180, 70)
	_ground(2740, 720)
	_checkpoint(2600, 0)
	_enemy(KNIFE, 2800, 0)
	_enemy(RIFLE, 3010, 0)
	_oneway(3270, -110, 190)
	_oneway(3510, -205, 180)
	_ground(3300, 400, 70)
	_ground(3890, 780)
	_checkpoint(3650, 0)
	_arena(3890, 0, 3540, 4240, _wave(RIFLE, KNIFE), _wave(RIFLE, STREET, KNIFE), AMMO)
	_checkpoint(4270, 0)
	_moving(4460, -20, Vector2(260, -80), 160)
	_moving(4760, -100, Vector2(230, 80), 160, 0.5)
	_ground(4595, 630, 70)
	_ground(5260, 700)
	_enemy(RIFLE, 5250, 0)
	_dialogue(5440, "REDMOUNT", "Yük treninin izi devam ediyor. Depolardan geçmeliyim.")
	_chapter_railway_extension()


func _chapter_railway_extension() -> void:
	# Yük sahası: vagon üstü kestirme, altta kesintisiz servis yolu.
	_ground(6300, 1400)
	_enemy(KNIFE, 6140, 0); _enemy(RIFLE, 6670, 0)
	_prop("kasa", 6520); _prop("varil", 6810)
	_ground(7600, 1300, 155)
	_platform(7220, -25, 300, 90)
	_platform(7620, -65, 300, 90)
	_platform(8020, -25, 300, 90)
	_ground(8300, 200, 70)
	_pickup(AMMO, 7620, -160)
	_ground(9100, 1800)
	_enemy(RIFLE, 8640, 0); _enemy(KNIFE, 8990, 0)
	_prop("sandik", 8240, 100, ARMOR)
	_checkpoint(9320, 0)
	_arena(9560, 0, 9190, 9940, _wave(RIFLE, KNIFE), _wave(STREET, RIFLE, KNIFE), HEALTH)
	_shop(9780, "YÜK SAHASI KANTİNİ", PackedStringArray(["can", "cephane", "zirh"]))

	# Taş viyadük: aşağı inip çıkılan servis yolunun üstünde vinç iskelesi.
	_ground(10750, 1600)
	_enemy(STREET, 10450, 0); _enemy(RIFLE, 11180, 0)
	_ground(12550, 2000, 150)
	for i in 5:
		_ground(11750 + i * 400, 400, [35, 70, 105, 70, 35][i])
	_oneway(12050, -110, 170); _oneway(12350, -190, 170)
	_pickup(RIFLE_PICKUP, 12350, -245)
	_ground(14400, 1700)
	_enemy(KNIFE, 13950, 0); _enemy(RIFLE, 14600, 0)
	_checkpoint(14100, 0)
	_arena(14600, 0, 13900, 15100, _wave(STREET, KNIFE), _wave(RIFLE, KNIFE, STREET), AMMO)
	_shop(15020, "VİYADÜK BEKÇİLİĞİ", PackedStringArray(["can", "cephane", "tabanca"]))

	# Kömür deposu: üstte bakım iskeleleri, altta güvenli ray yatağı.
	_ground(15950, 1400)
	_prop("varil", 15730); _prop("kasa", 16400)
	_enemy(RIFLE, 16080, 0)
	_ground(17500, 1700, 100)
	_platform(17040, -70, 320, 46)
	_platform(17450, -135, 300, 46)
	_platform(17860, -70, 320, 46)
	_pickup(ARMOR, 17450, -170)
	_ground(19250, 1800)
	_enemy(KNIFE, 18780, 0); _enemy(RIFLE, 19420, 0)
	_prop("sandik", 18800, 0, HEALTH)
	_checkpoint(19000, 0)
	_arena(19500, 0, 18900, 20050, _wave(RIFLE, STREET, KNIFE), _wave(RIFLE, KNIFE, STREET), HEALTH)
	_ground(21050, 1800)
	_shop(20600, "KÖMÜR DEPOSU BÜFESİ", PackedStringArray(["can", "cephane", "zirh"]))
	_dialogue(21400, "REDMOUNT", "Sevkiyat sanayi kuşağına girmiş. Gazelle'e yaklaşıyorum.")
	_goal(21650, 0)


# Perde III / Bölüm 7 — dökümhanenin dikey servis hattı.
func _chapter_foundry() -> void:
	_intro("KARAHANLI", "Israr, sadakatin ucuz taklididir Redmount. Geri dön.")
	_ground(420, 980)
	_pickup(ARMOR, 230, -45)
	_enemy(BRUISER, 650, 0)
	_oneway(1100, -90, 180)
	_oneway(1320, -185, 170)
	_oneway(1540, -280, 170)
	_enemy(ASSASSIN, 1540, -320)
	_ground(1940, 620)
	_checkpoint(1830, 0)
	_spike_gap(2320, 420, 130)
	_moving(2180, -30, Vector2(260, -130), 160)
	_moving(2470, -160, Vector2(220, 130), 160, 0.5)
	_ground(2860, 520)
	_enemy(BRUISER, 2940, 0)
	_roof_chain(3220, [-30, -110, -190, -110, -35])
	_enemy(ASSASSIN, 3850, -230)
	_ground(4300, 820)
	_arena(4300, 0, 3940, 4660, _wave(BRUISER, KNIFE), _wave(ASSASSIN, BRUISER), HEALTH)
	_checkpoint(4680, 0)
	_ground(5140, 700)
	_enemy(RIFLE, 5080, 0)
	_enemy(ASSASSIN, 5330, 0)
	_dialogue(5440, "REDMOUNT", "Sesini ilk kez duydum Karahanlı. Demek yaklaştım.")
	_goal(5580, 0)


# Perde III / Bölüm 8 — sevkiyat tünelinde hız ve yön değiştirme sınavı.
func _chapter_underground() -> void:
	_intro("REDMOUNT", "Tünel kapıları kapanıyor. Durursam burada gömerler.")
	_ground(400, 940)
	_enemy(ASSASSIN, 620, 0)
	_spike_gap(1120, 360, 130)
	_moving(1000, -30, Vector2(245, 0), 150)
	_ground(1540, 540)
	_oneway(1850, -90, 160)
	_oneway(2050, -180, 150)
	_oneway(2250, -270, 150)
	_checkpoint(2250, -310)
	_platform(2550, -230, 260, 40)
	_platform(2910, -145, 260, 40)
	_platform(3270, -60, 260, 40)
	_enemy(RIFLE, 2910, -185)
	_ground(3720, 700)
	_enemy(BRUISER, 3650, 0)
	_enemy(ASSASSIN, 3910, 0)
	_arena(4250, 0, 3920, 4580, _wave(ASSASSIN, RIFLE), _wave(BRUISER, ASSASSIN, RIFLE), AMMO)
	_checkpoint(4620, 0)
	_spike_gap(4920, 380, 130)
	_moving(4810, -30, Vector2(230, -95), 150)
	_ground(5400, 760)
	_dialogue(5480, "GAZELLE", "Dağın içindeyiz. Her geçişte kapıların sesini sayıyorum: üç tane kaldı.")
	_goal(5660, 0)


# Perde IV / Bölüm 10 — kaleye dışarıdan son yaklaşım.
func _chapter_north_walls() -> void:
	_intro("REDMOUNT", "Kuzey suru kör nokta sanılıyor. Karahanlı bile kendi kibrini koruyamaz.")
	_ground(420, 980)
	_pickup(ARMOR, 220, -45)
	_enemy(ELITE, 690, 0)
	_platform(1120, -80, 240, 120)
	_platform(1460, -170, 230, 120)
	_platform(1800, -260, 230, 120)
	_enemy(RIFLE, 1800, -320)
	_spike_gap(2140, 340, 130)
	_moving(2050, -165, Vector2(210, 100), 165)
	_ground(2550, 640)
	_checkpoint(2440, 0)
	_enemy(ASSASSIN, 2640, 0)
	_oneway(2940, -100, 170)
	_oneway(3160, -195, 170)
	_oneway(3380, -290, 170)
	_ground(3820, 700)
	_arena(3820, 0, 3500, 4140, _wave(ELITE, ASSASSIN), _wave(ELITE, RIFLE, BRUISER), HEALTH)
	_checkpoint(4170, 0)
	_spike_gap(4500, 420, 130)
	_moving(4380, -20, Vector2(250, -110), 150)
	_moving(4680, -130, Vector2(220, 110), 150, 0.5)
	_ground(5180, 700)
	_enemy(ELITE, 5200, 0)
	_dialogue(5400, "KARAHANLI", "Kapım sana açık. Bunun davet olduğunu sanma.")
	_goal(5560, 0)


# Perde IV / Bölüm 11 — finalden önce sessizlik, seçkin muhafızlar ve Gazelle'in izi.
func _chapter_silent_corridor() -> void:
	_intro("REDMOUNT", "Bu kattaki sessizlik boşluk değil. Her kapının ardında biri bekliyor.")
	_ground(460, 1060)
	_pickup(PISTOL, 220, -45)
	_pickup(AMMO, 300, -45)
	_enemy(ELITE, 680, 0)
	_oneway(1120, -100, 190)
	_oneway(1360, -200, 180)
	_enemy(ASSASSIN, 1360, -240)
	_ground(1730, 520)
	_checkpoint(1670, 0)
	_spike_gap(2100, 360, 130)
	_moving(1980, -40, Vector2(230, -80), 165)
	_ground(2540, 620)
	_enemy(ELITE, 2470, 0)
	_enemy(RIFLE, 2700, 0)
	_roof_chain(2980, [-30, -115, -200, -115])
	_ground(3860, 760)
	_arena(3860, 0, 3510, 4210, _wave(ELITE, ASSASSIN), _wave(ELITE, ELITE, RIFLE), ARMOR)
	_checkpoint(4240, 0)
	_platform(4510, -80, 230, 80)
	_platform(4830, -160, 220, 80)
	_platform(5150, -80, 230, 80)
	_enemy(ELITE, 5150, -160)
	_ground(5580, 680)
	_dialogue(5660, "GAZELLE", "Redmount! Sesin duvarın öbür tarafından geliyor.")
	_goal(5780, 0)


# --- İnşa yardımcıları ------------------------------------------------------

func _ground(x: float, width: float, surface_y := 0.0) -> void:
	if chapter <= 3:
		_platform(x, surface_y + 200.0, width, 400.0)
	else:
		_platform(x, surface_y + 110.0, width, 220.0)


func _platform(x: float, y: float, width: float, height: float) -> void:
	_serial += 1
	var body := StaticBody2D.new()
	body.name = "Ground%d" % _serial
	body.position = Vector2(x, y)
	var col := CollisionShape2D.new()
	col.name = "Col"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	col.shape = shape
	if chapter == 2 and ((x > 7000 and x < 9000) or (x > 28500 and x < 30600)):
		col.one_way_collision = true
	body.add_child(col)
	if chapter <= 3:
		body.add_child(_BlockSurface.new(width, height, chapter == 3 and (x < 2100 or (x > 7000 and x < 8200)) and height == 90))
	else:
		var vis := Polygon2D.new()
		vis.name = "Vis"
		var hw := width * 0.5
		var hh := height * 0.5
		vis.polygon = PackedVector2Array([
			Vector2(-hw, -hh), Vector2(hw, -hh), Vector2(hw, hh), Vector2(-hw, hh),
		])
		vis.color = Color(0.27, 0.29, 0.34)
		body.add_child(vis)
	add_child(body)


class _BlockSurface extends Node2D:
	const PAVING := preload("res://assets/environment/mahalle/ground_long.png")
	const STONE := preload("res://assets/environment/mahalle/stone_fill.png")
	const ROOF := preload("res://assets/environment/mahalle/roof_a.png")
	const AWNING := preload("res://assets/environment/mahalle/market_awning_v2.png")
	const SCAFFOLD := preload("res://assets/environment/mahalle/scaffold_deck_v2.png")
	const WAGON := preload("res://assets/environment/mahalle/freight_wagon.png")
	var width: float
	var height: float
	var wagon: bool

	func _init(w: float, h: float, is_wagon := false) -> void:
		width = w
		height = h
		wagon = is_wagon

	func _draw() -> void:
		var left := -width * 0.5
		var top := -height * 0.5
		var route_x: float = get_parent().position.x
		if wagon:
			draw_texture_rect_region(WAGON, Rect2(left, top - 4, width, 110), Rect2(4, 60, 1975, 680))
			return
		var awning := (route_x > 11000 and route_x < 12800) or (route_x > 33500 and route_x < 35500) or (route_x > 7000 and route_x < 9000) or (route_x > 28500 and route_x < 30600)
		var scaffold := (route_x > 22000 and route_x < 24500) or (route_x > 35600 and route_x < 37900) or (route_x > 44800 and route_x < 46900)
		if height >= 100:
			draw_texture_rect(STONE, Rect2(left, top + 32, width, height - 32), true, Color("797689"))
			draw_texture_rect(PAVING, Rect2(left, top, width, 90), true, Color("c7bbc4"))
		elif awning:
			draw_texture_rect_region(AWNING, Rect2(left, top, width, 66), Rect2(6, 147, 2161, 320))
		elif height < 60 or scaffold:
			var floor_depth := maxf(-get_parent().position.y, 75.0)
			for support_x in [left + 10.0, -left - 10.0]:
				draw_line(Vector2(support_x, top + 26), Vector2(support_x, floor_depth), Color("343b40"), 7)
			draw_line(Vector2(left + 10, top + 52), Vector2(-left - 10, floor_depth - 10), Color("55514a"), 4)
			draw_texture_rect_region(SCAFFOLD, Rect2(left, top, width, 65), Rect2(26, 148, 1931, 535))
		else:
			draw_texture_rect(ROOF, Rect2(left, top, width, height + 18), false)


func _roof_chain(start_x: float, heights: Array) -> void:
	for i in heights.size():
		_platform(start_x + i * 310.0, float(heights[i]) + 70.0, 230.0, 140.0)


func _oneway(x: float, y: float, width: float) -> void:
	var node := ONEWAY.instantiate()
	node.position = Vector2(x, y)
	node.set("width", width)
	if chapter <= 3:
		node.set("style", "scaffold")
	add_child(node)


func _cloud(x: float, y: float, width: float) -> void:
	var node := ONEWAY.instantiate()
	node.position = Vector2(x, y)
	node.set("width", width)
	node.set("style", "cloud")
	add_child(node)


func _moving(x: float, y: float, travel: Vector2, width: float, phase := 0.0) -> void:
	var node := MOVING.instantiate()
	node.position = Vector2(x, y)
	node.set("travel", travel)
	node.set("width", width)
	node.set("phase_offset", phase)
	add_child(node)


func _spike_gap(x: float, width: float, y: float) -> void:
	var node := SPIKES.instantiate()
	node.position = Vector2(x, y)
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


func _prop(kind: String, x: float, y: float = 0.0, reward: PackedScene = null) -> void:
	var node: BreakableProp = PROP.new()
	node.kind = kind
	node.reward = reward
	node.position = Vector2(x, y)
	add_child(node)


func _shop(x: float, title: String, items: PackedStringArray) -> void:
	var node: LevelShop = SHOP.new()
	node.position = Vector2(x, 0)
	node.title = title
	node.items = items
	node.accent = Color("e7a449")
	add_child(node)


func _checkpoint(x: float, y: float) -> void:
	var node := CHECKPOINT.instantiate()
	node.position = Vector2(x, y)
	add_child(node)


func _goal(x: float, y: float) -> void:
	var node := GOAL.instantiate()
	node.position = Vector2(x, y)
	add_child(node)


func _intro(speaker: String, text: String) -> void:
	_dialogue(170, speaker, text)


func _dialogue(x: float, speaker: String, text: String) -> void:
	var node := DIALOGUE.instantiate()
	node.position = Vector2(x, -70)
	node.set("speakers", PackedStringArray([speaker]))
	node.set("texts", PackedStringArray([text]))
	add_child(node)


func _coins_arc(start_x: float, count: int, spacing: float, top_y: float) -> void:
	for i in count:
		var t := float(i) / maxf(float(count - 1), 1.0)
		var y := top_y + absf(t - 0.5) * 95.0
		_pickup(COIN, start_x + i * spacing, y)


func _coin_line(start_x: float, count: int, spacing: float, y: float) -> void:
	for i in count:
		_pickup(COIN, start_x + i * spacing, y)


func _wave(a: PackedScene, b: PackedScene = null, c: PackedScene = null) -> Array[PackedScene]:
	var result: Array[PackedScene] = [a]
	if b != null: result.append(b)
	if c != null: result.append(c)
	return result


func _arena(x: float, floor_y: float, left: float, right: float,
		first: Array[PackedScene], second: Array[PackedScene], reward_scene: PackedScene = null) -> void:
	var node: BattleArena = ARENA.instantiate()
	node.position = Vector2(x, floor_y)
	node.gate_left_x = left
	node.gate_right_x = right
	node.floor_y = floor_y
	node.wave1 = first
	node.wave2 = second
	node.reward = reward_scene
	add_child(node)
