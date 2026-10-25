"""Seed Siege v2 prototype engine (design/seed-siege-v2.md).

Additive: sim.py, fields.py, bot.py, weekly.py and reference_runs.py are untouched and
still reproduce the version 1 numbers. This file adds, on top of the same rules:

- 14 new plants (24 in all) and 10 new pests (20 in all), with the new mechanics in
  v2 section 3 (knockback, multi target, armour crack, bounty, slowing aura, sour,
  boss bonus, burn aura, damage aura, hops, swoops, ruffles, scratches, snatches,
  stink on shoo, bin dive, unslowable).
- Plant rank (collection level 1 to 10).
- 1 to 4 players: zones, per player Sap, shared hearts, health scaling.

With one player, rank 1 plants and the classic data, CoopRun gives exactly the same
results as sim.Run (checked by `python3 coop_runs.py --check`).
"""
import math, random
from sim import SEEDS as SEEDS1, PESTS as PESTS1, LVL_DMG, LVL_RNG, UPG_COST, expand, posat, DT

# ---------------------------------------------------------------- plants (24)
SEEDS = {k: dict(v) for k, v in SEEDS1.items()}
NEW_SEEDS = {
 'wattle':     dict(cost=70,  grow=0, dmg=4,  rng=2.0, rate=2.0, dtype='pierce', air=True,  detect=False),
 'lilly':      dict(cost=80,  grow=1, dmg=14, rng=3.0, rate=0.6, dtype='blunt',  air=False, detect=False),
 'saltbush':   dict(cost=90,  grow=1, dmg=0,  rng=2.0, rate=0,   dtype=None,     air=False, detect=False, bounty=2),
 'roopaw':     dict(cost=100, grow=1, dmg=10, rng=1.5, rate=0.5, dtype='blunt',  air=False, detect=False, knock=0.6),
 'grevillea':  dict(cost=110, grow=1, dmg=6,  rng=2.5, rate=1.0, dtype='pierce', air=True,  detect=False, targets=3),
 'banksia':    dict(cost=140, grow=2, dmg=12, rng=3.0, rate=0.5, dtype='blunt',  air=True,  detect=False, splash=1.0, airsplash=True),
 'pigface':    dict(cost=120, grow=1, dmg=2,  rng=1.5, rate=1.0, dtype='poison', air=False, detect=False, aura=True, auraslow=0.25),
 'macadamia':  dict(cost=150, grow=2, dmg=20, rng=2.5, rate=0.6, dtype='blunt',  air=False, detect=False, crack=True),
 'bottlebrush':dict(cost=160, grow=2, dmg=5,  rng=3.0, rate=3.0, dtype='pierce', air=True,  detect=False, airmult=1.6),
 'fingerlime': dict(cost=150, grow=1, dmg=8,  rng=3.0, rate=0.8, dtype='pierce', air=True,  detect=False, sour=(1.25, 3.0)),
 'boab':       dict(cost=260, grow=3, dmg=90, rng=3.0, rate=0.25,dtype='blunt',  air=False, detect=False, bossmult=2.0, heavymult=1.3),
 'waratah':    dict(cost=220, grow=2, dmg=0,  rng=2.0, rate=1.0, dtype='fire',   air=True,  detect=False, burnaura=(8, 3.0)),
 'wollemi':    dict(cost=300, grow=3, dmg=20, rng=3.5, rate=0.6, dtype='pierce', air=True,  detect=False, reveal=3.0, dmgbuff=(0.20, 2.5)),
 'gumtree':    dict(cost=400, grow=3, dmg=40, rng=5.0, rate=0.5, dtype='blunt',  air=True,  detect=True,  splash=1.2, airsplash=True),
}
SEEDS.update(NEW_SEEDS)

RARITY = {
 'thorn':'C','sunpetal':'C','burr':'C','wattle':'C','lilly':'C',
 'nettle':'U','dandelion':'U','saltbush':'U','roopaw':'U','grevillea':'U',
 'pumpkin':'R','mint':'R','banksia':'R','pigface':'R','macadamia':'R',
 'chilli':'RB','snapjaw':'RB','bottlebrush':'RB','fingerlime':'RB',
 'oak':'BR','boab':'BR','waratah':'BR',
 'wollemi':'CH','gumtree':'CH',
}
TIERS = ['C','U','R','RB','BR','CH']
TIER_NAME = {'C':'Common','U':'Uncommon','R':'Rare','RB':'Ribbon','BR':'Blue Ribbon','CH':'Champion'}

