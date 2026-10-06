# REDMOUNT — İstanbul parkur sahneleri ve bölüm denetimi

**Durum:** Uygulandı (Ekim 2026). Kod: `scripts/systems/parkour_set.gd`,
`scripts/systems/awning_bounce.gd`, `book02_level01.gd` içindeki `_encounter()`.
Denetim aracı: `tests/level_audit.tscn`. Test pisti: `tests/ParkourTest.tscn`.

## Sorun neydi?

**Kitap 2 ve 3:** 24 bölüm aynı şablondan çıkmıştı.

- ~110.000 px uzunluğunda düz yol vardı.
- Her ~7.000 px'de yalnız bir düşman çıkıyordu.
- Her bölümde 5–6 kez aynı "havada asılı üç platform + coin" piramidi tekrarlanıyordu. Bu tentelerin altında hiçbir şey yoktu.
- Tehlike yoktu.

Parkur ile dövüş birbirine hiç değmiyordu. Oyuncu, piramitlere çıkmadan düz yolda koşarak bölümü bitirebiliyordu.

Bir ara denenen otomatik "boş sokağa set diz" yaklaşımı (657 set) bu yüzden geri alındı.
Yoğunluğu artırıyor, setleri düşmanlardan uzak tutuyordu. Sorunu çözmüyor, üstüne ekliyordu.

## Yeni yaklaşım: aynı yerde, daha iyi bir sahne

Tasarımcının parkur için ayırdığı her noktada (her piramit, her `_reward_path`) artık
mekâna uygun, düşmanlı bir parkur sahnesi var. Bu yüzden:

- Yeni yoğunluk eklenmez.
- Kontrol noktaları, arenalar, dükkânlar, diyaloglar ve hikâye akışı yerinde kalır.
- Zemindeki 200 px'lik su/çukur boşluklarının üstündeki köprüler korunur.

| Sahne | Mekân | Fikir | Düşman |
|---|---|---|---|
| `cati` | sokak, sahil | tenteden çatıya, ara sokakları atlayan üç evlik çatı zinciri | 2. ve 3. çatıda bekleyen |
| `balkon` | sokak | evin balkonlarını basamak gibi kullanıp çatıya çık | çatıda bekleyen |
| `tente_duvar` | çarşı | tezgâh tentesi fırlatır, kiremitli bahçe duvarını aş | duvar tepesinde tüfekli, iniş noktasında yakın dövüşçü |
| `sekme` | rıhtım, çarşı | üç tente, iki duvar: sek-sek-sek ya da aradaki çukurlarda dövüş | iki aralıkta birer düşman |
| `kasa` | depo, han, hamam | sandık basamaklarıyla yığının tepesine çık | Kitap 2: tepede ağır birlik. Kitap 3: iniş tarafında seçkin muhafız |
| `iskele` | depo, iç mekân | iskele katlarıyla yüksek barikatı tırman | barikat üstünde tüfekli |
| `engel` | dar iç mekân | iki katlı sandık siperi | siperin arkasında bekleyen |

Düşman türü kitaba göre ilerler: sokak serserisi → bıçaklı → suikastçı → seçkin muhafız.
Tüfekli yalnız yüksekte bekler. Dar çatı, balkon ve sandık tepesine seçkin muhafız konmaz.
Seçkin muhafız uzaktan ateş eder ve ağır vuruşu oyuncuyu 380 hızla iter. 180 px'lik sandık
tepesinde geri çekilemez; basamaktan çıkan oyuncuyu siper vermeden vurur. Bot koşularında
Kitap 3'teki bütün uzun takılmalar (56–68 sn, bölüm başına 2–3 ölüm) bu noktadaydı.
Bu yüzden Kitap 3'te muhafız yığının iniş tarafındaki düz zeminde bekler.

Adil olma kuralları:

- Bölümün ilk sahnesi fikri tanıtır, tek nöbetçi taşır.
- Sahneden önceki 2.500 px'de kontrol noktası yoksa sahnenin 320 px önüne bir tane
  eklenir. Sahne zemin parçasının başına dayalıysa bayrak parçanın ilk adımına konur.
  Böylece sahnede ölen oyuncu bölüm başına dönmez.
- Ölü cep yoktur: tezgâh tentesi duvarın ya da evin dibine dayalıdır. Ara sokağa düşen
  oyuncu iki balkonla ileriye doğru çatıya döner.
