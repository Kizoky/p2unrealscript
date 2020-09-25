///////////////////////////////////////////////////////////////////////////////
// P2GameInfo.
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Postal 2 game (shared by all game variations)
//
//	History:
//              11/06/12 JWB    Added Widescreen Stretch preference.
//
//		07/11/02 MJR	Huge restructuring to use GameState to hold all
//						persistent info and to move most of the errand stuff.
//
//		05/19/02 JMI	Added StartFirstDayURL and QuitToMenuURL for the menu
//						system to jump into single player levels and quit back to
//						the main menu level.
//
//		05/02/02 NPF	Added weekday stuff
//
//		02/07/02 MJR	Added dialog stuff.
//
///////////////////////////////////////////////////////////////////////////////
class P2GameInfo extends FPSGameInfo
	config;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var() String	MainMenuURL;					// URL for main menu

// All characters share a single instance of each dialog class.  This array
// of structs is used to keep track of which classes have already been loaded.
struct SDialogObjects
	{
	var string strClass;
	var P2Dialog dialog;
	};
var array<SDialogObjects> Dialogs;
var bool bDialogTestMode;

var() class<Chameleon>	ChameleonClass;			// Chameleon class to use
var() class<ChamelHead>	ChamelHeadClass;		// ChamelHead class to use
var Chameleon			myChameleon;			// Generates random appearances for pawns
var ChamelHead			myChamelHead;			// Generates random heads for pawns

var int PawnsActive;							// Number of pawns alive in level.
var int SliderPawnsActive;						// Number of pawns alive and not in bSliderStasis in this level. Used
												// with SliderPawnGoal for keeping the right number of
												// pawns alive in the level.
var int SliderPawnsTotal;						// Number of pawns using bUsePawnSlider. Changes to reflect
												// the total pawns that have bUsePawnSlider that are still in the
												// level alive or in stasis. Decrements for each pawn that dies.

// For options menus:
var globalconfig int	FireDetail;				// 10 means normal fire, 0 means less fire
var globalconfig int	SmokeDetail;			// 10 means normal smoke, 0 means no smoke
var globalconfig int	BloodSpouts;			// 1 means visible blood spouts, 0 means no spouts

var globalconfig int	DynamicWeaponLights;	// 1 means weapons dynamically light up the 3d world around
												// them, 0 means no lighting up (has nothing to with muzzle flash art)
var globalconfig int	SplatDetail;			// 10 means lots of splats, 0 means less
var globalconfig int	FluidDetail;			// Fluid lifetime. Value from 1-11 (5 is normal, 1 is short, 10 is really long, 11 is near-infinite)

var globalconfig int	BodiesSliderMax;		// Number of bodies to keep around. 0 means bodies will go away
												// as soon as possible. 50 means 50 bodies will stay until the 51st
												// is around.
var int	BodiesTotal;		// Total number of dead bodies in the world that pertain to the BodiesSliderMax.
							// This only includes humans with bReportDeath set to true.
var FPSPawn BodiesListStart;// Start of list of dead bodies in the level. Use P2Pawn::MyPrevDead/MyNextDead to get
							// around list.
var FPSPawn BodiesListEnd;	// End of same list. Put new bodies at start of list and take old bodies off the end
							// like a queue, FIFO style.

var globalconfig bool	bInventoryHints;		// True means in the game, the inventory items will explain things to you
												// about their use
var globalconfig bool	bGameplayHints;			// True means that certain areas of the game will put messages up on
												// screen about how to play the game.
var globalconfig bool	bReminderHints;			// True means if the player screws around too much on the first
												// day, he'll get reminders to check the map for errands to do.

var globalconfig int	ShadowDetail;			// What kind of shadows the characters have. 0 is none,
												// 1 is circles, 2 is body shaped. Consts are defined below.

// Configs for fog plane. These are used by setting all the zone infos fog planes in the whole leve to equal
// to these, unless the zone info specifies to use it's own. The sniper rifle, when in zoomed mode, will set
// the current zone info based on below values, one the fly.
var globalconfig int	GeneralFogEnd;			// Controls the far plane of fog for all zone infos that
												// Don't have their bUseGlobalFog set to true.
var globalconfig int	GeneralFogStart;			// Like above, but is for near plane
var globalconfig int	SniperFogEnd;			// The sniper rifle is useless in zoomed mode, unless you have
												// the fog plane is pushed away a certain distance. So it's possible
												// here to have the general fog close, but push the fog in sniper
												// mode out some to make it playable/useable.
var globalconfig int	SniperFogStart;			// Near fog plane in sniper mode

var globalconfig int	SliderPawnGoal;			// Number of pawns we want to have alive at any given
												// moment. All pawns count toward this number.
		// When the game starts, SliderPawnGoal number of pawns will be allowed to proceed alive, but the reset will be
		// set to bSliderStasis to true. When one of the ones alive dies, then the bSliderStasis pawn who best fits coming back to
		// life criteria, will be turned back on (rather than spawned--spawning usually causes a frame hitch).
		// The point of this is to reduce the number of pawns moving about at one time, while not reducing the
		// overall number of pawns to kill in a level. PawnsActive is how many pawns are currently alive and
		// not in bSliderStasis in the level.
