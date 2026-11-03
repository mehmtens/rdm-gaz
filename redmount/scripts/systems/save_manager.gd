## Save — kalıcı ilerleme + ayar kaydı autoload'u (Görev 13).
##
## `user://redmount_save.cfg` (ConfigFile). Ana plan md. 19: açılan bölüm,
## toplam coin, bölüm yüksek skorları, ses ayarı. project.godot -> [autoload] "Save".
extends Node

## Bir görev (Achievements.LIST) ilk kez tamamlandı; HUD tabela gösterir.
signal achievement_reached(id: String)

const PATH := "user://redmount_save.cfg"
## İnsan testi için başlatma (`-- --bolum=N`): gerçek kayıt yerine ayrı, boş bir
## kayıt kullanılır. Böylece test, oyuncunun açtığı bölümleri, coin'lerini ve
## mağaza alımlarını değiştirmez; test yükseltmesiz yeni bir oyuncu gibi başlar.
const TEST_PATH := "user://redmount_test_save.cfg"
## %100 ustalık (bölümün 3 yıldızı) için tek seferlik coin.
const MASTERY_REWARD := 50
## Bölüm sonu yıldızları (bit maskesi): hız (par süre), hasarsız, bütün gizli alanlar.
const STAR_SPEED := 1
const STAR_FLAWLESS := 2
const STAR_SECRETS := 4
const STARS_PER_LEVEL := 3

var _path := PATH

## En yüksek açılan bölüm indeksi (0 tabanlı). 0 = sadece Bölüm 1 açık.
var unlocked_level: int = 0
## Kalıcı cüzdan (koşu içi coin'den ayrı; bölüm bitince eklenir).
var total_coins: int = 0
## level_index -> en yüksek skor.
var best_scores: Dictionary = {}
## Bölüm başına en çok bulunan gizli alan [bulunan, toplam].
var secrets: Dictionary = {}
## Bölüm başına en iyi rütbe (S/A/B/C).
var ranks: Dictionary = {}
## Bölüm başına kazanılan yıldızlar (index -> bit maskesi; koşular birleşir).
## Eski kayıtlarda yok → boş sözlük; yıldız yeniden oynanarak kazanılır.
var stars: Dictionary = {}
## Bölüm başına en kısa bitirme süresi (sn).
var best_times: Dictionary = {}
## %100 ustalık ödülü alınmış bölümler (index -> true). Ödül bölüm başına bir kez.
var mastered: Dictionary = {}
var survival_best_wave: int = 0
## Günün Dalgası (DailyWave): puanlı denemenin günü ("YYYY-MM-DD"; boş = hiç),
## o denemede temizlenen dalga, en son tamamen bitirilen gün ve ardışık gün serisi.
## Eski kayıtlarda yok → boş/0; ilk deneme puanlı sayılır.
var daily_day: String = ""
var daily_waves: int = 0
var daily_clear_day: String = ""
var daily_streak: int = 0
## Son seri kurtarmanın günü (DailyWave.rescue_available; eski kayıtlarda yok → boş).
var daily_rescue_day: String = ""
## Ulaşılan en uzun seri (Kanıt Arşivi'nin GÜNLÜK kareleri; eski kayıtta yok → güncel seri).
var daily_best_streak: int = 0
var master_volume_db: float = 0.0
## Telefonda dokunma/isabet titreşimi (eski kayıtlarda yok → açık).
var vibration: bool = true
## Oyuncu duraklatma/cephaneliği bir kez açtı mı: HUD'daki "ESC: CEPHANELİK" ipucu
## öğrenildikten sonra gizlenir (eski kayıtta yok → false).
var armory_seen: bool = false
## Satın alınan mağaza ürün id'leri.
var purchased: Array = []
## Kalıcı kademeli geliştirmeler: ürün id -> kademe.
var upgrade_levels: Dictionary = {}
## Giyili kostüm id'si (`Shop.COSTUMES`; eski kayıtlarda yok → varsayılan).
## Satın alınan kostümler `purchased` içinde "costume_<id>" olarak tutulur.
var costume: String = "sokak"
## GÖREVLER (Achievements): ödülü alınmış ve tabelası gösterilmiş görev id'leri, iki
## olay sayacı (yenilen düşman, en uzun kombo). Eski kayıtta yok → yüklemede o ana kadar
## tamamlananlar "görülmüş" sayılır (tabela yağmuru olmaz), ödülleri arşivde alınabilir.
var achievements_claimed: Array = []
var achievements_seen: Array = []
var stat_defeats: int = 0
var stat_best_combo: int = 0
var stat_throws: int = 0
var stat_air_kills: int = 0
var stat_flawless_bosses: int = 0
var stat_weapon_kills: int = 0
## Düşman bitirmiş silahların kimlikleri (`Achievements.weapon_id`, tekrarsız).
var stat_weapon_kinds: Array = []


