# REDMOUNT — Tasarım günlüğü

Otomatik "oyun tasarımcısı" turlarının tarihli kayıtları. Her tur tek tutarlı
iyileştirme yapar; sayılar insan testi gelene kadar hipotezdir.

## Tasarım birikimi

Sıradaki adaylar (üstteki önce). Yol haritasında açık madde varken önce o yapılır.

- Bölüm 34 son arenasında iki Seçkin Muhafız yan yana (~37 px) nişan alıyordu; bot 101 → 6 can.
  Deney sahnesinde nişan durumunda 64 px aralık korunuyor (tur 30 düzeltmesi), yığılma kovalama
  ya da geri itilme sonrası oluyor; tek karede yeniden üretilemedi. İnsan testinde ya da bir
  sonraki denetimde yeniden görülürse `CHASE` durumundaki ayrışmaya nişancı komşusu eklensin.
- Son arenaya düşük canla varış (Bölüm 4: 16–25 can, Bölüm 5: 29 can, Bölüm 28: 21 can; bot). İki bölümde de
  orta arenadan son arenaya kadar can kaynağı yok (yalnız büfe). İnsan testinde son arenaya
  giriş canı ölçülsün; ortanca %40'ın altındaysa son kontrol noktası önüne kırılabilir simit.
- Adlı rakiplerin görünümü: Binbaşı Kaya, Sur Ağası ve Muhafız Başı ara sahnede Seçkin
  Muhafız (`elite`) görünümüyle konuşuyor, dövüşte Ağır Zırhlı (`miniboss`) olarak çıkıyor; Pusucu
  Kemal ve Yüzbaşı Demir sıradan düşmanla aynı. İnsan testinde karışıklık görülürse ara sahne
  aktörü dövüşteki görünüme eşitlensin, gerekirse ChatGPT tarzında kişiye özgü aksesuar.
- Bot, Bölüm 4 kule köprüsünde (x≈6926, y≈−290) pencereli koşuda bir kez 54 sn takıldı (başsız
  üç koşuda yok). Botun kuleden tüfekliye tırmanma mantığı; oyun hatası değil, bot güncellenebilir.
- Bölüm 9 ilk arena (x≈5000–5700; bot 109 → 25 can, 20 sn takılma) ve Bölüm 12 yalı kesimi
  (x≈4600–5400; bot 2 ölüm, 21 → 7 can): kaba yapay zekâ olabilir; insan testinde ölüm sayısı
  2'yi geçerse yalı arenasının önüne simit.
- Bölüm 22 bakım şaftı arenası (x≈7700–8300): tur 45'te Bombacı+Kalkanlı, sonra Seçkin+Bıçakçı
  (eski: iki Seçkin + Tüfekli). İnsan testinde ölüm sayısı ölçülsün.
- Bölüm 10 son arena (x≈8200–8700, Ağır Zırhlı + iki tüfekli): bot 3 ölüm, 21 sn takılma.
  Kaba yapay zekâ olabilir; insan testinde arena başına ölüm sayısı ölçülsün, 2'yi geçerse
  üçüncü dalgadan bir tüfekli çıkarılsın ya da ikinci dalga sonrası ödül simit olsun.
- Kamera çerçevesi: zemin ekranın %63'ünde (kamera oyuncunun 95 px üstünde), alt %37 zemin altı.
  Mobilde dokunmatik düğmeler bu bantta olduğu için bilinçli; masaüstünde DTM'ye yakın %75 için
  `Camera2D.position.y` yalnız masaüstünde −95 → −150 denenebilir (insan testiyle).
- Bölüm 16 son üçlü (belge odası arenası → mahzen seçkini → teras arenası): bot 115 → 1 can,
  iki yeniden doğma. Tur 45'te teras hafifledi (Suikastçı+Bıçakçı, sonra Kalkanlı+Bombacı);
  insan testinde ölüm hâlâ yığılıyorsa mahzene (x≈8900) simit.
- Bölüm 19 külhan finali (tur 45): Külhanbeyi bire bir + iki alev bacası; bot 4 koşunun 2'sinde
  bir kez öldü. İnsan testinde finalde ölüm 1'i geçerse alev hasarı 12 → 8 ya da tek baca.
- Orta kesimlerde "200 px kanal + tam üstünde 220 px sağlam plank" kalıbı (tur 60 taraması):
  14 (3900), 15 (6000, 8000), 16 (6900, 8650), 17 (7500, 8850), 18 (7450, 8700), 19 (7200,
  8950), 20 (7550, 8700), 21–23 (8600), 24 (9000, 11450, 13750), 25 (8450), 29 (5300). Kanal
  oynanışta yok, plank üstünden yürünüyor. Bölüm başına bir tur; yere göre: açık atlama
  (çıkış taşı ŞART: `_terrain(x1-50, x1, 55)`), çürük tahta, palet, ayak taşı ya da kanalı
  tamamen kaldırma. 13'ün ilk açıklığı (kayıkçı iskelesi), 35 ve 36 kasıtlı köprü.
- Bölüm 27 kablo koridoru (x≈7300–7500) ve final: bot 5 koşunun 4'ünde 1–2 yeniden doğma (tur 59,
  değişiklik öncesi de 2). İnsan testinde ölüm yığılırsa koridor arenasına simit.
- Bölüm 24 finali (kule terası, x≈17600–18100): bot 4 koşunun 4'ünde de 2 yeniden doğma (tur 57;
  değişiklikten önceki sürümde de aynı). İnsan testinde final ölümü 1'i geçerse son kontrol
  noktası önüne simit ya da Ana Vana Muhafızı'nın yardımcı dalgası hafifletilsin.

- Ön sıra katı evler yalnız 6 bölümde (1, 2, 3, 27, 29, 34; çoğu Kitap 1 Balat — yerine uygun).
  27/29/34'teki 2–3 ev insan testinde yere yabancı görünürse o bölüme özgü cephe çizilmeli
  (26 Ekim düzeltmesi: Bölüm 30'daki evler arka sıraydı, kapatıldı; yalı cephesi gereksiz).

- İpucu sırası insan testi: Bölüm 1'de oyuncu hemen koşarsa x=150 "sola bak" (gizli alan) ipucu,
  kart beklerken geçilip x=560 hareket ipucuna yol veriyor. Gizli alan bulma oranı düşerse ipucu
  560'tan sonraya ya da kart süresi (3,6 sn) kısaltılmalı.
- Kemal Bey'in ayrı görünümü yok (hikâye sahnesi de `elite` kullanıyor); avludaki izleyici siluet
  düşman sanılabilir. İnsan testinde karışıklık görülürse Kemal'e özgü piksel sprite (palto + şapka).

- Saldırı uyarısı insan testi: ilk hasarın nedeni (uyarı görüldü mü?) ölçülmeli; MIN_SHOW 0,28 ve
  kırpışma periyodu 0,06 hipotez.

- Kaldırım taşı: taş yalnız 2 ve 5'teki büfede; insan testinde taş çok seçiliyorsa
  diğer büfelerde de denenebilir.
- Günün dalgası: GÜNLÜK sekmesine 21/28. gün kareleri (insan testinde seri 14'ü geçen
  oyuncu çıkarsa).
- Pantolon maskesi kalıntıları: tekmenin (kick 2–3) diz arkasında ve koşuda ayakkabının arka
  kenarında 2–4 piksel ceket rengi (kontura yapışık, kırıntı birleştirmesine girmiyor).
  26 Ekim: 2–4 px, önceki turlar "kostüm kalıntı turları kapanmalı" dedi → yalnız insan testinde
  fark edilirse ele alınacak (tek başına tur değeri yok).
- Şemsiyeyle havaya kaldırılan düşmanı ikinci şemsiye vuruşunun tekrar kaldırması sonsuz
  dizi yaratabilir mi? İnsan testinde bakılacak; gerekirse havadaki düşmana kaldırma yok.

- Hız yıldızının par süresi bölüm başına ayarlanmalı: 34 bölümde düz 240 sn, bot
  ~80 sn'de bitiriyor. İnsan testinden gelen ortanca sürenin ~0,8'i hedef (ilk koşuda
  zor, ikinci koşuda alınabilir); `par_time` her `Bolum*.tscn`'de elle.
- Bıçak savuruşu (`knife_attack` 4) kalıntısı: şapkanın üstünde 1–2 sanat pikseli koyu nokta
  kalıyor (iz ön parçasının içinde ya da ≥ 8 px). İnsan testinde fark edilirse ön parçadan da
  tutam kenarı ayıkla.
- Telefonda dokunmatik ölçüm: yanlış/kaçırılan basış sayacı (insan testi formuyla bağlanacak).
- KAY düğmesinin yeri gerçek cihazda başparmak erişimiyle doğrulanacak; gerekirse
  oyuncu düğme düzenini sürükleyerek kaydedebilsin (Save'e `touch_layout`).

## Tur kayıtları

### 2026-10-26 (60) — Bölüm 13 kayıkçı iskelesinde ilk atlama + plank'sız sulara çıkış taşı

**Neden şimdi:** Tur 59 sonrası Kitap 1 taraması temiz çıktı; ama tüm bölümlerde arama, Kitap 2
orta kesimlerinde "kanal + üstünde sağlam plank" kalıbının 22 yerde daha durduğunu gösterdi
(birikime yazıldı). Kitabın ilk bölümünden başlandı.

**Oyuncu ne hissedecek:** Kayıkçı iskelesinde ilk açıklık tahtalı (suyun güvenli olduğunu
gösterir), ikincisinde tahta kopmuş: 200 px koşarak atlanır, üç altın atlama yayını çizer —
Kitap 2'nin ilk atlaması. Kaçıran ıslanır, çıkış taşından iki adımda rıhtıma çıkar.

**Bulunan hata (önceki turların iddiası yanlıştı):** Tur 51 ve 55'te "dipten (110) zıplanıp
çıkılır, zıplama ~125" yazılmıştı. Bot ilk koşuda üç kez 880 sn suda kaldı: dipten zıplayan
oyuncu rıhtım kenarına ancak yetişip duvara yapışıyor (y≈2–10, zemin yok). `_canal`
açıklaması zaten "çıkış için uçlara alçak taş basamak konur" diyor; Bölüm 4 ve 29 55 px'lik
taş kullanıyor. Bu oturumda plank'sız bıraktığım dört suya da çıkış taşı eklendi: 13 (4650),
15 (3900), 20 (4100), 32 (3100). Bölüm 20'de palet yolu 290 → 230 px kısaldı ki palet taştaki
oyuncunun üstünden geçmesin (paletten rıhtıma 70 px atlama kaldı).

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; bot başsız: Bölüm 13 3 koşu
CLEARED (82,1 / 76,6 / 76,6 sn), 15 iki koşu (93,2 / 91,2), 20 iki koşu (93,0 / 92,1), 32 iki
koşu (77,5 / 77,5); hepsinde yeniden doğma 0. Görsel 1280×720: 13 iskele ve su — "ait".

**Sonraki öneri:** Birikimdeki orta kesim kanal maddesi: Bölüm 14 (3900).

### 2026-10-26 (59) — Bölüm 27 köprübaşı sokak hizasında; Kitap 3 plank kalıbı kapandı

**Neden şimdi:** Tur 58 taramasının kalan izleri. 35 ve 36 incelendi, dokunulmadı: 35'te kesim
"Göksu kıyısı: taş köprü" — dereyi geçen köprü kasıtlı nefes, hemen sonraki hendek zaten çürük
tahtalı çivili çukur (yine çürük tahta tekrar olurdu); 36'da finalin açılışında kayıkhane
kapısının altındaki kızak suyu üstünde iskele tahtası, iki kişilik kavganın ardından nefes.
Geriye 27'nin 60 px çukur köprübaşı meydanı kaldı.

**Oyuncu ne hissedecek:** Köprübaşı arenası telgraf binasının merdivenli cephesinin önünde,
sokak hizasında. Orta iskele 50 → 100 px: eskiden çukur tabanından 110 px yüksekti, düz
zeminde 50 px'te bank gibi kalacaktı; 100 px'te kalabalığın üstüne atlayıp inme yeri olarak
korunuyor (zıplama ~125). Altınlar iskelenin 50 px üstünde.

**Yapılanlar:** `bolum27.gd` bölüm 2; zemin 1700–3250 tek parça, `_fight(..., 0.0)`.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 27 bot başsız 4 koşu
CLEARED (93,4 / 85,7 / 97,5 / 96,8 sn; yeniden doğma 2/0/1/1). Değişiklik öncesi 2 koşu: 92,7
/ 90,1 sn, ikisinde de 2 yeniden doğma — ölümler dokunulmayan kablo koridoru (x≈7300) ve
finalde; birikime not edildi. Görsel 1280×720: meydan — "ait".

**Sonraki öneri:** Açılış iskeleti işleri bitti (Kitap 2 + 3). Yeni denetim: Kitap 1
(1–12) bölüm sonlarında arena/final tekrarı taraması ya da birikimdeki can ekonomisi
maddeleri için insan testi beklenir.

### 2026-10-26 (58) — Denetim (Kitap 3 iskelet taraması) + Bölüm 32 rıhtımında çürük iskele

**Neden şimdi:** Kitap 2 iskeleti kapandı; birikimin üst maddeleri insan testine bağlı, bu
yüzden denetim. 26–36'nın açılışları tarandı: çoğu çeşitli; iki iz kaldı — 27'de 60 px çukur
meydan, 32/35/36'da 200 px kanalın tam üstüne serili 220 px sağlam plank (kanal oynanışta
yok, yalnız süs). Birikime yazıldı; ilki bu turda.

**Oyuncu ne hissedecek:** Kuleli taş rıhtımında 450 px su üstünde çürük kayık iskelesi: basılan
tahta yarım saniyede çöküp geri geliyor, 5 altın hattı üstte — durmadan koşmak gerekiyor.
Düşen ıslanıyor, dipten (110) çıkıyor; ölüm yok. Gece rıhtımı ve arkadaki çürük kazıklarla
uyumlu; Kitap 1'in su kesimlerindeki çürük tahtanın (8, 9, 11, 12) Kitap 3'te tek dönüşü.

**Yapılanlar:** `bolum32.gd` bölüm 3 ve başlık yorumu; sandık merdiveni 200 px sağa kaydı
(3250/3410/3560), fener kulesi (3850+) dokunulmadı.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 32 bot başsız 3 koşu
CLEARED (77,5 / 75,8 / 72,6 sn, yeniden doğma 0). Görsel 1280×720: iskele (bir tahta çökmüş,
oyuncu suda), sandık merdiveni — "ait".

**Sonraki öneri:** Birikimdeki plank kalıbı: Bölüm 35.

### 2026-10-26 (57) — Bölüm 24 açılışı yere özgü: kemer bulvarında arena, kemer altında varil pusu; iskelet maddesi kapandı

**Neden şimdi:** Kitap 2 iskeleti maddesinin son bölümü (tur 56 önerisi). Kitap 2 finali de
60 px çukur avlu arenası + kemer altında 200 px kanal ile açılıyordu.

**Oyuncu ne hissedecek:** İlk arena Bozdoğan kemerinin altındaki düz bulvarda. Kemer altında
kanal yerine fıçıların ve çeşmenin önünde iki kişilik pusu; aralarında patlayıcı varil —
ikili oyuncuya koşarken varilin yanında toplanıyor, tek tekmeyle ikisi birden savrulabilir
(Dan the Man'in "ortamı silah yap" anı). Kule tüfeklisi ve bombacı aynı.

**Yapılanlar:** `bolum24.gd` bölüm 1–2 ve başlık yorumu; zemin −400–19500 tek parça.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 24 bot başsız 3 koşu
CLEARED (201 / 185 / 196 sn), her birinde 2 yeniden doğma — değişiklik öncesi sürüm aynı
yerde (final terası) 2 yeniden doğma, 205 sn: fark yok, birikime not edildi. Görsel 1280×720:
bulvar, pusu — "ait".

**Kitap 2 iskeleti maddesi kapandı:** 15–25 ve Kitap 3'ün ilk bölümü 25'in açılışı artık
bölüme özgü (tur 47–57). 13 ve 14 zaten farklıydı.

**Sonraki öneri:** Birikimin üst maddeleri insan testine bağlı; yeni iş için tasarım denetimi
(Kitap 3 bölümleri 26–36'da açılış/iskelet benzerliği taraması).

### 2026-10-26 (56) — Bölüm 16 açılışı yere özgü: düz ciltçiler sokağı, külliye avlusunda devriye

**Neden şimdi:** Kitap 2 iskeleti maddesi (tur 55 önerisi). Süleymaniye'de 60 px çukur sokak
arenası ve dış avluda (külliye avlusu, arkada revak ve şadırvan) 200 px açık drenaj kanalı
vardı — kanal yere ait değildi.

**Oyuncu ne hissedecek:** Ciltçiler sokağı düz; cumbalardaki altınlar ve arena + erzak aynı.
Dış avlu bir nefes kesimi: revak önünde iki kişilik devriye (sokak serserisi + bıçakçı),
taş sekiden rafa, tepede tabanca, ardından kalkanlı. Kanalın yerine küçük bir kavga — bölüm
ritmi arena → erzak → hafif devriye → imalathane tüfeklisi.

**Yapılanlar:** `bolum16.gd` bölüm 2–3 ve başlık yorumu. Eski düzende rafın ilk basamağına
(−140) iskele planktan (−20) 120 px zıplamayla çıkılıyordu (sınırda); şimdi 90 px taş sekiden
50 px. Zemin 1700–6900 tek parça.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 16 bot başsız 4 koşu
CLEARED (84,8 / 73,3 / 79,2 / 77,8 sn), dördünde de yeniden doğma 0 (birikimdeki eski
ölçüm: son üçlüde 2 yeniden doğma; final canı 23–40). Görsel 1280×720: sokak, avlu — "ait".

**Sonraki öneri:** Kitap 2 iskeletinde Bölüm 24 (son çukur arena), sonra madde kapanır.

### 2026-10-26 (55) — Bölüm 15 açılışı yere özgü: düz çeşme meydanı, su kemerinde ayak taşları

**Neden şimdi:** Kitap 2 iskeleti maddesi (tur 54 önerisi). Zeyrek de 60 px çukur meydan +
üstü tahta iskeleli 200 px kanal taşıyordu; arka planda Bozdoğan kemerinin ayakları sudan
yükselirken geçiş bir tahta plankla bedavaydı.

**Oyuncu ne hissedecek:** Meydan çeşmenin önünde sokakla aynı hizada. Su kemerinde 500 px
açık su; kemer ayaklarının sudan çıkan başları (90 px) basamak taşı, aralarında 3 altın.
Kaçıran ıslanır, dipte (110) yürüyüp çıkar — ceza zaman, ölüm değil. Üst raf ve tabanca
olduğu gibi (ilk ayaktan rafa 50 px yukarı geçilir).

**Yapılanlar:** `bolum15.gd` bölüm 2–3, başlık yorumu ve yerel `_pier()`: ilk çekimde
`_stones` blokları su yüzeyinin üstünde havada asılı duruyordu (tabanları y=0, su yüzeyi
~+30); ayak gövdesi kanal dibine kadar 200 px uzatıldı, alt kısmı suyun arkasında kalıyor.
Sayılar: ayaklar arası 80 px, ikinci ayaktan rıhtıma 160 px (−90'dan 0'a iniş).

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 15 bot başsız 4 koşu
CLEARED (97,7 / 87,0 / 92,3 / 92,4 sn; en uzun duraklama 15 sn, dokunulmayan su çarkı
kesiminde x≈7290). Görsel 1280×720: meydan, ayak taşları — "ait".

**Sonraki öneri:** Kitap 2 iskeletinde Bölüm 16 (çukur arena).

### 2026-10-26 (54) — Bölüm 25 açılışı yere özgü: kitapçı yokuşu tırmanılır, avluda kâğıt balyaları

**Neden şimdi:** Kitap 2 iskeleti maddesi (tur 53 önerisi). Kitap 3'ün ilk bölümü Cağaloğlu da
çukur avlu + 200 px kanal açılışını birebir taşıyordu; arka planda yokuş yukarı taş merdiven
ve el baskı presli matbaa avlusu varken oyun "aşağı in" ve "kanalı geç" diyordu.

**Oyuncu ne hissedecek:** Kitapçı yokuşu gerçekten yokuş: 30'ar px üç basamak, arena yokuşun
düzünde (−90), sonra avluya üç basamak iniş — arkadaki merdivenle aynı yön. Matbaa avlusunda
kanal yerine kâğıt balyası yığını (90 + 180): üstünden 3 altın ve kirişlerle tabancaya; yığının
arkasında bıçakçı inen oyuncuyu karşılıyor.

**Yapılanlar:** `bolum25.gd` bölüm 2–3 ve başlık yorumu. İlk denemede avluya iki baskı presi
(`_press`) kondu: çekimde Kitap 1 fabrikasının sarı-siyah şeritli ezicisi 19. yüzyıl
avlusunda yapıştırılmış gibi duruyordu — "ait" değildi, kaldırıldı; arka plandaki sandıklarla
aynı ahşap balya yığını kondu.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 25 bot başsız 4 koşu
CLEARED (84,9 / 82,6 / 88,0 / 85,8 sn; en uzun duraklama 11 sn — yokuş arenası ya da final,
eşik 45). Görsel 1280×720: basamaklar, yokuş arenası, avlu — "ait".

**Sonraki öneri:** Kitap 2 iskeletinde Bölüm 15 (yalnız çukur meydan arenası).

### 2026-10-26 (53) — Bölüm 17 Beyazıt meydanı: sokak hizasında arena, sütun kaidesi siperi

**Neden şimdi:** Kitap 2 iskeleti maddesi. Tarama: 13 ve 14 zaten farklı; 17 ve 25 iskeletin
birebir aynısı, 15/16/24'te yalnız çukur arena kalmış. 17'de sahaflar kesimi zaten kanalsız
ve saçak zincirli; ortak olan yalnız 60 px çukur meydan.

**Oyuncu ne hissedecek:** Beyazıt kapısının önünde meydan düz. Sağ yarıda 90 px'lik kırık
sütun kaidesi: ikinci dalganın tüfeklisine karşı siper (düşman mermisi dünyaya çarpıyor —
`projectile.gd` WORLD maskesi), üstü yüksek zemin ve tepesinde bir altın. Tur 50'de "düz
zeminde siper yokken tüfekli yalnız bekleme yaratır" gözlemine bu bölümde siperle yanıt.

**Yapılanlar:** `bolum17.gd` bölüm 2 ve başlık yorumu. Kaide 2600–2690: dalga doğum
noktaları (2125/2250/2500/2750/2875) dışında — tur 52'deki "katı bloğa doğan düşman"
hatası tekrarlanmasın diye hesaplandı.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 17 bot başsız 4 koşu
CLEARED (75,1 / 73,2 / 79,7 / 73,2 sn; en uzun duraklama 12 sn x≈2747 — meydan dövüşünün
kendisi, eşik 45). Görsel 1280×720: meydan — "ait".

**Sonraki öneri:** Kitap 2 iskeletinde Bölüm 25 (açılışın birebir aynısı + kanal).

### 2026-10-26 (52) — Bölüm 18 kalpakçılar geçidi: sokak hizasında, tenteden revaka iki katlı arena

**Neden şimdi:** Kitap 2 iskeleti maddesinde sıradaki bölüm (tur 51 önerisi). Bölüm 18'de
ortak olan yalnız 60 px çukur avlu arenasıydı; bedesten kesimi zaten raf üstü rotalı ve
kanalsızdı, dokunulmadı.

**Oyuncu ne hissedecek:** Çarşı yolu düz akıyor (çukura inilmiyor). Arenanın sol yarısında
tezgâh tentesi oyuncuyu 240 px yukarıdaki dükkân revakına atıyor: revakta can + 2 altın;
kalabalıktan nefes alma ya da ikinci dalgadaki kalkanlının arkasına üstten inme seçeneği.
Kitap 2'de arena içinde dikey katman ilk kez burada.

**Yapılanlar:** `bolum18.gd` bölüm 2 ve başlık yorumu. İlk denemede tente arenanın ortasındaydı;
dalga doğum noktalarından biri (x≈2220) katı tezgâh bloğunun içine düşüyordu ve 3 bot
koşusunun birinde arena 886 sn kilitlendi. Tente sol kapıya dayandı (2020–2180, doğum
noktaları ≥ 2220), revak yanına alındı (2220–2440), sol kapıdaki süs tezgâhı kaldırıldı
(tente zaten tezgâh). Sayılar: tente→revak boşluğu 40 px (Bölüm 18 girişindeki 30 px ile aynı
his), revak −240 (tente fırlatması ~−260'a ulaşıyor).

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 18 bot başsız 4 koşu
CLEARED (94,6 / 94,9 / 87,8 / 99,9 sn; takılma yalnız dokunulmayan han çatısı finalinde,
x≈9690–9840). Görsel 1280×720: arena ve revak — "ait".

**Sonraki öneri:** Kitap 2 iskeletinde Bölüm 17 (ya da 13–16 sırasıyla).

### 2026-10-26 (51) — Bölüm 20 açılışı yere özgü: rıhtım düzünde pazar, deniz kapısında vinç paleti

**Neden şimdi:** Kitap 2 iskeleti maddesinde sıradaki bölüm (tur 50 önerisi). Samatya da 60 px
çukur avlu arenası + 200 px kanal + 220 px iskele açılışını taşıyordu.

**Oyuncu ne hissedecek:** Balık pazarı sur dibinde sokakla aynı hizada (çukura inilmiyor;
tezgâh arasında balık kasası altın veriyor). İniş artık anlamlı bir yerde: deniz kapısından
kayık iskelesine iki basamak, ardından 450 px'lik açık su. Alt yol: suyun üstünde gidip gelen
vinç paleti, palet hattında 5 altın; paleti kaçıran ıslanır ama dipte (110) yürüyüp karşı
rıhtıma çıkabilir — ceza ölüm değil zaman. Üst yol: pazarın sonundaki sur taşlarından kemerin
altındaki dört iskele kirişine, tepede tabanca; iskelede bıçakçı karşılar. Arka plandaki sur
kemeri ve deniz manzarası bu geçişin sahnesi oluyor.

**Yapılanlar:** `bolum20.gd` bölüm 2–3 ve başlık yorumu. Sayılar: iskele 60 (dip 110, çıkış
110 < zıplama ~125), palet 290 px yol, kirişler arası 90–100 px.
İlk bot koşusu TIMEOUT: karşı rıhtımda sudan çıkan oyuncu hemen 180 px taş yığınına
çarpıyordu (zıplama 125) — gerçek bir insan da takılırdı. Taş sırası 90 → 180 yapıldı; üst
yol 180'liğe iniyor.

**Testler:** import temiz; 36 sahne smoke çıkış 0 (36 SMOKE OK); DTM GAPS PASS; Bölüm 20 bot
başsız 3 koşu CLEARED (10108 @ 106 sn; 10105 @ 100 sn; 10110 @ 92 sn; takılma yalnız
dokunulmayan final avlusunda x≈9600–9880). Görsel 1280×720: pazar, iniş, su/palet, üst
kirişler, karşı rıhtım — "ait".

**Sonraki öneri:** Kitap 2 iskeletinde Bölüm 18.

### 2026-10-26 (50) — Bölüm 21 açılışı yere özgü: iskele düzünde balık mezadı, kızak iskelesi

**Neden şimdi:** Kitap 2 iskeleti maddesinde sıradaki bölüm (tur 49 önerisi). Yenikapı da
60 px çukur avlu arenası + 200 px kanal + 220 px iskele açılışını taşıyordu. (Önceki oturum
değişikliği yazıp testsiz kesilmişti; bu tur gözden geçirip doğruladı.)

**Oyuncu ne hissedecek:** Mezat arkadaki ahşap iskeleyle aynı hizada, tezgâhların arasında:
çukura inilmiyor, kavga sokaktan akarak başlıyor. Arenada iki balık sandığı (altın / can) —
dalga arasında kırılıp nefes alınıyor. İkinci dalgadaki tüfekli bıçakçıyla değişti: düz
zeminde siper yokken tüfekli yalnız bekleme süresi yaratıyordu. Kayıkhanede kanal yerine
kızaktaki teknelerin bakım iskelesi: iki sandıktan 180 px iskeleye çıkılır, altında bıçakçı
pusuda; üst hat tabancaya kadar kesintisiz (iskeleler arası 175 px, koşarak menzil ~250).

**Yapılanlar:** `bolum21.gd` bölüm 2–3 ve başlık yorumu. Sayılar: sandık 90 px, iskele
sandık üstünden 80 px yukarıda (zıplama ~125), altın hattı iskelenin 45 px üstünde.

**Testler:** import temiz; 36 sahne smoke çıkış 0 (36 SMOKE OK); DTM GAPS PASS; Bölüm 21 bot
başsız 2 koşu CLEARED (10107 @ 94,8 sn; 10108 @ 92,1 sn; takılma yalnız dokunulmayan sevk
bürosu arenasında, x≈8120–8270). Görsel 1280×720 (`tests/capture_level`): mezat, kayıkhane
girişi, bakım iskelesi — "ait".

**Sonraki öneri:** Kitap 2 iskeletinde Bölüm 20.

### 2026-10-26 (49) — Bölüm 22 açılışı yere özgü: kömür rampasında bombacı, kuru filtre havuzu

**Neden şimdi:** Kitap 2 iskeleti maddesinde sıradaki bölüm. Aksaray da aynı çukur avlu arenası
+ 200 px kanal açılışını taşıyordu.

**Oyuncu ne hissedecek:** İstasyon önünde kilitli arena yok: sokaktan iki basamakla çıkılan
kömür rampasında bombacı aşağı atıyor, altta sokak serserisi + bıçakçı yaklaşıyor — oyuncu
rampaya tırmanıp bombacıyı düşürmeyi seçiyor (kapalı kutu yerine akan kavga; bölüm 4 → 3 arena).
Rampanın üstündeki yük iskelesinde cephane (eski arena ödülü), rampadan inince suikastçı.
Filtre salonunda kanal yerine 500 px'lik boşaltılmış çökeltme havuzu: üstte boru köprüsünde
tabanca (güvenli yol), havuzun dibinde kalkanlı + 5 altın (riskli yol). Arkadaki su
kanallarının devamı gibi duruyor.

**Yapılanlar:** `bolum22.gd` bölüm 2–3. İlk denemede havuz 120 px derindi: kamera alt sınırı
açılmadan teleport çekiminde dip ekranın altında kaldı → 90 px (derin-kesim eşiği 110'un altı,
kamera hiç oynamıyor, dip ve kalkanlı tam görünür). Rampa 90 px (zıplama ~125).

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 22 bot başsız 3 koşu
CLEARED (77,5 sn 2 ölüm; 68,5 sn 0 ölüm; üçüncü 0 ölüm). Ölümler dokunulmayan bakım şaftı/final
kesiminde; açılış bota ~10 can kaybettiriyor. Görsel 1280×720: rampa, havuz, köprü — "ait".

**Sonraki öneri:** Kitap 2 iskeletinde Bölüm 21.

### 2026-10-26 (48) — Bölüm 23 açılışı yere özgü: yükseltilmiş çeşme avlusu, su terazisi kulesi

**Neden şimdi:** Birikimdeki Kitap 2 iskeleti maddesinde sıradaki bölüm (tur 47 önerisi).
Saraçhane de 60 px çukur avlu + 200 px kanal + iskele açılışını taşıyordu. (Önceki oturum bu
değişikliği yazıp testsiz kesilmişti; bu tur bitirip doğruladı.)

**Oyuncu ne hissedecek:** Avlu artık sokaktan iki basamak (45+45 px) yukarıda, arkadaki
çeşmenin taş setiyle aynı hizada: önceki bölümlerdeki "aşağı in, kavga et" yerine "yukarı çık,
kavga et". Kanal yerine bir su terazisi kulesi: 1-2-3-2-1 taş blok basamak, tepede tabanca,
basamak boyu altınlar; inince kalkanlı karşılar. Arkadaki su haznelerinin önünde taş yığını
yere ait duruyor.

**Yapılanlar:** `bolum23.gd` bölüm 2–3. Yarım kalan sürümde ikinci altın taş bloğun içindeydi
(`_coin_line` düz hat, kule basamaklı) → altınlar basamak başına tek tek, blok tepesinin 45 px
üstünde. Sayılar: basamak 90 px (zıplama ~125 px, rahat), kule 270 px — tabanca bir keşif
ödülü değil yol üstü ödül.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 23 bot başsız CLEARED
10110 (95 sn, 0 ölüm; finalde 12 sn takılma, eski davranış). Görsel 1280×720: avlu girişi,
avlu, kule — "ait".

**Sonraki öneri:** Kitap 2 iskeletinde Bölüm 22.

### 2026-10-26 (47) — Denetim (Bölüm 2, 3, 5, 11) + Bölüm 19 açılışı yere özgü

**Neden şimdi:** Tur 46'nın önerisi. Pencereli bot: Bölüm 2 CLEARED 9507 (0 ölüm), 3 CLEARED
9006 (0), 5 CLEARED 9391 (finalde 1 ölüm, finale 29 canla), 11 CLEARED 8655 (pres koridorunda
1 ölüm — bot zamanlamayı beklemiyor, Bölüm 6 ile aynı). Görselde sorun yok; Kasap Rıza ve
Pusucu Kemal çubukları, Muhafız Başı telsizi iyi. Bulgu yine verideydi: kontrol noktası ve
zemin dizilerinin taraması Bölüm 13–25'in açılışının aynı iskelet olduğunu gösterdi (birikimde
ölçüm). Oyuncu altı bölüm üst üste aynı çukur avluya inip aynı kanalı atlıyor.

**Oyuncu ne hissedecek:** Bölüm 19'da Çemberlitaş meydanı düz; sütunun önündeki iki katlı
restorasyon iskelesi tüfeklinin ateşinden kaçış ve atlayış saldırısı yolu. Hamam girişi kanal
yerine iki basamakla çıkılan taş sofa: kalkanlı sofanın kenarında, kapı rafına sofadan çıkılıyor,
sonra içeri iniliyor — arka plandaki hamam kapısının tam önünde.

**Yapılanlar:** `bolum19.gd` bölüm 2–3. İlk denemede meydana sütun kaidesi olarak taş blok
kondu: koyu kutu gibi durdu (sütun arkada solda) ve tüfekli arkasına siper alınca bot 37 sn
takılıp öldü → kaldırıldı, yalnız tek yönlü iskele.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; Bölüm 19 bot pencereli
CLEARED 10110 (75 sn, 0 ölüm) ve başsız CLEARED 10107. Görsel: meydan arenası ve taş sofa
1280×720 — "ait".

**Sonraki öneri:** Kitap 2 iskeletinde sıradaki Bölüm 23 (Saraçhane).

### 2026-10-26 (46) — Kamera alt sınırı yalnız derin kesimde açılır (Bölüm 8, 9, 10, 21)

**Neden şimdi:** Tur 45 denetiminin bulgusu (birikimde eyleme dönük tek madde). Bölüm 21'in
kamera alt sınırı kuru havuz (200 px derin) yüzünden 270; bölümün tamamında zemin ekranın
~%64'ünde, altta boş toprak dolgusu, finalde vapurlu rıhtım resmi yarıya iniyordu. Tarama:
aynı durum Bölüm 8 (260; 160 px derin kanal yolu), 9 (200; derin kanal) ve 10'da (200; derin
kesim yok, kalıntı) da var. Diğer 32 bölüm 130.

**Oyuncu ne hissedecek:** Dört bölümde de düz zeminde kadraj diğer bölümlerle aynı: zemin
ekranın altında, resim tam. Havuza ya da derin kanala yaklaşınca kamera yumuşakça aşağı açılır,
çıkınca geri kayar.

**Yapılanlar:** `dtm_level.gd`: `_build` sonrası zemini 110 px'ten derin parçalar (±420 px
pay) `_deep_spans`; `_process` bölümün alt sınırı 130'dan büyükse `_ease_cam_bottom` ile
sınırı oyuncu derin kesimdeyken bölüm değerine, değilken 130'a 360 px/sn kaydırıyor. Bölüm
dosyaları değişmedi (değerleri derin kesim için kalıyor). Pay ve hız hipotez: 420 px, kamera
kesime ekran yarısı kadar önce açılsın diye; 360 px/sn, sınır değişimi ~0,4 sn'de bitsin diye.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; bot Bölüm 1 (8607), 8 (9408),
9 (9408), 10 (9206), 13 (9556), 21 (10107), 25 (10156) CLEARED. Görsel 1280×720: Bölüm 21
finali (zemin altta, vapur tam), kuru havuz (kamera açık, oyuncu havuz dibinde görünür),
Bölüm 8 derin kanal ve Bölüm 9 köprü altı kanal (açık), Bölüm 10 ana kapı (130).

**Sonraki öneri:** Denetim sırası: Bölüm 2, 3, 5, 11.

### 2026-10-26 (45) — Denetim (Bölüm 19, 23): Kitap 2'nin altı finali aynı arenaydı

**Neden şimdi:** Tüm listeler kapalı, birikim insan testine bağlı → denetim (henüz bakılmamış
19 ve 23). Pencereli bot: Bölüm 19 (Çemberlitaş Külhanı) CLEARED 10108, 76 sn, 0 ölüm; Bölüm 23
(Saraçhane) CLEARED 10107, 98 sn, 1 ölüm (son arena). Külhan ocağı, hamam erzakçısı, su
galerisi, Bozdoğan Kemeri resimleri iyi. Bulgu ise ekranda değil verideydi: iki finalin dalga
dizisi birebir aynıydı. 36 bölümün bütün arenaları tarandı: Bölüm 18 çatısı + 19, 20, 21, 22,
23 finalleri — altı ardışık bölüm aynı üç dalga (Bıçakçı-Suikastçı-Bıçakçı / Seçkin+Tüfekli /
iki Ağır Zırhlı). Ayrıca 14/16/25 finalleri aynı, 6 arena çifti daha ikiz. Bu tam olarak
kaçınılan "şablon parkur": DTM'de her bölümün son kavgası yerin kendisi gibi okunur; Kitap 1'de
bunu adlı rakipler sağlıyordu, Kitap 2'de hiç yoktu.

**Oyuncu ne hissedecek:** Her final yerin kavgası. Külhan: ocak ağzında iki alev bacası ters
fazda yanarken külhancılar, sonra "KÜLHANBEYİ" ile bire bir (Kitap 2'nin ilk adlı rakibi,
can çubuğu). Samatya: ortada yük iskelesi; hamallar kalkanlının arkasında, Kemal Bey son
dalgada kaçıyor. Yenikapı: iki yük sandığı iskelesi, kalkanlının arkasında tüfekli nöbet.
Aksaray: avlunun ortasında kopuk pompa kablosu, bombacı oyuncuyu kabloya iter. Saraçhane:
Kâtip'in suikastçı baskını. Ara arenalar da ayrıştı (22 şaft, 23 avlu ve bakım geçidi, 22 avlu,
24 ilk arena); 16 terası ve 25 arşiv kapısı farklı ve 16'da daha hafif.

