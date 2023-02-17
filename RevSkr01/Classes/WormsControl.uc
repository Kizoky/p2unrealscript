//=============================================================================
// Erik Rossik.
// Revival Games 2014.
// WormsControl.
//=============================================================================
class WormsControl extends Actor
	placeable;

var() float maxradius;
var float ot,ct;
var int maxworm;
var int chanse;

function bool Testterrain(Pawn P)
{
 local vector HitLocation, HitNormal;
 local Actor Tr;

 If(p.physics == phys_ladder)
 {
  Tr = Trace(HitLocation,HitNormal,p.location - vect(0,0,100),P.Location,false);
  If(TerrainInfo(Tr) != none) return true;
 }
 else
 {
  Tr = Trace(HitLocation,HitNormal,p.location - vect(0,0,110),P.Location,True);
  If(TerrainInfo(Tr) != none) return true;
 }
}

Simulated function tick(float deltatime)
{
 local pawn p;
 local vector spawnloc,locd;
 local BigWormSkr nW;

 If(level.timeseconds > ct + 5 && chanse < 40)
 {
 chanse += 5;
 ct = level.timeseconds;
 }


 If(level.timeseconds > ot + 1)
 {
  Foreach allActors(class'pawn',p)
  {
   If(P != none && Testterrain(P))
   {
    spawnloc = generatelocation();
    spawnloc.X += P.Location.X;
    spawnloc.Y += P.Location.Y;

    if(maxworm <= 10 && Rand(100) < chanse)
    {
    nW = Spawn(class 'BigWormSkr',,,spawnloc);
    locd = P.location;
    locd.z = location.z;
    if(vsize(spawnloc-locd) < 2500) nW.huntingmode = 1;
    nW.victim = P;
    nW.WC = self;
    maxworm += 1;
    }
   }
  }
  ot = level.timeseconds;
 }
}


function vector generatelocation()
{
 local vector result;

 result.X = -maxradius + rand(maxradius*2);
 result.Y = -maxradius + rand(maxradius*2);

 result.Z = location.Z;

 return result;
}

defaultproperties
{
     bHidden=True
}
