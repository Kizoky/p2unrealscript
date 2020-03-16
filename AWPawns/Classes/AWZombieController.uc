///////////////////////////////////////////////////////////////////////////////
// AWZombieController
// Copyright 2004 RWS, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWZombieController extends LambController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var AWZombie	ZPawn;		// local zombie pawn version of Pawn variable
var FPSPawn	PlayerAttackedMe;// If the player attacked me, mark it in SetAttacker. Then look at this
							// again, so we can go hunt him down, when we're done with our old attacker
var	FPSPawn	OldAttacker;	// Remember who last hurt you, even though you may be thinking
var float	LevelSayTime;		// Time you started talking in the level
var float	SayLengthTime;		// Length of time you need to talk for in seconds
var bool	bDidPlead;
var bool	bIncreaseAttackSpeed;	// Bump up the attack speed during special situations, 
									// reduce as soon as it's used
var float   AttackSpeedMult;		// how much
var AWZombie WaitingZombie;		// guy waiting on us

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const ATTACK_UPDATE_MIN_TIME	=	0.1;
const CLOSE_VOMIT_RATIO			=	0.25;
const FLYING_DOWN_CHECK			=	1000;
const FLYING_DOWN_RANGE			=	130;
const FLYING_DOWN_END_RADIUS	=	30;
const FLYING_DOWN_SINK_SIZE		=	0;
const HERO_END_RADIUS			=	300;
const HANG_AROUND_HERO			=	350;
const ENEMY_CHECK				=	1000;

const PLEAD_END_RADIUS			=	80;
const PLEAD_TIME				=	30;
const NO_PLEAD_TIME				=	50;

const STAND_TIME				=	1.0;

const DIFF_CHANGE_ANIM_SPEED    =   0.09;

const DODGE_DIST				=   200;

const REPORT_LOOKS_SLEEP_TIME = 1.0;
var array<P2Pawn> RadarPawns;		// dummy var
var byte  RadarInDoors;				// dummy var

///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	// Set Report Looks Timer
	SetTimer(1.0, false);
}

// Report Looks Timer
// We're a fukkin' zombie - we wanna make sure everyone around us knows about it!
event Timer()
{
	// Only report if not dead or being destroyed
	if (!Pawn.IsInState('Dying'))
		P2Pawn(Pawn).ReportPlayerLooksToOthers(RadarPawns, False, RadarInDoors);
}

