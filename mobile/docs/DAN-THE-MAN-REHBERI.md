# Dan the Man → REDMOUNT: Oynanış Uyarlama Rehberi

Bu belge, oyun içi değişiklikler yapılırken rehber olarak kullanılmak üzere hazırlandı.
Amacı Dan the Man'i kopyalamak değil, **onu iyi yapan oynanış ilkelerini** ayırıp
REDMOUNT'un kendi dünyasına (mahalle, büfe, dolmuş, simit, Karahanlı, Gazelle) uyarlamaktır.

> **Kaynak notu:** İlk sürüm web arama özetlerinden (fan wiki, incelemeler) yazıldı.
> İkinci turda YouTube oynanış videoları **kare kare incelendi** (Bölüm 11).
> Video dosyası sunucusu (`googlevideo.com`) hâlâ engelli olduğu için videolar
> YouTube'un önizleme karelerinden (storyboard; 5 dk'lık videoda ~4 sn'de bir,
> fragmanda ~1 sn'de bir kare) izlendi. Yerleşim, HUD, akış ve ekranlar net okunuyor;
> kare kare vuruş zamanlaması ise bu çözünürlükte ölçülemiyor.
> "✔" kaynakta/videoda doğrulandı, "◇" hâlâ doğrulanmadı demektir.

---

## 1. Dan the Man'i Dan the Man yapan şey: 8 ilke

| # | İlke | Neden önemli |
|---|---|---|
| 1 | **Dövüş = kombo + tutma + havada tekme** üçlüsü. Tuşa abanmak cezalandırılır. ✔ kaynaklı | Basit iki tuşla derinlik. Oyuncu "hangi hareket?" diye düşünür. |
| 2 | **Fiziksel ağırlık**: vuruşta duraklama, sarsıntı, beyaz parlama, savrulan düşmanın diğerlerine çarpması. | Her vuruş "hissedilir". Ucuz ama en etkili cila budur. |
| 3 | **Kilitli dövüş odaları**: ekran kilitlenir, düşmanlar dalga dalga iki yandan gelir. ✔ kaynaklı (bonus bölümler 3 tur) | Platform ile dövüş arasında net ritim. |
| 4 | **Kısa bölümler, sık kontrol noktası, gizli alanlar** ✔ kaynaklı (gizli alanlar ödüllendirilir) | Mobilde 3–5 dakikalık oturum. |
| 5 | **Sınırlı silah**: düşmandan/sandıktan düşer, mermisi/dayanıklılığı biter. | Silah "güç patlaması" olur, dövüşü bitirmez. |
| 6 | **Coin → beceri yükseltmesi**. Hareketler mağazadan güçlendirilir. ✔ kaynaklı (ör. Temel Aparkat 500, Nihai Aparkat 5000 coin) | Uzun vadeli hedef ve tekrar oynama. |
| 7 | **Karakter ve mizah**: kısa ara sahneler, kişilikli bosslar (ör. GATEKEEPER, ROBORIOT ✔ kaynaklı). | Hikâye motivasyonu, akılda kalıcılık. |
| 8 | **Mobil kontrol**: solda ◀ ▶, sağda ZIPLA / VUR ve bağlamsal tuş. | Tek el başparmak düzeni, ekranı kapatmaz. |

