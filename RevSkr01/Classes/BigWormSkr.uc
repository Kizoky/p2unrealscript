//=============================================================================
// Erik Rossik.
// Revival Games 2014.
// BigWormSkr.
//=============================================================================
class BigWormSkr extends Actor
	placeable;

var pawn victim;
var WormsControl WC;
var float ot;
var () class<Emitter> wormruneffect;
var int huntingmode;
var bool destroytime;



Simulated function tick(float deltatime)
{
 local vector HitLocation, HitNormal, vloc;
 local Actor Tr;
 local rotator frot;
 local float dist;
 local BigwormAttakActor BW;

 if(victim == none || victim.health <= 0)
 {
  WC.maxworm -= 1;
  Destroy();
 }

 If(level.timeseconds > ot + 0.2)
 {
  vloc = victim.location;
  vloc.z = location.z;

  Dist = vsize(location - vloc);
  Tr = Trace(HitLocation,HitNormal,location + vect(0,0,-1000000),Location,false);

 if(huntingmode == 0)
 {
  if(Dist > 100)
  {
   If(TerrainInfo(Tr) != none && WC.Testterrain(victim))
   {
    Spawn(wormruneffect,,,HitLocation);
   }
  }
  else If(TerrainInfo(Tr) != none && WC.Testterrain(victim))
  {
    if(victim.Physics != Phys_ladder)
    {
     BW = Spawn(class 'BigwormAttakActor',,,victim.location,Rotation); 
    }
    else
    {
     BW = Spawn(class 'BigwormAttakActor',,,victim.location + (vect(-100,0,0) >> rotation),Rotation); 
    }
   BW.victim = victim;
   BW.WC = WC;
   BW.attakmode = 1;
   BW.PostNetBeginPlay();
   WC.maxworm -= 1;
   Destroy();
  }
  else 
  {
   huntingmode = 1;
  }
  frot = Rotator(victim.location - location);
  frot.pitch = 0;
 if(victim.Physics != Phys_ladder)
  {
   velocity = vect(700,0,0) >> frot;
  }
  else
  {
   velocity = vect(2000,0,0) >> frot;
  }
  SetRotation(frot);
  destroytime = false;
 }
 else
 {
  if(Dist < 100)
  {
   If(TerrainInfo(Tr) != none && WC.Testterrain(victim))
   {
    if(victim.Physics != Phys_ladder)
    {
     BW = Spawn(class 'BigwormAttakActor',,,victim.location,Rotation); 
    }
    else
    {
     BW = Spawn(class 'BigwormAttakActor',,,victim.location + (vect(-100,0,0) >> rotation),Rotation); 
    }
    BW.victim = victim;
    BW.WC = WC;
    BW.PostNetBeginPlay();
    WC.maxworm -= 1;
    Destroy();
   }
  }
  else if (TerrainInfo(Tr) != none && WC.Testterrain(victim) && Dist > 2500)
  {
   huntingmode = 0;
  }
  else
  {
 Startdestroytime(true);
  }

  frot = Rotator(victim.location - location);
  frot.pitch = 0;
  velocity = vect(300,0,0) >> frot;
  SetRotation(frot);
 }
  ot = level.timeseconds;
 }

}

Function Startdestroytime(bool YN)
{
 If(destroytime != YN)
 {
  destroytime = YN;
  Settimer(rand(10),false);
 }
}

Function timer()
{
 If(destroytime)
 { 
  WC.maxworm -= 1;
  Destroy();
 }
}

defaultproperties
{
     wormruneffect=Class'RevSkr01.Wormrun'
     bHidden=True
     Physics=PHYS_Projectile
}