var globalconfig int   DeathMessageUseNum;// Keep count of which death message we're on. Wrap them when
									// we go past the max. Do not expose this to an options menu.
var globalconfig bool  bPlayerPissedHimselfOut;	// If the player has figured out how to piss himself out, set to true.
									// This way if he dies from being on fire, we know he knows how to do this
									// so we won't tell him again. Do not expose this to an options menu.

var globalconfig int   GameRefVal;	// Reference value for start of game

// These flags control whether various types of log messages are generated for LambController AI.
var globalconfig int LogStates;
var globalconfig int LogDialog;
var globalconfig int LogStasis;

var globalconfig bool	bShowTracers;// Show bullet paths on things.

var globalconfig bool bWidescreenStretch; // 11/06/12 JWB Added

var globalconfig float ScreenXOffset; // 11/23/12 JWB	Added
var globalconfig float ScreenYOffset; // 11/23/12 JWB	Added


var globalconfig int GameDifficultyNumber;
var globalconfig bool bLieberMode;
var globalconfig bool bHestonMode;
var globalconfig bool bTheyHateMeMode;
var globalconfig bool bInsaneoMode;
var globalconfig bool bLudicrousMode;
var globalconfig bool bExpertMode;
var globalconfig bool bCustomMode;

// Need these for user configuration!
var globalconfig bool bSimpleShadows;
var globalconfig bool bPlayerShadows;

// Allow dismemberment.
var globalconfig bool bEnableDismemberment;
var globalconfig bool bEnableDismembermentPhysics;


// This shouldn't be here..
//var globalconfig float DefaultFOV;

struct MatSwap{
	var Material OrigMat;
	var Material NewMat;
};
var array<MatSwap> MatSwaps;		// Put the texture you have in the level in OrigMat to be swapped with
									// NewMat on level load.

// This string should not be modified to change who the code is issued to!  Use the CookieMonster utility
// instead because it avoids the need for recompiling the code and also automatically inserts the proper
// cookie values into various other files.
const IssuedTo = "Running With Scissors$$$$$$$$$$$";

// Used for throwing inventory items
const THROW_ADD_MAG		=	300;
const THROW_BASE_MAG	=	100;

const FIRE_DETAIL_MAX	=	10;					// range is from 0 to 10, with 0 being *some* fire, and 10 being full fire
const SMOKE_DETAIL_MAX  =   10;					// range is from 0 to 10, with 0 being no smoke at all, and 10 being full smoke
const FLUID_DETAIL_MAX	=	11;

const SKY_BOX_TRIGGER	=	'SkyboxTrigger';

const DEFAULT_DIFFICULTY=	5.0;			// halfway between 0 and 10
const LIEBERMAN_DIFFICULTY=	0.0;			// Difficulty has people with only melee weapons at most
const HESTON_DIFFICULTY=	10.0;			// Difficulty gives everyone a weapon, even if they didn't start with one
const INSANE_O_DIFFICULTY=	11.0;			// Very hard AI, and everyone gets weapons, but they can more often
											// get rockets and what not than usual.
const THEYHATEME_DIFFICULTY=12.0;			// Very Hard--cops don't arrest they just attack, and everyone else
											// with a gun hates you on sight.


const SIMPLE_CIRCLE_SHADOWS=	1;
const FULL_BODY_SHADOWS=		2;

const START_GAME_REF	= 10; // Make same as GameRefVal in default properties

const POWERUP_DROP_RATIO	= 0.1;

// Different levels of HUD viewedness. 0 is nothing, max is all

const LogStatesPath				= "Postal2Game.P2GameInfo LogStates"; // ini path
const LogDialogPath				= "Postal2Game.P2GameInfo LogDialog"; // ini path
const LogStasisPath				= "Postal2Game.P2GameInfo LogStasis"; // ini path
const ErrandsReminderPath		= "Postal2Game.P2GameInfo bReminderHints"; // ini path

//var BodyPart crap;

var globalconfig bool bUseWeaponSelector;		// If true, uses new weapon selector.
var globalconfig bool bWeaponSelectorAutoSwitch;// If true, switches weapons while scrolling in weapon selector.

// Change by NickP: MP fix
var globalconfig float DroppedPickupLifespan;
// End

///////////////////////////////////////////////////////////////////////////////
// Startup stuff
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(FireDetail > FIRE_DETAIL_MAX)
		FireDetail = FIRE_DETAIL_MAX;
	else if(FireDetail < 0)
		FireDetail = 0;
	if(SmokeDetail > SMOKE_DETAIL_MAX)
		SmokeDetail = SMOKE_DETAIL_MAX;
	else if(SmokeDetail < 0)
		SmokeDetail = 0;
	if (FluidDetail > FLUID_DETAIL_MAX)
		FluidDetail = FLUID_DETAIL_MAX;
	else if (FluidDetail < 1)
		FluidDetail = 1;
}

