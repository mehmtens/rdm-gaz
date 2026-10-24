## DailyWave — "Günün Dalgası" planı (OYNANIS-KALITE P1-7).
##
## Survival arenasında tarihten tohumlanan, 5 dalgalık kısa koşu. Aynı gün herkes
## (aynı sürümde) aynı kuralı ve aynı düşman dizisini görür; sunucu gerekmez.
## Günün ilk denemesi puanlıdır (coin + tamamlama ödülü), sonrakiler antrenmandır.
class_name DailyWave
extends RefCounted

const WAVES := 5
## Günün dalgası ilk denemede bitirilirse kalıcı cüzdana eklenen ödül.
const CLEAR_BONUS := 60
## Arenada 8 doğma noktası var (survival.gd); bir dalga bundan fazla olamaz.
const MAX_PER_WAVE := 8

## Günün kuralları. Her kural tek bir şeyi değiştirir; oyuncu açılış yazısından okur.
##  weapon: başlangıç silahı ("" = yumruk) · armor: zırhla başla · heal: dalga arası can
##  extra: dalga başına ek düşman · armory: cephanelik açık mı · pool: düşman havuzu üst sınırı
## İsteğe bağlı (yoksa varsayılan): must: dalga 2'den itibaren her dalgada en az bir bu
##  düşman · speed: düşman koşu hızı çarpanı · boss_at: bu dalga tek başına Mini Boss
const RULES: Array[Dictionary] = [
	{"id": "sopa", "name": "SOPA GÜNÜ", "desc": "Sopayla başla, kalabalık gelir",
		"weapon": "bat", "armor": false, "heal": 10, "extra": 1, "armory": true, "pool": 5},
	{"id": "zirh", "name": "ZIRHLI GİR", "desc": "Zırhla başla, iyileşme yarım",
		"weapon": "", "armor": true, "heal": 5, "extra": 0, "armory": true, "pool": 5},
	{"id": "aclik", "name": "SİMİT YOK", "desc": "Dalga arası iyileşme yok",
		"weapon": "", "armor": false, "heal": 0, "extra": 0, "armory": true, "pool": 4},
	{"id": "ciplak", "name": "ÇIPLAK EL", "desc": "Cephanelik kapalı, yumrukla",
		"weapon": "", "armor": false, "heal": 15, "extra": 0, "armory": false, "pool": 4},
	{"id": "nisanci", "name": "NİŞANCI GÜNÜ", "desc": "Tabancayla başla, tüfekliler çok",
		"weapon": "pistol", "armor": false, "heal": 10, "extra": 0, "armory": true, "pool": 5,
		"must": "rifle"},
	{"id": "kalabalik", "name": "PAZAR KALABALIĞI", "desc": "Her dalgada +2 eşkıya",
		"weapon": "", "armor": false, "heal": 10, "extra": 2, "armory": true, "pool": 2},
	{"id": "hizli", "name": "HIZLI ADIM", "desc": "Düşmanlar %30 daha hızlı",
		"weapon": "", "armor": false, "heal": 15, "extra": 0, "armory": true, "pool": 4,
		"speed": 1.3},
	{"id": "erken", "name": "ERKEN PATRON", "desc": "3. dalgada patron gelir",
		"weapon": "", "armor": false, "heal": 15, "extra": 0, "armory": true, "pool": 5,
		"boss_at": 3},
	{"id": "bicak", "name": "BIÇAK GÜNÜ", "desc": "Bıçakla başla, bıçaklılar çok",
		"weapon": "knife", "armor": false, "heal": 10, "extra": 0, "armory": true, "pool": 5,
		"must": "knife"},
]

## Seri ödülleri: bu günlük seriye ulaşılan gün, temizlemenin üstüne bir kez eklenir.
## 14'ten sonra her 7 günde bir STREAK_REPEAT (bkz. streak_reward).
const STREAK_REWARDS := {3: 40, 7: 100, 14: 200}
const STREAK_REPEAT := 100
## Kanıt Arşivi'nin GÜNLÜK sekmesi: bu seri günlerine ulaşınca birer kare açılır
## (assets/ui/photos/gun_N.png). İlk üç seri ödülüyle aynı günler: ödül anı tek yerde.
const ARCHIVE_DAYS: PackedInt32Array = [3, 7, 14]

## Düşman havuzu zorluk sırasıyla (survival.gd sahne eşlemesi). "pool" kuralı ilk N'i açar.
const POOL: PackedStringArray = ["thug", "knife", "rifle", "bruiser", "elite"]

## Test/geliştirme: boş değilse bugünün yerine bu tarih kullanılır ("YYYY-MM-DD").
static var day_override: String = ""


static func today() -> String:
	if not day_override.is_empty():
		return day_override
	return Time.get_date_string_from_system()


## Tarih dizgesinden kararlı tohum (hash() sürümler arasında değişebilir; elle FNV-1a).
static func seed_for(day: String) -> int:
	var h := 2166136261
	for b in day.to_utf8_buffer():
		h = ((h ^ b) * 16777619) & 0xFFFFFFFF
	return h


