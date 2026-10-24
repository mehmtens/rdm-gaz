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
	_new_rules()
	_streak_rewards()
	_rotation()
	_broken_streak()
	await _broken_badge()
	_rescue_rules()
	await _rescue_menu()
	await _speed_rule()
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
			_check((list.size() >= 3 or list == ["miniboss"]) and list.size() <= DailyWave.MAX_PER_WAVE, "%s dalga %d sayısı %d" % [day, w + 1, list.size()])
			for id in list:
				_check(SurvivalMode.DAILY_SCENES.has(id), "bilinen düşman: %s" % id)
			var boss_here: bool = w == DailyWave.WAVES - 1 or w + 1 == int(p.rule.get("boss_at", 0))
			_check(("miniboss" in list) == boss_here, "%s: boss yalnız son (ya da kuralın) dalgada" % day)
		_check(not "elite" in p.waves[0] and not "bruiser" in p.waves[0], "%s: ilk dalga yumuşak" % day)
	_check(rules.size() >= 5, "30 günde en az 4 farklı kural: %d" % rules.size())
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


## İkinci dilim kuralları: bir yıl içinde her kural en az bir gün çıkmalı, vaatleri planda görünmeli.
func _new_rules() -> void:
	var seen := {}
	for d in 365:
		var day := Time.get_date_string_from_unix_time(1767225600 + d * 86400)
		var p := DailyWave.plan(day)
		seen[p.rule.id] = true
		var must := String(p.rule.get("must", ""))
		for w in range(1, DailyWave.WAVES - 1):
			if not must.is_empty() and not "miniboss" in p.waves[w]:
				_check(must in p.waves[w], "%s: %s her dalgada" % [day, must])
		if p.rule.id == "erken":
			_check(p.waves[2] == ["miniboss"], "%s: erken patron 3. dalgada tek başına" % day)
	for r in DailyWave.RULES:
		_check(seen.has(r.id), "bir yılda çıkan kural: %s" % r.id)


func _streak_rewards() -> void:
	_check(DailyWave.streak_reward(2) == 0 and DailyWave.streak_reward(3) == 40, "3. gün ödülü")
	_check(DailyWave.streak_reward(7) == 100 and DailyWave.streak_reward(14) == 200, "7/14. gün ödülü")
	_check(DailyWave.streak_reward(21) == DailyWave.STREAK_REPEAT and DailyWave.streak_reward(15) == 0, "14 sonrası her 7 gün")
	_check(DailyWave.next_streak_reward(3) == [7, 100] and DailyWave.next_streak_reward(14) == [21, 100], "sıradaki ödül")
	_check(DailyWave.streak_alive("2026-10-22", DAY) and DailyWave.streak_alive(DAY, DAY), "dün/bugün seri canlı")
	_check(not DailyWave.streak_alive("2026-10-20", DAY) and not DailyWave.streak_alive("", DAY), "boşlukta seri ölü")
	# Aynı gün ikinci finish_daily ödülü tekrar vermez.
	Save.total_coins = 0
	Save.daily_clear_day = "2026-10-22"
	Save.daily_streak = 6
	_check(Save.finish_daily(DAY, 10, true) == 100 and Save.total_coins == 110, "7. gün +100")
	_check(Save.finish_daily(DAY, 0, true) == 0 and Save.total_coins == 110, "aynı gün ödül tekrarlanmaz")
	_check(Save.finish_daily("2026-10-24", 0, false) == 0 and Save.daily_streak == 7, "temizlenmeyen gün seri vermez")
	Save.wipe()


## Üçüncü dilim: bir yılda her kural eşit çıkar (±1 blok), art arda aynı kural yok.
func _rotation() -> void:
	var counts := {}
	var prev := ""
	var repeats := 0
	for d in 365:
		var day := Time.get_date_string_from_unix_time(1767225600 + d * 86400)
		var id := String(DailyWave.plan(day).rule.id)
		counts[id] = int(counts.get(id, 0)) + 1
		if id == prev:
			repeats += 1
		prev = id
	var lo := 999
	var hi := 0
	for r in DailyWave.RULES:
		lo = mini(lo, int(counts.get(r.id, 0)))
		hi = maxi(hi, int(counts.get(r.id, 0)))
	_check(hi - lo <= 2, "bir yılda kural dağılımı eşit: %d..%d" % [lo, hi])
	_check(repeats == 0, "art arda aynı kural: %d" % repeats)
	# Her 9 günlük blokta her kural tam bir kez.
	var n0 := int(Time.get_unix_time_from_datetime_string("2026-10-23T12:00:00") / 86400)
	var start := (floori(float(n0) / DailyWave.RULES.size()) + 1) * DailyWave.RULES.size()
	var block := {}
	for i in DailyWave.RULES.size():
		var day := Time.get_date_string_from_unix_time((start + i) * 86400)
		block[DailyWave.rule_index(day)] = true
	_check(block.size() == DailyWave.RULES.size(), "blokta her kural bir kez: %d" % block.size())


