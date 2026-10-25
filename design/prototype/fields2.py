"""Version 2 wave tables and pod drop tables (design/seed-siege-v2.md sections 3.5 and 5.3).
Same maps as fields.py; waves now bring the Aussie cast. Groups are
(pest, count, gap, start[, hpMult])."""
import fields

F1 = dict(fields.F1, name='Backyard Patch')
W1 = [
 [('aphid',4,1.5,0)],
 [('aphid',8,1.0,0)],
 [('ant',6,1.2,0),('blowie',5,1.0,4)],
 [('ant',10,1.0,0)],
 [('snail',2,4.0,0),('aphid',8,0.8,2)],
 [('ant',12,0.8,0),('stinkbug',3,2.5,6)],
 [('caterpillar',3,3.0,0),('ant',8,0.8,2)],
 [('snail',5,2.5,0),('blowie',10,0.6,1)],
 [('caterpillar',4,2.5,0),('ant',14,0.7,1)],
 [('kevin',1,1,0,0.35),('snail',4,2.0,2),('ant',12,0.6,4)],
]
F2 = dict(fields.F2, name='Veggie Rows', hpScale=1.25)
W2 = [
 [('ant',8,1.2,0)],
 [('aphid',14,0.7,0),('ant',4,1.0,5)],
 [('moth',6,1.2,0),('ant',8,1.0,2)],
 [('snail',4,2.5,0),('moth',6,1.0,3)],
 [('caterpillar',4,2.0,0),('blowie',12,0.6,1)],
 [('moth',10,0.8,0),('magpie',3,2.0,2)],
 [('beetle',3,3.5,0),('ant',14,0.6,2)],
 [('wasp',6,1.5,0),('toad',3,2.5,1)],
 [('caterpillar',6,1.8,0),('cocky',4,1.8,2)],
 [('slugmum',2,6.0,0),('magpie',6,1.2,2)],
 [('beetle',5,2.5,0),('wasp',8,1.2,3)],
 [('slugmum',3,4.0,0),('cocky',6,1.2,1)],
 [('toad',6,1.5,0),('wasp',10,1.0,2)],
 [('beetle',7,2.0,0),('slugmum',3,4.0,4),('blowie',20,0.4,1)],
 [('swoopy',1,1,0,0.6),('magpie',8,1.0,3),('beetle',5,2.0,2)],
]
F3 = dict(fields.F3, name='Night Orchard', hpScale=1.15)
W3 = [
 [('ant',10,1.0,0)],
 [('snail',3,2.5,0),('aphid',10,0.7,2)],
 [('mole',3,3.0,0),('ant',10,0.8,1)],
 [('moth',10,0.8,0),('caterpillar',3,2.5,2)],
 [('mole',5,2.5,0),('stinkbug',4,2.0,2)],
 [('beetle',4,3.0,0),('wasp',6,1.2,2)],
 [('slugmum',3,4.0,0),('mole',4,2.5,2)],
 [('flyingfox',4,2.5,0),('moth',12,0.7,1)],
 [('beetle',6,2.5,0),('mole',6,2.0,2)],
 [('possum',1,1,0),('ant',20,0.6,2)],
 [('wasp',14,0.7,0),('slugmum',3,4.0,2)],
 [('mole',10,1.5,0),('turkey',3,3.0,3)],
 [('caterpillar',10,1.2,0),('flyingfox',6,1.5,2)],
 [('slugmum',5,3.0,0),('beetle',7,2.0,1)],
 [('wombat',1,1,0),('mole',10,1.2,1),('moth',14,0.5,3)],
 [('beetle',10,1.6,0),('wasp',14,0.7,2)],
 [('turkey',5,2.5,0),('mole',10,1.4,2)],
 [('caterpillar',14,1.0,0),('flyingfox',8,1.6,2),('wasp',12,0.8,4)],
 [('mole',14,1.0,0),('slugmum',6,2.5,2),('beetle',8,1.6,4)],
 [('possum',1,1,0),('kevin',1,1,12,0.8),('beetle',10,1.5,2),('wasp',14,0.7,6),('mole',10,1.2,8)],
]
FIELDS = {'backyard': (F1, W1), 'veggie': (F2, W2), 'orchard': (F3, W3)}
BOSS_WAVES = {'backyard': {10}, 'veggie': {15}, 'orchard': {10, 15, 20}}

# Pod drop tables (v2 5.3). Tier chances in percent per draw, then the plants of each
# tier that drop on that field (equal shares, unsprouted plants count double).
DROPS = {
 'backyard': dict(tiers={'C':70,'U':25,'R':4.5,'RB':0.5,'BR':0,'CH':0},
                  plants={'C':['thorn','sunpetal','burr','wattle','lilly'],'U':['dandelion','roopaw','saltbush'],
                          'R':['pumpkin','macadamia'],'RB':['chilli'],'BR':[],'CH':[]}),
 'veggie':   dict(tiers={'C':55,'U':30,'R':11,'RB':3.4,'BR':0.5,'CH':0.1},
                  plants={'C':['thorn','wattle','lilly'],'U':['nettle','dandelion','grevillea','roopaw'],
                          'R':['banksia','pigface','mint'],'RB':['bottlebrush','fingerlime','snapjaw'],'BR':['boab'],'CH':['gumtree']}),
 'orchard':  dict(tiers={'C':45,'U':32,'R':15,'RB':6,'BR':1.6,'CH':0.4},
                  plants={'C':['sunpetal','burr'],'U':['saltbush','grevillea','nettle'],
                          'R':['mint','macadamia','pigface','pumpkin'],'RB':['chilli','snapjaw','fingerlime'],
                          'BR':['oak','waratah','boab'],'CH':['wollemi','gumtree']}),
}
FROST_TIERS = {'C':35,'U':32,'R':20,'RB':9,'BR':3,'CH':1}
BOSS_TIERS = {'C':0,'U':0,'R':70,'RB':24,'BR':5,'CH':1}
