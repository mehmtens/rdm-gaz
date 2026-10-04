## ArmorPickup — zırh kuşanma (Görev 8). Bkz. armor_config.gd
extends PickupBase

@export var armor: ArmorConfig


func _collect(player: Node) -> void:
	if armor != null and player.has_method(&"equip_armor"):
		player.equip_armor(armor)
