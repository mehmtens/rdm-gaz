# REDMOUNT — Dan the Man seviyesi yol haritası (otomatik geliştirme sırası)

Her otomatik tur **tek bir maddeyi** bitirir: uygula → piksel art kontrolü (ekran
görüntüsü) → 36 bölüm bot regresyonu → commit + push → maddeyi `[x]` yap.
Kurallar: her şey piksel art, şablon parkur yok, Türkçe metin, bölüm tasarımı elle.

## Sıra

- [x] 1. **Telsiz konuşmaları** — oynanışı durdurmayan alt panel (piksel portre +
      yazı): Gazelle/Komiser/Nüzhet bölüm içinde araya girer (Dan the Man'in
      oyun içi sohbeti). Her bölüme 2–3 hikâye satırı.
- [x] 2. **Bölüm açılış kartı** — DtM tarzı: bölüm numarası + adı + mekân, piksel
      çerçeveli büyük başlık, 2 sn, oyun akarken söner.
- [x] 3. **Film ruloları** — 3 gizli alanın ödülü "film rulosu" olur (Gazelle'in
      kanıt fotoğrafları); menüde "Kanıt Arşivi" galerisi (piksel art kareler).
- [x] 4. **Kovalama set-piece'leri** — arkadan sokağı süpüren minibüs (`_chase`):
      Bölüm 13 Balat yokuşu, Bölüm 29 Kuzguncuk (polis). Durma, koş; balkonlar kaçış.
- [x] 5. **Bombacı & kalkanlı animasyonları** — atış/kalkan darbesi kareleri,
      bombacıya özgü piksel kıyafet (yeşil yelek, bomba kemeri).
- [x] 6. **Boss desenleri** — Karahanlı, Ana Vana Muhafızı, Yayın Şefi'ne faz
      geçişli piksel uyarılı saldırılar + can çubuğu üstünde isim kartı.
- [x] 7. **Çevresel tehlike çeşitliliği** — düşen saksılar, kayan tabelalar,
      elektrikli tel (piksel art), bölüm temasına göre.
- [x] 8. **Dokunmatik kontrol cilası** — piksel art düğmeler, kayma tekmesi
      kısayolu, titreşim. *(23 Ekim: `tools/gen_pixel_touch.py` → `touch_*.png`
      piksel daire düğmeler + ok/duraklat ikonları, piksel yazı tipi; `KAY` düğmesi
      (`slide` eylemi); dokunma tıkı + duraklatma menüsünde `TİTREŞİM` ayarı.
      Kanıt: `tests/touch_polish.tscn` PASS, smoke PASS, bot 1/13/25 CLEARED.)*
- [x] 9. **Bölüm sonu yıldızları** — S/A/B/C yerine 3 yıldız (hız, hasarsızlık,
      gizli alan) + menüde toplam yıldız. *(23 Ekim: `tools/gen_pixel_stars.py` →
      `yildiz_{dolu,bos}[_kucuk].png`; sonuç kartında HIZ/HASARSIZ/GİZLİ ALAN yıldızları
      sırayla çakılır; `Save.stars` bit maskesi koşular arası birleşir, %100 = 3 yıldız;
      bölüm kartlarında 3 küçük yıldız, BÖLÜM SEÇ başlığında toplam ★ x/108.
      Kanıt: `tests/level_stars.tscn` PASS, dtm_gaps PASS, smoke PASS, bot 1/13/25 CLEARED.)*
- [x] 10. **Kitap geçiş sinematikleri** — kitap sonlarında piksel çizgi roman
      panelleri (3–4 kare). *(23 Ekim: `tools/gen_comic_panels.py` → `assets/ui/comic/kK_P.png`
      (100×60, 3x NEAREST): bölüm atlası kesiti + piksel portreler + elle boyanmış defter /
      not / simit; `BookComic` Bölüm 12, 24 ve 36 bitince sonuç kartından önce 4 kareyi
      soldan sağa çakar, alt yazı + "SIRADAKİ · KİTAP n" satırı. Kanıt: `tests/book_comic.tscn`
      PASS, dtm_gaps PASS, smoke PASS, bot 1/12/13/24/25 CLEARED.)*