func _ready() -> void:
	if not test_args().is_empty():
		_path = TEST_PATH
	load_game()
	Combat.combo_finished.connect(_on_combo_finished)


## Komut satırı test seçenekleri: `--bolum=N` (1–36), `--bayrak=K` (bölümün K. kontrol
## noktası, x'e göre sıralı; 0 = bölüm başı). Yoksa boş sözlük.
static func test_args() -> Dictionary:
	var out := {}
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--bolum="):
			out["bolum"] = int(a.get_slice("=", 1))
		elif a.begins_with("--bayrak="):
			out["bayrak"] = int(a.get_slice("=", 1))
		elif a == "--ornek":
			out["ornek"] = 1
	return out


func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(_path) != OK:
		return
	unlocked_level = int(cfg.get_value("progress", "unlocked_level", 0))
	total_coins = int(cfg.get_value("progress", "total_coins", 0))
	best_scores = cfg.get_value("progress", "best_scores", {})
	secrets = cfg.get_value("progress", "secrets", {})
	ranks = cfg.get_value("progress", "ranks", {})
	stars = cfg.get_value("progress", "stars", {})
	best_times = cfg.get_value("progress", "best_times", {})
	mastered = cfg.get_value("progress", "mastered", {})
	survival_best_wave = int(cfg.get_value("progress", "survival_best_wave", 0))
	daily_day = String(cfg.get_value("daily", "day", ""))
	daily_waves = int(cfg.get_value("daily", "waves", 0))
	daily_clear_day = String(cfg.get_value("daily", "clear_day", ""))
	daily_streak = int(cfg.get_value("daily", "streak", 0))
	daily_rescue_day = String(cfg.get_value("daily", "rescue_day", ""))
	daily_best_streak = maxi(int(cfg.get_value("daily", "best_streak", 0)), daily_streak)
	purchased = cfg.get_value("shop", "purchased", [])
	upgrade_levels = cfg.get_value("shop", "upgrade_levels", {})
	costume = String(cfg.get_value("shop", "costume", "sokak"))
	# Eski tek seferlik can yükseltmesini yeni sistemin ilk kademesine taşı.
	if "tough_body" in purchased:
		upgrade_levels["max_health"] = maxi(upgrade_level("max_health"), 1)
		purchased.erase("tough_body")
		save_game()
	master_volume_db = float(cfg.get_value("settings", "master_volume_db", 0.0))
	vibration = bool(cfg.get_value("settings", "vibration", true))
	armory_seen = bool(cfg.get_value("hints", "armory_seen", false))
	achievements_claimed = cfg.get_value("achievements", "claimed", [])
	stat_defeats = int(cfg.get_value("achievements", "defeats", 0))
	stat_best_combo = int(cfg.get_value("achievements", "best_combo", 0))
	stat_throws = int(cfg.get_value("achievements", "throws", 0))
	stat_air_kills = int(cfg.get_value("achievements", "air_kills", 0))
	stat_flawless_bosses = int(cfg.get_value("achievements", "flawless_bosses", 0))
	stat_weapon_kills = int(cfg.get_value("achievements", "weapon_kills", 0))
	stat_weapon_kinds = cfg.get_value("achievements", "weapon_kinds", [])
	if cfg.has_section_key("achievements", "seen"):
		achievements_seen = cfg.get_value("achievements", "seen", [])
	else:
		achievements_seen = Achievements.reached()
	_apply_volume()