**İncelemelerden alınacak dersler (Dan the Man'in eleştirildiği yerler):**

- "Hasar alınca geri savrulma aşırı ve dokunulmazlık karesi yok" (SuperPhillip Central).
  → REDMOUNT'ta **1,0 sn dokunulmazlık** ve ölçülü geri itme korunmalı (`player.gd` `take_hit`).
- "Kontroller ara sıra tepkisiz" (Pocket Gamer App Army).
  → Bizdeki **giriş tamponu (0,13 sn)**, **coyote süresi (0,1 sn)** ve **saldırı tamponu (0,2 sn)** asla kaldırılmamalı.

---

## 2. Hareket seti: Dan the Man → REDMOUNT

| Dan the Man | Nasıl çalışır | REDMOUNT uyarlaması | Durum |
|---|---|---|---|
| **Combo Attack** ✔ | VUR'a art arda bas. Yükseltmeyle uzar. | 4 vuruş: `fight → combo_a → punch → knee`, son vuruş yere serer. | Vardı |
| **Power Attack** ✔ video | Oyun içi açıklama: "VUR'u basılı tutup doldur, bir YÖN'e basarken bırak". Bütün saldırıları bloklayan düşmanların savunmasını deler. | **GÜÇLÜ YUMRUK**: VUR 0,4 sn basılı → turuncu dolum. Bırakınca dolum oranında hasar (24→48) ve itme. Savrulan düşman yoldakileri devirir. | **Bu sürümde eklendi** |
| **Grab n' Throw** ✔ | Yakındaki düşmana doğru yönü tut → tutar. | **TUT**: düşmana doğru yürü (105 px, 0,08 sn). VUR ile **diz** (3. diz öne savurur). **◀ geri + VUR** ile omuzdan arkaya **fırlat**. 1,3 sn sonra düşman kurtulur. | **Bu sürümde eklendi** |
| **Uppercut** ✔ | Tuttuktan sonra ZIPLA. | **APARKAT**: tutarken ZIPLA. Düşman havaya dikilir, Redmount yükselir. Hemen havada VUR ile hava kombosu yapılır. | **Bu sürümde eklendi** |
| **Down Kick** ✔ | Havada saldırı, çapraz aşağı tekme. Yükseltmeyle iki kez. | Uçan tekme vardı. Artık **isabet edince sekip 2 kez daha** atılabilir. | **Bu sürümde eklendi** |
| **High Kick** ◇ | Havada yukarı tekme (girdisi doğrulanmadı). | Yükselirken VUR = yukarı tekme (havadaki düşmanı karşılama). | Yapılacak (P1) |
| Silah toplama ✔ video | Düşman silahını düşürür, alınınca "CHANGE WEAPON" yazısı çıkar. Silahlar **ayrı ATEŞ düğmesiyle** kullanılır, yumruk serbest kalır. | Tüfekli muhafız → **tüfek** düşürür. Redmount'ın `rifle_*` şeritleri hazır, eşya ikonu eksik. | Yapılacak (P1) |
| Özel saldırı ◇ | Karaktere özgü. | **ÖZEL bar**: vuruşlarla dolar, yarısıyla uçan diz. Dan the Man'de birebir karşılığı olmayan, bize ait bir hareket. | Vardı (özgün) |

### Hareketlerin birbirine bağlanması

Dan the Man'in derinliği tek tek hareketlerden değil, **zincirlerden** gelir. Hedeflenen akış:

```
yürü → TUT → diz, diz → ZIPLA (aparkat) → havada VUR (dalış tekmesi) → sek → VUR (2. tekme)
kalabalık → TUT → ◀+VUR (fırlat) → uçan gövde 2 düşmanı devirir → yerdekilere GÜÇLÜ YUMRUK
```

### Kod haritası (bu sürüm)

| Mekanik | Dosya / fonksiyon |
|---|---|
| Tutma tespiti | `scripts/player.gd` `_grab_candidate`, `_start_grab`, `GRAB_RANGE`, `GRAB_PUSH` |
| Diz / fırlatma / aparkat | `player.gd` `_grab_tick`, `_knee_hit`, `_throw`, `_uppercut`, `_grab_release_forward` |
| Güçlü yumruk | `player.gd` `_start_charge`, `_charge_tick`, `_release_charge`, `ATTACKS["power"]` |
| Dalış tekmesi zinciri | `player.gd` `_resolve_hits` (`tag == "air"`), `AIR_CHAIN` |
| Tutulma (düşman) | `scripts/enemy.gd` `can_grab`, `grab`, `hold_at`, `grab_hit`, `escape` |
| Fırlatılan düşman devirir | `enemy.gd` `launch`, `_bowl`. `take_hit` içinde `kb >= 500` sert itme sayılır. |
| Öğretici ipuçları | `scripts/levels/level_01.gd` (`hint(...)` satırları) |

> **Animasyon notu:** Yeni hareketler şimdilik mevcut şeritlerden kurulu
> (`player.gd` `ANIMS` sonundaki satırlar). Gerçek hissi verecek özel şeritler
> için çizim listesi Bölüm 8'de.

---

## 3. Düşman tasarımı: her düşman bir hareketi "öğretmeli"

Dan the Man'de düşmanlar görünüşten çok **davranışla** ayrışır: coplu muhafızlar,
kayarak saldıran hızlı coplu muhafız (✔ kaynaklı), uçup dalış yapan düşmanlar (✔ kaynaklı),
bosslar (✔ kaynaklı). Kalkanlı ve farklı silahlı düşman çeşitleri ◇ videoda doğrulanmalı.

REDMOUNT kuralı: **Her yeni düşman, oyuncuyu bir hareketi kullanmaya zorlamalı.**

| REDMOUNT düşmanı | Sanat | Davranış | Zorladığı hareket |
|---|---|---|---|
| Sokak Eşkıyası | hazır | Yavaş, grup halinde | Temel kombo, fırlatma ile kalabalık temizleme |
| Bıçaklı Ajan | hazır | Kırmızı `!` → atılma | Okuma + zamanlı TUT (atılmadan önce yakala) |
| Tüfekli Muhafız | hazır | Lazerle nişan, geri çekilir | Mesafeyi kapat, **nişan alırken TUT** (AIM durumunda tutulabilir) |
| Zırhlı Vurucu | **hazır** (`armored_bruiser`: block, guard_break) | Önden gelen kombo bloklanır | **Güçlü yumruk** ya da **fırlatılan düşman** blok kırar |
| Çevik Suikastçı | **hazır** (`agile_assassin`: leap, evade) | Duvardan sıçrar, havadan dalar | **Aparkat** ile havada karşıla, **dalış tekmesi** zinciri |
| Elit Muhafız | **hazır** (`elite_guard`: block, attack2) | Blok + yakın kombo + ateş | Hepsinin karışımı (Bölüm 4–5) |
| Ağır Zırhlı (mini-boss) | **hazır** (`mini_boss`: special) | Çekiç savurma, yere vurma | Zıplama zamanlaması + zırh kırılınca güçlü yumruk |
| Karahanlı (boss) | hazır (`karahanli`) | Sakin, ölçülü, karşı saldırı | Bütün öğrenilenlerin sınavı |

**Kalabalık kuralı (var, korunmalı):** Aynı anda en fazla 2 düşman saldırır
(`level.gd` `take_token`). Dan the Man hissinin temeli budur. Kalabalık tehditkâr görünür ama adil kalır.

---

## 4. Bölüm ritmi

Tipik Dan the Man bölümü ◇: koridor/platform → kilitli oda → platform → gizli alan →
kontrol noktası → final odası veya boss. Bölüm 1 (`level_01.gd`) bu ritme zaten uyuyor:

```
Köşe Çay (öğretici) → Yol Çalışması (çukur, iskele, duvar zıplaması) → Kontrol Büfesi (arena 3 dalga)
→ Minibüs Parkı (tabanca, tüfekli, gizli niş) → Kuzey Hanı (final arenası) → bitiş
```

Eklenecek Dan the Man unsurları, bizim kılıkta:

- **Bölüm içi dükkân** (✔ video: bölüm içinde "Ye Olde Shoppe" binası)
  → **Büfe**: arena öncesi simit, zırh ya da sopa satın alma. `prop("bufe", ...)` zaten sahnede.
- **Bonus arena bölümleri** (3 tur, aralarda alışveriş ✔ kaynaklı) → **Kahvehane Arka Odası**:
  dalga dalga hayatta kalma, turlar arası büfe. Süre, düşman yendikçe ve nesne kırdıkça uzar.
- **Gizli alan ipucu**: çatlak tuğla, coin yayı, farklı renk. Bölüm 1'deki tuğla niş ve bulut yolu iyi örnekler.

---

## 5. Hissiyat: mevcut değerler ve hedefler

| Değer | Şu an | Not |
|---|---|---|
| Hafif vuruş duraklaması | 40 ms | Dan the Man'e çok yakın, koru |
| Ağır vuruş / yere seren | 70 ms | Koru |
| Güçlü yumruk | 110 ms + sarsıntı 14 | Yeni. Fazla gelirse 90 ms'ye düşür |
| Aparkat | 80 ms + sarsıntı 10 | Yeni |
| Fırlatılan gövde çarpması | 50 ms + sarsıntı 7 | Yeni. Zincirleme yok (çarpılan düşman `kb 420` ile savrulur, kimseyi devirmez) |
| Oyuncu dokunulmazlığı | 1,0 sn | Dan the Man eleştirisinden ders, kaldırma |
| Coin mıknatısı | 190 px | Dan the Man'deki gibi patlayıp toplanır |
| Aynı anda saldıran | 2 | Koru |

**Ayar sırası:** Önce `GRAB_PUSH` (yanlışlıkla tutma oluyor mu?), sonra `CHARGE_START`
(kombo yaparken istemeden doluyor mu?), en son hasar sayıları. Telefonda test et; masaüstü fare testi yanıltır.

---

## 6. Mobil kontrol

Dan the Man düzeni ile bizimki aynı mantıkta (`touch_controls.gd`). Eklenmesi önerilenler:

1. **VUR basılı tutma göstergesi**: düğme etrafında dolan turuncu halka (`CHARGE_FULL` süresinde).
2. **Bağlamsal ipucu**: düşman tutulduğunda VUR/ZIPLA düğmelerinin üstünde küçük "DİZ / APARKAT" etiketi.
3. Düğme boyutu ve opaklık ayarı (Ayarlar menüsü). Farklı el boyları için.

---

## 7. İlerleme ve ekonomi

Dan the Man'de hareketler coin ile yükseltilir (ör. Aparkat: Temel 500 → Nihai 5000 coin ✔ kaynaklı).
REDMOUNT'ta `Game.wallet` kalıcı cüzdan zaten kaydediliyor. Mağaza yok.

Önerilen **"Usta"** (mahalle antrenörü) yükseltmeleri. `level_01.gd` sayımına göre Bölüm 1'de
haritaya yerleşik ~60 coin, düşmanlardan ~84, kırılabilirlerden ~22 coin çıkıyor: tam bir
geçişte en fazla **~165 coin**. Fiyatlar buna göre:

| Yükseltme | Etki | Fiyat |
|---|---|---|
| Kombo II | 5. vuruş: dönen tekme | 300 |
| Güçlü Yumruk II | Dolum 0,6 → 0,4 sn | 400 |
| Dalış Tekmesi II | `AIR_CHAIN` 2 → 3 | 400 |
| Aparkat II | Aparkat sonrası otomatik ikinci vuruş | 800 |
| Demir Bilek | Tutma süresi 1,3 → 2 sn, diz hasarı +3 | 600 |

Kural (`PROJE-ANA-PLANI.md` §20 ile uyumlu): Yükseltme oyunu **kolaylaştırır**, ama yükseltmesiz de bitirilebilir olmalı.

---

## 8. Yol haritası

**P0, bu sürümde yapıldı:** tutma, diz, fırlatma, aparkat, güçlü yumruk, dalış tekmesi
zinciri, fırlatılan düşmanın diğerlerini devirmesi, Bölüm 1 öğretici ipuçları.

**P1, hemen sonra:**
1. Yeni hareketler için özel animasyon şeritleri (200×240, ayak çizgisi y=234):

   | Şerit | Kare | İçerik |
   |---|---|---|
   | `grab_hold` | 2–3 | Yaka paça tutuş, hafif sallanma |
   | `grab_knee` | 4 | Tutarken diz |
   | `throw` | 5 | Omuzdan arkaya savurma |
   | `uppercut` | 5 | Çömel, yükselen yumruk |
   | `charge` | 3 (döngü) | Yumruk geride, gövde gergin |
   | `power_punch` | 6 | Uzun hazırlık, tek sert temas |
   | düşman `grabbed` / `thrown` | 2 / 4 | Her düşman için |
2. **Zırhlı Vurucu**: blok + guard-break (sanat hazır). Güçlü yumruk ve fırlatma bloğu kırar.
3. Yukarı tekme (High Kick) ve arena kenarından seken fırlatılmış düşman.
4. Tüfekli muhafızdan tüfek düşmesi (eşya ikonu `tools/gen_icons.py` ile eklenir).

**P2:** Bölüm 2 (`level02_armed_checkpoint` arka planı hazır), Büfe dükkânı, Usta yükseltmeleri.

**P3:** Ağır Zırhlı mini-boss, Karahanlı boss savaşı, Kahvehane hayatta kalma modu, Android dışa aktarma.

---

## 9. Videodan doğrulama listesi

Oynanış videosu izlerken (tercihen kare kare, 0,25× hızda) aşağıdakileri not edip bu belgeye ekleyin:

- [ ] Kombo kaç vuruş, son vuruşta düşman ne kadar uzağa uçuyor? (ekran genişliğinin yüzde kaçı)
- [ ] Power Attack: basılı tutma ne kadar sürüyor, dolum nasıl gösteriliyor?
- [ ] Tutma nasıl tetikleniyor: yürüyerek mi, yön + saldırı ile mi? Tutulan düşman kaç sn sonra kurtuluyor?
- [ ] Fırlatılan düşman diğerlerine çarpınca onları deviriyor mu, zincirleme oluyor mu?
- [ ] Down Kick açısı (kaç derece), isabette ne kadar sekiyor?
- [ ] Bir kilitli odada kaç dalga, dalga başına kaç düşman, aynı anda kaçı saldırıyor?
- [ ] Kontrol noktaları arası süre (saniye)
- [ ] Gizli alan girişleri nasıl ima ediliyor (renk, çatlak, coin izi)?
- [ ] Düşman ölünce kaç coin, yemek ne sıklıkla düşüyor?
- [ ] Boss evre geçişleri nasıl duyuruluyor?

**Videoları birlikte incelemek için:** Ortamın ağ ayarlarında `youtube.com`, `googlevideo.com`
ve `i.ytimg.com` izinli alanlara eklenirse videolardan kare çıkarıp (yt-dlp + ffmpeg)
görüntü olarak inceleyebilir, bu tabloyu ölçümlerle doldurabilirim. Alternatif olarak
ekran görüntüleri veya kısa klipler depoya (`mobile/docs/referans/`) eklenebilir.

---

## 10. Özgünlük kuralları

- **Kopyalanmaz:** karakterler, isimler, diyaloglar, müzik, sanat, UI'nin birebir düzeni, bölüm haritaları.
- **Serbest:** tür gelenekleri (kombo, tutma, kilitli oda, coin, kontrol noktası). Bunlar Double Dragon,
  Final Fight ve Streets of Rage'den beri ortak dildir.
- **REDMOUNT kimliği:** İstanbul mahallesi, büfe, dolmuş, simit (can), Karahanlı'nın soğukkanlı otoritesi,
  Gazelle'i kurtarma motivasyonu, ÖZEL bar ve uçan diz.
- **Yerel tat önerisi:** Hareket adlarında güreş terimleri kullanılabilir. Örneğin fırlatma için "KÜNDE",
  tutma için "PAÇA". Bu, mekaniği Dan the Man'den ayırıp bize ait kılar.

---

## 11. Videolardan gözlemler (kare kare)

İncelenen videolar:

| Video | İçerik |
|---|---|
| [Dan the Man 1-1 with secret areas](https://www.youtube.com/watch?v=degvHzH7xaE) | 8-1-1 bölümünün tamamı, 5 gizli alan, sonuç tablosu |
| [Prologue 1–3 walkthrough](https://www.youtube.com/watch?v=n4mcz0_FMCM) | Öğretici bölümler, kayıt noktası, ilk ekranlar |
| [Launch Trailer](https://www.youtube.com/watch?v=--mbvEphvXA) | Beceri ekranı açıklamaları, hayatta kalma modu, ödüller |
| [All Bosses (No Damage)](https://www.youtube.com/watch?v=HpYvGvxbJNY) | Boss savaşları |
| [Mobile Gameplay (HD)](https://www.youtube.com/watch?v=FD4JPlmlQ-Q) | Net kontrol düzeni ve HUD |

### 11.1 Kontrol düzeni ✔
- Sol alt: yalnızca **◀ ▶** (çerçevesiz beyaz oklar, küçük). Aşağı tuşu yok.
- Sağ alt: **yumruk** (VUR) ve **yukarı ok** (ZIPLA). Bunların üstünde **nişangâh** (ATEŞ)
  ve **döngü oku** (silah değiştir).
- Düğmeler yarı saydam ve küçük; oyun alanını çok az kapatıyor.
- **Uygulandı:** ayrı ATEŞ düğmesi (yalnızca tabanca elindeyken görünür). VUR tabanca elindeyken de yumruk atar.

### 11.2 HUD ✔
- Sol üst: yuvarlak **portre** + yeşil can barı. Altında küçük kırmızı **iksir ikonu**
  (taşınan iyileştirme), onun altında **silah kutusu** (döngü ikonu + silah + mermi sayısı).
- Sağ üst: büyük **coin ikonu + 6 haneli sayaç**, duraklat.
- Boss savaşında üst ortada **boss portreli kırmızı can barı**.
- Kombo: sağda "**7 HITS! · Max 11 · BONUS +100**". Vuruş sayısı, en iyi seri ve bonus puan birlikte gösteriliyor.
- Düşmandan "**$1 / $2 / $5**" para ikonları fırlıyor, havada asılı kalıp toplanıyor.

### 11.3 Bölüm akışı ✔
- 8-1-1 yaklaşık **4 dakika**, **43 düşman**, **5 gizli alan**, ~23 kırılabilir nesne.
  Prolog 1 ise yalnızca ~2:20 ve 5 düşman: öğretici bölümler çok kısa.
- Kilitli dövüşler dev turuncu piksel "**FIGHT!**" afişiyle başlıyor, bitince el işaretli "**GO!**" çıkıyor.
- **Gizli alan**: mor büyük "**SECRET AREA!**" afişi. Gizli alanlar dikey şelale bacaları,
  ağaç içleri ve duvar arkaları; içlerinde coin yayları ve fosil gibi süsler var.
- **Kayıt noktası**: disket simgeli tabela. İlk seferinde açıklama penceresi açılıyor,
  sonra küçük "PROGRESS SAVED" yazısı çıkıyor.
- **Öğretim**: ekran yazısı yerine dünyaya dikilmiş **tahta tabelalarda piktogram**
  (düğme ikonu + hareket çizimi) ve önemli yerlerde **işaret eden el** animasyonu.
- Ara sahneler konuşmasız: karakterlerin üstünde **ikonlu konuşma balonları** ("?", "!!", ikon).

### 11.4 Bölüm sonu ✔
- Siyah arcade ekranı: "**STAGE 8-1-1 COMPLETED!**". Satırlar sırayla sayarak gelir:
  **TIME** (geçen/hedef), **ENEMIES** (31/43), **DAMAGE** (alınan), **SECRET AREAS** (5/5),
  **SMASHED OBJECTS** (x/y), **TOTAL**. Her satırın yanında kırmızı/yeşil değerlendirme şeridi var.
- Ardından **ödül sandığı** ("YOU GOT 1000 GOLD", kozmetik şapka vb.).
- **Uygulandı:** sonuç ekranı aynı mantıkta puan tablosuna çevrildi
  (`level.gd` `score_rows`, `par_time`; `hud.gd` `show_results`). Alınan hasar ve kırılan nesne artık sayılıyor.

### 11.5 İlerleme ✔
- Karakter ekranında 6 hareket ikonu var, her birinde 3 seviye çubuğu. Yükseltme ~5000 coin.
- Hareket açıklamaları oyunda aynen şöyle: Uppercut = "düşmanı TUT, sonra ZIPLA";
  Power Attack = "VUR'u basılı tutup doldur, bir YÖN'e basarken bırak".

### 11.6 Bosslar ✔
- Dev mekanik/araç bosslar: yürüyen robot, koçbaşlı (kafatası uçlu kütük) savaş arabasıyla
  köprüde hücum eden şövalye, çatıda **çok parçalı yüz-makine** (gözler/ağız ayrı zayıf noktalar, altta yangın).
- Boss savaşına sık sık **ara düşmanlar** karışıyor. Girişte boss'a yakın plan tanıtım var.
- REDMOUNT karşılığı: Ağır Zırhlı mini-boss'a **zırh parçaları** (kırıldıkça kısa savunmasızlık),
  Karahanlı'ya **evreli** savaş + adamlarını çağırma.

### 11.7 Kamera ve ölçek ◇ (karar gerekiyor)
- Dan the Man'de karakter ekran yüksekliğinin **~%10–12'si**. Bizde ~%20 (`ZOOM 0.6`, 240 px şerit).
  Daha geniş görüş platform ve dövüşü okunur kılıyor. Ama bizim karakter çizimleri daha detaylı.
  **Öneri:** `ZOOM` 0,6 → 0,5'i telefonda denemek. Bölüm kurgusunu etkilediği için oynanarak karar verilmeli.

### 11.8 Bu gözlemlerden çıkan yeni yapılacaklar
1. Kombo sayacına "en iyi seri" ve bonus puan ekle (11.2).
2. Simidi **taşınabilir** iyileştirme yap, HUD'da sayısı görünsün; düşmandan para ikonları (11.2).
3. İpucu yazılarını piktogramlı tahta tabelalara çevir (çizim gerekiyor) (11.3).
4. Kayıt noktasında "İLERLEME KAYDEDİLDİ" yazısı (11.3).
5. Bölüm 1'e 3 gizli alan daha ekle (8-1-1'de 5 var, bizde 2) (11.3).
6. Bölüm sonu ödül sandığı + kozmetik (11.4).
7. Portreli boss can barı — mini-boss ile birlikte (11.6).