func _broken_streak() -> void:
	_check(not DailyWave.streak_broken("2026-10-22", DAY, 5), "dün temizlendi → kopmadı")
	_check(not DailyWave.streak_broken(DAY, DAY, 5), "bugün temizlendi → kopmadı")
	_check(DailyWave.streak_broken("2026-10-21", DAY, 5), "dün kaçtı → koptu")
	_check(DailyWave.streak_broken("2026-10-15", DAY, 5), "8 gün önce → hâlâ uyarı")
	_check(not DailyWave.streak_broken("2026-10-01", DAY, 5), "uzun ara → uyarı yok")
	_check(not DailyWave.streak_broken("2026-10-21", DAY, 0) and not DailyWave.streak_broken("", DAY, 3), "seri yoksa uyarı yok")


## Menü rozeti: canlı seride altın ödül satırı, kopan seride uyarı, hiç seri yoksa rozet yok.
func _broken_badge() -> void:
	DailyWave.day_override = DAY
	var cases := [["2026-10-22", 4, "SERİ 4 GÜN"], ["2026-10-20", 4, "SERİ KOPTU (4 GÜN)"], ["", 0, ""]]
	for c in cases:
		Save.daily_clear_day = c[0]
		Save.daily_streak = c[1]
		var menu: Node = (load("res://scenes/MainMenu.tscn") as PackedScene).instantiate()
		add_child(menu)
		await get_tree().process_frame
		var badge := menu.find_child("StreakBadge", true, false)
		if String(c[2]).is_empty():
			_check(badge == null, "seri yokken rozet yok")
		else:
			_check(badge != null and String((badge.get_child(0) as Label).text).begins_with(c[2]), "rozet metni: %s" % c[2])
		menu.queue_free()
		await get_tree().process_frame
	DailyWave.day_override = ""
	Save.wipe()


## Seri koruma: yalnız dün kaçtıysa, haftada bir, coin karşılığı; bugün temizlenince seri sürer.
func _rescue_rules() -> void:
	_check(DailyWave.yesterday(DAY) == "2026-10-22" and DailyWave.yesterday("2027-01-01") == "2026-12-31", "dün hesabı")
	_check(DailyWave.rescue_available("2026-10-21", DAY, 5, ""), "dün kaçtı → kurtarılabilir")
	_check(not DailyWave.rescue_available("2026-10-20", DAY, 5, ""), "iki gün kaçtı → kurtarma yok")
	_check(not DailyWave.rescue_available("2026-10-22", DAY, 5, ""), "seri canlı → kurtarma yok")
	_check(not DailyWave.rescue_available("2026-10-21", DAY, 0, ""), "seri yok → kurtarma yok")
	_check(not DailyWave.rescue_available("2026-10-21", DAY, 5, "2026-10-18"), "5 gün önce kurtarıldı → yok")
	_check(DailyWave.rescue_available("2026-10-21", DAY, 5, "2026-10-16"), "7 gün sonra yeniden")
	Save.wipe()
	Save.daily_clear_day = "2026-10-21"
	Save.daily_streak = 6
	Save.total_coins = DailyWave.RESCUE_COST - 1
	_check(not Save.rescue_daily(DAY) and Save.daily_clear_day == "2026-10-21", "coin yetmez → kurtarma yok")
	Save.total_coins = DailyWave.RESCUE_COST + 20
	_check(Save.rescue_daily(DAY), "kurtarma yapıldı")
	_check(Save.total_coins == 20 and Save.daily_clear_day == "2026-10-22" and Save.daily_streak == 6, "coin düştü, dün köprülendi, seri aynı")
	_check(Save.daily_rescue_day == DAY and not Save.can_rescue_daily(DAY), "aynı gün ikinci kurtarma yok")
	Save.load_game()
	_check(Save.daily_rescue_day == DAY and Save.daily_clear_day == "2026-10-22", "kurtarma kayıttan okunur")
	_check(Save.finish_daily(DAY, 0, true) == DailyWave.streak_reward(7) and Save.daily_streak == 7, "kurtarılan seri bugün 7'ye çıkar")
	Save.wipe()
	Save.daily_clear_day = "2026-10-21"
	Save.daily_streak = 6
	Save.total_coins = 500
	Save.begin_daily(DAY)
	_check(not Save.can_rescue_daily(DAY), "bugün denendiyse kurtarma yok")
	Save.wipe()


