## Silah ayarları — TEK KAYNAK (Görev 4).
##
## Redmount'un kuşanabileceği ekipmanlar (şimdilik yalnızca sopa). Her silah
## bir `.tres` dosyasıdır; Redmount kuşanınca `attack` (J) bu silahın savuruşunu
## yapar, dayanıklılık biterse silah kırılır ve silahsız sete dönülür
## (ana plan md. 7.4 / 18.4).
class_name WeaponConfig
extends Resource

@export var display_name: String = "Sopa"
## Animasyon ön eki: "<prefix>_idle", "<prefix>_walk", "<prefix>_swing" varsa kullanılır.
@export var anim_prefix: String = "bat"

@export_group("Savuruş")
@export var damage: int = 16
@export var windup: float = 0.16
@export var active: float = 0.08
@export var recovery: float = 0.30
@export var knockback: float = 340.0
## Savuruşta Redmount'un aldığı ileri kayma (px/sn).
@export var step_forward: float = 70.0

@export_group("Menzil / dayanıklılık")
## Hitbox genişliği/yüksekliği (px) — yumruktan geniştir.
@export var reach: Vector2 = Vector2(120, 96)
## Hitbox merkezinin karakterden ileri ofseti (px).
@export var reach_offset: float = 70.0
## Kaç savuruş sonra kırılır.
@export var durability: int = 12
