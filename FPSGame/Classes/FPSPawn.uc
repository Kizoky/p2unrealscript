///////////////////////////////////////////////////////////////////////////////
// First Person Shooter Pawn
///////////////////////////////////////////////////////////////////////////////
class FPSPawn extends Pawn
	native
	abstract
	notplaceable
	config(User);

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////

var(PawnAttributes) float	HealthMax;				// How much Health this guy started with, usually 100.

var(PawnAttributes) bool	bPlayerIsFriend;		// They will fight along side you, unless you shoot them
var(PawnAttributes) bool	bPlayerIsEnemy;			// They will attack you on sight if they have a weapon, 
													// or run from you if they don't have a weapon

var(PawnAttributes) bool	bIgnoresSenses;			// Markers and player that tell him about things don't register.
													// Can't 'see' player with his gun. Doesn't 'hear' gunfire, screams
													// around him. But will respond if you bump him with a gun or 
													// hurt him.
													// Triggering most controllers turns this off.

var(PawnAttributes) string	Gang;					// What gang I associate with. If you're in a gang, you'll not
													// fight others in your gang, and you'll even help them.
													// People default to gang of None, which means they won't fight together
													// with anyone else. But if you set two people to be in the same gang, 
													// They'll help each other.
var(PawnAttributes) float	DonutLove;				// How much they love donuts. 0 - 1.0.
													// How likely this pawn will go for donuts the player has dropped.
var(PawnAttributes) enum	EPawnInitialState		// What a pawn does after he spawns
{
	EP_Think,					// Drops down and starts living his life
	EP_AttackPlayer,			// Hunts down player to attack him
	EP_Panic,					// Runs away from spawn point, scared
	EP_ScaredOfPlayer,			// Runs away from player, screaming
	EP_HoldPosition,			// Stand in this one spot where you put me
	EP_KickNearest,				// Go to the nearest person and kick him
	EP_PatrolJail,				// Patrol walk, but only in a jail--this makes footstep sounds
								// Normal PatrolToTarget takes over cops and the like just by
								// putting some patrol tags in there.
	EP_Dance,					// Dance where you are placed--don't stop till interrupted
	EP_StandWithGun,			// Stand with your gun out	(don't report gun)
	EP_StandWithGunReady,		// Stand with your gun raised, ready to fire  (don't report gun)
	EP_PlayArcade,				// play a game where you are placed--don't stop till interrupted
	EP_GoStandInQueue,			// Go stand in StartInterest for their product
	EP_Turret,					// Stands still and attacks if necessary
	EP_KeyboardType,			// Type in the direction you're place--don't stop till interrupted
	EP_WatchPlayer,				// Have the player as your focus and watch him a while till you get bored
	EP_ConfusedWatchPlayer,		// Yell something first, then have the player as your focus and watch him a while till you get bored
	EP_CheerPlayer,				// Player gets clapped at
	EP_LaughAtPlayer,			// Player gets laughed at
	EP_BystanderGoFindCop,		// Go find a cop and sick them on the player
	EP_Dead,					// Make them start out dead and in a given animation
	EP_Guitar,					// Plays guitar and triggers a SongThing
	EP_Custom,					// Loop custom anim
	EP_AttackTag				// Attack pawn with Tag matching AttackTag
} PawnInitialState;

var(PawnAttributes) name	AttackTag;				// If set and PawnInitialState is EP_AttackTag, finds a Pawn with tag matching this one and attacks it
var(PawnAttributes) bool	bCanEnterHomes;			// This pawn can use homenodes
var(PawnAttributes) Name	HomeTag;				// Tag of group of home nodes I consider my home, or use for other things
var(PawnAttributes) float	StartTimeTillStasis;	// Set in the editor, this determines TimeTillStasis, but only after
													// the pawn gets started well enough.
var(PawnAttributes) bool	bPersistent;			// Set this to true and Tag this pawn with a unique tag for 
													// that level. If the pawn dies or travels with the player (like
													// an animal friend) it will remember him. It must have
													// a unique tag for that level, to save him. 
													// If this is true, bUsePawnSlider should be false.
var(PawnAttributes) bool	bCanTeleportWithPlayer;	// whether pawn can teleport with player
var(PawnAttributes) float	SeeViewCone;			// -1.0 to 1 float saying how large an area he can see another character
													// in. 0.75 is about a 30 degree area in front of a pawn. -1.0 would be 180
var(PawnAttributes) bool	bFriendWithAuthority;	// Don't mind getting shot by cops/military, and cops
													// try not to shoot them.
var float					TimeTillStasis;			// How long they have to be not rendered before they'll TRY to go into stasis.
													// Use 0 to mean they never try for stasis, so they'll always update.
													// Player pawns are set to this in the possess function of their player controller.
var bool					bAllowStasis;			// While TimeTillStasis == 0 means there will be no stasis, this is used
													// for things that turn the stasis on and off in script. Everyone should default
													// this to true except players.
var(PawnAttributes) bool	bAngryWithHomeInvaders;	// Gets mad if true, and someone in the same zoneinfo tagged as your HomeTag
var(PawnAttributes) float	DamageMult;				// How much more(or less) damage we cause to people when shooting them
													// Most people default to 1.0. The dude should use something higher like 2.0
var(PawnAttributes) name	HeroTag;				// Sets the Hero variable in LambController if not None
var(PawnAttributes) float	FriendDamageThreshold;	// How much a player has to hurt you before you turn on him
var(PawnAttributes) name	StartAnimation;			// Provide a string for the animation to use
var(PawnAttributes) bool	bBodyDisappears;		// By default bodies eventually disappear.
var(PawnAttributes) bool    bReportDeath;			// Report death (so people get scared/puke when they see a body)
													// If this is FALSE, then the body will automatically never disappear

var(PawnAttributes) bool    bIgnoresHearing;			// Like IgnoreSenses, but can still 'see' player with a gun. Doesn't
													// respond to gunfire or screaming around him. Does respond to
													// bumps with a gun, and pain.
													// Triggering most controllers turns this off.
