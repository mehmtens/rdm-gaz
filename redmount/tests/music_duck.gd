## Müzik ducking (tur 268): ölüm sesiyle müzik ~10 dB iner, sonra kendiliğinden geri gelir;
## crossfade ducking'den bağımsız sürer.
extends Node

var _fails := 0


func _ready() -> void:
	Music.play("street", 0.05)
	await get_tree().create_timer(0.2).timeout
	_check(absf(Music._cur.volume_db - Music.BASE_DB) < 0.3, "parça taban düzeyde (%.1f)" % Music._cur.volume_db)
	Sfx.play(&"player_death")
	await get_tree().process_frame
	await get_tree().process_frame
	_check(absf(Music._cur.volume_db - (Music.BASE_DB - 10.0)) < 0.5, "ölümde müzik iner (%.1f)" % Music._cur.volume_db)
	await get_tree().create_timer(1.6).timeout
	_check(absf(Music._cur.volume_db - Music.BASE_DB) < 0.3, "müzik geri gelir (%.1f)" % Music._cur.volume_db)
	# Duck sırasında parça değişimi: yeni parça yine tabana oturur.
	Sfx.play(&"goal")
	Music.play("battle", 0.1)
	await get_tree().create_timer(1.4).timeout
	_check(absf(Music._cur.volume_db - Music.BASE_DB) < 0.3, "duck + crossfade sonrası taban (%.1f)" % Music._cur.volume_db)
	_check(not Music._idle.playing, "eski parça durdu")
	print("MUSIC DUCK: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
