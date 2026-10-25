"""How long a free player takes to collect each rarity tier (design/seed-siege-v2.md 5.6).

python3 collect.py [players]      default 2000 simulated players, 60 days

Uses the drop tables in fields2.py, the pod rules in v2 section 5 and the daily play
model of spec 4.5 (about 35 minutes a day at 1x), unchanged.
"""
import random, statistics, sys
import fields2
from sim2 import RARITY, TIERS, TIER_NAME

SPROUT = {'C': 5, 'U': 6, 'R': 6, 'RB': 5, 'BR': 3, 'CH': 2}
LADDER = {  # pods for level 1->2, 2->3, ... 9->10
 'C':  [10, 15, 20, 30, 40, 50, 65, 80, 100],
 'U':  [8, 12, 16, 24, 32, 40, 52, 64, 80],
 'R':  [6, 9, 12, 18, 24, 30, 39, 48, 60],
 'RB': [4, 6, 8, 12, 16, 20, 26, 32, 40],
 'BR': [3, 4, 6, 8, 11, 14, 18, 22, 28],
 'CH': [2, 3, 4, 5, 7, 9, 11, 14, 17],
}
PITY = [('R', 15), ('RB', 50), ('BR', 120), ('CH', 300)]  # tier or better within N draws
TI = {t: i for i, t in enumerate(TIERS)}

# Milestone gifts: (day, plant). Start: thorn and sunpetal. Then the version 1 unlock
# moments (spec 3.2), with the research seed nodes on the days spec 4.5 reaches them.
GIFTS = [(1, 'thorn'), (1, 'sunpetal'), (1, 'burr'), (1, 'dandelion'), (1, 'pumpkin'), (1, 'snapjaw'),
         (2, 'mint'), (3, 'nettle'), (5, 'chilli'), (12, 'oak')]

def day_runs(day):
    """(field, waves cleared, won) per run that day: spec 4.5 model."""
    if day == 1: return [('backyard', 10, True), ('veggie', 8, False)]
    if day == 2: return [('veggie', 15, True), ('veggie', 15, True)]
    if day in (3, 4): return [('orchard', 9, False), ('veggie', 15, True)]
    return [('orchard', 20, True), ('veggie', 15, True)]


class Player:
    def __init__(s, rnd):
        s.rnd = rnd
        s.level = {}      # plant -> 0 (seen, not sprouted) .. 10
        s.pods = {}       # pods towards the next step
        s.since = {t: 0 for t, _ in PITY}
        s.first = {}      # plant -> day sprouted

    def sprouted(s, p): return s.level.get(p, 0) >= 1

    def give_pod(s, p, day):
        t = RARITY[p]
        lv = s.level.get(p, 0)
        if lv >= 10: return  # turns into Petals
        s.pods[p] = s.pods.get(p, 0) + 1
        need = SPROUT[t] if lv == 0 else LADDER[t][lv - 1]
        if s.pods[p] >= need:
            s.pods[p] -= need; s.level[p] = lv + 1
            if lv == 0: s.first[p] = day

    def gift(s, p, day):
        if not s.sprouted(p):
            s.level[p] = 1; s.pods[p] = 0; s.first[p] = day
        else:
            for _ in range(SPROUT[RARITY[p]] * 2): s.give_pod(p, day)

    def pick_plant(s, plants, chosen=False):
        live = [p for p in plants if s.level.get(p, 0) < 10]
        if not live: live = plants
        if chosen:  # pity at Blue Ribbon or Champion: the player picks
            return min(live, key=lambda p: (s.sprouted(p), s.level.get(p, 0)))
        w = [2 if not s.sprouted(p) else 1 for p in live]
        return s.rnd.choices(live, w)[0]

    def draw(s, field, table, day):
        plants = fields2.DROPS[field]['plants']
        avail = [t for t in TIERS if plants[t] and table.get(t, 0) > 0]
        tier = s.rnd.choices(avail, [table[t] for t in avail])[0]
        forced = None
        for t, n in reversed(PITY):  # highest guarantee first
            if s.since[t] + 1 >= n and any(plants[u] for u in TIERS if TI[u] >= TI[t]):
                if TI[tier] < TI[t]:
                    tier = t if plants[t] else next(u for u in TIERS if TI[u] > TI[t] and plants[u])
                    forced = t
                break
        for t, _ in PITY:
            if TI[tier] >= TI[t]: s.since[t] = 0
            else: s.since[t] += 1
        p = s.pick_plant(plants[tier], chosen=(forced in ('BR', 'CH')))
        s.give_pod(p, day)


