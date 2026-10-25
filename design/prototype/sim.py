import math, sys, copy

DT = 0.1

SEEDS = {
 # id: cost, grow, dmg, range, rate, dtype, flying, detect, extra
 'thorn':    dict(cost=60,  grow=0, dmg=8,  rng=2.5, rate=1.0, dtype='pierce', air=True,  detect=False),
 'sunpetal': dict(cost=75,  grow=1, dmg=0,  rng=0,   rate=0,   dtype=None,     air=False, detect=False, income=(20,30,45)),
 'burr':     dict(cost=70,  grow=1, dmg=3,  rng=2.0, rate=1.2, dtype='pierce', air=False, detect=False, slow=(0.30,2.0)),
 'nettle':   dict(cost=90,  grow=1, dmg=3,  rng=1.5, rate=2.0, dtype='poison', air=False, detect=False, aura=True),
 'dandelion':dict(cost=100, grow=1, dmg=8,  rng=4.0, rate=1.4, dtype='pierce', air=True,  detect=False, airmult=2.0),
 'pumpkin':  dict(cost=130, grow=2, dmg=22, rng=3.5, rate=0.4, dtype='blunt',  air=False, detect=False, splash=1.0),
 'mint':     dict(cost=110, grow=1, dmg=0,  rng=1.5, rate=0,   dtype=None,     air=False, detect=False, buff=(0.15,0.20,0.25)),
 'chilli':   dict(cost=150, grow=2, dmg=6,  rng=2.5, rate=0.8, dtype='fire',   air=True,  detect=False, burn=(6,3.0)),
 'snapjaw':  dict(cost=170, grow=2, dmg=55, rng=1.5, rate=0.4, dtype='bite',   air=False, detect=False, heavymult=2.0),
 'oak':      dict(cost=320, grow=3, dmg=30, rng=4.5, rate=0.8, dtype='pierce', air=True,  detect=True),
}
LVL_DMG = (1.0, 1.4, 1.9)
LVL_RNG = (0.0, 0.0, 0.5)
UPG_COST = (0.6, 1.0)

PESTS = {
 'aphid':   dict(hp=18,  spd=1.2, reward=3,  leak=1,  armour=0, res={}),
 'ant':     dict(hp=34,  spd=1.0, reward=4,  leak=1,  armour=0, res={}),
 'snail':   dict(hp=110, spd=0.5, reward=8,  leak=2,  armour=2, res={'poison':1.5}, heavy=True),
 'moth':    dict(hp=36,  spd=1.4, reward=5,  leak=1,  armour=0, res={}, fly=True),
 'caterpillar': dict(hp=140, spd=0.8, reward=10, leak=2, armour=0, res={'fire':1.5}, regen=4),
 'beetle':  dict(hp=200, spd=0.7, reward=12, leak=3,  armour=5, res={'pierce':0.75,'blunt':1.25}, heavy=True),
 'wasp':    dict(hp=70,  spd=1.7, reward=8,  leak=2,  armour=0, res={'poison':0.5}, fly=True),
 'mole':    dict(hp=170, spd=0.8, reward=14, leak=3,  armour=1, res={'blunt':1.25}, burrow=True),
 'slugmum': dict(hp=280, spd=0.5, reward=18, leak=4,  armour=0, res={'fire':0.5,'poison':1.5}, split=('aphid',3), heavy=True),
 'possum':  dict(hp=2600,spd=0.45,reward=150,leak=20, armour=4, res={'fire':0.75,'bite':1.25}, heavy=True, boss=True),
}

def expand(wps):
    pts=[(x+0.5,y+0.5) for x,y in wps]
    segs=[];L=0
    for a,b in zip(pts,pts[1:]):
        l=math.dist(a,b); segs.append((a,b,L,l)); L+=l
    tiles=set()
    for (x0,y0),(x1,y1) in zip(wps,wps[1:]):
        if x0==x1:
            for y in range(min(y0,y1),max(y0,y1)+1): tiles.add((x0,y))
        else:
            for x in range(min(x0,x1),max(x0,x1)+1): tiles.add((x,y0))
    return segs,L,tiles

def posat(segs,d):
    for a,b,s,l in segs:
        if d<=s+l:
            t=(d-s)/l if l else 0
            return (a[0]+(b[0]-a[0])*t, a[1]+(b[1]-a[1])*t)
    a,b,s,l=segs[-1]; return b

