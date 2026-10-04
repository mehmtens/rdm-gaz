## WeaponPickup — yerden silah alma (Görev 4). Redmount silahı kuşanır
## (ana plan md. 7.5). Bkz. weapon_config.gd
extends PickupBase

@export var weapon: WeaponConfig


func _collect(player: Node) -> void:
	if weapon != null and player.has_method(&"equip_weapon"):
		player.equip_weapon(weapon)
