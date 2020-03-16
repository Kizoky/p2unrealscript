///////////////////////////////////////////////////////////////////////////////
// AWCowBossController
// Copyright 2004 RWS, Inc.  All Rights Reserved.
//
// Spits out orbiting gary heads
// Walks around/towards attacker
// Attacks by throwing heads or shooting diseased milk
// If not blocked by the Great Eye, it counts of damage trying to be dealt
// to it and then laughs after a time
///////////////////////////////////////////////////////////////////////////////
class AWCowBossController extends AnimalController;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
var float RunDamage;		// damage inflicted in these states
var float ChargeDamage;

var bool bForceRun;			// If, after something important happened and we go
							// to a think state that may randomly stop or run, this can
							// force it to run once, then get reset
var float HeadOrbitNum;		// Max number of heads that should be orbitting above me
var float touchdnum;		// damage amount on touch
var class<P2Damage> touchdtype;	// damage type on touch--burning
var float StandFreq;		// stand around frequency
var float WalkAttackTimeHalf;// how long to walk towards an attacker before changing states
var float AttackFreq;		// how often to attack in general
var float LeftShotFreq;		// how often to shoot thing with left hand
var float RightShotFreq;	// how often to shoot thing with right hand
var float TeatShootFreq;	// how often to shoot with your utter
var float TimeToMakeMoreHeads; // Level time we should make more heads, if we're past this, we'll probably 
							// make more heads
var float TimeWithoutHeads;	// How long to go without heads orbiting you
var bool  bNeedMoreHeads;	// Means TimeToMakeMoreHeads is valid
var bool  bAbsorbCount;		// Whether or not to keep counting damage
var float	LevelSayTime;		// Time you started talking in the level
var float	SayLengthTime;		// Length of time you need to talk for in seconds
var float MoanFreq, TouretteFreq;
var bool  bDoIntro;
var name ZombieSpawnerTag;	// name of zombies to spawn before you go into make heads mode

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const MIN_VELOCITY_FOR_REAL_MOVEMENT = 100;
const LEG_MOTION_CAUGHT_MAX	=	3;

const PICK_NEAREST_VICTIM	=	0.4;

const VICTIM_FIND_RADIUS	=	4096;

const MAX_TURN_WAIT			=	10.0;

const HIT_RATIO				=	0.01;

const FRONT_BUMP_DOT		=	0.5;
const BACK_KICK_DOT			=	-0.5;

const MOO_SOUND_FREQ		=	0.4;
const SCARED_SOUND_FREQ		=	0.5;

const MIN_SMALL_RADIUS		=	50.0;

const ATTACK_END_RADIUS		=	300;
const DIFF_CHANGE_ANIM_SPEED= 0.08;
const DIFF_CHANGE_HEALTH	= 0.1;

const START_HEADS_DAMAGE	= 10;


///////////////////////////////////////////////////////////////////////////////
// Possess the pawn
///////////////////////////////////////////////////////////////////////////////
function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);

	RampDifficulty();
}

///////////////////////////////////////////////////////////////////////////////
// Based on the difficulty settings, change the zombie's attributes
///////////////////////////////////////////////////////////////////////////////
function RampDifficulty()
{
	local float gamediff, diffoffset;

	gamediff = P2GameInfo(Level.Game).GetGameDifficulty();
	diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset();

	if(diffoffset != 0)
	{
		// more/less health based on difficulty
		MyPawn.HealthMax				  += (diffoffset*MyPawn.HealthMax*DIFF_CHANGE_HEALTH);
		// Make cowboss slightly faster animating as the difficulty increases
		AWCowBossPawn(MyPawn).GenAnimSpeed+= (diffoffset*DIFF_CHANGE_ANIM_SPEED);
	}

	// Double his health in Impossible mode. Just because. :D
	// Also make him meaner and tougher
	if (P2GameInfoSingle(Level.Game).InImpossibleMode())
	{
		MyPawn.HealthMax *= 2;
		AWCowBossPawn(MyPawn).GenAnimSpeed *= 1.5;
		
		// Attack more
		AttackFreq = 0.75;
		LeftShotFreq=0.3;
		RightShotFreq=0.4;
		TeatShootFreq=0.5;
		// More heads
		HeadOrbitNum=9;
		// Idle less
		StandFreq=0;
		// Move faster
		MyPawn.GroundSpeed *= 2;
		AWCowBossPawn(MyPawn).ChargeGroundSpeed *= 2;
	}
}

