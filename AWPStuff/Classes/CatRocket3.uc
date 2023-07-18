///////////////////////////////////////////////////////////////////////////////
// CatRocket3 ( Exploding Cats )
// 
// by Man Chrzan for xPatch 2.0
//
// Ported from AWP to Postal 2 Cumplete.
// Just some cool Exploding Cats for our epic Cat Launcher.
// Now it also explodes when hitting the wall (in non-bouncy mode)! 
//
///////////////////////////////////////////////////////////////////////////////
class CatRocket3 extends CatRocket2;

const FORCE_RAD_CHECK		= 50;

simulated event Timer()
{
	GenExplosion(Location, Velocity, None);
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local GrenadeExplosion exp;
	local vector WallHitPoint;

	if(Role == ROLE_Authority)
	{
		if(Other != None
			&& Other.bStatic)
		{
			// Make sure the force of this explosion is all the way against the wall that
			// we hit
			WallHitPoint = HitLocation - FORCE_RAD_CHECK*HitNormal;
			Trace(HitLocation, HitNormal, WallHitPoint, HitLocation);
		}
		else
			WallHitPoint = HitLocation;
		exp = spawn(class'GrenadeExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal);
		exp.CheckForHitType(Other);
		exp.ShakeCamera(exp.ExplosionDamage);
		exp.ForceLocation = WallHitPoint;
	}
 	Destroy();
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		// Break through windows
		if(Window(Other) != None)
		{
			Other.Bump(self);
		}
		else if (Other != instigator) // explode on everything else
			GenExplosion(HitLocation,Normal(HitLocation-Other.Location), Other);
	}
	
	// Added by Man Chrzan: Make cats explode when hitting the wall too!
	simulated function HitWall (vector HitNormal, actor Wall)
	{
		// Bounce off static things, if you're supposed to
		if(BounceCount < BOUNCE_MAX
			&& bDoBounces)
		{
			BounceOffSomething(HitNormal, Wall);
		}
		else 
			WallExplosion(HitNormal, Wall);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: Explosion for hitting the wall.
///////////////////////////////////////////////////////////////////////////////
function WallExplosion( vector HitNormal, actor Wall )
{
	local GrenadeExplosion exp;
	local vector WallHitPoint;
	
	// Draw a blood splat on the ground
	if(class'P2Player'.static.BloodMode())
	{
		spawn(class'BloodMachineGunSplatMaker',self,,Location,rotator(HitNormal));
		spawn(class'GrenadeExplosion',self,,Location,rotator(HitNormal));
	}
	// Make a sound
	PlaySound(BouncingSound, , 1.0, , , 0.96 + FRand()*0.08);
	
	Destroy();

}

defaultproperties
{
}