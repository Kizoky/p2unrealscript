///////////////////////////////////////////////////////////////////////////////
// PawnSpawner
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Same as spawner but has special pawn parts
//
// Changed all booleans to ints, so they could be -1 as default, meaning
// they weren't changed, and won't be assigned, and then 0 for false and 1 for
// true for when the LD set them intentionally.
// By not setting these, the spawned pawn will use the defaults he has
//
///////////////////////////////////////////////////////////////////////////////

class PawnSpawner extends Spawner
	showcategories(Collision);

// What a pawn does after he spawns
var() enum ESpawnerPawnInitialState
{
	SE_Think,				// Drops down and starts living his life
	SE_AttackPlayer,		// Hunts down player to attack him
	SE_Panic,				// Runs away from spawn point, scared
	SE_ScaredOfPlayer,		// Runs away from player, screaming
	SE_AttackTag,			// Attacks nearest pawn of this tag
	SE_ScaredOfTag,			// Scared of nearest pawn of this tag
	SE_Turret,				// Stands still and attacks if necessary
	SE_Dead					// Starts dead
} PawnInitialState;

var ()float	InitTimeTillStasis; // TimeTillStasis to deliver to the pawn when it starts
var ()int	InitbCanEnterHomes; // bCanEnterHomes to deliver to the pawn when it starts
var () Name InitHomeTag;		// give to pawn on start, Tag of group of home nodes I consider my home, or use for other things
var ()String InitGang;			// Gang they're associated with when they're spawned.
var ()int	InitbPlayerIsFriend;// They will fight along side you, unless you shoot them
var ()int	InitbPlayerIsEnemy;	// They will attack you on sight if they have a weapon, 
var ()class<AIController> InitControllerClass; // What controller class to give him instead of his usual one
var ()class<Inventory> InitInventoryClass;	// One more thing to give him when he starts (like a weapon)
var ()Name  UseTag;				// Used for the various initial states
var ()Name  InitAIScriptTag;	// AIScript that drives me
var ()float InitVoicePitch;		// Specific voice pitch to use
var ()name  InitStartAnimation;	// Dead animation to play
var ()float InitTwitch;			// initial twitch between 
var ()int   InitbKeepForMovie;	// whether to keep for a movie or not
// Check P2Pawn for explanations on all these variables.
// This should have been done at the C level in such a way that any actor could be placed
// and then marked as a 'spawner'. That way you could modify every single thing and have it
// spawn exactly that. It's too late for that (2/25/03), so I'm cramming some things in for
// the end modders.
var ()float InitPsychic;
var ()float InitChamp;
var ()float InitCajones;
var ()float InitTemper;
var ()float InitGlaucoma;
var ()float InitRat;
var ()float InitCompassion;
var ()float InitWarnPeople;
var ()float InitConscience;
var ()float InitBeg;
var ()float InitPainThreshold;
var ()float InitReactivity;
var ()float InitConfidence;
var ()float InitRebel;
var ()float InitCuriosity;
var ()float InitPatience;
var ()float InitWillDodge;
var ()float InitWillKneel;
var ()float InitWillUseCover;
var ()float InitTalkative;
var ()float InitStomach;
var ()float InitArmor;
var ()float InitArmorMax;
var ()float InitGreed;
var ()float InitTalkWhileFighting;
var ()int   InitMaxMoneyToStart;
var ()int   InitbScaredOfPantsDown;
var ()int   InitbTeamLeader;
var ()float InitTakesShotgunHeadShot;
var ()float InitTakesRifleHeadShot;	
var ()float InitTakesShovelHeadShot;	
var ()float InitTakesOnFireDamage;	
var ()float InitTakesAnthraxDamage;	
var ()float InitTakesShockerDamage;	
var ()int   InitbGunCrazy;
var ()name  InitStartInterest;
var ()float InitTakesPistolHeadShot;
var ()float InitTakesMachinegunDamage;
var ()float InitTalkBeforeFighting;	
var ()float InitWeapChangeDist;
var ()float InitFitness;
var ()int   InitbAdvancedFiring;
// Can't reach from fpsgame, define higher
//var ()class<P2Dialog> InitDialogClass;

