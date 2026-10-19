## Bomber — Bombacı (Dan the Man'in el bombası atan düşmanı).
##
## Menzilli düşman gibi mesafe korur ama mermi yerine oyuncunun durduğu yere yay
## çizen el bombası atar (Grenade). Bomba yere düşüp yanıp söner, sonra patlar:
## oyuncu yerinden kaçmalı ya da bombaya vurup geri yollamalıdır. Yakına gelen
## oyuncuya dirsek atar (panic_range).
extends EnemyBase


func _fire_one() -> void:
	var target := _player.global_position if _player != null else global_position + Vector2(_facing * 260.0, 0)
	# Biraz önüne atar: koşan oyuncu ileri kaçarsa bomba önüne düşer.
	if _player is CharacterBody2D:
		target.x += clampf((_player as CharacterBody2D).velocity.x * 0.35, -120.0, 120.0)
	var from := global_position + Vector2(_facing * 18.0, -96.0)
	Grenade.throw_at(get_parent(), from, target + Vector2(0, -8), config.projectile_damage)
	Sfx.play(&"swing", 0.8)
