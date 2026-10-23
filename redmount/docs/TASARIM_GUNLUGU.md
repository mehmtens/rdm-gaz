# REDMOUNT — Tasarım günlüğü

Otomatik "oyun tasarımcısı" turlarının tarihli kayıtları. Her tur tek tutarlı
iyileştirme yapar; sayılar insan testi gelene kadar hipotezdir.

## Tasarım birikimi

Sıradaki adaylar (üstteki önce). Yol haritasında açık madde varken önce o yapılır.

- Hız yıldızının par süresi bölüm başına ayarlanmalı: 34 bölümde düz 240 sn, bot
  ~80 sn'de bitiriyor. İnsan testinden gelen ortanca sürenin ~0,8'i hedef (ilk koşuda
  zor, ikinci koşuda alınabilir); `par_time` her `Bolum*.tscn`'de elle.
- Sonuç kartında önceki koşularda kazanılmış ama bu koşuda alınamamış yıldızı soluk
  altınla göstermek (oyuncu neyin kalıcı olduğunu görsün).
- Telefonda dokunmatik ölçüm: yanlış/kaçırılan basış sayacı (insan testi formuyla bağlanacak).
- KAY düğmesinin yeri gerçek cihazda başparmak erişimiyle doğrulanacak; gerekirse
  oyuncu düğme düzenini sürükleyerek kaydedebilsin (Save'e `touch_layout`).

## Tur kayıtları

### 2026-10-23 (2) — Bölüm sonu yıldızları (Yol haritası 9)

**Neden şimdi:** Yol haritasındaki ilk açık madde. S/A/B/C harfi 5 ağırlıklı
etkenden (süre, hasar, düşman, coin) puanla çıkıyordu; oyuncu neden A aldığını,
S için ne yapması gerektiğini göremiyordu. Üç ayrı, adı konmuş hedef tekrar oynama
sebebini açıkça söyler ve yıldız koşular arası birikir — her koşu tek bir hedefe
odaklanabilir.

**Oyuncu ne hissedecek:** Bölüm biter, kart açılır, kazanılan yıldızlar soldan
sağa bir coin sesiyle büyükten yerine "çakılır"; kazanılmayan yuva oyulmuş mürdüm
yıldız olarak kalır ve altındaki yazı (HIZ / HASARSIZ / GİZLİ ALAN) eksiği söyler.
Bölüm seçmede her kartta 3 küçük yıldız, başlıkta toplam ★ x/108.

**Yapılanlar:**
- `tools/gen_pixel_stars.py` → `assets/ui/pixel/yildiz_{dolu,bos}.png` (15×14,
  sonuç kartında 4×) ve `_kucuk` (9×8, menüde 3×); altın 4 ton + parıltı pikseli.
- `Save.stars` (index → bit maskesi; `progress/stars`, eski kayıtta `{}`),
  `record_stars` (birleştirir, geçersiz bitleri atar), `stars_of`, `star_count`,
  `total_stars`. `is_complete` artık "3 yıldız" (eski S + gizli alan kuralının yerine;
  önceden alınmış ustalık ödülleri `mastered`'da kalır).
- `main.gd`: `_compute_rank` → `_compute_stars`; iki bitiş yolu da yıldızı kaydeder.
- `hud.gd`: harf rütbesi gizli, madalya paneli genişledi, 3 yıldız + alt yazı, sıralı
  açılış animasyonu; `show_stage_clear/show_results` artık maske alır (-1 = yok).
  Uzun "Yeni vuruş mağazada" ipucu kartın dışına taşıyordu, kısaltıldı.
- `main_menu.gd`: rütbe rozeti yerine 3 küçük yıldız, BÖLÜM SEÇ başlığında toplam.

**Sayılar (hipotez):** HIZ = `elapsed ≤ par_time` (mevcut par; 34 bölümde 240 sn).
HASARSIZ = 0 isabet — kesin ve okunur bir hedef; yıldız kalıcı olduğundan ayrı bir
koşuda denenebilir, bu yüzden "≤1" gibi gevşetme yapılmadı. GİZLİ ALAN = kayıtlı en
iyi bulunan sayısı ≥ toplam (gizli alansız bölümde bedava). Açılış 0,45 sn sonra,
yıldızlar arası 0,32 sn — kart okunurken ritim, R'ye basmayı geciktirmeyecek kadar kısa.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS (ustalık testi yıldızlara uyarlandı); yeni `tests/level_stars.tscn` PASS
(birleştirme, geçersiz bit, eski kayıt uyumu, kartta doğru yıldızların dolması,
survival'da gizli); bot Bölüm 1 (78,7 sn), 13 (81,6 sn), 25 (80,7 sn) CLEARED.
1280×720 ekran görüntüsünde sonuç kartı ve bölüm seçme kontrol edildi (boş yıldız
ilk hâlinde okunmuyordu, tonu açıldı; orta yıldız başlık şeridine değiyordu, indirildi).

**Sonraki öneri:** Yol haritası 10 — kitap geçiş sinematikleri (piksel çizgi roman
panelleri).

### 2026-10-23 — Dokunmatik kontrol cilası (Yol haritası 8)

**Neden şimdi:** Yol haritasındaki ilk açık madde. Dokunmatik düğmeler hâlâ
yumuşak degrade daire + sistem yazı tipiydi; oyunun geri kalanı piksel art.
Telefonda kayma tekmesi pratikte erişilemezdi: koşarken (sol başparmak ◀/▶'da)
aynı başparmakla ▼'a basmak gerekiyordu.

**Oyuncu ne hissedecek:** Düğmeler HUD ve menülerle aynı piksel ailesinden
(koyu mürdüm gövde, altın halka, basılınca ateş rengine dönüp bir piksel
gömülme). Sağ başparmakla tek dokunuşta `KAY` → kayma tekmesi. Her eylem
düğmesinde çok kısa bir titreşim tıkı; istemeyen duraklatma menüsünden kapatır.

**Yapılanlar:**
- `tools/gen_pixel_touch.py` → `assets/ui/pixel/touch_{buyuk,kucuk,mini,genis}[_basili].png`
  ve `touch_ikon_{sol,sag,asagi,durdur}.png`; oyunda NEAREST, ~4x ölçek.
- `TouchControls`: degrade `_disc` kaldırıldı; piksel dokular, `PixelUI.font()`,
  ok/duraklat için piksel ikon, basılıyken ikon/yazı 1 sanat pikseli iner.
- Yeni `slide` girdi eylemi + `KAY` düğmesi; `redmount.gd` yerdeyken `slide`
  basılınca koşu şartı olmadan `slide_kick` başlatır (hamle kendi 640 hızını verir).
  İpucu rozeti dokunmatikte `KAY`.
- `Save.vibration` (`settings/vibration`, eski kayıtta varsayılan açık);
  `Combat.rumble` buna uyar; duraklatma menüsünde yalnız dokunmatik cihazda
  `TİTREŞİM: AÇIK/KAPALI`.

**Sayılar (hipotez):** Tık 12 ms / güç 0.3 — fark edilir ama isabet titreşimini
(20–65 ms) bastırmayacak kadar kısa. Hareket oklarında tık yok: başparmak oklar
arasında kayarken (`passby_press`) sürekli vızıldamasın. KAY düğmesi sağ kümenin
iç üst köşesinde (zıpla merkezinden ~150 px), oyun alanını kapatmayacak yükseklikte.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0;
`tests/dtm_gaps.tscn` PASS; yeni `tests/touch_polish.tscn` PASS (piksel doku +
yazı tipi, KAY → slide_kick, titreşim ayarı kayıt uyumu, menü düğmesi);
bot Bölüm 1 (83,4 sn), 13 (77,4 sn), 25 (91,8 sn) CLEARED. 1280×720 ekran
görüntüsünde düğmeler ve menü kontrol edildi; telefonda görülmedi.

**Sonraki öneri:** Yol haritası 9 — bölüm sonu 3 yıldız (hız, hasarsızlık, gizli
alan) + menüde toplam yıldız.
