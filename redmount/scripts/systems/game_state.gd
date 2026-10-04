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
	"res://scenes/levels/Level01.tscn",
	"res://scenes/levels/Level06.tscn",
	"res://scenes/levels/Level07.tscn",
	"res://scenes/levels/Level02.tscn",
	"res://scenes/levels/Level08.tscn",
	"res://scenes/levels/Level03.tscn",
	"res://scenes/levels/Level09.tscn",
	"res://scenes/levels/Level10.tscn",
	"res://scenes/levels/Level04.tscn",
	"res://scenes/levels/Level11.tscn",
	"res://scenes/levels/Level12.tscn",
	"res://scenes/levels/Level05.tscn",
	"res://scenes/levels/Book02Level01.tscn",
	"res://scenes/levels/Book02Level02.tscn",
	"res://scenes/levels/Book02Level03.tscn",
	"res://scenes/levels/Book02Level04.tscn",
	"res://scenes/levels/Book02Level05.tscn",
	"res://scenes/levels/Book02Level06.tscn",
	"res://scenes/levels/Book02Level07.tscn",
	"res://scenes/levels/Book02Level08.tscn",
	"res://scenes/levels/Book02Level09.tscn",
	"res://scenes/levels/Book02Level10.tscn",
	"res://scenes/levels/Book02Level11.tscn",
	"res://scenes/levels/Book02Level12.tscn",
	"res://scenes/levels/Book03Level01.tscn",
	"res://scenes/levels/Book03Level02.tscn",
	"res://scenes/levels/Book03Level03.tscn",
	"res://scenes/levels/Book03Level04.tscn",
	"res://scenes/levels/Book03Level05.tscn",
	"res://scenes/levels/Book03Level06.tscn",
	"res://scenes/levels/Book03Level07.tscn",
	"res://scenes/levels/Book03Level08.tscn",
	"res://scenes/levels/Book03Level09.tscn",
	"res://scenes/levels/Book03Level10.tscn",
	"res://scenes/levels/Book03Level11.tscn",
	"res://scenes/levels/Book03Level12.tscn",
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


func level_path() -> String:
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
