///////////////////////////////////////////////////////////////////////////////
// PersonController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI controllers for humans. (not animals)
///////////////////////////////////////////////////////////////////////////////
class PersonController extends LambController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars
var P2MoCapPawn	MyPawn;		// P2Pawn version of Pawn inside Controller.
var	FPSPawn	OldAttacker;	// Remember who last hurt you, even though you may be thinking
var FPSPawn	PlayerAttackedMe;// If the player attacked me, mark it in SetAttacker. Then look at this
							// again, so we can go hunt him down, when we're done with our old attacker
var vector  OldPlayerPos;	// This corresponds to the last place we saw the player *before* we attacked
							// someone else. So if we're using PlayerAttackedMe to reassign the player
							// as our attacker, then we should use this.
var float   PlayerAttackTime;// Last time we dealt with the player. Forget about attacking him if it's
							// been too long (unless you see him again when you're done attacking)
var float   AttackerLastTime; // Level time when our data was last updatted on our current attacker. Used
							// for detecting him, if it's really close to the time we lost him.
var vector	LastAttackerPos;// Last place we thought the attacker was
var vector  LastAttackerDir;// Last direction he was seen moving/point
//var vector	MyOldPos;		// Last position for me (usually used with navigation)
var FPSPawn  InterestPawn2;	// Same as InterestPawn
var vector  InterestVect;	// Junk vector used to say your interesting in this point or direction
var vector  InterestVect2;	// same as above
var class<Inventory> InterestInventoryClass;	// class we're interested in, like money
							// It's the inventory item we switch to when the dude shows up IF we're a
							// cashier. Most people don't use this.
//var bool	bFoundHideSpot;	// At my hide point
//var bool	bFoundFleeSpot;	// At my hide point
var float	UseReactivity;	// Used all the time, this changes based on how scared you are.
var float	UsePatience;	// How patient we currently are
var bool	bSaidGetDown;	// Already said this once
var FPSPawn IgnoreBody;		// This is the pawn to ignore because we've already messed with it enough
var byte	ToldGetDownCount;	// How many times I've been told to get down and didn't (it wasn't real)
var byte	ToldFuckYouCount;	// Number of times we've been told to fuck off by the player
var int		DonatedBotherCount;	// -1 means you've donated money, otherwise it's the number of times you've
							// been bothered to donate money. 
var int		PhotoBothered;	// 1 if bothered by the champ photo already							
//var vector  PossibleSafePoint;	// We've recently determined this could be a safe point to hide at
							// but could easily have been invalidated.
var byte	BeggedCount;	// How many times you've begged for your life, gotten up and run
							// and begged again.
var byte	ScreamState;	// If you've screamed in this state yet
var bool	bPanicked;		// If you've panicked once or not
var enum EQLineStatus
{
	EQ_Nothing,
	EQ_Cutting,				// We're trying to cut in line
	EQ_HoldingItUp			// We're idling or something stupid
} QLineStatus;				// What we're doing in line (cutting, holding it up)
var float	SayTime;		// how long you need to say something for (maybe sleep during this time)
var DoorBufferPoint CheckDoor;	// door buffer i'm currently waiting on
var float	BackToHandsFreq;// In their thinking state, how likely this guy will switch back
							// to his hands, if he has a weapon out.
var float	SwitchWeaponFreq;// Frequency with which you pull out your weapon when something crazy happens
							// but you're not directly involved.
var byte	SafePointStatus;// Used only in ShootAtAttacker, 0 is and invalid point, 1 means a safe point has been determined,
							// and as far as we can tell, the attacker is still around the area that he was before.
							// 2 supports crouching and more.. see SAFE_POINT consts below
var vector  SafePoint;		// Spot we last determined in combat that was safe from view of our attacker.
var FPSPawn.EPawnInitialState PlayerSightReaction;	// Type of reaction the player inspires in NPCs when they see him.
							// InterestVolume controls this.
var class<TimedMarker> DeadBodyMarkerHere;
var bool	bNewAttacker;	// If this is a new enemy, we may do special things when fighting him
var float   DistanceRun;	// Distance we've run. Gets calculated through RunToTarget.
							// Cumulative distance, gets added to more and more by runtotarget, till they
							// reset it through resting or through thinking. This is not perfectly
							// accurate--it's usually less than the actual distance covered.
var vector  RunStartPoint;	// Point in space where we started running. Could be used as a loose 'old position'
							// variable but generally only updatted in RunToTarget to calc DistanceRun.
var float	WorkFloat;		// Generic float used for most anything in a state. ShootAtAttacker needs lots
							// of these.
var bool	bHiToCop;		// Already talked to cop if true

//var localized string GameHint;	// Usually simply an inventory item hint
// Kamek 5-1 - save if we refuse to donate to someone
// and if they kill us later, reward them!
var bool bRefusedToDonate;
var int MeleeBlocking;		// how many melee/projectile hits you need to block

// Test for R. Kelly achievement
var bool bRKellyTest;

var sound ClappingSound;

// Valentines Day flag
var class<Inventory> ValentineVaseClass;	// Defined in subclasses where we have access to Inventory

// Knock out stuff
var float KnockedOutTime;
const KNOCK_OUT_TIME = 15.0;	// FIXME Increase after testing

// custom anim vars
var int CCurrentAction;					// Current custom action
var int CCurrentLoopCount;				// Current custom action loop count
var int CTotalLoopCount;				// Number of times we've looped the entire thing
var bool bCPreTrigger, bCPostTrigger;	// Pre/post trigger

var float FlashbangStartTime;

var class<Actor> LookZombieClass;	// zombies to look for

var Array<InterestPoint> InterestPointsVisited;	// List of interest points we've visited so far.

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////

const VISUALLY_FIND_RADIUS= 2048;
//const VISUALLY_FIND_RADIUS= 1024;
const MIN_VISUALLY_FIND_RADIUS= 300;
const MAX_RECOGIZE_TRIES=	6;

const MIN_SHY_DIST		=	256;

const TALK_TO_SOMEONE_RADIUS=	256;
const TALK_BACKUP_DIST		=	50;
const LAUGH_AT_GIMP_RADIUS	=	1024;
const HI_AT_COP_RADIUS		=	700;
const LISTEN_TO_DUDE_RADIUS	=	600;
const LOOK_FOR_TALKEE_RADIUS=	1024;
const NOTICE_GIMP_TO_LAUGH		=	0.5;
const START_LAUGH_AT_GIMP		=   0.2;
const KEEP_SNICKERING_AT_GIMP	=	0.3;
const COMMENT_TO_GIMP			=	0.9;
const LAUGH_AT_GIMP				=	0.7;

const INFECTION_HEALTH_PCT	= 0.05;

const AIM_MOD_DIST		=   0.7;
const TURRET_AIM		=	0.85;
const AIM_ERROR_MAX		=	1700;
const SHOOT_TIME_LAG	=	0.4;

const CHECK_DANGER_DIST	=	256;

const DEFAULT_VIEW_CONE	=	0.75;
const FIND_ENEMY_CONE	=	-0.3;
const TWITCH_DIVIDER	=	3;

const HIGH_CEILING		=	512;

const COWER_DISTANCE	=	180;
const BEG_PRONE_DISTANCE=	300;

const WEAPON_BASE_DIST	=	60;
const WEAP_FAR_BUFFER	=	1.2;
const WEAP_CLOSE_BUFFER	=	0.8;

const MAX_BREATHES_AFTER_SHOCK=5;

const MAX_DONATE_BOTHER=	3;

const LONG_TALK_LOOP	=	3;

const MAX_GET_DOWN_BLUFF=	10.0;
const SHOUT_GET_DOWN_RADIUS=1000;
const STAY_DOWN_SC_MAX		= 7;
const STOP_WATCHING_MIN_COUNT=5;
const STOP_WATCHING_MINOR_THREAT_RATIO	= 9;
const STOP_WATCHING_MAJOR_THREAT_RATIO	= 13;
const STOP_WATCHING_COP_BASE= 3;
const STOP_WATCHING_COP_ADD	= 6;
const MAX_REMEMBER_PLAYER_TIME= 40.0;

const MAX_DISTANCE_BEFORE_TIRED=14000;
const REGAIN_BREATH_DIST	=	3000;

const TRY_FOR_ATTACKER_DOWN	=	0.8;

const PERSONAL_SPACE_BASE	=	1.5;
const PERSONAL_SPACE_ADD	=	2.0;

const PANTING_MAX			=	6;
const PANTING_BASE			=	2;

const DONUTS_ARE_BAD		=	0.05;
const TAKE_THIS_KICK_DEAD	=	0.3;

const COMMENT_ON_CRAZY_FREQ	=	0.1;
const COMMENT_ON_FIRE_FREQ	=	0.6;	// Rikki - Orig 0.25. Testing higher value to see if fire lines will ever play. This constant has been unused for over 11 years!
const COMMENT_ON_PARADE_FREQ=   0.1;
const CLAP_AT_PARADE_FREQ	=	0.1;

const NEW_PARADER_FREQ			=	0.3;
const PARADE_PATHNODE_RADIUS	=   600;
const PARADE_MOVE_FORWARD_OFFSET=	500;
const PARADE_MOVE_SIDE_OFFSET	=   600;
const PARADE_MOVE_MIN_DOT		=   0.7;

const DANCE_AGAIN			=	0.5;

const DEG_360 				= 6.28;
const CONVERT_360_TO_2PI 	= 0.01746;

const REACTIVITY_LOSE		= 0.03;
const REACTIVITY_GAIN		= 0.035;

const PISS_FAKE_DAMAGE		= 10;
const GAS_FAKE_DAMAGE		= 10;

const ATTACKER_FUZZ			= 100;
const CAN_HEAR_RANGE		= 2000;
const ATTACKER_LOST_TIME_BASE	= 2.5;	// For when you just ran around a corner--everyone will know where you are
										// within this time
const ATTACKER_LOST_TIME_PSYCHIC= 5.0;  // P2Pawn.Psychic gets multiplied by this to find out how much more time
										// they get to magically know where you are.

const PATHNODE_SEARCH_RADIUS=	1300;

const TOO_CLOSE_CHANGE_TO_RUN_RATIO =	0.3;
const THREAT_TOO_CLOSE		=	0.2;
const SAFE_RANGE_HARASS_INCREASE = 1.1;
const SHY_AWAY_PATIENCE_LOSS=	0.05;
const HARASS_PATIENCE_LOSS=	0.05;
const PISS_RUN_AWAY_DIST	=	300;

const WATCH_HIGH_UP_ATTACKER_TIME	= 2.0;
const WATCH_HIGH_UP_PATHNODE_DIST = 700;
const WATCH_HIGH_UP_WAIT	= 3;

const STARE_AT_DEAD_DUDE	=	25;
const STARE_AT_DEAD_THING	=	10;

const TOSS_STUFF_VEL		=	128;

const SAFE_POINT_MIN_DIST	= 256;
const SAFE_POINT_ANGLE_MAX	= 10;
const SAFE_POINT_INVALID	= 0;
const SAFE_POINT_STAND		= 1;
const SAFE_POINT_CROUCH		= 2;
const HIDING_WAIT_TIME		= 10;
const DUCK_WAIT_TIME		= 3;

const STAY_PISSED_AT_CUTTER	= 0.8;

const SCREAMING_FREQ		= 0.2;
const FIRE_SCREAMING_FREQ	= 0.3;
const SCREAMING_STILL_FREQ	= 0.2;	// gets multiplied by violence rank of weapon
const WEAPON_RANK_SCREAM	= 2;

const TAKE_A_BREATHER_FREQ	= 0.8;

const IN_MY_WAY_DOT			= 0.85; // closer to 1.0, the more inline with my direction someone
	// has to be, before I try to get around them
const BACK_RUN_DEST_BASE	= 70;
const BACK_RUN_DEST_ADD		= 100;
const SIDE_STEP_DIST		= 128;
const FORWARD_RUN_DIST		= 128;
const STRATEGIC_STEP_ADD_DIST	= 200;
const STRATEGIC_STEP_BASE_DIST	= 100;
const MOVE_FROM_DOOR_DIST	= 160;
const WAIT_TO_ATTACK_INVERSE= 0.1;
const ATTACKER_CHECK_RANGE  = 1024;
const BURST_TIME_SAFEPOINT_CHECK=	0.5;

const TALKING_DIST			= 200;
const FIRE_MIN_DIST_MULT	= 1.5;

const DEFAULT_END_RADIUS	= 70;
const TIGHT_END_RADIUS		= 50;
const DEST_BUFFER			= 10.0;

const REPORT_WEAPON_FREQ	= 0.2;

// how gross something is effects how likely you are to be disgusted by it
const HEAD_EXPLODED_GROSS_MOD=	0.7;
const DEAD_BODY_GROSS_MOD	=	1.0;
const DEAD_HEAD_GROSS_MOD	=	0.9;
const PISSED_ON_GROSS_MOD	=	0.9;

const DO_IDLE_FREQ			=	0.05;

const SCREAM_STATE_NONE		=	0;
const SCREAM_STATE_ACTIVE	=	1;
const SCREAM_STATE_DONE		=	2;

const NORMAL_SCREAM			=	0;
const FIRE_SCREAM			=	1;

const COP_WEAPON_VIOLENCE_RANK	=	3;

const PERSON_BONE_PELVIS= 'Male01 pelvis';
const BONE_HAND	= 'MALE01 r hand';

const HAND_LENGTH	=	7;
const HAND_WIDTH	=	-2;

// Difficulty level changes
// These are percentages to be used as multipliers on to the original
const DIFF_CHANGE_HEALTH	= 0.01;
const DIFF_CHANGE_DAMAGE	= 0.2;
const DIFF_CHANGE_TWITCH	= -0.15;
const DIFF_CHANGE_TWITCH_FAR= -0.1;
const DIFF_CHANGE_DODGE		= 0.1;
const DIFF_CHANGE_COVER		= 0.1;
const DIFF_CHANGE_GLAUCOMA	= -0.1;
const DIFF_CHANGE_PAIN		= 0.2;
const DIFF_CHANGE_CHAMP		= 0.1;
const DIFF_CHANGE_CAJONES	= 0.3;

const HOT_GREETING_CHANCE = 0.5;	// Reduce me to a lower value after testing

const FLASHBANG_BASE_REST_TIME = 4.5;
const FLASHBANG_BASE_RUN_TIME = 30.0;

const PI_OVER_TWO = 1.5707963267949;

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage,
					   class<DamageType> damageType, vector Momentum)
{
	// If this hit depletes our "non-lethal" health, it's a knockout. Do that first and ignore everything else
	if (MyPawn.NonLethalHealth <= 0)
		DoGetKnockedOut();
	// Freak out instantly, no matter what, if it's a cat attached to me
	else if(ClassIsChildOf(damageType, class'DervishDamage'))
	{
		DervishAttack(InstigatedBy);
	}
	else if(ClassIsChildOf(damageType, class'ScytheDamage')
		|| ClassIsChildOf(damageType, class'MacheteDamage'))
		LimbChoppedOff(FPSPawn(InstigatedBy), hitlocation);
	else
		Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
}

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
			if(!MyPawn.bMissingLegParts)
				GotoStateSave('FleeFromAttacker');
			else
				DoDeathCrawlAway(true);
		}
	}
}
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
		
		// Turn off hearing and senses so we don't end up going into a state we shouldn't be in with no limbs
		MyPawn.bIgnoresSenses = true;
		MyPawn.bIgnoresHearing = true;

		// Either fall to the ground and crawl, or run away
		// Or if they are missing any leg parts, they fall automatically
		if(!MyPawn.bMissingLegParts
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

///////////////////////////////////////////////////////////////////////////////
// Decide what to do about this danger
///////////////////////////////////////////////////////////////////////////////
function GetReadyToReactToDanger(class<TimedMarker> dangerhere,
								FPSPawn CreatorPawn,
								Actor OriginActor,
								vector blipLoc,
								optional out byte StateChange)
{
	// This will never be called! BystanderController and PoliceController both have their own implementations.
	/*
	// Handle zombies
	if(CreatorPawn.IsA('AWZombie'))
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
	else if(CreatorPawn.IsA('DogPawn')
		&& P2MoCapPawn(Pawn).bDogFriend
		&& AnimalController(CreatorPawn.Controller) != None
		&& AnimalController(CreatorPawn.Controller).Attacker != MyPawn)
	{
		// STUB
		return;
	}
	else
		Super.GetReadyToReactToDanger(dangerhere, CreatorPawn, OriginActor, blipLoc, StateChange);
	*/
}

///////////////////////////////////////////////////////////////////////////////
// You successfully blocked a single melee attack
///////////////////////////////////////////////////////////////////////////////
function DidBlockMelee(out byte StateChange)
{
	// STUB
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

function ObservePawn(FPSPawn LookAtMe);
function DodgeBigWeapon(FPSPawn Swinger);

///////////////////////////////////////////////////////////////////////////////
// Possess the pawn
///////////////////////////////////////////////////////////////////////////////
function Possess(Pawn aPawn)
{
	local float gamediff, diffoffset;

	Super.Possess(aPawn);

	MyPawn = P2MoCapPawn(Pawn);
	if(MyPawn == None)
		PrintStateError("Possess: MyPawn is None");

	MyPawn.SetMovementPhysics();
	if (MyPawn.Physics == PHYS_Walking)
		MyPawn.SetPhysics(PHYS_Falling);
	MyNextLabel='Begin';
	OldEndPoint = MyPawn.Location;
	// set my defaults
	UseReactivity = MyPawn.Reactivity;
	UsePatience = MyPawn.Patience;
	PersonalSpace = (PERSONAL_SPACE_BASE*MyPawn.CollisionRadius) + (Rand(PERSONAL_SPACE_ADD*MyPawn.CollisionRadius));
	// Decide default current safe min
	GenSafeRangeMin();

	MyPawn.AddDefaultInventory();
	
	// See if the GameMod wants to do anything.
	P2GameInfoSingle(Level.Game).BaseMod.ModifyNPC(Pawn);

	// Set our hero, if we have a tag
	Hero = FPSPawn(FindActorByTag(MyPawn.HeroTag));
	
	// Only set this up once (in case we depossess/repossess the same pawn because of matinees, etc.)
	if (!MyPawn.bInitialDifficulty)
	{
		MyPawn.bInitialDifficulty = true;

		// Change settings based on being a Turret or not
		if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
		{
			// Make us twice as accurate (since turrets are placed and can't get any closer
			// to the attacker, give them an advantage)
			MyPawn.Glaucoma = TURRET_AIM*MyPawn.Glaucoma;
		}

		// Based on our abilities (weapons) and the game
		// difficulty, set our variables
		gamediff = P2GameInfo(Level.Game).GetGameDifficulty();
		diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset();
	/*
		log(self$" before diff "$gamediff$" offset "$diffoffset);
		log(MyPawn$" HealthMax "$MyPawn.HealthMax);
		log(MyPawn$" Twitch "$MyPawn.Twitch);
		log(MyPawn$" WillDodge "$MyPawn.WillDodge);
		log(MyPawn$" WillUseCover "$MyPawn.WillUseCover);
		log(MyPawn$" Glaucoma "$MyPawn.Glaucoma);
		log(MyPawn$" PainThreshold "$MyPawn.PainThreshold);
		log(MyPawn$" Champ "$MyPawn.Champ);
		log(MyPawn$" Cajones "$MyPawn.Cajones);
	*/
		// Basic difficulty ramping for characters
		if(MyPawn.bHasViolentWeapon
			&& diffoffset != 0)
		{
			// Key to only give them a little more life, and to up the damage they deal
			// more, so the quick satisfaction of killing them is still there, but they
			// kill you faster.
			MyPawn.HealthMax		+= (diffoffset*MyPawn.HealthMax*DIFF_CHANGE_HEALTH);
			MyPawn.DamageMult		+= (diffoffset*DIFF_CHANGE_DAMAGE);
			MyPawn.Twitch			+= (diffoffset*MyPawn.Twitch*DIFF_CHANGE_TWITCH);
			MyPawn.TwitchFar		+= (diffoffset*MyPawn.TwitchFar*DIFF_CHANGE_TWITCH_FAR);
			MyPawn.WillDodge		+= (diffoffset*MyPawn.WillDodge*DIFF_CHANGE_DODGE);
			MyPawn.WillUseCover		+= (diffoffset*MyPawn.WillUseCover*DIFF_CHANGE_COVER);
			MyPawn.Glaucoma			+= (diffoffset*MyPawn.Glaucoma*DIFF_CHANGE_GLAUCOMA);
			MyPawn.Champ			+= (diffoffset*MyPawn.Champ*DIFF_CHANGE_CHAMP);
			// Don't make these any lower
			if(diffoffset > 0)
			{
				MyPawn.PainThreshold	+= (diffoffset*MyPawn.PainThreshold*DIFF_CHANGE_PAIN);
				MyPawn.Cajones			+= (diffoffset*MyPawn.Cajones*DIFF_CHANGE_CAJONES);
			}
		}
	/*
		log(self$" after");
		log(MyPawn$" HealthMax "$MyPawn.HealthMax);
		log(MyPawn$" Twitch "$MyPawn.Twitch);
		log(MyPawn$" WillDodge "$MyPawn.WillDodge);
		log(MyPawn$" WillUseCover "$MyPawn.WillUseCover);
		log(MyPawn$" Glaucoma "$MyPawn.Glaucoma);
		log(MyPawn$" PainThreshold "$MyPawn.PainThreshold);
		log(MyPawn$" Champ "$MyPawn.Champ);
		log(MyPawn$" Cajones "$MyPawn.Cajones);
		*/
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called before this pawn is "teleported" with the player so it can save
// essential information that will later be passed to PostTeleportWithPlayer().
///////////////////////////////////////////////////////////////////////////////
function PreTeleportWithPlayer(out FPSGameState.TeleportedPawnInfo info, P2Pawn PlayerPawn)
{
	Super.PreTeleportWithPlayer(info, PlayerPawn);

	// Check if player should be considered enemy
	if((Attacker != None 
		&& Attacker.bPlayer)
			|| MyPawn.bPlayerIsEnemy)
		info.bPlayerIsEnemy = true;
	else
		info.bPlayerIsEnemy = false;

	// Save friends
	info.bPlayerIsFriend = MyPawn.bPlayerIsFriend;

	if (MyPawn.MyHead != None)
	{	
		info.HeadSkin = MyPawn.MyHead.Skins[0];
		info.HeadMesh = MyPawn.MyHead.Mesh;
	}	
}

///////////////////////////////////////////////////////////////////////////////
// Called after this pawn was "teleported" with the player so it can restore
// itself using the previously-saved information.  See PreTeleportWithPlayer().
///////////////////////////////////////////////////////////////////////////////
function PostTeleportWithPlayer(FPSGameState.TeleportedPawnInfo info, P2Pawn PlayerPawn)
{
	Super.PostTeleportWithPlayer(info, PlayerPawn);

	if (info.bPlayerIsEnemy)
	{
		if(MyPawn.bHasViolentWeapon)
			SetToAttackPlayer(PlayerPawn);
		else
			SetToBeScaredOfPlayer(PlayerPawn);
	}
	
	if (MyPawn.MyHead != None)
	{
		MyPawn.MyHead.Skins[0] = info.HeadSkin;
		MyPawn.MyHead.LinkMesh(info.HeadMesh, false);
	}
	MyPawn.SetupDialog();	// re-set dialog
}

///////////////////////////////////////////////////////////////////////////////
// Used only for AIScripts, make sure the MyPawn gets cleared too
///////////////////////////////////////////////////////////////////////////////
function PendingStasis()
{
	Super.PendingStasis();
	MyPawn = None;
}

///////////////////////////////////////////////////////////////////////////////
// Print out what the dialogue should say, with who said it
///////////////////////////////////////////////////////////////////////////////
function PrintDialogue(String diastr)
{
	if(P2GameInfo(Level.Game).LogDialog == 1)
		log("---------------------------"$MyPawn$" says: "$diastr);
}

///////////////////////////////////////////////////////////////////////////////
// Say the specified line of dialog.
// Returns the duration of the specified line.
///////////////////////////////////////////////////////////////////////////////
function float Say(out P2Dialog.SLine line, optional bool bImportant)
	{
	return MyPawn.Say(line, bImportant);
	}

///////////////////////////////////////////////////////////////////////////////
// Say the number
// bPureNumbers means don't say things like 'a' for '1', say '1', so you
// can say "i'll take a number 1, please"
///////////////////////////////////////////////////////////////////////////////
function float SayThisNumber(int NumberToSay, optional bool bPureNumbers, optional bool bImportant)
	{
	return MyPawn.SayThisNumber(NumberToSay, bPureNumbers, bImportant);
	}

///////////////////////////////////////////////////////////////////////////////
// Make sure youre attack range doesn't get too low
///////////////////////////////////////////////////////////////////////////////
function SetAttackRange(float nMin, optional float nMax)
{
	if(nMin < DEFAULT_END_RADIUS)
		nMin = DEFAULT_END_RADIUS;

	MyPawn.AttackRange.Min = nMin;

	if(nMax > 0)
	{
		if(nMax < DEFAULT_END_RADIUS)
			nMax = DEFAULT_END_RADIUS;

		MyPawn.AttackRange.Max = nMax;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Save data about our attacker, when we last looked at him
///////////////////////////////////////////////////////////////////////////////
function SaveAttackerData(optional FPSPawn ThisGuy, optional bool bDontUpdateAttackerTime)
{
	local FPSPawn UseGuy;

	if(ThisGuy != None)
		UseGuy = ThisGuy;
	else
		UseGuy = Attacker;

	//log(self$" saving attacker data my pos "$MyPawn.Location$" was "$LastAttackerPos$" att loc "$UseGuy.Location);
	// Save current attacker info
	LastAttackerPos = UseGuy.Location;

	// Save player specific info
	if(ThisGuy == PlayerAttackedMe)
	{
		PlayerAttackTime = Level.TimeSeconds;
		OldPlayerPos = UseGuy.Location;
	}

	if(!bDontUpdateAttackerTime)
	{
		// Last time we updatted him. Sometimes don't update this, because the only reason
		// we're allowed to update the other data, is that our timer here was close enough to just
		// losing him. If we updatted this too, then, we'd forever know about him.
		AttackerLastTime = Level.TimeSeconds;
	}

	if(UseGuy.Velocity.x == 0
		&& UseGuy.Velocity.y == 0)
		LastAttackerDir = vector(UseGuy.Rotation);
	else
		LastAttackerDir = UseGuy.Velocity;

	LastAttackerDir = Normal(LastAttackerDir);
}

///////////////////////////////////////////////////////////////////////////////
// Usually cop specific. Used to register with the cop radio and clear themselves
///////////////////////////////////////////////////////////////////////////////
function PlayerFirstTimeAttacker();

///////////////////////////////////////////////////////////////////////////////
// All our attacker pointers are blanked out. This should not be called everywhere.
// Cops use this to update their radio also. Use SetAttacker(None) for minor
// clears of attackers.
///////////////////////////////////////////////////////////////////////////////
function FullClearAttacker(optional bool bClearPlayerOnly)
{
	PlayerAttackedMe=None;
	if(!bClearPlayerOnly)
		SetAttacker(None);
}

///////////////////////////////////////////////////////////////////////////////
// Local spot to set my attacker, only assigns old when not none.
///////////////////////////////////////////////////////////////////////////////
function SetAttacker(Pawn NewA, optional bool bDontUpdateLocation)
{
	local bool bNewOne;
	local Inventory Inv;
	local bool bNoRanged;
	
	// If we're set to turret but with melee weapons only, chase them down anyway.
	if (MyPawn.PawnInitialState == EP_Turret)
	{
		//log(self@"i'm a turret and my new attack4er is "@newa,'Debug');
		bNoRanged = true;
		for (Inv = Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			//log(inv,'Debug');
			if (P2Weapon(Inv) != None
				&& !P2Weapon(Inv).bMeleeWeapon
				&& !Inv.IsA('HandsWeapon')
				&& !Inv.IsA('UrethraWeapon')
				&& !Inv.IsA('FootWeapon')
				&& !Inv.IsA('CellPhoneWeapon'))
			{
				//log("not a melee weapon");
				bNoRanged = false;
				break;
			}
		}
		if (bNoRanged) // Turn off the turret and chase them down
		{
			//log(self@"turning off turret",'Debug');
			MyPawn.PawnInitialState = EP_Think;
		}
	}

	if(Attacker == None)
	{
		// Reset our safe points
		SafePointStatus=SAFE_POINT_INVALID;
		// Make our old attacker be our current attacker
		OldAttacker = FPSPawn(NewA);
		bNewOne=true;
		if(FPSPawn(NewA) != None
			&& !FPSPawn(NewA).bPlayer)
			bNewAttacker=true;
	}
	else if(OldAttacker != NewA)
	{
		// Reset our safe points
		SafePointStatus=SAFE_POINT_INVALID;
		// Save the old attacker
		OldAttacker = Attacker;
		bNewOne=true;
		if(FPSPawn(NewA) != None
			&& !FPSPawn(NewA).bPlayer)
			bNewAttacker=true;
	}

	Attacker = FPSPawn(NewA);
	if(P2GAmeinfo(Level.Game).LogStates == 1)
		log(MyPawn$" SetAttacker called "$Attacker$" my state "$GetStateName()$" old state "$MyOldState);
	
	// See about cops saving themselves to the gamestate for radio reference
	// Only add the player in once
	if(bNewOne
		&& PlayerAttackedMe == None
		&& Attacker != None
		&& Attacker.bPlayer)
		PlayerFirstTimeAttacker();

	if(Attacker != None)
	{
		if(Attacker.bPlayer)
		{
			PlayerAttackTime = Level.TimeSeconds;
			PlayerAttackedMe=Attacker;
		}

		if(!bDontUpdateLocation)
		{
			SaveAttackerData();
		}
	}
	else
		bNewAttacker=false;
}

///////////////////////////////////////////////////////////////////////////////
//
// Polge AdjustAim()
// Returns a rotation which is the direction the npc should aim - after introducing the appropriate aiming error
///////////////////////////////////////////////////////////////////////////////
function rotator AdjustAim(Ammunition FiredAmmunition, vector ProjStart, int aimerror)
{
	local rotator FireRotation, TargetLook;
	local float FireDist, TargetDist, ProjSpeed;
	local actor HitActor;
	local vector FireSpot, FireDir, TargetVel, HitLocation, HitNormal;
	local int realYaw, AimAdd;
	local bool bDefendMelee, bClean, bLeadTargetNow;

	if ( FiredAmmunition.ProjectileClass != None )
		projspeed = FiredAmmunition.ProjectileClass.default.speed;

	// make sure bot has a valid target
	if(Enemy != None)
		Target = Enemy;
	if ( Target == None )
	{
//		StopFiring();
		return Rotation;
	}

	FireSpot = Target.Location;

	// perfect aim at stationary objects
	if ( Pawn(Target) == None )
	{
		if ( !FiredAmmunition.bTossed )
			return rotator(FireSpot - projstart);
		else
		{
			FireSpot.Z += AdjustToss(FiredAmmunition,ProjStart,FireSpot);
			SetRotation(Rotator(FireSpot - ProjStart));
			return Rotation;
		}					
	}
	else 
	{
		// Screw up your aim with some random lag behind (or leading of) moving targets
		FireSpot = FireSpot - ((2*FRand()*SHOOT_TIME_LAG) - 0.5*SHOOT_TIME_LAG)*Target.Velocity;
		// Try to aim at their head sometimes
		FireSpot.Z += 0.9 * Target.CollisionHeight;
	}

	TargetDist = VSize(FireSpot - Pawn.Location);

	bLeadTargetNow = false;//FiredAmmunition.bLeadTarget && bLeadTarget;
	bDefendMelee = false;//( (Target == Enemy) && DefendMelee(TargetDist) );

	//	aimerror = AdjustAimError(aimerror,TargetDist,bDefendMelee,FiredAmmunition.bInstantHit, bLeadTargetNow);
	// Post-release to keep the NPC's from being such sharp shooters. Every AIM_MOD_DIST their accuracy
	// decreases.
	AimAdd = AIM_MOD_DIST*TargetDist; 
	aimerror = AimAdd + aimerror;
	aimerror*=MyPawn.Glaucoma;
	//log(MyPawn$" aimerror "$aimerror$" gl "$MyPawn.Glaucoma);

	// Make sure they're never too stupidly inaccurate.
	if(aimerror > AIM_ERROR_MAX)
		aimerror = AIM_ERROR_MAX;

	// lead target with non instant hit projectiles
	if ( bLeadTargetNow )
	{
		TargetVel = Target.Velocity;
		// hack guess at projecting falling velocity of target
		if ( Target.Physics == PHYS_Falling )
		{
			if ( Target.PhysicsVolume.Gravity.Z <= Target.PhysicsVolume.Default.Gravity.Z )
				TargetVel.Z = FMin(-160, TargetVel.Z);
			else
				TargetVel.Z = FMin(0, TargetVel.Z);
		}
		// more or less lead target (with some random variation)
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * TargetVel * TargetDist/projSpeed;
		FireSpot.Z = FMin(Target.Location.Z, FireSpot.Z);

		if ( (Target.Physics != PHYS_Falling) && (FRand() <= 0.55) && (VSize(FireSpot - ProjStart) > 1000) )
		{
			// don't always lead far away targets, especially if they are moving sideways with respect to the bot
			TargetLook = Target.Rotation;
			if ( Target.Physics == PHYS_Walking )
				TargetLook.Pitch = 0;
			bClean = ( ((Vector(TargetLook) Dot Normal(Target.Velocity)) >= 0.71) && FastTrace(FireSpot, ProjStart) );
		}
		else // make sure that bot isn't leading into a wall
			bClean = FastTrace(FireSpot, ProjStart);
		if ( !bClean)
		{
			// reduce amount of leading
			if ( FRand() <= 0.3 )
				FireSpot = Target.Location;
			else
				FireSpot = 0.5 * (FireSpot + Target.Location);
		}
	}
/*
	bClean = false; //so will fail first check unless shooting at feet  
	if ( FiredAmmunition.bTrySplash && (Pawn(Target) != None) && ((Skill >=4) || bDefendMelee) 
		&& (((Target.Physics == PHYS_Falling) && (Pawn.Location.Z + 80 >= FireSpot.Z))
			|| ((Pawn.Location.Z + 19 >= FireSpot.Z) && (bDefendMelee || (skill > 6.5 * FRand() - 0.5)))) )
	{
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,1) * (Target.CollisionHeight + 6), FireSpot, false);
 		bClean = (HitActor == None);
		if ( !bClean )
		{
			FireSpot = HitLocation + vect(0,0,3);
			bClean = FastTrace(FireSpot, ProjStart);
		}
		else 
			bClean = ( (Target.Physics == PHYS_Falling) && FastTrace(FireSpot, ProjStart) );
	}
	if ( !bClean )
	{
		//try middle
		FireSpot.Z = Target.Location.Z;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( FiredAmmunition.bTossed && !bClean && bEnemyInfoValid )
	{
		FireSpot = LastSeenPos;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			StopFiring();
			FireSpot += 2 * Target.CollisionHeight * HitNormal;
		}
		bClean = true;
	}
	*/
/*
	if( !bClean ) 
	{
		// try head
 		FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( !bClean && (Target == Enemy) && bEnemyInfoValid )
	{
		FireSpot = LastSeenPos;
		if ( Pawn.Location.Z >= LastSeenPos.Z )
			FireSpot.Z -= 0.7 * Enemy.CollisionHeight;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			FireSpot = LastSeenPos + 2 * Enemy.CollisionHeight * HitNormal;
			if ( Pawn.Weapon.SplashDamage() && (Skill >= 4) )
			{
			 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
				if ( HitActor != None )
					FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			}
//			if ( Pawn.Weapon.RefireRate() < 0.99 )
//				bCanFire = false;
		}
	}
*/
	// adjust for toss distance
//	if ( FiredAmmunition.bTossed && (FRand() <= 0.75) )
//		FireSpot.Z += AdjustToss(FiredAmmunition,ProjStart,Target.Location);
	
	FireRotation = Rotator(FireSpot - ProjStart);
	realYaw = FireRotation.Yaw;
	FireRotation.Yaw = SetFireYaw(FireRotation.Yaw + (FRand()*aimerror - aimerror/2));
	FireDir = vector(FireRotation);
	// avoid shooting into wall
	FireDist = FMin(VSize(FireSpot-ProjStart), 400);
	FireSpot = ProjStart + FireDist * FireDir;
	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
	if ( HitActor != None )
	{
		if ( HitNormal.Z < 0.7 )
		{
			FireRotation.Yaw = SetFireYaw(realYaw - aimerror);
			FireDir = vector(FireRotation);
			FireSpot = ProjStart + FireDist * FireDir;
			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
		}
		if ( HitActor != None )
		{
			FireSpot += HitNormal * 2 * Target.CollisionHeight;
			if ( Skill >= 4 )
			{
				HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
				if ( HitActor != None )
					FireSpot += Target.CollisionHeight * HitNormal; 
			}
			FireDir = Normal(FireSpot - ProjStart);
			FireRotation = rotator(FireDir);		
		}
	}

	FiredAmmunition.WarnTarget(Target,Pawn,FireDir);
	SetRotation(FireRotation);			
	return FireRotation;
}

///////////////////////////////////////////////////////////////////////////////
// What to do once you've picked a sidestep place
///////////////////////////////////////////////////////////////////////////////
function AfterStrategicSideStep(vector checkpoint)
{
	// Now move to it and get ready to shoot again when you get there
	//log("side stepping");
	bDontSetFocus=true;
	SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	SetNextState('Thinking');
	bStraightPath=UseStraightPath();
	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;
	GotoStateSave('RunToTargetIgnoreAll');
}

///////////////////////////////////////////////////////////////////////////////
// Pick a good direction to your sides, to side-step to
// Attacking function
///////////////////////////////////////////////////////////////////////////////
function StrategicSideStep(optional out byte StateChange)
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, startdir, usevect, checkpoint;

	startdir = vector(MyPawn.Rotation);
	//log("beforestart dir "$startdir);
	// Add some randomness to our direction, so 
	// when we pick the side step, it won't be perfectly same every time
	startdir.x+=(FRand()-0.5)/8;
	startdir.y+=(FRand()-0.5)/8;
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

	checkpoint = MyPawn.Location + (Rand(STRATEGIC_STEP_ADD_DIST) + STRATEGIC_STEP_BASE_DIST)*usevect;

	HitActor = Trace(HitLocation, HitNormal, checkpoint, MyPawn.Location, true);

	// Find the distance from the wall or other obstacle
	if(HitActor != None)
	{
		MovePointFromWall(HitLocation, HitNormal, MyPawn);
		checkpoint = HitLocation;
	}
	if(//!TestPath(HitLocation, true)
		//|| 
		(HitActor != None && VSize(HitLocation - MyPawn.Location) <= DEFAULT_END_RADIUS))
	{
		// Check if that hit is too close to us, because we might then try the other direction
		// Also enter this, if test path fails
//			if(VSize(HitLocation - MyPawn.Location) <= TIGHT_END_RADIUS)
//			{
			//log("TOOOOOOO TIGHT  1!");
			// too tight, so try the other direction
			usevect.x = -usevect.x;
			usevect.y = -usevect.y;
			checkpoint = MyPawn.Location + (Rand(STRATEGIC_STEP_ADD_DIST) + STRATEGIC_STEP_BASE_DIST)*usevect;

			// Find the distance from the wall or other obstacle
			HitActor = Trace(HitLocation, HitNormal, checkpoint, MyPawn.Location, true);
			if(HitActor != None)
			{
				MovePointFromWall(HitLocation, HitNormal, MyPawn);
				checkpoint = HitLocation;
			}

			if(HitActor != None && VSize(HitLocation - MyPawn.Location) <= DEFAULT_END_RADIUS)
			{
				StateChange = 0;// failed to dodge
				return;
			}
	}

	// Now move to it and get ready to shoot again when you get there
	AfterStrategicSideStep(checkpoint);
	StateChange = 1;
}

///////////////////////////////////////////////////////////////////////////////
// Decide to crouch or kneel to make yourself harder to hit
// Attacking function
///////////////////////////////////////////////////////////////////////////////
function PerformStrategicMoves(optional bool bForce, optional bool bForceBackUp, optional out byte StateChange)
{
	local float DistToAttacker, UseMinRange;
	local vector checkpoint, dir;
	local int TotalViolenceRank;

	// Only allow most moves if you're a not a turret (still allow kneeling/crouching
	// if you're a turret or normal)
	if(MyPawn.PawnInitialState != MyPawn.EPawnInitialState.EP_Turret)
	{
		TotalViolenceRank = P2Weapon(MyPawn.Weapon).ViolenceRank;
		UseMinRange = P2Weapon(MyPawn.Weapon).MinRange;
		if(Attacker != None
			&& Attacker.Weapon != None)
		{
			TotalViolenceRank = (TotalViolenceRank + P2Weapon(Attacker.Weapon).ViolenceRank)/2;
			UseMinRange = UseMinRange + P2Weapon(Attacker.Weapon).MinRange;
		}
		//log(self$" min ranges "$P2Weapon(MyPawn.Weapon).MinRange$" attackers "$P2Weapon(Attacker.Weapon).MinRange$" use "$UseMinRange);
		// Convert rank to 0-1
		TotalViolenceRank = P2Weapon(MyPawn.Weapon).FindViolenceRatio(TotalViolenceRank);

		// Check to change your distance to your attacker, if your using a
		// melee weapon or you feel like being a champ and closing up the distance.
		// Or you can be too close and because of your violent weapon, you'll want
		// to obey the weapon's distance use.
		// If you don't have a violent weapon, your opponent might, so if you have a
		// pistol, but your attacker has a rocket launcher, you'll probably back up
		// When this is forced, it's forced to make him get out of the way. So
		// let him dodge or crouch, not run closer.
		if(!bForce
			&& 
			(bForceBackUp
			|| MyPawn.Weapon.bMeleeWeapon
			|| FRand() <= MyPawn.Champ
			|| FRand() <= TotalViolenceRank))
		{
			dir = LastAttackerPos - MyPawn.Location;
			DistToAttacker = VSize(dir);
			
			//log(MyPawn$" distance was "$DistToAttacker$" max is "$Pawn.Weapon.MaxRange$" min is "$P2Weapon(Pawn.Weapon).MinRange);
			if(DistToAttacker < UseMinRange)
			// if you're too close for your weapon vs your attacker's weapon, then try to back up
			{
				// Calc a point straight back, to the min distance to stand
				// with this weapon
				checkpoint = MyPawn.Location - UseMinRange*Normal(dir);
				GetMovePointOrHugWalls(checkpoint, MyPawn.Location, UseSafeRangeMin, true);
				//log(MyPawn$" run away "$checkpoint$" you "$Attacker.Location);
				SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
				SetNextState('ShootAtAttacker', 'FaceHimBeforeLook');
				bStraightPath=UseStraightPath();
				MyPawn.SetMood(MOOD_Normal, 1.0);	// run with your arms down
				GotoStateSave('RunToTargetIgnoreAll');
				StateChange=1;
				return;
			}
			// if you're further than your weapon vs your attacker's weapon says you should be
			else if(DistToAttacker > MyPawn.Weapon.MaxRange)
			{
				//log(MyPawn$" run towards "$LastAttackerPos$" you "$Attacker.Location);
				SetEndPoint(LastAttackerPos, MyPawn.Weapon.MaxRange);
				SetNextState('ShootAtAttacker', 'FaceHimBeforeLook');
				bStraightPath=UseStraightPath();
				GotoStateSave('RunToAttacker');
				StateChange=1;
				return;
			}
		}

		// check to do a side step dodge
		if(FRand() <= MyPawn.WillDodge
			|| bForce)
		{
			// Find a point to your sides, to side-step to
			StrategicSideStep(StateChange);
			if(StateChange == 1)
				return;
		}
	}

	// Still a be able to kneel/crouch if you're a turret or not
	// Check to kneel down
	if(FRand() <= MyPawn.WillKneel
		|| bForce)
	{
		// If we didn't succesfully dodge, then try to kneel, maybe
		if(!MyPawn.bIsCrouched)
		{
			// If the attacker has his pants down *don't* crouch in front of him.. move somehow
			// Also move somehow, if you have a weapon where you don't want to crouch with it
			// (like a shovel or a grenade)
			if((Attacker != None
					&& Attacker.HasPantsDown())
				|| (P2Weapon(MyPawn.Weapon) != None
					&& (P2Weapon(MyPawn.Weapon).bThrownByFiring
						|| P2Weapon(MyPawn.Weapon).bMeleeWeapon)))
			{
				// If you're not a turret, side step him, if you are, just don't do anything
				if(MyPawn.PawnInitialState != MyPawn.EPawnInitialState.EP_Turret)
				{
					StrategicSideStep(StateChange);
					if(StateChange == 1)
						return;
				}
			}
			else
				MyPawn.ShouldCrouch(true);
		}
		else
		// If we're already crouching, then stand back up
		{
			MyPawn.ShouldCrouch(false);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Returns true most of the time, but gets ignored by a state, if that
// state has the person so messed up they can't help anyone.
// Usually used by police before they give each other orders.
///////////////////////////////////////////////////////////////////////////////
function bool CanHelpOthers()
{
	// If we're missing an arm or a leg we can't do much but run around screaming (arm) or deathcrawling (leg)
	if (MyPawn.bMissingLimbs)
		return false;
		
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure we're all lined up for the shot
// We could have been running, facing elsewhere, now we're swinging
// around to get a shot in. This will ensure we're probably facing our target
// Used mostly in offensive states like arrest mode or attack modes.
// Pretty expensive. Use LostHim as 1 (positive sense) only. Use it to know
// when you've really lost him. This function takes care for the most part
// of telling them the next state, but it assumes they're chasing him already.
// This doesn't start people chasing their attacker.
///////////////////////////////////////////////////////////////////////////////
function DetectAttacker(FPSPawn CheckPawn, optional out byte StateChange,
						optional out byte LostHim, 
						optional bool AlreadyThere, optional name RunState)
{
	local bool bRunToLastPoint;
	local float endrad;

	//log(MyPawn$" try to detect him "$CheckPawn);
	if(!CanSeePawn(MyPawn, CheckPawn, FIND_ENEMY_CONE))
	{
		endrad = EndRadius;
		if(endrad < DEFAULT_END_RADIUS)
			endrad = DEFAULT_END_RADIUS;

		// If we're not where we need to be, then run there
		if(VSize(MyPawn.Location - LastAttackerPos) > endrad
			&& !AlreadyThere)
		{
			//log(MyPawn$" not close enough");
			endrad = TIGHT_END_RADIUS;
			bRunToLastPoint=true;
		}
		else
		{
			// This is like cheating, but it approximates a person just knowing vaguely where you
			// went if they lost you only a few seconds ago. Since it's only a few seconds, it doesn't
			// cheat that much, and doesn't feel too cheap. This is based on the pawns Psychic value.
			//log(self$" attacker time "$AttackerLastTime$" real time "$Level.TimeSeconds$" check time "$ATTACKER_LOST_TIME_BASE + MyPawn.Psychic*ATTACKER_LOST_TIME_PSYCHIC);
			// Check if we just lost him so close to acquiring him, then just know about it
			if(AttackerLastTime > Level.TimeSeconds - (ATTACKER_LOST_TIME_BASE + MyPawn.Psychic*ATTACKER_LOST_TIME_PSYCHIC))
			{
				//log(self$" time was close enough.. updatting him");
				SaveAttackerData(CheckPawn, true);
				bRunToLastPoint=true;
			}
			// See if he's moving fast(making noise), and if we're close enough to 'hear'
			else if(CheckPawn.MakingMovingNoises())
			{
				//log(MyPawn$" he's making noise");
				if(VSize(MyPawn.Location - CheckPawn.Location) < CAN_HEAR_RANGE)
				{
					endrad = TIGHT_END_RADIUS;
					//log(MyPawn$" i hear him!!!");
					SaveAttackerData(CheckPawn);
					bRunToLastPoint=true;
				}
			}
		}

		if(bRunToLastPoint && LastAttackerPos != Vect(0,0,0))
		{
			//log(MyPawn$" running to where we lost him "$LastAttackerPos$"; where he is "$CheckPawn.Location);
			SetEndPoint(LastAttackerPos, endrad);
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('ShootAtAttacker');
			SetAttacker(CheckPawn, true);
			bStraightPath=UseStraightPath();
			if(RunState == '')
				GotoStateSave('RunToAttacker');
			else
				GotoStateSave(RunState);
			StateChange = 1;
			return;
		}

		// Check to see if we're within 
		//log(MyPawn$" I LOST HIM! OH MAN!");
		LostHim=1;
	}
	else // I can see him directly so of course save his data
	{
		//log(MyPawn$" i can see some part of "$CheckPawn);
		SaveAttackerData(CheckPawn);
	}
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function DetectAttackerSomehow(FPSPawn CheckPawn, optional name RunState)
{
	DetectAttacker(CheckPawn,,,,RunState);
}

///////////////////////////////////////////////////////////////////////////////
// We *were* attacking the player, so now go looking to attack him again
///////////////////////////////////////////////////////////////////////////////
function GoAfterPlayerAgain(out byte StateChange)
{
	// See if we have a conceivable shot of him
	//if(FastTrace(PlayerAttackedMe.Location, MyPawn.Location))
	if(CanSeePawn(MyPawn, PlayerAttackedMe, FIND_ENEMY_CONE))
	{
		StateChange=1;
		SetAttacker(PlayerAttackedMe);
		GotoStateSave('AssessAttacker');
	}
	else// We can't see him, so go to where he last was
	{
		if(Level.TimeSeconds - MAX_REMEMBER_PLAYER_TIME < PlayerAttackTime)
		{
			StateChange=1;
			SetAttacker(PlayerAttackedMe, true);
			LastAttackerPos = OldPlayerPos;
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('LookAroundForTrouble');
			SetEndPoint(LastAttackerPos, DEFAULT_END_RADIUS);
			GotoStateSave('RunToAttacker');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Based on the weapon, decide how often to fire this weapon in a short burst
///////////////////////////////////////////////////////////////////////////////
function DecideFireCount()
{
	firecount = P2Weapon(MyPawn.Weapon).AI_BurstCountMin + Rand(P2Weapon(MyPawn.Weapon).AI_BurstCountExtra);
	P2Weapon(MyPawn.Weapon).ShotCountMaxForNotify=firecount;
	P2Weapon(MyPawn.Weapon).ShotCountReset();
}

///////////////////////////////////////////////////////////////////////////////
// start: set up functions (from spawner and the like) using PawnInitialState
///////////////////////////////////////////////////////////////////////////////
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
		SetAttacker(keepp);
		MyPawn.DropBoltons(Velocity);
		SetNextState('AssessAttacker');
	}
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
	SetNextState('FleeFromAttacker');
}

///////////////////////////////////////////////////////////////////////////////
// Alert them that i'm panicking,
// used usually by flee from danger
///////////////////////////////////////////////////////////////////////////////
function TellAllImPanicked(class<PanicMarker> ADanger)
{
	local FPSPawn CreatorPawn;

	if(!bPanicked)
	{
		// creator is the bad guy, so if i have an interest or attacker, make it that
		if(Attacker != None)
			CreatorPawn = Attacker;
		else if(InterestPawn != None)
			CreatorPawn = InterestPawn;
		else
			CreatorPawn = MyPawn;
		// now tell all
		ADanger.static.NotifyControllersStatic(
			Level,
			ADanger,
			CreatorPawn, 
			MyPawn, 
			ADanger.default.CollisionRadius,
			MyPawn.Location);

		//log(self$" pawn "$MyPawn$" telling everyone about panic");
		bPanicked=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Find a player and be scared of him
///////////////////////////////////////////////////////////////////////////////
function SetToBeScaredOfPlayer(FPSPawn PlayerP)
{
	local P2Player keepp;

	if(PlayerP == None)
		keepp = GetRandomPlayer();
	else
		keepp = P2Player(PlayerP.Controller);

	// check for some one to run from
	if(keepp != None)
	{
		SetAttacker(keepp.MyPawn);
		InterestPawn = Attacker;
		DangerPos = Attacker.Location;
		MyPawn.DropBoltons(MyPawn.Velocity);
		// Decide current safe min
		UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;
		SetNextState('FleeFromAttacker');
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
		SetAttacker(AttackHim);
		MyPawn.DropBoltons(MyPawn.Velocity);
		SetNextState('AssessAttacker');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Dance in this spot forever unless disturbed
///////////////////////////////////////////////////////////////////////////////
function SetToDance()
{
	SetNextState('DanceHere');
}

///////////////////////////////////////////////////////////////////////////////
// Stand this way and play an arcade game
///////////////////////////////////////////////////////////////////////////////
function SetToPlayArcadeGame()
{
	SetNextState('PlayArcadeGame');
}

///////////////////////////////////////////////////////////////////////////////
// Stand this way and type at a keyboard
///////////////////////////////////////////////////////////////////////////////
function SetToKeyboardType()
{
	SetNextState('KeyboardType');
}

///////////////////////////////////////////////////////////////////////////////
// Loop custom animation until disturbed.
///////////////////////////////////////////////////////////////////////////////
function SetToCustom()
{
	SetNextState('LoopCustomAnim');
}

///////////////////////////////////////////////////////////////////////////////
// Play guitar
///////////////////////////////////////////////////////////////////////////////
function SettoGuitar()
{
	SetNextState('PlayGuitar');
}

///////////////////////////////////////////////////////////////////////////////
// Find StartInterest and stand in it
///////////////////////////////////////////////////////////////////////////////
function SetToStandInQ()
{
	local QPoint newq;

	//log(MyPawn$" finding this q to start in "$MyPawn.StartInterest);
	if(MyPawn.StartInterest == '')
		PrintStateError(" No StartInterest tag for GoStandInQueue");

	foreach DynamicActors(class'QPoint', newq, MyPawn.StartInterest)
	{
		// After we find the q, set up the pawn to go stand in it, just like he's
		// been directed to, by an interest point
		newq.PrepStartupActorsToUseMe(MyPawn, LT_WalkTo);
		return;
	};

	if(newq == None)
		PrintStateError(" Bad StartInterest tag: "$MyPawn.StartInterest);
}

///////////////////////////////////////////////////////////////////////////////
// Find a closet actor with this tag (should be a pawn) and be scared of him
///////////////////////////////////////////////////////////////////////////////
function SetToBeScaredOfTag(Name RunTag)
{
	local FPSPawn RunFrom;

	RunFrom = FPSPawn(FindNearestActorByTag(RunTag));

	// check for some one to run from
	if(RunFrom != None)
	{
		SetAttacker(RunFrom);
		InterestPawn = Attacker;
		DangerPos = Attacker.Location;
		MyPawn.DropBoltons(MyPawn.Velocity);
		// Decide current safe min
		UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;
		SetNextState('FleeFromAttacker');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Just stand where you are, sort of like a security guard on duty or something
///////////////////////////////////////////////////////////////////////////////
function SetToHoldPosition()
{
	SetNextState('HoldingPosition');
}

///////////////////////////////////////////////////////////////////////////////
// Stand with gun at side (don't report gun)
///////////////////////////////////////////////////////////////////////////////
function SetToStandWithGun()
{
	SwitchToBestWeapon();
	SetNextState('StandWithGun');
}

///////////////////////////////////////////////////////////////////////////////
// Stand with gun out, ready to shoot (don't report gun)
///////////////////////////////////////////////////////////////////////////////
function SetToStandWithGunReady()
{
	SwitchToBestWeapon();
	MyPawn.SetMood(MOOD_Combat, 1.0);
	SetNextState('StandWithGun');
}

///////////////////////////////////////////////////////////////////////////////
// Go to the nearest person around me and kick him
///////////////////////////////////////////////////////////////////////////////
function SetToKickNearest()
{
}

///////////////////////////////////////////////////////////////////////////////
// Start patrolling your PatrolNodes.
///////////////////////////////////////////////////////////////////////////////
function SetToPatrolPath()
{
	//log(MyPawn$" SetToPatrolPath length "$MyPawn.PatrolNodes.Length);

	if (MyPawn.PatrolNodes.Length == 0)
		warn("================= I'M ON PATROL AND I HAVE NO PATROL NODES"@Self@MyPawn);

	if(MyPawn.PatrolNodes.Length > 0)
	{
		// Only reset the patrol tag if it's over
		if(MyPawn.PatrolI > MyPawn.PatrolNodes.Length)
			MyPawn.PatrolI=0;
		SetEndGoal(MyPawn.PatrolNodes[MyPawn.PatrolI], DEFAULT_END_RADIUS);
	}
	else
		PickRandomDest();

	//log(MyPawn$" SetToPatrolPath end goal"$EndGoal);
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

	if (MyPawn.PatrolNodes.Length == 0)
		warn("================= I'M ON PATROL AND I HAVE NO PATROL NODES"@Self@MyPawn);

	currI = MyPawn.PatrolI;

	// loop when you get the end.
	MyPawn.PatrolI++;
	if(MyPawn.PatrolI >= MyPawn.PatrolNodes.Length)
	{
		MyPawn.PatrolI = 0;
	}

	//log(MyPawn$" now picking "$MyPawn.PatrolNodes[currI]$" to walk to, tag is "$MyPawn.PatrolNodes[currI].Tag);

	return MyPawn.PatrolNodes[currI];
}

///////////////////////////////////////////////////////////////////////////////
// Face the direction we are and be ready to kill someone
///////////////////////////////////////////////////////////////////////////////
function SetToTurret()
{
	SwitchToBestWeapon();
	MyPawn.SetMood(MOOD_Combat, 1.0);
	// Make sure he never tries for cover
	MyPawn.WillUseCover=0.0;
	SetNextState('ActAsTurret');
}

///////////////////////////////////////////////////////////////////////////////
// Have the player as your focus and watch him a while till you get bored
///////////////////////////////////////////////////////////////////////////////
function SetToWatchPlayer(FPSPawn PlayerP)
{
	local P2Player keepp;

	if(PlayerP == None)
		keepp = GetRandomPlayer();
	else
		keepp = P2Player(PlayerP.Controller);

	// check for some one to attack
	if(keepp != None)
	{
		PlayerSightReaction = keepp.SightReaction;
		InterestPawn = keepp.MyPawn;
		SetNextState('WatchPlayer');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Yell something first, then have the player as your focus and watch him a while till you get bored
///////////////////////////////////////////////////////////////////////////////
function SetToConfusedWatchPlayer(FPSPawn PlayerP)
{
	local P2Player keepp;

	if(PlayerP == None)
		keepp = GetRandomPlayer();
	else
		keepp = P2Player(PlayerP.Controller);

	// check for some one to attack
	if(keepp != None)
	{
		PlayerSightReaction = keepp.SightReaction;
		InterestPawn = keepp.MyPawn;
		SetNextState('WatchPlayer', 'Confused');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Player gets clapped at
///////////////////////////////////////////////////////////////////////////////
function SetToCheerPlayer(FPSPawn PlayerP)
{
	local P2Player keepp;

	if(PlayerP == None)
		keepp = GetRandomPlayer();
	else
		keepp = P2Player(PlayerP.Controller);

	// check for some one to attack
	if(keepp != None)
	{
		PlayerSightReaction = keepp.SightReaction;
		InterestPawn = keepp.MyPawn;
		Focus = None;
		FocalPoint = InterestPawn.Location;
		SetNextState('ClapAtSomething');
	}
}
///////////////////////////////////////////////////////////////////////////////
// Player gets laughed at
///////////////////////////////////////////////////////////////////////////////
function SetToLaughAtPlayer(FPSPawn PlayerP)
{
	local P2Player keepp;

	if(PlayerP == None)
		keepp = GetRandomPlayer();
	else
		keepp = P2Player(PlayerP.Controller);

	// check for some one to attack
	if(keepp != None)
	{
		PlayerSightReaction = keepp.SightReaction;
		InterestPawn = keepp.MyPawn;
		Focus = None;
		FocalPoint = InterestPawn.Location;
		SetNextState('LaughAtSomething');
	}
}
///////////////////////////////////////////////////////////////////////////////
// Make people start dead and at the end of a given animation
///////////////////////////////////////////////////////////////////////////////
function SetToDead()
{
	MyPawn.TakeDamage(MyPawn.Health, None, MyPawn.Location, vect(0, 0, 1), class'P2Damage');
	// If the skin is set to the burned texture, then copy it for the head
	if(MyPawn.Skins.Length > 0
		&& MyPawn.Skins[0] == MyPawn.BurnSkin)
		MyPawn.SwapToBurnVictim();
	SetNextState('Destroying');
}

///////////////////////////////////////////////////////////////////////////////
// end: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// The player can enter various InterestVolumes and if the NPC isn't doing anything
// too important, then he can notice the player (if he sees him). For instance,
// say the player is doing something stupid, like walking along on a counter top.
// The people that see this may be surprised and watch him do this.
///////////////////////////////////////////////////////////////////////////////
function HandlePlayerSightReaction(FPSPawn LookPawn, optional out byte StateChange)
{
	local P2Player p2p;

	p2p = P2Player(LookPawn.Controller);

	// If the player is doing something cool and I'm not doing anything important
	if(p2p != None
		&& p2p.SightReaction != MyPawn.EPawnInitialState.EP_Think
		&& InterestPawn == None
		&& Attacker == None)
	{
		if(MyPawn.SetupNextState(p2p.SightReaction, LookPawn))
		{
			GoToNextState();
			StateChange = 1;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Generate a safe range based on our cowardice
///////////////////////////////////////////////////////////////////////////////
function GenSafeRangeMin()
{
	UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;
	// We're more confident with a weapon
	if(MyPawn.bHasViolentWeapon)
		UseSafeRangeMin = UseSafeRangeMin/2;
	if(UseSafeRangeMin < 150)
		UseSafeRangeMin = 150;
}

///////////////////////////////////////////////////////////////////////////////
// In the mean time, just look for a roof to determine to use the straight
// path code
///////////////////////////////////////////////////////////////////////////////
function bool UseStraightPath()
{
	local vector usepoint;

	usepoint = MyPawn.Location;
	usepoint.z += HIGH_CEILING;

	return false;

	if(FastTrace(usepoint, MyPawn.Location))
	{
		//log("use straight path");
		return true;
	}
	else
	{
		//log("DON'T   use straight path");
		return false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Look for a collision and move away from this
///////////////////////////////////////////////////////////////////////////////
function AdjustPointForWalls(out vector EndPoint, vector StartPoint)
{
	local vector HitNormal, HitLocation;
	local Actor HitActor;

	HitActor = Trace(HitLocation, HitNormal, EndPoint, StartPoint, true);
	if(HitActor != None)
	{
		if(P2Pawn(HitActor) != None)
			CheckObservePawnLooks(P2Pawn(HitActor));
		// move away from obstruction
		MovePointFromWall(HitLocation, HitNormal, MyPawn);
		EndPoint = HitLocation;
	}
	// raise it up from the ground (to normal person height)
	RaisePointFromGround(EndPoint, MyPawn);
}

///////////////////////////////////////////////////////////////////////////////
// Set new target and pick path
///////////////////////////////////////////////////////////////////////////////
function bool HasStraightPath(vector HerePoint, vector DestPoint, float userad,
							  bool bStrictCheck)
{
	local vector startp, endp;
	local vector st1, end1, st2, end2;
	local vector startdir, checkdir;

	if(!FastTrace(DestPoint, HerePoint))
		return false;

	startdir = Normal(DestPoint - HerePoint);

	//log("start check "$startdir);

	// left 
	checkdir.x = -startdir.y;
	checkdir.y = startdir.x;
	checkdir.z = startdir.z;
	// move to the left by the radius and then test forward
	checkdir = userad*checkdir;
	startp = HerePoint + checkdir;
	endp = DestPoint + checkdir;
	//log("left start "$startp);
	//log("left end "$endp);
	// check to the left
	if(!FastTrace(endp, startp))
		return false;

	// record these for strict checks
	st1 = startp;
	end1 = endp;

	// It worked on the left, so check on the right
	// right
	checkdir.x = startdir.y;
	checkdir.y = -startdir.x;
	checkdir.z = startdir.z;
	// move to the left by the radius and then test forward
	checkdir = userad*checkdir;
	startp = HerePoint + checkdir;
	endp = DestPoint + checkdir;

	//log("right start "$startp);
	//log("right end "$endp);
	// now check for no obstructions to the right
	if(!FastTrace(endp, startp))
		return false;
/*
	// if we're strict, also check in a X-shape over the path you're looking
//	if(bStrictCheck)
//	{
//		log("PERFORMING STRICT TEST");
		// record these for strict checks
		st2 = startp;
		end2 = endp;
		// If either of these hit something, also fail here
		// check from end 2 to start 1
		if(!FastTrace(end2, st1))
			return false;
		// check from end 1 to start 2
		if(!FastTrace(end1, st2))
			return false;
//	}
*/
	// It worked! A straight path from HerePoint to DestPoint!
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// This is spot is hidden from the view of the player if you stand or crouch
///////////////////////////////////////////////////////////////////////////////
function bool IsBlockedSpot(vector HerePoint, vector DestPoint, float userad,
							  bool bStrictCheck)
{
	local vector startp, endp;
	local vector st1, end1, st2, end2;
	local vector startdir, checkdir;
//	log("check straight path");
/*
	// left 
	checkdir.x = -startdir.y;
	checkdir.y = startdir.x;
	// right
	checkdir.x = startdir.y;
	checkdir.y = -startdir.x;
*/
	if(FastTrace(DestPoint, HerePoint))
		return false;

	startdir = Normal(DestPoint - HerePoint);

	//log("start check "$startdir);

	// left 
	checkdir.x = -startdir.y;
	checkdir.y = startdir.x;
	checkdir.z = startdir.z;
	// move to the left by the radius and then test forward
	checkdir = userad*checkdir;
	startp = HerePoint + checkdir;
	endp = DestPoint + checkdir;
	//log("left start "$startp);
	//log("left end "$endp);
	// check to the left
	if(FastTrace(endp, startp))
		return false;

	// record these for strict checks
	st1 = startp;
	end1 = endp;

	// It worked on the left, so check on the right
	// right
	checkdir.x = startdir.y;
	checkdir.y = -startdir.x;
	checkdir.z = startdir.z;
	// move to the left by the radius and then test forward
	checkdir = userad*checkdir;
	startp = HerePoint + checkdir;
	endp = DestPoint + checkdir;

	//log("right start "$startp);
	//log("right end "$endp);
	// now check for no obstructions to the right
	if(FastTrace(endp, startp))
		return false;

	// It worked! A (probably) blocked path from HerePoint to DestPoint! Let's use it for hiding!
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// This is spot is hidden from the view of the player if you crouch here
///////////////////////////////////////////////////////////////////////////////
function bool IsBlockedCrouchSpot(vector HerePoint, vector DestPoint, float userad,
							  bool bStrictCheck)
{
	local vector startp, endp;
	local vector st1, end1, st2, end2;
	local vector startdir, checkdir;
//	log("check straight path");
/*
	// left 
	checkdir.x = -startdir.y;
	checkdir.y = startdir.x;
	// right
	checkdir.x = startdir.y;
	checkdir.y = -startdir.x;
*/
	if(FastTrace(DestPoint, HerePoint))
		return false;

	startdir = Normal(DestPoint - HerePoint);

	//log("start check "$startdir);

	// left 
	checkdir.x = -startdir.y;
	checkdir.y = startdir.x;
	checkdir.z = startdir.z;
	// move to the left by the radius and then test forward
	checkdir = userad*checkdir;
	startp = HerePoint + checkdir;
	endp = DestPoint + checkdir;
	//log("left start "$startp);
	//log("left end "$endp);
	// check to the left
	if(FastTrace(endp, startp))
		return false;

	// record these for strict checks
	st1 = startp;
	end1 = endp;

	// It worked on the left, so check on the right
	// right
	checkdir.x = startdir.y;
	checkdir.y = -startdir.x;
	checkdir.z = startdir.z;
	// move to the left by the radius and then test forward
	checkdir = userad*checkdir;
	startp = HerePoint + checkdir;
	endp = DestPoint + checkdir;

	//log("right start "$startp);
	//log("right end "$endp);
	// now check for no obstructions to the right
	if(FastTrace(endp, startp))
		return false;
	// It worked! A (probably) blocked path from HerePoint to DestPoint! Let's use it for hiding!
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Go after our attacker again
///////////////////////////////////////////////////////////////////////////////
function FoundHim(FPSPawn OldA)
{
	//log(self$" FoundHim "$OldA);
	SetAttacker(OldA);
	GotoStateSave('ShootAtAttacker');
}

///////////////////////////////////////////////////////////////////////////////
// Check to see if you want to observe this pawn's personal looks (does he have a
// gun, is he naked)
///////////////////////////////////////////////////////////////////////////////
function CheckObservePawnLooks(FPSPawn LookAtMe)
{
	SetRotation(MyPawn.Rotation);

	if(/* LookAtMe.IsA('Bystander')
		&& */ CanSeePawn(MyPawn, LookAtMe))

		ActOnPawnLooks(LookAtMe);
}

///////////////////////////////////////////////////////////////////////////////
// Find the point to run to, on the side of the person in your way
// returns true if it was a 'clean' get
// returns false if there was something that it hit, when trying to grab
// a point nearby
///////////////////////////////////////////////////////////////////////////////
function bool GetSideOfHumanObstacle(FPSPawn ObstructingPawn, FPSPawn GoalPawn, out vector usepoint)
{
	local Actor HitActor;
	local vector HitNormal, HitLocation;
	local vector guydir;
	local vector newmovedir;
	local vector rundir;
	local float movedist;

	// New method, run up next to where the guy was blocking you. Run perp to you and
	// the attacker, but next to ObstructingPawn.
	// Well, next to means, from within the Collision radii to around the AttackRange. 
	movedist = ObstructingPawn.CollisionRadius + MyPawn.CollisionRadius + Rand(4*MyPawn.CollisionRadius);
	guydir = Normal(GoalPawn.Location - MyPawn.Location);
	// He will either run (local) to the right or left. So pick one
	rundir.x=0;
	rundir.y=0;
	if(FRand() <= 0.5)
		rundir.z = 1.0;
	else
		rundir.z = -1.0;
	// Get the perpendicular direction
	newmovedir = guydir cross rundir;
	// Add the distance to move, along the perp direction, based on the middle
	// guy's (the obstruction) position.
	usepoint = (movedist)*newmovedir + ObstructingPawn.Location;

	// Move our destination based on things in the way
	HitActor = Trace(HitLocation, HitNormal, usepoint, MyPawn.Location, false);

	if(HitActor != None)
	{
		MovePointFromWall(HitLocation, HitNormal, MyPawn);
		usepoint = HitLocation;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Go into a state to say hi to people
// Requires focus set to the passerby
///////////////////////////////////////////////////////////////////////////////
function TryToGreetPasserby(FPSPawn PasserBy, bool bIsGimp, bool bIsCop, optional out byte StateChange)
{
	if(bIsCop
		&& !bHiToCop
		&& VSize(PasserBy.Location - MyPawn.Location) < HI_AT_COP_RADIUS
		&& !MyPawn.IsA('Police')		// Don't greet the dude-cop in They Hate Me mode.
		)
	{
		if(Attacker != PasserBy)
		{
			Focus = PasserBy;
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			GotoStateSave('GreetDudeCop');
			StateChange = 1;
			return;
		}
	}
	else if(bIsGimp
		&& VSize(PasserBy.Location - MyPawn.Location) < LAUGH_AT_GIMP_RADIUS)
	{
		if(Attacker != PasserBy)
		{
			Focus = PasserBy;
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			GotoStateSave('GreetGimp');
			StateChange = 1;
			return;
		}
	}
	else
	{
		if(P2Pawn(PasserBy) != None)
			StartConversation(P2Pawn(PasserBy), StateChange);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Turn and try to fire at this actor
///////////////////////////////////////////////////////////////////////////////
function bool FireWeaponAt(Actor ShootActor)
{
	Focus = ShootActor;

	if( MyPawn.Weapon!=None )
	{
		if ( !MyPawn.Weapon.HasAmmo() )
			return  false;

		SetRotation(MyPawn.Rotation);
		MyPawn.Weapon.BotFire(false);
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Go back to our hands
///////////////////////////////////////////////////////////////////////////////
function SwitchToHands()
{
	// STUB--defined in bystander and police
}

///////////////////////////////////////////////////////////////////////////////
// We've stated a weapon we want to switch to
///////////////////////////////////////////////////////////////////////////////
function bool SwitchToThisWeapon(int GroupNum, int OffsetNum)
{
	local float rating;
	local Inventory inv;
	local bool bFoundIt;

	if ( Pawn.Inventory == None 
		|| (Pawn.Weapon.InventoryGroup == GroupNum 
			&& Pawn.Weapon.GroupOffset == OffsetNum))
		return false;

	StopFiring();
	inv = Pawn.Inventory;

//	log("Group num"$GroupNum);
//	log("Offset num "$OffsetNum);

	while(inv != None
		&& !bFoundIt)
	{
//		log("inv "$inv);
//		log("inv group "$inv.InventoryGroup);
//		log("inv offset "$inv.GroupOffset);
		if(Weapon(inv) != None 
			&& inv.InventoryGroup == GroupNum 
			&& inv.GroupOffset == OffsetNum)
			bFoundIt=true;
		else
			inv = inv.Inventory;
	}
	if(bFoundIt)
		Pawn.PendingWeapon = Weapon(inv);
	else
		return bFoundIt;
//	log("success "$Pawn.PendingWeapon);
//	log("w group "$Pawn.PendingWeapon.InventoryGroup);
//	log("w offset "$Pawn.PendingWeapon.GroupOffset);
//	log("pending level "$Pawn.PendingWeapon.InventoryGroup);
	if ( Pawn.PendingWeapon == Pawn.Weapon )
		Pawn.PendingWeapon = None;
	if ( Pawn.PendingWeapon == None )
		return bFoundIt;

	if ( Pawn.Weapon == None )
		Pawn.ChangedWeapon();

	if ( Pawn.Weapon != Pawn.PendingWeapon )
		Pawn.Weapon.PutDown();

	return bFoundIt;
}

///////////////////////////////////////////////////////////////////////////////
// Given the group, find the weapon that's furtherst down in the offsets. 
// For instance, group 0, should be Shovel, Shocker, Baton. If he has 
// any of those weapons, and we call this, it will pick the furthest one
// down the list
///////////////////////////////////////////////////////////////////////////////
function SwitchToLastWeaponInGroup(int GroupNum)
{
	local Inventory inv, last;
	local int lastoffset;

	if ( Pawn.Inventory == None )
		return;

	StopFiring();
	inv = Pawn.Inventory;
	lastoffset = -1;

	while(inv != None)
	{
		if(Weapon(inv) != None)
		{
			if(Weapon(inv).AmmoType.HasAmmo())
			{
				if(inv.InventoryGroup == GroupNum
					&& inv.GroupOffset > lastoffset)
				{
					last = inv;
					lastoffset = inv.GroupOffset;
				}
			}
		}

		inv = inv.Inventory;
	}

	if(last != None)
		Pawn.PendingWeapon = Weapon(last);
	else
		return;

	if ( Pawn.PendingWeapon == Pawn.Weapon )
		Pawn.PendingWeapon = None;
	if ( Pawn.PendingWeapon == None )
		return;

	if ( Pawn.Weapon == None )
		Pawn.ChangedWeapon();

	if ( Pawn.Weapon != Pawn.PendingWeapon 
		&& Pawn.PendingWeapon != None)
		Pawn.Weapon.PutDown();
}

///////////////////////////////////////////////////////////////////////////////
// This function checks first if we should be switching to our best weapon
// just yet.
///////////////////////////////////////////////////////////////////////////////
function bool DecideToPickBestWeapon()
{
	return (P2Weapon(Pawn.Weapon) == None
			|| P2Weapon(Pawn.Weapon).ViolenceRank <= 0);
}

///////////////////////////////////////////////////////////////////////////////
// First check if this pawn can use distance based attacks, with two weapons.
// Switch to the best one there, first. If not, then just use your best weapon
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToBestWeapon()
{
	local float usedist;
	
	// If we're missing limbs, don't bother, just crawl
	if (MyPawn.bMissingLimbs)
	{
        DoDeathCrawlAway(true);
        return;
    }

	// Check for distance-based weapon changing
	if(MyPawn.WeapChangeDist > 0
		&& Attacker != None)
	{
		usedist = VSize(MyPawn.Location - Attacker.Location);
		
		// If he doesn't have a proper weapon yet, then don't include a buffer
		// in the distance check. This will ensure he picks one or the other
		// for his new weapon
		if(MyPawn.Weapon == None
			|| P2Weapon(MyPawn.Weapon).ViolenceRank == 0)
		{
			// He's too far away and we're not using our far weapon, so switch
			if(usedist > MyPawn.WeapChangeDist)
			{
				SwitchToThisWeapon(MyPawn.FarWeap.default.InventoryGroup, 
									MyPawn.FarWeap.default.GroupOffset);
			}
			// He's too close and we're not using our close weapon, so switch
			else
			{
				SwitchToThisWeapon(MyPawn.CloseWeap.default.InventoryGroup, 
									MyPawn.CloseWeap.default.GroupOffset);
			}
		}
		else
		{
			// He's too far away and we're not using our far weapon, so switch
			if(usedist > WEAP_FAR_BUFFER*MyPawn.WeapChangeDist
				&& (MyPawn.Weapon == None
					|| MyPawn.Weapon.class != MyPawn.FarWeap))
			{
				SwitchToThisWeapon(MyPawn.FarWeap.default.InventoryGroup, 
									MyPawn.FarWeap.default.GroupOffset);
			}
			// He's too close and we're not using our close weapon, so switch
			else if(usedist < WEAP_CLOSE_BUFFER*MyPawn.WeapChangeDist
				&& (MyPawn.Weapon == None
					|| MyPawn.Weapon.class != MyPawn.CloseWeap))
			{
				SwitchToThisWeapon(MyPawn.CloseWeap.default.InventoryGroup, 
									MyPawn.CloseWeap.default.GroupOffset);
			}
		}
		// Make WorkFloat our twitch *wait* time (shorter than twitch), some pawns can modify this
		WorkFloat = (MyPawn.GetTwitch())/TWITCH_DIVIDER;
	}
	else // if not, then just use your best weapon
	{
		if(DecideToPickBestWeapon())
			Super.SwitchToBestWeapon();
		// Set twitch time
		WorkFloat = (MyPawn.GetTwitch())/TWITCH_DIVIDER;
	}
}

///////////////////////////////////////////////////////////////////////////////
// With the temper modifying the damage, check to get more angry
///////////////////////////////////////////////////////////////////////////////
function GetAngryFromDamage(float DamageIncurred)
{
	MyPawn.Anger += 0.05*(MyPawn.Temper*DamageIncurred);
	if(MyPawn.Anger > 1.0)
		MyPawn.Anger = 1.0;
}

///////////////////////////////////////////////////////////////////////////////
// Generically get more angry
///////////////////////////////////////////////////////////////////////////////
function GetMoreAngry(float addtemper)
{
	MyPawn.Anger += addtemper;
	if(MyPawn.Anger > 1.0)
		MyPawn.Anger = 1.0;
}

///////////////////////////////////////////////////////////////////////////
// Piss is hitting me, decide what to do
// Used the cheesy bool bPuke so we wouldn't have another
// function to ignore in all the states
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
	// Only none-turrets use this
	if(MyPawn.PawnInitialState != MyPawn.EPawnInitialState.EP_Turret)
	{
	//	log(self$" is getting pissed/puked on by "$Other);
		InterestPawn=Other;
		GetAngryFromDamage(PISS_FAKE_DAMAGE);
		MakeMoreAlert();

		if(bPuke)
			// Definitely throw up from puke on me
			CheckToPuke(, true);
		else
			// possibly throw up from the yuckiness
			GotoStateSave('InvestigateWetness');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Setup a move out of the way
///////////////////////////////////////////////////////////////////////////////
function SetupMoveForRunner(P2Pawn Asker)
{
	local vector destpoint, checkrot;
	local int goright;

	if(Asker != Attacker)
	{
		if(Rand(2) == 0)
			goright = 1;
		else
			goright =-1;

		checkrot = vector(MyPawn.Rotation);
		// Handle this pawn
		destpoint = MyPawn.Location;//-FRand()*SIDE_STEP_BASE_DIST
		destpoint.x += goright*(FORWARD_RUN_DIST)*checkrot.y + (FRand()*FORWARD_RUN_DIST)*checkrot.x;
		destpoint.y -= goright*(FORWARD_RUN_DIST)*checkrot.x + (FRand()*FORWARD_RUN_DIST)*checkrot.y;
		// Also, aim the collision point down somewhat, so that it's more
		// likely to hit little things in the way, and is more likely to
		// stop an ugly collision. Only do this for the tightest end point
		// area, so that if this thing ends early, he'll still know he hit a valid
		// end point (if the destination point is too high off the ground, he'll
		// never think he's reached it, and keep running towards it)
		destpoint.z -= TIGHT_END_RADIUS;

		// check for walls
		AdjustPointForWalls(destpoint, MyPawn.Location);

		if(VSize(destpoint - MyPawn.Location) <= 2*MyPawn.CollisionRadius)
		{
			//log(MyPawn$" go opposite instead");
			goright = -goright;
			destpoint = MyPawn.Location;//-FRand()*SIDE_STEP_BASE_DIST
			destpoint.x += goright*(FORWARD_RUN_DIST)*checkrot.y + (FRand()*FORWARD_RUN_DIST)*checkrot.x;
			destpoint.y -= goright*(FORWARD_RUN_DIST)*checkrot.x + (FRand()*FORWARD_RUN_DIST)*checkrot.y;
			AdjustPointForWalls(destpoint, MyPawn.Location);
		}

		//log("go right "$goright$" dest "$destpoint);

		MovePoint = destpoint;
		MoveTarget = None;
		FocalPoint = destpoint;
		Focus = None;

		bPreserveMotionValues=true;
		// If we've already saved our last state, don't do it again
		if(IsInState('WaitOnOtherGuy')
			|| IsInState('OnePassMove'))
			GotoState('StepForward');
		//else if(AllowOldState())
		else
			GotoStateSave('StepForward');
		//else
		//	GotoState('StepForward');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Calc and switch states to backstep
///////////////////////////////////////////////////////////////////////////////
function SetupBackStep(float BaseDist, float RandDist)
{
	local vector destpoint, checkrot;

	if(Attacker == None)
	{
		checkrot = vector(MyPawn.Rotation);
		// Handle this pawn
		destpoint = MyPawn.Location;
		destpoint.x -= (BaseDist+FRand()*RandDist)*checkrot.x;
		destpoint.y -= (BaseDist+FRand()*RandDist)*checkrot.y;

		// check for walls
		//GetMovePointOrHugWalls(destpoint, MyPawn.Location, FRand()*128 + 128, true);
		AdjustPointForWalls(destpoint, MyPawn.Location);

		MovePoint = destpoint;
		MoveTarget = None;
		// Don't walk backwards, that looks too goofy, turn and walk to your target
		FocalPoint = destpoint;
		Focus = None;

		bPreserveMotionValues=true;
		//if(AllowOldState())
			GotoStateSave('OnePassMove');
		//else
		//	GotoState('OnePassMove');
	}
}

///////////////////////////////////////////////////////////////////////////
// Something annoying, but not really gross or life threatening
// has been done to me, so check to maybe notice
///////////////////////////////////////////////////////////////////////////
function InterestIsAnnoyingUs(Actor Other, bool bMild)
{
	local byte StateChange;

	if(Attacker == None)
	{
		// Check first if the guy talking to us is in our home!
		if(P2Pawn(Other) != None)
			CheckForIntruder(P2Pawn(Other), StateChange);

		if(StateChange != 1)
		{
			InterestActor=Other;

			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			// Be annoyed with your Interest pawn
			if(bMild)
				GotoState('GetAnnoyedWithInterest');
			else
				GotoState('GetAngryWithInterest');
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// A bouncing, disembodied head (or dead body) just hit us, decide what to do
///////////////////////////////////////////////////////////////////////////
function GetHitByDeadThing(Actor DeadThing, FPSPawn KickerPawn)
{
	local Actor UseInterest;

	if(Attacker == None)
	{
		if((KickerPawn == None
				&& CanSeePoint(MyPawn, DeadThing.Location, 0.1))
			|| (KickerPawn != None
				&& CanSeePawn(MyPawn, KickerPawn, 0.1)))
		{
			// Clear our instigator after interaction
			DeadThing.Instigator = None;
			// If you're a wimp, run away screaming
			if(!MyPawn.bHasViolentWeapon)
			{
				if(KickerPawn != None)
					SetAttacker(KickerPawn);
				DangerPos = DeadThing.Location;
				// Decide current safe min
				UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;
				if(Attacker != None)
					GotoStateSave('FleeFromAttacker');
				else
					GotoStateSave('FleeFromDanger');
			}
			else // if you're tough, don't put up with it
			{
				// Get mad at the guy kicking it and kick it back!
				InterestPawn = KickerPawn;
				Focus = DeadThing;
				InterestActor = DeadThing;
				GotoStateSave('KickHeadBack');
			}
		}
		else // Can't see it so just turn around.
		{
			// Clear our instigator after interaction
			DeadThing.Instigator = None;
			if(KickerPawn != None)
				UseInterest = KickerPawn;
			else
				UseInterest = DeadThing;

			InterestIsAnnoyingUs(UseInterest, true);
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// A rocket is chasing me! Run!
///////////////////////////////////////////////////////////////////////////
function RocketIsAfterMe(FPSPawn Shooter, Actor therocket)
{
	// If we can see the person we're after, tell them
	if(FastTrace(MyPawn.Location, therocket.Location))
	{
		DangerPos = therocket.Location;
		DangerPos.x += ((Rand(256)) - 128);
		DangerPos.y += ((Rand(256)) - 128);
		MyPawn.DropBoltons(MyPawn.Velocity);
		// Decide current safe min
		UseSafeRangeMin = 10*MyPawn.SafeRangeMin;
		InterestPawn = Shooter;
		SetAttacker(Shooter);
		// If we can see  it, either attack the player or run, if we can't
		// do this afterwards, but be confused at first, and spin around to see the rocket
		if(CanSeePoint(MyPawn, therocket.Location, 0.1))
		{
			if(MyPawn.bHasViolentWeapon
				&& Attacker != None)
				GotoStateSave('AssessAttacker');
			else
				GotoStateSave('FleeFromDanger');
		}
		else
		{
			Focus = therocket;
			InterestActor = therocket;
			if(MyPawn.bHasViolentWeapon
				&& Attacker != None)
				SetNextState('AssessAttacker');
			else
				SetNextState('FleeFromDanger');
			GotoStateSave('ConfusedByDanger');
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// Generally only used by p2mocappawn to see which crouch anim to use.
///////////////////////////////////////////////////////////////////////////
function bool IsBegging()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////
// Gas is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function GettingDousedInGas(P2Pawn Other)
{
	//log("i'm getting gas poured on me "$self);
//	log("i'm doing it "$Other);
	InterestPawn=Other;
	GetAngryFromDamage(GAS_FAKE_DAMAGE);
	MakeMoreAlert();

	GotoStateSave('ReactToGasoline');
}

///////////////////////////////////////////////////////////////////////////////
// Override whatever you're saying and make puking noises
///////////////////////////////////////////////////////////////////////////////
function ActuallyPuking()
{
	// STUB called in puking states
}

///////////////////////////////////////////////////////////////////////////
// Check to see if you can/want to puke
///////////////////////////////////////////////////////////////////////////
function CheckToPuke(optional float modifier, optional bool bForce, optional out byte StateChange)
{
	//	log(self$" Stomach possible "$MyPawn.Stomach*modifier$" stomach is "$MyPawn.Stomach$" force is "$bForce);
	local PlayerController Pisser;

	if((MyPawn.Stomach < 1.0
		&& FRand() >= (MyPawn.Stomach*modifier)
		&& MyPawn.PukeCount == 0)
		|| bForce)
	{
		DangerPos = MyPawn.Location;
		GenSafeRangeMin();
		SetNextState('FleeFromDanger');
		GotoState('DoPuking');
		StateChange=1;
		// We made them puke! Give them an achievement
		//log("got pissed on"@bRKellyTest,'Debug');
		if (bRKellyTest)
			foreach DynamicActors(class'PlayerController',Pisser)
				if(Level.NetMode != NM_DedicatedServer ) Pisser.GetEntryLevel().EvaluateAchievement(Pisser,'PissInFace');
		bRKellyTest = False;
		return;
	}
	bRKellyTest = False;
}

///////////////////////////////////////////////////////////////////////////
// Tell people around me to get down
// But really only shout if it anyone was there to hear it.
///////////////////////////////////////////////////////////////////////////
function bool ShoutGetDown(vector ShoutPos, 
						   optional bool bShoutAnyway, 
						   optional out P2Pawn Shoutee)
{
	local P2Pawn CheckP;
	local int peoplecount;
	local byte StateChange;
	local LambController lambc;

	// First send the message to people to get down. In the process,
	// count how many people heard me. If no one heard me, then don't play
	// the audio! Tricky!
	// Or we can override that coolnes with bShoutAnyway, but still look 
	// for people to tell this too
	peoplecount=0;
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, SHOUT_GET_DOWN_RADIUS, ShoutPos)
	{
		if(CheckP != MyPawn									// not me
			&& CheckP != Attacker							// not my attacker
			&& CheckP.Health > 0							// live people are listening
			&& FastTrace(MyPawn.Location, CheckP.Location)) // not on the other side of a wall
		{
			if(Shoutee == None
				&& !SameGang(CheckP))
				Shoutee = CheckP;	// return some possible enemy so he can stare at them

			// only yell at bystanders to get down FIX!!!
			// Tell them who's shouting at me
			lambc = LambController(CheckP.Controller);
			if(lambc != None)
			{
				StateChange = 0;
				lambc.RespondToTalker(MyPawn, Attacker, TALK_getdown, StateChange);
			}
			peoplecount++;
		}
	}

	// If anyone heard me, then play the audio
	if(peoplecount > 0
		|| bShoutAnyway)
	{
		PrintDialogue("Get Down!");
		SayTime = Say(MyPawn.myDialog.lGetDown);
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// See if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function DecideToListen(P2Pawn Shouter)
{
	if(MyPawn.Physics == PHYS_WALKING)
	{
		// If I'm a rebel or a turret, yell something and just stand there
		if(FRand() <= MyPawn.Rebel
			|| MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
		{
			PrintDialogue("Go screw yourself!");
			Say(MyPawn.myDialog.lDefiant);
		}
		// otherwise, turn and listen to him
		InterestPawn = Shouter;
		GotoStateSave('WatchFireFromSafeRange', 'ListenToFocus');
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Run to where the attacker is, and then stare at him (unless he's the dude/gimp
// and has a weapon out, in which case, you'll naturally attack again
///////////////////////////////////////////////////////////////////////////////
function LostAttackerToDisguise(FPSPawn LookAtMe)
{
	if(Attacker == LookAtMe)
	{
		InterestPawn = Attacker;
		FullClearAttacker();
		DangerPos = LookAtMe.Location;
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		SetNextState('WatchACop');
		SetEndPoint(DangerPos, CHECK_DANGER_DIST);
		GotoStateSave('RunToTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////////////////////////
function RespondToCopBother()
{
	if(MyPawn.Physics == PHYS_WALKING)
	{
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		GotoStateSave('RespondWhatsWrong');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Point out where this attacker is to someone else
///////////////////////////////////////////////////////////////////////////////
function RatOutAttacker(P2Pawn TheAttacker, P2Pawn Asker)
{
	SetAttacker(TheAttacker);
	InterestPawn = Asker;
	GotoStateSave('RatOutTarget');
}

/*
///////////////////////////////////////////////////////////////////////////////
// Someone is telling us about someone attacking us, or stealing or something
///////////////////////////////////////////////////////////////////////////////
function ReportOnViolence(VE_Type ViolenceReported, 
						  FPSPawn TheAttacker, Pawn Teller, optional vector DangerLoc)
{
	switch(VE_Type)
	{
		case VE_HearWhoAttacked:
			break;
		case VE_HearAboutKiller:
			break;
		case VE_HearAboutDangerHere:
			break;
		case VE_HearAboutRobber:
			break;
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// Get a message from someone who said this guy attacked you
///////////////////////////////////////////////////////////////////////////////
function HearWhoAttackedMe(FPSPawn TheAttacker, Pawn Teller)
{
	// We know who did it, so focus on him now
	// Maybe check the validity of who told us this?
	SetAttacker(TheAttacker);
	Focus = TheAttacker;
	PrintDialogue("Thanks! ");
	Say(MyPawn.myDialog.lThanks);
	GotoStateSave('AssessAttacker');
}

///////////////////////////////////////////////////////////////////////////////
// Get a message from someone telling you about a 'known' killer
///////////////////////////////////////////////////////////////////////////////
function HearAboutKiller(vector DangerLoc, FPSPawn TheAttacker, Pawn Teller, float WaitTime)
{
	// STUB
	// normal people don't get this
}

///////////////////////////////////////////////////////////////////////////////
// Get a message from someone telling you about danger
///////////////////////////////////////////////////////////////////////////////
function HearAboutDangerHere(vector DangerLoc, Pawn Teller, float WaitTime)
{
	// STUB
	// normal people don't get this
}

///////////////////////////////////////////////////////////////////////////////
// Stop and watch the parade
///////////////////////////////////////////////////////////////////////////////
function SetupWatchParade(Actor OriginActor, out byte StateChange)
{
	local PathNode pn, closepn;
	local float closest, usedist, usedot;
	local vector PickPoint, usevect, dir, pointdir, usecross;
	local bool bTryForMove;
	local Actor lp1, lp2;	// loop points guy is marching between

	if(FPSPawn(OriginActor) != None
		&& PersonController(FPSPawn(OriginActor).Controller) != None
		&& InterestPawn == None
		&& Attacker == None)
	{
		InterestPawn = FPSPawn(OriginActor);
		// Find a spot to the left or right of the parade to move
		// to when they come by
		// First, take the guy we're looking at, and move to his right or left
		// looking for a point outside of the parade to move to
		PickPoint = InterestPawn.Location;
		// Check direction
		lp1 = PersonController(InterestPawn.Controller).OldEndGoal;
		lp2 = InterestPawn.MyLoopPoint;
		pointdir=lp2.Location - lp1.Location;
		pointdir.z=0;
		pointdir=Normal(pointdir);
		dir=InterestPawn.Location - MyPawn.Location;
		dir.z=0;
		dir=Normal(dir);
		usedot = dir dot pointdir;
		usecross = pointdir cross dir;
		//log(self$" dir "$dir$" pointdir "$pointdir$" cross from you "$usecross$" loop1 "$lp1$" loop2 "$lp2);
		// Check to make sure you're in the way first, then 
		// find out how to move out of the way
		if(abs(usedot) > PARADE_MOVE_MIN_DOT)
		{
			bTryForMove=true;
			// Postive means check right
			if(usecross.z > 0)
			{
				usevect.x = pointdir.y;
				usevect.y = -pointdir.x;
			}
			// negative dot means go left
			else 
			{
				usevect.x = -pointdir.y;
				usevect.y = pointdir.x;
			}
		}

		if(bTryForMove)
		{
			usevect.z = 0;
			//log(self$" looking at pawn here "$InterestPawn.Location$" this pawn "$InterestPawn);
			PickPoint = PickPoint + PARADE_MOVE_FORWARD_OFFSET*pointdir + PARADE_MOVE_SIDE_OFFSET*usevect;
			//log(self$" found this spot "$PickPoint);

			CheckMoveDest(PickPoint, InterestPawn.Location, usedist, false);
			RaisePointFromGround(PickPoint, InterestPawn);
			//log(self$" moving this spot "$PickPoint);

			closest = PARADE_PATHNODE_RADIUS;
			foreach RadiusActors(class'PathNode', pn, PARADE_PATHNODE_RADIUS, PickPoint)
			{
				usedist = VSize(PickPoint - pn.Location);
				if(usedist < closest)
				{
					closest = usedist;
					closepn = pn;
				}
			}
		}
		//else
		//	log(self$" just standing and watching");

		// Move out of the way
		if(closepn != None)
		{
			//log(self$" moving to this pathnode "$closepn$" loc "$closepn.Location);
			SetEndGoal(closepn, 2*DEFAULT_END_RADIUS);
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('WatchParade');
			GotoStateSave('WalkToTarget');
		}
		else	// Just stand and watch
			GotoStateSave('WatchParade');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do when you see someone's head explode
///////////////////////////////////////////////////////////////////////////////
function WatchHeadExplode(P2Pawn Explodee, optional out byte StateChange)
{
	//log(MyPawn$": seeing if I can see head");
	// See if we can actually see the body
	if(Explodee != None
		&& CanSeePawn(MyPawn, Explodee))
	{
		if (P2MocapPawn(Explodee) == None || P2MocapPawn(Explodee).MyRace != RACE_Skeleton)
		{
			//log(MyPawn$": SAW THE HEAD!!!! ");
			UseSafeRangeMin = (1.0 - MyPawn.Curiosity)*MyPawn.SafeRangeMin;		

			CheckToPuke(HEAD_EXPLODED_GROSS_MOD,,StateChange);
		}
		else // Cheer and/or laugh at the dead skeleton
			WatchFunnyThing(Explodee);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do if you saw a guy get hit by a dead cat
///////////////////////////////////////////////////////////////////////////////
function WatchDeadCatHitGuy(P2Pawn HitGuy, P2Pawn IdidIt, optional out byte StateChange)
{
	//log(MyPawn$" look for cat hit ");
	if(HitGuy != None
		&& CanSeePawn(MyPawn, HitGuy))
	{
		SetAttacker(IdidIt);
		// maybe do something
		InterestPawn = IdidIt;
		SetNextState('WatchForViolence');
		ViolenceWatchDeath(HitGuy, true, StateChange);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do about a disembodied head
///////////////////////////////////////////////////////////////////////////////
function CheckDeadHead(Actor DeadHead, optional out byte StateChange)
{
	// See if we can actually see the body
	// or if it's the dude, always care about it.
	if(InterestActor == None
		&& CanSeePoint(MyPawn, DeadHead.Location, 0.3))
	{
		//log(MyPawn$": sees a dead head ");
		UseSafeRangeMin = (1.0 - MyPawn.Curiosity)*MyPawn.SafeRangeMin;
		if(UseSafeRangeMin < 2*DEFAULT_END_RADIUS)
			UseSafeRangeMin = 2*DEFAULT_END_RADIUS;

		InterestActor = DeadHead;
		GotoStateSave('InvestigateDeadThing');
		StateChange=1;
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do about a dead body
// If it's the dude, then we can always see it, even if we're turned around
// this is to get more people to notice the dude.
///////////////////////////////////////////////////////////////////////////////
function CheckDeadBody(P2Pawn DeadBodyPawn, optional out byte StateChange)
{
	// See if we can actually see the body
	// or if it's the dude, always care about it.
	if((Attacker == None
		|| Attacker == DeadBodyPawn)
		&& DeadBodyPawn != None
		&& ((IgnoreBody != DeadBodyPawn
				&& CanSeePawn(MyPawn, DeadBodyPawn, 0.1))
			|| DeadBodyPawn.bPlayer))
	{
		//log(MyPawn$": sees a dead body ");
		InterestActor = DeadBodyPawn;
		InterestPawn = DeadBodyPawn;
		IgnoreBody=DeadBodyPawn;	// Don't look at this body any more (until you've looked at another body)
		GotoStateSave('InvestigateDeadThing');
		StateChange=1;
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////
// We just saw something funny and we might laugh at it
///////////////////////////////////////////////////////////////////////////////
function WatchFunnyThing(P2Pawn LaughTarget)
{
	if(Rand(2) == 0
		&& CanSeePawn(MyPawn, LaughTarget))
	{
		InterestPawn = LaughTarget;
		Focus = None;
		FocalPoint = InterestPawn.Location;
		GotoStateSave('LaughAtSomething');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to about that tastey donut before you
///////////////////////////////////////////////////////////////////////////////
function CheckDesiredThing(Actor DesireMaker, class<TimedMarker> blip, optional out byte StateChange)
{
	local float mydesirerand, myrealdesire;

	// See if it's a marker we care about (human's don't care about catnip, for instance)
	mydesirerand = FRand();

	if(blip == class'MoneyMarker')
		myrealdesire = MyPawn.Greed;
	else if(blip == class'DonutMarker')
		myrealdesire = MyPawn.DonutLove;
	else
		return;

	// Since we care about this thing, check to see if we can see it
	if(DesireMaker != None
		&& CanSeePoint(MyPawn, DesireMaker.Location))
	{
		//log(MyPawn$": sees it, desire level "$myrealdesire$" and my real desire "$mydesirerand$" desire type "$blip.DesireType);

		if(mydesirerand < myrealdesire)
		{
			// Record each person tricked by donuts
			if(blip == class'DonutMarker'
				&& MyPawn.IsA('Police'))
			{			
				if(P2GameInfoSingle(Level.Game) != None
					&& P2GameInfoSingle(Level.Game).TheGameState != None)
				{
					P2GameInfoSingle(Level.Game).TheGameState.CopsLuredByDonuts++;
				}
			}		

			Focus = DesireMaker;	// Focus here holds the item we're interested, be sure not to clear it!
			if(class<DesiredThingMarker>(blip).default.bRunToDesire)
				GotoStateSave('InvestigateDesiredThingRun');
			else
				GotoStateSave('InvestigateDesiredThing');
			StateChange=1;
			return;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Wipe my face off of all the fluid on it
///////////////////////////////////////////////////////////////////////////////
function CheckWipeFace(optional out byte StateChange)
{
	if(MyPawn.HeadIsDripping())
	{
		StateChange = 1;
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		GotoStateSave('WipeFace');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Respond to someone asking you something in a negative, random manner
///////////////////////////////////////////////////////////////////////////////
function RespondToQuestionNegatively(P2Pawn Asker)
{
	if(IsInState('LegMotionToTarget'))
	{
		bPreserveMotionValues=true;
		SetNextState(GetStateName());
		//log("recording and will return to "$GetStateName());
	}
	Focus = Asker;
	GotoStateSave('RespondNegative');
}

///////////////////////////////////////////////////////////////////////////////
// Make sure whoever is asking you this is really talking to you
// And make sure they still have the clipboard out
///////////////////////////////////////////////////////////////////////////////
function CheckTalkerAttention(optional out byte StateChange)
{
	// STUB -- handled during petition code
}

///////////////////////////////////////////////////////////////////////////////
// Someone's verbally threatened you.. attack or run
///////////////////////////////////////////////////////////////////////////////
function HandleMeanTalker(FPSPawn Meanie)
{
	InterestPawn = Meanie;
	SetAttacker(InterestPawn);
	DangerPos = InterestPawn.Location;
	if(MyPawn.bHasViolentWeapon)
		GotoStateSave('AssessAttacker');
	else
		GotoStateSave('FleeFromAttacker');
}

///////////////////////////////////////////////////////////////////////////////
// Setup the person to check about donating money.. someone is talking
// to me about donating money, see if I care
///////////////////////////////////////////////////////////////////////////////
function DonateSetup(Pawn Talker, out byte StateChange)
{
	local P2Player p2p;
	local PersonController per;

	if(MyPawn.Physics == PHYS_WALKING
		&& Attacker != Talker
		&& FPSPawn(Talker).MyBodyFire == None
		&& !MyPawn.bMissingLimbs)
	{
		bPreserveMotionValues=true;
		Focus = Talker;

		p2p=P2Player(Talker.Controller);
		if(p2p != None)
		{
			CurrentFloat = p2p.SayTime;
			p2p.InterestPawn = MyPawn;
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
// You've been told by TellingPawn to get out of his way. Decide what to do
///////////////////////////////////////////////////////////////////////////////
function GetOutOfMyWay(P2Pawn Shouter, P2Pawn AttackingShouter, out byte StateChange)
{
	// If I'm really scared by the shooting
	if(FRand() <= MyPawn.Cowardice/2
		&& !MyPawn.bHasViolentWeapon)
	{
		// I know what to do, and that is to run for my life
		if(FRand() <= MyPawn.Confidence)
		{
			SetAttacker(Shouter);
			DangerPos = Shouter.Location;
			GotoStateSave('FleeFromAttacker');
			StateChange=1;
		}
		else
		// I am too scared to move. I'll shake and look back and forth at the
		// too people shooting around me. I'm not confident
		{
			InterestPawn = Shouter;
			InterestPawn2 = AttackingShouter;
			GotoStateSave('QuakeBetweenAttackers');
			StateChange=1;
		}
	}
	else
	{
		// If it's youre buddy, just get down, becuase he needs to shoot
		// Gang AI
		if(SameGang(Shouter))
		{
			// If the attacker has his pants down *don't* crouch in front of him.. move somehow
			if(Attacker != None
				&& Attacker.HasPantsDown())
			{
				StrategicSideStep(StateChange);
			}
			else
			{
				//log(MyPawn$" getting down for buddy "$Shouter);
				MyPawn.ShouldCrouch(true);
				StateChange=1;
			}
		}
		else // treat everyone else the same
			RespondToTalker(Shouter, AttackingShouter, TALK_getdown, StateChange);
	}
}

///////////////////////////////////////////////////////////////////////////////
// You were looking for violence and someone just died.
// bForceDecision just makes sure you go to a new state, sometimes you don't want that
///////////////////////////////////////////////////////////////////////////////
function ViolenceWatchDeath(FPSPawn DyingPawn, optional bool bForceDecision, optional out byte StateChange)
{
	local float tryrand;
	//log("watching a death");
	tryrand = FRand();

	// Check to throw up from it, but only if the head exploded
	//log("dying pawn has a head? "$DyingPawn.bHasHead);
	if(P2Pawn(DyingPawn) != None
		&& !P2Pawn(DyingPawn).bHasHead
		&& (P2MocapPawn(DyingPawn) == None || P2MocapPawn(DyingPawn).MyRace != RACE_Skeleton))
		CheckToPuke(HEAD_EXPLODED_GROSS_MOD);

	// use Conscience or something here
	if(tryrand < 0.3)
	{
		GotoStateSave('LaughAtSomething');
		StateChange=1;
		return;
	}
	else if(tryrand < 0.6)
	{
		GotoStateSave('ClapAtSomething');
		StateChange=1;
		return;
	}
	else
	{
		Focus = Attacker;
		if(bForceDecision)
		{
			CurrentFloat = FRand()*5 + 1; // how long to look
			GotoStateSave('StareAtSomething');
			StateChange=1;
			return;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Something has startled him, so his active reactivity will increase
// and he'll react faster
///////////////////////////////////////////////////////////////////////////////
function MakeMoreAlert()
{
	UseReactivity+=REACTIVITY_GAIN;
	if(UseReactivity > 1.0)
		UseReactivity = 1.0;
	//log("NEW REACT "$UseReactivity);
}

///////////////////////////////////////////////////////////////////////////////
// He's getting a little tired of this
///////////////////////////////////////////////////////////////////////////////
function MakeLessPatient(float less)
{
	UsePatience-=less;
	if(UsePatience < 0.0)
		UsePatience = 0.0;
	//log("M use patience "$UsePatience);
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

	if(!MyPawn.bIgnoresSenses)
	{
		if(bliphere == class'ParadeMarker')
		{
			SetupWatchParade(OriginActor, Reacted);
		}
		else if(bliphere == class'HeadExplodeMarker')
		{
			WatchHeadExplode(P2Pawn(OriginActor), Reacted);
		}
		else if(bliphere == class'DeadCatHitGuyMarker')
		{
			WatchDeadCatHitGuy(P2Pawn(OriginActor), P2Pawn(CreatorPawn));
		}
		else if(bliphere == class'DeadHeadMarker')
		// Check for heads on the ground
		{
			CheckDeadHead(OriginActor);
		}
		else if(ClassIsChildOf(bliphere, class'DeadBodyMarker'))
		// Check for dead NPCs or a dead dude (head is checked above)
		{
			CheckDeadBody(P2Pawn(OriginActor));
		}
		else if(ClassIsChildOf(bliphere, class'FunnyThingMarker'))
		{
			WatchFunnyThing(P2Pawn(OriginActor));
		}
		else if(ClassIsChildOf(bliphere, class'DesiredThingMarker'))
		{
			CheckDesiredThing(OriginActor, bliphere);
		}
		else if(blipLoc != Pawn.Location)
		{
			GetReadyToReactToDanger(bliphere, CreatorPawn, OriginActor, blipLoc, Reacted);
			if(Reacted==1)
			{
				// If we went to a new panicked state drop things if you had them in your hands
				MyPawn.DropBoltons(MyPawn.Velocity);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// done screaming
///////////////////////////////////////////////////////////////////////////
function Timer()
{
	ScreamState=SCREAM_STATE_NONE;
}

///////////////////////////////////////////////////////////////////////////////
// Set the timer going for a scream
///////////////////////////////////////////////////////////////////////////////
function TimeToScream(optional int ScreamType, optional float UseThatScreamFreq)
{
	// STUB defined in bystander and police controllers
}

///////////////////////////////////////////////////////////////////////////////
// Check if you've screamed in this state before, and maybe scream then
///////////////////////////////////////////////////////////////////////////////
function TryToScream(optional bool bForce)
{
	if(ScreamState == SCREAM_STATE_NONE
		&& (bForce
			|| FRand() <= SCREAMING_FREQ))
	{
		ScreamState=SCREAM_STATE_ACTIVE;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Figure out if you should stand still and scream or not
// Usually only do it with big weapons and if you haven't been hurt yet
///////////////////////////////////////////////////////////////////////////////
function bool PickScreamingStill()
{
	return (P2Weapon(InterestPawn.Weapon) != None
				&& MyPawn.Health == MyPawn.HealthMax
				&& P2Weapon(InterestPawn.Weapon).ViolenceRank > WEAPON_RANK_SCREAM
				&& FRand() < (SCREAMING_STILL_FREQ*P2Weapon(InterestPawn.Weapon).GetViolenceRatio()));
}

///////////////////////////////////////////////////////////////////////////////
// You're catching on fire, but staying in the same state (deathcrawling,
// cowering, something like that.
///////////////////////////////////////////////////////////////////////////////
function CatchOnFireCantMove(FPSPawn Doer, optional bool bIsNapalm)
{
	local PathNode pickme;

	//log("SETTING ON FIRE");

	if(MyPawn.MyBodyFire == None)
	{
		if(Doer != Pawn)
			SetAttacker(Doer);

		MyPawn.SetOnFire(Doer, bIsNapalm);

		ScreamState=SCREAM_STATE_NONE;

		// Start screaming now
		TryToScream(true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// You've just caught on fire.. how do you feel about it?
///////////////////////////////////////////////////////////////////////////////
function CatchOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
	local PathNode pickme;

	//log("SETTING ON FIRE");
	
	// Kamek 5-1
	// Give the player an achievement for setting a cop ablaze when being lured (usually by a donut)
	if (IsInState('InvestigateDesiredThing')
		&& Focus.IsA('DonutPickup')
	// Don't do it if it's a molotov cocktail -- it has to be a pool of gasoline.
		&& Doer.Weapon.IsA('MatchesWeapon')
		&& PlayerController(Doer.Controller) != None)
		{
		if(Level.NetMode != NM_DedicatedServer ) PlayerController(Doer.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Doer.Controller),'RevengeForTrayvon');	
		}

	if(MyPawn.MyBodyFire == None)
	{
		if(Doer != Pawn)
			SetAttacker(Doer);

		MyPawn.SetOnFire(Doer, bIsNapalm);

		ScreamState=SCREAM_STATE_NONE;

		// You will die from the fire
		if(MyPawn.TakesOnFireDamage == 1.0)
		{
			// Drop your weapon you were killing, when you're on fire, 
			ThrowWeapon();

			// Start screaming now
			TryToScream(true);

			GotoState('ImOnFire');
		}
		else // You won't die from the fire, but you'll need to pat yourself out
		{
			// Put away your weapon as you run.
			SwitchToHands();

			// Start screaming now (once)
			TryToScream(true);

			// pick a 'random' point around the area to run to
			ForEach CollidingActors(class'PathNode', pickme, VISUALLY_FIND_RADIUS, MyPawn.Location)
			{
				if(FRand() <= 0.5
					&& PickMe != None
					&& PickMe != MyPawn.Anchor)
					break;
			}

			if(PickMe != None)
				SetEndGoal(PickMe, 2*DEFAULT_END_RADIUS);
			else
				SetEndGoal(Attacker, (Rand(4) + 3)*DEFAULT_END_RADIUS);
			SetNextState('PatOutFire');
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			GotoState('RunOnFire');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// You've just run into a cloud of deadly anthrax. You'll probably die
///////////////////////////////////////////////////////////////////////////////
function AnthraxPoisoning(P2Pawn Doer)
{
	local PathNode pnode;

	SetAttacker(Doer);

	// Drop things if you had them in your hands
	MyPawn.DropBoltons(MyPawn.Velocity);

	// Drop your weapon if we know you're going to die from this
	if(MyPawn.TakesAnthraxDamage >= 1.0)
		ThrowWeapon();
//	else
//		// Put away you're weapon first
//		SwitchToHands();

	// find a close-ish pathnode to run to
	UseNearestPathNode(2048);

	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;
	SetNextState('PoisonedByAnthrax');
	GotoStateSave('RunFromAnthrax');
}

///////////////////////////////////////////////////////////////////////////////
// You've just be infected by some chemical plague. Not good.
///////////////////////////////////////////////////////////////////////////////
function ChemicalInfection(FPSPawn Doer)
{
	if(MyPawn.MyBodyChem == None)
	{
		if(Doer != Pawn
			&& Doer != None)
			SetAttacker(Doer);

		MyPawn.SetInfected(Doer);

		//ScreamState=SCREAM_STATE_NONE;

		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);

		// You'll still carry it, but won't be affected by it, if you're at 0
		if(MyPawn.TakesChemDamage > 0)
		{
			// You will be incapacitated by the chemicals, deathcrawling and
			// puking
			if(MyPawn.TakesChemDamage == 1.0
				|| !MyPawn.bHasViolentWeapon)
			{
				// Makes you really close to death, if not already
				if(INFECTION_HEALTH_PCT*MyPawn.HealthMax < MyPawn.Health)
					MyPawn.Health = INFECTION_HEALTH_PCT*MyPawn.HealthMax;

				// Drop your weapon
				ThrowWeapon();

				// find a close-ish pathnode to run to
				//UseNearestPathNode(2048, (2*FRand()*DEFAULT_END_RADIUS + 2*DEFAULT_END_RADIUS));
				PickRandomDest(2*DEFAULT_END_RADIUS);

				if(IsInState('LegMotionToTarget'))
					bPreserveMotionValues=true;
				SetNextState('PrepDeathCrawl');
				GotoStateSave('RunFromAnthrax');
			}
			else // You'll puke from this but won't go down, deathcrawling from this
			{
				DangerPos = MyPawn.Location;
				GenSafeRangeMin();
				if(Doer != None
					&& Doer != MyPawn)
					SetNextState('ShootAtAttacker');
				else
					SetNextState('Thinking');
				GotoState('DoPuking');
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// You've been blinded by a flash grenade. This definitely stuns you
///////////////////////////////////////////////////////////////////////////////
function BlindedByFlashBang(P2Pawn Doer)
{	
	local PathNode PickMe;
	
	SetAttacker(Doer);
	SetNextState('AssessAttacker');
	
	// If you have a low tolerance for pain, you run around blind as a bat.
	if (FRand() > MyPawn.PainThreshold)
	{
		ScreamState=SCREAM_STATE_NONE;
		
		// If you had a weapon, there's a chance you'll drop it in the commotion.
		if (FRand() > MyPawn.Reactivity)
			ThrowWeapon();
		else
			// Toggle out to hands instead
			SwitchToHands();
			
		// Start screaming now (once)
		TryToScream(true);

		FlashbangStartTime = Level.TimeSeconds - FRand() * 2 - MyPawn.Fitness * 2;
		GotoState('ImBlind');
	}
	else
		GotoStateSave('RestAfterFlashbangHit');	
}

///////////////////////////////////////////////////////////////////////////////
// You just got your throat cut out. Run away and bleed out
///////////////////////////////////////////////////////////////////////////////
function GotThroatCut(FPSPawn Doer)
{
	if(MyPawn.Physics == PHYS_WALKING)
	{
		if(Doer != Pawn
			&& Doer != None)
			SetAttacker(Doer);

		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);

		// drop your weapon too if you're weak
		ThrowWeapon();
		
		// find a close-ish pathnode to run to
		//UseNearestPathNode(2048, (2*FRand()*DEFAULT_END_RADIUS + 2*DEFAULT_END_RADIUS));
		PickRandomDest(FRand() * DEFAULT_END_RADIUS / 2);

		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		SetNextState('PrepDeathCrawl');
		GotoStateSave('RunFromAnthrax');		
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

		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);
		
		// drop your weapon too if you're weak
		if(MyPawn.TakesShockerDamage == 1.0)
			ThrowWeapon();

		MakeShockerSteam(HitLocation, PERSON_BONE_PELVIS);

		GotoState('BeingShocked');
	}
}

///////////////////////////////////////////////////////////////////////////////
// No headshot by the rifle, but you've been hurt by it.
///////////////////////////////////////////////////////////////////////////////
function WingedByRifle(P2Pawn Doer, vector HitLocation)
{
	if(MyPawn.Physics == PHYS_WALKING
		&& MyPawn.TakesRifleHeadShot >= 1.0)
	{
		SetAttacker(Doer);

		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);
		
		// drop your weapon too--you're not getting up from this
		ThrowWeapon();

		DoDeathCrawlAway(true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Generate the toss velocity for something your throwing out of your inventory
///////////////////////////////////////////////////////////////////////////////
function vector GenTossVel(Actor Other)
{
	return (FRand()*TOSS_STUFF_VEL + TOSS_STUFF_VEL)*vector(Other.Rotation);
}

///////////////////////////////////////////////////////////////////////////////
// Returns whether or not with the given projectile start and desired end
// locations, projectile speed, and gravity or projectile z downward
// acceleration, we can hit the ProjEnd
//
// Basically copied from P2EMath
///////////////////////////////////////////////////////////////////////////////
function bool CanHitTargetWithProjectile(vector ProjStart, vector ProjEnd,
                                         float ProjSpeed, float Gravity)
{
    local float g, dx, dy;
    local vector LatStart, LatEnd;

    LatStart = ProjStart;
    LatStart.Z = 0;

    LatEnd = ProjEnd;
    LatEnd.Z = 0;

    g = Abs(Gravity);
    dx = VSize(LatEnd - LatStart);
    dy = ProjEnd.Z - ProjStart.Z;

    return Square(Square(ProjSpeed)) - g * (g * Square(dx) +
        2 * dy * Square(ProjSpeed)) >= 0;
}

///////////////////////////////////////////////////////////////////////////////
// Returns the pitch component for the projectile trajector
//
// Also copied from P2EMath
///////////////////////////////////////////////////////////////////////////////
function int GetTrajectoryPitch(float dx, float dy, float ProjSpeed,
                                float Gravity, bool bCalcLowerTrajectory)
{
    local float g, radian, ratio;

    g = Abs(Gravity);

    if (bCalcLowerTrajectory)
        radian = Atan((Square(ProjSpeed) - Sqrt(Square(Square(ProjSpeed))
            - g * (g * Square(dx) + 2 * dy * Square(ProjSpeed)))) / (g * dx));
    else
        radian = Atan((Square(ProjSpeed) + Sqrt(Square(Square(ProjSpeed))
            - g * (g * Square(dx) + 2 * dy * Square(ProjSpeed)))) / (g * dx));

    ratio = radian / PI_OVER_TWO;

    return int(ratio * 16384.0);
}

///////////////////////////////////////////////////////////////////////////////
// Returns the height above it's original spawn height which it'll travel
// We use this mainly for checking if a projectile can be thrown up over
// obstacles to hit the target
//
// Also copied from P2EMath
///////////////////////////////////////////////////////////////////////////////
function float GetMaxProjectileHeight(int Pitch, float ProjSpeed, float Gravity)
{
    local float rad, vi, g, t, yf;

    if (Pitch <= 0)
        return 0;

    rad = (float(Pitch) / 16384.0) * PI_OVER_TWO;
    vi = sin(rad) * ProjSpeed;
    g = Abs(Gravity);
    t = vi / g;

    return vi * t + 0.5 * -g * t;
}

///////////////////////////////////////////////////////////////////////////////
// Samples the area around a given TargetLocation that's behind cover and sees
// which location in the world is reachable by the projectile and is closest
// to the target for flushing them out of cover
///////////////////////////////////////////////////////////////////////////////
function vector GetCoverFlushLocation(vector ProjStart, vector TargetLocation,
                                      float ProjSpeed, float Gravity,
									  int GridXSize, int GridYSize,
									  float GridSize,
									  optional bool bUseHigherArc)
{
    local int i, j;
    local float dx, dy, g;
    local vector X, Y, Z;

    local float MaxHeight;
    local float Distance, ShortestDist;

    local vector LatStart, LatEnd;
    local vector TestFlushOffset, TestFlushLocation, HeightTestStart;

    local float TestTrajectoryPitch;

    local vector CoverFlushLoc;

    g = Abs(Gravity);

    ShortestDist = 3.4028e38;

    for (i=0;i<GridXSize;i++)
	{
        for (j=0;j<GridYSize;j++)
		{
            GetAxes(rot(0,0,0), X, Y, Z);

            // First calculate an offset from our player to test for viability
            TestFlushOffset.X = GridSize * i - GridSize * (GridXSize / 2);
            TestFlushOffset.Y = GridSize * j - GridSize * (GridYSize / 2);

            TestFlushLocation = TargetLocation + X * TestFlushOffset.X +
                Y * TestFlushOffset.Y + Z * TestFlushOffset.Z;

			// Calculate the distance from the target
            Distance = VSize(TestFlushLocation - TargetLocation);

            // Prune off locations that are clearly farther than an existing
            // cover flush location solution
            if (Distance >= ShortestDist)
                continue;

            // If the flush location can't be reached by the projectile, continue
            if (!CanHitTargetWithProjectile(ProjStart, TestFlushLocation, ProjSpeed, g))
                 continue;

            // Calculate the Pitch component so we can do a height check
            LatStart = ProjStart;
            LatStart.Z = 0;

            LatEnd = TestFlushLocation;
            LatEnd.Z = 0;

            dx = VSize(LatEnd - LatStart);
            dy = TestFlushLocation.Z - ProjStart.Z;

            // If we can hit it, then can calculate the trajector,
            TestTrajectoryPitch = GetTrajectoryPitch(dx, dy, ProjSpeed, g, bUseHigherArc);

            // Now that we have the throwing trajectory pitch, we can calculate
            // the maximum throwing height. Height is important for seeing
            // if the grenade can possibly hit
            MaxHeight = GetMaxProjectileHeight(TestTrajectoryPitch, ProjSpeed, g);

            HeightTestStart = ProjStart;
            HeightTestStart.Z += MaxHeight;

            if (FastTrace(TargetLocation, TestFlushLocation) &&
                FastTrace(TestFlushLocation, HeightTestStart)) {

                ShortestDist = Distance;
                CoverFlushLoc = TestFlushLocation;
            }
        }
    }

    return CoverFlushLoc;
}

///////////////////////////////////////////////////////////////////////////////
// Returns the trajector a projectile should take in order to hit a target. We
// also include options such as whether or not we should lead our target and
// whether or not to use the higher projectile travel arc
///////////////////////////////////////////////////////////////////////////////
function rotator GetProjectileTrajectory(vector ProjStart, vector ProjEnd,
                                         float ProjSpeed, vector TargetVelocity,
                                         int Spread, float Gravity,
                                         optional bool bLeadTarget,
                                         optional bool bUseHigherArc,
                                         optional bool bUseUpwardArc)
{
    local float dx, dy;
    local float LowerTrajectoryPitch, HigherTrajectoryPitch;
    local vector LatStart, LatEnd;
    local rotator ReturnTrajectory;

    local float LowerLatSpeed, HigherLatSpeed;
    local vector LeadTargetLocation;

    // If we can't hit our target simply fire as far as you can
    if (!CanHitTargetWithProjectile(ProjStart, ProjEnd, ProjSpeed, Gravity)) {

        ReturnTrajectory = rotator(ProjEnd - ProjStart);
        ReturnTrajectory.Pitch = 8192;

        return ReturnTrajectory;
    }

    // First perform calculations for the default position
    LatStart = ProjStart;
    LatStart.Z = 0;

    LatEnd = ProjEnd;
    LatEnd.Z = 0;

    // Calculate the dx and dy first so we can use these default values to
    // do lead time predictions
    dx = VSize(LatEnd - LatStart);
    dy = ProjEnd.Z - ProjStart.Z;

    // Perform lead time prediction with the default values if we choose to
    if (bLeadTarget) {

        LowerLatSpeed = cos(float(GetTrajectoryPitch(dx, dy, ProjSpeed,
            Gravity, true)) / 16384.0) * ProjSpeed;

        HigherLatSpeed = cos(float(GetTrajectoryPitch(dx, dy, ProjSpeed,
            Gravity, false)) / 16384.0) * ProjSpeed;

        if (bUseHigherArc)
            LeadTargetLocation = ProjEnd + TargetVelocity *
                (VSize(ProjEnd - ProjStart) / HigherLatSpeed);
        else
            LeadTargetLocation = ProjEnd + TargetVelocity *
                (VSize(ProjEnd - ProjStart) / LowerLatSpeed);

        // If we can't hit our lead location simply fire straight at the
        // lead target location
        if (!CanHitTargetWithProjectile(ProjStart, LeadTargetLocation, ProjSpeed, Gravity)) {

            ReturnTrajectory = rotator(LeadTargetLocation - ProjStart);
            ReturnTrajectory.Pitch = 8192;

            return ReturnTrajectory;
        }

        LatEnd = LeadTargetLocation;
        LatEnd.Z = 0;

        dx = VSize(LatEnd - LatStart);
        dy = LeadTargetLocation.Z - ProjStart.Z;

        ReturnTrajectory = rotator(LeadTargetLocation - ProjStart);
    }
    else
        ReturnTrajectory = rotator(ProjEnd - ProjStart);

    // Calculate both angles which we can use to hit the target
    LowerTrajectoryPitch = GetTrajectoryPitch(dx, dy, ProjSpeed, Gravity, true);
    HigherTrajectoryPitch = GetTrajectoryPitch(dx, dy, ProjSpeed, Gravity, false);

    if (bUseHigherArc)
        ReturnTrajectory.Pitch = HigherTrajectoryPitch;
    else
        ReturnTrajectory.Pitch = LowerTrajectoryPitch;

    if (bUseUpwardArc && LowerTrajectoryPitch < 0)
        ReturnTrajectory.Pitch = HigherTrajectoryPitch;

    ReturnTrajectory.Pitch += int(FRand() * float(Spread));
    ReturnTrajectory.Pitch -= int(FRand() * float(Spread));

    ReturnTrajectory.Yaw += int(FRand() * float(Spread));
    ReturnTrajectory.Yaw -= int(FRand() * float(Spread));


    return ReturnTrajectory;
}

///////////////////////////////////////////////////////////////////////////////
// ThrowWeapon()
// Throw out current weapon, and switch to a new weapon
///////////////////////////////////////////////////////////////////////////////
function ThrowWeapon()
{
	//log(MyPawn$" throwing my weapon ");
	if( Level.NetMode == NM_Client )
		return;
	if( MyPawn.Weapon==None || !MyPawn.Weapon.bCanThrow )
		return;
	// If you've tossed out your weapons, then there's no way you can
	// do distance-based weapon changing, so reset it
	MyPawn.WeapChangeDist = 0;

	MyPawn.Weapon.bTossedOut = true;
	MyPawn.TossWeapon(Vector(Rotation) * 500 + vect(0,0,220));
	if ( MyPawn.Weapon == None )
		SwitchToBestWeapon();
	// Redecide if you still have a violent weapon or not, or distance weapons
	MyPawn.EvaluateWeapons();
}

///////////////////////////////////////////////////////////////////////////////
// Find where to watch the fire from
///////////////////////////////////////////////////////////////////////////////
function SetupWatchFire(out byte DoRun)
{
	local vector dir, checkpoint;
	local float disttofire;

	// I don't try to watch out for fire when I'm actually burning
	if(MyPawn.MyBodyFire != None)
		return;

	UseSafeRangeMin = InterestActor.CollisionRadius + MyPawn.SafeRangeMin/2;

	bStraightPath=true;
	// direction away from fire, through player
	dir = MyPawn.Location - InterestActor.Location;
	// distance from player to fire
	disttofire = VSize(dir);
	// get a normalized direction
	dir = Normal(dir);

	Focus = InterestActor;
	// if we're too close or not
	if(disttofire < UseSafeRangeMin - DEFAULT_END_RADIUS)
	{
		//log("move away");
		// If we're too close, then run
		if(disttofire < InterestActor.CollisionRadius)
		{
			DoRun=1;
			Focus = None;
		}
		// Run away.. tough.. how do we determine this?
		// try straight back for the moment.
		checkpoint = MyPawn.Location + ((UseSafeRangeMin - disttofire)*dir);

		GetMovePointOrHugWalls(checkpoint, MyPawn.Location, (UseSafeRangeMin - disttofire), true);

		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	}
	else
	{
		//log("get closer");
		// If we're too far away, then run towards 
		if(disttofire > FIRE_MIN_DIST_MULT*UseSafeRangeMin)
			DoRun=1;
		// Run closer, easy...just follow paths if you can
		SetEndGoal(InterestActor, UseSafeRangeMin);
	}
}

///////////////////////////////////////////////////////////////////////////////
// There was fire in our way, decide what to do
///////////////////////////////////////////////////////////////////////////////
function HandleFireInWay(FireEmitter ThisFire)
{
	local float disttofire;
	local byte DoRun;

	InterestActor = ThisFire;

	// Check to attack our enemy, instead of look at fire
	if(Attacker != None
		&& MyPawn.bHasViolentWeapon)
	{
		GotoStateSave('ShootAttackerBehindFire');
	}
	else if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
	{
		SetupWatchFire(DoRun);
		GotoState('');// clear out of walking, maybe
		if(DoRun==1)
		{
			SetNextState('WatchFireFromSafeRange', 'LookAtFire');
			GotoStateSave('RunToFireSafeRange');
		}
		else if(MyPawn.MyBodyFire == None)
		{
			SetNextState('WatchFireFromSafeRange', 'LookAtFire');
			GotoStateSave('WalkToFireSafeRange');
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// Check first (before we see the weapon) if he is possibly in your house
// and not supposed to be, and you care about it
///////////////////////////////////////////////////////////////////////////
function CheckForIntruder(FPSPawn LookAtMe, out byte StateChange)
{
	if(LookAtMe.Region.Zone.Tag == MyPawn.HomeTag
		&& LookAtMe.HomeTag != MyPawn.HomeTag
		&& MyPawn.bCanEnterHomes
		&& MyPawn.bAngryWithHomeInvaders
		&& !SameGang(LookAtMe)
		&& (PlayerController(LookAtMe.Controller) == None || !MyPawn.bPlayerIsFriend)
		&& (P2Pawn(LookAtMe) == None
			|| (!P2Pawn(LookAtMe).bAuthorityFigure
				&& !DudeDressedAsCop(LookAtMe))))
	{
		HandleIntruder(LookAtMe);
		StateChange=1;
		return;
	}
}

///////////////////////////////////////////////////////////////////////////
// You've seen someone your home or office, so freak out
///////////////////////////////////////////////////////////////////////////
function HandleIntruder(FPSPawn LookAtMe)
{
	GenSafeRangeMin();
	InterestPawn = LookAtMe;
	SetAttacker(LookAtMe);
	GotoStateSave('IntruderInHome');
}

///////////////////////////////////////////////////////////////////////////////
// We've seen the pawn, now decide if we care
///////////////////////////////////////////////////////////////////////////////
function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
{
	// This will never be called! Bystander and Police have their own implementations
	/*
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
	*/	
}

/*
///////////////////////////////////////////////////////////////////////////////
//  Wait for Mover M to tell me it has completed its move
///////////////////////////////////////////////////////////////////////////////
function WaitForMover(Mover M)
{
	Super.WaitForMover(M);
	log(self$" wait for mover "$M);
}

///////////////////////////////////////////////////////////////////////////////
// Called by Mover when it finishes a move, and this pawn has the mover
// set as its PendingMover
///////////////////////////////////////////////////////////////////////////////
function MoverFinished()
{
	Super.MoverFinished();
	log(self$" mover finished");
}
*/
///////////////////////////////////////////////////////////////////////////////
// Someone has stolen something from you
///////////////////////////////////////////////////////////////////////////////
function PersonStoleSomething(P2Pawn CheckP, OwnedInv owninv)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Look at this person's inventory and see if they're trying to buy something
// you sell and if it's not already paid for
///////////////////////////////////////////////////////////////////////////////
function Inventory HasYourProduct(P2Pawn CheckP, P2Pawn OrigOwner)
{
	local Inventory inv;
	local OwnedInv owninv;

	// Check his inventory for this item type
	// If it's class we want to see if it's stolen
	inv = CheckP.Inventory;
	while(inv != None)
		//&& !inv.LegalOwner == OrigOwner)
		//&& !inv.ClassIsChildOf(inv.class, InvClassToCheck))
	{
		owninv = OwnedInv(inv);
		if(owninv != None
			&& owninv.LegalOwner == OrigOwner
			&& !owninv.bPaidFor)
			return inv;
//		log("inv "$inv);
		inv = inv.Inventory;
	}

	return inv;
}

///////////////////////////////////////////////////////////////////////////////
// Add up the total cost of the things in CheckP's inventory that aren't
// paid for and belong to OrigOwner
///////////////////////////////////////////////////////////////////////////////
function float GetTotalCostOfYourProducts(P2Pawn CheckP, P2Pawn OrigOwner)
{
	local Inventory inv;
	local OwnedInv owninv;
	local float TotalCost;

	inv = CheckP.Inventory;
	while(inv != None)
	{
		owninv = OwnedInv(inv);
		if(owninv != None
			&& owninv.LegalOwner == OrigOwner
			&& !owninv.bPaidFor)
			// Calc cost by multiplying by the amount of that product
			// and it's price (Advanced Econ)
			TotalCost += (owninv.Amount*owninv.Price);
//		log("inv "$inv);
		inv = inv.Inventory;
	}

//	log("total cost is "$TotalCost);

	return TotalCost;
}
/*
///////////////////////////////////////////////////////////////////////////////
// Cashiers only, usually
///////////////////////////////////////////////////////////////////////////////
function bool AcceptPayment(P2Pawn Payer, out float AmountTaken, float FullAmount)
{
	// STUB
	return false;
}
*/
///////////////////////////////////////////////////////////////////////////////
// Cashiers, tellers only
///////////////////////////////////////////////////////////////////////////////
function bool AcceptItem(P2Pawn Payer, Inventory thisitem, 
						 out float AmountTaken, float FullAmount)
{
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// She needs a book (an item) AND money (price of book, or late fee)
///////////////////////////////////////////////////////////////////////////////
function bool AcceptItemAndCash(P2Pawn Payer, Inventory thisitem, 
								P2PowerupInv cash, out float AmountTaken, float FullAmount)
{
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Spawn something in your hand as you hand it/take it from someone
///////////////////////////////////////////////////////////////////////////////
function NotifyHandSpawnItem()
{
	local Rotator rel;
	local vector loc;

	// Get rid of it, if there's something already there
	if(MyPawn.ExchangeActor != None)
	{
		MyPawn.ExchangeActor.Destroy();
		MyPawn.ExchangeActor = None;
	}

	MyPawn.ExchangeActor = spawn(class'AnimNotifyActor',MyPawn,,MyPawn.Location);
	MyPawn.ExchangeActor.SetDrawType(InterestInventoryClass.default.PickupClass.default.DrawType);
	MyPawn.ExchangeActor.SetStaticMesh(InterestInventoryClass.default.PickupClass.default.StaticMesh);
	MyPawn.ExchangeActor.LinkMesh(InterestInventoryClass.default.PickupClass.default.Mesh);
	// In case we hand over a cat (for the moment, the only animating thing to be sold) we play this 
	// canned anim of falling, so it writhes as she hands it over.
	if(MyPawn.ExchangeActor.Mesh != None)
		MyPawn.ExchangeActor.LoopAnim('fall');
	MyPawn.AttachToBone(MyPawn.ExchangeActor, BONE_HAND);
	if (class<P2PowerupPickup>(InterestInventoryClass.Default.PickupClass) == None
		|| !class<P2PowerupPickup>(InterestInventoryClass.Default.PickupClass).Default.bNoReorientHandOver)
	{
		MyPawn.ExchangeActor.SetDrawScale(0.5);
		rel.Pitch=16000;
		rel.Roll=16000;
		MyPawn.ExchangeActor.SetRelativeRotation(rel);
		loc.x = HAND_LENGTH;
		loc.y = HAND_WIDTH;
		MyPawn.ExchangeActor.SetRelativeLocation(loc);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Remove a thing you've gotten in your hand
///////////////////////////////////////////////////////////////////////////////
function NotifyHandRemoveItem()
{
	if(MyPawn.ExchangeActor != None)
	{
		MyPawn.ExchangeActor.Destroy();
		MyPawn.ExchangeActor = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// You've passed through a stolen point that references a product you care
// about. You may want to go back to your store
///////////////////////////////////////////////////////////////////////////////
function HitYourStolenPoint()
{
	GotoState('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
// This is the innards for the real versions of NoticePersonBeforeYouInLine
// which only get used in a few spots, but I didn't want to duplicate code
// to update.
///////////////////////////////////////////////////////////////////////////////
function CheckForLineCutter(P2Pawn Other, int YourNewSpot, optional out byte Cutter)
{
	if(Other != None)
	{
		if(InterestPawn != Other
			&& InterestPawn2 != Other)
		{
			if((Other.bPlayer
					|| (PersonController(Other.Controller) != None
						&& PersonController(Other.Controller).CurrentInterestPoint == CurrentInterestPoint)))
			{
				//log(MyPawn$"my next pawn "$InterestPawn$"; my NEW next pawn "$Other);
				//log(MyPawn$"statecount "$statecount$" and my new statecount "$YourNewSpot);
				//log(MyPawn$" my line cutting status: "$(QLineStatus == EQLineStatus.EQ_Cutting));

				// If you're a normal person, then get mad at anyone who cuts in front of you
				// who wasn't supposed to be there before, or who bumped you back as notch.
				// If yourself are a cutter, then get mad at people only if they bump you back
				// a notch (not if they aren't the same person)
				if(Other != None
	//				&& (YourNewSpot > statecount
	//					&& InterestPawn != Other))
					&& (QLineStatus != EQLineStatus.EQ_Cutting)
					&& (YourNewSpot > statecount
						|| InterestPawn != Other))
							
						
						//(QLineStatus != EQLineStatus.EQ_Cutting
							//&& InterestPawn != Other)))
				{
					MyPawn.SetMood(MOOD_Angry, 1.0);
					Focus = Other;
					Cutter=1;
				}
				if(PersonController(Other.Controller) == None
					|| PersonController(Other.Controller).QLineStatus != EQLineStatus.EQ_Cutting)
					InterestPawn = Other;
				InterestPawn2 = Other;
			}
		}
		else // Same guy but he's holding the line up
		{
			if((PersonController(Other.Controller) != None
					&& PersonController(Other.Controller).QLineStatus == EQ_HoldingItUp))
			{
				MyPawn.SetMood(MOOD_Angry, 1.0);
				Focus = Other;
				Cutter=1;
			}
			if(PersonController(Other.Controller) == None
				|| PersonController(Other.Controller).QLineStatus != EQLineStatus.EQ_Cutting)
				InterestPawn = Other;
			InterestPawn2 = Other;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Look at the person in front of you, perhaps they're the wrong person
///////////////////////////////////////////////////////////////////////////////
function NoticePersonBeforeYouInLine(P2Pawn Other, int YourNewSpot)
{
	InterestPawn = Other;
	//InterestPawn2 = Other;
	statecount = YourNewSpot;
	//log(MyPawn$" NoticePersonBeforeYouInLine, my new spot "$statecount);
}

///////////////////////////////////////////////////////////////////////////////
// The q said to move up
///////////////////////////////////////////////////////////////////////////////
function QPointSaysMoveUpInLine()
{
	SetNextState('WaitInQ');
	GotoStateSave('WalkInQ');
}

///////////////////////////////////////////////////////////////////////////////
// If it's okay to move forward/default to true, which means it won't continue
// forward or do anything else, which is what we want for most states
///////////////////////////////////////////////////////////////////////////////
function bool CheckToMoveUpInLine()
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// If the cashier is gone, randomly get bored and leave
// Returns true if we left.
///////////////////////////////////////////////////////////////////////////////
function bool CheckToLeaveQueue()
{
	local QPoint CheckQ;
	local Actor Cashier;
	
	const GET_BORED_AND_LEAVE = 0.25;

	// If there's no cashier, get the hell out of there maybe
	CheckQ = QPoint(CurrentInterestPoint);
	if (CheckQ != None)
	{
		Cashier = CheckQ.PickRandomOperator();
		if (Cashier == None && FRand() <= GET_BORED_AND_LEAVE)
		{
			// First, you say "no"
			Focus = None;
			CurrentInterestPoint = None;
			// then, you get outta there
			GotoState('Thinking');
			return true;
		}
	}
	
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// If the guy in front of us is still in line and 
// he's already moved again, then keep up with him.
///////////////////////////////////////////////////////////////////////////////
function bool CheckToMoveUpInLineBase()
{
	local QPoint CheckQ;
	
	if (CheckToLeaveQueue())
		return false;

	if(InterestPawn != None
		&& InterestPawn.Controller != None
		&&
		(P2Player(InterestPawn.Controller) != None
		|| InterestPawn.Controller.IsInState('WalkInQ')
		|| InterestPawn.Controller.IsInState('WaitInQ'))
		)
	{
		if(VSize(InterestPawn.Location - MyPawn.Location) > PersonalSpace + MyPawn.CollisionRadius)
		{
			CheckQ = QPoint(CurrentInterestPoint);
			SetEndPoint(CheckQ.ProjectPointOntoQLine(InterestPawn.Location)
					+ PersonalSpace*CheckQ.LineDirection, CheckQ.EndMarker.CollisionRadius);
			// switch states if I'm not there already
			if(!IsInState('WalkInQ'))
			{
				SetNextState(GetStateName());
				GotoStateSave('WalkInQ');
			}
			return true;
		}
	}
	return false;
}
/*
///////////////////////////////////////////////////////////////////////////////
// Return the hint you want to display for this item
///////////////////////////////////////////////////////////////////////////////
function GetInvHint(Inventory checkme, out String str1)
{
	// STUB--defined in cashiers
}
*/
///////////////////////////////////////////////////////////////////////////////
// People are busy doing deals
///////////////////////////////////////////////////////////////////////////////
function bool ExchangingAtCashRegister()
{
	//log(MyPawn$" i'm in this state "$GetStateName()$" with interest point as "$CurrentInterestPoint);
	// I'm doing business or the person I'm heading too/talking to is a cashier
	if(IsInState('TalkingWithSomeoneMaster')
		|| IsInState('ExchangeWithDude'))
	{
		return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Set who is last in line
///////////////////////////////////////////////////////////////////////////////
function SetLastInLine(Pawn LastOne)
{
	InterestPawn = P2Pawn(LastOne);
}

///////////////////////////////////////////////////////////////////////////
// Check to see if you have a violent weapon out.. if so, report it to others
// Before you report though, check to go into stasis
///////////////////////////////////////////////////////////////////////////
function ReportViolentWeaponNoStasis()
{
	local P2Weapon p2weap;

	// Make sure you're not supposed to go into stasis first.
	HandleStasisChange();

	// Only go ahead with the report if you didn't get put into stasis
	if(!bStasis)
	{
		p2weap = P2Weapon(MyPawn.Weapon);
		if(p2weap != None
			&& p2weap.ViolenceRank > 0)
			MyPawn.ReportPersonalLooksToOthers();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make me do the waiting
///////////////////////////////////////////////////////////////////////////////
function DoWaitOnOtherGuy(name WaitState, float lookcross)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Do your death crawl
///////////////////////////////////////////////////////////////////////////////
function DoDeathCrawlAway(optional bool bDoRand)
{
	local vector dir, checkpoint;

	// Used to allow this--caused anim problems
	// so now they just fall forward and start crawling.
/*
	// Randomly pick a direction to crawl towards
	if(bDoRand)
	{
		dir = VRand();
		dir.z=0;
	}
	else // Crawl away from your attacker
	{
		if(Attacker != None)
			dir = Normal(MyPawn.Location - Attacker.Location);
		else
			dir = Normal(MyPawn.Location);
	}
*/
	dir = vector(MyPawn.Rotation);

	checkpoint = MyPawn.Location + 8192*dir;
	// Don't adjust for walls, just keep crawling when you hit one
	SetEndPoint(checkpoint, DEFAULT_END_RADIUS);

	// Face where we're going
	Focus = None;
	FocalPoint = checkpoint;

	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;
	if(P2Pawn(Attacker) != None)
		SetNextState('PerformBegForLifeOnKnees', 'Rebeg');
	else
		SetNextState('DeathCrawlFromAttacker');

	GotoStateSave('PrepDeathCrawl');
}

///////////////////////////////////////////////////////////////////////////////
// Do your knockout pose
///////////////////////////////////////////////////////////////////////////////
function DoGetKnockedOut()
{
	bPreserveMotionValues=false;
	SetNextState('KnockedOutState');
	GotoStateSave('PrepKnockOut');
}

///////////////////////////////////////////////////////////////////////////////
// This tells the pawn how scared I am of various weapons. It makes
// use of violencerank in the p2weapon and ViolenceRankTolerance
// in P2Pawn. This can be overriden to normally
// people don't mind a shovel but when they're running scared, they might
// be scared of a shovel.
// No matter what the weapon is, if it's violent, and you're using it
// people will be concerned by the sight of it. (gas can is non-violent.. you
// swinging a shovel is violent)
///////////////////////////////////////////////////////////////////////////////
function bool ConcernedAboutWeapon(P2Weapon CheckWeap)
{
	if(CheckWeap.ViolenceRank > MyPawn.ViolenceRankTolerance
		|| (CheckWeap.ViolenceRank > 0
			&& CheckWeap.IsFiring()))
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// More extreme version of ConcernedAboutWeapon. This doesn't include you
// idly swinging melee weapons. This is only for really violent things
// you can't normally tolerate
///////////////////////////////////////////////////////////////////////////////
function bool FreakedAboutWeapon(P2Weapon CheckWeap)
{
	if(CheckWeap != None
		&& (CheckWeap.ViolenceRank > MyPawn.ViolenceRankTolerance))
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// People have a higher tolerance of a cop with a weapon
///////////////////////////////////////////////////////////////////////////////
function bool ConcernedAboutCopWeapon(P2Weapon CheckWeap)
{
	if(CheckWeap.ViolenceRank > COP_WEAPON_VIOLENCE_RANK)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Based on the violent strength of the weapon, decide if this guy is
// too close for comfort to us. (Don't account here for the direction 
// the weapon is pointing)
// 
///////////////////////////////////////////////////////////////////////////////
function bool TooCloseWithWeapon(FPSPawn CheckMe, optional bool bAlert)
{
	local int rank;
	local float dist;
	local P2Weapon p2weap;

	p2weap = P2Weapon(CheckMe.Weapon);

	if(p2weap != None)
		rank = p2weap.ViolenceRank;
	else
		return false;

	if(p2weap.bMeleeWeapon)
	{
		// If it's a melee weapon only be freaky if we're in alert mode, otherwise
		// let them get as close as they want.
		if(bAlert)
			dist = (2*p2weap.UseMeleeDist);
		//else
		//	dist = (p2weap.UseMeleeDist + CheckMe.CollisionRadius);
	}
	else
		dist = (2*CheckMe.CollisionRadius + WEAPON_BASE_DIST*rank);
	//log(MyPawn$" dist to attacker "$VSize(CheckMe.Location - MyPawn.Location)$" bad dist "$dist);

	if(VSize(CheckMe.Location - MyPawn.Location) <= dist)
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////
// Find out where your attacker is and decide to look forward or not (look
// back at him if he's behind you)
///////////////////////////////////////////////////////////////////////////
function bool CalcScaredRunAnim()
{
	local float attackerdot;
	local name runname;
	local FPSPawn RunFrom;

	if(Attacker != None)
		RunFrom = Attacker;
	else if(InterestPawn != None)
		RunFrom = InterestPawn;

	if(RunFrom != None)
	{
		// Check if the attacker is behind you or not
		attackerdot = Normal((RunFrom.Location - MyPawn.Location)) dot vector(MyPawn.Rotation);
		// look behind
		if(attackerdot < -0.5)
		{
			if (MyPawn.bIsFeminine)
				runname = 'sf_run1';
			else
				runname = 's_run1t1';
		}
		else // look forward
		{

			if (MyPawn.bIsFeminine)
			{
				if(Rand(2) == 0)
					runname = 'sf_run1a';
				else
					runname = 'sf_run2';
			}
			else
				runname = 's_run1t2';
		}
		MyPawn.MovementAnims[0]	= runname;
		MyPawn.MovementAnims[1]	= runname;
		MyPawn.MovementAnims[2]	= runname;
		MyPawn.MovementAnims[3]	= runname;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////
// Returns true if the pawn sent in uses a PersonController, and his
// attacker is a friend ours (or ourself, because we're our own best friend)
///////////////////////////////////////////////////////////////////////////
function bool FriendIsEnemyTarget(P2Pawn Aggressor)
{
	// STUB--defined in Bystander/higher level controllers
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Get out of the way of the door
///////////////////////////////////////////////////////////////////////////////
function MoveAwayFromDoorBase(DoorMover TheDoor)
{
	local vector destpoint, movedir;

	movedir = Normal(MyPawn.Location - TheDoor.Location);
	// Handle this pawn
	destpoint = MyPawn.Location;
	destpoint.x += (MOVE_FROM_DOOR_DIST+FRand()*MOVE_FROM_DOOR_DIST)*movedir.x;
	destpoint.y += (MOVE_FROM_DOOR_DIST+FRand()*MOVE_FROM_DOOR_DIST)*movedir.y;

	AdjustPointForWalls(destpoint, MyPawn.Location);

	// Play some ouch! dialog
	PrintDialogue("watch it!");
	SayTime = Say(MyPawn.myDialog.lGetBumped);

	// Get out of the way
	MovePoint = destpoint;
	MoveTarget = None;
	bDontSetFocus=true;
	bPreserveMotionValues=true;
	GotoStateSave('OnePassMove');
}

///////////////////////////////////////////////////////////////////////////////
// If your attacker bumps you, don't put up with it, spin around and notice him
///////////////////////////////////////////////////////////////////////////////
function DangerPawnBump( Actor Other, optional out byte StateChange )
{
	local P2Pawn ppawn;
	local PersonController pcont;
	
	// Clear log spam
	if (Attacker == None)
		Attacker = None;
	
	ppawn = P2Pawn(Other);
	if(ppawn != None)
		pcont = PersonController(ppawn.Controller);

	// If the pawn bumps us and we don't have an enemy, maybe
	// make him the attacker
	if(Attacker == None
		&& ppawn != None)
	{
		if(ppawn.bPlayer)
		{
			// I hate him, so attack him
			if(MyPawn.bPlayerIsEnemy)
				SetAttacker(ppawn);
			// If the player has a violent weapon out, psychically know to
			// turn around and check.. sort of imagine the dude is bumping
			// them with the weapon he has out--like a pistol to the back.
			// Make sure you're not a friend of the player and make
			// sure he's not dressed as a cop--they get to do anything.
			else if(P2Weapon(ppawn.Weapon) != None
					&& P2Weapon(ppawn.Weapon).bBumpStartsFight
					&& !MyPawn.bPlayerIsFriend
					&& !DudeDressedAsCop(ppawn))
				SetAttacker(ppawn);
		}
		else
		{
			// If you're not in the same gang, and it's not a cop that bumped you
			// then attack them or run, for bumping you with a bad weapon
			// and not the dude as a cop
			if(!SameGang(ppawn)
				&& !ppawn.bAuthorityFigure
				&& !DudeDressedAsCop(ppawn)
				&& P2Weapon(ppawn.Weapon) != None
				&& P2Weapon(ppawn.Weapon).bBumpStartsFight)
				SetAttacker(ppawn);
		}
	}

	// If our attacker bumps us (could be the new player enemy)
	if(Attacker != None
			&& (FPSPawn(Other) == Attacker
				|| FriendIsEnemyTarget(P2Pawn(Other))))
	{
		DangerPos = Other.Location;
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		InterestPawn = Attacker;
		if(MyPawn.bHasViolentWeapon)
			SetNextState('AssessAttacker');
		else
		{
			if(PickScreamingStill())
				SetNextState('ScreamingStill');
			else
				SetNextState('FleeFromAttacker');
		}
		GotoStateSave('ConfusedByDanger');
		StateChange=1;
	}

	// If a crazy running guy bumps us, check what the disturbance was
	// If our attacker bumps us (could be the new player enemy)
	if(Attacker == None
		&& pcont != None
		&& pcont.Attacker != None)
	{
		DangerPos = Other.Location;
		if(FRand() < 0.5)
		{
			SetupBackStep(SIDE_STEP_DIST, SIDE_STEP_DIST);
		}
		else
		{
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			InterestPawn = ppawn;
			SetNextState('WatchThreateningPawn');
			GotoStateSave('ConfusedByDanger');
		}
		StateChange=1;
	}

	// If you don't care about him, he's not secretly got a gun out
	// Then just check to see if he's bumping into you too hard. If he's
	// running into you, then get mad
	if(ppawn != None)
	{
		// If they are very close to running...
		if(VSize(ppawn.Velocity) > (0.9*ppawn.GroundSpeed))
			InterestIsAnnoyingUs(ppawn, true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check if we want to talk to this person
///////////////////////////////////////////////////////////////////////////////
function StartConversation( P2Pawn Other, optional out byte StateChange )
{
	local PersonController per;

	// Make sure they're not my attacker, and not the guy I just talked to
	if(Other != Attacker
		&& InterestPawn2 != Other)
	{
		per = PersonController(Other.Controller);
		// Make sure it's an NPC, and not the guy I just talked to
		if(per != None
			&& per.InterestPawn2 != MyPawn)
		{
			per.CanStartConversation(MyPawn, StateChange);
			if(StateChange == 1)
			{
				StateChange=0;
				per.Focus = MyPawn;
				per.InterestPawn = MyPawn;
				Focus = per.MyPawn;
				InterestPawn = Other;

				// Too close.. move away
				if(VSize(Other.Location - MyPawn.Location) <= 2*TALK_BACKUP_DIST)
				{
					per.GotoStateSave('StandAround');
					SetupBackStep(TALK_BACKUP_DIST, TALK_BACKUP_DIST);
					MyOldState = 'IdleConversation';
					StateChange=1;
				}
				/*
				// Sometimes people would end up standing around forever--couldn't fix it
				// in time, so it's removed
				else	// Too far, get closer
				{
					if(per.IsInState('LegMotionToTarget'))
						per.bPreserveMotionValues=true;
					//per.SetNextState('WaitOnOtherGuy');
					//per.SetEndPoint(MyPawn.Location, 2*TALK_BACKUP_DIST);
					per.GotoStateSave('StandAround');

					if(IsInState('LegMotionToTarget'))
						bPreserveMotionValues=true;
					SetNextState('IdleConversation');
					SetEndPoint(Other.Location, 2*TALK_BACKUP_DIST);
					GotoStateSave('WalkToTarget');
				}
				*/
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Someone is mugging me
///////////////////////////////////////////////////////////////////////////////
function SetupGettingMugged(P2Pawn MuggerGuy)
{
	InterestPawn = MuggerGuy;
	Focus = InterestPawn;
	SetAttacker(MuggerGuy);
	DangerPos = MuggerGuy.Location;
	GotoStateSave('GettingMugged');
}

///////////////////////////////////////////////////////////////////////////////
// Ask the controller if there is someone we should have hurt with our kick.
// If so, we'll see if they're close enough, and just hurt them magically
///////////////////////////////////////////////////////////////////////////////
function DoKickingDamage(out FPSPawn KickTarget, float KickingRadius)
{
	if(Attacker != None)
		KickTarget = Attacker;
	if(KickTarget == None
		&& InterestPawn != None)
		KickTarget = InterestPawn;
	if(KickTarget != None)
	{
		// Too far away, invalidate target
		if(VSize(KickTarget.Location - MyPawn.Location) > KickingRadius)
			KickTarget = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Release you're friend, if you're really talking to each other.
///////////////////////////////////////////////////////////////////////////////
function ReleaseSlave()
{
	if(InterestPawn != None
		&& PersonController(InterestPawn.Controller) != None
		&& PersonController(InterestPawn.Controller).InterestPawn == MyPawn
		&& PersonController(InterestPawn.Controller).IsInState('TalkingWithSomeoneMaster'))
	{
		// Make sure to save interestpawn2 again, in case something interrupted us
		// halfway through
		InterestPawn2 = InterestPawn;
		PersonController(InterestPawn.Controller).InterestPawn2 = MyPawn;
		PersonController(InterestPawn.Controller).GotoStateSave('Thinking');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Look around in random directions at different things
// The four frequencies of turning the head must all be below
// 1.0, and consectively higher. For instance, right 0.25, left 0.5
// down 0.75, up 1.0 will cause him to always look in *some* direction
// and he will randomly pick the direction evenly from the four groups.
// 0.1, 0.2, 0.3, 0.0 will cause him to never look up, and only look in the
// other three directions some 30% total (0.3) of the time.
///////////////////////////////////////////////////////////////////////////////
function bool LookAroundWithHead(float randcheck, 
							float rightfreq,
							float leftfreq,
							float downfreq,
							float upfreq,
							float speedfactor)
{
	local float randblend, randtime;

	if(randcheck < rightfreq)
	{
		randblend = FRand()/2 + 0.3;
		randtime = 1.0 - FRand()/3;
		MyPawn.PlayTurnHeadRightAnim(randtime*speedfactor, randblend);
		return true;
	}
	else if(randcheck < leftfreq)
	{
		randblend = FRand()/2 + 0.3;
		randtime = 1.0 - FRand()/3;
		MyPawn.PlayTurnHeadLeftAnim(randtime*speedfactor, randblend);
		return true;
	}
	else if(randcheck < downfreq)
	{
		randblend = FRand()/2 + 0.3;
		randtime = 1.0 - FRand()/3;
		MyPawn.PlayTurnHeadDownAnim(randtime*speedfactor, randblend);
		return true;
	}
	else if(randcheck < upfreq)
	{
		randblend = FRand()/2 + 0.3;
		randtime = 1.0 - FRand()/3;
		MyPawn.PlayTurnHeadUpAnim(randtime*speedfactor, randblend);
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Get ready for the Apocalypse. Usually, you get more weapons and get meaner
// and crazier.
///////////////////////////////////////////////////////////////////////////////
function ConvertToRiotMode()
{
	// STUB
}
/*
///////////////////////////////////////////////////////////////////////////////
// Bump you, if your in line and fall for no good reason, so you'd come out
// of the weird falling state hang-up problem (people would lock up, and not
// animate anymore in line, after a transaction. They were falling for some
// reason, but never hitting the ground).
///////////////////////////////////////////////////////////////////////////////
function QSetFall()
{
	log(MyPawn$" before throwing him in the air "$MyPawn.Velocity);
	MyPawn.Velocity = 100*VRand();
	MyPawn.Acceleration.z = 500;
	//MyPawn.Velocity
	log(MyPawn$" after throwing him in the air "$MyPawn.Velocity$" acc "$MyPawn.Acceleration);
}
*/

///////////////////////////////////////////////////////////////////////////////
// Returns true if A is "interested" in B.
///////////////////////////////////////////////////////////////////////////////
function bool PossibleHotGreeting(P2MoCapPawn A, P2MoCapPawn B)
{
	// Return true if they're opposite sexes -- or the same sex and A is a gay male (P2 doesn't have lesbians)
	return A.bIsGay ^^ (A.MyGender != B.MyGender);
}

///////////////////////////////////////////////////////////////////////////////
// Stub to resolve rare crash
///////////////////////////////////////////////////////////////////////////////
function AskWhereAttackerIs(vector CheckPos);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// initialize physics by falling to the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state InitFall
{
	ignores MarkerIsHere, damageAttitudeTo, CheckObservePawnLooks;

	///////////////////////////////////////////////////////////////////////////////
	//	Decide what to start doing
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		ForceInitPawnAttributes();

		// Figure out our home nodes, if we have any
		if(FPSPawn(Pawn).bCanEnterHomes)
			FindHomeList(FPSPawn(Pawn).HomeTag);
		// Link to the remaining path nodes
		FindPathList();

		// Set ourselves up if we have any special state other than Thinking
		// to do, as specified by our Initial state in PawnAttributes
		FPSPawn(Pawn).PrepInitialState();

		// You've been told to do something specific (like if you came in through a spawner)
		if(MyNextState != 'None'
			&& MyNextState != '')
			GotoNextState();
		else	// If you're not doing anything specific, go into stasis on start-up
		{
			// Save our old state as Thinking, and go here, if the stasis thing
			// below fails
			GotoStateSave('Thinking');

			if(MyPawn.TryToWaitForStasis())
			{
				// Now try immediately on game start-up, to go into stasis. If you're 
				// in view of the dude when he starts, that's fine, you'll be brought
				// right back out.
				GoIntoStasis();
			}
		}
	}

	function EndState()
	{
		Super.EndState();
		MyPawn.SetupCollisionInfo();
	}

Begin:
	OldMoveTarget = FindRandomDest();
	//log("old move target "$OldMoveTarget);
	Sleep(0.1);
	Goto('Begin'); // repeat state
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
	///////////////////////////////////////////////////////////////////////////////
	// Get out of the way of the door
	///////////////////////////////////////////////////////////////////////////////
	function MoveAwayFromDoor(DoorMover TheDoor)
	{
		MoveAwayFromDoorBase(TheDoor);
	}

	///////////////////////////////////////////////////////////////////////////
	// You're not doing anything important enough to keep you from walking to
	// the player (to get into some of the action). If you're bound by home nodes
	// you won't do this. And only a few states allow this
	// This state is boring enough to go seek the player instead
	///////////////////////////////////////////////////////////////////////////
	function bool FreeToSeekPlayer()
	{
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for guys in your house
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local byte StateChange;

		if(FPSPawn(Other) != None)
			CheckForIntruder(FPSPawn(Other), StateChange);

		if(StateChange != 1)
			DangerPawnBump(Other, StateChange);

		if(StateChange != 1)
			Super.Bump(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Just before getting destroyed, the beginstate here is executed, and the
// Endstate in the previous function is executed for a clean up.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Destroying
{
	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		if(MyPawn != None)
		{
			// You're not a team leader anymore
			MyPawn.bTeamLeader=false;
			MyPawn.MyLeader=None;
			// If you have no health, make sure you're dead
		}


		FullClearAttacker();

		// Not waiting around doors any more
		if(CheckDoor != None)
		{	
			CheckDoor.RemoveMe(MyPawn);
			CheckDoor = None;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand around and don't do too much
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StandAround
{
	///////////////////////////////////////////////////////////////////////////////
	// Get out of the way of the door
	///////////////////////////////////////////////////////////////////////////////
	function MoveAwayFromDoor(DoorMover TheDoor)
	{
		MoveAwayFromDoorBase(TheDoor);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if we're able to start conversations, most of the times, no
	///////////////////////////////////////////////////////////////////////////////
	function CanStartConversation( P2Pawn Other, optional out byte StateChange )
	{
		StateChange = 1;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if we're allowed to be mugged right now
	///////////////////////////////////////////////////////////////////////////////
	function CanBeMugged( P2Pawn Other, optional out byte StateChange )
	{
		StateChange=1;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for guys in your house
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local byte StateChange;

		if(FPSPawn(Other) != None)
			CheckForIntruder(FPSPawn(Other), StateChange);

		if(StateChange != 1)
			DangerPawnBump(Other, StateChange);

		if(StateChange != 1)
			Super.Bump(Other);
	}

	///////////////////////////////////////////////////////////////////////////
	// nothing on my mind when we start
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// clear vars
		EndGoal = None;
		EndRadius = 0;
		bSaidGetDown=false;
		MyPawn.StopAcc();
		MyPawn.ShouldCrouch(false);
	}

Begin:
	// Tell others if you have a weapon out
	ReportViolentWeaponNoStasis();

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
// Stand around and don't do too much
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HoldingPosition extends StandAround
{
	ignores InterestIsAnnoyingUs,
		RespondToTalker, RespondToQuestionNegatively, PrepToWaitOnDoor,
		RespondToCopBother, DecideToListen, PerformInterestAction,
		CheckForNormalDoorUse, DoWaitOnOtherGuy, TryToSendAway, TryToGreetPasserby, CheckDesiredThing,
		CheckDeadBody, WatchFunnyThing, CanStartConversation;

Begin:
	// Tell others if you have a weapon out
	ReportViolentWeaponNoStasis();

	Sleep(Rand(8) + 4);

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
// Stand with your gun out
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StandWithGun
{
	ignores InterestIsAnnoyingUs,
		RespondToTalker, RespondToQuestionNegatively, PrepToWaitOnDoor,
		RespondToCopBother, DecideToListen, PerformInterestAction,
		DonateSetup, CheckForNormalDoorUse,
		DoWaitOnOtherGuy, TryToSendAway, TryToGreetPasserby, CheckDesiredThing,
		CheckDeadBody, WatchFunnyThing, CanStartConversation;

	///////////////////////////////////////////////////////////////////////////////
	// Get out of the way of the door
	///////////////////////////////////////////////////////////////////////////////
	function MoveAwayFromDoor(DoorMover TheDoor)
	{
		MoveAwayFromDoorBase(TheDoor);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for guys in your house
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local byte StateChange;

		if(FPSPawn(Other) != None)
			CheckForIntruder(FPSPawn(Other), StateChange);

		if(StateChange != 1)
			DangerPawnBump(Other, StateChange);

		if(StateChange != 1)
			Super.Bump(Other);
	}

	///////////////////////////////////////////////////////////////////////////
	// nothing on my mind when we start
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// clear vars
		EndGoal = None;
		EndRadius = 0;
		bSaidGetDown=false;
		MyPawn.StopAcc();
	}

Begin:
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
// Stand with your gun out and be ready to kill, but don't move from here
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ActAsTurret extends StandWithGun
{
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do when attacked
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ReactToAttack
{
	ignores MarkerIsHere, damageAttitudeTo, CheckObservePawnLooks, RespondToQuestionNegatively,
		TryToGreetPasserby, DonateSetup;

	///////////////////////////////////////////////////////////////////////////////
	// Decide to run or attack
	///////////////////////////////////////////////////////////////////////////////
	function DetermineAttitudeToAttacker()
	{
		SaveAttackerData();
		// Check to see if I should run
		if(MyPawn.Health < (1.0-MyPawn.PainThreshold)*MyPawn.HealthMax
			|| !MyPawn.bHasViolentWeapon)
		{
			DangerPos = Attacker.Location;
			GotoStateSave('FleeFromAttacker');
			return;
		}
		else // Or stay and fight
		{
			GotoStateSave('RecognizeAttacker');
			return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Wait till we've landed to take off running
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		//log("react to attack my physics "$MyPawn.Physics);
		MyPawn.StopAcc();
		MyPawn.ChangeAnimation();
		DetermineAttitudeToAttacker();

		return true;
	}

Begin:
	if(MyPawn.Physics == PHYS_WALKING)
		DetermineAttitudeToAttacker();
	
	Sleep(0.1);
	Goto('Begin'); // repeat state
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CheckInterestForCommand
// Check back with the current interest state and see what to do next
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CheckInterestForCommand
{
	ignores TryToGreetPasserby, DonateSetup;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	//log(Mypawn$" checking interest "$CurrentInterestPoint);
	if(CurrentInterestPoint != None)
		CurrentInterestPoint.SetActorsNextAction(MyPawn);
	else
	{
		PrintStateError("ERROR: CurrentInterestPoint is none");
		GotoStateSave('Thinking');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PerformIdle
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PerformIdle
{
	ignores DoWaitOnOtherGuy, AllowOldState, TryToSendAway;
	
	///////////////////////////////////////////////////////////////////////////////
	// Check if we're allowed to be mugged right now
	///////////////////////////////////////////////////////////////////////////////
	function CanBeMugged( P2Pawn Other, optional out byte StateChange )
	{
		StateChange=1;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Get out of the way of the door
	///////////////////////////////////////////////////////////////////////////////
	function MoveAwayFromDoor(DoorMover TheDoor)
	{
		MoveAwayFromDoorBase(TheDoor);
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
			GotoState(MyOldState);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for guys in your house
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local byte StateChange;

		if(FPSPawn(Other) != None)
			CheckForIntruder(FPSPawn(Other), StateChange);

		if(StateChange != 1)
			DangerPawnBump(Other, StateChange);

		if(StateChange != 1)
			Super.Bump(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		// Even if you're not in a line
		QLineStatus = EQ_HoldingItUp;
	}
	function EndState()
	{
		Super.EndState();
		QLineStatus = EQ_Nothing;
		MyPawn.ChangeAnimation();
	}

Begin:
	MyPawn.StopAcc();

	MyPawn.PlayIdleAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PerformIdleQ
// This idle doesn't hold up the line
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PerformIdleQ extends PerformIdle
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
	function EndState();
Begin:
	MyPawn.StopAcc();

	MyPawn.PlayIdleAnimQ();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// SneezeInQ
// This one holds up the line
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SneezeInQ extends PerformIdle
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
	function EndState();
Begin:
	MyPawn.StopAcc();
	MyPawn.PlaySneezing();	
	SayTime = Say(MyPawn.myDialog.lSneezing);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PerformIdleWithTalk, they idle around, but can talk afterwards/during
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PerformIdleWithTalk extends PerformIdle
{
	///////////////////////////////////////////////////////////////////////////////
	// Check if we're able to start conversations, most of the times, no
	///////////////////////////////////////////////////////////////////////////////
	function CanStartConversation( P2Pawn Other, optional out byte StateChange )
	{
		StateChange = 1;
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		local P2Pawn CheckP;
		local byte StateChange;
		local vector loc;

		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			/*
			// Don't make people look anymore for people to talk to at the end of their
			// idle. Ending up not working and didn't have time to fix it. They would
			// wait forever, or talk too far away.

			// If they're alive and I want to talk, then try to talk
			if(MyPawn.Talkative > 0)
			{
				loc = MyPawn.Location + vector(MyPawn.Rotation)*LOOK_FOR_TALKEE_RADIUS;
				// Check all the pawns around me and find one to talk to
				ForEach VisibleCollidingActors(class'P2Pawn', CheckP, LOOK_FOR_TALKEE_RADIUS, loc)
				{
					if(CheckP != MyPawn 
						&& !CheckP.bPlayer
						&& CheckP.Health > 0
						&& CheckP != Attacker
						&& CheckP != InterestPawn2
						&& FastTrace(MyPawn.Location, CheckP.Location))
					{
						StartConversation(CheckP, StateChange);
						if(StateChange == 1)
							return;
					}
				}
			}
			*/
			GotoState(MyOldState);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Enter a queue
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state EnterQPoint
{
	///////////////////////////////////////////////////////////////////////////////
	// Look forward and see who's in front of me (look to q start)
	///////////////////////////////////////////////////////////////////////////////
	function P2Pawn GetNextInLine()
	{
		local P2Pawn HitActor, CheckA;
		local vector HitLocation, HitNormal;
		local QPoint checkQ;

		checkQ = QPoint(CurrentInterestPoint);

		//HitActor = Trace(HitLocation, HitNormal, checkQ.StartLoc, Location, true, checkQ.UseExtent);
		foreach TraceActors( class 'P2Pawn', HitActor, HitLocation, HitNormal, checkQ.StartLoc, MyPawn.Location, checkQ.UseExtent)
		{
			// There is someone validly in line.
			//if(HitActor.ClassIsChildOf(HitActor.class, ConcernedBaseClass))
			//log("get next "$HitActor);
			if(HitActor != None
				&& HitActor != MyPawn)
			{
				CheckA = HitActor;
				// we just need the first one
				break;
			}
		}

		return CheckA;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		Focus = CurrentInterestPoint;

		// Do final test to find correct person to be in front of you
		InterestPawn = GetNextInLine();
		//InterestPawn2 = InterestPawn;
		//log("final entry next in line "$InterestPawn);

		QPoint(CurrentInterestPoint).StartMonitoring();
	}
Begin:
	if(QPoint(CurrentInterestPoint) != None
		&& !QPoint(CurrentInterestPoint).bActive)
		GotoStateSave('WaitInQStatic');
	else
		GotoStateSave('WaitInQ');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Enter a queue and wait for it to get initiated
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state EnterQPointStatic extends EnterQPoint
{
Begin:
	GotoStateSave('WaitInQStatic');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//Wait in a queue
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitInQ
{
	///////////////////////////////////////////////////////////////////////////////
	// Check if someone cut in front of you
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local P2Pawn BeforeMe;
		local vector v1, v2;
		local byte Cutter; 

		if(FPSPawn(Other) != None
			&& FPSPawn(Other).Health > 0
			&& Other != InterestPawn)
		{
			BeforeMe = P2Pawn(Other);

			// If we can see the guy and he's not the guy who's supposed to be in front
			// of us, then get mad at him for cutting
			
			// Check if he's really between us and the start of the line or not
			v1 = (CurrentInterestPoint.Location - MyPawn.Location);
			v2 = (Other.Location - MyPawn.Location);

			if(BeforeMe != None
				&& (v1 dot v2) > 0)
			{
				CheckForLineCutter(BeforeMe, statecount, Cutter);

				if(Cutter == 1)
				{
					// Get mad with this guy
					MyPawn.SetMood(MOOD_Angry, 1.0);
					GotoState('WaitInQ', 'PissedAtCutter');
					return;
				}
			}
		}

		Super.Bump(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// If the guy in front of us is still in line and 
	// he's already moved again, then keep up with him.
	///////////////////////////////////////////////////////////////////////////////
	function bool CheckToMoveUpInLine()
	{
		return CheckToMoveUpInLineBase();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Look at the person in front of you, perhaps they're the wrong person
	// If you're farther back than you think you should be, then get mad
	///////////////////////////////////////////////////////////////////////////////
	function NoticePersonBeforeYouInLine(P2Pawn Other, int YourNewSpot)
	{
		local byte Cutter; 

		if(Other != None)
			CheckForLineCutter(Other, YourNewSpot, Cutter);

		statecount = YourNewSpot;

		if(Cutter == 1)
			GotoState('WaitInQ', 'PissedAtCutter');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Focus on a cashier (pick one from the list)
	///////////////////////////////////////////////////////////////////////////////
	function FocusOnCashier()
	{
		local QPoint myq;

		myq = QPoint(CurrentInterestPoint);

		Focus = myq.PickRandomOperator();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		// Record the max possible as your position in line
		statecount = QPoint(CurrentInterestPoint).CurrentUserNum;
	}

LookAnywhere:
	// look around restlessly
	LookInRandomDirection();
	Sleep(FRand()*5 + 1.0);
	Goto('Begin');

LookToLineFront:
	// look towards the front of the line
	LookInRandomDirection();
	Sleep(FRand()*5 + 1.0);
	Goto('Begin');

Begin:
	LookAroundWithHead(Frand(), 0.1, 0.2, 0.3, 0.4, 1.0);
	// look at the/a cashier
	Focus = QPoint(CurrentInterestPoint).PickRandomOperator();
	Sleep(FRand()*5 + 1.0);

	CheckToMoveUpInLine();

	CurrentDist = FRand();
	// randomly do a few things in line
	if(CurrentDist < 0.05)
		GotoStateSave('SneezeInQ');
	else if(CurrentDist < 0.5)
		GotoStateSave('PerformIdleQ');
	else if(CurrentDist < 0.6)
		GotoStateSave('PerformIdle');
	else if(CurrentDist < 0.7)
		Goto('LookAnywhere');
	else if(CurrentDist < 0.8)
		Goto('LookToLineFront');
	else
		Goto('Begin');

PissedAtCutter:
	PrintDialogue("Hey, watch it buddy!");
	Say(MyPawn.myDialog.lWhatThe);
	MyPawn.PlayTellOffAnim();
	// This reports to the cashier that someone has cut
//	if(InterestPawn.bPlayer)
//		log(MyPawn$" PLAYER CUT IN LINE--------------, my status "$(QLineStatus == EQLineStatus.EQ_Cutting));
	QPoint(CurrentInterestPoint).ReportCutter(InterestPawn);

StillPissedAtCutter:

	CheckToMoveUpInLine();

	Sleep(FRand()*5 + 1.0);

	if(FRand() < STAY_PISSED_AT_CUTTER)
	{
		PrintDialogue("Go screw yourself!");
		SayTime = Say(MyPawn.myDialog.lDefiantLine);
		Sleep(SayTime+FRand());
		MyPawn.PlayTellOffAnim();
		Goto('StillPissedAtCutter');
	}
	else
	{
		MyPawn.ChangeAnimation();
		Goto('Begin');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait in a queue, but really don't do anything till the player gets here
// When that happens, you'll be triggered to change states
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitInQStatic extends WaitInQ
{
	ignores CheckToMoveUpInLine;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		// We're probably not easily seen right now, so try to go into stasis first
		// so you can return back to this state later.
		if(MyPawn.TryToWaitForStasis())
		{
			GoIntoStasis();
		}
	}
LookAnywhere:
	// look around restlessly
	LookInRandomDirection();
	Sleep(FRand()*10 + 5.0);
	Goto('Begin');

LookToLineFront:
	// look towards the front of the line
	LookInRandomDirection();
	Sleep(FRand()*10 + 5.0);
	Goto('Begin');

Begin:
	// look at the/a cashier
	Focus = QPoint(CurrentInterestPoint).PickRandomOperator();
	Sleep(FRand()*20 + 10.0);

	CheckToMoveUpInLine();

	CurrentDist = FRand();
	// randomly do a few things in line
	if(CurrentDist < 0.1)
		GotoStateSave('PerformIdleQ');
	else if(CurrentDist < 0.3)
		Goto('LookAnywhere');
	else if(CurrentDist < 0.6)
		Goto('LookToLineFront');
	else
		Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Talking with someone, I control my dialogue and the slave's
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TalkingWithSomeoneMaster
{
	ignores TryToGreetPasserby, DonateSetup, PerformInterestAction, CheckDesiredThing,
		CheckDeadBody, WatchFunnyThing, StartConversation;

	///////////////////////////////////////////////////////////////////////////////
	// Say something and also possibly gesture
	///////////////////////////////////////////////////////////////////////////////
	function TalkSome(out P2Dialog.SLine line, optional P2Pawn Speaker, 
						optional bool bIsGreeting,
						optional bool bIsGiving,
						optional bool bIsTaking)
//						optional EMood NewMood)
	{
		local float userate;
			// we'll say 10 seconds is the max time someone will talk
		const MAX_TALK_TIME		=	10.0;

		if(Speaker == None)
			Speaker = MyPawn;

//		if(NewMood != MOOD_Normal)
//			MyPawn.SetMood(NewMood, 1.0);

		SayTime = Speaker.Say(line, bImportantDialog);

		if(SayTime <= 1.0)
			userate = 1.0 + (1.0 - SayTime);
		else if(SayTime < MAX_TALK_TIME)
		{
			// This caps things with the lowest being 0.5 because the closer to 0, the slower it plays
			userate = 1.0 - (SayTime/(2*MAX_TALK_TIME));
		}
		else
			userate = 0.5;

		if(bIsGreeting)
			P2MoCapPawn(Speaker).PlayHelloGesture(userate);
		else if(bIsTaking)
			P2MoCapPawn(Speaker).PlayTakeGesture();
		else if(bIsGiving)
			P2MoCapPawn(Speaker).PlayGiveGesture();
		else
			P2MoCapPawn(Speaker).PlayTalkingGesture(userate);
		SayTime += FRand();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		statecount=0;
		MyPawn.StopAcc();
		PrintThisState();
		Focus = InterestPawn;
		if(InterestPawn == None
			|| (P2Player(InterestPawn.Controller) != None
				&& !P2Player(InterestPawn.Controller).AllowTalking()))
			GotoStateSave('Thinking');
		else
		{
			if(InterestPawn.bPlayer
				&& InterestPawn.Health > 0)
				bImportantDialog=true;
			else
				bImportantDialog=false;
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		// Force the animations to end
		MyPawn.TermSecondaryChannels();
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
		if(InterestPawn != None)
		{
			P2MocapPawn(InterestPawn).TermSecondaryChannels();
			P2MocapPawn(InterestPawn).ChangePhysicsAnimUpdate(true);
			InterestPawn.ChangeAnimation();
		}
		MyPawn.SetMood(MOOD_Normal, 1.0);
		bImportantDialog=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Talking with someone, Master controls all my dialogue, I just stand here
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TalkingWithSomeoneSlave extends TalkingWithSomeoneMaster
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, ForceGetDown;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Talking about nonsense out in the street
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state IdleConversation extends TalkingWithSomeoneMaster
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, ForceGetDown;

	///////////////////////////////////////////////////////////////////////////////
	// Crazy guy is bored
	///////////////////////////////////////////////////////////////////////////////
	function CrazyGuyLooksAround()
	{
		if(PersonController(InterestPawn.Controller) != None)
			PersonController(InterestPawn.Controller).LookAroundWithHead(Frand(), 0.1, 0.2, 0.3, 0.4, 1.0);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Go back to thinking, and unhook the other guy
	///////////////////////////////////////////////////////////////////////////////
	function EndTalking()
	{
		ReleaseSlave();
		GotoStateSave('Thinking');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		ReleaseSlave();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local PersonController per;
		local byte StateChange;

		Super.BeginState();

		// Once we start we need to setup our other guy, make sure
		// he still wants to talk
		per = PersonController(InterestPawn.Controller);
		if(per != None)
		{
			per.CanStartConversation(MyPawn, StateChange);
			if(StateChange == 0
				&& per.IsInState('StandAround'))
				StateChange = 1;

		}
		// Don't continue! Something went wrong, so go back to thinking
		if(StateChange == 0)
		{
			GotoStateSave('Thinking');
			return;
		}
		else
		{
			per.InterestPawn = MyPawn;
			per.GotoStateSave('TalkingWithSomeoneSlave');
			// Save ourselves
			InterestPawn2 = per.MyPawn;
			per.InterestPawn2 = MyPawn;
		}
	}
Begin:
	// If it's Valentine's Day and we have a rose to give away, make it a hot greeting
	//log(MyPawn@MyPawn.bValentine@MyPawn.HoldingVase,'Debug');
	if (MyPawn.bValentine
		&& MyPawn.HoldingVase >= 0
		// Don't give if they're holding a vase too
		&& P2MoCapPawn(InterestPawn).HoldingVase == -1
		&& PossibleHotGreeting(MyPawn, P2MoCapPawn(InterestPawn)))
		Goto('BeginValentine');

	// Random chance to do a "hot"/sleazy greeting
	if (FRand() <= HOT_GREETING_CHANCE
		&& PossibleHotGreeting(MyPawn, P2MoCapPawn(InterestPawn))
		)
		Goto('BeginHot');
		
	// first asks how the second is doing
	TalkSome(MyPawn.myDialog.lGreetingquestions);
	PrintDialogue(" how are you?");
	Sleep(SayTime);

	// second responds greeting
	TalkSome(P2Pawn(InterestPawn).myDialog.lRespondToGreeting, P2Pawn(InterestPawn));
	PrintDialogue(InterestPawn$" fine thanks.");
	Sleep(SayTime);

	// first says that's good to hear
	TalkSome(MyPawn.myDialog.lRespondtoGreetingResponse);
	PrintDialogue(" That's good to hear");
	Sleep(SayTime);
	
	Goto('EndGreeting');
	
// "Hot"/Sleazy Greeting	
BeginHot:
	// first says "hi" sleazy
	TalkSome(MyPawn.myDialog.lHotGreeting);
	PrintDialogue(" hey sexy");
	Sleep(SayTime);
	
	// first propositions the other
	TalkSome(MyPawn.myDialog.lHotGreetingQuestions);
	PrintDialogue(" wanna fuck?");
	Sleep(SayTime);
	
	// Chance for a kiss and then branch off to the "normal" conversation line
	if (FRand() < 0.5) // FIXME
	{
		// Now kiss
		MyPawn.PlayKissing();
		P2MoCapPawn(InterestPawn).PlayKissing();
		Sleep(2.0);
		Goto('EndGreeting');
	}
	
	// otherwise, second rebuffs the first's advances
	TalkSome(P2Pawn(InterestPawn).myDialog.lRespondToHotGreeting, P2Pawn(InterestPawn));
	PrintDialogue(" you're creepy, go away");
	Sleep(SayTime);
	
	// End conversation here
	EndTalking();
	
// Valentine's Day special conversation
// Just like the "hot" greeting, except we hand over the roses and possibly kiss
BeginValentine:
	//log(MyPawn@"begin valentine conversation with"@InterestPawn,'debvyg');
	// First says "hi" sleazy
	TalkSome(MyPawn.myDialog.lHotGreeting);
	PrintDialogue(" hey sexy");
	Sleep(SayTime);
	
	// Propositions the other
	TalkSome(MyPawn.myDialog.lHotGreetingQuestions);
	PrintDialogue(" wanna fuck?");
	Sleep(SayTime);
	
	// Now hand over the vase
	// First turn off and destroy the vase bolton
	MyPawn.DestroyBolton(MyPawn.HoldingVase);
	// Turn on the thing in his hand
	InterestInventoryClass = ValentineVaseClass;
	PersonController(InterestPawn.Controller).InterestInventoryClass = ValentineVaseClass;
	
	// Actually hand it over
	MyPawn.PlayGiveGesture();
	Sleep(1.0);
	
	// Small chance of rejection
	if (FRand() < 0.2)
		Goto('RejectedValentine');

	// Otherwise thank them for the gift
	P2MoCapPawn(InterestPawn).PlayTakeGesture();
	PrintDialogue(InterestPawn$" thanks!");
	TalkSome(P2Pawn(InterestPawn).myDialog.lThanks, P2Pawn(InterestPawn));
	Sleep(2*SayTime);
	
	// Now kiss
	MyPawn.PlayKissing();
	P2MoCapPawn(InterestPawn).PlayKissing();
	Sleep(1.0);
	Spawn(P2GameInfoSingle(Level.Game).KissEmitterClass,,,MyPawn.MyHead.Location);
	Sleep(1.0);

	// Turn off further valentine's interactions for both characters
	MyPawn.bValentine = false;
	MyPawn.HoldingVase = -1;
	MyPawn.bNoExtendedAnims = false;
	MyPawn.SpecialHoldWalkAnim = '';
	P2MoCapPawn(InterestPawn).bValentine = false;
	P2MoCapPawn(InterestPawn).HoldingVase = -1;
	P2MoCapPawn(InterestPawn).bNoExtendedAnims = false;
	P2MoCapPawn(InterestPawn).SpecialHoldWalkAnim = '';

	// End conversation here
	EndTalking();
	
RejectedValentine:
	// Stare at them and wonder what the hell they're doing
	TalkSome(P2Pawn(InterestPawn).myDialog.lRespondToHotGreeting, P2Pawn(InterestPawn));
	PrintDialogue(" you're creepy, go away");
	Sleep(SayTime);
	
	// Turn off further valentine's interactions (just this guy)
	MyPawn.bValentine = false;
	MyPawn.HoldingVase = -1;
	MyPawn.bNoExtendedAnims = false;
	MyPawn.SpecialHoldWalkAnim = '';

	// First guy has a chance to either run screaming, or just flip them off
	if (FRand() <= 0.25)
	{
		Attacker = InterestPawn;
		GotoState('FleeFromAttacker');
	}
	else
	{
		// Flip them off
		MyPawn.SetMood(MOOD_Angry, 1.0);
		MyPawn.PlayTellOffAnim();
		PrintDialogue(" well screw you anyway, bitch");
		SayTime = Say(MyPawn.myDialog.lDefiant, true);
		Sleep(SayTime);		
	}
	EndTalking();
	

EndGreeting:
	// Check to go back to normal after a simple greeting
	if(FRand() < 0.5)
		EndTalking();

	// If not then go into an extended, idiotic conversation in which one 
	// guy asks something, the other guy says something stupid, and the first guy is confused.
	//  Loop appropriately.
	CurrentFloat = Rand(LONG_TALK_LOOP) + 1;
LongTalk:
	// Make crazy guy look around as normal guy talks
	CrazyGuyLooksAround();
	// First asks a reasonable question
	TalkSome(MyPawn.myDialog.lGenericQuestion);
	PrintDialogue(" here's a silly question");
	Sleep(SayTime);

	// Second makes a stupid comment
	TalkSome(P2Pawn(InterestPawn).myDialog.lGenericAnswer, P2Pawn(InterestPawn));
	PrintDialogue(InterestPawn$" here's a stupid answer");
	Sleep(SayTime);

	// Get angry with the idiot
	MyPawn.SetMood(MOOD_Combat, 1.0);
	// First is angry because second responded in a stupid way
	TalkSome(MyPawn.myDialog.lGenericFollowup);
	PrintDialogue(" That doesn't make sense!");
	Sleep(SayTime+FRand());
	// Look normal again
	MyPawn.SetMood(MOOD_Normal, 1.0);

	CurrentFloat = CurrentFloat-1;
	if(CurrentFloat > 0)
		Goto('LongTalk');

	// Go back to normal
	EndTalking();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//ExchangeGoodsAndServices
// interact with a cashier
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ExchangeGoodsAndServices extends TalkingWithSomeoneMaster
{
Begin:
	Sleep(2.0);
	Say(MyPawn.myDialog.lGreeting);
	PrintDialogue("Greeting");
	Sleep(4.0);
	Say(MyPawn.myDialog.lYes);
	PrintDialogue("Yes");
	Sleep(4.0);
	//PrintDialogue("Alrighty...there's the money.");
	//Sleep(4.0);
	Say(MyPawn.myDialog.lThanks);
	PrintDialogue("Thanks");
	// Release myself from this line
	CurrentInterestPoint = None;

	Sleep(2.0);
	// Dont' do something else till someone says too
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Try to go to my HomeTag and maybe do things along the way
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GoToMyHome
{
	/*
	///////////////////////////////////////////////////////////////////////////////
	// Find a home node that matches your home tag
	///////////////////////////////////////////////////////////////////////////////
	function bool FindHomeNode()
	{
		NavigationPoint navp;

		// go through nav points and look for matching homenode
		for(navp = NavigationPointList; navp!=None; navp=navp.NextNavigationPoint)
		{
			if(HomeNode(navp) != None)
				&& navp.Tag == MyPawn.HomeTag)
				break;
		}

		if(HomeNode(navp) != None)
			&& navp.Tag == MyPawn.HomeTag)
		{
			log("found home node "$navp);
			SetEndGoal(navp, DEFAULT_END_RADIUS);
			return true;
		}
		return false;
	}
*/
	///////////////////////////////////////////////////////////////////////////////
	// Make sure we have a valid home tag
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		if(MyPawn.HomeTag == 'None')
			PrintStateError("Home tag is none");
	}

StopForASmoke:

Begin:
	/*
	// see if we're home not
	if(AlreadyAtHome())
		GotoStateSave('Thinking');

	// if not, decide to walk there
	if(FindHomeNode())
	{
		SetNextState(GetStateName());
		GotoStateSave('WalkToTarget');
	}
	*/

	MyPawn.bCanEnterHomes=true;
	DisallowStasis();

	GotoStateSave('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// GreetPasserby
// Just stop and say hi to this person.
// Requires focus set to the passerby.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GreetPasserby
{
	ignores TryToGreetPasserby, DonateSetup, AllowOldState,
		DoWaitOnOtherGuy;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangePhysicsAnimUpdate(true);
		// Clear out your interest
		InterestPawn = None;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
	}
Begin:
	Sleep(1.0);
	SayTime=Say(MyPawn.myDialog.lGreeting);
	PrintDialogue("Greeting");
	Sleep(SayTime+1.0);
	GotoState(MyOldState);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// GreetGimp
// Laugh at the dude as the gimp
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GreetGimp extends GreetPasserby
{
Begin:
	Sleep(FRand());

	if(FRand() < START_LAUGH_AT_GIMP)
		Goto('Laughing');
	
Snickering:
	SayTime=Say(MyPawn.myDialog.lSnickering);
	//MyPawn.PlayTalkingGesture(1.0);
	PrintDialogue("snickering");
	Sleep(SayTime+1.0);
	CurrentFloat = FRand();
	if(CurrentFloat < KEEP_SNICKERING_AT_GIMP)
	{
		if(CanSeePoint(MyPawn, Focus.Location))
			Goto('Snickering');
		else
			// end early because we lost sight of him
			Goto('Ending');
	}
	else if(CurrentFloat > LAUGH_AT_GIMP)
		Goto('Ending');

Comments:
	if(FRand() < COMMENT_TO_GIMP)
	{
		SayTime=Say(MyPawn.myDialog.lHelloGimp);
		MyPawn.PlayTalkingGesture(1.0);
		PrintDialogue("You look funny!");
		Sleep(SayTime+1.0);
	}

Laughing:
	// Unhook the focus, so we don't try to laugh and turn (that will mess up, visually, so we'll
	// just face forward and laugh)
	FocalPoint = Focus.Location;
	Focus = None;

	SayTime=Say(MyPawn.myDialog.lLaughing);
	MyPawn.PlayLaughingAnim();
	PrintDialogue("laughing");
	Sleep(SayTime+1.0);

Ending:
	GotoState(MyOldState);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Say hi to the dude cop
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GreetDudeCop extends GreetPasserby
{
Begin:
	Sleep(FRand());

Comments:
	SayTime=Say(MyPawn.myDialog.lHelloCop);
	MyPawn.PlayTalkingGesture(1.0);
	PrintDialogue("Hi officer");
	Sleep(SayTime+1.0);
	bHiToCop=true;

	GotoState(MyOldState);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Get thrown through the air
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ThrownThroughAir
{
	ignores BodyJuiceSquirtedOnMe, HearWhoAttackedMe, HearAboutKiller, 
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker,  GetOutOfMyWay,
		MarkerIsHere, CheckObservePawnLooks, CheckToPuke, GettingDousedInGas,
		RespondToCopBother, DecideToListen, damageAttitudeTo, HandleFireInWay, DoWaitOnOtherGuy, TryToSendAway, DoGetKnockedOut, TookNutShot, BlindedByFlashBang;

	///////////////////////////////////////////////////////////////////////////////
	//	Stop us when we land, and make sure to run from our attacker
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		//log(self$" hit ground ");
		MyPawn.StopAcc();
		MyPawn.ChangeAnimation();
		// now run away!
		InterestPawn = Attacker;
		DangerPos = Attacker.Location;
		// Decide current safe min
		UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;
		SetNextState('FleeFromAttacker');
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Puking your guts out (vegetable soup mode) (puke)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DoPuking
{
	ignores BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, HearAboutKiller, 
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker, InterestIsAnnoyingUs, GetHitByDeadThing, HandlePlayerSightReaction,
		MarkerIsHere, CheckObservePawnLooks, RespondToCopBother, DecideToListen, damageAttitudeTo, HandleFireInWay,
		SetupSideStep, SetupBackStep, SetupMoveForRunner, AllowOldState, DoWaitOnOtherGuy, TryToSendAway, HitWithFluid,
		CanHelpOthers, DangerPawnBump, Trigger, RocketIsAfterMe,  GetOutOfMyWay, DoGetKnockedOut, TookNutShot, BlindedByFlashBang;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function AfterPukeHandleAttacker()
	{
		InterestPawn = Attacker;
		SetAttacker(InterestPawn);

		if(MyPawn.bHasViolentWeapon)
			GotoState('AssessAttacker');
		else
			GotoState('FleeFromPisser');
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function EndingPuke()
	{
		MyPawn.StopPuking();

		MyPawn.ChangeAnimation();

		MyPawn.SetMood(MOOD_Normal, 1.0);

		if(Attacker != None)
		{
			AfterPukeHandleAttacker();
			return;
		}
		else
			GotoNextState();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Override whatever you're saying and make puking noises
	///////////////////////////////////////////////////////////////////////////////
	function ActuallyPuking()
	{
		GotoState(GetStateName(), 'MakeNoises');
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0
			&& WorkFloat == 1.0)
		{
			EndingPuke();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		WorkFloat = 0.0;
		MyPawn.StopAllDripping();
		// Put away you're weapon first
		//SwitchToHands();
	}

Begin:
	if(Pawn(Focus) != None)
	{
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;	// stop looking at people
	}
	MyPawn.StopAcc();

	// Say you don't feel good
	SayTime = Say(MyPawn.myDialog.lAboutToPuke);
	Sleep(Frand() + 0.5);
	
	MyPawn.StartPuking(4);//FLUID_TYPE_Puke);

	//Sleep(SayTime);

	// Make throw up noises
MakeNoises:
	SayTime = Say(MyPawn.myDialog.lBodyFunctions);
//	MyPawn.SetMood(MOOD_Puking, 1.0);
	Sleep(SayTime);
	WorkFloat=1.0;

	if(!MyPawn.bIsFeminine)
		Goto('MakeNoises');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Puking your guts out (vegetable soup mode) (puke)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DoPukingBloody extends DoPuking
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function AfterPukeHandleAttacker()
	{
		InterestPawn = Attacker;
		SetAttacker(InterestPawn);
		GotoState('RestAfterBigHurt');
	}

Begin:
	if(Focus != None)
		FocalPoint = Focus.Location;
	Focus = None;	// stop looking around or rotating
	MyPawn.StopAcc();

	// Say you don't feel good
	SayTime = Say(MyPawn.myDialog.lAboutToPuke);
	Sleep(Frand() + 0.5);
	
	MyPawn.StartPuking(5);//FLUID_TYPE_BloodyPuke);

MakeNoises:
	SayTime = Say(MyPawn.myDialog.lBodyFunctions);
//	MyPawn.SetMood(MOOD_Puking, 1.0);
	Sleep(SayTime);
	WorkFloat=1.0;

	if(!MyPawn.bIsFeminine)
		Goto('MakeNoises');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Puke blood then fall over dead
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PoisonedByAnthrax extends DoPukingBloody
{
	ignores AnthraxPoisoning;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		local float takedamage;

		Super.EndState();
		if(MyPawn.Health > 0)
		{
			// We've just puked blood from anthrax poisoning.. check to die or just get hurt a lot
			takedamage = MyPawn.TakesAnthraxDamage*MyPawn.HealthMax;
			MyPawn.TakeDamage(takedamage, Attacker, MyPawn.Location, vect(0, 0, 1), class'AnthKillDamage');
		}
	}

Begin:
	if(Focus != None)
		FocalPoint = Focus.Location;
	Focus = None;	// stop looking around or rotating
	MyPawn.StopAcc();

	// Say you don't feel good
	SayTime = Say(MyPawn.myDialog.lAboutToPuke);
	Sleep(Frand() + 0.5);
	MyPawn.StartPuking(5);//FLUID_TYPE_BloodyPuke);
MakeNoises:
	SayTime = Say(MyPawn.myDialog.lBodyFunctions);
//	MyPawn.SetMood(MOOD_Puking, 1.0);
	Sleep(SayTime);
	WorkFloat=1.0;

	// If you're not going to die from this, then finish you're puke
	// and get the attacker
	if(MyPawn.TakesAnthraxDamage*MyPawn.HealthMax < MyPawn.Health)
		EndingPuke();
	else	// If you are, then just loop like normal, and finally die
		Goto('MakeNoises');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Puking cause a stinkin interest point made you
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DoPukingInterestPoint extends DoPuking
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function EndingPuke()
	{
		MyPawn.StopPuking();

		MyPawn.SetMood(MOOD_Normal, 1.0);

		MyPawn.ChangeAnimation();
		// continue with the interest point fun
		GotoNextState();
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
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
	ignores HearWhoAttackedMe, HearAboutKiller, DangerPawnBump,  GetOutOfMyWay,
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker, damageAttitudeTo,
		MarkerIsHere, CheckObservePawnLooks, RespondToCopBother, DecideToListen, HandleFireInWay,
		AnthraxPoisoning, InterestIsAnnoyingUs, GetHitByDeadThing, HandlePlayerSightReaction,
		CanHelpOthers, Trigger, RocketIsAfterMe, SetupSideStep, SetupBackStep, SetupMoveForRunner, 
		AllowOldState, CheckForNormalDoorUse, DoGetKnockedOut, TookNutShot, BlindedByFlashBang;

	///////////////////////////////////////////////////////////////////////////////
	// You're continuing to get electricuted
	///////////////////////////////////////////////////////////////////////////////
	function GetShocked(P2Pawn Doer, vector HitLocation)
	{
		if(MyPawn.Physics == PHYS_WALKING)
		{
			//log(self$" get shocked in beingshocked");
			MakeShockerSteam(HitLocation, PERSON_BONE_PELVIS);
			statecount=1; // been shocked *again*, need to loop
						// loop the animation--don't go to next state yet
			//GotoState('BeingShocked', 'MakeNoises');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function EndingGettingShocked()
	{
		MyPawn.ChangeAnimation();

		InterestPawn = Attacker;

		// Stand there and take it if you can
		if((float(MyPawn.Health)/MyPawn.HealthMax) > MyPawn.TakesShockerDamage)
		{
			CurrentFloat = int((CurrentFloat - MyPawn.Health)/MyPawn.HealthMax*MAX_BREATHES_AFTER_SHOCK);
			GotoStateSave('RestAfterBigHurt');
		}
		else // if you can't, fall over and pee yourself
		{
			CurrentFloat = CurrentFloat - MyPawn.Health + 1;
			GotoStateSave('FallAfterShocked');
		}
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
			if(statecount == 0)
				EndingGettingShocked();
			else	// continue to loop anim, but clear statecount
			{
				MyPawn.PlayShockedAnim();
				statecount=0;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopPuking();
		MyPawn.ShouldCrouch(false);
		CurrentFloat=MyPawn.Health;
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;	// stop looking around or rotating
		MyPawn.StopAcc();
		MyPawn.SetMood(MOOD_Scared, 1.0);
		MyPawn.PlayShockedAnim();
		statecount=0; // been shocked, playing the anim, ready to go to next state
	}

Begin:

MakeNoises:
	SayTime = Say(MyPawn.myDialog.lGettingShocked);
	Sleep(SayTime);
Goto('MakeNoises');

//	EndingGettingShocked();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You don't fall over after getting shocked (or didn't die from your
// general big  hurt), then you stand
// there and pant some after being shocked, then you attack again
// if you can
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RestAfterBigHurt extends BeingShocked
{
	///////////////////////////////////////////////////////////////////////////////
	// You're continuing to get electricuted
	///////////////////////////////////////////////////////////////////////////////
	function GetShocked(P2Pawn Doer, vector HitLocation)
	{
		Global.GetShocked(Doer, HitLocation);
	}

	///////////////////////////////////////////////////////////////////////////////
	// If you get hurt in this mode, it will shake you out of your daze (unless
	// it's more tazering)
	///////////////////////////////////////////////////////////////////////////////
	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		if ( (instigatedBy != None) 
			&& (instigatedBy != pawn) 
			&& damageType != class'ElectricalDamage'
			&& damage > 0)
			global.damageAttitudeTo(instigatedBy, Damage);
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
			CurrentFloat = CurrentFloat - 1;

			if(CurrentFloat > 0)
			{
				MyPawn.PlayRestStanding();
			}
			else if(Attacker != None)	// get up again
			{
				MyPawn.ChangeAnimation();

				InterestPawn = Attacker;
				SetAttacker(InterestPawn);
				if(MyPawn.bHasViolentWeapon)
					GotoState('AssessAttacker');
				else
					GotoState('FleeFromPisser');
			}
			else
				GotoState('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// block parent version
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
	}

	///////////////////////////////////////////////////////////////////////////////
	// Don't mess with the currentfloat in here
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;	// stop looking around or rotating
	}

Begin:
	// pant and rest, after getting shocked.
	//MyPawn.PlayRestStanding();
	MyPawn.PlayDazedAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Reset after sledge hit to the noggin'
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RestAfterBatonHit extends RestAfterBigHurt
{
	function BeginState()
	{
		Super.BeginState();
		MyPawn.StopAcc();
	}
Begin:
	MyPawn.PlayStunnedAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Reset after nut shot
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RestAfterNutShot extends RestAfterBigHurt
{
	function BeginState()
	{
		Super.BeginState();
		MyPawn.StopAcc();
	}
Begin:
	MyPawn.PlayKickedInTheBalls();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Reset after being blinded by a flashbang
// You just got hit, you're grabbing for your eyes
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RestAfterFlashbangHit
{
	ignores HearWhoAttackedMe, HearAboutKiller, DangerPawnBump,  GetOutOfMyWay,
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker, damageAttitudeTo,
		MarkerIsHere, CheckObservePawnLooks, RespondToCopBother, DecideToListen, HandleFireInWay,
		AnthraxPoisoning, InterestIsAnnoyingUs, GetHitByDeadThing, HandlePlayerSightReaction,
		CanHelpOthers, Trigger, RocketIsAfterMe, SetupSideStep, SetupBackStep, SetupMoveForRunner, 
		AllowOldState, CheckForNormalDoorUse;

	///////////////////////////////////////////////////////////////////////////////
	// Don't mess with the currentfloat in here
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;	// stop looking around or rotating
		MyPawn.StopAcc();
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
			GotoState('RestAfterFlashbangHit_Loop');
	}

	///////////////////////////////////////////////////////////////////////////////
	// If you get hurt in this mode, it will shake you out of your daze (unless
	// it's more tazering)
	///////////////////////////////////////////////////////////////////////////////
	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		if ( (instigatedBy != None) 
			&& (instigatedBy != pawn) 
			&& damageType != class'FlashBangDamage'
			&& damage > 0)
			global.damageAttitudeTo(instigatedBy, Damage);
	} 

Begin:
	MyPawn.PlayStunnedByFlashbang_In();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Reset after being blinded by a flashbang
// Waiting it out...
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RestAfterFlashbangHit_Loop extends RestAfterFlashbangHit
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			if (CurrentFloat == 0)
				GotoState('RestAfterFlashbangHit_Out');
			else
				MyPawn.PlayStunnedByFlashbang_Loop();
		}
	}
Begin:
	// Waiting it out
	CurrentFloat = 1;
	MyPawn.PlayStunnedByFlashbang_Loop();
	Sleep(FLASHBANG_BASE_REST_TIME - 2*FRand() - MyPawn.PainThreshold);
	CurrentFloat = 0;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Reset after being blinded by a flashbang
// Recovering now, go chase down your attacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RestAfterFlashbangHit_Out extends RestAfterFlashbangHit
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			if(Attacker != None)	// get up again
			{
				MyPawn.ChangeAnimation();

				InterestPawn = Attacker;
				SetAttacker(InterestPawn);
				if(MyPawn.bHasViolentWeapon)
					GotoState('AssessAttacker');
				else
					GotoState('FleeFromPisser');
			}
			else
				GotoState('Thinking');
		}
	}
Begin:
	MyPawn.PlayStunnedByFlashbang_Out();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Fall over after being shocked, and then pee yourself
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallAfterShocked extends BeingShocked
{
	ignores GetShocked, BodyJuiceSquirtedOnMe, GettingDousedInGas;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			GotoStateSave('CowerInABallShocked');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// block parent version
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
	}

	///////////////////////////////////////////////////////////////////////////////
	// Don't mess with the currentfloat in here
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;	// stop looking around or rotating
	}

Begin:
	// fall over and get ready to cower
	MyPawn.PlayFallOverAfterShocked();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're very tired from running from you're attacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RestFromAttacker
{
	ignores HearWhoAttackedMe, HearAboutKiller,  GetOutOfMyWay,
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker,
		CheckObservePawnLooks, RespondToCopBother, DecideToListen, HandleFireInWay,
		InterestIsAnnoyingUs, GetHitByDeadThing, HandlePlayerSightReaction,
		CanHelpOthers, Trigger, RocketIsAfterMe;

	///////////////////////////////////////////////////////////////////////////////
	// Stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);

		// Check for the base channel only
		if(channel == 0)
		{
			CurrentFloat = CurrentFloat - 1;

			DistanceRun-=(MyPawn.Fitness*REGAIN_BREATH_DIST);
			if(DistanceRun < 0)
				DistanceRun=0;

			if(CurrentFloat > 0)
			{
				// panting while standing
				MyPawn.PlayPantingAnim();
			}
			else
			{
				// You've rested fully
				DistanceRun=0;
				MyPawn.ChangeAnimation();

				if(Attacker != None)
					GotoState('WatchThreateningPawn');
				else
					GotoState('WatchForViolence');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Don't mess with the currentfloat in here
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;	// stop looking around or rotating
		CurrentFloat = DistanceRun/((MyPawn.Fitness*REGAIN_BREATH_DIST) + REGAIN_BREATH_DIST);
	}

Begin:
	// panting while standing
	MyPawn.PlayPantingAnim();
LoopBreath:
	SayTime = Say(MyPawn.myDialog.lOutOfBreath);
	PrintDialogue("breathing hard");
	Sleep(SayTime);
	Goto('LoopBreath');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Kick a dead body on the ground, or anything low
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DoKicking
{
	ignores HearWhoAttackedMe, HearAboutKiller, SetupWatchParade,
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker, RocketIsAfterMe,
		GetReadyToReactToDanger, CheckObservePawnLooks, InterestIsAnnoyingUs, GetHitByDeadThing, 
		HandlePlayerSightReaction,
		RespondToCopBother, DecideToListen, HandleFireInWay, SetupSideStep, SetupBackStep, SetupMoveForRunner, 
		AllowOldState;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			GotoNextState(true);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}

Begin:
	Focus = InterestPawn;
	MyPawn.StopAcc();

	MyPawn.PerformKick();
	// Don't say it every time.
	if(FRand() < TAKE_THIS_KICK_DEAD)
	{
		SayTime = Say(MyPawn.myDialog.lKickDead);
		PrintDialogue("Take this!");
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state JustKick extends DoKicking
{
Begin:
	MyPawn.StopAcc();
	MyPawn.PerformKick();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Get mad and try to kick back the head that just hit us
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state KickHeadBack
{
	ignores InterestIsAnnoyingUs, RespondToQuestionNegatively, TryToGreetPasserby, DonateSetup,
		SetupSideStep, SetupBackStep, SetupMoveForRunner, AllowOldState, CheckDeadBody, CheckDeadHead;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		if(InterestPawn != None)
			GotoStateSave('WatchThreateningPawn');
		else
			GotoStateSave('WatchForViolence');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0
			&& statecount == 1)
		{
			Focus = InterestActor;
			DecideNextState();
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
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
		statecount=0;
	}

Begin:
	FocalPoint = InterestActor.Location;
	Focus = None;
	MyPawn.PerformKick();
	if(InterestPawn != None)
	{
		SayTime = Say(MyPawn.myDialog.lGetMad);
		PrintDialogue("Screw you buddy!");
	}
	Sleep(4.0);
	Focus = InterestActor;
	DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're watching something morbid
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state MorbidAttention
{
	ignores TryToGreetPasserby, /*DonateSetup,*/ SetupWatchParade;
	///////////////////////////////////////////////////////////////////////////////
	// Check if the player has changed the crazy thing he's doing, then we'll update
	///////////////////////////////////////////////////////////////////////////////
	function bool PlayerDoingSomethingDifferent(FPSPawn LookAtMe)
	{
		if(P2Player(LookAtMe.Controller) != None
			&& P2Player(LookAtMe.Controller).SightReaction != 0
			&& P2Player(LookAtMe.Controller).SightReaction != PlayerSightReaction)
		{
			// Update
			if(LookAtMe == InterestPawn)
				InterestPawn = None;
			PlayerSightReaction = P2Player(LookAtMe.Controller).SightReaction;
			return true;
		}
		else
			return false;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Make sure your weapon is idling
	///////////////////////////////////////////////////////////////////////////////
	function bool WeaponReady()
	{
		local P2Weapon p2weap;

		p2weap = P2Weapon(MyPawn.Weapon);
		if(p2weap == None
			|| p2weap.IsIdle())
			return true;
		return false;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Care about the looks of any one else
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		if(LookAtMe != InterestPawn
			|| PlayerDoingSomethingDifferent(LookAtMe))
			ActOnPawnLooks(LookAtMe);
	}
	///////////////////////////////////////////////////////////////////////////////
	// play sounds, start count again
	///////////////////////////////////////////////////////////////////////////////
	function ResetVals()
	{
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
			MyPawn.PlaySound(TermSound, SLOT_Talk, 0.01);
			MyPawn.ChangeAnimation();
			DecideNextState();
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		if(MyNextState != 'None'
			&& MyNextState != '')
		{
			SetAttacker(None);
			GotoNextState();
		}
		else
		{
			GotoStateSave('Thinking');
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangePhysicsAnimUpdate(true);
	}
	///////////////////////////////////////////////////////////////////////////////
	// init with is conscience
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();
		UseAttribute = MyPawn.Conscience;
		ResetVals();
		SwitchToHands();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're laughing at something
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LaughAtSomething extends MorbidAttention
{
WeaponWait:
	Sleep(0.5);
Begin:
	if(!WeaponReady())
		Goto('WeaponWait');
	MyPawn.PlayLaughingAnim();

	Say(MyPawn.myDialog.lLaughing);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're clapping because of something. (applause)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ClapAtSomething extends MorbidAttention
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		MyPawn.AmbientSound = None;
	}
WeaponWait:
	Sleep(0.5);
Begin:
	if(!WeaponReady())
		Goto('WeaponWait');
	MyPawn.PlayClappingAnim();
	MyPawn.AmbientSound=ClappingSound;
	Sleep(0.1);
//ClappingSound:
	SayTime = Say(MyPawn.myDialog.lApplauding);
	Sleep(SayTime);
	//Goto('ClappingSound');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're staring at something
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StareAtSomething extends MorbidAttention
{
	ignores AnimEnd;

	///////////////////////////////////////////////////////////////////////////////
	// play sounds, start count again
	///////////////////////////////////////////////////////////////////////////////
	function ResetVals()
	{
		statecount=0;
		if(CurrentFloat > 0)
		{
			PrintDialogue("Hmmmm....");
			SayTime=Say(MyPawn.myDialog.lHmm);
		}
	}

Begin:
	Sleep(CurrentFloat);

	GotoNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Play dance animation and then try for your next state, if you have one
// if not, dance again
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DanceHere
{
	ignores TryToGreetPasserby, SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			DecideNextState();
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		// Dance facing the same direction
		if(Frand() < DANCE_AGAIN)
			GotoState(GetStateName(), 'DanceAgain');
		// Go to my next state
		else if(MyNextState != 'None'
			&& MyNextState != '')
		{
			GotoNextState();
		}
		else // or keep dancing
		{
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
		MyPawn.ChangeAnimation();
	}

Begin:
	Focus = None;
	// pick a new direction to look
	FocalPoint = MyPawn.Location + (1024*VRand());

DanceAgain:
	MyPawn.PlayDancingAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// An interest point is making us dance here
// Play dance animation and then try for your next state, if you have one
// if not, dance again
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DanceHereInterestPoint extends DanceHere
{
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		if(statecount < CurrentFloat)
		{
			statecount++;
			GotoState(GetStateName(), 'Begin');
		}
		else
			GotoNextState();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		statecount = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Smoke here
// FIXME add in cigarette, smoke etc.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SmokeHere
{
	ignores TryToGreetPasserby, SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			if (CurrentFloat != -1)
				MyPawn.PlaySmokingAnim();
			else
				GotoNextState();
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local Emitter TheSmoke;
		
		PrintThisState();
		//log("Smoking for"@CurrentFloat);
		// Create cigarette
		MyPawn.TempBolton.Bone = 'Male01 L finger2';
		MyPawn.TempBolton.Mesh = SkeletalMesh(DynamicLoadObject("MoreCharacters.cig_skel",class'SkeletalMesh'));
		MyPawn.TempBolton.bCanDrop = true;
		MyPawn.TempBolton.DrawScale = 1.0;
		MyPawn.SetupTempBolton();
		
		// If we made a cigarette, attach the smoke to it now
		if (MyPawn.TempBolton.Part != None)
		{
			TheSmoke = spawn(class'CigaretteSmoke',,,MyPawn.Location);
			log("created smoke"@TheSmoke);
			// FIXME Make this align better, it doesn't quite seem to line up right
			MyPawn.TempBolton.Part.AttachToBone(TheSmoke, 'cig_end');
		}

		MyPawn.StopAcc();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		local int i;
		MyPawn.ChangeAnimation();
		
		// If we made a cigarette, detach and destroy the smoke and cigarette
		if (MyPawn.TempBolton.Part != None)
		{
			for (i = 0; i < MyPawn.TempBolton.Part.Attached.Length; i++)
				MyPawn.TempBolton.Part.Attached[i].Destroy();
			MyPawn.DestroyTempBolton();
		}
	}

Begin:
	MyPawn.PlaySmokingAnim();
	Sleep(CurrentFloat);
	CurrentFloat = -1;	// indicate to animation that we're done here
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand this way, and play and arcade game.. make a mean face sometimes
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayArcadeGame
{
	ignores TryToGreetPasserby, ForceGetDown, SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	// Just yell 'screw you' at them, not matter what
	///////////////////////////////////////////////////////////////////////////////
	function DonateSetup(Pawn Talker, out byte StateChange)
	{
		if(Focus == None)
		{
			Focus = Talker;
			MyPawn.SetMood(MOOD_Angry, 1.0);
			MyPawn.PlayAnim(MyPawn.GetAnimStand(), 1.0, 0.15);
			GotoState('PlayArcadeGame', 'ScrewYou');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			DecideNextState();
		}
	}
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
		FocalPoint = MyPawn.Location + 100*vector(MyPawn.Rotation);
		Focus = None;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
		MyPawn.SetMood(MOOD_Normal, 1.0);
	}

ScrewYou:
	Sleep(1.0+Frand());
	// Flip them off
	MyPawn.SetMood(MOOD_Angry, 1.0);
	MyPawn.PlayTellOffAnim();
	PrintDialogue("no way! you're crazy");
	//SayTime = Say(MyPawn.myDialog.lDefiant);
	SayTime = Say(MyPawn.myDialog.lDontSignPetition, true);
	Sleep(SayTime);
	Focus = None;

Begin:
	if(FRand() < 0.5)
		MyPawn.SetMood(MOOD_Angry, 1.0);
	else
		MyPawn.SetMood(MOOD_Normal, 1.0);
	MyPawn.PlayArcadeAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Play the guitar. Trigger music too
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayGuitar
{
	ignores TryToGreetPasserby, ForceGetDown, SetupWatchParade, DonateSetup;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			DecideNextState();
		}
	}
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
		FocalPoint = MyPawn.Location + 100*vector(MyPawn.Rotation);
		Focus = None;
		
		// Turn on the music
		TriggerEvent(MyPawn.GuitarMusicTag, None, MyPawn);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
		MyPawn.SetMood(MOOD_Normal, 1.0);
		// Turn off the music
		TriggerEvent(MyPawn.GuitarMusicTag, None, MyPawn);
	}

Begin:
	MyPawn.PlayGuitarAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Play the guitar. Trigger music too
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayGuitarInterest extends PlayGuitar
{
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		if (CurrentFloat == -1) // stop
			GotoNextState();
		else //start over
			MyPawn.PlayGuitarAnim();
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();
		MyPawn.SetupTempBolton();
		
		// Turn on the music
		TriggerEvent(MyPawn.GuitarMusicTag, None, MyPawn);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.DestroyTempBolton();
		Super.EndState();
	}
Begin:
	// Immediately face our focus
	//log("PLAYING GUITAR MY FOCUS IS"@Focus@Focus.Location);
	//MyPawn.SetRotation(rotator(Focus.Location - MyPawn.Location));
	MyPawn.PlayGuitarAnim();
	Sleep(CurrentFloat);
	if (CurrentFloat > 0)
		CurrentFloat = -1;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Take a piss!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TakeALeak
{
	// STUB defined in Bystander where we have access to the pisser
	ignores TryToGreetPasserby, ForceGetDown, SetupWatchParade, DonateSetup;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Play custom-defined animation
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LoopCustomAnim
{
	ignores TryToGreetPasserby, ForceGetDown, SetupWatchParade, DonateSetup;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		//log(self@"AnimEnd decide what next");
		MyPawn.AnimEnd(channel);
		// One loop complete, decide what to do next.
		CCurrentLoopCount++;
		// If both the loop count and duration have been satisfied, consider it done
		if (MyPawn.CustomAnim.Actions[CCurrentAction].LoopCount > 0
			&& CCurrentLoopCount >= MyPawn.CustomAnim.Actions[CCurrentAction].LoopCount
			&& CurrentFloat == 0)
			// Get next custom anim going
			FinishCurrentCustomAnim();
		else
			// Start over
			PlayCurrentCustomAnim();
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		//log(self@"BEGIN STATE INIT");
		PrintThisState();

		//SetNextState('Thinking');
		MyPawn.StopAcc();
		FocalPoint = MyPawn.Location + 100*vector(MyPawn.Rotation);
		Focus = None;
		// reset our custom anim vars
		CCurrentAction = -1;
		CTotalLoopCount = 0;
		// get bolton from custom
		MyPawn.TempBolton.bone = MyPawn.CustomAnim.Bolton.bone;
		MyPawn.TempBolton.Mesh = MyPawn.CustomAnim.Bolton.Mesh;
		MyPawn.TempBolton.StaticMesh = MyPawn.CustomAnim.Bolton.StaticMesh;
		MyPawn.TempBolton.Skin = MyPawn.CustomAnim.Bolton.Skin;
		MyPawn.TempBolton.bCanDrop = True;
		MyPawn.TempBolton.bAttachToHead = MyPawn.CustomAnim.Bolton.bAttachToHead;
		MyPawn.TempBolton.DrawScale = MyPawn.CustomAnim.Bolton.DrawScale;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		//log(self@"ENDING STATE CLEANUP");
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
		MyPawn.SetMood(MOOD_Normal, 1.0);
		// Cleanup from the custom anim stuff
		// Remove boltons if there were any
		MyPawn.DestroyTempBolton();
		// Trigger post-trigger event
		TriggerEvent(MyPawn.CustomAnim.Actions[CCurrentAction].PostTrigger, Self, Pawn);
		TriggerEvent(MyPawn.CustomAnim.ExitTrigger, Self, Pawn);
		TriggerEvent(MyPawn.CustomAnim.CollidingStaticMeshTag, Self, Pawn);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Play whatever custom anim we're on
	///////////////////////////////////////////////////////////////////////////////
	function PlayCurrentCustomAnim()
	{
		// put in some sane defaults
		if (MyPawn.CustomAnim.Actions[CCurrentAction].AnimRate == 0)
			MyPawn.CustomAnim.Actions[CCurrentAction].AnimRate = 1.0;
		if (MyPawn.CustomAnim.Actions[CCurrentAction].TweenTime == 0)
			MyPawn.CustomAnim.Actions[CCurrentAction].TweenTime = 0.15;
		MyPawn.PlayAnim(MyPawn.CustomAnim.Actions[CCurrentAction].AnimName, MyPawn.CustomAnim.Actions[CCurrentAction].AnimRate, MyPawn.CustomAnim.Actions[CCurrentAction].TweenTime);
		//log(self@"Playing"@MyPawn.CustomAnim.Actions[CCurrentAction].AnimName@MyPawn.CustomAnim.Actions[CCurrentAction].AnimRate@MyPawn.CustomAnim.Actions[CCurrentAction].TweenTime);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Finish up current custom anim and go to the next
	///////////////////////////////////////////////////////////////////////////////
	function FinishCurrentCustomAnim()
	{
		//log(self@"Finishing current custom anim cleanup and return to start");
		// Set up our PostTrigger
		TriggerEvent(MyPawn.CustomAnim.Actions[CCurrentAction].PostTrigger, Self, Pawn);
		// Add bolton if necessary
		if (MyPawn.CustomAnim.Actions[CCurrentAction].bDestroyBolton)
			MyPawn.DestroyTempBolton();
		GotoState(GetStateName(), 'BeginAgain');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Setup for next custom anim
	///////////////////////////////////////////////////////////////////////////////
	function SetupForNextCustomAnim()
	{
		//log(self@"Setup for next custom anim");
		if (MyPawn.CustomAnim.LoopCount == -1)
		{
			// Random loop
			CCurrentAction = Rand(MyPawn.CustomAnim.Actions.Length);
			//log("Picked random action"@CCurrentAction);
		}
		else
		{
			// Increment current action
			CCurrentAction++;
			//log("Picked next action"@CCurrentAction);
		}
		if (CCurrentAction >= MyPawn.CustomAnim.Actions.Length)
		{
			// All actions complete, decide what to do next.
			CTotalLoopCount++;
			//log("All anims exhausted. Loop count:"@CTotalLoopCount@"Max loops allowed:"@MyPawn.CustomAnim.LoopCount);
			TriggerEvent(MyPawn.CustomAnim.PostTrigger, Self, Pawn);
			if (MyPawn.CustomAnim.LoopCount > 0
				&& CTotalLoopCount >= MyPawn.CustomAnim.LoopCount)
			{
				// All done, go back to thinking.
				//log("ALL DONE GO BACK TO THINKING");
				GotoState('Thinking');
				return;
			}
			// Not done looping, reset to beginning.
			CCurrentAction = 0;			
		}
		// reset loop count
		CCurrentLoopCount = 0;
		// Set up our PreTrigger
		TriggerEvent(MyPawn.CustomAnim.Actions[CCurrentAction].PreTrigger, Self, Pawn);
		// Add bolton if necessary
		if (MyPawn.CustomAnim.Actions[CCurrentAction].bAddBolton)
			MyPawn.SetupTempBolton();
		// Start anim
		PlayCurrentCustomAnim();
		// If we play for a duration, set it now
		CurrentFloat = MyPawn.CustomAnim.Actions[CCurrentAction].Duration;
		//log(self@"anim setup complete");
	}
	///////////////////////////////////////////////////////////////////////////////
	// Turn Off Colliding Static Meshes
	///////////////////////////////////////////////////////////////////////////////
	function TurnOffCollidingStaticMeshes()
	{
		local SitAssist sit;
		
		sit = spawn(class'SitAssist');
		sit.SetupFor(MyPawn.CustomAnim.CollidingStaticMeshTag, MyPawn.CustomAnim.CollidingStaticMeshRadius);
	}

Begin:
	// Play next custom animation
	//log(self@"--- BEGIN");
	TriggerEvent(MyPawn.CustomAnim.PreTrigger, Self, Pawn);
	// Turn off collision for any interfering static meshes
	TurnOffCollidingStaticMeshes();
BeginAgain:
	//log(self@"--- BEGIN AGAIN");
	SetupForNextCustomAnim();
	// Wait for duration, if any. AnimEnd will handle it afterward.
	//log(self@"--- SLEEP"@CurrentFloat);
	Sleep(CurrentFloat);
	CurrentFloat = 0;	
	//log(self@"--- CurrentFloat = "@CurrentFloat);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Play the guitar. Trigger music too
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayCustomInterest extends LoopCustomAnim
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();

		// reset our custom anim vars
		CCurrentAction = -1;
		CTotalLoopCount = 0;
		// get bolton from custom
		MyPawn.TempBolton.bone = MyPawn.CustomAnim.Bolton.bone;
		MyPawn.TempBolton.Mesh = MyPawn.CustomAnim.Bolton.Mesh;
		MyPawn.TempBolton.StaticMesh = MyPawn.CustomAnim.Bolton.StaticMesh;
		MyPawn.TempBolton.Skin = MyPawn.CustomAnim.Bolton.Skin;
		MyPawn.TempBolton.bCanDrop = True;
		MyPawn.TempBolton.bAttachToHead = MyPawn.CustomAnim.Bolton.bAttachToHead;
		MyPawn.TempBolton.DrawScale = MyPawn.CustomAnim.Bolton.DrawScale;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand this way, and type at a keyboard
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state KeyboardType extends PlayArcadeGame
{

	///////////////////////////////////////////////////////////////////////////////
	// Just yell 'screw you' at them, not matter what
	///////////////////////////////////////////////////////////////////////////////
	function DonateSetup(Pawn Talker, out byte StateChange)
	{
		if(Focus == None)
		{
			Focus = Talker;
			MyPawn.SetMood(MOOD_Angry, 1.0);
			MyPawn.PlayAnim(MyPawn.GetAnimStand(), 1.0, 0.15);
			GotoState('KeyboardType', 'ScrewYou');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
		// No mood changing
	}

ScrewYou:
	MyPawn.PlayAnim(MyPawn.GetAnimStand(), 1.0, 0.15);
	Sleep(1.0+Frand());
	// Flip them off
	MyPawn.SetMood(MOOD_Angry, 1.0);
	MyPawn.PlayTellOffAnim();
	PrintDialogue("no way! you're crazy");
	//SayTime = Say(MyPawn.myDialog.lDefiant);
	SayTime = Say(MyPawn.myDialog.lDontSignPetition, true);
	Sleep(SayTime);
	Focus = None;

Begin:
	// No mood changing
	MyPawn.PlayKeyboardTypeAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// An interest point sent us here
// Stand this way, and play and arcade game.. make a mean face sometimes
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayArcadeGameInterestPoint extends PlayArcadeGame
{
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		if(statecount < CurrentFloat)
		{
			statecount++;
			GotoState(GetStateName(), 'Begin');
		}
		else
			GotoNextState();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		statecount = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// An interest point sent us here
// Stand this way, and type at a keyboard
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state KeyboardTypeInterestPoint extends KeyboardType
{
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		if(statecount < CurrentFloat)
		{
			statecount++;
			GotoState(GetStateName(), 'Begin');
		}
		else
			GotoNextState();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		statecount = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchParade
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchParade
{
	ignores TryToGreetPasserby, PerformInterestAction;

	///////////////////////////////////////////////////////////////////////////////
	// Pick a new guy to look at
	///////////////////////////////////////////////////////////////////////////////
	function SetupWatchParade(Actor OriginActor, out byte StateChange)
	{
		if(FPSPawn(OriginActor) != None
			&& FRand() < NEW_PARADER_FREQ)
		{
			InterestPawn = FPSPawn(OriginActor);
			Focus = InterestPawn;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make sure you can see your interest
	// And they're being good.
	///////////////////////////////////////////////////////////////////////////////
	function CheckInterest()
	{
		if(InterestPawn == None
			|| InterestPawn.bDeleteMe
			|| InterestPawn.Health <= 0
			|| PersonController(InterestPawn.Controller) == None
			|| !PersonController(InterestPawn.Controller).IsInState('MarchToTarget')
			|| !FastTrace(InterestPawn.Location, MyPawn.Location))
		{
			GotoStateSave('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Start out definitely watching your immediate attacker (greatest threat)
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();
		Focus = InterestPawn;
		CurrentFloat = 3.0 + 3*FRand();
	}
Begin:
	Sleep(CurrentFloat);
	CheckInterest();
	if(FRand() < COMMENT_ON_PARADE_FREQ)
	{
		PrintDialogue("The parade is great!");
		SayTime = Say(MyPawn.myDialog.lThatsGreat);
		MyPawn.PlayTalkingGesture(1.0);
	}
	else if(FRand() < CLAP_AT_PARADE_FREQ)
	{
		FocalPoint = Focus.Location;
		Focus = None;
		SetNextState('WatchParade');
		GotoStateSave('ClapAtSomething');
	}
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait around for a while (at a safe distance) and WAIT for violence to occur
//
// If InterestPawn is none, this is okay. He doesn't have to have a
// good focus to use this state.
// 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchForViolence
{
	ignores TryToGreetPasserby, /*DonateSetup,*/ PerformInterestAction;

	///////////////////////////////////////////////////////////////////////////////
	// If you're kicking too close to me, do something other than watch you
	///////////////////////////////////////////////////////////////////////////////
	function GetReadyToReactToDanger(class<TimedMarker> dangerhere, 
									FPSPawn CreatorPawn, 
									Actor OriginActor,
									vector blipLoc,
									optional out byte StateChange)
	{
		if(Attacker == None
			&& dangerhere == class'KickHitNothingMarker'
			&& P2Pawn(InterestPawn) == CreatorPawn)
		{
			// Having them freak out when you kick again (even when you're too close) was
			// too strict, so just possibly make them say things if they're far enough away
			if(SayTime == 0
				&& FRand() < COMMENT_ON_CRAZY_FREQ
				&& VSize(InterestPawn.Location - MyPawn.Location) > (2*P2Pawn(InterestPawn).MyFoot.UseMeleeDist))
			{
				GotoStateSave(GetStateName(), 'WatchTheCrazy');
			}
		}
		else
			Global.GetReadyToReactToDanger(dangerhere, CreatorPawn, OriginActor, blipLoc, StateChange);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to get closer to interest, or stop watching, if he's dead
	///////////////////////////////////////////////////////////////////////////////
	function CheckInterest()
	{
		local FPSPawn hisattacker;

		if(InterestPawn.Health > 0)
		{
			// If the person you're watching is a friend or enemy, react
			if(PersonController(InterestPawn.Controller) != None)
			{
				hisattacker = PersonController(InterestPawn.Controller).Attacker;
				if(hisattacker != None)
				{
					// If we're friends with the interest attacking someone else, then help!
					if(SameGang(InterestPawn))
					{
						SetAttacker(hisattacker);
						GotoStateSave('AssessAttacker');
					}
					// If someone is attacking the player and you're friends with him, help the player out
					else if(hisattacker.bPlayer
						&& MyPawn.bPlayerIsFriend
						&& Attacker != hisattacker)
					{
						SetAttacker(InterestPawn);
						GotoStateSave('AssessAttacker');
					}
				}
			}
		}
		else
			EarlyNextState();
	}

	///////////////////////////////////////////////////////////////////////////////
	// We're bored, so find out what to do now
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		// If we were a turret, go back to that
		if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
		{
			SetToTurret();
			GotoNextState(true);
		}
		else
		{
			// if not, just think
			GotoState('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// We're still tense
	///////////////////////////////////////////////////////////////////////////////
	function EarlyNextState()
	{
		// But in the basic state, we'll just start thinking again
		GotoState('Thinking');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Start out definitely watching your immediate attacker (greatest threat)
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();

		Focus = InterestPawn;
		FocalPoint = DangerPos;
		UseReactivity = MyPawn.Reactivity;
		statecount=0;
		SayTime = 0;
		// determines how long you sleep for
		CurrentFloat = FRand() + 1.0;
		// determines how many times you'll repeat the watch, before
		// you give up watching
		UseAttribute = Rand(STOP_WATCHING_MINOR_THREAT_RATIO);
		UseAttribute += STOP_WATCHING_MIN_COUNT;
		// If you have a weapon, brandish it! Well.. okay, not all the time
		// just a little of the time. Too often this causes waaaay too much chaos
		// in a real map, because the cops notice all the people with their weapons
		// out and they start a big firefight.
		if(MyPawn.bHasViolentWeapon
			&& (FRand() < SwitchWeaponFreq
				|| MyPawn.bGunCrazy))
			SwitchToBestWeapon();
	}

Begin:
	// Check to either get bored or keep watching
	Sleep(CurrentFloat);
	
	// If I have an interest, check him
	if(InterestPawn != None)
		CheckInterest();

	statecount++;
	if(statecount > UseAttribute)
	{
		DecideNextState();
	}
	
	Goto('Begin');// run this state again

WatchTheCrazy:
	SayTime = Say(MyPawn.myDialog.lWatchingCrazy);
	PrintDialogue("You're crazy!");
	Sleep(SayTime + Frand());
	SayTime = 0;
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Watch the dude being a cop, don't really be concerned, just watch him
// If you have a weapon *don't* pull it out
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchACop extends WatchForViolence
{
	///////////////////////////////////////////////////////////////////////////////
	// We're bored, so find out what to do now
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		// If we were a turret, go back to that
		if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
		{
			SetToTurret();
			GotoNextState(true);
		}
		else
		// if not, just think
			GotoState('Thinking');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Start out definitely watching your immediate attacker (greatest threat)
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();

		Focus = InterestPawn;
		UseReactivity = MyPawn.Reactivity;
		statecount=0;
		// determines how long you sleep for
		CurrentFloat = FRand() + 1.0;
		// determines how many times you'll repeat the watch, before
		// you give up watching
		UseAttribute = Rand(STOP_WATCHING_COP_BASE);
		UseAttribute += STOP_WATCHING_COP_ADD;
	}

Begin:
	// If I have an interest, check him
	if(InterestPawn != None)
		CheckInterest();

	// Check to either get bored or keep watching
	Sleep(CurrentFloat);
	statecount++;
	if(statecount > UseAttribute)
	{
		DecideNextState();
	}
	
	Goto('Begin');// run this state again

WatchTheCrazy:
	SayTime = Say(MyPawn.myDialog.lWatchingCrazy);
	PrintDialogue("You're crazy!");
	Sleep(SayTime + Frand());
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait around (from a safe distance hopefully) and watch the violence
// Innocent bystanders *and* armed bystanders can use this state.
// The armed ones just don't pay too much mind to distance to the threatening pawn.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchThreateningPawn extends WatchForViolence
{

	///////////////////////////////////////////////////////////////////////////////
	// We're still tense
	///////////////////////////////////////////////////////////////////////////////
	function EarlyNextState()
	{
		GotoStateSave('WatchForViolence');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to see if the attacker guy we're watching is looking at us 
	// through is scope. If so, move
	///////////////////////////////////////////////////////////////////////////////
	function CheckForInLineOfFire(FPSPawn AimingGuy)
	{
		local float dottry;

		// Turrets don't care about line of fire
		if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
			return;

		// If he DOESN'T have a lethal weapon out, don't worry about it
		// OR if the weapon he has out is range based, then don't worry about
		// that either.
		if(AimingGuy.Weapon != None
			&& P2Weapon(AimingGuy.Weapon).ViolenceRank <= 0
//			|| AimingGuy.Weapon.bMeleeWeapon)
			)
		{
			statecount++;
			return;
		}

		// Check if you can't see your interest pawn. If not, 
		// consider going back to thinking
		if(!FastTrace(MyPawn.Location, AimingGuy.Location))
		{
			statecount++;
			return;
		}

		statecount=0;
		// If within a close range, then he feels like he could get shot, so he'll 
		// become more aware and more likely to move
		if(CloseEnoughToMakeOutDangerousWeapon(AimingGuy, MyPawn)
			&& WeaponPointedDirectlyAtUs(AimingGuy, MyPawn))
		{
			// Only get scared if we don't have a weapon too
			if(!MyPawn.bHasViolentWeapon)
			{
				UseReactivity += (UseReactivity + 1.0)/2;

				if(FRand() <= UseReactivity)
				{
					// We don't mind moving out of the way *this* time
					if(FRand() <= UsePatience)
					{
						//log("fleeing from his stare");

						// increase your range
						UseSafeRangeMin*=SAFE_RANGE_HARASS_INCREASE;

						InterestPawn = AimingGuy;
						GotoStateSave('ShyToSafeDistance');
						return;
					}
					else // he's harassed us too much
					{
						//log(" it's too much, i'm running! ");
						InterestPawn = AimingGuy;
						SetAttacker(AimingGuy);
						DangerPos = InterestPawn.Location;
						UseSafeRangeMin*=SAFE_RANGE_HARASS_INCREASE;
						// crank up the current safe distance
						if(PickScreamingStill())
							GotoStateSave('ScreamingStill');
						else
							GotoStateSave('FleeFromAttacker');
						return;
					}

					// Become less patient
					MakeLessPatient(HARASS_PATIENCE_LOSS);
				}
			}
		}
		return;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to see if you want to observe this pawn's personal looks (does he have a
	// gun, is he naked)
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		local float usedist;
		local bool bcheck;

		// If I don't have a violent weapon, then act on his looks
		if(!MyPawn.bHasViolentWeapon
			&& CanSeePawn(MyPawn, LookAtMe))
		{
			if(LookAtMe == InterestPawn)
			{
				usedist = VSize(InterestPawn.Location - MyPawn.Location);
				// We were already concerned about him
				if(usedist/UseSafeRangeMin < THREAT_TOO_CLOSE)
				{
					// And he's too close for comfort.
					if(FRand() > UseReactivity)
						MakeMoreAlert();

					SetAttacker(InterestPawn);
					DangerPos = InterestPawn.Location;
					if(PickScreamingStill())
						GotoStateSave('ScreamingStill');
					else
						GotoStateSave('FleeFromAttacker');
				}
			}
			else if(Attacker != LookAtMe)
				ActOnPawnLooks(LookAtMe);
		}
		else
			ActOnPawnLooks(LookAtMe);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check both things that are violent, that you're watching, and try to get
	// a better distance away, if needed
	///////////////////////////////////////////////////////////////////////////////
	function ReevaluateThreatDistances(FPSPawn AimingGuy)
	{
		local vector dir, checkpoint;

		// If I don't have a violent weapon then check our distances
		if(AimingGuy != None)
		{
			dir = (MyPawn.Location - AimingGuy.Location);
			dir.z=0;

			// Dist between threat and me
			CurrentDist = VSize(dir);

			if(CurrentDist < UseSafeRangeMin - DEFAULT_END_RADIUS)
			// time to run to a better location
			{
				// Every once in a while, make him more alert
				if(FRand() > UseReactivity)
					MakeMoreAlert();

				// If we have a weapon, run away from the threat, but
				// turn around again and watch (don't be scared too much)
				if(MyPawn.bHasViolentWeapon)
				{
					// Unless I'm a turret, in which case, do nothing
					if(MyPawn.PawnInitialState != MyPawn.EPawnInitialState.EP_Turret)
					{
						checkpoint = UseSafeRangeMin*Normal(MyPawn.Location - InterestPawn.Location) + MyPawn.Location;
						GetMovePointOrHugWalls(checkpoint, MyPawn.Location, UseSafeRangeMin, true);
						SetNextState('WatchThreateningPawn');
						bStraightPath=UseStraightPath();
						SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
						GotoStateSave('RunToTargetUrgent');
					}
				}
				else
				{
					// Run from the scary guy, we have no gun
					SetAttacker(AimingGuy);
					DangerPos = Attacker.Location;
					if(PickScreamingStill())
						GotoStateSave('ScreamingStill');
					else
						GotoStateSave('FleeFromAttacker');
				}
				return;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Start out definitely watching your immediate attacker (greatest threat)
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local P2Weapon p2weap;

		PrintThisState();

		if(InterestPawn == None)
		{
			PrintStateError(" No interest, watching for violence in general.");
			GotoStateSave('WatchForViolence');
			return;
		}
		else
		{
			// Start by looking at your interest pawn
			Focus = InterestPawn;
			DangerPos = InterestPawn.Location;

			//log(MyPawn$" watching threat interest "$InterestPawn);
			// If the interest is the player and you're friends with him
			// or another friend in general and he's not also your attacker 
			// then 'upgrade' and move to a calmer state
			if(!IsInState('WatchFriend')
				&& (SameGang(InterestPawn)
					|| (InterestPawn.bPlayer
						&& MyPawn.bPlayerIsFriend)))
			{
				GotoStateSave('WatchFriend');
				return;
			}

			// If you're really tired, rest instead
			if(DistanceRun > MyPawn.Fitness*MAX_DISTANCE_BEFORE_TIRED)
			{
				GotoStateSave('RestFromAttacker');
				return;
			}

			// Determines how long you sleep for, the more scary the weapon, the more likely
			// we are to do an update
			if(InterestPawn != None
				&& P2Weapon(InterestPawn.Weapon) != None)
			{
				p2weap = P2Weapon(InterestPawn.Weapon);
				CurrentFloat = FRand()/2 - (p2weap.GetViolenceRatio()) + 0.1;
				// determines how many times you'll repeat the watch, before
				// you give up watching
				UseAttribute = Rand(STOP_WATCHING_MAJOR_THREAT_RATIO) + p2weap.ViolenceRank;
				UseAttribute += STOP_WATCHING_MIN_COUNT;
			}
			else
			{
				CurrentFloat = FRand() + 1.0;
				// determines how many times you'll repeat the watch, before
				// you give up watching
				UseAttribute = Rand(STOP_WATCHING_MAJOR_THREAT_RATIO);
				UseAttribute += STOP_WATCHING_MIN_COUNT;
			}

			statecount=0;

			// stop moving
			MyPawn.StopAcc();

			// If you have a weapon, brandish it! Well.. okay, not all the time
			// just a little of the time. Too often this causes waaaay too much chaos
			// in a real map, because the cops notice all the people with their weapons
			// out and they start a big firefight.
			if(MyPawn.bHasViolentWeapon
				&& (FRand() < SwitchWeaponFreq
					|| MyPawn.bGunCrazy))
				SwitchToBestWeapon();
		}
	}

Begin:
	// look at it for your react time
	Sleep(CurrentFloat);

	// In case our guy got killed along the way
	if(InterestPawn == None)
		EarlyNextState();
	else
		CheckInterest();


	// Try to react to it's death
	// What you just were interested in has died, see what to do
	if((InterestPawn.Health <= 0
		|| InterestPawn.Controller == None 
		|| InterestPawn.Controller.IsInState('Dying'))
		&& CanSeePawn(MyPawn, InterestPawn))
	{
		SetNextState('WatchForViolence');
		ViolenceWatchDeath(InterestPawn);
	}

	// Check to make sure i'm not doing something stupid like standing
	// where the guy can hit me.
	CheckForInLineOfFire(InterestPawn);

	// Check the guy you're looking at for being too close
	if(statecount == 0)
		// 0 means we can see him and he is still a threat,
		// > 0 means we're thinking about not caring anymore
		ReevaluateThreatDistances(InterestPawn);

	if(statecount > UseAttribute)
	{
		DecideNextState();
	}

	Goto('Begin');// run this state again

WatchTheCrazy:
	SayTime = Say(MyPawn.myDialog.lWatchingCrazy);
	PrintDialogue("You're crazy!");
	Sleep(SayTime + Frand());
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// A friend player or otherwise, is doing something kinda violent.. watch.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchFriend extends WatchThreateningPawn
{
	function ReevaluateThreatDistances(FPSPawn AimingGuy)
	{
	}
	function CheckForInLineOfFire(FPSPawn AimingGuy)
	{
	}

	///////////////////////////////////////////////////////////////////////////////
	// Care about the looks of any one else
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		if(LookAtMe != InterestPawn)
			ActOnPawnLooks(LookAtMe);
	}

Begin:
	// look at it for your react time
	Sleep(CurrentFloat);

	// In case our guy got killed along the way
	if(InterestPawn == None)
		GotoStateSave('WatchForViolence');

	// Try to react to it's death
	// What you just were interested in has died, see what to do
	if((InterestPawn.Health <= 0
		|| InterestPawn.Controller == None 
		|| InterestPawn.Controller.IsInState('Dying'))
		&& CanSeePawn(MyPawn, InterestPawn))
	{
		SetNextState('WatchForViolence');
		ViolenceWatchDeath(InterestPawn);
	}

	if(statecount > UseAttribute)
	{
		DecideNextState();
	}
	else
		statecount++;

	Goto('Begin');// run this state again

WatchTheCrazy:
	SayTime = Say(MyPawn.myDialog.lWatchingCrazy);
	PrintDialogue("You're crazy!");
	Sleep(SayTime + Frand());
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// The interest isn't threatening.. just interesting.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchPlayer extends WatchForViolence
{
	///////////////////////////////////////////////////////////////////////////////
	// Check if the player's sight type is still interesting
	///////////////////////////////////////////////////////////////////////////////
	function bool PlayerStillInteresting()
	{
		if(P2Player(InterestPawn.Controller) != None
			&& (P2Player(InterestPawn.Controller).SightReaction == MyPawn.EPawnInitialState.EP_WatchPlayer
				|| P2Player(InterestPawn.Controller).SightReaction == MyPawn.EPawnInitialState.EP_ConfusedWatchPlayer))
				return true;
		else
			return false;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Check if the player has changed the crazy thing he's doing, then we'll update
	///////////////////////////////////////////////////////////////////////////////
	function bool PlayerDoingSomethingDifferent(FPSPawn LookAtMe)
	{
		if(P2Player(LookAtMe.Controller) != None
			&& P2Player(LookAtMe.Controller).SightReaction != 0
			&& P2Player(LookAtMe.Controller).SightReaction != PlayerSightReaction)
		{
			// Update
			if(LookAtMe == InterestPawn)
				InterestPawn = None;
			PlayerSightReaction = P2Player(LookAtMe.Controller).SightReaction;
			return true;
		}
		else
			return false;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Care about the looks of any one else
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		if(LookAtMe != InterestPawn
			|| PlayerDoingSomethingDifferent(LookAtMe))
			ActOnPawnLooks(LookAtMe);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Start out definitely watching your immediate attacker (greatest threat)
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();

		Focus = InterestPawn;
		FocalPoint = DangerPos;
		UseReactivity = MyPawn.Reactivity;
		statecount=0;
		// determines how long you sleep for
		CurrentFloat = FRand() + 1.0;
		// determines how many times you'll repeat the watch, before
		// you give up watching
		UseAttribute = Rand(STOP_WATCHING_MINOR_THREAT_RATIO);
		UseAttribute += STOP_WATCHING_MIN_COUNT;
	}

Confused:
	Sleep(FRand());
	PrintDialogue("What the..");
	SayTime = Say(MyPawn.myDialog.lWhatThe);
	MyPawn.PlayTalkingGesture(1.0);

Begin:
	// look at it for your react time
	Sleep(CurrentFloat);

	// In case our guy got killed along the way
	if(InterestPawn == None)
		GotoStateSave('WatchForViolence');

	// Try to react to it's death
	// What you just were interested in has died, see what to do
	if((InterestPawn.Health <= 0
		|| InterestPawn.Controller == None 
		|| InterestPawn.Controller.IsInState('Dying'))
		&& CanSeePawn(MyPawn, InterestPawn))
	{
		SetNextState('WatchForViolence');
		ViolenceWatchDeath(InterestPawn);
	}

	if(statecount > UseAttribute)
	{
		DecideNextState();
	}
	else if(!PlayerStillInteresting())
		// Only increment if the player's sight type isn't interesting any more
		statecount++;

	Goto('Begin');// run this state again

WatchTheCrazy:
	SayTime = Say(MyPawn.myDialog.lWatchingCrazy);
	PrintDialogue("You're crazy!");
	Sleep(SayTime + Frand());
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchGuyOnFire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchGuyOnFire extends WatchForViolence
{
	///////////////////////////////////////////////////////////////////////////////
	// Check to get closer to interest, or stop watching, if he's dead
	///////////////////////////////////////////////////////////////////////////////
	function CheckInterest()
	{
		local FPSPawn hisattacker;

		// If the person you're watching is a friend or enemy, react
		if(PersonController(InterestPawn.Controller) != None)
		{
			hisattacker = PersonController(InterestPawn.Controller).Attacker;
			if(hisattacker != None)
			{
				// If we're friends with the interest attacking someone else, then help!
				if(SameGang(InterestPawn))
				{
					SetAttacker(hisattacker);
					GotoStateSave('AssessAttacker');
				}
				// If someone is attacking the player and you're friends with him, help the player out
				else if(hisattacker.bPlayer
					&& MyPawn.bPlayerIsFriend
					&& Attacker != hisattacker)
				{
					SetAttacker(InterestPawn);
					GotoStateSave('AssessAttacker');
				}
			}
		}
		// If you can't see him, or he's not still on fire, give up watching
		else if(InterestPawn.MyBodyFire == None
			|| !FastTrace(InterestPawn.Location, MyPawn.Location))
			DecideNextState();
		else // think about making fun of the fact that he's on fire
		{
			if(SayTime == 0
				&& FRand() < COMMENT_ON_FIRE_FREQ)
				GotoStateSave(GetStateName(), 'WatchTheCrazy');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// We're bored, so find out what to do now
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		// If we were a turret, go back to that
		if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
		{
			SetToTurret();
			GotoNextState(true);
		}
		else
		{
			// if not, just think
			GotoState('Thinking');
		}
	}

Begin:
	// Check to either get bored or keep watching
	Sleep(CurrentFloat);
	
	// If I have an interest, check him
	if(InterestPawn != None
		&& !InterestPawn.bDeleteMe
		&& InterestPawn.Health > 0)
		CheckInterest();
	else // if not, go back to normal
		DecideNextState();
	
	Goto('Begin');// run this state again

WatchTheCrazy:
	SayTime = Say(MyPawn.myDialog.lsomeoneonfire, true);
	PrintDialogue("Ha ha! You're on fire!");
	Sleep(SayTime + Frand());
	SayTime = 0;
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Watch a fire burn at a nice safe range
// run to if, if you have to
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchFireFromSafeRange
{
	///////////////////////////////////////////////////////////////////////////////
	// Watch the fire we're interested in. If it moves, or if new
	// fire 'appears' (dude creates it) then move, possibly.
	///////////////////////////////////////////////////////////////////////////////
	function int WatchInterestFire()
	{
		local FireEmitter NewFire;
		local byte DoRun;
		
		//log("old fire is at .. "$InterestActor.Location );

		if(InterestActor == None)
			return 0;

		NewFire = CheckForFire(MyPawn.Location, InterestActor.Location);
		//log("new fire is "$NewFire);
		//log("old fire is.. "$InterestActor);

		if(NewFire == None)
		{
			if(InterestActor.LifeSpan <= 1.0)
			{
				InterestActor = None;
				return 0;
			}
		}
		else
		{
			// there's new fire in the way, so MOVE IT!!!
			if(NewFire != InterestActor)
			{
				InterestActor = NewFire;

				SetupWatchFire(DoRun);
				if(DoRun == 1)
					return 1;
				else
					return 2;
			}
		}

		return 3;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		InterestActor = None;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Look at the pretty fire
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.ShouldCrouch(false);
		MyPawn.StopAcc();
	}

ListenToFocus:
	Sleep(0.5);

	Focus = InterestPawn;

	Sleep(2.0);

LookAtFire:
	Focus = InterestActor;

Begin:
	// Check the fire you're supposed to be watching
	statecount = WatchInterestFire();

	if(statecount == 0)
	{
		// no more watching, fire is gone.. darn.
		GotoStateSave('Thinking');
	}
	else if(statecount == 1)
	{
		SetNextState('WatchFireFromSafeRange', 'LookAtFire');
		// A different fire is too close, so make it your new focus, and run
		GotoStateSave('RunToFireSafeRange');
	}
	else if(statecount == 2)
	{

		SetNextState('WatchFireFromSafeRange', 'LookAtFire');
		// A different fire is too close, so make it your new focus, and run
		GotoStateSave('WalkToFireSafeRange');
	}

	// watch for a while
	Sleep(1.0 + MyPawn.Curiosity);

	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// The voodoo fish is attacking! Not much you can do, but be freaked out
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AttackedByChompy
{
	ignores BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, HearAboutKiller, GetOutOfMyWay,
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker, InterestIsAnnoyingUs, GetHitByDeadThing, 
		HandlePlayerSightReaction, MarkerIsHere, CheckObservePawnLooks, RespondToCopBother, 
		DecideToListen, HandleFireInWay, SetupSideStep, SetupBackStep, SetupMoveForRunner, 
		AllowOldState, RocketIsAfterMe,
		DoWaitOnOtherGuy, TryToSendAway, HitWithFluid, CanHelpOthers, DangerPawnBump, Trigger, DoGetKnockedOut, TookNutShot, BlindedByFlashBang;

	function BeginState()
	{
		PrintThisState();
		MyPawn.SetMood(MOOD_Scared, 1.0);
		MyPawn.StopAcc();
	}
Begin:
	// Look around and freak out
	LookAroundWithHead(Frand(), 0.1, 0.2, 0.3, 0.4, 1.0);
	LookInRandomDirection();
	TryToScream(true);
	TimeToScream();
	Sleep(FRand() + 1.0);
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ScreamingStill
// Stand still and scream, then run
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ScreamingStill
{
	ignores BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, HearAboutKiller, 
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker, InterestIsAnnoyingUs, GetHitByDeadThing, 
		HandlePlayerSightReaction, MarkerIsHere, CheckObservePawnLooks, RespondToCopBother, RocketIsAfterMe,
		DecideToListen, HandleFireInWay, SetupSideStep, SetupBackStep, SetupMoveForRunner, AllowOldState, 
		DoWaitOnOtherGuy, TryToSendAway, HitWithFluid, CanHelpOthers, DangerPawnBump, Trigger,
		SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function PlayScreaming()
	{
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;
		MyPawn.PlayScreamingStillAnim();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		SetAttacker(InterestPawn);
		GotoStateSave('FleeFromAttacker');
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
			DecideNextState();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangeAnimation();
		ScreamState = SCREAM_STATE_NONE;
	}

Begin:
	MyPawn.StopAcc();
	MyPawn.SetMood(MOOD_Scared, 1.0);
	Sleep(FRand()/2);
	PlayScreaming();
	Sleep(0.5);
	PrintDialogue("Big Aaaaah! or maybe no screaming sometimes");
	SayTime = Say(MyPawn.myDialog.lScreaming);
	ScreamState = SCREAM_STATE_DONE;
	Sleep(SayTime+FRand()/2);
	DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You want to get outside of your minimum safe range from
// whatever scared you.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FleeFromDanger
{
	ignores RespondToQuestionNegatively, ActOnPawnLooks, CheckDeadBody, WatchFunnyThing, 
		CheckDesiredThing, DonateSetup, SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	// You've got a valid target, now decide how to get there (run, walk)
	// And how to scream or whatever on the way there
	///////////////////////////////////////////////////////////////////////////////
	function HeadToNextTarget()
	{
		GotoStateSave('RunToTargetFromDanger');
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
		local PathNode pnode;

		// Try to make dir fit terrain
		// Draw forward first and find the first wall hit
		checkpoint = MyPawn.Location + (CurrentDist*InterestVect);

		// If there's nothing in the way, then try to run to the nearest pathnode
		// to this point
		if(FastTrace(MyPawn.Location, checkpoint))
		{
			// get the closest pathnode to this point and run to it
			foreach CollidingActors(class'PathNode', pnode, PATHNODE_SEARCH_RADIUS)
				break;

			if(pnode != None)
				SetEndGoal(pnode, DEFAULT_END_RADIUS);
		}
		
		if(pnode == None)
			SetEndGoal(FindRandomPathNodeDest(), DEFAULT_END_RADIUS);

		// If we still  didn't find anything, just use the point we calced and hope for the best
		if(EndGoal == None)
		{
			GetMovePointOrHugWalls(checkpoint, MyPawn.Location, CurrentDist, true);
			SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
		}

		HeadToNextTarget();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Try to run directly away from your danger. Check for wall hits.
	///////////////////////////////////////////////////////////////////////////////
	function CalcRunDirection()
	{
		local vector otherdir;

		// Find direction away from danger
		InterestVect = (MyPawn.Location - DangerPos);
		if(MyPawn.Location.z < DangerPos.z)
			InterestVect.z=0;
		InterestVect = Normal(InterestVect);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find where the problem is
	///////////////////////////////////////////////////////////////////////////////
	function bool CalcProblemDistance()
	{
		local vector dir;

		//log("known danger "$KnownDanger);
		dir = (MyPawn.Location - DangerPos);
		dir.z=0;
		// Dist between attacker and me
		CurrentDist = VSize(dir);

		if(CurrentDist < DEFAULT_END_RADIUS)
			CurrentDist = DEFAULT_END_RADIUS;

		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Based on various things around me, decide what to do next
	// We're leaving this state now
	///////////////////////////////////////////////////////////////////////////////
	function PickNextStateNow()
	{
		if(Attacker != None)
			InterestPawn = Attacker;

		if(InterestPawn != None)// && Attacker != None)
			SetNextState('WatchThreateningPawn');
		else
			SetNextState('WatchForViolence');
	}

	///////////////////////////////////////////////////////////////////////////////
	// See if we can still see our attacker and decide what to do
	///////////////////////////////////////////////////////////////////////////////
	function DoAttackerCheck()
	{
		local vector HitLocation, HitNormal;
		local Actor HitActor;
		local bool bStopRunning;

		HitActor = Trace(HitLocation, HitNormal, DangerPos, MyPawn.Location, true);
		if(HitActor != None
			&& HitActor != Attacker
			&& HitActor != InterestPawn)
				bStopRunning=true;

		//log(self$" doing attacker check "$bStopRunning$" attacker is "$Attacker);

		// If we can't see our danger point, calm down
		if(bStopRunning)
		{
			if(Attacker != None)
				InterestPawn = Attacker;

			if(InterestPawn != None)// && Attacker != None)
				GotoStateSave('WatchThreateningPawn');
			else
				GotoStateSave('WatchForViolence');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Look around for cops
	///////////////////////////////////////////////////////////////////////////////
	function DoCopCheck()
	{
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find where to run
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// Start screaming now
		TryToScream(true);

		// toss your current weapon and get running!
		ThrowWeapon();

		MyPawn.SetMood(MOOD_Scared, 1.0);
	}


TakeABreather:
	// wait a second now that we're here again
	Focus = InterestPawn;
	Sleep(FRand());

Restart:
	DoAttackerCheck();
	DoCopCheck();
Begin:
	CurrentFloat=0;
	if(!CalcProblemDistance())
	{
		// Pick it and go to it immediately
		PickNextStateNow();
		GotoNextState(true);
	}
	else
		PickNextStateNow();

	// to see if we're far enough away already or not.
	CalcRunDirection();

	TryThisDirection();
/*
	// Only makes him pause like a retard every once in a while
	if(FRand() <= TAKE_A_BREATHER_FREQ)
//	if(FRand() > UseReactivity)
	{
		if(InterestPawn != None)
			Focus = InterestPawn;	// stare at the thing that caused me to run
		else
		{
			Focus = None;
			FocalPoint = DangerPos;
		}

		Sleep(1.0 - MyPawn.Reactivity);

		DoAttackerCheck();
		DoCopCheck();

		//log("recalc run direction");
		CalcRunDirection();
	}
	else
		Sleep(0.0);
	Goto('Begin');// run this state again
	*/
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run around screaming all the time
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FleeForever extends FleeFromDanger
{
	ignores GetReadyToReactToDanger, CheckDeadHead,
		WatchHeadExplode, WatchDeadCatHitGuy, ViolenceWatchDeath;

	///////////////////////////////////////////////////////////////////////////////
	// You've got a valid target, now decide how to get there (run, walk)
	// And how to scream or whatever on the way there
	///////////////////////////////////////////////////////////////////////////////
	function HeadToNextTarget()
	{
		SetNextState('FleeForever');
		GotoStateSave('RunToTargetFromDanger');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Try to run directly away from your attacker. Check for wall hits.
	///////////////////////////////////////////////////////////////////////////////
	function CalcRunDirection()
	{
		local vector otherdir;

		EndGoal = None;

		// Pick directly away from our attacker
		InterestVect = VRand();
		InterestVect.z=0;
		InterestVect = Normal(InterestVect);
/*
		// Sometimes don't run direction away, but run to the sides
		if(FRand() > 0.3)
		{
			// Find direction away from danger
			// But the direction as a combination of away from the attacker but
			// also away from the direction he's moving.
			if(Attacker.Velocity.x == 0 && Attacker.Velocity.y==0)
				// pick the direction he was facing
				otherdir = vector(Attacker.Rotation);
			else // pick his velocity, since he was moving
				otherdir = Normal(Attacker.Velocity);
			otherdir.z=0;
			// Factor in the other direction along with the main dir
			InterestVect -= otherdir;
			InterestVect = Normal(InterestVect);
			// Sometimes flip the direction in which you choose to run away
			if(FRand() > 0.5)
			{
				//log(" BIG FLIP");
				InterestVect.x = -InterestVect.x;
				InterestVect.y = -InterestVect.y;
			}
		}
		*/
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find where the problem is
	///////////////////////////////////////////////////////////////////////////////
	function bool CalcProblemDistance()
	{
		local vector dir;

		dir = UseSafeRangeMin*VRand();
		dir.z=0;
		// Dist between attacker and me
		CurrentDist = VSize(dir);

		if(CurrentDist < DEFAULT_END_RADIUS)
			CurrentDist = DEFAULT_END_RADIUS;
		else
			CurrentDist = UseSafeRangeMin;
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You want to get outside of your minimum safe range from
// your attacker.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FleeFromAttacker extends FleeFromDanger
{
	ignores GetReadyToReactToDanger;

	///////////////////////////////////////////////////////////////////////////////
	// You've got a valid target, now decide how to get there (run, walk)
	// And how to scream or whatever on the way there
	///////////////////////////////////////////////////////////////////////////////
	function HeadToNextTarget()
	{
		// If we're missing limbs, just deathcrawl when we're done
		if (MyPawn.bMissingLimbs)
			SetNextState('PrepDeathCrawl');
		else
			SetNextState('WatchThreateningPawn');
		GotoStateSave('RunToTargetFromAttacker');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Try to run directly away from your attacker. Check for wall hits.
	///////////////////////////////////////////////////////////////////////////////
	function CalcRunDirection()
	{
		local vector otherdir;

		EndGoal = None;

		// Pick directly away from our attacker
		InterestVect = (MyPawn.Location - Attacker.Location);
		if(MyPawn.Location.z < Attacker.Location.z)
			InterestVect.z=0;
		InterestVect = Normal(InterestVect);
/*
		// Sometimes don't run direction away, but run to the sides
		if(FRand() > 0.3)
		{
			// Find direction away from danger
			// But the direction as a combination of away from the attacker but
			// also away from the direction he's moving.
			if(Attacker.Velocity.x == 0 && Attacker.Velocity.y==0)
				// pick the direction he was facing
				otherdir = vector(Attacker.Rotation);
			else // pick his velocity, since he was moving
				otherdir = Normal(Attacker.Velocity);
			otherdir.z=0;
			// Factor in the other direction along with the main dir
			InterestVect -= otherdir;
			InterestVect = Normal(InterestVect);
			// Sometimes flip the direction in which you choose to run away
			if(FRand() > 0.5)
			{
				//log(" BIG FLIP");
				InterestVect.x = -InterestVect.x;
				InterestVect.y = -InterestVect.y;
			}
		}
		*/
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find where the problem is
	///////////////////////////////////////////////////////////////////////////////
	function bool CalcProblemDistance()
	{
		local vector dir;

		dir = (MyPawn.Location - DangerPos);
		dir.z=0;
		// Dist between attacker and me
		CurrentDist = VSize(dir);

		if(CurrentDist < DEFAULT_END_RADIUS)
			CurrentDist = DEFAULT_END_RADIUS;
		else
			CurrentDist = UseSafeRangeMin;
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You see someone with a big gun. Slowly move away from where they are heading
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShyToSafeDistance extends FleeFromDanger
{
	///////////////////////////////////////////////////////////////////////////////
	// Collide this way and search for the distance most closely matching our
	// desired distance.
	///////////////////////////////////////////////////////////////////////////////
	function TryThisDirection()
	{
		local vector HitLocation, HitNormal, checkpoint;
		local Actor HitActor;

		checkpoint = MyPawn.Location + (CurrentDist*InterestVect);

		HitActor = Trace(HitLocation, HitNormal, checkpoint, MyPawn.Location, true);

		if(HitActor != None)
		{
			// move away from obstruction
			checkpoint = HitLocation;
			MovePointFromWall(checkpoint, HitNormal, MyPawn);
		}

		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
		HeadToNextTarget();
	}

	///////////////////////////////////////////////////////////////////////////////
	// You've got a valid target, now decide how to get there (run, walk)
	// And how to scream or whatever on the way there
	///////////////////////////////////////////////////////////////////////////////
	function HeadToNextTarget()
	{
		// Run to endpoint
		Focus = InterestPawn;
		// We hope MyNextState was set to something useful, before we leave
		if(MyNextState=='')
			PrintStateError(" no mynextstate");

		if(CurrentFloat/UseSafeRangeMin < TOO_CLOSE_CHANGE_TO_RUN_RATIO
			|| FRand() > UsePatience)
		{
			GotoStateSave('RunToTargetShy');
		}
		else
		{
			bDontSetFocus=true;	// side step here for only the walk (the run looks silly)
			// make him less patient
			MakeLessPatient(SHY_AWAY_PATIENCE_LOSS);
			GotoStateSave('WalkToTargetShy');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Try to run directly away from your attacker. Check for wall hits.
	///////////////////////////////////////////////////////////////////////////////
	function CalcRunDirection()
	{
		local vector dir, rundir, otherdir;
		local float usedist;
		local Actor HitActor;
		local vector HitLocation, HitNormal;

		// Pick directly away from our attacker
//		InterestVect = (MyPawn.Location - InterestPawn.Location);
//		InterestVect.z=0;
//		InterestVect = Normal(InterestVect);

		//movedist = ObstructingPawn.CollisionRadius + MyPawn.CollisionRadius + FRand()*MyPawn.AttackRange.Min;
		usedist = CurrentDist;
		CurrentDist = (UseSafeRangeMin - CurrentDist)/2;
		//log("use dist "$CurrentDist);
		if(InterestPawn != None)
			dir = Normal(InterestPawn.Location - MyPawn.Location);
		else
			dir = Normal(DangerPos - MyPawn.Location);
		otherdir = vector(InterestPawn.Rotation);

		// He will either run (local) to the right or left. So pick one
		rundir = (dir cross otherdir);
		rundir.x=0;
		rundir.y=0;
		if(rundir.z > 0)
			rundir.z = 1.0;
		else
			rundir.z = -1.0;
		//log("after rundir "$rundir);
		// Get the perpendicular direction
		InterestVect = dir cross rundir;

		// Find out close I am and veer away more sharply, the closer I am
		// At a great distance, just walk pretty close to along your normal path.
		// The closer you are, the more of a 90 angle away from you he goes.
		usedist = (usedist/UseSafeRangeMin);
		//log("veer dist "$usedist);
		if(usedist < 1.0)
		{
			Normal((1.0 - usedist)*InterestVect - usedist*otherdir);
		}
		else
			InterestVect = Normal(InterestVect - otherdir);

		// sometimes move a little closer to the interest pawn as you're walking

//		InterestVect = Normal(InterestVect - otherdir);//+ vector(MyPawn.Rotation));

		//if(FRand() <= MyPawn.Confidence)
//			InterestVect = Normal(InterestVect + dir);


/*

		// Sometimes don't run direction away, but run to the sides
//		if(FRand() > 0.3)
//		{
			// Find direction away from danger
			// But the direction as a combination of away from the attacker but
			// also away from the direction he's moving.
//		log("interestvect "$Interestvect);
			if(InterestPawn.Velocity.x == 0 && InterestPawn.Velocity.y==0)
				// pick the direction he was facing
				otherdir = vector(InterestPawn.Rotation);
			else // pick his velocity, since he was moving
				otherdir = Normal(InterestPawn.Velocity);
			otherdir.z=0;
			// Factor in the other direction along with the main dir
			InterestVect -= otherdir;
			InterestVect = Normal(InterestVect);
//		log("USEinterestvect "$Interestvect);
			// Sometimes flip the direction in which you choose to run away
			*/
/*			if(FRand() > 0.5)
			{
				//log(" BIG FLIP");
				InterestVect.x = -InterestVect.x;
				InterestVect.y = -InterestVect.y;
			}
		}
		*/
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find where the problem is
	///////////////////////////////////////////////////////////////////////////////
	function bool CalcProblemDistance()
	{
		local vector dir;

		if(InterestPawn != None)
			dir = (MyPawn.Location - InterestPawn.Location);
		else
			dir = (MyPawn.Location - DangerPos);
		dir.z=0;
		// Dist between InterestPawn and me
		CurrentDist = VSize(dir);
		CurrentFloat = CurrentDist;

		if(CurrentDist > UseSafeRangeMin - DEFAULT_END_RADIUS)
		{
			CurrentDist = MIN_SHY_DIST;
			CurrentFloat = CurrentDist;
		}
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find where to run
	// But we don't scream when we're just shying away
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// Start screaming now
		//TryToScream(true);

		// toss your current weapon and get running!
		//ThrowWeapon();

		MyPawn.SetMood(MOOD_Scared, 1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You want to get outside of your minimum safe range from
// your attacker.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FleeFromPisser extends FleeFromAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// You've got a valid target, now decide how to get there (run, walk)
	// And how to scream or whatever on the way there
	///////////////////////////////////////////////////////////////////////////////
	function HeadToNextTarget()
	{
		// Run to endpoint
		//log("going to run to "$EndPoint);
		//log("my pos "$MyPawn.Location);
		Focus = InterestPawn;
		GotoStateSave('RunFromPisser');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find where the problem is
	///////////////////////////////////////////////////////////////////////////////
	function bool CalcProblemDistance()
	{
		if(FRand() <= MyPawn.Curiosity)
			return true;	// sometimes give up early so you can get pissed on again
		else
			Super.CalcProblemDistance();
	}

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// I've got lots of gross fluid on my face.. wipe it off.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WipeFace
{
	ignores BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, HearAboutKiller,  GetOutOfMyWay,
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker, InterestIsAnnoyingUs, GetHitByDeadThing,
		MarkerIsHere, CheckObservePawnLooks, RespondToCopBother, DecideToListen, HandleFireInWay, RocketIsAfterMe,
		SetupSideStep, SetupBackStep, SetupMoveForRunner, AllowOldState, DoWaitOnOtherGuy, TryToSendAway,
		CheckWipeFace, CanHelpOthers;
	
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
			MyPawn.WipeHead();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}

Begin:
	MyPawn.StopAcc();

	MyPawn.DisgustedSpitting(MyPawn.myDialog.lGettingPissedOn);

	MyPawn.PlayWipeFaceAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Someone has done something stupid to us, like flick a match in our
// face, see what to do about it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GetAngryWithInterest
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, RespondToQuestionNegatively, 
		TryToGreetPasserby, DonateSetup, AllowOldState;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		GotoState(MyOldState);
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0
			&& statecount == 1)
		{
			DecideNextState();
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
		InterestActor = None;
	}
	///////////////////////////////////////////////////////////////////////////////
	// stop running before you do this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		bPreserveMotionValues=false;
		MyPawn.StopAcc();
		statecount=0;
	}

Begin:
	// turn to idiot
	Focus = InterestActor;
	// get angry
	MyPawn.SetMood(MOOD_Angry, 1.0);

	SayTime = Say(MyPawn.myDialog.lGetMad);
	// wait while we yell
	PrintDialogue("watch it!");
	Sleep(SayTime+Frand());

	MakeLessPatient(HARASS_PATIENCE_LOSS);

	if(FRand() > UsePatience)
	{
		// Flip them off
		statecount=1;
		MyPawn.PlayTellOffAnim();
		PrintDialogue("Go screw yourself!");
		SayTime = Say(MyPawn.myDialog.lDefiant);
	}
	else
		DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// The interest just bumped into us, so don't be too angry about it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GetAnnoyedWithInterest extends GetAngryWithInterest
{
Begin:
	// turn to idiot
	Focus = InterestActor;
	// get angry
	MyPawn.SetMood(MOOD_Angry, 1.0);

	PrintDialogue("watch it!");
	SayTime = Say(MyPawn.myDialog.lGetBumped);
	// wait while we yell
	Sleep(SayTime+Frand());
	MakeLessPatient(HARASS_PATIENCE_LOSS);
	DecideNextState();
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
	ignores BodyJuiceSquirtedOnMe, RespondToQuestionNegatively, TryToGreetPasserby, DonateSetup,
		CheckDeadBody, CheckDesiredThing, WatchFunnyThing, PerformInterestAction;
Begin:
	PrintStateError("USING DEFAULT!");

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// We know he's pouring gasoline on us
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ReactToGasoline
{
	ignores GettingDousedInGas, RespondToQuestionNegatively, TryToGreetPasserby, DonateSetup,
		CheckDeadBody, CheckDesiredThing, WatchFunnyThing, PerformInterestAction;
Begin:
	PrintStateError("USING DEFAULT!");
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
	ignores CheckDeadBody, CheckDeadHead, CheckDesiredThing, WatchFunnyThing, TryToGreetPasserby,
		SetupWatchParade;
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		// Make sure the dead thing is still valid when we get there.
		if(InterestActor == None
			|| InterestActor.bDeleteMe)
			GotoState('Thinking');

		GenSafeRangeMin();
	}
Begin:
	PrintStateError("USING DEFAULT!");
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You see something you want, like money or a donut
//
// Focus here holds the item we're interested, be sure not to clear it!
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InvestigateDesiredThing
{
	ignores CheckDeadBody, CheckDeadHead, CheckDesiredThing, WatchFunnyThing, SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	// Walk closer now to the thing you desire, my child
	///////////////////////////////////////////////////////////////////////////////
	function MoveCloser()
	{
		if(Focus != None
			&& !Focus.bDeleteMe)
		{
			bDontSetFocus=true;
			SetEndGoal(Focus, TIGHT_END_RADIUS);
			SetNextState(GetStateName(), 'CloseEnough');
			GotoStateSave('WalkToDesiredThing');
		}
		else	// if it's since vanished, complain
		{
			GotoState(GetStateName(), 'Complain');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Switch over to be able to pick this thing up and if it's still valid,
	// nab it.
	///////////////////////////////////////////////////////////////////////////////
	function TryToPickItUp()
	{
		local P2PowerupPickup ppick;
		local bool bWasTainted, bWasEdible;

		SayTime = 0;
		// Check if it's still there
		if(Pickup(Focus) != None
			&& !Focus.bDeleteMe)
		{
			ppick = P2PowerupPickup(Focus);

			// save things
			if(ppick != None)
			{
				if(ppick.Tainted==1)
					bWasTainted=true;
				if(ppick.bEdible)
					bWasEdible=true;
			}

			// Record each person tricked by donuts
			if(PPick.IsA('DonutPickup')
				&& MyPawn.IsA('Police')
				&& bWasTainted)
			{			
				if(P2GameInfoSingle(Level.Game) != None)
				{
					// Kamek 4-22 - give them an achievement for it
					if(Level.NetMode != NM_DedicatedServer ) P2GameInfoSingle(Level.Game).GetPlayer().GetEntryLevel().EvaluateAchievement(P2GameInfoSingle(Level.Game).GetPlayer(), 'HerePiggyPiggy');
				}
			}		

			// if it's food, you eat it (destroy it, we cheat for the moment) on the spot
			if(bWasEdible)
			{
				if(Focus != None)
					FocalPoint = Focus.Location;
				Focus.Destroy();
				Focus = None;
				GotoState(GetStateName(), 'YummyFood');
			}
			else
			{
				// Say you can grab it.
				MyPawn.bCanPickupInventory=true;
				// Force a touch to register the grab
				Focus.Touch(MyPawn);
				// Say you can't grab anything anymore
				MyPawn.bCanPickupInventory=false;
				GotoState(GetStateName(), 'NormalItem');
			}

			if(bWasTainted)
			{
				if(bWasEdible)
					GotoState(GetStateName(), 'TaintedFood');
				else
					GotoState(GetStateName(), 'TaintedStuff');
				return;
			}
		}
		else	// if it's since vanished, complain
		{
			GotoState(GetStateName(), 'Complain');
			return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function bool LookAtIt()
	{
		// Look down also
		MyPawn.PlayTurnHeadDownAnim(1.0, 1.0);
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function ExamineFirst()
	{
		// STUB
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make sure you're not crouched and you can't get powerups
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangeAnimation();
		if(MyPawn.Health > 0)
			MyPawn.ShouldCrouch(false);
		MyPawn.bCanPickupInventory=false;
		if(Focus != None)
			FocalPoint = Focus.Location;
	}

Begin:
	// sleep while you're starting to look at it
	Sleep(2.0 - 2*MyPawn.Reactivity);
	// stop and be curious a second
	MyPawn.StopAcc();
	PrintDialogue("Hmmmm....");
	LookAtIt();
	SayTime=Say(MyPawn.myDialog.lHmm);
	Sleep(2.0 - 2*MyPawn.Reactivity);

ReadyToMove:
	SwitchToHands();
	MoveCloser();

CloseEnough:
	MyPawn.StopAcc();
	PrintDialogue("Hmmmm....");
	SayTime=Say(MyPawn.myDialog.lHmm);

	// Some people can tell if the thing is tainted
	ExamineFirst();

	// Bend down to get it
	MyPawn.ShouldCrouch(true);
	if(LookAtIt())
		Sleep(0.5);

	// Check to pick it up now
	// Set my pawn to be allowed to pick it up
	TryToPickItUp();

NormalItem:
	// Stay bent down getting it for just a split second
	Sleep(0.3);
	MyPawn.ShouldCrouch(false);
	Sleep(0.3);
	SayTime = Say(MyPawn.myDialog.lThatsGreat);
	Sleep(SayTime + FRand()); // In case you said something about it being good

	// Leave state, you got the pickup
	GotoStateSave('Thinking');

YummyFood:
	// Stay bent down getting it for just a split second
	Sleep(0.3);
	MyPawn.ShouldCrouch(false);
	Sleep(0.3);
	SayTime = Say(MyPawn.myDialog.lAfterEating);
	Sleep(SayTime + FRand()); // In case you said something about it being good

	// Leave state, you got the pickup
	GotoStateSave('Thinking');

Complain:
	// stand up and be mad that it's gone
	MyPawn.SetMood(MOOD_Angry, 1.0);
	MyPawn.StopAcc();
	MyPawn.ShouldCrouch(false);
	PrintDialogue("What the..");
	SayTime = Say(MyPawn.myDialog.lWhatThe);
	MyPawn.PlayTalkingGesture(1.0);
	Sleep(SayTime + FRand());

	// Leave state, you got screwed
	GotoStateSave('Thinking');

TaintedFood:
	// Try to stand up, but puke instead because you ate gross food
	MyPawn.StopAcc();
	Sleep(FRand());
	MyPawn.ShouldCrouch(false);

	// learn to not like donuts as much
	MyPawn.DonutLove-=DONUTS_ARE_BAD;

	// Do throw up from eating the gross donut
	// Force puking here
	CheckToPuke(,true);

	// didn't throw up, but still mad
	PrintDialogue("Gross!");
	SayTime = Say(MyPawn.myDialog.lSomethingIsGross, true);
	Sleep(SayTime);
	// Leave state, you got screwed
	GotoStateSave('Thinking');

TaintedStuff:
	// Stand up and be mad
	// and grossed out because it's been pissed on or something
	MyPawn.SetMood(MOOD_Angry, 1.0);
	MyPawn.StopAcc();
	MyPawn.ShouldCrouch(false);
	PrintDialogue("Gross!");
	SayTime = Say(MyPawn.myDialog.lSomethingIsGross, true);
	Sleep(SayTime);
	Sleep(SayTime/2 + FRand());

	MyPawn.PlayTalkingGesture(1.0);
	Sleep(1.0);	//pause as throwing
	// Throw out the nasty, probably pissed on inventory item
	//log(MyPawn$" toss this out "$Pawn.SelectedItem);
	MyPawn.TossThisInventory(GenTossVel(MyPawn), MyPawn.SelectedItem);
	Sleep(1.0);	//pause as throwing

	// Leave state, you got screwed
	GotoStateSave('Thinking');
KickTainted:
	// stand up and be mad that it's gone
	MyPawn.SetMood(MOOD_Angry, 1.0);
	MyPawn.StopAcc();
	MyPawn.ShouldCrouch(false);
	MyPawn.PlayTurnHeadDownAnim(1.0, 1.0);
	PrintDialogue("What the..");
	SayTime = Say(MyPawn.myDialog.lWhatThe);
	Sleep(SayTime/2);
	SetNextState('Thinking');
	GotoStateSave('JustKick');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You want the money so much you'll run to it
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InvestigateDesiredThingRun extends InvestigateDesiredThing
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function bool LookAtIt()
	{
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Run closer now to the thing you desire, my greedy child
	///////////////////////////////////////////////////////////////////////////////
	function MoveCloser()
	{
		if(Focus != None
			&& !Focus.bDeleteMe)
		{
			bDontSetFocus=true;
			SetEndGoal(Focus, TIGHT_END_RADIUS);
			SetNextState(GetStateName(), 'CloseEnough');
			ScreamState=SCREAM_STATE_NONE; // clear scream state before we run to the money
			GotoStateSave('RunToTarget');
		}
		else	// if it's since vanished, complain
		{
			GotoState(GetStateName(), 'Complain');
		}
	}

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CheckToDonate
// See if you want to donate money
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CheckToDonate
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, TryToGreetPasserby,
		RespondToTalker, QPointSaysMoveUpInLine, DonateSetup, InterestIsAnnoyingUs, GetHitByDeadThing,
		RespondToQuestionNegatively, CheckObservePawnLooks, CheckDesiredThing, CheckDeadBody, CheckDeadHead,
		WatchFunnyThing, PerformInterestAction, DoWaitOnOtherGuy, SetupSideStep, SetupBackStep, SetupMoveForRunner, 
		AllowOldState, TryToSendAway, SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	// Make sure whoever is asking you this is really talking to you
	// And make sure they still have the clipboard out
	///////////////////////////////////////////////////////////////////////////////
	function CheckTalkerAttention(optional out byte StateChange)
	{
		local bool bStopListening;
		local P2Player p2p;

		if(Pawn(Focus) == None)
			bStopListening=true;
		else
		{
			// Check if he's close enough
			if(VSize(Focus.Location - MyPawn.Location) > LISTEN_TO_DUDE_RADIUS)
				bStopListening=true;
			else if(!CanSeePawn(Pawn(Focus), MyPawn))
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
				if(bLostInterest
					&& DonatedBotherCount > 0)
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
		if(MyOldState != 'OnePassMove')
			GotoState(MyOldState);
		else
			GotoState('Thinking');
	}

	///////////////////////////////////////////////////////////////////////////////
	// make sure to unhook
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(DonatedBotherCount != -2)
			UnhookFocus();
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
	if(FPSPawn(Focus) != None
		&& P2Player(FPSPawn(Focus).Controller) != None)
		Sleep(P2Player(FPSPawn(Focus).Controller).SayTime + 0.3);
	else
		Sleep(1.0);

	// Check to see if I hate you first
	if(FPSPawn(Focus) != None)
		ActOnPawnLooks(FPSPawn(Focus));

	CheckTalkerAttention();

	// reduce the time to wait
	CurrentFloat = CurrentFloat - ((2.0 - UseReactivity) + MyPawn.Rebel);
	
	// If it's the Champ photo, run in terror
	// FIXME: have them say something else on the 9th attempt
	if (Pawn(Focus).Weapon.IsA('PhotoWeapon'))
	{
		// tell the dude (but not if we've already reacted to the photo)
		if (PhotoBothered == 0)
		{
			// If this is the last person the Dude needs, activate the "wise wang" errand
			if (Pawn(Focus).Weapon.AmmoType.AmmoAmount >= Pawn(Focus).Weapon.AmmoType.MaxAmmo - 1)
			{
				DonatedBotherCount=-2;
				// Make him scared
				MyPawn.SetMood(MOOD_Scared, 1.0);
				// Wait a tiny bit
				Sleep(CurrentFloat);
				// Then activate the errand
				GotoState('DealWithPhoto');				
			}			
			else
			{
				PhotoBothered = 1;
				if (P2Player(Pawn(Focus).Controller) != None)
					P2Player(Pawn(Focus).Controller).GrabMoneyPutInCan(1);
			}
		}
		// Just set this as a dangerous location and scream and/or run the fuck away
		MyPawn.SetMood(MOOD_Scared, 1.0);
		SayTime = Say(MyPawn.myDialog.lChampPhotoReaction, true);
		Sleep(SayTime);
		DangerPos = InterestPawn.Location;
		GotoStateSave('FleeFromDanger');
		/*
		if (FRand() <= SCREAMING_STILL_FREQ)
			GotoStateSave('ScreamingStill');
		else
			GotoStateSave('FleeFromDanger');
		*/
	}
	else
	{
		// Already signed, stop bothering me!
		if(DonatedBotherCount < 0)
			Goto('BuzzOff');

		// Hasn't signed, so change him
		DonatedBotherCount++;

		// Final bother is violent, so handle it differently
		if(DonatedBotherCount >= MAX_DONATE_BOTHER)
		{
			// You've officially been bothered beyond the point of caring
			DonatedBotherCount=-1;
			if(MyPawn.bHasViolentWeapon)
			{
				// If you're a friend with a weapon always sign at the end
				if(MyPawn.bPlayerIsFriend)
					Goto('SetupDonation');
				// Cops won't sign it
				else if(!MyPawn.bAuthorityFigure)
					Goto('SetupDonation');
				else
					HandleMeanTalker(FPSPawn(Focus));
			}
			else // No gun to defend themselves after you threaten them
			{
				// Sometimes they sign anyway
				if(Rand(MAX_DONATE_BOTHER) == MAX_DONATE_BOTHER)
					Goto('SetupDonation');
				// Sometimes they yell at you again
				else if(FRand() <= MyPawn.Rebel)
					Goto('SetupScrewYou');
				else	// Sometimes they run and scream
				{
					InterestPawn = FPSPawn(Focus);
					SetAttacker(InterestPawn);
					DangerPos = InterestPawn.Location;
					GotoStateSave('FleeFromAttacker');
				}
			}
		}
		else
		{
			// If you're a friend, sign it automatically
			if (MyPawn.bPlayerIsFriend)
				Goto('SetupDonation');
			// If you're a rebel decide not to help
			// Or if you're already mad
			if((FRand() <= MyPawn.Rebel
					|| (MyPawn.Mood == MOOD_Combat))
				&& !MyPawn.bPlayerIsFriend)
			{
	SetupScrewYou:
				// Wait a little while till you get tired, then continue on
				MyPawn.SetMood(MOOD_Angry, 1.0);
				Sleep(CurrentFloat*FRand());
				Goto('ScrewYou');
			}

			else if(DonatedBotherCount >= 0								// Haven't already donated
					&& Rand(MAX_DONATE_BOTHER)+1 > DonatedBotherCount)	// ready to be bothered again
				// The more you're bothered, the more likey you are to sign
			{
	SetupSorry:
				// Wait a little while till you get tired, then continue on
				Sleep(CurrentFloat*FRand());
				Goto('Sorry');
			}
			else // you will give this person money
			{
	SetupDonation:
				Sleep(CurrentFloat);
				// you're about to officially donate, so set it to so
				DonatedBotherCount=-2;
				GotoState('DealWithDonation');
			}
		}

	Sorry:
		// Kamek 5-1
		// Record that we didn't sign it -- this can turn to false later if the dude is persistent
		bRefusedToDonate = true;
		//log("RefusedToDonate"@bRefusedToDonate,'Debug');
		
		// Apologize and ignore them
		MyPawn.SetMood(MOOD_Normal, 1.0);
		MyPawn.PlayTalkingGesture(1.0);
		PrintDialogue("I'm sorry");
		SayTime = Say(MyPawn.myDialog.lApologize, true);
		Sleep(SayTime);
		UnhookFocus(true);
		DecideNextState();

	ScrewYou:
		// Kamek 5-1
		// Record that we didn't sign it -- this can turn to false later if the dude is persistent
		bRefusedToDonate = true;
		//log("RefusedToDonate"@bRefusedToDonate,'Debug');

		// Flip them off
		MyPawn.SetMood(MOOD_Angry, 1.0);
		MyPawn.PlayTellOffAnim();
		PrintDialogue("no way! you're crazy");
		//SayTime = Say(MyPawn.myDialog.lDefiant);
		SayTime = Say(MyPawn.myDialog.lDontSignPetition, true);
		Sleep(SayTime);
		// Kamek 5-1: Give them an achievement for begging a cop
		if (MyPawn.IsA('Police'))
		{
			if(Level.NetMode != NM_DedicatedServer ) PlayerController(Pawn(Focus).Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Pawn(Focus).Controller),'NoWayPinko');	
		}
		UnhookFocus(true);
		DecideNextState();

	BuzzOff:
		// Flip them off
		MyPawn.SetMood(MOOD_Angry, 1.0);
		MyPawn.PlayTellOffAnim();
		PrintDialogue("buzz off!");
		SayTime = Say(MyPawn.myDialog.lPetitionBother, true);
		Sleep(SayTime);
		UnhookFocus(true);
		DecideNextState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DealWithPhoto
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DealWithPhoto extends CheckToDonate
{
	///////////////////////////////////////////////////////////////////////////////
	// give them the money
	///////////////////////////////////////////////////////////////////////////////
	function GiveFocusSomeMoney()
	{
		local P2Player p2p;
		local Pawn checkp;
		local float MoneyToGive;
		
		//log(self@"give"@focus@"some money",'Debug');

		checkp = Pawn(Focus);
		if(checkp != None)
		{
			PhotoBothered = 1;
			if (P2Player(checkp.Controller) != None)
				P2Player(checkp.Controller).GrabMoneyPutInCan(1);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		UnhookFocus();
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop running before you do this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		DonatedBotherCount=0;
		// Record that we DID sign it -- if we refused earlier reset the flag, so
		// the dude doesn't get an achievement for killing us later.
		bRefusedtoDonate = false;
	}
Begin:
	// Tell them you'd like to donate
	MyPawn.PlayTalkingGesture(1.0);
	PrintDialogue("You should seek the Wise Man");
	SayTime = Say(MyPawn.myDialog.lPhoto_FindWiseWang, true);
	Sleep(SayTime);

	GiveFocusSomeMoney();

	Sleep(1.0);

	// NOW run in fear
	DangerPos = InterestPawn.Location;
	GotoStateSave('FleeFromDanger');	
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DealWithDonation
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DealWithDonation extends CheckToDonate
{
	///////////////////////////////////////////////////////////////////////////////
	// give them the money
	///////////////////////////////////////////////////////////////////////////////
	function GiveFocusSomeMoney()
	{
		local P2Player p2p;
		local Pawn checkp;
		local float MoneyToGive;
		
		//log(self@"give"@focus@"some money",'Debug');

		checkp = Pawn(Focus);
		if(checkp != None)
		{
			p2p = P2Player(checkp.Controller);

			if(p2p != None)
			{
				//MoneyToGive = ((1.0 - MyPawn.Greed)*COLLECTION_MONEY_MAX);
				// Not actually giving money anymore.. just collecting signatures.
				if(MoneyToGive <= 0)
					MoneyToGive=1;

				// Make it look like they're doing something.
				MyPawn.PlayTalkingGesture(1.0);
				
				// Make sure they have us as an interest
				p2p.InterestPawn = MyPawn;

				// make dude reach out and take money
				p2p.GrabMoneyPutInCan(MoneyToGive);

				// you've officially given, so set it so you won't any more
				DonatedBotherCount=-1;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		UnhookFocus();
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop running before you do this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		DonatedBotherCount=0;
		// Record that we DID sign it -- if we refused earlier reset the flag, so
		// the dude doesn't get an achievement for killing us later.
		bRefusedtoDonate = false;
	}
Begin:
	//Sleep(1.0 - UseReactivity); // Rikki - Decreasing wait before donation, still retaining pawn's natural reaction time 
	// Be okay again
	MyPawn.SetMood(MOOD_Normal, 1.0);
	//Sleep(FRand());
	Sleep(1.0 - UseReactivity);

	CheckTalkerAttention();

	// Tell them you'd like to donate
	MyPawn.PlayTalkingGesture(1.0);
	PrintDialogue("Sounds good");
	SayTime = Say(MyPawn.myDialog.lSignPetition, true);
	Sleep(SayTime/2);

	// check to sign petition
	CheckTalkerAttention();

	GiveFocusSomeMoney();

	Sleep(3.0);

	DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RespondNegative say something in the negative to a question someone asked
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RespondNegative
{
Begin:
	MyPawn.StopAcc();
	SayTime = Say(MyPawn.myDialog.lNo);
	PrintDialogue("Sorry, I don't think so.");
	Sleep(SayTime);
	GotoNextState(true);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Respond that you have no idea what's going on
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RespondWhatsWrong
{
	ignores AllowOldState;
Begin:
	// wait a second to turn around to the focus
	Sleep((1.0 - MyPawn.Reactivity)/2);

	PrintDialogue("What's seems to be the problem, officer?");
	Say(MyPawn.myDialog.lAskCopWhatsUp);
	Sleep(SayTime+1.0);

	GotoState(MyOldState);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PrepDeathCrawl
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepDeathCrawl
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, 
		HearAboutKiller, HearAboutDangerHere, HandleFireInWay, DodgeThinWall, GetOutOfMyWay,
		RespondToTalker, ForceGetDown, RatOutAttacker, MarkerIsHere, CheckToPuke,
		RespondToQuestionNegatively, CheckObservePawnLooks, PrepToWaitOnDoor, CheckForIntruder,
		RespondToCopBother, DecideToListen, DoDeathCrawlAway, PerformInterestAction,
		DonateSetup, SetupSideStep, SetupBackStep, MoveAwayFromDoor, CheckForNormalDoorUse, SetupMoveForRunner, 
		CanStartConversation, CanBeMugged, FreeToSeekPlayer, HandlePlayerSightReaction, DangerPawnBump, 
		WingedByRifle, CanHelpOthers, DoWaitOnOtherGuy, TryToSendAway, Trigger, RocketIsAfterMe, DoGetKnockedOut, TookNutShot, BlindedByFlashBang;

	///////////////////////////////////////////////////////////////////////////
	// Shot when begging, but not dead, so cry more
	// Or run or something
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		local bool bDoCry;

		if ( (Other == None) || (Damage <= 0))
			return;
		//local vector dir;
		if(Other == Pawn)
		{
			if(ScreamState == SCREAM_STATE_NONE)
				bDoCry=true;
		}
		else
			bDoCry=true;

		if(bDoCry)
		{
			PrintDialogue("Waaaahhaa... boohoo");
			SayTime = Say(MyPawn.myDialog.lCrying);
			// Instead of using the timer for the TryToScream/TimeToScream system,
			// just use this to know when we can scream again from our own pain
			// Otherwise, scream everytime the dude/someone hurts us now
			SetTimer(SayTime+Frand(), false);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop at the animation end, and go about as before
	// Try to death crawl before you leave this state. Wait 
	// idling in a deathcrawl anim if you can't truly deathcrawl yet. This is
	// because the collision radius gets greatly expanded for a deathcrawler.
	///////////////////////////////////////////////////////////////////////////////
	function EndFalling()
	{
		local vector dir, checkpoint;

		MyPawn.ShouldDeathCrawl(true);
		// See if you're death crawling yet.. if not, then wait
		if(MyPawn.bIsDeathCrawling)
		{
			if(MyPawn.MyBodyChem != None)
			{
				dir = vector(MyPawn.Rotation);

				checkpoint = MyPawn.Location + 8192*dir;
				// Don't adjust for walls, just keep crawling when you hit one
				SetEndPoint(checkpoint, DEFAULT_END_RADIUS);

				// Face where we're going
				Focus = None;
				FocalPoint = checkpoint;

				if(IsInState('LegMotionToTarget'))
					bPreserveMotionValues=true;
				SetNextState('CowerInABall');
				GotoStateSave('DeathCrawlChem');
			}
			else
				GotoStateSave('DeathCrawlFromAttacker');
		}
		else
			GotoState('PrepDeathCrawl','WaitAfterFall');
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
			EndFalling();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		MyPawn.SetMood(MOOD_Scared, 1.0);
		// Stare where we were last pointing
		Focus = None;
		FocalPoint = MyPawn.Location + 1024*vector(MyPawn.Rotation);
		
		// If we're deathcrawling because limbs are gone, keep deathcrawling forever
		if (MyPawn.bMissingLimbs)
			SetNextState('DeathCrawlFromAttacker');
	}

WaitAfterFall:
	MyPawn.SetAnimDeathCrawlWait();
	Sleep(3.0);
	Goto('WaitAfterFall');
Begin:	
	// If they are crouched then stand up and fall
	if(MyPawn.bIsCrouched)
	{
		MyPawn.ShouldCrouch(false);
		Sleep(0.3);
	}

	MyPawn.PlayAnim(MyPawn.GetAnimDeathFallForward(), 3.0, 0.3);

	Sleep(5.0);

	EndFalling();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PrepKnockOut
// Knockouts are similar to deathcrawls. Pretty much the only difference
// is the visual. Reuses DeathCrawl code
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepKnockOut
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, 
		HearAboutKiller, HearAboutDangerHere, HandleFireInWay, DodgeThinWall, GetOutOfMyWay,
		RespondToTalker, ForceGetDown, RatOutAttacker, MarkerIsHere, CheckToPuke,
		RespondToQuestionNegatively, CheckObservePawnLooks, PrepToWaitOnDoor, CheckForIntruder,
		RespondToCopBother, DecideToListen, DoDeathCrawlAway, PerformInterestAction,
		DonateSetup, SetupSideStep, SetupBackStep, MoveAwayFromDoor, CheckForNormalDoorUse, SetupMoveForRunner, 
		CanStartConversation, CanBeMugged, FreeToSeekPlayer, HandlePlayerSightReaction, DangerPawnBump, 
		WingedByRifle, CanHelpOthers, DoWaitOnOtherGuy, TryToSendAway, Trigger, RocketIsAfterMe, DoGetKnockedOut, TookNutShot, BlindedByFlashBang;

	///////////////////////////////////////////////////////////////////////////
	// Shot when begging, but not dead, so cry more
	// Or run or something
	// FIXME FIXME FIXME
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop at the animation end, and go about as before
	// Try to death crawl before you leave this state. Wait 
	// idling in a deathcrawl anim if you can't truly deathcrawl yet. This is
	// because the collision radius gets greatly expanded for a deathcrawler.
	///////////////////////////////////////////////////////////////////////////////
	function EndFalling()
	{
		local vector dir, checkpoint;

		//log(self@"endfalling");
		MyPawn.SetAnimKnockedOut();
		MyPawn.bIsKnockedOut=True;
		// Reduce the collision height
		MyPawn.ShouldDeathCrawl(true);
		GotoStateSave('KnockedOutState');
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		//log(self@"animend channel"@channel);
		MyPawn.AnimEnd(channel);
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
		//log(self@"Knockout Beginstate");
		PrintThisState();
		MyPawn.StopAcc();
		MyPawn.SetMood(MOOD_Scared, 1.0);
		// Stare where we were last pointing
		Focus = None;
		FocalPoint = MyPawn.Location + 1024*vector(MyPawn.Rotation);
	}

//WaitAfterFall:
	//MyPawn.SetAnimStartKnockOut();
	//Sleep(3.0);
	//Goto('WaitAfterFall');
Begin:
	//log(self@"Begin:");
	//MyPawn.SetAnimKnockedOut();
	MyPawn.ShouldCrouch(false);
	MyPawn.ShouldCower(false);

	MyPawn.PlayAnim(MyPawn.GetAnimStartKnockOut(), 1.5, 0.15);

	//Sleep(5.0);

	//EndFalling();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitOnOtherGuy
//
// We're extending Leg motion so we get the good 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitOnOtherGuy extends LegMotionToTarget
{
	ignores AllowOldState, DoWaitOnOtherGuy, TryToSendAway, ForceGetDown,
		SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	// Get out of the way of the door
	///////////////////////////////////////////////////////////////////////////////
	function MoveAwayFromDoor(DoorMover TheDoor)
	{
		MoveAwayFromDoorBase(TheDoor);
	}

	function DecideNextState()
	{
		GotoState(MyOldState);
	}
	function EndState()
	{
		// STUB this out so we don't do crazy stuff
	}
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
	}
Begin:
	Sleep(FRand() + 1.0);

	DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitOnOtherRunner
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitOnOtherRunner extends WaitOnOtherGuy
{
Begin:
	Sleep((FRand()/2) + 0.25);

	DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitAroundDoor
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitAroundDoor
{
	ignores AllowOldState, SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	// Get out of the way of the door
	///////////////////////////////////////////////////////////////////////////////
	function MoveAwayFromDoor(DoorMover TheDoor)
	{
		MoveAwayFromDoorBase(TheDoor);
	}

	///////////////////////////////////////////////////////////////////////////////
	// The door doesn't want you
	///////////////////////////////////////////////////////////////////////////////
	function TryToSendAway()
	{
		GotoStateSave('HeadBack');
	}

	///////////////////////////////////////////////////////////////////////////////
	// You're ready to wait around the door (in case you're not setup already)
	///////////////////////////////////////////////////////////////////////////////
	function bool PrepToWaitOnDoor(DoorBufferPoint thisdoor)
	{
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// See if you care about using a door
	///////////////////////////////////////////////////////////////////////////////
	function CheckToUseDoor(out byte StateChange)
	{
		//log(MyPawn$" going back to thinking after being sent");
		CheckDoor = None;
		StateChange = 1;
		GotoState('Thinking');
	}

	function BeginState()
	{
		PrintThisState();
		if(CheckDoor == None)
			GotoState('Thinking');
		else	// Make sure I'm in the list
			CheckDoor.Touch(MyPawn);
	}

	function EndState()
	{
		// If CheckDoor is not none, then we're leaving our state earlier than we should
		// have, so at this point, while we'll still maintain a link to the door
		// it's connection isn't valid and if we come back to this state, we'll need to
		// try to readd ourselves to the door.
		if(CheckDoor != None)
			CheckDoor.RemoveMe(MyPawn);
	}

Begin:
	Sleep(0.3);
	MyPawn.StopAcc();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// OnePassMove
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state OnePassMove
{
	ignores SetupSideStep, SetupBackStep, SetupMoveForRunner, AllowOldState, DoWaitOnOtherGuy, PrepToWaitOnDoor,
		TryToSendAway, CheckDesiredThing, CheckObservePawnLooks, ForceGetDown, WaitForMover, 
		MoverFinished, StartConversation, SetupWatchParade;

	///////////////////////////////////////////////////////////////////////////////
	// Go to next state
	///////////////////////////////////////////////////////////////////////////////
	function DoLeaveState()
	{
		SetRotation(Pawn.Rotation);
		if(MyOldState == 'RunToTargetIgnoreAll')
		{
			GotoState('ShootAtAttacker');
		}
		else
		{
			GotoState(MyOldState);
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////
	// *Only* check for guys in your house
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local byte StateChange;

		if(FPSPawn(Other) != None)
			CheckForIntruder(FPSPawn(Other), StateChange);

		if(StateChange != 1)
			DangerPawnBump(Other, StateChange);
		else if(StaticMeshActor(Other) != None)
			BumpStaticMesh(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// StepForward
// To get out of the way of a runner
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StepForward extends OnePassMove
{
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// StepBack
// To get out of the way of a runner
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StepBack extends OnePassMove
{
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// HeadBack
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HeadBack extends OnePassMove
{
	///////////////////////////////////////////////////////////////////////////////
	// Go to next state
	///////////////////////////////////////////////////////////////////////////////
	function DoLeaveState()
	{
		GotoState('Thinking');
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		MoveTarget = OldEndGoal;//OldMoveTarget;
		MovePoint = OldEndPoint;
		Focus = MoveTarget;
		FocalPoint = MovePoint;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LegMotionToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LegMotionToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// The door doesn't want you
	///////////////////////////////////////////////////////////////////////////////
	function TryToSendAway()
	{
		bPreserveMotionValues=true;
		GotoStateSave('HeadBack');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if we're able to start conversations, most of the times, no
	///////////////////////////////////////////////////////////////////////////////
	function CanStartConversation( P2Pawn Other, optional out byte StateChange )
	{
		StateChange = 1;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if we're allowed to be mugged right now
	///////////////////////////////////////////////////////////////////////////////
	function CanBeMugged( P2Pawn Other, optional out byte StateChange )
	{
		StateChange=1;
	}

	///////////////////////////////////////////////////////////////////////////////
	// See if you really want to wait on a door, to go through it
	///////////////////////////////////////////////////////////////////////////////
	function bool PrepToWaitOnDoor(DoorBufferPoint thisdoor)
	{
		bPreserveMotionValues=true;
		CheckDoor = thisdoor;
		GotoStateSave('WaitAroundDoor');
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make me do the waiting
	///////////////////////////////////////////////////////////////////////////////
	function DoWaitOnOtherGuy(name WaitState, float lookcross)
	{
		bPreserveMotionValues=true;

		if(lookcross!=0)
		{
			if(lookcross < 0)
				MyPawn.PlayEyesLookLeftAnim(1.0, 0.5);
			else
				MyPawn.PlayEyesLookRightAnim(1.0, 0.5);
		}

		GotoStateSave(WaitState);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Calc and switch states to sidestep
	///////////////////////////////////////////////////////////////////////////////
	function SetupSideStep(float goright)
	{
		local vector destpoint, checkrot;

		checkrot = vector(MyPawn.Rotation);
		// Handle this pawn
		destpoint = MyPawn.Location;//-FRand()*SIDE_STEP_BASE_DIST
		destpoint.x += goright*(SIDE_STEP_DIST)*checkrot.y;
		destpoint.y -= goright*(SIDE_STEP_DIST)*checkrot.x;
		// Also, aim the collision point down somewhat, so that it's more
		// likely to hit little things in the way, and is more likely to
		// stop an ugly collision. Only do this for the tightest end point
		// area, so that if this thing ends early, he'll still no he hit a valid
		// end point (if the destination point is too high off the ground, he'll
		// never think he's reached it, and keep running towards it)
		destpoint.z -= TIGHT_END_RADIUS;

		// check for walls
		AdjustPointForWalls(destpoint, MyPawn.Location);

		if(VSize(destpoint - MyPawn.Location) <= 2*MyPawn.CollisionRadius)
		{
			//log(MyPawn$" go opposite instead");
			goright = -goright;
			destpoint = MyPawn.Location;//-FRand()*SIDE_STEP_BASE_DIST
			destpoint.x += goright*(SIDE_STEP_DIST)*checkrot.y;
			destpoint.y -= goright*(SIDE_STEP_DIST)*checkrot.x;
			AdjustPointForWalls(destpoint, MyPawn.Location);
		}

		//log("go right "$goright$" dest "$destpoint);

		MovePoint = destpoint;
		MoveTarget = None;
		FocalPoint = destpoint;
		Focus = None;

		bPreserveMotionValues=true;
		//if(AllowOldState())
			GotoStateSave('OnePassMove');
		//else
		//	GotoState('OnePassMove');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Get out of the way of the door
	///////////////////////////////////////////////////////////////////////////////
	function MoveAwayFromDoor(DoorMover TheDoor)
	{
		MoveAwayFromDoorBase(TheDoor);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Calc and switch states to backstep
	///////////////////////////////////////////////////////////////////////////////
	function SetupBackStep(float BaseDist, float RandDist)
	{
		local vector destpoint, checkrot;

		checkrot = vector(MyPawn.Rotation);
		// Handle this pawn
		destpoint = MyPawn.Location;
		destpoint.x -= (BaseDist+FRand()*RandDist)*checkrot.x;
		destpoint.y -= (BaseDist+FRand()*RandDist)*checkrot.y;

		// check for walls
		//GetMovePointOrHugWalls(destpoint, MyPawn.Location, FRand()*128 + 128, true);
		AdjustPointForWalls(destpoint, MyPawn.Location);

		MovePoint = destpoint;
		MoveTarget = None;
		// Don't walk backwards, that looks too goofy, turn and walk to your target
		FocalPoint = destpoint;
		Focus = None;

		bPreserveMotionValues=true;
		//if(AllowOldState())
			GotoStateSave('OnePassMove');
		//else
		//	GotoState('OnePassMove');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Handle bumps with other characters
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local float infrontdot, facingdot, goright;
		local vector pawndiff, destdiff, checkrot, OtherRot, HitLocation, HitNormal, usecross;
		local Actor HitActor;
		local FPSPawn otherpawn;
		local PersonController personc;
		local byte StateChange;

		otherpawn = FPSPawn(Other);

		if(otherpawn != None)
		{
			//log(MyPawn$" at "$MyPawn.Location$" bumping "$otherpawn$" at "$otherpawn.Location$" dist "$VSize(MyPawn.Location - otherpawn.Location));
			// Check first if the person is in your house and shouldn't be
			CheckForIntruder(otherpawn, StateChange);
			if(StateChange == 1)
				return;

			// If not, see about getting around them
			if(!otherpawn.IsInState('WalkInQ')
				&& !otherpawn.IsInState('OnePassMove'))
			{
				// check if I'm behind Other
				pawndiff = Other.Location - MyPawn.Location;
				pawndiff.z = 0;
				pawndiff = Normal(pawndiff);
				checkrot = vector(MyPawn.Rotation);
				OtherRot = vector(Other.Rotation);

				infrontdot = Normal(checkrot) dot pawndiff;

				//log(MyPawn$" to dest dot "$infrontdot);
				// Check if someone is in front of me
				if(infrontdot >= IN_MY_WAY_DOT)
				{
					facingdot = checkrot dot OtherRot;
					// Check if they are facing me
					// or dead
					if(facingdot < 0
						|| otherpawn.NoLegMotion()
						|| otherpawn.Health <= 0)
					{
						// If they're alive and I want to talk, then try to talk
						if(MyPawn.Talkative > Frand()
							&& P2Pawn(otherpawn) != None)
						{
							StartConversation(P2Pawn(otherpawn), StateChange);
							if(StateChange == 1)
								return;
						}

						// Since they are determine a point to for each of us to sidestep to
						// Pick right, if we are closer to getting around them on the right side,
						// left otherwise.
						if(MoveTarget != None)
							destdiff = MoveTarget.Location;
						else
							destdiff = MovePoint;
						destdiff = destdiff - MyPawn.Location;
						destdiff.z = 0;

						//log(MyPawn$" dest dot "$Normal(destdiff) dot pawndiff);

						usecross = pawndiff cross destdiff;
						//log(MyPawn$" pawndiff "$pawndiff$" dest diff "$Normal(destdiff));
						//log(MyPawn$" cross pick "$usecross);
						if(usecross.z < 0)
							goright=1;	// go to your right
						else
							goright=-1;	// go to your left

						// Not very often, randomly pick the other direction to go to
						if(FRand() < 0.1)
							goright = -goright;

						personc = PersonController(otherpawn.Controller);

						if(personc == None)
						{
							DangerPawnBump(Other, StateChange);

							if(StateChange != 1)
								SetupSideStep(goright);
						}
						else
						{
							// If he's not already waiting, then we'll wait and he'll walk
							if(IsInState('WaitOnOtherGuy'))
							{
								// set me up to wait
								DoWaitOnOtherGuy('WaitOnOtherGuy', usecross.z);
							
								// If the other is not a player, then handle him too, and in his side step state
								// he'll ignore his bump (hopefully)
								// Set him up to walk
								personc.SetupSideStep(-goright);
							}
							else
							{
								// he waits
								personc.DoWaitOnOtherGuy('WaitOnOtherGuy', usecross.z);
								// and i sidestep
								SetupSideStep(goright);
							}
						}
					}
					else
					{
						// wait on this guy, he's in front, so don't go crazily bumping into him
						bPreserveMotionValues=true;
						if(FRand() > 0.3)
							DoWaitOnOtherGuy('WaitOnOtherGuy', usecross.z);
						else
							SetupBackStep(SIDE_STEP_DIST, SIDE_STEP_DIST);
					}
					// turn my head to the person we're avoiding
					if(usecross.z < 0)
						MyPawn.PlayTurnHeadRightAnim(2.0, 1.0);
					else
						MyPawn.PlayTurnHeadLeftAnim(2.0, 1.0);
				}
				else	// if you bump them from behind, they'll know
				{
					DangerPawnBump(Other);
				}
			}
		}
		else if(StaticMeshActor(Other) != None)
			BumpStaticMesh(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Look straight afterwards
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		// Look straight ahead again
		MyPawn.PlayTurnHeadStraightAnim(0.2);
	}
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
	ignores PerformInterestAction, RespondToQuestionNegatively, TryToGreetPasserby,
			DonateSetup, CheckDesiredThing, CheckDeadBody, CheckDeadHead, CheckForIntruder, 
			WatchFunnyThing, WaitForMover, MoverFinished, CanStartConversation, 
			CanBeMugged, HandlePlayerSightReaction, SetupWatchParade, RocketIsAfterMe;

	///////////////////////////////////////////////////////////////////////////////
	// Might not be the end goal, but the actor hit what he was going for.
	// Only calculate our run distance here. Sure, something else might force us
	// out here before we get the exact distance added up (we're in between goals
	// and have run more than the DistanceRun says) but we're only trying to get
	// vaguely close anyways.
	///////////////////////////////////////////////////////////////////////////////
	event HitPathGoal(Actor Goal, vector Dest)
	{
		local float dist;
		// For each goal we reach, add up the distance since we last check
		dist = VSize(MyPawn.Location - RunStartPoint);
		// Save where we started running.
		RunStartPoint = MyPawn.Location;
		DistanceRun+=dist;

		Super.HitPathGoal(Goal, Dest);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Calc and switch states to sideback
	///////////////////////////////////////////////////////////////////////////////
	function SetupBackStep(float BaseDist, float RandDist)
	{
		local vector destpoint, checkrot;

		// Run back to a point behind me
		checkrot = vector(MyPawn.Rotation);
		destpoint = MyPawn.Location;
		destpoint.x -= (BaseDist+(FRand()*RandDist))*checkrot.x;
		destpoint.y -= (BaseDist+(FRand()*RandDist))*checkrot.y;

		// check for walls
		AdjustPointForWalls(destpoint, MyPawn.Location);

		MovePoint = destpoint;
		MoveTarget = None;
		FocalPoint = destpoint;
		Focus = None;

		bPreserveMotionValues=true;
		//if(AllowOldState())
			GotoStateSave('StepBack');
		//else
		//	GotoState('StepBack');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Handle bumps with other characters
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local P2Pawn otherpawn;
		local PersonController personc;
		local float infrontdot, facingdot;
		local vector pawndiff, destdiff, checkrot, usecross;

		otherpawn = P2Pawn(Other);

		if(otherpawn != None)
		{
			personc = PersonController(otherpawn.Controller);
			if(otherpawn.Health > 0
				&& personc != None)
			{
				pawndiff = Other.Location - MyPawn.Location;
				pawndiff.z = 0;
				pawndiff = Normal(pawndiff);
				checkrot = vector(MyPawn.Rotation);

				infrontdot = Normal(checkrot) dot pawndiff;

				// Other pawn is already moving for someone else, or the
				// other pawn is just standing there, so stepback and
				// move him forward
				if(personc.IsInState('OnePassMove')
					|| (personc.IsInState('LegMotionToTarget')
						&& VSize(otherpawn.Velocity) < MIN_VELOCITY_FOR_REAL_MOVEMENT))
				{
					// Check if someone is in front of me
					if(infrontdot >= 0)
						SetupBackStep(BACK_RUN_DEST_BASE, BACK_RUN_DEST_ADD);
					personc.SetupMoveForRunner(MyPawn);
				}
				else
				{
					// Make the other person move for you. Make them run back
					// if they're facing you and run forwards if you're behind them.
					if(personc.Attacker != None
						|| personc.Attacker == MyPawn
						|| (Normal(vector(Other.Rotation)) dot (-pawndiff)) < 0)
					{
						personc.SetupMoveForRunner(MyPawn);
					}
					else
					{
						personc.SetupBackStep(BACK_RUN_DEST_BASE, BACK_RUN_DEST_ADD);
					}

					// Check if someone is in front of me
					if(infrontdot >= 0)
					{
						// I'll wait on him, and look at my attacker
						if(Attacker != None)
							Focus = Attacker;
						else if(InterestPawn != None)
							Focus = InterestPawn;
						DoWaitOnOtherGuy('WaitOnOtherRunner', 0);
					}
				}
			}
		}
		else if(StaticMeshActor(Other) != None)
			BumpStaticMesh(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set new target point and pick path
	///////////////////////////////////////////////////////////////////////////////
	function SetActorTargetPoint(vector DestPoint, optional bool bStrictCheck)
	{
		Super.SetActorTargetPoint(DestPoint, bStrictCheck);

		// Auto open doors for running people
		//log(Pawn$" move target actor is "$MoveTarget);
		if(Door(MoveTarget) != None
			&& Door(MoveTarget).MyDoor != None)
			Door(MoveTarget).MyDoor.Bump(Pawn);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set new target and pick path
	///////////////////////////////////////////////////////////////////////////////
	function SetActorTarget(Actor Dest, optional bool bStrictCheck)
	{
		Super.SetActorTarget(Dest, bStrictCheck);

		// Auto open doors for running people
		//log(Pawn$" move target actor is "$MoveTarget);
		if(Door(MoveTarget) != None)
			Door(MoveTarget).MyDoor.Bump(Pawn);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Most of the time you'll handle the door nicely
	///////////////////////////////////////////////////////////////////////////////
	function bool CheckForNormalDoorUse()
	{
		// When you run, you don't care about going through doors nicely
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local vector zerovec;
		
		Super.BeginState();

		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);
		
		TimeToScream();

		if(CheckDoor != None)
		{
			CheckDoor.RemoveMe(MyPawn);
			CheckDoor = None;
		}
		// We hope MyNextState was set to something useful, before we start
		if(MyNextState=='')
			PrintStateError(" no mynextstate");
		//log("inside run to target "$MyNextState);
		MyPawn.SetWalking(false);
		SetRotation(MyPawn.Rotation);
		if(EndGoal != None)
			SetActorTarget(EndGoal);
		else if (EndPoint != zerovec)
			SetActorTargetPoint(EndPoint);
		else
			// Short-circuit. End goal missing.
			NextStateAfterGoal();

		// Save where we started running.
		RunStartPoint = MyPawn.Location;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToInterest
// Same as RunToTarget, but only gets called by running to an interest pawn
// Because we don't want to ignore PerformInterestAction.
// Plus we do some destination updatting too, for QPoints.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToInterest extends LegMotionToTarget
{
	ignores RespondToQuestionNegatively, TryToGreetPasserby, DonateSetup, 
		CheckDesiredThing, CheckDeadBody, CheckDeadHead, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		local QPoint CheckQ;
		local vector newpoint;

		Super.InterimChecks();

		statecount++;

		if(statecount == 2)
		{
			// See if we're heading to a queue
			CheckQ = QPoint(CurrentInterestPoint);
			if(CheckQ != None)
			{
				// update where you are going, if the line has changed around on your way there
				newpoint = CheckQ.GetEndEntryPoint(self, MyPawn);

				if(newpoint != EndPoint)
				{
					SetActorTargetPoint(EndPoint);
					bPreserveMotionValues=true;
					GotoState('WalkToInterest');
					BeginState();
				}
			}
		}
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
		MyPawn.SetWalking(false);
		SetRotation(MyPawn.Rotation);
		if(EndGoal != None)
			SetActorTarget(EndGoal);
		else
			SetActorTargetPoint(EndPoint);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to a target from a danger
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToTargetFromDanger extends RunToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Do things after you reach a crappy goal, not your end goal
	///////////////////////////////////////////////////////////////////////////////
	function IntermediateGoalReached()
	{
		CalcScaredRunAnim();
		TellAllImPanicked(class'PanicMarker');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();
		TryToScream();
		TimeToScream();
	}
	///////////////////////////////////////////////////////////////////////////////
	// There was fire in our way, decide what to do
	///////////////////////////////////////////////////////////////////////////////
	function HandleFireInWay(FireEmitter ThisFire)
	{
		local vector newbadpoint, checkpoint, dir;
		local float dfire, ddanger, dtotal;

		//log("RE FIGURING RUN POINT FROM FIRE!!!");

		// Recalc new run destination based on our attacker and the fire
		// in the way

		// hokey method of figuring out a fraction of the too directions
		// to use. combine then use a ratio.
		dfire = VSize(ThisFire.Location - MyPawn.Location);
		//log("df "$dfire);
		ddanger = VSize(DangerPos - MyPawn.Location);
		//log("dd "$ddanger);
		dtotal = dfire + ddanger;
		//log("dt "$dtotal);

		// Use danger dist for fire and danger dist for fire (inverse) because
		// we want a reverse relationship--run away from the closest.
		// If fire dist is 0, then it means you're right next to it, so 
		// ddanger is the full distance, which means, you'll basically pick
		// on the fire location to run away from, because it's the closest danger.
		newbadpoint = (ddanger/dtotal)*ThisFire.Location + (dfire/dtotal)*DangerPos;
		//log("fire loc "$ThisFire.Location);
		//log("danger loc "$dangerpos);
		//log("my loc "$MyPawn.Location);
		//log("new bad point "$newbadpoint);

		dir = Normal(MyPawn.Location - newbadpoint);

		checkpoint = MyPawn.Location + UseSafeRangeMin*dir;

		GetMovePointOrHugWalls(checkpoint, MyPawn.Location, UseSafeRangeMin, true);

		EndGoal = None;
		EndPoint = checkpoint;
	}
	function BeginState()
	{
		Super.BeginState();
		CalcScaredRunAnim();
		LegMotionCaughtMax=1;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to a target, while being chased by Attacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToTargetFromAttacker extends RunToTargetFromDanger
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, 
		RespondToTalker, PerformInterestAction,	DoWaitOnOtherGuy, TryToSendAway,
		GetReadyToReactToDanger;

	///////////////////////////////////////////////////////////////////////////////
	// Check to see if you want to observe this pawn's personal looks (does he have a
	// gun, is he naked)
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		local vector dir;
		local bool bcheck;

		if(LookAtMe == InterestPawn)
		{
			if(CanSeePawn(MyPawn, LookAtMe)
				&& VSize(Attacker.Location - LookAtMe.Location)/UseSafeRangeMin < TOO_CLOSE_CHANGE_TO_RUN_RATIO)
			{
				// recalc and run again, if he's in front of us or something.
				GotoNextState(true);
			}
		}
		/*
		else if(Attacker != LookAtMe
			&& CanSeePawn(MyPawn, LookAtMe))
			ActOnPawnLooks(LookAtMe);
			*/
	}
	function BeginState()
	{
		Super.BeginState();
		LegMotionCaughtMax=1;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToTargetShy
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToTargetShy extends RunToTarget
{
	ignores CheckObservePawnLooks;

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		//log("walk to target SHY "$MyNextState);
		//bFoundFleeSpot=true;
		MyPawn.StopAcc();

		//log("going to watch this guy "$InterestPawn);
		// If you're scared enough to run, always check to see what just happened.
		MakeMoreAlert();
		GotoState('WatchThreateningPawn');
		return;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Don't scream during this
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		ScreamState=SCREAM_STATE_NONE;
		Super.BeginState();
		bDontSetFocus=false; // Make sure Not to side-step
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToFireSafeRange
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToFireSafeRange extends RunToTarget
{
	ignores CheckObservePawnLooks, CheckForObstacles;

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		local float disttofire;

		DodgeThinWall();
		//CheckForObstacles();

		if(EndGoal != None)
		{
			disttofire = VSize(EndGoal.Location - MyPawn.Location);
			// If we're close enough, then just walk there, rather than running right up
			// and not too close
			if(disttofire > EndGoal.CollisionRadius
				&& disttofire < FIRE_MIN_DIST_MULT*UseSafeRangeMin)
			{
				bPreserveMotionValues=true;
				GotoState('WalkToFireSafeRange');
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to a target, but ignore most stuff.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToTargetUrgent extends RunToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, CheckObservePawnLooks, 
		MarkerIsHere, DoWaitOnOtherGuy, TryToSendAway;

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to a target, but ignore everything we can think of
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToTargetIgnoreAll extends RunToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, HearAboutKiller, 
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker, 
		MarkerIsHere, CheckObservePawnLooks, CheckToPuke,
		RespondToCopBother, DecideToListen, damageAttitudeTo, HandleFireInWay, DoWaitOnOtherGuy, TryToSendAway;

	///////////////////////////////////////////////////////////////////////////////
	// Just handles a bump with our attacker
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		if(Attacker != None
			&& Attacker.Health > 0
			&& Attacker == Other
			&& MyNextState == 'ShootAtAttacker')
		{
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// If the SetActorTarget functions below can't find a proper path and end up
	// just setting the next move target as the destination itself, this function
	// will be called, so you can possibly exit your state and do something else instead.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//log(self$" Attacker "$Attacker$" my next "$MyNextState$" distance "$MyPawn.bHasDistanceWeapon$" trace "$FastTrace(MyPawn.Location, Attacker.Location));
		if(Attacker != None
			&& (MyNextState == 'ShootAtAttacker'))
		{
			if(MyPawn.bHasDistanceWeapon
				&& FastTrace(MyPawn.Location, Attacker.Location))
			{
				Focus = Attacker;
				GotoStateSave('ShootAtAttackerDistance');
			}
			else 
			{
				GotoStateSave('WatchAttackerHighUp');
			}
		}
	}
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
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, HearAboutKiller, 
		HearAboutDangerHere, RespondToTalker, ForceGetDown, RatOutAttacker, MarkerIsHere, GetOutOfMyWay,
		CheckObservePawnLooks, NoticePersonBeforeYouInLine, QPointSaysMoveUpInLine, CheckToPuke,
		RespondToCopBother, DecideToListen, damageAttitudeTo, CatchOnFire, CheckForObstacles,
		SetupSideStep, SetupBackStep, SetupMoveForRunner, AllowOldState, MoveAwayFromDoor, 
		DoWaitOnOtherGuy, TryToSendAway, 
		HandleFireInWay, PrepToWaitOnDoor, GetShocked, AnthraxPoisoning, CanHelpOthers, TookNutShot, BlindedByFlashBang;

	///////////////////////////////////////////////////////////////////////////////
	// Check if you've screamed in this state before, and maybe scream then
	///////////////////////////////////////////////////////////////////////////////
	function TryToScream(optional bool bForce)
	{
		if(ScreamState == SCREAM_STATE_NONE
			&& (bForce
				|| FRand() <= FIRE_SCREAMING_FREQ))
		{
			ScreamState=SCREAM_STATE_ACTIVE;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();
		TellAllImPanicked(class'PanicMarker');
		TryToScream();
		TimeToScream(FIRE_SCREAM, 0.5);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Running after blinded by a flashbang
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunningBlind extends RunOnFire
{
	event BeginState()
	{
		Super.BeginState();
		MyPawn.SetAnimRunning();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();
		TellAllImPanicked(class'PanicMarker');
		TryToScream();
		TimeToScream(NORMAL_SCREAM, 0.5);
	}
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're very tired from running from the flashbang
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RestFromFlashbang extends RestFromAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);

		// Check for the base channel only
		if(channel == 0)
		{
			CurrentFloat = CurrentFloat - 1;

			DistanceRun-=(MyPawn.Fitness*REGAIN_BREATH_DIST);
			if(DistanceRun < 0)
				DistanceRun=0;

			if(CurrentFloat > 0)
			{
				// panting while standing
				MyPawn.PlayPantingAnim();
			}
			else
			{
				// You've rested fully
				DistanceRun=0;
				MyPawn.ChangeAnimation();

				if(Attacker == None)
					SetAttacker(InterestPawn);

				DangerPos = MyPawn.Location;
				UseSafeRangeMin = 2*MyPawn.SafeRangeMin;
				if(Attacker != None)
				{
					if (MyPawn.bHasViolentWeapon)
						GotoStateSave('AssessAttacker');
					else
						GotoStateSave('WatchForViolence');
				}
				else
					GotoStateSave('WatchForViolence');
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Running after getting poisoned by anthrax
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunFromAnthrax extends RunOnFire
{
	///////////////////////////////////////////////////////////////////////////////
	// Check if you've screamed in this state before, and maybe scream then
	///////////////////////////////////////////////////////////////////////////////
	function TryToScream(optional bool bForce)
	{
		if(bForce
			|| (ScreamState == SCREAM_STATE_NONE
			&& FRand() <= SCREAMING_FREQ))
		{
			ScreamState=SCREAM_STATE_ACTIVE;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();
		TryToScream();
		TimeToScream(NORMAL_SCREAM, 0.5);
		MyPawn.SetMood(MOOD_Normal, 1.0);
	}
	
	// Force a scream when they begin to run, it always looked dumb with no scream
	event BeginState()
	{
		local AnthraxHack AH;
		
		Super.BeginState();
		TryToScream(true);		
		TimeToScream(NORMAL_SCREAM, 0.5);
		AH = spawn(class'AnthraxHack', Self);
		if (AH != None)
			AH.SetupBy(Self);
	}
/*	
	// Don't run for very long in this state.
Begin:
	Sleep(5.0);
	GotoNextState(); //just drop and fall here
*/
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to a enemy, and ignore most stuff.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToAttacker extends RunToTarget
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere,
			InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas;

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	// If we're going to attack, and we can see our attacker, and we have a weapon
	// that requires us to be close and we're not close enough, then just update
	// your attacker data and keep going after him.
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		local byte StateChange;

		if(MyNextState == 'ShootAtAttacker'
			&& MyPawn.Weapon.bMeleeWeapon
			&& Attacker != None
			&& CanSeePawn(MyPawn, Attacker, FIND_ENEMY_CONE)
			&& VSize(Attacker.Location - MyPawn.Location) > (P2Weapon(MyPawn.Weapon).MaxRange + Attacker.CollisionRadius))
		{
			//log(MyPawn$" run towards "$LastAttackerPos$" you "$Attacker.Location);
			SaveAttackerData();
			SetEndPoint(LastAttackerPos, MyPawn.Weapon.MaxRange);
			SetNextState('ShootAtAttacker', 'FaceHimBeforeLook');
			bStraightPath=UseStraightPath();
			GotoStateSave('RunToAttacker');
		}
		else
		{
			FPSPawn(Pawn).StopAcc();
			//log(Pawn$" NextStateAfterGoal goal was "$MoveTarget$" move point "$MovePoint);
			GotoState(MyNextState, MyNextLabel);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Handle bumps with other characters
	// If you bump you're attacker while chasing him, just attack
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		if(Attacker != None
			&& Attacker.Health > 0
			&& Attacker == Other)
		{
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
		}
		else
			Super.Bump(Other);
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked while you're attacking
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		if ( (Other == None) || (Other == Pawn) || (Damage <= 0))
			return;

		// If it's by a friend, then try to move
		if(SameGang(FPSPawn(Other))
			|| (FPSPawn(Other).bPlayer 
				&& MyPawn.bPlayerIsFriend))
		{
			return;
		}
		else if(MyPawn.MyBodyFire != None
			&& MyPawn.LastDamageType == class'OnFireDamage')
		{
			return;
		}
		else
		{
			SetAttacker(FPSPawn(Other));
			GetAngryFromDamage(Damage);
			MakeMoreAlert();

			// Check to see if you've been hurt past your pain threshold, and then run away
			if(MyPawn.Health < (1.0-MyPawn.PainThreshold)*MyPawn.HealthMax)
			{
				InterestPawn = Attacker;
				MakeMoreAlert();
				DangerPos = InterestPawn.Location;
				GotoStateSave('FleeFromAttacker');
			}
			else
			{
				// randomly pause from the attack
				//PrintDialogue("ARRGGHH!!");
				Say(MyPawn.myDialog.lGotHit);
				MyPawn.StopAcc();
				GotoStateSave('AttackedWhileAttacking');
			}

			return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Don't totally ignore this, but if you get this information, make
	// sure you record where you last saw him
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		local vector dir;
		local bool bcheck;

		if(LookAtMe == Attacker
			&& CanSeePawn(MyPawn, LookAtMe, FIND_ENEMY_CONE))
		{
				//log(MyPawn$" checkobserve, runtoattacker ------i can still see him "$Attacker);
				// Record were we just last saw him
				SaveAttackerData();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		local FPSPawn EnemyTarget;

		Super.InterimChecks();

		//log(MyPawn$" my goal is "$EndGoal$" point "$EndPoint);
		if(EndGoal != None
			&& EnemyTarget == Attacker)
			EnemyTarget = FPSPawn(EndGoal);
		else
			EnemyTarget = Attacker;

		if(EnemyTarget != None)
		{
			if(EnemyTarget.Health <= 0)
			{
				SetAttacker(None);
				GotoStateSave('LookAroundForTrouble');
			}
			//log("checking to see "$EndGoal);
			else if(CanSeePawn(MyPawn, EnemyTarget, FIND_ENEMY_CONE))
			{
				//log(MyPawn$" Interimchecks, runtoattacker ------i can still see him "$Attacker);
				// Record were we just last saw him
				SaveAttackerData(EnemyTarget);
				// Crank up the radius we're running to, if it's too small
				if(EndRadius < MyPawn.AttackRange.Min)
				{
					//UseEndRadius = MyPawn.AttackRange.Min;
					EndRadius=MyPawn.AttackRange.Min;
				}
				// Head to where you last saw him
				EndPoint = LastAttackerPos;
				SetActorTargetPoint(EndPoint);
			}
		}
		else if(Attacker != None
			&& Attacker.Health <= 0)
		{
			SetAttacker(None);
			GotoStateSave('LookAroundForTrouble');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// If the SetActorTarget functions below can't find a proper path and end up
	// just setting the next move target as the destination itself, this function
	// will be called, so you can possibly exit your state and do something else instead.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//log(self$" Attacker "$Attacker$" my next "$MyNextState$" distance "$MyPawn.bHasDistanceWeapon$" trace "$FastTrace(MyPawn.Location, Attacker.Location));
		if(Attacker != None
			&& (MyNextState == 'ShootAtAttacker'))
		{
			if(MyPawn.bHasDistanceWeapon
				&& FastTrace(MyPawn.Location, Attacker.Location))
			{
				Focus = Attacker;
				GotoStateSave('ShootAtAttackerDistance');
			}
			else 
			{
				GotoStateSave('WatchAttackerHighUp');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Handle anims
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		MyPawn.SetMood(MOOD_Combat, 1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to a target, but from something that was pissing on you
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunFromPisser extends RunToTargetFromDanger
{
	ignores GettingDousedInGas;

	function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
	{
		if(bPuke)
			// Definitely throw up from puke on me
			CheckToPuke(, true);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Each time you finish running, check to wipe your face
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		local byte StateChange;

		CheckWipeFace(StateChange);
		if(StateChange != 1)
			Super.NextStateAfterGoal();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunPatrolToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunPatrolToTarget extends RunToTarget
{
	ignores PerformInterestAction, TryToGreetPasserby;

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
	ignores BumpStaticMesh;

	///////////////////////////////////////////////////////////////////////////
	// You're not doing anything important enough to keep you from walking to
	// the player (to get into some of the action). If you're bound by home nodes
	// you won't do this. And only a few states allow this
	// This state is boring enough to go seek the player instead
	///////////////////////////////////////////////////////////////////////////
	function bool FreeToSeekPlayer()
	{
		return true;
	}

	/*
	///////////////////////////////////////////////////////////////////////////////
	// Do things after you reach a crappy goal, not your end goal
	///////////////////////////////////////////////////////////////////////////////
	function IntermediateGoalReached()
	{
		// Look straight ahead again
		MyPawn.PlayTurnHeadStraightAnim(0.2);
	}
*/
	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		local float randcheck;

		Super.InterimChecks();

		randcheck = FRand();

		// sometimes tell people about my weapon
		if(randcheck <= REPORT_WEAPON_FREQ)
			ReportViolentWeaponNoStasis();

		if(MyPawn.Mood != MOOD_Combat)
		{
			LookAroundWithHead(randcheck, 0.1, 0.2, 0.4, 0.042, 1.0);
		}
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
		MyPawn.TryToWaitForStasis();

		// restore our movement
//		MyPawn.MovementPct = MyPawn.default.MovementPct;
//		MyPawn.WalkingPct = MyPawn.default.WalkingPct;

		Super.EndState();
	}

Begin:
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
	Goto('Begin');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToWork
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToWork extends WalkToTarget
{
	ignores PerformInterestAction, RespondToQuestionNegatively, TryToGreetPasserby,
		DonateSetup, CheckDesiredThing, CheckDeadBody, CheckDeadHead, WatchFunnyThing, 
		CanStartConversation, FreeToSeekPlayer;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToDesiredThing
// On your way to picking up a donut or something
//
// Focus here holds the item we're interested, be sure not to clear it!
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToDesiredThing extends WalkToTarget
{
	ignores PerformInterestAction, RespondToQuestionNegatively, TryToGreetPasserby,
			CheckDesiredThing, CheckDeadBody, CheckDeadHead, DonateSetup, CanStartConversation, 
			WatchFunnyThing, FreeToSeekPlayer;
}

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToInterest
// Same as WalkToTarget, except we might update our destination
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToInterest extends WalkToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		local QPoint CheckQ;
		local vector newpoint;

		Super.InterimChecks();

		statecount++;

		if(statecount == 2)
		{
			// See if we're heading to a queue
			CheckQ = QPoint(CurrentInterestPoint);
			if(CheckQ != None
				&& EndGoal == None)
			{
				// update where you are going, if the line has changed around on your way there
				newpoint = CheckQ.GetEndEntryPoint(self, MyPawn);
				//log(MyPawn$"---------- my loc "$MyPawn.Location$" my goal "$EndPoint$" new point "$newpoint);
				if(newpoint != EndPoint)
				{
					EndPoint = newpoint;
					SetActorTargetPoint(EndPoint);
					bPreserveMotionValues=true;
					GotoState('WalkToInterest');
					BeginState();
				}
			}
			statecount=0;
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local QPoint CheckQ;
		local vector newpoint;

		// If we're not trying to cut, try to regrab where we should stand when
		// going into the line, in case we bumped into someone along the way and
		// the line restructured.
		if(QLineStatus != EQLineStatus.EQ_Cutting)
		{
			// See if we're heading to a queue
			CheckQ = QPoint(CurrentInterestPoint);
			if(CheckQ != None
				&& EndGoal == None)
			{
				// update where you are going, if the line has changed around on your way there
				newpoint = CheckQ.GetEndEntryPoint(self, MyPawn);
				//log(MyPawn$"---------- my loc "$MyPawn.Location$" my goal "$EndPoint$" new point "$newpoint);
				if(newpoint != EndPoint)
				{
					EndPoint = newpoint;
					SetActorTargetPoint(EndPoint);
					//log(self$" changing point ");
				}
			}
		}

		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkInQ
// Same as WalkToTarget, except we want line updates
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkInQ extends WalkToTarget
{
	ignores TryToGreetPasserby, DonateSetup, SetupSideStep, SetupBackStep, SetupMoveForRunner, AllowOldState,
		DoWaitOnOtherGuy, TryToSendAway, CanStartConversation, CanBeMugged, 
		FreeToSeekPlayer/*, InterimChecks*/;

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		//Super.InterimChecks();
		CheckToLeaveQueue();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if someone cut in front of you
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local P2Pawn BeforeMe;
		local vector v1, v2;
		local byte Cutter;

		if(FPSPawn(Other) != None
			&& FPSPawn(Other).Health > 0
			&& Other != InterestPawn)
		{
			BeforeMe = P2Pawn(Other);

			// If we can see the guy and he's not the guy who's supposed to be in front
			// of us, then get mad at him for cutting
			
			// Check if he's really between us and the start of the line or not
			v1 = (CurrentInterestPoint.Location - MyPawn.Location);
			v2 = (Other.Location - MyPawn.Location);

			if(BeforeMe != None
				&& (v1 dot v2) > 0)
			{
				CheckForLineCutter(BeforeMe, statecount, Cutter);

				if(Cutter == 1)
				{
					MyPawn.SetMood(MOOD_Angry, 1.0);
					InterestPawn = BeforeMe;
					// Quit early
					if(MyNextState != 'WaitInQ')
						NextStateAfterGoal();
					else
					{
						// Go straight to getting pissed at the guy in front of you
						MyPawn.StopAcc();
						GotoState('WaitInQ', 'PissedAtCutter');
					}
				}
			}
		}

		Super.Bump(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// If the guy in front of us is still in line and 
	// he's already moved again, then keep up with him.
	///////////////////////////////////////////////////////////////////////////////
	function bool CheckToMoveUpInLine()
	{
		return CheckToMoveUpInLineBase();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		// if the guy in front of us is still in line and 
		// he's already moved again, then keep up with him.
		if(!CheckToMoveUpInLine())
			Super.NextStateAfterGoal();
		else
			GotoState(GetStateName());
	}

	///////////////////////////////////////////////////////////////////////////////
	// Look at the person in front of you, perhaps they're the wrong person
	// If you're farther back than you think you should be, then get mad
	///////////////////////////////////////////////////////////////////////////////
	function NoticePersonBeforeYouInLine(P2Pawn Other, int YourNewSpot)
	{
		local byte Cutter;

		CheckForLineCutter(Other, YourNewSpot, Cutter);

		statecount = YourNewSpot;

		if(Cutter == 1)
		{
			// Quit early
			if(MyNextState != 'WaitInQ')
				NextStateAfterGoal();
			else
			{
				// Go straight to getting pissed at the guy in front of you
				MyPawn.StopAcc();
				GotoState('WaitInQ', 'PissedAtCutter');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Increase the frequency they check to see if they're stuck on something
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		MyPawn.PathCheckTimePoint = 1.0;
		Pawn.ShouldCrouch(false);
	}

	function EndState()
	{
		Super.EndState();
		MyPawn.PathCheckTimePoint = MyPawn.default.PathCheckTimePoint;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToCustomerStand
// Same as WalkToTarget, we don't want line updates, we just want to get
// to the front of the q
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToCustomerStand extends WalkToTarget
{
	ignores TryToGreetPasserby, DonateSetup, SetupSideStep, SetupBackStep, SetupMoveForRunner, AllowOldState,
		DoWaitOnOtherGuy, TryToSendAway, CanStartConversation, CanBeMugged, 
		FreeToSeekPlayer, InterestIsAnnoyingUs, InterimChecks;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToCounter
// Walk to the counter, and when you get there, tell the cashier, you're ready
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToCounter extends WalkToCustomerStand
{
	///////////////////////////////////////////////////////////////////////////////
	// Tell the person at the counter, you're ready
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		if(InterestPawn != None
			&& PersonController(InterestPawn.Controller) != None)
			PersonController(InterestPawn.Controller).HandleThisPerson(MyPawn);	// Tell them I've arrived.
		else
			Super.NextStateAfterGoal();	// Something's gone wrong, so abandon things
	}

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToTargetShy
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToTargetShy extends WalkToTarget
{
	ignores PerformInterestAction, TryToGreetPasserby, DonateSetup, CheckDeadBody, CheckDeadHead, 
		CheckDesiredThing, CheckForIntruder, WatchFunnyThing, CanStartConversation;

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		//log("walk to target SHY "$MyNextState);
		//bFoundFleeSpot=true;
		MyPawn.StopAcc();

		if(FRand() <= MyPawn.Curiosity)
		{
			//log("going to watch this guy "$InterestPawn);
			MakeMoreAlert();
			GotoState('WatchThreateningPawn');
			return;
		}
		else if(CanSeePawn(InterestPawn, MyPawn))
		{
			GotoState('ShyToSafeDistance');
			return;
		}

/*
		else if(MyNextState == 'WalkToTarget'
				|| MyNextState == 'RunToTarget')
		{
			Focus = None;

			PrintStateError("Using endpoint incorrectly 3");

			if(OldEndGoal != None)
			{
				SetEndGoal(OldEndGoal, OldEndGoal.CollisionRadius);
				SetActorTarget(EndGoal);
			}
			else
			{
				SetEndPoint(OldEndPoint, DEFAULT_END_RADIUS);
				SetActorTargetPoint(EndPoint);
			}
		}
		*/
		GotoState(MyNextState, MyNextLabel);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to see if you want to observe this pawn's personal looks (does he have a
	// gun, is he naked)
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		local vector dir;
		local bool bcheck;

		if(LookAtMe == InterestPawn)
		{
			if(CanSeePawn(MyPawn, LookAtMe)
				&& VSize(MyPawn.Location - LookAtMe.Location) < 4*MyPawn.CollisionRadius)
			{
				// We were already concerned about him and now he's within a person's
				// width from us

				//log("was walking, now I'm running");
				bPreserveMotionValues=true;
				GotoState('RunToTargetShy');
			}
		}
		else if(Attacker != LookAtMe
			&& CanSeePawn(MyPawn, LookAtMe))
			ActOnPawnLooks(LookAtMe);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToDeadThing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToDeadThing extends WalkToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Derail us to try again
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//log(MyPawn$" can't get to it "$Dest$" pt "$DestPoint);
		// Either stare at a while, or give up all together
		if(FRand() > MyPawn.Curiosity)
			GotoStateSave('InvestigateDeadThing', 'StareALongTime');
		else // give up
			GotoStateSave('Thinking');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToTargetFindAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToTargetFindAttacker extends WalkToTarget
{
	ignores RespondToTalker, PerformInterestAction, RatOutAttacker, CheckDeadBody, CheckDeadHead,
		WatchFunnyThing, CheckDesiredThing, CheckForIntruder, CanStartConversation, 
		HandleStasisChange, FreeToSeekPlayer;

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		local byte LostHim;
		local byte StateChange;

		Super.InterimChecks();
		// Check if you can hear your attacker
		if(InterestPawn != None)
		{
			DetectAttacker(InterestPawn, StateChange, LostHim, true);
			if(LostHim == 0
				&& StateChange == 0)
				FoundHim(InterestPawn);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// You currently only care about the looks of your attacker/aggressor
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		SetRotation(MyPawn.Rotation);

		// Engage your old attacker on sight
		if(InterestPawn == LookAtMe
			&& CanSeePawn(MyPawn, LookAtMe))
		{
			FoundHim(InterestPawn);
		}
		else	// Handle others around you
		{
			Super.CheckObservePawnLooks(LookAtMe);
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked while you're attacking
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		if ( (Other == None) || (Other == Pawn) || (Damage <= 0))
			return;

		// If it's by a friend, then try to move
		if(SameGang(FPSPawn(Other))
			|| (FPSPawn(Other).bPlayer 
				&& MyPawn.bPlayerIsFriend))
		{
			return;
		}
		else if(MyPawn.MyBodyFire != None
			&& MyPawn.LastDamageType == class'OnFireDamage')
		{
			return;
		}
		else
		{
			SetAttacker(FPSPawn(Other));
			GetAngryFromDamage(Damage);
			MakeMoreAlert();
			// Check to see if you've been hurt past your pain threshold, and then run away
			if(MyPawn.Health < (1.0-MyPawn.PainThreshold)*MyPawn.HealthMax)
			{
				InterestPawn = Attacker;
				MakeMoreAlert();
				DangerPos = InterestPawn.Location;
				GotoStateSave('FleeFromAttacker');
			}
			else
			{
				// randomly pause from the attack
				//PrintDialogue("ARRGGHH!!");
				Say(MyPawn.myDialog.lGotHit);
				SetNextState('ShootAtAttacker');
				MyPawn.StopAcc();
				GotoStateSave('AttackedWhileAttacking');
			}

			return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Handle anims
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		MyPawn.SetMood(MOOD_Combat, 1.0);

		SwitchToBestWeapon();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToFireSafeRange
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToFireSafeRange extends WalkToTarget
{
	ignores CheckObservePawnLooks, CheckForObstacles, PerformInterestAction, CheckDeadBody, CheckDeadHead, 
		CheckDesiredThing, CanStartConversation, FreeToSeekPlayer, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		DodgeThinWall();
		//CheckForObstacles();
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
	ignores PerformInterestAction, FreeToSeekPlayer, HandlePlayerSightReaction;

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

		//log(MyPawn$" NextStateAfterGoal, path node length "$MyPawn.PatrolNodes.Length$" goal was "$MoveTarget$" move point "$MovePoint);
		if(MyPawn.PatrolNodes.Length == 0)
		{
			PickRandomDest();
			//log(MyPawn$" new random dest is "$EndGoal);
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
// DeathCrawlFromAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DeathCrawlFromAttacker extends WalkToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, 
		HearAboutKiller, HearAboutDangerHere, HandleFireInWay, DodgeThinWall,
		RespondToTalker, ForceGetDown, RatOutAttacker, MarkerIsHere, CheckToPuke,
		RespondToQuestionNegatively, CheckObservePawnLooks, PrepToWaitOnDoor, CheckForIntruder,
		RespondToCopBother, DecideToListen, DoDeathCrawlAway, PerformInterestAction,
		DonateSetup, SetupSideStep, SetupBackStep, SetupMoveForRunner, 
		AllowOldState, MoveAwayFromDoor, CheckForNormalDoorUse,  GetOutOfMyWay,
		CanStartConversation, CanBeMugged, FreeToSeekPlayer, HandlePlayerSightReaction, DangerPawnBump, 
		WingedByRifle, CanHelpOthers, DoWaitOnOtherGuy, TryToSendAway, Trigger, RocketIsAfterMe, TookNutShot, BlindedByFlashBang;

	///////////////////////////////////////////////////////////////////////////////
	// If you get shocked in this position just vibrate more
	///////////////////////////////////////////////////////////////////////////////
	function GetShocked(P2Pawn Doer, vector HitLocation)
	{
		// Start randomly along the way to shake some
		CurrentFloat = Rand(10);
		GotoStateSave('CowerInABallShocked');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Catch on fire, but keep doing this
	///////////////////////////////////////////////////////////////////////////////
	function CatchOnFire(FPSPawn Doer, optional bool bIsNapalm)
	{
		CatchOnFireCantMove(Doer, bIsNapalm);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		FPSPawn(Pawn).StopAcc();
		if(MyPawn.Health > 0)
		{
			MyPawn.ShouldDeathCrawl(false);
			MyPawn.ShouldCrouch(false);
		}
		GotoNextState();
	}

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function InterimSound()
	{
		//PrintDialogue("ehh.. oooh...");
		Say(MyPawn.myDialog.lSniveling);
	}
	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function StartSound()
	{
		//PrintDialogue("Please just make it stop...");
		Say(MyPawn.myDialog.lDying);
	}

	///////////////////////////////////////////////////////////////////////////
	// Shot when begging, but not dead, so cry more
	// Or run or something
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		local bool bDoCry;

		if ( (Other == None) || (Damage <= 0))
			return;
		//local vector dir;
		if(Other == Pawn)
		{
			if(ScreamState == SCREAM_STATE_NONE)
				bDoCry=true;
		}
		else
			bDoCry=true;

		if(bDoCry)
		{
			PrintDialogue("Waaaahhaa... boohoo");
			SayTime = Say(MyPawn.myDialog.lCrying);
			// Instead of using the timer for the TryToScream/TimeToScream system,
			// just use this to know when we can scream again from our own pain
			// Otherwise, scream everytime the dude/someone hurts us now
			SetTimer(SayTime+Frand(), false);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Moan, make noises as you crawl
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		// Check how close the dude is and if he is aiming his gun at you. If so
		// curl up and cower
		if(Attacker != None)
			CurrentDist = VSize(Attacker.Location - MyPawn.Location);

		if(Attacker != None
			&& CurrentDist < COWER_DISTANCE
			&& MyPawn.MyBodyChem == None)
		{
			// Check if someone is in front of me
			if(P2Pawn(Attacker) != None
				&& WeaponTurnedToUs(Attacker, MyPawn)
				&& P2Weapon(Attacker.Weapon) != None
				&& P2Weapon(Attacker.Weapon).ViolenceRank > 0)
			{
				if(CanSeePawn(MyPawn, Attacker))
				{
					bPreserveMotionValues=true;
					GotoStateSave('PerformBegForLifeProne');
					return;
				}
				else
				{
					bPreserveMotionValues=true;
					GotoStateSave('CowerInABall');
					return;
				}
			}
			else // otherwise just moan
				InterimSound();
		}

		if(MyPawn.LastRenderTime + 1.0 >= Level.TimeSeconds)
		{
			DeadBodyMarkerHere.static.NotifyControllersStatic(
				Level,
				DeadBodyMarkerHere,
				None,
				MyPawn, 
				DeadBodyMarkerHere.default.CollisionRadius,
				MyPawn.Location);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		// We hope MyNextState was set to something useful, before we start
		if(MyNextState=='')
			PrintStateError(" no mynextstate");
		
		MyPawn.StopAcc();

		SetRotation(MyPawn.Rotation);

		Focus = None;

		if(EndGoal != None)
			SetActorTarget(EndGoal);
		else
			SetActorTargetPoint(EndPoint);

		ScreamState=SCREAM_STATE_NONE;
		StartSound();
		
		// If we're deathcrawling because limbs are gone, keep deathcrawling forever
		if (MyPawn.bMissingLimbs)
			SetNextState('DeathCrawlFromAttacker');
	}

	///////////////////////////////////////////////////////////////////////////////
	// allow them to crouch again
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(!bPreserveMotionValues
			&& MyPawn.Health > 0)
		{
			MyPawn.ShouldDeathCrawl(false);
			MyPawn.ShouldCrouch(false);
		}
		Super.EndState();
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Stop us when we land
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		FPSPawn(Pawn).StopAcc();
		Pawn.ChangeAnimation();
		//log(self$" notify landed ");
		return true;
	}
Begin:
	MyPawn.ShouldDeathCrawl(true);

	if(Pawn.Physics == PHYS_FALLING)
	{
		//log(self$" waiting for landing ");
		WaitForLanding();
	}
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,MyPawn.MovementPct,,,true);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,MyPawn.MovementPct,true);
		InterimChecks();
	}
	Sleep(0.0);
	Goto('Begin');// run this state again
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
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas,
		HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, HandleFireInWay,  GetOutOfMyWay,
		CheckForIntruder, RespondToTalker, ForceGetDown, RatOutAttacker, MarkerIsHere, 
		RespondToQuestionNegatively, CheckObservePawnLooks, AnthraxPoisoning,
		RespondToCopBother, DecideToListen, DoDeathCrawlAway, PerformInterestAction, 
		HandlePlayerSightReaction, CanHelpOthers, CheckForNormalDoorUse, MoveAwayFromDoor, WaitForMover,
		Bump, RocketIsAfterMe, SetupSideStep, SetupBackStep, SetupMoveForRunner, 
		AllowOldState, Bump, EncroachingOn;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function GetShocked(P2Pawn Doer, vector HitLocation)
	{
		// Stub it out for default, but shocked-cower wants to use this.
	}

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
		//local vector dir;

		if ( (Other == None) || (Other == Pawn) || (Damage <= 0))
			return;
		//PrintDialogue("Waaaahhaa... boohoo");
		Say(MyPawn.myDialog.lCrying);
	}

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
			else
			{
				GotoState(MyOldState);
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		MyPawn.StopAcc();
		MyPawn.ShouldCower(true);
		PrintThisState();
		PrintDialogue("Mommy...");
		Say(MyPawn.myDialog.lDying);
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Say you're not cowering anymore
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(MyPawn.Health > 0)
			MyPawn.ShouldCower(false);
		MyPawn.ChangeAnimation();
	}

Begin:
	MyPawn.PlayCoweringInBallAnim();
	Sleep(1.0);
	// stay in here till you die or maybe try to beg when comes over top of you
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// KnockedOutState
// You're laid out on the ground, but not dead
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state KnockedOutState
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas,
		HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, HandleFireInWay,  GetOutOfMyWay,
		CheckForIntruder, RespondToTalker, ForceGetDown, RatOutAttacker, MarkerIsHere, 
		RespondToQuestionNegatively, CheckObservePawnLooks, AnthraxPoisoning,
		RespondToCopBother, DecideToListen, DoDeathCrawlAway, PerformInterestAction, 
		HandlePlayerSightReaction, CanHelpOthers, CheckForNormalDoorUse, MoveAwayFromDoor, WaitForMover,
		Bump, RocketIsAfterMe, SetupSideStep, SetupBackStep, SetupMoveForRunner, 
		AllowOldState, Bump, EncroachingOn, GetShocked, DoGetKnockedOut, TookNutShot, BlindedByFlashBang;
	
	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage,
						   class<DamageType> damageType, vector Momentum)
	{
		// Any kind of damage in this state will accelerate the wake-up process
		KnockedOutTime -= Damage;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Catch on fire, but keep doing this
	// FIXME
	///////////////////////////////////////////////////////////////////////////////
	function CatchOnFire(FPSPawn Doer, optional bool bIsNapalm)
	{
		CatchOnFireCantMove(Doer, bIsNapalm);
	}

	///////////////////////////////////////////////////////////////////////////
	// Shot when begging, but not dead, so cry more
	// Or run or something
	// FIXME
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		//local vector dir;

		if ( (Other == None) || (Other == Pawn) || (Damage <= 0))
			return;
		//PrintDialogue("Waaaahhaa... boohoo");
		//Say(MyPawn.myDialog.lCrying);
	}

	///////////////////////////////////////////////////////////////////////////////
	// check to keep cowering
	// FIXME
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Engine bug causes head to go dark. For some reason, you can fix it by setting their location to... their location.
		MyPawn.SetLocation(MyPawn.Location);
		// Something is screwing with the head's ambient glow... fix it
		//if (MyPawn.MyHead != None)
			//MyPawn.MyHead.Ambientglow = 200;
			
		// see if it's time to get up yet
		if (Level.TimeSeconds - KnockedOutTime > KNOCK_OUT_TIME)
			GotoState('GetUpFromKnockOut');
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		MyPawn.StopAcc();
		// Record when we got rekt
		KnockedOutTime = Level.TimeSeconds;
		MyPawn.MyHead.GotoState('KnockedOutState');
		
		//MyPawn.ShouldCower(true);
		//PrintThisState();
		//PrintDialogue("Mommy...");
		//Say(MyPawn.myDialog.lDying);
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Say you're not cowering anymore
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(MyPawn.Health > 0)
			// Restore collision height
			MyPawn.ShouldDeathCrawl(false);
		MyPawn.bIsKnockedOut = false;
		MyPawn.ChangeAnimation();
		MyPawn.MyHead.GotoState('');
		
		// Say they recover with only half their regular stamina... so they can be knocked out again easily
		MyPawn.NonLethalHealth = MyPawn.HealthMax / 2;
	}

Begin:
	MyPawn.PlayKnockedOutAnim();
	//Sleep(1.0);
	// stay in here till you die or maybe try to beg when comes over top of you
	//Goto('Begin');

	// Engine bug causes head to go dark. For some reason, you can fix it by setting their location to... their location.
	Sleep(0.1);
	MyPawn.SetLocation(MyPawn.Location);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// GetUpFromKnockOut
// We're getting back up, not quite fully there yet though
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GetUpFromKnockOut
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, 
		HearAboutKiller, HearAboutDangerHere, HandleFireInWay, DodgeThinWall, GetOutOfMyWay,
		RespondToTalker, ForceGetDown, RatOutAttacker, MarkerIsHere, CheckToPuke,
		RespondToQuestionNegatively, CheckObservePawnLooks, PrepToWaitOnDoor, CheckForIntruder,
		RespondToCopBother, DecideToListen, DoDeathCrawlAway, PerformInterestAction,
		DonateSetup, SetupSideStep, SetupBackStep, MoveAwayFromDoor, CheckForNormalDoorUse, SetupMoveForRunner, 
		CanStartConversation, CanBeMugged, FreeToSeekPlayer, HandlePlayerSightReaction, DangerPawnBump, 
		WingedByRifle, CanHelpOthers, DoWaitOnOtherGuy, TryToSendAway, Trigger, RocketIsAfterMe, DoGetKnockedOut, TookNutShot, BlindedByFlashBang;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Mostly recovered now, shake it off.
		// We'll chase down our attacker afterward, we're probably mad as hell now
		GotoState('RestAfterBigHurt');		
	}

Begin:	
	MyPawn.PlayAnim(MyPawn.GetAnimEndKnockOut(), 1.0, 0.3);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CowerInABallShocked
// You've just been shocked and you're shaking on the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CowerInABallShocked extends CowerInABall
{
	///////////////////////////////////////////////////////////////////////////////
	// If you get shocked in this position just vibrate more
	///////////////////////////////////////////////////////////////////////////////
	function GetShocked(P2Pawn Doer, vector HitLocation)
	{
		if(CurrentFloat < MyPawn.HealthMax)
			CurrentFloat+=1.0;
	}

	///////////////////////////////////////////////////////////////////////////////
	// check to keep cowering
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			CurrentFloat = CurrentFloat - 1;

			if(CurrentFloat > 0)
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

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();

		MyPawn.StopPeeingPants();
	}

Begin:
	MyPawn.PlayCoweringInBallShockedAnim(CurrentFloat, 0.5);
	MyPawn.PeePants();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AccostFocus
// This assumes the focus has been set to something good
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AccostFocus
{
	ignores RespondToQuestionNegatively, TryToGreetPasserby, DonateSetup, PerformInterestAction,
		CheckDeadBody, CheckDeadHead,CheckDesiredThing, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			// continue on your way
			GotoNextState();
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
	}

Begin:
	MyPawn.StopAcc();
	// wait for a second to face the focus
	Sleep(0.5);

	// Flip them off
	MyPawn.SetMood(MOOD_Angry, 1.0);
	MyPawn.PlayTellOffAnim();
	// say something mean
	SayTime = Say(MyPawn.myDialog.lTrashTalk);
	Sleep(SayTime);

	// continue on your way
	GotoNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// HarassAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HarassAttacker
{
	ignores RespondToQuestionNegatively, TryToGreetPasserby, DonateSetup, PerformInterestAction,
		CheckDeadBody, CheckDeadHead, CheckDesiredThing, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// Say we want to harass this guy
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		Focus = Attacker;
	}
Begin:
	//log("harassing "$Attacker);
	Sleep(1.0 - MyPawn.Reactivity);
	MyPawn.ShouldCrouch(false);
	FireWeaponAt(Attacker);
	StopFiring();
	//log("harassing still"$Attacker);
	SetEndGoal(Attacker, Attacker.CollisionRadius);
	SetNextState('Thinking');
	GotoStateSave('RunToTarget');
	//GotoState('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// I'm on fiyaaaaa!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ImOnFire
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, HearWhoAttackedMe, 
		HearAboutKiller, HearAboutDangerHere, HandlePlayerSightReaction,  GetOutOfMyWay,
		RespondToTalker, PerformInterestAction, ForceGetDown, RatOutAttacker, MarkerIsHere, 
		RespondToQuestionNegatively, TryToGreetPasserby, CheckObservePawnLooks, CheckToPuke,
		RespondToCopBother, DecideToListen, damageAttitudeTo, CatchOnFire, NoticePersonBeforeYouInLine, 
		QPointSaysMoveUpInLine, CanHelpOthers, RocketIsAfterMe, TookNutShot, BlindedByFlashBang;

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
			if(Attacker != None)
				GotoStateSave('FleeFromAttacker');
			else
				GotoStateSave('FleeFromDanger');
		}
	}

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	CheckToReturnToNormal();

	TryToScream();
	TimeToScream(FIRE_SCREAM, 1.0);

	PickNextDest();

	SetNextState('ImOnFire');
	GotoStateSave('RunOnFire');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// I'm blind!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ImBlind extends ImOnFire
{
	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function CheckToReturnToNormal()
	{
		if(Level.TimeSeconds - FlashbangStartTime > FLASHBANG_BASE_RUN_TIME)
			GotoState('RestFromFlashbang');
	}

Begin:
	CheckToReturnToNormal();

	TryToScream();
	TimeToScream(NORMAL_SCREAM, 1.0);

	PickNextDest();

	SetNextState('ImBlind');
	GotoStateSave('RunningBlind');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PatOutFire
// Inherit ImOnFire's ignores only.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PatOutFire extends ImOnFire
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			log(MyPawn$" done with fire anim "$MyPawn.MyBodyFire$" delete "$MyPawn.MyBodyFire.bDeleteMe);
			MyPawn.MyBodyFire = None;
			MyPawn.ChangeAnimation();
			if(Attacker != None)
				GotoState('AssessAttacker');
			else
				GotoState('LookAroundForTrouble');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make sure you have your hands out to pat down the fire
	///////////////////////////////////////////////////////////////////////////////
	function CheckHandsReady(optional out byte StateChange)
	{
		local P2Weapon p2weap;

		p2weap = P2Weapon(MyPawn.Weapon);

		// You're weapon's not ready
		if(p2weap.ViolenceRank != 0
			|| !p2weap.IsIdle())
		{
			StateChange=1;
			GotoStateSave('PatOutFire','WaitForWeapon');
		}
	}

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		if(MyPawn.MyBodyFire != None)
		{
			MyPawn.MyBodyFire = None;
			MyPawn.ChangeAnimation();
		}
		Super.EndState();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		// Stare where we were last pointing
		Focus = None;
		FocalPoint = MyPawn.Location + 1024*vector(MyPawn.Rotation);

		// Put out the fire now as we pat
		if(MyPawn.MyBodyFire != None
			&& !MyPawn.MyBodyFire.bDeleteMe)
			MyPawn.MyBodyFire.GotoState('Fading');
	}
WaitForWeapon:
	Sleep(0.3);
Begin:
	CheckHandsReady();

	MyPawn.StopAcc();

	MyPawn.PlayPatFireAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RatOutTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RatOutTarget
{
	ignores RespondToTalker, PerformInterestAction, RespondToQuestionNegatively,
		TryToGreetPasserby, RespondToCopBother, DecideToListen, CheckDeadBody, CheckDeadHead, CheckDesiredThing,
		SetupSideStep, SetupBackStep, SetupMoveForRunner, AllowOldState, DoWaitOnOtherGuy, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// Because you love the attacker, pick someone else out to tell the Asker
	// that that is who you want him to think attacked him. Even though you're lying.
	///////////////////////////////////////////////////////////////////////////////
	function bool PickScapeGoat()
	{
		local P2Pawn CheckP;
		local float dist;

		// check all the pawns around me.
		ForEach VisibleCollidingActors(class'P2Pawn', CheckP, VISUALLY_FIND_RADIUS, MyPawn.Location)
		{
			// If it isn't me, the asker, and esp. not the person who REALLY did it.
			// Also, make sure he has a gun out
			if(CheckP != MyPawn && CheckP != InterestPawn
				&& CheckP != Attacker
				&& CheckP.Health > 0	// pick a live scape goat
				&& CheckP.Weapon != None
				&& FastTrace(MyPawn.Location, CheckP.Location))
			{
				// Pick him as your new 'attacker'
				SetAttacker(CheckP);
				return true;
			}
		}
		return false;
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

	function BeginState()
	{
		PrintThisState();
	}

Begin:
	Focus = Attacker;	// look at who you point out

	MyPawn.ShouldCrouch(false);
	// If his Rat level is less than zero, that means he sides with the
	// attacker and will falsely notify who attacked the asker. 
	if(MyPawn.Rat < 0)
	{
		if(!PickScapeGoat())
		{
			// We COULDN'T find a good scape goat, and since we don't want to point out our friend
			// we'll just skip all the rest of this and go attack people who tell people
			// about our friend.
			if(InterestPawn2 != None)
			{
				SetAttacker(InterestPawn2);
				GotoStateSave('HarassAttacker');
			}
				// FIX ME make it so he watches the violence or something
			else
				GotoStateSave('');
		}
		//log("I'm going to lie to you");
		PrintDialogue("That guy over there did it! hee hee hee...");
		SayTime = Say(MyPawn.myDialog.lFakeRatOut);
		Focus = Attacker;	// look at who you point out (probably the wrong guy here, since you lied)
		// Sit stupid for a second
		// but lying rats speak up faster, so as to confuse the asker
		Sleep(1.0 - MyPawn.Reactivity);
	}
	else
	{
		PrintDialogue("That guy over there did it! ");
		SayTime = Say(MyPawn.myDialog.lRatOut);
		// Sit stupid for a second
		Sleep(1.5 - MyPawn.Reactivity);
	}

	// Point anim
	MyPawn.SetMood(MOOD_Angry, 1.0);
	MyPawn.PlayPointThatWayAnim();

	// use Asker to help determine where to aim head.
	Sleep(SayTime);

	// Notify the guy that asked
	if(InterestPawn != None
		&& PersonController(InterestPawn.Controller) != None)
		PersonController(InterestPawn.Controller).HearWhoAttackedMe(Attacker, MyPawn);

	// If you lied and someone contradicted you, go bother them and get mad
	if(MyPawn.Rat < 0 && InterestPawn2 != None)
	{
		SetAttacker(InterestPawn2);
		GotoStateSave('HarassAttacker');
	}

	GotoStateSave('WatchForViolence');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Confused before next state 
// Generally be confused then do your next state, like attack the guy
// you were confused about
// Requires InterestVect be set first for the focal point interest
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ConfusedByDanger
{
	ignores CheckDeadBody, CheckDeadHead, CheckDesiredThing, DangerPawnBump, WatchFunnyThing;
	///////////////////////////////////////////////////////////////////////////////	
	// Look at your interest
	///////////////////////////////////////////////////////////////////////////////
	function CheckInterest()
	{
		local byte StateChange;

		//log(self$" checkinterest "$interestpawn$" hearing "$MyPawn.bIgnoresHearing$" senses "$MyPawn.bIgnoresSenses);
		if(InterestPawn != None)
		{
			ActOnPawnLooks(InterestPawn, StateChange);
		}
	}

	///////////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////////
	function bool SayWhat()
	{
		if(Attacker == None)
		{
			PrintDialogue("What the...?");
			SayTime = Say(MyPawn.myDialog.lWhatThe);
			return true;
		}
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		if(MyNextState == 'None')
			PrintStateError("No my next state!");
		MyPawn.StopAcc();
	}
Begin:
	FocalPoint = DangerPos;

	if(Attacker == None)
	{
		// First face the interest vect. This should be set to whatever you want
		// them to stare at first.
		Focus = None;
		Sleep(FRand());
	}

	// Stare at our interest actor if we don't have a good pawn to look at
	if(InterestActor != None)
		Focus = InterestActor;
	else
		Focus = InterestPawn;

	// Drop things if you had them in your hands
	MyPawn.DropBoltons(MyPawn.Velocity);

	if(SayWhat())
	{
		Sleep(SayTime);
	}

	CheckInterest();

	GotoNextState();
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
	ignores HandleIntruder, TryToGreetPasserby;

	function BeginState()
	{
		PrintThisState();
		Focus = Attacker;
		MyPawn.StopAcc();
		MyPawn.SetMood(MOOD_Angry, 1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LookAroundForTrouble
// Just look around and see if there's anything odd (CheckObservePawnLooks will 
// do the work)--You *don't* have a specific attacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LookAroundForTrouble
{
	ignores CheckDeadBody, CheckDeadHead, WatchFunnyThing, InterestIsAnnoyingUs;

	///////////////////////////////////////////////////////////////////////////////
	// Check for idiots bumping into you
	///////////////////////////////////////////////////////////////////////////////
	event Bump( Actor Other )
	{
		local byte StateChange;

		if(FPSPawn(Other) != None)
			CheckForIntruder(FPSPawn(Other), StateChange);

		if(StateChange != 1)
			DangerPawnBump(Other, StateChange);
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop moving, to look around
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// stop and stand up
		MyPawn.StopAcc();
		MyPawn.ShouldCrouch(false);
		// Make him face forward
		Focus = None;
		FocalPoint = MyPawn.Location + 1024*vector(MyPawn.Rotation);
	}

Begin:
	Sleep(2.0 + MyPawn.Curiosity);
	LookInRandomDirection();
	Sleep(2.0 + MyPawn.Curiosity);
	LookInRandomDirection();

	// most likely, go back to thinking
	if(FRand() <= MyPawn.Curiosity/2)
		Goto('Begin');
	else
	{
		Sleep(2.0 + MyPawn.Curiosity);
		GotoState('Thinking');
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
	ignores RespondToTalker, ForceGetDown, PerformInterestAction, RatOutAttacker, MarkerIsHere, 
		CheckObservePawnLooks, RespondToQuestionNegatively, TryToGreetPasserby, RespondToCopBother, DecideToListen;

	///////////////////////////////////////////////////////////////////////////
	// I've been attacked by someone (again)
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		if ( (Other == None) || (Other == Pawn) || (Damage <= 0))
			return;

			// and not in a friend/in Gang AI
		if(!(SameGang(FPSPawn(Other))
				|| (FPSPawn(Other).bPlayer 
					&& MyPawn.bPlayerIsFriend)))
		{
			SetAttacker(FPSPawn(Other));
			GetAngryFromDamage(Damage);
			MakeMoreAlert();
			Say(MyPawn.myDialog.lGotHit);		// cry out

			// Manually start over (since we got attacked again while looking)
			BeginState();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Look around this actor and depending your attributes, see him quickly or not
	///////////////////////////////////////////////////////////////////////////////
	function FPSPawn VisuallyFindPawn(FPSPawn LookActor, vector CheckPos)
	{
		local FPSPawn CheckP;
		local bool bPlayerIsAttacker;

		InterestPawn2=None;
		if(Attacker != None
			&& Attacker.bPlayer)
			bPlayerIsAttacker=true;

		// check all the pawns around me.
		//log(self$" checking with "$CurrentFloat);
		//log(MyPawn$" check pos "$CheckPos);
		//log(MyPawn$" diff "$VSize(MyPawn.Location - CheckPos)$" diff to attacker "$VSize(LookActor.Location - MyPawn.Location));
		ForEach VisibleCollidingActors(class'FPSPawn', CheckP, CurrentFloat, CheckPos)
		{
			if(CheckP != MyPawn	// not me and we can see him
				&& FastTrace(MyPawn.Location, CheckP.Location)
				&& CheckP.Health > 0				// Still alive
				&& CheckP.Controller != None
				&& !FriendWithMe(CheckP)			// Not in my gang
				&& !DudeDressedAsCop(CheckP)			// Can't be the dude/cop!
				&& (!CheckP.bPlayer	// Either not the player, or was the player, and he attacked
					|| (CheckP.bPlayer // or i have a reason to hate him
					&& (!MyPawn.bPlayerIsFriend
					|| bPlayerIsAttacker))))
			{
				//log(MyPawn$"checkp "$CheckP);
				InterestPawn2 = CheckP;
				// Find attacker in the crowd. 
				// The closer the attacker is to the person, the more likely
				// they are to be instantly recogized.
				if(FRand() > UseAttribute	// how quickly i react
					&& FRand() > MyPawn.Psychic	// how psychic i am
					&& FRand() <= CurrentDist	// 0 to 1 or slightly greater. 1 is farthest away, so less likely to be spotted
					&& CheckP != Focus)
				{
					return CheckP;
				}
				else if(CheckP == LookActor)
				{
					return LookActor;
				}
			}
		}
		return InterestPawn2;
	}

	///////////////////////////////////////////////////////////////////////////////
	// See how many people are around you now (also checks people)
	///////////////////////////////////////////////////////////////////////////////
	function int NumberOfPeopleAround(vector Loc)
	{
		local FPSPawn CheckP;
		local int count;

		count=0;
		ForEach VisibleCollidingActors(class'FPSPawn', CheckP, CurrentFloat, Loc)
		{
			if(CheckP != MyPawn
				&& FastTrace(MyPawn.Location, CheckP.Location)
				&& CheckP.Health > 0				// still alive
				&& CheckP.Controller != None		// has a controller
				&& (P2Pawn(CheckP) == None
					|| (!P2Pawn(CheckP).bAuthorityFigure// Not a good guy
						&& !SameGang(CheckP)))			// not in my gang)
				&& !DudeDressedAsCop(CheckP)			// Can't be the dude/cop!
				&& !(MyPawn.bPlayerIsFriend
					&& CheckP.bPlayer))	// and not the player and you're friends with him
				count++;
		}

		//log("there were this many people around me when I looked "$count);

		return count;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Call out to those around you to point out the attacker
	///////////////////////////////////////////////////////////////////////////////
	function AskWhereAttackerIs(vector CheckPos)
	{
		local P2Pawn CheckP, RealRat, LyingRat;
		local float dist;

		// check all the pawns around me.
		ForEach VisibleCollidingActors(class'P2Pawn', CheckP, VISUALLY_FIND_RADIUS, CheckPos)
		{
			// Don't check me or the guy that attacked us
			// or dead people
			// And don't check people that are friends with the attacker
			if(CheckP != MyPawn && CheckP!=Attacker
				&& CheckP.Controller != None
				&& PersonController(CheckP.Controller) != None
				&& CheckP.Health > 0
				&& FastTrace(MyPawn.Location, CheckP.Location)
				&& !(PersonController(CheckP.Controller).SameGang(Attacker)
					|| (Attacker.bPlayer 
						&& CheckP.bPlayerIsFriend)))
			
			{
				// How much of a rat is this person?
				if(FRand() <= abs(CheckP.Rat))
				{
					// A good rat, but did they see what happened?
					if(PersonController(CheckP.Controller).CanSeePawn(CheckP, Attacker))
					{
						// Yes, they saw it
						// So he goes to see if he should report it.
						PersonController(CheckP.Controller).InterestPawn2=None;
						PersonController(CheckP.Controller).RatOutAttacker(P2Pawn(Attacker), MyPawn);
						if(CheckP.Rat > 0 && RealRat == None)
							RealRat = CheckP;
						else if(CheckP.Rat < 0 && LyingRat == None)
							LyingRat = CheckP;
						//return;
					}
				}
			}
		} // for all colliding actors

		// Let the lying rat (the one that likes you a lot) know that someone contradicted
		// him, so he can go harrass them.
		if(RealRat != None
			&& LyingRat != None)
		{
			PersonController(LyingRat.Controller).InterestPawn2 = RealRat;
		}
	}

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

		// If this person has a weapon out already, make him our current suspect
		// or if we were kicked
		usepawn = FPSPawn(Focus);
		if(P2Pawn(usepawn) != None
			&& usepawn.Weapon != None
			&& (P2Weapon(usepawn.Weapon).ViolenceRank > 0
				|| (MyPawn.LastDamageType == class'KickingDamage')))
			SetAttacker(usepawn);
		//else if(AnimalPawn(usepawn) != None)
		//	Attacker = usepawn;
	}

	///////////////////////////////////////////////////////////////////////////////
	// You're tired of looking
	///////////////////////////////////////////////////////////////////////////////
	function GiveUpLooking()
	{
		// Search around some because we couldn't find him
		SetAttacker(None);
		GotoStateSave('LookAroundForTrouble');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		// stop moving
		MyPawn.StopAcc();

		PrintThisState();

		SwitchToBestWeapon();

		if(Enemy == None 
			|| Enemy != Attacker)
		{
			UseAttribute = MyPawn.Reactivity;

			// Check first to see if you're straight in front of me
			// or if he melee attacked me (shovel, baton foot--these are close enough to
			// definitely know who it was anyway)
			if(Attacker != None
				&& (CanSee(Attacker) 
					|| (MyPawn.LastDamageType != None
						&& MyPawn.LastDamageType.default.bMeleeDamage)))
			{
				// I can see you so think about attacking
				GotoStateSave('AssessAttacker');
				return;
			}
			// Prep the check radius for the radiusactor searches
			CurrentDist = VSize(LastAttackerPos - MyPawn.Location)/VISUALLY_FIND_RADIUS;
			CurrentFloat = VISUALLY_FIND_RADIUS;
			// Before we leave, call out and ask for help. Ask for someone
			// if they saw it, to rat you out
			//PrintDialogue("Aaaaaaaaaahh! I'm hit!");
			SayTime = Say(MyPawn.myDialog.lAttacked);

			AskWhereAttackerIs(LastAttackerPos);

			// blank the count
			statecount=0;
		}
		else	// We're already attacking this guy and we know we hate him
			// so get him
		{
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
			return;
		}
	}

Begin:
	// Look for attacker
	PickOutAttacker(Attacker, LastAttackerPos);
	// Stare at the result a minute
	Sleep(1.0 - MyPawn.Reactivity);
	statecount++;
	// Check to see if correct
	if(Focus != Attacker
		|| Focus == None)
	{
		// You didn't find the attacker
		if(statecount >= MAX_RECOGIZE_TRIES
			|| Focus == None)
			GiveUpLooking();
		else
		{
			// Look again, wrong one
			// This time you're more likely to get it right
			UseAttribute = (UseAttribute + 1.0)/2;
			Goto('Begin');
		}
	}
	else // We're looking at the bad guy. See if he still looks suspicious
	{
		if(Attacker != None
			&& Attacker.Weapon != None
			&& (P2Weapon(Attacker.Weapon).ViolenceRank > 0
			|| NumberOfPeopleAround(Attacker.Location) == 1))
			// Found him so decide to attack
			GotoStateSave('AssessAttacker');
		else
			GiveUpLooking();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AssessAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AssessAttacker
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere,
		RespondToTalker, ForceGetDown, PerformInterestAction, RatOutAttacker, MarkerIsHere, 
		RespondToQuestionNegatively, CheckObservePawnLooks, RespondToCopBother, DecideToListen,
		PersonStoleSomething, BodyJuiceSquirtedOnMe, GettingDousedInGas, RocketIsAfterMe;

	///////////////////////////////////////////////////////////////////////////////
	// We want to shout to people to get down
	///////////////////////////////////////////////////////////////////////////////
	function bool SetupShoutGetDown()
	{
		local vector ShoutPos;

		ShoutPos = (SHOUT_GET_DOWN_RADIUS*Normal(Attacker.Location - MyPawn.Location)) + MyPawn.Location;	
		bSaidGetDown=true;
		return ShoutGetDown(ShoutPos);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Yell things before we attack
	///////////////////////////////////////////////////////////////////////////////
	function YellBeforeAttack()
	{
		if(FRand() <= MyPawn.TalkBeforeFighting)
		{
			SayTime = Say(MyPawn.myDialog.lDecideToFight, bImportantDialog);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Say we definitely want to fight him
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// stop moving
		MyPawn.StopAcc();

		// Clear that I said this
		bSaidGetDown=false;
		SetNextState('ShootAtAttacker');
		SwitchToBestWeapon();
		Focus = Attacker;
		if(Attacker != None)
		{
			if(Attacker.bPlayer)
				bImportantDialog = true;
			else
				bImportantDialog = false;
		}
	}
Begin:
	YellBeforeAttack();
	Sleep(0.0);//SayTime);

	if(Attacker == None
		|| Attacker.bDeleteMe
		|| Attacker.Health <= 0)
	{
		SetAttacker(None);
		GotoStateSave('LookAroundForTrouble');
	}

	if(!bSaidGetDown 
		&& FRand() <= MyPawn.WarnPeople)
	{
		//if(FRand() > MyPawn.Anger)
		//{
			if(SetupShoutGetDown())
			// wait for them to get down
				Sleep(SayTime + MyPawn.Patience);
		//}
		//else
		//	log("i wanted to yell GET DOWN but was too angry");
	}
	GotoStateSave('ShootAtAttacker');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LineUpShot
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LineUpShot
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, 
		RespondToTalker, ForceGetDown, PerformInterestAction, RatOutAttacker, damageAttitudeTo, 
		MarkerIsHere, RespondToQuestionNegatively, CheckObservePawnLooks, RocketIsAfterMe,
		RespondToCopBother, DecideToListen, PersonStoleSomething, BodyJuiceSquirtedOnMe, GettingDousedInGas;

	///////////////////////////////////////////////////////////////////////////////
	// Make sure we're aimed at our attacker
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		Focus = Attacker;
		if(Focus == None)
		{
			PrintStateError(" attacker== none");
			GotoStateSave('Thinking');
			return;
		}
		SetNextState('ShootAtAttacker');
	}
Begin:
	Sleep(MyPawn.Twitch/4);
	GotoStateSave('ShootAtAttacker');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AttackedWhileAttacking
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AttackedWhileAttacking
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, 
		RespondToTalker, ForceGetDown, PerformInterestAction, RatOutAttacker, damageAttitudeTo, 
		MarkerIsHere, RespondToQuestionNegatively, CheckObservePawnLooks, RocketIsAfterMe,
		RespondToCopBother, DecideToListen, PersonStoleSomething, BodyJuiceSquirtedOnMe, GettingDousedInGas;

	///////////////////////////////////////////////////////////////////////////////
	// Set up another version of reactivity based on health
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		UseAttribute = MyPawn.Health/MyPawn.HealthMax;
	}

Begin:
	if(FRand() > MyPawn.Reactivity
		|| FRand() > UseAttribute)
	// Second on-the-fly reactivity is based on health. As he's closer to death, he's
	// less reactive/easier to kill
	{
		// Be slightly stunned
		Sleep(1.0-MyPawn.Reactivity);
	}
	else
		Sleep(0.0);
	GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitToAttack
// Hiding in cover for a good time to attack.
// Needs UseAttribute set first for it.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitToAttack
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, 
		RespondToTalker, ForceGetDown, PerformInterestAction, RatOutAttacker, MarkerIsHere, 
		RespondToQuestionNegatively, CheckObservePawnLooks, RocketIsAfterMe,
		RespondToCopBother, DecideToListen, PersonStoleSomething;

	///////////////////////////////////////////////////////////////////////////
	// When attacked while you're attacking
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		if ( (Other == None) || (Other == Pawn) || (Damage <= 0))
			return;

		// If it's by a friend, then try to move
		if(SameGang(FPSPawn(Other))
			|| (FPSPawn(Other).bPlayer 
				&& MyPawn.bPlayerIsFriend))
		{
			PerformStrategicMoves(true);
			return;
		}
		else if(MyPawn.MyBodyFire != None
			&& MyPawn.LastDamageType == class'OnFireDamage')
		{
			return;
		}
		else
		{
			// randomly pause from the attack
			GotoStateSave('AttackedWhileAttacking');
			return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Since we can't focus on the attacker (we can't see him.. he's behind a wall
	// as we hide--and we don't want to cheat and magically watch him) we'll look
	// around shakily, in a small area around our original focal point. This helps us
	// if the attacker tries to sneak up on us in our hiding place.
	///////////////////////////////////////////////////////////////////////////////
	function SmallLookAround()
	{
		FocalPoint = LastAttackerPos + SAFE_POINT_MIN_DIST*VRand();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Using an extended viewcone, check for your attacker around you
	// (this view cone is 180 of your forward view)
	// Also, check to hear the attacker, if he's running.
	///////////////////////////////////////////////////////////////////////////////
	function bool CheckToSenseAttacker()
	{
		// True means there is a direct line of sight from me to the pawn.. so either
		// decide to magically see him if he's anywhere in front of you, or 'hear' him
		// behind you. But only hear/see him if he's not hidden. If he's hidden, that's
		// fine--what we want, because we're hiding from him, getting ready to jump out
		// and attack again. This is just to make sure he hasn't snuck up on us in 
		// our hiding place.
		if(CanSeeAnyPart(Attacker, MyPawn))
		{
			// See if he's within your forward 180 view
			if((Normal(Attacker.Location - MyPawn.Location) Dot vector(MyPawn.Rotation))
				> 0)
				return true;
			else	// Didn't see him, so see if he's anywhere behind you, running around.
				// This let's him sneak up on you if he walks
			{
				if(Attacker.MakingMovingNoises())
				{
					if(VSize(MyPawn.Location - Attacker.Location) < CAN_HEAR_RANGE)
					{
						return true;
					}
				}
			}
		}

		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	//
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// Don't make him magically stare at our attacker.. stare at where he last knew he was
		FocalPoint = LastAttackerPos;
		Focus = None;
		// UseAttribute is our timer to determine when to leave. If we see the 
		// dude before that, we'll leave early

		// If this point is valid only when he crouches, then make him crouch
		if(SafePointStatus == SAFE_POINT_CROUCH)
			MyPawn.ShouldCrouch(true);
	}
Begin:
	// If we see him early, then attack
	// otherwise, wait around till spring out again
	if(CheckToSenseAttacker())
		GotoStateSave('ShootAtAttacker', 'WaitTillFacing');

	Sleep(MyPawn.Patience + 0.1);
	
	UseAttribute = UseAttribute - 1;

	if(UseAttribute <= 0)
	{
		// Turrets just attack again
		if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
		{
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
		}
		else // Others run to the attacker
		{
			// Think about saying something cocky when we take off
			// after the attacker again
			if(FRand() <= MyPawn.TalkWhileFighting)
			{
				Say(MyPawn.myDialog.lDoHeroics);
				PrintDialogue("You're going down!");
			}

			// Interest vect 2 here, is where we last were
			SetEndPoint(InterestVect2, TIGHT_END_RADIUS);
			SetNextState('ShootAtAttacker', 'LookForAttacker');
			bStraightPath=UseStraightPath();
			bDontSetFocus=true;
			GotoStateSave('RunToAttacker');
		}
	}
	else
	{
		if(Frand() < MyPawn.WillUseCover)
			SmallLookAround();

		Goto('Begin');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LookingForAttacker
// Wander around where you last saw him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LookingForAttacker
{
	ignores RespondToTalker, PerformInterestAction, ForceGetDown, RatOutAttacker, RocketIsAfterMe,
		PersonStoleSomething, CheckDeadBody, CheckDeadHead, CheckDesiredThing, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// See if we can see or hear the attacker
	///////////////////////////////////////////////////////////////////////////////
	function DetectAttackerSomehow(FPSPawn CheckPawn, optional name RunState)
	{
		local byte LostHim, StateChange;

		DetectAttacker(CheckPawn, StateChange, LostHim, ,RunState);
		if(LostHim == 0
			&& StateChange == 0)
			FoundHim(InterestPawn);
	}

	///////////////////////////////////////////////////////////////////////////////
	// If we can't hear him now, think about quitting
	///////////////////////////////////////////////////////////////////////////////
	function DetectAttackerOrQuit(FPSPawn CheckPawn, optional name RunState)
	{
		local byte LostHim, StateChange;

		DetectAttacker(CheckPawn, StateChange, LostHim, true, RunState);

		if(LostHim == 1)
		{
			if(MyPawn.Champ > FRand())
			{
				GotoStateSave('Thinking');
			}
		}
		else if(StateChange == 0)
			FoundHim(InterestPawn);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Pick the next point to run to
	///////////////////////////////////////////////////////////////////////////////
	function PickNextDestination()
	{
		local vector checkpos, endpos;
		local Actor HitActor;
		local vector HitLocation, HitNormal;
		local NavigationPoint pnode;
		local byte StateChange;
		local int i;

		// See if the area in the direction of our attacker is a valid area
		// to run to
		endpos = LastAttackerPos + LastAttackerDir*ATTACKER_CHECK_RANGE;
		checkpos = endpos - 2*LastAttackerDir*MyPawn.CollisionRadius;

		if(FastTrace(checkpos, endpos))
		{
			SetEndPoint(checkpos, DEFAULT_END_RADIUS);
			bStraightPath=UseStraightPath();
			SetNextState('LookingForAttacker', 'DetectOrQuit');
			GotoStateSave('WalkToTargetFindAttacker');
			StateChange=1;
		}
		else if(MyPawn.Anchor != None)
		{
			// Pick a random point out of this points nearby points.
			i = Rand(MyPawn.Anchor.PathList.Length);
			if(MyPawn.Anchor.PathList.Length > 0)
				pnode = MyPawn.Anchor.PathList[i].end;

			// Couldn't find one, so check the ordered points
			if(pnode == None)
			{
				if(MyPawn.Anchor.nextOrdered == None)
					pnode = MyPawn.Anchor.prevOrdered; // choose the other
				else if(MyPawn.Anchor.prevOrdered == None)
					pnode = MyPawn.Anchor.nextOrdered; // choose the other
				else // choose either one
				{
					if(FRand() <= 0.5)
						pnode = MyPawn.Anchor.prevOrdered;
					else
						pnode = MyPawn.Anchor.nextOrdered;
				}
			}

			// Make sure we grabbed one before change states.
			if(pnode != None
				&& MyPawn.Anchor != pnode)
			{
				Focus = pnode;
				SetEndGoal(pnode, DEFAULT_END_RADIUS);
				bStraightPath=UseStraightPath();
				SetNextState('LookingForAttacker', 'DetectOrQuit');
				GotoStateSave('WalkToTargetFindAttacker');
				StateChange=1;
			}
		}

		if(StateChange == 0) 
		// no path nodes, so figure out our new look pos for ourself
		{

			checkpos.x = 2*FRand() - 1.0;
			checkpos.y = 2*FRand() - 1.0;
			checkpos.z = 0.0;
			checkpos = Normal(checkpos);

			checkpos = VISUALLY_FIND_RADIUS*checkpos + MyPawn.Location;
				//LastAttackerPos;

			// Check for things in the way of our new running direction
			HitActor = Trace(HitLocation, HitNormal, checkpos, MyPawn.Location, false);

			if(HitActor != None)
			{
				MovePointFromWall(HitLocation, HitNormal, MyPawn);
				checkpos = HitLocation;
			}

			Focus = None;
			SetEndPoint(checkpos, DEFAULT_END_RADIUS);
			bStraightPath=UseStraightPath();
			SetNextState('LookingForAttacker', 'DetectOrQuit');
			GotoStateSave('WalkToTargetFindAttacker');
			StateChange = 1;
		}
	}

	function BeginState()
	{
		PrintThisState();
		// stop moving
		MyPawn.StopAcc();
		// Look where he was first
		Focus = None;
		FocalPoint = LastAttackerPos;
		if(Attacker != None)
		{
			InterestPawn = Attacker;
			SetAttacker(None);
		}
	}

DetectOrQuit:
	Sleep(0.5);
	DetectAttackerOrQuit(InterestPawn);

Begin:
	Sleep(0.5);
	// Now look around wildly
	LookInRandomDirection();
	Sleep(0.5);
	LookInRandomDirection();
	Sleep(0.5);
	DetectAttackerSomehow(InterestPawn);
	// Now walk somewhere if we didn't find him
	PickNextDestination();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootAtAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAtAttacker
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, 
		RespondToTalker, RatOutAttacker, PerformInterestAction, MarkerIsHere, 
		RespondToQuestionNegatively, RocketIsAfterMe,
		RespondToCopBother, DecideToListen, GettingDousedInGas, PersonStoleSomething;

	///////////////////////////////////////////////////////////////////////////////
	// See if we can see or hear the attacker
	///////////////////////////////////////////////////////////////////////////////
	function DetectAttackerSomehow(FPSPawn CheckPawn, optional name RunState)
	{
		local byte LostHim;

		// Only allow detection/catch up if you're not a turret
		if(MyPawn.PawnInitialState != MyPawn.EPawnInitialState.EP_Turret)
		{
			DetectAttacker(Attacker, , LostHim, , RunState);

			if(LostHim == 1)
				GotoStateSave('LookingForAttacker');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check out attacker just before you shoot--you may want to hold your fire
	// But generally just get your gun ready
	///////////////////////////////////////////////////////////////////////////////
	function EvaluateAttacker()
	{
		SwitchToBestWeapon();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if it's our attacker
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		local vector StartLoc;

		if(LookAtMe == Attacker)
		{
			StartLoc = MyPawn.Location;
			StartLoc.z += MyPawn.EyeHeight;
			// Check first to make sure nothing is in the way
			if(FastTrace(StartLoc, LookAtMe.Location))
				ActOnPawnLooks(LookAtMe);
			else // Stare at where they last were
			{
				UseAttribute=FRand() + 1.0;	// wait a second or two before attacking again
					// or reevaluating your attacker and you're position
				InterestVect2 = LastAttackerPos;
				GotoStateSave('WaitToAttack');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// We see our attacker, check his weapons
	///////////////////////////////////////////////////////////////////////////////
	function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
	{
		local vector dir, checkpoint;
		local float DistToAttacker, ViolenceRank;

		if(LookAtMe != Attacker
			// We don't move based on weapons if we're a turret
			|| MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
			return;

		if(Attacker.Weapon != None)
			ViolenceRank = P2Weapon(Attacker.Weapon).GetViolenceRatio();
		// Check and see if your attacker has some giant weapon. The more
		// dangerous, the more likely we're are to obey the distance we're
		// supposed to stay away from this thing.
		if(ViolenceRank > 0
			&& FRand() < ViolenceRank)
		{
			dir = LastAttackerPos - Pawn.Location;
			DistToAttacker = VSize(dir);

			// This is only if the attacker got way too close to us
			if(DistToAttacker < P2Weapon(Attacker.Weapon).MinRange)
			{
				// Check to cuss about how dangerous this is, if the thing he has is
				// really dangerous, and we're really close
				if(Frand() > (DistToAttacker/P2Weapon(Attacker.Weapon).MinRange)
					&& FRand() < ViolenceRank)
				{
					Say(MyPawn.myDialog.lCloseToWeapon);
					PrintDialogue("Crap that's a big gun that's too close!");
				}

				// Calc a point straight back, to the min distance to stand
				// with this weapon
				checkpoint = MyPawn.Location - P2Weapon(Attacker.Weapon).MinRange*Normal(dir);
				GetMovePointOrHugWalls(checkpoint, MyPawn.Location, UseSafeRangeMin, true);
				SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
				SetNextState('ShootAtAttacker', 'FaceHimBeforeLook');
				bStraightPath=UseStraightPath();
				MyPawn.SetMood(MOOD_Normal, 1.0);	// run with your arms down
				GotoStateSave('RunToTargetIgnoreAll');
				StateChange=1;
				return;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// Run to safe point, you better have one first, though
	///////////////////////////////////////////////////////////////////////////
	function RunToSafePoint(float WaitTime)
	{
		SetEndPoint(SafePoint, DEFAULT_END_RADIUS);
		bDontSetFocus=true;
		bStraightPath=UseStraightPath();
		UseAttribute=WaitTime;
		SetNextState('WaitToAttack');
		GotoStateSave('RunToTargetIgnoreAll');
	}

	///////////////////////////////////////////////////////////////////////////
	// Check to do any kind of strategic move, dodge, crouch, move back/forward
	// or decide to take cover
	///////////////////////////////////////////////////////////////////////////
	function CheckToMoveAround()
	{
		local bool bForce;
		local byte StateChange;

		// Move around all cool-like
		PerformStrategicMoves(bForce,,StateChange);

		// If you didn't crouch or side-step, then think about running to your
		// cover point
		if(StateChange == 0)
		{
			if(SafePointStatus != SAFE_POINT_INVALID && FRand() <= MyPawn.WillUseCover)
				RunToSafePoint(Rand(DUCK_WAIT_TIME));
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked while you're attacking
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		local byte StateChange;

		if ( (Other == None) || (Other == Pawn) || (Damage <= 0))
			return;

		// If it's by a friend, then try to move
		if(SameGang(FPSPawn(Other))
			|| (FPSPawn(Other).bPlayer 
				&& MyPawn.bPlayerIsFriend))
		{
			PerformStrategicMoves(true);
			return;
		}
		else if(MyPawn.MyBodyFire != None
			&& MyPawn.LastDamageType == class'OnFireDamage')
		{
			return;
		}
		else
		{
			SetAttacker(FPSPawn(Other));
			GetAngryFromDamage(Damage);
			MakeMoreAlert();
			Say(MyPawn.myDialog.lGotHit);		// cry out

			// If we're a turret, check to do something strategic when you get shot
			if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
			{
				PerformStrategicMoves();
				if(Attacker != Enemy)
				{
					Enemy = Attacker;
					GotoState('ShootAtAttacker', 'WaitTillFacing');
					return;
				}
			}
			else // options for non-turrets (normal people)
			{
				// Check if we think our safe point is valid, then make sure we weren't standing there
				// when we got hit--if so he's found just the right angle to hit us in our safe point
				// so invalidate it
				if(SafePointStatus != SAFE_POINT_INVALID)
				{
					if(VSize(MyPawn.Location - SafePoint) < 1.0)
					{
						//log(MyPawn$" shot in my safe place, INVALID safe point ");
						SafePointStatus=SAFE_POINT_INVALID;
						CurrentDist = VSize(Attacker.Location - MyPawn.Location);
						if(CurrentDist < SAFE_POINT_MIN_DIST)
							CurrentDist=SAFE_POINT_MIN_DIST;
						statecount=SAFE_POINT_ANGLE_MAX;
						InterestVect = Attacker.Location;
					}
				}

				// If you have a safe point, then be more likely to use it 
				// the closer to death you are.
				if(SafePointStatus != SAFE_POINT_INVALID 
					&& MyPawn.WillUseCover > 0)
				{
					RunToSafePoint(Rand(HIDING_WAIT_TIME));
				}
				else if(MyPawn.Health < (1.0-MyPawn.PainThreshold)*MyPawn.HealthMax)
				// Check to see if you've been hurt past your pain threshold, and then run away
				{
					InterestPawn = Attacker;
					MakeMoreAlert();
					DangerPos = InterestPawn.Location;
					GotoStateSave('FleeFromAttacker');
				}
				else
				{
					// Check to do a side step dodge
					if(FRand() <= MyPawn.WillDodge)
					{
						// Find a point to your sides, to side-step to
						StrategicSideStep(StateChange);
					}
					// If you didn't move, then randomly pause from the attack
					if(StateChange == 0)
						GotoStateSave('AttackedWhileAttacking');
					else
						return;
				}
			}

			return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Try to run to one side of the person, to get a better shot
	///////////////////////////////////////////////////////////////////////////////
	function HandleHumanObstacle(FPSPawn ObstructingPawn)
	{
		local vector usepoint;
		local byte StateChange;
		if(PersonController(ObstructingPawn.Controller) != None)
			PersonController(ObstructingPawn.Controller).GetOutOfMyWay(MyPawn, P2Pawn(Attacker), StateChange);

		if(StateChange==1)
			return;

		GetSideOfHumanObstacle(ObstructingPawn, Attacker, usepoint);

		SetEndPoint(usepoint, DEFAULT_END_RADIUS);
		SetNextState('LineUpShot');
		bStraightPath=false;//UseStraightPath();
		GotoStateSave('RunToTargetIgnoreAll');

		// Yell at the pawn for being in the way. They'll react and they may crouch,
		// run, get pissed, or start shaking from being too scared.
		// If it's a friend, don't yell as often.
		if(!FriendWithMe(ObstructingPawn)
			|| FRand() < 0.3)
		{
			PrintDialogue("Get out of the way, I'm going to attack! ");
			if(!MyPawn.Weapon.bMeleeWeapon)
				SayTime = Say(MyPawn.myDialog.lCleanShot);
			else
				SayTime = Say(MyPawn.myDialog.lCleanMeleeHit);
		}
	}
/*
	///////////////////////////////////////////////////////////////////////////////
	// Finish pointing yelling at someone
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			log(self$" animend "$channel);
			MyPawn.ChangeAnimation();
		}
	}
*/
	///////////////////////////////////////////////////////////////////////////////
	// See if there's someone in the way, if so handle it
	// If we're normal, we'll probably run around the obstacle and try to catch
	// up to the player. If not, we'll make sure we can shoot at the player.
	// If we can't we'll probably go back to just hanging around, or waiting to shoot.
	///////////////////////////////////////////////////////////////////////////////
	function CheckForObstacle(optional out byte StateChange)
	{
		local Actor HitActor;
		local P2Pawn HitPawn;
		local vector HitLocation, HitNormal;
		local vector mytop, histop;

		// If we're a turret, then just make sure we can see him from our
		// once we start 
		if(MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_Turret)
		{
			mytop = MyPawn.Location + MyPawn.EyePosition();
			histop = Attacker.Location + Attacker.EyePosition();
			// Something in the way, so wait some more
			if(!FastTrace(mytop,histop))
				GotoState('ShootAtAttacker', 'TurretWait');
		}
		else	//Normal, able to run around
		{

			HitActor = Trace(HitLocation, HitNormal, Attacker.Location, MyPawn.Location, true);

			if(HitActor != None)
			// Something was in the way
			{

				HitPawn = P2Pawn(HitActor);
				// If we hit a person, see about running next to him
				// as long as beyond this guy, is our attacker (if it's a wall, run to the attacker)
				if(FPSPawn(HitActor) != None
					&& FastTrace(MyPawn.Location, Attacker.Location))
				{
					// If it's our target, then leave now, because we want to shoot him
					// or if he's dead already shoot through him
					if(HitActor == Attacker
						|| FPSPawn(HitActor).Health <= 0)
						return;

					// If there's someone in the way (other than the person you're trying to kill)
					// then do something about it
					// Or if it's a buddy of yours, then don't intentionally hit them
					if(HitPawn != None
						&& (FRand() <= MyPawn.Compassion
						|| HitPawn.bAuthorityFigure
						|| SameGang(HitPawn)))
					// This means we don't want to kill innocents, so try to move them
					{
						HandleHumanObstacle(HitPawn);
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
					if(SafePointStatus != SAFE_POINT_INVALID && (FRand() <= (MyPawn.WillUseCover*0.5)))
					{
						RunToSafePoint(Rand(HIDING_WAIT_TIME));
					}
					else // if not ducking and waiting, follow him immediately
					{
						//log(MyPawn$" this was in my way! "$HitActor);
						SetEndPoint(LastAttackerPos, MyPawn.AttackRange.Min);
						// and reduce our attack range, so he'll try for closer next time
						SetAttackRange(MyPawn.AttackRange.Min*0.95);
						SetNextState('ShootAtAttacker', 'LookForAttacker');
						bStraightPath=UseStraightPath();
						GotoStateSave('RunToAttacker');
						return;
					}
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Look at our current hiding point and make sure it's still good
	///////////////////////////////////////////////////////////////////////////////
	function bool CheckForValidSafePoint(bool bStartUp)
	{
		local bool bResetChecks;
		local vector mytop, histop;

		// See if the point is still valid, check if it's still hidden from the dude's
		// sight, and if you're on startup, check to make sure you're pretty close to your
		// hidden point still.. if not, make it invalid
		if(SafePointStatus != SAFE_POINT_INVALID)
		{
			// If you're supposed to crouch here, but he can see you if you crouch here, then it's invalid
			if(SafePointStatus == SAFE_POINT_CROUCH)
			{
				mytop = SafePoint;
				mytop.z = SafePoint.z + MyPawn.CrouchHeight;
				histop = Attacker.Location;
				histop.z = histop.z + Attacker.CollisionHeight;
				// If no hit, then it's not valid any more, because now test in this version from the
				// safe point, at the height of the crouched pawn.. so if you can see the dude now, then it's
				// invalid
				if(FastTrace(mytop,histop))
				{
					//log(MyPawn$" crouch point now invalid");
					bResetChecks=true;
				}
			}

			if(!bResetChecks)
			{
				//log(MyPawn$" start up "$bStartUp);
				//log(MyPawn$" my dist "$VSize(MyPawn.Location - InterestVect2)$" required "$2*CurrentDist);
				//log(MyPawn$" is blocked spot "$IsBlockedSpot(Attacker.Location, SafePoint, MyPawn.CollisionRadius, false));
				if((!bStartUp
						|| VSize(MyPawn.Location - InterestVect2) < 2*CurrentDist)
					&& IsBlockedSpot(Attacker.Location, SafePoint, MyPawn.CollisionRadius, false))
				{
					//log(MyPawn$" safe points still valid");
					return true; // still valid so leave
				}
				else
					bResetChecks=true;
			}
		}
		else
			bResetChecks=true;

		// If something failed, then reset the checks
		if(bResetChecks)
		{
			//log(MyPawn$" SAFE POINTS are now INVALID, starting over");
			SafePointStatus=SAFE_POINT_INVALID;
			CurrentDist = VSize(Attacker.Location - MyPawn.Location);
			if(CurrentDist < SAFE_POINT_MIN_DIST)
				CurrentDist=SAFE_POINT_MIN_DIST;
			// On non-start up, if this is called always update the statecount,
			// if on start up though, then check to make sure he hasn't moved too much.
			if(!bStartUp
				|| VSize(Attacker.Location - InterestVect) > ATTACKER_FUZZ)
				statecount=SAFE_POINT_ANGLE_MAX;
			// If we didn't already reset out statecount, check for a bad one now and reset it
			else if(statecount >= 0
					&& statecount <= 1)
				statecount=SAFE_POINT_ANGLE_MAX;

			InterestVect = Attacker.Location;
		}
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Look around your environment, one line test at a time and look for 
	// possible points to hide in bad situations.
	///////////////////////////////////////////////////////////////////////////////
	function LookForSafePoints()
	{
		local Actor HitActor;
		local vector HitLocation, HitNormal;
		local vector startdir, checkdir, usevect, checkpoint, mytop, histop;
		local float interp, interprest, flipdir;
		local bool bBlockedWay;
		local byte StateChange;

		if(MyPawn.WillUseCover == 0)
			return;

		CheckForDeadAttacker(StateChange);
		if(StateChange == 1)
			return;

		// Check to reset, if the guy has moved too much
		if(VSize(Attacker.Location - InterestVect) > ATTACKER_FUZZ)
		{
			// If we can't see the attacker, then don't update the other stuff, just
			// figure out how to see him again
			if(!FastTrace(MyPawn.Location, Attacker.Location))
			{
				CheckForObstacle(StateChange);
				if(StateChange == 1)
					return;
			}

			// Update the attacker position
			SaveAttackerData();
			// We still have a clean line of sight, so update our data on him and
			// see if we need to start re-evaluating our safe points
			if(CheckForValidSafePoint(false))
				return;
		}

		// We've found a point, so leave early
		if(SafePointStatus != SAFE_POINT_INVALID)
			return;	// our point is valid, so don't check again

		startdir = vector(MyPawn.Rotation);
		//log(MyPawn$" START COUNT "$statecount$"--------------------------");
		flipdir = statecount/abs(statecount);
		interp = abs(statecount)/SAFE_POINT_ANGLE_MAX;
		interprest = 1.0 - interp;

		checkdir.x = -flipdir*startdir.y;
		checkdir.y = flipdir*startdir.x;
		checkdir.z = startdir.z;
		//log("initial check "$checkdir);

		// Startdir is directly in front of MyPawn. Checkdir is to be left and right,
		// that is, 90 off startdir. We interpolate between these two fanning outwards. 
		usevect = interp*checkdir + interprest*startdir;	
		//log("use dir "$usevect);
		checkpoint = CurrentDist*usevect + MyPawn.Location;

		HitActor = Trace(HitLocation, HitNormal, checkpoint, MyPawn.Location, false);

		if(HitActor != None)
		{
			// Move it away from the wall.
			MovePointFromWall(HitLocation, HitNormal, MyPawn);
			checkpoint = HitLocation;
			bBlockedWay=true;
		}
		else
		{
			// Because we picked one that didn't hit a wall, this could be floating out in space
			// behind a column (good) or right next to a wall, which means IsBlockedSpot will
			// incorrectly fail (it assumes the point is at least CollisionRadius from the wall).
			// So first make sure the way is NOT clear, that is, blocked by something. If not
			// don't use this one.
			bBlockedWay = !FastTrace(Attacker.Location, checkpoint);
		}

		// Check to see if you *can't* see the attacker, so this means
		// you can hide here. 
		// Even check when you didn't hit anything directly, because it could pass a good
		// ways behind something because of the potentially small distance we're checking.
		if(bBlockedWay
			&& IsBlockedSpot(Attacker.Location, checkpoint, MyPawn.CollisionRadius, false))
		{
			// It hit something, so use it.
			SafePoint = checkpoint;
			//log(MyPawn$" PICKING THIS ONE -- "$SafePoint$" statecount, soon to be 0, "$statecount);
			// Say this one is valid, but check first if we can see the dude from there,
			// at top of head height from the safe point to the dude. 
			// If so, then make it a stand point, if not, them make it a crouch point
			mytop = SafePoint;
			mytop.z = SafePoint.z + MyPawn.CollisionHeight;
			histop = Attacker.Location;
			histop.z = histop.z + Attacker.CollisionHeight;
			// If no hit, then make it a crouch point
			if(FastTrace(mytop,histop))
				SafePointStatus=SAFE_POINT_CROUCH;
			else
				SafePointStatus=SAFE_POINT_STAND;
			//log(MyPawn$" testing from "$mytop$" to his "$histop$" safe point status is "$SafePointStatus);

			statecount = 0;	
			// Save where we last were
			InterestVect2 = MyPawn.Location;
			return;
		}

		statecount=-statecount;
		// Don't use the abs version of statecount. We're using the negative to represent
		// the flip side
		if(statecount >= 0
			&& statecount <= 1)
			statecount=SAFE_POINT_ANGLE_MAX;
		else if(statecount > 0)
		{
			// update the position/location
			//CurrentDist = VSize(Attacker.Location - MyPawn.Location);
			statecount--;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// What to do once you've picked a sidestep place
	///////////////////////////////////////////////////////////////////////////////
	function AfterStrategicSideStep(vector checkpoint)
	{
		// Now move to it and get ready to shoot again when you get there
		//log("side stepping");
		bDontSetFocus=true;
		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
		SetNextState('ShootAtAttacker', 'WaitTillFacing');
		bStraightPath=UseStraightPath();
		GotoStateSave('RunToAttacker');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Decide what to do now that someone is dead
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		local byte StateChange;

		if(PlayerAttackedMe != None
			&& PlayerAttackedMe.Health > 0)
			GoAfterPlayerAgain(StateChange);
		// If we didn't do anything, then look important
		if(StateChange == 0)
		{
			FullClearAttacker();
			GotoStateSave('LookAroundForTrouble');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make sure you're target isn't dead
	///////////////////////////////////////////////////////////////////////////////
	function CheckForDeadAttacker(optional out byte StateChange)
	{
		if(Attacker == None || Attacker.Health <= 0)
		{
			if(Focus != None)
				FocalPoint = Attacker.Location;
			else
				FocalPoint = (MyPawn.Location + MyPawn.CollisionRadius*vector(MyPawn.Rotation));
			SetAttacker(None);
			Enemy = None;

			DecideNextState();
			StateChange = 1;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Say various things during a fight
	///////////////////////////////////////////////////////////////////////////////
	function FightTalk()
	{
		if(FRand() <= MyPawn.TalkWhileFighting)
		{
			Say(MyPawn.myDialog.lWhileFighting, bImportantDialog);
			SayTime=0;	// Don't wait here, in either case
			PrintDialogue("Fight like a man!");
		}
		else
			SayTime=0;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make sure you have a real weapon, or your weapon ready before you start
	// trying to shoot. If you have a melee weapon and they are deathcrawling,
	// then change to kicking him.
	///////////////////////////////////////////////////////////////////////////////
	function CheckWeaponReady(optional out byte StateChange)
	{
		local P2Weapon p2weap;

		p2weap = P2Weapon(MyPawn.Weapon);

		// You don't have a real weapon
		if(!MyPawn.bHasViolentWeapon
			|| p2weap == None)
		{
			PrintStateError(" I came here without a violent weapon! "$MyPawn.Weapon$" came from old state "$MyOldState);
			StateChange=1;
			GotoStateSave('KickAttacker');
		}
		// He's too low to hit, so start kicking him
		else if(p2weap.bMeleeWeapon
			&& Attacker != None
			&& Attacker.bIsDeathCrawling)
		{
			StateChange=1;
			GotoStateSave('KickAttacker');
		}
		// You're weapon's not ready
		else if(p2weap.ViolenceRank == 0
			|| !p2weap.IsIdle())
		{
			StateChange=1;
			GotoStateSave('ShootAtAttacker','WaitForWeapon');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Say we definitely want to fight him
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local P2Weapon p2weap;

		PrintThisState();

		// Look straight for an attack
		MyPawn.PlayTurnHeadStraightAnim(0.2);

		// stop moving
		MyPawn.StopAcc();

		// Turn off screams, when you're attacking
		ScreamState=SCREAM_STATE_NONE;

		// disable this, in case he could do it at some point
		MyPawn.bCanPickupInventory=false;

		// Prep based on attacker
		if(Attacker != None)
		{
			Enemy = Attacker;
			SetNextState(GetStateName(), 'WaitTillFacing');
		}
		else
		{
			FullClearAttacker();
			GotoStateSave('LookAroundForTrouble');
			return;
		}

		// Check to reset our cover finder
		if(MyPawn.WillUseCover > 0)
			CheckForValidSafePoint(true);

		// How long we wait in between bursts, divided by a factor of how many
		// times we look for hiding spots
		WorkFloat = (MyPawn.GetTwitch())/TWITCH_DIVIDER;

		SayTime = 0;

		if(Attacker.bPlayer)
			bImportantDialog = true;
		else
		{
			bImportantDialog = false;
		}
	}

	function EndState()
	{
		Super.EndState();
		StopFiring();
	}

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
	if(MyPawn.Weapon.CanAttack(Attacker))
	{
		FireWeaponAt(Enemy);
		StopFiring();
		firecount--;
		if(firecount > 0)
		{
			Sleep(P2Weapon(MyPawn.Weapon).AI_BurstTime);
			CurrentFloat += P2Weapon(MyPawn.Weapon).AI_BurstTime;
			// If we've waited enough, then check for a safe point while shooting
			if(CurrentFloat >= BURST_TIME_SAFEPOINT_CHECK)
			{
				LookForSafePoints();
				CurrentFloat-=BURST_TIME_SAFEPOINT_CHECK;
			}
			Goto('FireNow');
		}
		// After the entire burst of shots, wait our twitch time, checking for safe
		// points all the way.
		LookForSafePoints();
		Sleep(WorkFloat);
		LookForSafePoints();
		Sleep(WorkFloat);
		LookForSafePoints();
		Sleep(WorkFloat);
		LookForSafePoints();
	}

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
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootAtAttackerDistance
// Just like the above version, but we do this when we can't get any closer
// to the attacker, at least for a little while. 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAtAttackerDistance extends ShootAtAttacker
{
	ignores PerformStrategicMoves;

	///////////////////////////////////////////////////////////////////////////////
	// Stub these out
	///////////////////////////////////////////////////////////////////////////////
	function LookForSafePoints()
	{
	}
	function bool CheckForValidSafePoint(bool bStartUp)
	{
		return false;
	}
	function RunToSafePoint(float WaitTime)
	{
	}
	function CheckWeaponReady(optional out byte StateChange)
	{
	}
	function CheckForObstacle(optional out byte StateChange)
	{
	}

	///////////////////////////////////////////////////////////////////////////////
	// Say various things during a fight
	///////////////////////////////////////////////////////////////////////////////
	function FightTalk()
	{
		local float temptime;

		if(FRand() <= MyPawn.TalkWhileFighting)
		{
			temptime = Say(MyPawn.myDialog.lWhileFighting, bImportantDialog);
			
			if(MyPawn.Weapon != None
				&& MyPawn.Weapon.bMeleeWeapon)
				SayTime = (3*FRand() + 2)*temptime;	// Only have melee weapons wait, because
								// we can't do anything when he's too far away, and while you're at it
								// wait a while
			PrintDialogue("Fight like a man!");
		}
		else
			SayTime=0;
	}

	///////////////////////////////////////////////////////////////////////////
	// Just try to run to him again after you've shot some
	///////////////////////////////////////////////////////////////////////////
	function CheckToMoveAround()
	{
		local NavigationPoint pnode;
		local int i;

		if(firecount == 0)
		{
			// Try for the player again. We're hoping he's down
			// from his silly high point and we can get him.
			if(FRand() < TRY_FOR_ATTACKER_DOWN)
			{
				SetEndPoint(LastAttackerPos, DEFAULT_END_RADIUS);
				SetNextState('ShootAtAttacker', 'WaitTillFacing');
				GotoStateSave('RunToAttacker');
			}
			else
			{
				// If you have an anchor, go through it's reachspec, and 
				// pick a random end.
				if(MyPawn.Anchor != None)
				{
					i = Rand(MyPawn.Anchor.PathList.Length);
					if(MyPawn.Anchor.PathList.Length > 0)
						pnode = MyPawn.Anchor.PathList[i].end;
					if(pnode != None
						&& MyPawn.Anchor != pnode)
					{
						Focus = pnode;

						//log(self$" running to "$pnode);
						SetEndGoal(pnode, DEFAULT_END_RADIUS);
						bStraightPath=UseStraightPath();
						SetNextState('ShootAtAttacker');
						GotoStateSave('RunToAttacker');
					}
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchAttackerHighUp
// Attacker is in some stupid spot without path nodes that you can't really
// reach, so watch him till he gets down and then go beat his ass.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchAttackerHighUp extends ShootAtAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Check if it's our attacker
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		local vector StartLoc;

		if(LookAtMe == Attacker)
		{
			StartLoc = MyPawn.Location;
			StartLoc.z += MyPawn.EyeHeight;
			// Check first to make sure nothing is in the way
			if(FastTrace(StartLoc, LookAtMe.Location))
			{
				CurrentFloat = 0; // Reset each time we can see him
				Focus = Attacker;	// Look at him
				LastAttackerPos = LookAtMe.Location;
				GotoStateSave('ShootAtAttackerDistance');
			}
			else if(Focus == Attacker) // loose focus
			{
				FocalPoint = Focus.Location;
				Focus = None;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// If there's a nearby pathnode to me, then move to it, to look a little more
	// intelligent, so it looks like i'm trying to do something
	///////////////////////////////////////////////////////////////////////////////
	function CheckNearbyPathnode()
	{
		local NavigationPoint pnode;
		local int i;

		// If you have an anchor, go through it's reachspec, and 
		// pick a random end.
		if(MyPawn.Anchor != None)
		{
			i = Rand(MyPawn.Anchor.PathList.Length);
			if(MyPawn.Anchor.PathList.Length > 0)
				pnode = MyPawn.Anchor.PathList[i].end;

			// Make sure it's close enough to run to with out looking too stupid.
			if(pnode != None
				&& MyPawn.Anchor != pnode
				&& VSize(pnode.Location - MyPawn.Location) < WATCH_HIGH_UP_PATHNODE_DIST)
			{
				Focus = pnode;

				//log(self$" running to "$pnode);
				SetEndGoal(pnode, DEFAULT_END_RADIUS);
				bStraightPath=UseStraightPath();
				SetNextState('WatchAttackerHighUp');
				GotoStateSave('RunToTargetIgnoreAll');
			}

		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Say things to him while you can't get to him
	///////////////////////////////////////////////////////////////////////////////
	function float TalkToAttacker()
	{
		return 0.0;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Derail us to try again
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//log(self$" derailed");
		// If we've been waiting around too long, give up and start looking around
		// We'll only do this after enough time of not seeing him
		if(CurrentFloat > statecount*UseAttribute)
			GotoStateSave('LookAroundForTrouble');
		else // otherwise, keep waiting him out
			GotoStateSave('WatchAttackerHighUp', 'Begin');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Decide random wait period
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// Calc sleep time
		UseAttribute = WATCH_HIGH_UP_ATTACKER_TIME + FRand()*WATCH_HIGH_UP_ATTACKER_TIME;
		// Init how long you've been doing this approximately
		CurrentFloat = 0;
		statecount=Rand(WATCH_HIGH_UP_WAIT) + WATCH_HIGH_UP_WAIT;
		SwitchToBestWeapon();
		Focus = Attacker;
	}

MoveAround:
	Sleep(FRand() + 0.5);
	CheckNearbyPathnode();
Begin:
	Sleep(UseAttribute);
	CurrentFloat += UseAttribute;
	CheckForDeadAttacker();
	SayTime = TalkToAttacker();
	Sleep(SayTime);
	CurrentFloat += SayTime;
	CheckObservePawnLooks(Attacker);
	//log(MyPawn$" trying for him again");
	SetActorTargetPoint(LastAttackerPos);
	// If it worked, go for him
	//log(self$" going for it");
	SetEndPoint(LastAttackerPos, DEFAULT_END_RADIUS);
	SetNextState('ShootAtAttacker', 'WaitTillFacing');
	GotoStateSave('RunToAttacker');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// KickAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state KickAttacker extends ShootAtAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		local byte StateChange;

		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			CheckWeaponReady(StateChange);
			if(StateChange == 0)
				CheckToMoveAround();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// See if we have a real weapon to hurt him with
	///////////////////////////////////////////////////////////////////////////////
	function CheckWeaponReady(optional out byte StateChange)
	{
		local P2Weapon p2weap;

		p2weap = P2Weapon(Pawn.Weapon);

		// He's standing again, go back to our real weapon
		if(MyPawn.bHasViolentWeapon
			&& Attacker != None
			&& !Attacker.bIsDeathCrawling)
		{
			StateChange=1;
			GotoStateSave('ShootAtAttacker');
		}
	}
Begin:
	MyPawn.PerformKick();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// BlockMelee
// Reflects/blocks melee or flying melee attack say from a machete, or a scythe
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
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
		if(MyPawn.IsBlockChannel(channel))
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
		MyPawn.FinishBlockAnim();
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
		MyPawn.PlayBlockMeleeAnim();
		// Say you're blocking one hit
		MeleeBlocking++;
		MyPawn.SetMood(MOOD_Angry, 1.0);
	}

Begin:
	Sleep(MyPawn.BlockMeleeTime + FRand()*MyPawn.BlockMeleeTime);

	DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Karaoke response states
// End goal and next state are already set for these.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToTargetNoInterest extends WalkToTarget
{
	ignores PerformInterestAction, TryToGreetPasserby, CanStartConversation;
}
state AwfulKaraoke
{
	ignores PerformInterestAction, TryToGreetPasserby, CanStartConversation;
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		Focus = InterestPawn;
	}
Begin:
	// Stare at the result a minute
	FinishRotation();
	Sleep(1.0 - MyPawn.Reactivity);

	MyPawn.SetMood(MOOD_Angry, 1.0);
	PrintDialogue("Gross!");
	SayTime = Say(MyPawn.myDialog.lKaraoke_Response1, true);
	Sleep(SayTime);
	SayTime=0;

	GotoStateSave('WalkToTargetNoInterest');
}
state LaughKaraoke
{
	ignores PerformInterestAction, TryToGreetPasserby, CanStartConversation;
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		Focus = InterestPawn;
	}	
Begin:
	FinishRotation();
	MyPawn.PlayLaughingAnim();
	SayTime = Say(MyPawn.myDialog.lLaughing);
	Sleep(SayTime);
	SayTime = 0;
	GotoStateSave('WalkToTargetNoInterest');
}
state InsultKaraoke
{
	ignores PerformInterestAction, TryToGreetPasserby, CanStartConversation;
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		Focus = InterestPawn;
	}
Begin:
	FinishRotation();
	// Stare at the result a minute
	Sleep(1.0 - MyPawn.Reactivity);

	MyPawn.SetMood(MOOD_Angry, 1.0);
	PrintDialogue("Your singing sucks");
	SayTime = Say(MyPawn.myDialog.lKaraoke_Response2, true);
	MyPawn.PlayTellOffAnim();
	Sleep(SayTime);
	SayTime=0;

	GotoStateSave('WalkToTargetNoInterest');
}
state PanicKaraoke
{
	ignores PerformInterestAction, TryToGreetPasserby, CanStartConversation;
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		Focus = InterestPawn;

		// Didn't puke, so run away from this point now
		DangerPos = InterestActor.Location;
		InterestActor = None;
		InterestPawn = None;
		UseSafeRangeMin = MyPawn.SafeRangeMin;
	}

TheHorror:
	FinishRotation();
	PrintDialogue("the horror!!");
	SayTime = Say(MyPawn.myDialog.lcarnageoccurred);
	Sleep(SayTime + FRand());
	Goto('Flee');

Flee:
	GotoStateSave('FleeFromDanger');
}
state PanicKaraokeScream extends ScreamingStill
{
	ignores PerformInterestAction, TryToGreetPasserby, CanStartConversation;
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		Focus = InterestPawn;
	}
	function DecideNextState()
	{
		DangerPos = InterestPawn.Location;
		InterestPawn = None;
		InterestActor = None;
		GotoStateSave('FleeFromDanger');
	}
Begin:
	MyPawn.StopAcc();
	FinishRotation();
	MyPawn.SetMood(MOOD_Scared, 1.0);
	Sleep(FRand()/2);
	PlayScreaming();
	Sleep(0.5);
	PrintDialogue("Big Aaaaah! or maybe no screaming sometimes!");
	SayTime = Say(MyPawn.myDialog.lScreaming);
	ScreamState = SCREAM_STATE_DONE;
	Sleep(SayTime+FRand()/2);
	DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	BackToHandsFreq=1.0
	SwitchWeaponFreq=0.2
	RotationRate=(Pitch=0,Yaw=50000,Roll=0)
	DeadBodyMarkerHere=class'DeadBodyMarker'
//	GameHint=""
	ClappingSound=Sound'WFemaleDialog.wf_clap'
	bRKellyTest=False
}