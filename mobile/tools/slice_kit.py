"""Platform kitinden (level01_turkish_platform_kit_v1.png) prop'ları keser.
Arka plandaki yarı saydam parıltı (alpha<200) temizlenir; bulutlar orijinal alfa ile kalır."""
import os, numpy as np
from PIL import Image
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, '..', 'redmount', 'assets', 'environment', 'level01_turkish_platform_kit_v1.png')
OUT = os.path.join(ROOT, 'art', 'kit')
# ad: (x, y, w, h, bulut_mu)
SLICES = {
  'ground_long': (24,34,436,90,0), 'ground_a': (473,34,126,90,0), 'ground_b': (608,34,157,90,0),
  'ground_stairs': (774,34,155,90,0), 'ground_end': (923,34,95,90,0),
  'ledge_l': (28,151,241,72,0), 'ledge_m': (281,151,129,72,0), 'ledge_s': (432,151,79,72,0),
  'ledge_xs': (536,151,55,72,0), 'ledge_m2': (616,151,123,72,0), 'ledge_l2': (766,151,151,72,0),
  'ledge_xs2': (937,151,63,72,0),
  'cloud_city': (1036,18,487,140,1), 'cloud_house': (1004,156,259,165,1), 'cloud_puff': (1255,179,262,83,1),
  'cloud_small': (1334,271,168,64,1),
  'house_a': (19,246,281,391,0), 'house_b': (314,234,268,401,0), 'house_c': (582,274,209,361,0),
  'bufe': (800,373,294,262,0),
  'wall_broken': (1099,352,112,160,0), 'wall_plain': (1231,352,80,160,0), 'wall_niche': (1334,352,121,232,0),
  'wall_pillar': (1459,352,56,232,0),
  'scaffold': (1116,534,199,169,0), 'ladder': (1321,607,53,222,0), 'scaffold_post': (1405,613,104,197,0),
  'bus': (144,649,415,146,0), 'scaffold_small': (976,672,145,120,0), 'car': (625,696,261,98,0),
  'plank': (1162,718,123,48,0),
  'roof_a': (22,805,341,60,0), 'roof_b': (361,805,260,60,0), 'roof_chimney': (639,807,181,172,0),
  'shop_interior': (836,809,368,185,0), 'tree_pot': (1441,834,73,137,0), 'vase_big': (1222,842,56,130,0), 'vase_small': (1280,890,52,82,0),
  'pots': (1336,890,52,82,0), 'rail_wall': (21,881,374,114,0), 'window_balcony': (424,875,204,132,0),
  'plant_small': (1390,880,50,92,0),
}
def main():
    os.makedirs(OUT, exist_ok=True)
    im = np.array(Image.open(SRC).convert('RGBA'))
    for name, (x, y, w, h, cloud) in SLICES.items():
        p = 2 if cloud else 0
        c = im[max(0,y-p):y+h+p, max(0,x-p):x+w+p].copy()
        if not cloud:
            c[c[:,:,3] < 200, 3] = 0
            c[c[:,:,3] >= 200, 3] = 255
        img = Image.fromarray(c)
        bb = img.getbbox()
        if bb: img = img.crop(bb)
        img.save(os.path.join(OUT, name + '.png'))
    print(len(SLICES), 'parça ->', OUT)
if __name__ == '__main__':
    main()


def extras():
    """Zemin altı taş dolgusu (dikey döşenebilir, koyulaştırılmış) + ikon/portre."""
    g = Image.open(os.path.join(OUT, 'ground_long.png')).convert('RGBA')
    fill = g.crop((4, 30, 424, 86))
    arr = np.array(fill).astype(float)
    arr[:, :, :3] *= 0.55
    arr[:, :, 3] = 255
    Image.fromarray(arr.astype('uint8')).save(os.path.join(OUT, 'stone_fill.png'))
    idle = Image.open(os.path.join(ROOT, 'art', 'chars', 'redmount', 'idle.png')).convert('RGBA')
    face = idle.crop((62, 36, 138, 112))
    face.resize((152, 152), Image.NEAREST).save(os.path.join(ROOT, 'art', 'items', 'portrait.png'))
    icon = Image.new('RGBA', (152, 152), (34, 26, 44, 255))
    icon.alpha_composite(face.resize((152, 152), Image.NEAREST))
    icon.resize((128, 128), Image.LANCZOS).save(os.path.join(ROOT, 'icon.png'))

if __name__ == '__main__':
    extras()