var(PawnAttributes) bool	bUsePawnSlider;			// If this is true, then this pawn's existance is controlled with the
													// Pawn slider in the game info. The slider determines how many
													// can be alive at once. When one dies, if anyone was in SliderStasis
													// then they may be picked to fill the role of the dead person.
													// Generic bystanders are usually the only ones to use this
													// though cops, dogs, anyone can use it (except CashierController
													// codes it to false always for a cashier).
													// If this is true, bPersistent should be false.
var(PawnAttributes) bool	bKeepForMovie;			// If this is true, then when an Action_RemoveNonMoviePawns is
													// called around this pawn, then this pawn will be spared. All others
													// will be turned off and forced to use the pawn slider.
var(PawnAttributes) bool	bUseForErrands;			// I'm used for an errand, so for instance, when I die
													// I'll tell the errand system to check if I completed an errand goal.
var(PawnAttributes) bool	bNoTriggerAttackPlayer;	// If true, then triggering him won't make him attack the
									// player. Usually NPC's will attack the player when triggered.
var(PawnAttributes) bool	bRiotMode;				// Used only for the apocalypse--makes them carry their gun
													// out all the time so as to get in more fights.
var/*(PawnAttributes)*/ name	CustomAnimLoop;			// Name of custom animation to loop in EP_Custom
var(PawnAttributes) name	GuitarMusicTag;			// Tag of music to trigger when playing guitar
var(PawnAttributes) export editinline CustomAnimAction	CustomAnim;	// List of custom animations to play in EP_Custom
// Internal vars
var int			OneUnitInHealth;	// A single percentage of the max health. If Max is <= 100, this is 1.
var float		HealthPctConversion;// Ratio of HealthMax/100. Different from the above, because it can go
									// below 1 if needed.
var bool		bExtraFlammable;	// They've been soaked in gas at some point, so they're extra ready
									// to burn. Even a match will light them on fire now.
var Emitter		MyBodyFire;			// Torso fire emitter for me.. it hurts! 
									// If this is not None, then we're on fire
var range		AttackRange;		// Where you prefer to attack from (distance from you to attacker)
var float		SafeRangeMin;		// Distance past which you feel safest in relation to danger
var float		MovementPct;		// Generic pecertang to reduce movement by for pawns
var	Pawn		DamageInstigator;	// Who last attacked me.
var LoopPoint	MyLoopPoint;		// Current loop point we're going to
var float		PathCheckTimeActor;	// Max time till they reassess their path when going towards an actor
var float		PathCheckTimePoint;	// Max time till they reassess their path for a point
var float		RagDollStartTime;	// The level time when we first got our ragdoll. Use this to find out
									// if we've had it long enough and someone will take it from us.
var bool		bPlayer;			// Allows the pawn to say he's the player or not. bIsPlayer is marked
									// in controllers. This simply set when the pawn is possessed and he's the
									// player. It's *not* cleared when the pawn is unpossessed. This could be
									// a problem for some things, but it's good for when he dies, and his controller
									// is taken away.
var float		NoisySpeed;			// Determined and then saved. Past this, we make noise NPCs can hear.
var FPSPawn		StasisPartner;		// Person who I wake up from stasis, when I die.
var bool		bSliderStasis;		// If true, this person is in normal stasis, but also hidden, and 
									// will only come out of stasis when the game info says someone
									// else has died, and they need to fill that spot of the guy that
									// just died. This keeps a seemingly large number of people always
									// alive, but keeps it from too quickly becoming a ghost town
									// if lots of people are killed. To use this, the pawn just have
									// bUsePawnSlider set to true.
var FPSPawn		MyPrevDead;			// These two variables form the doubly linked list of dead pawns. They're used
var FPSPawn		MyNextDead;			// to know who to remove next when it's time to remove a dead pawn (as specified
									// by P2GameInfo and done by the DeadBodyMarker.
// animation vars
var bool		bWantsToDeathCrawl;	// Character wants to deathcrawl.
var const bool	bIsDeathCrawling;	// Animation state for doing a death crawl. On par with bIsCrouching
var const bool	bWasDeathCrawling;	// Set after you start deathcrawling. C uses this to know when to do a changeanimation.
var bool		bIsKnockedOut;		// Set to true when controller is in a knock-out state.
									// Uses DeathCrawl physics state so we need this flag to differentiate the two
var float		DeathCrawlingPct;	// Percent of motion for movement in death crawl. 0-1.
var Rotator		DeathCrawlRotationRate;	// You rotate more slowly while doing this
var float		DeathCrawlRadius;	// collision for deathcrawling
var float		DeathCrawlHeight;

var bool		bIgnoreTimeDilation;// Defaults to false--set to true if you want this pawn to not be
									// effected by catnip--good for dog friends of player (they lack usefulness
									// in catnip mode otherwise--they can't catch up with you)

var bool		bIsCowering;		// Animation state for cowering in a ball (curled up in a ball)

var transient bool bPostLoadCalled;	// For pawns spawned during postload, they set this so it doesn't get
									// called on them again.									

// Available gender selections
enum EGender
	{
	Gender_Any,
	Gender_Male,
	Gender_Female
	};

// Available race selections
enum ERace
	{
	Race_Any,
	Race_White,
	Race_Black,
	Race_Mexican,
	Race_Asian,
	Race_Hindu,
	Race_Fanatic,
	Race_Automaton,
	Race_Skeleton
	};

// Available body types
enum EBody
	{
	Body_Any,
	Body_Avg,
	Body_Fat,
	Body_Tall
	};

// Inventory										
var Weapon					MyUrethra;				// The thing that lets pee come out of the body

// Dialog

// Travelling
var bool					bTravelledWithPlayer;	// We need to know if they travelled with us already
													// Set after player brings them through a level transition