**Yapılanlar:** Yalnız bölüm betikleri (16, 19–25): dalga dizileri, 19'da `named_title`
+ iki `_flame`, 20/21'de `_scaffold`, 22'de `_live_wire`. Yeni çizim yok. Tarama sonrası ikiz
arena kalmadı. Sayılar (hipotez): finaller eski 7 düşman / 2 Ağır Zırhlı yerine 5–7 düşman,
en fazla 1 Ağır Zırhlı; Külhanbeyi 2,5× can (Kitap 1 adlı rakipleriyle aynı). İlk denemede
Külhanbeyi'nin yanında Bombacı vardı, bot öldü → bire bir yapıldı; Yenikapı'da iki tüfekli bot
4–11 canla bitiriyordu → tek tüfekli.

**Testler:** import temiz; 36 sahne smoke çıkış 0 (iki kez); DTM GAPS PASS; bot (başsız)
Bölüm 1, 13, 16, 19 (×3), 20, 21 (×4), 22 (×2), 23, 24, 25 CLEARED. Bölüm 19'da 3 koşunun
1'inde finalde bir ölüm; 21'de bir koşuda sevk bürosunda (değişmedi) bir ölüm. Görsel: 19, 20,
21, 22 finalleri 1280×720 — KÜLHANBEYİ çubuğu, alev, iskele, kablo sahneye ait.

**Sonraki öneri:** Denetim sırası: Bölüm 2, 3, 5, 11 (Kitap 1'in bakılmamışları). Kitap 2
bölüm iskeletinin ayrıştırılması birikimde.

### 2026-10-26 (44) — Denetim (Bölüm 15, 17, 21): bot duraklatmayı "bitti" sanıyordu

**Neden şimdi:** Tur 43'ün önerisi. Pencereli bot: Bölüm 15 (Zeyrek Su Hattı) CLEARED 9735,
88 sn, 0 ölüm; Bölüm 17 CLEARED 10006, 75 sn; Bölüm 21 (Yenikapı) CLEARED 10106, 90 sn.
Su kemeri, çeşme meydanı, su çarkı, Sahaflar ve Rıhtım erzakçısı, sevk odası resimleri
iyi; birkaç karedeki çift pozlama 240 px'lik gökyüzü geçişine denk geliyor (Bölüm 16 denetiminde
kısaltılmıştı, beklenen). Bulgu oyunda değil test düzeneğinde: Bölüm 15'in ilk koşusu 0 sn'de
"CLEARED @80", Bölüm 21'in ilk koşusu 36 sn'de "CLEARED @5796" dedi (hedef 10150). Pencereli
koşuda odak kaybı (`NOTIFICATION_WM_WINDOW_FOCUS_OUT`) duraklatma menüsünü açıyor; bot
`get_tree().paused`'u bölüm bitti sayıyordu. Denetim koşuları bu yüzden yarım bölümü
"temiz" raporlayabiliyordu (günlükteki eski "zaman zaman duraklatma menüsü" notu aynı şey).

**Oyuncu ne hissedecek:** Doğrudan bir şey değil; denetim ve bot sonuçları güvenilir olur.

**Yapılanlar:** `_autoplay.gd`: duraklatma menüsü açıksa (bölüm bitmemişse) bot menüyü kapatıp
sürdürüyor; bitiş yalnız gerçek bitişte. Bölüm 21 yeniden: CLEARED 10106.

**Testler:** import temiz; DTM GAPS PASS; bot (başsız) Bölüm 1 (8608), 13 (9556), 25 (10159)
CLEARED; pencereli Bölüm 21 CLEARED 10106.

**Sonraki öneri:** Önerilen denetim listesi (9, 12, 15, 17, 21) bitti. Birikimin kalanı insan
testine bağlı.

### 2026-10-26 (43) — Denetim (Bölüm 9, 12): Karahanlı dövüşünde boss çubuğu yoktu

**Neden şimdi:** Tur 42'nin önerisi (sıradaki denetimler: 9, 12, 15…). Bölüm 9 (Kız Kulesi
surları) pencereli bot: CLEARED 9409, 122 sn, 0 ölüm, 21 kare; Binbaşı Kaya çubuğu, telsizler,
ÜS KANTİNİ iyi; iç duvar stil listesinde zaten dönüşmüştü (844606dc). Bölüm 12 (İç Kale,
Kitap 1 finali): CLEARED 7421, 78 sn, 2 yeniden doğma. Bulgu bir hata: taht salonunda
Karahanlı ile dövüşte HUD'da can çubuğu hiç görünmüyordu — yalnız son vuruşta bir kare.
Kitabın finalinde oyuncu boss'un ne kadar kaldığını göremiyordu. Neden: `main.gd`
`_physics_process`'te eski Level05'ten kalan satır, bölümde "Karahanli" adlı düğüm varsa
çubuğu her kare `x ≥ 237000` koşuluna bağlıyordu; yeni Bölüm 12'de bu hiç sağlanmıyor.
Aynı dövüşte iki yan bulgu: öfke evresinde (can ≤ ½) çağrılan iki yardımcı vuruşun fizik
sorgusu içinde `add_child` ediliyordu (her öfkede 12 "flushing queries" hatası), ve dalga
rozeti yardımcılar gelince güncellenmiyordu ("1 DÜŞMAN" yazarken sahnede 3 düşman).

**Oyuncu ne hissedecek:** Taht salonunda kapılar kapanınca altta "KARAHANLI" çubuğu açılır,
her vuruşta kısalır; ÖFKE! anında yardımcılar gelince rozet "3 DÜŞMAN" der. Aynısı Bölüm 24
Ana Vana Muhafızı'nın yardımcıları için de geçerli (aynı `StoryBoss`).

**Yapılanlar:** `main.gd`: eski 237000 satırı kaldırıldı (kampanyada o sahne yok).
`story_boss.gd`: `_call_add` ertelenmiş çağrı; arenaya eklerken `wave_changed` yayınlanıyor.
Yeni `tests/story_boss_bar.tscn` (Bölüm 12 botu; boss canlıyken çubuk gizli kare ≤ 2, rozet ≥ 3
düşman). Düzeltme öncesi kodla koşturuldu: 2370 boss karesinin 2344'ünde çubuk gizli → FAIL;
sonrası 0 → PASS. (Rozet kontrolü eski kodda da 3 gördü — başka bir yayın sonradan sayıyı
düzeltiyordu; ayırt edici kısım çubuk.)

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; `story_boss_bar` PASS (hata
mesajı yok); bot Bölüm 1 (8605), 12 (7369), 24 (18657, Ana Vana Muhafızı), 25 (10157) CLEARED. Görsel: taht salonu
1280×720 — çubuk altta, telsiz kutusu ve rozetle çakışmıyor.

**Sonraki öneri:** Sıradaki denetimler: Bölüm 15, 17, 21. İnsan testinde Bölüm 9 ilk arena
(x≈5000–5700, bot 109 → 25 can) ve Bölüm 12 yalı kesimi (x≈4600–5400, bot 2 ölüm) ölçülsün.

### 2026-10-26 (42) — Denetim (Bölüm 6): yeni iş yok, otomasyon durdu

**Neden şimdi:** Tur 41'in önerisi. Bölüm 6 (Karahanlı Haddehanesi) pencereli bot: CLEARED 9455,
131 sn, 2 yeniden doğma (ilk arena), 26 kare. Bot ilk 4000 px'te 115 → 15 can kaybediyor: alev
koridorunda (4 zamanlı alev, 12 hasar, üstte iskele yolu) ve pres salonunda zamanlamayı
beklemeden yerden yürüyor. Tehlikeler telgraflı ve kaçınılabilir; insan testinde bu iki
bölümdeki hasar ölçülmeden değişiklik yapılmadı. İyi çalışanlar: fabrika ve haddehane
resimleri, Ustabaşı'nın telsizi, "ZIRHLI USTABAŞI" çubuğu (tur 35), İŞÇİ KANTİNİ, HADDEHANE
kapısı.

**Durum:** Stil listesi, YOL_HARITASI ve oyun-kalite P1 maddeleri tamam; birikimin her maddesi
insan testine bağlı. Bu oturumda 11 tur (32–42) yapıldı; son iki denetimden (18, 6) yeni iş
çıkmadı. Otomatik döngü burada durdu.

**Sonraki öneri:** İnsan testi (özellikle son arenaya giriş canı, adlı rakiplerin dövüş süresi,
Bölüm 6 alev/pres hasarı). Yeni otomatik denetim için sıradakiler: Bölüm 9, 12, 15, 17, 21.

### 2026-10-26 (41) — Gündüz sokaklarında tuğla, konak salonunda ahşap raf kule

**Neden şimdi:** Tur 40'ın önerisi. 36 bölümün 18 baca kulesinin hepsi tek süreçte 1280×720
çekildi (geçici yakalama betiği, `_chimney_xs` okunarak) ve resimle yan yana değerlendirildi.
Gece, kale, sarnıç, külhan, fabrika ve su kanalı resimlerinde koyu taş kule uyuyor (4, 7, 11,
15, 19, 24, 32, 34, 35); 33 ve 36 tur 32'de ahşap raf, 26 tur 40'ta gar tuğlası. Yabancı duran
dört kule: güneşli Balat sokağı (2), gündüz yeşil sokak (14), Üsküdar meydanı (28) — renkli
sıvalı evlerin ve sıcak ışığın önünde gri-siyah blok; Çengelköy konağının ahşap ve çini salonu
(31) — konağın içinde taş kule.

**Oyuncu ne hissedecek:** Gündüz sokaklarında tırmanılan kule, mahallenin sıcak tuğla
yapılarından biri; konakta salondaki ahşap dolap. Gizli yol aynı, sahne bütün.

**Yapılanlar:** Yalnız bölüm dosyaları: 2, 14, 28'de kule için `chimney_brick` açılıp
kapanıyor; 31'de `chimney_rack`. Yeni çizim yok (tur 32 ve 40'ın dokuları).

**Testler:** 36 sahne smoke çıkış 0; DTM GAPS PASS; bot Bölüm 2 (9509), 14 (9655), 28 (10107),
31 (9710) CLEARED. Görsel: dört kule 1280×720 — "ait".