// These are the other variables from FPSPawn that I quickly moved over.
// Read comments above on P2Pawn ones.
var ()float	InitHealthMax;
var ()int	InitbIgnoresSenses;
var ()float	InitDonutLove;
var ()int	InitbAngryWithHomeInvaders;
var ()float	InitDamageMult;			
var ()name	InitHeroTag;			
var ()float	InitFriendDamageThreshold;
var ()int	InitbBodyDisappears;	
var ()int   InitbReportDeath;		
var ()int   InitbIgnoresHearing;	
var ()int	InitbUsePawnSlider;		
var ()int	InitbUseForErrands;		
var ()int	InitbNoTriggerAttackPlayer;
var ()int	InitbPersistent;		
var ()int	InitbCanTeleportWithPlayer;
var ()float	InitSeeViewCone;		
var ()int	InitbFriendWithAuthority;
var ()int   InitbRiotMode;
var() name	InitPatrolTag;

// Steven: Adding in a new var for better alteration of base equipment.

// An array of new inventory classes to replace in the pawn's BaseEquipment array.
// If this has at least one element, the pawn's old base equipment array will be
// emptied and all inventory items that match the classes in the old array will be
// deleted. Then InitBySpawner() in P2Pawn will give the pawn the new inventory items
// from this array.
var() array< class<Inventory> >	InitBaseEquipment;