- Tentenin üstünde basılan zıplama da tam güç fırlatmadır. Yükselirken tuşu bırakmak
  fırlatmayı kesmez.

Hangi noktaya hangi sahnenin konacağı her bölüm dosyasında açıkça yazılıdır
(örnek: `_encounter("balkon", 17300, ARMOR)`). Seçim, o noktanın mekânına göre
yapıldı: açık gökyüzü görünen sokak, sahil ve bahçede dış mekân sahneleri, han,
hamam, sarnıç ve depoda iç mekân sahneleri kullanıldı. Ardışık iki sahne aynı türde
değildir. Final bölümlerinde ödül yolları (`_reward_path`) aynı kuralla sahneye çevrilir.
İç mekânda sandık, iskele ve siper; dışarıda tente-duvar ve balkon sırayla gelir.

Çeşitlilik konusunda açık olmak gerekirse: 168 sahne yedi şablondan gelir. Şablonlar
mekâna, ev çeşidine, ödüle ve nöbetçinin türüne göre değişir. Ama her sahne ayrı elle
tasarlanmış bir parkur değildir.

Sahne, altındaki düz zemin parçasına oturur. Parçadan taşacaksa kaydırılır, sığmıyorsa
küçük siper (`engel`) kullanılır. 60 px alçak sokaklar da dahildir.

## Oyun genelindeki düzeltmeler

- **Düşmanlar tek yön platformlarda durur.** Önceden yalnız katı zemini görüyorlardı.
  Bu yüzden Bölüm 1'de çatılara ve tentelere yerleştirilen 9 düşman bölüm açılır
  açılmaz sokağa düşüyordu. Kenar algıları da platformu zemin sayar; çatı kenarında
  geri dönerler.
- **Tente ve çatı platformları havada asılı kalmaz.** Altındaki zemine kadar ahşap
  direk (tente) ya da taş sütun (çatı) çizilir. Çukur üstündekilere direk çizilmez.
- **Zemin hizası:** Kitap 2 ve 3'te zemin hizasındaki düşman, ödül ve sandıklar
  altındaki zeminin yüzeyine oturtulur. Böylece alçak sokakta havada doğmaz,
  yükseltilmiş kaldırımda zemine gömülmez.
- **Bölüm bazlı hatalar:**
  - Bölüm 4 açılışı: dikenli çukur + hareketli vinç ve çöken köprü sahneleri, iki zemin
    parçası üst üste kaydırıldığı için kapanmıştı. Çukurlar yeniden açıldı. Yangın
    merdiveni basamakları duvarın içinden çıkarıldı.
  - Gömülü ödüller: Bölüm 2, 3, 5, 9, 11, 12 ve Kitap 3 Bölüm 7'de zemine ya da bloğa
    gömülü coin, can ve zırh paketleri düzeltildi.
  - Ulaşılamayan ödül platformları: Bölüm 6, 8 ve 10'da düzeltildi.

## Gece sahnelerinde okunurluk (Kitap 3)

Vaniköy ve Son Yayın gibi karanlık iç mekânlarda siyah giysili düşmanlar ve ince ahşap
iskeleler arka plana karışıyordu. Oynanış ve düşman gücü değişmedi; yalnız iki çizim
kuralı eklendi. Bunlar yalnız Kitap 3'te (`dark_scene` grubu) açıktır:

- **Düşman konturu** (`shaders/dark_rim.gdshader`): sprite'ın saydam kenar pikselleri,
  bölümün kenar ışığı renginde (`level.gd` `edge_light`, fener sarısı) ince bir kontura
  döner. Gövde renkleri, vuruş parlaması ve ölüm solması aynen kalır.
- **İskele ve raf kenarı:** ince tek yön platformların basılan yüzüne, oyunun zeminlerde
  zaten kullandığı kural çizilir: 3 px kenar ışığı ve altına koyu bir şerit. Çizgi
  çarpışma yüzeyiyle hizalıdır.

## Denetim araçları

`tests/encounter_check.tscn` (Kitap 2–3) şunları bildirir:

- `GUARD_LEFT`: 2 sn fizikte sahnesinden düşen ya da çıkan nöbetçi
- `CP_IN_ARENA`: kilitli arenanın içine düşen kontrol noktası
- `CP_CROWDED`: 700 px'ten yakın iki kontrol noktası
- `NO_CP`: önündeki 2.500 px'de kontrol noktası olmayan sahne
- `SET_IN_ARENA`: arena kapılarıyla çakışan sahne

Kalan iki `CP_CROWDED`, Son Yayın'daki köprü geçişlerinin kendi bayraklarıdır. Bunlar bu
değişiklikten önce de vardı.

`tests/level_audit.tscn` tüm bölümlerin geometrisini tarar:

```
cd redmount
godot --headless --path . res://tests/level_audit.tscn
AUDIT_LEVELS=12,13 AUDIT_PROBE="17300,-150" godot --headless --path . res://tests/level_audit.tscn
```

Her bölüm için şunları bildirir:

- **Özet:** uzunluk, düşman sayısı ve yoğunluğu, en uzun düşmansız koşu, tehlike sayısı.
- **Sorunlar:**
  - `ENEMY_AIR` / `ENEMY_FELL`: havada doğan, 1,5 sn fizikte düşen düşman
  - `ITEM_SOLID` / `ITEM_HIGH`: gömülü ya da ulaşılamayan ödül
  - `PLAT_UNREACH` / `PLAT_INSIDE`: çıkılamayan ya da gövde içinde kalan platform

Hareketli platformların yolu ve tente sıçrayışı hesaba katılır. Kalan birkaç uyarı
zararsızdır: 20–40 px yukarıda doğup yere inen düşmanlar ve hareketli platformdan
ulaşılan ödüller.

## Doğrulama

- 36 bölüm yükleniyor (`tests/campaign_smoke.gd`).
- 36 bölümün 36'sı uçtan uca bot testinde (`tests/levelNN_play`, `tests/book0X_levelNN_play`)
  bölümü bitiriyor. Kitap 1'in 4, 5 ve 6. bölümleri önceden hiç test edilmiyordu.
  Bölüm 6'nın testi iki eski hatayı buldu:
  - Arenadaki 120 px'lik siper zıplamayla aşılamıyordu (gerçek tepe ~115 px). İlk dalga
    siperin öbür yanında doğduğu ve kapılar kilitlendiği için yumruklu oyuncu
    sıkışıyordu. Arena siperleri 90 px'e indirildi; duvar zıplaması çifti olan `Cover1`
    ve `Cover2` aynen kaldı.
  - Eski kısa sahnenin x=4980'deki bitiş duvarı, uzun rotanın kalan 45.000 px'ini
    kapatıyordu ve duvardan sonraki boşluk 290 px'ti. Duvar kaldırıldı, boşluk 200 px'e
    indirildi.
- Kitap 2–3 bot süreleri: bölümler 7:47–8:54, finaller 21:08 ve 19:48. Parkur
  sahnelerindeki dövüşler süreyi yaklaşık yarım dakika uzattığı için test pencereleri
  bölümlerde 7–10 dk'ya, finallerde 18–22 dk'ya genişletildi.
- Geniş süre penceresi gerçek bir takılmayı gizlemesin diye bot, en uzak noktası 50 px
  ilerlemeden geçen en uzun süreyi ölçer. 45 sn'yi aşarsa test düşer. Bu sınır 36
  testin hepsinde geçerlidir (`_assert_no_stall`). Önceki sürümde yalnız Kitap 2–3'te
  vardı; bu yüzden Bölüm 12'deki 68 sn'lik takılma fark edilmemişti. O takılma botun
  hatasıydı: hareketli platformun yan yüzünü duvar sanıp duvar zıplamasıyla geri
  sekiyordu. Bot artık hareketli platformda duvar zıplaması yapmıyor. 36 bölümde şu
  anki en uzun süre 24 sn (Kitap 2 final boss'u); Bölüm 12 artık 20 sn.
- Bot testleri insan oynanışı değildir. Bot, oyuncunun tuş haritasını kullanır ama
  kurallarla oynar: sağa koşar, duvara gelince zıplar, düşmana vurur.

## Ölçüler

| Hareket | Değer |
|---|---|
| Zıplama | ~120 px |
| Koşarak sıçrama | ~265 px |
| Tente | ~240 px; zıplama basılıysa ~345 px |
| Duvar zıplaması | duvarlar arası 160 px |