func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked_level", unlocked_level)
	cfg.set_value("progress", "total_coins", total_coins)
	cfg.set_value("progress", "best_scores", best_scores)
	cfg.set_value("progress", "secrets", secrets)
	cfg.set_value("progress", "ranks", ranks)
	cfg.set_value("progress", "stars", stars)
	cfg.set_value("progress", "best_times", best_times)
	cfg.set_value("progress", "mastered", mastered)
	cfg.set_value("progress", "survival_best_wave", survival_best_wave)
	cfg.set_value("daily", "day", daily_day)
	cfg.set_value("daily", "waves", daily_waves)
	cfg.set_value("daily", "clear_day", daily_clear_day)
	cfg.set_value("daily", "streak", daily_streak)
	cfg.set_value("daily", "rescue_day", daily_rescue_day)
	cfg.set_value("daily", "best_streak", daily_best_streak)
	cfg.set_value("shop", "purchased", purchased)
	cfg.set_value("shop", "upgrade_levels", upgrade_levels)
	cfg.set_value("shop", "costume", costume)
	cfg.set_value("settings", "master_volume_db", master_volume_db)
	cfg.set_value("settings", "vibration", vibration)
	cfg.set_value("hints", "armory_seen", armory_seen)
	_announce_achievements()
	cfg.set_value("achievements", "claimed", achievements_claimed)
	cfg.set_value("achievements", "seen", achievements_seen)
	cfg.set_value("achievements", "defeats", stat_defeats)
	cfg.set_value("achievements", "best_combo", stat_best_combo)
	cfg.set_value("achievements", "throws", stat_throws)
	cfg.set_value("achievements", "air_kills", stat_air_kills)
	cfg.set_value("achievements", "flawless_bosses", stat_flawless_bosses)
	cfg.set_value("achievements", "weapon_kills", stat_weapon_kills)
	cfg.set_value("achievements", "weapon_kinds", stat_weapon_kinds)
	var error := cfg.save(_path)
	if error != OK:
		push_error("Oyun kaydı yazılamadı: %s (%d)" % [_path, error])


## Bir bölüm tamamlanınca çağrılır.
func record_level_clear(index: int, run_coins: int, score: int) -> void:
	var next_max := mini(index + 1, GameState.level_count() - 1)
	unlocked_level = maxi(unlocked_level, next_max)
	total_coins += run_coins
	if score > int(best_scores.get(index, 0)):
		best_scores[index] = score
	save_game()


func record_secrets(index: int, found: int, total: int) -> void:
	var old: Array = secrets.get(index, [0, total])
	secrets[index] = [maxi(int(old[0]), found), total]
	save_game()


func record_rank(index: int, rank: String) -> void:
	const ORDER := "CBAS"
	if rank.length() != 1 or ORDER.find(rank) < 0:
		return
	var previous := String(ranks.get(index, ""))
	if previous.is_empty() or ORDER.find(rank) > ORDER.find(previous):
		ranks[index] = rank
		save_game()


## Bu koşunun yıldızlarını öncekilerle birleştirir (yıldız bir kez kazanılınca kalır).
func record_stars(index: int, mask: int) -> void:
	mask &= STAR_SPEED | STAR_FLAWLESS | STAR_SECRETS
	var merged := stars_of(index) | mask
	if merged != stars_of(index):
		stars[index] = merged
		save_game()


func stars_of(index: int) -> int:
	return int(stars.get(index, 0))


