## Redmount dövüş ayarları — TEK KAYNAK (Görev 2).
##
## Silahsız dövüş setinin (üçlü combo + ağır yumruk + hava diz) tüm sayısal
## değerleri ve hasar-alma tepkileri burada tutulur. Sahnede
## `res://resources/combat/redmount_combat.tres` olarak bağlanır; Inspector'dan
## kod değiştirmeden ayarlanır (ana plan md. 18.4).
##
## Saldırı zamanlaması üç fazdır: hazırlık → temas (hitbox açık) → geri dönüş
## (ana plan md. 7.3 / character-animation-bible "hazırlık → temas → geri dönüş").
class_name CombatConfig
extends Resource

@export_group("Can")
@export var max_health: int = 100

@export_group("Silahsız üçlü combo")
## Her combo vuruşunun hasarı (3 eleman).
@export var combo_damage: PackedInt32Array = PackedInt32Array([6, 6, 12])
## Hazırlık süresi — vuruş başlar, hitbox henüz kapalı (sn).
@export var combo_windup: PackedFloat32Array = PackedFloat32Array([0.06, 0.06, 0.10])
## Temas süresi — hitbox açık (sn).
@export var combo_active: PackedFloat32Array = PackedFloat32Array([0.05, 0.05, 0.06])
## Geri dönüş süresi — hitbox kapalı, hâlâ hareket kilitli (sn).
@export var combo_recovery: PackedFloat32Array = PackedFloat32Array([0.16, 0.18, 0.30])
## Her vuruşun düşmana verdiği yatay geri itme (px/sn).
@export var combo_knockback: PackedFloat32Array = PackedFloat32Array([120.0, 120.0, 300.0])
## Her vuruşta Redmount'un aldığı küçük ileri kayma hızı (px/sn).
@export var combo_step_forward: float = 90.0

@export_group("Ağır yumruk (K)")
@export var heavy_damage: int = 18
@export var heavy_windup: float = 0.18
@export var heavy_active: float = 0.07
@export var heavy_recovery: float = 0.38
@export var heavy_knockback: float = 380.0
@export var heavy_step_forward: float = 60.0

@export_group("Hava diz (havada J)")
@export var air_knee_damage: int = 10
@export var air_knee_windup: float = 0.05
@export var air_knee_active: float = 0.12
@export var air_knee_recovery: float = 0.10
@export var air_knee_knockback: float = 160.0

@export_group("Hasar alma")
## Hafif sersemleme süresi (sn).
@export var hit_light_duration: float = 0.28
## Bu hasar değeri ve üstünü tek darbede alınca knockdown (yere düşme).
@export var knockdown_damage_threshold: int = 16
## Yerde yatma süresi (sn).
@export var knockdown_duration: float = 0.8
## Ayağa kalkma süresi — hâlâ kontrol yok (sn).
@export var getup_duration: float = 0.45
## Darbe sonrası dokunulmazlık süresi (sn).
@export var invuln_after_hit: float = 0.6
## Darbeden gelen yatay geri itme (px/sn).
@export var knockback_from_hit: float = 260.0
## Darbeden gelen yukarı fırlama (px/sn, negatif = yukarı).
@export var knockback_up_from_hit: float = -170.0

@export_group("His / geri bildirim")
## Vuruş anındaki kısa donma (hit-stop) süresi, gerçek zaman (sn).
@export var hitstop_seconds: float = 0.055
## Normal vuruşta ekran sarsıntısı gücü (px).
@export var shake_on_hit: float = 4.0
## Ağır vuruşta ekran sarsıntısı gücü (px).
@export var shake_on_heavy: float = 7.5
