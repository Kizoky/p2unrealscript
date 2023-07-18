///////////////////////////////////////////////////////////////////////////////
// BystanderController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for bystanders
///////////////////////////////////////////////////////////////////////////////
class BystanderController extends PersonController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////


const BEG_WILL_DO_DEATH_CRAWL=	1;
const BEG_WILL_RUN_FOR_COP	=	2;
const BEG_WILL_GO_FOR_GUN	=	3;
const BEG_WILL_TALK_BACK	=	4;

const BABBLE_WHILE_BEGGING	=	0.7;
const DEFAULT_BEG_TIME		=	3.0;

const DEATH_CRAWL_PERCENT	=	0.4;

const VERBAL_ABUSE_LOOP_MAX	=	8;

const ROGUE_COP_SCREAM	=	0.5;

const DANGER_TOO_CLOSE	=	256;

const FIND_COP_RADIUS	=	2048;
const FIND_A_COP_FREQ	=	0.1;

const SNICKER_AT_NAKED	=	600;
const COMMENT_ON_NAKED	=	300;

const COWHEAD_COMMENT_FREQ	=	0.25;

const KICK_DEAD_DUDE		=	0.7;

const RIOT_GUN_RAND				= 3;
const RIOT_BIG_GUN_PICK_RAND	= 100;
const RIOT_HATE_PLAYER			= 1.0;
const RIOT_HEALTH_INCREASE		= 2.0;
const RIOT_DAMAGE_INCREASE		= 2.0;
const RIOT_MELEE_BLOCK			= 0.75;

var bool bLaughedAtDudesPackage;

//const IDLE_CELL_FREQ			= 0.001;
const CELL_TALK_LOOP			= 4.0;
const CELL_TALK_WAIT			= 2.0;
const CELL_TALK_RING			= 3.0;

var bool bLoopCell;

var int TimesKickedDeadThing;
const MAX_KICK_DEAD_THING		= 3;		// max number of times we wanna kick a dead thing

const WALK_PATROL_STATE				='PatrolToTarget';
const RUN_PATROL_STATE				='RunPatrolToTarget';
var bool bPatrolJail;			// If you're patrolling, use PatrolJailToTarget

var array<Sound> FartSounds;

// Change by NickP: NicksCoop fix
var bool bCoopAlertMode;
var float fForceAlertTime;
const FORCE_ALERT_DELAY = 0.1;
// End

