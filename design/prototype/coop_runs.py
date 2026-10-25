"""Version 2 balance runs (design/seed-siege-v2.md section 6).

python3 coop_runs.py --check     v2 engine reproduces the version 1 reference table
python3 coop_runs.py             v2 fields, 1 to 4 players, careful and casual bots
python3 coop_runs.py --quick     fewer casual seeds
"""
import math, random, sys, statistics
from functools import lru_cache
from multiprocessing import Pool
import sim2, fields2, fields, reference_runs as ref
from sim2 import SEEDS, PESTS, CoopRun, LVL_DMG, LVL_RNG, UPG_COST

# ---------------------------------------------------------------- regression
def check():
    ok_all = True
    for frost in (1.0, 1.4):
        for nm, F, W, S in [('Backyard Patch', fields.F1, fields.W1, ref.S1), ('Backyard lazy', fields.F1, fields.W1, ref.L1),
                            ('Veggie Rows', fields.F2, fields.W2, ref.S2), ('Night Orchard', fields.F3, fields.W3, ref.S3)]:
            F = dict(F, hpScale=F['hpScale'] * frost)
            for rn, R in [('R0', ref.R0), ('RMID', ref.RMID), ('RFULL', ref.RFULL)]:
                a = ref.run_script(F, W, S, R); b = sim2.run_script_coop(F, W, S, R)
                same = (a[0], a[1], a[2].hearts, a[2].sap) == (b[0], b[1], b[2].hearts, b[2].sap)
                ok_all &= same
                print(('same ' if same else 'DIFF ') + ('Frost ' if frost > 1 else '') + nm, rn,
                      'win %d hearts' % a[2].hearts if a[0] else 'lose wave %d' % (a[1] + 1))
    print('v2 engine reproduces v1:', ok_all)
    return ok_all

# ---------------------------------------------------------------- bots
@lru_cache(maxsize=None)
def cov_table(path_key, rng):
    path = list(path_key)
    _, _, tiles = sim2.expand(path)
    out = {}
    for y in range(8):
        for x in range(12):
            if (x, y) in tiles: continue
            out[(x, y)] = sum(1 for (tx, ty) in tiles if math.dist((tx+.5, ty+.5), (x+.5, y+.5)) <= rng + 1e-9)
    return out

ATTACKERS = [k for k, v in SEEDS.items() if v['rate'] > 0]
SUPPORT = {'sunpetal', 'saltbush', 'mint'}

def eff(seed, lvl, rank, flyers, bosses):
    sd = SEEDS[seed]
    if sd.get('burnaura'): base = sd['burnaura'][0] * 1.6
    elif sd.get('aura') or sd.get('crack'): base = sd['dmg'] * sd['rate']
    else: base = max(1.0, sd['dmg'] * LVL_DMG[lvl] * sim2.rank_mult(rank) - 2.0) / (LVL_DMG[lvl] * sim2.rank_mult(rank)) * sd['rate']
    m = 1.0
    if sd.get('splash'): m *= 1.8
    if sd.get('aura'): m *= 1.8
    if sd.get('targets'): m *= 2.0
    if sd.get('crack'): m *= 1.4
    if sd.get('sour'): m *= 1.6
    if sd.get('dmgbuff'): m *= 1.5
    if sd.get('knock'): m *= 1.5
    if sd.get('slow'): m *= 1.6
    if sd.get('burn'): m *= 1.5
    if sd.get('heavymult') or sd.get('bossmult'): m *= 1.3 if bosses else 1.1
    if flyers and sd['air']: m *= 1.2 * (sd.get('airmult', 1.0))
    return base * LVL_DMG[lvl] * m * sim2.rank_mult(rank)