///////////////////////////////////////////////////////////////////////////////
// start: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////
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

	keepp = FPSPawn(FindNearestActorByTag(AWCowPawn(MyPawn).InitAttackTag));

	if(keepp == None
		|| keepp.bDeleteMe
		|| keepp.Health < 0)
	{
		keepp = None;

		if(!MyPawn.bPlayerIsFriend
			&& !MyPawn.bNoTriggerAttackPlayer)
			keepp = GetRandomPlayer().MyPawn;
	}

	HandleAttack(keepp);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SaveNewAttacker(FPSPawn AttackMe)
{
	if(AttackMe != None
		&& AWZombie(AttackMe) == None)
	{
		MyPawn.SetMood(MOOD_Angry, 1.0);
		SetAttacker(AttackMe);
		DangerPos = AttackMe.Location;
	}
}

///////////////////////////////////////////////////////////////////////////
// Switch your state appropriately
///////////////////////////////////////////////////////////////////////////
function HandleAttack(FPSPawn Other)
{
	if(Attacker == None
		&& Other != None
		&& AWZombie(Other) == None)
	{
		SaveNewAttacker(Other);
//		GotoStateSave('AttackTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Print out what the dialogue should say, with who said it
///////////////////////////////////////////////////////////////////////////////
function PrintDialogue(String diastr)
{
	if(P2GameInfo(Level.Game).LogDialog == 1)
		log(self$"---------------------------"$MyPawn$" says: "$diastr);
}

///////////////////////////////////////////////////////////////////////////////
// Say the specified line of dialog.
// Returns the duration of the specified line.
// Moaning will set bDontOverwrite, so other moaning won't contradict it,
// but getting hurt and attacking will set bAlwaysPlay which will override
// bDontOverwrite
///////////////////////////////////////////////////////////////////////////////
function float Say(out P2Dialog.SLine line, optional bool bImportant, 
				   optional bool bDontOverwrite, optional bool bAlwaysPlay)
{
	// It's been long enough to say more
	// or it's very important
	if(SayLengthTime + LevelSayTime < Level.TimeSeconds
		|| bAlwaysPlay)
	{
		// Save the time again on things you want to have checked for. This will
		// keep this sound from getting overwritten when he tries to talk
		// again too soon
		if(bDontOverwrite)
			LevelSayTime = Level.TimeSeconds;

		SayLengthTime = AWCowBossPawn(MyPawn).Say(line, bImportant);
		return SayLengthTime;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Don't yell when hurt by anthrax, etc.
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, 
					   class<DamageType> damageType, vector Momentum)
{
	if((ClassIsChildOf(damageType, class'AnthDamage')
			|| ClassIsChildOf(damageType, class'BurnedDamage')
			|| ClassIsChildOf(damageType, class'OnFireDamage'))
		&& InstigatedBy != Pawn)
		HandleAttack(FPSPawn(InstigatedBy));
	else
		Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
}

///////////////////////////////////////////////////////////////////////////
// When attacked
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;

	if ( (Other != Pawn) && (Damage > 0) )
	{
		PrintDialogue("ouch!");
		Say(AWCowBossPawn(MyPawn).myDialog.lGotHit,true,,true);
		HandleAttack(FPSPawn(Other));
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
	DangerPos = blipLoc;

	HandleAttack(CreatorPawn);

	StateChange=1;
	return;
}

///////////////////////////////////////////////////////////////////////////////
// Because animals are more simple, we can have a general 'startled' function
///////////////////////////////////////////////////////////////////////////////
function StartledBySomething(Pawn Meanie)
{
	if(Meanie != None)
		DangerPos = Meanie.Location;

	HandleAttack(FPSPawn(Meanie));
}

///////////////////////////////////////////////////////////////////////////
// Piss is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
	HandleAttack(Other);
}

///////////////////////////////////////////////////////////////////////////
// Gas is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function GettingDousedInGas(P2Pawn Other)
{
	HandleAttack(Other);
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

///////////////////////////////////////////////////////////////////////////////
// You're getting electricuted
///////////////////////////////////////////////////////////////////////////////
function GetShocked(P2Pawn Doer, vector HitLocation)
{
	if(MyPawn.Physics == PHYS_WALKING)
	{
		MakeShockerSteam(HitLocation,,true);
		HandleAttack(Doer);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Bumps when cowboss is not charging
///////////////////////////////////////////////////////////////////////////////
event StandBump(actor Other, optional out byte StateChange)
{
	local vector HitMomentum, HitLocation, Rot, dir;
	local FPSPawn otherpawn;
	local float fcheck, usedam, dot1;

	if(Other != None
		&& Other.Owner != Pawn)
	{
		TakeDamage(touchdnum, MyPawn, Other.Location, vect(0,0,1), touchdtype);
	}
	else if(PeoplePart(Other) != None
		|| (Pawn(Other) != None
			&& AWCowPawn(Other) == None)
		|| Projectile(Other) != None)
	{
		/*
		// Make sure it's in front of you before you hurt it
		Rot = vector(MyPawn.Rotation);
		dir = Other.location - MyPawn.location;
		dir.z=0;
		dir = Normal(dir);
		dot1 = Rot Dot dir;
		if(dot1 < BACK_KICK_DOT)
		{
			GotoState('KickBack');
			StateChange=1;
		}
		*/
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle bumps with other characters when we're angry and will hurt them
///////////////////////////////////////////////////////////////////////////////
function bool AngryBump(actor Other, float TouchDamage, float hitratio)
{
	local vector HitMomentum, HitLocation, Rot, dir;
	local FPSPawn otherpawn;
	local float fcheck, usedam, dot1;

	// Send this thing flying...
	HitMomentum = MyPawn.Velocity*MyPawn.Mass*hitratio;
	HitMomentum.z = 0;
	HitMomentum.z = VSize(HitMomentum)*(FRand()*0.3 + 0.5);

	// Kill normal bystander types instantly, the dude, cops, special
	// other characters and such, we just hurt some
	otherpawn = FPSPawn(Other);
	if(otherpawn != None
		&& otherpawn.Health > 0)
	{
		if(PersonPawn(otherpawn) != None
			&& !(otherpawn.bPlayer
				|| otherpawn.IsA('AuthorityFigure')
				|| otherpawn.bPersistent))
			usedam = otherpawn.Health;
		else
			usedam = TouchDamage;

		// Make sure it's in front of you before you hurt it
		Rot = vector(MyPawn.Rotation);
		dir = Other.location - MyPawn.location;
		dir.z=0;
		dir = Normal(dir);
		dot1 = Rot Dot dir;
		if(dot1 > FRONT_BUMP_DOT
			|| Other.CollisionRadius > MIN_SMALL_RADIUS)
		{
			Other.TakeDamage(usedam,
								MyPawn, Other.Location, HitMomentum, AWCowPawn(MyPawn).MyDamage);
			return true;
		}
		else if(otherpawn != None
			&& AnimalController(otherpawn.Controller) != None)
		{
			AnimalController(otherpawn.Controller).StartledBySomething(MyPawn);
			return true;
		}
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Remember when this happened and set the time to make more heads
///////////////////////////////////////////////////////////////////////////////
function NeedMoreHeads()
{
	TimeToMakeMoreHeads = Level.TimeSeconds + TimeWithoutHeads;
	bNeedMoreHeads=true;
}

///////////////////////////////////////////////////////////////////////////////
// You made a gary orbit head
///////////////////////////////////////////////////////////////////////////////
function MadeHead()
{
	bNeedMoreHeads=false;
}

///////////////////////////////////////////////////////////////////////////////
// You need more heads to spin around you
///////////////////////////////////////////////////////////////////////////////
function CheckToMakeMoreHeads(optional out byte StateChange)
{
	if(AWCowBossPawn(MyPawn) != None
		&& bNeedMoreHeads
		&& Level.TimeSeconds > TimeToMakeMoreHeads
		&& AWCowBossPawn(MyPawn).orbitheads.Length < HeadOrbitNum)
	{
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		if(bDoIntro)
			SetNextState('IntroStanding');
		else if(Attacker != None)
			SetNextState('AttackTarget');
		else
			SetNextState('Thinking');
		GotoStateSave('MakeAllHeads');
		StateChange=1;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Allow it to be counted when getting hit
///////////////////////////////////////////////////////////////////////////////
function bool DoCountAbsorbedDamage()
{
	return bAbsorbCount;
}
///////////////////////////////////////////////////////////////////////////////
// Do more absorbtion for counting to laugh
///////////////////////////////////////////////////////////////////////////////
function ResetAbsorb()
{
	bAbsorbCount=true;
	AWCowBossPawn(MyPawn).ResetAbsorb();
}

///////////////////////////////////////////////////////////////////////////////
// Call zombies to protect you as make more heads
///////////////////////////////////////////////////////////////////////////////
function CallZombies()
{
	TriggerEvent(ZombieSpawnerTag, None, MyPawn);
}

///////////////////////////////////////////////////////////////////////////////
// Laugh at them for shooting puny rockets at you
///////////////////////////////////////////////////////////////////////////////
function LaughAtAttacker()
{
	bAbsorbCount=false;
	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;
	if(Attacker != None)
		SetNextState('AttackTarget');
	else
		SetNextState('Thinking');
	GotoStateSave('DoLaughing');
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
	// Use the simple group of pathnodes gathered up the gameinfo to determine
	// a random point to walk to. The problem is we then have to test it
	// and handle not having it return a good path node every time--different
	// but more random than the engine.FindRandomDest.
	///////////////////////////////////////////////////////////////////////////
	function PathNode FindRandomPathNodeDest()
	{
		local PathNode usenode;

		if(PathList.node != None)
		{
			usenode = FindRandomNode(PathList.node, PathList.Length);
			if(FindPathToward(usenode) != None
				|| FastTrace(usenode.Location, MyPawn.Location))
				return usenode;
		}
		return None;
	}

	///////////////////////////////////////////////////////////////////////////
	// If we hate the player, find him and kill him
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local P2Player keepp;

		Super.BeginState();

		if(MyPawn.bPlayerIsEnemy)
		{
			keepp = GetRandomPlayer();
			if(keepp != None
				&& keepp.Pawn != None
				&& !keepp.Pawn.bDeleteMe
				&& keepp.Pawn.Health > 0)
			{
				HandleAttack(keepp.MyPawn);
			}
		}
	}
Begin:
//	if(Frand() < MOO_SOUND_FREQ)
//		AWCowPawn(MyPawn).PlayNormalMoo();

	CheckToMakeMoreHeads();

	if(Attacker != None)
	{
		SetEndGoal(Attacker, ATTACK_END_RADIUS);
		SetNextState('AttackTarget');
		GotoStateSave('WalkToAttacker');
	}

	if(Frand() < StandFreq)
	{
		SetNextState('Thinking');
		GotoStateSave('Standing');
	}
	// Walk to some random place, close by, that I can see (not through walls)
	if(!PickRandomDest())
		UseNearestPathNode(2048);
	SetNextState('Thinking');
	GotoStateSave('WalkToTarget');
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
	// Check for things hitting me in the butt
	///////////////////////////////////////////////////////////////////////////////
	function Bump(Actor Other)
	{
		local byte StateChange;
		StandBump(Other, StateChange);
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
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
		local vector dir, rot;

		PrintThisState();
		MyPawn.StopAcc();

		// face forwards
		Focus = None;
		rot = vector(MyPawn.Rotation);
		dir = MyPawn.Location + 100*rot;
		FocalPoint = dir;
	}
Begin:
	MyPawn.PlayAnimStanding();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand and say your intro, do this only once
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state IntroStanding extends Standing
{
	ignores LaughAtAttacker, DoCountAbsorbedDamage;

Begin:
	PrintDialogue("I'm am the mike j cow boss!");
	Say(AWCowBossPawn(MyPawn).myDialog.lgreeting,true,true);
	MyPawn.PlayAnimStanding();
	if(Attacker != None)
		SetNextState('AttackTarget');
	else
		SetNextState('Thinking');
	bDoIntro=false;
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand and look around
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DoLaughing extends Standing
{
	ignores LaughAtAttacker, DoCountAbsorbedDamage;

	function EndState()
	{
		// Make them take longer to laugh next time
		ResetAbsorb();
		Super.EndState();
	}
Begin:
	PrintDialogue("mahahah!");
	Say(AWCowBossPawn(MyPawn).myDialog.lLaughing,true,true);
	AWCowBossPawn(MyPawn).PlayAnimLaughing();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Spit out all your flying protector head
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state MakeAllHeads
{
	ignores HandleAttack, LaughAtAttacker, DoCountAbsorbedDamage;

	///////////////////////////////////////////////////////////////////////////////
	// Check for things hitting me in the butt
	///////////////////////////////////////////////////////////////////////////////
	function Bump(Actor Other)
	{
		local byte StateChange;
		StandBump(Other, StateChange);
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			// Make the full number of heads
			if(statecount < HeadOrbitNum
				&& AWCowBossPawn(MyPawn).orbitheads.Length < HeadOrbitNum)
				GotoState(GetStateName(), 'Begin');
			else
				GotoNextState();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local vector dir, rot;

		PrintThisState();
		MyPawn.StopAcc();

		statecount=0;
		// face forwards
		Focus = None;
		rot = vector(MyPawn.Rotation);
		dir = MyPawn.Location + 100*rot;
		FocalPoint = dir;
		// call for backup
		CallZombies();
		// Hurt the area around your center so as to throw off any dervish cats currently
		// attacking you
		MyPawn.HurtRadius(START_HEADS_DAMAGE, MyPawn.CollisionRadius, class'P2Damage', 0, MyPawn.Location);
	}
Begin:
	AWCowBossPawn(Mypawn).PlayAnimSpitHead();
	statecount++;
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
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();

		if(Frand() < MoanFreq)
		{
			PrintDialogue("Moaning");
			Say(AWCowBossPawn(MyPawn).myDialog.lHmm,true,true);
		}
		else if(Frand() < TouretteFreq)
		{
			PrintDialogue("tourettes");
			Say(AWCowBossPawn(MyPawn).myDialog.lGenericAnswer,true,true);
		}

		HandleStasisChange();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Move to the left or right, if we notice we're hung up, when we should be 
	// moving
	///////////////////////////////////////////////////////////////////////////////
	function DodgeThinWall()
	{
		local vector startdir, usevect;

		// If we're stopped or in the same spot.
		if(VSize(Pawn.Velocity) < MIN_VELOCITY_FOR_REAL_MOVEMENT)
		{
			LegMotionCaughtCount++;
			if(LegMotionCaughtCount > LEG_MOTION_CAUGHT_MAX)
				NextStateAfterGoal();
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// If hit by a running human, then ramage
	///////////////////////////////////////////////////////////////////////////////
	event Bump(actor Other)
	{
		local vector HitMomentum, HitLocation;
		local P2Pawn otherpawn;
		local float fcheck;
		local byte StateChange;

		StandBump(Other, StateChange);
		
		if(StateChange == 0)
		{
			otherpawn = P2Pawn(Other);

			if(otherpawn != None)
			{
				if(!otherpawn.bIsWalking)
					HandleAttack(otherpawn);
			}
		}
	}
	
	function BeginState()
	{
		MyPawn.ChangeAnimation();
		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToAttacker extends WalkToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// When you're moving towards your attacker and you reach them, end it now
	///////////////////////////////////////////////////////////////////////////////
	function Bump(Actor Other)
	{
		StandBump(Other);
		If(Other == Attacker)
			GotoStateSave('AttackTarget');
		else
			Super.Bump(Other);
	}
	function Touch(Actor Other)
	{
		StandBump(Other);
		If(Other == Attacker)
			GotoStateSave('AttackTarget');
		else
			Super.Touch(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to chase after your hero more often here
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super(LambController).InterimChecks();
		// If they aren't viable, stop attacking
		if(Attacker == None
			|| Attacker.bDeleteMe
			|| Attacker.Health <= 0)
			GotoStateSave('Thinking');
		// If you can see them, attack
		else if(MyPawn.FastTrace(Attacker.Location, MyPawn.Location))
			GotoStateSave('AttackTarget');
//		// If you can't see, think about running some
		else// if(FRand() < MyPawn.ChargeFreq)
		{
			bPreserveMotionValues=true;
			SetEndGoal(Attacker, ATTACK_END_RADIUS);
			GotoStateSave('WalkToAttacker');
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		FPSPawn(Pawn).PathCheckTimeActor = FPSPawn(Pawn).default.PathCheckTimeActor;
		FPSPawn(Pawn).PathCheckTimePoint = FPSPawn(Pawn).default.PathCheckTimePoint;
		Super.EndState();
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// Do more internal checks when moving like this
		FPSPawn(Pawn).PathCheckTimeActor = FRand()*WalkAttackTimeHalf + WalkAttackTimeHalf;
		FPSPawn(Pawn).PathCheckTimePoint = FPSPawn(Pawn).PathCheckTimeActor;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AttackTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AttackTarget extends Standing
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function DecideAttack()
	{
		local byte StateChange;
		local float dist;

		if(Attacker != None
			&& !Attacker.bDeleteMe
			&& Attacker.Health > 0)
		{
			CheckToMakeMoreHeads(StateChange);

			if(StateChange == 0)
			{
				dist = VSize(Attacker.Location - MyPawn.Location);
				if(dist > MyPawn.AttackRange.Min)
				{
					if(FRand() < AttackFreq)
					{
						if(FRand() < LeftShotFreq)
						{
							GotoStateSave('ShootWithLeft');
							StateChange=1;
						}
						else if(FRand() < RightShotFreq)
						{
							GotoStateSave('ShootWithRight');
							StateChange=1;
						}
						else if(FRand() < TeatShootFreq)
						{
							GotoStateSave('DoTeatShoot');
							StateChange=1;
						}
					}

					if(StateChange == 0)
					{
						if(FRand() < 0.5)
						{
							if(!PickRandomDest())
								UseNearestPathNode(2048);
							SetNextState('AttackTarget');
							GotoStateSave('WalkToTarget');
						}
						else
						{
							SetNextState('AttackTarget');
							SetEndGoal(Attacker, ATTACK_END_RADIUS);
							GotoStateSave('WalkToAttacker');
						}
					}
				}
				else
				{
					SetNextState('AttackTarget');
					SetEndGoal(Attacker, ATTACK_END_RADIUS);
					GotoStateSave('WalkToAttacker');
				}
			}
		}
		else
		{
			SetAttacker(None);
			GotoStateSave('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	Focus = Attacker;
//	FinishRotation();
	DecideAttack();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AttackBase
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AttackBase
{
	ignores LaughAtAttacker, DoCountAbsorbedDamage;

	///////////////////////////////////////////////////////////////////////////////
	// Check for things hitting me in the butt
	///////////////////////////////////////////////////////////////////////////////
	function Bump(Actor Other)
	{
		local byte StateChange;
		StandBump(Other, StateChange);
	}
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		local byte StateChange;

		// Check for the base channel only
		if(channel == 0)
		{
			GotoStateSave('AttackTarget');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Focus = Attacker;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
	}
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootWithRight
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootWithRight extends AttackBase
{
Begin:
	PrintDialogue("catch this!");
	Say(AWCowBossPawn(MyPawn).myDialog.lWhileFighting,true,true);
	AWCowBossPawn(MyPawn).PlayAnimRightShoot();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootWithLeft
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootWithLeft extends AttackBase
{
Begin:
	PrintDialogue("catch this!");
	Say(AWCowBossPawn(MyPawn).myDialog.lWhileFighting,true,true);
	AWCowBossPawn(MyPawn).PlayAnimLeftShoot();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DoTeatShoot
// Shoot diseased milk out of your four teats in your utter
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DoTeatShoot extends AttackBase
{
Begin:
	Focus = Attacker;
	PrintDialogue("teat shot!");
	Say(AWCowBossPawn(MyPawn).myDialog.ltrashtalk,true,true);
	AWCowBossPawn(MyPawn).PlayAnimTeatShoot();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     RunDamage=50.000000
     ChargeDamage=50.000000
     HeadOrbitNum=6.000000
     touchdnum=10.000000
     touchdtype=Class'BaseFX.BurnedDamage'
     StandFreq=0.500000
     WalkAttackTimeHalf=1.000000
     AttackFreq=0.500000
     LeftShotFreq=0.300000
     RightShotFreq=0.300000
     TeatShootFreq=0.300000
     TimeWithoutHeads=15.000000
     bNeedMoreHeads=True
     bAbsorbCount=True
     MoanFreq=0.400000
     TouretteFreq=0.500000
     ZombieSpawnerTag="cowbosszombies"
}
