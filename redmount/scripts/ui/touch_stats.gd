class_name TouchStats
extends RefCounted
## Dokunma ölçümü (insan testi): oyun sırasında her basışı düğme düzeniyle karşılaştırır,
## bölüm sonunda tek satır CSV yazar. Videodan elle saymanın yerine geçer.
##  boş      = hiçbir görünür düğmenin dokunma alanına değmeyen basış;
##  kaçan    = boş basışın en yakın düğme kenarına o düğmenin yarıçapının NEAR_MISS katı
##             kadar yakın olanı (parmak düğmeyi ıskaladı) — en yakın düğmeye yazılır;
##  düzeltme = bir oyun düğmesine kısa basıp (< QUICK_TAP_MS) bırakır bırakmaz
##             (< FIX_GAP_MS) komşu düğmeye geçmek ("ZIPLA yerine VUR'a bastım").
## Sayılar hipotez: 0,6 yarıçap ≈ büyük düğmede 40 sanal piksel (başparmak kayması);
## 150 ms bilinçli dokunuşun alt ucu, 250 ms fark edip düzeltme tepkisi.

const NEAR_MISS := 0.6
const QUICK_TAP_MS := 150
const FIX_GAP_MS := 250
const LOG_PATH := "user://dokunma_olcum.csv"
const HEADER := "tarih;sahne;bolum;sure_sn;basis;bos;kacan;duzeltme;kacan_ayrinti;duzeltme_ayrinti"

var log_path := LOG_PATH
## eylem -> basış sayısı
var presses: Dictionary = {}
var empty := 0
## en yakın eylem -> kaçan basış sayısı
var near: Dictionary = {}
## "ZIPLA>VUR" -> sayı
var fixes: Dictionary = {}
var started_ms := 0
var _down_ms: Dictionary = {}
var _quick_key := ""
var _quick_ms := -100000


func reset(now_ms: int) -> void:
	presses.clear()
	near.clear()
	fixes.clear()
	_down_ms.clear()
	empty = 0
	started_ms = now_ms
	_quick_key = ""
	_quick_ms = -100000


## Düğmeye değmeyen basış mı? circles: [[eylem, merkez, yarıçap], ...] (görünür düğmeler,
## ekran birimiyle; yarıçap gerçek dokunma şeklinin yarıçapı).
func on_touch(pos: Vector2, circles: Array) -> void:
	var best_key := ""
	var best_gap := INF
	var best_radius := 1.0
	for c in circles:
		var gap: float = pos.distance_to(c[1]) - float(c[2])
		if gap <= 0.0:
			return  # düğmeye değdi; basışı düğmenin kendi sinyali sayar
		if gap < best_gap:
			best_gap = gap
			best_key = c[0]
			best_radius = c[2]
	empty += 1
	if best_key != "" and best_gap <= best_radius * NEAR_MISS:
		near[best_key] = int(near.get(best_key, 0)) + 1


## neighbors: eylem -> komşu eylemler (düzeltme yalnız komşular arasında sayılır).
func on_press(key: String, now_ms: int, neighbors: Dictionary) -> void:
	presses[key] = int(presses.get(key, 0)) + 1
	_down_ms[key] = now_ms
	if _quick_key != "" and _quick_key != key and now_ms - _quick_ms <= FIX_GAP_MS \
			and key in neighbors.get(_quick_key, []):
		var pair := "%s>%s" % [_quick_key, key]
		fixes[pair] = int(fixes.get(pair, 0)) + 1
		_quick_key = ""


func on_release(key: String, now_ms: int) -> void:
	if not _down_ms.has(key):
		return
	if now_ms - int(_down_ms[key]) < QUICK_TAP_MS:
		_quick_key = key
		_quick_ms = now_ms
	_down_ms.erase(key)


func total_presses() -> int:
	var n := 0
	for k in presses:
		n += int(presses[k])
	return n


func total_near() -> int:
	var n := 0
	for k in near:
		n += int(near[k])
	return n


func total_fixes() -> int:
	var n := 0
	for k in fixes:
		n += int(fixes[k])
	return n


func is_empty() -> bool:
	return total_presses() == 0 and empty == 0


static func _detail(d: Dictionary) -> String:
	var parts: PackedStringArray = []
	var keys := d.keys()
	keys.sort()
	for k in keys:
		parts.append("%s %d" % [k, d[k]])
	return ", ".join(parts)


## Konsol (Android'de logcat) için tek satır özet.
func summary(scene: String, level: int, now_ms: int) -> String:
	return "DOKUNMA %s bölüm %d: %d sn, %d basış, %d boş, %d kaçan (%s), %d düzeltme (%s)" % [
		scene, level, (now_ms - started_ms) / 1000, total_presses(), empty,
		total_near(), _detail(near), total_fixes(), _detail(fixes)]


## Kaydı CSV'ye ekler (dosya yoksa başlıkla açılır) ve sayaçları sıfırlar.
## Boş kesit yazılmaz. Dönüş: yazılan satır ("" = yazılmadı).
func flush(scene: String, level: int, now_ms: int) -> String:
	if is_empty():
		reset(now_ms)
		return ""
	var line := "%s;%s;%d;%d;%d;%d;%d;%d;%s;%s" % [
		Time.get_datetime_string_from_system(false, true), scene, level,
		(now_ms - started_ms) / 1000, total_presses(), empty, total_near(), total_fixes(),
		_detail(near), _detail(fixes)]
	print(summary(scene, level, now_ms))
	var exists := FileAccess.file_exists(log_path)
	var f := FileAccess.open(log_path, FileAccess.READ_WRITE if exists else FileAccess.WRITE)
	if f:
		if exists:
			f.seek_end()
		else:
			f.store_line(HEADER)
		f.store_line(line)
		f.close()
	reset(now_ms)
	return line
