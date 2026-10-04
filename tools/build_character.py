"""
build_character.py — atlas sayfalarını Godot SpriteFrames .tres'e çevirir.

Her karakter için:
  * slice_atlas.build_sheet ile satırları tek-boy şerit PNG'lere böler
    -> redmount/assets/anim/<char>/<anim>.png
  * bu şeritleri AtlasTexture bölgeleriyle referanslayan bir SpriteFrames
    kaynağı yazar -> redmount/resources/anim/<char>_frames.tres

Kullanım:  python tools/build_character.py <char_name> [char_name ...]   (hepsi: all)
"""
import os, sys, json, hashlib
sys.path.insert(0, os.path.dirname(__file__))
from slice_atlas import build_sheet

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GODOT = os.path.join(ROOT, "redmount")
A = os.path.join(GODOT, "assets")

# --- kare hücresi ---
CW, CH, PAD = 200, 240, 6
# ayak hizası: hücre altından PAD px yukarı. AnimatedSprite2D offset.y = -(CH/2 - PAD).

# --- her animasyonun: (loop, fps) ---
DEF = {}


def anim(name, loop=True, fps=10.0):
    DEF[name] = (loop, fps)


# ortak
for n in ["idle", "walk", "run"]:
    anim(n, True, 10)
anim("jump", False, 12)
anim("fall", True, 8)
anim("land", False, 14)
anim("crouch", False, 10)
anim("hurt", False, 12)
anim("knockdown", False, 10)
anim("dead", False, 10)
for w in ["bat", "knife", "pistol", "rifle"]:
    anim(f"{w}_idle", True, 9)
    anim(f"{w}_walk", True, 10)
    anim(f"{w}_attack", False, 16)
    anim(f"{w}_attack2", False, 16)
anim("fight", True, 8)
anim("combo_a", False, 16)
anim("combo_b", False, 16)
anim("knee", False, 15)
anim("pistol_shoot", False, 18)
anim("rifle_shoot", False, 18)
anim("pistol_reload", False, 12)
anim("rifle_reload", False, 12)
# düşman ekstra
for n in ["attack", "attack_heavy", "block", "aim", "shoot", "getup", "evade",
          "leap", "guard_break", "special"]:
    anim(n, False, 12)
anim("walk", True, 10)


# --- karakter tanımları: atlas -> satır eşlemesi -------------------------
# row eşlemesi: "rowN=animad:beklenen_kare_sayısı"
CHARS = {
    "redmount": [
        dict(atlas="characters/redmount/redmount_locomotion_atlas_v2.png",
             bg="light", stand_row=0, stand_h=196,
             map="row0=idle:5,row1=walk:8,row2=run:8,row3=jump:5,row4=crouch:3"),
        dict(atlas="characters/redmount/redmount_unarmed_atlas_v1.png",
             bg="light", stand_row=0, stand_h=196,
             map="row0=fight:4,row1=combo_a:6,row2=combo_b:7,row3=knee:5"),
        dict(atlas="characters/redmount/redmount_bat_atlas_v1.png",
             bg="light", stand_row=0, stand_h=196,
             map="row0=bat_idle:4,row1=bat_walk:8,row2=bat_attack:8,row3=bat_attack2:8"),
        dict(atlas="characters/redmount/redmount_knife_atlas_v1.png",
             bg="light", stand_row=0, stand_h=196,
             map="row0=knife_idle:4,row1=knife_walk:8,row2=knife_attack:7,row3=knife_attack2:5"),
        dict(atlas="characters/redmount/redmount_handgun_atlas_v1.png",
             bg="light", stand_row=0, stand_h=196,
             map="row0=pistol_idle:5,row1=pistol_walk:8,row2=pistol_aim:4,row3=pistol_shoot:4,row4=pistol_reload:8"),
        dict(atlas="characters/redmount/redmount_rifle_atlas_v1.png",
             bg="light", stand_row=1, stand_h=196,
             map="row0=rifle_idle:5,row1=rifle_walk:8,row2=rifle_aim:4,row3=rifle_shoot:5,row4=rifle_reload:8"),
    ],
    "karahanli": [
        dict(atlas="characters/karahanli/karahanli_locomotion_atlas_v2.png",
             bg="light", stand_row=0, stand_h=204,
             map="row0=idle:6,row1=walk:8,row2=attack:7,row3=attack_heavy:5,row4=hurt:3"),
    ],
}

