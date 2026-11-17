## Tur 248: dost telsiz satırları (Gazelle/Redmount) kilitli arenada dövüş sürerken
## bekler, arena temizlenince çıkar; düşman telsizi ve `urgent` satırlar beklemez.
extends Node


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _ready() -> void:
	var p := Node2D.new()
	p.add_to_group(&"player")
	p.position = Vector2(500, 0)
	add_child(p)
	var arena := BattleArena.new()
	arena.gate_left_x = 0.0
	arena.gate_right_x = 1000.0
	add_child(arena)
	arena._active = true
	await _frames(2)
	assert(BattleArena.player_in_combat(get_tree()), "arena içi dövüş algılanmadı")

	# Düşman telsizi dövüşün parçası: hemen çıkar.
	RadioPanel.say(get_tree(), "telsiz", "TELSİZ", "Kapıyı tutun!")
	await _frames(5)
	var rp: RadioPanel = RadioPanel._instance
	assert(rp._active, "düşman telsizi arenada bekletilmemeli")
	rp._active = false

	# Dost hikâye satırı: dövüş sürerken bekler.
	RadioPanel.say(get_tree(), "gazelle", "GAZELLE", "Hikâye satırı")
	await get_tree().create_timer(1.1).timeout
	assert(not rp._active and rp._queue.size() == 1, "dost satır arenada bekletilmeli")

	# Oyuncu arenanın dışındaysa (kapısız arena) beklemez.
	p.position.x = 1500.0
	await get_tree().create_timer(1.1).timeout
	assert(rp._active and rp._full == "Hikâye satırı", "arena dışındaki oyuncuya satır çıkmalı")
	rp._active = false
	p.position.x = 500.0

	# Acil (senaryolu) satır beklemez.
	RadioPanel.say(get_tree(), "gazelle", "GAZELLE", "Acil!", true)
	await _frames(5)
	assert(rp._active and rp._full == "Acil!", "acil satır bekletilmemeli")
	rp._active = false

	# Arena bitince satır CALM süresi sonra çıkar, hemen değil.
	RadioPanel.say(get_tree(), "redmount", "REDMOUNT", "Bitti.")
	await _frames(10)
	assert(not rp._active, "dövüşte redmount satırı bekletilmeli")
	arena._done = true
	await _frames(3)
	assert(not rp._active, "TEMİZ! okunmadan satır çıkmamalı")
	await get_tree().create_timer(1.1).timeout
	assert(rp._active and rp._full == "Bitti.", "arena temizlenince satır çıkmalı")
	print("RADIO ARENA HOLD: PASS")
	get_tree().quit(0)