class Bot:
    def __init__(s, slot, loadout, careful=True, rnd=None):
        s.slot = slot; s.loadout = loadout; s.careful = careful; s.rnd = rnd or random.Random(0)

    def tile(s, r, rng, lowest=False):
        tab = cov_table(tuple(r.f['path']), rng)
        opts = [(c, -y, -x, x, y) for (x, y), c in tab.items() if r.can_plant(s.slot, x, y)]
        if not opts: return None
        if lowest:
            opts.sort(key=lambda o: (o[0], -o[1], -o[2]))
        else:
            opts.sort(key=lambda o: (-o[0], -o[1], -o[2]))
        if not s.careful and len(opts) > 1:
            o = opts[s.rnd.randrange(min(4, len(opts)))]
        else:
            o = opts[0]
        return (o[3], o[4], o[0])

    def phase(s, r, pool, wave):
        hidden = 'mole' in pool
        flyers = any(PESTS[p].get('fly') for p in pool)
        bosses = any(PESTS[p].get('boss') or p == 'wombat' for p in pool)
        sl = r.slots[s.slot]
        acts_done = 0
        while True:
            if not s.careful and acts_done >= 1 and s.rnd.random() < 0.3: return
            mine = [p for p in r.plants if p['owner'] == s.slot]
            cnt = lambda k: sum(1 for p in mine if p['seed'] == k)
            acts = []
            if wave <= 6 and cnt('sunpetal') < (2 if r.n == 1 else (1 if wave < 4 else 2)) and 'sunpetal' in s.loadout and (s.careful or s.rnd.random() < 0.6):
                b = s.tile(r, 2.5, lowest=True)
                if b: acts.append((1e9, 'p', 'sunpetal', b[0], b[1]))
            if 'saltbush' in s.loadout and wave >= 2 and cnt('saltbush') < 1:
                b = s.tile(r, 2.0)
                if b: acts.append((5e8, 'p', 'saltbush', b[0], b[1]))
            if hidden and wave >= 2:
                rv = [k for k in ('mint', 'wollemi') if k in s.loadout]
                have = cnt('mint') + cnt('wollemi')
                det = any(SEEDS[k]['detect'] for k in s.loadout)
                if rv and have < 1 + wave // 8 and not (det and have >= 1):
                    k = rv[-1]; b = s.tile(r, 1.5)
                    if b: acts.append((1e8, 'p', k, b[0], b[1]))
            if flyers and wave >= 2:
                air = [k for k in s.loadout if k in ATTACKERS and SEEDS[k]['air'] and k != 'thorn']
                have = sum(1 for p in mine if p['seed'] in air)
                if air and have < 1 + wave // 6:
                    k = max(air, key=lambda k: eff(k, 0, sl['ranks'].get(k, 1), True, bosses) / SEEDS[k]['cost'])
                    b = s.tile(r, SEEDS[k]['rng'])
                    if b: acts.append((1e7, 'p', k, b[0], b[1]))
            for k in s.loadout:
                if k not in ATTACKERS: continue
                sd = SEEDS[k]
                b = s.tile(r, sd['rng'])
                if b: acts.append((eff(k, 0, sl['ranks'].get(k, 1), flyers, bosses) * b[2] / sd['cost'], 'p', k, b[0], b[1]))
            for i, p in enumerate(r.plants):
                if p['owner'] != s.slot: continue
                sd = SEEDS[p['seed']]
                if p['lvl'] >= 2 or sd['rate'] == 0: continue
                c = round(sd['cost'] * UPG_COST[p['lvl']])
                cov = cov_table(tuple(r.f['path']), sd['rng'] + LVL_RNG[p['lvl'] + 1]).get((p['x'], p['y']), 0)
                gain = (eff(p['seed'], p['lvl'] + 1, p['rank'], flyers, bosses) - eff(p['seed'], p['lvl'], p['rank'], flyers, bosses)) * cov
                acts.append((gain / c, 'u', i, c))
            acts.sort(key=lambda a: -a[0])
            if not s.careful and len(acts) > 2:
                head = acts[:3]; s.rnd.shuffle(head); acts = head + acts[3:]
            done = False
            for a in acts:
                if a[1] == 'p':
                    if r.place(a[2], a[3], a[4], s.slot): done = True; break
                    elif SEEDS[a[2]]['cost'] > sl['sap'] and a[0] >= 1e7: return
                else:
                    if r.upgrade(a[2], s.slot): done = True; break
            if not done: return
            acts_done += 1