**Sonraki öneri:** Birikimin kalanı insan testine bağlı → yeni denetim (Bölüm 14'ün tamamı
ya da Kitap 1'den Bölüm 6).

### 2026-10-26 (40) — Denetim (Bölüm 26): gar avlusunun su kulesi gar tuğlasından

**Neden şimdi:** Birikimin kalanı insan testine bağlı → denetim (Bölüm 30 tur 25'te yapılmıştı,
yerine Bölüm 26). Pencereli bot: CLEARED 9756, 78 sn, 0 ölüm, 16 kare. Gar cephesi, peron
treni, yük avlusu ve sevk odası resimleri; DALGA rozetleri; film rulosu bandı iyi. Bulgu: "Su
kulesi" tırmanışı (x 7670) güneşli yük avlusunun ortasında koyu demir panelli duvar + neredeyse
siyah düz kuyu içi; ChatGPT resminin sıcak taş ve ahşabının önünde yapıştırılmış bir blok gibi
duruyordu (tur 32 bu kuleyi "açık rıhtım, taş uyar" diye geçmişti — gece resimlerinde doğru,
bu güneşli gar avlusunda değil).

**Oyuncu ne hissedecek:** Tırmanılan kule, arkadaki gar binasıyla aynı kırmızı tuğla ve krem
taş kuşaklı bir su kulesi; içi iki-üç ton koyu tuğla (oyuk okunuyor), tepede kiremit çatı.
Gizli zırh yolu aynı, sahne bütün.

**Yapılanlar:** `tools/gen_gpt_style_props.py`: `GAR_BRICK` rampası (8 ton, gölge mora, ışık
turuncuya), `make_kule_tugla` (20×48: dört sıra şaşırtmalı tuğla + bir sıra krem kesme taş
kuşak, sol yüz sıcak, sağda ay kenarı, kuşak altında is akıntısı, üst/alt konturu yok → dikişsiz)
ve `make_baca_tugla` (24×32: koyu tuğla, sol kenardan sıcak sızıntı). İlk sürümde kuyu içi
duvarla aynı parlaklıktaydı, oyuk okunmuyordu; iki-üç ton koyulaştırıldı. Diğer bütün çıktılar
bire bir aynı üretildi. `DtmLevel.chimney_brick` (varsayılan false; `chimney_rack` gibi bölüm
başına seçim): duvar `A_BRICK_TOWER` (altta hatıl), iç `A_SHAFT_BRICK`. Bölüm 26'da yalnız
su kulesi için açılıp kapanıyor.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; bot Bölüm 1 (8606), 13 (9559),
25 (10156), 26 (9755) CLEARED. Görsel: kule önü ve tepe 1280×720, ChatGPT gar avlusu resmiyle
yan yana — "ait".

**Sonraki öneri:** Gündüz resimli diğer bölümlerdeki baca kulelerine (taş/demir panel) aynı
gözle bakılsın; sonra yeni denetim (Bölüm 14).

### 2026-10-26 (39) — Denetim (Bölüm 8): Tünel Bekçisi adıyla dövüşür

**Neden şimdi:** Birikimin kalanı insan testine bağlı → denetim (tur 38'in önerisi). Bölüm 8
(Yeraltı Sevkiyatı) pencereli bot: CLEARED 9407, 89 sn, 0 ölüm, 18 kare. Sarnıç ve su çarkı
resimleri, film rulosu bandı (tur 38 düzeltmesiyle temiz), dalga rozetleri iyi. Bulgu: tur 35'in
taraması yalnız ara sahnede konuşanlara bakmıştı; bölümün son kısmı "Tünel bekçisi" başlıklı,
bekçi telsizden "Sevkiyatı sarnıçtan geçirin" diyor, ama son arenadaki Ağır Zırhlı'nın çubuğunda
genel "Ağır Zırhlı" yazıyordu. Telsiz konuşmacıları da tarandı: Ustabaşı, Sur Ağası ve Muhafız
Başı zaten tur 35'te adlandırılmıştı; Bölüm 7 ve 24'teki Ağır Zırhlılar tanıtılmamış muhafız,
genel ad doğru.

**Oyuncu ne hissedecek:** Telsizden duyduğu sesin sahibiyle çark dairesinde yüz yüze; çubukta
"TÜNEL BEKÇİSİ".

**Yapılanlar:** `bolum08.gd` son arena `named_title = "TÜNEL BEKÇİSİ"`, `named_wave = 2`
(zaten boss: yalnız ad).

**Testler:** import temiz; 36 sahne smoke çıkış 0; bot Bölüm 8 CLEARED 9408. Görsel: çark
dairesinde boss çubuğu "TÜNEL BEKÇİSİ" 1280×720.

**Sonraki öneri:** Birikimin kalanı insan testine bağlı → yeni denetim (Kitap 3'ten Bölüm 30).

### 2026-10-26 (38) — Denetim (Bölüm 18 ve 34) + film rulosu bildirimi HUD'a binmez

**Neden şimdi:** Tur 37'nin önerisi: ara arenaların arka plan taraması, sonra yeni denetim.
(1) Ara arena taraması: Kitap 2–3'ün 36 ara arenasının kamera merkezindeki atlas karesi bölüm
başlığıyla yan yana incelendi; hepsi uyuşuyor (31'in kütüphanesi giriş salonu resminde, atlasta
kütüphane karesi yok — kabul). Değişiklik yok. (2) Bölüm 18 pencereli bot: CLEARED 10057,
93 sn, 0 ölüm; tur 37'de düzelen han çatısı arenası iyi okunuyor; yeni bulgu yok. (3) Bölüm 34
pencereli bot: CLEARED 9908, 86 sn, 1 yeniden doğma. Bulgu: Kandilli'deki ilk film rulosunda
"FİLM RULOSU 1/3" bandının alt satırı (800 px genişlikte ortalanmış, x 240–1040) sol sütundaki
zırh satırının ("Zırh: … · hasar -%50 · hız -%15", x 16–380) üstüne biniyordu; ikisi de
okunmuyordu. İkinci bulgu (yan yana iki Seçkin) birikime.

**Oyuncu ne hissedecek:** Gizli film rulosunu bulduğu an, kutlama metni temiz okunur; silah,
mermi, zırh satırları yerinde kalır.

**Yapılanlar:** `_PlaceBanner` genişliği 800 → 580 px (x 350–930: sol sütun ~330 px'te bitiyor,
sağ üst kombo yazısı 1000 px'ten sonra), alt satır zaten sarıyordu. Film rulosu metni açık iki
satır: "Gazelle'in kanıt fotoğrafı bulundu · +10 coin" / "Kanıt Arşivi'ne eklendi" (sarma
"+10 coin ·" diye bölüyordu). Masaüstü zırh satırı "Zırh  6/6" (silah satırıyla aynı; etkileri
mağaza açıklamasında).

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS, NAMED FOE, ARENA PURSUER PASS; bot
Bölüm 1 (8604), 13 (9555), 25 (10155), 34 (9906) CLEARED. Görsel: Bölüm 34 x=2300'de zırh +
silah + mermi + film rulosu bandı aynı anda, 1280×720 — çakışma yok.

**Sonraki öneri:** Birikimin kalanı insan testine bağlı → yeni denetim (Kitap 1'den Bölüm 8).

### 2026-10-26 (37) — Yedi bölümde son arena kendi resminin önünde (tur 36 taraması)

**Neden şimdi:** Tur 36'da Bölüm 28'in son arenası rıhtım yerine mahzende çıkmıştı; aynı hatanın
başka bölümlerde olup olmadığını taradım. Yöntem: her bölümde son arenanın kamera merkezi
(arena ekrandan darsa sabit orta) ile `sky_cells` eşikleri ve 240 px harmanlama karşılaştırıldı;
son karenin ağırlığı < 0,5 olan 13 bölümün atlas kareleri, bölüm yorum başlıklarıyla yan yana
incelendi. Dördünde arena zaten doğru resimdeydi (19 külhan, 29 defter odası; 3, 26, 33, 35'te
son arena bölüm sonu değil). Yedisinde yanlıştı.

**Oyuncu ne hissedecek:** Bölümün adını verdiği yerde dövüşür: Süleymaniye arşivinin arka
terası (16), Kapalıçarşı han çatısı ve kubbeler (18), Samatya yükleme avlusu (20), Galata'ya
bakan telgraf direkleri (27), Çengelköy deniz köşkü (31), Kuleli sahil kapısı (32), Haliç gümrük
avlusu (13). Kapalı odalardan sonra açık manzara — bölüm sonu nefesi.

**Yapılanlar (yalnız kare eşikleri):** 13: avlu karesi (2) hiç kullanılmıyordu → 8650, kapı 9000
→ 9550. 16: teras 9700 → 9450. 18: çatı 10150 → 9550 (önceden yalnız bitiş kapısında). 20:
yükleme avlusu 10000 → 9550. 27: çatı direkleri 9700 → 9250. 31: sıra mühür odası (6800) →
deniz manzaralı salon (7800) → köşk (8600); önceden mühür odası salon resmindeydi, köşk arenası
pres masası resmindeydi. 32: kayıt odası 8300 → 7550, sahil kapısı 9500 → 8900. Eşikler önceki
iç mekânın bittiği yerle arena kapısı arasında; arenanın kamera aralığı tam yeni karede.

**Testler:** 36 sahne smoke çıkış 0; DTM GAPS PASS; bot Bölüm 13 (9557), 16 (9959), 18 (10060),
20 (10109), 27 (10106), 31 (9709), 32 (9855) CLEARED. Görsel: 16 ekran görüntüsü 1280×720,
her bölümde önceki oda + son arena — "ait".

**Sonraki öneri:** Ara bölümlerde de aynı tarama (her bölümün her arenası, yalnız sonuncusu
değil); sonra yeni denetim (Bölüm 18).

### 2026-10-26 (36) — Tasarım denetimi (Bölüm 28): son arena Kız Kulesi rıhtımında

**Neden şimdi:** Birikimin kalanı insan testine bağlı → denetim (tur 35'in önerisi). Bölüm 28
(Üsküdar Yedek Hattı) pencereli bot koşusu: CLEARED 10105, 93 sn, 2 yeniden doğma, 16 kare. En
somut bulgu bir set-piece kaybı: kod son bölümü "Kız Kulesi rıhtımı: son arena" diye anlatıyor,
ChatGPT atlasında da tam o kare var (rıhtım duvarı, karşıda Kız Kulesi ve tarihî yarımada), ama
kare 9700'de başladığı için son arena (9200–9800) arşiv mahzeninin önünde oynanıyordu; rıhtım
yalnız arena bittikten sonraki koşuda görünüyordu.

**Oyuncu ne hissedecek:** Kitap 3'ün dördüncü bölümünün son kavgası Kız Kulesi'ne karşı, açık
rıhtımda; kapalı röle salonu ve mahzenden sonra ilk kez deniz — bölüm sonunun nefesi ve manzarası.

**Yapılanlar:** `bolum28.gd` arka plan kare eşikleri: mahzen 8500 → 8300 (arşiv odası 8200'de
başlıyor, önceden ilk 300 px röle salonu önündeydi), rıhtım 9700 → 9150 (kontrol noktası 9050 ile
arena kapısı 9200 arası; arşivin demir çerçevesi 8800'de bitiyor). İlk deneme 9000 arşiv
çerçevesini rıhtım gökyüzüne taşıdı, 9150'de çerçeve kenarda kalıyor.

**Diğer bulgular:** Son arenaya düşük canla varış birikime (Bölüm 4 ile ortak örüntü). İyi
çalışanlar: Üsküdar meydanı ve şadırvan resmi, röle salonundaki iki yandan tüfekli kıskacı,
ŞERİT MAKİNESİ kırılabilir duvarı, Rıfat'ın telsizi.

**Testler:** 36 sahne smoke çıkış 0; DTM GAPS PASS; bot Bölüm 28 CLEARED 10107 (87,6 sn).
Görsel: 8350 (mahzen), 8950, 9150, 9500 (rıhtım, Kız Kulesi) 1280×720 — "ait".

**Sonraki öneri:** Diğer bölümlerde de arka plan karesinin bölüm metniyle (yorum başlıkları)
uyuşup uyuşmadığına bakan hızlı tarama; sonra yeni denetim (Bölüm 18).

### 2026-10-26 (35) — Kitap 1–2'nin adlı rakipleri adıyla dövüşür (birikim)

**Neden şimdi:** Tur 34'ün birikime yazdığı tarama. Ara sahnede adıyla konuşup "kapıları kapatın"
diyen yedi rakip dövüşte kimliksizdi: Kasap Rıza (Bölüm 2) sıradan Zırhlı Vurucu, Pusucu Kemal
(3) arenada hiç yoktu (son dalga suikastçı + zırhlı), Makinist Cemil (5) sıradan Seçkin;
Zırhlı Ustabaşı (6), Binbaşı Kaya (9), Sur Ağası (10) ve Muhafız Başı (11) dördü de aynı
"Ağır Zırhlı" can çubuğuyla çıkıyordu. Ara sahne bir kişiyi tanıtıp dövüş başka birini
gösterince bölüm doruğu dağılıyor.

**Oyuncu ne hissedecek:** Her bölümün son kavgasında konuşan kişi adıyla karşısında; can
çubuğunda onun adı. Kitap 1'in ilk bölümlerinde adlı rakip daha dayanıklı bir sıradan düşman,
6. bölümden itibaren ağır boss — zorluk merdiveni okunur.

**Yapılanlar:** `make_named` zaten boss olanda (Ağır Zırhlı) yalnız adı değiştirir; can/blok
aynı (tur 34'teki güçlendirme dört boss'u iki buçuk kat zorlaştırırdı). Bölüm 2 son arena
2. dalga `KASAP RIZA` (Zırhlı 60 × 2,0 = 120; tek başına dalga, yardımcısız); Bölüm 3 arena
3. dalga ASSASSIN → KNIFE, `PUSUCU KEMAL` (22 × 3,0 = 66; bıçaklı hızlı ama kırılgan, 3 kat
olmadan iki kombo sürmüyor); Bölüm 5 son arena 3. dalga `MAKİNİST CEMİL` (Seçkin 40 × 2,5);
6/9/10/11 yalnız ad. `tests/named_foe.tscn`'e boss yalnız ad alır denetimi eklendi.

**Testler:** import temiz; NAMED FOE, ARENA PURSUER, DTM GAPS PASS; 36 sahne smoke çıkış 0;
bot Bölüm 1 (8607), 2 (9506), 3 (9006), 5 (9391), 6 (9454), 9 (9408), 10 (9207), 11 (8658),
13 (9559), 25 (10155) CLEARED. Görsel: boss çubuğu yolu tur 34'te Demir ile ekranda doğrulandı;
aynı yol, yalnız metin değişiyor.

**Sonraki öneri:** Birikimin kalanı insan testine bağlı → yeni denetim (Kitap 3'ten Bölüm 28).

### 2026-10-26 (34) — Tasarım denetimi (Bölüm 4) + Yüzbaşı Demir adlı rakip olarak dövüşür

**Neden şimdi:** Birikimin kalanı insan testine bağlı → denetim (tur 33'ün önerisi). Bölüm 4
(Silahlı Kontrol Bölgesi) pencereli bot koşusu: CLEARED 9310, 107 sn, 2 yeniden doğma, 18 kare.
En somut bulgu bir set-piece kaybı: ara sahnede bölümün kötüsü Yüzbaşı Demir "Kapıları kapatın!"
diye arenaya yürüyor, ama dövüşte isimsiz, can çubuksuz sıradan bir Seçkin Muhafız; üstelik
ikinci ve üçüncü dalgada aynı görünümlü iki "Demir" çıkıyor, oyuncu hangisini yendiğini bilmiyor.
DTM'de bölümün adlı rakibi ad + can çubuğuyla bölümün doruğudur. Yan bulgu: masaüstü HUD'u zırhı
"Zırh: Zırh 3/6" diye iki kez yazıyordu.

**Oyuncu ne hissedecek:** Üçüncü dalgada Demir, tüfekli korumasıyla gelir; ekranın altında
"YÜZBAŞI DEMİR" can çubuğu açılır. Daha dayanıklı, daha sık bloklar ("Kalkanımı geçemeyen…"),
kolay yere düşmez; onu yenmek bölümün kapanış anı olur.

**Yapılanlar:** `EnemyBase.make_named(ad, can katı)`: ayarın kopyası boss olur (HUD can çubuğu
ve adı mevcut `_register_arena_enemy` yoluyla gelir), can × kat, skor × 3, blok ≥ 0,4, yere düşme
eşiği ≥ 25, itme direnci ≥ 0,5. `BattleArena.named_title / named_wave / named_health_mult`
(varsayılan boş → eski davranış): o dalganın ilk düşmanı adlı rakip olur. Bölüm 4 son arena:
`named_wave = 3`. HUD zırh satırı "Zırh  3/6 · hasar -%50 · hız -%15" (silah satırıyla aynı
biçim). Sayı gerekçesi: Seçkin 40 can × 2,5 = 100 — Bölüm 24'ün ana vana muhafızı (180) ile
sokak serserisi arasında, Kitap 1'in dördüncü bölümüne uygun; blok 0,25 → 0,4 Demir'in "kalkan"
repliğini oynanışa taşır. Hipotez: insan testinde Demir'le dövüş 25–40 sn sürmeli.
Yeni `tests/named_foe.tscn` (ad, can 100, ikinci düşman sıradan, ortak `.tres` değişmedi).

**Diğer bulgular:** Diğer adlı rakipler, Demir'in görünümü ve botun kule takılması birikime.
İyi çalışanlar: tepeden gözlem açılışı, kum torbası siperleri, kule köprüsü, kontrol kulesi
resmi, SINIR KANTİNİ.

**Testler:** import temiz; NAMED FOE, ARENA PURSUER, DTM GAPS, ARENA RESPAWN, TELEGRAPH MARK
PASS; 36 sahne smoke çıkış 0; bot Bölüm 4 başsız iki koşu (9307, 9310) CLEARED, pencereli koşu
CLEARED 9308 ama kule köprüsünde 54 sn takılma (bot; birikimde); Bölüm 1 (8604), 13 (9559),
25 (10155) CLEARED. Görsel: son arenada "YÜZBAŞI DEMİR" çubuğu altta, dalga rozetiyle çakışmıyor.

**Sonraki öneri:** Birikim — adlı rakiplerin taraması.

### 2026-10-26 (33) — Tasarım denetimi (Bölüm 22) + kapı dışında kalan takipçi arenaya alınır

**Neden şimdi:** Birikimin kalanı insan testine bağlı → denetim (tur 32'nin önerisi). Bölüm 22
(Aksaray Pompa İstasyonu) pencereli bot koşusu: CLEARED 10109, 101 sn, 1 yeniden doğma, 17 kare.
En somut bulgu bir hata: son arenada (Saraçhane, kapılar 9450–10000) rozet "DALGA 2/3 · 1 DÜŞMAN"
derken ekranda iki silahlı vardı. Yoklama: kontrol odasındaki Seçkin Muhafız (x 9150) oyuncuyu
kovalayıp sol kapının 30 px dışında (x 9421) kalıyor, kapının ardından ateş ediyordu. Oyuncu ona
ulaşamıyor, rozet onu saymıyor; geniş arenalarda kamera kapıya kilitli olduğu için mermi ekran
dışından geliyor (oyun-kalite belgesindeki "görünmeyen mermi" adayı). Bot ölümü tam burada.

**Oyuncu ne hissedecek:** Arkasından gelen düşman kapı kapanırken içeri dalar (arena doğma
halkasıyla), rozet onu da sayar; vurulamayan, görünmeyen nişancı yok.

**Yapılanlar:** `EnemyBase.is_engaged()` (boşta/devriyede/ölü değil). `BattleArena`: açılışta ve
etkinken her 0,4 sn kapı dışında, kapıya ≤ 640 px (yaklaşık bir ekran genişliği) ve zemin
bandında (±200 px) olup çatışmadaki düşmanı kapının 70 px içine alır, `defeated`'ı bağlar,
`_alive`'a ekler, rozeti günceller. Boştaki/devriyedeki düşman, kapısız arena ve hikâye boss'u
(kendi yardımcılarını yönetiyor) dışarıda kalır. Sayı gerekçesi: 640 px'ten uzaktaki düşman
oyuncuyu görmez (görüş 320 px) ve kapıya ulaşmadan ekranda olamaz; daha uzağı çekmek bölüm
tasarımını değiştirir. Yeni `tests/arena_pursuer.tscn` (eski kodda FAIL 3, yeni kodda PASS).

**Diğer bulgular:** Bakım şaftı arenası zorluğu birikime. İyi çalışanlar: pompa salonu resmi ve
pistonlar, SU ERZAKÇISI büfesi, makine rafındaki gizli sandık, Saraçhane bent resmi, düşmandan
düşen silah.

**Testler:** import temiz; ARENA PURSUER, DTM GAPS, ARENA RESPAWN, RANGED SPACING, DAILY WAVE,
TELEGRAPH MARK PASS; 36 sahne smoke çıkış 0; bot Bölüm 1 (8606), 13 (9558), 22 (10106; son
arenada ölüm yok, en uzun takılma 16 → 11 sn), 25 (10157) CLEARED.

**Sonraki öneri:** Birikimin kalanı insan testine bağlı → yeni denetim (Kitap 1'den Bölüm 4).

### 2026-10-26 (32) — Baca kulesi verici odası ve gemi ambarında ahşap depo rafı (birikim)

**Neden şimdi:** Bölüm 33 denetiminin bulgusu, birikimin en üstü. Kandilli verici odası
resminin ortasında 260 px'lik koyu gri, `ic_duvar` dokusu ızgara gibi tekrar eden düz bir sütun
duruyordu (otomatik gizli baca). Resmin her yeri ahşap, pirinç ve raf; taş-gri kule yapıştırılmış
gibiydi.

**Ölçüm:** 36 bölümde 18 baca; sekizi iç mekân resmi aralığında. Hepsini tek tek çektim: sarnıç
(15), külhan (19), su kemeri ve taş salon (24), kale (35) resimlerine taş kule zaten uyuyor;
Bölüm 26'daki açık rıhtım. Taşın yabancı durduğu yalnız iki resim: verici odası/kasa ambarı (33)
ve gemi kablo ambarı (36). Bu yüzden kural "iç mekân → ahşap" değil, bölüm başına seçim.

**Oyuncu ne hissedecek:** Verici odasında ve gemi ambarında tırmanılan kule, odanın kendi
eşyasından bir raf dolabı: rafta çuval, demir köşeli kasa, defter yığını, pirinç kavanoz;
içi is kararmış tahta. Gizli tırmanış yolu aynı, sahne bütün.

**Yapılanlar:** `tools/gen_gpt_style_props.py`: `make_depo_rafi` (20×90: ahşap dikmeler, beş
raf, rafın ilk eşyası rafa göre sabit → tekrar kırılır; sol üst sıcak ışık, sağ dikmede ay
kenarı, eşya sınırında koyu mor kontur, üst/alt kenar konturu yok → dikişsiz dikey döşeme) ve
`make_baca_tahta` (24×32). Diğer bütün çıktılar bire bir aynı üretildi. `DtmLevel.chimney_rack`
(varsayılan false): duvar `A_RACK` (altta hatıl tahtası), iç `A_SHAFT_WOOD`, tepe çatı yerine
ahşap kat. Bölüm 33 ve 36'da açık. Yan düzeltme: `tests/capture_level.gd` bekleme sırasında da
hikâye sahnelerini atlıyor (ışınlanınca tetiklenen sahne çekimi örtüyordu).

**Testler:** import temiz; DTM GAPS PASS; 36 sahne smoke çıkış 0; bot Bölüm 1 (8604), 13 (9559),
33 (9757), 36 (16256) CLEARED. Görsel: sekiz bacanın hepsi 1280×720; 33 ve 36 yeni hâliyle, 15
taş hâliyle ve 33 yakın çekim — raf eşyası resmin kendi raflarıyla aynı aileden, "ait".

**Sonraki öneri:** Birikimin kalanı insan testine bağlı → yeni denetim (Bölüm 22).

### 2026-10-26 (31) — Tasarım denetimi (Bölüm 33) + kesilen son savuruşta silah kırılır

**Neden şimdi:** Birikimin kalanı insan testine bağlı → denetim. Bölüm 33 (Vaniköy → Kandilli)
pencereli bot koşusu: CLEARED 9759, 82,3 sn, 0 ölüm, 13 kare. En somut bulgu bir hata: HUD
"Sopa -2/12" gösteriyordu. Silah yalnız savuruş `_finish_attack` ile bitince kırılıyordu; son
kullanımlık savuruş dash/zıplama iptali, hasar ya da yeniden doğmayla kesilince silah 0'da elde
kalıyor, sonraki savuruşlar dayanıklılığı eksiye indiriyordu (bedava sınırsız silah).

**Oyuncu ne hissedecek:** Sayaç 0'a inen silah her durumda kırılır (kırılma sesiyle); eksi sayı
yok, dayanıklılık kararları (son vuruşu neye harcayayım) anlamlı.

**Yapılanlar:** `Redmount._cancel_attack()` kesilen saldırı kullanımı bitmiş bir silah
savuruşuysa `_drop_weapon()` çağırır. Yeni `tests/weapon_break_cancel.tscn` (eski kodda FAIL,
yeni kodda PASS; kullanımı kalan silah kesilince elde kalır).

**Diğer bulgular:** Kandilli kablo kapısındaki koyu gri sütun otomatik baca kulesi (birikime).
(Önce anteni 4× ölçek yüzünden yoğunluk ihlali sandım; ölçünce ChatGPT arka planlarının ekrandaki
sanat pikseli ~10 ekran pikseli, proplar 3× — 4× bu aralıkta, ayrı ihlal değil; stil listesine
eklenmedi.) İyi çalışanlar: Vaniköy yalı resmi, YÜKLEME KİLERİ tabelası, iskele set-piece'i,
verici odası resmi.

**Testler:** import temiz; WEAPON BREAK CANCEL, NEW MELEE WEAPONS, KALDIRIM TASI, DTM GAPS PASS;
move_progression çıkış 0; 36 sahne smoke çıkış 0; bot Bölüm 1 (8605), 13 (9560), 25 (10160),
33 (9760) CLEARED.

**Sonraki öneri:** Birikim — iç mekân resmi önündeki otomatik baca kulesi.

### 2026-10-26 (30) — Tasarım denetimi (Bölüm 10) + nişancılar üst üste yığılmaz

**Neden şimdi:** Birikimin kalanı insan testine bağlı → denetim. Bölüm 10 (sur ve kale kapısı,
gece) pencereli bot koşusu: CLEARED 9205, 118,8 sn, 3 yeniden doğma, 19 kare. Bulgular:
(1) masaüstünde boss çubuğu telsizle ekrandan kayıyordu — tur 29'da düzeltildi; (2) son arenada
iki tüfekli muhafız arena kapısına yaslanıp üst üste duruyordu — rozet "2 DÜŞMAN" derken ekranda
tek gövde, iki namlu tek kişi gibi; (3) son arena zorluğu ve (4) kamera çerçevesi birikime.
İyi çalışanlar: ANA KAPI tabelası, ayna sinyali telsizi, kale arka planı, kombo kademeleri.

**Oyuncu ne hissedecek:** Nişancılar kademeli hatta durur (öndeki önde, arkadaki bir gövde
geride); kaç tüfek olduğu bir bakışta sayılır, hangisinin nişan aldığı ayrı okunur.

**Yapılanlar:** `EnemyBase._ranged_neighbor(dx, ahead)`: aynı taraftaki en yakın nişancı
komşusu (`_RANGED_GAP` 64 px ≈ bir gövde + boşluk). Arkadaki, öndekine 64 px'ten yakınsa geri
çekilir (duvar/kenar yoksa). Öndeki, oyuncu çok yakınken arkasında nişancı varsa geri çekilmez:
arkadaki duvara/kenara yaslıysa yarım hızla bir adım öne çıkar (panik menzilinin 40 px dışında
durur), değilse yerinde kalır. Eski 40 px ayrışma itişi geri çekilme hızını yenemiyordu.
Yeni `tests/ranged_spacing.tscn`: duvar önünde iki muhafız, oyuncu 150 px'te — eski kodda
18 px (FAIL), yeni kodda 63 px (PASS).

**Testler:** import temiz; RANGED SPACING PASS; DTM GAPS, DAILY WAVE, ARENA RESPAWN, TELEGRAPH
MARK PASS; 36 sahne smoke çıkış 0; bot Bölüm 1 (8607), 10 (9205), 13 (9560), 25 (10160) CLEARED.

**Sonraki öneri:** Birikimin kalanı insan testine bağlı → yeni denetim (Kitap 3'ten Bölüm 33).

### 2026-10-26 (29) — Düzeltme: masaüstünde boss çubuğu telsizle kaymaz

**Neden:** Bölüm 10 denetim koşusunda görüldü: masaüstünde boss çubuğu alta sabitli (anchor_top 1);
tur 26'da üst bant kaydırmasına eklenmişti, telsiz açıkken +110 px kayıp ekranın dışına
çıkıyordu (mobilde çubuk üstte, orada kayması doğru). Yalnız üste sabitli öğeler kaydırılır.
`radio_top_band` testi bu durumu denetliyor (eski kodda düştüğü doğrulandı: 46 ≠ −64).

**Testler:** RADIO TOP BAND PASS; DTM GAPS PASS; 36 sahne smoke çıkış 0; bot Bölüm 1 (8608),
10 (9205), 13 (9555), 25 (10155) CLEARED.

### 2026-10-26 (28) — Arka plan geçişi kısaldı: çift pozlama %55 → %15 (birikim)

**Neden şimdi:** Bölüm 16 denetiminin üçüncü bulgusu. Ölçünce sorun tek bölümün değil: `_Sky`
hücreleri 900 px boyunca doğrusal karışıyordu, Kitap 2–3'te hücreler ~1500 px'te bir değiştiği için
36 bölümün toplam yolunun ~%55'i iki ChatGPT resminin yarı saydam üst üste bindiği bulanık ara
hâlde oynanıyordu (çamaşırlı avluda cami kubbeleri, arşivde atölye rafları hayalet gibi).

**Oyuncu ne hissedecek:** Her semtin resmi net ve tek; geçiş koşarken ~0,7 sn'lik yumuşak bir
çözülme — "yeni bir yere girdim" duygusu, bulanık fotoğraf yok.

**Yapılanlar:** `_Sky.SKY_BLEND` 240 px (gerekçeli yorum) + smoothstep eğrisi (uçlarda yavaş,
ortada hızlı: en bulanık an daha da kısa). Ölçüm betiği: bölüm başına hücre aralıkları,
min(blend, aralık) / yol → 900 px'te %56, 240 px'te %15. Hücre konumları değişmedi.

**Testler:** import temiz; DTM GAPS PASS; 36 sahne smoke çıkış 0; bot Bölüm 1 (8604), 13 (9557),
16 (9955), 25 (10160) CLEARED. Görsel: Bölüm 16 x 4450 / 4680 / 4900 — cami avlusu ve çamaşırlı
avlu net, ara hâlde hayalet yok.

**Sonraki öneri:** Birikimin kalanı insan testine bağlı → yeni denetim (henüz bakılmayan bir
Kitap 1 bölümü, ör. Bölüm 10).

### 2026-10-26 (27) — Dalga arası rozet: "DALGA 2/2 GELİYOR!" (birikim)

**Neden şimdi:** Bölüm 16 denetiminin ikinci bulgusu, birikimin en üstü, ucuz. Bir dalga bitip
sonraki doğana kadar (arenada `wave_delay`, Survival'da 4 sn) rozet "DALGA 1/2 · 0 DÜŞMAN"
yazıyordu; oyuncu arenanın bittiğini sanıp kapıya koşabiliyordu.

**Oyuncu ne hissedecek:** Son düşman düşünce rozet açık sarıya döner ve "DALGA 2/2 GELİYOR!"
der — mola değil, hazırlık anı. Son dalganın sonunda zaten arena kapanıp rozet gizlenir.

**Yapılanlar:** `Hud.set_arena_wave`: kalan 0 ve `wave < total` ise sıradaki dalgayı duyurur,
renk (1,0; 0,9; 0,55). Arena ve Survival/Günün Dalgası aynı yolu kullanır. `tests/dtm_gaps.gd`
iki yeni denetim (dalga arası metni, son dalga sonu eski biçim).

**Testler:** import temiz; DTM GAPS PASS; DAILY WAVE PASS; 36 sahne smoke çıkış 0; bot Bölüm 1
(8606), 13 (9556), 16 (9960), 25 (10155) CLEARED. Görsel: Bölüm 16 arşiv salonu — rozet telsiz
panelinin altında, okunuyor.

**Sonraki öneri:** Birikim — biyom geçişi çift pozlama (ölç, kısalt ya da kapı arkasına sakla).

### 2026-10-26 (26) — Tasarım denetimi (Bölüm 16) + telsiz üst bandı örtmez

**Neden şimdi:** Stil listesi, yol haritaları ve P1'ler bitti; birikimin kalanı insan testine bağlı →
denetim. Bölüm 16 (Süleymaniye Arşivi) pencereli bot koşusu (CLEARED 9957, 76,7 sn, 6 sn'de bir
13 kare). En net bulgu üst bantta: telsiz paneli (y 16–116, x 410–1230) açıkken altında kalan her
şey kayboluyordu — FİLM RULOSU 1/3 afişinin başlığı, kombo bitiş yazısı ("COMBO x3 +45" panelin
içinden okunuyordu) ve arena sırasında DALGA rozeti. Oyuncu tam ödül anında ödülü göremiyordu.

**Oyuncu ne hissedecek:** Telsiz konuşurken dalga sayacı, kombo, yer/film afişi ve boss çubuğu
panelin hemen altına yumuşakça iner, telsiz susunca yerine döner; hiçbir bilgi örtülmez.

**Yapılanlar:** `RadioPanel.top_inset()` (panel saydamlığı × 110 px: panel altı 116 + 6 boşluk −
rozet tabanı 12; hikâye sahnesinde panel gizliyse 0). `Hud._follow_radio()` üst bant öğelerinin
taban offset'lerine bu payı ekler (`_top_band`: arena rozeti, kombo, boss çubuğu, ilk açılışta yer
afişi). Değer yalnız değişince yazılır. Yeni `tests/radio_top_band.tscn`. Telsizin eski
"ekranın altında" yorumu düzeltildi.

**Diğer bulgular (birikime, etki/maliyet sırasıyla):** (2) dalga arası "0 DÜŞMAN"; (3) biyom
geçişinde çift pozlama; (4) Bölüm 16 son üçlüde can düşüşü (insan testi). İyi çalışanlar: CİLTÇİ
tabelası, film rulosu ödül afişi, Beyazıt Yolu kapısı, kombo kademeleri. Duraklat düğmesi alt
ortada; telsizle çakışmıyor.

**Testler:** import temiz; RADIO TOP BAND PASS; DTM GAPS PASS; 36 sahne smoke çıkış 0 (`backdrop`
`Fx` uyarısı `-s` kipinin bilinen autoload sorunu); bot Bölüm 1 (8606), 13 (9558), 16 (9958), 25
(10160) CLEARED. Görsel: Bölüm 16 arşiv salonu 1280×720 — telsiz, DALGA 2/2, FİLM RULOSU ve
açıklama satırı alt alta, kombo sağda; çakışma yok.

**Sonraki öneri:** Birikim — dalga arası "SIRADAKİ DALGA".

### 2026-10-26 (25) — Tasarım denetimi (Bölüm 30) + arka sıra evler varsayılan kapalı

**Neden şimdi:** Birikimin kalanı insan testine bağlı → yeni denetim, Kitap 3'ten Bölüm 30 (bot
CLEARED, 10007). En büyük bulgu: yavaş kayan arka sıradaki üç genel Balat evi, ChatGPT arka
planının Beylerbeyi yalılarını, iskele köşkünü ve bahçe merdivenini yarıya kadar örtüyordu — hem
güzel resmi saklıyor hem yere yanlış mimari koyuyordu.

**Ölçüm:** 36 bölümün her biri iki noktada (x 1500, 4500) arka sıra açık/kapalı çekildi (144
görüntü, altı kontak sayfası). Her bölümde kapalı hâli eşit ya da daha iyi: Sirkeci garı, Galata,
Üsküdar şadırvanı, Kapalıçarşı, Anadoluhisarı, yalılar ve iskeleler ortaya çıkıyor; hiçbir yerde
boşluk açılmıyor (resimler zeminin altına kadar dolu). Bölüm 6–12 zaten kapalıydı.

**Oyuncu ne hissedecek:** Her bölümün arkasında o yerin kendi resmi: Beylerbeyi'nde yalı, Sirkeci'de
gar, Üsküdar'da şadırvan — "aynı sokak, farklı gökyüzü" hissi gider.

**Yapılanlar:** `DtmLevel.back_row_on` varsayılanı false (gerekçeli yorum), Bölüm 13'ün açık
`true` satırı kaldırıldı. Kod duruyor; bir bölüm isterse açar. Ön sıradaki katı evler (`_house`,
`A_BUILDING`) ve tur 21'in sıva boyaları yerinde. Not: tur 21'in boya çeşitlemesi en çok arka sırada
görünüyordu; artık yalnız ön sıra evlerde etkili.

**Yan bulgu (düzeltildi):** paralel pencerelerle çekimde odak kaybı duraklatma menüsünü açıp
kullanıcının gerçek kaydına `armory_seen=true` yazmıştı; değer geri `false` yapıldı. `capture_level`
gerçek kaydı kullanıyor — çekimleri sıralı yapmalı ya da ayrı kayıt yolu kullanmalı.

**Testler:** import temiz; DTM GAPS PASS; 36 sahne smoke çıkış 0; bot Bölüm 1 (8609), 13 (9555),
25 (10157) CLEARED.

**Sonraki öneri:** Ön sıra katı evler de yer yer aynı üç ev; Kitap 3 kıyı bölümlerinde ön sıranın
yerine yere özgü cephe (ahşap yalı cephesi) — büyük sanat işi, birikime.

### 2026-10-26 (24) — Bölüm 20 son avlu: Kemal Bey dövüşü izler, üçüncü dalgada kaçar (set-piece)

**Neden şimdi:** Denetimin üçüncü bulgusu. Son avlu düz üç dalgalı bir arenaydı; bölümün hedefi
Kemal Bey yalnız dövüşten sonraki hikâye sahnesinde ortaya çıkıyordu. DTM'de kaçan hedef dövüş
sırasında oyuncunun gözü önündedir — dövüşe "acele" duygusu katar.

**Oyuncu ne hissedecek:** Avluya girince sağ kapının ardında loş, küçük (arka plan) bir siluet:
Kemal Bey izliyor. Üçüncü dalga başlayınca arkasını dönüp kayığa koşar, Gazelle telsizden "Kemal
Bey kaçıyor! Çabuk, Redmount!" der; son dalga bir kovalamacanın son engeli olur. Hikâye sahnesi onu
kayığın başında yakalar.

**Yapılanlar:** `bolum20._kemal_watches(arena)`: dokunulmaz `AnimatedSprite2D` (Cutscene.ELITE_FRAMES,
0,52 ölçek, z −6, loş), `wave_changed` 3'te 2,2 hızlı yürüyüşle 520 px sağa çıkıp silinir, `cleared`
yedek temizlik. Kamera arenada kapılara kilitli olduğu için kapının 40 px içinde durur.

**Testler:** import temiz; DTM GAPS PASS; 36 sahne smoke çıkış 0; bot Bölüm 20 CLEARED (10108, üç
dalga, betik hatası yok). Görsel: avlu 1280×720 — siluet kapı ardında okunuyor, arka planda kalıyor.

**Sonraki öneri:** Birikim — tasnif salonunda havadaki düz coin hattı (hareketli platformun yayı).

### 2026-10-26 (23) — Öğretici ipuçları: başlık kartını bekler, üst üste binmez, piksel çerçeve

**Neden şimdi:** Denetimin "üst bant kalabalığı" bulgusu. Ölçünce telsiz bulgusu çekim yönteminin
eseriydi (oyuncu ışınlanıyordu; en erken telsiz x=2100, kart 3,6 sn — gerçek oyunda çakışmaz).
Ama gerçek çakışma Bölüm 1'in ilk saniyesinde, oyunun ilk izleniminde: bölüm adı kartının altında
iki öğretici ipucu üst üste. Üstelik ipucu kutuları `StyleBoxFlat` ile çizilmiş yuvarlak köşeli
düz kutulardı (piksel art kuralına aykırı).

**Oyuncu ne hissedecek:** Önce "BALAT SOKAKLARI" kartı tek başına, sönünce ipucu gelir; aynı anda tek
ipucu. Kutular HUD/telsizle aynı altın çerçeveli piksel panel, tuş rozeti piksel tuş başlığı.

**Yapılanlar:** `_TitleCard` grup "title_card"; `HintTrigger` kart varken görünmez (kalma süresi
de işlemez), yeni ipucu açılınca eskisi yol verir (`_gone`, `static var _current`); tekrar girişte
yeniden açılır. Çerçeveler `PixelUI.box("panel_hud")` / `("button_normal")`; `_box` (StyleBoxFlat)
silindi. Yeni `tests/hint_order.tscn`.

**Testler:** import temiz; HINT ORDER PASS; DTM GAPS PASS; 36 sahne smoke çıkış 0; bot Bölüm 1
(8605), 2 (9506), 13 (9555) CLEARED. Görsel: Bölüm 1 açılışı üç ardışık çekim — kart tek başına,
sonra tek ipucu, piksel çerçeve.

**Sonraki öneri:** Birikim — Bölüm 20 son avluda kaçış kayığı set-piece'i.

### 2026-10-26 (22) — Gecede kahramana soğuk ay ışığı konturu (birikim/denetim)

**Neden şimdi:** Denetimin en ucuz, orta etkili bulgusu. Gecede kahraman ve düşman aynı sıcak fener
konturuyla çevriliyordu; kalabalık dövüşte kim kim bir bakışta ayrılmıyordu (gündüzde zaten yalnız
düşman konturlu).

**Oyuncu ne hissedecek:** Gecede Redmount soğuk mavi ay ışığıyla, düşmanlar sıcak fener ışığıyla
konturlu — kahraman kalabalıkta hep bulunur. Renk tarzın "sağ kenarda soğuk ay parlaması"
kuralının ailesinden.

**Yapılanlar:** `DtmLevel.HERO_NIGHT_RIM` (0,62; 0,74; 1,0; 0,85) — kostümsüz `dark_rim` ve kostüm
malzemesinin konturu; `CostumeAccessory.rig_rim` varsayılanı aynı renk (sınıf referansı değil:
`DtmLevel`'e bağlamak `-s` derlemesinde döngüsel bağımlılık yaptı, smoke çökünce yakalandı).
Ölçüt: ton farkı fener (~35°) ↔ ay (~220°) ≈ 185° (≥ 120° hedefi).

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS, DARK RIM SCOPE, COSTUME ACCESSORY,
COSTUMES PASS; bot Bölüm 7 (9257), 20 (10108), 36 (16259) CLEARED. Görsel: Bölüm 20 gece, kahraman
ve sokak serserisi yan yana, yakın çekim — mavi/turuncu kontur net ayrılıyor.

**Sonraki öneri:** Birikim — üst bant kalabalığı (telsiz, bölüm kartı sönene kadar beklesin).

### 2026-10-26 (21) — Tasarım denetimi (Bölüm 20) + mahalle evlerine sıva boyası çeşitleri

**Neden şimdi:** Birikimin kalanı insan testine bağlıydı → TASARIM DENETİMİ. Bölüm 20 (Samatya Taş
Depoları) bot ile CLEARED (10109, 89,8 sn), altı çekim (sokak, pazar, deniz kapısı, depo girişi,
tasnif salonu, avlu). DTM'ye göre en büyük boşluk tekrar: 36 bölümün ön ve arka sırasında yalnız
üç ChatGPT evi, hepsi aynı bej sıvayla — her ekranda aynı ev 2–3 kez. Diğer dört bulgu birikimde
(etki/maliyet sırasıyla).

**Oyuncu ne hissedecek:** Mahalle sırası tek tip değil; aynı ev yan yana gül kurusu, gri-mavi,
okra ya da bej boyalı — eski İstanbul mahallesinin renk karışıklığı. Gece/arka sıra kararmasında
fark ince (koyu dramatik ton korunuyor), gündüz sokaklarında belirgin.

**Yapılanlar:** `tools/gen_house_variants.py`: yalnız sıva piksellerini (sıcak ton, orta
doygunluk; doygun+koyu tuğla/ahşap hariç; ≥ 1500 px bağlı bölge + kapanış) yeniden boyar,
parlaklık piksel piksel korunur, koyu tonlar mora kayar, fener vuran sıva sıcaklığını %65 korur.
Kesip yapıştırma yok: aynı çizim, yeni boya. `DtmLevel.house_tex(idx, n)`: `_house`, `A_BUILDING`
ve arka sıra ardışık konumlara farklı boya verir; arka sırada bölüm adına göre kayma.
Eski `Level01`/`parkour_set` (kampanyada kullanılmıyor) değişmedi.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; bot Bölüm 1 (8606), 13 (9559),
20 (10105) CLEARED. Görsel: Bölüm 20 (gece) ve Bölüm 2 (alacakaranlık) 1280×720 + yakın çekim;
üç evin dört boyası yan yana önizlemede: kapı, tuğla, kiremit, pencere ışığı değişmedi.

**Sonraki öneri:** Birikim — gecede kahramana soğuk ay ışığı konturu.

### 2026-10-26 (20) — Kitap şeridinde konuşma balonları (birikim)

**Neden şimdi:** Birikimin insan testine bağlı olmayan ilk anlamlı maddesi (pantolon maskesi
kalıntısı 2–4 px, tek başına tur değeri yok diye koşula bağlandı). Şerit kareleri yalnız alt
yazıyla anlatıyordu; DTM'nin çizgi romanında karakterler konuşur.

**Oyuncu ne hissedecek:** Kare yerine oturduktan 0,35 sn sonra konuşanın başında kısa bir balon:
"Bitti, Karahanlı.", "Geç kaldın.", "Haliç'e!", "Akıyor...", "Duyuyor musun?", "Herkes duydu.",
"Adım temiz.", "Eve gidelim." — alt yazı anlatır, balon karakterin sesi olur (alt yazıyı
tekrarlamaz). Nesne kareleri (defter, not, matbaa, simit) balonsuz.

**Yapılanlar:** `book_comic.gd` `PAGES[*].bubbles` ([yazı, ağız x'i] ya da boş); balon oyun içi
diyaloğun aynı piksel çerçevesi (`PixelUI.box("balon")`) + `balon_kuyruk.png` — yeni görsel
çizilmedi. Konum kare iç kenarına kıstırılır, sanat pikseline (3) yuvarlanır. `BUBBLE_DELAY`
0,35 sn (gerekçe: çakılma 0,18 + oturma 0,21 sn'den sonra; göz önce sahneyi, sonra sesi okusun).
Kayıt formatı değişmedi.

**Testler:** import temiz; `book_comic` PASS (yeni: balon yazıları, oturmadan görünmez, balonsuz
kare, kare içinde ve piksel ızgarasında), `archive_comic` PASS, DTM GAPS PASS; 36 sahne smoke çıkış
0; bot Bölüm 12 (kitap sonu) CLEARED (7380). Görsel: üç kitabın şeridi 1280×720 — balonlar okunur,
kuyruklar konuşana iniyor, çerçeve dışına taşma yok. Telefonda görülmedi.

**Sonraki öneri:** Birikimin kalanı insan testine bağlı → TASARIM DENETİMİ (Kitap 2'den bir bölüm).

### 2026-10-26 (19) — Tuğla cephe zemin katı: mahalle dükkânı + yükleme kepenkleri (birikim)

**Neden şimdi:** Tur 16'nın birikime bıraktığı dilim. Pencereler çeşitlendi ama zemin kat hâlâ
düz tuğlaydı; sokak seviyesi, oyuncunun en çok baktığı yer.

**Oyuncu ne hissedecek:** Konut/han cephesinde kapının yanında tabelalı, çizgili tenteli, kepengi
yarıya inmiş bir mahalle dükkânı — altından sıcak ışık sızıyor. Haddehanede son pencere sırasının
altında iki paslı yükleme kepengi. Sokak "yaşanıyor" hissi verir, oyun alanına dokunmaz (süs).

**Yapılanlar:** `dukkan.png` (40×32; WOOD/BRASS tabela, RED/CREAM tente, STEEL oluklu kepenk +
perçinden pas akıntısı, WARM_GLASS ışık aralığı, STONE eşik; mor kontur, sağda ay parlaması).
`_Facade` stil 0 zemin katta yer varsa (kat ≥ 104 px, cephe ≥ 350 px) dükkânı kapının yanına koyar,
pencereler ondan sonra başlar. `A_FACTORY` son sıra ile zemin arası ≥ 60 px ise satır 14–31'i
(kepenk + ışık) yükleme kapısı olarak bir/iki kez çizer.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; bot Bölüm 3 (9006), 7 (9258),
9 (9409) CLEARED. Görsel: Bölüm 7 haddehane (kepenkler) ve Bölüm 9 üs cephesi (dükkân, gece tonu
altında) 1280×720 + yakın çekim — han kapısıyla aynı dilde, sahneye ait.

**Sonraki öneri:** Birikimin kalanı insan testine bağlı; tasarım denetimi (d) ile yeni iş çıkar.

### 2026-10-26 (18) — Saldırı uyarısı: piksel ünlem + beyaz kontur kırpışması (birikim/denetim)

**Neden şimdi:** Birikimin en üstü. Uyarı, yazı tipiyle çizilen 22 px "!" idi: yukarı kayıp 0,3 sn'de
soluyordu, denetim çekimlerinde hiç yakalanmadı; suikastçının 0,12 sn hazırlığında fark edilmiyordu.
Üstelik piksel art kuralına aykırı (font çizimi).

**Oyuncu ne hissedecek:** Saldıracak düşmanın başında 10×18 piksel ünlem (3x → ~54 px, eskinin
~2,5 katı) belirip hafifçe zıplar; aynı anda düşmanın konturu beyaz kırpışır — kalabalıkta
"hangisi vuracak" bir bakışta okunur. Ağır saldırı / atış / hamle kızıl, normal kehribar.

**Yapılanlar:** `saldiri_uyari.png` (gen_gpt_style_props: HAZARD/RED rampası, sol üst ışık, sağda ay
parlaması, mor kontur; uyarı olduğu için rampanın üst yarısı — tarzın karanlık kuralına bilinçli
istisna). `EnemyBase._telegraph()` + `_Warn`: hazırlık süresince kalır, en az `MIN_SHOW` 0,28 sn
(gerekçe: ~17 kare, 60 fps'te göz için alt sınır), vurulunca/devrilince hemen kalkar; kırpışma
`FLASH_PERIOD` 0,06 sn yalnız gerçek hazırlıkta, bitince taban kontur geri yazılır. Yakın dövüş,
nişan, hamle ve hikâye patronunun şok dalgası aynı uyarıyı kullanır (4 `Fx.popup` "!" kalktı).
Önceki turun gündüz konturu `tests/dark_rim_scope` testini kırmıştı (gündüzde kontursuz bekliyordu);
test yeni davranışa (biome rengi × `DAY_RIM_ALPHA`, gece rengi asla) güncellendi.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS, DARK RIM SCOPE (güncellendi), yeni TELEGRAPH MARK, HUD HINTS PASS; bot Bölüm 1 (8604), 12 (7385), 25 (10158), 36 (16256, son patron) CLEARED. Görsel: Bölüm 2’de üç düşman; vuran beyaz konturlu + ünlemli, diğer
ikisi zayıf sıcak konturlu, 1280×720 + yakın çekim; ünlem baştan 10 px yukarı alındı.

**Sonraki öneri:** Birikim — tuğla cephe alt katında dükkân.

### 2026-10-26 (17) — Gündüz/alacakaranlıkta düşmana zayıf kenar ışığı (birikim/denetim)

**Neden şimdi:** Birikimin en üstü. Gece olmayan 15 bölümde (1, 2, 5, 13–18, 23–28) düşmanın hiç
konturu yoktu; koyu ceketli bıçakçı ve lacivert zırhlı kalkanlı koyu kapı/duvar önünde zemine
karışıyordu.

**Oyuncu ne hissedecek:** Düşman, bölümün biome renginde ince sıcak bir hatla zeminden ayrılır;
kahramanın konturu yok, böylece dost/düşman bir bakışta ayrılır (DTM'de düşman okunurluğu).
Gece bölümlerinin dramatik fener konturu değişmedi.

**Yapılanlar:** `Level.level_of()` (ata zincirindeki bölüm); `enemy_base._apply_dark_rim` gece
değilse `edge_light` alfasını `DAY_RIM_ALPHA = 0.5` ile çarpar (gece 0,85 → gündüz biome'a göre
~0,33–0,35). Gerekçe: denetimin %50 önerisi; tam alfanın gündüz ışığında çizgi film konturu gibi
bağıracağı varsayımı (denenmedi) — insan testinde ayarlanacak. Mevcut `dark_rim` shader'ı yeniden kullanıldı.

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; bot Bölüm 1 (8605), 13 (9560), 15 (9740), 25 (10160) CLEARED. Görsel: Bölüm 2 sokak (üç düşman, siyah bıçakçı koyu kapı önünde
okunuyor) ve Bölüm 15 kalkanlı (lacivert zırh koyu duvardan ayrılıyor), 1280×720 + yakın çekim.
Sayısal parlaklık ölçümü yapılmadı; görsel değerlendirme.

**Sonraki öneri:** Birikim — saldırı uyarısı (`!`) 2x + beyaz kontur kırpışması.

### 2026-10-26 (16) — Tuğla cephe: pencere çeşitleri + kat silmesi (birikim/denetim)

**Neden şimdi:** Birikimin en üstü. Bölüm 7 haddehanesinin 600×480 tuğla cephesi (`A_FACTORY`,
birikimde yanlışlıkla `_interior` yazılmıştı; ikisi de düzeltildi) aynı yanan pencereyi 4×7
ızgara hâlinde basıyordu; ChatGPT arka planının yanında şablon gibi duruyordu.

**Oyuncu ne hissedecek:** Cephe yaşanmış bir bina gibi: kimi pencere yanıyor, kimi karanlıkta ay
yansıtıyor, kimi ahşap kepenkli, birkaçına tahta çakılmış; konut cephelerinde saksılı sardunya.
İki sırada bir taş kat silmesi yüksek duvarı katlara böler.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `cephe_pencereleri.png` (5 × 14×20 şerit, aynı
`arch_window` söve; WARM_GLASS/SEA/WOOD/OLIVE/LEAF/RED rampaları, mor kontur) ve `kat_silmesi.png`
(16×6 STONE korniş, altta mor gölge). `DtmLevel.facade_window()` konum hash'inden ağırlıklı çeşit
seçer — yanan %35, karanlık %30, kepenk %20, tahta %15 (saksı izinliyse yanan payının bir kısmı);
gerekçe: tahta çarpısı en çok göze batan, ilk denemede eşit dağılımda cephenin ~%40'ı çarpı
görünüp gürültü yaptı. Ardışık iki pencere aynı olmaz (ölçüt: yan yana tekrar ≤ 1). Fabrikada
saksı yok. `_interior` stil 0'da katlar arasına kat silmesi.

**Testler:** import temiz; 36 sahne smoke çıkış 0 (36 SMOKE OK; başlangıçtaki `Fx` derleme uyarısı `-s` autoload kaynaklı, önceden var); DTM GAPS PASS; bot Bölüm 3 (9009), 7 (9255), 12 (7374) CLEARED. Görsel: Bölüm 7 haddehane cephesi 1280×720, ChatGPT gün batımı
arka planının yanında — tonlar (koyu tuğla, sıcak cam, mor gölge) sahneye ait.

**Sonraki öneri:** Birikim — alacakaranlıkta karakter/zemin ayrışması (zayıf kenar ışığı).

### 2026-10-26 (15) — HUD sadeleştirme: öğrenilen ipucu gizlenir, yumruk yazılmaz (birikim/denetim)

**Neden şimdi:** Denetimin birikime yazdığı en üst madde. Masaüstü HUD'u her karede
`COIN 32 · ESC: CEPHANELİK` ve `Silah: Yumruk` yazıyordu — ayrıntılı arka plan üstünde okunması
gereken iki satır düz metin, ikisi de bilgisi çoktan öğrenilmiş şeyler.

**Oyuncu ne hissedecek:** Sol üstte yalnız can çubuğu ve `COIN 032`; silah alınca kısa `Sopa 8/10`.
Cephanelik ipucu oyuncu duraklatmayı bir kez açana kadar (Bölüm 2'den itibaren) durur, sonra
kaybolur — DTM'nin ipucu bir kez öğretip geri çekilme tavrı.

**Yapılanlar:** `Save.armory_seen` (`[hints] armory_seen`, eski kayıtta false, `wipe()` sıfırlar,
`set_armory_seen()`); `PauseMenu.open()` bayrağı yazar; `hud.gd` ipucu koşulu ve kısa silah
satırı (yumrukken boş; ad `to_upper` edilmez — Türkçe i/İ bozuluyordu). Ölçüt: sabit HUD metni
~38 → 8 karakter (silahsız).

**Testler:** import temiz; 36 sahne smoke çıkış 0; DTM GAPS PASS; yeni `tests/hud_hints.tscn` PASS; bot Bölüm 1 (8604), 13 (9559), 25 (10157) CLEARED. Görsel: Bölüm 7 HUD 1280×720 — ipucu ilk kez görünüyor, silah satırı boş, çakışma yok.

**Sonraki öneri:** Birikim — Bölüm 7 tuğla cephe çeşitlemesi.

### 2026-10-26 (14) — Tasarım denetimi (Bölüm 7) + düşük can uyarısı

**Neden şimdi:** Stil listesi, yol haritası ve P1'ler bitti; birikimin kalanı insan testine bağlı.
Kural gereği denetim: Bölüm 7 (Karahanlı Haddehanesi) pencereli bot koşusu (104 sn, CLEARED),
7 sn'de bir 15 kare; 8'i DTM sütunlarıyla karşılaştırıldı.

**Bulgular (etki/maliyet sırasıyla birikime yazıldı):** (1) düşük can için hiçbir geri bildirim
yok — bot 15/115 cana kadar iniyor, ekranda yalnız küçük çubuk sarıya dönüyor (DTM'de kenar
kızarır, kalp atar); (2) HUD düz metin kalabalığı; (3) tekrar eden tuğla cephe şablon gibi;
(4) alacakaranlıkta koyu düşman koyu zemine karışıyor; (5) saldırı `!` işareti küçük. İyi
çalışanlar: kombo yazısı (EFSANE x18), dalga sayacı, büfe tabelası, konuşma panelleri.

**Bu turda uygulanan (1):** `hud.gd` düşük can uyarısı — can ≤ %30'da tam ekran piksel art kenar
(`assets/ui/pixel/tehlike_kenar.png`, 320×180, 4×4 Bayer dither, kırmızı rampa, `gen_gpt_style_ui.
tehlike_kenar()`), kalp atışı gibi çift vuruşla parlar; ≤ %15'te nabız 1,0 → 0,62 sn. Can çubuğu
dolgusu atışla kızarır; her atışta `land` sesi 0,55 perde, −14 dB. Duraklatmada, sonuç kartında,
ölümde ve iyileşince söner. Kenar HUD öğelerinin arkasında, dokunuşu engellemez.
**Sayılar (hipotez):** %30 mevcut çubuk renk eşiğiyle aynı; taban parlaklık 0,3/0,45 (kritik) —
sürekli görünür ama oyun alanını kapatmaz; ikinci atış 0,17 sn sonra %70 güçte (lub-dub).
İlk sürüm 160×90'dı ve kaba "ekran kapısı" deseni veriyordu → 320×180, bant 0,2 → 0,13.

**Testler:** `--import` hatasız; `touch_polish`, `level_stars`, `costume_badge` PASS; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (77,2 sn), 13 (81,7 sn), 25 (80,8 sn) CLEARED. Yeni `tests/low_health.tscn` PASS (görünmezlik, atış zirvesi > 0,8, taban
≥ 0,29, kritik bölge, ölümde/iyileşince sönme, dokunuş geçirgenliği). Görsel: Bölüm 7, can 12/115.

**Sonraki öneri:** Birikimin en üstü — HUD metin kalabalığı.

### 2026-10-26 (13) — Havada elde kaldırım taşı (`tas_jump`, birikim)

**Neden şimdi:** Stil listesi, yol haritası ve üçüncü denetimin P1'leri bitti; birikimin en
üstündeki madde. Taş tutan oyuncu zıpladığında `jump` sayfası silahsız olduğu için taş elden
kayboluyor, havada fırlatınca mermi boş elden çıkıyordu.

**Oyuncu ne hissedecek:** Zıplama boyunca taş öndeki yumrukta; havada atış artık elden çıkan
taş gibi okunuyor. İniş karesinde öndeki el yüze yapışık olduğundan taş arka elde (5 kareden
1'i; okunur).

**Yapılanlar:** `gen_tas_sheets` `jump` sayfasını da üretir; çömelmiş pozda yüz kalça eşiğinin
altına indiği için yumruk ten bileşenleriyle bulunur (`_front_fist_crouched`: en yüksek leke
yüz, yüzün hemen altı dışarıda, kalanların en öndeki). İlk iki kural (en alçak / en üst hariç
en sağ) taşı yüze ya da arka ele koydu. `PlayerSprite.TAS_SHEETS["tas_jump"]`. Idle/walk
sayfaları birebir aynı kaldı.

**Testler:** `--import` hatasız; `kaldirim_tasi`, `new_melee_weapons`, `costumes`, `costume_accessory` PASS; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (79,9 sn), 13 (80,6 sn), 25 (80,7 sn) CLEARED. Görsel: Bölüm 13'te taşla zıplama dört kare — animasyon `tas_jump`,
taş elde, "ait".

**Sonraki öneri:** Birikimde kalanlar insan testine bağlı; bir sonraki tur TASARIM DENETİMİ
(bot ile 1–2 bölüm, DTM karşılaştırması, yeni birikim).

### 2026-10-26 (12) — Stil listesi 6: kaynak kontrolü + kitap şeridi katmanları

**Neden şimdi:** Stil listesi 6'nın "kontrol et" maddeleri; liste bitmeden başka işe geçilmiyor.

**Bulgular:**
- `environment/kit/*` (16 parça) ve `mahalle/{plant_small,tree_pot,vase_*,wall_*,portrait}`:
  hepsi 2 800–322 000 renkli, 4 Ekim'den beri değişmemiş — ChatGPT kesitleri. Dokunulmadı.
- `ui/comic/*`: sahne kesitleri arka plan atlaslarından (ChatGPT); Claude katmanları elle
  boyanmış defter, not kâğıdı, simit (düz palet) ve mürekkep çerçeve. Bunlar ikon geçişinden
  (`restyle`) geçirildi, çerçeve konturu koyu mor; yeni film/telsiz dokuları karelere girdi.

**İkon geçişine düzeltme (önceki turun ikonları da yeniden boyandı):** nötr griler koyu
mürdüm rampasına düşüp açık uçlarını kaybediyordu (film rulosunun delikleri, telsiz gövdesi
silindi) → nötr gri artık `STEEL`. Kâğıt/krem için ayrı `PAPER` sınıfı (not kâğıdı tene
kayıyordu), ahşaba +0,1 ışık; simidin kabuk rengi kaynağı tuğla yerine ahşap kahvesi (kırmızı
halkalı çörek gibi duruyordu). Tüm ikonlar orijinal düz hâllerinden yeniden üretildi.

- `ui/photos/*` (Kanıt Arşivi): fotoğraflar arka plan atlası kesiti (ChatGPT). Claude katmanı
  1 px çerçeve ve Günün Dalgası "N. GÜN" damgası (düz kırmızı kutu): çerçeve koyu mor,
  damga 8 tonluk mühür mürekkebi rampasında, üstte dolu altta incelen, yer yer kâğıda
  tutmamış piksel (`tools/gen_photos.py`). 111 dosya çerçeve rengi yüzünden değişti.

**Testler:** `--import` hatasız; `archive_comic`, `book_comic`, `daily_wave`, `touch_polish`, `level_stars`, `costume_badge` PASS; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (80,9 sn), 13 (77,3 sn), 25 (80,7 sn) CLEARED. Görsel: 12 kitap karesi, ikonlar ve üç fotoğraf önce/sonra — "ait".
(Bir test turu, `grep book` filtresi 24 uzun `book0x_level_play` testini yakaladığı için
durduruldu ve hedefli testlerle yeniden koşturuldu.)

**Stil uyumu tamam.** `STIL_DONUSUM_LISTESI.md`'de açık madde kalmadı.

**Sonraki öneri:** YOL_HARITASI ve üçüncü denetimin P1'leri bitti → tasarım birikiminin en üstü (havada fırlatmada elde taş: `tas_jump`).

### 2026-10-26 (11) — Logo ve alt başlık ChatGPT tarzında (stil listesi 5/logo)

**Neden şimdi:** Stil listesi 5'in sıradaki maddesi. REDMOUNT logosu 4 bantlı düz turuncu→
kırmızı degrade, alt başlık 4 bantlı altındı.

**Oyuncu ne hissedecek:** Ana menüde logo boyalı bir tabela harfi gibi: 9 tonluk kırmızı-
turuncu rampa, 2×2 kümeli boya dokusu ve yer yer kalkmış boya, harf üstünde ince fener ışığı,
sağ kenarda ay ışığı, mora inen 3 piksellik derinlik, koyu mor kontur. Alt başlık 6 tonluk
pirinç rampada. İlk denemede üst kenar krem şeridi fazla genişti ve kırmızı kimlik zayıfladı;
rampa kırmızıya kaydırıldı (`0.84 - t*0.6`), ışık şeridi `ramp[-2]` + %25 kreme indi.
**Hipotez:** yeni logo alacakaranlık göğünde eskisinden daha az parlıyor (sahneyle bütün,
ama marka vurgusu azaldı) — insan testi gerekirse rampanın üst ucunu bir ton açmak yeter.

**Yapılanlar:** `tools/gen_pixel_menu.py` `logo()` yeniden yazıldı (`LOGO_RED`, `LOGO_GOLD`);
yalnız `logo()` çağrılarak üretildi (aracın `main`'i yeniden boyanmış ikonları ezerdi).

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (84,2 sn) CLEARED (yalnız menü dokusu değişti). Görsel: ana menü 1280×720 — "ait".

**Ek (aynı tur, portre kontrolü):** `portre_gazelle/karahanli/redmount` 845–1217 renkli,
ChatGPT karakter karelerinden kesit — dokunulmadı. `portre_telsiz` 9 renkli Claude çizimi:
`ikonlar(["portre_telsiz"])` ile aynı malzeme rampalarından geçirildi (yeşil ekran rengi
korunur). Testler: `--import` hatasız, `tests/campaign_smoke.gd` çıkış 0, `dtm_gaps` PASS;
yalnız doku değişti.

**Sonraki öneri:** Stil listesi 6 — `environment/kit/*` ve `mahalle/*` küçük parçaların
kaynak kontrolü.

### 2026-10-26 (10) — Arayüz ikonları ChatGPT tarzında (stil listesi 5/ikonlar)

**Neden şimdi:** Stil listesi 5'in sıradaki maddesi. 17 küçük ikon (coin, kilit, film, odak,
pip, tutamaç, çubuk zemin/dolgu, tüfek/yumruk ikonu, üç hâlde iki boy yıldız) 3–4 sabit
tonla boyanmış düz şekillerdi.

**Oyuncu ne hissedecek:** Tasarımlar aynı (oyuncu ikonları tanıyor), ama malzemeleri artık
sahnedeki gibi: pirinç/altın, soğuk demir, ahşap, ten ve kırmızı kendi 8–9 tonluk rampasında;
sol üstten ışık eğimi, sağ kenarda ay ışığı, en açık tonda sıcak parlama, koyu mor kontur.
Yıldızın üç hâli (dolu altın / önceki koşudan soluk okra / boş mürdüm) ayrık kaldı.

**Yapılanlar:** `tools/gen_gpt_style_ui.py`: `ikonlar()` her ikonu sanat ölçeğine indirir
(ölçek ölçüldü: 11 ikon 3x, yıldızlar 1x), pikselleri malzeme sınıfına göre (`_material`:
doygunluk/ton) rampaya oturtur, geri büyütür. Bir kez çalışır (`--ikonlar`); eski üreticilere
(`gen_pixel_menu/ui/stars`) "yeniden çalıştırırsan ardından `--ikonlar`" notu eklendi. İlk
geçişte yumruk teni altına, can çubuğu bordoya, boş pip kontura düştü: ten sınıfı (mavi kanal
> 0,42·kırmızı) altından önce, kırmızıya +0,18 ışık, kontur eşiği 45 → 30.

**Testler:** `--import` hatasız; `touch_polish`, `level_stars`, `costume_badge` PASS; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (83,3 sn), 13 (81,7 sn), 25 (79,3 sn) CLEARED. Görsel: bölüm seçme (yıldızlar), mağaza (coin, sekme), Bölüm 2 HUD
1280×720 — "ait".

**Sonraki öneri:** Stil listesi 5 — logo, logo_alt.

### 2026-10-26 (9) — Menü ve dokunmatik düğmeler ChatGPT tarzında (stil listesi 5/düğmeler)

**Neden şimdi:** Stil listesi 5'te "mobilde sürekli ekranda, yüksek öncelik" diye işaretli
madde. Menü düğmeleri düz renk gövde + tek renk altın çizgi, dokunmatik daireler düz mürdüm
disk + 4 sabit altın tonuydu.

**Oyuncu ne hissedecek:** Telefonda başparmağın altındaki halkalar artık sahnedeki fener
pirinciyle aynı: açıya göre gölgelenen pirinç halka (sol üst sıcak, sağ alt ay ışığı), yarı
saydam mürdüm gövdede hafif doku; basınca içe gömülen ateş rengi. Menü düğmeleri ahşap/lake
levha: üst/sol pah ışıkta, basılıyken ters, içte ışık-gölgeli altın çizgi; devre dışı soğuk
demir. İkonlar (ok, duraklat) krem rampa.

**Yapılanlar:** `tools/gen_pixel_touch.py` yerinde ChatGPT kurallarına çevrildi (boyutlar,
saydamlık ve basılı/normal mantığı aynı). Menü düğmeleri `tools/gen_gpt_style_ui.py`
`dugmeler()`'e taşındı; `gen_pixel_ui.py`'deki eski `buttons()` silindi.

**Testler:** `--import` hatasız; `touch_polish`, `level_stars` PASS; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (82,6 sn), 13 (75,7 sn), 25 (77,2 sn) CLEARED. Görsel: ana menü ve `REDMOUNT_TOUCH_CONTROLS=1` ile Bölüm 13
dokunmatik düzeni 1280×720 — "ait", yazılar ve ikonlar okunuyor. Basılı hâl yalnız doku
önizlemesinde görüldü (çekimde dokunuş üretilmedi).

**Sonraki öneri:** Stil listesi 5 — ikonlar (coin, kilit, film, pip, yıldız, ikon_*, odak,
tutamaç, çubuk).

### 2026-10-26 (8) — Arayüz çerçeveleri ChatGPT tarzında (stil listesi 5/çerçeveler)

**Neden şimdi:** Stil listesi 5'in ilk maddesi. Panel, HUD paneli, bölüm kartı, kitap
sekmesi ve konuşma balonu `Canvas.rect` ile düz renkli dikdörtgen + tek renkli altın
çizgiydi; oyuncu bunlara menüde, HUD'da ve her diyalogda bakıyor.

**Oyuncu ne hissedecek:** Çerçeveler sahnedeki ahşap ve pirinçle aynı malzeme: sakin damarlı
koyu mürdüm ahşap zemin (yazının altı bilerek düşük kontrastlı), üst/sol kenarı fener
ışığında ahşap pah, içte eski Osmanlı çizgisi korunarak ışık-gölgeli altın, köşede sıcak
parlamalı perçin; kartın üstünde kırmızı lake şerit; balon sıcak kâğıt. İlk denemede iç
altın çizgi kaybolmuş, kenar sert sarıydı ve kâğıt yazı altında fazla gürültülüydü —
eski dilin üstüne yeniden kuruldu, kâğıt titreşimi 0,25 → 0,1'e indi.

**Yapılanlar:** yeni `tools/gen_gpt_style_ui.py` → `assets/ui/pixel/{panel,panel_hud,kart,
kart_kilitli,sekme,sekme_secili,balon,balon_kuyruk,balon_ad}.png` (boyut ve 9 parça payları
aynı, 3x). `gen_pixel_ui.py` / `gen_pixel_menu.py` artık bu dosyaları yazmıyor (yeniden
çalıştırınca ezilmesin).

**Testler:** `--import` hatasız; `touch_polish`, `level_stars`, `costume_badge` PASS; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (76,3 sn), 13 (80,6 sn), 25 (87,8 sn) CLEARED. Görsel: ana menü bölüm seçme ekranı (12 kart + 3 sekme) ve Bölüm 1
(HUD paneli, başlık kartı, Gazelle'in konuşma balonu) 1280×720 — "ait", yazılar okunuyor.

**Sonraki öneri:** Stil listesi 5 — düğmeler (`button_*`, `touch_*`; mobilde sürekli ekranda).

### 2026-10-26 (7) — Kostüm palet takası ChatGPT ışık kuralına (stil listesi 3/palet takası)

**Neden şimdi:** Stil listesi 3'ün "kontrol" maddesi. Bulgu: kostüm shader'ı ceket/pantolon
grisini iki uçlu doğrusal karışımla (`shade` → `light`) boyuyordu; sonuç tek tonlu ve
doygundu — özellikle vapurcu ceketi gece sahnesinde parlak mavi bir leke gibi okunuyordu.
ChatGPT karelerinde gölge mor-laciverte, ışık turuncu-altına kayar.

**Oyuncu ne hissedecek:** Kostümler karakterin kendi deri ceketiyle aynı ışıkta: koyu
kıvrımlar mora iner, fener tarafı hafif sıcaklaşır; renk kimliği (lacivert/haki/kahve/
kızıl) korunur ama sahneden kopmaz.

**Yapılanlar:** `shaders/player_costume.gdshader`: rampa üstüne gölge ucunda %30'a kadar
(0.13,0.08,0.2) mor karışım, açık uçta (k>0.6) %60'a kadar sıcak çarpan (1.12,1,0.82).
`shop.gd`: vapurcu `light` (70,110,180) → (64,92,150). Sayılar hipotez: mor karışım,
kontur ve gölge mürdümüyle aynı aileden; daha fazlası ceketi siyaha yaklaştırıp renk
kimliğini siliyor.

**Testler:** `--import` hatasız (shader derlendi); `costumes`, `costume_accessory`,
`costume_badge`, `new_melee_weapons` PASS; `tests/campaign_smoke.gd` çıkış 0;
`tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (77,3 sn), 13 (82,0 sn), 25 (93,3 sn) CLEARED.
Görsel: Bölüm 13 çekiminde dört kostümün önce/sonra karşılaştırması — "ait".

**Aynı turda kontrol edilen iki madde (değişiklik yok):**
- Sopa/bıçak/tabanca/tüfek elde görünümü (`bat_*`, `knife_*`, `pistol_*`, `rifle_*`): sayfalar
  ilk commit'ten (960cc98d) beri karakterle birlikte çizilmiş temel sanat; `gen_pixel_weapons`
  ve `gen_weapon_mask` onlara yalnız görünmez kostüm işareti (alfa 252) yazar. Yoğunluk aynı.
- Pickup ikonları (stil listesi 4: ammo…speed): hepsi ilk commit'ten, hiçbir üreticide yok,
  zengin tonlu ve sol üst ışıklı — kaynak ChatGPT/temel sanat; kurala göre dokunulmadı.

**Sonraki öneri:** Stil listesi 5 — arayüz çerçeveleri (panel, kart, sekme, balon).

### 2026-10-26 (6) — Kostüm başlıkları ChatGPT tarzında (stil listesi 3/kostüm başlıkları)

**Neden şimdi:** Stil listesi 3'ün sıradaki maddesi. Dört başlık (kahveci kasketi, hamal
beresi, vapurcu kaptan şapkası, Kızıl Dağ bandanası) 4 tonla ve düzenli `(x+y)%2` dama
dither'ıyla boyanıyordu — ChatGPT karelerinin yanında desen gibi parlıyordu.

**Oyuncu ne hissedecek:** Başlık artık karakterin üstüne yapıştırılmış çıkartma değil, aynı
ışığın altında: 8–9 tonluk rampa (tüvit kahve, haki yün, krem tepe + lacivert bant, kırmızı
pamuk), 2×2 kümeli kumaş gürültüsü, sol üstte sıcak fener parlaması, sağ kenarda ay ışığı,
cilalı siper, pirinç çapa rozeti, koyu mor kontur.

**Yapılanlar:** `tools/gen_costume_accessory.py`: `_ramp` rampa uzunluğundan bağımsız,
konuma bağlı sabit `_noise`; `TWEED/KHAKI/CREAM/NAVY/RED` rampaları, adlı palet renkleri
(`wood0`, `iron2`, `gold1`...) rampa indekslerine çevrildi. Yeni `main_hats()` yalnız dört
PNG'yi yazar. **Not:** aracın `--preview` bayrağı önizlemeden önce tam `main()`'i (çapa
tablosu, ön saç atlası, saç işaretleri) çalıştırır; başlık işinde `main_hats()` + `preview()`
kullanılmalı. Ön saç atlası (`head_front.png`) karakter karelerinden kesildiği için
temel sanattır, dokunulmadı.

**Testler:** `--import` hatasız; `costumes`, `costume_accessory`, `costume_badge` PASS; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (88,8 sn), 13 (77,6 sn), 25 (80,7 sn) CLEARED. Görsel: Bölüm 13 (Haliç) pencereli çekiminde dört kostüm palet
takası + başlıkla — "ait"; ilk sürümde tek pikselli gürültü kumlu duruyordu, 2×2 kümeye
ve daha düşük genliğe çekildi.

**Sonraki öneri:** Stil listesi 3 — kostüm palet takası kontrolü (vapurcu laciverti
çekimde fazla doygun mavi görünüyor; `gen_costume_mask.py` / kostüm rampaları).

### 2026-10-26 (5) — Boru anahtarı, şemsiye ve kaldırım taşı ChatGPT tarzında (stil listesi 3)

**Neden şimdi:** Stil listesi 3'ün ilk maddesi. Anahtarın eldeki kareleri sopa
sayfalarından 4 tonluk düz rampayla (RED/STEEL, siyaha yakın kontur) boyanıyordu;
yerdeki ikon da 4 tonluk, dokusuz bir çizimdi.

**Oyuncu ne hissedecek:** Elde ve yerde aynı nesne: kırmızı emaye sap (8 ton, gölgesi
mor bordoya kayar, yer yer kalkmış boyanın altından çelik), dövme çelik baş üstünde pas
benekleri, ışığa bakan uçta sıcak fener parlaması, sağ kenarda soğuk ay ışığı, koyu mor
kontur. İlk denemede sap fazla koyu bordoya düştü ve "kırmızı anahtar" okunmuyordu;
rampa yukarı kaydırıldı (sap `v*0.7+0.28`, baş `v*0.75+0.22`).

**Yapılanlar:** `tools/gen_pixel_weapons.py`: `gen_gpt_style_props` rampaları (`W_RED`,
`W_STEEL`, `W_RUST`, `W_MOON`, `GPT_OUTLINE`), `_wrench_px` (titreşimli rampa + boya
kalkması + pas + ışık/ay kenarı), çene de aynı fonksiyonla; `icon_anahtar` yeniden
çizildi; yalnız anahtarı yeniden üreten `main_anahtar()`. `tools/gen_weapon_mask.py`:
anahtar artık sabit paletle boyanmadığından kostüm silah işareti = sopa farkı + sopa
sayfasında saydam olup anahtarda dolu pikseller (çene ve konturu). Yeniden çalıştırınca
yalnız `anahtar_*` ve `placeholder_anahtar` değişti; diğer sayfaların işaretleri aynı.

**Şemsiye (aynı üretici, aynı tur):** sapı cilalı ahşap (`WOOD`), uç çelik yüksük, kumaş
yeni 9 tonluk `W_BORDO` (gölge mora, ışık gül-altına); eksene dik her 9 pikselde kıvrım
oluğu + hemen yanında ışığı yakalayan kıvrım sırtı; ay kenarı. `icon_semsiye` ve
`main_semsiye()` aynı kurallarla. Şemsiyeye piksel eklenmediği için kostüm işareti sopa
farkıyla tam kapsanıyor. Üreticinin eklenen-piksel konturu artık koyu mor (12,7,18).

**Kaldırım taşı (aynı üretici):** 4 tonlu düz gri yerine 9 tonluk `W_BAZALT` (gölge
mor-laciverte, üst yüz sıcak); şablon tonuna sol üst ışık eğimi, gözenek benekleri, sağ
kenarda ay ışığı; yığının dibinde harç kırıntısı + yosun; kontur koyu mor. Elde taş
(`tas_idle/walk`), yerdeki yığın ve uçan mermi aynı `_stone_col` ile.

**Testler:** `--import` hatasız; `new_melee_weapons`, `costumes`, `costume_accessory` PASS; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (77,8 sn), 13 (81,3 sn), 25 (80,9 sn) CLEARED. (İlk koşu sırasında `gen_costume_accessory.py --preview` yanlışlıkla tam üreticiyi çalıştırıp çapa tablosunu yeniden yazdı; geri alındı, silah sayfaları yeniden üretildi ve testler temiz koşturuldu.) Görsel: Bölüm 13 (Haliç) pencereli çekiminde yerdeki ikon "ait";
oyuncu giriş sahnesinde yürüdüğü için silah elde çekilemedi — saldırı kareleri aynı
arka plan kesitine oyun ölçeğinde (0,6) bindirilerek kontrol edildi (şemsiye ve taş da:
elde taş, uçan mermi, yerdeki yığın) — "ait".

**Sonraki öneri:** Stil listesi 3 — kostüm başlıkları (`anim/costume_acc/*`).

### 2026-10-26 (4) — Kalan kodla şekil çizimleri dokuya (stil listesi 2/diğerleri — bölüm tamam)

**Neden şimdi:** Stil listesi 2'nin son maddesi. Kalan şekiller: eski bölümlerde
(Level02/04/06–12, story_blockout tabanlı) iskele direkleri ve çapraz `draw_line`,
kale yüzeylerinin üstünde düz `draw_rect` şerit; düşen saksının yer gölgesi üç
siyah `draw_rect`; arka plan zerreleri `draw_circle`; ana menüde çatıların altı düz
koyu blok ve alt ipucu şeridi düz yarı saydam dikdörtgen.

**Oyuncu ne hissedecek:** İskeleler yeni platformlarla aynı perçinli çelik dikme +
yatay kuşak; kale taşının dudağı ışık yakalayan taş şerit; saksı gölgesi karakterlerle
aynı dither gölge; havadaki toz/kıvılcım zerreleri yumuşak daire değil piksel kare.
Ana menüde çatı sırası gölgede kalan tuğla duvara oturuyor, kontrol ipucu HUD'la aynı
piksel çerçevede.

**Bilinçli olarak dokunulmayanlar (şekil değil, ton):** `dtm_level` gök karartma
bantları, `ui_style.draw_city_bg` menü karartma bantları, `backdrop._SkyLayer` adımlı
gök degradesi — bunlar sahnenin üstüne konan yarı saydam renk katmanı, nesne çizimi
değil. `Fx.px` 3 px ızgaraya oturan piksel karedir; efektlerin piksel ilkelidir.

**Yapılanlar:** `story_blockout.gd`, `level02_redesign.gd` (`_OWP` sabiti; alt sınıflar
level04/level11 bunu miras alır — ilk denemede yinelenen sabit ayrıştırma hatası verdi,
yalnız pencereli çekimde görüldü; kaldırıldı), `level04/11_redesign.gd` (`KENAR_TAS`),
`dtm_level.gd` (`PIX_SHADOW` = pixel/golge), `backdrop.gd` (`Fx.px`), `main_menu.gd`
(`tugla` döşeme + `PixelUI.box("panel_hud")`).

**Testler:** `--import` hatasız; geçici `_parse_all` sahnesi `res://scripts` altındaki
153 betiği yükledi, hata yok (kampanya smoke'u eski Level0x sahnelerini kapsamıyor);
`tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 (83,1 sn), 13 (78,4 sn), 25 (91,4 sn) CLEARED.
1280×720 çekim: ana menü, Level04 (kale), Level06 (iskele), Level02 — "ait".

**Sonraki öneri:** Stil listesi 3 — boru anahtarı animasyon kareleri ve pickup'ı.

### 2026-10-26 (3) — char_rig / weapon_visual kontrolü: ölü kod, silindi (stil listesi 2)

**Neden şimdi:** Stil listesi 2'nin "görsel mi, hata ayıklama mı kontrol et" maddesi.
**Bulgu:** İkisi de görsel değil, hiç çalışmıyor: hiçbir sahne/betik bu dosyaları (ne
yolla ne uid ile) yüklemiyor. Redmount'un `Rig` düğümü `player_sprite.gd`'li
AnimatedSprite2D, düşmanlar `enemy_sprite.gd`; silah elde görünümü sprite karelerinde.
Prosedürel iskeletin kalıntısı olan 47 satırlık kodla çizim oyuncuya hiç ulaşmıyordu.
**Yapılanlar:** iki dosya silindi; `redmount.gd` / `enemy_base.gd`'de "Görsel = char_rig"
diyen eski yorumlar gerçek düğüme (player_sprite / enemy_sprite) çevrildi.
**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 1 (80,5 sn), 13 (77,2 sn), 25 (80,8 sn) CLEARED. Görsel değişiklik yok.
**Sonraki öneri:** Stil listesi 2 — "diğerleri" (story_blockout/level02 destek çizgileri,
level04/11 kenar şeridi, dtm_level saksı gölgesi, backdrop zerreleri, ana menü blokları).

### 2026-10-26 (2) — Büfe fiyat levhası ve "E/DOKUN" rozeti piksel art (stil listesi 2/level_shop)

**Neden şimdi:** Stil listesi 2'nin sıradaki maddesi. Büfe tabelasının üstündeki
etkileşim rozeti dört `draw_rect` (düz sarı kutu + kara çerçeve + kare uç), ürün
kartındaki fiyat etiketi üç `draw_rect`, satın alma/yetmeme parlaması iki yarı saydam
`draw_rect` idi; panel çerçevesi ve KAPAT düğmesi `StyleBoxFlat` düz renkti.

**Oyuncu ne hissedecek:** Fiyat, perçinli fırçalanmış pirinç levhada; parası yetmiyorsa
levha pas kırmızısı emaye ve yazı açık renk — kart sönükleşmenin yanında ikinci okunur
işaret. Tabelanın üstünde zıplayan rozet aynı pirinç malzemeden, aşağı bakan ucuyla.
Panel ve KAPAT, oyunun geri kalan menüleriyle aynı piksel çerçeve ailesinde.

**Yapılanlar:** yeni `tools/gen_shop_ui.py` → `assets/ui/pixel/{etiket_fiyat,
etiket_fiyat_yok}.png` (16×14, 3x — UI ölçeği), `rozet_dokun.png` + `rozet_kuyruk.png`
(2x — dünya ölçeği). `level_shop.gd`: önbellekli 9 parça `LevelShop.plate()`;
parlama `self_modulate` boyası; panel/düğme `PixelUI.box`; `_box` (StyleBoxFlat) silindi.
Kodla çizim 9 → 0. İlk denemede levha gürültüsü fiyatı okunmaz yapıyordu: yüzey
satır satır sakin ışığa çekildi, açıldı, yazı koyu mora alındı.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 1 (79,8 sn), 13 (84,7 sn), 25 (89,8 sn) CLEARED. 1280×720 geçici sahnede (Bölüm 1, Balat)
rozet tabelanın üstünde ve açık panelde alınabilir/alınamaz kartlar çekildi — "ait".

**Sonraki öneri:** Stil listesi 2 — `char_rig.gd` (42) / `weapon_visual.gd` (5) görsel mi
hata ayıklama mı kontrolü.

### 2026-10-26 — Platform destekleri ve kenarları piksel art (stil listesi 2/one_way + moving)

**Neden şimdi:** Stil listesi 2'nin sıradaki maddesi. Koridor, kale, raf ve iskele
platformlarının direkleri, çapraz kuşakları ve basılacak üst kenarı `draw_line` ile
düz renkli çizgiydi; ray platformunun tekerleği `draw_circle`, gece sahnesi kenar
ışığı (`draw_dark_edge`, parkour setleri de kullanıyor) iki düz çizgiydi.

**Oyuncu ne hissedecek:** Platformun altındaki çerçeve artık sahnenin malzemesi:
perçinli, pas akıntılı çelik boru ya da damarlı ahşap direk, aralarında eksene
hizalı yatay kuşaklar (eski çapraz çizgi 2x NEAREST'te merdivenleşiyordu). Kale
asansörü iki zincirle asılı; ray platformunun altından piksel makaralar görünüyor.
Basılacak dudak ışığı yakalayan taş/çelik şerit; gece kenar ışığı dithered doku.

**Yapılanlar:** yeni `tools/gen_platform_supports.py` (gen_gpt_style_props
yardımcılarıyla) → `pixel/{dikme_celik,dikme_ahsap,kusak_celik,kusak_ahsap,
kenar_tas,kenar_celik,kenar_isik,makara}.png`. `one_way_platform.gd`: statik
`tile_down/tile_across`, `_draw_frame` (iki direk + ~64 px'te bir kuşak),
`draw_dark_edge` doku + edge_light boyası. `moving_platform.gd` bu yardımcıları
kullanıyor. Kodla çizim: one_way 13 → 0, moving 9 → 0.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 1 (78,6 sn), 13 (76,3 sn), 25 (91,3 sn) CLEARED. 1280×720 geçici sahnede
Book02Level12 ve Book03Level05 arka planı önünde dört tek yönlü + dört hareketli stil
çekildi — "ait"; makara ilk çekimde ray dokusunun altında kalıyordu, 7 px indirildi.

**Sonraki öneri:** Stil listesi 2 — `level_shop.gd`.

### 2026-10-25 (12) — Kırılabilir kaplarda kodla çizim kalmadı (stil listesi 2/breakable_prop)

**Neden şimdi:** Stil listesi 2'nin sıradaki maddesi. Her kırılabilir kabın altında
`draw_colored_polygon` elips gölge, hasar çatlakları 3 px `draw_rect` kareleri, kırılma
kıymıkları düz renkli dörtgen çokgendi; `_draw_saksi/_vazo/_kasa/_tup/_varil/_sandik`
yedekleri ise her türün PNG'si olduğu için hiç çalışmayan ölü koddu.

**Oyuncu ne hissedecek:** Kaplar karakterlerle aynı piksel dither gölgeye oturuyor. Vurdukça
büyüyen çatlak artık el çizimi: koyu mor yarık, kırık kenarında sıcak ışık, son aşamada
dallanma ve kopmuş parça çukuru (kaba göre kaydırılıp aynalanır; küçük kapta 2x).
Kırılınca saçılan kıymıklar köşeli piksel parçalar; malzeme rengiyle çarpıldığı için
toprak saksıdan kiremit, sandıktan ahşap tonunda parça uçuyor.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `make_catlak` (3×12×16, aşamalar birikimli),
`make_kiymik` (4×7×7, nötr `SHARD` rampası). `breakable_prop.gd`: `GOLGE/CATLAK/KIYMIK`;
`_draw` yalnız doku; çatlak aşaması `int(wear*3)`; `_Shard` doku + modulate; ölü yedek
çizimler, `_ellipse`, kullanılmayan `VASE_BIG/VASE_IZNIK` kaldırıldı (kodla çizim 28 → 0).

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; `tests/barrel_probe.tscn` (pencereli) düşman 30→0, zincir varil kırıldı; bot Bölüm 1
(80,8 sn), 2 (74,3 sn), 6 (129,5 sn) CLEARED. 1280×720 ekran görüntüsü (geçici sahne): farklı
hasar aşamasında tüp/varil/sandık + kırılan kasanın kıymıkları — "ait".

**Sonraki öneri:** Stil listesi 2 — `one_way_platform.gd`, `moving_platform.gd`.

### 2026-10-25 (11) — Toplanabilir ikonlar tamamen piksel art (stil listesi 2/pickup_icon)

**Neden şimdi:** Stil listesi bölüm 1 bitti; bölüm 2 (kodla çizilen görseller) başladı.
İlk madde `level01_long_route.gd` / `level01_dressing.gd` yalnız eski prototip
`Level01.tscn`'de kullanılıyor; kampanya (`GameState.LEVELS`, 36 `Bolum*.tscn`) bu sahneyi
yüklemiyor → oyuncu görmüyor, dönüştürme yapılmadı, madde bu notla kapatıldı.
Sıradaki `pickup_icon.gd`: her toplanabilirin altında `draw_circle` gölge ve parıltı vardı;
tüfek toplanabilirinin (`RiflePickup.tscn`) ikonu hâlâ `draw_rect`/`draw_colored_polygon`du.

**Oyuncu ne hissedecek:** Yerdeki eşyaların altında karakterlerinkiyle aynı piksel dither
gölge; değerli eşyanın arkasında fener hâlesiyle aynı dokuda nabız atan sıcak ışık.
Tüfek artık tabanca/bıçak/sopa ikonlarıyla aynı yoğunlukta: ceviz dipçik ve el kundağı,
çelik mekanizma, kavisli şarjör, namlu ağzı parlaması.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `make_tufek_ikon` (48×48, eksen
koordinatında tanımlanıp çapraz rasterlenir) → `assets/pickups/placeholder_rifle.png`.
`pickup_icon.gd`: `ART`'a `rifle`; prosedürel yedek çizimlerin hepsi (`_coin`, `_health`,
`_ammo`, `_shield`, `_bat`, `_knife`, `_pistol`, `_rifle`, `_glyph`, `_ellipse`; 39 çizim
çağrısı) kaldırıldı; bilinmeyen tür coin ikonunu kullanır; gölge `golge.png`, parıltı
`fener_hale.png` (alfa 0,45–0,75 nabız).

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 2 (73,1 sn), 13 (77,4 sn) CLEARED. 1280×720 ekran görüntüsü (geçici sahne,
Bölüm 2 sokağında tüfek/tabanca/can/coin/bıçak yan yana) — "ait".

**Sonraki öneri:** Stil listesi 2 — `breakable_prop.gd` (saksı/tüp/varil yedek çizimleri,
kıymık).

### 2026-10-25 (10) — Kontrol noktası sancağı ChatGPT tarzında; gölge kontrolü (stil listesi 1 tamam)

**Neden şimdi:** Stil listesi bölüm 1'in son iki maddesi. Kaynak kontrolü: `sancak.png`
ChatGPT bayrağı değil, `tools/gen_pixel_props.py` çizimi (16 Ekim, 22 renk, düz kırmızı
bant) → yeniden çizildi. `golge.png` koyu mor (8,6,12) yarı saydam dither; tarzın gölge
tonuyla uyumlu → değiştirilmedi.

**Oyuncu ne hissedecek:** Kontrol noktası her bölümde birkaç kez görülen "güvendesin" işareti:
pasifken direğe sarılı, iple bağlı soluk bez; dokununca kırlangıç kuyruklu sancak
dalgalanıyor — kıvrımın ışığa bakan yüzü sıcak, çukuru bordo, ay-yıldız krem ve kıvrımla
gölgeleniyor; pirinç alem, bilezik, altın saçak ve püskül; taş kaidede AO.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `DUSK_CLOTH`, `_sancak_frame`, `make_sancak`
(5×30×82; direk x=5 ve kare düzeni aynı, `checkpoint.gd` değişmedi).
`tools/gen_pixel_props.py`: argümansız çalıştırılınca ChatGPT tarzına taşınmış 30+ parçayı
eski çizimle ezerdi → `GPT_STYLE` kümesi atlanıyor (yalnız `golge`, `huzme` eski üreticide).

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 2 (70,0 sn) CLEARED; `gen_pixel_props.py sancak golge` → sancak atlandı,
golge birebir aynı. 1280×720 ekran görüntüsü: Bölüm 2 ilk kontrol noktası — "ait".

**Sonraki öneri:** Stil listesi bölüm 2 — kodla çizilen görseller (`level01_long_route.gd`,
`level01_dressing.gd`).

### 2026-10-25 (9) — Kalkanlı Zabıta'nın kalkanı ChatGPT tarzında (stil listesi 1/kalkan)

**Neden şimdi:** Stil listesinin sıradaki maddesi. Kalkan düz açık gri levha + düz kırmızı
şeritti; ChatGPT çizimi lacivert zırhlı zabıtanın önünde oyuncak gibi duruyordu.

**Oyuncu ne hissedecek:** Füme polikarbon, kavisli dikey parlama şeridi, kauçuk kenar,
gözetleme camında soğuk yansıma, yansıtıcı kenarlı kırmızı zabıta bandı, dipte çamur.
Kalkan düşünce (kırık sürüm) sağ üst köşe kopmuş, darbe noktasından çatlaklar yayılıyor,
bant ucu sarkıyor — "kalkan açıldı, şimdi vur" anı daha net okunur.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `POLY` rampası, `riot_shield(broken)`
(14×34, kalkan.png / kalkan_kirik.png). Ölçü aynı; kod değişmedi.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 20 (81,9 sn) CLEARED. 1280×720 ekran görüntüsü: Bölüm 20'de oyuncuya
kalkanla vuran zabıta — "ait".

**Sonraki öneri:** Stil listesi — golge (ton kontrolü), sancak (kaynak kontrolü).

### 2026-10-25 (8) — Set-piece parçaları ChatGPT tarzında (stil listesi 1/set-piece)

**Neden şimdi:** Stil listesinin sıradaki açık maddesi. Pres, ray, kanal suyu, gözetleme
kulesi, anten ve iç kat döşemesi bölümlerin akılda kalan anlarının parçaları; eski
hâlleri düz gri levha, düz turkuaz dither ve tek renk kafes çizgisiydi.

**Oyuncu ne hissedecek:** Pres perçinli dövme çelik, aşınmış ikaz bandı ve dişli ezme yüzü
(tehlike hemen okunur); piston parlatılmış silindir. Ray parlak mantarlı, katranlı
traversli. Kanal suyu derin bulanık gövde + köpüklü dalga sırtı ve yatay fener
parıltıları (3 kare). Kule çelik bacak + X kuşak, kulübe paslı kırmızı teneke çatı ve
içeriden yanan pencere; anten incelen kafes, ara platformlar, kırmızı ikaz lambası.
Ek düzeltme: iç duvar dokusundaki çatlak/kabarma 144 pikselde bir tekrar edip desen
gibi okunuyordu (Bölüm 2 ekran görüntüsü) — kaldırıldı, sıva bulutu periyodik yapıldı.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `STEEL/WATER` rampaları, `make_pres` (34×22),
`make_pres_kol` (8×16, dikey döşenir), `make_ray` (16×6; üst 2 satır korniş), `make_su_govde`
(32×16, periyodik), `make_su_yuzey` (3×32×12), `make_anten` (24×96), `make_kule_ayak`
(40×20, dikey döşenir), `make_kule_kulube` (40×30), `make_ahsap_kat` (32×8). Ölçüler ve
kare düzeni eskisiyle aynı; kod değişmedi.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 4 (104,4 sn), 5 (99,3 sn), 27 (84,5 sn) CLEARED. 1280×720 ekran görüntüleri:
Bölüm 6 presleri, Bölüm 4 kulesi, Bölüm 2 kanalı ve iç mekânı — "ait".

**Not:** Pencereli yakalamada ardışık çalıştırmalarda zaman zaman duraklatma menüsü
açılıyor (odak kaybı) — çekimi tekrarlamak yetiyor; anten z=-9 arkada olduğu için oyun
içinde kadraja alınamadı, oyun ölçeği ve tonuyla ekran görüntüsü üzerine bindirilerek
değerlendirildi.

**Sonraki öneri:** Stil listesi — kalkan, kalkan_kirik (Kalkanlı Zabıta).

### 2026-10-25 (7) — İç mekân, fabrika ve tavan dokuları ChatGPT tarzında (stil listesi 1/iç mekân)

**Neden şimdi:** Stil listesinin sıradaki açık maddesi. Bu dokular en büyük ekran
alanını kaplar (15 bölümde iç mekân, fabrika blokları, iki mağara bölümünün tüm tavanı,
dört bölümün han kapısı); eski hâlleri düz gri taş, düz kırmızı tuğla ve düz bej sıvaydı.

**Oyuncu ne hissedecek:** Han kapısı arka plandaki ChatGPT kemeriyle aynı dilde: kırmızı-krem
almaşık kemer taşları, çivili demir lamalı çift kanat, pirinç tokmak, kiremit saçak, eşikte AO.
Fabrika tuğlası şaşırtmalı, üst kenarı ışıkta, isli; arka plan tuğlasına göre bir ton
koyulaştırıldı. Pencereler taş söveli kemer (gece: ay + yıldız; fabrika: içeriden yanan
sıcak cam, kırık camlı). İç duvar bulutlu kireç sıva, rutubet lekesi, çatlak; sıvası
dökülmüş yamada tuğla görünür. Tavan düzensiz kaya kütleleri + solu ışıklı, ucu ıslak
sarkıt saçağı.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `BRICK/PLASTER/WARM_GLASS` rampaları,
`make_tugla` (16×16), `make_sivali_tugla` (24×14), `make_ic_duvar` (48×32), `make_hatil` (8×8),
`arch_window` + `make_ic_pencere` (18×26) / `make_fabrika_pencere` (14×20), `make_tavan`
(48×30), `make_han_kapisi` (86×100). Ölçüler eskisiyle aynı; kod değişmedi.
Ekran görüntüsünde düzeltilenler: tuğla ilk hâlinde arka plana göre fazla doygundu;
tavanın 14 kütlesi 48 pikselde ızgara gibi tekrar ediyordu (24 kütle + düşük kontrast);
sarkıtlar `x % 5` ışığıyla dikey çizgi gibi okunuyordu (sarkıt başına sol ışık / sağ gölge).

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 2 (77,7 sn), 6 (129,3 sn), 8 (85,9 sn) CLEARED. 1280×720 ekran görüntüleri:
Bölüm 2 han kapısı + iç mekân, Bölüm 6 fabrika bloğu, Bölüm 8 mağara tavanı — "ait".

**Sonraki öneri:** Stil listesi — set-piece grubu (pres, pres_kol, ray, su_govde, su_yuzey,
anten, kule_ayak, kule_kulube, ahsap_kat).

### 2026-10-25 (6) — Tehlike ve efektler ChatGPT tarzında (stil listesi 1/tehlike-efekt)

**Neden şimdi:** Stil listesinin sıradaki açık maddesi. Alev bacası, kopuk kablo, çivi,
el bombası ve patlama oyuncunun en çok bakması gereken şeyler (tehlike telegrafı) ama
düz turuncu/mavi bantlı eski çizimlerdi; fabrika arka planının sıcak, kirli tonlarından
kopuk duruyorlardı.

**Oyuncu ne hissedecek:** Alev dili kenarda bordo-mor, içe doğru turuncu, çekirdekte krem;
yırtık dil ve kopan közler. Patlama düzensiz bulut kenarlı ateş topu (sol üstü ışıkta,
sağ altı bordo gölgede) → içi sönen kor → mor-gri duman halkası. Çiviler ışıkta parlayan
uçlu dövme kazık; taban lamada aşınmış sarı-siyah ikaz boyası (koyu zeminde tehlike
hemen okunsun). Izgara yarıklarından kor sızıyor; kablo bükülü kauçuk + sarı bant +
sıyrık bakır; ark mor-lacivert haleli beyaz-mavi zikzak; bomba zeytin dökme gövde, pirinç
tapa, ikazda kırmızı kor + fitil kıvılcımı.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `FIRE/SMOKE/ARC/OLIVE` rampaları,
`strip_frames`, `make_diken`, `make_alev_izgara`, `make_kablo`, `grenade(lit)`,
`make_alev` (4×16×46), `make_kivilcim` (3×16×14), `make_patlama` (6×40×40). Kare düzeni
ve ölçüler eskisiyle aynı; kod değişmedi.
İlk denemede kazıklar konturla şişe gibi okunuyordu, sonra birbirine kaynayıp taç gibi
duruyordu; kontur yalnız gölge kenarına alındı, taban genişliği 5 piksele sınırlandı.
Patlamanın 7 kollu düzenli yıldız silüeti çark gibi duruyordu → üç frekanslı düzensiz kenar.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 6 (135,0 sn), 7 (97,2 sn) CLEARED. 1280×720 ekran görüntüleri (geçici
yakalama sahnesi, Bölüm 6 fabrikası): alev bacaları, kablo + ark, çivi şeridi, iki bomba ve
patlama kareleri yan yana — "ait"; çiviler koyu zeminde ikaz şeridiyle okunuyor.

**Sonraki öneri:** Stil listesi — iç mekân grubu (han_kapisi, ic_duvar, ic_pencere,
fabrika_pencere, tavan, tugla, sivali_tugla, hatil).

### 2026-10-25 (5) — Kum torbası, taş blok, raf, kaset, çerçeve ChatGPT tarzında (stil listesi 1/siper-dekor)

**Neden şimdi:** Stil listesinin sıradaki açık maddesi. Bölüm 4'ün siperleri, Bölüm 20'nin
taş depoları ve 15 bölümdeki iç mekân süsleri hâlâ eski düz renkli çizimdi; ChatGPT
arka planlarının önünde yapıştırılmış gibi duruyordu. (Önceki oturum üreticiyi yazıp
commit edemeden kesilmişti; bu tur doğrulayıp tamamladı.)

**Oyuncu ne hissedecek:** Kum torbaları şaşırtmalı yastık çuvallar (örgü dokusu, bağ ucu
büzgüsü, aralarda mor AO, sağ kenarda ay ışığı); taş bloklar pahlı kesme taş, çökük oyma
pano, keski izi, kırık köşe ve dipte yosun; raflarda yaldız şeritli cilt sırtları ve pirinç
kavanozlar; kaset bej plastik + turuncu etiketli makara penceresi; tabloda gece Boğaz'ı ve
ışıklı vapur.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `BURLAP/BOOK_RED/BOOK_TEAL/SEA`
rampaları, `make_kum_torbasi` (32×24, döşenir), `make_tas_blok` (30×30, döşenir),
`make_raf` (30×22), `make_kaset` (16×11), `make_cerceve` (16×12). Ölçüler eskisiyle aynı;
kod değişmedi.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn` PASS;
bot Bölüm 4 (104,9 sn), 2 (76,5 sn), 20 (85,3 sn) CLEARED. 1280×720 ekran
görüntüleri: Bölüm 4 siperi, Bölüm 2 iç mekân rafı, Bölüm 20 taş yığını — "ait"
(taş blok oyunda (0.78,0.7,0.6) tonlandığı için kahverengiye kayıyor, arka plandaki
taş evlerle uyumlu).

**Sonraki öneri:** Stil listesi — tehlike/efekt grubu (diken, alev, alev_izgara, kivilcim,
kablo, bomba, bomba_ikaz, patlama).

### 2026-10-25 (4) — Ön plan kolonu, sarmaşık, zincir, halat ChatGPT tarzında (stil listesi 1/on_kolon)

**Neden şimdi:** Stil listesinin sıradaki açık maddesi. Ön plan kolonları 8 bölümde
kameranın önünden geçer (4x ölçek, en büyük ekran alanı); eski çizim düz mor tahta +
turuncu kenar çizgisi, sarmaşık seyrek düz yeşil nokta, halat düz şeritti.

**Oyuncu ne hissedecek:** Sarnıç/kervansaray kolonları arka plandaki ChatGPT
sütunlarıyla aynı gri-kahve taş: oluklu yuvarlak gövde, sol kenarda sıcak fener ışığı,
sağda ay ışığı, damar çatlağı ve yosun, basamaklı kaidede AO. Sarmaşık dolgun baklava
yapraklı (ışık sol üstte, gölge mor-yeşil); zincirde halka deliği okunuyor; asma
platform halatı çapraz bükülmüş kenevir.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `STONE/LEAF/HEMP` rampaları,
`outline_sides` (dikey döşenen parçada üst/alt dikişte kontur yok), `make_on_kolon`
(18×16, döşenir), `make_on_kolon_bas`, `make_on_kolon_kaide` (18×10, gövdeye dikişsiz),
`make_on_sarmasik` (40×48), `make_zincir` (6×8, döşenir), `make_halat` (3×8). Ölçüler
eskisiyle aynı; kod değişmedi.
İlk denemede taş rampası morumsuydu ve 16 satırlık derz tekrarlanınca kolon tuğla yığını
gibi okunuyordu (ekran görüntüsünde fark edildi): rampa nötrleştirildi, derz kaldırıldı.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 14 (95,9 sn), 15 (87,1 sn), 29 (86,4 sn) CLEARED. 1280×720 ekran görüntüleri: Bölüm 15 sarnıcı (kolon), 29 (sarmaşık),
14 halat atölyesi (zincir + asma platform halatı) — "ait".

**Sonraki öneri:** Stil listesi — kum_torbasi, raf, kaset, cerceve, tas_blok.

### 2026-10-25 (3) — Fener, fener halesi, asma lamba ChatGPT tarzında (stil listesi 1/fener)

**Neden şimdi:** Stil dönüşüm listesinin ilk açık maddesi. Fener 70'ten fazla yerde
(gece bölümlerinin hepsi) ışık kaynağı; eski çizim düz gri direk + düz sarı cam, hale
ortası düz bir disk, asma lamba düz turuncu kutuydu.

**Oyuncu ne hissedecek:** Fenerler ChatGPT erzak sayfasındaki pirinç fenerlerin
akrabası: piramit dövme çatı, pirinç dikmeli kafes, alevden dışa sönen sıcak cam,
fenere yakın direk ucu sıcak ışık alır, aşağısı karanlık ve paslı bilezikli; halkalı
kaide zemine AO ile oturur. Hale düz disk değil, 4×4 Bayer dither ile kademeli söner.
İç mekânda asma lamba artık dikmenin arkasında yarı gizli değil.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `cage` (ortak kafes), `make_fener`
(13×60), `make_fener_hale` (48×48, eklemeli karışım için alfa ≤124 — eski en parlak
120 ile aynı düzey), `make_asma_lamba` (12×14); ölçüler eskisiyle aynı, yerleşim
değişmedi. `dtm_level.gd`: asma lamba bölme ortası + 120 (= dikme) yerine + 70.
Diğer proplar deterministik, değişmedi.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 1 (76,9 sn), 9 (131,3 sn), 13 (80,9 sn), 25 (80,8 sn) CLEARED. Bölüm 3 gece sokağında 1280×720 ekran görüntüsü:
fener ChatGPT arka planındaki duvar fenerinin yanında "ait"; Bölüm 9 iç mekânında
asma lamba görünür (iç duvar hâlâ Claude çizimi — listede iç mekân maddesi).

**Sonraki öneri:** Stil listesi — on_kolon, on_kolon_bas, on_kolon_kaide, on_sarmasik,
zincir, halat.

### 2026-10-25 (2) — Gaz tüpü ChatGPT temel sanatının tarzında (stil listesi 1/tup)

**Neden şimdi:** Stil dönüşüm listesinin ilk açık maddesi. Tüp 1 ve 2. bölümde sık
kırılan prop; eski 11×20 çizim düz kırmızı gövde + beyaz şeritti, ChatGPT arka planının
önünde yapıştırılmış gibi duruyordu.

**Oyuncu ne hissedecek:** Mahalle tüpü artık sahnenin parçası: boyası kalkmış turuncu
çelik gövde, kaynak dikişinden aşağı pas akıntısı, soluk damgalı etiket kuşağı, çelik
koruma tacı içinde pirinç vana; sol üstten fener ışığı, sağ kenarda ay ışığı, koyu mor kontur.

**Yapılanlar:** `tools/gen_gpt_style_props.py` → `make_tup` (17×27 sanat pikseli, oyunda
34×54 = 2x; ölçü/çarpışma değişmedi). Yeni ORANGE/CREAM/BRASS rampaları aynı kural
setinden (gölge mor, ışık altın). Diğer proplar deterministik, değişmedi (md5 aynı).

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 2 CLEARED (74,6 sn). Bölüm 2'de tüpün yanında 1280×720 ekran görüntüsü:
ton ve ışık arka planla uyumlu, "ait" (ilk denemede taç siyah bir blok gibiydi, çelik
dudak ve içi gölgeli taç olarak yeniden çizildi).

**Sonraki öneri:** Stil listesi — fener, fener_hale, asma_lamba.

### 2026-10-25 — Kitap şeridi karelerinde piksel adımlı hareket

**Neden şimdi:** Yol haritası ve P1 maddeleri oyunda; birikimin üstündeki maddeler insan testi
koşullu, pantolon maskesi kalıntısı için önceki turlar "kostüm kalıntı turları kapanmalı" dedi.
Kitap şeridi kareleri tamamen durağandı; DTM'nin bölüm arası çizgi romanları küçük hareketle
canlı durur. Şerit artık Kanıt Arşivi'nden de izlendiği için daha sık görülüyor.

**Oyuncu ne hissedecek:** Kare çakıldığında portreler/nesneler 3 sanat pikseli aşağıdan piksel
piksel yerine oturur (sahne sabit kalır, hafif derinlik); sonra her karede ara ara 1 piksellik
"nefes" — kareler birbirinden kayık nefes alır, hepsi aynı anda zıplamaz.

**Yapılanlar:**
- `tools/gen_comic_panels.py`: birleşik `kK_P.png` aynen (bayt bayt değişmedi) + yeni
  `kK_P_bg.png` (çerçeve + sahne) ve `kK_P_on.png` (96×56 ön katman).
- `book_comic.gd`: sahne + kırpılmış ön katman; `layer_offset(i)` (sanat pikseli), konum her
  zaman `SCALE` katı — kayan alt piksel yok. Kırpma çerçevenin iç alanı: katman aşağı inince
  portrenin altı kaybolur, boşluk açılmaz. Kayıt formatı değişmedi.

**Sayılar (hipotez):** Oturma 3 px × 0,07 sn = 0,21 sn (çakılma 0,18 sn ile aynı ritim, hemen
ardından). Nefes 1,6 sn'de bir 0,4 sn boyunca 1 px; kareler arası 0,4 sn kayma. Daha büyük
genlik okunan alt yazıdan göz kaçırır diye 1 px'te tutuldu.

**Testler:** `--import` hatasız; `tests/book_comic.tscn` PASS (yeni: katmanlar birleşince eski
kareyle piksel piksel aynı, oturma/nefes adımları, konum tam sanat pikseli); `archive_comic.tscn`
PASS; `dtm_gaps` PASS; `campaign_smoke.gd` çıkış 0; bot Bölüm 12 (kitap sonu) CLEARED (88,2 sn).
1280×720 pencereli görüntüde dört kare: portreler çerçeve içinde kırpılıyor, taşma yok.
Telefonda görülmedi.

**Sonraki öneri:** Birikimdeki koşulsuz iş bitti sayılır; bir sonraki tur TASARIM DENETİMİ —
Kitap 2'den bir bölüm (ör. 15) bot ile oynatılıp ritim/set-piece/ödül karşılaştırması.

### 2026-10-24 (22) — Seri rozeti sıradaki arşiv karesini söylüyor

**Neden şimdi:** Yol haritası ve P1 maddeleri oyunda; birikimin en üstündeki taş maddesi insan
testi koşullu, ikincisi (rozette arşiv karesi) koşulsuz ve küçük. Seri rozeti yalnız coin
söylüyordu; 3/7/14. gün aynı zamanda Kanıt Arşivi'nde kalıcı bir kare açıyor ama oyuncu bunu ancak
kare açıldığında öğreniyordu. Coin harcanıp biter, kare koleksiyonda kalır — DTM'de olduğu gibi
"yarın dön" çağrısının en güçlü hâli kalıcı ödülü önceden göstermek.

**Oyuncu ne hissedecek:** Ana menüde `SERİ 4 GÜN · 7. günde +100 coin + kare`. Kare daha önce
açıldıysa (en uzun seri o güne zaten ulaştıysa) ya da 21+ gibi kare vermeyen ödül günündeyse
`+ kare` yazmaz — yalan vaat yok.

**Yapılan:** `DailyWave.day_opens_photo(day, best_streak)` (gün `ARCHIVE_DAYS` içinde ve en uzun
seriden büyük); `main_menu.gd` rozet metnine ekleme. Yeni kayıt alanı yok.

**Test:** `tests/daily_wave.tscn` PASS (rozet durumları: kare açacak / kare zaten açık / 21. gün /
kopuk seri / seri yok), derleme temiz, `tests/dtm_gaps.tscn` PASS, 36 sahne smoke çıkış 0, Bölüm 1
bot CLEARED. 1280×720 ekran görüntüsünde rozet piksel çerçeveye sığıyor (sağda ~100 px pay).

**Sıradaki öneri:** Birikimdeki koşulsuz madde kalmadı sayılır (hepsi insan testi/cihaz
koşullu); bir sonraki tur TASARIM DENETİMİ — Kitap 2'den bir bölümü (ör. 15) bot ile oynatıp
ritim/set-piece/ödül karşılaştırması ve yeni birikim.

### 2026-10-24 (21) — Kanıt Arşivi'nde kitap sonu şeridini yeniden izleme

**Neden şimdi:** Yol haritası ve P1 maddeleri oyunda; birikimin üstündeki maddeler insan testi
koşullu. Önceki turun önerisi buydu. Kitap sonu çizgi roman şeridi bir kez oynuyor, sonra
kayboluyordu — DTM'de bölüm arası çizgi romanlar yeniden izlenebilir; hikâyeyi unutup ara
verip dönen mobil oyuncu "nerede kalmıştık?" sorusunu arşivden yanıtlar.

**Oyuncu ne hissedecek:** Kanıt Arşivi'nde her kitap sekmesinin altında, GERİ'nin yanında
`▸ KİTAP 1 ŞERİDİ` düğmesi; basınca dört kare aynı çakılma ritmiyle oynar, kapanınca odak
düğmeye döner (arşivden çıkmaz). Bitirilmemiş kitapta düğme soluk: `ŞERİT · KİTAP 2'Yİ BİTİR`
(hedef). GÜNLÜK sekmesinde düğme yok.

**Yapılanlar:**
- `book_comic.gd`: `end_of(book)`, `is_unlocked(book)` — yeni kayıt alanı açmadım: son bölümün
  bitiş süresi, skoru ya da sonraki bölümün açık olması yeterli (eski kayıtlarda da çalışır;
  birikimdeki "Save alanı" fikrinden daha basit ve geriye uyumlu).
- `main_menu.gd`: arşiv alt satırı `GERİ` + `ComicReplay`; sayfaya bir `BookComic` katmanı;
  şerit açıkken menünün `ui_cancel` geri dönüşü yutulmaz (şerit ESC ile kapanır, sayfa kalır).
- Kayıt formatı değişmedi.

**Testler:** `--import` hatasız; yeni `tests/archive_comic.tscn` PASS (açılma kuralları, eski
kayıt, kapalı/açık/GÜNLÜK düğme durumları, ikinci basış baştan başlatmıyor, kapanınca arşiv
açık); `book_comic.tscn` PASS; `daily_wave.tscn` PASS (aynı menü); `dtm_gaps` PASS;
`campaign_smoke.gd` çıkış 0; bot Bölüm 12 CLEARED (71,8 sn) — oyun içi şerit yolu değişmedi,
kitap sonu bölümü kontrol için.

**Görsel kanıt:** 1280×720 pencereli üç görüntü: açık düğme altın çerçeveli, kapalı düğme gri
ve Türkçe ekle okunuyor, taşma yok; şerit arşivin üstünde tam karartmayla oynuyor. Telefonda
görülmedi. (Pencereli koşuda görülen `pixel_ui_boot._pixelize` "Object to Object" hatası
aynı karede iki kez sekme kurulmasından; önceden de var, bu turla ilgisiz.)

**Sonraki öneri:** Birikimde insan testine bağlı olmayan somut iş: kitap şeridinde karelere
küçük hareket (kare açılırken portrenin 1–2 sanat pikseli kayması). Ya da birikim yalnız
insan testi koşullu kaldıysa yeni bir tasarım denetimi turu.

### 2026-10-24 (20) — Sonuç kartında önceden kazanılmış yıldız soluk okra

**Neden şimdi:** Yol haritası ve P1 maddeleri oyunda; birikimin ilk iki maddesi insan testi
koşullu. Önceki turun önerisi buydu ve küçük, kendi başına tamamlanan bir okunurluk işi.
Şimdiye kadar tekrar koşuda alınmayan yıldız boş yuva olarak görünüyordu — oyuncu "kaybettim mi?"
diye düşünebiliyordu; kayıt aslında yıldızları birleştiriyor.

**Oyuncu ne hissedecek:** Sonuç kartında bu koşuda kazanılan yıldızlar eskisi gibi altın
çakılır; daha önce kazanılmış ama bu koşuda alınmamış olanlar baştan sönük okra (parıltısız)
durur, hiç alınmamışlar boş mürdüm yuva. Üç durum bir bakışta ayrılıyor: "bu koşu / kalıcı /
eksik". DTM'deki "hedef kalıcı, tekrar koşu ek şans" hissi.

**Yapılanlar:**
- `tools/gen_pixel_stars.py`: `faded` modu → `yildiz_soluk[_kucuk].png` (dolu/boş bayt bayt
  aynı kaldı).
- `hud.gd`: `STAR_FAINT`, `earned_stars` (Main doldurur, `_reveal` tüketip sıfırlar — sonraki
  karta sızmaz).
- `main.gd`: iki bitiş yolunda `record_stars` öncesi `_hud.earned_stars = Save.stars_of(...)`.
- Kayıt formatı değişmedi.

**Testler:** `--import` hatasız; `level_stars.tscn` PASS (yeni: önceki HASARSIZ soluk, hiç
alınmamış HIZ boş, bu koşunun yıldızı yine dolu, maske sonraki karta sızmıyor); `dtm_gaps` PASS;
`campaign_smoke.gd` çıkış 0; bot Bölüm 1 CLEARED (78,9 sn), Bölüm 13 (77,3), Bölüm 25 (83,9)
— bitiş yolu (`main.gd`) ortak olduğu için.

**Görsel kanıt:** 1280×720 pencereli görüntü: iki soluk + bir altın yıldız; soluk okra
altından açıkça ayrılıyor, boş yuvayla karışmıyor, taşma yok. Telefonda görülmedi.

**Sonraki öneri:** Bölüm seçme kartındaki küçük yıldızlarda da aynı dil hazır
(`yildiz_soluk_kucuk.png`) ama orada "bu koşu" yok; kullanılmadı. Birikimden hız yıldızı par
süreleri insan testi bekliyor; insan testi verisi yoksa Kanıt Arşivi'nde kitap şeritlerini
yeniden izleme sekmesi sıradaki somut iş.

### 2026-10-24 (19) — Günün Dalgası beşinci dilim: Kanıt Arşivi'nde seri kareleri

**Neden şimdi:** Yol haritasında açık madde yok, P1 maddelerinin hepsi oyunda; birikimin ilk
maddesi (taşın havada görünmemesi) insan testi koşullu, sıradaki somut iş buydu. Seri şimdiye
kadar yalnız coin veriyordu; coin ekonomisi kostümlerden sonra doyuyor. DTM'de günlük ödülün
kalıcı bir izi olur — oyuncu "o haftayı" bir koleksiyonda görür.

**Oyuncu ne hissedecek:** Seri 3., 7. ve 14. güne ulaşınca sonuç kartında coin ödülünün
yanında `ARŞİVE KARE` yazar. Kanıt Arşivi'nde yeni GÜNLÜK sekmesinde arenanın akşamüstü
tonlu kareleri, köşede kırmızı piksel gün damgası; kilitliyse altında `14 GÜN SERİ` hedefi.
Seri kopsa da kare gitmez (en uzun seri saklanır).

**Yapılanlar:**
- `DailyWave.ARCHIVE_DAYS = [3, 7, 14]`, `archive_photos(best)`.
- `Save.daily_best_streak` (`[daily] best_streak`; eski kayıtta `max(0, streak)` →
  geriye uyumlu, mevcut seriyle başlar), `finish_daily` günceller, `wipe` sıfırlar.
- `survival.gd`: puanlı koşu öncesi/sonrası açık kare sayısı karşılaştırılır (`_new_photo`);
  yazı kısa coin satırına konur (seri satırı skorla birlikte kartı dolduruyordu).
- `main_menu.gd`: arşivde 4. sekme GÜNLÜK, `_daily_archive_cell()`.
- `tools/gen_photos.py daily_photo`: survival arenasının atlasından (`level06_backstreets`)
  3 kare, mor-turuncu akşamüstü tonu (kitap karelerinin sepyasından ayrılsın), 3×5 piksel
  rakamlı gün damgası. Mevcut 108 kare yeniden üretildi, bayt bayt aynı kaldı.

**Sayılar (hipotez):** Kare günleri ilk üç coin ödülüyle aynı — "ödül anı" tek yerde toplanır,
oyuncu iki ayrı takvim öğrenmez. 14'ten sonra kare yok: koleksiyon kapanır, sonsuz kovalamaca
yaratmaz; insan testinde 14'ü geçen oyuncu olursa 21/28 eklenir.

**Testler:** `--import` hatasız; `tests/daily_wave.tscn` PASS (yeni: eski kayıtta en uzun seri
0 / yalnız `streak` varsa ondan, `archive_photos` sınırları, kare dosyaları, arşivde GÜNLÜK
sekmesi ve seri 7'de 2 açık + 1 kilitli, puanlı 3. gün koşusunda `ARŞİVE KARE` ve kayıttan
okuma); `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS; `survival_mode` OK; bot Bölüm 1
CLEARED (79,7 sn), Bölüm 13 (77,6), Bölüm 25 (82,4) — kayıt sistemi ortak olduğu için.

**Görsel kanıt:** 1280×720 pencereli görüntü: GÜNLÜK sekmesinde 4 sekme başlığa sığıyor, iki
açık kare okunur, damga görünür; sonuç kartında `ARŞİVE KARE` coin satırında, taşma yok.
İlk denemede not seri satırına eklenmişti ve satır kartın kenarına dayanıyordu — taşındı.
Telefonda görülmedi.

**Sonraki öneri:** Hız yıldızı par sürelerinin bölüm başına ayarı için insan testi verisi
gelene kadar, sonuç kartında önceki koşulardan kazanılmış yıldızı soluk altınla gösterme.

### 2026-10-24 (18) — Kaldırım taşı dördüncü dilim: varilden ve büfeden taş

**Neden şimdi:** Yol haritasında açık madde yok, P1 ilk dilimleri oyunda; birikimin başı
taşın dördüncü dilimiydi. Taş yalnız Bölüm 2'deki tek yığından ve duraklat cephaneliğinden
geliyordu; oyuncu bölüm içinde taşa ulaşamıyordu. Üstelik silahsız oyuncu için varilden çıkan
cephane kutusu (%35) hiçbir işe yaramıyordu — DTM'de kırılan her kap "değdi" hissi verir.

**Oyuncu ne hissedecek:** Elinde ateşli/fırlatılan silah yokken varil kırınca cephane kutusu
yerine taş yığını düşer: bir sonraki kalabalığa üç taşla girer. Tabancalıyken varil yine
cephane verir. Bölüm 2 ve 5 büfelerinde `TAŞ · 14 C` kartı var. Taş elindeyken cephane kutusu
alırsa 16 değil 3 taş kazanır.

**Yapılanlar:**
- `BreakableProp.adapt_loot(scene, player)`: zar cephane çıkarırsa ve oyuncunun silahı yoksa
  `TasPickup` döner; diğer ganimetler değişmez. `_break` zarı bundan geçirir.
- `LevelShop.CATALOG["tas"]` (14 coin); `bolum02.gd` ve `bolum05.gd` büfelerine 4. kart.
- `redmount.gd add_ammo`: yerçekimli (fırlatılan) silahta ekleme `mag_size + starting_reserve`
  ile sınırlı.

**Sayılar (hipotez):** 14 coin: cephanelik (15) ile aynı düzeyde, can (15) ile yan yana en
ucuz seçenek; duraklat menüsüne gitmeden bölüm içinden alınabildiği için 1 coin indirim.
Kutu taşa 3 ekler (bir yığın): 16 taş, 22 hasarlı yay atışla tabancayı (16 mermi) geçerdi.
Varil zarı (%35) değişmedi; yalnız ne düştüğü değişti — ganimet sıklığı aynı kalır.

**Testler:** `--import` hatasız; `tests/kaldirim_tasi.tscn` PASS (yeni: silahsızken varil →
taş, tabancalıyken cephane, boş zar/yiyecek değişmez, kutu taşa +3, büfe kataloğu, Bölüm 2
bakkalında taş); `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS; `new_melee_weapons` PASS;
`survival_mode` OK; bot Bölüm 2 CLEARED (74,3 sn), Bölüm 5 (96,6), Bölüm 1 (84,5), Bölüm 13 (77,4), Bölüm 25 (83,6) — büfe değişen iki bölüm + ortak varil/oyuncu sistemi için 0, 12, 24.

**Görsel kanıt:** 1280×720 pencereli görüntü, Bölüm 2 bakkalı: 4 kart (CAN/BIÇAK/TAŞ/ZIRH)
panele sığıyor, taş ikonu piksel art ve okunur, coin yetmeyen kart kırmızı. Telefonda görülmedi.

**Sonraki öneri:** Günün dalgası 5. dilim (7. gün Kanıt Arşivi karesi).

### 2026-10-24 (17) — Kaldırım taşı üçüncü dilim: elde görünen taş + fırlatma kareleri

**Neden şimdi:** Yol haritasında açık madde yok, P1 ilk dilimleri oyunda; birikimin başı
kaldırım taşıydı. Taş kuşanılınca Redmount boş elle duruyor, atış da düz yumruk (combo_a
1–5) oynuyordu: oyuncu elinde ne olduğunu ve kaç atış kaldığını yalnız HUD'dan okuyordu.
DTM'de eldeki eşya her zaman karakterin silüetinde görünür.

**Oyuncu ne hissedecek:** Taşı alınca öndeki yumrukta gri bazalt taş görünür (bekleme ve
yürüme/koşu). L'ye basınca geri çekiş → kol önde bırakış → toparlanma oynar, taş anında
çıkar; el boşalır, yedek taş varsa 0,25 sn sonra elde yenisi belirir. Kostüm ne olursa
olsun taş gri kalır.

**Yapılanlar:**
- `tools/gen_pixel_weapons.py gen_tas_sheets`: `tas_idle`, `tas_walk` sayfaları silahsız
  sayfaların kopyası (pantolon/saç işaretleri korunur) + öndeki yumruğun (kalça altındaki en
  sağdaki ten lekesi) üstüne 2x taş ve kontur, silah işaretiyle (alfa 252) — kostüm shader'ı
  boyamaz. Uçan taşla aynı desen.
- `player_sprite.gd TAS_SHEETS`: taş animasyonları kaynak animasyonun bölge/zamanlamasıyla
  SpriteFrames'e eklenir; `tas_shoot` ayrı sayfa değil, `combo_a` 2–5. kareleri.
- İlk denemede fırlatma sayfası omuzda/geri çekişte elde taş taşıyordu; mermi tuşa basıldığı
  anda doğduğu için iki kare boyunca ekranda iki taş vardı. Atış gecikmesi eklemek dokunmatik
  tepkiyi bozacağından elde taş fırlatma karelerinden çıkarıldı (anında bırakış).
- `kaldirim_tasi.tres shoot_anim = &"shoot"`; `redmount.gd _play`: yerçekimli mermili
  silahın atış animasyonu 0,25 sn (4 kare × 16 fps).
- `CostumeAccessory.SHEET_ALIAS`: `tas_*` sayfaları kaynağın baş çapasını/ön parçasını
  kullanır (`head_anchors.json` yeniden üretilmedi; şapka taşla da doğru oturur).

**Sayılar (hipotez):** Taş 2x (20×14 sayfa pikseli ≈ 12×8 oyun pikseli): yumruktan büyük,
telefonda okunur, uçan taştan (20×14 oyun pikseli) küçük — "elde" ve "havada" aynı nesne gibi
okunuyor ama elde silüeti bozmuyor. Atış animasyonu 0,25 sn < atış aralığı 0,45 sn.

**Testler:** `--import` hatasız; `tests/kaldirim_tasi.tscn` PASS (yeni: her bekleme/yürüme
karesinde silah işaretli taş, başlık çapası paylaşımı, beklerken `tas_idle`, kare sayıları,
atışta `tas_shoot`); `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS; `costumes`,
`new_melee_weapons`, `survival_mode` PASS; bot Bölüm 2 CLEARED (75,5 sn), Bölüm 1 (84,8),
Bölüm 13 (80,3), Bölüm 25 (85,5) — oyuncu sprite'ı ve kostüm çapası ortak olduğu için dört bölüm.

**Görsel kanıt:** 1280×720 pencereli görüntü, Bölüm 2, vapurcu kostümü: elde taş gri ve
okunur, şapka yerinde; atışta el boş, taş havada; ardından elde yeni taş. Telefonda görülmedi.

**Sonraki öneri:** Günün dalgası 5. dilim (7. gün arşiv karesi) ya da taşın dördüncü dilimi
(varil/dükkân kaynağı).

### 2026-10-24 (16) — Günün Dalgası dördüncü dilim: seri koruma ("dünü kurtar")

**Neden şimdi:** Yol haritasında açık madde yok, P1'lerin ilk dilimleri oyunda; önceki tur
kostüm kalıntı turlarını kapatıp oynanış maddelerini öne aldı, birikimin başı günün dalgası.
Seri tek kaçırılan günde sıfırlanıyordu: 13 günlük seriyi bir gün unutan oyuncu 14. gün
ödülünü (200) ve rozetini kaybedip "baştan" uyarısını görüyordu — mobilde en çok bırakma
anlarından biri.

**Oyuncu ne hissedecek:** Yalnız dünü kaçırdıysa menüde rozet `SERİ KOPTU (6 GÜN) · dünü kurtar`
der, altında piksel `DÜNÜ KURTAR · 80 coin` düğmesi çıkar. Basınca coin düşer, rozet hemen
`SERİ 6 GÜN · 7. günde +100 coin`a döner; bugün dalgayı temizlerse seri 7 olur. Coin yetmezse
düğme kapalı görünür (hedef olarak).

**Yapılanlar:**
- `DailyWave.RESCUE_COST/RESCUE_COOLDOWN`, `rescue_available`, `yesterday`.
- `Save.daily_rescue_day` (yeni alan, eski kayıtta boş), `can_rescue_daily`, `rescue_daily`:
  coin düşer, `daily_clear_day` düne çekilir, seri sayısı artmaz (kaçırılan gün sayılmaz,
  yalnız köprü). Bugünün puanlı denemesi kullanıldıysa kurtarma yok (boşa coin harcatmasın).
- `main_menu.gd`: `StreakRescue` düğmesi rozetin altında; kurtarınca sayfalar `_rebuild()` ile
  yeniden kurulur (coin ve rozet anında güncellenir).

**Sayılar (hipotez):** 80 coin = bir günlük tamamlama (60) + üçte biri: bedava değil ama
14. gün (200) ve sonrasındaki her 7 günlük 100'lük ödülün altında, uzun seriyi korumak kârlı.
Yalnız 1 gün boşluk (2+ gün kaçıran zaten "geri dönen oyuncu", suçlama yok) ve 7 günde bir:
alışkanlığın yerine geçmesin. İnsan testinde kurtarma oranı çok yüksekse maliyet 100'e.

**Testler:** `--import` hatasız; `tests/daily_wave.tscn` PASS (yeni: dün hesabı + yıl sınırı,
kurtarma koşulları, bekleme süresi, coin yetmezliği, kayıttan okuma, kurtarılan serinin bugün
7'ye çıkıp 100 ödül vermesi, denenmiş günde kurtarma yok, menüde kapalı/açık düğme ve basınca
rozetin canlı seriye dönmesi, eski kayıtta alan boş); `campaign_smoke.gd` çıkış 0;
`dtm_gaps` PASS; `costumes` PASS; bot Bölüm 1 CLEARED (76,9 sn; bölüm sistemleri değişmedi,
yalnız menü + kayıt).

**Görsel kanıt:** 1280×720 pencereli görüntü, kurtarma öncesi (rozet + düğme, coin 140) ve
sonrası (coin 60, altın seri rozeti, düğme yok): piksel düğme, taşma yok. Telefonda görülmedi.

**Sonraki öneri:** Kaldırım taşı üçüncü dilim (elde görünür taş + fırlatma sayfası) — birikimde
oynanışa en çok değer katan madde; ardından günün dalgası 5. dilim (arşiv karesi).

### 2026-10-24 (15) — Bıçağın son kareleri de kostüm rengine boyanmıyor

**Neden şimdi:** Yol haritasında açık madde yok, P1'lerin ilk dilimleri oyunda; birikimin başı
bıçaktaki son işaret boşluklarıydı. Ölçünce `knife_walk` 5–7'de bele inen bıçağın orta gri
kenarındaki 7–23 piksel **pantolon** işaretli çıktı (Vapurcu/Kızıl Dağ'da bıçakta mavi lekeler),
`knife_attack2` 0'da omuz üstündeki bıçağın tamamı (59 px) ceket rengine boyanıyordu.

**Oyuncu ne hissedecek:** Bıçakla yürürken ve ikinci savuruşun hazırlığında bıçak hep çelik gri;
kostüm rengi yalnız giyside.

**Yapılanlar:**
- `tools/gen_weapon_mask.py` `KNIFE_POLYS`: bileşen kuralının kaçırdığı dört karede elle çizilmiş
  bıçak çokgeni (yürüyüş 5–7'de ağız + iki küçük uç parçası, `attack2` 0'da ağız + kabza ucu);
  işaret çokgendeki giysi pikselleri. RGB değişmedi (doğrulandı), yalnız alfa; yalnız bu iki
  sayfa değişti.
- `tests/costumes.gd`: dört karede bıçak kutusunda en az silah işareti ve ≤ 1 pantolon pikseli.

**Testler:** `--import` hata yok; `costumes` (genişletildi) PASS, `dtm_gaps` PASS;
`campaign_smoke.gd` çıkış 0; bot Bölüm 1 (77,8 sn), 13 (77,5 sn), 25 (85,6 sn) CLEARED.

**Görsel kanıt:** 1280×720 pencereli görüntü, Kızıl Dağ ve Vapurcu × dört kare: bıçaklar gri,
kırmızı/mavi leke yok.

**Sonraki öneri:** Kostüm görsel kalıntı turları burada kapanmalı. Birikimin yeni başı pantolon
maskesi kalıntıları (2–4 px, düşük etki); ondan önce oynanış maddeleri (günün dalgası 4. dilim,
kaldırım taşı fırlatma sayfası) daha çok değer katar — birikim sırası buna göre değiştirildi.

### 2026-10-24 (14) — Şarjör değiştirirken de silah kostüm rengine boyanmıyor

**Neden şimdi:** Yol haritası ve P1 ilk dilimleri bitti; birikimin başı silah işaretinin
üçüncü dilimiydi. Ölçünce şarjör değiştirme karelerinde tüfeğin ve tabancanın tamamı (ve
yere düşen şarjör) ceket rengine, tüfeğin bir kısmı (1169 px) pantolon rengine boyanıyordu.
Cephane bitince her seferinde oynayan animasyon olduğu için kostümün en görünür kalan kusuruydu.

**Oyuncu ne hissedecek:** Kızıl Dağ ya da Vapurcu giyerken şarjör değiştirmek tüfeği bir
anlığına kırmızı/lacivert yapmıyor; silah ve şarjör hep siyah-gri metal.

**Yapılanlar:**
- `tools/gen_weapon_mask.py` `RELOADS`: silah karede döndüğü ve şarjör elden ayrıldığı için
  ilk kareden taşıma işe yaramıyor; her karenin elle çizilmiş çokgeni var (tabanca 1. karede
  düşen şarjör ayrı parça). Kare kare aynı bileşen kuralı; bileşen silahın yarısından azını
  bulursa (gövde önünde kontur ceketle birleşik) o parça çokgenin kendisi.
- İşaret: `pistol_reload` 192–364 px/kare, `rifle_reload` 1066–1574 px/kare (3. kare yalnız
  elde şarjör: 280 px). RGB değişmedi (doğrulandı), yalnız alfa; araç diğer sayfalarda aynı sonucu
  üretiyor (git farkı yok).
- `tests/costumes.gd`: şarjör sayfalarında kare başına alt/üst sınır (tabanca 150–450,
  tüfek 200–1800; üst sınır ceketin işarete karışmadığını gösterir).

**Testler:** `--import` hata yok; `costumes` (genişletildi) PASS, `dtm_gaps` PASS;
`campaign_smoke.gd` çıkış 0; bot Bölüm 1 (80,9 sn), 13 (80,7 sn), 25 (86,6 sn) CLEARED.

**Görsel kanıt:** 1280×720 pencereli görüntü, Vapurcu ve Kızıl Dağ × iki şarjör sayfasının 8
karesi: silahlar ve düşen şarjör her karede gri; kostüm rengi yalnız ceket/pantolonda.

**Sonraki öneri:** Birikimin yeni başı pantolon maskesi kalıntıları (tekmede diz arkası) ya da
bıçağın kalan iki karesi; ikisi de küçük. Görsel kalıntı turları doygunluğa yaklaştı, sonraki
turlarda oynanış maddelerine (günün dalgası 4. dilim, kaldırım taşı fırlatma sayfası) geçilmeli.

### 2026-10-24 (13) — Yakın silahlar da kostüm rengine boyanmıyor

**Neden şimdi:** Yol haritası ve P1 ilk dilimleri bitti; birikimin başı silah işaretinin ikinci
dilimiydi. Ölçünce kostümlü oyuncunun en sık gördüğü yakın silah kareleri bozuktu: sopa
savuruş izi ve bıçak ağzının kenarı pantolon rengine (Vapurcu'da lacivert iz), anahtar çenesi
ve şemsiye ucunun koyu çelik tonları ceket rengine boyanıyordu (sayfa başına 80–1700 px).

**Oyuncu ne hissedecek:** Hangi kostümle olursa olsun sopa ahşap, anahtar kırmızı-çelik,
şemsiye bordo, bıçak ve savuruş izi gümüş okunur; kostüm rengi yalnız giyside.

**Yapılanlar:**
- `tools/gen_weapon_mask.py` yakın silah bölümü (çokgen yok, savuruşta silah dönüyor):
  sopa = `bat_*` ile `anahtar_*` sayfalarının RGB farkı (anahtar sopadan türetildiği için
  fark tam olarak sopa + iz); anahtar/şemsiye = aynı fark + `gen_pixel_weapons.py`
  rampalarıyla birebir aynı renkler (çıplak sayfalarda ≤ 2 px, yani güvenli). Bıçak renkle
  ayrılmıyor (b−r dağılımı ceketle aynı); ağız ve iz açık gri olduğundan, açık bileşenlerin
  (≥ 10 px, ayakkabı hizası y < 200 üstünde) 2 px yakınında, en az yarısı ağza değen küçük
  (≤ 150 px) giysi bileşenleri işaretlenir. 60 px sınırı ağzın üst kenarını (62 px) kaçırdı,
  150'ye çıkarıldı; ceket/pantolon parçaları yüzlerce piksel.
- 16 sayfa işaretlendi: sopa/şemsiye 2,6k–5,5k, anahtar 2,8k–5,9k, bıçak 106–860 px/sayfa.
  Shader değişmedi (kod 3 zaten boyanmıyor), yalnız yorumu güncellendi.
- `tests/costumes.gd`: yakın silah sayfalarında toplam işaret alt sınırı + kare başına üst
  sınır (ceket/pantolon işarete karışmasın: sopa ≤ 1000, bıçak ≤ 400).

**Testler:** `--import` hata yok; `costumes` (genişletildi) PASS, `dtm_gaps` PASS;
`campaign_smoke.gd` çıkış 0 (36 sahne); bot Bölüm 1 (75,4 sn), 13 (80,7 sn), 25 (80,8 sn) CLEARED.

**Görsel kanıt:** 1280×720 pencereli görüntü, kırmızı ceket + lacivert pantolon kostümüyle
bıçak saldırısı, sopa saldırısı 2, anahtar yürüme, şemsiye saldırısı: silahlar ve izler
kendi renginde; kostüm rengine geçen silah pikseli görülmedi.

**Sonraki öneri:** Pantolon maskesi kalıntıları (tekmede diz arkası, koşuda ayakkabı arkası)
ya da şarjör değiştirme karelerinin silah işareti.

### 2026-10-24 (12) — Ateşli silahlar kostüm rengine boyanmıyor

**Neden şimdi:** Yol haritasında açık madde yok, P1'lerin ilk dilimleri oyunda; birikimin başı
buydu. Ölçünce en görünür kısım tüfek ve tabancaydı: shader'ın giysi eşiği (doygunluk < 0,25)
koyu gri metali de giysi sayıyor, Kızıl Dağ kostümüyle kırmızı, Vapurcu ile lacivert tüfek
çıkıyordu. Ateşli silah alınınca her karede elde göründüğü için kostümün en çok bozulduğu yer.

**Oyuncu ne hissedecek:** Hangi kostümü giyerse giysin tabanca/tüfek silah gibi okunur
(siyah-gri metal); kostüm rengi yalnız ceket ve pantolonda kalır.

**Yapılanlar:**
- Önce otomatik ayrım denendi ve atıldı: renk tonu ayırmıyor (aynı tüfek bir karede nötr,
  ötekinde ceket kadar sıcak, r−b dağılımları örtüşüyor), kalınlık da ayırmıyor (morfolojik
  açma r=5 sopa ve tüfek gövdesini de gövde sayıyor).
- `tools/gen_weapon_mask.py` (yeni): her sayfanın ilk karesinde silah elle çizilmiş çokgen;
  diğer karelere RGB+alfa şablon eşleştirmesiyle kaydırılarak taşınır (±26 px). Giysi
  pikselleri 4-komşulu bileşenlere ayrılır, pikselinin ≥ %60'ı çokgende olan bileşen silahtır
  (piksel art konturu silahı koldan ayırdığı için sınırı kontur çizer). Silah ceketle tek
  bileşen olduğunda (tüfek gövde önünde: `rifle_idle`/`rifle_walk`, nişanda omza dayanan
  dipçik, iki tekil kare) çokgenin kendisi kullanılır. İşaret alfa 252 = kod 3 (pantolon 1,
  saç bitleri çift; çakışmaz, saç ve pantolon araçları bu değere dokunmuyor).
- 8 sayfa / 46 kare: `pistol_{aim,idle,shoot,walk}` kare başına 140–327 px, `rifle_{aim,idle,
  shoot,walk}` 833–1492 px.
- `shaders/player_costume.gdshader`: kod 3 boyanmaz. `tests/costumes.gd` `_weapon_mask`:
  her karede silah işareti (tabanca ≥ 100, tüfek ≥ 600 px), `idle` sayfasında hiç yok.

**Testler:** `--import` hata yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps`, `costumes`
(genişletildi), `costume_accessory`, `costume_badge` PASS; bot Bölüm 1 (83,5 sn), 13 (77,4 sn),
25 (80,8 sn) CLEARED.

**Görsel kanıt:** 1280×720 pencereli görüntü (kızıl/vapurcu/hamal × tüfek nişan, yürüme,
ateş, tabanca nişan, bekleme): silahlar her kostümde gri; ilk geçişte kırmızı kalan dipçik
ayrı parçayla düzeltildi. Çokgen sınırında ceket üzerinde 1–2 px gri kalıntı olabilir.

**Sonraki öneri:** Silah işaretinin ikinci dilimi (şarjör değiştirme kareleri + yakın
silahlar; bıçak ağzı şu an pantolon rengine boyanıyor).

### 2026-10-24 (11) — Pantolon maskesindeki kaçaklar giderildi

**Neden şimdi:** Yol haritası ve P1 maddelerinin ilk dilimleri bitti; birikimin başı bu
kusurdu. Önce/sonra görselleştirmesinde (ceket mor, pantolon camgöbeği) koşu karelerinin
üçünde ceketin parlak fermuar/etek yamaları pantolon rengine geçiyor (bir karede 387 px),
gölgedeki arka bacak ise ceket renginde kalıyordu; kostümlü koşu en çok görülen kare
olduğu için oyuncunun kostümü "lekeli" görünüyordu.

**Oyuncu ne hissedecek:** Vapurcu/Kızıl Dağ gibi kostümlerde ceket tek parça renk, pantolon
koşarken de tek parça; ayakkabının gri gölgesi artık ceket rengine boyanmıyor.

**Yapılanlar:**
- `tools/gen_costume_mask.py`: parlaklık eşiği tek başına yetmiyordu (siyah deri ceketin
  parlak yamaları kot kadar açık). Ölçünce asıl ayırt edici doku çıktı: 7×7 pencerede
  çok koyu (≤ 22) giysi pikseli oranı ceket derisinde ~0,4–0,8, kotta (gölgedeki arka bacak
  dahil) ~0–0,1. Aday = yerel ortalama ≥ 26 **ve** koyu oran ≤ 0,2 (eski: ortalama ≥ 36).
  Pantolona değen < 25 px giysi kırıntıları ve ayakkabıya 2 px yakın açık gri (≥ 90)
  gölge pantolona katılır. İşaretli piksel 756 797 → 735 791; yalnız alfa 254/255 değişti
  (RGB ve saç bitleri aynen, doğrulandı).
- İşaretçili watershed (ayakkabı/el tohumları) de denendi; ceket arkasına taşıyordu, atıldı.
- `tests/costumes.gd`: koşu ve yürüme karelerinde gövdenin üst %45'inde ≤ 10 pantolon
  pikseli ve alt dörtte birin ≥ %68'i pantolon (eski maske ikisinde de düşüyordu).

**Testler:** `--import` hata yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps`, `costumes`
(genişletildi), `costume_accessory`, `costume_badge` PASS; bot Bölüm 1 (85,8 sn), 13 (76,0 sn), 25 (86,5 sn) CLEARED.

**Görsel kanıt:** 38 sayfanın mor/camgöbeği önizlemesi ve 1280×720 pencereli oyun içi
görüntü (vapurcu + kızıl, koşu 4 kare + tekme 2 kare): ceket ve pantolon temiz ayrılıyor.
Kalan 2–4 px kalıntı ve silahların ceket rengine boyanması birikime yazıldı.

**Sonraki öneri:** Birikimin yeni başı: kostüm shader'ının sopa/tüfek gibi koyu gri
silahları ceket rengine boyaması.

### 2026-10-24 (10) — Bıçak savuruşunda şapkanın üstündeki tutamlar

**Neden şimdi:** Yol haritasında açık madde yok, P1 maddelerinin hepsinin ilk dilimleri
oyunda; birikimin başı bu kusurdu. Ölçünce sorun notta sanılandan büyük çıktı: bu karede
sivri tutamlar neredeyse siyah çizildiği için doygun saç maskesine girmiyor, bıçak izi
tutamların dibinden geçtiği için de baştan kopuk duruyor; iz ile tek parça olunca **ön
parça** sayılıp şapkanın ÖNÜNE çiziliyordu (kaptan şapkasında yalnız 2 piksel gizliydi).

**Oyuncu ne hissedecek:** Başlıklı kostümle bıçak sallarken saç şapkayı delmiyor; şapka
silüeti diğer karelerle aynı, savuruş izi şapkanın üstünden geçmeye devam ediyor.

**Yapılanlar:**
- `tools/gen_costume_accessory.py` `_tufts()`: baş lekesine HAIR_REACH (8 px) içinde
  yaklaşan, 40–400 px boyunda, çoğu sıcak koyu (r − b ≥ 6, en parlak kanal < 70) ayrı
  koyu leke saç tutamıdır. `front_mask` bunu başa katar (ön parça olmaz); `hair_over_hat`
  bunları korumadan çıkarır, izle karışan gri-kahve kenarlarını (3 px, < 160) ve tutam
  yanında kalan < 8 px görünür kırıntıları da gizler.
- İlk deneme (baştan koyu pikseller boyunca geodezik büyüme) sopa/anahtar/şemsiye
  karelerinde el ve sopanın ön parçasını yiyordu (bat_attack2/0: 178 → 0 px); ikinci
  denemede 40 px alt sınır yokken kol kıvrımı kırıntıları tutam sayılıp kolu şapkanın
  arkasına atıyordu. Son hâlde 236 hücrenin ön parça/işaret sayılarını önce/sonra
  karşılaştırdım: **yalnız `knife_attack/4` değişiyor** (ön parça 525 → 126 px; gizli
  tutam vapurcu 2 → 396, hamal 8 → 309, kahveci 62 → 535 px).
- `tests/costume_accessory.gd`: bıçak karesinde kaptan şapkası bitli > 300 piksel.

**Testler:** `--import` hata yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS;
`costume_accessory` (genişletildi), `costumes` PASS; bot Bölüm 1 (95,3 sn), 13 (78,7 sn),
25 (80,2 sn) CLEARED.

**Görsel kanıt:** Araç önce/sonra önizlemesi (3 başlık, 3× büyütme) ve 1280×720 pencereli
oyun içi görüntü (üç kostüm, `knife_attack` 4. kare): tırtıklı tutamlar gitti, iz duruyor;
şapka üstünde 1 piksellik koyu nokta kaldı (birikimde).

**Sonraki öneri:** Pantolon maskesindeki kaçaklar (birikimin yeni başı).

### 2026-10-24 (9) — Şapkanın üstünden taşan saç gizlendi

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı "başlık ön katmanı gece
konturu" denetimiydi. 1280×720 pencereli görüntüde (dört başlık × sopa/şemsiye/anahtar
saldırı ve bekleme kareleri, gece konturu açık, 5× büyütme) ön parçanın konturu SORUNSUZ
çıktı: rig'in konturu rig'in saydam piksellerinde, ön parça yalnız opak silah/el
piksellerini taşıdığı için konturu örtmüyor; kesik kenar başlığın içinde kalıyor. Aynı
görüntüde asıl kusur görüldü: başlık saç tepesinin 16 px altına oturduğu için sivri saç
tutamları kaptan şapkasının ve kasketin tepesinden dışarı taşıyor, gece konturu bunları
şapkanın üstünde tırtıklı bir hâle olarak çiziyordu (saç şapkayı delmiş gibi; gündüz de
koyu kırıntı olarak görünüyordu).

**Oyuncu ne hissedecek:** Kasket, bere ve kaptan şapkası başın üstünde temiz bir silüet;
gece fener konturu şapkanın düzgün kenarını izler. Sopa/eller şapkanın üstüne çıktığında
kesilmez. Bandana saçı örtmediği için değişmedi.

**Yapılanlar:**
- `tools/gen_costume_accessory.py` 1c: her hücrede her taç başlık için başlığın sütun
  sütun tepe çizgisinin üstünde kalan baş pikselleri (saç lekesi, `HAIR_REACH` = 8 px
  içindeki koyu tutam/kontur pikselleri; ten hariç) sayfa alfasına bit olarak gömülür:
  alfa = 255 − 2·bit (vapurcu 1, hamal 2, kahveci 4; pantolon işareti 254 tek sayı,
  çakışmaz). Baş dışındaki ≥ 60 px parçalar (el, silah) saç olmayan pikseller boyunca
  baş bölgesine doğru büyütülerek korunur (ilk denemede sopanın şapkaya yakın ucu
  kırpılıyordu). Başlığın önüne çizilen ön parçalar (`front_mask`) ve 2 px kenarları da
  korunur (yoksa şapka üstünde silah/kol konturu siliniyordu). 38 sayfada 31 949
  piksel/bit; araç idempotent (eski işaretleri siler, ön parçaları işaretsiz keser).
  Çapa ve ön parça çıktıları değişmedi.
- `player_costume.gdshader`: `hair_bit`; kendi bitini taşıyan piksel saydam sayılır,
  konturda da (kontur yeni silüeti, yani şapkanın kenarını izler). Pantolon ayrımı
  artık kodla (`255 − alfa == 1`).
- `CostumeAccessory.HAIR_BITS` / `hair_bit()`, `Shop.costume_material` bunu malzemeye
  yazar. Malzemesiz (varsayılan) çizimde işaretli saç alfası ≥ 241/255, fark edilmez.
- `tests/costume_accessory.gd`: malzemelerde doğru bit, bandanada 0; koşu sayfasında üç
  başlığın da işareti var ve hepsi başlık tepesinin üstünde.
- Eşikler (8 px erişim, 60 px koruma) önce/sonra önizlemesiyle seçildi: 2 px erişimde
  koyu tutamlar kalıyordu, korumasız sopa ucu kırpılıyordu.

**Testler:** `--import` SCRIPT/SHADER ERROR yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps`
PASS; `costume_accessory` (genişletildi), `costumes`, `costume_badge`,
`new_melee_weapons`, `kaldirim_tasi`, `dark_rim_scope` PASS; bot Bölüm 1 (80,7 sn),
3 (gece, 67,7 sn), 13 (81,7 sn), 25 (95,8 sn) CLEARED.

**Görsel kanıt:** Araç önce/sonra önizlemesi (3 başlık × 12 kare) ve 1280×720 pencereli
oyun içi gece konturlu görüntü: kaptan şapkası ve kasketin tepesindeki tırtıklı hâle
gitti, kontur şapka kenarını izliyor; sopa/şemsiye/eller kesilmedi.

**Sonraki öneri:** Birikimin yeni başı: bıçak savuruşu karesindeki kalan tutamlar (küçük),
ardından pantolon maskesindeki kaçaklar.

### 2026-10-24 (8) — Gece konturu bölüm kapsamında

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı. `main.gd` bölüm
değiştirirken eskisini `queue_free` edip yenisini aynı karede ekliyor; düşman konturu
ertelenmiş kurulduğu için o karede ağaçta iki bölüm var ve `get_first_node_in_group`
eski bölümü döndürüyordu. Test bunu doğruladı: gece bölümünden (ör. 12, 19) sonra gelen
gündüz bölümünün düşmanları fener konturuyla doğuyordu; gece→gece geçişte de eski
bölümün kenar ışığı alınıyordu.

**Oyuncu ne hissedecek:** Gündüz bölümünde düşman silüeti gündüz gibi temiz; turuncu
gece hâlesi yalnız gece bölümlerinde. Bölüm sırasına göre "bazen parlayan" düşman yok.

**Yapılanlar:**
- `Level.dark_scene_of(n)`: düğümün ata zincirindeki bölümü bulur; bölüm gündüzse null.
  Bölüm dışındaki düğümde (test/önizleme) ağaçta TEK gece bölümü varsa onu kabul eder.
- `enemy_base._apply_dark_rim` ve `one_way_platform.draw_dark_edge` bu yardımcıyı
  kullanıyor (iskele kenar ışığı da aynı geçiş karesinde yanlış bölüme bakabiliyordu).
- `tests/dark_rim_scope.gd`: main.gd'nin değişimini taklit eder (eskiyi queue_free +
  yeniyi aynı karede ekle) — gece→gündüz kontursuz, gündüz→gece konturlu, gece→gece
  yeni bölümün rengi, bölüm dışı düğüm kuralları. Eski kodla 2 denetim düşüyor.
- Görsel kanıt ekran görüntüsü yerine deterministik testle: değişiklik kontur
  görünümünü değil hangi bölüme bakıldığını etkiliyor.

**Testler:** `--import` SCRIPT ERROR yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS;
`dark_rim_scope` PASS; bot Bölüm 1 (80,8 sn), 3 (gece, 66,6 sn), 13 (77,6 sn),
20 (geceden sonraki gündüz, 92,0 sn), 25 (86,4 sn) CLEARED.

**Sonraki öneri:** Başlık ön katmanının gece konturu denetimi (birikimin yeni başı).

### 2026-10-24 (7) — Başlığın önünden geçen kol ve silah

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı. Başlıklı kostümle sopa/
şemsiye/anahtarın baş üstü savuruşunda (ikinci vuruş ve hazırlık kareleri) şapka eli ve
silahı örtüyordu: oyuncu vuruşun hangi karede tepeye kalktığını göremiyor, silah şapkanın
içinden çıkıyormuş gibi okunuyordu. Ayrıca sopalı bir karede sopa ahşabı saç sanıldığı
için başlık başın 45 px üstünde havada asılı kalıyordu.

**Oyuncu ne hissedecek:** Kasketle sopayı tepeye kaldırınca eller ve sopa şapkanın önünde;
şapka başta kalır, savuruşun tepe noktası okunur. Kostüm boyası kolda da sürer.

**Yapılanlar:**
- `tools/gen_costume_accessory.py`: saç maskesine doygunluk eşiği (> 0,46; saç ≥ ~0,52,
  sopa ahşabı ≤ ~0,41 ölçüldü) — `bat_attack2` 0. karede çapa 15→54. Yeni "ön parça"
  çıktısı: her hücrede dört başlığın birleşik izdüşümüne düşen, başa (saç lekesi + ona
  değen yüz ten lekesi, delikler dolu, 4 px genişletilmiş) ait olmayan, ≥ 30 px opak
  bölgeler `costume_acc/head_front.png` atlasına kesilir; tablo `head_anchors.json`
  `front` alanında. 236 hücreden 40'ında parça var (sopa/şemsiye/anahtar saldırı,
  bekleme ve yürüme kareleri, bıçak savuruş izi).
- `CostumeAccessory`: ön parçayı rig'in çocuğu olarak başlıktan SONRA ekler (üstte),
  aynı çapa/aynalama hesabıyla yerleştirir; malzeme rig'in kostüm malzemesinin
  kontursuz kopyası. Parçası olmayan karede gizli; başlık çıkınca silinir.
- `tests/costume_accessory.gd`: sopalı karede çapa doğrulaması, ön parçanın başlığın
  üstünde/hizalı/aynalı, kostüm boyalı-kontursuz ve parçasız karede gizli olması.
- Eşikler (0,46 doygunluk, 30 px, 4 px) önizleme sayfasında elle seçildi: 12 px / 2 px
  ile saç tutamı uçları şapkanın üstüne leke olarak çıkıyordu.

**Görsel kanıt:** Araç önizlemesi (kasket/kaptan, 8 silah sayfası) ve 1280×720 pencereli
oyun içi görüntü (kasketle `bat_attack2` 0/1/7, `bat_attack` 7, `bat_walk` 3): sopa ve
eller şapkanın önünde, şapka başta.

**Testler:** `--import` SCRIPT ERROR yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS;
`costume_accessory` (genişletildi), `costumes`, `costume_badge`, `kaldirim_tasi`,
`new_melee_weapons` PASS; bot Bölüm 1 (83,2 sn), 13 (81,8 sn), 25 (80,8 sn) CLEARED.

**Sonraki öneri:** Gece geçişinde düşman konturu denetimi (birikimin yeni başı).

### 2026-10-24 (6) — Gece bölümlerinde kostüm başlığına fener konturu

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı. Kitap 1'in yarısı gece
(Bölüm 3, 4, 6, 7, 8…); başlıklı kostümde gövde fener ışığıyla konturlanırken başlık
konturuz kalıyor, gövdenin kontur çizgisi de şapkanın altından saça doğru görünüyordu.

**Oyuncu ne hissedecek:** Gece pazarında kaptan şapkası, bere, kasket gövdeyle aynı
sıcak kontur içinde; karakter tek parça silüet olarak okunur, başlık "yapıştırılmış"
görünmez.

**Yapılanlar:**
- `dark_rim.gdshader`: `rim_only` (yalnız kontur, gövde saydam). `CostumeAccessory`
  rig'in malzemesinden gece konturunu okur (`rig_rim`: kostüm `rim_enabled` ya da
  `night_rim`), açıksa başlık dokusunun kontur kopyasını rig'in kardeşi olarak
  `show_behind_parent` ile ARKAYA çizer: yalnız silüetin dışına taşan kenar parlar,
  şapkanın saça bindiği alt kenarda kontur yüze binmez. Başlık çıkınca kopya da silinir.
- **Önceden var olan hata düzeltildi:** `main.gd` eski bölümü yenisi eklendikten sonra
  siler; eski bölümün `_exit_tree`'si yeni gece bölümünün açtığı oyuncu konturunu
  kapatıyordu (kostümsüzde malzemeyi bile siliyordu). Kontur yalnız menüden doğrudan
  girişte görünüyordu; bölüm geçişinde ve TEKRAR'da kayboluyordu. `_owns_night_rim()`:
  yalnız gece olan ve ağaçta başka gece bölümü kalmamış bölüm konturu kapatır.
- `tests/costume_accessory.gd`: gece konturu açılınca kopya arkada/hizalı/aynı doku ve
  renkte, kapanınca gizli, başlık çıkınca silinmiş denetimleri. Kayıt formatı değişmedi.

**Görsel kanıt:** Bölüm 3 (gece) 1280×720 pencereli, vapurcu kostümü, ara sahne
geçildikten sonra 5× büyütme; önce/sonra karşılaştırıldı.

**Testler:** `--import` SCRIPT ERROR yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS;
`costume_accessory` (genişletildi), `costume_badge` PASS; bot Bölüm 1 (79,0 sn), 3 (gece,
63,4 sn), 13 (77,2 sn), 25 (86,5 sn) CLEARED.

**Sonraki öneri:** Birikimdeki başlık kol-önü kareleri ya da gece geçişinde düşman konturu
denetimi.

### 2026-10-24 (5) — Sonuç kartında "giyili" kostüm künyesi

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı. Bir önceki turda
duraklat menüsüne eklenen rozetin eşi: bölüm sonucunu okuyan oyuncu o koşuyu hangi
bonusla oynadığını da görsün (ör. HASARSIZ yıldızı VAPURCU'nun +10 canıyla alındı).

**Oyuncu ne hissedecek:** Sonuç kartının hemen altında tek satırlık piksel künye:
başlık ikonu + `GİYİLİ: HAMAL · SİLAH ÖMRÜ +%15`. Sokak ceketinde künye yok.

**Yapılanlar:**
- `hud.gd`: `_build_costume_badge()` / `_refresh_costume_badge()`; künye kartın
  dışında (kart alt kenarı +258..318), `panel_hud` piksel çerçeve, piksel yazı tipi,
  her `_reveal`'da yenilenir. Kart içine konmadı: oyun sonu istatistiği masaüstünde
  7 satıra çıkıyor, iç boşluk değişken. Metin ve ikon `Shop` tek kaynağından.
- Önceden kalan taşma: "Yeni vuruş mağazada!" ipucu kartın sağ çerçevesine
  biniyordu; `R — devam` olarak kısaltıldı.
- `tests/costume_badge.gd`: HUD sonuç kartında görünürlük/bonus/ikon ve sokak
  ceketinde gizlilik denetimi eklendi. Kayıt formatı değişmedi.

**Testler:** `--import` SCRIPT ERROR yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps`
PASS; `costume_badge` (genişletildi), `level_stars`, `touch_polish` PASS; bot Bölüm 1
(80,7 sn), 13 (80,9 sn), 25 (85,4 sn) CLEARED. 1280×720 pencereli görüntüde vapurcu ve
hamal künyesi incelendi: ilk hâlde bonus yazısı çerçeveye değiyordu ve ad ile bonus
bitişikti; iç pay 20'ye çıkarıldı, araya `·` kondu.

**Sonraki öneri:** Başlık katmanı eksikleri (gece kontur, kolun önünden geçtiği kareler).

### 2026-10-24 (4) — Duraklat menüsünde "giyili" kostüm rozeti

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı. Kostüm bonusu (can,
yumruk, silah ömrü, yiyecek) sahada hiçbir yerde yazmıyordu; oyuncu 240 coin verdiği
KIZIL DAĞ'ın ne kazandırdığını mağazaya dönmeden hatırlayamıyordu. Küçük, okunurluğu
doğrudan artıran iş.

**Oyuncu ne hissedecek:** Duraklatınca menünün başında HUD çerçeveli küçük bir rozet:
kostümün piksel başlığı + `GİYİLİ: VAPURCU` + altın `CAN +10`. Bonussuz sokak ceketinde
rozet yok (menü eskisi gibi).

**Yapılanlar:**
- `Shop.costume_bonus_text(id)`: `bonus` sözlüğünden kısa metin (`CAN +10`,
  `SİLAH ÖMRÜ +%15`, `YİYECEK +%25`, `YUMRUK +%8`); sayılar tek kaynaktan.
- `PauseMenu`: `Costume` rozeti (`panel_hud` piksel çerçeve, başlık ikonu 1x NEAREST),
  her açılışta `refresh_costume()`. Kayıt formatı değişmedi.

**Testler:** `--import` SCRIPT ERROR yok; yeni `tests/costume_badge.tscn` PASS (dört bonus
metni, varsayılanda gizli, kızıl dağda ad/bonus/ikon); `touch_polish` PASS;
`campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS; bot Bölüm 1 CLEARED (80,3 sn). 1280×720
pencereli görüntüde hamal/kızıl/vapurcu rozeti incelendi: ilk denemede `kart` çerçevesinin
kırmızı başlık şeridi yazıyla çakışıyordu, `panel_hud`'a geçildi; bandana çerçeveye
değiyordu, iç pay 22'ye çıkarıldı.

**Sonraki öneri:** Başlık katmanı eksikleri (gece kontur, kolun önünden geçtiği kareler)
ya da günün dalgası dördüncü dilim.

### 2026-10-24 (3) — Kostümlerin üçüncü dilimi: piksel başlıklar

**Neden şimdi:** Yol haritası ve OYNANIS-KALITE P1 sırası (1–7) bitti; birikimin başı.
Kostümler yalnız giysi paletini değiştiriyordu: siluet aynıydı, oyun ölçeğinde (0,6) ve
kalabalık arenada kostüm "renk farkı" olarak kalıyordu. DTM'de kıyafetin ilk okunan
yeri baş/şapkadır.

**Oyuncu ne hissedecek:** Satın aldığı kostüm sahada uzaktan tanınır: VAPURCU beyaz
tepeli kaptan şapkası (altın çapa rozetli), HAMAL haki yün bere, KAHVECİ tüvit kasket,
KIZIL DAĞ alında kırmızı bandana (arkada düğüm ve sarkan uçlar). Başlık her karede başla
birlikte oynar, sola dönünce aynalanır; mağaza önizlemesinde, ana menüde ve ara
sahnelerde de görünür.

**Yapılanlar:**
- `tools/gen_costume_accessory.py`: 38 sayfanın 236 hücresinde baş çapası `[cx, top,
  brow]` (saç = doygun koyu kahve, ten = doygun açık turuncu; en büyük saç lekesi baş,
  tek sivri tutam tepeyi yukarı çekmesin diye ≥4 piksellik ilk satır) →
  `assets/anim/redmount/head_anchors.json`. Dört başlık 72×44, sayfalarla aynı piksel
  yoğunluğunda (1 sanat pikseli = 1 hücre pikseli), palet + 4 ton gölge + kontur →
  `assets/anim/costume_acc/*.png`. Araç tekrar çalıştırılabilir.
- `CostumeAccessory` (Sprite2D): AnimatedSprite2D'ye çocuk; o anki AtlasTexture'ın
  sayfa/hücresinden çapayı okur (sopa varyantları gibi kodla eklenen animasyonlar da
  çalışır), dönüş/eğim/ölçek/modülasyon ebeveynden gelir. `apply(sprite, id)` tek giriş:
  `Redmount.apply_costume`, ana menü, ara sahne. Mağaza önizlemesine `TextureRect` başlık;
  önizleme bölgesi başlığa yer açmak için 12 px yukarı uzatıldı.
- `Shop.COSTUMES`: `accessory` + `attach` ("crown"/"brow"). Kayıt formatı değişmedi.

**Sayılar (hipotez):** Başlık saç tepesinin 16 px altına oturur (saç ~20 px kabarık; tepe
örter, yanlardan kıvırcık saç taşar — karakterin saçı korunur); bandana alın çizgisinin
2 px üstünde. Başlıklar ~54 px genişlik: saç lekesiyle aynı, siluete en fazla siper kadar
(~15 px) ekler.

**Testler:** `--import` SCRIPT ERROR yok; yeni `tests/costume_accessory.tscn` PASS (dört
başlık dokusu, oyuncunun bütün animasyon karelerinde makul çapa, rig'de baş hizası ve
sola dönünce aynalama, kostüm değişince değişme / sokak ceketinde çıkma, mağazada 4
başlıklı önizleme); `tests/costumes.tscn` PASS; `survival_mode` OK; `campaign_smoke.gd`
çıkış 0; `dtm_gaps` PASS; bot Bölüm 1 CLEARED (82,9 sn), Bölüm 13 (80,8), Bölüm 25 (90,8) —
oyuncu rig'i ortak olduğu için üç bölüm. 1280×720 pencereli görüntüde 4 kostüm × 5 poz
(idle/koşu/kombo/aynalı tekme/zıplama) oyun ölçeğinde ve 1,5x, ayrıca mağaza sekmesi
incelendi; taşma yok. Telefonda görülmedi.

**Sonraki öneri:** Pantolon maskesi kaçakları ya da günün dalgası dördüncü dilim (arşiv
karesi ödülü, seri koruma); kostüm bonusunun duraklat menüsünde hatırlatılması küçük iş.

### 2026-10-24 (2) — Yeni silahların ikinci dilimi: kaldırım taşı ve tam cephanelik

**Neden şimdi:** OYNANIS-KALITE P1 sırasında "yeni yakın silahlar" maddesinin kalanı açıktı
(fırlatılabilir silah + duraklat cephaneliğinde yeni silahlar yok). Tüfekli muhafız gibi
menzilli düşmana karşı oyuncunun yakın dövüşten başka cevabı yalnız tabancaydı; DTM'deki
"yerden bir şey kapıp fırlat" kararı eksikti.

**Oyuncu ne hissedecek:** Bölüm 2'nin alt sokağında tüfekliden önce sökük kaldırım
yığını: üç taş, L ile kısa bir yay çizerek fırlatılır, ağır vurur ve düşmanı iter; taşlar
bitince el boşalır. Duraklat menüsünde artık Anahtar, Şemsiye ve Taş da satılır; her
kartın kuşanma notu silahın tek ayırt edici özelliğini söyler.

**Yapılanlar:**
- `GunConfig` "Fırlatma" grubu: `ammo_label`, `projectile_gravity`, `throw_lift`,
  `projectile_scene`, `fire_sfx` (eski `.tres`'ler varsayılanla okunur). Yeni ateş/fırlatma
  sistemi yazılmadı: taş bir GunConfig (`kaldirim_tasi.tres`, şarjör 1 + yedek 2; "yeniden
  doldurma" yerden yeni taş almak).
- `Projectile.arc_gravity` (Area2D'nin kendi `gravity` özelliğiyle çakışmasın diye bu ad):
  yay + dönüş; zemine çarpınca toz ve tok ses. `spawn()` artık mermiyi döndürür ve isteğe
  bağlı sahne alır; düşman çağrıları değişmedi.
- Sanat (`tools/gen_pixel_weapons.py main_tas`): 48 px üç taşlık yığın ikonu, 12×10 uçan
  bazalt taş (oyunda 2x NEAREST, `scenes/systems/TasMermi.tscn`). Yüz gibi okunan ilk
  çatlak deseni değiştirildi.
- HUD: fırlatılan silahta `TAŞ 3` / `Taş: 3` (toplam adet), ateşli silahta eskisi gibi
  `MERMİ m/r`. `ammo_changed` sinyaline `label` eklendi.
- Cephanelik tek kaynak: `PauseMenu.ARMORY` (kimlik, ad, fiyat, kaynak, not); Main ve
  Survival aynı listeyi ve `armory_equip` kullanır (Survival'daki çift `knife` dalı ve
  "Kuşanıldı: Anahtar" gibi ham kimlikli mesaj gitti).

**Sayılar (hipotez):** Taş hasarı 22 (sopa 16, anahtar 20): üç atışla sınırlı ve nişan
istiyor. Hız 760, kaldırış 0,35, yerçekimi 1100 → yayın tepesi ~29 px, aynı yükseklikte
~330 px menzil: ayaktaki düşmana yol boyunca isabet eder, ekranın yarısını aşmaz. Geri
itme 360 (tüfekliyi siperinden düşürecek kadar). Fiyatlar: taş 15 (en ucuz, tek
kullanımlık), şemsiye 25, anahtar 30 (bölüm dükkânından ucuz, çünkü yalnız bu can için).

**Testler:** `--import` SCRIPT ERROR yok; `tests/kaldirim_tasi.tscn` PASS (yeni: kaynak
değerleri, pickup/ikon, 9 kartlı tek kaynak cephanelik, Bölüm 2 yığını, 15 coin alım, HUD,
yay + 260 px'teki düşmana isabet, üç atıştan sonra el boşalır); `campaign_smoke.gd` çıkış 0;
`dtm_gaps` PASS; `survival_mode`, `new_melee_weapons`, `daily_wave`, `costumes` PASS;
bot Bölüm 2 CLEARED (70,9 sn), Bölüm 1 (81,0), Bölüm 13 (80,5), Bölüm 25 (85,9) — ortak
mermi/HUD/cephanelik değiştiği için dört bölüm. 1280×720 pencereli görüntüde yığın, uçan
taş ve 9 kartlı cephanelik incelendi; taşma yok. Telefonda görülmedi.

**Sonraki öneri:** Kostüm aksesuar katmanı (birikimin başı) ya da kaldırım taşı için gerçek
fırlatma sayfası.

### 2026-10-24 — Kostümlerin ikinci dilimi: ceket ve pantolon ayrı renk

**Neden şimdi:** Yol haritası ve P1 listesi bitti; birikimin başı. Kostümler tek rampayla
boyandığı için VAPURCU baştan ayağa lacivert, KIZIL DAĞ baştan ayağa kırmızı bir tulum
gibi duruyordu; giysi değil "renk filtresi" okunuyordu. 240 coin'lik hedefin kıyafet gibi
görünmesi gerekiyor.

**Oyuncu ne hissedecek:** Kostüm giyince ceket rengini alır, pantolon ayrı ve daha sakin
bir tonda kalır (lacivert ceket + füme pantolon, kızıl ceket + kömür pantolon); mağaza
önizlemesi ve oyundaki karakter aynı.

**Yapılanlar:**
- `tools/gen_costume_mask.py`: her 200×240 karede pantolon piksellerinin alfasını 255→254
  yapar (RGB'ye dokunmaz; kostümsüz çizimde fark yok). Ayrım: giysi gri pikselinin 7×7
  yerel ortalaması ≥ 36 (ceket ~30, pantolon ~45), büyük beyaz lekeden (ayakkabı ≥ 30 px;
  fermuar parıltısı elenir) başlayıp adaylar boyunca en fazla 60 adım (bacak boyu) büyüme,
  sonra kıvrım/kontur deliklerinin kapatılması. 38 sayfanın tamamı işlendi; araç tekrar
  çalıştırılabilir.
- `player_costume.gdshader`: `pants_shade`/`pants_light`; alfa < 0,998 olan giysi pikseli
  ikinci rampaya, alfa 1'e. `Shop.COSTUMES` dört kostüme pantolon rampası; alan yoksa
  ceket rampası kullanılır (eski veri bozulmaz). Kayıt formatı değişmedi.

**Sayılar (hipotez):** Eşik 36 / 60 adım, kopya sayfalarda 3 denemeyle seçildi: 40 arka
bacağı kaybediyor, 74 adım koşuda ceket eteğine taşıyordu. Pantolon rampalarının koyu
ucu ceketinkine yakın: maskenin kaçırdığı gölgeli bacak pikseli gölge gibi okunur.

**Testler:** `--import` hatasız; `tests/costumes.tscn` PASS (yeni: idle karesinde bacakta
>1000 işaretli piksel, baş/omuzda 0; malzemede pantolon rampası); `tests/campaign_smoke.gd`
çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 CLEARED (80,4 sn), Bölüm 13 CLEARED (81,7 sn), Bölüm 25 CLEARED (103,4 sn) — ortak oyuncu sayfaları değiştiği için üç bölüm. 1280×720 pencereli görüntüde 5
kostüm × 4 poz (idle/koşu/tekme/kombo) incelendi: ayrım net, kızılda tekme dizinde
birkaç kırmızı piksel kalıyor (birikime yazıldı). Telefonda görülmedi.

**Sonraki öneri:** Kostüm aksesuar katmanı ya da günün dalgası dördüncü dilim (arşiv
karesi ödülü, seri koruma).

### 2026-10-23 (9) — Günün Dalgası üçüncü dilim: eşit kural rotasyonu, "seri koptu" uyarısı

**Neden şimdi:** Yol haritası ve P1 listesi bitti; birikimin en üstündeki madde. Kural
`randi_range` ile tohumdan seçiliyordu: 365 günde bazı kurallar ~50, bazıları ~30 kez
çıkıyor, aynı kural art arda iki gün gelebiliyordu (dün SOPA GÜNÜ, bugün yine SOPA GÜNÜ
"günlük" hissini öldürür). Seri koptuğunda ise rozet sessizce kayboluyordu — oyuncu
neyi kaybettiğini ve geri dönebileceğini görmüyordu.

**Oyuncu ne hissedecek:** Her gün bir öncekinden farklı kural; 9 günde 9 kuralın hepsi
bir kez. Bir günü kaçıran oyuncu menüde seri rozetinin yerinde ateş renginde
`SERİ KOPTU (6 GÜN) · yeniden başla` görür; bugün temizleyince rozet seri 1 ile altına döner.

**Yapılanlar:**
- `DailyWave.rule_index`: günler 9'luk bloklara bölünür, her blokta kurallar tohumlu
  Fisher–Yates ile karışık sırada birer kez; blok sınırında önceki bloğun son kuralı
  tekrar gelirse ilk ikisi takas edilir. Dalga dizisi hâlâ tarih tohumundan.
- `DailyWave.streak_broken` + `BROKEN_NOTICE_DAYS = 7`; menüde aynı piksel panelde
  uyarı (`StreakBadge`). Kayıt formatı değişmedi.

**Sayılar (hipotez):** Uyarı kopuştan sonra 7 gün gösterilir: haftalık oynayan oyuncuya
hatırlatma, aylarca sonra dönen oyuncuya suçlama yok. Rotasyonla aynı kural en erken
2, en geç 17 gün sonra döner. Kural değişimi aynı tarihe eski sürümden farklı plan
verir (sunucu yok, sorun değil).

**Testler:** `--import` hatasız; `tests/daily_wave.tscn` PASS (yeni: bir yılda kural
sayıları arasında en fazla 2 fark, art arda tekrar 0, blokta her kural bir kez, kopuş sınırları, menüde
canlı/kopan/boş seri rozeti); `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 1 CLEARED (82,0 sn; ortak sistem değişmedi, yalnız menü + günlük kip).
1280×720 ekran görüntüsünde uyarı rozeti kontrol edildi (ilk metin panelin sağ kenarına
değiyordu, kısaltıldı). Telefonda görülmedi.

**Sonraki öneri:** Birikimin başı kostümlerin ikinci dilimi (ceket/pantolon ayrı rampa +
küçük piksel aksesuar).

### 2026-10-23 (8) — Günün Dalgası ikinci dilim: seri ödülü, seri rozeti, 3 yeni kural

**Neden şimdi:** Yol haritası ve OYNANIS-KALITE P1 listesi bitti; birikimin en üstündeki
madde. Günlük kipin seri sayacı vardı ama hiçbir şey vermiyordu ve menüde görünmüyordu —
"yarın da gel" çağrısı yoktu. 6 kural haftada bir tekrarlanıyordu.

**Oyuncu ne hissedecek:** Ana menüde sağ üstte istatistik panelinin altında piksel
çerçeveli `SERİ 6 GÜN · 7. günde +100 coin` rozeti (seri canlıyken). Ödül gününde sonuç
kartında `SERİ ÖDÜLÜ +40`. Üç yeni gün türü: HIZLI ADIM (düşmanlar %30 hızlı, kaçma/
pozisyon günü), ERKEN PATRON (3. dalga tek başına Mini Boss, sonra iki normal dalga ve
final boss), BIÇAK GÜNÜ (bıçakla başla, her dalgada bıçaklı).

**Yapılanlar:**
- `DailyWave`: `STREAK_REWARDS` 3→40, 7→100, 14→200, sonra her 7 günde 100;
  `streak_reward/next_streak_reward/streak_alive`; isteğe bağlı kural alanları `must`,
  `speed`, `boss_at` (eski kurallar varsayılanla okunur; nişancı `must: rifle`a taşındı).
- `Save.finish_daily` ödülü cüzdana ekleyip döndürür; aynı gün ikinci çağrı ödül vermez.
  Kayıt formatı değişmedi.
- `survival.gd`: bıçak başlangıcı, hızlı günde düşman config'inin kopyası hızlandırılır
  (paylaşılan .tres bozulmaz), ara patron dalgasında "PATRON DALGASI" yazısı, sonuç kartında
  seri ödülü.
- `main_menu.gd`: seri rozeti istatistik panelinin altında (ilk denemede ana sütuna
  konmuştu; ÇIKIŞ düğmesini alttaki tuş yardım satırına bindirdi → taşındı).

**Sayılar (hipotez):** 3. gün 40 ≈ günlük tamamlamanın üçte ikisi (erken, kısa vadeli
kanca); 7. gün 100 ≈ bir kostümün yarısı; 14. gün 200 ≈ en pahalı kostüm. Bir haftalık
seri günlük 60+~45'in üstüne toplam 140 ekler — kampanyayı gölgelemez, geri dönmeyi
ödüllendirir. Hızlı gün çarpanı 1,3: koşan oyuncu ~ düşman hızı farkını hisseder ama
eşkıya yine de oyuncudan yavaş; insan testinde "kaçamadım" ölümü artarsa 1,2.
Kural seçimi artık 9'da bir; değişiklik aynı tarih için eski sürümden farklı plan verir
(sunucu olmadığından sorun değil).

**Testler:** `--import` hatasız; `tests/daily_wave.tscn` PASS (yeni: bir yılda 9 kuralın
hepsi çıkıyor, `must` vaadi her dalgada, erken patron 3. dalgada tek, seri ödül tablosu,
aynı gün ödül tekrarlanmıyor, hızlı günde gerçek sahnede düşmanlar ×1,3 ve paylaşılan
config değişmiyor, seri 2→3 koşusunda +40 ve sonuç kartı metni); `tests/campaign_smoke.gd`
çıkış 0; `tests/dtm_gaps.tscn` PASS; `tests/costumes.tscn` PASS; bot Bölüm 1 (84,7 sn),
13 (77,4 sn), 25 (98,6 sn) CLEARED. 1280×720 ekran görüntüsünde menü rozeti ve sonuç
kartı kontrol edildi. Telefonda görülmedi.

**Sonraki öneri:** Birikimin başı artık kostümlerin ikinci dilimi (ceket/pantolon ayrı
rampa + küçük piksel aksesuar).

### 2026-10-23 (7) — Survival arenası piksel art'a çevrildi (birikim 1. madde)

**Neden şimdi:** Yol haritası ve OYNANIS-KALITE P1 sırası (1–7) bitti; birikimin en
üstündeki madde. Survival ve yeni Günün Dalgası, `_draw()` ile çizilen koyu düz dikdörtgen
+ eğik çizgilerden ibaret bir boşlukta oynanıyordu — piksel art kuralına aykırı ve
kampanya bölümlerinin yanında "bitmemiş prototip" gibi duruyordu. Günlük kip her gün
açılan ekran olacağı için ilk izlenim önemli.

**Oyuncu ne hissedecek:** Survival akşamüstü bir Balat arka sokağında: boyalı gökyüzü,
arkada karartılmış ev sırası, kaldırım + taş dolgulu zemin, üç sokak feneri, büfe ve
saksılar. Günün Dalgası aynı süslerle ama pazar sokağı/kemer arka planında — iki kip ilk
bakışta ayrılır.

**Yapılanlar:** `survival.gd` yeni sistem yazmadan DtmLevel'in çizim sınıflarını
kullanıyor: `DtmLevel._Sky` + `_BackRow` (`level` = Survival düğümü; okudukları
`sky_*`/`back_*` alanları Survival'a eklendi), zemin `_Art.A_TERRAIN` (zemin gövdesi
bölümlerdeki gibi 520 px derin; çarpışma üstü y=0, değişmedi), `_Lantern`, mahalle
süsleri (`BUFE`, `TREE_POT`, `PLANT`, `POTS`) ve `_night()` ile aynı hafif
`CanvasModulate`. Atlas: `level06_backstreets_atlas.png` hücre 0 (Survival) / 1 (Günlük).
`_draw()` kaldırıldı.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; `tests/daily_wave.tscn` PASS; `tests/survival_mode.tscn` OK. 1280×720 pencereli
ekran görüntüsü (iki kip, orta ve sol kenar): taşma/boşluk yok, HUD/pankart okunuyor;
sol kenarda arka sıra evler x≈-600'den başlıyor, arkada gökyüzü dolu (sorun görülmedi).
Kampanya bölümleri değişmediği için bot koşusu yapılmadı. Telefonda görülmedi.

**Sıradaki öneri:** birikimdeki günün dalgası ikinci dilimi (seri ödülü/rozeti, yeni kurallar).

### 2026-10-23 (6) — Günün Dalgası (OYNANIS-KALITE P1-7, ilk dilim)

**Neden şimdi:** Yol haritası bitti; P1 sırasında yeni silahlar ve kostümlerden sonra
sıradaki madde. Kampanya 36 bölüm ama telefonda "3 dakikam var" oturumuna uyan, her gün
yeni bir sebep veren kısa bir mod yoktu; Survival sonsuz ve her seferinde aynı.

**Oyuncu ne hissedecek:** Menüde GÜNÜN DALGASI'na basar, arenaya girer girmez pankartta
günün kuralı ("PAZAR KALABALIĞI · Her dalgada +2 eşkıya"). Beş kısa dalga, üstte
`DALGA 2/5 · 4 DÜŞMAN`, sonda Mini Boss. Bitince kartta büyük `5/5`, coin + tamamlama
ödülü ve seri. Tek hak olduğu için ilk deneme gerilimli; tekrar istediği kadar antrenman
yapar ama ödül yarın — yarın yeni kural ve dizi gelir.

**Yapılanlar:**
- `scripts/systems/daily_wave.gd` (`DailyWave`): FNV-1a tarih tohumu (Godot `hash()`
  sürümler arası değişebilir), 6 kural, 5 dalgalık plan, `next_streak` (ay/yıl sınırı).
- `survival.gd`: `GameState.daily_run` ile günlük kip; plan dalgaları kenarlardan
  dönüşümlü doğar, kural silah/zırh/iyileşme/cephanelik uygular, arena sayacı ve
  pankart HUD'un mevcut piksel parçalarıyla; sonuç kartında madalya çerçevesine `n/5`.
  Doğurma kodu `_spawn` olarak ortaklaştı (normal survival aynı).
- `Save`: `[daily] day/waves/clear_day/streak`, `begin_daily/record_daily_wave/finish_daily`.
- `main_menu.gd`: SURVIVAL ile GÜNÜN DALGASI yan yana (sütun 720 px'e sığsın).

**Sayılar (hipotez):** 5 dalga ≈ 2–4 dk (mobil oturum). Dalga başına 2+w (+kural ek)
düşman, en çok 8; dalga w'de havuzun ilk w+1 tipi açık, ilk dalga yalnız eşkıya/bıçaklı.
Tamamlama +60: dalga coin'leri (5–13, toplam 45) kadar — günde bir kez alınır, mağaza
kostümü (120–240) 2–4 günlük hedef olur, kampanyanın bölüm coin'ini gölgelemez. Hak
başlarken kullanılır: yarıda çıkıp yeniden denemek "puanlı tekrar" olmasın.

**Testler:** `--import` hatasız; yeni `tests/daily_wave.tscn` PASS (aynı gün aynı plan,
30 günde ≥4 kural ve ≥25 farklı dizi, boss yalnız son dalgada, seri ay/yıl sınırı, eski
kayıt uyumu, gerçek Survival sahnesinde 5 dalga: coin + 60, seri 2→3, sonuç kartı,
survival rekoru değişmez; ikinci deneme antrenman, coin yazmaz); `tests/campaign_smoke.gd`
çıkış 0; `tests/dtm_gaps.tscn` PASS; `tests/costumes.tscn`, `tests/level_stars.tscn` PASS;
bot Bölüm 1 (78,0 sn), 13 (75,1 sn), 25 (88,2 sn) CLEARED; normal Survival 300 kare
hatasız. 1280×720 ekran görüntüsünde menü satırı, kural pankartı + dalga sayacı ve sonuç
kartı kontrol edildi (ilk denemede kural `Fx.popup` ile hemen sönüyordu → pankarta
taşındı; sonuç metni ipucu düğmesinin altına taşıyordu → 3 satıra indirildi). Telefonda
görülmedi; insan oyuncuyla günlük koşu süresi ölçülmedi.

**Sonraki öneri:** OYNANIS-KALITE P1 listesi ilk dilimleriyle bitti. Birikimin başı:
Survival arenasının arka planını piksel art'a çevirmek (günlük mod artık oraya oyuncu
çekiyor ve arena kurala aykırı biçimde kodla çiziliyor).

### 2026-10-23 (5) — Kostümler (OYNANIS-KALITE P1-6, ilk dilim)

**Neden şimdi:** Yol haritası bitti; P1 sırasında yeni yakın silahların ilk dilimi yapıldı,
sıradaki madde kostümler. Mağazadaki 4 hareket + 7×3 yükseltme ~2.200 coin'de bitiyor;
sonrasında coin'in hiçbir karşılığı kalmıyordu. Kostüm hem uzun vadeli harcama hedefi
hem de oyuncunun karakterine sahip çıkma hissi verir.

**Oyuncu ne hissedecek:** Mağazada KOSTÜMLER sekmesinde Redmount'u beş giysiyle yan yana
görür; kilitli olanlar hangi bölümde açılacağını söyler. Alınca hemen giyer; bölüme
girince sahada, ara sahnede ve ana menü çatısında aynı renkte görür. Her kostümün tek
küçük bonusu oyun tarzına göre seçim yaptırır (tank / silahçı / yiyecekle toparlanan /
yumrukçu), ama hiçbiri zorunlu değil.

**Yapılanlar:**
- `shaders/player_costume.gdshader`: palet takası (doygunluk < 0,25 ve parlaklık
  0,035–0,62 arası pikseller rampaya; kontur, ten, saç, ayakkabı korunur) + isteğe
  bağlı gece konturu. Varsayılan kostümde malzeme yok (sıfır risk).
- `Shop.COSTUMES`, `Shop.costume/costume_bonus/costume_material`; adlar Türkçe büyük
  harfle (Godot `to_upper` "i"yi "I" yapıyordu).
- `Save.costume` + `owns_costume/buy_costume/set_costume`; eski kayıt uyumlu.
- `redmount.gd`: `apply_costume()`, can ve yumruk/silah kapasitesi çarpanlarına bonus;
  `health_pickup.gd`: yiyecek bonusu (Survival dalga iyileştirmesi etkilenmez).
- `dtm_level.gd`: gece konturu kostüm malzemesi varsa onun `rim_enabled`'ını açar/kapatır.
- `cutscene.gd`, `main_menu.gd`: Redmount kuklası da giyili kostümle.
- `shop_menu.gd`: üçüncü sekme ve kostüm kartı.

**Sayılar (hipotez):** Fiyatlar 120–240: en pahalı yükseltme kademesinden (140) yüksek,
böylece önce oynanışı değiştiren alımlar yapılır, kostüm "sonraki hedef" olur. Bonuslar
yükseltmenin tek kademesinden küçük ya da ona yakın (can +10 < +15; yumruk %8 < %12;
silah %15 < %20) — kostüm bir güç basamağı değil, tarz seçimi. Kahveci %25 yiyecek:
30'luk simit 37'ye çıkar, tek başına bir isabeti karşılar. Açılış bölümleri (3/8/14/20)
kitaplara yayılır, her kitapta yeni bir hedef görünsün.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; `tests/level_stars.tscn` PASS; `tests/new_melee_weapons.tscn` PASS; yeni
`tests/costumes.tscn` PASS (eski kayıt, bilinmeyen id, satın alma/giyme, palet
malzemesi + gece konturu parametresi, oyuncuya can/yumruk bonusu, mağaza sekmesi);
bot Bölüm 1 (77,1 sn), 13 (79,0 sn), 25 (89,5 sn) CLEARED. 1280×720 ekran görüntüsünde
mağaza sekmesi ve Bölüm 1 açılış sahnesinde lacivert Redmount kontrol edildi (ilk
görüntüde ara sahne kuklası siyah kalıyordu → `cutscene.gd` düzeltildi). Gece bölümü
ve telefon ekranında görülmedi.

**Sonraki öneri:** OYNANIS-KALITE P1-7 — günün dalgası (Survival'a tarih tohumlu kısa mod).

### 2026-10-23 (4) — Yeni yakın silahlar: Boru Anahtarı ve Şemsiye (OYNANIS-KALITE P1-5, ilk dilim)

**Neden şimdi:** Yol haritası bitti; OYNANIS-KALITE P1 sırasında ilk açık madde yeni yakın
silahlar. 4 silahın ikisi yakın ve ikisi de "daha çok hasar" farkıyla ayrılıyordu; silah
seçimi bir karar değildi. Kalkanlı Zabıta ve blok yapan muhafızlar dövüşün en sinir bozucu
anlarıydı, havada takip (AIR_KNEE) ise neredeyse yalnız bitiriciden sonra açılıyordu.

**Oyuncu ne hissedecek:** Bölüm 4'te kalkanlıdan hemen önce yerde kırmızı saplı bir boru
anahtarı; alınca "BLOK DELER" yazar, kalkana vurunca kalkan iner ve "KALKAN DELİNDİ!".
Bölüm 3 pazarında bordo bir şemsiye: alınca "HAVAYA KALDIRIR"; her isabet düşmanı kaldırır,
zıplayıp dizle karşılamak cazip olur. Ağır-yavaş-az kullanım ↔ hafif-uzun-çok kullanım.

**Yapılanlar:**
- `WeaponConfig.guard_break` / `launch_speed` (varsayılan kapalı, eski kaynaklar aynı).
- `EnemyBase.apply_guard_break_hit` (blok duruşu + blok şansı yok sayılır),
  `ShieldGuard` geçersiz kılması (önden kalkanı indirir, tam hasar). `Redmount._deal_attack_hit`
  silah özelliğine göre çağırır; kuşanınca özellik yazısı.
- `tools/gen_pixel_weapons.py`: sopa sayfalarında sopa pikselleri renk maskesi + bağlı
  bileşen ile bulunur, sap ucu el pikseline yakınlıktan seçilir, sap→uç boyunca yeniden
  boyanır (anahtar: kırmızı sap + çelik baş + çene; şemsiye: siyah sap, bordo katlı kumaş,
  gümüş uç); savuruş izi bileşeni çene almaz. 24 px elle yerleştirilmiş ikonlar 2x.
- `PlayerSprite._register_bat_variants`: yeni sayfalar sopa bölgeleri/zamanlamasıyla eklenir.
- Hata düzeltmesi: `play_action("weapon_swing")` sayfası olmayınca "idle"a düşüp savuruşun
  hazırlık karelerini silahsız duruşla örtüyordu (sopa ve bıçakta da).
- Elle yerleşim: Bölüm 3 (x=760), Bölüm 4 (x=2620, ipucu metni güncellendi); dükkân:
  Bölüm 7 ANAHTAR (34 coin), Bölüm 14 ŞEMSİYE (26 coin); sandık ganimeti 4 silahtan biri.

**Sayılar (hipotez):** Anahtar 20 hasar / 0,24 sn hazırlık / 10 kullanım — sopadan (16/0,16/12)
ağır ve yavaş; kalkanı deldiği için kalabalıkta değil hedefli kullanılmalı. Şemsiye 10 hasar /
0,12 sn / 16 kullanım, menzil 104 px (sopa 74); kaldırma hızı 320 — aparkat 430, bitirici 260
arası: dize zaman bırakır ama tek başına aparkat kadar güçlü değil. Dükkân fiyatları sopa (22)
ile bıçak (30) çizgisinde.

**Testler:** `--import` hatasız; yeni `tests/new_melee_weapons.tscn` PASS (kaynak alanları,
pickup/ikon/dükkân/sandık, 8 yeni animasyon kare sayısı, kalkan delme, blok delme, kaldırma +
hava dizine açıklık, hazırlık karesi düzeltmesi); `tests/dtm_gaps.tscn` PASS;
`tests/level_stars.tscn` PASS; `tests/campaign_smoke.gd` çıkış 0; bot Bölüm 1, 3, 4, 13, 25
CLEARED (87,7 / 70,1 / 109,3 / 76,0 / 85,6 sn). 1280×720 ekran görüntüsünde yerdeki anahtar ikonu, anahtar
savuruşu, şemsiye duruşu kontrol edildi; telefonda görülmedi.

**Sonraki öneri:** Kostümler (P1-6) — ya da bu maddenin ikinci dilimi: fırlatılabilir
kaldırım taşı + pause cephaneliğine yeni silahlar (birikime yazıldı).

### 2026-10-23 (3) — Kitap geçiş sinematikleri (Yol haritası 10)

**Neden şimdi:** Yol haritasındaki son açık madde. Kitap 1 ve 2'nin son bölümleri
oyun içi sahneyle bitip doğrudan sonuç kartına düşüyordu; oyuncu bir kitabın
kapandığını, sıradakinin neden başladığını hissetmiyordu. DTM bölüm aralarını
çizgi roman kareleriyle bağlar — bu bir "nefes" ve ödül anıdır.

**Oyuncu ne hissedecek:** Bölüm 12 / 24 / 36'nın son konuşması biter, ekran kararır,
"KİTAP n SONU · ad" başlığının altında dört kare soldan sağa küçük bir sarsılmayla
yerine çakılır; her karenin altında krem kutuda tek cümle. Son karede sarı
"SIRADAKİ · KİTAP n+1 · ad" (finalde "SON · TEŞEKKÜRLER"). Sabırsız oyuncu J/dokunuşla
kareleri öne alır, ESC bütün şeridi atlar.

**Yapılanlar:**
- `tools/gen_comic_panels.py` → `assets/ui/comic/k{1,2,3}_{0..3}.png`: bölümün kendi
  atlasından kesit (96×56, kutu filtresi, 22 renk) + 48×48 piksel portreler (karşılıklı
  bakış için aynalı) + elle boyanmış defter, Kâtip'in notu ve simit; 1 px mürekkep + krem
  çerçeve. Tekrar eden ikili yakın planlar azaltıldı (matbaa genel planı, simit kapanışı).
- `scripts/ui/book_comic.gd` (`BookComic`, CanvasLayer 8): metinler sahnelerdeki son
  konuşmalarla aynı olayları özetler; `present/advance/is_active`.
- `main.gd`: `_on_goal_reached` içinde oyun içi bitişten sonra, yalnız `story_scenes`
  açıkken (menüden oyun) ve kitap sonu bölümde; `_ending_in_progress` dokunmatik
  düğmeleri gizler ve ESC'nin duraklatma menüsünü açmasını engeller.

**Sayılar (hipotez):** Kareler arası 1,1 sn (bir cümle okunur; tüm şerit ~4,5 sn,
izleyen oyuncuyu sıkmaz), çakılma 0,18 sn; son kareden sonra 0,5 sn kapanma kilidi
(basılı tutulan saldırı tuşu şeridi yutmasın). 3x ölçek: dört kare 1280'e 22 px
pay ile sığar, alt yazı 24 px piksel yazıyla en fazla 3 satır.

**Testler:** `--import` hatasız; yeni `tests/book_comic.tscn` PASS (yalnız 12/24/36,
12 kare dokusu 100×60, otomatik akış, girdiyle öne alma, erken basış kilidi, ESC
atlama); `tests/dtm_gaps.tscn` PASS; `tests/campaign_smoke.gd` çıkış 0; bot Bölüm 1 (81,3 sn), 12 (91,5 sn),
13 (77,5 sn), 24 (193,1 sn), 25 (81,6 sn) CLEARED (bot `story_scenes` kapalı
koştuğu için şerit yolunu değil, ortak bitiş akışını doğrular). 1280×720 ekran görüntüsünde üç şerit kontrol edildi (Kitap 2'nin son alt
yazısı 4 satıra taşıyordu, kısaltıldı; kutular eşit boya getirildi). Telefonda görülmedi.

**Sonraki öneri:** Yol haritası tamamlandı. Sıradaki tur OYNANIS-KALITE P1:
yeni yakın silahlar.

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
