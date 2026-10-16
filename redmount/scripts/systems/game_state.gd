## GameState — koşu (run) durumu autoload'u (Görev 4 + Görev 11).
##
## Coin / skor + bölüm ilerleyişi. Kalıcı kayıt (save/load) ve mağaza sonra.
## project.godot -> [autoload] altında "GameState".
extends Node

signal coins_changed(total: int)
signal score_changed(total: int)
signal level_changed(index: int, total: int)

## Kitap 1 ve Kitap 2'nin on ikişer bölümü; Kitap 3 bölümleri.
## Mevcut büyük prototip bölümleri, yeni hikâye blockout'larıyla dönüşümlü kullanılır;
## böylece her perde iki yükseliş bölümü ve bir kırılma/final bölümü taşır.
const LEVELS: PackedStringArray = [
	"res://scenes/levels/Bolum01.tscn",
	"res://scenes/levels/Bolum02.tscn",
	"res://scenes/levels/Bolum03.tscn",
	"res://scenes/levels/Bolum04.tscn",
	"res://scenes/levels/Bolum05.tscn",
	"res://scenes/levels/Bolum06.tscn",
	"res://scenes/levels/Bolum07.tscn",
	"res://scenes/levels/Bolum08.tscn",
	"res://scenes/levels/Bolum09.tscn",
	"res://scenes/levels/Bolum10.tscn",
	"res://scenes/levels/Bolum11.tscn",
	"res://scenes/levels/Bolum12.tscn",
	"res://scenes/levels/Bolum13.tscn",
	"res://scenes/levels/Bolum14.tscn",
	"res://scenes/levels/Bolum15.tscn",
	"res://scenes/levels/Bolum16.tscn",
	"res://scenes/levels/Bolum17.tscn",
	"res://scenes/levels/Bolum18.tscn",
	"res://scenes/levels/Bolum19.tscn",
	"res://scenes/levels/Bolum20.tscn",
	"res://scenes/levels/Bolum21.tscn",
	"res://scenes/levels/Bolum22.tscn",
	"res://scenes/levels/Bolum23.tscn",
	"res://scenes/levels/Bolum24.tscn",
	"res://scenes/levels/Bolum25.tscn",
	"res://scenes/levels/Bolum26.tscn",
	"res://scenes/levels/Bolum27.tscn",
	"res://scenes/levels/Bolum28.tscn",
	"res://scenes/levels/Bolum29.tscn",
	"res://scenes/levels/Bolum30.tscn",
	"res://scenes/levels/Bolum31.tscn",
	"res://scenes/levels/Bolum32.tscn",
	"res://scenes/levels/Bolum33.tscn",
	"res://scenes/levels/Bolum34.tscn",
	"res://scenes/levels/Bolum35.tscn",
	"res://scenes/levels/Bolum36.tscn",
]

const ACT_NAMES: PackedStringArray = [
	"Şehrin Nabzı", "Demir Hat", "Soğuk Yamaç", "İç Kale", "Haliç'in İzi", "Kayıt Zinciri", "Külhanın İzi", "Su Hattı", "İlk Baskın", "Yedek Hat", "Boğaz'ın İzi", "İstanbul'un Sesi",
]

var coins: int = 0
var score: int = 0
var level_index: int = 0
## Mağaza "çift coin" yükseltmesi (Main koşu başında ayarlar).
var coin_multiplier: int = 1
## Bölüm başı hikâye kartı + bitiş konuşması. Menüden başlatılan oyunda açılır;
## Main'i doğrudan kuran test botları kapalı bırakır.
var story_scenes: bool = false
## Toplanan coin ADEDİ (değeri değil) — rank ekranı toplama oranı için.
var coin_pickups: int = 0


func add_coins(amount: int) -> void:
	var gained := amount * coin_multiplier
	coins += gained
	score += gained
	coin_pickups += 1
	coins_changed.emit(coins)
	score_changed.emit(score)


func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


func spend_coins(amount: int) -> bool:
	if amount < 0 or coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	return true


func level_count() -> int:
	return LEVELS.size()


func act_index(for_level: int = level_index) -> int:
	return clampi(floori(float(for_level) / 3.0), 0, ACT_NAMES.size() - 1)


func act_name(for_level: int = level_index) -> String:
	return ACT_NAMES[act_index(for_level)]


## Test/geliştirme: boş değilse kampanya sırası yerine bu sahne yüklenir.
var level_path_override: String = ""


func level_path() -> String:
	if not level_path_override.is_empty():
		return level_path_override
	return LEVELS[clampi(level_index, 0, LEVELS.size() - 1)]


func has_next_level() -> bool:
	return level_index < LEVELS.size() - 1


## Bir sonraki bölüme geç. Son bölümdeyse false döner.
func advance_level() -> bool:
	if not has_next_level():
		return false
	level_index += 1
	level_changed.emit(level_index, LEVELS.size())
	return true


## Koşu sayaçlarını sıfırla (bölüm indeksine dokunma — onu menü belirler).
func start_run() -> void:
	coins = 0
	score = 0
	coin_pickups = 0
	coins_changed.emit(coins)
	score_changed.emit(score)
	level_changed.emit(level_index, LEVELS.size())


## Tüm koşuyu Bölüm 1'den baştan başlat.
func reset_run() -> void:
	level_index = 0
	start_run()
