"""16x16 piksel ikonları çizer ve 4x büyütür (art/items/)."""
import os
from PIL import Image
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'art', 'items')
PAL = {'.': None, 'k': (28,22,30), 'y': (255,206,64), 'Y': (255,240,150), 'o': (214,140,30),
       'b': (150,86,40), 'B': (196,124,62), 'l': (232,170,96), 's': (250,236,200),
       'g': (120,124,138), 'G': (182,186,198), 'd': (60,62,74), 'r': (200,60,50), 'w': (255,255,255)}
ICONS = {
 'coin': [
  '................','.....kkkkkk.....','...kkyyyyyykk...','..kyyYYyyyyyok..','..kyYYyyyyyyok..',
  '.kyyYyykkyyyyok.','.kyyyyyk.yyyyok.','.kyyyyyk.yyyyok.','.kyyyyyk.yyyyok.','.kyyyyyk.yyyyok.',
  '.kyyyykkkyyyook.','..kyyyyyyyyook..','..koyyyyyyooko..','...kkooooookk...','.....kkkkkk.....','................'],
 'simit': [
  '................','.....kkkkkk.....','...kkBBsBBBkk...','..kBlBBBBsBBbk..','..kBsBkkkkBBbk..',
  '.kBBBk....kBsbk.','.kBsk......kBbk.','.kBBk......kBbk.','.kBBk......ksbk.','.kBsk......kBbk.',
  '.kBBBk....kBBbk.','..kbBBkkkkBsbk..','..kbbsBBBBbbbk..','...kkbbbbbbkk...','.....kkkkkk.....','................'],
 'bat': [
  '................','.............kk.','............kBBk','...........kBlBk','..........kBlBk.',
  '.........kBlBk..','........kBlBk...','.......kBlBk....','......kBBBk.....','.....kbBbk......',
  '....kbbbk.......','...kkbbk........','..kddkk.........','.kddk...........','..kk............','................'],
 'pistol': [
  '................','................','................','..kkkkkkkkkkkk..','..kGGGGGGGGGGGk.',
  '..kgGggggggggdk.','..kkkkgggddkkkk.','......kgdk......','.....kgdkk......','.....kgdk.......',
  '....kgddk.......','....kdddk.......','....kkkkk.......','................','................','................'],
}
os.makedirs(OUT, exist_ok=True)
for name, rows in ICONS.items():
    im = Image.new('RGBA', (16, 16), (0,0,0,0))
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if PAL.get(c): im.putpixel((x, y), PAL[c] + (255,))
    im.resize((64, 64), Image.NEAREST).save(os.path.join(OUT, name + '.png'))
print('ok', list(ICONS))