## Günün planı: {day, rule, waves: Array[Array[String]]}. Son dalga boss + iki koruma.
static func plan(day: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_for(day)
	var rule: Dictionary = RULES[rule_index(day)]
	var waves: Array = []
	for w in range(1, WAVES + 1):
		var list: Array[String] = []
		if w == int(rule.get("boss_at", 0)):
			list.append("miniboss")
		elif w == WAVES:
			list.append("miniboss")
			for i in 2:
				list.append(POOL[rng.randi_range(0, mini(int(rule.pool), 2) - 1)])
		else:
			# Dalga w'de havuzun ilk w+1 düşmanı açık: ilk dalga yalnız eşkıya/bıçaklı.
			var open := clampi(w + 1, 1, int(rule.pool))
			var count := mini(2 + w + int(rule.extra), MAX_PER_WAVE)
			for i in count:
				list.append(POOL[rng.randi_range(0, open - 1)])
			# Nişancı/bıçak gününde her dalgada en az bir tüfekli/bıçaklı (kuralın vaadi görünsün).
			var must := String(rule.get("must", ""))
			if not must.is_empty() and w >= 2 and not must in list:
				list[0] = must
		waves.append(list)
	return {"day": day, "rule": rule, "waves": waves}


## Günün kural sırası: günler RULES.size()'lik bloklara bölünür, her blokta kurallar
## bir kez ve karışık sırayla gelir (tohum modülüne göre eşit dağılım; aynı kural en geç
## 2·N-1 gün sonra döner). Blok sınırında aynı kural art arda gelmesin diye ilk ikisi takas.
static func rule_index(day: String) -> int:
	var n := _day_number(day)
	var size := RULES.size()
	var block := floori(float(n) / size)
	var order := _block_order(block)
	if order[0] == _block_order(block - 1)[size - 1]:
		var first: int = order[0]
		order[0] = order[1]
		order[1] = first
	return order[posmod(n, size)]


static func _block_order(block: int) -> Array:
	var order: Array = range(RULES.size())
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_for("blok-%d" % block)
	# Fisher–Yates; Array.shuffle() genel tohumu kullanır, kararlı değil.
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t: int = order[i]
		order[i] = order[j]
		order[j] = t
	return order


## Seri bu güne ulaştığında verilen ek coin (0 = ödül günü değil).
static func streak_reward(streak: int) -> int:
	if STREAK_REWARDS.has(streak):
		return int(STREAK_REWARDS[streak])
	if streak > 14 and streak % 7 == 0:
		return STREAK_REPEAT
	return 0


## En uzun seriye göre açılmış arşiv karesi sayısı (0–ARCHIVE_DAYS.size()).
static func archive_photos(best_streak: int) -> int:
	var n := 0
	for d in ARCHIVE_DAYS:
		if best_streak >= d:
			n += 1
	return n


## Sıradaki ödül günü ve miktarı: [gün, coin].
static func next_streak_reward(streak: int) -> Array:
	var d := streak + 1
	while streak_reward(d) == 0:
		d += 1
	return [d, streak_reward(d)]


## Seri `day` gününe ulaşınca yeni bir arşiv karesi açılır mı (en uzun seri henüz oraya varmadıysa).
static func day_opens_photo(day: int, best_streak: int) -> bool:
	return day in ARCHIVE_DAYS and day > best_streak


## Seri bugün hâlâ canlı mı: son temizleme bugün ya da dün.
static func streak_alive(last_clear_day: String, day: String) -> bool:
	if last_clear_day.is_empty():
		return false
	return last_clear_day == day or _day_number(day) - _day_number(last_clear_day) == 1


## Seri yakın zamanda koptu mu (menüde "SERİ KOPTU" uyarısı): seri vardı, dün de bugün de
## temizlenmedi ve kopuş BROKEN_NOTICE_DAYS günden eski değil (uzun aradan dönene suçlama yok).
const BROKEN_NOTICE_DAYS := 7


static func streak_broken(last_clear_day: String, day: String, streak: int) -> bool:
	if streak <= 0 or last_clear_day.is_empty():
		return false
	var gap := _day_number(day) - _day_number(last_clear_day)
	return gap >= 2 and gap <= BROKEN_NOTICE_DAYS + 1


## Seri koruma: yalnız dün kaçırıldıysa (bugün henüz temizlenmedi) oyuncu RESCUE_COST
## coin ödeyip dünü "temizlenmiş" sayabilir; seri sayısı artmaz, yalnız köprü kurulur.
## Bir kurtarma sonrası RESCUE_COOLDOWN gün yeniden kurtarma yok (alışkanlık bedava olmasın).
const RESCUE_COST := 80
const RESCUE_COOLDOWN := 7


static func rescue_available(last_clear_day: String, day: String, streak: int, rescue_day: String) -> bool:
	if streak <= 0 or last_clear_day.is_empty():
		return false
	if _day_number(day) - _day_number(last_clear_day) != 2:
		return false
	return rescue_day.is_empty() or _day_number(day) - _day_number(rescue_day) >= RESCUE_COOLDOWN


## Verilen günden bir önceki gün ("YYYY-MM-DD").
static func yesterday(day: String) -> String:
	return Time.get_date_string_from_unix_time((_day_number(day) - 1) * 86400 + 43200)


## Bitirilen gün dünü takip ediyorsa seri sürer; aksi hâlde 1'den başlar.
static func next_streak(last_clear_day: String, day: String, streak: int) -> int:
	if last_clear_day == day:
		return streak
	if not last_clear_day.is_empty() and _day_number(day) - _day_number(last_clear_day) == 1:
		return streak + 1
	return 1


static func _day_number(day: String) -> int:
	return int(Time.get_unix_time_from_datetime_string(day + "T12:00:00") / 86400)
