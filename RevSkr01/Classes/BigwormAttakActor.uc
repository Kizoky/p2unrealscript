//=============================================================================
// Erik Rossik.
// Revival Games 2014.
// BigwormAttakActor.
//=============================================================================
class BigwormAttakActor extends Actor
	placeable;

var pawn victim;
var WormsControl WC;
var () name AttakAnim1,AttakAnim2;
var int attakmode;
var () int health;
var () class<emitter> wormsexplosion;
var () class<emitter> SandSplash;
var () sound Attaksounds[4],explodesounds[2];

replication
{
	unreliable if (Role==ROLE_Authority)
      	victim,attakmode;
}


simulated Event PostNetBeginPlay()
{ 
 local kactor Vh;

 if(victim != none)
 {
 PlaySound(	Attaksounds[rand(2)],,soundVolume,,soundRadius,soundPitch);

 If(attakmode == 0)
 {
  PlayAnim(AttakAnim1,1);
  Spawn(SandSplash,,,location);
 if(victim.Physics != Phys_ladder)
  {
   victim.TakeDamage(10000000, none, vect(0,0,0), vect(0,0,0), none);
   victim.kaddimpulse(vect(0,0,200000),victim.location);
   settimer(0.6,false);
  }
  else 
  {
   foreach radiusactors(class 'kactor',Vh, 500, victim.location)
   {
    if(vh != none)
    {
     vh.kaddimpulse(vect(0,0,200000),victim.location);
    }
   }
  }
 }
 else if(attakmode == 1)
 {
   PlayAnim(AttakAnim2,1);
   Spawn(SandSplash,,,location);
 if(victim.Physics != Phys_ladder)
  {
   victim.TakeDamage(10000000, none, vect(0,0,0), vect(0,0,0), none);
   settimer(1,false);
  }
  else
  {
   foreach radiusactors(class 'kactor',Vh, 500, victim.location)
   {
    if(vh != none)
    {
     vh.kaddimpulse(vect(100000,0,100000)>> rotation,victim.location);
    }
   }
  }
 }
 }
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
		if(damage > 20)
		{

			Health -= damage;
			if(Health <= 0)
			{
             Spawn(wormsexplosion,,,location);
             WC.chanse -= 7;
             Destroy();
			}
			PlaySound(	explodesounds[rand(2)],,soundVolume,,soundRadius,soundPitch);
			Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		}
}


Simulated Function timer()
{
  victim.ChunkUp(0);
  victim.destroy();
}

defaultproperties
{
     AttakAnim1="Attak1"
     AttakAnim2="Attak2"
     Health=10
     wormsexplosion=Class'RevSkr01.WormExplosion'
     SandSplash=Class'RevSkr01.WormAttak'
     Attaksounds(0)=Sound'RevWormSo.Worm01'
     Attaksounds(1)=Sound'RevWormSo.Worm02'
     Attaksounds(2)=Sound'RevWormSo.Worm03'
     Attaksounds(3)=Sound'RevWormSo.Worm04'
     explodesounds(0)=Sound'WeaponSounds.flesh_explode'
     explodesounds(1)=Sound'WeaponSounds.flesh_explode'
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     LifeSpan=3.000000
     Mesh=SkeletalMesh'RevWormAnim.Ow7BigWorm'
     AmbientGlow=30
     SoundRadius=200.000000
     SoundVolume=255
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=True
     bBlockActors=True
     bProjTarget=True
}
