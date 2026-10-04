# REDMOUNT: Sokaklar — mobil (Dan the Man tarzı)

Eski `redmount/` projesinden bağımsız, sıfırdan kurulmuş mobil oyun. Tüm görseller
senin tasarımlarından geliyor: `art/chars/` animasyon şeritleri (200×240, ayak çizgisi y=234),
`art/kit/` platform kitinden kesilmiş parçalar, `art/bg/` sahne çizimleri.

**Çalıştır:** kökteki `OYNA_MOBIL.cmd` (PC'de 20:9 telefon oranında açar).
Fare dokunmatik gibi çalışır; klavye: A/D koş, Space zıpla, J vur, K özel, S aşağı, Esc duraklat.

## Oynanış
- Koşu, değişken zıplama (basılı tut = yüksek), coyote/buffer, **duvar zıplaması** (tek duvara tırmanılır).
- 4 vuruşluk kombo (fight → combo_a → punch → knee; sonuncusu yere serer), havada **uçan tekme**.
- **ÖZEL**: vuruşlarla dolan bar, yarısını harcayıp uçan diz atılır.
- **Sopa** (14 vuruş, sonra kırılır), **tabanca** (12 mermi, VUR ile ateş).
- Düşmanlar: sokak eşkıyası, bıçaklı ajan (kırmızı `!` telegrafı + atılma), tüfekli muhafız (kırmızı lazerle nişan).
  Aynı anda en fazla 2 düşman saldırır; yere serilen düşman kalkar.
- **Kilitli arenalar** (dalga dalga, iki yandan), kırılabilir vazo/saksı, kırılabilir tuğla niş = gizli oda,
  kontrol noktası (bayrak), çukura düşünce hasar + son güvenli zemine dönüş.
- Bölüm sonu: 3 yıldız (bitir · haritadaki coin'lerin %80'i · tüm gizli alanlar).

## Bölüm 1 — Mahalle
Referans şeridi sırasıyla: Köşe Çay → yol çalışması/iskele → duvar + çatılar →
Kontrol Büfesi (arena) → Minibüs Parkı → gizli niş odası → Kuzey Hanı (final arenası).

## Yapı
| Dosya | Görev |
|---|---|
| `scripts/level.gd` | Bölüm tabanı + kurulum API'si (`ground`, `ledge`, `platform`, `prop`, `coin_*`, `enemy`, `breakable`, `arena`, `checkpoint`, `secret`, `hint`, `goal`), kamera, paralaks |
| `scripts/levels/level_01.gd` | Bölüm 1 düzeni |
| `scripts/player.gd` / `enemy.gd` | Oyuncu ve düşman YZ; animasyon ve vuruş kareleri tabloda |
| `scripts/hud.gd` / `touch_controls.gd` | HUD, duraklat/yenilgi/sonuç ekranları; çoklu dokunuş kontrolleri |
| `tools/slice_kit.py` | Platform kitini parçalara böler (+ taş dolgu, portre, ikon) |
| `tools/gen_icons.py` | Coin / simit / sopa / tabanca piksel ikonları |

## Doğrulama
```
godot --headless --fixed-fps 60 --path mobile res://tests/bot.tscn -- 300
```
Bot gerçek girdi eylemleriyle bölümü baştan sona oynar ve özet yazar.
`tests/capture.tscn -- <klasör> x,y ...` noktalardan ekran görüntüsü alır; `tests/wallclimb.tscn` duvar tırmanışını ölçer.

## Sıradaki
Bölüm 2+ (`level02_armed_checkpoint` vb. arka planlar hazır), mağaza (cüzdan kaydediliyor),
Gazelle/Karahanlı ara sahneleri, mini-boss (Ağır Zırhlı şeritleri hazır), Android dışa aktarma ayarı.
