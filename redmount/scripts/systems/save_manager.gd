## Save — kalıcı ilerleme + ayar kaydı autoload'u (Görev 13).
##
## `user://redmount_save.cfg` (ConfigFile). Ana plan md. 19: açılan bölüm,
## toplam coin, bölüm yüksek skorları, ses ayarı. project.godot -> [autoload] "Save".
extends Node

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
var master_volume_db: float = 0.0
## Telefonda dokunma/isabet titreşimi (eski kayıtlarda yok → açık).
var vibration: bool = true
## Satın alınan mağaza ürün id'leri.
var purchased: Array = []
## Kalıcı kademeli geliştirmeler: ürün id -> kademe.
var upgrade_levels: Dictionary = {}


func _ready() -> void:
	if not test_args().is_empty():
		_path = TEST_PATH
	load_game()


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
	purchased = cfg.get_value("shop", "purchased", [])
	upgrade_levels = cfg.get_value("shop", "upgrade_levels", {})
	# Eski tek seferlik can yükseltmesini yeni sistemin ilk kademesine taşı.
	if "tough_body" in purchased:
		upgrade_levels["max_health"] = maxi(upgrade_level("max_health"), 1)
		purchased.erase("tough_body")
		save_game()
	master_volume_db = float(cfg.get_value("settings", "master_volume_db", 0.0))
	vibration = bool(cfg.get_value("settings", "vibration", true))
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
	cfg.set_value("shop", "purchased", purchased)
	cfg.set_value("shop", "upgrade_levels", upgrade_levels)
	cfg.set_value("settings", "master_volume_db", master_volume_db)
	cfg.set_value("settings", "vibration", vibration)
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


func set_volume_db(db: float) -> void:
	master_volume_db = clampf(db, -40.0, 6.0)
	_apply_volume()
	save_game()


func set_vibration(on: bool) -> void:
	vibration = on
	save_game()


func wipe() -> void:
	unlocked_level = 0
	total_coins = 0
	best_scores = {}
	secrets = {}
	ranks = {}
	stars = {}
	best_times = {}
	mastered = {}
	survival_best_wave = 0
	purchased = []
	upgrade_levels = {}
	save_game()


func _apply_volume() -> void:
	var bus := AudioServer.get_bus_index(&"Master")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, master_volume_db)