# ---------------------------------------------------------------- stages
# A: a new player (no research, rank 1). B: about day 4 (RMID, ranks below).
# C: about day 21 (RFULL, 6 slots, more of the collection; ranks from collect.py).
STAGES = {
 'A': dict(research=ref.R0, ranks={},
           load={'backyard': ['thorn', 'sunpetal', 'burr'],
                 'veggie': ['thorn', 'sunpetal', 'burr', 'dandelion', 'wattle'],
                 'orchard': ['thorn', 'sunpetal', 'burr', 'dandelion', 'lilly']}),
 'B': dict(research=ref.RMID, ranks={'thorn': 2, 'sunpetal': 2, 'burr': 2, 'wattle': 2, 'lilly': 2},
           load={'backyard': ['thorn', 'sunpetal', 'burr', 'wattle', 'lilly'],
                 'veggie': ['thorn', 'sunpetal', 'dandelion', 'pumpkin', 'grevillea'],
                 'orchard': ['thorn', 'mint', 'pumpkin', 'dandelion', 'snapjaw']}),
 'C': dict(research=ref.RFULL, ranks={'thorn': 5, 'sunpetal': 5, 'wattle': 5, 'lilly': 5, 'dandelion': 4, 'grevillea': 4,
                                      'saltbush': 4, 'mint': 4, 'pumpkin': 4, 'macadamia': 4, 'banksia': 4,
                                      'bottlebrush': 3, 'snapjaw': 3, 'boab': 2},
           load={'backyard': ['thorn', 'sunpetal', 'wattle', 'lilly', 'grevillea', 'pumpkin'],
                 'veggie': ['wattle', 'sunpetal', 'grevillea', 'pumpkin', 'bottlebrush', 'boab'],
                 'orchard': ['wattle', 'sunpetal', 'mint', 'pumpkin', 'bottlebrush', 'boab']}),
}

def play(field_id, n, stage, careful, seed=0, frost=False):
    F, W = fields2.FIELDS[field_id]
    st = STAGES[stage]
    load = st['load'][field_id]
    slots = [dict(loadout=set(load), ranks=st['ranks']) for _ in range(n)]
    r = CoopRun(F, slots, st['research'], 1.4 if frost else 1.0)
    rnd = random.Random(seed * 7919 + n * 31 + len(field_id))
    bots = [Bot(i, load, careful, random.Random(rnd.random())) for i in range(n)]
    pool = set(g[0] for w in W for g in w)
    for wi in range(len(W)):
        for b in bots: b.phase(r, pool, wi + 1)
        if not r.play_wave(W): return False, wi + 1, r.hearts
    return True, len(W), r.hearts

def _job(a):
    return a, play(*a)

def table(seeds):
    jobs = []
    for f in ('backyard', 'veggie', 'orchard'):
        for stage in ('A', 'B', 'C'):
            for n in (1, 2, 3, 4):
                jobs.append((f, n, stage, True, 0))
                for sd in range(seeds): jobs.append((f, n, stage, False, sd))
    with Pool() as pool:
        res = dict(pool.map(_job, jobs, chunksize=4))
    for f in ('backyard', 'veggie', 'orchard'):
        print('\n' + f)
        print('stage | players | careful bot | casual bot win rate | casual median hearts (wins) | casual median loss wave')
        for stage in ('A', 'B', 'C'):
            for n in (1, 2, 3, 4):
                w, wave, h = res[(f, n, stage, True, 0)]
                car = 'win %d hearts' % h if w else 'lose wave %d' % wave
                cs = [res[(f, n, stage, False, sd)] for sd in range(seeds)]
                wins = [c for c in cs if c[0]]
                rate = 100 * len(wins) / len(cs)
                mh = statistics.median([c[2] for c in wins]) if wins else '-'
                ml = statistics.median([c[1] for c in cs if not c[0]]) if len(wins) < len(cs) else '-'
                print('%s | %d | %s | %d%% | %s | %s' % (stage, n, car, round(rate), mh, ml))

if __name__ == '__main__':
    if '--check' in sys.argv:
        sys.exit(0 if check() else 1)
    if '--one' in sys.argv:
        f, n, st = sys.argv[2], int(sys.argv[3]), sys.argv[4]
        print(play(f, n, st, True))
        sys.exit(0)
    table(20 if '--quick' in sys.argv else 40)