// Hack for drawing cylinders in editor
event PostBeginPlay()
{
	SetCollision(false,false,false);
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Active or not, check right now for any that are spawned and count them
// as our own
///////////////////////////////////////////////////////////////////////////////
function InitMonitor()
{
	local Actor CheckA;

	TotalSpawned=0;
	// Check the world and see if anyone is still alive--slow!
	foreach DynamicActors(class'Actor', CheckA, SpawnTag)
	{
		if(Pawn(CheckA) != None
			&& Pawn(CheckA).Health > 0)
		{
			// Link up the live ones to have me as an event, to trigger
			// me when they die (even if we already did this)
			CheckA.Event = Tag;

			//log(self$" initting with "$CheckA);
			TotalSpawned++;
		}
	}
	//log(self$" total already is "$TotalSpawned);

	// If we have enough already, delete me now
	if(MaxSpawned != 0 
		&& TotalSpawned >= MaxSpawned)
		Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Tally up the current number of alive of the class we care about.
///////////////////////////////////////////////////////////////////////////////
function MonitorWorld()
{
	local Actor CheckA;

	TotalAlive=0;
	// Check the world and see if anyone is still alive--slow!
	foreach DynamicActors(class'Actor', CheckA, SpawnTag)
	{
		if(Pawn(CheckA) != None
			&& Pawn(CheckA).Health > 0)
		{
			//log(self$" monitoring "$CheckA);
			// Link up the live ones to have me as an event, to trigger
			// me when they die (even if we already did this)
			CheckA.Event = Tag;

			//log(self$" still alive "$CheckA);
			TotalAlive++;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Do specific things to the spawned object, like to pawns
///////////////////////////////////////////////////////////////////////////////
function SpecificInits(Actor spawned)
{
	local FPSPawn checkpawn;
	local FPSController fpscont;
	local AIScript checkscript;
	local Inventory thisinv;

	// if a pawn, make the controller
	checkpawn = FPSPawn(spawned);
	if(checkpawn != None)
	{
		// Transfer appropriate pawn only variables
		checkpawn.InitBySpawner(self);

		if(InitControllerClass != None)
			checkpawn.ControllerClass = InitControllerClass;

		// DO possess controllers and pawns during gameplay, but only if not already made
		if ( checkpawn.Controller == None
			&& checkpawn.Health > 0 )
			//&& !checkpawn.bDontPossess )
		{		
			if ( (checkpawn.ControllerClass != None))
				checkpawn.Controller = spawn(checkpawn.ControllerClass);
			if ( checkpawn.Controller != None )
			{
				checkpawn.Controller.Possess(checkpawn);
				AIController(checkpawn.Controller).Skill += checkpawn.SkillModifier;

				fpscont = FPSController(checkpawn.Controller);

				// Set up the pawn's initial state
				switch(PawnInitialState)
				{
					case SE_Think:
						// Do nothing, you'll start thinking naturally
						break;
					case SE_AttackPlayer:
						checkpawn.PawnInitialState = checkpawn.EPawnInitialState.EP_AttackPlayer;
						fpscont.SetToAttackPlayer(None);
						break;
					case SE_Panic:
						checkpawn.PawnInitialState = checkpawn.EPawnInitialState.EP_Panic;
						fpscont.SetToPanic();
						break;
					case SE_ScaredOfPlayer:
						checkpawn.PawnInitialState = checkpawn.EPawnInitialState.EP_ScaredOfPlayer;
						fpscont.SetToBeScaredOfPlayer(None);
						break;
					case SE_AttackTag:
						//checkpawn.PawnInitialState = checkpawn.EPawnInitialState.EP_AttackTag;
						fpscont.SetToAttackTag(UseTag);
						break;
					case SE_ScaredOfTag:
						//checkpawn.PawnInitialState = checkpawn.EPawnInitialState.EP_ScaredOfTag;
						fpscont.SetToBeScaredOfTag(UseTag);
						break;
					case SE_Turret:
						checkpawn.PawnInitialState = checkpawn.EPawnInitialState.EP_Turret;
						fpscont.SetToTurret();
						break;
					case SE_Dead:
						checkpawn.PawnInitialState = checkpawn.EPawnInitialState.EP_Dead;
						fpscont.SetToDead();
						break;
					default:
						warn(self$" ERROR, bad initial pawn state "$PawnInitialState);
				}
			}

			// Wait till everything's kosher before we add any more stuff.
			if(InitInventoryClass != None)
			{
				thisinv = checkpawn.CreateInventoryByClass(InitInventoryClass);
			}

			// Check for AI Script
			checkpawn.CheckForAIScript();
		}
	}
	else
		log(self$" NOT a pawn "$spawned);
}

defaultproperties
{
	InitTimeTillStasis=10
	InitbCanEnterHomes=-1
	InitbPlayerIsFriend=-1
	InitbPlayerIsEnemy=-1
	InitbKeepForMovie=-1
		// p2pawn stuff
	InitVoicePitch=-1
	InitPsychic=-1
	InitChamp=-1
	InitCajones=-1
	InitTemper=-1
	InitGlaucoma=-1
	InitRat=-1
	InitCompassion=-1
	InitWarnPeople=-1
	InitConscience=-1
	InitBeg=-1
	InitPainThreshold=-1
	InitReactivity=-1
	InitConfidence=-1
	InitRebel=-1
	InitCuriosity=-1
	InitPatience=-1
	InitWillDodge=-1
	InitWillKneel=-1
	InitWillUseCover=-1
	InitTalkative=-1
	InitStomach=-1
	InitArmor=-1
	InitArmorMax=-1
	InitGreed=-1
	InitTalkWhileFighting=-1
	InitMaxMoneyToStart=-1
	InitbScaredOfPantsDown=-1
	InitbTeamLeader=-1
	InitTakesShotgunHeadShot=-1
	InitTakesRifleHeadShot=-1
	InitTakesShovelHeadShot=-1
	InitTakesOnFireDamage=-1
	InitTakesAnthraxDamage=-1
	InitTakesShockerDamage=-1
	InitbGunCrazy=-1
	InitTakesPistolHeadShot=-1
	InitTakesMachinegunDamage=-1
	InitTalkBeforeFighting=-1
	InitWeapChangeDist=-1
	InitFitness=-1
	InitbAdvancedFiring=-1
		// fpspawn stuff
	InitHealthMax=-1
	InitbIgnoresSenses=-1
	InitDonutLove=-1
	InitbAngryWithHomeInvaders=-1
	InitDamageMult=-1
	InitFriendDamageThreshold=-1
	InitbBodyDisappears=-1
	InitbReportDeath=-1
	InitbIgnoresHearing=-1
	InitbUsePawnSlider=-1
	InitbUseForErrands=-1
	InitbNoTriggerAttackPlayer=-1
	InitbPersistent=-1
	InitbCanTeleportWithPlayer=-1
	InitSeeViewCone=-1
	InitbFriendWithAuthority=-1
	InitbRiotMode=-1
	//Texture=Texture'PostEd.Icons_256.SpawnerYellow'
	//DrawScale=0.125
	DrawType=DT_Mesh
	Skins[0]=Texture'ChameleonSkins.BystandersF.XX__097__Fem_SS_Shorts'
	Mesh=Mesh'Characters.Fem_SS_Shorts'
	DrawScale=1
     CollisionRadius=+00028.000000
     CollisionHeight=+00072.000000
	 // Hack for drawing cylinder in editor
	 bCollideActors=true
}

