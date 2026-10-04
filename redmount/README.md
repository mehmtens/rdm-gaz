# REDMOUNT — Godot 4 projesi

**Güncel kampanya:** Üç kitap, 36 bölüm. Kitap 3 finali **Son Yayın — İstanbul'un Sesi**
Göksu kıyısı ve yayın mavnasında geçer. Üç bağlantı hedefi, üç evreli Yayın Şefi,
geceden şafağa 12 mekân ve hikâyeyi kapatan epilog içerir.
[Final bölüm tasarımı](docs/BOOK03-FINALE.md).

Ana plan: [`../PROJE-ANA-PLANI.md`](../PROJE-ANA-PLANI.md) · Animasyon notları: [`../character-animation-bible.md`](../character-animation-bible.md)

**Durum (12 bölümlük kampanya blockout'u):** Güncel kampanya sırası dört perde ×
üç bölüm olarak `GameState.LEVELS` içine alındı. Mevcut beş büyük prototip
bölümünün arasına yedi özgün hikâye/parkur blockout'u eklendi
(`Level06–12.tscn`, `story_blockout.gd`). Bölüm hedefleri ve anlatı ritmi:
[`docs/12-BOLUM-KAMPANYA.md`](docs/12-BOLUM-KAMPANYA.md).

**Durum (Görev 28):** Görev 26 prosedürel chiptune müzik (`music.gd` autoload +
`tools/gen_music.py`, per-biome + boss + victory). Görev 27 **duraklat menüsü**
(`pause_menu.gd`, ESC/Start) + **tam gamepad** desteği (analog + D-pad + tüm
tuşlar `project.godot [input]`). Görev 28 **öğretici ipuçları** (`hint_trigger.gd`,
Bölüm 1'de engellemeyen fade etiketler) + menüde/HUD'da kontrol referansı.

**Durum (Görev 25c):** 5 bölümün TAMAMI 25b tasarım diliyle yeniden yazıldı
(`scenes/levels/Level01–05.tscn`). Ortak kalıp: her yeni fikir güvenli geniş
zeminde TEK BAŞINA tanıtılır → sonra birleştirilir; her segmentten önce CP;
dövüş asla anında-ölüm (diken/çukur) üstünde geçmez; zorunlu boşluk ≤120px yatay
/ ≤90px yukarı; katı çatılar 220–240px; duvar-zıplama yalnız OPSİYONEL ödül
dallarında (ana yolu kapatmaz, duvarlar zeminin üstünde yüzer). Uzunluklar
~3400–4700px → ~4700–5900px. Bölüm sonları: L01/L02/L03 kilitli arena, L04
kilitli mini-boss arenası, L05 açık taht salonu (Karahanlı + kaidede Gazelle).
Doğrulama: headless `_probe` botu gerçek girdiyle parkuru sürer (godmode: yol'u
test eder, dövüş değil; tıkanınca dash); L05 C–F kamera sweep (`_sweep.gd`).

**Son bölüm çalışması:** Level02'nin uzun kampanya rotasından sonra Level03 de
`level03_redesign.gd` ile ~49.200px'e uzatıldı: ağır-sanayi temalı beş segment,
üç arena, siper/üst rota, mağazalar ve düzenli kontrol noktaları. Eski kısa
blockout öğretici açılış olarak korunur; bölüm hedefi uzun rotanın sonuna taşınır.
Level04 de `level04_redesign.gd` ile ~50.600px dağ-kalesi rotasına uzatıldı;
zırhlı birlik baskısı aşamalı yükselir ve uzun rota mini-boss arenasında biter.

Aşağıdaki Görev 15-16 notları tarihseldir; güncel özet:

- **Sprite'lar** (Görev 23): kullanıcının el-çizimi Dan the Man tarzı atlas sayfaları
  `tools/slice_atlas.py` + `build_character.py` ile dilimlenip `resources/anim/*_frames.tres`
  SpriteFrames'e döküldü. `player_sprite.gd` / `enemy_sprite.gd` (AnimatedSprite2D) durum→
  animasyon eşler. Redmount 27 anim; 8 düşman ~7'şer + Karahanlı 5.
- **Ölçek** (Görev 24): Rig `scale 0.6` → karakter ~120px (uzak arcade kamerası).
  Çarpışma kutuları, kamera, silah menzilleri orantılı.
- **Dünya**: `level.gd` biome'a göre prosedürel tiling doku (asfalt/metal/taş);
  `backdrop.gd` 3 katman paralaks silüet; `blob_shadow.gd` temas gölgesi;
  `game_camera.gd` bakış-öngörüsü; `main.gd` biome vinyet grade.
- **Arayüz**: `ui_style.gd` ortak tema; menü/mağaza prosedürel gece-şehir arka plan;
  HUD outline'lı; `transition.gd` (autoload) sahne geçiş perdesi.
- **Diyalog**: `dialogue_box.gd` + `dialogue_trigger.gd` (Area2D, `speakers`/`texts`).
  Level01 açılış, Level05 Karahanlı, `_trigger_ending` Gazelle kurtarılış replikleri.
- **Ses**: `sfx.gd` `TRIM` per-clip dB dengesi. **Müzik** (Görev 26):
  `music.gd` (autoload `Music`) + `tools/gen_music.py` ile sentezlenmiş
  prosedürel chiptune parçalar (`assets/music/mus_*.wav`) — menü, 4 biome,
  boss, victory. İki AudioStreamPlayer crossfade; döngü `.import`'ta.
- **`Fx`** (autoload, `fx.gd`): savuruş yayı / kıvılcım / toz / halka / hasar yazısı —
  hepsi yeni ölçeğe göre küçültüldü.

Eksik: Redmount hurt/knockdown/dead sprite sheet'leri, Gazelle gerçek sanat,
dallanan hikâye, Windows export (export template'leri kurulu değil).

**Parkur mekanikleri (Görev 15):** dash (`Ctrl` veya yön tuşuna çift basma; havada 1 hak,
kısa dokunulmazlık), duvar kayması + duvar zıplaması, çömelme (`S`), tek yön platformdan
iniş (`S` + `Zıpla`). Değerler `movement_config.gd` → `.tres`. Yeni ortam sahneleri:
`OneWayPlatform`, `MovingPlatform`, `Spikes` (Hazard, grup "hazard" → Main son kontrol
noktasına döndürür). Level01–05'in **hepsi** bu mekaniklerle **Dan the Man** tarzı yeniden tasarlandı:
tek yön platform tırmanışları, dikenli çukur/hendek + hareketli platformlar,
duvar-zıplama şaftları (bonus ödül), kırılabilir duvar gizli odalar, ara
checkpoint'ler. Bölüm 4 sonu düz mini-boss arenası, Bölüm 5 sonu düz taht salonu
arenası (Karahanlı + arka planda kafeste Gazelle) — boss dövüşleri parkursuz,
geniş ve duvarlı.

**Görev 16 (uzatma/ayrıntı geçişi):** her bölüm ~40–70% uzatıldı, her birine en
az bir **ek bonus dal** (sıçrayarak ulaşılan gizli coin platformu) + **ikinci
gizli oda** (kırılabilir duvar veya tek yön platform) eklendi; parkur/dövüş iç
içe geçti (platform üstünde/geçiş sırasında düşman). Level01 ayrıca 4 sekmelik
çatı zinciri + iki paralel hareketli platform + koşarak-sıçrama menzilinin
üstünde **dash gerektiren** boşluk + iki katlı duvar-zıplama bacası ile en zengin
bölüm. Tüm zıplama/dash/duvar-zıplama mesafeleri gerçek girdiyle headless
otomatik botla ölçülüp (~125px zıplama, ~250px koşarak sıçrama menzili, ~90px
duvar-zıplama aralığı, tek yön platformdan iniş) doğrulandı — bkz. hafıza notu
`redmount-project` "mekanik doğrulama".

**Görev 17 (görsel geçiş):** her bölüme prosedürel **çok katmanlı paralaks arka
plan** (`scripts/systems/backdrop.gd`) — biome'a göre farklı ruh hâli: sokak
(alacakaranlık şehir), endüstri (dumanlı gri), kale (soğuk dağ sırtı), taht
salonu (gece suru). Zemin/platformlara üstten-alta gradyan + biome-renkli kenar
ışığı; ekran kenarı vignette shader'ı. `Level.biome` export'undan seçilir.

**Görev 18 (kilitli dövüş arenaları):** `scripts/systems/battle_arena.gd` —
Dan the Man tarzı "dövüş kapısı": oyuncu tetik alanına girince iki yanda
bariyer + kamera kilidi + düşman dalgaları (`wave1/wave2/wave3`); hepsi
temizlenince bariyer çözülür + ödül düşer. Level01 son bölüm ve Level05 surlar
bu sistemi kullanır. Otonom bot Bölüm 1–4'ü tam, Bölüm 5'i son boss'a kadar
temizliyor.

**K tuşu:** artık silah kuşanıkken de ağır yumruk atar (silah kullanımını harcamaz).

## Çalıştırma

Godot 4.7.x ile `project.godot` dosyasını aç, F5 (veya editörde ▶). Ana sahne: `scenes/MainMenu.tscn`
(oyun kökü: `scenes/Main.tscn`).

**Mobil hedef — ilk dikey kesit:** Kökteki `OYNA_MOBIL.cmd`, 36 bölümlük ana oyunu
PC'de dokunmatik düğmelerle açar. `export_presets.cfg` içindeki **Android Debug**
ayarı ARM64 APK üretir; son doğrulanmış paket `../build/redmount-debug.apk`
(235,3 MiB). Paket, geliştirme ekran görüntülerini, vitrin/reference görsellerini
ve testleri dışarıda bırakır; 36 bölümün oyun kaynakları korunur. Gerçek telefon
oynanış testi hâlâ gereklidir. Godot testi: `godot --headless --path . --script
res://tests/touch_controls.gd`

Kampanya smoke testi: `godot --headless --path . --script res://tests/campaign_smoke.gd`.

## Kontroller

| Tuş | İşlev |
|---|---|
| `A` / `D` veya `←` / `→` | Sola / sağa hareket |
| `Shift` (basılı tut) | Koşma |
| `Space` / `W` / `↑` | Zıplama |
| `J` | Silahsızken başlangıçta ikili kombo, yükseltmeyle üçüncü vuruş; silah kuşanıkken silahın saldırısı |
| `J` (havada) | Hava diz darbesi |
| `K` | Ağır yumruk (silah kuşanıkken de kullanılabilir) |
| `L` | Ateş et (tabanca kuşanıkken); şarjör bitince otomatik reload |
| `S` / `↓` | Çömel (yüksek saldırıdan kaçar); basılıyken `Zıpla` → tek yön platformdan aşağı in |
| `Ctrl` | Dash (yatay atılım + kısa dokunulmazlık); yön tuşuna hızlı çift basmak da dash yapar |
| Duvara doğru bas (havada) | Duvar kayması; sonra `Zıpla` → duvar zıplaması |
| `R` | Son kontrol noktasına dön + canı doldur. "Bölüm tamam" ekranında: sonraki bölüm (son bölümde koşu baştan) |
| `Esc` | Duraklat menüsü (devam / kontrol noktası / bölüm başı / ses / ana menü) |

**Gamepad** (Görev 27): sol analog + D-pad hareket/çömel · `A` zıpla · `X` saldır ·
`Y` ağır · `RB` ateş · `RT` koş · `LB` dash · `Start` duraklat.

**Dokunmatik:** Solda yön, eğilme ve atılma; sağda vurma, zıplama, ağır saldırı,
ateş ve etkileşim; üstte duraklatma. Hareket ederken otomatik koşulur. Ölümde
TEKRAR, bölüm sonunda SONRAKİ/BAŞTAN ve MENÜ düğmeleri görünür.

Toplanabilirlere yürüyerek dokun: **coin**, **kalp** (can), **sopa** / **bıçak** (yakın dövüş
silahı, dayanıklılık bitince kırılır), **tabanca** (menzilli, ayrı slot), **cephane** (yedek mermi),
**zırh** (hasar azaltır, birkaç darbe emer, hızı düşürür), **güçlendirmeler** (2x hasar / hız /
görünmezlik süreli; kalkan bir darbe engeller).

## Mimari (kısa)

- **`scenes/Main.tscn`** + `scripts/systems/main.gd` — oyun kökü. Kalıcı **Redmount** + **HUD** +
  boş **`LevelHolder`**. `_load_current_level()` `GameState.level_path()` sahnesini `LevelHolder`
  altına yükler, `PlayerSpawn`'ı bulur, kamera sınırlarını + düşme Y'sini bölümden okur,
  düşman/checkpoint/goal sinyallerini yeni bölümün alt ağacından tarayıp bağlar. Bölüm bitişi →
  duraklat + "Bölüm X tamam"; `R` → sonraki bölüm (veya son bölümde final + koşu başa).
  Aksi hâlde `R` / düşme = son kontrol noktası. Main `PROCESS_MODE_ALWAYS`, dünya `PAUSABLE`.
- **`scripts/systems/level.gd`** (`class_name Level`) — her `LevelXX.tscn` kökü: `display_name`,
  kamera sınırları, `fall_respawn_y`. Geometri/düşman/pickup/`PlayerSpawn`/`LevelGoal` sahnede.
- **`scenes/levels/Level01..Level12.tscn`** — 4 perde / 12 bölümlük sıra.
  Level01–05 elde yazılmış büyük prototip sahneleridir; Level06–12,
  `story_blockout.gd` içindeki yedi ayrı elle bestelenmiş bağlayıcı parkuru taşır.
  Karahanlı ve Gazelle finali sıranın 12. bölümündeki `Level05.tscn` sahnesidir.
  `TestLevel.tscn` sıralama dışı geliştirici kum havuzudur.
- **`scenes/enemies/EliteGuard.tscn`** + `elite_guard.tres` — Elit Muhafız (md. 10.7): 40 can,
  `is_ranged` (kısa mesafe seri ateş) + yakın combo + `heavy_attack_chance` + `block_chance`.
- **`scenes/enemies/Karahanli.tscn`** + `karahanli.tres` — son boss (md. 9). 170 can,
  `is_boss` + `is_story_boss`, ağır melee combo (`punch` / `guard_break`) + hücum, `damage_taken_mult
  0.75`. Yenilince Main `_trigger_ending()` çağırır (LevelGoal yok).
- **`scripts/characters/gazelle.gd`** + **`scenes/characters/Gazelle.tscn`** — kurtarılmayı
  bekleyen NPC (md. 8). `bound_idle` döngüsü; `rescue()` → `rescue_react` → `freed` → `rescue_pose`
  tween zinciri + `freed` sinyali. Grup: `gazelle`.
- Main `_trigger_ending()`: story-boss yenilince oyuncuyu dondurur, Gazelle'i kurtarır, ~2.6 sn
  sonra duraklat + `show_results("GAZELLE KURTARILDI")`.
- **`scenes/characters/Redmount.tscn`** — `CharacterBody2D` (layer `player`) kök +
  `AnimatedSprite2D` (`offset = (0,-128)`) + gövde `CollisionShape2D` +
  **`Hurtbox`** (Area2D, düşman hitbox'larını dinler) +
  **`Hitbox`** (Area2D, saldırı temas fazında açılır, yöne göre x konumu döner) +
  script'li `Camera2D` (yumuşak takip + ekran sarsıntısı).
- **`scripts/characters/redmount.gd`** — hareket + dövüş + durum sistemi. Tek `enum State`
  (`IDLE, MOVE, RUN, JUMP, FALL, LAND, ATTACK, HURT, KNOCKDOWN, DEAD`) ve `match`; node tabanlı
  FSM yok. Saldırılar üç fazlı: **WINDUP → ACTIVE (hitbox açık) → RECOVERY**. Combo, ACTIVE/RECOVERY
  sırasında tekrar `J` ile zincirlenir. Hasar alma `apply_hit(damage, dir, knockback)` ile gelir
  (düşmanlarla simetrik imza); eşik (`knockdown_damage_threshold`) üstü tek darbe → knockdown → getup.
  Sopa kuşanıkken (`_weapon`) `J` sopa savuruşu yapar (geniş hitbox, `WeaponConfig`'ten değerler),
  her savuruş 1 dayanıklılık; biterse silah kırılır. `equip_weapon()` / `heal()` pickup'lar için.
- **`scripts/systems/movement_config.gd`** + **`resources/movement/redmount_movement.tres`** —
  tüm hareket değerleri (Görev 1).
- **`scripts/systems/combat_config.gd`** (`class_name CombatConfig`, `Resource`) +
  **`resources/combat/redmount_combat.tres`** — TÜM dövüş/can değerleri tek yerde: max can,
  combo hasar/zamanlama/geri itme dizileri, ağır yumruk, hava diz, hasar-alma tepkileri,
  hit-stop süresi, sarsıntı gücü. Inspector'dan kod değiştirmeden ayarlanır.
- **`scripts/systems/combat.gd`** (autoload `Combat`) — `hitstop(sn)` vuruş anında oyunu
  gerçek-zamanlı çok kısa dondurur; `shake(güç)` `shake_requested` sinyalini yayar.
- **`scripts/systems/game_state.gd`** (autoload `GameState`) — koşu durumu: `coins`, `score`,
  `level_index` + `LEVELS` yol listesi. `add_coins/add_score`, `level_path/has_next_level/
  advance_level`, `start_run` (sayaç sıfırla, indekse dokunma) / `reset_run` (Bölüm 1'den).
- **`scripts/systems/save_manager.gd`** (autoload `Save`) — `user://redmount_save.cfg` (ConfigFile).
  `unlocked_level`, `total_coins`, `best_scores`, `purchased`, `upgrade_levels`, `master_volume_db`. `record_level_clear(index,
  run_coins, score)` bölüm bitince Main tarafından çağrılır → açılan bölümü ilerletir + kaydeder.
  `set_volume_db` (Master bus'a uygular + kaydeder), `wipe`.
- **`scripts/systems/shop.gd`** + **`scripts/ui/shop_menu.gd`** — kalıcı mağaza: beş özel
  hareket açılışı, çift coin ve üçer kademeli yumruk gücü, kombo hızı, bitirici gücü,
  silah kapasitesi ve azami can geliştirmesi. Eski `tough_body` kaydı ilk can kademesine taşınır.
- **`scenes/MainMenu.tscn`** + `scripts/ui/main_menu.gd` — ANA SAHNE. "DEVAM ET" açılan bölümden
  başlar; bölüm düğmeleri `Save.unlocked_level`'e kadar aktif; ses kaydırıcısı; çıkış; kaydı
  sıfırla. Seçim `GameState.level_index`'i ayarlar, `Main.tscn`'e geçer.
- **`scripts/systems/sfx.gd`** (autoload `Sfx`) — `Sfx.play(name, pitch, volume_db)`. 15 placeholder
  `.wav` (`assets/audio/`, PowerShell'de sentezlendi), 12'lik AudioStreamPlayer havuzu, hafif
  rastgele perde. İsimler: step/jump/land/swing/hit/heavy_hit/weapon_break/coin/heal/enemy_hurt/
  enemy_down/player_hurt/player_death/checkpoint/goal.
- **`scripts/systems/checkpoint.gd`** + **`scenes/systems/Checkpoint.tscn`** — oyuncu değince
  `activated(pos)` yayar, Main son spawn'ı günceller; bayrak yeşile döner.
- **`scripts/systems/level_goal.gd`** + **`scenes/systems/LevelGoal.tscn`** — oyuncu ulaşınca
  `reached` yayar; Main `get_tree().paused = true` + HUD sonuç ekranı. `R` → `reload_current_scene()`.
  (Main `PROCESS_MODE_ALWAYS`, dünya `PAUSABLE`, HUD `ALWAYS`.)
- **`scripts/systems/weapon_config.gd`** (`class_name WeaponConfig`, `Resource`) +
  **`resources/weapons/bat.tres`** (sopa) + **`knife.tres`** (bıçak) — yakın dövüş silahı:
  hasar/zamanlama/menzil/dayanıklılık/anim-öneki. Yeni silah = yeni `.tres` + `<prefix>_swing`
  (+ ops. `_idle`/`_walk`) karesi.
- **`scripts/systems/gun_config.gd`** (`class_name GunConfig`, `Resource`) +
  **`resources/weapons/pistol.tres`** — ateşli silah (ayrı slot): hasar, mermi hızı, atış aralığı,
  şarjör boyu, başlangıç yedek cephane, reload süresi, geri tepme.
- **`scripts/systems/armor_config.gd`** (`class_name ArmorConfig`, `Resource`) +
  **`resources/armor/body_armor.tres`** — `damage_reduction` (0..1), `durability` (emilen darbe),
  `speed_penalty`. Redmount `_armor` / `_armor_hp`; `apply_hit`'te hasarı azaltır, darbe başına
  1 dayanıklılık, bitince kırılır. `armor_changed` sinyali.
- **`scripts/systems/powerup_config.gd`** (`class_name PowerupConfig`, `Resource`) +
  **`resources/powerups/*.tres`** — `Kind` (DAMAGE_X2 / SPEED / INVISIBILITY / SHIELD), süre,
  `magnitude`. Redmount `_pu` sözlüğünde tutulur, `_tick_powerups` süreyi işler, `powerups_changed`
  sinyali. DAMAGE_X2/SPEED çarpan olarak hasar/hıza girer; INVISIBILITY `is_invisible()` -> düşman
  `_sees_player` false; SHIELD `apply_hit`'te bir darbeyi yutar.
- **`scripts/systems/projectile.gd`** (`class_name Projectile`) + **`scenes/systems/Bullet.tscn`** —
  Area2D mermi; `Projectile.spawn(world, pos, dir, speed, dmg, kb, hostile_to_player, shooter)`
  static yardımcısıyla hem Redmount hem düşmanlar oluşturur. Hurtbox'a değince `apply_hit`, duvara
  değince yok olur. `process_mode = PAUSABLE`.
- **`scripts/systems/game_camera.gd`** — `Camera2D`; `Combat.shake_requested` dinleyip
  `offset` ile sönümlü ekran sarsıntısı uygular.
- **`resources/redmount_frames.tres`** — `SpriteFrames`, 19 durum için placeholder animasyon
  (`idle, walk, run, jump, fall, land, punch_1..3, heavy, air_knee, bat_idle, bat_walk,
  bat_swing, hit_light, hit_heavy, knockdown, getup, dead`), her biri şimdilik tek kare.
- **`scripts/enemies/enemy_base.gd`** (`class_name EnemyBase`) + **`scenes/enemies/EnemyBase.tscn`** —
  tüm düşmanların ortak tabanı: can, Hurtbox/AttackHitbox/Muzzle, geri itme, hasar-alma tepkileri,
  yerçekimi, devriye, algı, üç fazlı yakın dövüş; config açıkken ayrıca **dash** (geri-çekil→dash),
  **menzilli** (mesafe koru + seri ateş + dipçik), **ağır saldırı varyantı** (`guard_break`),
  **blok** (darbeyi yutar), **sıçrama** (`LEAP` → havadan drop strike), **kaçınma** (`EVADE`).
  Tek `enum State` (IDLE/PATROL/ALERT/CHASE/ATTACK/RETREAT/DASH/RANGED/BLOCK/LEAP/EVADE/HURT/
  KNOCKDOWN/DEAD) + `match`. `defeated(enemy)` sinyali; simetrik `apply_hit(damage, dir, knockback)`.
- **`scripts/enemies/enemy_config.gd`** (`class_name EnemyConfig`, `Resource`) — bir düşman türünün
  TÜM sayısal değerleri: temel (can/hız/algı/saldırı) + dash + menzilli + ağır-saldırı +
  blok (`block_chance`) + çeviklik (`is_agile`/`leap_*`/`evade_chance`) + `damage_taken_mult`
  (kalıcı zırh). Yeni düşman = yeni `.tres` + `SpriteFrames` (+ gereken anim adları).
- **`scenes/enemies/StreetThug.tscn`** (EnemyBase'i miras alır) + `resources/enemies/street_thug.tres`
  + `street_thug_frames.tres` — Sokak Eşkıyası: yavaş, 30 can, temel yakın dövüşçü (md. 10.1).
- **`scenes/enemies/KnifeAgent.tscn`** (EnemyBase'i miras alır) + `knife_agent.tres`
  + `knife_agent_frames.tres` — Bıçaklı Ajan: hızlı, 22 can, `uses_dash = true` → menzile girince
  geri çekilip telegraph'lı dash ile saldırır (md. 10.2). TestLevel'de 2 adet.
- **`scenes/enemies/RifleGuard.tscn`** (EnemyBase'i miras alır) + `rifle_guard.tres`
  + `rifle_guard_frames.tres` — Tüfekli Muhafız: `is_ranged = true` → `ranged_preferred_distance`
  mesafesini korur, `aim_time` telegraph'ından sonra `burst_count`'luk seri ateş açar; oyuncu
  `panic_range`'e girerse dipçik (yakın dövüş) atar (md. 10.3). EnemyBase'e `RANGED` durumu + `$Muzzle`.
- **`scenes/enemies/ArmoredBruiser.tscn`** + `armored_bruiser.tres` — Zırhlı Vurucu: 60 can,
  `damage_taken_mult = 0.55` (kalıcı zırh), `knockback_resist = 0.6`, `block_chance = 0.35`
  (darbeyi bloka geçip yutar), `heavy_attack_chance = 0.4` (yavaş telegraph'lı `guard_break`,
  20 hasar + büyük geri itme) (md. 10.4).
- **`scenes/enemies/AgileAssassin.tscn`** + `agile_assassin.tres` — Çevik Suikastçı: 18 can, hızlı,
  `is_agile = true` → saldırı menzili dışında ama yakınsa oyuncuya sıçrar (`LEAP`), düşüşte
  drop-strike hitbox'ı açılır; `evade_chance = 0.5` → darbe alınca çoğu zaman geri kaçar (md. 10.5).
- **`scripts/systems/breakable_wall.gd`** + **`scenes/systems/BreakableWall.tscn`** — StaticBody2D
  yolu kapatır; `apply_hit` (Redmount saldırısı / mermi) ile `hits_to_break` kez vurulunca çöker,
  ardındaki gizli ödül açılır. TestLevel'de spawn'ın solunda 3 gizli coin'i kapatır (md. 15).
- **`scenes/enemies/MiniBoss.tscn`** + `mini_boss.tres` + `mini_boss_frames.tres` — Ağır Zırhlı
  mini-boss (Bölüm 4 sonu, md. 10.6). `is_boss` (HUD can barı), `damage_taken_mult = 0.45`,
  `armor_break_hits = 8` → zırh kırılınca `ARMOR_BREAK` durumunda ~2.4 sn tam hasar + hareketsiz;
  `slam_on_heavy` → ağır saldırıda `Shockwave` çıkarır; `uses_dash` (charge). Kök `scale 1.3`.
- **`scripts/systems/shockwave.gd`** (`class_name Shockwave`) + **`scenes/systems/Shockwave.tscn`** —
  zeminde ileri doğru büyüyen alçak darbe dalgası; `Shockwave.spawn(...)` static. Oyuncu
  **zıplayarak** kaçabilir (hurtbox yükselir). `RectangleShape2D` `resource_local_to_scene`.
- **`scripts/enemies/enemy_config.gd`** boss alanları: `is_boss`, `armor_break_hits/duration`,
  `slam_on_heavy` + `slam_damage/knockback`. EnemyBase sinyali: `boss_health_changed(cur, max)`.
- **`scenes/enemies/TrainingDummy.tscn`** + `scripts/enemies/training_dummy.gd` — GERÇEK DÜŞMAN
  DEĞİL, saf hit-testi için kum torbası (`apply_hit()` alır, K.O. olur, dolu canla döner).
  TestLevel'de 1 pasif adet.
- **`scripts/pickups/pickup_base.gd`** (`class_name PickupBase`) + **`scenes/pickups/PickupBase.tscn`** —
  Area2D; yalnız oyuncu gövdesini algılar, süzülür (bob), değince `_collect()` (alt sınıf) + sönme.
  Miras alan sahneler: **`Coin.tscn`** (`GameState.add_coins`), **`HealthPickup.tscn`**
  (`player.heal`), **`BatPickup.tscn`** / **`KnifePickup.tscn`** (`player.equip_weapon`),
  **`PistolPickup.tscn`** (`player.equip_gun`), **`AmmoPickup.tscn`** (`player.add_ammo`),
  **`ArmorPickup.tscn`** (`player.equip_armor`), **`PowerupPickup.tscn`** (`player.apply_powerup` —
  generic; her TestLevel örneği kendi `.tres` + ikonunu verir).
- **`scenes/ui/HUD.tscn`** + `scripts/ui/hud.gd` — Redmount can çubuğu + coin sayacı +
  silah/dayanıklılık göstergesi + ölüm bilgisi. Coin'i `GameState`'ten, can/silahı Main
  üzerinden Redmount sinyallerinden alır. Ana plan md. 13'teki tam HUD (zırh, skor, bonus
  ikonları, boss barı) sonraki görevlerde.
- **`scenes/levels/TestLevel.tscn`** — düz zemin + boşluk + yükseltiler + platform + düşme
  testi + duvarlar + engel + 1 TrainingDummy + 3 Sokak Eşkıyası + coin/kalp/sopa pickup'ları
  + 1 kontrol noktası (x≈960) + bölüm bitiş noktası (sağ uçta). Görseller placeholder
  `Polygon2D` kutular / ikonlardır.

## Çarpışma katmanları (`project.godot` → `[layer_names]`)

`1 world · 2 player · 3 enemy · 4 player_hitbox · 5 enemy_hitbox · 6 player_hurtbox · 7 enemy_hurtbox`

## Pixel-art ayarları

- `rendering/textures/canvas_textures/default_texture_filter = 0` (Nearest, filtreleme kapalı)
- `display/window/stretch/mode = viewport`, `scale_mode = integer`
- Sprite hedef hücresi 128×256 px, ayak tabanı baseline'ı tüm karelerde y=0.

## Placeholder sanat

`assets/characters/redmount/placeholder_*.png` — üzerinde "PLACEHOLDER" yazan geçici kutular
(`knockdown` / `dead` yatık çizilir). Gerçek sprite'lar geldiğinde bu dosyaların yerine konur;
`redmount_frames.tres` içindeki kareler gerçek sheet'lere göre çoğaltılır.
