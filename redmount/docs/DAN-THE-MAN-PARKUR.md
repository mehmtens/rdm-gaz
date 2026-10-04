# REDMOUNT — Dan the Man tarzı İstanbul parkur setleri

**Durum:** Uygulandı (Ekim 2026). Kod: `scripts/systems/parkour_set.gd`,
`scripts/systems/awning_bounce.gd`, `scripts/systems/parkour_layer.gd`,
`scripts/systems/parkour_interiors.gd`. Test pisti: `tests/ParkourTest.tscn`.

## Neden

Kampanya bölümleri uzun ve okunaklı, ancak Kitap 2 ve 3'te bölümlerin büyük kısmı
düz sokak + üç basamaklı tek yön platform tekrarından oluşuyordu. Dan the Man'in
seviye dilinden alınan ders şudur: **her ekranda tek, okunur bir hareket fikri**;
fikir önce güvenli yerde gösterilir, sonra düşmanla ve başka fikirlerle birleşir;
keşif her zaman somut ödül verir; ölüm cezası kısa tutulur.

REDMOUNT bu ritmi kopyalamaz, İstanbul mekânlarıyla yeniden kurar. Hiçbir set
düz renk kutu, soyut geometri veya oyunun dünyasına yabancı bir yapı kullanmaz.
Bütün görseller mevcut mahalle piksel sanat setinden gelir: tezgâh tentesi,
kiremitli bahçe duvarı, cumbalı/balkonlu evler, baca ve taş direkler, depo
sandıkları, ahşap iskele.

## Hareket ölçüleri (MovementConfig'ten)

| Hareket | Değer |
|---|---|
| Zıplama yüksekliği | ~120 px |
| Koşarak sıçrama menzili | ~265 px |
| Tente sıçrayışı | ~240 px; zıplama basılıysa ~345 px |
| Duvar kayma / zıplama | duvarlar arası 160 px rahat |

## Set sözlüğü

### Dış mekân (gökyüzü görünen sokak, sahil, meydan)

| Set | Fikir | Ana yol mu? | Ödül |
|---|---|---|---|
| **tente_duvar** | Tezgâha çık, tente seni fırlatır, kiremitli bahçe duvarını aş | Evet (duvar zemini keser) | Sıçrama eğrisini çizen coin yayı |
| **balkon** | Evin yüzüne asılı üç balkonu basamak gibi kullanıp çatıya çık | Evet (ev zemini keser) | Çatıda coin, bazen can |
| **cati** | Tenteden çatıya; ara sokakları atlayarak üç evlik çatı zinciri | Evet | Her çatıda coin, bazen cephane |
| **sekme** | Üç tezgâh + iki duvar; her tente duvarın dibine dayalı, sek-sek-sek | Evet | Son tentede zıplama basılı tutana kemer üstü ödül |
| **baca** | İki asılı baca duvarı arasında duvar zıplaması | Hayır (altından geçilir) | Tepede can / zırh / cephane |

### İç mekân ve depo (gökyüzü görünmeyen han, hamam, sarnıç, pompa, matbaa)

| Set | Fikir | Ana yol mu? | Ödül |
|---|---|---|---|
| **kasa** | 60 px'lik sandık basamaklarıyla 180 px'e çık, öbür yandan in | Evet | Tepedeki rafta can / zırh / cephane |
| **iskele** | Barikatın yüzüne çatılmış iki iskele katıyla 230 px'lik sandık yığınını aş | Evet | Basamak coinleri |
| **direk** | Baca setinin kiremitsiz, iç mekân hâli | Hayır | Tepede ödül |

## Güvenlik kuralları

1. Hiçbir set ölümcül boşluk içermez. Düşen oyuncu sokağa iner ve aynı yerden tekrar dener.
2. Ana yolu kesen her engelin önünde tek tuşla kullanılabilen bir çözüm vardır
   (tezgâh 60–64 px, balkon / iskele 105–110 px aralıklarla).
3. Duvar zıplaması yalnız isteğe bağlı ödül setlerinde (baca / direk) gerekir.
4. Coin dizileri izlenecek yolu çizer. Oyuncu sıçramadan önce nereye ineceğini görür.

## Yerleşim (ParkourLayer)

* Her kampanya bölümü yüklenince `Level._spawn_parkour()` katmanı kurar.
* Yalnız **aynı yükseklikte kesintisiz zemin** üstüne kurulur.
* Çevresine girilmeyen alanlar:
  * düşman ±280 px, kontrol noktası ±420 px, dükkân ±680 px;
  * ipucu / diyalog / mekân tabelası ±260 px, toplanabilir ±180 px, coin ±70 px;
  * arena kapılarının arası ve diğer bütün platform ve yapılar.
* Bölüm başında 1400 px serbest kalır. Bitiş kapısından önce 900 px boş bırakılır.
* İki set arasında en az 1500 px nefes alanı vardır. Hedef yoğunluk 4200 px'de bir settir.
* Set havuzu perdeye göre açılır (öğret → uygula → birleştir):
  * **Kitap 1:** Perde I tente + balkon; Perde II'de çatı, III'te sekme, IV'te baca eklenir.
  * **Kitap 2 ve 3:** Tüm setler dönüşümlü kullanılır, sıra perdeye göre değişir.
* İç mekân seçimi `parkour_interiors.gd` tablosundan gelir. Her bölüm 1500 px
  aralıkla görüntülendi (`tests/capture_interiors.tscn`). Dış mekân aralıkları
  görüntülere bakılarak elle etiketlendi (`tools/gen_parkour_interiors.py`).
  Bunlar açık gökyüzü görünen sokak, sahil ve bahçelerdir. Gerisi iç mekân sayılır:
  sandık ve iskele, rıhtımda ve avluda da doğal durduğu için güvenli taraf budur.
  Setin kapladığı aralığa iç mekân değiyorsa iç mekân havuzu kullanılır.
* Yerleşim deterministiktir: aynı bölüm her açılışta aynı düzeni kurar.

Kitap 1 bölümleri zaten elle sık tasarlanmıştır (yaklaşık her 800 px'de düşman ya da
basamak). Bu yüzden orada kurallara uyan az sayıda boşluk bulunur. Bu bilinçli bir
tercihtir: elle yapılmış ritim bozulmaz.

## Ayar ve test

* Setlerin ölçüleri `ParkourSet.WIDTHS` ve `_build_*` fonksiyonlarındadır.
* Test pisti tüm setleri sırayla dizer. Bot geçişi:
  `REDMOUNT_LEVEL_PATH=res://tests/ParkourTest.tscn REDMOUNT_PROBE_LEVEL=0 godot --headless --path . res://_autoplay.tscn`
* Kampanya botu (`_autoplay.gd`) duvar zıplamasını yalnız düşerken dener.
  Tentenin yükselen kolunda duvardan geri itilmez.
