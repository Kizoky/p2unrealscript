// CatRocketGrenade
// Cat rockets shot by the Cat-Silenced Grenade Launcher
class CatRocketGrenade extends CatRocket;

const FORCE_RAD_CHECK		= 50;

var() float LifeTime;				// After this much time we explode even if we haven't hit anything
var() array<Material> CatSkins;		// Skins for cat
var() int MaxBounces;

simulated event PostBeginPlay()
{
	// Don't use random skins, use one of the cat we had in inventory.
	//Skins[0] = CatSkins[Rand(CatSkins.Length - 1)];
	Super.PostBeginPlay();
	SetTimer(LifeTime, false);
}

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
	
	simulated function HitWall (vector HitNormal, actor Wall)
	{
		// Bounce off static things, if you're supposed to
		if(BounceCount < MaxBounces
			&& bDoBounces)
		{
			BounceOffSomething(HitNormal, Wall);
		}
		else 
			WallExplosion(HitNormal, Wall);
	}
}

defaultproperties
{
	 bDoBounces=False
     LifeSpan=0
	 Lifetime=30
//	 CatSkins[0]=Texture'AnimalSkins.Cat_Black'
//	 CatSkins[1]=Texture'AnimalSkins.Cat_Grey'
//   CatSkins[2]=Texture'AnimalSkins.Cat_Orange'
//	 CatSkins[3]=Texture'AnimalSkins.Cat_Siamese'
	 speed=1200.000000
	 MaxBounces=3
}
