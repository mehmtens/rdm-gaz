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

var _path := PATH

## En yüksek açılan bölüm indeksi (0 tabanlı). 0 = sadece Bölüm 1 açık.
var unlocked_level: int = 0
## Kalıcı cüzdan (koşu içi coin'den ayrı; bölüm bitince eklenir).
var total_coins: int = 0
## level_index -> en yüksek skor.
var best_scores: Dictionary = {}
var survival_best_wave: int = 0
var master_volume_db: float = 0.0
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
	return out


func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(_path) != OK:
		return
	unlocked_level = int(cfg.get_value("progress", "unlocked_level", 0))
	total_coins = int(cfg.get_value("progress", "total_coins", 0))
	best_scores = cfg.get_value("progress", "best_scores", {})
	survival_best_wave = int(cfg.get_value("progress", "survival_best_wave", 0))
	purchased = cfg.get_value("shop", "purchased", [])
	upgrade_levels = cfg.get_value("shop", "upgrade_levels", {})
	# Eski tek seferlik can yükseltmesini yeni sistemin ilk kademesine taşı.
	if "tough_body" in purchased:
		upgrade_levels["max_health"] = maxi(upgrade_level("max_health"), 1)
		purchased.erase("tough_body")
		save_game()
	master_volume_db = float(cfg.get_value("settings", "master_volume_db", 0.0))
	_apply_volume()


func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked_level", unlocked_level)
	cfg.set_value("progress", "total_coins", total_coins)
	cfg.set_value("progress", "best_scores", best_scores)
	cfg.set_value("progress", "survival_best_wave", survival_best_wave)
	cfg.set_value("shop", "purchased", purchased)
	cfg.set_value("shop", "upgrade_levels", upgrade_levels)
	cfg.set_value("settings", "master_volume_db", master_volume_db)
	cfg.save(_path)


## Bir bölüm tamamlanınca çağrılır.
func record_level_clear(index: int, run_coins: int, score: int) -> void:
	var next_max := mini(index + 1, GameState.level_count() - 1)
	unlocked_level = maxi(unlocked_level, next_max)
	total_coins += run_coins
	if score > int(best_scores.get(index, 0)):
		best_scores[index] = score
	save_game()


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


func wipe() -> void:
	unlocked_level = 0
	total_coins = 0
	best_scores = {}
	survival_best_wave = 0
	purchased = []
	upgrade_levels = {}
	save_game()


func _apply_volume() -> void:
	var bus := AudioServer.get_bus_index(&"Master")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, master_volume_db)
