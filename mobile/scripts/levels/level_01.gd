## Bölüm 1 — Mahalle. Referans şeridi: Köşe Çay → yol çalışması → çatılar →
## Kontrol Büfesi → Minibüs Parkı → Kuzey Hanı. 2 gizli alan, 2 arena, 2 kontrol noktası.
extends Level

const DIM := Color(0.82, 0.8, 0.92) ## Cepheler oyuncudan hafif geride dursun.


func build() -> void:
	level_end = 9900.0
	start_pos = Vector2(260, 0)
	_mahalle()
	_yol_calismasi()
	_bufe()
	_minibus_parki()
	_kuzey_hani()


# A — Köşe Çay / mahalle: hareket, kombo, vazo kırma, ilk gizli alan (bulutlar).
func _mahalle() -> void:
	ground(-600, 2250)
	prop("house_c", 140, 0, "back", 1.0, true, DIM)
	sign_board("KÖŞE ÇAY", 140, -300, 34)
	prop("house_a", 420, 0, "back", 1.0, false, DIM)
	prop("house_b", 720, 0, "back", 1.0, false, DIM)
	prop("tree_pot", 560, 0, "back")
	prop("plant_small", 880, 0, "back")
	prop("house_a", 1080, 0, "back", 1.0, true, DIM)
	prop("house_c", 1330, 0, "back", 1.0, false, DIM)
	prop("house_b", 1640, 0, "back", 1.0, true, DIM)
	prop("house_a", 1960, 0, "back", 1.0, false, DIM)
	prop("pots", 1480, 0, "back")

	hint(Rect2(-100, -500, 800, 520), "◀ ▶ KOŞ   ·   ZIPLA (basılı tut: yüksek)   ·   VUR")
	coin_row(420, -70, 6)
	coin_arc(880, -80, 5, 60, 150)

	hint(Rect2(760, -500, 280, 520), "VUR'u basılı tut, bırak: GÜÇLÜ YUMRUK")
	breakable("vase_big", 1180, 0, 4)
	breakable("vase_small", 1260, 0, 2)
	hint(Rect2(1050, -500, 300, 520), "Vazoları kır — içinden coin çıkar")

	enemy("thug", 1560)
	hint(Rect2(1380, -500, 300, 520), "VUR'a art arda bas: 4 vuruşluk kombo, sonuncusu yere serer")

	# Yukarı tırmanan çıkıntılar → bulut üstü gizli alan.
	ledge(1640, -210, "ledge_m")
	coin_arc(1650, -300, 3, 55, 60)
	ledge(1880, -400, "ledge_s")
	ledge(2080, -590, "ledge_xs2")
	prop("cloud_city", 1640, -760, "back", 1.0, false, Color(1, 1, 1, 0.85))
	platform("cloud_puff", 1750, -810, 26, 30)
	platform("cloud_small", 1500, -960, 17, 20)
	secret(Rect2(1450, -1150, 620, 400))
	coin_row(1790, -880, 4, 55)
	coin_row(1530, -1030, 2, 55)
	item("simit", 2000, -900)

	enemy("thug", 2080)
	hint(Rect2(1700, -500, 250, 520), "Düşmana doğru yürü: TUT → VUR diz · ZIPLA aparkat · ◀ geri+VUR fırlat")
	hint(Rect2(1950, -500, 300, 520), "Çukur! Koşarak ZIPLA")


# B — Belediye yol çalışması: çukur, iskele, yükseltilmiş blok, duvar zıplaması, çatılar.
func _yol_calismasi() -> void:
	sign_board("YOL ÇALIŞMASI", 2380, -420, 26)
	coin_arc(2250, -130, 5, 60, 160)
	ground(2500, 3150)
	prop("scaffold_post", 2560, 0, "back")
	prop("ladder", 2660, 0, "back")
	breakable("vase_small", 2620, 0, 3)
	platform("scaffold", 2750, -169, 1, 12)
	coin_row(2785, -240, 3, 55)
	platform("scaffold_small", 2960, -120, 1, 12)
	enemy("knife", 3060)
	hint(Rect2(2830, -500, 200, 520), "Havada VUR: dalış tekmesi — isabet edince sekip tekrar vur")

	ground(3150, 3480, -180)
	ground(3480, 3720, -520)
	ledge(3280, -360, "ledge_s")
	for i in 4:
		coin(3430, -250 - i * 70)
	hint(Rect2(3150, -760, 330, 600), "Duvara doğru zıpla, değince tekrar ZIPLA")

	# Çatı yolu (sokağın üstünden) — coin dolu.
	platform("roof_a", 3770, -470, 2, 16)
	coin_row(3810, -540, 5, 60)
	platform("roof_b", 4190, -400, 2, 16)
	coin_row(4230, -470, 4, 55)


