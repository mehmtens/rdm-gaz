## Günün Dalgası (OYNANIS-KALITE P1-7): tarihten kararlı plan, seri hesabı, eski kayıt
## uyumu, puanlı ilk deneme (coin + tamamlama ödülü + seri) ve ödülsüz antrenman.
##
##  godot --headless --path . res://tests/daily_wave.tscn
extends Node

const PATH := "user://daily_wave_test.cfg"
const DAY := "2026-10-23"

var _fails := 0


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	_plans()
	_streak()
	_legacy_save()
	await _scored_run()
	await _practice_run()
	DailyWave.day_override = ""
	GameState.daily_run = false
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("DAILY WAVE: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _plans() -> void:
	var a := DailyWave.plan(DAY)
	_check(a == DailyWave.plan(DAY), "aynı gün aynı plan")
	_check(DailyWave.seed_for(DAY) == DailyWave.seed_for(DAY) and DailyWave.seed_for(DAY) > 0, "kararlı tohum")
	var rules := {}
	var distinct_waves := {}
	for d in 30:
		var day := "2026-11-%02d" % (d + 1)
		var p := DailyWave.plan(day)
		rules[p.rule.id] = true
		distinct_waves[str(p.waves)] = true
		_check(p.waves.size() == DailyWave.WAVES, "%s: 5 dalga" % day)
		for w in p.waves.size():
			var list: Array = p.waves[w]
			_check(list.size() >= 3 and list.size() <= DailyWave.MAX_PER_WAVE, "%s dalga %d sayısı %d" % [day, w + 1, list.size()])
			for id in list:
				_check(SurvivalMode.DAILY_SCENES.has(id), "bilinen düşman: %s" % id)
			_check(("miniboss" in list) == (w == DailyWave.WAVES - 1), "%s: boss yalnız son dalgada" % day)
		_check(not "elite" in p.waves[0] and not "bruiser" in p.waves[0], "%s: ilk dalga yumuşak" % day)
	_check(rules.size() >= 4, "30 günde en az 4 farklı kural: %d" % rules.size())
	_check(distinct_waves.size() >= 25, "günler farklı dizi üretmeli: %d" % distinct_waves.size())
	for r in DailyWave.RULES:
		_check(String(r.name).length() <= 18 and String(r.desc).length() <= 34, "kural metni kısa: %s" % r.id)


func _streak() -> void:
	_check(DailyWave.next_streak("2026-10-22", DAY, 3) == 4, "dün → seri +1")
	_check(DailyWave.next_streak("2026-10-20", DAY, 3) == 1, "boşluk → seri 1")
	_check(DailyWave.next_streak(DAY, DAY, 3) == 3, "aynı gün → seri aynı")
	_check(DailyWave.next_streak("", DAY, 0) == 1, "ilk gün → 1")
	_check(DailyWave.next_streak("2026-10-31", "2026-11-01", 5) == 6, "ay sınırı")
	_check(DailyWave.next_streak("2026-12-31", "2027-01-01", 2) == 3, "yıl sınırı")


func _legacy_save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "total_coins", 40)
	cfg.save(PATH)
	Save.load_game()
	_check(Save.daily_day == "" and Save.daily_waves == 0 and Save.daily_streak == 0, "eski kayıtta günlük alanlar boş")
	_check(not Save.daily_attempted(DAY), "eski kayıtta günün hakkı açık")
	_check(Save.total_coins == 40, "eski coin korunur")


## Survival sahnesini günlük modda açar, bütün dalgaları temizler; sahneyi döndürür.
func _play(clear: bool) -> SurvivalMode:
	DailyWave.day_override = DAY
	GameState.daily_run = true
	var s: SurvivalMode = (load("res://scenes/Survival.tscn") as PackedScene).instantiate()
	add_child(s)
	await get_tree().process_frame
	if not clear:
		return s
	Engine.time_scale = 6.0
	var frames := 0
	while not s._finished and not s._dead and frames < 6000:
		for c in s.get_children():
			if c is EnemyBase and c._state != EnemyBase.State.DEAD:
				c.apply_guard_break_hit(9999, Vector2.RIGHT, 0.0)
		await get_tree().process_frame
		frames += 1
	Engine.time_scale = 1.0
	return s


func _scored_run() -> void:
	Save.total_coins = 0
	Save.daily_clear_day = "2026-10-22"
	Save.daily_streak = 2
	var s := await _play(true)
	_check(s._daily and s._scored, "günün ilk denemesi puanlı")
	_check(s._finished, "beş dalga bitmeli (dalga %d)" % s._wave)
	var expected := DailyWave.CLEAR_BONUS
	for w in range(1, DailyWave.WAVES + 1):
		expected += SurvivalMode.reward_for_wave(w)
	_check(Save.total_coins == expected, "coin + tamamlama ödülü: %d / %d" % [Save.total_coins, expected])
	_check(Save.daily_day == DAY and Save.daily_waves == DailyWave.WAVES, "deneme kaydı")
	_check(Save.daily_clear_day == DAY and Save.daily_streak == 3, "seri ilerledi: %d" % Save.daily_streak)
	_check(s._defeated == _plan_total(), "plandaki bütün düşmanlar: %d" % s._defeated)
	_check(s._hud._results.visible and s._hud._results_title.text == "GÜNÜN DALGASI TAMAM", "sonuç kartı")
	_check(Save.survival_best_wave == 0, "günlük, survival rekorunu değiştirmez")
	Save.load_game()
	_check(Save.daily_streak == 3 and Save.daily_day == DAY, "kayıttan okunur")
	s.queue_free()
	await get_tree().process_frame


func _practice_run() -> void:
	var coins := Save.total_coins
	var s := await _play(true)
	_check(not s._scored, "ikinci deneme antrenman")
	_check(s._finished, "antrenman da bitebilmeli")
	_check(Save.total_coins == coins, "antrenman coin yazmaz: %d" % Save.total_coins)
	_check(Save.daily_streak == 3, "antrenman seriyi değiştirmez")
	s.queue_free()
	await get_tree().process_frame


func _plan_total() -> int:
	var n := 0
	for list in DailyWave.plan(DAY).waves:
		n += list.size()
	return n
