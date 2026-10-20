## Bölüm 13 — Haliç'te Şafak (Kitap 2 / "Haliç'in İzi", 1. bölüm).
##
## Karahanlı yenildi, Gazelle kurtuldu. İkili kaleden şafakta çıkar; sevkiyat
## defterindeki ilk adres Haliç kıyısı. Balat yokuşu, kayıkçı iskelesi, kapan
## depoları (tüfekli + avlu), rıhtım vinci, defterdeki eski han ve gümrük kaydı.
## Gazelle hikâye sahnelerinde Redmount'un yanında; yeni düşmanın adı açıklanmaz.
extends DtmLevel

const OPENING := preload("res://assets/backgrounds/book02_halij_opening_atlas.png")
const FINAL := preload("res://assets/backgrounds/book02_halij_final_atlas.png")
const REGISTRY := preload("res://assets/backgrounds/book02_halij_registry_atlas.png")


func _build() -> void:
	sky_atlas = OPENING
	sky_cells = [[0, -100000.0], [1, 1800.0], [2, 3600.0], [3, 5200.0, OPENING],
		[0, 6500.0, FINAL], [1, 7700.0, FINAL], [3, 9000.0, FINAL]]
	sky_tint = Color(0.9, 0.86, 0.86)
	sky_shade = Color(0.08, 0.05, 0.08)
	back_row_on = true
	back_row_skip = [[5900.0, 7150.0]]

	# --- 1. Kale çıkışı: şafak, defter ------------------------------------------
	_terrain(-400, 1700, 0)
	_story(-1.0, _sahne_safak, 240.0)
	_prop("saksi", 380)
	_coin_line(450, 5, 50, -50)
	_enemy(STREET, 900, 0)
	_prop("vazo", 1150)
	_prop("kasa", 1220)

	# --- 2. Balat yokuşu: ana yol iner, balkonlar isteğe bağlı ---------------
	_checkpoint(1500, 0)
	_terrain(1700, 1900, 30)
	_terrain(1900, 2100, 60)
	_terrain(2100, 3300, 90)
	_balcony(1950, -60, 110)
	_balcony(2110, -160, 110)
	_coin_line(2060, 3, 50, -210)
	_balcony(2400, -70, 120)
	_balcony(2560, -170, 120)
	_pickup(ARMOR, 2560, -215)
	_coin_line(2360, 4, 50, -120)
	# Kovalamaca: Karahanlı'nın kalan adamları minibüsle yokuştan iner. Durma, koş;
	# balkonlar isteğe bağlı kaçış + ödül yolu.
	_chase(1560, 3350, 280.0, "MİNİBÜS! KOŞ!")
	_balcony(2750, -60, 120)
	_balcony(2950, -150, 120)
	_coin_line(1750, 10, 70, -10)
	_coin_line(2700, 6, 60, -200)
	_prop("saksi", 3150, 90)

	# --- 3. Kayıkçı iskelesi: kısa su boşlukları, sabit iskele -------------------
	_checkpoint(3200, 90)
	_terrain(3300, 3500, 45)
	_terrain(3500, 3900, 0)
	_canal(3900, 4100, 110)
	_scaffold(4000, -20, 220)
	_terrain(4100, 4500, 0)
	_canal(4500, 4700, 110)
	_scaffold(4600, -20, 220)
	_coin_line(3950, 3, 50, -70)
	_coin_line(4550, 3, 50, -70)
	_enemy(SHIELD, 4300, 0)
	_story(4250, _sahne_kayikci)

	# --- 4. Kapan depoları: tüfekli siper; iki dalgalı avlu ----------------------
	_terrain(4700, 9800, 0)
	_checkpoint(4800, 0)
	_crates(5000, 1, 1)
	_crates(5090, 1, 2)
	_terrain(5180, 5500, -180)
	_enemy(RIFLE, 5420, -180)
	_coin_line(5220, 4, 60, -230)
	_prop("kasa", 5650)
	_prop("varil", 5720)
	_scaffold(6200, -170, 220)
	_coin_line(6140, 4, 50, -220)
	var arena: BattleArena = ARENA.instantiate()
	arena.position = Vector2(6200, 0)
	arena.gate_left_x = 5800
	arena.gate_right_x = 6700
	arena.floor_y = 0
	arena.wave1 = _wave(BOMBER, KNIFE, STREET)
	arena.wave2 = _wave(BRUISER, SHIELD)
	arena.reward = HEALTH
	add_child(arena)
	var shop: LevelShop = SHOP.new()
	shop.position = Vector2(6900, 0)
	shop.title = "KAYIKÇI ERZAKI"
	shop.items = PackedStringArray(["can", "cephane", "zirh"])
	shop.accent = Color("e7a449")
	add_child(shop)

	# --- 5. Rıhtım vinci (üst ödül yolu) + eski han -----------------------------
	_checkpoint(7100, 0)
	_crates(7200, 1, 1)
	_scaffold(7380, -150, 140)
	_moving(7550, -230, Vector2(300, 0), 140, 0.0)
	_scaffold(8020, -230, 140)
	_coin_line(7560, 5, 75, -290)
	_pickup(AMMO, 8020, -275)
	_enemy(ASSASSIN, 7600, 0)
	_enemy(BOMBER, 7900, 0)
	_story(8150, _sahne_eski_han)

	# --- 6. Gümrük kaydı: son avlu --------------------------------------------
	_checkpoint(8300, 0)
	_prop("vazo", 8450)
	_prop("sandik", 9150, 0, HEALTH)
	var final: BattleArena = ARENA.instantiate()
	final.position = Vector2(8850, 0)
	final.gate_left_x = 8450
	final.gate_right_x = 9250
	final.floor_y = 0
	final.wave1 = _wave(KNIFE, ASSASSIN)
	final.wave2 = _wave(ELITE, RIFLE)
	final.reward = HEALTH
	add_child(final)
	_story(9350, _sahne_gumruk)
	_han_gate(9600, "GÜMRÜK")
	# Çevresel tehlikeler.
	_falling_pot(1950, -64)
	_falling_pot(2560, -174)
	# Telsiz: oynanışı durdurmayan bölüm içi konuşmalar.
	_radio(2400, "gazelle", "GAZELLE", "Sevkiyat defterinde Haliç'teki eski han yazıyor. Kartal başının yeni sahibi var.")
	_radio(5280, "redmount", "REDMOUNT", "Karahanlı düştü ama zincir kopmadı.")
	_radio(8160, "gazelle", "GAZELLE", "Gümrük kaydında bir imza: tek harf, K. Mürekkebi beyaz.")
	_goal(9600, 0)