func star_count(index: int) -> int:
	var m := stars_of(index)
	return int((m & STAR_SPEED) != 0) + int((m & STAR_FLAWLESS) != 0) + int((m & STAR_SECRETS) != 0)


func total_stars() -> int:
	var n := 0
	for k in stars:
		n += star_count(int(k))
	return n


func record_time(index: int, seconds: float) -> void:
	if seconds <= 0.0:
		return
	if not best_times.has(index) or seconds < float(best_times[index]):
		best_times[index] = seconds
		save_game()


func best_time(index: int) -> float:
	return float(best_times.get(index, 0.0))


## Bölüm %100 mü: üç yıldızın hepsi kazanılmış.
func is_cleared(index: int) -> bool:
	return best_scores.has(index) or unlocked_level > index


func is_complete(index: int) -> bool:
	return star_count(index) == STARS_PER_LEVEL


## %100'e ilk kez ulaşıldıysa ödülü cüzdana ekler ve miktarı döner; yoksa 0.
func claim_mastery(index: int) -> int:
	if mastered.has(index) or not is_complete(index):
		return 0
	mastered[index] = true
	total_coins += MASTERY_REWARD
	save_game()
	return MASTERY_REWARD


func rank_of(index: int) -> String:
	return String(ranks.get(index, ""))


func secrets_of(index: int) -> Array:
	return secrets.get(index, [])


func best_score(index: int) -> int:
	return int(best_scores.get(index, 0))


func record_survival(wave: int, earned_coins: int) -> void:
	survival_best_wave = maxi(survival_best_wave, wave)
	total_coins += maxi(earned_coins, 0)
	save_game()


## Günün puanlı denemesi bu gün zaten başladı mı (sonraki koşular antrenman).
func daily_attempted(day: String) -> bool:
	return daily_day == day


## Puanlı denemeyi başlatır: yarıda bırakılsa da günün hakkı kullanılmış olur.
func begin_daily(day: String) -> void:
	daily_day = day
	daily_waves = 0
	save_game()


func record_daily_wave(waves: int) -> void:
	daily_waves = maxi(daily_waves, waves)
	save_game()


## Puanlı deneme biter: koşu coin'i cüzdana; bütün dalgalar temizse seri ilerler.
## Seri bir ödül gününe ulaştıysa ek coin de eklenir; dönüş değeri o ek coin.
func finish_daily(day: String, earned_coins: int, cleared: bool) -> int:
	total_coins += maxi(earned_coins, 0)
	var reward := 0
	if cleared and daily_clear_day != day:
		daily_streak = DailyWave.next_streak(daily_clear_day, day, daily_streak)
		daily_clear_day = day
		daily_best_streak = maxi(daily_best_streak, daily_streak)
		reward = DailyWave.streak_reward(daily_streak)
		total_coins += reward
	save_game()
	return reward


## Kopan seri bugün kurtarılabilir mi (bugünün puanlı denemesi henüz kullanılmadıysa).
func can_rescue_daily(day: String) -> bool:
	return not daily_attempted(day) and DailyWave.rescue_available(
		daily_clear_day, day, daily_streak, daily_rescue_day)


## Seriyi coin karşılığı kurtarır: dün temizlenmiş sayılır, bugün temizlenirse seri sürer.
func rescue_daily(day: String) -> bool:
	if not can_rescue_daily(day) or total_coins < DailyWave.RESCUE_COST:
		return false
	total_coins -= DailyWave.RESCUE_COST
	daily_clear_day = DailyWave.yesterday(day)
	daily_rescue_day = day
	save_game()
	return true


func owns(item_id: String) -> bool:
	return item_id in purchased


## Ürünü satın al. Yeterli coin yoksa / zaten sahipse false döner.
func buy(item_id: String, cost: int) -> bool:
	if owns(item_id) or total_coins < cost:
		return false
	total_coins -= cost
	purchased.append(item_id)
	save_game()
	return true


func upgrade_level(item_id: String) -> int:
	return maxi(int(upgrade_levels.get(item_id, 0)), 0)


