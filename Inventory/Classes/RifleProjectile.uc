///////////////////////////////////////////////////////////////////////////////
// RifleProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Doesn't use projectile physics to move. It moves forward after a sleep
// with it's velocity and checks things along with the way with a Trace. If the
// trace hits a static thing, it stops the bullet. Otherwise, it damages the thing
// it hit, and calculates a distance to come out on the other side, and continues
// on *after* the next sleep so as not to chunk too much.
//
// Enhanced mode/RWS mode effect: exploding rifle rounds (makes a grenade explosion on contact)
//
///////////////////////////////////////////////////////////////////////////////
class RifleProjectile extends P2Projectile;


const FLESH_HIT_MAX	=	4;
const WAIT_TIME = 0.05;
const MIN_SIZE = 10.0;

var class<TimedMarker> PawnHitMarkerMade;	// danger made when bullet hits a pawn 
var class<TimedMarker> BulletHitMarkerMade;	// danger made when bullet hits dirt
var Sound FleshHit[FLESH_HIT_MAX];
var float FleshRad;
var vector Direction;
//var vector OldLocation;

const FORCE_RAD_CHECK	=	50;			// Distance to the wall to check for attaching
										// the rocket force to a wall (instead of having the force
										// applied at the explosion epicenter--this is to make sure
										// things get thrown up and away more often.


///////////////////////////////////////////////////////////////////////////////
// Send it off in the right direction
///////////////////////////////////////////////////////////////////////////////
function SetVelocity(vector Dir)
{
	Direction = Dir;
	Velocity = Speed*Direction;
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects (only in enhanced mode for the player)
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local RifleExplosion exp;
	local vector WallHitPoint, OrigLoc;
	local Actor ViewThing;

	if(Other != None
		&& Other.bStatic)
	{
		// Make sure the force of this explosion is all the way against the wall that
		// we hit
		OrigLoc = HitLocation;
		WallHitPoint = HitLocation - FORCE_RAD_CHECK*HitNormal;
		if(Trace(HitLocation, HitNormal, WallHitPoint, HitLocation) == None)
		{
			HitLocation = OrigLoc;
			WallHitPoint = OrigLoc;
		}
	}
	else
		WallHitPoint = HitLocation;

	exp = spawn(class'RifleExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal);
	exp.CheckForHitType(Other);
	exp.ShakeCamera(exp.ExplosionDamage);
	exp.ForceLocation = WallHitPoint;

 	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Flying through the air
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Moving
{
	ignores HitWall, Explode, Blowup, ProcessTouch, Touch, EncroachingOn;

	///////////////////////////////////////////////////////////////////////////////
	// Make people notice a body dropping limply before them from a sniper hit
	///////////////////////////////////////////////////////////////////////////////
	function TellNPCs(Actor Other, vector HitLocation)
	{
		if(Pawn(Other) != None)
		{
			// Set your enemy as the one you attacked.
			if(P2Player(Instigator.Controller) != None
				&& FPSPawn(Other) != None)
			{
				P2Player(Instigator.Controller).Enemy = FPSPawn(Other);
			}

			PawnHitMarkerMade.static.NotifyControllersStatic(
				Level,
				PawnHitMarkerMade,
				FPSPawn(Owner), 
				FPSPawn(Other), 
				PawnHitMarkerMade.default.CollisionRadius,
				HitLocation);
		}
		else	// wall hit.. still have them notice
		{
			BulletHitMarkerMade.static.NotifyControllersStatic(
				Level,
				BulletHitMarkerMade,
				FPSPawn(Owner), 
				None, 
				BulletHitMarkerMade.default.CollisionRadius,
				HitLocation);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// False means you hit something you can't go past so die.
	///////////////////////////////////////////////////////////////////////////////
	function bool ProcessTraceHit(Actor Other, out vector HitLocation, Vector HitNormal)
	{
		local Rotator NewRot;
		local float usesize;

		if ( Other == None )
		{
			return true;
		}

		if(P2GameInfoSingle(Level.Game) != None
			&& P2GameInfoSingle(Level.Game).VerifySeqTime()
			&& P2Pawn(Instigator) != None
			&& P2Pawn(Instigator).bPlayer)
		{
			GenExplosion(HitLocation, HitNormal, Other);
			return false;
		}

		TellNPCs(Other, HitLocation);

		if(Other.bStatic)
		{
			spawn(class'RifleBulletHitPack',Owner, ,HitLocation, Rotator(HitNormal));
			return false;
		}
		else 
		{
			Other.TakeDamage(class'RifleAmmoInv'.default.DamageAmount, Pawn(Owner), 
							HitLocation, Velocity, class'RifleAmmoInv'.default.DamageTypeInflicted);

			// If we're a guy (krotchy) who doesn't take head shots at all, stop the bullet completely)
			if(P2Pawn(Other) != None
				&& P2Pawn(Other).TakesRifleHeadShot == 0)
			{
				spawn(class'BulletSparkPack',Owner, ,HitLocation, Rotator(HitNormal));
				return false;
			}
			else if((Pawn(Other) != None 
					&& Other != Owner)
				|| PeoplePart(Other) != None
				|| CowheadProjectile(Other) != None)
			{
				Other.PlaySound(FleshHit[Rand(ArrayCount(FleshHit))],SLOT_Pain,,,FleshRad,GetRandPitch());
			}
			else if(Other.bBlockActors)
			{
				spawn(class'BulletSparkPack',Owner, ,HitLocation, Rotator(HitNormal));
			}
			// If it blocks rifle shots, stop it here
			if (PeoplePart(Other) != None && PeoplePart(Other).bStopsRifle)
				return false;
			// Move to the other side of the thing you hit
			usesize = Other.CollisionRadius + Other.CollisionHeight;
			if(usesize < MIN_SIZE)
				usesize = MIN_SIZE;
			HitLocation += Direction*(usesize);
		}
		return true;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Moves along next path and checks everything for hit damage. Goes through
	// pawns and windows, etc, till it hits static things.
	///////////////////////////////////////////////////////////////////////////////
	function TraceFire()
	{
		local vector HitLocation, HitNormal, StartTrace, EndTrace;
		local actor Other;
		
		//if(!SetLocation(OldLocation))
		//	Destroy();
		// Do collision test
		StartTrace = Location;
		EndTrace = StartTrace + Velocity*WAIT_TIME;

		Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,true);

		if ( Other == None )
			HitLocation = EndTrace;

		if(ProcessTraceHit(Other, HitLocation, HitNormal))
		{
			if(!SetLocation(HitLocation))
				Destroy();
			//else
			//{
			//	OldLocation = HitLocation;
			//}
		}
		else
			Destroy();

	}
	
	//function BeginState()
	//{
	//	OldLocation = Location;
	//}

Begin:
	TraceFire();
	Sleep(WAIT_TIME);
	Goto('Begin');
}

defaultproperties
{
	 Physics=PHYS_None
	 MyDamageType=class'RifleDamage'
     Speed=20000.000000
     MaxSpeed=20000.000000
     MomentumTransfer=50000
	 DrawType=DT_StaticMesh
	 //StaticMesh=None
	 StaticMesh'stuff.stuff1.scissors'
	 CollisionHeight=0
	 CollisionRadius=0
     bCollideActors=false
     bCollideWorld=false
	 bBlockPlayers=false
	 bBlockActors=false
	 bBlockZeroExtentTraces=false
	 bBlockNonZeroExtentTraces=false
	 LifeSpan=10.0
	 PawnHitMarkerMade=  class'PawnShotMarker'
	 BulletHitMarkerMade=class'BulletHitMarker'

	TransientSoundRadius=400
	FleshRad=200
}
