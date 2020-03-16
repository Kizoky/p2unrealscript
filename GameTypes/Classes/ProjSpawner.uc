///////////////////////////////////////////////////////////////////////////////
// ProjSpawner
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
// 
// Shoots out grenades, rockets, etc.
//
// Can't do 'num to keep alive', becuase projectiles don't trigger there
// event on death, like pawns. Wish they would have. 
//
// Also, in the future, projectiles should have a spawner setup function
// rather than doing it in the spawner, like in SpecificInits.
///////////////////////////////////////////////////////////////////////////////

class ProjSpawner extends Spawner
	placeable;

var ()vector SpawnAcceleration; // acceleration used by projectile
var ()float ExitSpeed;			// Speed with which we are emitted in the direction the spawner faces
var ()float ExitSpeedRange;     // From 0 to this number is randomly added to the direction for velocity
var ()float FuelTime;			// How much 'fuel' is given to the projectile, if it takes fuel
var ()float StartSpinMag;		// How fast they spin, 0 for no spinning
var ()Sound ExitSound;			// Sound made on spawn
var ()int	SpawnHealth;	// Starting health of projectile
var ()StaticMesh SpawnStaticMesh;//stmesh to use instead of normal one

///////////////////////////////////////////////////////////////////////////////
// Do specific things to the spawned object, like to pawns
///////////////////////////////////////////////////////////////////////////////
function SpecificInits(Actor spawned)
{
	local Projectile proj;

	// Tell them they used the wrong spawner
	if(FPSPawn(spawned) != None)
		log(self$" Use a pawn spawner instead "$spawned);

	proj = Projectile(spawned);
	if(proj != None)
	{
		// Change static mesh if specified
		if(SpawnStaticMesh != None)
		{
			proj.SetStaticMesh(SpawnStaticMesh);
			proj.SetDrawType(DT_StaticMesh);
		}
		// Add in fuel for rockets and set their state, they're more complicated than most projs
		if(LauncherProjectile(proj) != None)
		{
			// For seeking ones, pick a target
			if(LauncherSeekingProjectileTrad(proj) != None)
			{
				LauncherSeekingProjectileTrad(proj).DetermineTarget(Location);
			}
			LauncherProjectile(proj).LifeSpan = FuelTime;
			LauncherProjectile(proj).StartFlyTime=Level.TimeSeconds;
			LauncherProjectile(proj).GotoState('Flying');
		}
		// Arm the grenade
		if(GrenadeProjectile(proj) != None)
		{
			GrenadeProjectile(proj).DetonateTime = FuelTime;
			proj.SetTimer(FuelTime,false);
		}

		// Make normal projectiles get thrown out by a speed
		if(P2Projectile(proj) != None)
		{
			proj.Speed = ExitSpeed;
			proj.Velocity = vector(Rotation)*ExitSpeed;
			proj.Velocity += (ExitSpeedRange*VRand());
			proj.Acceleration = SpawnAcceleration;
			P2Projectile(proj).StartSpinMag=StartSpinMag;
			P2Projectile(proj).RandSpin(StartSpinMag);
			P2Projectile(proj).Health = SpawnHealth;
		}
		else
		{
			proj.Velocity = vector(Rotation)*ExitSpeed;
			proj.Velocity += (ExitSpeedRange*VRand());
			proj.Acceleration = SpawnAcceleration;
		}

		// Play exit sound
		if(ExitSound != None)
			PlaySound(ExitSound, SLOT_Misc, 1.0, false, 512.0, 1.0);
	}
	else
		log(self$" Don't spawn this "$spawned$" with a projspawner, it's for projectiles/bombs only");
}

defaultproperties
{
	SpawnAcceleration=(Z=-800.000000)
	ExitSpeed=500.000000
	ExitSpeedRange=50.000000
	FuelTime=6.000000
	StartSpinMag=20000.000000
	SpawnHealth=4
	SpawnClass=Class'Inventory.GrenadeProjectile'
	NumToKeepAlive=0
	bSpawnWhenNotSeen=False
	Texture=Texture'PostEd.Icons_256.ProjSpawner'
	DrawScale=0.25
}
