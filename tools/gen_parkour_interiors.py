"""İç mekân tablosu üretici.

Kullanım:
  cd redmount
  REDMOUNT_NO_PARKOUR=1 SWEEP_LVLS=0,1,...,35 SWEEP_OUT=/tmp/cls \
    godot --path . res://tests/capture_interiors.tscn
  python3 ../tools/gen_parkour_interiors.py /tmp/cls

Kitap 1 (MANUAL) ve Kitap 2-3 (EXTERIOR) görüntülere bakılarak elle etiketlidir;
otomatik "üst bantta gökyüzü var mı" ölçütü yalnız listelenmeyen bölümlere uygulanır.
Yeni bölüm eklenince görüntüler üretilip etiketler buradan güncellenir.
"""
import glob,os,re,sys,colorsys
from PIL import Image, ImageFilter
STEP=1500
def feat(f):
    im=Image.open(f).convert('RGB')
    top=im.crop((75,0,320,45))
    ed=top.convert('L').filter(ImageFilter.FIND_EDGES)
    px=list(top.get_flattened_data()) if hasattr(top,'get_flattened_data') else list(top.getdata())
    eg=list(ed.get_flattened_data()) if hasattr(ed,'get_flattened_data') else list(ed.getdata())
    sky=0
    for (r,g,b),e in zip(px,eg):
        h,l,s=colorsys.rgb_to_hls(r/255,g/255,b/255)
        if l>0.35 and s>0.2 and e<40: sky+=1
    return sky/len(px)
levels={}
for f in sorted(glob.glob(os.path.join(sys.argv[1], 'c*_*.png'))):
    m=re.match(r'c(\d+)_(\d+)\.png',os.path.basename(f))
    lv=int(m.group(1))-1; x=int(m.group(2))
    levels.setdefault(lv,[]).append((x,feat(f)))
