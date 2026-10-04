## Music — prosedürel chiptune müzik autoload (Görev 26).
##
## `assets/music/mus_*.wav` (Python'da sentezlendi, gen_music.py) döngüsel parçalar.
## İki AudioStreamPlayer arasında crossfade. project.godot -> [autoload] "Music".
## Menü tek parça (`menu`); her bölüm biome'una göre (`street/industrial/fortress/
## keep`); story-boss bölümü `boss`; final `victory` (döngüsüz sting).
extends Node

const DIR := "res://assets/music/"
## Parçaların çalınacağı temel ses düzeyi (SFX'in altında kalsın).
const BASE_DB := -9.0
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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cur = _make_player()
	_idle = _make_player()


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
	if s is AudioStreamWAV and name != "victory":
		s = s.duplicate()
		(s as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
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
	_cur.stream = s
	_cur.volume_db = OFF_DB
	_cur.play()
	_begin_fade(OFF_DB, BASE_DB, fade)


## Müziği yavaşça sustur.
func stop(fade: float = FADE) -> void:
	if _current_name == "" and not _cur.playing and not _idle.playing:
		return
	_current_name = ""
	_begin_fade(clampf(_cur.volume_db, OFF_DB, 0.0), OFF_DB, fade)


func _begin_fade(cur_from: float, cur_to: float, fade: float) -> void:
	_cur_from = cur_from
	_cur_to = cur_to
	_idle_from = clampf(_idle.volume_db, OFF_DB, 0.0)
	_fade_t = 0.0
	_fade_dur = maxf(fade, 0.05)
	_fading = true


func _process(delta: float) -> void:
	# Ses aygıtı yenilenmesi gibi bir nedenle akış durursa kaldığı parçayı başlat.
	if _current_name != "" and _cur.stream != null and not _cur.playing:
		_cur.play()
	if not _fading:
		return
	_fade_t += delta
	var k := clampf(_fade_t / _fade_dur, 0.0, 1.0)
	_cur.volume_db = lerpf(_cur_from, _cur_to, k)
	_idle.volume_db = lerpf(_idle_from, OFF_DB, k)
	if k >= 1.0:
		_fading = false
		_idle.stop()
		if _cur_to <= OFF_DB:
			_cur.stop()


func _exit_tree() -> void:
	for p in [_cur, _idle]:
		if is_instance_valid(p):
			p.stop()
			p.stream = null
	_cache.clear()
