///////////////////////////////////////////////////////////////////////////////
// AWBystanderController
// Copyright 2003 RWS, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWBystanderController extends BystanderController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars
//var class<Actor> LookZombieClass;	// zombies to look for

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const TURRET_TRACE_DIST	= 20000;


///////////////////////////////////////////////////////////////////////////////
// Call out to those around you to point out the attacker
///////////////////////////////////////////////////////////////////////////////
function AskWhereAttackerIs(vector CheckPos)
{
	// STUB needs this or it can crash when changing states from RecognizeAttacker
}

///////////////////////////////////////////////////////////////////////////////
// Run screaming from where you are
///////////////////////////////////////////////////////////////////////////////
function SetToPanic()
{
	DangerPos = MyPawn.Location;
	DangerPos.x += ((Rand(256)) - 128);
	DangerPos.y += ((Rand(256)) - 128);
	MyPawn.DropBoltons(MyPawn.Velocity);
	// Decide current safe min
	UseSafeRangeMin = 10*MyPawn.SafeRangeMin;
	InterestPawn = MyPawn;
	SetAttacker(MyPawn);
	SetNextState('FleeForever');
}

///////////////////////////////////////////////////////////////////////////////
// Enter a ladder friendly state
///////////////////////////////////////////////////////////////////////////////
function StartClimbLadder()
{
	//log(self$" start climb ladder "$Attacker$" End goal "$endgoal);

	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;

	if(Attacker != None)
	{
		SetNextState('ShootAtAttacker');
		SetEndGoal(Attacker, DEFAULT_END_RADIUS);
		GotoStateSave('ClimbingLadder');
	}
	else if(EndGoal != None)
	{
		SetNextState('Thinking');
		SetEndGoal(EndGoal, DEFAULT_END_RADIUS);
		GotoStateSave('ClimbingLadder');
	}
	else
	{
		SetNextState('Thinking');
		SetEndPoint(EndPoint, DEFAULT_END_RADIUS);
		GotoStateSave('ClimbingLadder');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Finish up climbing the ladder
///////////////////////////////////////////////////////////////////////////////
function EndClimbLadder()
{
	Super.EndClimbLadder();
	//log(self$" end climb ladder");

	if(Attacker != None)
	{
		GotoStateSave('ShootAtAttacker');
	}
	else
	{
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		SetNextState('Thinking');
		GotoStateSave('WalkToTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Trigger functionality:
// If you set InitAttackTag and they have a weapon, they'll attack that pawn,
// otherwise, it goes back to the super (to attack the player or run)
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	local FPSPawn keepp, PlayerP;

	if(MyPawn.bHasViolentWeapon
		&& AWPerson(MyPawn).InitAttackTag != '')
	{
		SetToAttackTag(AWPerson(MyPawn).InitAttackTag);
		GotoNextState();
	}
	else
		Super.Trigger(Other, EventInstigator);
}

///////////////////////////////////////////////////////////////////////////////
// Face the direction we are and be ready to kill someone
///////////////////////////////////////////////////////////////////////////////
function SetToTurret()
{
	local FPSPawn keepp;
	local Inventory inv;

	SwitchToBestWeapon();

	MyPawn.SetMood(MOOD_Combat, 1.0);
	// Make sure he never tries for cover
	MyPawn.WillUseCover=0.0;
	// Set all his bullet weapons to full trace dist,
	// so they can shoot from where they are, when they get
	// a line of site
	inv = MyPawn.Inventory;
	while(inv != None)
	{
		if(P2Weapon(inv) != None
			&& !P2Weapon(inv).bMeleeWeapon)
			P2Weapon(inv).TraceDist = TURRET_TRACE_DIST;

		inv = inv.Inventory;
	}

	// If he hates the player, start attacking now
	if(MyPawn.bPlayerIsEnemy)
	{
		keepp = GetRandomPlayer().MyPawn;

		// check for some one to attack
		if(keepp != None)
		{
			SetAttacker(keepp);
			MyPawn.DropBoltons(Velocity);
			SetNextState('ShootAtAttacker');
		}
		else
			SetNextState('ActAsTurret');
	}
	else
		SetNextState('ActAsTurret');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function StartInHalf()
{
	LimbChoppedOff(None, MyPawn.Location);
	SetNextState(GetStateName());
}

///////////////////////////////////////////////////////////////////////////////
// React to an oncoming projectile or guy attacking you with blade
//
// Put in after the fact so it's hard to extend all the original states
// and have this plug in to them. We just block the original states outright
///////////////////////////////////////////////////////////////////////////////
function PerfomBlockMelee(Actor MeleeAttack)
{
	local P2Pawn usepawn;
	local Projectile useproj;

	// Find our attacker
	if(P2Pawn(MeleeAttack) != None)
		usepawn = P2Pawn(MeleeAttack);
	else if(P2Pawn(MeleeAttack.Owner) != None)
		usepawn = P2Pawn(MeleeAttack.Owner);

	// Find our projectile, if there is one
	if(Projectile(MeleeAttack) != None)
		useproj = Projectile(MeleeAttack);

	//log(Self$" PerfomBlockMelee "$MeleeAttack);
	if(!IsInState('BeingShocked')
		&& !IsInState('DoPuking')
		&& !IsInState('DoKicking')
		&& !MyPawn.bWantsToDeathCrawl
		&& !MyPawn.bIsDeathCrawling
		&& usepawn != None)
	{
		//log(self$" ready to block "$MeleeAttack$" attacker "$MeleeAttack.Owner);
		if(!SameGang(usepawn))
		{
			// Don't attack friends doing this
			if(!usepawn.bPlayer 
				|| !MyPawn.bPlayerIsFriend)
			{
				// He's your new attacker now, the owner of the projectile, or the 
				// guy attacking
				SetAttacker(usepawn);

				Focus = MeleeAttack;
				GotoStateSave('BlockMelee');
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// You successfully blocked a single melee attack
///////////////////////////////////////////////////////////////////////////////
function DidBlockMelee(out byte StateChange)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do about this danger
///////////////////////////////////////////////////////////////////////////////
// Moved to PersonController
/*
function GetReadyToReactToDanger(class<TimedMarker> dangerhere,
								FPSPawn CreatorPawn,
								Actor OriginActor,
								vector blipLoc,
								optional out byte StateChange)
{
	// Handle zombies
	if(AWZombie(CreatorPawn) != None)
	{
		if(MyPawn.bHasViolentWeapon)
		{
			// Drop things if you had them in your hands
			MyPawn.DropBoltons(MyPawn.Velocity);
			SetAttacker(CreatorPawn);
			MakeMoreAlert();
			SaveAttackerData(CreatorPawn);
			PrintDialogue("Animals must die!");
			Say(MyPawn.myDialog.lStartAttackingAnimal);
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
			StateChange=1;
		}
		else
		{
			GenSafeRangeMin();
			InterestPawn = CreatorPawn;
			SetAttacker(InterestPawn);
			DangerPos = Attacker.Location;
			GotoStateSave('FleeFromAttacker');
			StateChange=1;
		}
	}
	// Ignore dog attacks, if you're friends and they're not attacking you
	else if(AWDogPawn(CreatorPawn) != None
		&& AWPerson(Pawn).bDogFriend
		&& AnimalController(CreatorPawn.Controller) != None
		&& AnimalController(CreatorPawn.Controller).Attacker != MyPawn)
	{
		// STUB
		return;
	}
	else
		Super.GetReadyToReactToDanger(dangerhere, CreatorPawn, OriginActor, blipLoc, StateChange);
}
*/

///////////////////////////////////////////////////////////////////////////////
// We've seen the pawn, now decide if we care
// Returns true if there state changes at some point
///////////////////////////////////////////////////////////////////////////////
// Moved to PersonController
/*
function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
{
	// Handle zombies
	if(AWZombie(LookAtMe) != None)
	{
		if(MyPawn.bHasViolentWeapon)
		{
			// Drop things if you had them in your hands
			MyPawn.DropBoltons(MyPawn.Velocity);
			SetAttacker(LookAtMe);
			MakeMoreAlert();
			SaveAttackerData(LookAtMe);
			PrintDialogue("Animals must die!");
			Say(MyPawn.myDialog.lStartAttackingAnimal);
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
			StateChange=1;
		}
		else
		{
			GenSafeRangeMin();
			InterestPawn = LookAtMe;
			SetAttacker(InterestPawn);
			DangerPos = Attacker.Location;
			GotoStateSave('FleeFromAttacker');
			StateChange=1;
		}
	}
	else
		Super.ActOnPawnLooks(LookAtMe, StateChange);
}
*/
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Moved to PersonController
/*
function LimbChoppedOff(FPSPawn Doer, vector HitLocation)
{
	if(MyPawn.Physics == PHYS_WALKING
		&& MyPawn.Health > 0)
	{
		if(Doer != None)
		{
			SetAttacker(Doer);
			DangerPos = Doer.Location;
		}

		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);

		// drop your weapon too--you're not getting up from this
		ThrowWeapon();

		// Either fall to the ground and crawl, or run away
		// Or if they are missing any leg parts, they fall automatically
		if(!AWPerson(MyPawn).bMissingLegParts
			&& FRand() < MyPawn.PainThreshold)
		{
			// Decide current safe min
			UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;
			if(Attacker != None)
				GotoStateSave('FleeFromAttacker');
		}
		else // too weak to run or can't stand up
		{
			DoDeathCrawlAway(true);
		}
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// First check if this pawn can use distance based attacks, with two weapons.
// Switch to the best one there, first. If not, then just use your best weapon
//
// If we're missing a limb, don't pull out a weapon. Fall down instead.
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToBestWeapon()
{
	// Must have all your limbs to draw a weapon, otherwise you fall
	if(!AWPerson(MyPawn).bMissingLimbs)
	{
		Super.SwitchToBestWeapon();
	}
	else
		DoDeathCrawlAway(true);
}

///////////////////////////////////////////////////////////////////////////////
// You've just caught on fire.. how do you feel about it?
///////////////////////////////////////////////////////////////////////////////
function CatchOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
	// Only catch on fire again, if we haven't already burned once
	if(MyPawn.Skins[0] != MyPawn.BurnSkin)
		Super.CatchOnFire(Doer, bIsNapalm);
}

///////////////////////////////////////////////////////////////////////////////
// You're catching on fire, but staying in the same state (deathcrawling,
// cowering, something like that.
///////////////////////////////////////////////////////////////////////////////
function CatchOnFireCantMove(FPSPawn Doer, optional bool bIsNapalm)
{
	// Only catch on fire again, if we haven't already burned once
	if(MyPawn.Skins[0] != MyPawn.BurnSkin)
		Super.CatchOnFireCantMove(Doer, bIsNapalm);
}

///////////////////////////////////////////////////////////////////////////////
// Someone is pickpocketing me
///////////////////////////////////////////////////////////////////////////////
function SetupGettingPickPocketed(P2Pawn MuggerGuy)
{
	InterestPawn = MuggerGuy;
	InterestActor = Focus; // save old focus
	Focus = InterestPawn;
	SetAttacker(MuggerGuy);
	DangerPos = MuggerGuy.Location;
	GotoStateSave('GettingPickPocketed');
}

///////////////////////////////////////////////////////////////////////////////
// Freak out instantly, no matter what, if it's a cat attached to me
///////////////////////////////////////////////////////////////////////////////
// Moved to PersonController
/*
function DervishAttack(Pawn CatAttacker)
{
	if(CatAttacker != Attacker)
	{
		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);
		DangerPos = CatAttacker.Location;
		// Dist between attacker and me
		CurrentDist = 0;
		// Decide current safe min
		GenSafeRangeMin();
		InterestPawn = FPSPawn(CatAttacker);
		SetAttacker(CatAttacker);
		// Only run if you're not deathcrawling
		if(!MyPawn.bWantsToDeathCrawl
			&& !MyPawn.bIsDeathCrawling)
		{
			if(!AWPerson(MyPawn).bMissingLegParts)
				GotoStateSave('FleeFromAttacker');
			else
				DoDeathCrawlAway(true);
		}
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// Decide how to handle being attacked or having a limb cut off
///////////////////////////////////////////////////////////////////////////////
// Moved to PersonController
/*
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage,
					   class<DamageType> damageType, vector Momentum)
{
	// Freak out instantly, no matter what, if it's a cat attached to me
	if(ClassIsChildOf(damageType, class'DervishDamage'))
	{
		DervishAttack(InstigatedBy);
	}
	else if(ClassIsChildOf(damageType, class'ScytheDamage')
		|| ClassIsChildOf(damageType, class'MacheteDamage'))
		LimbChoppedOff(FPSPawn(InstigatedBy), hitlocation);
	else
		Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
}
*/

///////////////////////////////////////////////////////////////////////////////
// Look around for zombies and either kill them or run
///////////////////////////////////////////////////////////////////////////////
// Moved to Bystander/Police
/*
function LookForZombies(optional out byte StateChange)
{
	local Actor CheckP;
	local AWZombie KeepP;
	local float checkdist, keepdist;

	if(LookZombieClass != None)
	{
		checkdist = MyPawn.ReportLooksRadius;
		keepdist = checkdist;

		foreach MyPawn.CollidingActors(LookZombieClass, CheckP, MyPawn.ReportLooksRadius, MyPawn.Location)
		{
			// If not me
			if(CheckP != MyPawn
				&& !CheckP.bDeleteMe
				&& AWZombie(CheckP) != None
				// if still alive (and not dying)
				&& AWZombie(CheckP).Health > 0)
			{
				if(KeepP == None)
					KeepP = AWZombie(CheckP);
				checkdist = VSize(CheckP.Location - MyPawn.Location);
				if(checkdist < keepdist)
				{
					KeepP = AWZombie(CheckP);
					keepdist = checkdist;
				}
			}
		}
	}
	// If we found one deal with him
	if(KeepP != None)
	{
		// Tell the SP NPC's about the zombie
		CheckObservePawnLooks(KeepP);
		StateChange = 1;
		return;
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do next
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Thinking
{
	///////////////////////////////////////////////////////////////////////////
	// nothing on my mind when we start
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local byte StateChange;

		//  If we're missing anything, and we're trying to walk normally
		// give up and deathcrawl
		if(AWPerson(MyPawn).bMissingLimbs)
			DoDeathCrawlAway(true);
		else
			Super.BeginState();

		if(AWPerson(MyPawn).bLookForZombies)
			LookForZombies(StateChange);

		if(StateChange == 0)
		{
			// If you try to think as a turret--don't! Go back to being a turret!
			if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
				GotoStateSave('ActAsTurret');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand with your gun out and be ready to kill, but don't move from here
// Also now, look for zombies
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ActAsTurret
{
Begin:
	if(AWPerson(MyPawn).bLookForZombies)
		LookForZombies();
	// Don't report your weapon
	Sleep(Rand(10) + 5);

	// Because he's just standing around anyway, not doing much, don't wait
	// to go into stasis--go as soon as you can.
	if(bPendingStasis
		|| MyPawn.TryToWaitForStasis())
		GoIntoStasis();

	// Randomly, and not very often, check if you want to do an idle
	if(!LookAroundWithHead(Frand(), 0.1, 0.2, 0.3, 0.4, 1.0))
	{
		// If you didn't look around then think about doing an idle
		if(FRand() <= DO_IDLE_FREQ)
			GotoStateSave('PerformIdle');
	}

	Goto('Begin');
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CowerInABall
// You're so scared you can't move any more
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CowerInABall
{
	///////////////////////////////////////////////////////////////////////////////
	// check to keep cowering
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			CurrentDist = VSize(Attacker.Location - MyPawn.Location);

			if(CurrentDist < COWER_DISTANCE)
			{
				GotoState(GetStateName());
			}
			// Definitely continue to crawl if you're missing a limb
			else if(AWPerson(MyPawn).bMissingLimbs)
			{
				GotoState('DeathCrawlFromAttacker');
			}
			else
			{
				GotoState(MyOldState);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CowerInABallShocked 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CowerInABallShocked
{
	///////////////////////////////////////////////////////////////////////////////
	// check to keep cowering
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		local vector dir, checkpoint;

		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			CurrentFloat = CurrentFloat - 1;

			// Death crawl if you're missing limbs
			if(AWPerson(MyPawn).bMissingLimbs)
			{
				dir = vector(MyPawn.Rotation);

				checkpoint = MyPawn.Location + 8192*dir;
				// Don't adjust for walls, just keep crawling when you hit one
				SetEndPoint(checkpoint, DEFAULT_END_RADIUS);

				// Face where we're going
				Focus = None;
				FocalPoint = checkpoint;
				GotoState('DeathCrawlFromAttacker');
			}
			else if(CurrentFloat > 0)
			{
				MyPawn.PlayCoweringInBallShockedAnim(FRand()*CurrentFloat + 0.5, 0.1);
			}
			else	// get up again
			{
				MyPawn.ShouldCower(false);
				MyPawn.ChangeAnimation();

				GotoState('RestAfterBigHurt');
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// GettingPickPocketed
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GettingPickPocketed extends TalkingWithSomeoneSlave
{
	ignores CheckObservePawnLooks, MarkerIsHere;

Begin:
	Sleep(2.5);
	Focus = InterestActor;	// look away
	MyPawn.SetMood(MOOD_Angry, 1.0);
	Sleep(1.5);
	Focus = InterestPawn;	// look back again as you realize what happened
	SayTime = Say(MyPawn.myDialog.lwhatthe, true);
	Sleep(1.0);
	// You're a wimp, so complain, then get a cop
	if(!MyPawn.bHasViolentWeapon)
	{
		bDontSetFocus=false;
		GotoStateSave('LookForCop');
	}
	else
	{
		GotoStateSave('AssessAttacker');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// BlockMelee
// Reflects/blocks melee or flying melee attack say from a machete, or a scythe
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// moved to personcontroller
/*
state BlockMelee
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, 
		RespondToTalker, RatOutAttacker, PerformInterestAction, MarkerIsHere, 
		RespondToQuestionNegatively, RocketIsAfterMe,
		RespondToCopBother, DecideToListen, GettingDousedInGas, PersonStoleSomething,
		CheckObservePawnLooks;

	///////////////////////////////////////////////////////////////////////////////
	// check to keep cowering
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(AWPerson(MyPawn).IsBlockChannel(channel))
		{
			DecideNextState();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// You need to block another hit! Don't let your guard down yet
	///////////////////////////////////////////////////////////////////////////////
	function PerfomBlockMelee(Actor MeleeAttacker)
	{
		MeleeBlocking++;
		// reset blocking
		GotoState(GetStateName(), 'Begin');
	}

	///////////////////////////////////////////////////////////////////////////////
	// You successfully blocked a single melee attack
	///////////////////////////////////////////////////////////////////////////////
	function DidBlockMelee(out byte StateChange)
	{
		StateChange = 1;
		MeleeBlocking--;
		if(MeleeBlocking <= 0)
		{
			//DecideNextState();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		if(Attacker != None)
			GotoStateSave('ShootAtAttacker');
		else
			GotoStateSave('Thinking');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		// reset how many you're blocking
		MeleeBlocking=0;
		MyPawn.ChangePhysicsAnimUpdate(true);
		// Stop animating block
		AWPerson(MyPawn).FinishBlockAnim();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// clear vars
		EndGoal = None;
		EndRadius = 0;
		bSaidGetDown=false;
		MyPawn.StopAcc();
		AWPerson(MyPawn).PlayBlockMeleeAnim();
		// Say you're blocking one hit
		MeleeBlocking++;
		MyPawn.SetMood(MOOD_Angry, 1.0);
	}

Begin:
	Sleep(AWPerson(MyPawn).BlockMeleeTime + FRand()*AWPerson(MyPawn).BlockMeleeTime);

	DecideNextState();
}
*/
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ClimbingLadder
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ClimbingLadder extends RunToTarget
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, 
		RespondToTalker, RatOutAttacker, PerformInterestAction, MarkerIsHere, 
		RespondToQuestionNegatively, RocketIsAfterMe,
		RespondToCopBother, DecideToListen, GettingDousedInGas, PersonStoleSomething,
		NotifyTakeHit, LookForZombies, damageAttitudeTo, CheckObservePawnLooks,
		StartClimbLadder;
}

///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     LookZombieClass=Class'AWZombie'
}
