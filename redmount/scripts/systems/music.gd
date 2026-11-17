## Music — prosedürel chiptune müzik autoload (Görev 26).
##
## `assets/music/mus_*.wav` (Python'da sentezlendi, gen_music.py) döngüsel parçalar.
## İki AudioStreamPlayer arasında crossfade. project.godot -> [autoload] "Music".
## Menü tek parça (`menu`); her bölüm biome'una göre (`street/industrial/fortress/
## keep`); story-boss bölümü `boss`; final `victory` (döngüsüz sting).
extends Node

const DIR := "res://assets/music/"
## Parçaların çalınacağı temel ses düzeyi (SFX'in altında kalsın).
const BASE_DB := -6.0
const OFF_DB := -60.0
const FADE := 1.1

const BIOME_TRACK: PackedStringArray = ["street", "industrial", "fortress", "keep"]

var _cur: AudioStreamPlayer
var _idle: AudioStreamPlayer
var _current_name: String = ""
var _cache: Dictionary = {}

var _fading: bool = false
var _fade_t: float = 0.0
var _fade_dur: float = FADE
var _cur_from: float = OFF_DB
var _cur_to: float = BASE_DB
var _idle_from: float = OFF_DB
## Crossfade'in hesapladığı düzeyler; oyuncuya bunlara ducking eklenerek yazılır.
var _cur_lvl: float = OFF_DB
var _idle_lvl: float = OFF_DB
## Ducking (tur 268, ses denetimi): ölüm/hedef gibi büyük anlarda müzik kısa süre kısılır,
## olayın sesi öne çıkar. Gerçek zamanla çözülür (ölüm yavaşlatması süreyi uzatmasın).
var duck_db: float = 0.0
var _duck_depth: float = 0.0
var _duck_hold_until: int = 0
var _duck_release: float = 0.6
var _duck_last_ms: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cur = _make_player()
	_idle = _make_player()
	# Parçalar uzun (1-1,5 dk); ilk çalışta diskten okuma takılma yapmasın diye
	# hepsi arka planda önceden yüklenir.
	for n in ["street", "battle", "boss", "industrial", "fortress", "keep", "menu", "victory"]:
		var path: String = DIR + "mus_" + n + ".wav"
		if ResourceLoader.exists(path):
			ResourceLoader.load_threaded_request(path)


func _make_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = &"Master"
	p.volume_db = OFF_DB
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(p)
	return p


func _stream(name: String) -> AudioStream:
	if _cache.has(name):
		return _cache[name]
	var path := DIR + "mus_" + name + ".wav"
	if not ResourceLoader.exists(path):
		return null
	# Döngü `.import` içinde ayarlı (edit/loop_mode=1); burada ek iş yok.
	var s: AudioStream = load(path)
	# İçe aktarma ayarı kaybolsa bile bölüm parçaları kesintisiz döner.
	# (Kopyalamadan: 1 dakikalık parçayı çoğaltmak arena başında takılma yapıyordu.)
	if s is AudioStreamWAV and name != "victory":
		var w := s as AudioStreamWAV
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * w.mix_rate)
	_cache[name] = s
	return s


## Bölüm biome'una uygun döngüsel parça.
func play_for_biome(biome: int) -> void:
	play(BIOME_TRACK[clampi(biome, 0, BIOME_TRACK.size() - 1)])


## `name` parçasına geç (zaten çalıyorsa hiçbir şey yapma). `loop_it=false` → sting.
func play(name: String, fade: float = FADE) -> void:
	if name == _current_name and _cur.playing:
		return
	var s := _stream(name)
	if s == null:
		return
	_current_name = name
	var swap := _idle
	_idle = _cur
	_cur = swap
	_idle_lvl = _cur_lvl
	_cur.stream = s
	_cur_lvl = OFF_DB
	_cur.volume_db = OFF_DB
	_cur.play()
	_begin_fade(OFF_DB, BASE_DB, fade)


var _before_battle: String = ""


## Kilitli arena başladı: bölüm parçasını hatırla, dövüş parçasına geç.
func battle_start() -> void:
	if _current_name != "battle":
		_before_battle = _current_name
	play("battle", 0.45)


## Arena temizlendi: bölüm parçasına geri dön.
func battle_end() -> void:
	if _current_name != "battle":
		return
	play(_before_battle if _before_battle != "" else "street", 1.6)
	_before_battle = ""


## Müziği yavaşça sustur.
func stop(fade: float = FADE) -> void:
	if _current_name == "" and not _cur.playing and not _idle.playing:
		return
	_current_name = ""
	_begin_fade(clampf(_cur_lvl, OFF_DB, 0.0), OFF_DB, fade)


## Müziği `depth_db` kadar indir, `hold` sn tut, `release` sn'de geri getir. Üst üste gelen
## duck daha derinse onu alır; sığsa yalnız tutma süresini uzatır.
func duck(depth_db: float = -8.0, hold: float = 0.4, release: float = 0.6) -> void:
	var now := Time.get_ticks_msec()
	if depth_db < duck_db:
		duck_db = depth_db
	_duck_depth = minf(duck_db, -0.01)
	_duck_hold_until = maxi(_duck_hold_until, now + int(hold * 1000.0))
	_duck_release = maxf(release, 0.05)
	_duck_last_ms = now


func _begin_fade(cur_from: float, cur_to: float, fade: float) -> void:
	_cur_from = cur_from
	_cur_to = cur_to
	_idle_from = clampf(_idle_lvl, OFF_DB, 0.0)
	_fade_t = 0.0
	_fade_dur = maxf(fade, 0.05)
	_fading = true


func _process(delta: float) -> void:
	# Ses aygıtı yenilenmesi gibi bir nedenle akış durursa kaldığı parçayı başlat.
	if _current_name != "" and _cur.stream != null and not _cur.playing:
		_cur.play()
	_update_duck()
	if _fading:
		_fade_t += delta
		var k := clampf(_fade_t / _fade_dur, 0.0, 1.0)
		_cur_lvl = lerpf(_cur_from, _cur_to, k)
		_idle_lvl = lerpf(_idle_from, OFF_DB, k)
		if k >= 1.0:
			_fading = false
			_idle.stop()
			if _cur_to <= OFF_DB:
				_cur.stop()
	_cur.volume_db = maxf(OFF_DB, _cur_lvl + duck_db)
	_idle.volume_db = maxf(OFF_DB, _idle_lvl + duck_db)


func _update_duck() -> void:
	if duck_db >= 0.0:
		return
	var now := Time.get_ticks_msec()
	var dt := float(now - _duck_last_ms) / 1000.0
	_duck_last_ms = now
	if now < _duck_hold_until:
		return
	duck_db = minf(0.0, duck_db - _duck_depth * dt / _duck_release)


func _exit_tree() -> void:
	for p in [_cur, _idle]:
		if is_instance_valid(p):
			p.stop()
			p.stream = null
	_cache.clear()
