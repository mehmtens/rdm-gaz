## AmmoPickup — mermi takviyesi (Görev 7). Menzilli silahın yedek cephanesine
## anlık stok ekler (ana plan md. 12.5). Silah yoksa etkisizdir.
extends PickupBase

@export var amount: int = 16


func _collect(player: Node) -> void:
	if player.has_method(&"add_ammo"):
		player.add_ammo(amount)