var string					OrigLevelName;			// For pawns that get travelled around a lot (like dog
													// friends) this is the original level you were in. Defaults
													// to none, so more than likely this is empty unless someone
													// set it--like the player befriending a dog.
var bool					bChunkedUp;				// Variably to know that we died instantly from something
													// so the controller doesn't try to clean us up in the
													// normal fashion

// equipment

// Effects

// CONVERSION: These are set by the C++ code before it calls PostEditChange(), which
// was a lot easier than hooking up a new event that can be called from the editor.
// See Bystanders.PostEditChange() for an example of how this is used.
var transient bool			bDupPawn;				// Flag used to tell PostEditChange() we're duplicating instead
var transient FPSPawn		DupPawn;				// The new pawn to duplicate this pawn into

var Emitter					MyBodyChem;				// Chemical infection effect for when they can tranfer
													// an infection from a plague rocket
var bool					bSimpleBasedPhysicsAnim;	// Usually just for simple animals
													// Calls run when they move really fast, walk when not so
													// fast, stand when 0, fall, etc. Used to save on network bandwidth


///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////


const NO_ONE_DIES	=	0;		// Set this to 1 to make no one die, including yourself

const STASIS_RAND_TIME	=	10;	// Amount of time people can choose during which to wait to go into
								// stasis, this is picked once and kept set.
const MIN_STASIS_TIME_TILL_INF = 0.5;	// Amount of time for a stasis time pick, befeore we just say
								// he's never goes into stasis, keep this low so not everyone is in stasis.
const RAGDOLL_USE_TIME	=	10;	// Max time for how long someone gets to use a ragdoll before it's allowed to be
								// taken away from him if someone else needs it.

const FIRE_RESET_TIME	=	10.0;	// Time before a dead body can be caught on fire again

const NOISY_SPEED_FRACTION = 0.9;

const DIED_EARLY_EVENT	=	'DiedEarly';

const DEF_SPAWN_FLOAT = -1;

replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		bIsDeathCrawling, bPlayer;

}

///////////////////////////////////////////////////////////////////////////////
// For better compatibility with updated ACTION_ChangeWeapon
///////////////////////////////////////////////////////////////////////////////
function class<Weapon> GetHandsClass()
{
	// STUB -- filled out in PersonPawn
	return none;
}

///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	local FPSGameInfo checkg;

	Super.PostBeginPlay();

	// Make his starting health be the health max that they set.
	Health = HealthMax;
	SetMaxHealth(HealthMax);

	// count this pawn
	checkg = FPSGameInfo(Level.Game);
	if (checkg != None)
		checkg.AddPawn(self);

	// Past this we start making enough noise for everyone to hear us
	NoisySpeed = GroundSpeed*NOISY_SPEED_FRACTION;

//	ConfigSizeByDrawScale();
}