def rank_mult(rank):
    return 1.0 + 0.04 * (rank - 1)

# ---------------------------------------------------------------- pests (20)
PESTS = {k: dict(v) for k, v in PESTS1.items()}
NEW_PESTS = {
 'blowie':   dict(hp=14,  spd=1.8, reward=2,   leak=1,  armour=0, res={}, fly=True),
 'stinkbug': dict(hp=60,  spd=0.9, reward=6,   leak=1,  armour=1, res={}, stink=(0.6, 2.0, 1.0)),
 'toad':     dict(hp=120, spd=0.6, reward=9,   leak=2,  armour=0, res={'poison':0.5}, hop=(3.0, 1.0)),
 'magpie':   dict(hp=80,  spd=1.3, reward=9,   leak=2,  armour=0, res={}, fly=True, swoop=(5.0, 1.5, 1.5, 0)),
 'cocky':    dict(hp=90,  spd=1.1, reward=9,   leak=2,  armour=0, res={}, fly=True, ruffle=(0.7, 1.0)),
 'turkey':   dict(hp=260, spd=0.6, reward=15,  leak=3,  armour=3, res={}, heavy=True, scratch=(5.0, 1.0, 2.0)),
 'flyingfox':dict(hp=180, spd=0.9, reward=14,  leak=3,  armour=1, res={}, fly=True, heavy=True),
 'wombat':   dict(hp=900, spd=0.4, reward=50,  leak=8,  armour=8, res={'blunt':1.5,'pierce':0.5}, heavy=True, unslow=True),
 'kevin':    dict(hp=1800,spd=0.5, reward=120, leak=15, armour=3, res={'bite':1.25}, heavy=True, boss=True, snatch=(7.0, 1.5, 5.0), bindive=(0.5, 3.0)),
 'swoopy':   dict(hp=1500,spd=0.6, reward=120, leak=15, armour=2, res={}, fly=True, boss=True, swoop=(6.0, 2.0, 1.0, 1.0)),
}
PESTS.update(NEW_PESTS)

# ---------------------------------------------------------------- co-op scaling
# Index by player count 1..4. Tuned with coop_runs.py (v2 section 4.4).
HP_SCALE   = {1: 1.0, 2: 1.7,  3: 2.2,  4: 2.5}
SAP_SHARE  = {1: 1.0, 2: 0.85, 3: 0.75, 4: 0.68}
START_SHARE= {1: 1.0, 2: 0.85, 3: 0.75, 4: 0.68}
SLOT_PLANT_CAP = 20


def zones_split(path_wps, n):
    """Zones.split (v2 4.3): plantable tiles sorted by how far along the route their
    nearest path tile is, then cut into n runs of near equal size (gate end first)."""
    segs, L, ptiles = expand(path_wps)
    # route distance of each path tile centre
    pd = {}
    for (tx, ty) in ptiles:
        c = (tx + 0.5, ty + 0.5); best = None
        for a, b, s, l in segs:
            # projection on the segment
            ax, ay = a; bx, by = b
            vx, vy = bx - ax, by - ay
            t = 0 if l == 0 else max(0, min(1, ((c[0]-ax)*vx + (c[1]-ay)*vy) / (l*l)))
            px, py = ax + vx*t, ay + vy*t
            if math.dist((px, py), c) < 1e-6:
                d = s + t*l
                if best is None or d < best: best = d
        pd[(tx, ty)] = best
    tiles = []
    for y in range(8):
        for x in range(12):
            if (x, y) in ptiles: continue
            md = min(math.dist((x+.5, y+.5), (tx+.5, ty+.5)) for (tx, ty) in ptiles)
            dd = min(pd[t] for t in ptiles if abs(math.dist((x+.5, y+.5), (t[0]+.5, t[1]+.5)) - md) < 1e-9)
            tiles.append((dd, y, x))
    tiles.sort()
    zones = {}
    N = len(tiles); start = 0
    for k in range(n):
        size = N // n + (1 if k < N % n else 0)
        for (_, y, x) in tiles[start:start+size]: zones[(x, y)] = k
        start += size
    return zones


