///////////////////////////////////////////////////////////////////////////////
// CatController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class CatController extends AnimalController;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
var() class<P2PowerupInv> InventoryGiveClass;	// inventory class I give out when caught by dude
var	sound PickupSound;							// Noise made when you pickup the cat/pawn and take it
												// into your inventory
var vector LastNipLoc;							// Position catnip was when we started to go for it.
												// If it's not here when we start to mess with it, 
												// we'll simply run for it.

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const HISS_FREQ  = 0.25;

const LAY_LOOP_FREQ		= 0.35;

const LAY_DOWN_FOR_THEM_FREQ = 0.1;

const SNIFF_FREQ    = 0.4;
const PISS_FREQ    = 0.35;
const SIT_LOOP_FREQ = 0.15;
const STAND_LOOP_FREQ = 0.1;
const SNIFF_BUTT_FREQ = 0.2;
const WALK_AROUND_FREQ = 0.6;

const WALKING_MEOW_FREQ	=	0.01;

const SCARY_PERSON_RAD = 1024;
const CHECK_FOR_CAT_RAD = 1024;

const MIN_VELOCITY_FOR_REAL_MOVEMENT = 30;
const LEG_MOTION_CAUGHT_MAX=3;

// Marphy - Original constant is larger so cops can express cat hate more often.
const CALL_KITTY_FREQ	=	0.16;
const CALL_KITTY_FREQ_NEW	=	0.03;

var bool  bDervish;				// It's a dervish or not, controlled by TurnOn/OffDervish

function TurnOffDervish(optional bool bDontSetState)
{
	warn(self@"CALLED TURN OFF DERVISH IN REGULAR CAT CONTROLLER!!!");
}
function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Class == class'CatController')
		warn(self@"is a normal cat controller");
}

///////////////////////////////////////////////////////////////////////////////
// start: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Just stand where you are, sort of like a security guard on duty or something
///////////////////////////////////////////////////////////////////////////////
function SetToHoldPosition()
{
	SetNextState('HoldPosition');
}
///////////////////////////////////////////////////////////////////////////////
// Run screaming from where you are
///////////////////////////////////////////////////////////////////////////////
function SetToPanic()
{
	SetNextState('RunAway');
}

///////////////////////////////////////////////////////////////////////////////
// Find a player and be scared of him
///////////////////////////////////////////////////////////////////////////////
function SetToBeScaredOfPlayer(FPSPawn PlayerP)
{
	SetToPanic();
}
///////////////////////////////////////////////////////////////////////////////
// Find a closet actor with this tag (should be a pawn) and be scared of him
///////////////////////////////////////////////////////////////////////////////
function SetToBeScaredOfTag(Name RunTag)
{
	SetToPanic();
}
///////////////////////////////////////////////////////////////////////////////
// Make pawns start dead and at the end of a given animation
///////////////////////////////////////////////////////////////////////////////
function SetToDead()
{
	MyPawn.TakeDamage(MyPawn.HealthMax, None, MyPawn.Location, vect(0, 0, 1), class'P2Damage');
	SetNextState('Destroying');
}