///////////////////////////////////////////////////////////////////////////////
// This is for testing the new bDeleteMe functionality
///////////////////////////////////////////////////////////////////////////////
/*exec function MakeCrap()
{
	local class<BodyPart> bodyclass;

	Super.PreBeginPlay();

	bodyclass = class<BodyPart>(DynamicLoadObject("BasePeople.Head", class'class'));
	crap = spawn(bodyclass);
	Log("Created crap="$crap);
	crap.Destroy();
	Log("After crap.Destroy(), crap.bDeleteMe="$crap.bDeleteMe);
	if (crap.Location.Z == 0)
		Log("blah");
	Log("After crap.Destroy(), crap.Location="$crap.Location);
}

exec function TestCrap()
{
	Log("Checking crap(): crap="$crap);
	Log("Checking crap(), crap.bDeleteMe="$crap.bDeleteMe);
}*/


///////////////////////////////////////////////////////////////////////////////
// Set log stats. Setting 1 turns it on, setting > 1 turns it on and saves it
// setting 0 turns it off, setting < 0 turns it off and saves it.
///////////////////////////////////////////////////////////////////////////////
exec function SetLogStates(int T)
{
	if(T > 1)
	{
		LogStates = 1;
		ConsoleCommand("set "@LogStatesPath@LogStates);
	}
	else if(T < 0)
	{
		LogStates = 0;
		ConsoleCommand("set "@LogStatesPath@LogStates);
	}
	else
		LogStates = T;
}
exec function SetLogDialog(int T)
{
	if(T > 1)
	{
		LogDialog = 1;
		ConsoleCommand("set "@LogDialogPath@LogDialog);
	}
	else if(T < 0)
	{
		LogDialog = 0;
		ConsoleCommand("set "@LogDialogPath@LogDialog);
	}
	else
		LogDialog = T;
}
exec function SetLogStasis(int T)
{
	if(T > 1)
	{
		LogStasis = 1;
		ConsoleCommand("set "@LogStasisPath@LogStasis);
	}
	else if(T < 0)
	{
		LogStasis = 0;
		ConsoleCommand("set "@LogStasisPath@LogStasis);
	}
	else
		LogStasis = T;
}

///////////////////////////////////////////////////////////////////////////////
// Set errand reminder status
///////////////////////////////////////////////////////////////////////////////
function SetErrandReminder(bool bSet)
{
	bReminderHints=bSet;
	ConsoleCommand("set "@ErrandsReminderPath@bReminderHints);
}

///////////////////////////////////////////////////////////////////////////////
// Send player to specified URL.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerEx(PlayerController player, String URL, optional ETravelType TravelType, optional ETravelItems TravelItems)
	{
	// Must stop SceneManagers before going to a new level
	StopSceneManagers();

	Super.SendPlayerEx(player, URL, TravelType, TravelItems);
	}

///////////////////////////////////////////////////////////////////////////////
// Stop any active SceneManagers
///////////////////////////////////////////////////////////////////////////////
function StopSceneManagers()
	{
	local SceneManager SM;

	// Must cleanup SceneManagers before going to new level
	foreach AllActors (class'SceneManager', SM)
		SM.PreTravel();
	}

