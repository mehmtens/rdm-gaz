## Achievements — Kanıt Arşivi'ndeki GÖREVLER (OYNANIS-KALITE P2 "başarımlar", ilk dilim).
##
## Uzun vadeli hedef listesi: her görevin ilerlemesi kayıttan (`Save`) türetilir, ayrı
## sayaç tutulmaz; yalnız iki koşu içi olay (yenilen düşman, en uzun kombo) `Save.stat_*`
## alanlarında birikir. Görev tamamlanınca HUD'da tabela çıkar (`Save.achievement_reached`),
## coin ödülü arşivde elle alınır (DTM'deki görev ödülü gibi: oyuncu menüye döner, ödülü
## görür). Elle alma, eski testlerdeki cüzdan hesaplarını da bozmaz.
class_name Achievements
extends RefCounted

## kind: clear (bölüm `goal`-1 bitti), secrets, stars, mastered, survival, streak,
## costumes, upgrades, defeats, combo; beceri: throws, air_kills, flawless_boss. Ödül kademeleri 30 / 60 / 120 coin — ustalık
## (50) ve seri ödülleriyle (40–200) aynı ölçek; toplamı (≈1000) iki kostüm eder.
const LIST: Array[Dictionary] = [
	{"id": "ilk_adim", "name": "İLK ADIM", "desc": "Bölüm 1'i bitir", "kind": "clear", "goal": 1, "reward": 30},
	{"id": "kitap1", "name": "BALAT AYAKTA", "desc": "Kitap 1'i bitir", "kind": "clear", "goal": 12, "reward": 60},
	{"id": "kitap2", "name": "ŞEHRİN ALTINDA", "desc": "Kitap 2'yi bitir", "kind": "clear", "goal": 24, "reward": 120},
	{"id": "kitap3", "name": "ŞEHİR UYANDI", "desc": "Kitap 3'ü bitir", "kind": "clear", "goal": 36, "reward": 120},
	{"id": "iz_suren", "name": "İZ SÜREN", "desc": "10 gizli alan bul", "kind": "secrets", "goal": 10, "reward": 30},
	{"id": "kanit_avcisi", "name": "KANIT AVCISI", "desc": "50 gizli alan bul", "kind": "secrets", "goal": 50, "reward": 120},
	{"id": "yildiz_30", "name": "YILDIZ TOPLAYICI", "desc": "30 yıldız topla", "kind": "stars", "goal": 30, "reward": 60},
	{"id": "usta", "name": "USTA ELİ", "desc": "5 bölümü %100 bitir", "kind": "mastered", "goal": 5, "reward": 60},
	{"id": "dalga_10", "name": "MEYDAN BEKÇİSİ", "desc": "Survival'da 10. dalgaya ulaş", "kind": "survival", "goal": 10, "reward": 30},
	{"id": "dalga_20", "name": "MEYDANIN SAHİBİ", "desc": "Survival'da 20. dalgaya ulaş", "kind": "survival", "goal": 20, "reward": 120},
	{"id": "seri_7", "name": "MÜDAVİM", "desc": "Günün Dalgası'nda 7 günlük seri", "kind": "streak", "goal": 7, "reward": 60},
	{"id": "gardirop", "name": "GARDIROP", "desc": "3 kostüm satın al", "kind": "costumes", "goal": 3, "reward": 60},
	{"id": "talim", "name": "TALİMLİ", "desc": "Geliştirmelerden 6 kademe al", "kind": "upgrades", "goal": 6, "reward": 30},
	{"id": "yuz_kavga", "name": "MAHALLE KAVGASI", "desc": "100 düşman yen", "kind": "defeats", "goal": 100, "reward": 30},
	{"id": "bin_kavga", "name": "ŞEHRİN KABUSU", "desc": "1000 düşman yen", "kind": "defeats", "goal": 1000, "reward": 120},
	{"id": "kombo_25", "name": "DURMAK YOK", "desc": "25 vuruşluk kombo yap", "kind": "combo", "goal": 25, "reward": 60},
	## Beceri görevleri (ikinci dilim): ilerleme değil oyun tarzı ister.
	{"id": "firlatici", "name": "HAMAL KOLU", "desc": "15 düşmanı fırlat", "kind": "throws", "goal": 15, "reward": 30},
	{"id": "havada", "name": "YERE DEĞMEDEN", "desc": "Havadaki 10 düşmanı bitir", "kind": "air_kills", "goal": 10, "reward": 60},
	{"id": "temiz_is", "name": "TEMİZ İŞ", "desc": "Bir patronu hasar almadan yen", "kind": "flawless_boss", "goal": 1, "reward": 120},
]


static func find(id: String) -> Dictionary:
	for a in LIST:
		if a.id == id:
			return a
	return {}


## Görevin şu anki ilerlemesi (hedefte kırpılmaz; ekranda `mini(value, goal)` yazılır).
static func value(a: Dictionary) -> int:
	match String(a.kind):
		"clear":
			return int(a.goal) if Save.is_cleared(int(a.goal) - 1) else 0
		"secrets":
			var n := 0
			for i in Save.secrets:
				var s: Array = Save.secrets[i]
				if s.size() == 2:
					n += int(s[0])
			return n
		"stars":
			return Save.total_stars()
		"mastered":
			return Save.mastered.size()
		"survival":
			return Save.survival_best_wave
		"streak":
			return Save.daily_best_streak
		"costumes":
			var n := 0
			for item in Save.purchased:
				if String(item).begins_with("costume_"):
					n += 1
			return n
		"upgrades":
			var n := 0
			for k in Save.upgrade_levels:
				n += int(Save.upgrade_levels[k])
			return n
		"defeats":
			return Save.stat_defeats
		"combo":
			return Save.stat_best_combo
		"throws":
			return Save.stat_throws
		"air_kills":
			return Save.stat_air_kills
		"flawless_boss":
			return Save.stat_flawless_bosses
	return 0


static func is_done(a: Dictionary) -> bool:
	return value(a) >= int(a.goal)


## Tamamlanmış id'ler (LIST sırasıyla).
static func reached() -> Array:
	var out := []
	for a in LIST:
		if is_done(a):
			out.append(a.id)
	return out


## Tamamlanıp ödülü alınmamış görev sayısı (ana menü düğmesindeki "· n ÖDÜL").
static func unclaimed() -> int:
	var n := 0
	for a in LIST:
		if is_done(a) and not (a.id in Save.achievements_claimed):
			n += 1
	return n
