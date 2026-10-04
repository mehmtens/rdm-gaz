## Düşman ayarları — TEK KAYNAK (Görev 3).
##
## Her düşman türü kendi `.tres` dosyasıyla gelir; EnemyBase bu değerlerle
## çalışır. Yeni düşman eklerken yeni bir `EnemyConfig` kaynağı + frames yeter,
## kod tekrarı gerekmez (ana plan md. 18.1 / 18.4).
class_name EnemyConfig
extends Resource

@export_group("Can / kimlik")
@export var display_name: String = "Düşman"
@export var max_health: int = 30
## Yenilince verilen skor / coin değeri (ileride kullanılacak).
@export var score_value: int = 100

@export_group("Hareket")
@export var move_speed: float = 90.0
@export var patrol_speed: float = 45.0
@export var gravity: float = 1400.0

@export_group("Algı")
## Oyuncuyu bu yatay mesafede fark eder (px).
@export var sight_range: float = 320.0
## Algı dikey bandı — oyuncu bu kadar yukarıda/aşağıda olabilir (px).
@export var sight_band: float = 150.0
## Fark ettikten sonra saldırıya geçmeden önceki kısa irkilme (sn).
@export var alert_time: float = 0.35
## Oyuncu bu mesafenin ötesine kaçarsa takip bırakılır (px).
@export var give_up_range: float = 460.0

@export_group("Saldırı")
## Saldırı animasyonunun adı (SpriteFrames'te).
@export var attack_anim: StringName = &"punch"
## Bu yatay mesafede saldırı başlatır (px).
@export var attack_range: float = 66.0
## Saldırının isabet için gereken dikey band (px).
@export var attack_band: float = 96.0
@export var attack_damage: int = 8
## Hazırlık → temas → geri dönüş (sn).
@export var attack_windup: float = 0.32
@export var attack_active: float = 0.09
@export var attack_recovery: float = 0.42
## İki saldırı arası bekleme (sn).
@export var attack_cooldown: float = 0.8
## Oyuncuya verdiği geri itme (px/sn).
@export var attack_knockback: float = 240.0

@export_group("Dash saldırısı (Bıçaklı Ajan vb.)")
## Bu düşman geri çekilip dash ile saldırır mı?
@export var uses_dash: bool = false
## Oyuncu bu menzile girince geri-çekil + dash döngüsü başlar (px).
@export var dash_trigger_range: float = 220.0
## Oyuncu bundan yakınsa önce geri çekilir (px).
@export var retreat_range: float = 130.0
@export var retreat_speed: float = 150.0
## Geri çekilme en fazla bu kadar sürer (sn).
@export var retreat_time: float = 0.6
## Dash öncesi hazırlık / telegraph (sn) — sabit durur, sonra fırlar.
@export var dash_prepare_time: float = 0.35
@export var dash_speed: float = 520.0
@export var dash_duration: float = 0.28
## Dash bitince bekleme (sn).
@export var dash_cooldown: float = 1.1

@export_group("Menzilli saldırı (Tüfekli Muhafız vb.)")
## Bu düşman mermi atıp mesafe koruyor mu?
@export var is_ranged: bool = false
## Korumaya çalıştığı yatay mesafe (px).
@export var ranged_preferred_distance: float = 260.0
## Bu menzilde oyuncuya ateş açar (px).
@export var ranged_fire_range: float = 430.0
## Bu kadar yakınsa panikleyip dipçik (yakın dövüş) atar (px).
@export var panic_range: float = 84.0
@export var projectile_speed: float = 620.0
@export var projectile_damage: int = 6
@export var projectile_knockback: float = 90.0
## Nişan alma / telegraph süresi (sn).
@export var aim_time: float = 0.4
## Bir seride kaç mermi.
@export var burst_count: int = 3
## Seri içi atışlar arası süre (sn).
@export var burst_interval: float = 0.13
## Seriler arası bekleme (sn).
@export var shoot_cooldown: float = 1.5

@export_group("Ağır saldırı varyantı (Zırhlı Vurucu vb.)")
## Her saldırıda bu olasılıkla ağır ("guard_break") varyant seçilir (0..1).
@export var heavy_attack_chance: float = 0.0
@export var heavy_attack_anim: StringName = &"guard_break"
@export var heavy_attack_damage: int = 16
@export var heavy_attack_windup: float = 0.5
@export var heavy_attack_active: float = 0.1
@export var heavy_attack_recovery: float = 0.55
@export var heavy_attack_knockback: float = 420.0

@export_group("Blok (Zırhlı Vurucu)")
## Gelen darbeye bu olasılıkla bloka geçer (0..1).
@export var block_chance: float = 0.0
@export var block_windup: float = 0.1
@export var block_duration: float = 0.6

@export_group("Çeviklik (Çevik Suikastçı)")
## Bu düşman oyuncuya sıçrayıp havadan iner mi?
@export var is_agile: bool = false
## Oyuncu saldırı menzilinin dışında ama bu menzilde -> sıçra (px).
@export var leap_range: float = 320.0
@export var leap_jump_velocity: float = -560.0
@export var leap_h_speed: float = 320.0
@export var leap_cooldown: float = 1.3
## Darbe alınca bu olasılıkla geri kaçar (hurt yerine) (0..1).
@export var evade_chance: float = 0.0
@export var evade_speed: float = 320.0
@export var evade_time: float = 0.28

@export_group("Boss")
## Boss can barı HUD'da gösterilsin mi?
@export var is_boss: bool = false
## Yenilince bölüm bitiş noktası yerine kurtarılma sahnesini tetikler (Karahanlı).
@export var is_story_boss: bool = false
## Bu kadar isabet alınca zırhı kırılıp kısa süre savunmasız kalır (0 = kapalı).
@export var armor_break_hits: int = 0
## Zırh kırık kalma süresi — bu sırada tam hasar alır, hareket edemez (sn).
@export var armor_break_duration: float = 2.2
## Ağır saldırıda (`guard_break`) yere vurup dalga (shockwave) çıkarsın mı?
@export var slam_on_heavy: bool = false
@export var slam_damage: int = 14
@export var slam_knockback: float = 300.0

@export_group("Hasar alma")
## Gelen hasarı bu oranla çarpar (kalıcı zırh; 1.0 = normal).
@export var damage_taken_mult: float = 1.0
## 0..1 — gelen geri itmeyi bu oranda azaltır.
@export var knockback_resist: float = 0.0
## Bu hasar ve üstünü tek darbede alınca knockdown.
@export var knockdown_damage_threshold: int = 14
@export var hurt_duration: float = 0.3
@export var knockdown_duration: float = 0.7
@export var getup_duration: float = 0.4
