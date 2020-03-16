///////////////////////////////////////////////////////////////////////////////
// AWElephantPawn for Postal 2 AW
//
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWElephantPawn extends ElephantPawn;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var class<P2Damage> CloserCutDamage;		// Damage that when hitting you, we need
											// to reposition the blood that hits us
var class<SideSprayBlood> SprayBloodClass;
var (PawnAttributes) float SledgeDamageHealthRatio;	// How health does the sledge take off, 1.0 for full health down to 0.0 for no health
var (PawnAttributes) float TakesFireDamage;
var (PawnAttributes) bool	bScytheStarter;
var (PawnAttributes) bool bScreenShake;		// If true, shakes screen while stampeding
var Sound ChargingSound;
var float ChargingVolume, ChargingRadius;


///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const FIN_BLAST		= 23;

///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if(bScytheStarter)
		SetTimer(1.0, false);
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Timer()
{
	// Redo some variables
	if(bScytheStarter)
	{
		AWGameState(AWGameSP(Level.Game).TheGameState).KillElephantsScythe=1;
		log(Self$" cheattest new fin stop "$AWGameSP(Level.Game).FinStop);
	}
}

///////////////////////////////////////////////////////////////////////////////
// shake the camera from the heavy elephant
///////////////////////////////////////////////////////////////////////////////
function ShakePlayerCamCharge(P2Player p2p)
{
	local float usemag, usedist;

	const MAX_SHAKE_DIST_QUICK = 1000.0f;
	const USE_CHARGE_MAG = 80.0f;

	// Find who did it first, then shake them
	if(p2p.Pawn != None
		&& p2p.Pawn.Physics != PHYS_FALLING)
	{
		usedist = VSize(p2p.Pawn.Location - Location);		
		if(usedist < MAX_SHAKE_DIST_QUICK)
		{
			usemag = ((MAX_SHAKE_DIST_QUICK - usedist)/MAX_SHAKE_DIST_QUICK)*USE_CHARGE_MAG;
			//if(usemag < MIN_MAG_FOR_SHAKE)
			//	return;

			p2p.ShakeView((usemag * 0.2 + 1.0)*vect(1.0,1.0,2.0), 
			   vect(1000,1000,1000),
			   0.3 + usemag*0.02,
			   (usemag * 0.3 + 1.0)*vect(1.0,1.0,2.0),
			   vect(800,800,800),
			   0.3 + usemag*0.02);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//	A blood splash here
///////////////////////////////////////////////////////////////////////////////
function BloodSpray(vector BloodHitLocation, vector Momentum)
{
	local vector BloodOffset, dir, HitLocation, HitNormal, checkpoint;
	local float tempf;
	local Actor HitActor;
	local SideSprayBlood sprayb;
	local vector usecross, forward1, up1;

	// Find direction to center
	dir = BloodHitLocation - Location;
	dir = Normal(BloodHitLocation - Location);
	// push it away from the his center
	BloodOffset = 0.2 * CollisionRadius * dir;
	// pull it up some from the bottom and pull it down from the top
	BloodOffset.Z = BloodOffset.Z * 0.75;

	////////////////
	forward1 = Normal(Location - BloodHitLocation);
	up1.z = 1.0;
	usecross = forward1 cross up1;
	sprayb = spawn(SprayBloodClass,self,,BloodHitLocation+BloodOffset,Rotator(dir));
	sprayb.SetSpray(usecross);

	
	////////////////
	// Blood that shoots onto the wall 
	// Check to see if you're close enough to the wall, to squirt blood on it.
	// Do this by coming out of the actor where we hit and continue along the path
	// that goes from the original hit point, toward the player. (So look 
	// behind the player)
	checkpoint = BloodHitLocation + DIST_TO_WALL_FOR_BLOODSPLAT*Normal(Momentum);
	//log("momentum "$Momentum);
	HitActor = Trace(HitLocation, HitNormal, checkpoint, BloodHitLocation, true);

	//log(self$" blood hit, hit actor "$HitActor);

	if ( HitActor != None
		&& HitActor.bStatic ) 
	{
		spawn(class'BloodMachineGunSplatMaker',self,,HitLocation,rotator(HitNormal));
	}

	////////////////
	// Drips of blood on the ground around you (smaller)
	if(FRand() <= 0.7)
	{
		DripBloodOnGround(Momentum);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Does damage effects (blood) and plays hit animations
// Do a better blood effect for scythes
///////////////////////////////////////////////////////////////////////////////
function PlayHit(float Damage, vector HitLocation, class<DamageType> damageType, vector Momentum)
{
	if (Damage <= 0 
		&& Controller != None
		&& !Controller.bGodMode )
		return;

	if(ClassIsChildOf(DamageType, class'BloodMakingDamage'))
	{
		if (Damage > 0) //spawn some blood
		{
			if(class'P2Player'.static.BloodMode())
			{
				if(ClassIsChildOf(DamageType, class'ScytheDamage'))
					BloodSpray(HitLocation, Momentum);
				else
					BloodHit(HitLocation, Momentum);
			}
		}

		if ( Health <= 0 )
		{
			if ( PhysicsVolume.bDestructive && (PhysicsVolume.ExitActor != None) )
				Spawn(PhysicsVolume.ExitActor);
			return;
		}
	}
	if ( Level.TimeSeconds - LastPainTime > 0.1 )
	{
		PlayTakeHit(HitLocation,Damage,damageType);
		LastPainTime = Level.TimeSeconds;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Record pawn dead, if player killed them
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
	{
		// If you don't kill them with a scythe, say you didn't
		if(!ClassIsChildOf(DamageType, class'ScytheDamage'))
		{
			AWGameState(AWGameSP(Level.Game).TheGameState).KillElephantsScythe=0;
			AWGameSP(Level.Game).FinStop = FIN_BLAST - 1;
			log(Self$" cheattest, died, setting fin stop "$AWGameSP(Level.Game).FinStop);
		}
	}

	Super.Died(Killer, damageType, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local vector Rot, Diff, dmom;
	local float dot1, dot2;

	// Take half on all fire damage
	if(ClassIsChildOf(damageType, class'BurnedDamage')
		|| damageType == class'OnFireDamage')
		Damage = TakesFireDamage*Damage;
	else  if(ClassIsChildOf(damageType, class'SledgeDamage'))
	{
		Damage = ((SledgeDamageHealthRatio*HealthMax)/FPSPawn(InstigatedBy).DamageMult);	// Turns it into health, not original damage
	}

	// Don't get hurt by other elephants (smashing damage)
	if(ClassIsChildOf(damageType, MyDamage))
		return;

	// Specifically pull scythe damage closer to make the blood effect nicer
	if(ClassIsChildOf(damageType, CloserCutDamage))
	{
		dmom = InstigatedBy.Location;
		dmom.z+=InstigatedBy.CollisionHeight;
		diff = Normal(dmom - Location);
		HitLocation = 0.5*CollisionRadius*diff + Location;
	}

	// Check for if this really hit me or not
	Rot = vector(Rotation);
	dmom = Momentum;
	dmom.z=0;
	dmom = Normal(dmom);
	dot1 = Rot Dot dmom;

	if(abs(dot1) > BODY_SIDE_DOT)
	{
		Diff = Normal(Location - HitLocation);
		dot2 = Rot Dot Diff;

		if(abs(dot2) > BODY_INLINE_DOT)
		{
			Super(AnimalPawn).TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		}
		else
			// no hit, so return without taking damage
			return;
	}
	else
	{
		Super(AnimalPawn).TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}

}


///////////////////////////////////////////////////////////////////////////////
// Play sound while charging
///////////////////////////////////////////////////////////////////////////////
function StartRunningSound()
{
	AmbientSound=ChargingSound;
	SoundVolume=ChargingVolume;
	SoundRadius=ChargingRadius;
}

///////////////////////////////////////////////////////////////////////////////
// Stop charging sound
///////////////////////////////////////////////////////////////////////////////
function StopRunningSound()
{
	AmbientSound=None;
	SoundVolume=default.SoundVolume;
	SoundRadius=default.SoundRadius;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dying
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
State Dying
{
	///////////////////////////////////////////////////////////////////////////////
	// Be able to still see blood as something dies
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
	{
		local vector Diff, dmom;
		// Specifically pull some cutting damage closer to make the blood effect nicer
		if(ClassIsChildOf(damageType, CloserCutDamage))
		{
			dmom = InstigatedBy.Location;
			dmom.z+=InstigatedBy.CollisionHeight;
			diff = Normal(dmom - Location);
			HitLocation = 0.5*CollisionRadius*diff + Location;
		}

		// If fire hit you, even dead, catch on fire for sure
		if(ClassIsChildOf(damageType, class'BurnedDamage'))
			SetOnFire(FPSPawn(instigatedBy), (damageType==class'NapalmDamage'));

		// If fire has killed me,
		// or we're on fire and we died,
		// then swap to my burn victim mesh
		if(damageType == class'OnFireDamage'
			|| ClassIsChildOf(damageType, class'BurnedDamage')
			|| MyBodyFire != None)
			SwapToBurnVictim();

		PlayHit(Damage, hitLocation, damageType, Momentum);
	}
}

defaultproperties
{
	CloserCutDamage=Class'BaseFX.CuttingDamage'
	SprayBloodClass=Class'AWEffects.SideSprayBlood'
	SledgeDamageHealthRatio=0.600000
	TakesFireDamage=0.500000
	ChargingSound=Sound'AWSoundFX.Elephant.elephant_charging'
	ChargingVolume=222.000000
	ChargingRadius=200.000000
	Trumpet=Sound'AWSoundFX.Elephant.elephant_trumpet'
	MyDamage=Class'AWEffects.ElephantSmashDamage'
	ControllerClass=Class'AWPawns.AWElephantController'
	TransientSoundRadius=300.000000
	bScreenShake=True
}
