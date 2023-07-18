///////////////////////////////////////////////////////////////////////////////
// PLZombieController
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
class PLZombieController extends AWZombieController;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
const FRIENDLY_DAY = 2;		// Day the zombies won't attack the Dude (Wednesday)
const FRIENDLY_DAY_2 = 9;		// Day the zombies won't attack the Dude (2nd Wednesday - Two Weeks)
var bool bTriggeredAttack;

// Try the friendly check immediately, if it fails then GameInfo will call it again for us.
event PostBeginPlay()
{
	Super.PostBeginPlay();
	GameInfoIsNowValid();
}
	
///////////////////////////////////////////////////////////////////////////////
// On Wednesday, zombies won't attack the dude because he's working for them.
///////////////////////////////////////////////////////////////////////////////
simulated function GameInfoIsNowValid()
{
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& (P2GameInfoSingle(Level.Game).GetCurrentDay() == FRIENDLY_DAY
		|| P2GameInfoSingle(Level.Game).GetCurrentDay() == FRIENDLY_DAY_2))
	{
		ZPawn.bPlayerIsFriend = true;
		ZPawn.bPlayerIsEnemy = false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// CanAttackThis
// Valid only for regular zombies, not the floating kind
///////////////////////////////////////////////////////////////////////////////
function bool CanAttackThis(FPSPawn AttackMe)
{
	// "You are not supposed to attack no pawns with no references. You already haven't done it."
	if (AttackMe == None)
		return false;
	
	// Don't attack yourself
	if (AttackMe == Pawn)
		return false;
		
	// Gang check (this will invalidate other zombies)
	if (AttackMe != None && SameGang(AttackMe))
		return false;
		
	// Don't attack Mike J or the Bitch. In fact just don't bother trying to attack bosses
	if (PLBossPawn(AttackMe) != None)
		return false;
	
	// Wednesday dude check.
	if ((ZPawn.bPlayerIsFriend 
		|| P2GameInfoSingle(Level.Game).GetCurrentDay() == FRIENDLY_DAY 
		|| P2GameInfoSingle(Level.Game).GetCurrentDay() == FRIENDLY_DAY_2)
		&& PLDude(AttackMe) != None)
		return false;

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Don't attack the dude on wednesday
// Also don't attack anyone within our own gang (other zombies, Jewcow, etc)
///////////////////////////////////////////////////////////////////////////////
function AttackThisNow(FPSPawn AttackMe, optional bool bForce,
					   optional out byte StateChange)
{
	if (CanAttackThis(AttackMe))
		Super.AttackThisNow(AttackMe, bForce, StateChange);
}

///////////////////////////////////////////////////////////////////////////////
// Based on the difficulty settings, change the zombie's attributes
///////////////////////////////////////////////////////////////////////////////
function RampDifficulty()
{
	local float gamediff, diffoffset;

	gamediff = P2GameInfo(Level.Game).GetGameDifficulty();
	diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset();
	if (PLZombie(Pawn) != None)
		diffoffset += PLZombie(Pawn).GenDifficultyMod;

	if(diffoffset != 0)
	{
		// Make zombies slightly faster animating as the difficulty increases
		ZPawn.GenAnimSpeed+= (diffoffset*DIFF_CHANGE_ANIM_SPEED);
		ZPawn.DefAnimSpeed = ZPawn.GenAnimSpeed;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Someone might have shouted get down, said hi, or asked for money.. see what to do
// Go to state to see if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function RespondToTalker(Pawn Talker, Pawn AttackingShouter, ETalk TalkType, out byte StateChange)
{
	// If we're not supposed to hear things, then don't respond at all.
	if(ZPawn.bIgnoresSenses
			|| ZPawn.bIgnoresHearing)
		return;
		
	// If we're already attacking something, don't bother listening
	if (Attacker != None)
		return;
		
	// PL zombies "respond" to dude asking for money... champ pic... clipboard?
	if (TalkType == TALK_askformoney)
		DonateSetup(Talker, StateChange);
}

///////////////////////////////////////////////////////////////////////////////
// Setup the person to check about donating money.. someone is talking
// to me about donating money, see if I care
///////////////////////////////////////////////////////////////////////////////
function DonateSetup(Pawn Talker, out byte StateChange)
{
	local P2Player p2p;
	local PersonController per;

	if(ZPawn.Physics == PHYS_WALKING
		&& Attacker != Talker
		&& FPSPawn(Talker).MyBodyFire == None
		&& !ZPawn.bMissingLimbs)
	{
		bPreserveMotionValues=true;
		Focus = Talker;

		p2p=P2Player(Talker.Controller);
		if(p2p != None)
		{
			CurrentFloat = p2p.SayTime;
			p2p.InterestPawn = ZPawn;
		}
		else
		{
			PrintStateError(" Talker was bad in DonateSetup! "$Talker);
			return;	// do nothing, something failed
		}

		GotoStateSave('CheckToDonate');

		StateChange=1;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CheckToDonate
// See if you want to donate money (spoilers: zombies won't)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CheckToDonate
{
	///////////////////////////////////////////////////////////////////////////////
	// Make sure whoever is asking you this is really talking to you
	// And make sure they still have the clipboard out
	///////////////////////////////////////////////////////////////////////////////
	function CheckTalkerAttention(optional out byte StateChange)
	{
		local bool bStopListening;
		local P2Player p2p;		
		const LISTEN_TO_DUDE_RADIUS	=	600;

		if(Pawn(Focus) == None)
			bStopListening=true;
		else
		{
			// Check if he's close enough
			if(VSize(Focus.Location - ZPawn.Location) > LISTEN_TO_DUDE_RADIUS)
				bStopListening=true;
			else if(!CanSeePawn(Pawn(Focus), ZPawn))
			// Check to make sure he's even facing us
				bStopListening=true;
			else
			{
				p2p = P2Player(Pawn(Focus).Controller);
				if(p2p == None
					|| !p2p.ClipboardReady())
					bStopListening=true;
			}
		}

		// Walk away from them
		if(bStopListening)
		{
			StateChange=1;
			UnhookFocus();
			DecideNextState();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Unhook from dude
	///////////////////////////////////////////////////////////////////////////////
	function UnhookFocus(optional bool bLostInterest)
	{
		local P2Player p2p;
		local Pawn checkp;

		checkp = Pawn(Focus);
		if(checkp != None)
		{
			p2p = P2Player(checkp.Controller);

			if(p2p != None)
			{
				if(bLostInterest)
					p2p.LostDonation();
				p2p.InterestPawn = None;
			}
		}
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;
	}

	///////////////////////////////////////////////////////////////////////////////
	// If you're old state isn't safe, go back to thinking
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		GotoState('Thinking');
	}

	///////////////////////////////////////////////////////////////////////////////
	// make sure to unhook
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		UnhookFocus();
		ZPawn.ChangePhysicsAnimUpdate(true);
		ZPawn.ChangeAnimation();
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop running before you do this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		bPreserveMotionValues=false;
		ZPawn.StopAcc();
	}

Begin:
	if(FPSPawn(Focus) != None
		&& P2Player(FPSPawn(Focus).Controller) != None)
		Sleep(P2Player(FPSPawn(Focus).Controller).SayTime + 0.3);
	else
		Sleep(1.0);

	CheckTalkerAttention();

	// Wait a tad bit longer
	Sleep(FRand());	
	
AnnoyedWithFocus:
	// Flip them off
	ZPawn.PlayTellOffAnim();
	PrintDialogue("fuck beans ass cock shit");
	CurrentFloat = Say(ZPawn.myDialog.lGenericAnswer, true, true, true);
	// Tourette lines take awhile, just sleep for a second for the dude to get the idea then unhook him
	Sleep(1.0);
	UnhookFocus();
	Sleep(CurrentFloat - 1.0);
	DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AttackTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AttackTarget
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function DecideAttack()
	{
		local float dist, vomitf, userand;
		local bool bswiped;
		local byte StateChange;
		local float SmashChance;
		
		if (PLZombie(Pawn) == None)
			SmashChance = 0.333;
		else
			SmashChance = PLZombie(Pawn).AttackChanceSmash;

		if(Attacker != None
			&& !Attacker.bDeleteMe
			&& Attacker.Health > 0)
		{
			if(ZPawn.bFloating)
				FindGroundAgain(StateChange);
			if(StateChange == 0)
			{
				dist = VSize(Attacker.Location - ZPawn.Location);
				if(dist < ZPawn.AttackRange.Max)
				{
					if(dist < ZPawn.AttackRange.Min)
					{
						userand = FRand();

						// Can do big smash either with legs
						// or floating, and has both arms
						if((!ZPawn.bMissingLegParts
								|| ZPawn.bFloating)
							&& ZPawn.HasBothArms()
							&& userand < SmashChance)
						{
							GotoStateSave('BigSmash');
							bSwiped=true;
						}
						// single arm swung, melee attack
						else if(userand < 0.5
							&& ZPawn.HasLeftArm())
						{
							GotoStateSave('SwipeLeft');
							bSwiped=true;
						}
						else if(ZPawn.HasRightArm())
						{
							GotoStateSave('SwipeRight');
							bSwiped=true;
						}
					}

					// Too far, tourette, spit, run or walk again
					if(!bSwiped)
					{
						// If you're very close to swiping range, be less likely to attack
						// by spitting, unless you don't have arms
						if(dist < 2*ZPawn.AttackRange.Min
							&& ZPawn.HasLeftArm()
							&& ZPawn.HasRightArm())
							vomitf = CLOSE_VOMIT_RATIO*ZPawn.VomitFreq;
						else
							vomitf = ZPawn.VomitFreq;

						// ranged attack
						if(FRand() <= vomitf)
						{
							GotoStateSave('VomitAttack');
						}
						// If we're a tourette, hang out for a moment
						else if(ZPawn.PawnInitialState == ZPawn.EPawnInitialState.EP_Turret)
						{
							SetNextState('AttackTarget');
							GotoStateSave('TurretWait');
						}
						else // check how to move there
						{
							SetNextState('AttackTarget');
							SetEndGoal(Attacker, DEFAULT_END_RADIUS);

							if(ZPawn.bIsDeathCrawling
								|| ZPawn.bWantsToDeathCrawl
								|| ZPawn.bMissingLegParts)
								GotoStateSave('CrawlToAttacker');
							else if(FRand() < ZPawn.ChargeFreq)
								GotoStateSave('RunToAttacker');
							else
								GotoStateSave('WalkToAttacker');
						}
					}

				}
				else
				{
					SetNextState('AttackTarget');
					if(ZPawn.PawnInitialState == ZPawn.EPawnInitialState.EP_Turret)
					{
						GotoStateSave('TurretWait');
					}
					else
					{
						SetEndGoal(Attacker, DEFAULT_END_RADIUS);
						if(ZPawn.bIsDeathCrawling
							|| ZPawn.bWantsToDeathCrawl
							|| ZPawn.bMissingLegParts)
							GotoStateSave('CrawlToAttacker');
						else
							GotoStateSave('WalkToAttacker');
					}
				}
			}
		}
		else
		{
			SetAttacker(None);
			if(ZPawn.PawnInitialState == ZPawn.EPawnInitialState.EP_Turret)
			{
				GotoStateSave('ActAsTurret');
			}
			else
				GotoStateSave('Thinking');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// VomitAttack
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state VomitAttack
{
	/*
	event BeginState()
	{
		Super.BeginState();
		Pawn.TurnLeftAnim=ZPawn.GetAnimVomitAttack();
		Pawn.TurnRightAnim=ZPawn.GetAnimVomitAttack();
		Focus = Attacker;
	}
	event EndState()
	{
		Pawn.TurnLeftAnim=Pawn.MovementAnims[0];
		Pawn.TurnRightAnim=Pawn.MovementAnims[0];
		Focus = None;
	}
	*/
Begin:
	ZPawn.PlayAnimVomitAttack();
}

///////////////////////////////////////////////////////////////////////////////
// LookForEnemies
// Looks for things to hurt
///////////////////////////////////////////////////////////////////////////////
function LookForEnemies(out byte StateChange)
{
	local FPSPawn P;
	
	foreach ZPawn.RadiusActors(class'FPSPawn', P, ENEMY_CHECK)
	{
		if (CanAttackThis(P))
		{
			AttackThisNow(P, false, StateChange);
			// Break out if it was successful.
			if (StateChange != 0)
				break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Occasionally look for things to hurt
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Thinking
{
	function DecideNext()
	{
		local byte StateChange;		
		
		LookForEnemies(StateChange);
		if (StateChange == 0)
			Super.DecideNext();
	}
}
state WalkToTarget
{
	function InterimChecks()
	{
		local byte StateChange;		
		
		LookForEnemies(StateChange);
		if (StateChange == 0)
			Super.InterimChecks();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Protest walk to next loop point
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ProtestToTarget extends WalkToTarget
{
	ignores RespondToTalker, ForceGetDown, HandleFireInWay, DodgeThinWall, 
		SeeWeaponDrop, Trigger, MarkerIsHere, ObservePawn,
		DoTourettes, FindEnemies, CanWaitOnZombie, HandleWaitAndMove, LookForEnemies;

	///////////////////////////////////////////////////////////////////////////////
	// When we get triggered, we attack the player.
	///////////////////////////////////////////////////////////////////////////////
	function Trigger( actor Other, pawn EventInstigator )
	{
		local P2Player keepp;

		ZPawn.bIgnoresSenses=false;
		ZPawn.bIgnoresHearing=false;

		// If you don't have the player as your attacker already, then attack
		// him, otherwise, don't execute this
		if(Attacker == None
			|| !Attacker.bPlayer)
		{
			keepp = GetRandomPlayer();

			SetAttacker(keepp.MyPawn);
			InterestPawn = Attacker;
			ProtestingDisrupted(Attacker, InterestPawn,	true);
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// Something annoying, but not really gross or life threatening
	// has been done to me, so check to maybe notice
	///////////////////////////////////////////////////////////////////////////
	function InterestIsAnnoyingUs(Actor Other, bool bMild)
	{
		if(InterestActor == None)
		{
			InterestActor = Other;
			// Turn to idiot
			Focus=Other;
			// Get angry
			ZPawn.SetMood(MOOD_Angry, 1.0);
			// Be annoyed with your Interest pawn
			GotoState('ProtestToTarget', 'Annoyed');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if dude bumps you as you march
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		if(P2Pawn(Other) != None
			&& P2Pawn(Other).Health > 0
			&& P2Pawn(Other).bPlayer)
			InterestIsAnnoyingUs(Other, true);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Don't attack the dude on wednesday
	// Also don't attack anyone within our own gang (other zombies, Jewcow, etc)
	///////////////////////////////////////////////////////////////////////////////
	function AttackThisNow(FPSPawn AttackMe, optional bool bForce,
						   optional out byte StateChange)
	{
		if (CanAttackThis(AttackMe))
			Super.AttackThisNow(AttackMe, bForce, StateChange);
		else
		{
			// The dude kicked us or something, so get annoyed with him for ruining our fun
			// Something bad happened so tell the others
			InterestPawn = AttackMe;
			Focus = InterestPawn;
			if(MyProtestInfo != None)
				MyProtestInfo.DisruptGroup(self, AttackMe, InterestPawn, bTriggeredAttack);
			SetNextState('Thinking');
			GotoStateSave('CheckToDonate','AnnoyedWithFocus');
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// A protestor in a group has been disrupted, so do something about it.
	///////////////////////////////////////////////////////////////////////////
	function ProtestingDisrupted(FPSPawn NewAttacker, FPSPawn NewInterestPawn,
								optional bool bKnowAttacker)
	{
		// We've already been triggered into attacking, so quit now
		if(bTriggeredAttack)
			return;

		bTriggeredAttack = true;
		AttackThisNow(NewAttacker);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		OldEndGoal = ZPawn.MyLoopPoint;
		ZPawn.MyLoopPoint = ZPawn.MyLoopPoint.NextPoint;
		// Store the offset speed for this row of people
		CurrentFloat = ZPawn.MyLoopPoint.WalkToReductionPct;

		bStraightPath=true;
		SetNextState(GetStateName());
		SetEndGoal(ZPawn.MyLoopPoint, PROTEST_END_RADIUS);

		GotoState(GetStateName(), 'Begin');
		BeginState();
	}

	///////////////////////////////////////////////////////////////////////////////
	// If we're heading to a new loop point, just walk straight there, if not
	// then use your super
	///////////////////////////////////////////////////////////////////////////////
	function SetActorTarget(Actor Dest, optional bool bStrictCheck)
	{
		if(LoopPoint(Dest) != None)
		{
			MoveTarget = Dest;
			if(!bDontSetFocus)
				Focus = MoveTarget;

			UseEndRadius = MoveTarget.CollisionRadius;
		}
		else
			SetActorTarget(Dest, bStrictCheck);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		ZPawn.SetProtesting(true);
		// Store the offset speed for this row of people
		// This determines how much slower we will walk as we move towards this point
		// It should be 1.0 on straight aways, and less for the group that's tighest
		// in a turn. 
		CurrentFloat = ZPawn.MyLoopPoint.WalkToReductionPct;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		ZPawn.SetProtesting(false);

		// Drop things if you had them in your hands
		ZPawn.DropBoltons(ZPawn.Velocity);

		// Something bad happened so tell the others
		if(MyProtestInfo != None)
			MyProtestInfo.DisruptGroup(self, Attacker, InterestPawn, bTriggeredAttack);
			
		// Reset protest sign attachment
		if (Pawn.Weapon != None
			&& Pawn.Weapon.ThirdPersonActor != None)
		{
			Pawn.Weapon.ThirdPersonActor.SetRelativeLocation(Pawn.Weapon.ThirdPersonRelativeLocation);
			Pawn.Weapon.ThirdPersonActor.SetRelativeRotation(Pawn.Weapon.ThirdPersonRelativeRotation);
		}
	}
Begin:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,ZPawn.MovementPct*CurrentFloat,,,true);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,ZPawn.MovementPct*CurrentFloat,true);
		InterimChecks();
		Sleep(0.0);
	}
	Goto('Begin');// run this state again
Annoyed:
	// Stop moving
	ZPawn.StopAcc();
	// return focus early
	Focus = EndGoal;
	Sleep(0.5 + FRand()/2);

	// Reset them yelling
	ZPawn.SetProtesting(false);
	ZPawn.SetProtesting(true);

	// Go back to protesting/marching
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// March walk to next loop point
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state MarchToTarget extends ProtestToTarget
{
	ignores HandleStasisChange, InterestIsAnnoyingUs, GetHitByDeadThing;
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		ZPawn.SetProtesting(false);
		ZPawn.SetMarching(true);
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		ZPawn.SetMarching(false);
	}
Begin:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,ZPawn.MovementPct*CurrentFloat,,,true);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,ZPawn.MovementPct*CurrentFloat,true);
		InterimChecks();
		Sleep(0.0);
	}
	Goto('Begin');// run this state again
Annoyed:
	// Stop moving
	ZPawn.StopAcc();
	// return focus early
	Focus = EndGoal;
	Sleep(0.5 + FRand()/2);

	// Reset them yelling
	ZPawn.SetMarching(false);
	ZPawn.SetMarching(true);

	// Go back to protesting/marching
	Goto('Begin');
}
