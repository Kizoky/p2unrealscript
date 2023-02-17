class FGrenadeProjectile extends GrenadeProjectile;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// we got made successfully, so take the ammo
	P2AmmoInv(Pawn(Owner).Weapon.AmmoType).UseAmmoForShot();
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local FGrenadeExplosion exp;
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
		exp = spawn(class'FGrenadeExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal); //change this
		exp.ShakeCamera(exp.ExplosionDamage);
		exp.ForceLocation = WallHitPoint;
	}
 	Destroy();
}

defaultproperties
{
	TransientSoundRadius=60
	 MyDamageType=class'FlashBangDamage'
	 Speed=1200
     MaxSpeed=2800.000000
	 Damage=0.000000	// these two are handled in the FX explosion
	 DamageRadius=0
     MomentumTransfer=80000
	 //ExplosionDecal=class'BlastMark'
     CollisionRadius=+00018.000000
     CollisionHeight=+00018.000000
     bBounce=true
	 bFixedRotationDir=true
	 RotationRate=(Yaw=50000)
	 DrawType=DT_StaticMesh
 	 StaticMesh=StaticMesh'MrD_PL_Mesh.Weapons.Flash_Nade_NoPin'
     AmbientGlow=64
	 DetonateTime=4
	 MinSpeedForBounce=100
	 VelDampen=0.6
	 RotDampen=0.85
	 StartSpinMag=20000
	 Acceleration=(Z=-1000)
	 Health=4
	 MinChargeTime=0.5
	 MinTossTime=0.1
	 UpRatio=0.45
	 ExploWallOut=0
	 GrenadeBounce=Sound'PL_FlashGrenadeSound.FlashGrenade_Bounce'
	 bProjTarget=true
	 bUseCylinderCollision=true
	 Lifespan=0.0
	 bArmed=true
	bNetTemporary=false
	bUpdateSimulatedPosition=true
	TransientSoundRadius=150
}