# Kitap 1 gece/alacakaranlık göğü koyu olduğu için ölçüt orada güvenilmez;
# bu bölümler ekran görüntülerine bakılarak elle etiketlendi.
# True = tamamı iç mekân / sanayi içi, False = tamamı dış mekân.
MANUAL = {
    0: False,   # Kayıp İz · Mahalle — sokak ve çatılar
    1: False,   # Arka Sokak İzi — yokuşlar, çarşı sokakları
    2: False,   # Gece Pazarı Baskını — açık pazar tezgâhları
    3: False,   # Silahlı Kontrol Bölgesi — terminal, istasyon, hat
    4: False,   # Demiryolu Ablukası — gar ve vagon hattı
    5: True,    # Ağır Güvenlik Bölgesi — fabrika ve fırın avluları
    6: True,    # Karahanlı Haddehanesi
    7: True,    # Yeraltı Sevkiyatı
    8: False,   # Zırhlı Üs — sur önü
    9: False,   # Kuzey Surları
    10: True,   # Sessiz Koridor — kale içi
    11: True,   # İç Kale / Karahanlı — saray içi
}
# Kitap 2 ve 3: yalnız gökyüzü açıkça görünen sokak / sahil / bahçe aralıkları dış
# mekândır; aydınlık tonozlu çarşılar ve pencereden manzara gören salonlar
# otomatik ölçütü yanıltabildiği için aralıklar görüntülere bakılarak elle verildi.
# Listede olmayan her yer iç mekân sayılır (sandık/iskele setleri her yerde doğal durur).
EXTERIOR = {
    12: [(0, 42750), (57750, 71250), (83250, 92250), (101250, 113000)],  # Haliç'te Şafak
    13: [(0, 28500), (58500, 75000), (90000, 113000)],                     # Sahte Mühür
    14: [(0, 43500), (101250, 117000)],                                   # Zeyrek Su Hattı
    15: [(0, 44250), (104250, 121000)],                                   # Süleymaniye Arşivi
    16: [(0, 44250), (89250, 117000)],                                    # Beyazıt Posta Hattı
    17: [(0, 14250), (57750, 72750), (102750, 117000)],                   # Kapalıçarşı Arka Hanı
    18: [(0, 44250)],                                                     # Çemberlitaş Külhanı
    19: [(0, 44250)],                                                     # Samatya Taş Depoları
    20: [(0, 29250), (44250, 72750), (102750, 117000)],                   # Yenikapı Gece Vardiyası
    21: [(0, 29250), (89250, 117000)],                                    # Aksaray Pompa İstasyonu
    22: [(0, 29250), (89250, 117000)],                                    # Saraçhane Ana Vana
    23: [(0, 32250), (248250, 290000)],                                   # Bozdoğan Kemeri
    24: [(0, 56250), (68250, 83250)],                                     # Cağaloğlu'nda İlk Baskın
    25: [(0, 29250), (83250, 98250)],                                     # Sirkeci Sevkiyatı
    26: [(0, 56250), (98250, 112000)],                                    # Galata Telgrafı
    27: [(0, 57000), (83250, 112000)],                                    # Üsküdar Yedek Hattı
    28: [(0, 68250), (98250, 112000)],                                    # Kuzguncuk Kıyı Deposu
    29: [(0, 56250)],                                                     # Beylerbeyi İskele Arşivi
    30: [(0, 41250)],                                                     # Çengelköy Sahil Konağı
    31: [(0, 56250)],                                                     # Kuleli Gözetleme Hattı
    32: [(0, 41250)],                                                     # Vaniköy Gece Sevkiyatı
    33: [(0, 59250), (83250, 112000)],                                    # Kandilli Verici Sırtı
    34: [(0, 41250), (83250, 112000)],                                    # Anadoluhisarı Kale İçi
    35: [(201000, 237000), (246000, 273000)],                             # Son Yayın
}
lines=[]
for lv in sorted(levels):
    if lv in EXTERIOR:
        rngs=[]; cur=-1000
        for a,b in EXTERIOR[lv]:
            if a>cur: rngs.append((cur,a))
            cur=b
        rngs.append((cur,1000000))
        lines.append("\t%d: [%s]," % (lv, ", ".join("Vector2(%d, %d)"%(a,b) for a,b in rngs)))
        continue
    if lv in MANUAL:
        if MANUAL[lv]:
            lines.append("\t%d: [Vector2(-1000, 1000000)]," % lv)
        continue
    rngs=[]
    for x,v in sorted(levels[lv]):
        if v<0.2:
            a,b=x-STEP//2,x+STEP//2
            if rngs and rngs[-1][1]>=a: rngs[-1][1]=b
            else: rngs.append([a,b])
    if rngs:
        lines.append("\t%d: [%s]," % (lv, ", ".join("Vector2(%d, %d)"%(a,b) for a,b in rngs)))
out='''## ParkourInteriors — bölüm başına iç mekân (gökyüzü görünmeyen) x aralıkları.
##
## Üretici: tools/gen_parkour_interiors.py. Bölümler 1500 px aralıkla görüntülenip
## etiketlendi; kampanya bölümleri elle doğrulanmış aralıklardır
## (bkz. docs/DAN-THE-MAN-PARKUR.md). Bu dosyayı elle düzenlemeyin.
## Anahtar: GameState.LEVELS indeksi. Değer: Vector2(sol_x, sağ_x) aralıkları.
## Bölüm arka planları değişirse tablo yeniden üretilmelidir.
class_name ParkourInteriors
extends RefCounted

const RANGES := {
%s
}


static func is_interior(level_index: int, x0: float, x1: float) -> bool:
	for r in RANGES.get(level_index, []):
		if r.x < x1 and r.y > x0:
			return true
	return false
''' % "\n".join(lines)
open(os.path.join(os.path.dirname(__file__), '..', 'redmount', 'scripts', 'systems', 'parkour_interiors.gd'),'w').write(out)
print(len(levels),"levels", sum(len(l) for l in levels.values()),"samples")