# --- Hikâye sahneleri ----------------------------------------------------------

## Şafak: kaleden çıkış, defterin ilk adresi.
func _sahne_safak(cs: Cutscene) -> void:
	cs.actor("rm", "redmount", Vector2(40, 0))
	cs.actor("gz", "gazelle", Vector2(-40, 0))
	await cs.pan(Vector2(380, -200), 0.01)
	cs.move("gz", 160, 1.4, "walk", false)
	await cs.move("rm", 240, 1.4, "walk")
	cs.face("gz", 1)
	await cs.say("gz", "GAZELLE", "Şafak... Kaç gündür gökyüzü görmedim, bilmiyorum bile.")
	await cs.say("rm", "REDMOUNT", "Dört gün. Saydım. Sen kapıları saydın, ben günleri.")
	await cs.say("gz", "GAZELLE", "Defteri okudum. İlk adres Haliç kıyısı: kayıkçılar, depolar, bir de eski bir han.")
	await cs.say("rm", "REDMOUNT", "Karahanlı'nın üstündeki biri. Yüzünü görmeden durmayacak mıyız?")
	await cs.say("gz", "GAZELLE", "Durmayacağız. Ama bu sefer önden gitme. Yan yana.")
	await cs.say("rm", "REDMOUNT", "Yan yana. Sen fotoğraf çek, ben kapıları açarım.")


## Kayıkçı iskelesi: yaşlı kayıkçı ipucu verir.
func _sahne_kayikci(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	cs.actor("ky", "voice", Vector2(p.x + 260, -60))
	await cs.pan(Vector2(p.x + 120, -200), 0.5)
	await cs.say("ky", "KAYIKÇI (sandalından)", "Gece yarısı mühürsüz kasalar indirdiler. Kapan depolarına taşıdılar.")
	await cs.say("gz", "GAZELLE", "Kasaların üstünde bir işaret var mıydı? Kartal başı?")
	await cs.say("ky", "KAYIKÇI", "Kartal değil kızım. Bir mühür... gümrük mührüne benziyordu ama yanlıştı.")
	await cs.say("rm", "REDMOUNT", "Sahte gümrük mührü. Defterdeki ikinci iz.")


## Eski han: adres boş, kayıt gümrükte.
func _sahne_eski_han(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(p.x + 150, -200), 0.5)
	await cs.say("gz", "GAZELLE", "Defterdeki han bu. Kapı açık... içi bomboş.")
	await cs.say("rm", "REDMOUNT", "Birileri bizden önce temizlemiş. Ama mühür kaydı gümrüğe kalır.")
	await cs.say("gz", "GAZELLE", "Gümrük kayıt kapısı rıhtımın sonunda. Kayıt varsa oradadır.")


## Gümrük: kayıt bulunur; zincir Haliç'ten içeri uzanır.
func _sahne_gumruk(cs: Cutscene) -> void:
	var p := cs.player_pos()
	cs.actor("rm", "redmount", p)
	cs.actor("gz", "gazelle", p + Vector2(-80, 0))
	await cs.pan(Vector2(9500, -200), 0.6)
	cs.pose("gz", "rescue_react")
	await cs.say("gz", "GAZELLE", "Buldum! Kayıt... mühür numarası defterdekiyle aynı. Ama bu bir adres değil.")
	await cs.say("gz", "GAZELLE", "Sahte bir sevkiyat mührü. Kalıbı Cibali'deki baskıhanede basılmış.")
	await cs.say("rm", "REDMOUNT", "Haliç boyunca işleyen koca bir zincir. Halka halka sökeceğiz.")
	await cs.say("gz", "GAZELLE", "Baskıhane. Kalıbı bulursak, kimin bastırdığını da buluruz.")