///////////////////////////////////////////////////////////////////////////////
// end: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
// When attacked
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;

	if(Damage > 0
		&& Other != MyPawn)
	{
		if (Other != None)
		{
			if(Attacker == None)
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
// You've been blinded by a flash grenade. Run away
///////////////////////////////////////////////////////////////////////////////
function BlindedByFlashBang(P2Pawn Doer)
{
	if (Doer != None)
	{
		if(Attacker == None)
		{
			SetAttacker(Doer);
			GotoStateSave('RunAway');
		}
	}	
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do about this danger
///////////////////////////////////////////////////////////////////////////////
function GetReadyToReactToDanger(class<TimedMarker> dangerhere, 
								FPSPawn CreatorPawn, 
								Actor OriginActor,
								vector blipLoc,
								optional out byte StateChange)
{
	// If this thing doesn't care about things going on around him
	if(!MyPawn.bIgnoresSenses
		&& !MyPawn.bIgnoresHearing)
	{
		DangerPos = blipLoc;

		MyPawn.PlayScaredSound();

		GotoStateSave('RunAway');

		StateChange=1;
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Because animals are more simple, we can have a general 'startled' function
///////////////////////////////////////////////////////////////////////////////
function StartledBySomething(Pawn Meanie)
{
	if(Meanie != None)
		DangerPos = Meanie.Location;

	GotoStateSave('RunAway');
}

///////////////////////////////////////////////////////////////////////////
// Something splashed him or something, so he may hiss, but might also run
///////////////////////////////////////////////////////////////////////////
function HissOrRun(Actor Other)
{
	if(Other != None)
		DangerPos = Other.Location;

	if(FRand() <= HISS_FREQ
		&& Other != None)
	{
		Focus = Other;
		GotoStateSave('Hissing');
	}
	else
	{
		MyPawn.PlayScaredSound();

		GotoStateSave('RunAway');
	}
}

///////////////////////////////////////////////////////////////////////////
// Piss is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
	HissOrRun(Other);
}

///////////////////////////////////////////////////////////////////////////
// Something annoying, but not really gross or life threatening
// has been done to me, so check to maybe notice
///////////////////////////////////////////////////////////////////////////
function InterestIsAnnoyingUs(Actor Other, bool bMild)
{
	HissOrRun(Other);
}

///////////////////////////////////////////////////////////////////////////
// A bouncing, disembodied head just hit us, decide what to do
///////////////////////////////////////////////////////////////////////////
function GetHitByDeadThing(Actor DeadThing, FPSPawn KickerPawn)
{
	HissOrRun(DeadThing);
}

///////////////////////////////////////////////////////////////////////////
// Gas is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function GettingDousedInGas(P2Pawn Other)
{
	Super.GettingDousedInGas(Other);

	HissOrRun(Other);
}

///////////////////////////////////////////////////////////////////////////
// See if someone is close by
///////////////////////////////////////////////////////////////////////////
function P2Pawn CheckForPersonAroundMe(float RadCheck)
{
	local P2Pawn CheckP;

	// check all the pawns around me.
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		return CheckP;
	}

	return None;
}

///////////////////////////////////////////////////////////////////////////
// See if someone is close by doing something scary like running
//
// Returns the closest nice person
// 
///////////////////////////////////////////////////////////////////////////
function P2Pawn CheckForScaryPerson(float RadCheck)
{
	local FPSPawn CheckP, PickMe;
	local float closest, dist;

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
				if(dist > ((CheckP.Default.GroundSpeed)/2 + 1)
					&& (P2MoCapPawn(CheckP) == None || dist > ((P2MoCapPawn(CheckP).Default.GroundSpeedMax)/2 + 1))
					)
				{
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

///////////////////////////////////////////////////////////////////////////////
// True means it's okay for you to sniff my butt
///////////////////////////////////////////////////////////////////////////////
function bool ReadyForASniff(FPSPawn Sniffer)
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// True means youre waiting for a butt sniff
///////////////////////////////////////////////////////////////////////////////
function bool WaitingForASniff()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Some dumb human is talking to me (not shouting)
///////////////////////////////////////////////////////////////////////////////
function LookAtTalker(FPSPawn Talker, out byte StateChange)
{
	Focus = Talker;
	MyPawn.PlayHappySound();
	GotoStateSave('Sitting');
	StateChange=1;
}

///////////////////////////////////////////////////////////////////////////////
// Someone might have shouted get down, said hi, or asked for money.. see what to do
// Go to state to see if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function RespondToTalker(Pawn Talker, Pawn AttackingShouter, ETalk TalkType, out byte StateChange)
{
	switch(TalkType)
	{
		case TALK_getdown:
			// Run away when someone yells
			HissOrRun(P2Pawn(Talker));
			StateChange=1;
		break;
		case TALK_askformoney:
			LookAtTalker(FPSPawn(Talker), StateChange);
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// See if people are around me and decide what to do about it
///////////////////////////////////////////////////////////////////////////////
function CheckForPeopleAroundMe()
{
	// See if someone around me might scare me into running or something
	if(CheckForScaryPerson(SCARY_PERSON_RAD) != None)
	{
		// if there's nice people around, consider laying down
		if(FRand() <= LAY_DOWN_FOR_THEM_FREQ)
		{
			GotoStateSave('LetThemPetMe');
			return;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Look for other cats around me
///////////////////////////////////////////////////////////////////////////////
function CheckForAnimalsAroundMe(float RadCheck)
{
	local AnimalPawn CheckP;
	local float closest, dist;
	local vector catbutt;

	closest = RadCheck;

	// check all the pawns around me.
	ForEach VisibleCollidingActors(class'AnimalPawn', CheckP, RadCheck, MyPawn.Location)
	{
		// Only check cats not behind obstructions.
		if(FastTrace(MyPawn.Location, CheckP.Location)
			&& CheckP != MyPawn)
		{
			dist = VSize(CheckP.Velocity);
			// If he's walking or not moving, walk over to him
			if(dist < (CheckP.WalkingPct*CheckP.GroundSpeed))
			{
				// if we get to one cat, decide to do it or not
				if(FRand() > SNIFF_BUTT_FREQ)
					return;

				// When you're telling other cats you ready for sniff, also tell
				// dogs that you'r ready to be attacked..hehehee..
				if(AnimalController(CheckP.Controller) != None
					&& AnimalController(CheckP.Controller).ReadyForASniff(MyPawn))
				{
					DangerPos = CheckP.Location;

					InterestPawn = CheckP;
					// Walk to behind the other cat's butt
					catbutt = CheckP.Location;
					catbutt = catbutt - (CheckP.CollisionRadius*2.0)*vector(CheckP.Rotation);
					//log(" cat loc "$CheckP.Location$" cat butt "$catbutt);
					SetEndPoint(catbutt, CheckP.CollisionRadius);
					SetNextState('DoButtSniffing');
					MyPawn.ChangeAnimation();
					GotoStateSave('WalkToCat');

					return;
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check for a cat already in there
///////////////////////////////////////////////////////////////////////////////
function P2PowerupInv GetThisInv(Pawn Other, int GroupNum, int OffsetNum)
{
	local Inventory inv;
	local int Count;

	if ( Other.Inventory == None )
		return None;

	inv = Other.Inventory;

	while(inv != None
		&& !(inv.InventoryGroup == GroupNum
		&& inv.GroupOffset == OffsetNum))
	{
		//log("inv "$inv);
		//log("inv group "$inv.InventoryGroup);
		//log("inv offset "$inv.GroupOffset);
		inv = inv.Inventory;
		Count++;
		if (Count > 5000)
			break;
	}

	if(inv != None 
		&& inv.InventoryGroup == GroupNum 
		&& inv.GroupOffset == OffsetNum)
	{
		// found one already there
		return P2PowerupInv(inv);
	}
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// Send me flying
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, 
					   class<DamageType> damageType, vector Momentum)
{
	Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
	// if he's up in the air, send him falling
	if(Momentum.z != 0)
		GotoStateSave('FallingFar');
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

	otherpawn = P2Pawn(Other);

	if(MyPawn.Health > 0)
	{
		if(otherpawn != None)
		{
			if(otherpawn.bPlayer)
			{
				// If it's the player--he caught us!
				// Go into his inventory
				// See if there's already a cat or not
				Copy = GetThisInv(otherpawn, class'CatInv'.default.InventoryGroup, class'CatInv'.default.GroupOffset);

				if(MyPawn.Skins.Length > 0)
					usedskin = Texture(MyPawn.Skins[0]);
				else// Don't allow this to finish if you don't
					// have a skin for your cat.
					return;

				if(Copy != None)
				{
					// Say we picked up one cat
					Copy.AddAmount(1, usedskin);
				}
				else
				{
					Copy = spawn(InventoryGiveClass,otherpawn,,,rot(0,0,0));
					// Say we picked up one cat
					Copy.AddAmount(1, usedskin);
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
						// Marphy - Cops won't sign your petition, so they probably hate cats too.
						if(FRand() <= CALL_KITTY_FREQ && (otherpawn.IsA('Cop') || otherpawn.IsA('AuthorityFigure')))
							otherpawn.Say(otherpawn.MyDialog.lHateCat);
						else
						{
							if(FRand() <= CALL_KITTY_FREQ)
							{
								if(FRand() <= 0.5)
									otherpawn.Say(otherpawn.MyDialog.lCallCat);
								else
									otherpawn.Say(otherpawn.MyDialog.lHateCat);
							}
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
// An animal caller is trying to get you to come to it
///////////////////////////////////////////////////////////////////////////////
function RespondToAnimalCaller(FPSPawn Thrower, Actor Other, out byte StateChange)
{
	StateChange=1;

	if(Other != None)
	{
		SetEndGoal(Other, ((FRand()*2*TIGHT_END_RADIUS) + TIGHT_END_RADIUS));
		Focus = Other;
		LastNipLoc = Other.Location;	// Save where it is. If it's not still exactly
			// there by the time we get there, don't go through with the laying down part.
		SetNextState('CatNipCovering');
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		GotoStateSave('WalkToNip');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to about that tastey donut before you
///////////////////////////////////////////////////////////////////////////////
function CheckDesiredThing(Actor DesireMaker, class<TimedMarker> blip, optional out byte StateChange)
{
	local P2PowerupPickup p2p;

	p2p = P2PowerupPickup(DesireMaker);

	if(p2p != None)
	{
		RespondToAnimalCaller(FPSPawn(p2p.Instigator), p2p, StateChange);
		StateChange=1;
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Something important occurred
///////////////////////////////////////////////////////////////////////////////
function MarkerIsHere(class<TimedMarker> bliphere,
					  FPSPawn CreatorPawn, 
					  Actor OriginActor,
					  vector blipLoc)
{
	local byte Reacted;

	if(ClassIsChildOf(bliphere, class'CatnipMarker'))
	{
		CheckDesiredThing(OriginActor, bliphere);
	}
	else if(bliphere == class'DeadCatHitGuyMarker')
	{
	// nothing for dead cats on guys
	}
	else if(bliphere == class'HeadExplodeMarker')
	{
	// Nothing for at exploding heads
	}
	else if(ClassIsChildOf(bliphere, class'DeadBodyMarker'))
	{
		// nothing for dead bodies
	}
	else if(blipLoc != Pawn.Location)
	{
		GetReadyToReactToDanger(bliphere, CreatorPawn, OriginActor, blipLoc);
	}
}

///////////////////////////////////////////////////////////////////////////////
// You're getting electricuted
///////////////////////////////////////////////////////////////////////////////
function GetShocked(P2Pawn Doer, vector HitLocation)
{
	if(MyPawn.Physics == PHYS_WALKING)
	{
		SetAttacker(Doer);

		MakeShockerSteam(HitLocation, ANIMAL_BONE_PELVIS);

		GotoState('BeingShocked');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do next
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Thinking
{
	///////////////////////////////////////////////////////////////////////////////
	// True means it's okay for you to sniff my butt
	///////////////////////////////////////////////////////////////////////////////
	function bool ReadyForASniff(FPSPawn Sniffer)
	{
		InterestPawn = Sniffer;
		GotoStateSave('WaitForButtSniff');
		return true;
	}

Begin:
	Sleep(0.0);

	if(!bPreparingMove)
	{
		// See if people are around me and decide what to do about it
		CheckForPeopleAroundMe();
		CheckForAnimalsAroundMe(CHECK_FOR_CAT_RAD);

		if(FRand() <= WALK_AROUND_FREQ)
		{
			// walk to some random place I can see (not through walls)
			SetNextState('Thinking');
			if(!PickRandomDest())
				Goto('Begin');	// Didn't find a valid point, try again

			MyPawn.ChangeAnimation();

			GotoStateSave('WalkToTarget');
		}
		else
		{
			if(FRand() <= 0.5)
				GotoStateSave('Standing');
			else
				GotoStateSave('Sitting');
		}
	}
	else
	{
		Sleep(2.0);
		Goto('Begin');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand and look around
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Standing
{
	///////////////////////////////////////////////////////////////////////////////
	// Decide to go through this state again
	///////////////////////////////////////////////////////////////////////////////
	function bool StandAgain()
	{
		return (FRand() <= STAND_LOOP_FREQ);
	}

	///////////////////////////////////////////////////////////////////////////////
	// True means it's okay for you to sniff my butt
	///////////////////////////////////////////////////////////////////////////////
	function bool ReadyForASniff(FPSPawn Sniffer)
	{
		InterestPawn = Sniffer;
		GotoStateSave('WaitForButtSniff');
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			if(statecount == 0)
				GotoStateSave(GetStateName(), 'LookingAround');
			else if(statecount == 1)
				GotoStateSave(GetStateName(), 'CheckToStandAgain');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		statecount=0;
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
	// Very rarely, decide to piss
	if(FRand() <= PISS_FREQ)
	{
		GotoStateSave('Pissing');
	}

CheckToStandAgain:
	// Sometimes stand again
	if(StandAgain())
		Goto('Begin');

	GotoStateSave('Thinking');

Waiting:

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand and look around forever (until provoked)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HoldPosition extends Standing
{
	///////////////////////////////////////////////////////////////////////////////
	// Always go through this state again, if we have our druthers
	///////////////////////////////////////////////////////////////////////////////
	function bool StandAgain()
	{
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand and look around and wait for another cat to sniff your butt
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitForButtSniff extends Standing
{
	ignores ReadyForASniff;

	///////////////////////////////////////////////////////////////////////////////
	// True means it's okay for you to sniff my butt
	///////////////////////////////////////////////////////////////////////////////
	function bool WaitingForASniff()
	{
		return true;
	}

Begin:
	MyPawn.PlayAnimStanding();
	statecount=0;
	Goto('Waiting');

LookingAround:
	// Only check for scary people
	CheckForScaryPerson(SCARY_PERSON_RAD);

	// sometimes sniff some
	if(FRand() <= SNIFF_FREQ)
	{
		MyPawn.PlayInvestigate();
		statecount=1;
		Goto('Waiting');
	}

CheckToStandAgain:
	// Always stand again until our interestpawn sniffs our 
	// but or we get scared away
	Goto('Begin');

Waiting:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand there and sniff another cat's butt
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DoButtSniffing extends Standing
{
	ignores ReadyForASniff;

	///////////////////////////////////////////////////////////////////////////////
	// Always tell your interest pawn you're done
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		local CatController catbuddy;
		// tell you buddy to walk away and you will too now
		// buddy walks away
		catbuddy = CatController(InterestPawn.Controller);
		if(catbuddy.WaitingForASniff())
		{
			InterestPawn.ChangeAnimation();
			catbuddy.SetEndGoal(FindRandomDest(), DEFAULT_END_RADIUS);
			catbuddy.SetNextState('Thinking');
			catbuddy.GotoStateSave('WalkToTarget');
		}
		// you walk away
		MyPawn.ChangeAnimation();
		SetEndGoal(FindRandomDest(), DEFAULT_END_RADIUS);
		SetNextState('Thinking');
		GotoStateSave('WalkToTarget');
	}
Begin:
	// aim at the butt
	Focus = InterestPawn;

LookingAround:
	// Only check for scary people
	CheckForScaryPerson(SCARY_PERSON_RAD);

	// Do some sniffing!
	MyPawn.PlayInvestigate();
	statecount=1;
	Goto('Waiting');

	// Make your friend look up
	if(CatController(InterestPawn.Controller).WaitingForASniff())
		CatController(InterestPawn.Controller).GotoStateSave('WaitForButtSniff', 'LookingAround');


CheckToStandAgain:
	GotoStateSave('Thinking');

Waiting:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Sit and look around
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Sitting
{
	///////////////////////////////////////////////////////////////////////////////
	// Some dumb human is talking to me (not shouting)
	///////////////////////////////////////////////////////////////////////////////
	function LookAtTalker(FPSPawn Talker, out byte StateChange)
	{
		MyPawn.PlayHappySound();
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			if(statecount == 0)
				GotoState(GetStateName(), 'LoopSitting');
			else if(statecount == 1)
			{
				// Sometimes sit again
				if(FRand() <= SIT_LOOP_FREQ)
					GotoState(GetStateName(), 'LoopSitting');
				else
					GotoState(GetStateName(), 'StandBackUp');
			}
			else
				GotoStateSave('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		statecount=0;
	}

Begin:
	// sit down
	MyPawn.PlaySitDown();
	statecount=0;
	Goto('Waiting');

LoopSitting:
	// See if people are around me and decide what to do about it
	CheckForPeopleAroundMe();

	MyPawn.PlayHappySound();

	MyPawn.PlaySitting();
	statecount=1;
	Goto('Waiting');

StandBackUp:
	MyPawn.PlayStandUp();
	statecount=2;

Waiting:

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Lay down and let them pet me, maybe
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LetThemPetMe
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			if(statecount == 0)
				GotoState(GetStateName(), 'LoopLaying');
			else if(statecount == 1)
			{
				// Sometimes sit again
				if(FRand() <= LAY_LOOP_FREQ)
					GotoState(GetStateName(), 'LoopLaying');
				else
					GotoState(GetStateName(), 'GetBackUp');
			}
			else
			{
				MyPawn.ChangeAnimation();
				// Always walk somewhere after you just laid down, don't just sit and think
				SetEndGoal(FindRandomDest(), DEFAULT_END_RADIUS);
				SetNextState('Thinking');
				GotoStateSave('WalkToTarget');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		statecount=0;
	}

Begin:
	// sit down
	MyPawn.PlayLayDown();
	statecount=0;
	Goto('Waiting');

LoopLaying:
	// See if someone around me might scare me into running or something
	//CheckForScaryPerson(SCARY_PERSON_RAD);

	MyPawn.PlayLaying();
	statecount=1;
	Goto('Waiting');

	// Sometimes sit again
	if(FRand() <= LAY_LOOP_FREQ)
		Goto('LoopLaying');

GetBackUp:
	MyPawn.PlayGetBackUp();
	statecount=2;

Waiting:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Sleeping by the catnip.. you can easily be picked up now. 
// Sleep forever.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CatNipSleep extends LetThemPetMe
{
	ignores CheckForScaryPerson, RespondToTalker, CheckForAnimalsAroundMe,
		CheckForPeopleAroundMe, RespondToAnimalCaller;
Begin:
	// sit down
	MyPawn.PlayLayDown();
	statecount=0;
	Goto('Waiting');

LoopLaying:
	// See if someone around me might scare me into running or something
	//CheckForScaryPerson(SCARY_PERSON_RAD);

	MyPawn.PlayDruggedOut();
	statecount=1;
	Goto('Waiting');

	// Always keep laying there, until you're heavily disturbed
	Goto('LoopLaying');

GetBackUp:
	MyPawn.PlayGetBackUp();
	statecount=2;

Waiting:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Hiss at interest
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Hissing
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GetReadyToReactToDanger,
		StartledBySomething, GettingDousedInGas, RespondToTalker;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			GotoStateSave('RunAway');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop moving
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
	}

Begin:
	MyPawn.PlayGetScared();
/*
	// temp--make anim actually longer than one frame, someday
	Sleep(FRand() + 0.5);
	GotoStateSave('RunAway');
	*/
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Pee on the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Pissing
{
	///////////////////////////////////////////////////////////////////////////////
	// In the pissing state, say pissing is valid, only then
	///////////////////////////////////////////////////////////////////////////////
	function bool PissingValid()
	{
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			SetNextState('Thinking');
			GotoStateSave('Covering');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make sure to terminate the stream
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.Notify_PissStop();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		statecount=0;
	}
Begin:
	// modify the speed for faster and slower
	MyPawn.PlayPissing(0.5 + FRand()/2);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Cover up the pee
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Covering
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			GotoNextState();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		statecount=0;
	}
Begin:
	MyPawn.PlayCovering();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Kick at the cat nip
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CatNipCovering extends Covering
{
	ignores RespondToAnimalCaller;

	///////////////////////////////////////////////////////////////////////////////
	// Convert the catnip pickup into an useable open tin of catnip
	///////////////////////////////////////////////////////////////////////////////
	function KnockOffLid()
	{
		//log(self@"knock off lid",'Debug');
		if(CatNipPickup(EndGoal) != None)
		{
			CatNipPickup(EndGoal).ConvertToUsed();
			EndGoal = None;
			//log(self@"end goal is now none",'Debug');
		}
	}

	function BeginState()
	{
		if(Focus != None
			&& !Focus.bDeleteMe
			&& !Focus.bHidden
			&& LastNipLoc == Focus.Location)
		{
			Super.BeginState();
			// Turn around
			EndGoal = Focus;
			FocalPoint = (MyPawn.Location - Focus.Location) + MyPawn.Location; 
			Focus = None;
			// Get ready for sleeping
			SetNextState('CatNipSleep');
			myPawn.bHighOnCatnip = True;
			//log(self@"now high on catnip and ready for catnip sleep",'Debug');
		}
		else	// Nip has moved! abort mission..
		{
			//log(self@"catnip moved, escaping",'Debug');
			DangerPos = MyPawn.Location;
			GotoStateSave('RunAway');
		}
	}
Begin:
	//log(self@"catnipcovering",'Debug');
	FinishRotation();
	MyPawn.PlayCovering();
	KnockOffLid();
	//log(self@"done with begin in catnipcovering",'Debug');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Move to the left or right, if we notice we're hung up, when we should be 
	// moving
	///////////////////////////////////////////////////////////////////////////////
	function DodgeThinWall()
	{
		local vector startdir, usevect;

		//log("dodge "$VSize(Pawn.Velocity));
		// If we're stopped or in the same spot.
		if(VSize(Pawn.Velocity) < MIN_VELOCITY_FOR_REAL_MOVEMENT)
		{
			LegMotionCaughtCount++;
			if(LegMotionCaughtCount > LEG_MOTION_CAUGHT_MAX)
				NextStateAfterGoal();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// True means it's okay for you to sniff my butt
	///////////////////////////////////////////////////////////////////////////////
	function bool ReadyForASniff(FPSPawn Sniffer)
	{
		InterestPawn = Sniffer;
		GotoStateSave('WaitForButtSniff');
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();
		// See if people are around me and decide what to do about it
		CheckForPeopleAroundMe();

		if(FRand() <= WALKING_MEOW_FREQ)
			MyPawn.PlayHappySound();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToCat
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToCat extends WalkToTarget
{
	ignores ReadyForASniff;

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		DodgeThinWall();
		CheckForObstacles();
		// On the way to a cat butt, you only check for scary people, you don't
		// care to lay down for nice people.
		CheckForScaryPerson(SCARY_PERSON_RAD);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToNip
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToNip extends WalkToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, 
		StartledBySomething, GetReadyToReactToDanger, RespondToTalker, Touch,
		RespondToAnimalCaller, CheckForPeopleAroundMe, ReadyForASniff;
	///////////////////////////////////////////////////////////////////////////////
	//	clean up anims
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		MyPawn.SetToTrot(false);
	}
	///////////////////////////////////////////////////////////////////////////////
	//	Set up anims
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		MyPawn.SetToTrot(true);
	}
Begin:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,MyPawn.TrottingPct);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,MyPawn.TrottingPct);
		InterimChecks();
		Sleep(0.0);
	}
	Goto('Begin');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunningScared
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Marphy - Cats are more likely to be in this running state than RunAway, so adding
// touch check here for bystander comments.
state RunningScared extends RunToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, 
		StartledBySomething, GetReadyToReactToDanger, RespondToTalker;
		
	///////////////////////////////////////////////////////////////////////////////
	// If someone Touches it as it runs they may call for it
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		local P2Pawn otherpawn;
		local AnimalPawn anpawn;

		otherpawn = P2Pawn(Other);
		
		// Marphy - Dead people shouldn't care about cats.
		if(otherpawn != None 	// xPatch: check for none first
			&& otherpawn.Controller != None
			&& !otherpawn.bPlayer
			&& otherpawn.Health > 0)
		{
			if(PersonController(otherpawn.Controller) != None)
			{
				// Marphy - Cops won't sign your petition, so they probably hate cats too.
				if(FRand() <= CALL_KITTY_FREQ && (otherpawn.IsA('Cop') || otherpawn.IsA('AuthorityFigure')))
					otherpawn.Say(otherpawn.MyDialog.lHateCat);
				else
				{
					if(FRand() <= CALL_KITTY_FREQ_NEW)
					{
						if(FRand() <= 0.5)
							otherpawn.Say(otherpawn.MyDialog.lCallCat);
						else
							otherpawn.Say(otherpawn.MyDialog.lHateCat);
					}
				}
			}
		}
		
		else // bump animals
		{
			anpawn = AnimalPawn(Other);
			if(anpawn != None)
			{
				// If we bump another animal, tell him
				if(//DogController(anpawn.Controller) != None
					//|| 
					ElephantController(anpawn.Controller) != None)
				{
					anpawn.Controller.Bump(MyPawn);
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Move to the left or right, if we notice we're hung up, when we should be 
	// moving
	///////////////////////////////////////////////////////////////////////////////
	function DodgeThinWall()
	{
		local vector startdir, usevect;

		//log("dodge "$VSize(Pawn.Velocity));
		// If we're stopped or in the same spot.
		if(VSize(Pawn.Velocity) < MIN_VELOCITY_FOR_REAL_MOVEMENT)
		{
			LegMotionCaughtCount++;
			if(LegMotionCaughtCount > LEG_MOTION_CAUGHT_MAX)
				NextStateAfterGoal();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunAway
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunAway extends Thinking
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, 
		StartledBySomething, GetReadyToReactToDanger, RespondToTalker;

	///////////////////////////////////////////////////////////////////////////////
	// If someone Touches it as it runs they may call for it
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		local P2Pawn otherpawn;
		local AnimalPawn anpawn;

		otherpawn = P2Pawn(Other);

		// Marphy - Dead people shouldn't care about cats.
		if(otherpawn.Controller != None
			&& !otherpawn.bPlayer
			&& otherpawn.Health > 0)
		{
			if(PersonController(otherpawn.Controller) != None)
			{
				// Marphy - Cops won't sign your petition, so they probably hate cats too.
				if(FRand() <= CALL_KITTY_FREQ && (otherpawn.IsA('Cop') || otherpawn.IsA('AuthorityFigure')))
					otherpawn.Say(otherpawn.MyDialog.lHateCat);
				else
				{
					if(FRand() <= CALL_KITTY_FREQ)
					{
						if(FRand() <= 0.5)
							otherpawn.Say(otherpawn.MyDialog.lCallCat);
						else
							otherpawn.Say(otherpawn.MyDialog.lHateCat);
					}
				}
			}
		}
		else // bump animals
		{
			anpawn = AnimalPawn(Other);
			if(anpawn != None)
			{
				// If we bump another animal, tell him
				if(//DogController(anpawn.Controller) != None
					//|| 
					ElephantController(anpawn.Controller) != None)
				{
					anpawn.Controller.Bump(MyPawn);
				}
			}
		}
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

		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	}

	///////////////////////////////////////////////////////////////////////////////
	// come back to this state again
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.SetAnimRunning();
		SetNextState('Thinking');
	}
Begin:
	Sleep(0.1);
	if(!PickRandomDest())
		// Didn't find a valid point, so get nearest
	{
		UseNearestPathNode(2048);
	}

	GotoStateSave('RunningScared');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunAwayFromToucher
// Something has Touched me so run directly away from it, a short distance
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunAwayFromToucher extends RunAway
{
	///////////////////////////////////////////////////////////////////////////////
	// Collide this way and search for the distance most closely matching our
	// desired distance.
	///////////////////////////////////////////////////////////////////////////////
	function TryThisDirection()
	{
		local vector checkpoint, dir;
		local Actor HitActor;
		local vector HitLocation, HitNormal;

		// pick direction away from Toucher
		dir = MyPawn.Location - DangerPos;
		512*Normal(dir);

		// Try to make dir fit terrain
		checkpoint = 512*Normal(dir) + MyPawn.Location;

		GetMovePointOrHugWalls(checkpoint, MyPawn.Location, 512, true);

		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	}

Begin:
	Sleep(0.1);
	TryThisDirection();
	GotoStateSave('RunningScared');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Running around on fire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunOnFire extends RunToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, RespondToTalker, ForceGetDown, 
		MarkerIsHere, damageAttitudeTo, CatchOnFire, CheckForObstacles, Touch,
		StartledBySomething, GetShocked;

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();
		statecount++;
		if(statecount == 2)
		{
			//Say(MyPawn.myDialog.lScreaming);
			statecount=0;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Handle scared flag
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		//Say(MyPawn.myDialog.lScreaming);
		statecount=0;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ImOnFire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ImOnFire
{
	ignores CatchOnFire, GettingDousedInGas, Touch, 
		MarkerIsHere, damageAttitudeTo, StartledBySomething, GetReadyToReactToDanger, 
		InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, RespondToTalker, GetShocked,
		RespondToAnimalCaller;

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function CheckToReturnToNormal()
	{
		if(MyPawn.MyBodyFire == None
			|| MyPawn.MyBodyFire.bDeleteMe)
		{
			MyPawn.MyBodyFire = None;

			if(Attacker == None)
				SetAttacker(InterestPawn);

			DangerPos = MyPawn.Location;
			UseSafeRangeMin = 2*MyPawn.SafeRangeMin;
			GotoStateSave('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// Pick a random spot not through a wall
	///////////////////////////////////////////////////////////////////////////
	function PickNextDest()
	{
		local Actor HitActor;
		local vector HitLocation, HitNormal, checkpoint;

		checkpoint = MyPawn.Location;
		checkpoint.x+=(FRand()*1024) - 512;
		checkpoint.y+=(FRand()*1024) - 512;

		// check for walls
		GetMovePointOrHugWalls(checkpoint, MyPawn.Location, FRand()*512 + 512, true);

		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	}

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}

Begin:
	CheckToReturnToNormal();

	SetNextState('ImOnFire');

	PickNextDest();

	GotoStateSave('RunOnFire');
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
		//log(self@"begin state falling far IN REGULAR CAT CONTROLLER",'Debug');

		MyPawn.SetPhysics(PHYS_FALLING);

		MyPawn.PlayThrownSound();

		MyPawn.PlayFalling();
	}
Begin:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// InDogMouth
// couldn't get it to attach reliably
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InDogMouth
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, RespondToTalker, ForceGetDown, 
		MarkerIsHere, damageAttitudeTo, CheckForObstacles, Touch, BaseChange;

	function BeginState()
	{
		PrintThisState();
		MyPawn.SetCollisionSize(0, 0);
		MyPawn.SetCollision(false, false, false);
		MyPawn.bCollideWorld=false;
		MyPawn.SetPhysics(PHYS_None);
		//MyPawn.SetPhysics(PHYS_Trailer);
		Attacker.AttachToBone(MyPawn, 'DUMMY07');
		MyPawn.PlayFalling();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Shake a lot and then maybe pee or something
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state BeingShocked
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, RespondToTalker, ForceGetDown, 
		MarkerIsHere, damageAttitudeTo, CatchOnFire, CheckForObstacles, Touch,
		StartledBySomething;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function EndingGettingShocked()
	{
		MyPawn.ChangeAnimation();

		InterestPawn = Attacker;

		GotoStateSave('RunAway');
	}
/*
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			EndingGettingShocked();
		}
	}
*/
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.ShouldCrouch(false);
	}

Begin:
	if(Focus != None)
		FocalPoint = Focus.Location;
	Focus = None;	// stop looking around or rotating
	MyPawn.StopAcc();
	MyPawn.PlayShockedAnim();
	Sleep(1.0);
	EndingGettingShocked();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     InventoryGiveClass=Class'Inventory.catinv'
     PickupSound=Sound'AnimalSounds.CatShreak'
}
