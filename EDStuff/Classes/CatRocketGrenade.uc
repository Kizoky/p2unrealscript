// CatRocketGrenade
// Cat rockets shot by the grenade launcher in enhanced mode.
class CatRocketGrenade extends CatRocket;

const FORCE_RAD_CHECK		= 50;

var() float LifeTime;				// After this much time we explode even if we haven't hit anything
var() array<Material> CatSkins;		// Skins for cat

simulated event PostBeginPlay()
{
	Skins[0] = CatSkins[Rand(CatSkins.Length - 1)];
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
}

defaultproperties
{
	bDoBounces=True
	LifeSpan=0
	LifeTime=30
	CatSkins[0]=Texture'AnimalSkins.Cat_Black'
	CatSkins[1]=Texture'AnimalSkins.Cat_Grey'
	CatSkins[2]=Texture'AnimalSkins.Cat_Orange'
	CatSkins[3]=Texture'AnimalSkins.Cat_Siamese'
}