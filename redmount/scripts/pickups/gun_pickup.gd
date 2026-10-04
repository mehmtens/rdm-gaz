## GunPickup — yerden ateşli silah alma (Görev 7). Bkz. gun_config.gd
extends PickupBase

@export var gun: GunConfig


func _collect(player: Node) -> void:
	if gun != null and player.has_method(&"equip_gun"):
		player.equip_gun(gun)
