## Ses düzeyi dengesi (tur 287). Ham WAV'lardan 50 ms en yüksek pencere RMS'i ölçülür, `Sfx.TRIM` +
## `Sfx.HEADROOM` eklenir. Korunan kurallar: menü sesleri kısık→belirgin sırada (odak < seçim, ret seçimden
## en çok 2 dB yüksek); oyuncunun silah kaybı aynı öncelikteki zırh kırılmasından alçak değil ve müziğin
## sürekli düzeyinin en az 6 dB üstünde.
extends Node

const MUSIC_DB := -24.0


func _level(name: String, extra_db: float = 0.0) -> float:
	var f := FileAccess.open("res://assets/audio/%s.wav" % name, FileAccess.READ)
	if f == null:
		return -999.0
	var buf := f.get_buffer(f.get_length())
	## RIFF parçaları içinde "fmt " ve "data" ara.
	var pos := 12
	var channels := 1
	var rate := 22050
	var bits := 16
	var data := PackedByteArray()
	while pos + 8 <= buf.size():
		var id := buf.slice(pos, pos + 4).get_string_from_ascii()
		var sz := buf.decode_u32(pos + 4)
		if id == "fmt ":
			channels = buf.decode_u16(pos + 10)
			rate = buf.decode_u32(pos + 12)
			bits = buf.decode_u16(pos + 22)
		elif id == "data":
			data = buf.slice(pos + 8, pos + 8 + sz)
		pos += 8 + sz + (sz & 1)
	if bits != 16 or data.is_empty():
		return -999.0
	var step := 2 * channels
	var n := data.size() / step
	var win := int(rate * 0.05)
	var best := 0.0
	var i := 0
	while i < maxi(1, n - win):
		var acc := 0.0
		var cnt := 0
		for k in range(i, mini(n, i + win)):
			var v := float(data.decode_s16(k * step)) / 32768.0
			acc += v * v
			cnt += 1
		best = maxf(best, sqrt(acc / maxf(1.0, float(cnt))))
		i += win / 4
	return linear_to_db(best) + float(Sfx.TRIM.get(name, 0.0)) + Sfx.HEADROOM + extra_db


func _ready() -> void:
	var ok := true
	var mv := _level("ui_move")
	var sel := _level("ui_select")
	var deny := _level("ui_deny")
	var loss := _level("weapon_break", Sfx.WEAPON_LOSS_DB)
	var armor := _level("armor_break")
	print("SFX MIX: ui_move %.1f ui_select %.1f ui_deny %.1f · silah kaybı %.1f zırh %.1f müzik %.1f" % [mv, sel, deny, loss, armor, MUSIC_DB])
	if not (mv < sel):
		push_error("odak tıkı seçimden kısık değil"); ok = false
	if deny > sel + 2.0:
		push_error("ret sesi seçimden %.1f dB yüksek" % (deny - sel)); ok = false
	if loss < armor:
		push_error("silah kaybı zırh kırılmasından alçak"); ok = false
	if loss < MUSIC_DB + 6.0:
		push_error("silah kaybı müziğin altında kalıyor"); ok = false
	print("SFX MIX: %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
