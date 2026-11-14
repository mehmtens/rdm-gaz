## Ağır çekim bitişi (tur 182): Combat.slowmo() süresi dolunca Engine.time_scale
## 1.0'a dönmeli — duvar saati zamanlayıcıdan geride kalsa bile. `--fixed-fps 60`
## headless koşuda kareler gerçek zamandan hızlı akar; eski duvar saati kontrolü
## burada ölçeği 0,45'te bırakıyordu.
##   timeout 60 "$G" --headless --path . --fixed-fps 60 res://tests/slowmo_bitis.tscn
extends Node

var _fail := 0


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fail += 1
		print("  BASARISIZ: ", msg, " (time_scale=", Engine.time_scale, ")")


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _ready() -> void:
	# 1) Tek ağır çekim: süre dolunca tam hız.
	Combat.slowmo(0.45, 0.5)
	_check(is_equal_approx(Engine.time_scale, 0.45), "slowmo başında ölçek 0,45 olmalı")
	await _frames(60)
	_check(is_equal_approx(Engine.time_scale, 1.0), "slowmo bitince ölçek 1,0 olmalı")

	# 2) Üst üste iki ağır çekim: ilkinin zamanlayıcısı ikinciyi erken bitirmesin.
	Combat.slowmo(0.45, 0.5)
	await _frames(15)
	Combat.slowmo(0.3, 0.5)
	await _frames(20)  # ilk zamanlayıcı doldu, ikinci sürüyor
	_check(is_equal_approx(Engine.time_scale, 0.3), "ikinci slowmo sürerken ölçek 0,3 kalmalı")
	await _frames(30)
	_check(is_equal_approx(Engine.time_scale, 1.0), "ikinci slowmo bitince ölçek 1,0 olmalı")

	# 3) Ağır çekim içinde hitstop: donma bitince ağır çekime, o da bitince tam hıza.
	Combat.slowmo(0.45, 0.6)
	await _frames(3)
	Combat.hitstop(0.03)
	_check(Engine.time_scale == 0.0, "hitstop sırasında ölçek 0 olmalı")
	# Hitstop gerçek (duvar) saatle biter; hızlı headless karelerde kare sayısı değil süre bekle.
	var t0 := Time.get_ticks_msec()
	while Combat._hitstop_running and Time.get_ticks_msec() - t0 < 2000:
		await get_tree().process_frame
	# Donma süresinde ağır çekim zamanlayıcısı da dolmuş olabilir (hızlı kareler):
	# o zaman doğru hedef tam hızdır.
	var hedef := 0.45 if Combat._slow_active else 1.0
	_check(is_equal_approx(Engine.time_scale, hedef), "hitstop bitince ağır çekime (ya da bittiyse tam hıza) dönmeli")
	await _frames(60)
	_check(is_equal_approx(Engine.time_scale, 1.0), "ağır çekim bitince ölçek 1,0 olmalı")

	if _fail == 0:
		print("SLOWMO BITIS: PASS")
	else:
		print("SLOWMO BITIS: FAIL (", _fail, ")")
	get_tree().quit(1 if _fail > 0 else 0)