func buy_upgrade(item_id: String, cost: int, max_level: int) -> bool:
	var current := upgrade_level(item_id)
	if cost < 0 or current >= max_level or total_coins < cost:
		return false
	total_coins -= cost
	upgrade_levels[item_id] = current + 1
	save_game()
	return true


func owns_costume(id: String) -> bool:
	return id == "sokak" or owns("costume_" + id)


func buy_costume(id: String, cost: int) -> bool:
	return buy("costume_" + id, cost)


## Sahip olunan kostümü giyer; sahip değilse false.
func set_costume(id: String) -> bool:
	if not owns_costume(id):
		return false
	costume = id
	save_game()
	return true


func set_volume_db(db: float) -> void:
	master_volume_db = clampf(db, -40.0, 6.0)
	_apply_volume()
	save_game()


func set_vibration(on: bool) -> void:
	vibration = on
	save_game()


func set_armory_seen() -> void:
	if armory_seen:
		return
	armory_seen = true
	save_game()


func wipe() -> void:
	unlocked_level = 0
	armory_seen = false
	total_coins = 0
	best_scores = {}
	secrets = {}
	ranks = {}
	stars = {}
	best_times = {}
	mastered = {}
	survival_best_wave = 0
	daily_day = ""
	daily_waves = 0
	daily_clear_day = ""
	daily_streak = 0
	daily_rescue_day = ""
	daily_best_streak = 0
	purchased = []
	upgrade_levels = {}
	costume = "sokak"
	achievements_claimed = []
	achievements_seen = []
	stat_defeats = 0
	stat_best_combo = 0
	stat_throws = 0
	stat_air_kills = 0
	stat_flawless_bosses = 0
	stat_weapon_kills = 0
	stat_weapon_kinds = []
	save_game()


# --- Görevler (Achievements) ------------------------------------------------------

## Yenilen düşman (Main ve Survival çağırır). Yalnız bellekte; bölüm/koşu sonundaki
## kayıtla yazılır. Eşik geçildiyse tabela hemen çıksın diye duyuru da yapılır.
func count_defeat() -> void:
	stat_defeats += 1
	_announce_achievements()


## Beceri sayaçları (oyuncu fırlatışı, havada biten düşman, hasarsız patron); bellekte
## birikir, `count_defeat` gibi bölüm/koşu sonundaki kayıtla yazılır.
func count_throw() -> void:
	stat_throws += 1
	_announce_achievements()


func count_air_kill() -> void:
	stat_air_kills += 1
	_announce_achievements()


func count_flawless_boss() -> void:
	stat_flawless_bosses += 1
	_announce_achievements()


func count_weapon_kill(weapon: StringName) -> void:
	stat_weapon_kills += 1
	if not (String(weapon) in stat_weapon_kinds):
		stat_weapon_kinds.append(String(weapon))
	_announce_achievements()


func _on_combo_finished(count: int, _bonus: int) -> void:
	if count > stat_best_combo:
		stat_best_combo = count
		_announce_achievements()


## Yeni tamamlanan görevleri "görülmüş" işaretler ve sinyalle duyurur (yazma yok).
func _announce_achievements() -> void:
	for id in Achievements.reached():
		if not (id in achievements_seen):
			achievements_seen.append(id)
			achievement_reached.emit(id)


func can_claim_achievement(id: String) -> bool:
	var a := Achievements.find(id)
	return not a.is_empty() and Achievements.is_done(a) and not (id in achievements_claimed)


## Görev ödülünü cüzdana ekler, miktarı döner (alınamıyorsa 0).
func claim_achievement(id: String) -> int:
	if not can_claim_achievement(id):
		return 0
	var reward := int(Achievements.find(id).reward)
	achievements_claimed.append(id)
	total_coins += reward
	save_game()
	return reward


func _apply_volume() -> void:
	var bus := AudioServer.get_bus_index(&"Master")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, master_volume_db)