## Menüde kurtarma düğmesi: basınca coin düşer, rozet canlı seriye döner, düğme kalkar.
func _rescue_menu() -> void:
	DailyWave.day_override = DAY
	Save.daily_clear_day = "2026-10-21"
	Save.daily_streak = 6
	Save.total_coins = 30
	var menu: Node = (load("res://scenes/MainMenu.tscn") as PackedScene).instantiate()
	add_child(menu)
	await get_tree().process_frame
	var btn := menu.find_child("StreakRescue", true, false) as Button
	_check(btn != null and btn.disabled, "coin yetmezken düğme kapalı")
	menu.queue_free()
	await get_tree().process_frame
	Save.total_coins = 100
	menu = (load("res://scenes/MainMenu.tscn") as PackedScene).instantiate()
	add_child(menu)
	await get_tree().process_frame
	btn = menu.find_child("StreakRescue", true, false) as Button
	_check(btn != null and not btn.disabled, "kurtarma düğmesi açık")
	var badge := menu.find_child("StreakBadge", true, false)
	_check(badge != null and "dünü kurtar" in String((badge.get_child(0) as Label).text), "rozet kurtarmayı söylüyor")
	if btn != null:
		btn.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	_check(Save.total_coins == 100 - DailyWave.RESCUE_COST, "menüden kurtarma coin düşürdü")
	_check(menu.find_child("StreakRescue", true, false) == null, "kurtarma sonrası düğme yok")
	badge = menu.find_child("StreakBadge", true, false)
	_check(badge != null and String((badge.get_child(0) as Label).text).begins_with("SERİ 6 GÜN"), "rozet canlı seriye döndü")
	menu.queue_free()
	await get_tree().process_frame
	DailyWave.day_override = ""
	Save.wipe()


## HIZLI ADIM: günlük koşuda düşman hızlanır, paylaşılan .tres değişmez.
func _speed_rule() -> void:
	var day := ""
	for d in 365:
		var cand := Time.get_date_string_from_unix_time(1767225600 + d * 86400)
		if DailyWave.plan(cand).rule.id == "hizli":
			day = cand
			break
	DailyWave.day_override = day
	GameState.daily_run = true
	var thug: Node = (load("res://scenes/enemies/StreetThug.tscn") as PackedScene).instantiate()
	var base: EnemyConfig = thug.config
	thug.free()
	var shared_speed := base.move_speed
	var s: SurvivalMode = (load("res://scenes/Survival.tscn") as PackedScene).instantiate()
	add_child(s)
	await get_tree().process_frame
	var fast := 0
	for c in s.get_children():
		if c is EnemyBase:
			var probe: Node = (load(c.scene_file_path) as PackedScene).instantiate()
			var ref: EnemyConfig = probe.config
			probe.free()
			_check(is_equal_approx(c.config.move_speed, ref.move_speed * 1.3), "hızlı düşman: %s" % c.name)
			fast += 1
	_check(fast > 0, "hızlı günde düşman doğdu")
	_check(is_equal_approx(base.move_speed, shared_speed), "paylaşılan config değişmedi")
	s.queue_free()
	await get_tree().process_frame
	Save.wipe()


func _legacy_save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "total_coins", 40)
	cfg.save(PATH)
	Save.load_game()
	_check(Save.daily_day == "" and Save.daily_waves == 0 and Save.daily_streak == 0, "eski kayıtta günlük alanlar boş")
	_check(not Save.daily_attempted(DAY), "eski kayıtta günün hakkı açık")
	_check(Save.total_coins == 40, "eski coin korunur")
	_check(Save.daily_rescue_day == "", "eski kayıtta kurtarma günü boş")


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
	# Seri 2 → 3: üçüncü gün seri ödülü de eklenir.
	var expected := DailyWave.CLEAR_BONUS + DailyWave.streak_reward(3)
	for w in range(1, DailyWave.WAVES + 1):
		expected += SurvivalMode.reward_for_wave(w)
	_check(Save.total_coins == expected, "coin + tamamlama ödülü: %d / %d" % [Save.total_coins, expected])
	_check(Save.daily_day == DAY and Save.daily_waves == DailyWave.WAVES, "deneme kaydı")
	_check(Save.daily_clear_day == DAY and Save.daily_streak == 3, "seri ilerledi: %d" % Save.daily_streak)
	_check(s._defeated == _plan_total(), "plandaki bütün düşmanlar: %d" % s._defeated)
	_check(s._hud._results.visible and s._hud._results_title.text == "GÜNÜN DALGASI TAMAM", "sonuç kartı")
	_check(s._streak_reward == 40 and "SERİ ÖDÜLÜ +40" in s._hud._results_stats.text, "sonuç kartında seri ödülü")
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
