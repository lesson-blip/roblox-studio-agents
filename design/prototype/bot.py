import math, datetime, statistics, sys
import sim, weekly
from sim import SEEDS, Run, LVL_DMG, LVL_RNG, UPG_COST

def coverage(r, x, y, rng):
    c=0
    for (tx,ty) in r.path:
        if math.dist((tx+0.5,ty+0.5),(x+0.5,y+0.5))<=rng+1e-9: c+=1
    return c

def best_tile(r, rng, lowest=False):
    best=None
    for y in range(8):
        for x in range(12):
            if (x,y) in r.path or any(p['x']==x and p['y']==y for p in r.plants): continue
            c=coverage(r,x,y,rng)
            key=(-c if lowest else c)
            if best is None or key>best[0]: best=(key,x,y,c)
    return best

def dps(seed,lvl):
    sd=SEEDS[seed]; return sd['dmg']*LVL_DMG[lvl]*sd['rate']

def bot_phase(r, pool, wave, loadout):
    hidden='mole' in pool; flying=any(p in pool for p in ('moth','wasp'))
    while True:
        acts=[]
        cnt=lambda s: sum(1 for p in r.plants if p['seed']==s)
        if wave<=6 and cnt('sunpetal')<2 and 'sunpetal' in loadout:
            b=best_tile(r,2.5,lowest=True)
            if b: acts.append((1e9,'p','sunpetal',b[1],b[2]))
        if hidden and cnt('mint')<1+ (wave//8) and wave>=2 and 'mint' in loadout:
            b=best_tile(r,1.5)
            if b: acts.append((1e8,'p','mint',b[1],b[2]))
        if flying and cnt('dandelion')<1+wave//6 and wave>=2 and 'dandelion' in loadout:
            b=best_tile(r,4.0)
            if b: acts.append((1e7,'p','dandelion',b[1],b[2]))
        for s in ('thorn','pumpkin','snapjaw'):
            if s not in loadout: continue
            sd=SEEDS[s]; b=best_tile(r,sd['rng'])
            if b: acts.append((dps(s,0)*b[3]/sd['cost'],'p',s,b[1],b[2]))
        for p in r.plants:
            sd=SEEDS[p['seed']]
            if p['lvl']>=2 or sd['rate']==0: continue
            c=round(sd['cost']*UPG_COST[p['lvl']])
            gain=(dps(p['seed'],p['lvl']+1)-dps(p['seed'],p['lvl']))*coverage(r,p['x'],p['y'],sd['rng']+LVL_RNG[p['lvl']+1])
            acts.append((gain/c,'u',p['x'],p['y'],c))
        acts.sort(key=lambda a:-a[0])
        done=False
        for a in acts:
            if a[1]=='p':
                if r.place(a[2],a[3],a[4]): done=True; break
                elif SEEDS[a[2]]['cost']>r.sap and a[0]>=1e7: return  # save for priority
            else:
                i=[k for k,p in enumerate(r.plants) if p['x']==a[2] and p['y']==a[3]][0]
                if r.upgrade(i): done=True; break
        if not done: return

LEVEL={'dmg':0.10,'rate':0.05,'startsap':0,'sapm':0.10}
NW=40
LOAD=['thorn','sunpetal','pumpkin','dandelion','mint','snapjaw']
def run_week(y,w):
    g=weekly.gen(y,w)
    waves=[[ (p,c,gap,st) for (p,c,gap,st,hpm) in wv] for wv in g['waves']]
    hpm=[[hpm for (p,c,gap,st,hpm) in wv] for wv in g['waves']]
    F=dict(name=g['title'],start=350,path=g['path'],hpScale=1.0)
    r=Run(F,dict(LEVEL,mods=g['mods']))
    pool=g['featured']
    for wi in range(NW):
        bot_phase(r,pool,wi+1,LOAD)
        # apply per-group hp multiplier approx: scale run hp_scale by max hpm
        r.hp_scale=max(hpm[wi])*(0.7 if 'swarm' in g['mods'] else 1.0)
        if not r.play_wave(waves): return wi, g
    return NW, g
if __name__=='__main__':
    d=datetime.date(2026,10,26); res=[]
    for i in range(int(sys.argv[1]) if len(sys.argv)>1 else 26):
        y,w,_=(d+datetime.timedelta(weeks=i)).isocalendar()
        n,g=run_week(y,w); res.append(n); print(y,w,g['template'],g['mods'],'cleared',n)
    print('median',statistics.median(res),'min',min(res),'max',max(res))
