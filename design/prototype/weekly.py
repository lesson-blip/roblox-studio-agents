import math, datetime
from sim import expand
M32=0xFFFFFFFF
class Prng:
    def __init__(s,isoYear,isoWeek):
        st=((isoYear*100+isoWeek)*2654435761) % 4294967296
        if st==0: st=0x9E3779B9
        s.x=st
        for _ in range(8): s.next()
    def next(s):
        x=s.x
        x^=(x<<13)&M32; x^=(x>>17); x^=(x<<5)&M32
        s.x=x&M32; return s.x
    def int(s,n): return (s.next()%n)+1
TEMPL=[('Long S',[(0,1),(10,1),(10,3),(1,3),(1,5),(10,5),(10,7)]),
       ('Hook',[(0,4),(5,4),(5,1),(9,1),(9,6),(11,6)]),
       ('Zig',[(0,0),(3,0),(3,4),(6,4),(6,1),(9,1),(9,7)]),
       ('Spiral',[(11,0),(1,0),(1,6),(9,6),(9,2),(4,2),(4,4)]),
       ('Short U',[(0,2),(8,2),(8,5),(0,5)]),
       ('Comb',[(0,6),(2,6),(2,1),(5,1),(5,6),(8,6),(8,1),(11,1)])]
MODS=[('drought','econ'),('bloom','econ'),('rainy','growth'),('heatwave','tempo'),('fog','sight'),('swarm','tempo'),('ironshell','armour'),('nightshift','sight')]
ADJ=['Dewy','Sunny','Misty','Windy','Frosty','Golden','Muddy','Leafy','Breezy','Rusty','Mossy','Dusty','Rainy','Sleepy','Prickly','Bright']
NOUN=['Paddock','Orchard','Allotment','Meadow','Hedgerow','Glasshouse','Courtyard','Vineyard','Creekbed','Verandah','Backyard','Terrace','Nursery','Clearing','Plot','Gully']
PESTS=['snail','moth','caterpillar','beetle','wasp','mole','slugmum']
THREAT={'aphid':2,'ant':3,'snail':8,'moth':4,'caterpillar':10,'beetle':16,'wasp':7,'mole':14,'slugmum':26,'possum':200}
MINW={'aphid':1,'ant':1,'snail':2,'moth':3,'caterpillar':4,'beetle':5,'wasp':6,'mole':5,'slugmum':8}
BOSS={15:1,30:2,45:3}
def gap_for(c):
    g=math.floor(10*12/c+0.5)/10
    return max(0.4,min(2.5,g))
NW=40
def gen(y,w):
    r=Prng(y,w); trace=[]
    ti=r.int(6); name,path=TEMPL[ti-1]
    mirror=r.int(2)==2
    if mirror: path=[(11-x,yy) for x,yy in path]
    m1=r.int(8); mod1=MODS[m1-1]
    allowed=[m for m in MODS if m[1]!=mod1[1]]
    m2=r.int(len(allowed)); mod2=allowed[m2-1]
    mods=[mod1[0],mod2[0]]
    title=ADJ[r.int(16)-1]+' '+NOUN[r.int(16)-1]
    pool=list(PESTS)
    for i in range(len(pool),1,-1):   # Fisher-Yates, i from n down to 2 (1-based)
        j=r.int(i)
        pool[i-1],pool[j-1]=pool[j-1],pool[i-1]
    featured=['aphid','ant']+pool[:4]
    minw=dict(MINW)
    if 'nightshift' in mods: minw['mole']=2
    waves=[]
    for n in range(1,NW+1):
        B=math.floor(30*1.16**(n-1))
        rem=B; groups=[]
        if n%15==0:
            BOSS[n]=n//15
        if n in BOSS:
            rem=B-BOSS[n]*THREAT['possum']
            if rem<math.floor(B*0.3): rem=math.floor(B*0.3)
            groups.append(['possum',BOSS[n]])
        allowedp=[p for p in featured if minw[p]<=n]
        if n>=12:
            big=[p for p in allowedp if p not in ('aphid','ant')]
            if big: allowedp=big
        p1=allowedp[r.int(len(allowedp))-1]; p2=allowedp[r.int(len(allowedp))-1]
        c1=max(1,math.floor(0.6*rem/THREAT[p1]))
        if p2==p1:
            c1=max(1,math.floor(rem/THREAT[p1])); grp=[[p1,c1]]
        else:
            c2=max(1,math.floor((rem-c1*THREAT[p1])/THREAT[p2])); grp=[[p1,c1],[p2,c2]]
        groups+=grp
        if 'swarm' in mods:
            for g in groups:
                if g[0]!='possum': g[1]=max(1,math.floor(g[1]*1.5))
        out=[]
        for k,(p,c) in enumerate(groups):
            hpm=1.0
            if c>40: hpm=math.floor(100*c/40)/100; c=40
            out.append((p,c,gap_for(c) if p!='possum' else 12.0,2.0*k,hpm))
        waves.append(out)
    return dict(template=name,ti=ti,mirror=mirror,mods=mods,title=title,featured=featured,path=path,waves=waves)
if __name__=='__main__':
    p=Prng(2026,44); print('seed state',((2026*100+44)*2654435761)%4294967296,[p.next() for _ in range(5)])
    for nm,wp in TEMPL:
        segs,L,t=expand(wp); print(nm,'len',round(L,1),'pathTiles',len(t),'build',96-len(t))
    for yw in [(2026,44),(2026,45),(2026,53),(2027,1)]:
        g=gen(*yw); print(yw,g['template'],g['mirror'],g['mods'],g['title'],g['featured'])
        for i in [0,4,9,19,24]: print('  wave',i+1,g['waves'][i])