# --- düşmanlar: koyu zemin (bg=detail) --------------------------------
# Üst satırlar (idle/walk/attack) güvenilir; alt satırlar (hurt/dead) yaklaşık.
_ENEMY_MAPS = {
    "street_thug": "row0=idle,row1=walk,row2=attack,row3=attack2,row4=hurt,row6=knockdown,row7=dead",
    "knife_agent": "row0=idle,row1=walk,row2=walk,row3=attack,row4=attack2,row5=knockdown,row6=dead",
    "rifle_guard": "row0=idle,row1=walk,row2=aim,row4=shoot,row5=reload,row8=hurt,row10=dead",
    "armored_bruiser": "row0=idle,row1=walk,row2=attack,row3=attack_heavy,row4=block,row5=guard_break,row7=hurt,row8=dead",
    "agile_assassin": "row0=idle,row1=walk,row2=walk,row3=evade,row4=attack,row5=leap,row7=hurt,row9=dead",
    "elite_guard": "row0=idle,row1=walk,row2=attack,row3=attack2,row5=block,row7=hurt,row8=dead",
    "mini_boss": "row0=idle,row1=walk,row2=attack,row3=attack_heavy,row4=special,row7=hurt,row8=dead",
}
for _e, _m in _ENEMY_MAPS.items():
    CHARS[_e] = [dict(
        atlas=f"enemies/{_e}/{_e}_animation_atlas_v1.png",
        bg="detail", stand_row=0, stand_h=176,
        map=",".join(f"{s}:0" for s in _m.split(",")),
    )]


def esc(p):
    return p.replace("\\", "/")


def gen_tres(char, manifest):
    """manifest: list of (anim_name, frame_count). Şeritler assets/anim/<char>/<name>.png"""
    ext = []      # (id, path)
    subs = []     # (id, ext_id, x)
    anims = []
    step = 1
    lines_ext = []
    lines_sub = []
    for name, n in manifest:
        loop, fps = DEF.get(name, (name in ("idle", "walk", "run"), 10.0))
        rel = f"assets/anim/{char}/{name}.png"
        eid = f"{step}_{name}"
        step += 1
        lines_ext.append(f'[ext_resource type="Texture2D" path="res://{rel}" id="{eid}"]')
        fr = []
        for i in range(n):
            sid = f"{name}_{i}"
            lines_sub.append(f'[sub_resource type="AtlasTexture" id="{sid}"]')
            lines_sub.append(f'atlas = ExtResource("{eid}")')
            lines_sub.append(f'region = Rect2({i*CW}, 0, {CW}, {CH})')
            lines_sub.append("")
            fr.append('{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % sid)
        anims.append('{\n"frames": [%s],\n"loop": %s,\n"name": &"%s",\n"speed": %s\n}'
                     % (", ".join(fr), "true" if loop else "false", name, fps))
    load_steps = len(manifest) + sum(n for _, n in manifest) + 1
    out = []
    out.append(f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]')
    out.append("")
    out.extend(lines_ext)
    out.append("")
    out.extend(lines_sub)
    out.append("[resource]")
    out.append("animations = [%s]" % ", ".join(anims))
    out.append("")
    dest = os.path.join(GODOT, "resources", "anim", f"{char}_frames.tres")
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    with open(dest, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out))
    print(f"  .tres -> {esc(os.path.relpath(dest, GODOT))}  ({len(manifest)} anim)")


def build(char):
    specs = CHARS.get(char)
    if not specs:
        print(f"!! tanım yok: {char}")
        return
    out_dir = os.path.join(A, "anim", char)
    full_manifest = []
    for spec in specs:
        atlas = os.path.join(A, spec["atlas"])
        print(f"[{char}] {os.path.basename(atlas)}")
        mp = []
        for part in spec["map"].split(","):
            k, v = part.split("=")
            ri = int(k.replace("row", ""))
            nm, cnt = v.split(":")
            mp.append((ri, nm, int(cnt)))
        m = build_sheet(atlas, out_dir, mp, cell=(CW, CH), bg=spec.get("bg", "auto"),
                        pad=PAD, stand_row=spec.get("stand_row", 0),
                        stand_h=spec.get("stand_h", 196))
        full_manifest.extend(m)
    # tekrarları at (sonraki kazanır zaten dosya üzerine yazıldı)
    seen = {}
    for nm, n in full_manifest:
        seen[nm] = n
    gen_tres(char, list(seen.items()))


if __name__ == "__main__":
    args = sys.argv[1:]
    if not args or args == ["all"]:
        args = list(CHARS)
    for c in args:
        build(c)
