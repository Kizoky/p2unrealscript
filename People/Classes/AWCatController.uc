///////////////////////////////////////////////////////////////////////////////
// AWCatController
// Copyright 2004 RWS, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWCatController extends CatController;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
var float AttachTime;		// reset each quanta
var class<DamageType> DervishDamageClass;
var FPSPawn AttachPawn;		// pawn I'm attacking and attached to
var FPSPawn OldAttachPawn;	// Don't go after the old attach pawn right after you've stopped with him
var vector AttachOffset;	// offset from the our attacked guy
var vector AttachMoveVel;    // how fast we're moving around on our attach guy
var float TotalAttachTime;	// Make time is specified, when this is reached, we stop attach anyway
var float DervishDamageAmt;
var float SecondaryEndRadius;	// End radius used when travelling places. 
								// Changes based on dervish or not
var float DervishEndRadius;		// Secondary end radius used when dervish is active
var bool  bDervish;				// It's a dervish or not, controlled by TurnOn/OffDervish
var float DervishTime;			// How long to go for
var float DervishStartTime;		// Time we started
var float TargetAttachHealth;	// What health the attacked should be left with.

var float SeverDamageAmt;		// how much damage when we sever a limb
var class<DamageType> DervishSeverClass;
var Limb	PreciousLimb;		// Limb we want to grind to the bone

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const ATTACK_SEARCH_RADIUS	=	600;
const ATTACH_HURT_TIME		=	0.4;
const ATTACH_VEL_XY			=	40.0;
const ATTACH_VEL_Z			=	60.0;

const PATHNODE_FREQ			=	0.6;
const PATHNODE_OFFSET		=	45.0;
const TINY_RADIUS			=   5.0;
const HIT_MOMENTUM			=	10000;
const MAX_ATTACH_SPEED		=	1000;
const KICK_UP_VEL			=	500;

const GRIND_TIME			=	1.0;

const DERVISH_BONE			=	'DUMMY01';
const GUY_ATTACH_BONE		=	'MALE01 spine1';

const MOVE_BACK_DIST		=	700;

var name OldStateName;

