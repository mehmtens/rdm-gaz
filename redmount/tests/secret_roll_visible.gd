## Gizli alanın film rulosu ana yoldan görünür kalmalı: rulo, hanın / binanın ön
## cephesinin (`_Facade`) arkasında çizilirse oyuncu sırrı yalnız çatlak kapıdan
## sezebiliyordu (tur 205 denetimi: Bölüm 11 x 5590 hanı). 36 bölümün her rulosu
## için üstünde çizilen bir cephe var mı ölçülür.
##
##  godot --headless --path . res://tests/secret_roll_visible.tscn
##  REDMOUNT_ROLL_OFF=1 → düzeltmeyi kapatıp taban ölçümü.
extends Node

const GAME_STATE_SCRIPT := preload("res://scripts/systems/game_state.gd")


## Düğümün çizim z'si (göreli z'ler toplanır).
static func _abs_z(n: CanvasItem) -> int:
	var z := 0
	var c: Node = n
	while c is CanvasItem:
		z += (c as CanvasItem).z_index
		if not (c as CanvasItem).z_as_relative:
			break
		c = c.get_parent()
	return z


func _ready() -> void:
	var hidden := 0
	var total := 0
	var off := OS.get_environment("REDMOUNT_ROLL_OFF") == "1"
	for li in GAME_STATE_SCRIPT.LEVELS.size():
		var level: Node = (load(GAME_STATE_SCRIPT.LEVELS[li]) as PackedScene).instantiate()
		add_child(level)
		await get_tree().process_frame
		await get_tree().process_frame
		var facades: Array = []
		for ch in level.get_children():
			if ch is DtmLevel._Facade:
				facades.append(ch)
		for z in level.get_children():
			if not (z is DtmLevel._SecretZone):
				continue
			var roll: Sprite2D = z._roll
			if off:
				roll.z_index = 3
			total += 1
			var rr: Rect2 = z.roll_rect()
			var rz := _abs_z(roll)
			for f in facades:
				var fr: Rect2 = f.rect
				fr.position += f.global_position
				if not fr.intersects(rr):
					continue
				var fz := _abs_z(f)
				if fz > rz or (fz == rz and f.get_index() > z.get_index()):
					hidden += 1
					print("GIZLI RULO: bölüm %d x %.0f y %.0f" % [li + 1, rr.get_center().x, rr.get_center().y])
					break
		level.queue_free()
		await get_tree().process_frame
	print("RULO: %d / %d cephe arkasında" % [hidden, total])
	if hidden == 0 and total > 0:
		print("SECRET ROLL: PASS")
	else:
		print("SECRET ROLL: FAIL")
	get_tree().quit(0 if hidden == 0 else 1)