def simulate(nplayers=2000, days=60, seed=1):
    rnd = random.Random(seed)
    res = []
    for _ in range(nplayers):
        pl = Player(random.Random(rnd.random()))
        for d in range(1, days + 1):
            for gd, p in GIFTS:
                if gd == d: pl.gift(p, d)
            for f, waves, won in day_runs(d):
                base = fields2.DROPS[f]['tiers']
                for w in range(1, waves + 1):
                    pl.draw(f, base, d)
                    if w in fields2.BOSS_WAVES[f]:
                        for _ in range(2): pl.draw(f, fields2.BOSS_TIERS, d)
                if won:
                    for _ in range(2): pl.draw(f, base, d)
            if d % 7 == 1:  # one weekly run to wave 15: 3 draws on the Orchard table
                for _ in range(3): pl.draw('orchard', fields2.DROPS['orchard']['tiers'], d)
        res.append(pl)
    return res


def report(res, days=60):
    print('tier | plants | median day all sprouted | 90%% of players by day | not done by day %d' % days)
    for t in TIERS:
        plants = [p for p in RARITY if RARITY[p] == t]
        ds = []
        for pl in res:
            if all(p in pl.first for p in plants): ds.append(max(pl.first[p] for p in plants))
            else: ds.append(999)
        ds.sort()
        med = ds[len(ds) // 2]; p90 = ds[int(len(ds) * 0.9)]
        miss = sum(1 for x in ds if x == 999)
        print('%s | %d | %s | %s | %d%%' % (TIER_NAME[t], len(plants), med if med < 999 else '>%d' % days,
                                             p90 if p90 < 999 else '>%d' % days, round(100 * miss / len(ds))))
    fc = sorted(min([pl.first[p] for p in pl.first if RARITY[p] == 'CH'] or [999]) for pl in res)
    print('first Champion: median day %d, 90%% by day %d' % (fc[len(fc) // 2], fc[int(len(fc) * 0.9)]))
    allp = sorted(max(pl.first.values()) if len(pl.first) == len(RARITY) else 999 for pl in res)
    print('all 24 sprouted: median day %s, 90%% by day %s' % (allp[len(allp) // 2], allp[int(len(allp) * 0.9)]))


def levels_at(days_list=(7, 14, 28, 60), nplayers=500):
    print('day | plants sprouted (median) | average level of sprouted plants | plants at level 10')
    for d in days_list:
        res = simulate(nplayers, d, seed=2)
        sp = [len(pl.first) for pl in res]
        av = [statistics.mean(pl.level[p] for p in pl.first) for pl in res]
        mx = [sum(1 for p in pl.level if pl.level[p] >= 10) for pl in res]
        print('%d | %d | %.1f | %.1f' % (d, statistics.median(sp), statistics.median(av), statistics.mean(mx)))


if __name__ == '__main__':
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 2000
    report(simulate(n))
    levels_at()
    # draws per day in the model
    for d in (1, 2, 3, 5):
        tot = 0
        for f, w, won in day_runs(d):
            tot += w + 2 * sum(1 for b in fields2.BOSS_WAVES[f] if b <= w) + (2 if won else 0)
        print('day', d, 'draws', tot)
