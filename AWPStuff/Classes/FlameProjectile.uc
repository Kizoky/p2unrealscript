///////////////////////////////////////////////////////////////////////////////
// FlameProjectile
// By: Dopamine, Kamek
// For: Eternal Damnation
//
// Flamethrower projectile for Eternal Damnation.
//
// 7/30/07 (Kamek)
//		Set TossZ to 0, projectile should shoot straight now
//
///////////////////////////////////////////////////////////////////////////////
class FlameProjectile extends P2Projectile;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, etc.
///////////////////////////////////////////////////////////////////////////////

var() class<P2Emitter> FireEffectsClass; // Class name of our fire effects
var() class<P2Emitter> FireExplosionClass; // Class name of fire explosion
var() float FireEffectSizeMod; // How quickly the fire effects grow. For "show" only -- does not affect actual collision

var P2Emitter ArrowFire;

///////////////////////////////////////////////////////////////////////////////
// Set up our fire and attach it to the invisible projectile.
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	//Dopamine -- Set the flying arrow on fire
//	if (Level.NetMode != NM_DedicatedServer) // Change by NickP: MP fix
//	{ // End
  		if(Level.Game == None
  			|| !Level.Game.bIsSinglePlayer)
  			ArrowFire = spawn(FireEffectsClass, self,, Location);
  		else
  			// Send player as owner so it will keep up in slomo time
  			ArrowFire = spawn(FireEffectsClass, Instigator,, Location);
//	} // Change by NickP: MP fix

	//log("my ArrowFire is" @ ArrowFire);
	if (ArrowFire != None)
		ArrowFire.SetBase(Self);

	Velocity = GetThrownVelocity(Instigator, Rotation, 0.4);

	// Travel faster in enhanced mode.
	if (P2GameInfoSingle(Level.Game).VerifySeqTime() && Instigator.Controller.bIsPlayer)
	{
		Velocity = 3*Velocity;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Remove our fire, if it's not already destroyed.
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	//DOPAMINE - Destroy the arrow flame on impact
	if(ArrowFire != None)
	{
		//Dopamine - Destroy the arrow flame so it doesn't just stay forever
		ArrowFire.Destroy();
		ArrowFire = None;
	}

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Ignore damage
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType);

///////////////////////////////////////////////////////////////////////////////
// Dies when it hits a wall/floor
// Set fire to anything we touch
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	Wall.TakeDamage(Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);

	// Generate fire starter ring
	Explode(Location, HitNormal);
}

///////////////////////////////////////////////////////////////////////////////
// Damage target and die
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	// Don't damage ourself with it
	if (Other != Instigator)
	{
		// Breaks windows
		if(Window(Other) != None)
			Other.Bump(self);
		else
		{
			Other.TakeDamage(Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			Destroy();
		}
	}
	/*
	if ( Pawn(Other) == None
		|| !RelatedToMe(Pawn(Other)) )
	{

		// Die without exploding.
		Destroy();
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function Explode(vector HitLocation, vector HitNormal)
{
	//Dopamine - Generate explosion on impact
    spawn(FireExplosionClass, Instigator,, Location);
    Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Die if our fire goes out
// Gradually make the flames bigger
///////////////////////////////////////////////////////////////////////////////
simulated event Tick(float Delta)
{
	//log("my ArrowFire is" @ ArrowFire);
	if (ArrowFire == None)
	{
		// Cleans up log output
		ArrowFire = None;
		
		// Our emitter died out, so we die too.
		Destroy();
	}
	else
	{
		// Make our flame bigger
		ArrowFire.Emitters[0].SizeScale[1].RelativeSize += (FireEffectSizeMod * Delta);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default Properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	FireEffectsClass=class'FlameProjectileFire'
	FireExplosionClass=class'DynamicFireStarterRingSmall'
	FireEffectSizeMod=2.00
	MyDamageType=class'FireExplodedDamage'
	Speed=500.000000 // edit as desired
    MaxSpeed=2000.000000 // edit as desired
    Damage=25.000000 // edit as desired
	DamageMP=50 // edit as desired
	bRotatetoDesired=false
	bFixedRotationDir=true
	DrawType=DT_None
	CollisionHeight=18 // edit as desired
	CollisionRadius=18 // edit as desired
	bUseCylinderCollision=true
	TossZ=0
}
