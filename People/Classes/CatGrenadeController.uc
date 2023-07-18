///////////////////////////////////////////////////////////////////////////////
// AWCatController
// Copyright 2004 RWS, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class CatGrenadeController extends AWCatController;

const EXPLODE_SEARCH_RADIUS	=	2400;

///////////////////////////////////////////////////////////////////////////////
// If touched by someone it explodes
///////////////////////////////////////////////////////////////////////////////
event Touch(actor Other)
{
	local vector HitMomentum, HitLocation;
	local P2Pawn otherpawn;
	local AnimalPawn anpawn;
	local float fcheck;
	local P2PowerupInv Copy;
	local FPSGameInfo checkg;
	local Texture usedskin;
	local int IsTainted;

	otherpawn = P2Pawn(Other);
	
	if(MyPawn.Health > 0)
	{
		if(otherpawn != None
			&& otherpawn.Health > 0)
		{
			if(CatGrenadePawn(MyPawn).Grenade != None)
				CatGrenadePawn(MyPawn).Grenade.ExplodeCat();
		}
		else if(AnimalPawn(Other) != None
			&& AnimalPawn(Other).Health > 0)
		{
			if(CatGrenadePawn(MyPawn).Grenade != None)
				CatGrenadePawn(MyPawn).Grenade.ExplodeCat();
		}
		else if((Projectile(Other) != None
				|| Pickup(Other) != None)
			&& VSize(Other.Velocity) > 0)
			// if it's a thing that can move, like a thrown powerup
			// or a mover smashing me, run
		{
			DangerPos = Other.Location;
			GotoStateSave('RunAwayFromToucher');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Falling through the air (probably thrown)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallingGrenade
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, RespondToTalker, ForceGetDown, 
		MarkerIsHere, damageAttitudeTo, CheckForObstacles;

	///////////////////////////////////////////////////////////////////////////////
	// I've fallen to the ground
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		//log(self$" hit ground");
		MyPawn.SetAnimWalking();

		GotoStateSave('GrenadeThink');

		return true;
	}
	
	///////////////////////////////////////////////////////////////////////////////
	// Don't do anything to player yet
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		if(P2Pawn(Other) != None && !P2Pawn(Other).bPlayer)
			global.Touch(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make us flail our legs
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		//log(self@"begin state falling far crazy"@CatPawn(MyPawn).IsCrazy(),'Debug');

		// If we got thrown out and we're a crazy cat, go dervish instead
		//if (CatPawn(MyPawn).IsCrazy())
		//	GotoState('FallingStartDervish');

		MyPawn.SetPhysics(PHYS_FALLING);

		MyPawn.PlayThrownSound();

		MyPawn.PlayFalling();
	}
Begin:
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to nearest person and explode 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GrenadeThink extends Thinking
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, GetReadyToReactToDanger,
		StartledBySomething, RespondToTalker,
		ReadyForASniff, damageAttitudeTo, BodyJuiceSquirtedOnMe, GettingDousedInGas;

	///////////////////////////////////////////////////////////////////////////
	// Find a hapless victim somewhere around you
	///////////////////////////////////////////////////////////////////////////
	function bool PickRandomTarget()
	{
		local FPSPawn CheckP, KeepP;
		local float checkdist, keepdist;

		keepdist = EXPLODE_SEARCH_RADIUS;

		foreach VisibleCollidingActors(class'FPSPawn', CheckP, EXPLODE_SEARCH_RADIUS, MyPawn.Location)
		{
			// Don't dervish other cats or death things
			if(CatPawn(CheckP) == None
				&& OldAttachPawn != CheckP
				&& CheckP.Health > 0
				// If we're friends with the dude, don't latch onto him
				&& (!MyPawn.bPlayerIsFriend && !CheckP.IsPlayerPawn())
				)
			{
				checkdist = VSize(CheckP.Location - MyPawn.Location);
				if(checkdist < keepdist)
				{
					keepdist = checkdist;
					KeepP = CheckP;
				}
			}
		}

		if(KeepP != None)
		{
			MyPawn.SetPhysics(PHYS_Falling);
			SetEndGoal(KeepP, TINY_RADIUS);
			return true;
		}
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Use nearest pathnode that isn't where I already am
	///////////////////////////////////////////////////////////////////////////////
	function UseNearestPathNode(float UseRad, optional float usesize)
	{
		local PathNode nextpnode;
		local Actor backupnode;
		local vector HitNormal, HitLocation, checkpoint, usepoint;

		if(usesize == 0)
			usesize = DervishEndRadius;

		MyPawn.SetPhysics(PHYS_Falling);

		checkpoint = Pawn.Location;
		checkpoint.z += Pawn.CollisionHeight;

		foreach RadiusActors(class'PathNode', nextpnode, UseRad, Pawn.Location)
		{
			if(nextpnode != None
				&& nextpnode != PathNode(Pawn.Anchor)
				// Make sure you're not already heading here
				&& nextpnode != OldEndGoal
				&& (!MyPawn.bCanEnterHomes
					|| nextpnode.Tag == MyPawn.HomeTag))
			{
				if(FastTrace(nextpnode.Location, checkpoint))
				{
					if(FRand() < PATHNODE_FREQ)
					{
						usepoint = nextpnode.Location;
						usepoint.z-=PATHNODE_OFFSET;
						// we're not saving the point, so save the goal as an actor
						OldEndGoal = nextpnode;
						SetEndPoint(usepoint, usesize);
						return;
					}
					else
						backupnode = nextpnode;
				}
			}
		}

		// If you didn't find anything, try for some backups
		// If we don't have a backup, try the anchor
		if(backupnode == None)
			backupnode = Pawn.Anchor;
		// check to use the backup if we have any kind
		if(backupnode != None)
		{
			usepoint = backupnode.Location;
			usepoint.z-=PATHNODE_OFFSET;
			OldEndGoal = backupnode;
			SetEndPoint(usepoint, usesize);
		}
		else
			SetEndPoint(Pawn.Location, usesize);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Collide this way and search for the distance most closely matching our
	// desired distance.
	///////////////////////////////////////////////////////////////////////////////
	function TryThisDirection()
	{
		local vector checkpoint;
		local Actor HitActor;
		local vector HitLocation, HitNormal;

		// Try to make dir fit terrain
		checkpoint = EndGoal.Location;//MyPawn.Location + (CurrentDist*InterestVect);

		GetMovePointOrHugWalls(checkpoint, MyPawn.Location, 2048, true);
		checkpoint.z -= MyPawn.CollisionRadius;

		SetEndPoint(checkpoint, 2*DEFAULT_END_RADIUS);
	}

	///////////////////////////////////////////////////////////////////////////////
	// come back to this state again
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
/*
HurtWait:
	SetupMoveOpposite(Attacker);
	// clear your attacker 
	SetAttacker(None);
	Goto('StartMoving');
*/
Begin:
	Sleep(0.01);
	if(!PickRandomTarget())
	// Didn't find a valid point, so get nearest
	{
		// Also checks homenodes
		UseNearestPathNode(2048);
	}
StartMoving:
	SetNextState('GrenadeThink');
	GotoStateSave('RunToTarget');
}



defaultproperties
{
     InventoryGiveClass=None
}
