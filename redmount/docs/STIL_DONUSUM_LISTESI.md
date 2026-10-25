# Stil dönüşüm listesi — ChatGPT temel sanatına uyum

**Kural (kullanıcı, 25 Ekim 2026):** Oyunun görsel temelini ChatGPT üretti
(`assets/backgrounds/*_atlas.png`, `assets/environment/book03_final_*.png`,
`level01_turkish_platform_kit_v1.png`, `mahalle/*_v2.png`, bayraklar). Claude'un ve
otomasyonun ürettiği her görsel bu tarzda yeniden çizilecek. ChatGPT görselinden
kesip yapıştırmak yok; aynı tarzda çizmek var. Ölçülmüş kurallar ve örnek üretici:
`tools/gen_gpt_style_props.py`.

Her madde: yeniden çiz → oyun içi ekran görüntüsünde ChatGPT arka planı yanında bak
→ "sahneye ait" değilse commit etme → `[x]` + commit hash'i.

Öncelik: oyuncunun en çok gördüğü yerden başla.

## 1. Oyun alanı propları — `assets/environment/pixel/` (Claude çizimi, 8–96 px)

- [x] varil, patlayici, parmaklik, parmaklik_tepe (e785cec4)
- [x] tup (gaz tüpü) — BreakableProp, birçok bölümde (ba989e3f)
- [x] fener, fener_hale, asma_lamba — her bölümde ışık kaynağı (2a8bbb7b)
- [x] on_kolon, on_kolon_bas, on_kolon_kaide, on_sarmasik, zincir, halat — ön plan (826b52d3)
- [x] kum_torbasi, raf, kaset, cerceve, tas_blok — siper/dekor (c0d3a221)
- [x] diken, alev, alev_izgara, kivilcim, kablo, bomba, bomba_ikaz, patlama — tehlike/efekt (67e753bc)
- [ ] han_kapisi, ic_duvar, ic_pencere, fabrika_pencere, tavan, tugla, sivali_tugla, hatil — iç mekân
- [ ] pres, pres_kol, ray, su_govde, su_yuzey, anten, kule_ayak, kule_kulube, ahsap_kat — set-piece
- [ ] kalkan, kalkan_kirik — Kalkanlı Zabıta
- [ ] golge — temas gölgesi (yalnız ton kontrolü)
- [ ] sancak — ChatGPT bayrağı olabilir: kontrol et, ChatGPT ise DOKUNMA

## 2. Kodla çizilen görseller (draw_rect/draw_circle/draw_colored_polygon — yasak)

PNG piksel art'a taşınacak. Satır sayıları 25 Ekim taramasından.

- [ ] `scripts/systems/level01_long_route.gd` (77) ve `level01_dressing.gd` (24)
- [ ] `scripts/pickups/pickup_icon.gd` (39) — pickup ikonları
- [ ] `scripts/systems/breakable_prop.gd` (28) — saksı/tüp/varil yedek çizimleri, kıymık
- [ ] `scripts/systems/one_way_platform.gd` (13), `moving_platform.gd` (9)
- [ ] `scripts/systems/level_shop.gd` (9)
- [ ] `scripts/characters/char_rig.gd` (42), `weapon_visual.gd` (5) — gerçekten görsel mi, yoksa hata ayıklama mı kontrol et
- [ ] diğerleri (1–3 satır): dtm_level, story_blockout, backdrop, main_menu, ui_style, level02/04/11_redesign, fx

## 3. Silah ve karakter ekleri (otomasyonun 23–25 Ekim üretimi)

- [ ] Boru anahtarı: `anim/redmount/anahtar_*`, `pickups/placeholder_anahtar`
- [ ] Şemsiye: `anim/redmount/semsiye_*`, `pickups/placeholder_semsiye`
- [ ] Kaldırım taşı: `anim/redmount/tas_*`, `pickups/placeholder_tas`, `fx/tas_mermi`
- [ ] Kostüm başlıkları: `anim/costume_acc/{hamal,kahveci,kizil,vapurcu,head_front}`
- [ ] Kostüm palet takası: ChatGPT karakter karelerinin üstünde renkler tarza uyuyor mu (`tools/gen_costume_mask.py`)
- [ ] Sopa/bıçak/tabanca/tüfek elde görünümü (`tools/gen_pixel_weapons.py`, `gen_weapon_mask.py`) — karakter karesiyle aynı yoğunlukta mı
- Not: Redmount'un gövde kareleri temel sanattır; yalnız Claude'un eklediği silah/aksesuar katmanları dönüştürülür.

## 4. Pickup ikonları — `assets/pickups/placeholder_*` (48×48)

- [ ] ammo, armor, bat, coin, dmg2x, health, invis, knife, pistol, shield, speed

## 5. Arayüz — `assets/ui/pixel/` (Claude çizimi)

ChatGPT tarzına yaklaştır: aynı mor gölge / altın ışık rampası, doku, koyu mor kontur.

- [ ] panel, panel_hud, kart, kart_kilitli, sekme, sekme_secili, balon* — çerçeveler
- [ ] button_* , touch_* — düğmeler (mobilde sürekli ekranda; yüksek öncelik)
- [ ] coin, kilit, film, pip_*, yildiz_*, ikon_*, odak, tutamac, cubuk_* — ikonlar
- [ ] logo, logo_alt
- [ ] portre_* — ChatGPT karakter portresinden mi? kontrol et; Claude çizimiyse dönüştür

## 6. Kontrol edilecek (ChatGPT kaynaklı olabilir — ChatGPT ise dokunma)

- [ ] `environment/kit/*` küçük parçalar, `environment/mahalle/{plant_small,tree_pot,vase_*,wall_*,portrait}`
- [ ] `ui/comic/*` (kitap şeridi, `tools/gen_comic_panels.py`) — arka plan kesitleri + Claude katmanları; Claude katmanları tarza uymalı
- [ ] `ui/photos/*` (Kanıt Arşivi, `tools/gen_photos.py`) — arka plan kesitleri; çerçeve/efekt katmanı kontrol