class Run:
    def __init__(s, field, research=None):
        s.f=field; s.segs,s.L,s.path=expand(field['path'])
        r=research or {}
        s.dmgm=1+r.get('dmg',0); s.ratem=1+r.get('rate',0); s.rngb=r.get('rng',0)
        s.sap=field['start']+r.get('startsap',0); s.hearts=20+r.get('hearts',0)
        s.sapm=1+r.get('sapm',0); s.hp_scale=field.get('hpScale',1.0)
        s.plants=[]; s.pests=[]; s.wave=0; s.time=0
        s.growbonus=r.get('grow',0)
        s.mods=r.get('mods',[])
        M=s.mods
        if 'drought' in M: s.sapm*=0.75; s.sap+=100
        s.sunm=2 if 'bloom' in M else 1
        if 'rainy' in M: s.growbonus+=1
        s.firem=1.3 if 'heatwave' in M else 1.0
        s.spdm=1.1 if 'heatwave' in M else 1.0
        if 'fog' in M: s.rngb-=0.5
        if 'swarm' in M: s.hp_scale*=0.7
        s.armb=2 if 'ironshell' in M else 0
        s.mintb=0.5 if 'nightshift' in M else 0
    def place(s,seed,x,y):
        sd=SEEDS[seed]
        if (x,y) in s.path or any(p['x']==x and p['y']==y for p in s.plants): return False
        if not(0<=x<12 and 0<=y<8): return False
        if s.sap<sd['cost']: return False
        s.sap-=sd['cost']
        s.plants.append(dict(seed=seed,x=x,y=y,lvl=0,grow=max(0,sd['grow']-s.growbonus),cd=0,cx=x+0.5,cy=y+0.5))
        return True
    def upgrade(s,i):
        p=s.plants[i]
        if p['lvl']>=2: return False
        c=round(SEEDS[p['seed']]['cost']*UPG_COST[p['lvl']])
        if s.sap<c: return False
        s.sap-=c; p['lvl']+=1; return True
    def buff(s,p):
        b=0
        for q in s.plants:
            if q['seed']=='mint' and q['grow']==0 and q is not p:
                if math.dist((q['cx'],q['cy']),(p['cx'],p['cy']))<=SEEDS['mint']['rng']+s.mintb+0.001:
                    b=max(b,SEEDS['mint']['buff'][q['lvl']])
        return b
    def revealed(s,e):
        if not e.get('hidden'): return True
        return False
    def dmg(s,e,amount,dtype,ignore_armour=False):
        pd=PESTS[e['id']]
        m=pd['res'].get(dtype,1.0)
        v=amount*m
        if dtype=='fire': v*=s.firem
        if not ignore_armour: v=max(1,v-pd['armour']-s.armb)
        e['hp']-=v
    def play_wave(s,waves):
        w=waves[s.wave]
        sched=[]
        for g in w:
            pid,cnt,gap,start=g
            for k in range(cnt): sched.append((start+k*gap,pid))
        sched.sort()
        t=0;si=0
        while True:
            while si<len(sched) and sched[si][0]<=t+1e-9:
                pid=sched[si][1]; pd=PESTS[pid]
                s.pests.append(dict(id=pid,hp=pd['hp']*s.hp_scale,max=pd['hp']*s.hp_scale,d=0,slow=0,slowt=0,burn=0,burnt=0,bt=0,ph=0,hidden=False))
                si+=1
            s.step(t)
            t+=DT
            if s.hearts<=0: return False
            if si>=len(sched) and not s.pests: break
            if t>600: break
        s.wave+=1
        s.sap+= 25+5*s.wave
        for p in s.plants:
            if p['grow']>0: p['grow']-=1
            if p['seed']=='sunpetal' and p['grow']==0: s.sap+=SEEDS['sunpetal']['income'][p['lvl']]*s.sunm
        return True
    def step(s,t):
        # move
        for e in s.pests:
            pd=PESTS[e['id']]
            if pd.get('burrow'):
                e['ph']=(e['ph']+DT)%5.0
                e['hidden']= e['ph']<3.0
            sp=pd['spd']*s.spdm*(1-(e['slow'] if e['slowt']>0 else 0))
            e['d']+=sp*DT
            if e['slowt']>0: e['slowt']-=DT
            if pd.get('regen') and e['burnt']<=0: e['hp']=min(e['max'],e['hp']+pd['regen']*DT)
            if e['burnt']>0:
                e['bt']+=DT
                if e['bt']>=0.5-1e-9:
                    e['bt']-=0.5; s.dmg(e,e['burn']*0.5,'fire',True)
                e['burnt']-=DT
        for e in list(s.pests):
            if e['d']>=s.L:
                s.hearts-=PESTS[e['id']]['leak']; s.pests.remove(e)
        # attack
        for p in s.plants:
            sd=SEEDS[p['seed']]
            if sd['rate']==0: continue
            rate=sd['rate']*s.ratem*(1+s.buff(p))
            p['cd']-=DT
            if p['cd']>0: continue
            rng=sd['rng']+LVL_RNG[p['lvl']]+s.rngb
            dm=sd['dmg']*LVL_DMG[p['lvl']]*s.dmgm*(0.5 if p['grow']>0 else 1.0)
            cands=[]
            for e in s.pests:
                pd=PESTS[e['id']]
                if pd.get('fly') and not sd['air']: continue
                if e['hidden'] and not sd['detect'] and not s.minted(e): continue
                ex,ey=posat(s.segs,e['d'])
                if math.dist((ex,ey),(p['cx'],p['cy']))<=rng+1e-9: cands.append(e)
            if not cands: continue
            p['cd']=1.0/rate
            if sd.get('aura'):
                for e in cands: s.dmg(e,dm,sd['dtype'],True)
            else:
                tgt=max(cands,key=lambda e:e['d'])
                m=1.0
                pd=PESTS[tgt['id']]
                if pd.get('fly') and sd.get('airmult'): m=sd['airmult']
                if pd.get('heavy') and sd.get('heavymult'): m=sd['heavymult']
                if sd.get('splash'):
                    tx,ty=posat(s.segs,tgt['d'])
                    for e in s.pests:
                        if PESTS[e['id']].get('fly'): continue
                        if e['hidden'] and not s.minted(e): continue
                        ex,ey=posat(s.segs,e['d'])
                        if math.dist((ex,ey),(tx,ty))<=sd['splash']+1e-9: s.dmg(e,dm,sd['dtype'])
                else:
                    s.dmg(tgt,dm*m,sd['dtype'])
                if sd.get('slow'):
                    if tgt['slow']<=sd['slow'][0] or tgt['slowt']<=0:
                        tgt['slow']=sd['slow'][0]; tgt['slowt']=sd['slow'][1]
                if sd.get('burn'):
                    tgt['burn']=sd['burn'][0]*LVL_DMG[p['lvl']]*s.dmgm; tgt['burnt']=sd['burn'][1]
        for e in list(s.pests):
            if e['hp']<=0:
                pd=PESTS[e['id']]
                s.sap+=round(pd['reward']*s.sapm)
                s.pests.remove(e)
                if pd.get('split'):
                    cid,n=pd['split']
                    for k in range(n):
                        c=PESTS[cid]
                        s.pests.append(dict(id=cid,hp=c['hp']*s.hp_scale,max=c['hp']*s.hp_scale,d=max(0,e['d']-0.3*k),slow=0,slowt=0,burn=0,burnt=0,bt=0,ph=0,hidden=False))
    def minted(s,e):
        ex,ey=posat(s.segs,e['d'])
        for q in s.plants:
            if q['seed'] in ('mint',) and q['grow']==0:
                if math.dist((ex,ey),(q['cx'],q['cy']))<=SEEDS['mint']['rng']+s.mintb+1e-9: return True
            if q['seed']=='oak' and q['grow']==0:
                pass
        return False

def run_script(field, waves, script, research=None, verbose=False):
    r=Run(field,research)
    queue=list(script)
    for wi in range(len(waves)):
        # build phase: do as many steps in order as affordable
        while queue:
            st=queue[0]
            if st[0]=='p': ok=r.place(st[1],st[2],st[3])
            else:
                idx=[i for i,p in enumerate(r.plants) if p['x']==st[1] and p['y']==st[2]]
                if not idx: raise Exception('no plant at %s'%(st,))
                ok=r.upgrade(idx[0])
            if ok: queue.pop(0)
            else:
                # if impossible placement (occupied/path) skip
                if st[0]=='p' and ((st[2],st[3]) in r.path): print('BAD TILE',st); queue.pop(0); continue
                break
        alive=r.play_wave(waves)
        if verbose: print(f" wave {wi+1}: hearts {r.hearts} sap {r.sap} plants {len(r.plants)} queue {len(queue)}")
        if not alive: return False, wi, r
    return True, len(waves), r