///////////////////////////////////////////////////////////////////////////////
// Chance of going into cell phone idle sequence.
///////////////////////////////////////////////////////////////////////////////
function CheckForCellIdle()
{
	//log(self@"check for cell idle"@FreeToSeekPlayer()@f@P2MoCapPawn(Pawn).bCellUser,'Debug');
	// Now this checks for other types of idles
	if (FreeToSeekPlayer())
	{
		if (P2MoCapPawn(Pawn).bCellUser && frand() <= P2MoCapPawn(Pawn).IdleCellPct && !P2MoCapPawn(Pawn).bIsFat)
			GotoState('PerformCellIdle');
		else if (frand() <= P2MoCapPawn(Pawn).IdleFartPct)
			GotoState('Farting');
		else if (frand() <= P2MoCapPawn(Pawn).IdleSneezePct)
		{
			// maybe do a sneeze walk
			if (IsInState('WalkToTarget') && FRand() < 0.5)
			{
				bPreserveMotionValues=true;
				GotoStateSave('SneezingWalking');
			}
			else
				GotoState('Sneezing');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Bystanders have view pitching now
///////////////////////////////////////////////////////////////////////////////
// DISABLED for performance - Rick
/*
simulated event Tick(float Delta)
{
	local rotator ORot;
	local vector VDiff;
	local float PDiff;

	Super.Tick(Delta);

	if (Focus != None)
	{
		if (!Focus.bStatic)
		{
			VDiff = Focus.Location - Pawn.Location;
			ORot = Rotator(VDiff);
			// Only look up/down at focus if we're looking directly at them, otherwise it looks stupid
			if (CanSeePoint(Pawn, Focus.Location)
				&& !IsInState('ThrownThroughAir')
				&& !IsInState('DoPuking')
				&& !IsInState('BeingShocked')
				&& !IsInState('RestFromAttacker')
				&& !IsInState('DanceHere')
				&& !IsInState('PlayArcadeGame')
				&& !IsInState('AttackedByChompy')
				&& !IsInState('WipeFace')
				&& !IsInState('PrepDeathCrawl')
				&& !IsInState('RunOnFire')
				&& !IsInState('DeathCrawlFromAttacker')
				&& !IsInState('CowerInABall')
				&& !IsInState('ImOnFire')
				)
				Pawn.ViewPitch = Clamp(ORot.Pitch / 256, 0, 255);
			else
				Pawn.ViewPitch = 0;
		}
		else
			Pawn.ViewPitch = 0;
//		log(self@"focus is"@Focus@"VDiff"@VDiff@"ORot"@ORot@"Rotation"@Pawn.Rotation);
	}
	else
	{
		Focus = None;	// Null out invalid Focus references
		Pawn.ViewPitch = 0;
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// start: set up functions (from spawner and the like) using PawnInitialState
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Find a cop and sick them on the player
///////////////////////////////////////////////////////////////////////////////
function SetToFindCop(FPSPawn PlayerP)
{
	local P2Player keepp;

	if(PlayerP == None)
		keepp = GetRandomPlayer();
	else
		keepp = P2Player(PlayerP.Controller);

	// check for some one to attack
	if(keepp != None)
	{
		UseSafeRangeMin = VSize(MyPawn.Location - keepp.Location) + MyPawn.CollisionRadius;
		PlayerSightReaction = keepp.SightReaction;
		InterestPawn = keepp.MyPawn;
		DangerPos = keepp.Location;
		SetAttacker(keepp.MyPawn);
		SetNextState('LookForCop');
	}
}
///////////////////////////////////////////////////////////////////////////////
// end: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// As long as you have patrol tags, you'll and make footstep noises
///////////////////////////////////////////////////////////////////////////////
function SetToPatrolJail()
{
	//log(MyPawn$" SetToPatrolJail ");
	bPatrolJail=true;
	SetToPatrolPath();
}

///////////////////////////////////////////////////////////////////////////////
// When triggered, they will attack the player, wherever he is
///////////////////////////////////////////////////////////////////////////////
function CopTrigger( actor Other, pawn EventInstigator )
{
	local P2Player keepp;
	
	//log("i'm a cop and i got triggered");

	// If you're ready, go for it.
	if(!MyPawn.bIgnoresHearing
		&& !MyPawn.bIgnoresSenses)
	{
		if(Attacker == None)
		{
			// When we get triggered, we attack the player.
			keepp = GetRandomPlayer();

			// Check for person to attack
			if(keepp != None)
			{
				//log("attack player"@keepp@"dressed as cop"@DudeDressedAsCop(KeepP.MyPawn));
				// If they're dressed as a cop, just run there and look around
				if(DudeDressedAsCop(keepp.MyPawn))
				{
					//log("investigate!");
					DangerPos = keepp.MyPawn.Location;
					SetEndPoint(DangerPos, CHECK_DANGER_DIST);
					if(IsInState('LegMotionToTarget'))
						bPreserveMotionValues=true;
					SetNextState('LookAroundForTrouble');
					GotoStateSave('RunToTarget');
				}
				else // Otherwise, attack the player
				{
					if(!MyPawn.bNoTriggerAttackPlayer)
					{
						//log("attack!!!");
						SetAttacker(keepp.MyPawn);
						GotoStateSave('AssessAttacker');
					}
				}
			}
		}
	}
	else	// if not ready, get ready, but don't attack yet.
	{
		MyPawn.bIgnoresHearing=false;
		MyPawn.bIgnoresSenses=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// When triggered, they will attack the player, wherever he is
// Special handling for police officers who get changed to bystanders in
// They Hate Me or greater
///////////////////////////////////////////////////////////////////////////////
function PoliceTrigger( actor Other, pawn EventInstigator )
{
	// Patrolling cops are never allowed normal triggers..they can only
	// be triggered when in their patrolling state
	//log("patroljail"@bPatrolJail);
	if(!bPatrolJail)
		CopTrigger(Other, EventInstigator);
	else
	{
		if(ScriptedTrigger(Other) != None)
		{
			if(Attacker == None)
			{
				bPreserveMotionValues=true;

				// Check various options.. maybe they are in the walk/run patrol state, 
				// then act accordingly. If they are not, then each needs to check the old
				// state first. If neither switch on that, test with the next state.
				// If these are bundled together in an OR conditional, it will mess up when
				// the old state is walking, because it just ran and will pick run again
				// even though it really wants to go back to walking.
				if(GetStateName() == WALK_PATROL_STATE)
				{
					// When triggered, start running in panick--someone set off the fire alarm
					GotoStateSave(RUN_PATROL_STATE);
					return;
				}
				else if(GetStateName() == RUN_PATROL_STATE)
				{
					// When triggered, stop running in panick--the fire alarm is off
					GotoStateSave(WALK_PATROL_STATE);
					return;
				}
				else if(MyOldState == WALK_PATROL_STATE)
				{
					// When triggered, start running in panick--someone set off the fire alarm
					GotoStateSave(RUN_PATROL_STATE);
					return;
				}
				else if(MyOldState == RUN_PATROL_STATE)
				{
					// When triggered, stop running in panick--the fire alarm is off
					GotoStateSave(WALK_PATROL_STATE);
					return;
				}
				else if(MyNextState == WALK_PATROL_STATE)
				{
					// When triggered, start running in panick--someone set off the fire alarm
					GotoStateSave(RUN_PATROL_STATE);
					return;
				}
				else if(MyNextState == RUN_PATROL_STATE)
				{
					// When triggered, stop running in panick--the fire alarm is off
					GotoStateSave(WALK_PATROL_STATE);
					return;
				}
			}
		}
		else
		{
			//log("falling back to coptrigger");
			CopTrigger(Other, EventInstigator);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Find a player and kick his butt
// Special handling for cops during They Hate Me or greater.
///////////////////////////////////////////////////////////////////////////////
function SetToAttackPlayer(FPSPawn PlayerP)
{
	local FPSPawn keepp;

	// Change by NickP: NicksCoop fix
	if( bCoopAlertMode && MyPawn != None  )
		MyPawn.bPlayerIsEnemy = true;
	// End
	
	// If we're not a cop, do super instead
	if (!Pawn.IsA('AuthorityFigure'))
	{
		Super.SetToAttackPlayer(PlayerP);
		return;
	}

	if(PlayerP == None)
		keepp = GetRandomPlayer().MyPawn;
	else
		keepp = PlayerP;

	// check for some one to attack
	if(keepp != None)
	{
		// If they're dressed as a cop, just run there and look around
		if(DudeDressedAsCop(keepp))
		{
			DangerPos = keepp.Location;
			SetEndPoint(DangerPos, CHECK_DANGER_DIST);
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('LookAroundForTrouble');
			GotoStateSave('RunToTarget');
		}
		else // go kick their butt
		{
			SetAttacker(keepp);
			MyPawn.DropBoltons(Velocity);
			SetNextState('AssessAttacker');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make him get mad and attack, because we're walking back where we
// aren't supposed to be and we haven't paid
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	// Special handling for cops in the police station during They Hate Me or greater.
	if (MyPawn.IsA('AuthorityFigure'))
	{
		//log(self@"triggered by"@other@eventinstigator@"and i'm a cop");
		PoliceTrigger(Other, EventInstigator);
		return;
	}

	MyPawn.bIgnoresSenses=false;
	MyPawn.bIgnoresHearing=false;

	if(!MyPawn.bPlayerIsFriend)
	{
		if(MyPawn.bHasViolentWeapon)
		{
			if(!MyPawn.bNoTriggerAttackPlayer)
			{
				SetToAttackPlayer(FPSPawn(Other));
				GotoNextState();
			}
		}
		else
		{
			SetAttacker(FPSPawn(EventInstigator));
			if (FPSPawn(EventInstigator) != None)
				InterestPawn = FPSPawn(EventInstigator);

			// run far, far away from this location
			DangerPos = Location;
			UseSafeRangeMin = 32000;
			GotoStateSave('FleeFromDanger');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to see if you want to observe this pawn's personal looks (does he have a
// gun, is he naked)
///////////////////////////////////////////////////////////////////////////////
function CheckObservePawnLooks(FPSPawn LookAtMe)
{
	//log(self@"checking to observe pawn looks from"@LookAtMe,'Debug');
	SetRotation(MyPawn.Rotation);

	if(/*LookAtMe.IsA('Bystander')
		&& */ CanSeePawn(MyPawn, LookAtMe))
		ActOnPawnLooks(LookAtMe);
}

///////////////////////////////////////////////////////////////////////////
// This is a seperate function so various states (like ProtestToTarget)
// can call this within the same class, and not call down to a super
// like in PersonController. 
///////////////////////////////////////////////////////////////////////////
function BystanderDamageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;

	// Drop things if you had them in your hands
	MyPawn.DropBoltons(MyPawn.Velocity);

	if(Damage > 0
		&& Other != Pawn)
	{
		if (Other != None)
		{
			// If a live pawn that hurt me
			// and not in my Gang AI, 
			// then attack him
			if(!SameGang(FPSPawn(Other)))
			{
				// The player is my friend, but he shot me.. complain that he hurt me
				// if I'm not attacking anyone else
				if(P2Pawn(Other) != None 
					&& P2Pawn(Other).bPlayer 
					&& MyPawn.bPlayerIsFriend)
				{
					Say(MyPawn.myDialog.lGotHit);		// cry out

					if(Attacker == None)
						InterestIsAnnoyingUs(Other, false);
				}
				else
				{
					SetAttacker(FPSPawn(Other));
					SaveAttackerData();
					GetAngryFromDamage(Damage);
					MakeMoreAlert();
					Say(MyPawn.myDialog.lGotHit);		// cry out

					// Check to see if you've been hurt past your pain threshold, and then run away
					//log("my Painthreshold "$MyPawn.PainThreshold);
					//log("my health "$MyPawn.Health);
					if(MyPawn.Health < (1.0-MyPawn.PainThreshold)*MyPawn.HealthMax
						|| !MyPawn.bHasViolentWeapon)
					{
						if(MyPawn.Beg > FRand()
							&& !ClassIsChildOf(MyPawn.LastDamageType, class'ElectricalDamage'))
						{
							StartBegging(P2Pawn(Attacker));
							return;
						}
						else
						{
							DangerPos = Attacker.Location;
							dir = (MyPawn.Location - DangerPos);
							dir.z=0;
							// Dist between attacker and me
							CurrentDist = VSize(dir);
							// Decide current safe min
							GenSafeRangeMin();

							// We're scared of cops, etc. shooting, at us, but we understand
							// it was just them doing their job. Still.. run from them.
							if(P2Pawn(Other) != None
								&& P2Pawn(Other).bAuthorityFigure)
							{
								InterestPawn = Attacker;
								SetAttacker(None); // dont' get to mad with them
								GotoStateSave('FleeFromDanger');
								return;
							}

							InterestPawn = Attacker;
							// Most of the time you run scared, but sometimes, you look for a cop
							if(FRand() > FIND_A_COP_FREQ
								// Don't attempt this if the dude is the attacker and he's dressed as a cop.
								&& !DudeDressedAsCop(Attacker)
								)
								GotoStateSave('FleeFromAttacker');
							else
								GoFindACop();
							return;
						}
					}
					else if(MyNextState == 'Thinking'
							|| IsInState('WalkToTarget'))
					{
						SetNextState('');
						GotoStateSave('ReactToAttack');
					}
					else if(MyNextState != '')
					{
						GotoNextState();
					}
					else
						GotoStateSave('ReactToAttack');

					return;
				}
			}
		}
		else	// If i bumped a thing that hurts me, like a cactus
		{
			Say(MyPawn.myDialog.lGotHit);		// cry out
			MyPawn.SetMood(MOOD_Angry, 1.0);
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// When attacked, decide what to do
//
// Defined above.
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	BystanderDamageAttitudeTo(Other, Damage);
}

///////////////////////////////////////////////////////////////////////////////
// Depending on the situation, know the same thing your homie's knows..
// if he's attacking someone, back him up, if he's telling someone to freeze,
// then follow along
///////////////////////////////////////////////////////////////////////////////
function bool GainGangMemberKnowledge(PersonController NewPartner)
{
	if(NewPartner.Attacker != None)
	{
		Focus = NewPartner.Focus;
		InterestPawn = NewPartner.InterestPawn;
		SetAttacker(NewPartner.Attacker, true);
		LastAttackerPos = NewPartner.LastAttackerPos;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// If this dogs hero is your friend too, then be don't attack him
///////////////////////////////////////////////////////////////////////////////
function bool FriendsWithAnimal(AnimalPawn apawn)
{
	local AnimalController acont;

	if(apawn != None)
	{
		acont = AnimalController(apawn.Controller);
		if(acont != None
			&& acont.Hero != None
			&& acont.Hero.bPlayer
			&& MyPawn.bPlayerIsFriend)
			return true;
	}
	return false;
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
	local float dist;
	local vector dir;
	local bool bAcquireInterest;
	
	//log(self@"react to this danger"@dangerhere@"CreatorPawn"@CreatorPawn@"Origin"@OriginActor);

	// If this guy doesn't care about things going on around him
	if(MyPawn.bIgnoresSenses
		|| MyPawn.bIgnoresHearing)
		return;

	// Handle zombies
	if(CreatorPawn != None
		&& CreatorPawn.IsA('AWZombie'))
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
	
	// Handle zombies, part deux
	if (OriginActor != None
		&& OriginActor.IsA('AWZombie'))
	{
		if(MyPawn.bHasViolentWeapon)
		{
			// Drop things if you had them in your hands
			MyPawn.DropBoltons(MyPawn.Velocity);
			SetAttacker(FPSPawn(OriginActor));
			MakeMoreAlert();
			SaveAttackerData(FPSPawn(OriginActor));
			PrintDialogue("Animals must die!");
			Say(MyPawn.myDialog.lStartAttackingAnimal);
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
			StateChange=1;
			return;
		}
		else
		{
			GenSafeRangeMin();
			InterestPawn = FPSPawn(OriginActor);
			SetAttacker(InterestPawn);
			DangerPos = Attacker.Location;
			GotoStateSave('FleeFromAttacker');
			StateChange=1;
		}
	}

	// Ignore dog attacks, if you're friends and they're not attacking you
	if(CreatorPawn != None
		&& CreatorPawn.IsA('DogPawn')
		&& P2MoCapPawn(Pawn).bDogFriend
		&& AnimalController(CreatorPawn.Controller) != None
		&& AnimalController(CreatorPawn.Controller).Attacker != MyPawn)
	{
		// STUB
		return;
	}

	// if it's a crazy animal, run or fight it
	if((Attacker == None
			|| Attacker == CreatorPawn)
		&& AnimalPawn(CreatorPawn) != None)
	{
		// If the animal *didn't* attack, then just be alarmed
		// Or if you're friends with the owner, don't attack it.
		if(!dangerhere.default.bCreatorIsAttacker
			|| FriendsWithAnimal(AnimalPawn(CreatorPawn)))
		{
			if(InterestPawn != CreatorPawn
				&& GetStateName() != 'ConfusedByDanger')
			{
				InterestPawn = CreatorPawn;
				DangerPos = blipLoc;
				LastAttackerPos = DangerPos;
				SetNextState('WatchForViolence');
				if(IsInState('LegMotionToTarget'))
					bPreserveMotionValues=true;
				GotoStateSave('ConfusedByDanger');
				StateChange=1;
			}
			return;
		}
		else	// if did attack, so respond
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
				return;
			}
		}
		return;
	}

	// If the dude, and you're friends with him, then only 
	// be confused by it.
	if(CreatorPawn != None
		&& MyPawn.bPlayerIsFriend 
		&& CreatorPawn.bPlayer)
	{
		InterestPawn = CreatorPawn;
		DangerPos = blipLoc;
		LastAttackerPos = CreatorPawn.Location;
		SetNextState('WatchForViolence');
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		// If we can see him, just be confused
		if(FastTrace(MyPawn.Location, CreatorPawn.Location))
			GotoStateSave('ConfusedByDanger');
		else	// if we can't see him, run kind of close to him
		{
			SetEndPoint(LastAttackerPos, DEFAULT_END_RADIUS);
			GotoStateSave('RunToTarget');
		}
		StateChange=1;
		return;
	}
	
	// If they're shooting at nothing in particular but there's a zombie nearby, they
	// might have been shooting the zombie. Watch and be concerned.
	if (CreatorPawn != None
		&& (OriginActor == None || OriginActor == CreatorPawn || OriginActor.IsA('AWZombie'))
		&& ZombiePerimeterCheck(BlipLoc))
	{
		InterestPawn = CreatorPawn;
		DangerPos = blipLoc;
		LastAttackerPos = CreatorPawn.Location;
		SetNextState('WatchForViolence');
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		// If we can see him, just be confused
		if(FastTrace(MyPawn.Location, CreatorPawn.Location))
			GotoStateSave('ConfusedByDanger');
		else	// if we can't see him, run kind of close to him
		{
			SetEndPoint(LastAttackerPos, DEFAULT_END_RADIUS);
			GotoStateSave('RunToTarget');
		}
		StateChange=1;
		return;
	}

	// If the danger pawn is not in my gang, and I don't have a violent weapon
	// and am not tough (cajones) then be freaked out
	if((CreatorPawn != None
		&& !SameGang(CreatorPawn))
		&& !(MyPawn.Cajones > FRand()
			&& MyPawn.bHasViolentWeapon))
	{
		// Check to see if we should flee or if we're an okay distance away
		// Find direction away from danger
		DangerPos = blipLoc;
		dir = (MyPawn.Location - DangerPos);
		dir.z=0;
		// Dist between attacker and me
		CurrentDist = VSize(dir);
		// Decide current safe min
		GenSafeRangeMin();

		// If we're already scared of this person, run immediately from the gunfire
		// but only if we have a clear line of site to the person doing it
			// taken out--OR if they are too close to us and we're in the same zone, then freak
			// out then too.
		if((Attacker == CreatorPawn
			|| (InterestPawn == CreatorPawn
				&& dangerhere.default.bCreatorIsAttacker))
			&& CreatorPawn != None
			&& (//CreatorPawn.Region.Zone.Tag == MyPawn.Region.Zone.Tag
				//|| 
				FastTrace(MyPawn.Location, CreatorPawn.Location))
			//CurrentDist < DANGER_TOO_CLOSE
			)
		{
			DangerPos = blipLoc;
			LastAttackerPos = DangerPos;
			GotoStateSave('FleeFromDanger');
			StateChange=1;
			return;
		}
		else if(!IsInState('ConfusedByDanger')
			&& Attacker == None)
		{
			// If this guy just broke something like a window
			// then just watch him, but don't get freaked unless
			// he has a weapon
			if(dangerhere == class'PropBreakMarker')
			{
				InterestPawn = CreatorPawn;
				DangerPos = blipLoc;
				LastAttackerPos = DangerPos;
				SetNextState('WatchForViolence');
				if(IsInState('LegMotionToTarget'))
					bPreserveMotionValues=true;
				GotoStateSave('ConfusedByDanger');
				StateChange=1;
				return;
			}
			// Watch the crazy kicking person
			else if(ClassIsChildOf(dangerhere, class'MeleeHitNothingMarker'))
			{
				if(InterestPawn == None)
				{
					InterestPawn = CreatorPawn;
					DangerPos = blipLoc;
					LastAttackerPos = DangerPos;
					SetNextState('WatchForViolence');
					if(IsInState('LegMotionToTarget'))
						bPreserveMotionValues=true;
					GotoStateSave('ConfusedByDanger');
					StateChange=1;
				}
				return;
			}
			// If it's an explosion
			else if(dangerhere == class'ExplosionMarker')
			{
				if(CurrentDist < UseSafeRangeMin)
				{
					InterestPawn = CreatorPawn;
					DangerPos = blipLoc;
					LastAttackerPos = DangerPos;
					GotoStateSave('FleeFromDanger');
					StateChange=1;
					return;
				}
				else
					SetNextState('WatchForViolence');
			}
			// Cop or someone yelling
			else if(!ClassIsChildOf(dangerhere, class'AuthorityOrderMarker'))
			{
				if(InterestPawn == CreatorPawn
					&& (!P2Pawn(CreatorPawn).bAuthorityFigure
						|| (PersonController(CreatorPawn.Controller) != None
							&& PersonController(CreatorPawn.Controller).Attacker == MyPawn)))
					SetAttacker(InterestPawn);
				else
					InterestPawn = CreatorPawn;

				if(InterestPawn != None)
					SetNextState('WatchThreateningPawn');
				else
					SetNextState('WatchForViolence');
			}
			else
				SetNextState('WatchForViolence');


			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			GotoStateSave('ConfusedByDanger');
			StateChange=1;
			return;
		}
	}
	// Check if the danger has someone to attack about, if you're not already
	// attacking then attack him
	else if(dangerhere.default.bCreatorIsAttacker
		 && (Attacker == None 
			|| CreatorPawn == Attacker))
//		 && FastTrace(MyPawn.Location, CreatorPawn.Location))
	{
		// Gang AI
		// if the pawn making the bad noise has the same tag as me
		// then gain his attacker
		if(SameGang(CreatorPawn))
		{
			if(GainGangMemberKnowledge(PersonController(CreatorPawn.Controller)))
			{
				GotoStateSave('AssessAttacker');
				StateChange=1;
				return;
			}
		}
		else if(FriendIsEnemyTarget(P2Pawn(CreatorPawn)))
		// If the attacked is a friend (once removed from being in the same gang... the
		// player falls under this, then hear them no matter what and go help
		{
			DangerPos = blipLoc;
			MakeMoreAlert();
			SetAttacker(CreatorPawn);
			LastAttackerPos = DangerPos;
			GotoStateSave('AssessAttacker');
			StateChange=1;
			return;
		}
		else if(CreatorPawn.Region.Zone.Tag == MyPawn.Region.Zone.Tag
				|| FastTrace(MyPawn.Location, CreatorPawn.Location))
		// If it ends up being the dude or anyone you don't care about
		// fighting around then see if you can see the area first before reacting (this acts
		// like bad hearing, because if you're right around the corner you won't do this)
		// Also, do this if your in the same zone as the bad guy and you're close enough
		{
			DangerPos = blipLoc;
			MakeMoreAlert();
			// Just attack them ouright
			if(CreatorPawn.bPlayer
				|| MyPawn.bGunCrazy)
			{
				SetAttacker(CreatorPawn);
				LastAttackerPos = DangerPos;
				GotoStateSave('RecognizeAttacker');
			}
			// If it's anyone other than the dude, or someone attacking a
			// friend, then just watch the firefight
			else
			{
				GenSafeRangeMin();
				InterestPawn = CreatorPawn;
				GotoStateSave('WatchThreateningPawn');
			}
			StateChange=1;
			return;
		}
	}

	// If it's not danger, at least turn around and see what's happening
	// or if you're crazy.. start attacking
	if(CreatorPawn != None)
	{
		if(MyPawn.bGunCrazy
			&& !SameGang(CreatorPawn)
			&& MyPawn.bHasViolentWeapon)
		{
			SetAttacker(CreatorPawn);
			GotoStateSave('RecognizeAttacker');
			StateChange=1;
			return;
		}
		else if(Attacker == None
			&& InterestPawn == None)
		{
			// If you couldn't see the danger, and you're normal, turn around
			// and look at the wall, if you're a turret, keep facing the way you
			// were before
			if(MyPawn.PawnInitialState != MyPawn.EPawnInitialState.EP_Turret)
			{
				if(!IsInState('ConfusedByDanger'))
				{
					if(InterestPawn == CreatorPawn)
						SetAttacker(InterestPawn);
					else
						InterestPawn = CreatorPawn;

					if(InterestPawn != None)
						SetNextState('WatchThreateningPawn');
					else
						SetNextState('WatchForViolence');

					GenSafeRangeMin();
					if(IsInState('LegMotionToTarget'))
						bPreserveMotionValues=true;
					GotoStateSave('ConfusedByDanger');
					StateChange=1;
					return;
				}
			}
		}
	}

	return;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if the pawn is a cop, false if not
///////////////////////////////////////////////////////////////////////////////
function bool IsACop(P2Pawn P)
{
	return (P.bAuthorityFigure || DudeDressedAsCop(P));
}

// Just real quick check for nearby zombies/skeletons
function bool ZombiePerimeterCheck(vector BlipLoc)
{
	local P2Pawn P;
	
	const ZOMBIE_PERIMETER = 2000.0;
	
	foreach VisibleCollidingActors(class'P2Pawn', P, ZOMBIE_PERIMETER, BlipLoc)
		if (P.IsA('AWZombie'))
			return true;
			
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// We've seen the pawn, now decide if we care
// Returns true if there state changes at some point
///////////////////////////////////////////////////////////////////////////////
function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
{
	local P2Weapon p2weap;
	local vector dir;
	local bool bcheck;
	local bool bIsGimp;
	local float dist;
	
	//log(self@"acting on"@LookAtMe@"pawn looks",'Debug');

	// If this guy doesn't care about things going on around him
	if(MyPawn.bIgnoresSenses)
		return;

	// CopKilla cheat
	if (P2GameInfoSingle(Level.Game).TheGameState.bCopKilla && IsACop(P2Pawn(LookAtMe)))
	{
		// decide to fight if you have a weapon, or run if you don't
		if(MyPawn.bHasViolentWeapon)
		{
			// if I'm not attacking anyone already--esp. not the dude
			// then decide to recognize him
			if(Attacker == None)
			{
				InterestPawn = LookAtMe;
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				GotoStateSave('SightedHatedGuy');
				StateChange=1;
			}
			else if(!IsInState('SightedHatedGuy'))
				// we already know we hate him (if we're not trying to decide already)
			{
				// Drop things if you had them in your hands
				MyPawn.DropBoltons(MyPawn.Velocity);
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				SaveAttackerData(LookAtMe);
				GotoStateSave('RecognizeAttacker');
				StateChange=1;
			}
			return;
		}
	}

	// Handle zombies
	if(LookAtMe.IsA('AWZombie'))
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

	// If he's on fire, just watch him, if we're not already fighting
	if(Attacker == None
		&& LookAtMe.MyBodyFire != None)
	{
		GenSafeRangeMin();
		DangerPos = LookAtMe.Location;
		MakeMoreAlert();
		InterestPawn = LookAtMe;
		GotoStateSave('WatchGuyOnFire');
		StateChange = 1;
		return;
	}

	// if it's a crazy animal, run or fight it
	if(AnimalPawn(LookAtMe) != None)
	{
		// Animals very rarely send out look requests--usually only when they're deadly
		if(AnimalPawn(LookAtMe).bDangerous)
		{
			if(MyPawn.bHasViolentWeapon)
			{
				// Drop things if you had them in your hands
				MyPawn.DropBoltons(MyPawn.Velocity);
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				SaveAttackerData(LookAtMe);
				GotoStateSave('RecognizeAttacker');
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
				return;
			}
		}
		return;
	}

	// If it's the dude, and I hate him, act now
	// unless he's not dressed like the dude, in which case, don't
	// recognize him
	if(MyPawn.bPlayerIsEnemy 
		&& LookAtMe.bPlayer
		&& DudeDressedAsDude(LookAtMe))
	{
		// decide to fight if you have a weapon, or run if you don't
		if(MyPawn.bHasViolentWeapon)
		{
			// if I'm not attacking anyone already--esp. not the dude
			// then decide to recognize him
			if(Attacker == None)
			{
				InterestPawn = LookAtMe;
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				GotoStateSave('SightedHatedGuy');
				StateChange=1;
			}
			else if(!IsInState('SightedHatedGuy'))
				// we already know we hate him (if we're not trying to decide already)
			{
				// Drop things if you had them in your hands
				MyPawn.DropBoltons(MyPawn.Velocity);
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				SaveAttackerData(LookAtMe);
				GotoStateSave('RecognizeAttacker');
				StateChange=1;
			}
			return;
		}
		else
		{
			DangerPos = LookAtMe.Location;
			GenSafeRangeMin();
			InterestPawn = LookAtMe;
			GotoStateSave('ShyToSafeDistance');
			StateChange=1;
			return;
		}
	}

	// If the dude, and you're friends with him, don't care what he looks like
	if(LookAtMe.bPlayer
		&& PlayerAttackedMe == None
		&& MyPawn.bPlayerIsFriend)
		return;

	// Check first (before we see the weapon) if he is possibly in your house
	// and not supposed to be, and you care about it
	CheckForIntruder(LookAtMe, StateChange);
	if(StateChange == 1)
		return;

	// Check to see if we care what he's doing or what he looks like
	p2weap = P2Weapon(LookAtMe.Weapon);
	if(p2weap != None)
	{
		// Gang AI
		// If this other pawn had his weapon out, see if he has
		// an attacker, if so, and we don't already have one, 
		// fight with him if he's in your gang
		if(SameGang(LookAtMe)
			&& ConcernedAboutWeapon(p2weap))
		{
			if(Attacker == None)
			{
				if(GainGangMemberKnowledge(PersonController(LookAtMe.Controller))
					&& MyPawn.bHasViolentWeapon)
				{
					GotoStateSave('AssessAttacker');
					StateChange=1;
					return;
				}
			}
			// Return regardless because it's a fellow buddy and we don't
			// care about his weapons
			return;
		}

		// See if they are pointing they're weapon at you, and they're
		// not a police or military that you hate.
		if(WeaponTurnedToUs(LookAtMe, MyPawn)
			&& !P2Pawn(LookAtMe).bAuthorityFigure
			&& !ZombiePerimeterCheck(LookAtMe.Location))
		{
			dir = LookAtMe.Location - MyPawn.Location;
			dist = VSize(dir);

			// We're close enough to see what the weapon is, that he has
			if(dist < p2weap.RecognitionDist)
			{
				// We don't care if you're the gimp, cop, or dude, if you have your pants down, we're concerned
				if(MyPawn.bScaredOfPantsDown
					&& LookAtMe.HasPantsDown())
				{
					HandlePantsDown(LookAtMe, StateChange);
					if(StateChange == 1)
						return;
				}
				// If he's got a cowhead, stare at him
				else if(P2Weapon(LookAtMe.Weapon) != None
						&& P2Weapon(LookAtMe.Weapon).bWeaponIsGross
						&& FRand() < COWHEAD_COMMENT_FREQ)
				{
					InterestPawn = LookAtMe;
					GotoStateSave('WatchGuyWithCowhead');
					StateChange=1;
					return;
				}
				// Handle the dude being a cop
				else if(DudeDressedAsCop(LookAtMe))
				{
					if(ConcernedAboutCopWeapon(p2weap))
					{
						// Check to make sure you're not protesting, because we don't want protestors
						// to bother with the dude being a cop (unless he starts shooting)
						if(IsInState('ProtestToTarget'))
							return;	// don't let protestors/marchers react anymore
						else if(FRand() <= MyPawn.Curiosity)
						{
							InterestPawn = LookAtMe;
							GotoStateSave('WatchACop');
							StateChange = 1;
							return;
						}
					}
				}
				else if(ConcernedAboutWeapon(p2weap))
				{
					// Drop things if you had them in your hands
					MyPawn.DropBoltons(MyPawn.Velocity);

					// Check if you have the balls and a gun to attack
					// the bad guy, then pull out the gun and watch him
					// or if it's the dude, just attack him
					if(MyPawn.Cajones > FRand()
						&& MyPawn.bHasViolentWeapon)
					{
						// It's the dude--attack!
						// or, it's not and i'm just happy to shoot anyone
						if(FreakedAboutWeapon(p2weap)
							&& (LookAtMe.bPlayer
								|| MyPawn.bGunCrazy
								|| FriendIsEnemyTarget(P2Pawn(LookAtMe))))
						{
							SetAttacker(LookAtMe);
							MakeMoreAlert();
							SaveAttackerData(LookAtMe);
							GotoStateSave('RecognizeAttacker');
							StateChange=1;
							return;
						}
						else // Somebody other than the dude, or it's not a 
							// bad weapon, .. so just watch
						{
							GenSafeRangeMin();
							DangerPos = LookAtMe.Location;
							MakeMoreAlert();
							InterestPawn = LookAtMe;
							GotoStateSave('WatchThreateningPawn');
							StateChange = 1;
							return;
						}
					}
					else // Watch or run, you can't defend yourself
					{
						// Check to see if we should flee or if we're an okay distance away
						// Dist between attacker and me
						CurrentDist = dist;
						// pick how far away to stand around a guy
						UseSafeRangeMin = (p2weap.ViolenceRank*0.3)*(MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin);
						//log("use safe range for observe "$UseSafeRangeMin);

						// I'm scared of whatever this guy has out
						InterestPawn = LookAtMe;
						MakeMoreAlert();
						if(PickScreamingStill())
							GotoStateSave('ScreamingStill');
						else
							GotoStateSave('ShyToSafeDistance');
						StateChange=1;
						return;
					}
				}
			}
		}
	}

	bIsGimp = PersonDressedAsGimp(LookAtMe);

	if(MyPawn.Talkative > FRand()
		|| bIsGimp)
	// Consider talking to them
	{
		// If they don't have their pants down and have no weapon,
		// then check to talk to them
		if(p2weap == None
			|| (!ConcernedAboutWeapon(p2weap)
			&& !LookAtMe.HasPantsDown()))
		{
			TryToGreetPasserby(LookAtMe, bIsGimp, DudeDressedAsCop(LookAtMe), StateChange);
			if(StateChange == 1)
				return;
		}
	}

	// Since we're not doing anything else, if it's the player, then check to see what he's doing
	if(LookAtMe.bPlayer)
		HandlePlayerSightReaction(LookAtMe);

	if(Attacker == LookAtMe)
	{
		// We know we can still see him here, so record his 
		SaveAttackerData();
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////
// Set the timer going for a scream
///////////////////////////////////////////////////////////////////////////////
function TimeToScream(optional int ScreamType, optional float UseThatScreamFreq)
{
//	local float UseRand;

	//log(self$" scream type "$ScreamState);
	if(ScreamState == SCREAM_STATE_ACTIVE)
	{
//		if(ScreamType != NORMAL_SCREAM)
//			UseRand = FRand();
//		if(ScreamType == FIRE_SCREAM && UseRand < UseThatScreamFreq)
		// Marphy - Restoring fire screams but still allowing for the original
		// screams with random chance.
		if(ScreamType == FIRE_SCREAM && MyPawn.MyBodyFire != None)
			{
			if(Frand() < 0.5)
				SayTime = Say(MyPawn.myDialog.lScreamingOnFire);
			else
				SayTime = Say(MyPawn.myDialog.lScreaming);
			}
		else

		// If a cop or dude-cop is chasing you and you have no weapon sometimes
		// scream things about a rogue cop attacking you.
		if(Attacker != None
			&& (PoliceController(Attacker.Controller) != None
				|| DudeDressedAsCop(Attacker))
			&& FRand() < ROGUE_COP_SCREAM)
		{
			PrintDialogue("Aaaaah! Rogue cop!!");
			SayTime = Say(MyPawn.myDialog.lRogueCop);
		}
		else
		{
			PrintDialogue("Aaaaah! or maybe no screaming sometimes");
			SayTime = Say(MyPawn.myDialog.lScreaming);
		}

		ScreamState = SCREAM_STATE_DONE;
		SetTimer(SayTime, false);
	}
}

///////////////////////////////////////////////////////////////////////////
// Returns true if the pawn sent in uses a PersonController, and his
// attacker is a friend ours (or ourself, because we're our own best friend)
///////////////////////////////////////////////////////////////////////////
function bool FriendIsEnemyTarget(P2Pawn Aggressor)
{
	local PersonController per;
	local Controller cont;

	if(Aggressor != None)
	{
		if(Aggressor.Controller != None
			&& PersonController(Aggressor.Controller) != None)
		{
			per = PersonController(Aggressor.Controller);
			if(per.Attacker != None
				&& per.Attacker.Controller != None)
				cont = per.Attacker.Controller;

			if(cont != None)
			{
				if(per.Attacker == MyPawn			// if he's attacking us
					|| (cont.bIsPlayer 				// if he's attacking the dude and we're friends with him
						&& MyPawn.bPlayerIsFriend)
					|| SameGang(per.Attacker))		// if he's attacking a gang member
					return true;
			}
		}
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////
// Stare or laugh at him
///////////////////////////////////////////////////////////////////////////
function HandlePantsDown(FPSPawn LookAtMe, optional out byte StateChange)
{
	// for the moment, only a few care
	if(LookAtMe != Attacker
		&& FRand() <= MyPawn.Curiosity)
	{
		GenSafeRangeMin();
		InterestPawn = LookAtMe;
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		GotoStateSave('CommentOnPantsDown');
		StateChange=1;
	}
}

///////////////////////////////////////////////////////////////////////////
// Record where you were, and find a cop and tell him the bad news
///////////////////////////////////////////////////////////////////////////
function GoFindACop()
{
	if(InterestPawn2 == None
		|| PoliceController(InterestPawn2.Controller) == None)
	{
		if(Attacker != None)
			InterestPawn = Attacker;

		GotoStateSave('LookForCop');
	}
}

///////////////////////////////////////////////////////////////////////////////
// A cop is trying to arrest me. If I'm not already fighting someone else
// then attack him if I can
///////////////////////////////////////////////////////////////////////////////
function CopTriesToArrestMe(P2Pawn Copper)
{
	// If don't have a valid attacker, then make it the cop, after I get 'unconfused'
	if(Attacker == None
		|| Attacker.Health <= 0)
	{
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		SetAttacker(Copper);
		InterestPawn = Attacker;
		DangerPos = InterestPawn.Location;
		if(MyPawn.bHasViolentWeapon)
			SetNextState('AssessAttacker');
		else
			SetNextState('FleeFromAttacker');
		GotoStateSave('ConfusedByDanger');
	}
}

///////////////////////////////////////////////////////////////////////////////
// True if this pawn is the anyone (dude or otherwise) dressed up as the gimp
///////////////////////////////////////////////////////////////////////////////
function bool PersonDressedAsGimp(FPSPawn CheckP)
{
	if(GimpController(CheckP.Controller) != None
		|| (P2Player(CheckP.Controller) != None
			&& P2Player(CheckP.Controller).DudeIsGimp()))
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Go to state to see if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function RespondToTalker(Pawn Talker, Pawn AttackingShouter, ETalk TalkType, out byte StateChange)
{
	//if (TalkType == TALK_GetDown)
		//log(self@"told to get down by"@Talker@"bignoressenses"@MyPawn.bIgnoresSenses@"bignoreshering"@MyPawn.bIgnoresHearing@"body fire"@MyPawn.MyBodyFire@"StateChange"@StateChange,'Debug');
	
	// If we're not supposed to hear things, then don't respond at all.
	if(MyPawn.bIgnoresSenses
			|| MyPawn.bIgnoresHearing)
		return;

	if(MyPawn.MyBodyFire != None)
		return;

	// Check first if the guy talking to us is in our home!
	//log("checking for intruder statechange"@StateChange,'Debug');
	CheckForIntruder(FPSPawn(Talker), StateChange);
	//log("done checking for intruders statechange"@StateChange,'Debug');
	if(StateChange == 1)
		return;
		
	//log("Okay, now what to do",'Debug');

	// He's not in our home, so proceed
	switch(TalkType)
	{
		case TALK_getdown:
			// More often you've been told to get down and didn't, more likely you are to just skip
			// this state
			if(!(ToldGetDownCount > 2					// min times they can be told and still pay attention
				&& FRand() <= ToldGetDownCount/MAX_GET_DOWN_BLUFF))	// max times before they'll never listen again
			{
				ForceGetDown(Talker, AttackingShouter);
				StateChange=1;
			}			
		break;
		case TALK_askformoney:
			DonateSetup(Talker, StateChange);
		break;
		case TALK_FuckYou:
			InsultResponse(Talker);
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Dude said something mean to us, see if we care to respond.
///////////////////////////////////////////////////////////////////////////////
function InsultResponse(Pawn Shouter)
{
	if(MyPawn.Physics == PHYS_WALKING
		&& MyPawn.MyBodyFire == None)
	{
		if(CanSeePawn(Shouter, MyPawn))
		{
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;

			Focus = Shouter;
			// If the attacker has his pants down *don't* crouch in front of him.. move somehow
			if(Attacker != None
				&& Attacker.HasPantsDown())
			{
				StrategicSideStep();
			}
			else // Check first for guys yelling at you to get down
				 // See if they are enemies of your friends
				if(Attacker == None
					&& !SameGang(FPSPawn(Shouter))
					&& MyPawn.bHasViolentWeapon
					&& (!P2Pawn(Shouter).bAuthorityFigure
						|| (PersonController(Shouter.Controller) != None
							&& PersonController(Shouter.Controller).Attacker == MyPawn)))
			{
				SetAttacker(FPSPawn(Shouter));
				SetNextState('AssessAttacker');
				if(IsInState('LegMotionToTarget'))
					bPreserveMotionValues=true;
				GotoStateSave('ConfusedByDanger');
			}
			else 
			{
				if(IsInState('LegMotionToTarget'))
					bPreserveMotionValues=true;
				GotoStateSave('RespondToFuckYou');
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Go to state to see if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function ForceGetDown(Pawn Shouter, Pawn AttackingShouter)
{
	if(MyPawn.Physics == PHYS_WALKING
		&& MyPawn.MyBodyFire == None)
	{
		if(CanSeePawn(Shouter, MyPawn))
		{
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;

			Focus = Shouter;
			// If the attacker has his pants down *don't* crouch in front of him.. move somehow
			if(Attacker != None
				&& Attacker.HasPantsDown())
			{
				StrategicSideStep();
			}
			else // Check first for guys yelling at you to get down
				 // See if they are enemies of your friends
				if(Attacker == None
					&& AttackingShouter != None
					&& FPSPawn(AttackingShouter).bPlayer
					&& !SameGang(FPSPawn(Shouter))
					&& MyPawn.bHasViolentWeapon
					&& (!P2Pawn(Shouter).bAuthorityFigure
						|| (PersonController(Shouter.Controller) != None
							&& PersonController(Shouter.Controller).Attacker == MyPawn)))
			{
				SetAttacker(FPSPawn(Shouter));
				SetNextState('AssessAttacker');
				if(IsInState('LegMotionToTarget'))
					bPreserveMotionValues=true;
				GotoStateSave('ConfusedByDanger');
			}
			else 
			{
				if(IsInState('LegMotionToTarget'))
					bPreserveMotionValues=true;
				GotoStateSave('DecideToGetDown');
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// You just got beat up Rodney King style
///////////////////////////////////////////////////////////////////////////////
function HitByBaton(P2Pawn Doer)
{
	const STUN_CHANCE = 0.75;
	
	// How to react
	/*
	if (FRand() <= MyPawn.Beg * 3)
	// Beg for life immediately (triple beg chance for baton beatings)
		StartBegging(Doer);
	else */if (!MyPawn.bMissingLimbs && FRand() <= STUN_CHANCE)	
		GotoStateSave('RestAfterBatonHit');
}

///////////////////////////////////////////////////////////////////////////////
// You just got kicked in the balls
///////////////////////////////////////////////////////////////////////////////
function TookNutShot(P2Pawn Doer)
{
	// If you're a male and have a pain tolerance of anything below 1.0 this hurts you big time
	if (!MyPawn.bMissingLimbs && MyPawn.MyGender == Gender_Male
		&& MyPawn.PainThreshold < 1.0)
		GotoStateSave('RestAfterNutShot');
}

///////////////////////////////////////////////////////////////////////////
// Beg for life
// Possibly start begging (don't beg for animals)
///////////////////////////////////////////////////////////////////////////
function StartBegging(P2Pawn OurAttacker)
{
	if(OurAttacker == None)
	{
		DangerPos = MyPawn.Location;
		GotoStateSave('FleeFromDanger');
	}
	else
	{
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		if(BeggedCount > 0)
		{
			MyOldState = GetStateName();
			GotoStateSave('PerformBegForLifeOnKnees','Rebeg');
		}
		else
			GotoStateSave('PerformBegForLifeOnKnees');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Look for this pawn
///////////////////////////////////////////////////////////////////////////////
function WeaponPickup DoGunPickupSearch(float ColRad)
{
	local WeaponPickup wpick;

	// check all the pawns around me.
	ForEach VisibleCollidingActors(class'WeaponPickup', wpick, ColRad, MyPawn.Location)
	{
		// make sure there's no geometry in the way
		if(FastTrace(wpick.Location, MyPawn.Location))
		{
			//if(wpick
			log("we need to make him look at the violence rank "$wpick);
			return wpick;
		}
	}
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// Try to go for a gun
///////////////////////////////////////////////////////////////////////////////
function bool TryGoForGun()
{
	local Actor NextT;

	// Search for a gun around you and then shamble to it and pick it up
	//log("i'm searching for a gun");
	NextT = DoGunPickupSearch(VISUALLY_FIND_RADIUS);
	// see a gun pickup, go for it
	if(NextT != None)
	{
		SetEndGoal(NextT, NextT.CollisionRadius);
		Focus = NextT;
		MyPawn.bCanPickupInventory=true;
		SetNextState('VictimPerformRebelAttack');
		GotoStateSave('CrabShuffleFromAttacker');
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Go back to our hands (unless we're rioting)
///////////////////////////////////////////////////////////////////////////////
function SwitchToHands()
{
	//log("switch to this"@MyPawn.HandsClass@MyPawn.HandsClass.default.InventoryGroup@MyPawn.HandsClass.default.GroupOffset);
	if(!MyPawn.bRiotMode)
		SwitchToThisWeapon(MyPawn.HandsClass.default.InventoryGroup,
							MyPawn.HandsClass.default.GroupOffset);
}

///////////////////////////////////////////////////////////////////////////
// This function shouldn't be ignored (though it's counterpart below certainly
// may be). This registers with the pawn that 
///////////////////////////////////////////////////////////////////////////
function HitWithFluid(Fluid.FluidTypeEnum ftype, vector HitLocation)
{
	// Hit the pawn, so make it drip
	MyPawn.MakeDrip(ftype, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
// Get ready for the Apocalypse. Usually, you get more weapons and get meaner
// and crazier.
///////////////////////////////////////////////////////////////////////////////
function ConvertToRiotMode()
{
	local int randpick;

	//  Give him a good weapon, even if he already has one
	// Every once in a while give him a big 'gun'
	//if(Rand(RIOT_BIG_GUN_PICK_RAND) == 0)
	if(Rand(RIOT_BIG_GUN_PICK_RAND) < 15)	
	{
		// Added by Man Chrzan: Add ED Weapons too (if these are enabled)
		if (P2GameInfoSingle(Level.Game).InClassicMode())
			randpick = Rand(RIOT_GUN_RAND); 
		else
			randpick = Rand(6);
		
			switch(randpick)
			{
				case 0:
					MyPawn.CreateInventoryByClass(class'GrenadeWeapon');
					break;
				case 1:
					MyPawn.CreateInventoryByClass(class'MolotovWeapon');
					break;
				case 2:
					MyPawn.CreateInventoryByClass(class'LauncherWeapon');
					break;
				case 3:
					MyPawn.CreateInventory("EDStuff.GrenadeLauncherWeapon");
					break;
				case 4:
					MyPawn.CreateInventory("AWPStuff.SawnOffWeapon");	// (it was fixed so its ok for NPCs to use)
					break;
				case 5:
					MyPawn.CreateInventory("EDStuff.DynamiteWeapon");
					break;
			}
		
	}
	else	// Otherwise he gets a smaller gun
	{
		// Added by Man Chrzan: Add ED Weapons too (if these are enabled)
		if (P2GameInfoSingle(Level.Game).InClassicMode())
			randpick = Rand(RIOT_GUN_RAND); 
		else
			randpick = Rand(5);
			
		switch(randpick)
		{
			case 0:
				MyPawn.CreateInventoryByClass(class'PistolWeapon');
				break;
			case 1:
				MyPawn.CreateInventoryByClass(class'ShotgunWeapon');
				break;
			case 2:
				MyPawn.CreateInventoryByClass(class'MachinegunWeapon');
				break;
			case 3:
				MyPawn.CreateInventory("EDStuff.GSelectWeapon");
				break;
			case 4:
				MyPawn.CreateInventory("EDStuff.MP5Weapon");
				break;
		}
		
	}

	// Make them meaner and stronger
	if(MyPawn.Cajones < 1.0)
		MyPawn.Cajones = 1.0;
	if(MyPawn.PainThreshold < 1.0)
		MyPawn.PainThreshold = 1.0;
	MyPawn.Cowardice = 1.0-MyPawn.PainThreshold;
	if (MyPawn.BlockMeleeFreq < RIOT_MELEE_BLOCK)
		MyPawn.BlockMeleeFreq = RIOT_MELEE_BLOCK;

	// Up their health and the damage they do
	MyPawn.HealthMax *= RIOT_HEALTH_INCREASE;
	MyPawn.Health = MyPawn.HealthMax;
	MyPawn.DamageMult *= RIOT_DAMAGE_INCREASE;

	// And much crazier...(if you're not the dude's friend)
	if(!MyPawn.bPlayerIsFriend)
	{
		if(FRand() < RIOT_HATE_PLAYER)
			MyPawn.bPlayerIsEnemy=true;

		MyPawn.bGunCrazy=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Look around for zombies and either kill them or run
///////////////////////////////////////////////////////////////////////////////
function LookForZombies(optional out byte StateChange)
{
	local Actor CheckP;
	local FPSPawn KeepP;
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
				&& FPSPawn(CheckP) != None
				// if still alive (and not dying)
				&& FPSPawn(CheckP).Health > 0)
			{
				if(KeepP == None)
					KeepP = FPSPawn(CheckP);
				checkdist = VSize(CheckP.Location - MyPawn.Location);
				if(checkdist < keepdist)
				{
					KeepP = FPSPawn(CheckP);
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
		Super.BeginState();

		// eventually decide to put away your weapon
		if(FRand() <= BackToHandsFreq
			&& !MyPawn.bRiotMode)		// Fixed 2017-05-29
			SwitchToHands();

		// clear vars
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;
		FullClearAttacker();
		InterestPawn=None;
		InterestActor=None;
		CurrentInterestPoint = None;
		UsePatience=MyPawn.Patience;
		UseReactivity = MyPawn.Reactivity;
		EndGoal = None;
		EndRadius = 0;
		DistanceRun = 0;
		bSaidGetDown=false;
		bPanicked=false;
		SafePointStatus=SAFE_POINT_INVALID;
		MyPawn.SetMood(MOOD_Normal, 1.0);
		QLineStatus=EQ_Nothing;
		SetNextState('');
		MyPawn.SetupCollisionInfo();
		MyPawn.StopAllDripping();
		SetNextState('');
		// Get ready to get mean
		if(MyPawn.bRiotMode)
		{
			SwitchToBestWeapon();
			MyPawn.SetMood(MOOD_Angry, 1.0);
		}

		if(MyPawn.bLookForZombies)
			LookForZombies();
	}

Begin:
	// Tell others if you have a weapon out
	ReportViolentWeaponNoStasis();

TryAgain:
	Sleep(FRand()*0.5 + 0.5);

	// Randomly, and not very often, check if you want to do an idle
	if(FRand() <= DO_IDLE_FREQ)
		GotoStateSave('PerformIdleWithTalk');

	// Check to do a patrol
	if(MyPawn.PatrolNodes.Length > 0)
	{
		Sleep(2.0);
		SetToPatrolPath();
		GotoNextState();
	}

	// walk to some random place I can see (not through walls)
	SetNextState('Thinking');
	if(!PickRandomDest())
		Goto('TryAgain');	// Didn't find a valid point, try again
	GotoStateSave('WalkToTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchGuyWithCowhead
// He has a cowhead.. it's really gross, but just say stuff if he
// gets too close
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchGuyWithCowhead
{
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		Focus = InterestPawn;
	}
Begin:
	// Stare at the result a minute
	Sleep(2.0 - MyPawn.Reactivity);

	MyPawn.SetMood(MOOD_Angry, 1.0);
	PrintDialogue("Gross!");
	SayTime = Say(MyPawn.myDialog.lSomethingIsGross, bImportantDialog);
	Sleep(SayTime);
	SayTime=0;

	GotoStateSave('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// GettingMugged
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GettingMugged extends TalkingWithSomeoneSlave
{
	ignores CheckObservePawnLooks, MarkerIsHere;

	///////////////////////////////////////////////////////////////////////////////
	// Pick some space left or right, and side step there
	///////////////////////////////////////////////////////////////////////////////
	function QuickSideStep()
	{
		local Actor HitActor;
		local vector HitLocation, HitNormal, startdir, usevect, checkpoint;

		startdir = vector(MyPawn.Rotation);
		// Add some randomness to our direction, so 
		// when we pick the side step, it won't be perfectly same every time
		//startdir.x+=(FRand()-0.5)/8;
		//startdir.y+=(FRand()-0.5)/8;
		startdir = Normal(startdir);
		//log("after start dir "$startdir);
		// pick left
		if(FRand() <= 0.5)
		{
			usevect.x = -startdir.y;
			usevect.y = startdir.x;
		}
		else // pick right
		{
			usevect.x = startdir.y;
			usevect.y = -startdir.x;
		}
		usevect.z = startdir.z;
		// Now that we have our side, pick our new dest point

		checkpoint = MyPawn.Location + STRATEGIC_STEP_BASE_DIST*usevect;

		HitActor = Trace(HitLocation, HitNormal, checkpoint, MyPawn.Location, true);

		// Find the distance from the wall or other obstacle
		if(HitActor != None)
		{
			MovePointFromWall(HitLocation, HitNormal, MyPawn);
			checkpoint = HitLocation;
		}
		// Too tight, so try the other side
		if(HitActor != None 
			&& VSize(HitLocation - MyPawn.Location) <= TIGHT_END_RADIUS)
		{
			usevect.x = -usevect.x;
			usevect.y = -usevect.y;
			checkpoint = MyPawn.Location + STRATEGIC_STEP_BASE_DIST*usevect;

			// Find the distance from the wall or other obstacle
			HitActor = Trace(HitLocation, HitNormal, checkpoint, MyPawn.Location, true);
			if(HitActor != None)
			{
				MovePointFromWall(HitLocation, HitNormal, MyPawn);
				checkpoint = HitLocation;
			}
			// If that was too tight too, then just wait there
			if(HitActor != None && VSize(HitLocation - MyPawn.Location) <= TIGHT_END_RADIUS)
			{
				// Failed to dodge
				GotoState('GettingMugged', 'WaitingAgain');
				return;
			}
		}

		// Sidestep a little, while you're scared
		bDontSetFocus=true;
		bStraightPath=true;
		SetEndPoint(checkpoint, TIGHT_END_RADIUS);
		MoveTarget=None;
		MovePoint = checkpoint;
		bMovePointValid = true;
		UseEndRadius = TIGHT_END_RADIUS;
	}

Begin:
	Sleep(Frand());
	MyPawn.SetMood(MOOD_Scared, 1.0);
	Sleep(1.0);
	if(!MyPawn.bHasViolentWeapon)
	{
		// Side step a little, to look extra scared
		QuickSideStep();
TrySideStepping:
		MoveToWithRadius(MovePoint,Focus,TIGHT_END_RADIUS,,Pawn.bIsWalking);
	}
	Goto('WaitingAgain');
DoKicking:
	bDontSetFocus=false;
	SetNextState('LookForCop');
	GotoStateSave('DoKicking');
WaitingAgain:
	Sleep(10);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PerformBegForLifeOnKnees
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PerformBegForLifeOnKnees
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, HearWhoAttackedMe, RespondToTalker, ForceGetDown, RatOutAttacker, MarkerIsHere, 
		HearAboutKiller, HearAboutDangerHere, HandleFireInWay, DodgeThinWall, RocketIsAfterMe,
		RespondToQuestionNegatively, CheckObservePawnLooks, RespondToCopBother,
		Trigger, DonateSetup, SetupSideStep, SetupBackStep, SetupMoveForRunner, 
		AllowOldState, MoveAwayFromDoor, CheckForNormalDoorUse,  GetOutOfMyWay,
		CanStartConversation, CanBeMugged, FreeToSeekPlayer, HandlePlayerSightReaction, DangerPawnBump;

	///////////////////////////////////////////////////////////////////////////
	// Generally only used by p2mocappawn to see which crouch anim to use.
	///////////////////////////////////////////////////////////////////////////
	function bool IsBegging()
	{
		return true;
	}

	///////////////////////////////////////////////////////////////////////////
	// Shot when begging, but not dead, so cry more
	// Or run or something
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		local float healthratio;

		MyPawn.StopAcc();
		//PrintDialogue("Waaaahhaa... boohoo");
		Say(MyPawn.myDialog.lCrying);

		healthratio = MyPawn.Health/MyPawn.HealthMax;
		// Try to crawl away if you're a touch from death
		// and you randomly decide to, but's likely because you're health 
		// is so low
		//log("healthratio "$healthratio);
		//log("low percent "$DEATH_CRAWL_PERCENT*MyPawn.HealthMax);
		//log("health  max "$MyPawn.HealthMax);


//			DoDeathCrawlAway();
//			return;

		if(MyPawn.Health <= DEATH_CRAWL_PERCENT*MyPawn.HealthMax
			&& healthratio < FRand())
		{
			DoDeathCrawlAway();
			return;
		}

		// Depending on health, when you're shot, you may just cry and take it
		// or you may get up and run
		if(healthratio/4 > FRand())
		{
			// More likely to run when you have a lot of health still
			InterestPawn = Attacker;
			MakeMoreAlert();
			DangerPos = InterestPawn.Location;
			GotoStateSave('FleeFromAttacker');
			return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to see if you're attacking is watching.. if not, we might run or
	// something
	///////////////////////////////////////////////////////////////////////////////
	function CheckForAttackerWatching()
	{
		local vector dir;

		// if we know already know we want to do something extra.
		if(UseAttribute > 0)
		{
			// If the attacker can't see you, maybe do something
			// Or if the attacker doesn't have a threatening weapon out,
			// Or if you not close enough to hurt them
			// then probably do something
			if(!CanSeePawn(Attacker, MyPawn)
				|| P2Weapon(Attacker.Weapon).ViolenceRank <= 0
				|| VSize(MyPawn.Location - Attacker.Location) > 2*Attacker.Weapon.TraceDist)
			{
				// if he has enough life to still run
				if(MyPawn.Health > DEATH_CRAWL_PERCENT*MyPawn.HealthMax)
				{
					// check to run and find a cop
					if(UseAttribute == BEG_WILL_RUN_FOR_COP
						&& FRand() <= MyPawn.Cajones)
					{
						PrintDialogue("eheheeheeee...I'm getting away!");
						Say(MyPawn.myDialog.lSnickering);
						DangerPos = Attacker.Location;
						GoFindACop();
						return;
					}

					if(UseAttribute == BEG_WILL_GO_FOR_GUN)
					{
						// Search for a gun around you and then shamble to it and pick it up
						if(TryGoForGun())
							return;
					}
				}
				else if(UseAttribute == BEG_WILL_DO_DEATH_CRAWL)
				{
					DoDeathCrawlAway();
					return;
				}


				// maybe stand up and yell something
				if(UseAttribute == BEG_WILL_TALK_BACK
					&& Frand() <= MyPawn.Rebel)
				{
					SetNextState('PerformBegForLifeOnKnees', 'Rebeg');
					GotoStateSave('VerballyAbuseAttackerAfterBeg');
					return;
				}

				// if you did nothing else and he's not looking or 
				// can't hurt you, get up and run away eventually
				if(statecount > FRand()*10)
				{
					DangerPos = Attacker.Location;
					GotoStateSave('FleeFromDanger');
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// beg for your life
	///////////////////////////////////////////////////////////////////////////////
	function SayNotToKillMe()
	{
		if(!MyPawn.IsAMinority())
			SayTime = Say(MyPawn.myDialog.lBegForLife);
		else
			SayTime = Say(MyPawn.myDialog.lBegForLifeMin);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(MyPawn.Health > 0)
			MyPawn.ShouldCrouch(false);
	}
	///////////////////////////////////////////////////////////////////////////////
	// stop running before you do this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		MyPawn.SetMood(MOOD_Scared, 1.0);
		Focus = Attacker;
		BeggedCount++;
		statecount=0;
		if(FRand() <= MyPawn.Cajones)
			UseAttribute = BEG_WILL_RUN_FOR_COP;
		else if(FRand() <= MyPawn.Rebel
			&& P2Pawn(Attacker) != None)	// Only make them talk back to people, not animals
			UseAttribute = BEG_WILL_TALK_BACK;
		else if(FRand() <= MyPawn.Rebel
			&& FRand() <= MyPawn.Cajones)
			UseAttribute = BEG_WILL_GO_FOR_GUN;
		else
			UseAttribute = BEG_WILL_DO_DEATH_CRAWL;

		//log("my use attribute "$UseAttribute);
	}

Rebeg:
	MyPawn.ShouldCrouch(true);
	// You've already begged for your life, got up, run and now the
	// dude has tracked you down again, so you're really in trouble.
//	PrintDialogue("I'm so sorry.. I'll never do that again!");
	SayTime = Say(MyPawn.myDialog.lFrightenedApology);
	Sleep(SayTime);
Begin:
	MyPawn.ShouldCrouch(true);
	MyPawn.StopAcc();
	// Randomly babble about not killing me
	if(FRand() <= BABBLE_WHILE_BEGGING)
	{
		MyPawn.PerformCrouchBeg();
		statecount++;
		SayNotToKillMe();
		Sleep(SayTime);
	}
	else
	{
		// Always cry
		//MyPawn.PerformCrouchBeg();
		SayTime = Say(MyPawn.myDialog.lCrying);
		Sleep(SayTime);
	}

	Sleep(FRand()*2);

	CheckForAttackerWatching();

	Goto('Begin');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PerformBegForLifeProne
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PerformBegForLifeProne extends PerformBegForLifeOnKnees
{
	ignores BodyJuiceSquirtedOnMe, GettingDousedInGas, 
		CheckToPuke, PrepToWaitOnDoor, CheckForIntruder,
		DecideToListen, DoDeathCrawlAway, PerformInterestAction,
		WingedByRifle, CanHelpOthers, DoWaitOnOtherGuy, TryToSendAway, IsBegging;

	///////////////////////////////////////////////////////////////////////////////
	// Catch on fire, but keep doing this
	///////////////////////////////////////////////////////////////////////////////
	function CatchOnFire(FPSPawn Doer, optional bool bIsNapalm)
	{
		CatchOnFireCantMove(Doer, bIsNapalm);
	}

	///////////////////////////////////////////////////////////////////////////
	// Shot when begging, but not dead, so cry more
	// Or run or something
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		//PrintDialogue("Waaaahhaa... boohoo");
		Say(MyPawn.myDialog.lCrying);
	}

	///////////////////////////////////////////////////////////////////////////////
	// beg for your life
	///////////////////////////////////////////////////////////////////////////////
	function SayNotToKillMe()
	{
		if(FRand() <= BABBLE_WHILE_BEGGING)
		{
			if(!MyPawn.IsAMinority())
				SayTime = Say(MyPawn.myDialog.lBegForLife);
			else
				SayTime = Say(MyPawn.myDialog.lBegForLifeMin);
		}
		else
			SayTime = Say(MyPawn.myDialog.lCrying);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Go back to crawling
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
			else
			{
				MyPawn.ChangeAnimation();
				GotoState(MyOldState);
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
	}
Rebeg:

Begin:
	MyPawn.ShouldDeathCrawl(true);
	// Randomly babble about not killing you
	if(FRand() <= BABBLE_WHILE_BEGGING)
	{
		MyPawn.PerformProneBeg();
		SayNotToKillMe();
		Sleep(SayTime);
	}
	else
	{
		Sleep(DEFAULT_BEG_TIME + FRand()*2);
		Goto('Begin');// run this state again
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Tell cop that someone shot gun around you
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TellCopAboutShooter
{
	ignores RespondToQuestionNegatively, TryToGreetPasserby,
		AllowOldState, DoWaitOnOtherGuy;

	///////////////////////////////////////////////////////////////////////////////
	// Finish pointing yelling at someone
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			MyPawn.ChangeAnimation();
			InterestPawn = InterestPawn2;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// For cops to be told only. Alert them of the fact that there was a gun
	// shot over in this direction.
	///////////////////////////////////////////////////////////////////////////////
	function TellAboutShooter()
	{
		if(InterestPawn2 != None)
		{
			PrintDialogue("Someone shot a gun over there! Go check! ");
			SayTime = Say(MyPawn.myDialog.lShootingOverThere);
			if(!DudeDressedAsCop(InterestPawn2))
				PoliceController(InterestPawn2.Controller).HearAboutDangerHere(DangerPos, MyPawn, SayTime);
			else
				log("I TOLD THE POSTAL DUDE SOMETHING WHEN HE WAS A COP!!");
		}
		else
			PrintStateError(" no interest pawn2!");
	}

	function BeginState()
	{
		PrintThisState();
	}

Begin:
	// gesture at where it happened
	Focus = None;
	FocalPoint = DangerPos;
	Sleep(0.5);
	// Point anim
	MyPawn.PlayPointThatWayAnim();
	TellAboutShooter();
	Sleep(SayTime + 1.5);	// Give cop a head start, then follow
	// Now have this person run back to the original point too, hopefully behind
	// the cop (but we're not linking them up, so the cop could get distracted and
	// this guy could make it back there before the cop--if the cop shows up at all)
	SetEndPoint(DangerPos, UseSafeRangeMin);
	SetNextState('WatchForViolence');
	GotoStateSave('RunBackToDanger');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Tell cop that someone shot gun around you
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TellCopAboutKiller extends TellCopAboutShooter
{
	///////////////////////////////////////////////////////////////////////////////
	// For cops to be told only. Alert them of the killer over that way
	///////////////////////////////////////////////////////////////////////////////
	function TellAboutShooter()
	{
		if(InterestPawn2 != None)
		{
			PrintDialogue("There's a guy shooting people over there! Go check!");
			SayTime = Say(MyPawn.myDialog.lKillingOverThere);
			if(!DudeDressedAsCop(InterestPawn2))
				PoliceController(InterestPawn2.Controller).HearAboutKiller(DangerPos, Attacker, MyPawn, SayTime);
			else
				log("I TOLD THE POSTAL DUDE SOMETHING AS HE WAS A COP!!");
		}
		else
			PrintStateError("No interest pawn2!");
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Look around for a cop, then run to him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LookForCop
{
	ignores GoFindACop, SetToFindCop, InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, 
		GettingDousedInGas, HandlePlayerSightReaction,
		CheckObservePawnLooks, RespondToQuestionNegatively, AllowOldState, DoWaitOnOtherGuy,
		RocketIsAfterMe;

	///////////////////////////////////////////////////////////////////////////////
	// Look for this pawn
	///////////////////////////////////////////////////////////////////////////////
	function P2Pawn DoCopSearch(float ColRad)
	{
		local P2Pawn CheckP;

		// check all the pawns around me.
		ForEach CollidingActors(class'P2Pawn', CheckP, ColRad, MyPawn.Location)
		{
			// If not the asker
			// and has a police controller
			// and is either a cop that's not the player's friend
			// or is the player dressed as a cop
			if(CheckP != MyPawn 
				&& CheckP.Health > 0
				&& ((PoliceController(CheckP.Controller) != None
						&& !CheckP.bPlayerIsFriend)
					|| (DudeDressedAsCop(CheckP)
						&& CheckP != Attacker)))
			{
				return CheckP;
			}
		}
		return None;
	}
	///////////////////////////////////////////////////////////////////////////////
	// See if you could see a cop
	///////////////////////////////////////////////////////////////////////////////
	function CheckToSeeCop()
	{
		local P2Pawn cop;

		cop = DoCopSearch(FIND_COP_RADIUS);
		if(cop != None)
		{
			SetEndGoal(cop, TALK_TO_SOMEONE_RADIUS);
			InterestPawn2 = cop;
			//log("going to talk to this cop "$EndGoal);
		}
		else
			EndGoal = None;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		Focus = Attacker;
	}

Begin:
	Sleep(0.1+Frand()/2);
	CheckToSeeCop();

	if(EndGoal != None)
	{
		Focus = EndGoal;
		Sleep(Frand() + 0.1);

		if(Attacker != None
			&& Attacker.Health > 0)
		{
			// Update attacker's position if he's within sight
			// and close enough to reasonable be able to know about him
			if(FastTrace(Attacker.Location, MyPawn.Location)
				&& VSize(Attacker.Location - MyPawn.Location) < FIND_COP_RADIUS)
				DangerPos = Attacker.Location;
			SetNextState('TellCopAboutKiller');
		}
		else
			SetNextState('TellCopAboutShooter');
		GotoStateSave('RunToFindCop');
	}
	else // make him look some more, by pushing him farther away from who started
		// the cop search in the first place
	{
		// crank up the current safe distance
		UseSafeRangeMin*=SAFE_RANGE_HARASS_INCREASE;
		//log("going further away");
		GotoStateSave('FleeAndFindCop');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// SightedHatedGuy
// Hey--it's that guy I hate! Be confused at first, then realize we
// hate him and attack.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SightedHatedGuy
{
	///////////////////////////////////////////////////////////////////////////////	
	// Go attacking
	///////////////////////////////////////////////////////////////////////////////
	function AttackHim()
	{
		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);

		GotoStateSave('AssessAttacker');
	}

	///////////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////////
	function bool RecognizeHim()
	{
		local float dist;

		// Steven: Recognize him immediately if he's wielding a dangerous weapon.
		if(ConcernedAboutWeapon(P2Weapon(Attacker.Weapon)))
		{
			MakeMoreAlert();
			SayTime=0;
			return true;
		}
		// Steven: End fix
		dist = VSize(Attacker.Location - MyPawn.Location);

		// Turrets say things, but don't wait to attack, and they
		// recognize instantly.
		if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
		{
			SayTime=0;
			// Don't record a time, so you'll attack quicker
			if(MyPawn.bPlayerHater)
			{
				PrintDialogue("I hate you!");
				Say(MyPawn.myDialog.lLynchMob);
			}
			else
			{
				PrintDialogue("Hey, it's the player enemy!");
				Say(MyPawn.myDialog.lSeesEnemy);	// Don't record a time, so you'll attack quicker
			}
			return true;
		}
		// Closer the are, the more likely he will recogize you (unless you're
		// in riot mode, then you just attack all the time)
		else if(FRand() > (2*dist)/(P2Pawn(Attacker).ReportLooksRadius)
			|| MyPawn.bRiotMode)
		{
			if(MyPawn.bPlayerHater)
			{
				PrintDialogue("I hate you!");
				SayTime = Say(MyPawn.myDialog.lLynchMob);
			}
			else
			{
				PrintDialogue("Hey, it's the player enemy!");
				SayTime = Say(MyPawn.myDialog.lSeesEnemy);
			}
			return true;
		}
		else // if not, go back to watching
		{
			return false;
		}
	}

	///////////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		Focus = InterestPawn;
		statecount = 0;
		MyPawn.SetMood(MOOD_Combat, 1.0);
		if(InterestPawn.bPlayer
			&& InterestPawn.Health > 0)
			bImportantDialog=true;
		else
			bImportantDialog=false;
	}
	///////////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		bImportantDialog=false;
		Super.EndState();
	}
Begin:
	Sleep(0.0);
	if(RecognizeHim())
	// You know you hate him, so shout then, start
	// attacking
	{
		Sleep(SayTime);
	}
	else // you're too far away to be sure.
	{
		statecount++;
		if(FRand() > float(statecount)/10)
		{
			// try to recognize him again after a sec
			Sleep(1.0);
			Goto('Begin');
		}
		else	// give up on him
		{
			if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
			{
				SetToTurret();
				GotoNextState(true);
			}
			else
				GotoStateSave('Thinking');
		}
	}

	AttackHim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// The Attacker is in our home--react to it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state IntruderInHome
{
Begin:
	FinishRotation();
	PrintDialogue("Get outta here!");
	SayTime = Say(MyPawn.myDialog.lInvadesHome);
	Sleep(SayTime);
	// If we're capable of defending our place, then start attacking
	if(MyPawn.Cajones > FRand()
		&& MyPawn.bHasViolentWeapon)
	{
		GotoStateSave('AssessAttacker');
	}
	else // if not, then get a cop to help, and run out
	{
		GoFindACop();
	}
	// If we didn't do either of those, then stand and watch
	GotoStateSave('WatchThreateningPawn');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RespondToFuckYou
// Assumes the focus is set to who we want to look at
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RespondToFuckYou
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere,
		RespondToTalker, ForceGetDown, QPointSaysMoveUpInLine,//GetReadyToReactToDanger, 
		RespondToQuestionNegatively, CheckObservePawnLooks,
		PerformInterestAction, AllowOldState, SetupSideStep, SetupBackStep, SetupMoveForRunner;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
	}
	///////////////////////////////////////////////////////////////////////////////
	// stop running before you do this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		bPreserveMotionValues=false;
		MyPawn.StopAcc();
	}

Begin:

WaitForTalker:
	// Wait for the pawn to finish talking first.
	if (P2Pawn(Focus) != None
		&& P2Pawn(Focus).IsTalking())
	{
		Sleep(0.1);
		Goto('WaitForTalker');
	}		

	if (UseReactivity + MyPawn.Rebel >= 1.0)
		Sleep(1.0 - (UseReactivity + MyPawn.Rebel));
		
	// Increment the number of times we've been told to fuck off
	ToldFuckYouCount++;
	
	// Also tell the game info
	P2GameInfoSingle(Level.Game).TheGameState.BirdsFlipped++;
	
	// If the dude has flipped us off several times, eventually get pissed off and attack.
	if (!MyPawn.bPlayerIsFriend && MyPawn.bHasViolentWeapon && ToldFuckYouCount > 6 - MyPawn.Patience * 3.0)
		Goto('TiredOfYourShit');
	
	// If we have a lot of balls (or a big gun) then we laugh at his attempt to provoke us
	if (MyPawn.bHasViolentWeapon || MyPawn.Cajones > FRand())
		Goto('LaughAtThem');
		
	// If we're confident enough, flip them off in return
	if (MyPawn.Confidence * 2 > FRand())
		Goto('ScrewYou');
		
	// Otherwise, stare at the weirdo
	Goto('WatchCrazy');

ScrewYou:
	// Flip them off
	MyPawn.PlayTellOffAnim();
	PrintDialogue("Go screw yourself!");
	SayTime = Say(MyPawn.myDialog.lDefiant);
	Sleep(SayTime);
	GotoState(MyOldState);
	
WatchCrazy:
	InterestPawn = P2Pawn(Focus);
	DangerPos = Focus.Location;
	LastAttackerPos = DangerPos;
	SetNextState('WatchForViolence');
	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;
	GotoStateSave('ConfusedByDanger');

TiredOfYourShit:
	// Yell at them if we're talkative
	if (MyPawn.Talkative * 2 > FRand())
	{
		SayTime = Say(MyPawn.MyDialog.lDoHeroics);
		Sleep(SayTime);
	}
	SetAttacker(P2Pawn(Focus));
	MyPawn.DropBoltons(MyPawn.Velocity);
	GotoState('AssessAttacker');
	
LaughAtThem:
	InterestPawn = P2Pawn(Focus);
	Focus = None;
	FocalPoint = InterestPawn.Location;
	GotoStateSave('LaughAtSomething');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DecideToGetDown
// Assumes the focus is set to who we want to look at
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DecideToGetDown
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere,
		RespondToTalker, ForceGetDown, QPointSaysMoveUpInLine,//GetReadyToReactToDanger, 
		RespondToQuestionNegatively, CheckObservePawnLooks,
		PerformInterestAction, AllowOldState, SetupSideStep, SetupBackStep, SetupMoveForRunner;
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
			GotoStateSave(MyOldState);
		}
	}
*/
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
	}
	///////////////////////////////////////////////////////////////////////////////
	// stop running before you do this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		bPreserveMotionValues=false;
		MyPawn.StopAcc();
	}

	// In AWP we respond to these quicker.
Begin:
	// Wait for how naturally slow they react, plus how rebellious they are
	// Also, look to see who shouted it InterestPawn and decide to believe 
	// them or not
//	Sleep((2.0 - UseReactivity) + MyPawn.Rebel);

WaitForTalker:
	// Wait for the pawn to finish talking first.
	if (P2Pawn(Focus) != None
		&& P2Pawn(Focus).IsTalking())
	{
		Sleep(0.1);
		Goto('WaitForTalker');
	}		

	if (UseReactivity + MyPawn.Rebel >= 1.0)
		Sleep(1.0 - (UseReactivity + MyPawn.Rebel));

	// If he has a weak weapon, then do nothing, or tell him off
	if(FPSPawn(Focus) != None
		&& !FreakedAboutWeapon(P2Weapon(FPSPawn(Focus).Weapon)))
	{
		//ToldGetDownCount++;	// record how many times it didn't matter--crying wolf
		
		// As per Jon, we're changing the behavior of "Get Down" when the yeller is unarmed
		// (always the dude, bystanders never use Get Down unless they mean it)
		// React in one of the following ways:
		// -get scared and run away or at least make a remark and walk away 'no way you frinking pinko'
		// -Be defiant and start a fight (wish we still had the bystander fists)
		// -Think your crazy and kinda laugh at you / pity you
		// In some rare cases maybe someone would ignore you but not like 90% of the pawns do now. 

		if(FRand() <= MyPawn.Rebel)
		{
			// Possibly have them flip out and attack instead
			if (FRand() <= MyPawn.Cajones
				&& !MyPawn.bPlayerIsFriend)
			{
				// now set the interest pawn back to the focus
				SetAttacker(P2Pawn(Focus));
				MyPawn.DropBoltons(MyPawn.Velocity);
				GotoState('AssessAttacker');
			}
			else // Tell them off
				Goto('ScrewYou');
		}
		// If they're pretty cowardly, maybe have them scream and run away instead
		else if (MyPawn.Cajones <= 0.20
			&& FRand() <= 1.0 - MyPawn.Cajones)
		{
			DangerPos = MyPawn.Location; // Just consider where we are a dangerous position
			LastAttackerPos = DangerPos;
			GotoStateSave('FleeFromDanger');
		}
		// Maybe laugh instead
		else if (FRand() <= MyPawn.Talkative)
		{
			InterestPawn = P2Pawn(Focus);
			Focus = None;
			FocalPoint = InterestPawn.Location;
			GotoStateSave('LaughAtSomething');
		}
		else // go back to what you were doing
			GotoState(MyOldState);
	}
	// if he has a weapon and we're still a rebel and we're strong, then tell him off
	else if(FRand() <= MyPawn.Rebel
		&& FRand() <= MyPawn.PainThreshold)
		Goto('ScrewYou');
	else // otherwise, crouch like told
	{
		// If they're pretty cowardly, maybe have them scream and run away instead
		if (MyPawn.Cajones <= 0.25
			&& FRand() <= 1.0 - MyPawn.Cajones)
		{
			DangerPos = MyPawn.Location; // Just consider where we are a dangerous position
			LastAttackerPos = DangerPos;
			GotoStateSave('FleeFromDanger');
		}
		else {
			DangerPos = MyPawn.Location; // Just consider where we are a dangerous position
			// now set the interest pawn back to the focus
			InterestPawn = FPSPawn(Focus);
			GotoState('PerformGetDown');
		}
	}

ScrewYou:
	// Flip them off
	MyPawn.PlayTellOffAnim();
	PrintDialogue("Go screw yourself!");
	SayTime = Say(MyPawn.myDialog.lDefiant);
	Sleep(SayTime);
	GotoState(MyOldState);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PerformGetDown
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PerformGetDown extends DecideToGetDown
{
	///////////////////////////////////////////////////////////////////////////////
	// stop running before you do this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();
	}

Begin:
	// Wait for how naturally slow they react, plus how rebellious they are
	// Also, look to see who shouted it InterestPawn and decide to believe 
	// them or not
	Sleep((1.0 - UseReactivity) + MyPawn.Rebel);
	MyPawn.ShouldCrouch(true);
	GotoState('StayDown');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// StayDown
// Stay crouching for a certain period of time
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StayDown extends DecideToGetDown
{
	///////////////////////////////////////////////////////////////////////////////
	// stop running before you do this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();

		statecount=0;
	}

Begin:
	Sleep((1.0 - UseReactivity) + (1.0 - MyPawn.Rebel) + 1.0);

	LookAroundWithHead(FRand(), 0.2, 0.4, 0.0, 0.8, 2.0);

	statecount++;
	if(statecount > STAY_DOWN_SC_MAX)
	{
		GenSafeRangeMin();
		if(!MyPawn.bHasViolentWeapon)
		{
			if(Attacker == None)
			{
				DangerPos = MyPawn.Location;
				GotoState('FleeFromDanger');
			}
			else
			{
				DangerPos = InterestPawn.Location;
				GotoState('FleeFromAttacker');
			}
		}
		else	// if we have a weapon, just watch again
		{
			if(InterestPawn != None)
				GotoState('WatchThreateningPawn');
			else
				GotoState('Thinking');
		}
	}
	Goto('Begin');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CommentOnPantsDown
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CommentOnPantsDown extends GreetPasserby
{
	///////////////////////////////////////////////////////////////////////////////
	// See if we can see our guy
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		SetRotation(MyPawn.Rotation);

		if(LookAtMe == InterestPawn)
		{
			if(!MyPawn.IsTalking())
				GotoState('CommentOnPantsDown', 'CheckHim');
		}
		else if(LookAtMe.IsA('Bystander')
			&& CanSeePawn(MyPawn, LookAtMe)
			&& !MyPawn.bIgnoresSenses)

			ActOnPawnLooks(LookAtMe);
	}

	function BeginState()
	{
		Super.BeginState();
		Focus = InterestPawn;
		statecount=0;
	}

Begin:
	MyPawn.PlayTurnHeadDownAnim(1.0, 0.5);
	Sleep(FRand());

CheckHim:
	CurrentFloat = VSize(InterestPawn.Location - MyPawn.Location);

	if(WeaponTurnedToUs(InterestPawn, MyPawn))
	{
		if(CurrentFloat < COMMENT_ON_NAKED
			&& statecount == 0)
		{
			// Kamek 4-23
			// Give an achievement if enough women comment on the dude's 'package'
			//log(self@"I've seen bigger!"@MyPawn.bIsFemale@InterestPawn@InterestPawn.Controller);
			if (MyPawn.bIsFemale && PlayerController(InterestPawn.Controller) != None && !bLaughedAtDudesPackage)
			{
				bLaughedAtDudesPackage = True;
				if( Level.NetMode != NM_DedicatedServer ) PlayerController(InterestPawn.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(InterestPawn.Controller),'IveSeenBigger',1,true);
			}

			SayTime=Say(MyPawn.myDialog.lNoticeDickOut);
			MyPawn.PlayTalkingGesture(1.0);
			PrintDialogue("I've seen bigger");
			statecount++;
			Sleep(SayTime+1.0);				
		}
		else if(CurrentFloat < SNICKER_AT_NAKED
			&& Frand() < MyPawn.Curiosity)
		{
			SayTime=Say(MyPawn.myDialog.lSnickering);
			MyPawn.PlayTalkingGesture(1.0);
			PrintDialogue("snickering");
			Sleep(SayTime+1.0);
		}
	}

	Sleep(FRand());

Ending:

	GotoState(MyOldState);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// QuakeBetweenAttackers
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state QuakeBetweenAttackers
{
	ignores TryToGreetPasserby;

	///////////////////////////////////////////////////////////////////////////////
	// stop running before you do this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();
		UseAttribute=MyPawn.Confidence;
		SetNextState('FleeFromDanger');
	}

Begin:
	// look at one attacker
	Focus = InterestPawn;
	Sleep(1.0 - UseReactivity);

	// look at the other attacker
	Focus = InterestPawn2;
	Sleep(1.0 - UseReactivity);

	// Slowly become more and more confident each time you do this
	// until you finally decide to run away
	UseAttribute*=2;
	//log("QuakeBetweenAttackers use react "$UseAttribute);
	if(FRand() <= UseAttribute)
	{
		// I've finally decided to run away
		SetAttacker(InterestPawn);
		MakeMoreAlert();
		DangerPos = InterestPawn.Location;
		GotoStateSave('FleeFromAttacker');
	}
	//log(" continue QuakeBetweenAttackers");
	// do it again
	Goto('Begin');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You want to get outside of your minimum safe range from
// your attacker.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FleeAndFindCop extends FleeFromDanger
{
	ignores MarkerIsHere, InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, 
		GettingDousedInGas, CheckObservePawnLooks, RocketIsAfterMe;

	///////////////////////////////////////////////////////////////////////////////
	// Go running around, away from the bad thing. 
	///////////////////////////////////////////////////////////////////////////////
	function HeadToNextTarget()
	{
		// Run to endpoint
		Focus = InterestPawn;
		GotoStateSave('RunToFindCop');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Based on various things around me, decide what to do next
	///////////////////////////////////////////////////////////////////////////////
	function PickNextStateNow()
	{
		SetNextState('LookForCop');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PointOutAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PointOutAttacker extends RatOutTarget
{
Begin:
	Focus = Attacker;	// look at who you point out

	MyPawn.ShouldCrouch(false);

	PrintDialogue("That guy over there did it! ");
	SayTime = Say(MyPawn.myDialog.lRatOut);

	// Point anim
	MyPawn.PlayPointThatWayAnim();

	// use Asker to help determine where to aim head.
	Sleep(SayTime);

	// Notify the guy that asked
	if(InterestPawn2 != None
		&& PersonController(InterestPawn2.Controller) != None)
		PersonController(InterestPawn2.Controller).HearWhoAttackedMe(Attacker, MyPawn);

	GotoStateSave('WatchForViolence');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToTargetFindAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToTargetFindAttacker
{
	ignores RespondToTalker, PerformInterestAction, RatOutAttacker, CheckDeadBody, CheckDeadHead, WatchFunnyThing,
		CheckDesiredThing, CheckForIntruder, CanStartConversation, HandleStasisChange, FreeToSeekPlayer;

	///////////////////////////////////////////////////////////////////////////////
	// Everybody has better hearing when they looking for an attacker--before only 
	// cops would investigate sounds behind walls, no everyone does
	///////////////////////////////////////////////////////////////////////////////
	function GetReadyToReactToDanger(class<TimedMarker> dangerhere, 
									FPSPawn CreatorPawn, 
									Actor OriginActor,
									vector blipLoc,
									optional out byte StateChange)
	{
		if(CreatorPawn == Attacker
			|| CreatorPawn == InterestPawn)
			FoundHim(CreatorPawn);
		else
			Global.GetReadyToReactToDanger(dangerhere, CreatorPawn, OriginActor, blipLoc, StateChange);
	}

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CrabShuffleFromAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CrabShuffleFromAttacker extends WalkToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, 
		RespondToTalker, RatOutAttacker, MarkerIsHere, PrepToWaitOnDoor, HandlePlayerSightReaction,
		RespondToQuestionNegatively, CheckObservePawnLooks, CanStartConversation, CanBeMugged,
		RespondToCopBother, PerformInterestAction, CheckForIntruder, FreeToSeekPlayer, RocketIsAfterMe;
/*
	///////////////////////////////////////////////////////////////////////////
	// Shot when begging, but not dead, so cry more
	// Or run or something
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		//local vector dir;

		PrintDialogue("Waaaahhaa... boohoo");
	}
*/
	///////////////////////////////////////////////////////////////////////////////
	// Moan, make noises as you crawl
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		// Check to maybe start begging again if we notice the dude is
		// on us with a gun
		CurrentDist = VSize(Attacker.Location - MyPawn.Location);
		if(CurrentDist < COWER_DISTANCE
			&& WeaponTurnedToUs(Attacker, MyPawn))
			StartBegging(P2Pawn(Attacker));
		else
			//PrintDialogue("ehh.. oooh...");
			Say(MyPawn.myDialog.lSniveling);
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		// We hope MyNextState was set to something useful, before we start
		if(MyNextState=='')
			PrintStateError(" no mynextstate");
		
		// force an animation change
		//MyPawn.SetWalking(false);
		// do crawl anim
		//MyPawn.ShouldCrouch(true);
		//MyPawn.SetWalking(true);

		SetRotation(MyPawn.Rotation);
		//log("inside walk to target "$MyNextState);
		if(EndGoal != None)
			SetActorTarget(EndGoal);
		else
			SetActorTargetPoint(EndPoint);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're looking for a cop
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToFindCop extends RunToTargetUrgent
{
	///////////////////////////////////////////////////////////////////////////////
	// If you bump into a cop along the way, stop this state.
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		if(Pawn(Other) != None
			&& PoliceController(Pawn(Other).Controller) != None)
			NextStateAfterGoal();
		else if(StaticMeshActor(Other) != None)
			BumpStaticMesh(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're going back to where the trouble started
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunBackToDanger extends RunToTargetUrgent
{
	///////////////////////////////////////////////////////////////////////////////
	// If you bump you're attacker, exit now
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		if(Attacker.Health > 0
			&& Attacker != None
			&& Other == Attacker)
			NextStateAfterGoal();
		else if(StaticMeshActor(Other) != None)
			BumpStaticMesh(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// If you can see your attacker now, point him out to the cop, otherwise, 
	// just be scared
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		if(Attacker != None
			&& FastTrace(Attacker.Location, MyPawn.Location))
		{
			// If our cop is dead or non-existant, then get another
			if(InterestPawn2 == None
				|| InterestPawn2.Health <= 0)
				GoFindACop();
			else
				GotoStateSave('PointOutAttacker');	
		}
		else
			Super.NextStateAfterGoal();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to a target, while being chased by Attacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToTargetFromAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Do things after you reach a crappy goal, not your end goal
	///////////////////////////////////////////////////////////////////////////////
	function IntermediateGoalReached()
	{
		//log(self$" run dot "$Normal((Attacker.Location - MyPawn.Location)) dot vector(MyPawn.Rotation));
		CalcScaredRunAnim();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DeathCrawlFromAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DeathCrawlFromAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		FPSPawn(Pawn).StopAcc();
		GotoNextState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DeathCrawlChem
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DeathCrawlChem extends DeathCrawlFromAttacker
{

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function InterimSound()
	{
		Say(MyPawn.myDialog.lBodyFunctions);
	}
	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function StartSound()
	{
		Say(MyPawn.myDialog.lBodyFunctions);
	}
	function EndState()
	{
		Super.BeginState();
		MyPawn.Notify_StopPuking();
	}
	function BeginState()
	{
		Super.BeginState();
		// puke type for when we're deathcrawling
		MyPawn.Notify_StartDeathCrawlPuking();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// VerballyAbuseAttackerAfterBeg
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state VerballyAbuseAttackerAfterBeg
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, HearWhoAttackedMe, RespondToTalker, RatOutAttacker, MarkerIsHere, 
		RespondToQuestionNegatively, CheckObservePawnLooks,
		RespondToCopBother, RocketIsAfterMe;

	///////////////////////////////////////////////////////////////////////////////
	// say something mean to attacker
	///////////////////////////////////////////////////////////////////////////////
	function YellVerbalAbuse()
	{
		Say(MyPawn.myDialog.lTrashTalk);
/*		if(FRand() <= 0.5)
			PrintDialogue("You're not so tough!");
		else
			PrintDialogue("How 'bout you fight like a man!");
*/
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stand up and yell something
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		// stand up to yell things
		MyPawn.ShouldCrouch(false);

		Focus = Attacker;
		statecount=0;

		YellVerbalAbuse();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Finish pointing yelling at someone
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			MyPawn.ChangeAnimation();
		}
	}

YellAbuse:

	// Point anim
	MyPawn.PlayTellOffAnim();
	YellVerbalAbuse();

Begin:

	Sleep(0.3);

	// Make sure our attacker is still alive, if not, watch that spot
	if(Attacker.bDeleteMe
		|| Attacker.Health <= 0)
	{
		DangerPos = Attacker.Location;
		GotoStateSave('FleeFromDanger');
	}
	// If he looks at us again, we get scared quickly
	else if(CanSeePawn(Attacker, MyPawn))
		Goto('QuickChange');

	statecount++;

	if(statecount < VERBAL_ABUSE_LOOP_MAX)
		Goto('Begin');
	else
	{
		statecount=0;
		Goto('YellAbuse');
	}

QuickChange:

	GotoNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You see a dead body or a disembodied head off in the distance, decide what to do
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InvestigateDeadThing
{
	///////////////////////////////////////////////////////////////////////////////
	// See if we will throw up after seeing the body
	///////////////////////////////////////////////////////////////////////////////
	function CheckToPukeBody()
	{
		local byte StateChange;

		if(OldAttacker == None)
		{
			CheckToPuke(DEAD_BODY_GROSS_MOD,,StateChange);
			if(StateChange == 1)
			// Run away from him, after puking
			{
				DangerPos = InterestActor.Location;
				SetNextState('FleeFromDanger');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		MyNextState='';
		BystanderDamageAttitudeTo(Other, Damage);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function MoveCloser()
	{
		local float dist;
		local vector checkpos;

		if(InterestActor != None)
		{
			// Make sure the body isn't on fire first
			if(InterestPawn == None
				|| InterestPawn.MyBodyFire == None)
			{
				dist = VSize(MyPawn.Location - InterestActor.Location);
				if(dist > UseSafeRangeMin)
				{
					SetEndPoint(InterestActor.Location, UseSafeRangeMin);
					SetNextState(GetStateName(), 'CloseEnough');
					GotoStateSave('WalkToDeadThing');
				}
			}
			else
				GotoStateSave('InvestigateDeadThing');
		}
		else
			GotoStateSave('Thinking');
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// Put away you're weapon first
		SwitchToHands();
		// Either be scared or mad on the way over to the gross thing.. just don't be normal
		if(MyPawn.bHasViolentWeapon)
			MyPawn.SetMood(MOOD_Scared, 1.0);
		else
			MyPawn.SetMood(MOOD_Combat, 1.0);
	}

StareALongTime:
	Sleep(Rand(STARE_AT_DEAD_THING) + 1);
Begin:
	Focus = InterestActor;
	Sleep(2.0 - 2*MyPawn.Reactivity);
	MyPawn.StopAcc();
	Sleep(2.0 - 2*MyPawn.Reactivity);
ReadyToMove:
	MoveCloser();

CloseEnough:
	// Tough guy here is strong enough not to puke and probably wants
	// to kick the body/head
	if(MyPawn.bHasViolentWeapon
		|| (InterestPawn != None
			&& InterestPawn.bPlayer)
		|| OldAttacker != None)
	// tough guy choices
	{
		SetEndPoint(InterestActor.Location, UseSafeRangeMin/2);
		SetNextState('InvestigateDeadThing', 'StareAtBody');
		GotoStateSave('WalkToDeadThing');
StareAtBody:
		Focus = InterestActor;
		Sleep(MyPawn.Curiosity + 1);	// stare a while
		if(InterestPawn != None
			&& InterestPawn.bPlayer)
		{
			Sleep(Rand(STARE_AT_DEAD_DUDE));// possibly stare a long while
			// Say something mean about him
			SayTime = Say(MyPawn.myDialog.lDudeDead);
			PrintDialogue("The dude sure was bad...");
			Sleep(Rand(STARE_AT_DEAD_DUDE) + 1);	// stare a long while
		}
		
		// Sick ones will kick the body
		if(FRand() > MyPawn.Conscience
			|| FRand() > MyPawn.Curiosity
			|| (InterestPawn != None
				&& InterestPawn.bPlayer
				&& FRand() > KICK_DEAD_DUDE))
		{
TryToKick:
			// If you're close enough, just kick
			if(VSize(InterestActor.Location - MyPawn.Location) <= DEFAULT_END_RADIUS + 2*MyPawn.CollisionRadius)
			{
				SetNextState('InvestigateDeadThing','StareAtBody');
				GotoStateSave('DoKicking');
			}
			else // not close.. then try to get closer
			{
				SetEndPoint(InterestActor.Location, DEFAULT_END_RADIUS + MyPawn.CollisionRadius);
				SetNextState('InvestigateDeadThing', 'TryToKick');
				GotoStateSave('WalkToDeadThing');
			}
		}
		// Normal-ish people will just walk up and look
		// or stop if they're bored
		// Be more likley to kick the dead dude
		else
		{
			GotoStateSave('Thinking');
		}

	}
	else // scared choices
	{
		// See if you will puke
		CheckToPukeBody();
		
		// Didn't puke, so run away from this point now
		DangerPos = InterestActor.Location;
		InterestActor = None;
		InterestPawn = None;
		UseSafeRangeMin = MyPawn.SafeRangeMin;

		PrintDialogue("the horror!!");
		SayTime = Say(MyPawn.myDialog.lcarnageoccurred);
		Sleep(SayTime + FRand());

		GotoStateSave('FleeFromDanger');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// See what the wetness on us is. If we're facing the pissing person, then
// we short-circuit because we immediately know what's happening.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InvestigateWetness
{
	ignores HandlePantsDown;

	///////////////////////////////////////////////////////////////////////////////
	// Run away (to get away from the piss!) then turn around and kick his butt or arrest him
	///////////////////////////////////////////////////////////////////////////////
	function RunAwayThenDecide()
	{
		local vector dir;

		SetAttacker(InterestPawn);
		// pick a distance away
		dir = MyPawn.Location - Attacker.Location;
		dir = Normal(dir);
		dir = MyPawn.Location + PISS_RUN_AWAY_DIST*dir;

		GetMovePointOrHugWalls(dir, MyPawn.Location, PISS_RUN_AWAY_DIST, true);

		Focus = InterestPawn;
		SetEndPoint(dir, DEFAULT_END_RADIUS);
		//log("new end point "$dir);

		GetMoreAngry(MyPawn.Temper);
		PrintDialogue("Ewwww...");
		MyPawn.DisgustedSpitting(MyPawn.myDialog.lGettingPissedOn);
		SetNextState('AssessAttacker');

		ScreamState = SCREAM_STATE_NONE;
		GotoStateSave('RunFromPisser');
	}

	///////////////////////////////////////////////////////////////////////////////	
	// Check to see if you see the pisser already 
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// if they're already pissing on us (we know about it)
		if(Attacker == InterestPawn)
		{
			PrintDialogue("Gross!");
			Say(MyPawn.myDialog.lAfterGettingPissedOn);
			//GotoStateSave('AssessAttacker');
		}
		else if(CanSeePawn(MyPawn, InterestPawn))// see if we're watching them do this
		{
			SetAttacker(InterestPawn);
//			PrintDialogue("Hey, what are you doing!!");
			MyPawn.DisgustedSpitting(MyPawn.myDialog.lGettingPissedOn);
			CanSeePawn(MyPawn, InterestPawn);
		}
		else
		{
			PrintDialogue("What the...?");
			SayTime = Say(MyPawn.myDialog.lWhatThe);
		}
		MyPawn.ShouldCrouch(false);
	}

Begin:
	MyPawn.StopAcc();
	// Turn towards the person pissing on us
	Focus = InterestPawn;
	Sleep(SayTime);

	// possibly throw up from the yuckiness
	//log("checking to puke RKellyTest set to true",'Debug');
	bRKellyTest = True;
	CheckToPuke(PISSED_ON_GROSS_MOD);

	// if you don't have a gun, run away
	if(!MyPawn.bHasViolentWeapon)
	{
		CurrentDist = 0;
		// Decide current safe min
		UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;

		//GoFindACop();
		SetAttacker(InterestPawn);
		GotoStateSave('FleeFromPisser');
	}
	else // if you have a gun, run away then attack him
	{
		// We don't deal well with the pisser
		RunAwayThenDecide();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Gas is being dumped on us
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ReactToGasoline
{
	///////////////////////////////////////////////////////////////////////////////	
	// Either attack or run
	///////////////////////////////////////////////////////////////////////////////	
	function DecideNextState()
	{
		SetAttacker(InterestPawn);
		if(MyPawn.bHasViolentWeapon)
			GotoStateSave('AssessAttacker');
		else
			GotoStateSave('FleeFromPisser');
	}

	///////////////////////////////////////////////////////////////////////////////	
	// Check to see if you see the pisser already 
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// if they're already pissing on us (we know about it)
		if(Attacker == InterestPawn
			&& InterestPawn != None)
		{
			DecideNextState();
		}
		else if(CanSeePawn(MyPawn, InterestPawn))// see if we're watching them do this
		{
			SetAttacker(InterestPawn);
			PrintDialogue("What the...?");
			SayTime = Say(MyPawn.myDialog.lWhatThe);
			CanSeePawn(MyPawn, InterestPawn);
		}
		else
		{
			PrintDialogue("What the...?");
			SayTime = Say(MyPawn.myDialog.lWhatThe);
		}
		MyPawn.ShouldCrouch(false);
	}

Begin:
	MyPawn.StopAcc();
	// Turn towards the person pissing on us
	Focus = InterestPawn;
	Sleep(SayTime);

	CurrentDist = 0;
	// Decide current safe min
	UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;

	DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do when attacked
// extends original, and allows begging
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ReactToAttack
{
	///////////////////////////////////////////////////////////////////////////////
	// Decide to run or attack
	///////////////////////////////////////////////////////////////////////////////
	function DetermineAttitudeToAttacker()
	{
		SaveAttackerData();
		// Check to see if I should run
		if(MyPawn.Health < (1.0-MyPawn.PainThreshold)*MyPawn.HealthMax)
		{
			if(MyPawn.Beg > FRand())
			{
				StartBegging(P2Pawn(Attacker));
				return;
			}
			else
			{
				GotoStateSave('FleeFromDanger');
				return;
			}
		}
		else // Or stay and fight
		{
			GotoStateSave('RecognizeAttacker');
			return;
		}
	}
	// Override base one, because we want to set our mood to scared
	function BeginState()
	{
		PrintThisState();
		MyPawn.SetMood(MOOD_Scared, 1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to the danger spot to investigate things
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepRunToInvestigate
{
	ignores CheckObservePawnLooks, MarkerIsHere, TryToGreetPasserby;

	function BeginState()
	{
		PrintThisState();
	}

Begin:
	LastAttackerPos = DangerPos;
	SetAttacker(None);

	SetEndPoint(DangerPos, CHECK_DANGER_DIST);

	Sleep(0.0);

	SetNextState('RecognizeAttacker');
	GotoStateSave('RunToTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RecognizeAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RecognizeAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Stare at pawn
	///////////////////////////////////////////////////////////////////////////////
	function PickOutAttacker(FPSPawn Other, vector CheckLoc)
	{
		local FPSPawn usepawn;

		// Start looking at him
		Focus = VisuallyFindPawn(Other, CheckLoc);

		if(Focus == None)
			Focus = InterestPawn2;
		//log("use focus "$Focus);

		// if this person has a weapon out already, make him our current suspect
		usepawn = FPSPawn(Focus);
		if(P2Pawn(usepawn) != None
			&& usepawn.Weapon != None
			&& (P2Weapon(usepawn.Weapon).ViolenceRank > 0
				|| (MyPawn.LastDamageType == class'KickingDamage')))
		{
			// if not in my gang, then attack
			if(!SameGang(Attacker))
				SetAttacker(usepawn);
		}
		//else if(AnimalPawn(usepawn) != None)
		//	Attacker = usepawn;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Someone you just beat up, who didn't have a gun, now has a gun
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state VictimPerformRebelAttack extends ShootAtAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// and in some dialogue and make sure you stand up
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local P2Weapon p2weap;

		Super.BeginState();

		SwitchToBestWeapon();
		p2weap = P2Weapon(MyPawn.Weapon);
		// Check to see if we got a good weapon
		if(p2weap.ViolenceRank > 0)
		{
			MyPawn.bHasViolentWeapon=true;

			MyPawn.ShouldCrouch(false);

			//PrintDialogue("I'm not a victim!");
			Say(MyPawn.myDialog.lDecideToFight);
		}
		else
		{
			// we didn't so keep begging
			GotoState('PerformBegForLifeOnKnees');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Shoot at a guy from behind the fire, waiting to advance again
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAttackerBehindFire extends ShootAtAttacker
{
	ignores damageAttitudeTo;

	///////////////////////////////////////////////////////////////////////////////
	// See if there's someone in the way, if so handle it
	///////////////////////////////////////////////////////////////////////////////
	function CheckForObstacle(optional out byte StateChange)
	{
		local Actor HitActor;
		local vector HitLocation, HitNormal;
		//local vector checkdir;

		//checkdir = vector(MyPawn.Rotation);

		//Pawn.Location + (VISUALLY_FIND_RADIUS * checkdir)
		HitActor = Trace(HitLocation, HitNormal, Attacker.Location, MyPawn.Location, true);
		if(HitActor != None)
		// Something was in the way
		{
			if(FPSPawn(HitActor) != None)
			{
				// If it's our target, then leave now, because we want to shoot him
				if(HitActor == Attacker)
					return;

				// If there's someone in the way (other than the person you're trying to kill)
				// then do something about it
				if(P2Pawn(HitActor) != None
					&& FRand() <= MyPawn.Compassion)
				// This means we don't want to kill innocents, so try to move them
				{
					HandleHumanObstacle(P2Pawn(HitActor));
					return;
				}
			}
			else  // Not a pawn, so negotiate it or wait
			{
				// Decide here, that sometimes when we're tracking a guy, we
				// might want to wait before following him around stuff. So 
				// sometimes, we'll go into waiting, hiding mode--that is, if we
				// have cover

				// Check if we have cover
				if(statecount == 0 && FRand() <= MyPawn.WillUseCover)
				{
					RunToSafePoint(Rand(HIDING_WAIT_TIME));
				}
				else // if not ducking and waiting, follow him immediately
				{
					log("this was in my way! "$HitActor$" running with this as range "$MyPawn.AttackRange.Min);
					SetEndGoal(Attacker, MyPawn.AttackRange.Min);
					// and reduce our attack range, so he'll try for closer next time
					SetAttackRange(MyPawn.AttackRange.Min*0.95);
					SaveAttackerData();
					SetNextState('ShootAtAttacker', 'LookForAttacker');
					bStraightPath=UseStraightPath();
					GotoStateSave('RunToAttacker');
					return;
				}
			}
		}
	}

WaitTillFacing:

	Focus = Attacker;
	FinishRotation();
	//Sleep(0.5);

Begin:
	if(Enemy == None || Enemy.Health <= 0)
	{
		SetAttacker(None);
		Enemy = None;
		GotoStateSave('Thinking');
	}

	//CheckForObstacle();
FireNowPrep:
	DecideFireCount();
FireNow:
	// We know we can still see him here, so record his 
	SaveAttackerData();

	FireWeaponAt(Enemy);
	StopFiring();

	Sleep(MyPawn.Twitch);

	// Test to attacker, if there's no fire, you can go ahead and run to
	// him, otherwise, wait and attack
	InterestActor = CheckForFire(MyPawn.Location, LastAttackerPos);//InterestVect2);

	//log("interest actor "$InterestActor);
	//log("check point "$LastAttackerPos);
	if(InterestActor == None)
	{
		// carry on a normal attack
		//log("i'm ready to attack again");
		GotoStateSave('ShootAtAttacker');
	}
	Goto('Begin');
}

// Reinstate these calls -- causing problems with stasis pawns not reacting to the dude.
// Do not change or remove these calls, it will break older save games if you do.
///////////////////////////////////////////////////////////////////////////////
// Ignore intruders in stasis (this is a problem for some reason)
///////////////////////////////////////////////////////////////////////////////
state StasisState
{
	function CheckForIntruder(FPSPawn LookAtMe, out byte StateChange)
	{
		Global.CheckForIntruder(LookatMe, StateChange);
	}
	
	function HandleIntruder(FPSPawn LookAtMe)
	{
		Global.HandleIntruder(LookatMe);
	}
	
	event Trigger( Actor Other, Pawn EventInstigator )
	{
		Global.Trigger(Other, Eventinstigator);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Ignore intruders in stasis (this is a problem for some reason)
///////////////////////////////////////////////////////////////////////////////
state SliderStasis
{
	function CheckForIntruder(FPSPawn LookAtMe, out byte StateChange);
	function HandleIntruder(FPSPawn LookAtMe);
	event Trigger( Actor Other, Pawn EventInstigator );
}

///////////////////////////////////////////////////////////////////////////////
// LegMotionToTarget
// Chance of going into cell phone idling
///////////////////////////////////////////////////////////////////////////////
// Removed, this checks ALL legmotion states and it makes more sense to interrupt
// a walk in the middle instead of the beginning.
/*
state LegMotionToTarget
{
	function BeginState()
	{
		Super.BeginState();
		CheckForCellIdle();
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// WalkToTarget
// Chance of going into cell phone idling
///////////////////////////////////////////////////////////////////////////////
state WalkToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();
		CheckForCellIdle();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function IntermediateGoalReached()
	{
		Super.IntermediateGoalReached();
		CheckForCellIdle();
	}
}

///////////////////////////////////////////////////////////////////////////////
// PerformIdle
// Chance of going into cell phone idling
///////////////////////////////////////////////////////////////////////////////
state PerformIdle
{
	function BeginState()
	{
		Super.BeginState();
		CheckForCellIdle();
	}
}

///////////////////////////////////////////////////////////////////////////////
// We just saw something funny and we might laugh at it
///////////////////////////////////////////////////////////////////////////////
function WatchGrossThing(P2Pawn LaughTarget)
{
	if(Rand(2) == 0
		&& CanSeePawn(MyPawn, LaughTarget))
	{
		InterestPawn = LaughTarget;
		Focus = None;
		FocalPoint = InterestPawn.Location;
		GotoStateSave('WatchGuyWithCowhead');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Some danger occurred
///////////////////////////////////////////////////////////////////////////////
function MarkerIsHere(class<TimedMarker> bliphere,
					  FPSPawn CreatorPawn, 
					  Actor OriginActor,
					  vector blipLoc)
{
	local byte Reacted;
	local bool bUseSuper;
	
	bUseSuper = true;

	if(!MyPawn.bIgnoresSenses)
	{
		if(bliphere == class'GrossThingMarker')
		{
			bUseSuper = false;
			WatchGrossThing(P2Pawn(CreatorPawn));
		}
	}
	
	if (bUseSuper)
	Super.MarkerIsHere(bliphere, CreatorPawn, OriginActor, blipLoc);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Farting
// Whoever smelt it, dealt it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Farting
{
Begin:
	MyPawn.StopAcc();

	class'GrossThingMarker'.static.NotifyControllersStatic(
		Level,
		class'GrossThingMarker',
		MyPawn, 
		MyPawn, 
		class'GrossThingMarker'.default.CollisionRadius,
		Pawn.Location);
	MyPawn.PlaySound(FartSounds[Rand(FartSounds.Length)], SLOT_Interact, 1.0,,128.0, MyPawn.GetRandPitch());
	Sleep(1.0);
	SayTime = Say(MyPawn.myDialog.lpleasureresponse);
	Sleep(SayTime + FRand());
	
	// Go back to whatever we were doing
	GotoState('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Sneezing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Sneezing
{
Begin:
	MyPawn.StopAcc();
	MyPawn.PlaySneezing();
	
	SayTime = Say(MyPawn.myDialog.lSneezing);
	Sleep(SayTime + FRand());
	
	// Go back to whatever we were doing
	GotoState('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Sneezing while walking
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SneezingWalking extends WalkToTarget
{
	// Go about as before
	event AnimEnd( int Channel )
	{
		MyPawn.SetAnimWalking();
	}
Begin:
	MyPawn.MaybeUseSpecialWalkAnim(MyPawn.GetAnimSneezingWalking());
	
	SayTime = Say(MyPawn.myDialog.lSneezing);
ImWalkingHere:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,MyPawn.MovementPct,,,true);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,MyPawn.MovementPct,true);
		InterimChecks();
		Sleep(0.0);
	}
	Goto('ImWalkingHere');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PerformCellIdle
// We're idling around and someone calls us.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PerformCellIdle
{
	ignores CanBeMugged;

    ///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		if (bLoopCell)
			P2MoCapPawn(Pawn).PlayCellLoop();
//		bFinishedAnim = true;
	}

    ///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		PersonController(Pawn.Controller).SwitchToHands();
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
Begin:
	bLoopCell=false;

	// Stop what we're doing
	MyPawn.StopAcc();

	// for debug
	//GetRandomPlayer().ClientMessage(self@"entering cell phone talk");
//	spawn(class'CellBeacon',,, Location);

	// Begin cell phone idling. Phone rings a couple times
	CurrentFloat = Rand(CELL_TALK_RING) + 1;
ObnoxiousRing:
	// Phone rings
	SayTime = P2MoCapPawn(Pawn).PlayIncomingCall();
	Sleep(SayTime*2);

	// See if we care to answer it yet
	CurrentFloat = CurrentFloat - 1;
	if (CurrentFloat >= 0)
		Goto('ObnoxiousRing');

	// Finally decide to answer phone
AnswerPhone:
	// Switch to cell phone weapon
	P2MoCapPawn(Pawn).PlayCellIn();
	FinishAnim();

	// Answer the phone
	P2MoCapPawn(Pawn).PlayCellOn();
	Sleep(1.0);
	bLoopCell=True;
	P2MoCapPawn(Pawn).PlayCellLoop();

	// Say hello to the caller
	PrintDialogue("hello?");
	SayTime = Say(MyPawn.myDialog.lGreeting);
	Sleep(SayTime + FRand());

	// Enter a loop of random bullshitting with the caller
    CurrentFloat = Rand(CELL_TALK_LOOP) + 3;

	// Wait for the guy on the other end to "say" something
	Sleep(CELL_TALK_WAIT + 2*(FRand()-0.5));
RandomBullshitting:

	// Say something back
	PrintDialogue("cell phone bullshitting");
	SayTime = Say(MyPawn.myDialog.lCellPhoneTalk);
	Sleep(SayTime + FRand());

	// Wait for the guy on the other end to "say" something
	Sleep(CELL_TALK_WAIT + 2*(FRand()-0.5));
	CurrentFloat = CurrentFloat - 1;

	if (CurrentFloat > 0)
		Goto('RandomBullshitting');

	// Done bullshitting, hang up the phone
HangUp:
	bLoopCell=false;
	P2MoCapPawn(Pawn).PlayCellOut();
	FinishAnim();

	// Go back to whatever we were doing
	GotoState('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Take a piss!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TakeALeak
{
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		// Go to my next state
		if(MyNextState != 'None'
			&& MyNextState != '')
		{
			GotoNextState();
		}
		else // or keep dancing
		{
			if(Focus == None)
				GotoState(GetStateName(), 'Begin');
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
		MyPawn.SetMood(MOOD_Normal, 1.0);
		// Turn off the waterworks, if any (might have gotten interrupted while peeing)
		if (NPCUrethraWeapon(Pawn.Weapon) != None)
		{
			//log(self@"INTERRUPTED while pissing! Forcing to stop and switching back to hands");
			
			// Force the weapon to finish, whatever it takes.
			NPCUrethraWeapon(Pawn.Weapon).bFinishPissing = true;
			NPCUrethraWeapon(Pawn.Weapon).ForceEndFire();
			NPCUrethraWeapon(Pawn.Weapon).GotoState('DownWeapon');
			
			// And switch back to hands
			SwitchToHands();
			//log(self@"Pawn weapon is now"@Pawn.Weapon);
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Aim at the thing we want to pee into
	///////////////////////////////////////////////////////////////////////////////
	function rotator GetViewRotation()
	{
		local rotator ORot;
		local vector VDiff;
		local float PDiff;

		if (Focus != None)
		{
			VDiff = Focus.Location - Pawn.Location;
			VDiff.Z = VDiff.Z - Pawn.EyeHeight;
			ORot = Rotator(VDiff);
			return ORot;
		}
		else
			return Global.GetViewRotation();
	}
	

Begin:
	//log(self@"taking a leak now, switching to pisser");
	// Change to pisser
	SwitchToThisWeapon(class'NPCUrethraWeapon'.Default.InventoryGroup, class'NPCUrethraWeapon'.Default.GroupOffset);
	
	// Wait for it to become ready
	while (!Pawn.Weapon.IsInState('Idle'))
		Sleep(0.1);

	//log(self@"firing pisser");
	// Now fire
	if (NPCUrethraWeapon(Pawn.Weapon) != None)
	{
		NPCUrethraWeapon(Pawn.Weapon).LeakTime = CurrentFloat;
		NPCUrethraWeapon(Pawn.Weapon).bGonorrheaPiss = false;
		NPCUrethraWeapon(Pawn.Weapon).Fire(1);
	}
	
	// Wait it out
	Sleep(CurrentFloat + FRand());
	
	//log(self@"finished, zipping up");
	// Zip back up
	SwitchToHands();

	// Wait for it to become ready
	while (!Pawn.Weapon.IsInState('Idle'))
		Sleep(0.1);
		
	//log(self@"done pissing, returning to going about our business now");
	// And go back to what we were doing
	DecideNextState();
}

// Change by NickP: NicksCoop fix
function bool nc_PlayerIsEnemy()
{
	return ( MyPawn != None && (MyPawn.bPlayerIsEnemy || MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_AttackPlayer) );
}

function bool nc_WantsToKill(Pawn Other)
{
	return ( Other != None && Other.Health > 0 && PlayerController(Other.Controller) != None );
}

function nc_ForceAlertMe(Pawn AlertPawn)
{
	if( Level.TimeSeconds < fForceAlertTime )
		return;
	fForceAlertTime = Level.TimeSeconds + FORCE_ALERT_DELAY;

	if( Attacker != None 
		&& ( Attacker == AlertPawn || VSize(AlertPawn.Location-MyPawn.Location) > VSize(Attacker.Location-MyPawn.Location)) )
		return;

	MakeMoreAlert();
	SetToAttackPlayer(FPSPawn(AlertPawn));
}

function HearNoise(float Loudness, Actor NoiseMaker)
{
	if( bCoopAlertMode && nc_PlayerIsEnemy() && NoiseMaker != None && nc_WantsToKill(NoiseMaker.Instigator) )
	{
		nc_ForceAlertMe(NoiseMaker.Instigator);
	}
}

event SeePlayer(Pawn SeenPlayer)
{
	if( bCoopAlertMode && nc_PlayerIsEnemy() && nc_WantsToKill(SeenPlayer) )
	{
		nc_ForceAlertMe(SeenPlayer);
	}
}
// End

defaultproperties
{
	InterestInventoryClass=Class'Inventory.MoneyInv'
	ValentineVaseClass=class'Inventory.VaseInv'
	FartSounds[0]=Sound'AmbientSounds.fart1'
	FartSounds[1]=Sound'AmbientSounds.fart3'
	FartSounds[2]=Sound'AmbientSounds.fart4'
	FartSounds[3]=Sound'AmbientSounds.fart5'
	LookZombieClass=Class'AWZombie'
}
