## Ateşli silah ayarları — TEK KAYNAK (Görev 7).
##
## Redmount'un menzilli silahı. Yakın dövüş silahından (WeaponConfig) ayrı slot:
## `L` ile ateş edilir, `J`/`K` yakın dövüşü etkilemez. Şarjör biter -> otomatik
## yeniden doldurma; cephane tümüyle biter -> silah bırakılır (ana plan md. 7.4).
class_name GunConfig
extends Resource

@export var display_name: String = "Tabanca"
@export var anim_prefix: String = "pistol"
@export var damage: int = 7
@export var projectile_speed: float = 900.0
@export var projectile_knockback: float = 80.0
## İki atış arası minimum süre (sn).
@export var fire_interval: float = 0.26
@export var mag_size: int = 8
## Yeni silah alınırken gelen yedek cephane.
@export var starting_reserve: int = 24
@export var reload_time: float = 1.1
## Atışta Redmount'a binen geri tepme (px/sn, ateş yönünün tersi).
@export var recoil: float = 60.0
@export var shoot_anim: StringName = &"shoot"

@export_group("Fırlatma")
## HUD'daki cephane adı ("MERMİ" / "TAŞ").
@export var ammo_label: String = "MERMİ"
## > 0 ise mermi yerçekimiyle yay çizer (px/sn²). Kaldırım taşı.
@export var projectile_gravity: float = 0.0
## Atış yönünün yukarı bileşeni (yatay 1'e göre); yayın tepesini belirler.
@export var throw_lift: float = 0.0
## Boşsa standart mermi (Bullet.tscn).
@export_file("*.tscn") var projectile_scene: String = ""
## Atış sesi.
@export var fire_sfx: StringName = &"shoot"
