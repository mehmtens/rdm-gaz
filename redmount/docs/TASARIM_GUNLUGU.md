# REDMOUNT — Tasarım günlüğü

Otomatik "oyun tasarımcısı" turlarının tarihli kayıtları. Her tur tek tutarlı
iyileştirme yapar; sayılar insan testi gelene kadar hipotezdir.

## Tasarım birikimi

Sıradaki adaylar (üstteki önce). Yol haritasında açık madde varken önce o yapılır.

- Telefonda dokunmatik ölçüm: yanlış/kaçırılan basış sayacı (insan testi formuyla bağlanacak).
- KAY düğmesinin yeri gerçek cihazda başparmak erişimiyle doğrulanacak; gerekirse
  oyuncu düğme düzenini sürükleyerek kaydedebilsin (Save'e `touch_layout`).

## Tur kayıtları

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
