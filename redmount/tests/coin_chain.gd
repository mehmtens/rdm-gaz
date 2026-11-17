## Coin zinciri perdesi (tur 265): pencere içinde yükselir, tepede kalır, aradan sonra sıfırlanır.
extends Node


func _ready() -> void:
	var C: Script = load("res://scripts/pickups/coin_pickup.gd")
	var ok := true
	var t := 1000000
	var prev := 0.0
	var p := 0.0
	for i in 8:
		p = C.chain_pitch(t + i * 200)
		if i > 0 and p <= prev:
			push_error("zincir yükselmedi: %d" % i); ok = false
		prev = p
	if not is_equal_approx(p, 2.0):
		push_error("tepe bir oktav değil: %f" % p); ok = false
	if not is_equal_approx(C.chain_pitch(t + 1600), 2.0):
		push_error("tepede kalmadı"); ok = false
	if not is_equal_approx(C.chain_pitch(t + 3000), 1.0):
		push_error("aradan sonra sıfırlanmadı"); ok = false
	print("COIN CHAIN: %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
