## Çizim sırası: içinden yürünen kırılabilir varil/kasa kahramanı ve düşmanı örtmemeli
## (tur 189: varil z 2, karakterler z 0'dı → Bölüm 5 finalinde kahraman varilin arkasında).
## Ön katmanlar (önde süs, su, gizli oda cephesi) karakterlerin üstünde kalmalı.
extends Node

const PLAYER := preload("res://scenes/characters/Redmount.tscn")
const ENEMY := preload("res://scenes/enemies/KnifeAgent.tscn")


func _ready() -> void:
	var fails: Array[String] = []
	var prop := BreakableProp.new()
	prop.kind = "varil"
	add_child(prop)
	var player: Node2D = PLAYER.instantiate()
	add_child(player)
	var enemy: Node2D = ENEMY.instantiate()
	add_child(enemy)
	await get_tree().process_frame

	if player.z_index <= prop.z_index:
		fails.append("kahraman z %d ≤ varil z %d" % [player.z_index, prop.z_index])
	if enemy.z_index <= prop.z_index:
		fails.append("düşman z %d ≤ varil z %d" % [enemy.z_index, prop.z_index])
	if player.z_index != enemy.z_index:
		fails.append("kahraman z %d ≠ düşman z %d" % [player.z_index, enemy.z_index])
	if prop.z_index < 1:
		fails.append("varil z %d zemin süslerinin (0) altına düştü" % prop.z_index)

	# Önde süs (`_deco(..., behind = false)`) karakterlerin üstünde kalmalı.
	# Ağaca eklenmez: bölüm kurulumu (_ready) çalışmasın, yalnız yardımcı ölçülsün.
	var level := DtmLevel.new()
	level._deco(preload("res://icon.svg"), 0.0, 0.0, 1.0, false)
	var deco := level.get_child(level.get_child_count() - 1) as CanvasItem
	if deco == null or deco.z_index <= player.z_index:
		fails.append("önde süs karakterlerin üstünde değil")
	level.free()

	if fails.is_empty():
		print("DRAW ORDER: PASS")
	else:
		for f in fails:
			print("FAIL: ", f)
		print("DRAW ORDER: FAIL")
	get_tree().quit(0 if fails.is_empty() else 1)