def _newpest(pid, hp_scale, d=0.0):
    pd = PESTS[pid]
    hp = pd['hp'] * hp_scale
    return dict(id=pid, hp=hp, max=hp, d=d, slow=0, slowt=0, burn=0, burnt=0, bt=0, ph=0, hidden=False,
                clk=0.0, low=False, sour=1.0, sourt=0.0, dived=False, divet=0.0, snat=0.0, scrt=0.0, hopt=0.0)


class CoopRun:
    """One run for 1 to 4 players. slots: list of dict(loadout=set or None, ranks={seed: rank})."""
    def __init__(s, field, slots, research=None, hp_extra=1.0, zones=True):
        s.f = field; s.segs, s.L, s.path = expand(field['path'])
        r = research or {}
        n = len(slots); s.n = n
        s.dmgm = 1 + r.get('dmg', 0); s.ratem = 1 + r.get('rate', 0); s.rngb = r.get('rng', 0)
        s.hearts = 20 + r.get('hearts', 0)
        s.sapm = 1 + r.get('sapm', 0)
        s.hp_scale = field.get('hpScale', 1.0) * hp_extra * HP_SCALE[n]
        s.growbonus = r.get('grow', 0)
        s.firem = 1.0; s.spdm = 1.0; s.armb = 0; s.mintb = 0; s.sunm = 1
        start = field['start'] + r.get('startsap', 0)
        s.slots = []
        for sl in slots:
            s.slots.append(dict(sap=start if n == 1 else math.floor(start * START_SHARE[n]),
                                loadout=sl.get('loadout'), ranks=sl.get('ranks', {}), planted=0))
        s.zones = zones_split(field['path'], n) if (zones and n > 1) else None
        s.plants = []; s.pests = []; s.wave = 0
        s.share = SAP_SHARE[n]
        s.hp_mults = None

    # -- actions
    def can_plant(s, slot, x, y):
        if (x, y) in s.path or not (0 <= x < 12 and 0 <= y < 8): return False
        if any(p['x'] == x and p['y'] == y for p in s.plants): return False
        if s.zones is not None and s.zones.get((x, y)) != slot: return False
        return True

    def place(s, seed, x, y, slot=0):
        sd = SEEDS[seed]; sl = s.slots[slot]
        if not s.can_plant(slot, x, y): return False
        if sl['loadout'] is not None and seed not in sl['loadout']: return False
        if s.n > 1 and sl['planted'] >= SLOT_PLANT_CAP: return False
        if sl['sap'] < sd['cost']: return False
        sl['sap'] -= sd['cost']; sl['planted'] += 1
        rank = sl['ranks'].get(seed, 1)
        s.plants.append(dict(seed=seed, x=x, y=y, lvl=0, grow=max(0, sd['grow'] - s.growbonus), cd=0,
                             cx=x+0.5, cy=y+0.5, owner=slot, rank=rank, rm=rank_mult(rank),
                             stun=0.0, deb=1.0, debt=0.0))
        return True

    def upgrade(s, i, slot=None):
        p = s.plants[i]
        if slot is not None and p['owner'] != slot: return False
        if p['lvl'] >= 2: return False
        c = round(SEEDS[p['seed']]['cost'] * UPG_COST[p['lvl']])
        sl = s.slots[p['owner']]
        if sl['sap'] < c: return False
        sl['sap'] -= c; p['lvl'] += 1; return True

    @property
    def sap(s):
        return s.slots[0]['sap']

    # -- helpers
    def flying(s, e):
        return PESTS[e['id']].get('fly') and not e['low']

    def buff(s, p):
        b = 0
        for q in s.plants:
            if q['seed'] == 'mint' and q['grow'] == 0 and q is not p:
                if math.dist((q['cx'], q['cy']), (p['cx'], p['cy'])) <= SEEDS['mint']['rng'] + s.mintb + 0.001:
                    b = max(b, SEEDS['mint']['buff'][q['lvl']] + 0.005 * (q['rank'] - 1))
        return b

    def dbuff(s, p):
        b = 0
        for q in s.plants:
            if q['seed'] == 'wollemi' and q['grow'] == 0 and q is not p:
                amt, rr = SEEDS['wollemi']['dmgbuff']
                if math.dist((q['cx'], q['cy']), (p['cx'], p['cy'])) <= rr + 1e-9:
                    b = max(b, amt)
        return b

    def minted(s, e, pos=None):
        ex, ey = pos or posat(s.segs, e['d'])
        for q in s.plants:
            if q['grow'] != 0: continue
            if q['seed'] == 'mint':
                if math.dist((ex, ey), (q['cx'], q['cy'])) <= SEEDS['mint']['rng'] + s.mintb + 1e-9: return True
            elif q['seed'] == 'wollemi':
                if math.dist((ex, ey), (q['cx'], q['cy'])) <= SEEDS['wollemi']['reveal'] + 1e-9: return True
        return False

    def untouchable(s, e):
        return e['divet'] > 0

    def dmg(s, e, amount, dtype, ignore_armour=False):
        if s.untouchable(e): return
        pd = PESTS[e['id']]
        m = pd['res'].get(dtype, 1.0)
        v = amount * m
        if dtype == 'fire': v *= s.firem
        if e['sourt'] > 0: v *= e['sour']
        if not ignore_armour: v = max(1, v - pd['armour'] - s.armb)
        e['hp'] -= v
        if pd.get('bindive') and not e['dived'] and e['hp'] <= e['max'] * pd['bindive'][0] and e['hp'] > 0:
            e['dived'] = True; e['divet'] = pd['bindive'][1]

    def plants_near(s, x, y, r):
        return [p for p in s.plants if math.dist((p['cx'], p['cy']), (x, y)) <= r + 1e-9]

    # -- the wave
    def play_wave(s, waves):
        w = waves[s.wave]
        sched = []
        for g in w:
            pid, cnt, gap, start = g[:4]
            hpm = g[4] if len(g) > 4 else 1.0
            for k in range(cnt): sched.append((start + k * gap, pid, hpm))
        sched.sort(key=lambda a: (a[0], a[1]))
        t = 0; si = 0
        while True:
            while si < len(sched) and sched[si][0] <= t + 1e-9:
                _, pid, hpm = sched[si]
                s.pests.append(_newpest(pid, s.hp_scale * hpm))
                si += 1
            s.step(t)
            t += DT
            if s.hearts <= 0: return False
            if si >= len(sched) and not s.pests: break
            if t > 900: break
        s.wave += 1
        bonus = 25 + 5 * s.wave
        for sl in s.slots:
            sl['sap'] += bonus if s.n == 1 else round(bonus * s.share)
        for p in s.plants:
            if p['grow'] > 0: p['grow'] -= 1
            if p['seed'] == 'sunpetal' and p['grow'] == 0:
                inc = SEEDS['sunpetal']['income'][p['lvl']] * s.sunm
                if p['rank'] > 1: inc = round(inc * p['rm'])
                s.slots[p['owner']]['sap'] += inc
        return True

    def step(s, t):
        # plant status timers
        for p in s.plants:
            if p['debt'] > 0:
                p['debt'] -= DT
                if p['debt'] <= 0: p['deb'] = 1.0
        # move and pest abilities
        for e in s.pests:
            pd = PESTS[e['id']]
            e['clk'] += DT
            if pd.get('burrow'):
                e['ph'] = (e['ph'] + DT) % 5.0
                e['hidden'] = e['ph'] < 3.0
            if pd.get('swoop'):
                per, dur, spdm, flinch = pd['swoop']
                was = e['low']
                e['low'] = (e['clk'] % per) >= per - dur - 1e-9
                if e['low'] and not was and flinch > 0:
                    ex, ey = posat(s.segs, e['d'])
                    for p in s.plants_near(ex, ey, 1.5): p['stun'] = max(p['stun'], flinch)
            if e['divet'] > 0: e['divet'] -= DT
            sl = 0 if pd.get('unslow') else (e['slow'] if e['slowt'] > 0 else 0)
            sp = pd['spd'] * s.spdm * (1 - sl)
            if pd.get('swoop') and e['low']: sp *= pd['swoop'][2]
            e['d'] += sp * DT
            if pd.get('hop'):
                e['hopt'] += DT
                if e['hopt'] >= pd['hop'][0] - 1e-9: e['hopt'] = 0; e['d'] += pd['hop'][1]
            if e['slowt'] > 0: e['slowt'] -= DT
            if e['sourt'] > 0: e['sourt'] -= DT
            if pd.get('regen') and e['burnt'] <= 0: e['hp'] = min(e['max'], e['hp'] + pd['regen'] * DT)
            if e['burnt'] > 0:
                e['bt'] += DT
                if e['bt'] >= 0.5 - 1e-9:
                    e['bt'] -= 0.5; s.dmg(e, e['burn'] * 0.5, 'fire', True)
                e['burnt'] -= DT
            if pd.get('ruffle'):
                ex, ey = posat(s.segs, e['d'])
                for p in s.plants_near(ex, ey, pd['ruffle'][1]):
                    if pd['ruffle'][0] <= p['deb'] or p['debt'] <= 0:
                        p['deb'] = min(p['deb'], pd['ruffle'][0]) if p['debt'] > 0 else pd['ruffle'][0]
                        p['debt'] = max(p['debt'], 0.5)
            if pd.get('scratch'):
                per, r, st = pd['scratch']
                e['scrt'] += DT
                if e['scrt'] >= per - 1e-9:
                    e['scrt'] = 0; ex, ey = posat(s.segs, e['d'])
                    for p in s.plants_near(ex, ey, r): p['stun'] = max(p['stun'], st)
            if pd.get('snatch'):
                per, r, st = pd['snatch']
                e['snat'] += DT
                if e['snat'] >= per - 1e-9:
                    e['snat'] = 0; ex, ey = posat(s.segs, e['d'])
                    near = [p for p in s.plants_near(ex, ey, r) if p['stun'] <= 0]
                    if near:
                        tgt = max(near, key=lambda p: (s.spent(p), -s.plants.index(p)))
                        tgt['stun'] = st
        for e in list(s.pests):
            if e['d'] >= s.L:
                s.hearts -= PESTS[e['id']]['leak']; s.pests.remove(e)
        # attack
        for p in s.plants:
            sd = SEEDS[p['seed']]
            if sd['rate'] == 0: continue
            if p['stun'] > 0:
                p['stun'] -= DT; continue
            rate = sd['rate'] * s.ratem * (1 + s.buff(p))
            if p['deb'] < 1.0: rate *= p['deb']
            p['cd'] -= DT
            if p['cd'] > 0: continue
            rng = sd['rng'] + LVL_RNG[p['lvl']] + s.rngb
            dm = sd['dmg'] * LVL_DMG[p['lvl']] * s.dmgm * (0.5 if p['grow'] > 0 else 1.0)
            if p['rank'] > 1: dm *= p['rm']
            db = s.dbuff(p)
            if db: dm *= (1 + db)
            cands = []
            for e in s.pests:
                if s.untouchable(e): continue
                if s.flying(e) and not sd['air']: continue
                ex, ey = posat(s.segs, e['d'])
                if e['hidden'] and not sd['detect'] and not s.minted(e, (ex, ey)): continue
                if math.dist((ex, ey), (p['cx'], p['cy'])) <= rng + 1e-9: cands.append(e)
            if not cands: continue
            p['cd'] = 1.0 / rate
            if sd.get('burnaura'):
                bd, bt = sd['burnaura']
                for e in cands:
                    e['burn'] = bd * LVL_DMG[p['lvl']] * s.dmgm * p['rm'] * (0.5 if p['grow'] > 0 else 1.0); e['burnt'] = bt
                continue
            if sd.get('aura'):
                for e in cands:
                    s.dmg(e, dm, sd['dtype'], True)
                    if sd.get('auraslow') and not s.flying(e):
                        a = sd['auraslow']
                        if e['slow'] <= a or e['slowt'] <= 0: e['slow'] = a; e['slowt'] = 0.5
                continue
            ntarg = sd.get('targets', 1)
            tgts = sorted(cands, key=lambda e: -e['d'])[:ntarg] if ntarg > 1 else [max(cands, key=lambda e: e['d'])]
            for tgt in tgts:
                m = 1.0
                pd = PESTS[tgt['id']]
                if s.flying(tgt) and sd.get('airmult'): m = sd['airmult']
                if pd.get('heavy') and sd.get('heavymult'): m = sd['heavymult']
                if pd.get('boss') and sd.get('bossmult'): m = sd['bossmult']
                if sd.get('splash'):
                    tx, ty = posat(s.segs, tgt['d'])
                    for e in s.pests:
                        if s.flying(e) and not sd.get('airsplash'): continue
                        if s.untouchable(e): continue
                        if e['hidden'] and not s.minted(e) and not sd['detect']: continue
                        ex, ey = posat(s.segs, e['d'])
                        if math.dist((ex, ey), (tx, ty)) <= sd['splash'] + 1e-9: s.dmg(e, dm, sd['dtype'])
                else:
                    s.dmg(tgt, dm * m, sd['dtype'], sd.get('crack', False))
                if sd.get('slow'):
                    sa = sd['slow'][0] + (0.01 * (p['rank'] - 1) if p['rank'] > 1 else 0)
                    if tgt['slow'] <= sa or tgt['slowt'] <= 0:
                        tgt['slow'] = sa; tgt['slowt'] = sd['slow'][1]
                if sd.get('burn'):
                    tgt['burn'] = sd['burn'][0] * LVL_DMG[p['lvl']] * s.dmgm * (p['rm'] if p['rank'] > 1 else 1); tgt['burnt'] = sd['burn'][1]
                if sd.get('sour'):
                    tgt['sour'] = sd['sour'][0]; tgt['sourt'] = sd['sour'][1]
                if sd.get('knock') and not pd.get('boss') and not pd.get('unslow'):
                    k = sd['knock'] * (0.5 if pd.get('heavy') else 1.0)
                    tgt['d'] = max(0.0, tgt['d'] - k)
        for e in list(s.pests):
            if e['hp'] <= 0:
                pd = PESTS[e['id']]
                rw = pd['reward'] * s.sapm
                if s.n == 1:
                    s.slots[0]['sap'] += round(rw)
                else:
                    for sl in s.slots: sl['sap'] += round(rw * s.share)
                ex, ey = posat(s.segs, e['d'])
                for q in s.plants:
                    if q['seed'] == 'saltbush' and q['grow'] == 0 and math.dist((ex, ey), (q['cx'], q['cy'])) <= SEEDS['saltbush']['rng'] + 1e-9:
                        s.slots[q['owner']]['sap'] += 2 + (1 if q['rank'] >= 5 else 0) + (1 if q['rank'] >= 10 else 0)
                        break
                if pd.get('stink'):
                    m, tt, r = pd['stink']
                    for q in s.plants_near(ex, ey, r):
                        q['deb'] = min(q['deb'], m) if q['debt'] > 0 else m; q['debt'] = max(q['debt'], tt)
                s.pests.remove(e)
                if pd.get('split'):
                    cid, n = pd['split']
                    for k in range(n):
                        s.pests.append(_newpest(cid, s.hp_scale, max(0, e['d'] - 0.3 * k)))

    def spent(s, p):
        c = SEEDS[p['seed']]['cost']; tot = c
        for l in range(p['lvl']): tot += round(c * UPG_COST[l])
        return tot


def run_script_coop(field, waves, script, research=None, hp_extra=1.0):
    """Runs a version 1 reference script with the v2 engine, one player (regression)."""
    r = CoopRun(field, [dict(loadout=None)], research, hp_extra)
    queue = list(script)
    for wi in range(len(waves)):
        while queue:
            st = queue[0]
            if st[0] == 'p': ok = r.place(st[1], st[2], st[3])
            else:
                idx = [i for i, p in enumerate(r.plants) if p['x'] == st[1] and p['y'] == st[2]]
                ok = r.upgrade(idx[0])
            if ok: queue.pop(0)
            else: break
        if not r.play_wave(waves): return False, wi, r
    return True, len(waves), r
