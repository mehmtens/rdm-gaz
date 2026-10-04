# Kitap 3 / Bölüm 12 — Son Yayın: İstanbul'un Sesi

Hedef: yaklaşık 20 dakikalık final. Nihai yükseltmesiz ana yol testi **18:16**;
bu bot diyalogları hızla geçer ve isteğe bağlı rafları araştırmaz. İnsan oyuncunun
ilk bitirme süresi henüz ölçülmedi. Aşağıdaki aralıklar tasarım hedefidir.

Doğrulama: 1096,0 saniye, sıfır yeniden doğma; üç bağlantı, üç boss evresi,
her evrede boss saldırısı, epilog ve kayıt kontrolleri geçti. 36 bölüm ve menü
yükleme testi geçti. Hızlandırılmış headless süreç kapanışında Godot ses
kaynakları için uyarı verdi; oynanış kontrolleri başarılıydı.

| Akış | Mekân / oyuncunun kararı | Anlatı sonucu |
|---|---|---|
| 0–3 dk | Göksu kayıkçı yolu, tekne atölyesi. Tekli düşmanlar, sığ iniş, ikmal rafı, ilk iki dalgalı karşılaşma. | Cağaloğlu kayıtlarını yayına çıkarma amacı. |
| 3–7 dk | Yükleme iskelesi ve ana güverte. 220 px ek boşluklarında sabit iskele basamağı; alçak ana yol / zırhlı üst raf seçimi. | Kıyı hattı kapanır: 1/3. |
| 7–11 dk | Kablo geçidi ve yedek dinamo. Önce menzilli, sonra yakın dövüş baskısı; dinamoda ağır düşmanla karşılaşma. | Mavnanın yedek kumandası kapanır: 2/3. |
| 11–14 dk | Kaset arşivi ve yayın odası. Cephaneli yan raf, suikastçı–tüfekli birleşimi, son bağlantının korunması. | Kayıtların kopyaları kıyıya ulaşır; susturucu kapanır: 3/3. |
| 14–18 dk | Anten güvertesi ve kıç güverte. Son birleşik karşılaşma, ikmal ve ayrı boss kontrol noktası. | Gazelle kaydı yayına verir; Redmount yayını korur. |
| 18–20 dk | Üç evreli düello, sessiz kumanda, sabah kıyısı. Son yürüyüşte tuzak veya yeni düşman yok. | Kayıtlar yayılır, matbaa yeniden basar, su hattı açık kalır; iki karakter dinlenmeye döner. |

## Dövüş

Yayın Şefi tek bir 420 canlık düşmandır; evreler yeni can çubuğu doldurmaz.
İlk evre ağır darbeyi her üçüncü saldırıda kullanır. Canın üçte ikisinde
işaretli dash ve daha hızlı takip; son üçte birde her ikinci saldırıda
zemin dalgası ve daha uzun karşı saldırı penceresi vardır. Normal yumruk
hazırlığı başlamış hamleyi iptal etmez; hasar yine işler. Beş isabet zırhı
kırar, temel saldırılarla da kazanılır. Yere çakma gibi açılmış hareketler
ek avantaj sağlar. Yeni mobil düğme yoktur.

Boss mevcut mini-boss animasyonlarını kullanır; davranış, renk ve isim bu finale
özeldir. Saldırılar havada kaçılabilir dalga ve okunabilir hazırlıkla gelir.
Son kontrol noktası düellonun hemen önündedir.

## Sanat ve oynanış sınırları

- 12 ayrı mekân, üç yeni arka plan atlası; gece → analog odalar → şafak.
- Dört malzeme: taş rıhtım, ahşap iskele, perçinli gemi gövdesi, kabin döşemesi.
- Dört ayrı ikmal resmi; aynı sokak büfesi geminin içine taşınmaz.
- Ana yol ±60 px kot değiştirir; üst raflar isteğe bağlıdır. Sandıklar rafın
  merkezinde ve çarpışma yüzeyi üstündedir. Kırılma durumları mevcut sistemden gelir.
- Üç bağlantı arenası tamamlanmadan ve boss yenilmeden bitiş etkinleşmez.
- Boss sonrası yeni bir tehdit veya devam kitabı kancası yoktur. Cağaloğlu'nda
  başlayan susturma planı kamuya açıklanır; Gazelle sonucun etkin öznesidir.

## Çalıştırma ve kontrol

Menü: **K3-12**. Sahne: `scenes/levels/Book03Level12.tscn`.

`Godot --headless --path redmount --script res://tests/campaign_smoke.gd`

`Godot --headless --path redmount --fixed-fps 60 res://tests/book03_level12_play.tscn`

Test yükseltmeleri kapatır; bütün rotayı, 18–22 dakika aralığını, üç bağlantıyı,
boss'un üç evresini ve her evrede saldırmasını, epiloğu ve kaydı denetler.
`REDMOUNT_TEST_SPEED=8` isteğe bağlıdır: fizik simülasyon adımı 1/60 sn kalır.
Testler izole `APPDATA=C:/rdm-gaz/.godot-user` ile çalıştırılır.

Görsel üretim yöntemi, kaynak dosyaları ve tam promptlar:
[BOOK03-FINALE-ART-PROMPTS.md](BOOK03-FINALE-ART-PROMPTS.md).