// Cat Debugging
/*
function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.25, true);
}
event Timer()
{
	if (GetStateName() != OldStateName)
	{
		log(self@"changed states from"@OldStateName@"to"@GetStateName()@"Dervishing"@bDervish@"Mesh"@MyPawn.Mesh,'Debug');
		OldStateName = GetStateName();
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// start: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Find a closet actor with this tag (should be a pawn) and kick his butt
// If not tag, then start dervishing after the spawn anyways.
///////////////////////////////////////////////////////////////////////////////
function SetToAttackTag(Name AttackTag)
{
	local FPSPawn AttackHim;

	AttackHim = FPSPawn(FindNearestActorByTag(AttackTag));

	// check for some one to attack
	if(AttackHim != None)
	{
		SetAttacker(AttackHim);
		OldAttachPawn = AttackHim;
		DervishThisPawn(AttackHim);
	}
	else // just start dervishing anyways when you start, if no tag.
		TurnOnDervish();
}

///////////////////////////////////////////////////////////////////////////////
// This means to turn on a dervish immediately.
// Set AttackFreq to 0.0 if you don't want it to attack anyone and just
// buzz back and forth.
///////////////////////////////////////////////////////////////////////////////
function SetToStandWithGunReady()
{
	TurnOnDervish();
}

///////////////////////////////////////////////////////////////////////////////
// end: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Use nearest pathnode that isn't where I already am
///////////////////////////////////////////////////////////////////////////////
function bool UseNearestHomeNode(float UseRad, optional float usesize)
{
	local HomeNode nextpnode;
	local vector HitNormal, HitLocation, checkpoint;

	if(usesize == 0)
		usesize = DEFAULT_END_RADIUS;

	checkpoint = Pawn.Location;
	checkpoint.z += Pawn.CollisionHeight;

	foreach RadiusActors(class'HomeNode', nextpnode, UseRad, Pawn.Location)
	{
		if(nextpnode != None
			&& nextpnode != HomeNode(Pawn.Anchor)
			&& nextpnode != EndGoal
			&& (!MyPawn.bCanEnterHomes
				|| nextpnode.Tag == MyPawn.HomeTag))
		{
			if(FastTrace(nextpnode.Location, checkpoint))
			{
				SetEndGoal(nextpnode, usesize);
				return true;
			}
		}
	}

	// If you didn't find anything, do it right here
	if(Pawn.Anchor != None)
		SetEndGoal(Pawn.Anchor, usesize);
	else
		SetEndPoint(Pawn.Location, usesize);
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Trigger functionality:
// If you set InitAttackTag, triggering makes the cat go after that pawn
// If you don't and they're not bPlayerIsFriend or bNoTriggerAttackPlayer, 
// then they'll attack the player
// otherwise, they attack something random around them.
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	local FPSPawn keepp, PlayerP;

	keepp = FPSPawn(FindNearestActorByTag(CatPawn(MyPawn).InitAttackTag));

	if(keepp == None
		|| keepp.bDeleteMe
		|| keepp.Health < 0)
	{
		keepp = None;

		if(!MyPawn.bPlayerIsFriend
			&& !MyPawn.bNoTriggerAttackPlayer)
			keepp = GetRandomPlayer().MyPawn;
		else // go into dervish state anyways, and seek out whatever
			TurnOnDervish();
	}

	if(keepp != None)
	{
		OldAttachPawn = keepp;
		DervishThisPawn(keepp);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Find a player and kick his butt
///////////////////////////////////////////////////////////////////////////////
function SetToAttackPlayer(FPSPawn PlayerP)
{
	local FPSPawn keepp;

	if(PlayerP == None)
		keepp = GetRandomPlayer().MyPawn;
	else
		keepp = PlayerP;

	// check for some one to attack
	if(keepp != None)
	{
		OldAttachPawn = keepp;
		DervishThisPawn(keepp);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Call this outside of the DervishThink state.
///////////////////////////////////////////////////////////////////////////////
function DervishThisPawn(FPSPawn Other)
{
	TurnOnDervish(true);
	MyPawn.SetPhysics(PHYS_Falling);
	SetEndGoal(Other, TINY_RADIUS);
	bPreserveMotionValues=true;
	SetNextState('DervishThink');
	GotoStateSave('DervishMove');
}

///////////////////////////////////////////////////////////////////////////////
// I'm attacking or about to attack, so scare everyone around me
///////////////////////////////////////////////////////////////////////////////
function MakePeopleScared(class<AnimalAttackMarker> ADanger)
{
	ADanger.static.NotifyControllersStatic(
		Level,
		ADanger,
		MyPawn, 
		MyPawn, 
		ADanger.default.CollisionRadius,
		MyPawn.Location);
}

///////////////////////////////////////////////////////////////////////////
// Move in the same direction as heading for a bit more
///////////////////////////////////////////////////////////////////////////
function SetupMoveSameDirection()
{
	local vector dir, newloc;

	dir = vector(MyPawn.Rotation);
	dir.z = 0;
	dir = MOVE_BACK_DIST*dir;
	newloc = MyPawn.Location + dir;
	// go after a spot behind you for a bit
	SetEndPoint(newloc, DervishEndRadius);
}

///////////////////////////////////////////////////////////////////////////
// Move in the opposite direction of your hurter
///////////////////////////////////////////////////////////////////////////
function SetupMoveOpposite(FPSPawn Other)
{
	local vector dir, newloc;

	// Stop them and make it move around a little before it starts up again
	if(Other != None)
		dir = Normal(MyPawn.Location - Other.Location);
	else
		dir = VRand();
	dir.z = 0;
	dir = MOVE_BACK_DIST*dir;
	newloc = MyPawn.Location + dir;
	// go after a spot behind you for a bit
	SetEndPoint(newloc, DervishEndRadius);
}

///////////////////////////////////////////////////////////////////////////////
// An animal caller is trying to get you to come to it
///////////////////////////////////////////////////////////////////////////////
function RespondToAnimalCaller(FPSPawn Thrower, Actor Other, out byte StateChange)
{
	Super.RespondToAnimalCaller(Thrower, Other, StateChange);
	// Come out of dervish no matter what
	if(bDervish)
		TurnOffDervish(true);
}

///////////////////////////////////////////////////////////////////////////////
// Because animals are more simple, we can have a general 'startled' function
///////////////////////////////////////////////////////////////////////////////
function StartledBySomething(Pawn Meanie)
{
	InterestPawn = FPSPawn(Meanie);

	Super.StartledBySomething(Meanie);
}

///////////////////////////////////////////////////////////////////////////
// Something splashed him or something, so he may hiss, but might also run
///////////////////////////////////////////////////////////////////////////
function HissOrRun(Actor Other)
{
	if(FPSPawn(Other) != None)
		InterestPawn = FPSPawn(Other);

	Super.HissOrRun(Other);
}

///////////////////////////////////////////////////////////////////////////
// See if someone is close by doing something scary like running
//
// Returns the closest nice person
//
// We have to overwrite this completely and not use the Super in order
// to make it save the interestpawn
// 
///////////////////////////////////////////////////////////////////////////
function P2Pawn CheckForScaryPerson(float RadCheck)
{
	local FPSPawn CheckP, PickMe;
	local float closest, dist;

	// Only if they can see or hear things
	if(!MyPawn.bIgnoresSenses)
	{
		closest = RadCheck;

		// check all the pawns around me.
		ForEach VisibleCollidingActors(class'FPSPawn', CheckP, RadCheck, MyPawn.Location)
		{
			// Only check people not behind obstructions.
			if(FastTrace(MyPawn.Location, CheckP.Location))
			{
				// While we're looking through the people, if you come across a dog, tell him about
				// yourself, so he can attack you.. silly cats!
				if(DogController(CheckP.Controller) != None)
				{
					DogController(CheckP.Controller).InvestigatePrey(MyPawn);
				}

				// Let dogs, people and elephants scare cats but not cats
				if(CatController(CheckP.Controller) == None)
				{
					dist = VSize(CheckP.Velocity);
					// If he's moving and not walking (so running) run away
					if(dist > ((CheckP.GroundSpeed)/2 + 1))
					{
						InterestPawn = CheckP;
						DangerPos = CheckP.Location;

						MyPawn.PlayScaredSound();

						GotoStateSave('RunAway');

						return None;
					}
					// if not, then check how close the nice person is
					if(dist <= closest)
					{
						PickMe = CheckP;
					}
				}
			}
		}

		// Say this person around me was nice
		return P2Pawn(PickMe);
	}
	// Can't sense anyone
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// Set new target and pick path
// DOESN'T call Super.
// Doesn't extend, this overwrites. It does to ensure a good check
// radius when the dervish is in action
///////////////////////////////////////////////////////////////////////////////
function SetActorTarget(Actor Dest, optional bool bStrictCheck)
{
	local Actor DestResult;

	bMovePointValid = false;
	if(MoveTarget != None)
		OldMoveTarget = MoveTarget;
	MoveTarget = None;

	// Don't use the actor reachable test to walking to pathnodes--
	// always use the path system when walking to pathnodes. Otherwise,
	// test to possibly just walk there.
	if(PathNode(Dest) == None
		&& ActorReachable(Dest))
	{
		DestResult = Dest;
		MoveTarget = Dest;
		//log(Pawn$" actor was reachable, "$Dest);
	}
	else
	{
		DestResult = FindPathToward(Dest);
		MoveTarget = DestResult;
		//log(Pawn$" trying to find path toward, dest "$Dest$", move target "$MoveTarget);
	}

	//log(Pawn$" SetActorTarget, move target is "$MoveTarget$" actor dest "$Dest);

	if(MoveTarget == None)
	{
		// Only try to approximate it if we haven't already once this round
		if(ApproxGoal == None)
		{
			ApproxGoal = TargetClosestPathnode(Dest.Location);
			if(ApproxGoal != None
				&& ApproxGoal != Dest)
			{
				//log(Pawn$" +++++++++++++++ using this pathnode instead "$ApproxGoal$" at "$ApproxGoal.Location$" found path? "$FindPathToward(ApproxGoal));
				MoveTarget = FindPathToward(ApproxGoal);
			}
		}

		// If we still couldn't find anything, go straight there.
		if(MoveTarget == None
			|| DestResult == None)
		{
			MoveTarget = Dest;

			CantFindPath(Dest);

			//log(Pawn$" sending him straight there, SetActorTarget "$Dest$" me at "$Pawn.Location);
			if(Dest == None)
				PrintStateError("SetActorTarget Dest is null");
		}
	}
	//else
	//{
	//	log("set movetarget in SetActorTarget "$MoveTarget);
	//}

	if(!bDontSetFocus)
		Focus = MoveTarget;

	// If it's a pathnode and we're a dervish, choose a point below it
	if(PathNode(MoveTarget) != None
		&& bDervish)
	{
		MovePoint = MoveTarget.Location;
		MovePoint.z -= PATHNODE_OFFSET;
		MoveTarget = None; // make it use the point
	}

	// If we're heading to our target, then make it the end radius,
	// otherwise, pick the normal collision radius
	if(MoveTarget == Dest)
		UseEndRadius = EndRadius;
	else
		// Use a secondary end radius instead of the collision radius because
		// the dervish has problems and needs a special range
		UseEndRadius = SecondaryEndRadius;

	CheckForObstacles();
}

///////////////////////////////////////////////////////////////////////////////
// Set new target point and pick path
// DOESN'T call Super.
// Doesn't extend, this overwrites. It does to ensure a good check
// radius when the dervish is in action
///////////////////////////////////////////////////////////////////////////////
function SetActorTargetPoint(vector DestPoint, optional bool bStrictCheck)
{
	local Actor DestResult;
	local bool bMovePoint;

	bMovePointValid = false;
	MoveTarget=None;

	if(PointReachable(DestPoint))
	{
		//log("setting target point");
		MovePoint = DestPoint;
		bMovePointValid = true;
		UseEndRadius = EndRadius;
	}
	else
	{
		DestResult = FindPathTo(DestPoint);
		MoveTarget = DestResult;
		// Only if we're going to the last point, do we want the real end radius.
		// Generally just use the collision radius of the object
		if(MoveTarget != None)
		{
			// Handle it with a wider range, if you're a dervish
			if(PathNode(MoveTarget) != None
				&& bDervish)
			{
				bMovePoint=true;
				MovePoint = MoveTarget.Location;
				MovePoint.z -= PATHNODE_OFFSET;
				MoveTarget = None; // make it use the point
				// Use a secondary end radius instead of the collision radius because
				// the dervish has problems and needs a special range
				UseEndRadius = SecondaryEndRadius;
			}
			else
				UseEndRadius = MoveTarget.CollisionRadius;
		}
		else // We don't know how to get there, so do a quick test around this area to 
			// find a close by path node
		{
			// Only try to approximate it if we haven't already once this round
			if(ApproxGoal == None)
			{
				ApproxGoal = TargetClosestPathnode(DestPoint);
				if(ApproxGoal != None)
				{
					//log(Pawn$" ***************** using this pathnode instead "$ApproxGoal$" at "$ApproxGoal.Location$" found path? "$FindPathToward(ApproxGoal));
					MoveTarget = FindPathToward(ApproxGoal);
				}
			}

			// Handle it with a wider range, if you're a dervish
			if(PathNode(MoveTarget) != None
				&& bDervish)
			{
				bMovePoint=true;
				MovePoint = MoveTarget.Location;
				MovePoint.z -= PATHNODE_OFFSET;
				MoveTarget = None; // make it use the point
				// Use a secondary end radius instead of the collision radius because
				// the dervish has problems and needs a special range
				UseEndRadius = SecondaryEndRadius;
			}
			// If we still couldn't find anything, go straight there.
			else if(MoveTarget == None
				|| (DestResult == None
					&& !bMovePointValid))
			{
				CantFindPath(None, DestPoint);
				//log(Pawn$" sending him straight there, SetActorTargetPoint "$DestPoint$" me at "$Pawn.Location);
				MovePoint = DestPoint;
				bMovePointValid = true;
				UseEndRadius = EndRadius;
			}
		}
	}

	if(!bDontSetFocus)
	{
		if(MoveTarget == None)
		{
			if(bMovePoint)
				FocalPoint = MovePoint;
			else
				FocalPoint = DestPoint;
			Focus = None;
		}
		else
			Focus = MoveTarget;
	}
	// Check for things in the way
	CheckForObstacles();
}

///////////////////////////////////////////////////////////////////////////////
// Whether we can hack legs off or not
///////////////////////////////////////////////////////////////////////////////
function bool CanHackLegs()
{
	return bDervish;
}

///////////////////////////////////////////////////////////////////////////////
// Hack a leg of a person and keep moving
///////////////////////////////////////////////////////////////////////////////
function HackPersonLimb(AWPerson Other)
{
	Other.TakeDamage(SeverDamageAmt, MyPawn, MyPawn.Location, HIT_MOMENTUM*VRand(), DervishSeverClass);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetupGrindLimb(Limb Other)
{
	if(Other.CanBeGround())
	{
		PreciousLimb = Other;
		PreciousLimb.SnapToCat(CatPawn(MyPawn), DERVISH_BONE);
		SetupMoveSameDirection();
		bPreserveMotionValues=true;
		SetNextState('GrindPreciousLimb');
		GotoStateSave('DervishMove');
	}
}

///////////////////////////////////////////////////////////////////////////////
// We didn't get done with it in time, so throw it
///////////////////////////////////////////////////////////////////////////////
function ThrowPrecious()
{
	local vector usev;
	if(PreciousLimb != None
		&& PreciousLimb.bDeleteMe)
		PreciousLimb = None;
	if(PreciousLimb != None)
	{
		PreciousLimb.DropFromCat(CatPawn(MyPawn));
		usev = VRand();
		if(usev.z < 0)
			usev.z = -usev.z;
		usev = HIT_MOMENTUM*usev;
		usev.z += HIT_MOMENTUM;
		PreciousLimb.GiveMomentum(usev);
		PreciousLimb = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Non-cat pawns touching me in dervish mode get attacked
///////////////////////////////////////////////////////////////////////////////
function DervishTouch(actor Other)
{
	if(Pawn != None
		&& !Pawn.bDeleteMe
		&& !bDeleteMe)
	{
		if(AttachPawn == None
			&& PreciousLimb == None
			&& Pawn(Other) != None
			&& Pawn(Other).Health > 0
			&& CatPawn(Other) == None
			// If we're friends with the dude, don't latch onto him
			&& (!MyPawn.bPlayerIsFriend
				|| Dude(Other) == None
				|| AWDude(Other) == None)
			)
		{
			// Connect us to pawn
			SetAttacker(FPSPawn(Other));
			// Check to just cut a leg off instead
			// but only for non-animals other than the dude
			if(CanHackLegs()
				&& FRand() < CatPawn(MyPawn).HackLegFreq
				&& AWPerson(Other) != None
				&& P2Player(AWPerson(Other).Controller) == None)
			{
				TurnOnDervish();
				HackPersonLimb(AWPerson(Other));
				GotoStateSave('DervishThink');
			}
			else
			{
				AttachPawn = FPSPawn(Other);
				// and tell the pawn about us
				if(AttachPawn.IsPlayerPawn()
					&& P2Player(AttachPawn.Controller) != None)
					P2Player(AttachPawn.Controller).AttachedCat = MyPawn;
				else if(Bystanders(AttachPawn) != None
					&& BystanderController(AttachPawn.Controller) != None)
					BystanderController(AttachPawn.Controller).DervishAttack(MyPawn);
				// start it up
				TurnOnDervish();
				CatPawn(MyPawn).StartAttachDervish();
				GotoStateSave('DervishAttach');
			}
		}
		// If we hit a limb and we're not doing anything better, maybe grind it up
		else if(FRand() < CatPawn(MyPawn).GrindLimbFreq 
			&& Limb(Other) != None
			&& !Other.bDeleteMe
			&& AttachPawn == None
			// Not already got one
			&& PreciousLimb == None)
		{
			TurnOnDervish();
			SetupGrindLimb(Limb(Other));
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// When attacked, redecide your attack
///////////////////////////////////////////////////////////////////////////
function DervishdamageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;

	if(Damage > 0
		&& Other != MyPawn)
	{
		if (Other != None)
		{
			ThrowPrecious();
			GotoState('FallingHurtDervish');
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// When attacked, run away or decide to dervish
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;

	if(Damage > 0
		&& Other != MyPawn)
	{
		if (Other != None)
		{
			// Attack them instead
			if(Frand() < CatPawn(MyPawn).DervishAfterHurtFreq
			// But only if we're a crazy dervish cat
				&& CatPawn(MyPawn).IsCrazy())
			{
				DervishThisPawn(FPSPawn(Other));
			}
			else // run away
			{
				SetAttacker(FPSPawn(Other));
				GotoStateSave('RunAway');
			}
		}
		else	// hit by something like a cactus
			GotoStateSave('RunAway');
	}
}

///////////////////////////////////////////////////////////////////////////////
// You've been blinded by a flash grenade. Run away, even if dervishing
///////////////////////////////////////////////////////////////////////////////
function BlindedByFlashBang(P2Pawn Doer)
{
	if (bDervish)
		// Turn off the dervish	
		TurnOffDervish(true);

	// Super will handle running away
	Super.BlindedByFlashBang(Doer);
}

///////////////////////////////////////////////////////////////////////////////
// Send me flying
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, 
					   class<DamageType> damageType, vector Momentum)
{
	if(bDervish)
	{
		SetAttacker(FPSPawn(InstigatedBy));
		// If you got bludgeoned and you're after someone, fly through the air more
		// We can't test the physics here because it's already been changed by
		// the damage to make him fall
		if(Pawn(EndGoal) != None
			&& (ClassIsChildOf(damageType, class'BludgeonDamage')
				|| ClassIsChildOf(damageType, class'ExplodedDamage')))
		{
			MyPawn.Velocity.z+=KICK_UP_VEL;
		}
		Super(LambController).NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
	}
	else
		Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
} 

///////////////////////////////////////////////////////////////////////////////
// We'll fall like normal, but upon hitting the ground, we dervish
///////////////////////////////////////////////////////////////////////////////
function ThrownToGround(Pawn thrower)
{
	MyPawn.Instigator = thrower;
	OldAttachPawn = FPSPawn(thrower);
	GotoStateSave('FallingStartDervish');
}

///////////////////////////////////////////////////////////////////////////////
// If touched by normal people run, otherwise, jump in the player's inventory
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
		if(otherpawn != None)
		{
			if(otherpawn.bPlayer && !otherpawn.bCannotPickupCats)
			{
				// If it's the player--he caught us!
				// Go into his inventory
				// See if there's already a cat or not
				Copy = GetThisInv(otherpawn, InventoryGiveClass.default.InventoryGroup, InventoryGiveClass.default.GroupOffset);

				if(MyPawn.Skins.Length > 0)
					usedskin = Texture(MyPawn.Skins[0]);
				else// Don't allow this to finish if you don't
					// have a skin for your cat.
					return;
					
				if (MyPawn.bHighOnCatnip)	
					IsTainted = 1;
				else
					IsTainted = 0;
				//log(self@"picked up by dude - tainted status"@IsTainted,'Debug');

				if(Copy != None)
				{
					// Say we picked up one cat
					Copy.AddAmount(1, usedskin,,IsTainted);
				}
				else
				{
					Copy = spawn(InventoryGiveClass,otherpawn,,,rot(0,0,0));
					// Say we picked up one cat
					Copy.AddAmount(1, usedskin,,IsTainted);
					Copy.GiveTo( otherpawn );
				}

				// Play pickup noise
				otherpawn.PlaySound( PickupSound,,2.0 );

				// Display pickup message
				if (PlayerController(OtherPawn.Controller) != None)
					PlayerController(OtherPawn.Controller).ReceiveLocalizedMessage( InventoryGiveClass.default.PickupClass.default.MessageClass, 0, None, None, InventoryGiveClass.default.PickupClass );
					
				// Switch to the cat in inventory
				if (otherpawn.SelectedItem == None || PlayerController(otherpawn.Controller) == None || !PlayerController(otherpawn.Controller).bNeverSwitchItemOnPickup)
				{
					otherpawn.SelectedItem = Copy;
					if (P2Player(OtherPawn.Controller) != None)
						P2Player(OtherPawn.Controller).InvChanged();
				}
				
				// Record that we picked up the cat so it doesn't respawn
				if (P2GameInfoSingle(Level.Game) != None
					&& P2GameInfoSingle(Level.Game).TheGameState != None)
					P2GameInfoSingle(Level.Game).TheGameState.AddPersistentPawn(MyPawn);

				// Remove the cat and destroy it
				checkg = FPSGameInfo(Level.Game);
				checkg.RemovePawn(MyPawn);
				MyPawn.Destroy();
				MyPawn = None;
				Destroy();
			}
			else // if anyone else, then run away
			{
				if(otherpawn.Controller != None
					&& otherpawn.Health > 0)
				{
					if(PersonController(otherpawn.Controller) != None)
					{
						// if someone Touches the cat, as it's running around
						if(FRand() <= CALL_KITTY_FREQ)
						{
							if(P2GameInfo(Level.Game).LogDialog==1)
								log(otherpawn$" says here kitty kitty");
							otherpawn.Say(otherpawn.MyDialog.lCallCat);
						}
					}
				}

				DangerPos = otherpawn.Location;

				GotoStateSave('RunAway');
			}
		}
		else if(AnimalPawn(Other) != None)
		{
			anpawn = AnimalPawn(Other);
			// If we bump another animal, tell him
			if(//DogController(anpawn.Controller) != None
				//|| 
				ElephantController(anpawn.Controller) != None)
			{
				anpawn.Controller.Bump(MyPawn);
			}
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
// Begin the whirling dervish
///////////////////////////////////////////////////////////////////////////////
function TurnOnDervish(optional bool bDontSetState)
{
	local float usetime;
	
	if(!bDervish)
	{
		bDervish=true;
		// Pick how long to go for
		usetime = 0.5*CatPawn(MyPawn).DervishTimeMax;
		DervishTime = usetime*Frand() + usetime;
		// Save start time
		DervishStartTime = Level.TimeSeconds;
		// Setup the dervish
		CatPawn(MyPawn).TurnOnDervish();
		CatPawn(MyPawn).PlayDervish();
		SecondaryEndRadius = DervishEndRadius;
		if(!bDontSetState)
			GotoStateSave('DervishThink');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Stop the whirling dervish
///////////////////////////////////////////////////////////////////////////////
function TurnOffDervish(optional bool bDontSetState)
{
	if(bDervish)
	{
		// Throw precious limb if we still have one
		ThrowPrecious();
		
		CatPawn(MyPawn).TurnOffDervish();
		SetAttacker(None);
		SecondaryEndRadius = default.SecondaryEndRadius;
		if(!bDontSetState)
			GotoStateSave('DervishFinish');
		bDervish=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CheckAttachVel(out float velx, out float pos, float top, float bot)
{
	if(pos > top)
	{
		if(velx > 0)
			velx = -velx;
		pos = top;
	}
	else if(pos < bot)
	{
		if(velx < 0)
			velx = -velx;
		pos = bot;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Falling through the air (probably thrown)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallingFar
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, RespondToTalker, ForceGetDown, 
		MarkerIsHere, damageAttitudeTo, CheckForObstacles;

	///////////////////////////////////////////////////////////////////////////////
	// If touched by normal people run, otherwise, jump in the player's inventory
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		local P2Pawn otherpawn;
		local AnimalPawn anpawn;

		otherpawn = P2Pawn(Other);

		if(otherpawn != None)
		{
			// If you were thrown by the player, then have people get mad
			// at the player
			if(LambController(otherpawn.Controller) != None
				&& otherpawn.Health > 0
				&& MyPawn.Instigator != None)
			{
				LambController(otherpawn.Controller).InterestIsAnnoyingUs(MyPawn.Instigator, true);
				// Bounce off of the person you hit
				//log(self$" before "$MyPawn.Velocity);
				//MyPawn.Velocity.x = -0.5*MyPawn.Velocity.x;
				//MyPawn.Velocity.y = -0.5*MyPawn.Velocity.y;
				//log(self$" after "$MyPawn.Velocity);
			}
		}
		else // bump animals
		{
			anpawn = AnimalPawn(Other);
			if(anpawn != None)
			{
				// If we bump another animal, tell him
				if(
					//DogController(anpawn.Controller) != None
					//||
					ElephantController(anpawn.Controller) != None)
				{
					anpawn.Controller.Bump(MyPawn);
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// I've fallen to the ground
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		//log(self$" hit ground");
		MyPawn.SetAnimWalking();

		GotoStateSave('RunAway');

		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make us flail our legs
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		//log(self@"begin state falling far crazy"@CatPawn(MyPawn).IsCrazy(),'Debug');

		// If we got thrown out and we're a crazy cat, go dervish instead
		if (CatPawn(MyPawn).IsCrazy())
			GotoState('FallingStartDervish');

		MyPawn.SetPhysics(PHYS_FALLING);

		MyPawn.PlayThrownSound();

		MyPawn.PlayFalling();
	}
Begin:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// After we hit the ground, we'll start spinning
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallingDervish extends FallingFar
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, GetReadyToReactToDanger,
		StartledBySomething, RespondToTalker,
		damageAttitudeTo, NotifyTakeHit, CanHackLegs;

	///////////////////////////////////////////////////////////////////////////////
	// STUB so others can extend it
	///////////////////////////////////////////////////////////////////////////////
	function Touch(actor Other)
	{
	}
	///////////////////////////////////////////////////////////////////////////////
	// Allow Landed to do the work
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		return false;
	}
	///////////////////////////////////////////////////////////////////////////////
	// I've fallen to the ground, start dervish
	///////////////////////////////////////////////////////////////////////////////
	function Landed(vector HitNormal)
	{
		GotoState('DervishThink');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Make us flail our legs
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.SetPhysics(PHYS_FALLING);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// After we hit the ground, we'll start spinning
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallingStartDervish extends FallingDervish
{
	///////////////////////////////////////////////////////////////////////////////
	// Attack those you touch now
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		DervishTouch(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// I've fallen to the ground
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		log(Self$" landed ");
		TurnOnDervish();
		return true;
	}
	///////////////////////////////////////////////////////////////////////////////
	// I've fallen to the ground, start dervish
	///////////////////////////////////////////////////////////////////////////////
	function Landed(vector HitNormal)
	{
		log(Self$" landed ");
		TurnOnDervish();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Make us flail our legs
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.SetPhysics(PHYS_FALLING);

		MyPawn.PlayThrownSound();

		MyPawn.PlayFalling();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// After we hit the ground, we'll stop
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallingStopDervish extends FallingDervish
{
	///////////////////////////////////////////////////////////////////////////////
	// I've fallen to the ground, start dervish
	///////////////////////////////////////////////////////////////////////////////
	function Landed(vector HitNormal)
	{
		SetupMoveOpposite(OldAttachPawn);
		SetNextState('DervishFinish');
		GotoStateSave('DervishMove');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// After we hit the ground, we'll start again, after we were hurt
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallingHurtDervish extends FallingDervish
///////////////////////////////////////////////////////////////////////////////
{
	///////////////////////////////////////////////////////////////////////////////
	// I've fallen to the ground, start dervish
	///////////////////////////////////////////////////////////////////////////////
	function Landed(vector HitNormal)
	{
		// If we hate the player and was attacking him, keep attacking
		if(MyPawn.bPlayerIsEnemy
			&& OldAttachPawn != None
			&& P2Player(OldAttachPawn.Controller) != None)
			DervishThisPawn(OldAttachPawn);
		else // otherwise, go back to running around after getting hurt
			GotoState('DervishThink', 'HurtWait');
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		MyPawn.PlayThrownSound();
		// Reset the dervish timer too
		DervishStartTime = Level.TimeSeconds;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Swirling around to hurt things
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DervishThink extends Thinking
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

		if(FRand() < CatPawn(MyPawn).AttackFreq)
		{
			keepdist = ATTACK_SEARCH_RADIUS;

			foreach VisibleCollidingActors(class'FPSPawn', CheckP, ATTACK_SEARCH_RADIUS, MyPawn.Location)
			{
				// Don't dervish other cats or death things
				if(CatPawn(CheckP) == None
					&& OldAttachPawn != CheckP
					&& CheckP.Health > 0
					// If we're friends with the dude, don't latch onto him
					&& (!MyPawn.bPlayerIsFriend
						&& !CheckP.IsPlayerPawn())
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

		MyPawn.SetPhysics(PHYS_Flying);

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
	// Attack those you touch now
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		DervishTouch(Other);
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
		SetNextState('DervishThink');
	}
HurtWait:
	SetupMoveOpposite(Attacker);
	// clear your attacker 
	SetAttacker(None);
	Goto('StartMoving');
Begin:
	Sleep(0.01);
	// Check to stop dervish, unless it's infinite time
	if(DervishTime > 0
		&& Level.TimeSeconds - DervishStartTime > DervishTime)
	{
		GotoStateSave('FallingStopDervish');
	}

	if(!PickRandomTarget())
	// Didn't find a valid point, so get nearest
	{
		// Also checks homenodes
		UseNearestPathNode(2048);
	}
StartMoving:
	SetNextState('DervishThink');
	GotoStateSave('DervishMove');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Swirling around to hurt things
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DervishMove extends RunToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, GetReadyToReactToDanger,
		StartledBySomething, RespondToTalker;

	///////////////////////////////////////////////////////////////////////////
	// Piss is hitting me makes me stop attacking
	///////////////////////////////////////////////////////////////////////////
	function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
	{
		SetAttacker(Other);
		GotoStateSave('FallingHurtDervish');
	}

	///////////////////////////////////////////////////////////////////////////
	// Gas is hitting me makes me stop attacking
	///////////////////////////////////////////////////////////////////////////
	function GettingDousedInGas(P2Pawn Other)
	{
		SetAttacker(Other);
		GotoStateSave('FallingHurtDervish');
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		DervishDamageAttitudeTo(Other, Damage);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Attack those you touch now
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		DervishTouch(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stuck to someone and your attacking them
// We're not actually using AttachToBone or even SetBase. We manually
// use SetLocation each tick to position them on the pawn where we want
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DervishAttach
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, GetReadyToReactToDanger,
		StartledBySomething, RespondToTalker, Touch, CanHackLegs;

	///////////////////////////////////////////////////////////////////////////
	// Piss is hitting me makes me stop attacking
	///////////////////////////////////////////////////////////////////////////
	function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
	{
		SetAttacker(Other);
		GotoStateSave('FallingHurtDervish');
	}

	///////////////////////////////////////////////////////////////////////////
	// Gas is hitting me makes me stop attacking
	///////////////////////////////////////////////////////////////////////////
	function GettingDousedInGas(P2Pawn Other)
	{
		SetAttacker(Other);
		GotoStateSave('FallingHurtDervish');
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		DervishDamageAttitudeTo(Other, Damage);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		local vector dir, snaploc;
		local float mag;
		local coords bcoords;

		AttachTime += DeltaTime;
		TotalAttachTime-=DeltaTime;

		// Decide to stop attacking, if you've hurt them enough (that could be 
		// when they're dead though too)
		// Or if we've attacked someone (like god-mode dude) for too long
		// quit then too
		if(AttachPawn == None
			|| AttachPawn.bDeleteMe
			|| AttachPawn.Health <= 0
			|| AttachPawn.Health < TargetAttachHealth
			|| (AttachPawn.Controller != None
				&& (AttachPawn.Controller.bGodMode
					|| AWZombie(AttachPawn) != None
					|| AttachPawn.IsA('AWCowBossPawn')
					|| AttachPawn.IsA('MadCowPawn'))
				&& TotalAttachTime <= 0))
		{
			// We are allow to stop
			if(DervishTime > 0)
				GotoStateSave('FallingStopDervish');
			else // We just keep dervishing over and over
			{
				TurnOffDervish();
				GotoStateSave('FallingStartDervish');
			}
		}

		if(AttachPawn != None)
		{
			// Hurt the pawn in intervals
			if(AttachTime > ATTACH_HURT_TIME)
			{
				AttachTime -= ATTACH_HURT_TIME;
				AttachPawn.TakeDamage(DervishDamageAmt, MyPawn, MyPawn.Location, HIT_MOMENTUM*VRand(), DervishDamageClass);
			}
			// Move the cat up and down
			AttachOffset = AttachOffset + AttachMoveVel*DeltaTime;
			
			CheckAttachVel(AttachMoveVel.x, AttachOffset.x, 0.2*AttachPawn.CollisionRadius, -0.2*AttachPawn.CollisionRadius);
			CheckAttachVel(AttachMoveVel.y, AttachOffset.y, 0.2*AttachPawn.CollisionRadius, -0.2*AttachPawn.CollisionRadius);
			CheckAttachVel(AttachMoveVel.z, AttachOffset.z, 0.3*AttachPawn.CollisionHeight, 0);

			if(AWPerson(AttachPawn) != None)
			{
				bcoords = AttachPawn.GetBoneCoords(GUY_ATTACH_BONE);
				// Move the cat onto the pawn's location, with our offset, plus the speed the attach pawn is moving
				snaploc = bcoords.Origin + AttachOffset + AttachPawn.Velocity*Deltatime;
			}
			else
			{
				// Move the cat onto the pawn's location, with our offset, plus the speed the attach pawn is moving
				snaploc = AttachPawn.Location + AttachOffset + AttachPawn.Velocity*Deltatime;
			}
			// Do attach
			MyPawn.SetLocation(snaploc);
			SetLocation(snaploc);
			// Enforce physics during attach
			if(MyPawn.Physics != PHYS_None)
			{
				MyPawn.SetPhysics(PHYS_None);
				MyPawn.Velocity = vect(0,0,0);
				MyPawn.Acceleration = vect(0,0,0);
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(AttachPawn != None)
			MyPawn.SetLocation(AttachPawn.Location);
		if(AttachPawn.IsPlayerPawn()
			&& P2Player(AttachPawn.Controller) != None)
			P2Player(AttachPawn.Controller).AttachedCat = None;
		AttachPawn = None;
		CatPawn(MyPawn).StopAttachDervish();
		SetAttacker(None);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		// Save the last guy you went after so you won't go after him again
		// until you've attacked someone else
		OldAttachPawn = AttachPawn;
		// Pick starting offsets
		AttachOffset = vect(0,0,0);
		AttachMoveVel.x=2*FRand()*ATTACH_VEL_XY - ATTACH_VEL_XY;
		AttachMoveVel.y=2*FRand()*ATTACH_VEL_XY - ATTACH_VEL_XY;
		AttachMoveVel.z=0.5*FRand()*ATTACH_VEL_Z + ATTACH_VEL_Z;
		MyPawn.SetRotation(AttachPawn.Rotation);
		// Find for how long you should hurt them. We hurt them down to 
		// a certain percentage of health.
		if(AWPerson(AttachPawn) == None
			|| AWPerson(AttachPawn).TakesDervishDamage >= 1.0)
			TargetAttachHealth = 0;	// goes till they die
		else
			TargetAttachHealth = AttachPawn.Health - AttachPawn.HealthMax*AWPerson(AttachPawn).TakesDervishDamage;
		TotalAttachTime = default.TotalAttachTime;
		// Freak people out around you
		MakePeopleScared(class'AnimalAttackMarker');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Grind the PreciousLimb we have
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GrindPreciousLimb
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, GetReadyToReactToDanger,
		StartledBySomething, RespondToTalker, Touch, CanHackLegs;

	///////////////////////////////////////////////////////////////////////////
	// Piss is hitting me makes me stop attacking
	///////////////////////////////////////////////////////////////////////////
	function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
	{
		SetAttacker(Other);
		GotoStateSave('FallingHurtDervish');
	}

	///////////////////////////////////////////////////////////////////////////
	// Gas is hitting me makes me stop attacking
	///////////////////////////////////////////////////////////////////////////
	function GettingDousedInGas(P2Pawn Other)
	{
		SetAttacker(Other);
		GotoStateSave('FallingHurtDervish');
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		DervishDamageAttitudeTo(Other, Damage);
	}

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		CatPawn(MyPawn).StopGrindingLimb();
		if(PreciousLimb != None
			&& PreciousLimb.bDeleteMe)
			PreciousLimb = None;
		// Get rid of our limb, if it's not be thrown or ground up
		if(PreciousLimb != None)
		{
			PreciousLimb.Destroy();
			PreciousLimb = None;
		}
	}
	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		if(PreciousLimb == None
			|| PreciousLimb.bDeleteMe)
		{
			PreciousLimb = None;
			GotoStateSave('DervishThink');
		}
		else
		{
			CatPawn(MyPawn).StartGrindingLimb();
			PreciousLimb.GotoState('GettingGroundDown');
			MyPawn.Acceleration = vect(0,0,0);
			MyPawn.Velocity = vect(0,0,0);
		}
	}
Begin:
	Sleep(GRIND_TIME);
	GotoStateSave('DervishThink');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Coming out of dervish,
// allow them to be picked up, but not much else
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DervishFinish extends Sitting
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, GetReadyToReactToDanger,
		StartledBySomething, RespondToTalker, HissOrRun, CheckForScaryPerson,
		CanHackLegs;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		TurnOffDervish();
		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunAway
// If a dog is chasing us randomly dervish after it, after a while
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunAway
{
Begin:
	Sleep(0.1);
	// Get tired of running and decide to attack after a while
	if(DogPawn(InterestPawn) != None
		&& InterestPawn.Health > 0
		&& FRand() < CatPawn(MyPawn).DervishChaserFreq)
		DervishThisPawn(InterestPawn);

	// If we didn't attack, check to run
	if(!PickRandomDest())
		// Didn't find a valid point, so get nearest
	{
		if(UseNearestHomeNode(2048))
			UseNearestPathNode(2048);
	}

	GotoStateSave('RunningScared');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand and look around forever (until provoked)
// No pissing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HoldPosition
{
	ignores ReadyForASniff;

	///////////////////////////////////////////////////////////////////////////////
	// We're ready to expierence thigns again, so turn off the ignore
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		MyPawn.bIgnoresSenses=false;
	}

Begin:
	MyPawn.PlayAnimStanding();
	statecount=0;
	Goto('Waiting');

LookingAround:
	// See if people are around me and decide what to do about it
	CheckForPeopleAroundMe();

	if(FRand() <= 0.5)
		MyPawn.PlayHappySound();
	else
		MyPawn.PlayContentSound();

	// sometimes sniff some
	if(FRand() <= SNIFF_FREQ)
	{
		MyPawn.PlayInvestigate();
		statecount=1;
		Goto('Waiting');
	}

CheckToStandAgain:
	// Always stand again
	Goto('Begin');

Waiting:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     DervishDamageClass=Class'DervishDamage'
     TotalAttachTime=8.000000
     DervishDamageAmt=5.000000
     SecondaryEndRadius=35.000000
     DervishEndRadius=300.000000
     SeverDamageAmt=50.000000
     DervishSeverClass=Class'AWEffects.DervishSeverDamage'
     InventoryGiveClass=Class'CatInv'
}
