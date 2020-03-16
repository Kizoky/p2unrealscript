///////////////////////////////////////////////////////////////////////////////
// ShotGunProjectile
// "Gyrojet" projectiles to be fired from the shotgun in enhanced mode.
///////////////////////////////////////////////////////////////////////////////
class ShotGunProjectile extends GrenadeProjectile;

var bool bBlownUp;

///////////////////////////////////////////////////////////////////////////////
// Send it with a certain speed and arm it
///////////////////////////////////////////////////////////////////////////////
function SetupShot()
{
	local vector Dir;
	local rotator FuzzedRotation;
	
	const ROTATION_FUZZ = 1024;
	
	// Fuzz the rotation a bit
	FuzzedRotation.Roll = Rotation.Roll + ROTATION_FUZZ - Rand(ROTATION_FUZZ*2);
	FuzzedRotation.Pitch = Rotation.Pitch + ROTATION_FUZZ - Rand(ROTATION_FUZZ*2);
	FuzzedRotation.Yaw = Rotation.Yaw + ROTATION_FUZZ - Rand(ROTATION_FUZZ*2);
	
	SetRotation(FuzzedRotation);

	Dir = vector(Rotation);

	Velocity = speed * Dir;
	//Velocity.Z = 0;
	//Velocity.z += TossZ;
	
	MakeSmokeTrail();
	RandSpin(StartSpinMag);
}

///////////////////////////////////////////////////////////////////////////////
// We can hurt ourselves with this if it's bounced once.
// Otherwise, it hurts everyone else all the same
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	// Only allow touch on world objects or pawns.
	if (Other.bStatic
		|| Pawn(Other) != None)
		Super.ProcessTouch(Other, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	GenExplosion(Location, HitNormal, Wall);
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
		exp = spawn(class'MiniExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal);
		exp.CheckForHitType(Other);
		exp.ShakeCamera(exp.ExplosionDamage);
		exp.ForceLocation = WallHitPoint;
	}

	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Take damage or be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	//DrawType=DT_None
	StaticMesh=None
	DrawScale=0.25
	bUseCylinderCollision=true
	Acceleration=(Z=0)
	Speed=1200
	//Physics=PHYS_Flying
}