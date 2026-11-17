## Ses havuzu önceliği ve aynı kare birleştirme (tur 265).
## Önemli ses (sancak) dolu havuzda düşük öncelikli sesle (coin) kesilmez; eşit öncelikli
## ses en eskiyi keser; aynı karede iki özdeş ses tek sese birleşir.
extends Node


func _ready() -> void:
	await get_tree().process_frame
	var ok := true
	for p in Sfx._pool:
		p.stop()
	# 1) Aynı kare birleştirme.
	var m0: int = Sfx.merged_count
	Sfx.play(&"heavy_hit")
	Sfx.play(&"heavy_hit")
	Sfx.play(&"heavy_hit")
	if Sfx.merged_count - m0 != 2:
		push_error("birleştirme beklenmedi: %d" % (Sfx.merged_count - m0)); ok = false
	await get_tree().process_frame
	for p in Sfx._pool:
		p.stop()
	# 2) Havuzu farklı karelerde 'goal' ile doldur.
	for i in Sfx.POOL_SIZE:
		Sfx.play(&"goal")
		await get_tree().process_frame
	var playing := 0
	for p in Sfx._pool:
		if p.playing: playing += 1
	if playing < Sfx.POOL_SIZE:
		print("SFX VOICES: SKIP (ses sürücüsü çalmayı tutmuyor, playing=%d)" % playing)
		get_tree().quit(0); return
	var d0: int = Sfx.dropped_count
	var s0: int = Sfx.stolen_count
	Sfx.play(&"coin")
	if Sfx.dropped_count - d0 != 1 or Sfx.stolen_count != s0:
		push_error("coin önemli sesi kesti"); ok = false
	Sfx.play(&"player_death")
	if Sfx.stolen_count - s0 != 1:
		push_error("eşit öncelikli ses yer bulamadı"); ok = false
	print("SFX VOICES: %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