///////////////////////////////////////////////////////////////////////////////
// Restore your animation if you had one, otherwise, just changeanimation.
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	if(!bPostLoadCalled)
	{
		Super.PostLoadGame();

		bPostLoadCalled=true;
		// Force the animations to restart
		bInitializeAnimation=false;
		if(Health <= 0)
			SetupDeadAfterLoad();
		else
		{
			//log(self$" PostLoadGame, save anim "$SaveAnim$" save frame "$SaveFrame$" rate "$SaveRate);
			if(SaveAnim != '')
				PlayAnimAt(SaveAnim, SaveRate, , , SaveFrame);
			else
				ChangeAnimation();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Events for simple physics based anims
///////////////////////////////////////////////////////////////////////////////
event bool IsStanding()
{
	return true;	// default anim to play (standing)
}
event bool IsWalking()
{
	return false;
}
event bool IsRunning()
{
	return false;
}
event PhysPlayStanding();
event PhysPlayWalking();
event PhysPlayRunning();

///////////////////////////////////////////////////////////////////////////////
// Play special anims to 'reinit' a ragdoll (it doesn't get saved well)
///////////////////////////////////////////////////////////////////////////////
function SetupDeadAfterLoad()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Allow the pawn to turn off certain channels when having an AI script
// action play an animation
///////////////////////////////////////////////////////////////////////////////
function ActionPlayAnim( name BaseAnim, float AnimRate, float BlendInTime)
{
	PlayAnim(BaseAnim,AnimRate,BlendInTime);
}
function ActionLoopAnim( name BaseAnim, float AnimRate)
{
	LoopAnim(BaseAnim,AnimRate);
}

///////////////////////////////////////////////////////////////////////////////
// Check if pawn wants AI script to take over.  This should only be called
// after the pawn already has a controller.
///////////////////////////////////////////////////////////////////////////////
function CheckForAIScript()
{
	local AIScript checkscript;

	// Note that if the script does take over the pawn, it will preserve
	// the existing controller and restore it after the script completes.
	if ( (AIScriptTag != 'None') && (AIScriptTag != '') )
	{
		ForEach AllActors(class'AIScript',checkscript,AIScriptTag)
			break;
		if ( checkscript != None )
			checkscript.TakeOver(self);
		else
			Warn(self$" CheckForAIScript(): can't find AIScript with tag '"$AIScriptTag$"'");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Prepare this pawn to work within this difficulty level (make him
// tougher/better aim for higher difficulties)
///////////////////////////////////////////////////////////////////////////////
function SetForDifficulty(byte ThisDiff)
{
	local float HealthDiv;

	//HealthDiv = 0.1*HealthMax;
	//HealthMax += (ThisDiff*HealthDiv);
}

///////////////////////////////////////////////////////////////////////////////
// If the player can't see me, then go ahead and get rid of me
///////////////////////////////////////////////////////////////////////////////
function TryToRemoveDeadBody()
{
	if ( !PlayerCanSeeMe() )
		Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Unhook ragdoll completely
///////////////////////////////////////////////////////////////////////////////
function UnhookRagdoll()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// If you've used the ragdoll long enough to fall to the ground or whatever
///////////////////////////////////////////////////////////////////////////////
function bool FinishedWithRagdoll()
{
	//log(self$" finished with ragdoll?, level time "$Level.TimeSeconds$" vel "$Velocity$" rag start "$RagDollStartTime);
	if((Level.TimeSeconds - RagDollStartTime) >= RAGDOLL_USE_TIME)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Find the best location after teleporting
///////////////////////////////////////////////////////////////////////////////
function vector FindBestLocAfterTeleport(vector TeleLoc, vector DesiredLoc, float CollisionHeight)
	{
	local Actor HitActor;
	local vector HitLocation, HitNormal, retLoc, StartLoc, EndLoc;
	
	// Trace from teleporter location to desired location.  If we don't hit
	// anything then use that location (adjusting it for collision height)
	HitActor = Trace(HitLocation, HitNormal, DesiredLoc, TeleLoc, true);
	if(HitActor != None)
		{
		retLoc = HitLocation;
		retLoc.z += CollisionHeight;
		}
	else
		{
		// Trace from head down to feet and if we don't hit anything
		// then use that location (adjusting it for collision height)
		StartLoc = DesiredLoc;
		StartLoc.z += CollisionHeight;
		EndLoc = DesiredLoc;
		EndLoc.z -= CollisionHeight;
		HitActor = Trace(HitLocation, HitNormal, EndLoc, StartLoc, true);
		if(HitActor != None)
			{
			retLoc = HitLocation;
			retLoc.z += CollisionHeight;
			}
		else
			retLoc = DesiredLoc;
		}
	
	return retLoc;
	}

///////////////////////////////////////////////////////////////////////////////
// When someone bumped into me, tell my controller
///////////////////////////////////////////////////////////////////////////////
event Bump( actor Other )
{
	//log(self$" bump "$Other$" my pos "$Location$" his "$Other.Location);
	if(Controller != None)
		Controller.Bump(Other);
}

// If we hit a wall, treat it as a bump into the wall we hit
event HitWall( vector HitNormal, actor HitWall )
{
	if (HitWall.bWorldGeometry) {
		if(Controller != None)	// xPatch: Check for None
			Controller.Bump(HitWall);
	}
}


///////////////////////////////////////////////////////////////////////////////
// Determines how much a threat to the player this pawn is
///////////////////////////////////////////////////////////////////////////////
function float DetermineThreat()
{
	return 0.0;
}

///////////////////////////////////////////////////////////////////////////////
// ConfigSizeByDrawScale
// Make the collision size based on the draw scale
///////////////////////////////////////////////////////////////////////////////
function ConfigSizeByDrawScale()
{
	// draw scale modifies collision size
	// Handle drawscale in an overall manner
	if(DrawScale != 1.0)
	{
		log(self$" rad "$CollisionRadius$" height "$CollisionHeight$" scale "$DrawScale);
		SetCollisionSize(CollisionRadius*DrawScale, CollisionHeight*DrawScale);
		CrouchHeight*=DrawScale;
		CrouchRadius*=DrawScale;
		BaseEyeHeight*=DrawScale;
		EyeHeight*=DrawScale;
		log(self$" rad "$CollisionRadius$" height "$CollisionHeight$" scale "$DrawScale);

	}
	else if(DrawScale3D.X != 1.0
		|| DrawScale3D.Y != 1.0
		|| DrawScale3D.Z != 1.0)
	// Handle drawscale3d in a peicemeal manner
	// X is the only thing that effects the radius
	// Z is the only thing that effects the height
	{
		log(self$" rad "$CollisionRadius$" height "$CollisionHeight$" scale3d "$DrawScale3D);
		SetCollisionSize(CollisionRadius*DrawScale3D.X, CollisionHeight*DrawScale3D.Z);
		CrouchHeight*=DrawScale3D.Z;
		CrouchRadius*=DrawScale3D.X;
		BaseEyeHeight*=DrawScale3D.Z;
		EyeHeight*=DrawScale3D.Z;
		log(self$" rad "$CollisionRadius$" height "$CollisionHeight$" scale3d "$DrawScale);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Take an state to setup and get the controller ready
///////////////////////////////////////////////////////////////////////////////
function bool SetupNextState(EPawnInitialState PrepState, optional FPSPawn UsePlayer)
{
	local FPSController fpscont;

	fpscont = FPSController(Controller);

	if(fpscont == None)
	{
		warn(self$" ERROR: no fps controller for me");
		return false;
	}

	switch(PrepState)
	{
		case EP_Think:				// Drops down and starts living his life
			// Do nothing here
			return false;
			break;
		case EP_AttackPlayer:		// Hunts down player to attack him
				fpscont.SetToAttackPlayer(UsePlayer);
			break;
		case EP_AttackTag:			// Attacks tagged actor
			if (AttackTag == '')	// Tag is missing, warn in the log but keep going
				warn("============================"@self@"set to AttackTag but no AttackTag is defined!!!");
			fpscont.SetToAttackTag(AttackTag);
			break;
		case EP_Panic:				// Runs away from spawn point, scared
				fpscont.SetToPanic();
			break;
		case EP_ScaredOfPlayer:		// Runs away from player, screaming
				fpscont.SetToBeScaredOfPlayer(UsePlayer);
			break;
		case EP_HoldPosition:		// Stand in this one spot where you put me
				fpscont.SetToHoldPosition();
			break;
		case EP_KickNearest:		// Go to the nearest person and kick him
				fpscont.SetToKickNearest();
			break;
		case EP_PatrolJail:			// As long as you have patrol tags, you'll and make footstep noises
				fpscont.SetToPatrolJail();
			break;
		case EP_Dance:				//  Dance in place
				fpscont.SetToDance();
			break;
		case EP_StandWithGun:		//  Stand with gun out, but not in combat pose--don't move
				fpscont.SetToStandWithGun();
			break;
		case EP_StandWithGunReady:	//  Face the direction place, don't move, but have gun out
									// in combat ready pose
				fpscont.SetToStandWithGunReady();
			break;
		case EP_PlayArcade:			//  Play an arcade game here
				fpscont.SetToPlayArcadeGame();
			break;
		case EP_GoStandInQueue:		// Find StartInterest to stand in, and go stand in it
				fpscont.SetToStandInQ();
			break;
		case EP_Turret:		//  Stand with gun out, ready to kill
				fpscont.SetToTurret();
			break;
		case EP_KeyboardType:	//  Type on something here
				fpscont.SetToKeyboardType();
			break;
		case EP_WatchPlayer:		// Have the player as your focus and watch him a while till you get bored
				fpscont.SetToWatchPlayer(UsePlayer);
			break;
		case EP_ConfusedWatchPlayer:// Yell something first, then have the player as your focus and watch him a while till you get bored
				fpscont.SetToConfusedWatchPlayer(UsePlayer);
			break;
		case EP_CheerPlayer:		// Player gets clapped at
				fpscont.SetToCheerPlayer(UsePlayer);
			break;
		case EP_LaughAtPlayer:		// Player gets laughed at
				fpscont.SetToLaughAtPlayer(UsePlayer);
			break;
		case EP_BystanderGoFindCop:		// Find a cop and sick them on the player
				fpscont.SetToFindCop(UsePlayer);
			break;
		case EP_Dead:					// Start dead, and in a given animation
				fpscont.SetToDead();
			break;
		case EP_Guitar:
			fpscont.SetToGuitar();
			break;
		case EP_Custom:
			fpscont.SetToCustom();
		default:
			warn(self$" ERROR: this initial state is not handled: "$PrepState);
			return false;
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Once, you've landed, this is called from LambController. It's supposed to
// setup complicated things for your initial controller state. 
///////////////////////////////////////////////////////////////////////////////
function bool PrepInitialState()
{
	return SetupNextState(PawnInitialState);
}

///////////////////////////////////////////////////////////////////////////////
// Clean up
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
{
	// If already destroyed, don't continue
	if ( bDeleteMe)
		return;

	// If we're destroyed instantly, only check if we're needed for an errand
	// if we're destroyed *after* the initial game info start up. That will destroy
	// us if we're dayblocked.
	if(FPSGameInfo(Level.Game) != None
		&& !FPSGameInfo(Level.Game).StartingUp())
	{
		// If I'm used for an errand, check to see if I did anything important
		CheckForErrandCompleteOnDeath(None);
	}

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Drop any bolt-ons that can be dropped
// Simply dissociates them and turns on their physics
///////////////////////////////////////////////////////////////////////////////
function DropBoltons(vector Momentum)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Set time stasis variable. Make it random, so that people won't bunch up
// the exact same distance away on a sort of perimeter. They'll still go into
// stasis, but this will have them do it in a random enough way, it'll be really
// hard to recognize it.
///////////////////////////////////////////////////////////////////////////////
function SetTimeTillStasis()
{
	if(StartTimeTillStasis > 0)
		TimeTillStasis = FRand()*StartTimeTillStasis + 1;//FRand()*STASIS_RAND_TIME;

//	if(TimeTillStasis < MIN_STASIS_TIME_TILL_INF)
//		TimeTillStasis = 0.0; // you never go into stasis;

//	log(self$" my time stasis "$TimeTillStasis);
}

///////////////////////////////////////////////////////////////////////////////
// This sets up the pawn to wait for a while then go into stasis.
//
// This can fail, so this is only a try. And even then
// they don't instantly go into stasis. They go about for a while, then
// try to really do it.
///////////////////////////////////////////////////////////////////////////////
function bool TryToWaitForStasis()
{
	//log(self$" allow "$bAllowStasis$" timetill "$TimeTillStasis$" startime "$StartTimeTillStasis);
	if(bAllowStasis
		&& TimeTillStasis == 0
		&& StartTimeTillStasis != 0)
		{
			SetTimeTillStasis();
			return true;
		}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Do anything else while going into stasis
///////////////////////////////////////////////////////////////////////////////
function PrepBeforeStasis()
{
	// STUB
}
///////////////////////////////////////////////////////////////////////////////
// Do anything else while coming out of stasis
///////////////////////////////////////////////////////////////////////////////
function PrepAfterStasis()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Make him on fire and update his anims
///////////////////////////////////////////////////////////////////////////////
function SetOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
	ChangeAnimation();
}

///////////////////////////////////////////////////////////////////////////////
// Set to be infected.
///////////////////////////////////////////////////////////////////////////////
function SetInfected(FPSPawn Doer)
{
	ChangeAnimation();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/*
function name GetWeaponBoneFor(Inventory I)
{
	return 'weapon_bone';
}
*/

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PreSetMovement()
{
	if (JumpZ > 0)
		bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
}
	
///////////////////////////////////////////////////////////////////////////////
//
// Last time I checked, SetBoneDirection WASN'T working properly.. if you just get the 
// rotation and then set it in the direction, it doesn't work.
// To start calling this again, change it in FPSPawn.cpp
// Epic does this with UpdateRotation in their player controller, but we want it for
// all characters, check 927 code to see how
///////////////////////////////////////////////////////////////////////////////
event RotateTowards(Actor Focus, Vector FocalPoint)
{
//	log("i got calleD!");
}

///////////////////////////////////////////////////////////////////////////////
// Pass along the touch event. We should only get this is we're *not* blocking
// things. Pawns default to blocking each other and use Bump, but CatPawn doesnt'
// so he can squeeze through people's legs easily.. he uses Touch.
///////////////////////////////////////////////////////////////////////////////
event Touch(actor Other)
{
	if(Controller != None)
		Controller.Touch(Other);
}

///////////////////////////////////////////////////////////////////////////////
// Don't do anything if the vel mag is 0
///////////////////////////////////////////////////////////////////////////////
function AddVelocity( vector NewVelocity)
{
	if ( bIgnoreForces )
		return;

	// return earlier if you have nothing to do
	if(NewVelocity.x==0
		&& NewVelocity.y==0
		&& NewVelocity.z==0)
		return;

	if ( (Physics == PHYS_Walking)
		|| (((Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) && (NewVelocity.Z > Default.JumpZ)) )
		SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

///////////////////////////////////////////////////////////////////////////////
// Keeps float within these two values
///////////////////////////////////////////////////////////////////////////////
function ClipFloat(out float val, float max, float min)
{
	if(val > max)
		val = max;
	else if(val < min)
		val = min;
}

///////////////////////////////////////////////////////////////////////////////
// Randomize by randval AROUND val and return it.
// Don't randomize if you're at a limit
///////////////////////////////////////////////////////////////////////////////
function RandomizeAttribute(out float val, float randval, float max, float min)
{
	local float half;
	if(val != max
		&& val != min)
	{
		half = randval/2;

		val += randval*FRand() - half;
	}
}

///////////////////////////////////////////////////////////////////////////////
//	Stop running/walking
///////////////////////////////////////////////////////////////////////////////
function StopAcc()
{
	if(Physics == PHYS_WALKING)
	{
		// Don't set Z values
		Acceleration = vect(0,0,0);
		Velocity = vect(0, 0, 0);
	}
}

///////////////////////////////////////////////////////////////////////////////
//	He's not walking or running
///////////////////////////////////////////////////////////////////////////////
simulated function bool NoLegMotion()
{
	if(Physics == PHYS_WALKING 
		&& VSize(Acceleration)==0)
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
//	He's moving around enough to make noise
///////////////////////////////////////////////////////////////////////////////
function bool MakingMovingNoises()
{
	if(bIsWalking
		|| (abs(Velocity.x) <= NoisySpeed
			&& abs(Velocity.y) <= NoisySpeed))
		return false;
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Handle health additions
// Returns true if it added any health at all
///////////////////////////////////////////////////////////////////////////////
function bool AddHealth(float NewHealth, 
						optional int Tainted,
						optional out float LeftOver,
						optional bool bIsAddictive, 
						optional bool bCanSurpassMax,
						optional bool bIsFood)
{
	local float HealthAdded;
	local FPSPlayer fpscont;

	fpscont = FPSPlayer(Controller);
	if(fpscont != None)
		fpscont.NotifyGotHealth(NewHealth);

	if (Health < HealthMax) 
	{
		Health += NewHealth;
		if(Health > HealthMax)
		{
			LeftOver = Health - HealthMax;	// record what we didn't use
			Health = HealthMax;
		}
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
//	Get the percentage of your health (usually for display purposes)
///////////////////////////////////////////////////////////////////////////////
simulated function int GetHealthPercent()
{
	return (100*Health)/HealthMax;
}

///////////////////////////////////////////////////////////////////////////////
// Set your max health and do some calculations
///////////////////////////////////////////////////////////////////////////////
simulated function SetMaxHealth(int NewMax)
{
	HealthMax = NewMax;
	if(HealthMax > 100)
		OneUnitInHealth = HealthMax/100;
	else
		// Force it to be 1, so that for damage reduction, when something gets
		// hurt a little, even could get factored out, but we want it to count
		OneUnitInHealth = 1;

	// Use this for health additions in a percentage
	HealthPctConversion = HealthMax/100;
	//log(self$" one unit "$OneUnitInHealth$" health pct "$HealthPctConversion$" again "$(100*OneUnitInHealth)/HealthMax);
}

///////////////////////////////////////////////////////////////////////////////
// Pick physics type
///////////////////////////////////////////////////////////////////////////////
function SetMovementPhysics()
{
	if (Physics == PHYS_Falling)
		return;
	if ( PhysicsVolume.bWaterVolume )
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Walking); 
}

///////////////////////////////////////////////////////////////////////////////
// Set the mood, which determines how various actions are performed.
//
// The amount is between 0.0 to 1.0 and is used by some of the mood-based
// to further refine the responses.  Most functionality is based purely on
// the specified mood, completely ignoring the amount.
///////////////////////////////////////////////////////////////////////////////
function SetMood(EMood moodNew, float amount)
	{
	// STUB
	}

///////////////////////////////////////////////////////////////////////////////
// Make sure BEFORE this, that he has the weapon you care about
// True if he's using it actively
///////////////////////////////////////////////////////////////////////////////
function bool ActivelyUsingWeapon()
{
	if(PressingFire()					// trying to use it
	&& (Weapon.IsInState('NormalFire')	// actively using it
		|| Weapon.IsInState('AltFire')))
		return	true;
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Normal characters accept all damage. Gary, for instance is smaller, and
// excludes some
///////////////////////////////////////////////////////////////////////////////
function bool AcceptHit(vector HitLocation, vector Momentum)
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Lower the damage based on body location, closer to the center of the
// person, the closer to Damage it is
// Taking the incident angle and the angle from the hit to the center, 
// the more inline these two are, the closer the return damage is to Damage.
///////////////////////////////////////////////////////////////////////////////
function int ModifyDamageByBodyLocation( int Damage, Pawn InstigatedBy,
						  vector HitLocation, vector Momentum, 
						  out class<DamageType> ThisDamage,
						  out byte HeadShot)
{
	if(FPSPawn(InstigatedBy) != None)
	{
 		// Multiply damage from dude by a certain factor
		Damage = FPSPawn(InstigatedBy).DamageMult*Damage;
	}
	return Damage;
}

///////////////////////////////////////////////////////////////////////////////
// Perform protesting motion
///////////////////////////////////////////////////////////////////////////////
function SetProtesting(bool bSet)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Perform marching motion
///////////////////////////////////////////////////////////////////////////////
function SetMarching(bool bSet)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Disconnect my variable from my torso fire, now or later (later in the Dying state of
// AnimalPawn and P2Pawn)
///////////////////////////////////////////////////////////////////////////////
function UnhookPawnFromFire()
{
	MyBodyFire=None;
	if(PlayerController(Controller) != None)
		ChangeAnimation();
}

///////////////////////////////////////////////////////////////////////////////
// Disconnect my variable from my torso infection, now or later
///////////////////////////////////////////////////////////////////////////////
function UnhookPawnFromChem()
{
	MyBodyChem=None;
	//if(PlayerController(Controller) != None)
	//	ChangeAnimation();
}

///////////////////////////////////////////////////////////////////////////////
// Used to make a new inventory item with a class
///////////////////////////////////////////////////////////////////////////////
function Inventory CreateInventoryByClass(class<Inventory> MakeMe, 
										  optional out byte CreatedNow,
										  optional bool bIgnoreDifficulty)
{
	// STUB
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// All this ensures is that the weapon we currently have equipped (even if it's
// none) is not violent.
///////////////////////////////////////////////////////////////////////////////
function bool ViolentWeaponNotEquipped()
{
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// True if he has a urethra equipped
///////////////////////////////////////////////////////////////////////////////
function bool HasPantsDown()
{
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// True if he has a gas can equipped
///////////////////////////////////////////////////////////////////////////////
function bool HasGasCan()
{
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Controller is requesting that pawn crouch
// Don't let him crouch when deathcrawling already
///////////////////////////////////////////////////////////////////////////////
function ShouldCrouch(bool Crouch)
{
	if((!bIsDeathCrawling && !bIsKnockedOut)
		|| !Crouch)
		bWantsToCrouch = Crouch;
}

///////////////////////////////////////////////////////////////////////////////
// Set up to be cowering, but play anim seperately.
///////////////////////////////////////////////////////////////////////////////
function ShouldCower(bool bSet)
{
//	if(bWantsToCrouch != bSet)
//		ShouldCrouch(bSet);
	if(bWantsToDeathCrawl != bSet)
		ShouldDeathCrawl(bSet);
	bIsCowering=bSet;
}

///////////////////////////////////////////////////////////////////////////////
// Controller is requesting that pawn start deathcrawling
///////////////////////////////////////////////////////////////////////////////
function ShouldDeathCrawl(bool bDoDeathCrawl)
{
	if(!bIsCrouched
		|| !bDoDeathCrawl)
		bWantsToDeathCrawl = bDoDeathCrawl;
}

///////////////////////////////////////////////////////////////////////////////
// after successful deathcrawl starts and ends, called from C
///////////////////////////////////////////////////////////////////////////////
event StartDeathCrawl(float HeightAdjust)
{
	// STUB
}
event EndDeathCrawl(float HeightAdjust)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// PawnSpawner sets some things for you
///////////////////////////////////////////////////////////////////////////////
function InitBySpawner(PawnSpawner initsp)
{
	StartTimeTillStasis		=initsp.InitTimeTillStasis;
	
	if(initsp.InitbCanEnterHomes == 0)
		bCanEnterHomes = false;
	else if(initsp.InitbCanEnterHomes == 1)
		bCanEnterHomes = true;
	
	HomeTag					=initsp.InitHomeTag;

	if(initsp.InitbPlayerIsFriend == 0)
		bPlayerIsFriend = false;
	else if(initsp.InitbPlayerIsFriend == 1)
		bPlayerIsFriend = true;
	
	if(initsp.InitbPlayerIsEnemy == 0)
		bPlayerIsEnemy = false;
	else if(initsp.InitbPlayerIsEnemy == 1)
		bPlayerIsEnemy = true;

	if(initsp.InitGang != "")
		Gang					=initsp.InitGang;
	AIScriptTag				=initsp.InitAIScriptTag;
	StartAnimation			=initsp.InitStartAnimation;

	if(initsp.InitbKeepForMovie== 0)
		bKeepForMovie= false;
	else if(initsp.InitbKeepForMovie== 1)
		bKeepForMovie= true;
	
	// Added later.. see notes in p2pawn and pawnspawner. This format sucks! Sorry.
	if(initsp.InitHealthMax != DEF_SPAWN_FLOAT)
	{
		HealthMax				= initsp.InitHealthMax;
		Health					= HealthMax;
	}

	if(initsp.InitbIgnoresSenses== 0)
		bIgnoresSenses= false;
	else if(initsp.InitbIgnoresSenses== 1)
		bIgnoresSenses= true;

	if(initsp.InitDonutLove != DEF_SPAWN_FLOAT)
		DonutLove				=initsp.InitDonutLove;

	if(initsp.InitbAngryWithHomeInvaders== 0)
		bAngryWithHomeInvaders= false;
	else if(initsp.InitbAngryWithHomeInvaders== 1)
		bAngryWithHomeInvaders= true;

	if(initsp.InitDamageMult != DEF_SPAWN_FLOAT)
		DamageMult				=initsp.InitDamageMult;			
	if(initsp.InitHeroTag != '')
		HeroTag					=initsp.InitHeroTag;			
	if(initsp.InitFriendDamageThreshold != DEF_SPAWN_FLOAT)
		FriendDamageThreshold	=initsp.InitFriendDamageThreshold;

	if(initsp.InitbBodyDisappears== 0)
		bBodyDisappears= false;
	else if(initsp.InitbBodyDisappears== 1)
		bBodyDisappears= true;

	if(initsp.InitbReportDeath== 0)
		bReportDeath= false;
	else if(initsp.InitbReportDeath== 1)
		bReportDeath= true;

	if(initsp.InitbIgnoresHearing== 0)
		bIgnoresHearing= false;
	else if(initsp.InitbIgnoresHearing== 1)
		bIgnoresHearing= true;

	if(initsp.InitbUsePawnSlider== 0)
		bUsePawnSlider= false;
	else if(initsp.InitbUsePawnSlider== 1)
		bUsePawnSlider= true;

	if(initsp.InitbUseForErrands== 0)
		bUseForErrands= false;
	else if(initsp.InitbUseForErrands== 1)
		bUseForErrands= true;

	if(initsp.InitbNoTriggerAttackPlayer== 0)
		bNoTriggerAttackPlayer= false;
	else if(initsp.InitbNoTriggerAttackPlayer== 1)
		bNoTriggerAttackPlayer= true;

	if(initsp.InitbPersistent== 0)
		bPersistent= false;
	else if(initsp.InitbPersistent== 1)
		bPersistent= true;

	if(initsp.InitbCanTeleportWithPlayer== 0)
		bCanTeleportWithPlayer= false;
	else if(initsp.InitbCanTeleportWithPlayer== 1)
		bCanTeleportWithPlayer= true;

	if(initsp.InitSeeViewCone != DEF_SPAWN_FLOAT)
		SeeViewCone				=initsp.InitSeeViewCone;		

	if(initsp.InitbFriendWithAuthority== 0)
		bFriendWithAuthority= false;
	else if(initsp.InitbFriendWithAuthority== 1)
		bFriendWithAuthority= true;

	if(initsp.InitbRiotMode== 0)
		bRiotMode= false;
	else if(initsp.InitbRiotMode== 1)
		bRiotMode= true;
}

///////////////////////////////////////////////////////////////////////////////
// If I'm used for an errand, tell them I died
///////////////////////////////////////////////////////////////////////////////
function CheckForErrandCompleteOnDeath(Controller Killer)
{
}

///////////////////////////////////////////////////////////////////////////////
//	detonate the head
// Moved to FPSPawn so ACTION_KillPawns can call it. - K
///////////////////////////////////////////////////////////////////////////////
function ExplodeHead(vector HitLocation, vector Momentum)
{
}

///////////////////////////////////////////////////////////////////////////////
// To change the anim action of a PropAnimated, we need to copy the
// animaction's properties into the propanimated's animaction. Otherwise it
// gets linked to Transient and that opens up a whole other can of worms.
// Except instead of being full of worms it's full of bees instead, and the
// bees eat the save data and cause the game to crash. Into a train full of bees.
// In short, it's very bad news.
///////////////////////////////////////////////////////////////////////////////
function CopyAnimActionFrom(CustomAnimAction A)
{
	local int i;
	local CustomAnimAction TempAnimAction;
	
	// Create a new temp anim action if it doesn't exist already.
	if (TempAnimAction == None)
		// Make sure it's tied to Level and not something stupid like Transient
		// That would put us right back to square one with the can of bees crashing
		// the game into the train full of bees and that's a Bad Thing (TM)
		TempAnimAction = new(Level) class'CustomAnimAction';
	
	// Copy over the properties from the other anim action
	TempAnimAction.BoltOn = A.BoltOn;
	TempAnimAction.LoopCount = A.LoopCount;
	TempAnimAction.PreTrigger = A.PreTrigger;
	TempAnimAction.PostTrigger = A.PostTrigger;
	TempAnimAction.ExitTrigger = A.ExitTrigger;
	TempAnimAction.CollidingStaticMeshTag = A.CollidingStaticMeshTag;
	TempAnimAction.CollidingStaticMeshRadius = A.CollidingStaticMeshRadius;
	TempAnimAction.Actions.Length = A.Actions.Length;
	
	for (i = 0; i < A.Actions.Length; i++)
	{
		TempAnimAction.Actions[i].AnimName = A.Actions[i].AnimName;
		TempAnimAction.Actions[i].AnimRate = A.Actions[i].AnimRate;
		TempAnimAction.Actions[i].TweenTime = A.Actions[i].TweenTime;
		TempAnimAction.Actions[i].Duration = A.Actions[i].Duration;
		TempAnimAction.Actions[i].LoopCount = A.Actions[i].LoopCount;
		TempAnimAction.Actions[i].PreTrigger = A.Actions[i].PreTrigger;
		TempAnimAction.Actions[i].PostTrigger = A.Actions[i].PostTrigger;
		TempAnimAction.Actions[i].bAddBolton = A.Actions[i].bAddBolton;
		TempAnimAction.Actions[i].bDestroyBolton = A.Actions[i].bDestroyBolton;
	}
	
	CustomAnim = TempAnimAction;
}

defaultproperties
{
	 AmbientGlow=100
	 bTravel=true
     ControllerClass=class'FPSController'
	 DamageMult=1.0
	 HealthMax=100
	 bMuffledHearing=true
     Buoyancy=+00099.000000
     UnderWaterTime=+00020.000000
     BaseEyeHeight=+00070.000000
     EyeHeight=+00070.000000
     CollisionRadius=+00028.000000
     CollisionHeight=+00072.000000
	 CrouchHeight=+52.0
	 CrouchRadius=+25.0
     GroundSpeed=+00600.000000
     AirSpeed=+00600.000000
     WaterSpeed=+00300.000000
     AccelRate=+02048.000000
     JumpZ=+00550.000000
     bCanStrafe=True
     DrawType=DT_Mesh
     LightBrightness=70
     LightHue=40
     LightSaturation=128
     LightRadius=6
     RotationRate=(Pitch=0,Yaw=65000,Roll=2048)
	 AirControl=+0.35
	 bStasis=false
	 bCanCrouch=True
	 bCanClimbLadders=True
	 bCanPickupInventory=True
	 WalkingPct=+0.3
	 MovementPct=1.0
	 bCanWalkOffLedges=true
	 bAllowStasis=true
   	 StartTimeTillStasis=5
	 PathCheckTimeActor=4.0
	 PathCheckTimePoint=4.0
	 SeeViewCone=0.5
	 PeripheralVision=0.5
	 bAngryWithHomeInvaders=true
	 FriendDamageThreshold=1
	 bBodyDisappears=true
	 bReportDeath=true
	 bUsePawnSlider=false
}