///////////////////////////////////////////////////////////////////////////////
// Check whether a cinematic is running
///////////////////////////////////////////////////////////////////////////////
function bool IsCinematic()
	{
	local SceneManager SM;

	foreach AllActors (class'SceneManager', SM)
		{
		if (SM.bIsRunning)
			return true;
		}

	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Modify the fire particle number by the detail level specified
///////////////////////////////////////////////////////////////////////////////
/*function int ModifyByFireDetail(int startnum)
{
	if(FireDetail == FIRE_DETAIL_MAX)	// full fire
		return startnum;
	else
	{
		startnum = (startnum / (FIRE_DETAIL_MAX - FireDetail));
		if(startnum <= 0)
			startnum = 1;
		return startnum;
	}
}*/
// Change by NickP: MP fix
static function int ModifyByFireDetail(int startnum)
{
	if(default.FireDetail == FIRE_DETAIL_MAX)	// full fire
		return startnum;
	else
	{
		startnum = (startnum / (FIRE_DETAIL_MAX - default.FireDetail));
		if(startnum <= 0)
			startnum = 1;
		return startnum;
	}
}
// End

///////////////////////////////////////////////////////////////////////////////
// Modify the smoke particle number by the detail level specified
// Make none come out of the detail level is 0.
///////////////////////////////////////////////////////////////////////////////
/*function int ModifyBySmokeDetail(int startnum)
{
	if(SmokeDetail == SMOKE_DETAIL_MAX)	// full smoke
		return startnum;
	else if(SmokeDetail == 0)	// no smoke
		return 0;
	else
	{
		startnum = (startnum / (SMOKE_DETAIL_MAX - SmokeDetail));
		if(startnum <= 0)
			startnum = 1;
		return startnum;
	}
}*/
// Change by NickP: MP fix
static function int ModifyBySmokeDetail(int startnum)
{
	if(default.SmokeDetail == SMOKE_DETAIL_MAX)	// full smoke
		return startnum;
	else if(default.SmokeDetail == 0)	// no smoke
		return 0;
	else
	{
		startnum = (startnum / (SMOKE_DETAIL_MAX - default.SmokeDetail));
		if(startnum <= 0)
			startnum = 1;
		return startnum;
	}
}
// End

///////////////////////////////////////////////////////////////////////////////
// Modifies lifetime based on fluid life
///////////////////////////////////////////////////////////////////////////////
function float ModifyByFluidDetail(float startnum)
{
	// Values from 1-11.
	// 5 is normal
	// 1-4 are 6/10, 7/10, 8/10, 9/10
	// 6-10 are 2x, 3x, 4x, 5x, 6x
	// 11 is effectively infinite
	
	if (FluidDetail == 5)
		return startnum;
	else if (FluidDetail == 11)
		return 3600.0;
	else if (FluidDetail < 5)
		return (5.0 + FluidDetail)/10.0 * startnum;
	else
		return (FluidDetail - 4.0) * startnum;
}


///////////////////////////////////////////////////////////////////////////////
// True, you get blood feeders from all bodies and from any that
// have their heads popped off, false, your system is too slow to support them
///////////////////////////////////////////////////////////////////////////////
function bool AllowBloodSpouts()
{
	if(BloodSpouts != 0)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// True, means weapons dynamically light up the 3d world around
// them, false means no lighting up (has nothing to with muzzle flash art)
///////////////////////////////////////////////////////////////////////////////
function bool AllowDynamicWeaponLights()
{
	if(DynamicWeaponLights != 0)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Get the splat detail.. longer lasting splats, the higher the number
///////////////////////////////////////////////////////////////////////////////
function int GetSplatDetail()
{
	return SplatDetail;
}

///////////////////////////////////////////////////////////////////////////////
// Get the max number of bodies allowed
///////////////////////////////////////////////////////////////////////////////
function int GetBodiesMax()
{
	return BodiesSliderMax;
}

///////////////////////////////////////////////////////////////////////////////
// 11/06/12 JWB
// Get whether the user wants to use widescreen stretch
///////////////////////////////////////////////////////////////////////////////
function bool GetWidescreenStretch()
{
	return bWidescreenStretch;
    // Fix this eventually.
    //return bool(ConsoleCommand("get Postal2Game.P2GameInfo bWidescreenStretch"));
}

///////////////////////////////////////////////////////////////////////////////
// 11/23/12 JWB
// Get Screen X Offset
///////////////////////////////////////////////////////////////////////////////
function float GetScreenXOffset()
{
	return ScreenXOffset;
}

///////////////////////////////////////////////////////////////////////////////
// 11/23/12 JWB
// Get Screen Y Offset
///////////////////////////////////////////////////////////////////////////////
function float GetScreenYOffset()
{
	return ScreenYOffset;
}

///////////////////////////////////////////////////////////////////////////////
// Get the number of bodies that are currently dead, that play along with the
// BodiesSliderMax.
///////////////////////////////////////////////////////////////////////////////
function int GetBodiesTotal()
{
	return BodiesTotal;
}

///////////////////////////////////////////////////////////////////////////////
// If this guy is at the end of the bodies list and we're over our goal, then
// remove him.
///////////////////////////////////////////////////////////////////////////////
function bool CanRemoveThisBody(FPSPawn RemoveMe)
{
	//log(self$" CanRemoveThisBody remove "$RemoveMe$" end "$BodiesListEnd);
	if(BodiesTotal > BodiesSliderMax
		&& BodiesListEnd == RemoveMe)
		return true;
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Given a new dead body, link it into the list.
// New bodies go in at the start, old bodies come off the end, FIFO style.
///////////////////////////////////////////////////////////////////////////////
function AddDeadBody(FPSPawn NewBody)
{
	local FPSPawn nextone;

	if(NewBody != None
		&& !NewBody.bDeleteMe)
	{
		if(BodiesListStart == None)
		{
			BodiesListStart=NewBody;
			BodiesListEnd=NewBody;
		}
		else
		{
			// Link new body to start of current list
			NewBody.MyNextDead = BodiesListStart;
			// Link old 'start' body back to me
			BodiesListStart.MyPrevDead = NewBody;
			// Set the new start to be this new body
			BodiesListStart = NewBody;
			// Increase the total number of dead bodies
		}
		BodiesTotal++;
		//log(self$" Adding bodies start "$BodiesListStart$" end "$BodiesListEnd$" total "$BodiesTotal);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Remove a dead body.
// This should only get called in P2Pawn Destroyed and not through other
// means, because while we may know when we want to destroy a pawn from the
// dead body markers, we don't know when the karma might just decide to destroy
// a ragdolled pawn for us.
///////////////////////////////////////////////////////////////////////////////
function RemoveDeadBody(FPSPawn NewBody)
{
	local FPSPawn curone;

	// Find the new body we sent in and remove it from the list, while relinking
	// the doubly-linked list
	if(NewBody != None)
	{
		curone = BodiesListStart;
		while(curone != None
			&& curone != NewBody)
		{
			curone = curone.MyNextDead;
		}
		// Found it, so remove it
		if(curone == NewBody)
		{
			// Handle the case of no more bodies in the list
			if(curone.MyPrevDead == None
				&& curone.MyNextDead == None)
			{
				BodiesListStart = None;
				BodiesListEnd = None;
				// If we're not removing the last one, then we've got a problem
				if(BodiesTotal > 1)
					warn(" thought it was end of list, but has more bodies, last one: "$NewBody);
			}
			else // more than one in the list
			{
				// Link the one before, to the one after
				if(curone.MyPrevDead != None)
				{
					curone.MyPrevDead.MyNextDead = curone.MyNextDead;
				}
				else // the one we're removing was the start, so reposition to the
					// one after the current one
				{
					if(curone.MyNextDead != None)
					{
						BodiesListStart = curone.MyNextDead;
						BodiesListStart.MyPrevDead = None;
					}
				}
				// Link the one after to the one before
				if(curone.MyNextDead != None)
				{
					curone.MyNextDead.MyPrevDead = curone.MyPrevDead;
				}
				else // the one we're removing is the last one, so reposition it to the
					// one before the current one
				{
					if(curone.MyPrevDead != None)
					{
						BodiesListEnd = curone.MyPrevDead;
						BodiesListEnd.MyNextDead = None;
					}
				}
			}

			BodiesTotal--;
			//log(self$" REmove specific: "$NewBody$" bodies start "$BodiesListStart$" end "$BodiesListEnd$" total "$BodiesTotal);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Try to return the true difficulty
///////////////////////////////////////////////////////////////////////////////
function float GetGameDifficulty()
{
	return GameDifficulty;
}

///////////////////////////////////////////////////////////////////////////////
// Get how far off the base difficulty (of average) we are
///////////////////////////////////////////////////////////////////////////////
function float GetDifficultyOffset()
{
	return (GetGameDifficulty() - (DEFAULT_DIFFICULTY));
}

///////////////////////////////////////////////////////////////////////////////
// In super-easy Lieberman mode
///////////////////////////////////////////////////////////////////////////////
function bool InLiebermode()
{
	//return (GetGameDifficulty() == LIEBERMAN_DIFFICULTY);
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// In super-hard Heston mode
///////////////////////////////////////////////////////////////////////////////
function bool InHestonmode()
{
	//return (GetGameDifficulty() == HESTON_DIFFICULTY);
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// In They Hate Me mode. Cops don't arrest you and everyone hates you that has
// a weapon. very Hard
///////////////////////////////////////////////////////////////////////////////
function bool TheyHateMeMode()
{
	//return (GetGameDifficulty() == THEYHATEME_DIFFICULTY);
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// In super-duper-hard Insane-o mode
///////////////////////////////////////////////////////////////////////////////
function bool InInsanemode()
{
	//return (GetGameDifficulty() == INSANE_O_DIFFICULTY);
	// STUB
	return false;
}

// returns true in Nightmare mode (no save-scumming, etc)
function bool InNightmareMode()
{
	// STUB
	return false;
}

function bool InLudicrousMode()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Return true when they want the complex body shadows.
///////////////////////////////////////////////////////////////////////////////
function bool FullBodyShadows()
{
	if(ShadowDetail == FULL_BODY_SHADOWS)
		return true;
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// True means that certain areas of the game will put messages up on
// screen about how to play the game.
///////////////////////////////////////////////////////////////////////////////
function bool AllowInventoryHints()
{
	return bInventoryHints;
}

///////////////////////////////////////////////////////////////////////////////
// Reach into gamestate to do this.
// Reset any hints for inventory/weapons, so that they will show up again
///////////////////////////////////////////////////////////////////////////////
function ClearInventoryHints()
{
}

///////////////////////////////////////////////////////////////////////////////
// True means that certain areas of the game will put messages up on
// screen about how to play the game.
///////////////////////////////////////////////////////////////////////////////
function bool AllowGameplayHints()
{
	return bGameplayHints;
}

///////////////////////////////////////////////////////////////////////////////
// True means if the player screws around too much on the first
// day, he'll get reminders to check the map for errands to do.
///////////////////////////////////////////////////////////////////////////////
function bool AllowReminderHints()
{
	return (bReminderHints);
}

///////////////////////////////////////////////////////////////////////////////
// Go through all the zones in the level and set their fog planes (if they allow
// it) to the gameinfo's plane numbers.
///////////////////////////////////////////////////////////////////////////////
function SetZoneFogPlanes()
{
	local ZoneInfo zi;

	//log(self$" SetZoneFogPlanes, start "$GeneralFogStart$", end "$GeneralFogEnd);
	foreach AllActors (class'ZoneInfo', zi)
	{
		if(zi.class != class'SkyZoneInfo'
			&& zi.bUseGlobalFog)
		{
			//log(self$" setting fog in zone "$zi$" old start "$zi.DistanceFogStart$" old end "$zi.DistanceFogEnd);
			zi.DistanceFogStart = GeneralFogStart;
			zi.DistanceFogEnd = GeneralFogEnd;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// For this actor, find the zone he's in and set the zone fog near/far planes
// to be those of the General settings
///////////////////////////////////////////////////////////////////////////////
function SetGeneralZoneFog(Actor Other)
{
	if(Other.Region.Zone.bUseGlobalFog)
	{
		Other.Region.Zone.DistanceFogStart = GeneralFogStart;
		Other.Region.Zone.DistanceFogEnd = GeneralFogEnd;
	}
}

///////////////////////////////////////////////////////////////////////////////
// For this actor, find the zone he's in and set the zone fog near/far planes
// to be those of the Sniper settings
///////////////////////////////////////////////////////////////////////////////
function SetSniperZoneFog(Actor Other)
{
	if(Other.Region.Zone.bUseGlobalFog)
	{
		Other.Region.Zone.DistanceFogStart = SniperFogStart;
		Other.Region.Zone.DistanceFogEnd = SniperFogEnd;
	}
}

///////////////////////////////////////////////////////////////////////////////
// For a newly entered zone, set it to sniper fog
///////////////////////////////////////////////////////////////////////////////
function SetNewSniperZoneFog(ZoneInfo NewZone)
{
	if(NewZone.bUseGlobalFog)
	{
		NewZone.DistanceFogStart = SniperFogStart;
		NewZone.DistanceFogEnd = SniperFogEnd;
	}
}

///////////////////////////////////////////////////////////////////////////////
// This is called to indicate the GameInfo has become valid.
///////////////////////////////////////////////////////////////////////////////
function GameInfoIsNowValid()
	{
	Super.GameInfoIsNowValid();
	}

///////////////////////////////////////////////////////////////////////////////
// Spawn any default inventory for the player.
///////////////////////////////////////////////////////////////////////////////
function AddDefaultInventory( pawn PlayerPawn )
	{
	SetPlayerDefaults(PlayerPawn);
	}

///////////////////////////////////////////////////////////////////////////////
// Decide how many to drop at the start, goes with DiscardInventory
///////////////////////////////////////////////////////////////////////////////
function DiscardPowerupStart(out int checkamount, P2PowerupInv powerupcheck, P2Pawn pawncheck)
{
	checkamount = powerupcheck.Amount;
}
///////////////////////////////////////////////////////////////////////////////
// Make sure what you dropped came out, goes with DiscardInventory
///////////////////////////////////////////////////////////////////////////////
function DiscardPowerupVerify(out int checkamount, P2PowerupInv powerupcheck, P2Pawn pawncheck)
{
	if(powerupcheck != None)
	{
		if(powerupcheck.Amount == checkamount)
			{
			if(powerupcheck.bThrowIndividually)
				checkamount--;
			else
				checkamount = 0;
			powerupcheck.Amount = checkamount;
			}
		else
			checkamount = powerupcheck.Amount;
	}
	else
		checkamount = 0;
}

///////////////////////////////////////////////////////////////////////////////
// Discard a character's inventory after he dies.
// Override so we can force the weapons to stop firing.
// In single player mode, make players only drop 10% or one of each powerup so
// we avoid slowdown of having tons of items later in the game.
///////////////////////////////////////////////////////////////////////////////
function DiscardInventory( Pawn Other )
	{
	local actor dropped;
	local inventory Inv,Next;
	local float speed;
	local vector throwvel;
	local P2Weapon weapcheck;
	local P2PowerupInv powerupcheck;
	local P2Pawn pawncheck;
	local int checkamount;
	local int Count;

	pawncheck = P2Pawn(Other);
	if(pawncheck == None)
		return;

	// Add in armor to be dropped, if you have it
	pawncheck.DropArmorDead();

	// Save the speed of this pawn
	speed = VSize(pawncheck.Velocity);

	// Make sure he can't pick up anything anymore
	pawncheck.bCanPickupInventory=false;

	Inv = pawncheck.Inventory;
	while ( Inv != None )
		{
		Next = Inv.Inventory;

		// Handle the weapons
		weapcheck = P2Weapon(Inv);
		if(weapcheck!=None)
			{
			if(weapcheck.bCanThrow && weapcheck.HasAmmo() )
				{
				if ( weapcheck.PickupAmmoCount == 0 )
					weapcheck.PickupAmmoCount = 1;

				// if it was the main weapon he was carrying, then shoot it straight out in front of him
				if(weapcheck == pawncheck.Weapon)
					{
					if (speed != 0)
						pawncheck.TossWeapon(Normal(pawncheck.Velocity/speed + 0.5 * VRand()) * (speed + 280));
					else
						pawncheck.TossWeapon(vect(0,0,0));
					}
				else	// otherwise, randomly spit it out somewhere
					{
					throwvel = VRand();
					throwvel.z =0.5;
					throwvel = ((speed + THROW_ADD_MAG)*FRand() + THROW_BASE_MAG)*throwvel;
					pawncheck.TossThisInventory(throwvel, weapcheck);//Normal(pawncheck.Velocity/speed + 0.5 * VRand()) * (speed + 280));
					}
				}
			else if(weapcheck != None)
				{
				// It won't be dropped, like the Urethra, but we still need it to stop firing.
				weapcheck.ForceEndFire();
				}
			}
		else // check for non-weapons
			{
			// Handle the powerups
			powerupcheck = P2PowerupInv(Inv);
			if(powerupcheck != None)
				{
				// Because DropFrom doesn't allow tell you if it failed or not (it fails when you try
				// to drop something and it can't do spawn it because there's a wall or something)
				// then we keep track of things with this outside count, to make sure everything is dropped
				// even if it fails.
				DiscardPowerupStart(checkamount, powerupcheck, pawncheck);

				while(checkamount > 0)//powerupcheck.Amount > 0)
					{
					throwvel = VRand();
					throwvel.z =0.4;
					throwvel = ((speed + THROW_ADD_MAG)*FRand() + THROW_BASE_MAG)*throwvel;
					pawncheck.TossThisInventory(throwvel, powerupcheck);

					DiscardPowerupVerify(checkamount, powerupcheck, pawncheck);
					}
				}
			}

		Count++;
		if (Count > 5000)
			break;

		// Move along and destroy your inventory
		if (!Inv.bDeleteMe)
			Inv.Destroy();

		Inv = Next;
		}

	// clear his vals
	pawncheck.Inventory = None;
	pawncheck.Weapon = None;
	pawncheck.SelectedItem = None;
	}

///////////////////////////////////////////////////////////////////////////////
// Return true if the difficulty level is low enough to be considered 'easy'
///////////////////////////////////////////////////////////////////////////////
function bool InEasyMode()
{
	if(GetGameDifficulty() < 6)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Get shared Chameleon.  Creates one if it doesn't exist.
///////////////////////////////////////////////////////////////////////////////
function Chameleon GetChameleon()
	{
	if (myChameleon == None)
		{
		myChameleon = spawn(ChameleonClass);
		if (myChameleon == None)
			Warn("Couldn't spawn "$ChameleonClass);
		}
	return myChameleon;
	}

///////////////////////////////////////////////////////////////////////////////
// Get shared ChamelHead.  Creates one if it doesn't exist.
///////////////////////////////////////////////////////////////////////////////
function ChamelHead GetChamelHead()
	{
	if (myChamelHead == None)
		{
		myChamelHead = spawn(ChamelHeadClass);
		if (myChamelHead == None)
			Warn("Couldn't spawn "$ChamelHeadClass);
		}
	return myChamelHead;
	}

///////////////////////////////////////////////////////////////////////////////
// View chamaleon usage statistics
///////////////////////////////////////////////////////////////////////////////
exec function ChamUsage()
	{
	if (myChameleon != None)
		myChameleon.LogUsage();
	else
		Log("It appers that Chameleon has not been used yet");

	if (myChamelHead != None)
		myChamelHead.LogUsage();
	else
		Log("It appers that ChamelHead has not been used yet");
	}

///////////////////////////////////////////////////////////////////////////////
// Get a reference to the shared instance of the specified dialog class.
//
// All objects share a single instance of each dialog class, and this is the
// sole method by which they should obtain a reference to that instance.
//
// Unreal script's garbage collection should be able to get rid of any
// dialog classes that aren't used once all the references to it are gone.
///////////////////////////////////////////////////////////////////////////////
function P2Dialog GetDialogObj(string strClass)
	{
	local class<P2Dialog> dialogclass;
	local P2Dialog dialog;
	local int i;

	// Check if specified class was already loaded
	dialog = None;
	for (i = 0; i < Dialogs.Length; i++)
		{
		if (Dialogs[i].strClass == strClass)
			{
			// Return reference to existing object
			dialog = Dialogs[i].dialog;
			break;
			}
		}

	// If not already loaded, then load it now
	if (dialog == None)
		{
		// Try to load specified class
		dialogclass = class<P2Dialog>(DynamicLoadObject(strClass, class'Class'));
		if (dialogclass != None)
			{
			// Try to spawn an object of that class
			dialog = spawn(dialogclass);
			if (dialog != None)
				{
				// Add class to list
				Dialogs.Insert(i, 1);
				Dialogs[i].dialog = dialog;
				Dialogs[i].strClass = strClass;
				}
			else
				{
				Warn("GetDialogObj() - spawn failed for class "$dialogclass);
				}
			}
		else
			{
			Warn("GetDialogObj() - DynamicLoadObject() failed using name "$strClass);
			}
		}

	return dialog;
	}

///////////////////////////////////////////////////////////////////////////////
// Tell all dialogs about new setting for filtering foul language
///////////////////////////////////////////////////////////////////////////////
function SetDialogFilterFoulLanguage()
	{
	local int i;

	for (i = 0; i < Dialogs.Length; i++)
		Dialogs[i].dialog.SetFilterFoulLanguage();
	}

///////////////////////////////////////////////////////////////////////////////
// Tell all dialogs about new setting for bleeping foul language
///////////////////////////////////////////////////////////////////////////////
function SetDialogBleepFoulLanguage()
	{
	local int i;

	for (i = 0; i < Dialogs.Length; i++)
		Dialogs[i].dialog.SetBleepFoulLanguage();
	}

///////////////////////////////////////////////////////////////////////////////
// Tell all dialogs about new setting for memory usage
///////////////////////////////////////////////////////////////////////////////
function SetDialogMemUsage()
	{
	local int i;

	for (i = 0; i < Dialogs.Length; i++)
		Dialogs[i].dialog.SetMemUsage();
	}

///////////////////////////////////////////////////////////////////////////////
// Display debug info
///////////////////////////////////////////////////////////////////////////////
event RenderOverlays(Canvas Canvas)
	{
	Super.RenderOverlays(Canvas);
	}

///////////////////////////////////////////////////////////////////////////////
// Check if the current map is the "main menu" map
///////////////////////////////////////////////////////////////////////////////
function bool IsMainMenuMap()
	{
	//log("IsMainMenuMap"@Level.GetLocalUrl()@"vs."@MainMenuURL);
	return ParseLevelName(Level.GetLocalURL()) ~= ParseLevelName(MainMenuURL);
	}

///////////////////////////////////////////////////////////////////////////////
// Parse the level name out of the URL.  This only handles simple URL's that
// look like any of the following:
//
//		LevelName
//		LevelName?anything_else
//		LevelName#TelepadName
//		LevelName#TelepadName?anything_else
//
///////////////////////////////////////////////////////////////////////////////
function String ParseLevelName(String URL)
	{
	local int i, j;

	// Not sure which of these will come first in the string, so use whichever
	// occurs sooner and whatever is to the left of it is the level name.
	i = InStr(URL, "#");
	j = InStr(URL, "?");
	if (i >= 0)
		{
		if (j >= 0)
			i = Min(i, j);
		}
	else
		i = j;

	if (i >= 0)
		return Left(URL, i);

	return URL;
	}

///////////////////////////////////////////////////////////////////////////////
// Get string saying who this version of the game was issued to
///////////////////////////////////////////////////////////////////////////////
function String GetIssuedTo()
	{
	local String Trimmed;

	Trimmed = Left(IssuedTo, InStr(IssuedTo, "$"));
	if (Trimmed == "Running With Scissors")
		Trimmed = "";

	return Trimmed;
	}

///////////////////////////////////////////////////////////////////////////////
// Do anything special to the static meshes at the start of the level.
///////////////////////////////////////////////////////////////////////////////
function CheckStaticMesh(StaticMeshActor stm)
{
	local int i;

	if(stm != None)
	{
		if(stm.Skins.Length > 0)
		{
			for(i=0; i<MatSwaps.Length; i++)
			{
				if(stm.Skins[0] == MatSwaps[i].OrigMat)
				{
					stm.Skins[0] = MatSwaps[i].NewMat;
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Cheat that says the player can kill anyone in one shot to the head from the
// pistol or machinegun.
///////////////////////////////////////////////////////////////////////////////
function bool PlayerGetsHeadShots()
{
	return false;
}

function P2Player GetPlayer()
{
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// Cheat to toggle menu between "main" and "game" modes
///////////////////////////////////////////////////////////////////////////////
exec function MenuMode()
	{
	if(GetPlayer() != None)
		P2RootWindow(GetPlayer().Player.InteractionMaster.BaseMenu).MenuMode();
	}
	
// ErikFOV Change: For Nick's coop
function P2Player xGetValidPlayerFor(LambController useController)
{
	return None;
}
//End

// Change by NickP: MP fix
function NotifyPickupDropped(Pickup aPickup)
{
	if(!bIsSingleplayer && aPickup != None)
		aPickup.LifeSpan = DroppedPickupLifespan;
}
// End

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	// Change by NickP: MP fix
	DroppedPickupLifespan=30.0
	// End

     MainMenuURL="Startup"
     ChameleonClass=Class'Postal2Game.Chameleon'
     ChamelHeadClass=Class'Postal2Game.ChamelHead'
     FireDetail=10
     SmokeDetail=10
	 FluidDetail=5
     BloodSpouts=1
     SplatDetail=10
     BodiesSliderMax=200
     bInventoryHints=True
     bGameplayHints=True
     GeneralFogEnd=16000
     GeneralFogStart=2400
     SniperFogEnd=16000
     SniperFogStart=2400
     SliderPawnGoal=30
     GameRefVal=32
     bShowTracers=True
     MatSwaps(0)=(OrigMat=Texture'Josh-textures.signs.game_banner_2',NewMat=Texture'Josh-textures.signs.game_banner_5')
     MatSwaps(1)=(OrigMat=Texture'Timb.arcade.Game_FagHunter',NewMat=Texture'Timb.arcade.Game_BastardFish')
     HUDType="Postal2Game.P2HUD"
     GameName="Postal2"
     PlayerControllerClassName="GameTypes.DudePlayer"
	 bEnableDismemberment=true
	 bEnableDismembermentPhysics=true
	bUseWeaponSelector=true
}
