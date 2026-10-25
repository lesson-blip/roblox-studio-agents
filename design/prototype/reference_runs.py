from sim import *
import fields
P=lambda s,x,y:('p',s,x,y)
U=lambda x,y:('u',x,y)
S1=[P('thorn',8,2),P('thorn',3,5),P('sunpetal',11,0),P('thorn',5,3),P('thorn',6,5),P('burr',8,3),
    U(8,2),U(3,5),P('thorn',5,2),U(5,3),U(6,5),P('burr',3,3),U(8,2),U(3,5),P('thorn',10,5),U(11,0)]
L1=[P('thorn',8,2),P('thorn',3,5),P('thorn',5,3)]
# F2 loadout: thorn sunpetal dandelion pumpkin snapjaw
S2=[P('thorn',4,1),P('thorn',7,3),P('sunpetal',0,7),P('dandelion',5,2),P('thorn',7,4),P('sunpetal',1,7),
    P('pumpkin',4,2),U(4,1),U(7,3),P('dandelion',8,5),P('pumpkin',8,3),U(5,2),U(4,2),P('thorn',10,4),U(0,7),U(1,7),
    P('snapjaw',5,5),U(8,5),U(8,3),U(5,2),U(4,2),U(4,1),U(7,3),P('pumpkin',2,1),U(2,1),P('dandelion',7,5),U(7,5),U(8,5),U(8,3),U(2,1),U(7,5),U(7,4),U(7,4)]
# F3 loadout: thorn mint pumpkin dandelion snapjaw
S3=[P('thorn',4,2),P('thorn',7,2),P('mint',7,4),P('pumpkin',5,2),P('dandelion',2,2),P('thorn',9,4),
    U(4,2),U(7,2),P('snapjaw',9,3),P('mint',2,4),P('pumpkin',7,5),U(5,2),U(2,2),P('dandelion',3,2),
    U(9,3),P('pumpkin',4,4),U(7,5),U(5,2),U(2,2),U(4,2),U(7,2),P('snapjaw',9,2),U(9,3),P('pumpkin',5,4),U(5,4),U(3,2),
    U(7,5),U(4,4),P('dandelion',9,5),U(9,5),U(9,2),U(5,4),U(3,2),U(4,4),U(9,5),U(9,2),U(9,4),U(9,4),U(7,4),U(2,4)]
R0={}
RMID={'dmg':0.10,'rate':0.05,'startsap':50,'sapm':0.10}
RFULL={'dmg':0.20,'rate':0.10,'startsap':100,'hearts':5,'sapm':0.20,'rng':0.25,'grow':1}
if __name__=='__main__':
    for frost in (1.0,1.4):
        for nm,F,W,S in [('Backyard Patch',fields.F1,fields.W1,S1),('Backyard lazy',fields.F1,fields.W1,L1),('Veggie Rows',fields.F2,fields.W2,S2),('Night Orchard',fields.F3,fields.W3,S3)]:
            F=dict(F,hpScale=F['hpScale']*frost); out=[]
            for rn,R in [('R0',R0),('RMID',RMID),('RFULL',RFULL)]:
                ok,wi,r=run_script(F,W,S,R); out.append(f"{rn}:{'win '+str(r.hearts)+' hearts' if ok else 'lose wave '+str(wi+1)}")
            print('Frost' if frost>1 else 'Normal',nm,' | '.join(out))