# C — Kontrol Büfesi: kontrol noktası, sopa, ilk kilitli arena.
func _bufe() -> void:
	ground(3720, 5600)
	checkpoint(3880)
	prop("house_b", 3980, 0, "back", 1.0, false, DIM)
	prop("house_a", 4260, 0, "back", 1.0, true, DIM)
	prop("bufe", 4800, 0, "back")
	prop("tree_pot", 4600, 0, "back")
	prop("house_c", 5220, 0, "back", 1.0, false, DIM)
	prop("house_b", 5470, 0, "back", 1.0, true, DIM)

	item("bat", 4100, -70)
	hint(Rect2(3960, -500, 280, 520), "SOPA: güçlü ama 14 vuruşta kırılır")
	breakable("pots", 4380, 0, 3)
	breakable("vase_big", 5400, 0, 3, "simit")
	arena(4250, 5560, [
		[["thug", -1], ["thug", 1]],
		[["knife", 1], ["thug", -1], ["thug", 1]],
		[["knife", -1], ["knife", 1], ["thug", 1]],
	])
	hint(Rect2(4400, -500, 500, 520), "ÖZEL dolunca bas: uçan diz, önündeki herkesi yıkar")


# D — Minibüs Parkı: tabanca, minibüs/araba platformları, tüfekli muhafız, gizli niş odası.
func _minibus_parki() -> void:
	ground(5600, 6560)
	sign_board("DOLMUŞ · HER YERE", 5980, -420, 28)
	item("pistol", 5720, -70)
	hint(Rect2(5620, -500, 260, 520), "TABANCA: VUR ile ateş et (12 mermi)")
	platform("bus", 5880, -145, 1, 14)
	coin_row(5930, -215, 6, 55)
	breakable("vase_small", 6400, 0, 2)
	coin_arc(6560, -140, 5, 60, 180)
	hint(Rect2(6300, -500, 260, 520), "Kırmızı lazer = ateş geliyor. ZIPLA!")

	ground(6820, 9900)
	platform("car", 6890, -96, 0, 60)
	enemy("rifle", 7200)
	enemy("knife", 7000)
	ledge(7180, -250, "ledge_l2")
	coin_row(7210, -320, 3, 50)

	# Niş odası: üstü taş tavan, girişi kırılabilir tuğla niş (3 vuruş).
	ground(7460, 7800, -290, 58)
	ledge(7800, -290, "ledge_m") # tavanda alttan geçilen kapak = odadan çıkış
	ground(7929, 7990, -290, 290)
	ledge(7640, -130, "ledge_xs")
	breakable("wall_niche", 7522, 0, 2, "", 3, true, Color(0.55, 0.45, 0.4))
	secret(Rect2(7590, -232, 300, 232))
	coin_row(7620, -80, 4, 60)
	item("simit", 7850, -90)
	enemy("thug", 7600, -290)


# E — Kuzey Hanı: kontrol noktası, final arenası, bölüm sonu.
func _kuzey_hani() -> void:
	checkpoint(8150)
	prop("house_a", 8420, 0, "back", 1.0, false, DIM)
	prop("house_c", 8700, 0, "back", 1.0, true, DIM)
	prop("house_b", 8980, 0, "back", 1.0, false, DIM)
	prop("house_a", 9280, 0, "back", 1.0, true, DIM)
	breakable("pots", 8260, 0, 3)
	arena(8300, 9560, [
		[["thug", -1], ["thug", 1], ["thug", 1]],
		[["rifle", 1], ["knife", -1], ["thug", 1]],
		[["knife", -1], ["knife", 1], ["thug", -1], ["thug", 1]],
	])
	prop("wall_pillar", 9620, 0, "back")
	prop("wall_niche", 9720, 0, "back")
	prop("wall_pillar", 9820, 0, "back")
	sign_board("KUZEY HANI", 9720, -330, 38)
	coin_arc(9600, -90, 4, 55, 90)
	goal(9660)