///////////////////////////////////////////////////////////////////////////////
// Possess the pawn
///////////////////////////////////////////////////////////////////////////////
function Possess(Pawn aPawn)
{
	Super(LambController).Possess(aPawn);

	ZPawn = AWZombie(Pawn);
	
	if(ZPawn == None)
		PrintStateError("Possess: ZPawn is None");

	ZPawn.SetMovementPhysics();
	
	if(ZPawn.bFloating)
		ZPawn.SetPhysics(PHYS_Flying);
	else if (ZPawn.Physics == PHYS_Walking)
		ZPawn.SetPhysics(PHYS_Falling);

	MyNextLabel='Begin';
	OldEndPoint = ZPawn.Location;

	PersonalSpace = (1.5*ZPawn.CollisionRadius) + (FRand()*(3.3*ZPawn.CollisionRadius));

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
		// Make zombies slightly faster animating as the difficulty increases
		ZPawn.GenAnimSpeed+= (diffoffset*DIFF_CHANGE_ANIM_SPEED);
		ZPawn.DefAnimSpeed = ZPawn.GenAnimSpeed;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Unhook us from our hero
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	UnhookHero();

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Called before this pawn is "teleported" with the player so it can save
// essential information that will later be passed to PostTeleportWithPlayer().
///////////////////////////////////////////////////////////////////////////////
function PreTeleportWithPlayer(out FPSGameState.TeleportedPawnInfo info, P2Pawn PlayerPawn)
{
	//log(ZPawn$" tried to send me ");
	Super.PreTeleportWithPlayer(info, PlayerPawn);

	// Check if player should be considered enemy
	if((Attacker != None 
		&& Attacker.bPlayer)
			|| ZPawn.bPlayerIsEnemy)
		info.bPlayerIsEnemy = true;
	else
		info.bPlayerIsEnemy = false;

	// Save friends
	info.bPlayerIsFriend = ZPawn.bPlayerIsFriend;

	// Check if the player is a hero
	if(Hero != None
		&& Hero.bPlayer)
	{
		info.bPlayerIsHero=true;
		// If we're too far away from the player, modify our offset
		if(VSize(info.Offset) > class'Telepad'.default.TravelRadius)
		{
			info.Offset = class'Telepad'.default.TravelRadius*Normal(info.Offset);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called after this pawn was "teleported" with the player so it can restore
// itself using the previously-saved information.  See PreTeleportWithPlayer().
///////////////////////////////////////////////////////////////////////////////
function PostTeleportWithPlayer(FPSGameState.TeleportedPawnInfo info, P2Pawn PlayerPawn)
{
	//log(Self$" post teleport");
	Super.PostTeleportWithPlayer(info, PlayerPawn);

	if (info.bPlayerIsEnemy)
		SetToAttackPlayer(PlayerPawn);

	// Rehook up the player if he was our hero
	if(info.bPlayerIsHero)
	{
		HookHero(PlayerPawn);
	}

	// Set our hero love
//	HeroLove=0;
//	ChangeHeroLove(info.FloatVal1, HERO_LOVE_START_TIME);
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
// Face the direction we are and be ready to kill someone
///////////////////////////////////////////////////////////////////////////////
function SetToTurret()
{
	ZPawn.SetMood(MOOD_Angry, 1.0);
	// Make sure he never tries for cover
	ZPawn.WillUseCover=0.0;
	SetNextState('ActAsTurret');
}

///////////////////////////////////////////////////////////////////////////////
// Find a player and kick his butt
///////////////////////////////////////////////////////////////////////////////
function SetToAttackPlayer(FPSPawn PlayerP)
{
	local FPSPawn keepp;

	// When we get triggered, we attack the player.

	if(PlayerP == None)
		keepp = GetRandomPlayer().MyPawn;
	else
		keepp = PlayerP;

	// check for some one to attack
	if(keepp != None)
	{
		AttackThisNow(keepp);
		if(!ZPawn.bStartMissingLegs)
			SetNextState('AttackTarget');
	}
}
///////////////////////////////////////////////////////////////////////////////
// Find a closet actor with this tag (should be a pawn) and kick his butt
///////////////////////////////////////////////////////////////////////////////
function SetToAttackTag(Name AttackTag)
{
	local FPSPawn AttackHim;

	AttackHim = FPSPawn(FindNearestActorByTag(AttackTag));

	// check for some one to attack
	if(AttackHim != None)
	{
		AttackThisNow(AttackHim);
		if(!ZPawn.bStartMissingLegs)
			SetNextState('AttackTarget');
	}
}
///////////////////////////////////////////////////////////////////////////////
// Run screaming from where you are
///////////////////////////////////////////////////////////////////////////////
function SetToPanic()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Find a player and be scared of him
///////////////////////////////////////////////////////////////////////////////
function SetToBeScaredOfPlayer(FPSPawn PlayerP)
{
	// STUB
}
///////////////////////////////////////////////////////////////////////////////
// Find a closet actor with this tag (should be a pawn) and be scared of him
///////////////////////////////////////////////////////////////////////////////
function SetToBeScaredOfTag(Name RunTag)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Make pawns start dead and at the end of a given animation
///////////////////////////////////////////////////////////////////////////////
function SetToDead()
{
	ZPawn.TakeDamage(ZPawn.HealthMax, None, ZPawn.Location, vect(0, 0, 1), class'P2Damage');
	SetNextState('Destroying');
}

///////////////////////////////////////////////////////////////////////////////
// Start patrolling your PatrolNodes.
///////////////////////////////////////////////////////////////////////////////
function SetToPatrolPath()
{
	if(ZPawn.PatrolNodes.Length > 0)
	{
		// Only reset the patrol tag if it's over
		if(ZPawn.PatrolI > ZPawn.PatrolNodes.Length)
			ZPawn.PatrolI=0;
		SetEndGoal(ZPawn.PatrolNodes[ZPawn.PatrolI], DEFAULT_END_RADIUS);
	}
	else
		PickRandomDest();

	//log(ZPawn$" SetToPatrolPath end goal"$EndGoal);
	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;
	SetNextState('PatrolToTarget');
}

///////////////////////////////////////////////////////////////////////////////
// Find the next point to walk to
///////////////////////////////////////////////////////////////////////////////
function PathNode GetNextPatrolEndPoint()
{
	local int currI;

	currI = ZPawn.PatrolI;

	// loop when you get the end.
	ZPawn.PatrolI++;
	if(ZPawn.PatrolI >= ZPawn.PatrolNodes.Length)
	{
		ZPawn.PatrolI = 0;
	}

	//log(ZPawn$" now picking "$ZPawn.PatrolNodes[currI]$" to walk to, tag is "$ZPawn.PatrolNodes[currI].Tag);

	return ZPawn.PatrolNodes[currI];
}

///////////////////////////////////////////////////////////////////////////////
// end: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Determine if he's allowed to see the weapon fall, may have no legs, etc,
// then we wouldn't want him to go after it.
///////////////////////////////////////////////////////////////////////////////
function bool SeeWeaponDrop(P2WeaponPickup grabme)
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Certain weapons, like the sledge pickup, can fall and tell all zombies
// around it, about this, with the hopes that they will run and pick 
// it up. They won't then use it, they'll simply grab it from the player.
///////////////////////////////////////////////////////////////////////////////
function WeaponDropped(P2WeaponPickup grabme)
{
	if(grabme != None
		&& !grabme.bDeleteMe)
	{
		SetEndGoal(grabme, grabme.CollisionRadius);
		EndPoint = grabme.Location;
		Focus = grabme;
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		SetNextState('TryWeaponGrab');
		GotoStateSave('RunToWeapon');
	}
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
		SetNextState('AttackTarget');
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
		GotoStateSave('AttackTarget');
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
// Print out what the dialogue should say, with who said it
///////////////////////////////////////////////////////////////////////////////
function PrintDialogue(String diastr)
{
	if(P2GameInfo(Level.Game).LogDialog == 1)
		log(self$"---------------------------"$ZPawn$" says: "$diastr);
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

		SayLengthTime = ZPawn.Say(line, bImportant);
		return SayLengthTime;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Say the number
// bPureNumbers means don't say things like 'a' for '1', say '1', so you
// can say "i'll take a number 1, please"
///////////////////////////////////////////////////////////////////////////////
function float SayThisNumber(int NumberToSay, optional bool bPureNumbers, optional bool bImportant, 
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

		SayLengthTime = ZPawn.SayThisNumber(NumberToSay, bPureNumbers, bImportant);
		return SayLengthTime;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Cat's and the like don't hurt people by jumping on them
///////////////////////////////////////////////////////////////////////////////
function BaseChange()
{
	local float decorMass;
	
	if ( ZPawn.bInterpolating 
		|| ZPawn.bFloating)
		return;
	if ( (ZPawn.base == None) 
		&& (ZPawn.Physics == PHYS_None))
		ZPawn.SetPhysics(PHYS_Falling);
	else if( PeoplePart(ZPawn.Base) != None)
	{
		ZPawn.JumpOffPawn();
	}
	// Pawns can only set base to non-pawns, or pawns which specifically allow it.
	// Otherwise we do some damage and jump off.
	else if ( Pawn(ZPawn.Base) != None )
	{	
		if ( !Pawn(ZPawn.Base).bCanBeBaseForPawns )
		{
			ZPawn.JumpOffPawn();
		}
	}
	else if ( (Decoration(ZPawn.Base) != None) && (ZPawn.Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(ZPawn.Base).Mass, 1);

		// NPC's can still crush other things
		ZPawn.Base.TakeDamage((-2* ZPawn.Mass/decorMass * ZPawn.Velocity.Z/400), ZPawn, 
								ZPawn.Location, 0.5 * ZPawn.Velocity, class'Crushed');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Used only for AIScripts, make sure the ZPawn gets cleared too
///////////////////////////////////////////////////////////////////////////////
function PendingStasis()
{
	Super.PendingStasis();
	ZPawn = None;
}

///////////////////////////////////////////////////////////////////////////////
// In the pissing state, say pissing is valid, only then
///////////////////////////////////////////////////////////////////////////////
function bool PissingValid()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Determines how much a threat to the player this pawn is
///////////////////////////////////////////////////////////////////////////////
function float DetermineThreat()
{
	return 0.0;
}

///////////////////////////////////////////////////////////////////////////////
// You've just caught on fire.. how do you feel about it?
///////////////////////////////////////////////////////////////////////////////
function CatchOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
	ZPawn.SetOnFire(Doer, bIsNapalm);

//	GotoState('ImOnFire');
}

///////////////////////////////////////////////////////////////////////////////
// Trigger functionality:
// If you set InitAttackTag and they have a weapon, they'll attack that pawn,
// otherwise, it goes back to the super (to attack the player or run)
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, Pawn EventInstigator )
{
	local FPSPawn keepp, PlayerP;

	if(//ZPawn.bHasViolentWeapon
		//&& 
		ZPawn.InitAttackTag != '')
	{
		SetToAttackTag(ZPawn.InitAttackTag);
		GotoNextState();
	}
	else
		Super.Trigger(Other, EventInstigator);
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

	if(ClassIsChildOf(bliphere, class'DesiredThingMarker'))
	{
	//	CheckDesiredThing(OriginActor, bliphere);
	}
	else if(bliphere == class'DeadCatHitGuyMarker')
	{
	// stub
	}
	else if(bliphere == class'HeadExplodeMarker')
	{
	// stub
	}
	else if(ClassIsChildOf(bliphere, class'DeadBodyMarker'))
	{
	// stub
	}
	else if(blipLoc != Pawn.Location)
	{
		GetReadyToReactToDanger(bliphere, CreatorPawn, OriginActor, blipLoc);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Local spot to set my attacker, only assigns old when not none.
///////////////////////////////////////////////////////////////////////////////
function SetAttacker(FPSPawn NewAttacker)
{
	if(Attacker != NewAttacker)
	{
		//  Save our old one
		if(Attacker != None)
			OldAttacker = Attacker;

		Attacker = NewAttacker;
		
		if(Attacker != None)
		{
			if(Attacker.bPlayer)
				PlayerAttackedMe=Attacker;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// ThrowWeapon()
// Throw out current weapon, and switch to a new weapon
///////////////////////////////////////////////////////////////////////////////
function ThrowWeapon()
{
	if( ZPawn.Weapon==None || !ZPawn.Weapon.bCanThrow )
		return;
	// If you've tossed out your weapons, then there's no way you can
	// do distance-based weapon changing, so reset it
	ZPawn.WeapChangeDist = 0;
	ZPawn.Weapon.bTossedOut = true;
	ZPawn.TossWeapon(Vector(Rotation) * 500 + vect(0,0,220));
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function LimbChoppedOff(P2Pawn Doer, vector HitLocation)
{
	if(ZPawn.Physics == PHYS_WALKING
		|| ZPawn.Physics == PHYS_FLYING)
	{
		AttackThisNow(Doer, true);

		// Drop things if you had them in your hands
		ZPawn.DropBoltons(ZPawn.Velocity);
		
		// drop your weapon too--you're not getting up from this
		ThrowWeapon();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Do live ragdoll
///////////////////////////////////////////////////////////////////////////////
function DoLiveRagdoll()
{
	GotoStateSave('RagdollWait');
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function RestartAfterUnRagdollWait()
{
	if(ZPawn.bMissingLegParts)
	{
		ZPawn.ShouldDeathCrawl(true);
		ZPawn.ChangeAnimation();
	}
	GotoState('RagdollWait');
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function RestartAfterUnRagdoll()
{
	if(ZPawn.bMissingLegParts)
	{
		ZPawn.ShouldDeathCrawl(true);
		GotoState('Thinking');
	}
	else
	{
		GotoState('StandUpUnRagdoll');
	}
}

///////////////////////////////////////////////////////////////////////////////
// We *were* attacking the player, so now go looking to attack him again
///////////////////////////////////////////////////////////////////////////////
function GoAfterPlayerAgain()
{
	AttackThisNow(PlayerAttackedMe);
}

///////////////////////////////////////////////////////////////////////////
// Ignore this function when we're already attacking the guy
///////////////////////////////////////////////////////////////////////////
function StartAttacking()
{
	GotoStateSave('AttackTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SaveNewAttacker(FPSPawn AttackMe)
{
	if(AttackMe != None
		&& Hero != AttackMe)
	{
		ZPawn.SetMood(MOOD_Angry, 1.0);
		InterestPawn = AttackMe;
		SetAttacker(AttackMe);
		DangerPos = AttackMe.Location;
		ZPawn.DropBoltons(ZPawn.Velocity);
	}
}

///////////////////////////////////////////////////////////////////////////////
// True if it's okay to attack this zombie
///////////////////////////////////////////////////////////////////////////////
function bool AllowZombieAttack(AWZombie AttackMe)
{
	return (AttackMe == None
			|| (AWZombieController(AttackMe.Controller) != None
				&& (AWZombieController(AttackMe.Controller).Attacker == None
					|| AWZombieController(AttackMe.Controller).Attacker == ZPawn
					|| AWZombieController(AttackMe.Controller).Attacker == Hero)));
}

///////////////////////////////////////////////////////////////////////////////
// True if it's okay to attack the cowboss
///////////////////////////////////////////////////////////////////////////////
function bool AllowCowBossAttack(AWCowBossPawn AttackMe)
{
	return (AttackMe == None
			|| (Hero != None));
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function AttackThisNow(FPSPawn AttackMe, optional bool bForce,
					   optional out byte StateChange)
{
	UpdateFloatTime();

	//log(Self$" attack this now "$attackme$" bforce "$bforce);
	if((AttackMe != None
			// Can't attack my master
			&& AttackMe != Hero
			&& Attacker == None
			&& AttackMe != Attacker
			&& AttackMe != ZPawn
			// Don't attack other zombies unless they are specifically attacking you
			// or attacking your master
			&& AllowZombieAttack(AWZombie(AttackMe))
			&& AllowCowBossAttack(AWCowBossPawn(AttackMe))
			// Ignore head eating dogs, they only eat decapped heads, so they're fine
			&& AWHeadDogPawn(AttackMe) == None)
		|| bForce)
	{
		SaveNewAttacker(AttackMe);

		//log(self$" going after "$Attacker$" missing legs "$ZPawn.bMissingLegParts);
		// If we weren't attacking before, be suprised
		// Don't do this if you're floating
		if((!ZPawn.bMissingLegParts)
			&& OldAttacker == None)
			GotoStateSave('RecognizeAttacker');
		else // otherwise, start right into it
		{
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('AttackTarget');
			// If we're a turret, go to a special state first
			if(ZPawn.PawnInitialState == ZPawn.EPawnInitialState.EP_Turret)
			{
				if(ZPawn.bMissingLegParts)
				{
					SetNextState('TurretWait');
					GotoStateSave('PrepToCrawl');
				}
				else
					GotoStateSave('TurretWait');
			}
			// If we can move
			else if(ZPawn.bMissingLegParts
				&& !ZPawn.bFloating)
			{
				SetEndGoal(Attacker, DEFAULT_END_RADIUS);
				if(!ZPawn.bIsDeathCrawling
					&& !ZPawn.bWantsToDeathCrawl)
				{
					SetNextState('CrawlToAttacker');
					GotoStateSave('PrepToCrawl');
				}
				else
					GotoStateSave('CrawlToAttacker');
			}
			else
				GotoStateSave('WalkToAttacker');
		}
		StateChange=1;
	}
}

///////////////////////////////////////////////////////////////////////////
// When attacked
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	if(Damage > 0)
	{
		if(ZPawn.bHasHead)
		{
			PrintDialogue("Ouch!");
			Say(ZPawn.myDialog.lGotHit,true,,true);
		}
		else
		{
			PrintDialogue("Gurgle.. Ouch!");
			if(Say(ZPawn.myDialog.lSpitting,true,,true) > 0)
				ZPawn.DoNeckGurgle();
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
	if(ZPawn.bIgnoresSenses
		|| ZPawn.bIgnoresHearing)
		return;

	//log(Self$" get ready to react to danger "$creatorpawn$" attacker "$Attacker);
	if(Attacker == None)
		AttackThisNow(CreatorPawn, , StateChange);
	return;
}

///////////////////////////////////////////////////////////////////////////////
// Decide how to handle being attacked or having a limb cut off
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, 
					   class<DamageType> damageType, vector Momentum)
{
	local vector dir;
	local vector X, Y, Z;
	local bool bLimbCut, bCanAttackZombie;

	UpdateFloatTime();

	if(Damage > 0)
		damageAttitudeTo(instigatedBy, Damage);

	if(Damage > 0)
	{
		bCanAttackZombie = AllowZombieAttack(AWZombie(InstigatedBy));

		if ( InstigatedBy != Pawn
			&& bCanAttackZombie
			&& AllowCowBossAttack(AWCowBossPawn(InstigatedBy)))
		{
			// If a limb just got cut off, have him reset his attacker
			// and decide to fall to the ground or not.
			if(ClassIsChildOf(damageType, class'ScytheDamage')
				|| ClassIsChildOf(damageType, class'MacheteDamage'))
			{
				bLimbCut=true;
				LimbChoppedOff(P2Pawn(InstigatedBy), hitlocation);
			}

			// Attack every thing that hurts us, each time, unless it's another zombie
			// that doesn't want to hurt us.
			// If a zombie attacked us and we're not attacking him, reset our
			// attacker
			if(Attacker != InstigatedBy
				&& bCanAttackZombie)
				SetAttacker(None);

			// If we're already on the ground then only have a single anim
			// reaction to a hit, otherwise, go into a special state to react
			// to the hit
			if(ZPawn.bWantsToDeathCrawl
				|| ZPawn.bIsDeathCrawling
				|| ZPawn.bBlendTakeHit
				|| bLimbCut)
				AttackThisNow(FPSPawn(InstigatedBy));
			else // figure out the vague direction of the attack and 
				// make an anim play
			{
				AttackThisNow(FPSPawn(InstigatedBy));
				GetAxes(ZPawn.Rotation,X,Y,Z);
				Dir = Normal(HitLocation - ZPawn.Location);
				if ( (Dir Dot X) < 0 )
				{
					ZPawn.PlayAnimHitBackBlend();
					//GotoStateSave('RecoilBack');
				}
				else if(Dir Dot Y > 0)
				{
					ZPawn.PlayAnimHitRightBlend();
					//GotoStateSave('RecoilRight');
				}
				else
				{
					ZPawn.PlayAnimHitLeftBlend();
					//GotoStateSave('RecoilLeft');
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// Just attack whoever is pissing on you, don't care otherwise
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
	//ZPawn.BodyJuiceSquirtedOnMe(Other, bPuke);
	if(Attacker == None)
		AttackThisNow(Other);
}

///////////////////////////////////////////////////////////////////////////
// A bouncing, disembodied head (or dead body) just hit us, decide what to do
///////////////////////////////////////////////////////////////////////////
function GetHitByDeadThing(Actor DeadThing, FPSPawn KickerPawn)
{
}

///////////////////////////////////////////////////////////////////////////
// A rocket is chasing me! Run!
///////////////////////////////////////////////////////////////////////////
function RocketIsAfterMe(FPSPawn Shooter, Actor therocket)
{
}

///////////////////////////////////////////////////////////////////////////
// Gas is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function GettingDousedInGas(P2Pawn Other)
{
	if(Attacker == None)
		AttackThisNow(Other);
}

///////////////////////////////////////////////////////////////////////////////
// Someone might have shouted get down, said hi, or asked for money.. see what to do
// Go to state to see if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function RespondToTalker(Pawn Talker, Pawn AttackingShouter, ETalk TalkType, out byte StateChange)
{
	if(Attacker == None)
		AttackThisNow(FPSPawn(Talker), , StateChange);
}

///////////////////////////////////////////////////////////////////////////////
// If bumped or touched
///////////////////////////////////////////////////////////////////////////////
event Bump(actor Other)
{
	if(Attacker == None)
		AttackThisNow(FPSPawn(Other));
}
event Touch(actor Other)
{
	if(Attacker == None)
		AttackThisNow(FPSPawn(Other));
}

///////////////////////////////////////////////////////////////////////////////
// An animal caller is trying to get you to come to it
// Dogs that have you as their enemy will go after food only, and then keep
// attacking you. Eventually, however you can win them over.
///////////////////////////////////////////////////////////////////////////////
function RespondToAnimalCaller(FPSPawn Thrower, Actor Other, out byte StateChange)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// You're getting electricuted
///////////////////////////////////////////////////////////////////////////////
function GetShocked(P2Pawn Doer, vector HitLocation)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Look at the pawn telling you about him
///////////////////////////////////////////////////////////////////////////////
function ObservePawn(FPSPawn LookAtMe)
{
	if(Attacker == None)
	{
		if(CanSeePawn(ZPawn, LookAtMe))
			AttackThisNow(LookAtMe);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Babble incoherently, should blend from pelvis up
///////////////////////////////////////////////////////////////////////////////
function DoTourettes(optional out byte StateChange)
{
	if(ZPawn.bHasHead
		&& FRand() < ZPawn.TouretteFreq)
	{
		// If you're not saying something else, then you may tourette
		if(SayLengthTime + LevelSayTime < Level.TimeSeconds)
		{
			ZPawn.PlayAnimTourettes();
			PrintDialogue("Crazy talk");
			Say(ZPawn.myDialog.lGenericAnswer,true,,true);
			StateChange = 1;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function StartInHalf()
{
}

///////////////////////////////////////////////////////////////////////////////
// Set new target and pick path
///////////////////////////////////////////////////////////////////////////////
function SetActorTarget(Actor Dest, optional bool bStrictCheck)
{
	local Actor DestResult;

	if(ZPawn.bFloating)
	{
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
		}
		else
		{
			DestResult = FindPathToward(Dest);
			MoveTarget = DestResult;
		}
		// If it failed, move him straight there
		if(MoveTarget == None) 
		{
			DestResult=Dest;
			MoveTarget=DestResult;
		}

		if(!bDontSetFocus)
			Focus = MoveTarget;

		// If we're heading to our target, then make it the end radius,
		// otherwise, pick the normal collision radius
		if(MoveTarget == Dest)
			UseEndRadius = EndRadius;
		else
			UseEndRadius = MoveTarget.CollisionRadius;

		CheckForObstacles();
	}
	else
		Super.SetActorTarget(Dest, bStrictCheck);
}

///////////////////////////////////////////////////////////////////////////////
// Set new target point and pick path
///////////////////////////////////////////////////////////////////////////////
function SetActorTargetPoint(vector DestPoint, optional bool bStrictCheck)
{
	local Actor DestResult;

	if(ZPawn.bFloating)
	{
		bMovePointValid = false;
		MoveTarget=None;

		if(PointReachable(DestPoint))
		{
			MovePoint = DestPoint;
			bMovePointValid = true;
			UseEndRadius = EndRadius;
		}
		else
		{
			DestResult = FindPathTo(DestPoint);
			MoveTarget = DestResult;
			if(MoveTarget != None)
				UseEndRadius = MoveTarget.CollisionRadius;
		}
		// Still failed, so move him there straightaway
		if(!bMovePointValid
			&& MoveTarget == None)
		{
			MovePoint = DestPoint;
			bMovePointValid = true;
			UseEndRadius = EndRadius;
		}

		if(!bDontSetFocus)
		{
			if(MoveTarget == None)
			{
				FocalPoint = DestPoint;
				Focus = None;
			}
			else
				Focus = MoveTarget;
		}
		// Check for things in the way
		CheckForObstacles();
	}
	else
		Super.SetActorTargetPoint(DestPoint, bStrictCheck);
}
///////////////////////////////////////////////////////////////////////////////
// We're too high
///////////////////////////////////////////////////////////////////////////////
function FindGroundAgain(optional out byte StateChange)
{
	local vector endpt, hitlocation, hitnormal;
	local Actor HitActor;

	// Trace down and find the ground first
	endpt = ZPawn.Location;
	endpt.z -= FLYING_DOWN_CHECK;
	HitActor = ZPawn.Trace(HitLocation, HitNormal, endpt, ZPawn.Location, true);
	HitLocation.z-=FLYING_DOWN_SINK_SIZE;

	if(HitActor != None
		&& (ZPawn.Location.z - HitLocation.z) > FLYING_DOWN_RANGE)
	{
		StateChange=1;
		if(Attacker != None
			&& !Attacker.bDeleteMe)
			SetNextState('AttackTarget');
		else
			SetNextState('Thinking','DecideNow');
		SetEndPoint(HitLocation, FLYING_DOWN_END_RADIUS);
		GotoStateSave('WalkToTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
// The player is our hero. We can only have one hero, but the player
// can have multiple dog friends.
///////////////////////////////////////////////////////////////////////////////
function SetPlayerAsHero(FPSPawn PlayerPawn)
{
	local AWPlayer awp;

	// Link the two up
	if(PlayerPawn != None
		&& Hero == None)
	{
		Hero = PlayerPawn;
		ZPawn.HeroTag = Hero.Tag;
		// Make him your friend
		ZPawn.bPlayerIsFriend=true;
		// Make him not your enemy anymore.
		ZPawn.bPlayerIsEnemy=false;

		awp = AWPlayer(PlayerPawn.Controller);
		if(awp != None)
		{
			awp.AddAWFriend(ZPawn);
			//log(self$" player is now our hero !");
			// Add me to the list of pawns that should be destroyed
			// in our original levels, because we're now travelling with the dude
			if(P2GameInfoSingle(Level.Game) != None
				&& P2GameInfoSingle(Level.Game).TheGameState != None)
				P2GameInfoSingle(Level.Game).TheGameState.AddPersistentPawn(ZPawn);
			// Link the player to them, so they don't get effected by catnip time
			FPSPawn(Pawn).bIgnoreTimeDilation=true;
			// Keep him around in special cases
			ZPawn.bCanTeleportWithPlayer=true;
			ZPawn.bKeepForMovie=false;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set our new hero
// Don't let player enemies have dude as a hero.
///////////////////////////////////////////////////////////////////////////////
function HookHero(FPSPawn NewHero, optional out byte Worked)
{
	if(NewHero != None)
	{
		Worked=1;
		ZPawn.bTravel=true;
		if(NewHero.bPlayer)
		{
			SetPlayerAsHero(NewHero);
			// Gain other super powers--like never going into stasis!
			DisallowStasis();
		}
		else
		{
			Hero = NewHero;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Unset the current hero
///////////////////////////////////////////////////////////////////////////////
function UnhookHero()
{
	local AWPlayer awp;

	if(Hero != None)
	{
		awp = AWPlayer(Hero.Controller);

		if(awp != None)
		{
			awp.RemoveAWFriend(ZPawn);
			// Remove me from the list of pawns that are dead/gone, so I'll 'return' back to
			// my original level.
			// Don't remove us if we've chunked up, because we probably just got added, 
			// to be remembered.
			if(P2GameInfoSingle(Level.Game) != None
				&& P2GameInfoSingle(Level.Game).TheGameState != None
				&& !ZPawn.bChunkedUp)
				P2GameInfoSingle(Level.Game).TheGameState.RemovePersistentPawn(ZPawn);
			// Unhook us from his time dilation effects
			FPSPawn(Pawn).bIgnoreTimeDilation=false;
			// Reallow stasis, because we're just a normal animal again
			ReallowStasis();
		}

		ZPawn.bPlayerIsFriend=false;
		ZPawn.HeroTag = '';
		ZPawn.bCanTeleportWithPlayer=false;
		ZPawn.bKeepForMovie=false;
		Hero = None;
		ZPawn.bTravel=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get closer to our hero
///////////////////////////////////////////////////////////////////////////////
function GoToHero(optional bool bPlayerOnly, optional out byte StateChange)
{
	local float dist, vel;

	//log(self$" go to hero ");
	if(Hero == None
		|| ZPawn.FloatTime < 0)
		return;

	if(bPlayerOnly
		&& !Hero.bPlayer)
		return;

	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;

	SetNextState('Thinking');

	dist = VSize(Hero.Location - ZPawn.Location);

	if(dist < HANG_AROUND_HERO)
	{
		if(!IsInState('LegMotionToTarget')
			&& !IsInState('Standing'))
		{
			StateChange=1;
			GotoStateSave('Standing');
			return;
		}
	}
	else
	{
		if(!IsInState('RunToHero'))
		{
			StateChange=1;
			SetEndGoal(Hero, (DEFAULT_END_RADIUS + FRand()*HERO_END_RADIUS));
			GotoStateSave('RunToHero');
			return;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to update your float time, when flying around as a zombie toy for the player
///////////////////////////////////////////////////////////////////////////////
function UpdateFloatTime(optional out byte StateChange)
{
	local float usef;

	if(Hero != None
		&& ZPawn.FloatTime > 0)
	{
		// Subtract time spent flying around
		usef = Level.TimeSeconds;
		ZPawn.FloatTime -= (usef - ZPawn.LastFloatTime);

		// If you're close to dying go to the dude to plead
		if(ZPawn.FloatTime < PLEAD_TIME
			&& !bDidPlead)
		{
			bDidPlead=true;
			StateChange=1;
			SetEndGoal(Hero, (DEFAULT_END_RADIUS + PLEAD_END_RADIUS));
			SetNextState('PleadForHealth');
			GotoStateSave('RunToHeroPlead');
		}

		// If you're out of time, you die
		if(ZPawn.FloatTime <= 0)
		{
			ZPawn.TakeDamage(ZPawn.Health, None, ZPawn.Location, vect(0,0,0), class'HeadKillDamage');
		}
		else
		{
			if(bDidPlead
				&& ZPawn.FloatTime > NO_PLEAD_TIME)
				bDidPlead=false;
			ZPawn.LastFloatTime = usef;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// floating--find enemies of the dude
///////////////////////////////////////////////////////////////////////////////
function FindEnemies()
{
	local FPSPawn checkpawn;
	local byte StateChange;

	foreach ZPawn.RadiusActors(class'FPSPAWN', checkpawn, ENEMY_CHECK)
	{
		if(checkpawn.Health > 0 &&
		// Don't attack other zombie or dog helpers 
		!(LambController(checkpawn.Controller) == None || LambController(CheckPawn.Controller).Hero == Hero) &&
		// Don't attack friends of the dude
		!checkpawn.bPlayerIsFriend)
		{			
			AttackThisNow(checkpawn,,StateChange);
			if(StateChange == 1)
				return;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Do something about them swinging their big weapon!
// Either	PreSledgeChargeFreq:	charge him and then attack
//			PreSledgeAttackFreq:	attack where you are
//			PreSledgeFleeFreq:		run away, run away! (not necessarily in the right direction)
///////////////////////////////////////////////////////////////////////////////
function DodgeBigWeapon(PersonPawn Swinger, optional out byte StateChange)
{
	local vector usev;
	local bool bAttacking;

	//log(self$" DodgeBigWeapon "$Swinger);
	// If it's not your hero swinging at you, move from the big attack
	if((Hero == None
			|| Hero != Swinger)
		&& !ZPawn.bFloating)
	{
		// You hate this guy now, it's like a physical hit
		SetAttacker(Swinger);

		// Check to see if he's already attacking
		//bAttacking = (IsInState('AttackTarget') || IsInState('AttackBase'));

		// Charge him and then attack
		if(FRand() < ZPawn.PreSledgeChargeFreq
			&& !bAttacking)
		{
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetEndGoal(Attacker, TIGHT_END_RADIUS);
			SetNextState('AttackTarget');

			if(!ZPawn.bIsDeathCrawling
				&& !ZPawn.bWantsToDeathCrawl
				&& !ZPawn.bMissingLegParts)
				GotoStateSave('RunToAttacker');
			else
				GotoStateSave('CrawlToAttacker');
			// Give him an edge in his attack
			if(!bIncreaseAttackSpeed)
			{
				bIncreaseAttackSpeed=true;
				ZPawn.GenAnimSpeed = AttackSpeedMult*ZPawn.GenAnimSpeed;
			}
			StateChange = 1;
			return;
		}
		// Attack from here, swipe or spit
		else if(FRand() < ZPawn.PreSledgeAttackFreq
			&& !bAttacking)
		{
			// Give him an edge in his attack
			if(!bIncreaseAttackSpeed)
			{
				bIncreaseAttackSpeed=true;
				ZPawn.GenAnimSpeed = AttackSpeedMult*ZPawn.GenAnimSpeed;
			}
			GotoStateSave('AttackTarget');
			StateChange = 1;
			return;
		}
		// Run in some random direction
		else if(FRand() < ZPawn.PreSledgeFleeFreq)
		{
			// Find a random point to run towards
			usev = VRand();
			usev.z = 0;
			usev = (Frand()*DODGE_DIST + DODGE_DIST)*Normal(usev) + ZPawn.Location;

			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetEndPoint(usev, DEFAULT_END_RADIUS);
			SetNextState('AttackTarget');

			if(!ZPawn.bIsDeathCrawling
				&& !ZPawn.bWantsToDeathCrawl
				&& !ZPawn.bMissingLegParts)
				GotoStateSave('RunToAttacker');
			else
				GotoStateSave('CrawlToAttacker');
			// Make noise as you dodge
			PrintDialogue("Yikes, a sledge!");
			Say(ZPawn.myDialog.lSeesEnemy,true,,true);
			StateChange = 1;
			return;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Allow yourself to wait on another zombie in front of you
///////////////////////////////////////////////////////////////////////////////
function bool CanWaitOnZombie(AWZombie checkme)
{
	if(checkme != WaitingZombie)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Setup first to wait and second to keep moving
//////////////////////////////////////////////////////////////////////////////
function static HandleWaitAndMove(AWZombieController waitguy, AWZombieController moveguy)
{
	if(waitguy.IsInState('LegMotionToTarget'))
		waitguy.bPreserveMotionValues=true;
	if(waitguy.Attacker != None)
		waitguy.SetNextState('AttackTarget');
	else
		waitguy.SetNextState('Thinking');
	waitguy.GotoState('WaitOnZombie');

	moveguy.WaitingZombie = waitguy.ZPawn;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// initialize physics by falling to the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state InitFall
{
	ignores MarkerIsHere, damageAttitudeTo, DodgeBigWeapon;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Wait till we've landed to take off running
	///////////////////////////////////////////////////////////////////////////////
	function Landed(vector HitNormal)
	{
		// If we're missing our legs, start a death crawl now
		if (ZPawn.bStartMissingLegs)
			ZPawn.ShouldDeathCrawl(true);
		Pawn.ChangeAnimation();
		GotoState(GetStateName(), 'End');
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Decide what to start doing
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		ForceInitPawnAttributes();

		FPSPawn(Pawn).PrepInitialState();

		// Figure out our home nodes, if we have any
		if(FPSPawn(Pawn).bCanEnterHomes)
			FindHomeList(FPSPawn(Pawn).HomeTag);
		// Link to the remaining path nodes
		FindPathList();

		// You've been told to do something specific (like if you came in through a spawner)
		if(MyNextState != 'None'
			&& MyNextState != '')
			GotoNextState();
		else	// If you're not doing anything specific, go into stasis on start-up
		{
			// Save our old state as Thinking, and go here, if the stasis thing
			// below fails
			GotoStateSave('Thinking');

			if(ZPawn.TryToWaitForStasis())
			{
				// Now try immediately on game start-up, to go into stasis. If you're 
				// in view of the dude when he starts, that's fine, you'll be brought
				// right back out.
				GoIntoStasis();
			}
		}
	}

Begin:
	OldMoveTarget = FindRandomDest();
	//log("old move target "$OldMoveTarget);
	Sleep(0.1);
	if(!ZPawn.bFloating)
		Goto('Begin'); // repeat state
	else
		ZPawn.SetPhysics(PHYS_Flying);
End:
	DecideNextState();
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
	function DecideNext()
	{
		local byte StateChange;

		if(ZPawn.bFloating)
			FindGroundAgain(StateChange);
		if(StateChange == 0)
		{
			if(ZPawn.bMissingLegParts
				&& !ZPawn.bFloating)
			{
				if(!ZPawn.bIsDeathCrawling
					&& !ZPawn.bWantsToDeathCrawl)
				{
					SetNextState('CrawlToTarget');
					GotoStateSave('PrepToCrawl');
					return;
				}
				else
				{
					GotoStateSave('CrawlToTarget');
					return;
				}
			}
			GotoStateSave('WalkToTarget');
			return;
		}
	}
	///////////////////////////////////////////////////////////////////////////
	// nothing on my mind when we start
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		SetAttacker(None);
	}

Begin:
TryAgain:
	Sleep(FRand()*0.1 + 0.1);

	// Check to do a patrol
	if(ZPawn.PatrolNodes.Length > 0)
	{
		Sleep(2.0);
		SetToPatrolPath();
		GotoNextState();
	}
DecideNow:
	if(ZPawn.bFloating)
		FindGroundAgain();
	GotoHero();
	SetNextState('Thinking');
	// walk to some random place I can see (not through walls)
	if(!PickRandomDest())
		Goto('TryAgain');	// Didn't find a valid point, try again
	UpdateFloatTime();
	DecideNext();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Standing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Standing
{
	function BeginState()
	{
		PrintThisState();
		ZPawn.StopAcc();
		// Make him look in some random direction
		Focus = None;
		FocalPoint = VRand();
		FocalPoint.z = 0;
		FocalPoint = 100*FocalPoint + ZPawn.Location;
	}
Begin:
	Sleep(STAND_TIME);
	FindEnemies();
	Sleep(FRand()*STAND_TIME);
	// If had the time to stand around and look for enemies, then 
	// he's ready to pead again
	bDidPlead=false;
	GotoNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitOnZombie
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitOnZombie extends Standing
{
	ignores CanWaitOnZombie, FindEnemies;
	function BeginState()
	{
		PrintThisState();
		ZPawn.StopAcc();
		// stare at your focus
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ActAsTurret
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ActAsTurret
{
	ignores DodgeBigWeapon;

	///////////////////////////////////////////////////////////////////////////
	// Nothing on my mind when we start
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// clear vars
		EndGoal = None;
		EndRadius = 0;
		ZPawn.StopAcc();
	}

Begin:
	Sleep(Rand(10) + 5);

	// Because he's just standing around anyway, not doing much, don't wait
	// to go into stasis--go as soon as you can.
	if(bPendingStasis
		|| ZPawn.TryToWaitForStasis())
		GoIntoStasis();

	// Check to do tourettes every so often
	DoTourettes();

	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TurretWait ... waiting to attack
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TurretWait
{
	///////////////////////////////////////////////////////////////////////////
	// Nothing on my mind when we start
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		ZPawn.StopAcc();
	}

Begin:
	// Check to do tourettes every so often
	DoTourettes();

	Sleep(FRand()*ZPawn.WalkAttackTimeHalf + ZPawn.WalkAttackTimeHalf + ATTACK_UPDATE_MIN_TIME);

	GotoNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToTarget extends LegMotionToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		DodgeThinWall();
		CheckForObstacles();
		// If our actor is a pawn, then get ready to update it frequently
		if(Pawn(EndGoal) != None)
		{
			if(EndGoal != None)
				SetActorTarget(EndGoal, true);
			else
				SetActorTargetPoint(EndPoint, true);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to wait on other zombie
	///////////////////////////////////////////////////////////////////////////////
	function Bump(Actor Other)
	{
		// Make sure it's a zombie that I'm okay with
		if(AWZombie(Other) != None
			&& AWZombieController(AWZombie(Other).Controller) != None
			&& AWZombieController(AWZombie(Other).Controller).Attacker != ZPawn
			&& Attacker != Other
			&& CanWaitOnZombie(AWZombie(Other))
			&& AWZombieController(AWZombie(Other).Controller).CanWaitOnZombie(ZPawn))
		{
			// I wait
			if(Rand(2) == 0)
			{
				HandleWaitAndMove(self, AWZombieController(AWZombie(Other).Controller));
			}
			else // he waits
			{
				HandleWaitAndMove(AWZombieController(AWZombie(Other).Controller), self);
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		WaitingZombie = None;
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		// We hope MyNextState was set to something useful, before we start
		if(MyNextState=='')
			PrintStateError(" no mynextstate");
		//log("inside run to target "$MyNextState);
		Pawn.SetWalking(false);
		if(ZPawn.bFloating)
			ZPawn.ChangeAnimation();
		SetRotation(Pawn.Rotation);
		if(EndGoal != None)
			SetActorTarget(EndGoal);
		else
			SetActorTargetPoint(EndPoint);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToTarget extends LegMotionToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Check to wait on other zombie
	///////////////////////////////////////////////////////////////////////////////
	function Bump(Actor Other)
	{
		// Make sure it's a zombie that I'm okay with
		if(AWZombie(Other) != None
			&& AWZombieController(AWZombie(Other).Controller) != None
			&& AWZombieController(AWZombie(Other).Controller).Attacker != ZPawn
			&& Attacker != Other
			&& CanWaitOnZombie(AWZombie(Other))
			&& AWZombieController(AWZombie(Other).Controller).CanWaitOnZombie(ZPawn))
		{
			// I wait
			if(Rand(2) == 0)
			{
				HandleWaitAndMove(self, AWZombieController(AWZombie(Other).Controller));
			}
			else // he waits
			{
				HandleWaitAndMove(AWZombieController(AWZombie(Other).Controller), self);
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();
		
		// Short-circuit to death crawl if legs are missing
		if(ZPawn.bMissingLegParts)
		{
			ZPawn.ShouldDeathCrawl(true);
			ZPawn.ChangeAnimation();
			GotoState('PrepToCrawl');
		}

		if(Frand() < ZPawn.MoanFreq)
		{
			// Generic moaning
			if(ZPawn.bHasHead)
			{
				PrintDialogue("Moaning");
				Say(ZPawn.myDialog.lHmm,true,true);
			}
			else
			{
				PrintDialogue("Gurgle.. moan");
				if(Say(ZPawn.myDialog.lSpitting,true,true) > 0)
					ZPawn.DoNeckGurgle();
			}
		}
		// If you have your head, consider touretting
		else 
			DoTourettes();

		HandleStasisChange();
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		// We hope MyNextState was set to something useful, before we start
		if(MyNextState=='')
			PrintStateError(" no mynextstate");
		Pawn.SetWalking(true);
		SetRotation(Pawn.Rotation);
		if(EndGoal != None)
			SetActorTarget(EndGoal);
		else
			SetActorTargetPoint(EndPoint);

		statecount=0;

		DoTourettes();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set up our stasis abilities if we haven't yet
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		// Now that everything has calmed down, set the person stasis time, if they
		// haven't already. This can fail, so this is only a try. And even then
		// they don't instantly go into stasis. They go about for a while, then
		// try to really do it.
		ZPawn.TryToWaitForStasis();

		Super.EndState();

		ZPawn.EndTourettes();
		WaitingZombie = None;
	}

Begin:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,ZPawn.MovementPct,,,true);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,ZPawn.MovementPct,true);
		InterimChecks();
		Sleep(0.0);
	}
	Goto('Begin');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToHero
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToHero extends WalkToTarget
{
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToHero
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToHero extends RunToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	// Zombie magically opens doors to get back to the dude
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		if (AutoDoor(MoveTarget) != None)
			AutoDoor(MoveTarget).MyDoor.Bump(Pawn);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToWeapon
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToWeapon extends RunToTarget
{
	ignores WeaponDropped, CanWaitOnZombie, GetReadyToReactToDanger, RespondToTalker,
		ObservePawn;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToHeroPlead
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToHeroPlead extends RunToTarget
{
	ignores AttackThisNow;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PrepToCrawl
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepToCrawl
{
	ignores DoTourettes, DodgeBigWeapon, CanWaitOnZombie;
	///////////////////////////////////////////////////////////////////////////////
	// Only cry out in pain, nothing more
	///////////////////////////////////////////////////////////////////////////////
	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, 
						   class<DamageType> damageType, vector Momentum)
	{
		if(Damage > 0)
			damageAttitudeTo(instigatedBy, Damage);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop at the animation end, and go about as before
	// Try to death crawl before you leave this state. Wait 
	// idling in a deathcrawl anim if you can't truly deathcrawl yet. This is
	// because the collision radius gets greatly expanded for a deathcrawler.
	///////////////////////////////////////////////////////////////////////////////
	function EndFalling(optional bool bForce)
	{
		local vector dir, checkpoint;

		ZPawn.ShouldDeathCrawl(true);
		// See if you're death crawling yet.. if not, then wait
		if(ZPawn.bIsDeathCrawling
			|| bForce)
			//	&& ZPawn.Physics == PHYS_Walking))
		{
			if(Attacker != None
				&& !Attacker.bDeleteMe
				&& Attacker.Health > 0)
			{
				SetNextState('AttackTarget');
				GotoStateSave('CrawlToAttacker');
			}
			else
				GotoStateSave('Thinking');
		}
		else
			GotoState('PrepToCrawl','WaitAfterFall');
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		ZPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			EndFalling();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		ZPawn.StopAcc();
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;
	}

WaitAfterFall:
	ZPawn.SetAnimDeathCrawlWait();
	Sleep(1.0);
	EndFalling(true);
	Goto('WaitAfterFall');
Begin:	
	// If they are crouched then stand up and fall
	if(ZPawn.bIsCrouched)
	{
		ZPawn.ShouldCrouch(false);
		Sleep(0.3);
	}

	ZPawn.PlayAnim(ZPawn.GetAnimDeathFallForward(), 3.0, 0.3);

	Sleep(3.0);

	EndFalling(true);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CrawlToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CrawlToTarget extends WalkToTarget
{
	ignores DoTourettes;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Stop us when we land
	///////////////////////////////////////////////////////////////////////////////
	function Landed(vector HitNormal)
	{
		FPSPawn(Pawn).StopAcc();
		Pawn.ChangeAnimation();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// Turn off blocking collision now
		Pawn.SetCollision(Pawn.bCollideActors, false, false);
	}
Begin:
	ZPawn.ShouldDeathCrawl(true);

	if(Pawn.Physics == PHYS_FALLING)
	{
		WaitForLanding();
	}
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,ZPawn.MovementPct,,,true);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,ZPawn.MovementPct,true);
		InterimChecks();
	}
	Sleep(0.0);
	Goto('Begin');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CrawlToAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CrawlToAttacker extends CrawlToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Check to chase after your hero more often here
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();
		GotoStateSave('AttackTarget');
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
		FPSPawn(Pawn).PathCheckTimeActor = FRand()*ZPawn.CrawlAttackTimeHalf + ZPawn.CrawlAttackTimeHalf + ATTACK_UPDATE_MIN_TIME;
		FPSPawn(Pawn).PathCheckTimePoint = FPSPawn(Pawn).PathCheckTimeActor;
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
		If(Other == Attacker)
			GotoStateSave('AttackTarget');
		else
			Super.Bump(Other);
	}
	function Touch(Actor Other)
	{
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
		else if(ZPawn.FastTrace(Attacker.Location, ZPawn.Location))
			GotoStateSave('AttackTarget');
		else // If we lose sight of them, immediately reduce the check times
		{
			// If you can't see, think about running some
			if(FRand() < ZPawn.ChargeFreq)
			{
				bPreserveMotionValues=true;
				SetEndGoal(Attacker, DEFAULT_END_RADIUS);
				GotoStateSave('RunToAttacker');
			}
			else
			{
				FPSPawn(Pawn).PathCheckTimeActor = FPSPawn(Pawn).default.PathCheckTimeActor;
				FPSPawn(Pawn).PathCheckTimePoint = FPSPawn(Pawn).default.PathCheckTimePoint;
			}
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
		FPSPawn(Pawn).PathCheckTimeActor = FRand()*ZPawn.WalkAttackTimeHalf + ZPawn.WalkAttackTimeHalf + ATTACK_UPDATE_MIN_TIME;
		FPSPawn(Pawn).PathCheckTimePoint = FPSPawn(Pawn).PathCheckTimeActor;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToAttacker extends RunToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// When you're moving towards your attacker and you reach them, end it now
	///////////////////////////////////////////////////////////////////////////////
	function Bump(Actor Other)
	{
		//log(self$" bump with "$Other$" attacker "$attacker);
		if(Other == Attacker)
		{
			//log(self$" going to attack targ");
			GotoStateSave('AttackTarget');
		}
		else
			Super.Bump(Other);
	}
	function Touch(Actor Other)
	{
		if(Other == Attacker)
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
		else if(ZPawn.FastTrace(Attacker.Location, ZPawn.Location))
			GotoStateSave('AttackTarget');
		// Give up charging, and walk again
		else 
		{
			bPreserveMotionValues=true;
			SetEndGoal(Attacker, DEFAULT_END_RADIUS);
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
		FPSPawn(Pawn).PathCheckTimeActor = FRand()*ZPawn.ChargeAttackTimeHalf + ZPawn.ChargeAttackTimeHalf + ATTACK_UPDATE_MIN_TIME;
		FPSPawn(Pawn).PathCheckTimePoint = FPSPawn(Pawn).PathCheckTimeActor;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PatrolToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PatrolToTarget extends WalkToTarget
{
	ignores CanWaitOnZombie;

	///////////////////////////////////////////////////////////////////////////////
	// I've reached a patrol goal point
	///////////////////////////////////////////////////////////////////////////////
	function HitEndPatrol()
	{
		//FPSPawn(Pawn).StopAcc();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		HitEndPatrol();

		//log(ZPawn$" NextStateAfterGoal, path node length "$ZPawn.PatrolNodes.Length$" goal was "$MoveTarget$" move point "$MovePoint);
		if(ZPawn.PatrolNodes.Length == 0)
		{
			PickRandomDest();
			//log(ZPawn$" new random dest is "$EndGoal);
		}
		else
			SetEndGoal(GetNextPatrolEndPoint(), DEFAULT_END_RADIUS);

		GotoState(GetStateName());
		BeginState();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Force your next state
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		SetNextState('PatrolToTarget');
		Super.BeginState();
		//log(self$" using end goal "$EndGoal);
	}
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
	ignores CanWaitOnZombie;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		local byte StateChange;

		ZPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
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
		ZPawn.ChangeAnimation();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		ZPawn.StopAcc();
		statecount=0;
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;
		// Moan when you see them
		if(ZPawn.bHasHead)
		{
			PrintDialogue("Hey you!");
			Say(ZPawn.myDialog.lInvadesHome,true,,true);
		}
		else
		{
			PrintDialogue("Gurgle.. Ouch!");
			if(Say(ZPawn.myDialog.lSpitting,true,,true) > 0)
				ZPawn.DoNeckGurgle();
		}
	}

Begin:
	//ZPawn.PlayAnimRecognize();
	GotoStateSave('AttackTarget');
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
	ignores CanWaitOnZombie;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function DecideAttack()
	{
		local float dist, vomitf, userand;
		local bool bswiped;
		local byte StateChange;

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
							&& userand < 0.333)
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

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	Focus = Attacker;
	//FinishRotation();
	DecideAttack();
/*
FaceHimBeforeLook:
	Focus = Attacker;
	FinishRotation();
LookForAttacker:
	MyPawn.ShouldCrouch(false);
	DetectAttackerSomehow(Attacker);

WaitTillFacing:
	Focus = Attacker;
	FinishRotation();
	//Sleep(0.5);

Begin:
	// Use the right anims to fire
	MyPawn.SetMood(MOOD_Combat, 1.0);
	SayTime=0.0;
	CurrentFloat=0;

	CheckForDeadAttacker();

	CheckForObstacle();

	Sleep(0.01);

	// We know we can still see him here, so record his location/direction
	SaveAttackerData();
	LookForSafePoints();

	// Check out attacker just before you shoot--you may want to hold your fire
	// Also get your gun ready based on his looks
	EvaluateAttacker();

	// If this is a new AI we're fighting, back up some to fight him (only do this once 
	// for each new attacker we encounter). At this point, after evaulating your attacker, you should have
	// your correct weapon selected (but might not be ready) so go ahead and back up.
	if(bNewAttacker) 
	{
		bNewAttacker=false;
		PerformStrategicMoves(,true);
	}

	CheckWeaponReady();

FireNowPrep:
	DecideFireCount();
FireNow:
	// See if we can attack, if so, shoot the random number of times our gun says to, pauses
	// very briefly in between

	DecideAttack();

	Sleep(WorkFloat);

	CheckToMoveAround();

	FightTalk();
	Sleep(SayTime); // Melee weapons should be the only ones that really sleep here, and only
					// in distance mode, even then.

	Goto('Begin');// run this state again

WaitForWeapon:
	Sleep(0.5);	// Give him time to get his gun out
	Goto('Begin'); // try again

TurretWait:
	MyPawn.ShouldCrouch(false);
	Sleep(WorkFloat*TWITCH_DIVIDER);
	Goto('Begin');// try again
	*/
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
	ignores CanWaitOnZombie;

	///////////////////////////////////////////////////////////////////////////////
	// Decide how to handle being attacked or having a limb cut off
	///////////////////////////////////////////////////////////////////////////////
	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, 
						   class<DamageType> damageType, vector Momentum)
	{
		if(Damage > 0)
			damageAttitudeTo(instigatedBy, Damage);

		// If it's not a serious attack, then blend the hit in
		// and don't go to our special stunted state
		if(ClassIsChildOf(damageType, class'BludgeonDamage')
			&& !ClassIsChildOf(damageType, class'SledgeDamage')
			&& !ClassIsChildOf(damageType, class'CuttingDamage'))
		{
			ZPawn.bBlendTakeHit=false;
		}
		else
		{
			Global.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		local byte StateChange;

		ZPawn.AnimEnd(channel);
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
		ZPawn.EndFightAnim();
		ZPawn.ChangeAnimation();
		Focus = Attacker;
		// Return attack speed to normal
		if(bIncreaseAttackSpeed)
		{
			ZPawn.GenAnimSpeed = ZPawn.DefAnimSpeed;
			bIncreaseAttackSpeed=false;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		ZPawn.StopAcc();
		statecount=0;
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;

		if(Attacker == None
			|| Attacker.bDeleteMe
			|| Attacker.Health <= 0)
			GotoStateSave('Thinking');
		// Check if we can hit them
		else if(!ZPawn.FastTrace(Attacker.Location, ZPawn.Location))
		{
			SetNextState('AttackTarget');
			// Failed, bail out, start moving again
			SetEndGoal(Attacker, DEFAULT_END_RADIUS);
			if(!ZPawn.bFloating
				&& (ZPawn.bIsDeathCrawling
					|| ZPawn.bWantsToDeathCrawl
					|| ZPawn.bMissingLegParts))
				GotoStateSave('CrawlToAttacker');
			else
				GotoStateSave('WalkToAttacker');
		}
		else // didn't fail, continue
		{
			// attack yell
			if(ZPawn.bHasHead)
			{
				PrintDialogue("Attack yell");
				Say(ZPawn.myDialog.lWhileFighting,true,true);
			}
			else
			{
				PrintDialogue("Gurgle.. attack!");
				if(Say(ZPawn.myDialog.lSpitting,true,true) > 0)
					ZPawn.DoNeckGurgle();
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TryWeaponGrab
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TryWeaponGrab
{
	ignores WeaponDropped, CanWaitOnZombie, GetReadyToReactToDanger, RespondToTalker,
		ObservePawn;

	///////////////////////////////////////////////////////////////////////////////
	// If your close enough, let him grab it
	///////////////////////////////////////////////////////////////////////////////
	function GrabIt()
	{
		if(P2WeaponPickup(Focus) != None
			&& !Focus.bDeleteMe
			&& VSize(Pawn.Location - Focus.Location) < 2*Focus.CollisionRadius)
		{
			// Say you can grab it.
			ZPawn.bCanPickupInventory=true;
			// Force a touch to register the grab
			Focus.Touch(ZPawn);
			// Say you can't grab anything anymore
			ZPawn.bCanPickupInventory=false;
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	GrabIt();
	if(Attacker != None)
		GotoStateSave('AttackTarget');
	else
		GotoStateSave('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// BigSmash
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state BigSmash extends AttackBase
{
Begin:
	// attack yell
	if(ZPawn.bHasHead)
	{
		PrintDialogue("Attack yell");
		Say(ZPawn.myDialog.lWhileFighting,true,true);
	}
	else
	{
		PrintDialogue("Gurgle.. attack!");
		if(Say(ZPawn.myDialog.lSpitting,true,true) > 0)
			ZPawn.DoNeckGurgle();
	}
	ZPawn.PlayAnimSmash();
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// SwipeLeft
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SwipeLeft extends AttackBase
{
Begin:
	// attack yell
	if(ZPawn.bHasHead)
	{
		PrintDialogue("Attack yell");
		Say(ZPawn.myDialog.lWhileFighting,true,true);
	}
	else
	{
		PrintDialogue("Gurgle.. attack!");
		if(Say(ZPawn.myDialog.lSpitting,true,true) > 0)
			ZPawn.DoNeckGurgle();
	}
	ZPawn.PlayAnimSwipeLeft();
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// SwipeRight
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SwipeRight extends AttackBase
{
Begin:
	// attack yell
	if(ZPawn.bHasHead)
	{
		PrintDialogue("Attack yell");
		Say(ZPawn.myDialog.lWhileFighting,true,true);
	}
	else
	{
		PrintDialogue("Gurgle.. attack!");
		if(Say(ZPawn.myDialog.lSpitting,true,true) > 0)
			ZPawn.DoNeckGurgle();
	}
	ZPawn.PlayAnimSwipeRight();
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// VomitAttack
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state VomitAttack extends AttackBase
{
Begin:
	ZPawn.PlayAnimVomitAttack();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RecoilFromHit
// They don't attack for a moment and play this animation
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RecoilFromHit
{
	ignores AttackThisNow, DodgeBigWeapon, CanWaitOnZombie;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		local byte StateChange;

		ZPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			if(Attacker != None)
				GotoStateSave('AttackTarget');
			else
				GotoStateSave('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		ZPawn.EndFightAnim();
		ZPawn.ChangeAnimation();
		Focus = Attacker;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		ZPawn.StopAcc();
		statecount=0;
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RecoilLeft
// Throws back left shoulder
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RecoilLeft extends RecoilFromHit
{
Begin:
	ZPawn.PlayAnimHitLeft();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RecoilRight
// Throws back right shoulder
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RecoilRight extends RecoilFromHit
{
Begin:
	ZPawn.PlayAnimHitRight();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RecoilBack
// Throws forward
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RecoilBack extends RecoilFromHit
{
Begin:
	ZPawn.PlayAnimHitBack();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Plead with hero to be healed
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PleadForHealth extends RecoilFromHit
{
Begin:
	Focus = Hero;
	if(Say(ZPawn.myDialog.lSpitting,true,true) > 0)
		ZPawn.DoNeckGurgle();
	ZPawn.PlayScreamingStillAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RagdollWait
// You're physics is karma as you sail through the air from an explosion
// Don't try to animate, don't do anything
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RagdollWait
{
	ignores AttackThisNow, StartAttacking, NotifyTakeHit, DoLiveRagdoll, DodgeBigWeapon,
		CanWaitOnZombie;

	function BeginState()
	{
		PrintThisState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// StandUpUnRagdoll
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StandUpUnRagdoll
{
	ignores AttackThisNow, StartAttacking, NotifyTakeHit, DoLiveRagdoll, DodgeBigWeapon,
		CanWaitOnZombie;

Begin:
	Sleep(ZPawn.PlayAnimStandUpFromRagdoll());
	GotoState('Thinking', 'DecideNow');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ClimbingLadder
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ClimbingLadder extends RunToTarget
{
	ignores NotifyTakeHit, AttackThisNow, DodgeBigWeapon, CanWaitOnZombie,
		StartClimbLadder;
}

defaultproperties
{
     AttackSpeedMult=3.000000
}
