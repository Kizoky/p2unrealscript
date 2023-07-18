///////////////////////////////////////////////////////////////////////////////
// P2GameInfoSingle.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for single player games
//
// History:
//	02/19/03 JMI	Moved save slot ownership here from ShellInfo which seems
//					to have simplified things nicely.
//
//	09/16/02 MJR	Started by pulling stuff out of P2GameInfo.
//
// 4/29 Kamek - backported game timer from AW7
// 8/11 Kamek - backport AW stuff.
///////////////////////////////////////////////////////////////////////////////
class P2GameInfoSingle extends P2GameInfo;

///////////////////////////////////////////////////////////////////////////////
// Constants
///////////////////////////////////////////////////////////////////////////////
// Save slot definitions
const QUICKSAVE_SLOT			= 20;
const AUTOSAVE_SLOT				= 21;
const CHECKPOINT_SLOT			= 19;
const MAX_SAVE_ATTEMPTS = 3; // Three attempts

const LOADGAME_URL				= "?load=";

const RUNNING_LOOP_TIME			= 1.0;

const REVIVE_CHECK_TIME			= 12.0;			// How often to check about reviving pawns
												// if we're below our SliderPawnGoal limit.
const SLIDER_PAWN_DIST			= 800;			// Closest distance a pawn can be before he
												// can be pulled out of bSliderStasis.
const VIEW_CONE_SLIDER_PAWN		= 0.1;			// Dot product value from view of player to pawn
												// possibly to be brought of out slider stasis. We want
												// this to be so he's not seeing them come out.
const REF_STARTUP				= 5000;
const FOVER_SUM					= 5323;
const GOVER_SUM					= 4817;
const HOVER_SUM					= 7689;

const COOL_FACTOR				= 1000;

const SLEEP_TIME_INC			= 1.0;			// For a complex sleep loop. We sleep this time and check
												// some functions more often than others.

// The following are groups as specified by the unreal editor. Generally a group can only be
// created when an object is selected. It is suggested that one select the playerstart,
// then add all groups necessary for the game. In our immediate single-player case
// we would want
// DAY_A, DAY_B, DAY_C, DAY_D, DAY_E, GOODGUY, BADGUY
// The day's are used to allow things only for certain days in the game. Goodguy allows
// things only for when the player has picked to play as the 'good' dude. Badguy is
// for things when the player has picked the normal dude.
// Day specification code
const DAY_STR					=	"DAY_";
const DAY_STR_LEN				=	4;
const DAY_START_ASCII			=	65;
//const W
// Good/evil dude
const GOOD_GUY_GROUP			=	"GOODGUY";
const BAD_GUY_GROUP				=	"BADGUY";
// Hard/easy difficulty
const EASY_GROUP				=	"EASY_";
const HARD_GROUP				=	"HARD_";

const SEQ_ADD					=	100;

//ini paths
const InfoSeqPath				=	"Postal2Game.P2GameInfoSingle InfoSeqTime"; // ini path
const RefPath					=	"Postal2Game.P2GameInfo GameRefVal"; // keep in super's ini spot
const EGamePath					=	"Postal2Game.P2GameInfoSingle bEGameStart";
const EndCoolPath				=	"Postal2Game.P2GameInfoSingle EndCool";
const CoolStartPath				=	"Postal2Game.P2GameInfoSingle CoolStart";
const FOverPath					=	"Postal2Game.P2GameInfoSingle Fover";
const GOverPath					=	"Postal2Game.P2GameInfoSingle Gover";
const HOverPath					=	"Postal2Game.P2GameInfoSingle Hover";
const TimesBeatenGamePath		=	"Postal2Game.P2GameInfoSingle TimesBeatenGame";
const TimesBeatenAWPath			=	"Postal2Game.P2GameInfoSingle TimesBeatenAW";
const TimesBeatenAWPPath		=	"Postal2Game.P2GameInfoSingle TimesBeatenAWP";
const DifficultyPath			=	"Postal2Game.P2GameInfo GameDifficulty";
const LieberPath = "Postal2Game.P2GameInfo bLieberMode";
const HestonPath = "Postal2Game.P2GameInfo bHestonMode";
const TheyHateMePath = "Postal2Game.P2GameInfo bTheyHateMeMode";
const InsaneoPath = "Postal2Game.P2GameInfo bInsaneoMode";
const LudicrousPath = "Postal2Game.P2GameInfo bLudicrousMode";
const ExpertPath = "Postal2Game.P2GameInfo bExpertMode";
const MasochistPath = "Postal2Game.P2GameInfo bMasochistMode";
const VeteranPath = "Postal2Game.P2GameInfo bVeteranMode";
const MeleePath = "Postal2Game.P2GameInfo bMeeleMode";
const HardLieberPath = "Postal2Game.P2GameInfo bHardLieberMode";
const NukeModePath = "Postal2Game.P2GameInfo bNukeMode";
const CustomPath = "Postal2Game.P2GameInfo bCustomMode";

const FinStopPath=	"Postal2Game.P2GameInfoSingle FinStop"; // ini path
const MultCastPath=	"Postal2Game.P2GameInfoSingle MultCast"; // ini path
const TunnelingPath="Postal2Game.P2GameInfoSingle Tunneling"; // ini path

const CAST_MAX	= 42;

const P2_GAME_PATH = "GameTypes.GameSinglePlayer";
const AW_GAME_PATH = "GameTypes.AWGameSPFinal";
const AWP_GAME_PATH = "GameTypes.AWPGameInfo";

// Difficulty numbers for Hestonworld and up
const DIFFICULTY_NUMBER_LUDICROUS = 15;
const DIFFICULTY_NUMBER_IMPOSSIBLE = 14;
const DIFFICULTY_NUMBER_POSTAL = 13;
const DIFFICULTY_NUMBER_THEYHATEME = 12;
const DIFFICULTY_NUMBER_INSANE = 11;
const DIFFICULTY_NUMBER_HESTON = 10;

const NIGHT_MODE_HOLIDAY = 'NightMode';

///////////////////////////////////////////////////////////////////////////////
// Structs
///////////////////////////////////////////////////////////////////////////////
// Date-limit certain world objects based on user's computer date (seasonal DLC)
struct DateRange {
	var() range Year, Month, Day;
};
struct HolidayDef {
	var() name HolidayName;			// Name of holiday
	//ErikFOV Change: For Licalization
		//var() string DisplayName;		// Display name
		//var() string Description;		// Description
	//end
	var() array<DateRange> Dates;	// Range of dates in which holiday is considered valid.
									// If the current date falls within ANY of the date ranges, it's considered valid.
};

///////////////////////////////////////////////////////////////////////////////
// Public vars
///////////////////////////////////////////////////////////////////////////////
var() export editinline array<DayBase> Days;	// All the days and their errands

var() localized string GameNameShort;			// Short name of game (for save/load menu)
var() localized string GameDescription;			// Short description of game (for Workshop browser)

var() String	IntroURL;						// URL for intro
var() String	StartFirstDayURL;				// URL for starting the first day
var() String	StartNextDayURL;				// URL for starting the next day
var() String	FinishedDayURL;					// URL for when you finish the day
var() String	JailURL;						// URL for jail (include "#cell" but no number)

var() name		ApocalypseTex;					// Newspaper texture for the Apocalypse (independent of day)
var() name		ApocalypseComment;				// Dude comment for the Apocalypse (independent of day)

//ErikFOV Change: For Licalization
var() localized array<String> HolidayDisplayName;	
var() localized array<String> HolidayDescription;	
//end

var() array<HolidayDef> Holidays;				// Definition of seasonal DLC
var() class<P2Emitter> KissEmitterClass;		// Emitter for kisses in Valentine's Day
var() string HolidaySpawnerClassName;			// Class of holiday spawner to use

var() name ArrestedScreenTex;					// Texture of "Busted" screen (used only in maps with no defined jail)
var() name MenuTitleTex;						// Texture for in-game menu titles

var() class<GameState> GameStateClass;			// Class of GameState to use

var() bool bShowStartupOnNewGame;				// If true, runs the gameinfo's MainMenuURL instead of starting a new game
												// The gameinfo should also specify a MainMenuName, which will be a simple "Start/Quit" menu
												// This is mostly for workshop purposes
var() name MainMenuName;						// Name of Main Menu (menu displayed during Startup map)
var() name StartMenuName;						// Name of Start Menu (menu displayed when starting a brand-new game. Mostly consists of "Start/Quit". Not to be confused with MainMenuName)
var() name GameMenuName;						// Name of Game Menu (menu displayed in-game)

///////////////////////////////////////////////////////////////////////////////
// Internal vars
///////////////////////////////////////////////////////////////////////////////

var GameState	TheGameState;					// The one-and-only GameState which stores persistent game info
var() string StatsScreenClassName;				// Name of stats screen class to use
var() string MapScreenClassName;					// Name of map screen class to use

var bool		bQuitting;						// True if quitting the game (to differentiate from other loads)
var bool		bLoadedSavedGame;				// True if loaded a saved game (useful before PostLoadGame() is called)
var bool		bTesting;						// True if this is not a real game, we're just playing a map directly
var bool 		bGameIsOver;					// Set true before the final travel to the Main Menu.

var bool		bShowErrandsDuringLoad;			// Whether to show new errands during load process
var bool		bShowStatsDuringLoad;			// Whether to show stats during load -- only at end of game
var bool		bShowHatersDuringLoad;			// Whether to show new haters during load process
var bool		bShowDayDuringLoad;
var bool		bForceNoLoadingScreen;
var bool		bForceNoLoadFade;
var Texture		ForcedLoadTex;
var bool		bCrossOutErrandDuringLoad;
var int			ErrandCompletedDuringLoad;		// Index of completed errand to cross out during load

var int			DayToShowDuringLoad;

var localized string EasySaveMessageString;
var localized string AutoSaveMessageString;
var localized string CheckpointSaveMessageString;
var localized string ForcedSaveMessageString;
var localized string NormalSaveMessageString;


var globalconfig bool 	bShowedControls;		// If set to true and the game was beaten the "How to play" screen no longer shows up.
var globalconfig bool	bAllowCManager;			// If set to true, cheats in P2CheatManager can be used.
var globalconfig bool	bWarnedCheater;			// The first time a player puts in a cheat, we'll pop up a warning screen
												// reminding them that cheating will disqualify them from achievements
												// and will carry over if saved.

var globalconfig bool	bUseAutoSave;			// Enables auto-save after each level transition
var bool		bSafeToSave;					// Whether it is safe to save the game
var bool		bDoAutoSave;					// Whether autosave should occur after level starts
var bool		bForcedAutoSave;				// whether this was a forced autosave
var int			AutoSaveSlot;					// Which slot to autosave to
var int			MostRecentGameSlot;				// The most recently used game slot
var SlotInfoMgr	MySlotInfoMgr;					// Manages extraneous info about the slots

var globalconfig int	InfoSeqTime;			// Info on sequence of game
var globalconfig bool bDrawTime;				// Draw in-game timer y/n
var bool bReadyToDrawTime;
var bool bNeverDrawTime;						// True if this game mode should never draw time (credits etc.)
var globalconfig bool bStrictTime;				// Strict IGT

var array<Material>	SpawnerMaterials;			// Preloaded textures for any spawners in the level
var array<Mesh>		SpawnerMeshes;				// Preloaded meshes for any spawners in the level

var float		CheckReviveTime;				// Cumulative time of sleeping until something clears us. Used
												// with REVIVE_CHECK_TIME below. When this is greater than that const
												// the pawns are checked to be removed from pawn slider stasis.
var name		RunningStateName;				// State name that the game normal runs in. (Differs for full game
												// versus demo game. Don't change this when switching over to the
												// apocalypse at the end of the game--this is special.)

var localized string DifficultyNames[16];		// These used to be held in the menu files, but now it's here
												// so both the menu and the slot mgr can get to it.
var localized string CustomDifficultyName;
var globalconfig int CoolStart, EndCool;
var globalconfig int FOver;
var globalconfig int GOver;
var globalconfig int HOver;
var globalconfig int TimesBeatenGame;			// Number of times you've beaten the game
var globalconfig int TimesBeatenAW;				// Number of times you've beaten AW
var globalconfig int TimesBeatenAWP;			// Number of times you've beaten AWP

var globalconfig bool bContraMode;
var globalconfig bool bSeekritKodeEntered;

var globalconfig int FinStop;
var globalconfig int MultCast;
var globalconfig int Tunneling;

var bool bNightmareSave;	// Saved already on this map

var localized array<String> DayNames;			// xPatch Change: Day names are now localized (can be now translated into other languages)
var array<Texture> LoadingScreens;

var P2GameMod BaseMod;	// P2GameMod version of BaseMutator

var bool bEGameStart;	// Set only via command line
var int ForceDayOnStartup;	// Also set only via command line

var globalconfig array<name> HolidayOverrides;	// Contains a list of overrides for holiday DLC, allowing these to be played at any time
var private bool bWorkshopGame;

var bool bDisallowSave;		// Can be turned on/off by scripted sequence. Disables game save if true.
var bool bDisallowPause;	// Can be turned on/off by scripted sequence. Disables pause if true.

var HolidaySpawnerBase HolidaySpawner;	// Our actual holiday spawner. Just dump one into the game at the start and let it handle the rest.

// Ignore holidays
var globalconfig bool bNoHolidays; // No-holidays mode

var bool bForbidRagdolls;						// LD can now forbid ragdolls for whatever reason. Does not carry over

///////////////////////////////////////////////////////////////////////////////
// xPatch's vars, structs, consts...
///////////////////////////////////////////////////////////////////////////////
var /*private*/ xPatchManager xManager;	// Now instead of having the settings scattered around (bleh)
										// everything will be handled through this cool manager thing, bravo me.

var globalconfig string SavedCountryCode; // This will allow us to correctly setup the default dialog variety automatically but only if needed.

var array<Texture> ClassicLoadTex;

// Loadout copied form P2CheatManager,
// needs to be here to work with day selection correctly
struct LoadoutItem
{
	var() class<Inventory> Item;	// Item to give
	var int Amount;					// How much of this thing to give (ammo, armor etc.)
	var bool NonClassic;
};
// Can't do nested arrays
struct LoadoutList
{
	var() array<LoadoutItem> Items;	// List of items for this day
};
var() array<LoadoutList> LoadoutDays;	// List of items per day

// Classic Game arrays
struct ClassicReplaceStr
{
	var string OldClass;	// weapon we look for 
	var string NewClass;	// other weapon we replace it with
};
var array<ClassicReplaceStr> ClassicModeReplace;

struct ClassicDestroyStr 
{
	var() string ClassName;				// Class name of the pickup
	var() bool bAWPickup;				// Apocalypse Weekend pickup
	var() class<Actor> MyClass;			// Actual class of the pickup
};
var() array<ClassicDestroyStr> NonClassicPickupList;

var localized string ClassicSaveText;
var bool bAllowClassicGame;				// For workshop games to allow Classic Game mode (or not).

const ClassicPath 			= 	"Postal2Game.P2GameInfo bNoEDWeapons";
const LoacalizationPath 	= 	"Postal2Game.P2GameInfo bLocalizedDialog";

const UPDATE_GROUP			=	"UPDATED_GAME";		// Group for objects only present in standard game
const CLASSIC_GROUP			=	"CLASSIC_GAME";		// Group for objects only present in classic game

const MENU_BGR_TRIGGER		=	'MenuBackgroundTrigger';

const DAY_PLMONDAY = 7; 							// First day of the 2nd week

//=================================================================================================
//=================================================================================================
// Functions for 1412 support
//=================================================================================================
//=================================================================================================

///////////////////////////////////////////////////////////////////////////////
// Get start URL
///////////////////////////////////////////////////////////////////////////////
static function string GetStartURL(optional bool bIntroMap, optional bool bIntroSkip)
{
	local string StartURL;

	if (bIntroMap)
	{
		if (Default.IntroUrl != "" && !bIntroSkip)	// xPatch: Added bIntroSkip
			StartURL = Default.IntroURL;
		else
			StartURL = Default.StartFirstDayURL;
	}

	StartURL = StartUrl $ "?Game="$String(Default.Class);

	return StartURL;
}

// AW7 backports
// These functions determine what type of game we are, or what day it is if it's the weekend.

///////////////////////////////////////////////////////////////////////////////
// We need IsWeekend because Saturday and Sunday are days 0 and 1 in AW, but 5 and 6 in AWP.
///////////////////////////////////////////////////////////////////////////////
function bool IsWeekend()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// returns true for AW-only game
///////////////////////////////////////////////////////////////////////////////
function bool WeekendOnlyGame()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// returns true if we use saturday or sunday at all
///////////////////////////////////////////////////////////////////////////////
function bool WeekendGame()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: returns true if we play Two Weeks In Paradise (Paradise Lost DLC)
///////////////////////////////////////////////////////////////////////////////
function bool TwoWeeksGame()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: This new function allows to make cats AW-Like even if it's not weekend.
///////////////////////////////////////////////////////////////////////////////
function bool CrazyCats()
{
	// by default have it return weekend.
	// since that's what was used before.
	return IsWeekend();
}

///////////////////////////////////////////////////////////////////////////////
// returns true in Nightmare mode (no save-scumming, etc)
///////////////////////////////////////////////////////////////////////////////
function bool InNightmareMode()
{
	if (TheGameState != None)
		return (TheGameState.bExpertMode);
	else
		return bExpertMode;
}

///////////////////////////////////////////////////////////////////////////////
// returns true in Masochist mode (Player takes damage like NPCs)
///////////////////////////////////////////////////////////////////////////////
function bool InMasochistMode()
{
	if (TheGameState != None)
		return (TheGameState.bMasochistMode);
	else
		return bMasochistMode;
}

///////////////////////////////////////////////////////////////////////////////
// returns true in Veteran mode (no weapon drop, half the maxammo etc)
///////////////////////////////////////////////////////////////////////////////
function bool InVeteranMode()
{
	if (TheGameState != None)
		return (TheGameState.bVeteranMode);
	else
		return bVeteranMode;
}

///////////////////////////////////////////////////////////////////////////////
// returns true in Melee mode (Custom Difficulty)
///////////////////////////////////////////////////////////////////////////////
function bool InMeeleMode()
{
	if (TheGameState != None)
		return (TheGameState.bMeeleMode);
	else
		return bMeeleMode;
}

///////////////////////////////////////////////////////////////////////////////
// returns true in Hard Liebermode (Custom Difficulty)
///////////////////////////////////////////////////////////////////////////////
function bool InHardLiebermode()
{
	if (TheGameState != None)
		return (TheGameState.bHardLieberMode);
	else
		return bHardLieberMode;
}

///////////////////////////////////////////////////////////////////////////////
// returns true in Nuke (Mass Destruction) Mode (Custom Difficulty)
///////////////////////////////////////////////////////////////////////////////
function bool InNukeMode()
{
	if (TheGameState != None)
		return (TheGameState.bNukeMode);
	else
		return bNukeMode;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if in custom-difficulty mode (seekrit menu)
///////////////////////////////////////////////////////////////////////////////
function bool InCustomMode()
{
	if (TheGameState != None)
		return (TheGameState.bCustomMode);
	else
		return bCustomMode;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if Impossible mode
///////////////////////////////////////////////////////////////////////////////
function bool InImpossibleMode()
{
	if ((InInsaneMode() || InLudicrousMode())	// xPatch: Count the harder Ludicrous mode too
		&& TheyHateMeMode()
		&& InNightmareMode()
		&& TheGameState.GameDifficulty >= 10
		)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if Ludicrous Difficulty
///////////////////////////////////////////////////////////////////////////////
function bool InLudicrousDifficulty()
{
	if (InLudicrousMode()
		&& TheyHateMeMode()
		&& InNightmareMode()
		&& InVeteranMode()
		&& InMasochistMode()
		&& TheGameState.GameDifficulty >= 10
		)
		return true;
	else
		return false;
}


///////////////////////////////////////////////////////////////////////////////
// returns true if free-roam (AW+P2)
// Not currently used
///////////////////////////////////////////////////////////////////////////////
function bool IsFreeRoam()
{
	return false;
}

// This stuff is saved in the GameState now, so we can make hybrid difficulty levels
///////////////////////////////////////////////////////////////////////////////
// In super-easy Lieberman mode
///////////////////////////////////////////////////////////////////////////////
function bool InLiebermode()
{
	if (TheGameState != None)
	{
		//log(self@"in lieber mode gs"@TheGameState.bLieberMode);
		return (TheGameState.bLieberMode);
	}
	else
	{
		//log(self@"in lieber mode"@bLieberMode);
		return bLieberMode;
	}
}

///////////////////////////////////////////////////////////////////////////////
// In super-hard Heston mode
///////////////////////////////////////////////////////////////////////////////
function bool InHestonmode()
{
	if (TheGameState != None)
	{
		//log(self@"in heston mode gs"@TheGameState.bHestonMode);
		return (TheGameState.bHestonMode);
	}
	else
	{
		//log(self@"in heston mode"@bHestonMode);
		return bHestonMode;
	}
}

///////////////////////////////////////////////////////////////////////////////
// In They Hate Me mode. Cops don't arrest you and everyone hates you that has
// a weapon. very Hard
///////////////////////////////////////////////////////////////////////////////
function bool TheyHateMeMode()
{
	if (TheGameState != None)
	{
		//log(self@"in they hate me mode gs"@TheGameState.bTheyHateMeMode);
		return (TheGameState.bTheyHateMeMode);
	}
	else
	{
		//log(self@"in they hate me mode"@bTheyHateMeMode);
		return bTheyHateMeMode;
	}
}

///////////////////////////////////////////////////////////////////////////////
// In super-duper-hard Insane-o mode
///////////////////////////////////////////////////////////////////////////////
function bool InInsanemode()
{
	if (TheGameState != None)
	{
		//log(self@"in insane mode gs"@TheGameState.bInsaneoMode);
		return (TheGameState.bInsaneoMode);
	}
	else
	{
		//log(self@"in insane mode"@bInsaneoMode);
		return bInsaneoMode;
	}
}

///////////////////////////////////////////////////////////////////////////////
// In ludicrous mode where everyone gets crazy powerful weapons
///////////////////////////////////////////////////////////////////////////////
function bool InLudicrousMode()
{
	if (TheGameState != None)
	{
		//log(self@"in ludicrous mode gs"@TheGameState.bLudicrousMode);
		return (TheGameState.bLudicrousMode);
	}
	else
	{
		//log(self@"in ludicrous mode"@bLudicrousMode);
		return bLudicrousMode;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Change day, but only in value, don't warp him or anything
///////////////////////////////////////////////////////////////////////////////
function IncrementDay()
{
	// See if there's any more days
	if (TheGameState.CurrentDay + 1 < Days.length)
	{
		TheGameState.bChangeDayPostTravel = false;
		TheGameState.NextDay = TheGameState.CurrentDay + 1;
		TheGameState.CurrentDay = TheGameState.NextDay;
		//log(self$" increment day, now "$TheGameState.CurrentDay);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Something wants to set the game speed, make sure the player isn't in catnip mode
// before something else resets it early, or something like that.
///////////////////////////////////////////////////////////////////////////////
function PossibleSetGameSpeed(float newspeed)
{
	local P2Player adude;

	adude = GetPlayer();

	// Catnip mode isn't controlling things, so it's okay
	if(adude.CatnipUseTime == 0)
	{
		if(P2GameInfoSingle(Level.Game) != None)
			P2GameInfoSingle(Level.Game).SetGameSpeedNoSave(newspeed);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool VerifyGH()
{
	return GinallyOver();

	/*
	return (DoMP1(true)
			&& DoMP2(true)
			&& DoMP3(true)
			&& GinallyOver());
	*/
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool ChangedMP1()
{
	local int oldval;
	const MP1 = 5;
	oldval = int(ConsoleCommand("get "@MultCastPath));
	//log(Self$" cheattest old val, oldval "$oldval$" MultCast "$MultCast);
	return (oldval < MP1
		&& MultCast > MP1 && MultCast <= 2*MP1);
}
function bool DoMP1(optional bool bNoWrite)
{
	local int oldval;
	const MP1A = 5;
	//log(self$" cheattest do mp1, multcast "$MultCast);
	if(MultCast > MP1A && MultCast <= 2*MP1A)
	{
		if(!bNoWrite)
		{
			//log(self$" setting ");
			ConsoleCommand("set "@MultCastPath@MultCast);
		}
		return true;
	}
	else
	{
		oldval = int(ConsoleCommand("get "@MultCastPath));
		//log(Self$" getting old val "$oldval);
		if(oldval > MP1A && oldval <= 2*MP1A)
		{
			return true;
		}
		else
			return false;
	}
}
function bool ChangedMP2()
{
	local int oldval;
	const MP2 = 23;
	oldval = int(ConsoleCommand("get "@FinStopPath));
	log(Self$" cheattest old val, oldval "$oldval$" FinStop "$FinStop);
	return (oldval < MP2
		&& FinStop > MP2 && FinStop <= 2*MP2);
}
function bool DoMP2(optional bool bNoWrite)
{
	local int oldval;
	const MP2A = 23;
	//log(self$" cheattest do mp2, finstop "$finstop);
	if(FinStop > MP2A && FinStop <= 2*MP2A)
	{
		if(!bNoWrite)
		{
			//log(self$" setting ");
			ConsoleCommand("set "@FinStopPath@FinStop);
		}
		return true;
	}
	else
	{
		oldval = int(ConsoleCommand("get "@FinStopPath));
		//log(self$" getting it, "$oldval);
		if(oldval > MP2A && oldval <= 2*MP2A)
		{
			return true;
		}
		else
			return false;
	}
}
function bool ChangedMP3()
{
	local int oldval;
	const MP3 = 18;
	oldval = int(ConsoleCommand("get "@TunnelingPath));
	return (oldval < MP3
		&& Tunneling > MP3 && Tunneling <= 2*MP3);
}
function bool DoMP3(optional bool bNoWrite)
{
	local int oldval;
	const MP3A = 23;
	if(Tunneling > MP3A && Tunneling <= 2*MP3A)
	{
		if(!bNoWrite)
		{
			ConsoleCommand("set "@TunnelingPath@Tunneling);
		}
		return true;
	}
	else
	{
		oldval = int(ConsoleCommand("get "@TunnelingPath));
		if(oldval > MP3A && oldval <= 2*MP3A)
		{
			return true;
		}
		else
			return false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Keep track of time elapsed for speed runs and whatnot
///////////////////////////////////////////////////////////////////////////////
event Tick(float Delta)
{
	local P2Player p2p;

	Super.Tick(Delta);

	p2p = GetPlayer();

	// Ticks up the IGT when player is in control
	if(p2p != None									// no player controller (player is probably traveling)
		&& p2p.Pawn != None							// no pawn (player is viewing a cutscene)
		&& p2p.Pawn.Health > 0						// pawn is not alive
		&& p2p.Level.Pauser == None					// game is not paused
		&& TheGameState != None						// no gamestate (player is probably traveling)
		&& !p2p.IsInState('PlayerPrepSave')			// not waiting on autosave
		)
		TheGameState.TimeElapsed += Delta * (1.0/Level.TimeDilation);
}

///////////////////////////////////////////////////////////////////////////////
// This function is called before any other scripts (including PreBeginPlay().
///////////////////////////////////////////////////////////////////////////////
event InitGame(out string Options, out string Error)
{
	local string InName, InClass, InTeam;

	// RWS CHANGE: For Singleplayer, Modify URL options to use the default Name, Class and Team

	// Use same name that the PlayerReplicationInfo.PlayerName gets set to (in Controller.InitPlayerReplicationInfo())
	Options = SetURLOption(Options, "Name",  class'GameInfo'.Default.DefaultPlayerName);

	Options = SetURLOption(Options, "Class", Default.DefaultPlayerClassName);

	//Options = SetURLOption(Options, "Team",  "255");

	Super.InitGame(Options, Error);
	MySlotInfoMgr = spawn(class'SlotInfoMgr');
	if (ParseOption(Options,"Enhanced") != "")
		bEGameStart = true;
	
	// Man Chrzan: Add xPatch Manager
	xPatchManagerCheck();
	
	if (ParseOption(Options,"Workshop") == "1")
		bWorkshopGame = true;
	else						
		bWorkshopGame = false;

	if (ParseOption(Options,"SetDay") != "")
	{
		ForceDayOnStartup = int(ParseOption(Options,"SetDay"));
	}
	BaseMod = P2GameMod(BaseMutator);

	// Init difficulty flags for subclasses.
	GameDifficultyNumber = class'P2GameInfo'.Default.GameDifficultyNumber;
	bLieberMode = class'P2GameInfo'.Default.bLieberMode;
	bHestonMode = class'P2GameInfo'.Default.bHestonMode;
	bTheyHateMeMode = class'P2GameInfo'.Default.bTheyHateMeMode;
	bInsaneoMode = class'P2GameInfo'.Default.bInsaneoMode;
	bLudicrousMode = class'P2GameInfo'.Default.bLudicrousMode;
	bExpertMode = class'P2GameInfo'.Default.bExpertMode;
	bCustomMode = class'P2GameInfo'.Default.bCustomMode;
	bNoEDWeapons  = class'P2GameInfoSingle'.Default.bNoEDWeapons;			// xPatch
	bMasochistMode = class'P2GameInfo'.Default.bMasochistMode;
	bVeteranMode = class'P2GameInfo'.Default.bVeteranMode;
	bMeeleMode = class'P2GameInfo'.Default.bMeeleMode;
	bHardLieberMode = class'P2GameInfo'.Default.bHardLieberMode;
	bNukeMode = class'P2GameInfo'.Default.bNukeMode;
}

//=================================================================================================
//=================================================================================================
//=================================================================================================
//
// Start/Quit/Load/Save/etc
//
//=================================================================================================
//=================================================================================================
//=================================================================================================

///////////////////////////////////////////////////////////////////////////////
// Start the game
///////////////////////////////////////////////////////////////////////////////
function StartGame(optional bool bEnhancedMode)
	{
	local P2Player p2p;

	P2RootWindow(GetPlayer().Player.InteractionMaster.BaseMenu).StartingGame();

	// Stop any active SceneManager so player will have a pawn
	StopSceneManagers();

	// No longer used, make sure it's always off
	TheGameState.bNiceDude = false;

	PrepIniStartVals();

	TheGameState.bEGameStart = bEnhancedMode;

	// Reset the game timer
	TheGameState.TimeElapsed = 0;
	TheGameState.TimeStart = Level.GetMillisecondsNow();

	// Get the difficulty ready for this game state.
	SetupDifficultyOnce();

	// Get rid of any things in his inventory before a new game starts
	p2p = GetPlayer();
	P2Pawn(p2p.pawn).DestroyAllInventory();

	// Game doesn't actually start until player is sent to first day,
	// which *should* happen at the end of the intro sequence.
	if(!Level.IsDemoBuild())
		SendPlayerTo(GetPlayer(), IntroURL);
	else	// Unless of course it's the demo, then it *does* actaully just start.
		{
		TheGameState.bChangeDayPostTravel = true;
		TheGameState.NextDay = 0;
		SendPlayerTo(GetPlayer(), StartFirstDayURL);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Make sure these are done at StartGame and every time you load, in case,
// in between, someone deletes their ini, but uses an old load
///////////////////////////////////////////////////////////////////////////////
function PrepIniStartVals()
{
	GameRefVal = int(ConsoleCommand("get "@RefPath));
	if(GameRefVal == START_GAME_REF)
	{
		// Setup the reference value
		GameRefVal=(Rand(REF_STARTUP)/2);
		GameRefVal=2*GameRefVal;
		ConsoleCommand("set "@RefPath@GameRefVal);
		//log(self$" NEW made up gameref "$GameRefVal);
	}
	//else
		//log(self$" CURRENT gameref "$GameRefVal);
	if(CoolStart == 0)
	{
		CoolStart = Rand(COOL_FACTOR);
		ConsoleCommand("set "@CoolStartPath@CoolStart);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Quit the game.
// NOTE: Player may not have a pawn if he's dead or a cinematic is playing.
///////////////////////////////////////////////////////////////////////////////
function QuitGame()
	{
	P2RootWindow(GetPlayer().Player.InteractionMaster.BaseMenu).EndingGame();

	bQuitting = true;

	// Send player to main menu (set flag to indicate that pawn might be none)
	SendPlayerTo(GetPlayer(), MainMenuURL, true);
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function RecordEnding()
{
	local bool bDoFOver;
	local bool bDoGOver;
	// record ending based on whether they beat P2, AW, or both

	// P2 never uses the weekend.
	if (!WeekendGame())
		bDoFOver = true;

	// AW uses the weekend only
	if (WeekendGame()
		&& WeekendOnlyGame())
		bDoGOver = true;

	// AWP does both
	if (WeekendGame()
		&& !WeekendOnlyGame())
	{
		bDoFOver = true;
		bDoGOver = true;
	}

	TimesBeatenGame++;
	if (bDoFOver)
	{
		FOver = FOVER_SUM - GameRefVal;
		ConsoleCommand("set "@FOverPath@FOver);
		ConsoleCommand("set "@TimesBeatenGamePath@TimesBeatenGame);
	}
	if (bDoGOver)
	{
		GOver = GOVER_SUM - GameRefVal;
		ConsoleCommand("set "@GOverPath@GOver);
		ConsoleCommand("set "@TimesBeatenGamePath@TimesBeatenGame);
	}
}

///////////////////////////////////////////////////////////////////////////////
// The player has watched the last movie in the game and successfully beaten
// the game! Put up the stats screen as we load the main menu.
///////////////////////////////////////////////////////////////////////////////
function EndOfGame(P2Player player)
	{
	P2RootWindow(player.Player.InteractionMaster.BaseMenu).EndingGame();
	
	// If we haven't called time yet, do so now
	TheGameState.TimeStop = Level.GetMillisecondsNow();
	bGameIsOver = true;

	// Set that you want the stats
	bShowStatsDuringLoad=true;

	// Only save sequence 'time' if beaten at average difficulty or higher
	// (Or if we've already unlocked it, give it to them again)
	if(GetDifficultyOffset() >= 0
		|| TheGameState.bEGameStart)
		InfoSeqTime = GetSeqTime();
	ConsoleCommand("set "@InfoSeqPath@InfoSeqTime);
	RecordEnding();
	//log(self$" GameRefVal new InfoSeqTime "$InfoSeqTime$" GameRefVal "$GameRefVal$" fover "$FOver);

	
	// xPatch: Must be played from the first day to get these achievement		
	if(TheGameState.StartDay == 0)	
	{
		// Grant achievement if we beat both AW and P2
		if (FinallyOver()
			&& GinallyOver())
			{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'GameComplete');
			}

		// Grant achievements for beating the game in certain ways

		// Shovel ending
		if (!TheGameState.bShovelEndingDQ		// Used only the shovel to kill
			&& TheGameState.PeopleKilled >= 30	// Must have killed at least 30 people
			&& !WeekendOnlyGame())				// Must be AWP or P2
			{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'ShovelEnding',true);
			}
		// Speedrun ending
		if (TheGameState.TimeElapsed <= TheGameState.SPEEDRUN_ACHIEVEMENT
			&& !WeekendOnlyGame()				// Must be AWP or P2
			&& !VerifySeqTime())					// Can't be in Enhanced
			{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'SpeedrunEnding',true);
			}
		// Hestonworld ending
		if (InHestonMode())
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'HestonworldEnding',true);
		}
		// Jesus/Anustart ending
		if (TheGameState.PeopleKilled + TheGameState.CatsKilled + TheGameState.ElephantsKilled + TheGameState.DogsKilled == 0)
		{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'JesusEnding',true);
		}
		// Scientology Level OT VIII ending
		if (InNightmareMode()		// Beat the game in nightmare mode
			&& !WeekendOnlyGame()	// Not in AW
			&& WeekendGame())		// Not in P2
			{
			if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'NightmareEnding',true);
			}
			
		// If they completed Ludicrous unlock custom difficulty menu. 
		if(InLudicrousDifficulty())
		{
			bSeekritKodeEntered = True;
			SaveConfig();
		}
	}
	
	// Send player to main menu
	SendPlayerTo(player, MainMenuURL);
	}

///////////////////////////////////////////////////////////////////////////////
// Load custom map
///////////////////////////////////////////////////////////////////////////////
function LoadCustomMap(string URL)
	{
	local P2Player p2p;

	Log(self$" LoadCustomMap(): URL="$URL);

	P2RootWindow(GetPlayer().Player.InteractionMaster.BaseMenu).StartingGame();
	GetPlayer().MyHUD.bHideHud = true;

	// Get rid of any things in his inventory before a new game starts
	p2p = GetPlayer();
	if (p2p.pawn != None)
		P2Pawn(p2p.pawn).DestroyAllInventory();

	// The perverted engine technique for loading a level is to travel to
	// the loaded game.  (Set flag to indicate pawn might be none)
	SendPlayerTo(p2p, URL, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Load game from the specified slot
///////////////////////////////////////////////////////////////////////////////
function LoadGame(int Slot, bool bShowScreen)
	{
	local String SaveInfo, LoadTex;
	local int i;

	Log(self$" LoadGame(): Slot="$Slot);

	P2RootWindow(GetPlayer().Player.InteractionMaster.BaseMenu).StartingGame();
	GetPlayer().MyHUD.bHideHud = true;

	if (bShowScreen)
	{
		// Show the day (monday, tuesday,...) associated with the game during the load
		//bShowDayDuringLoad = true;
		//DayToShowDuringLoad = MySlotInfoMgr.GetInfo(Slot).Day;

		// Determine day to display on load.
		// If we can't find the day, the game will fall back to the normal method above.
		SaveInfo = MySlotInfoMgr.GetInfo(Slot).Name;
		// See if it saved a load texture first.
		LoadTex = MySlotInfoMgr.GetInfo(Slot).LoadScreen;
		if (LoadTex != "")
		{
			ForcedLoadTex = Texture(DynamicLoadObject(LoadTex, class'Texture'));
		}
		else // Fall back to old method.
		{
			for (i=0; i<DayNames.Length; i++)
			{
				if ((Len(SaveInfo) >= Len(DayNames[i]))
					&& (
						(Left(SaveInfo,Len(DayNames[i])) ~= DayNames[i])
					||	(Left(SaveInfo,Len(DayNames[i]) + 1) ~= ("*"$DayNames[i]))
						)
					)
				{
					ForcedLoadTex = LoadingScreens[i];
					i = DayNames.Length;
				}
			}
		}
	}
	
	// Added by Man Chrzan: xPatch 2.0 -- Loadscreen Swap
	//if(class'xPatchManager'.static.GetClassicLoading())
	if(xManager.bClassicLoadScreens || (InStr((SaveInfo), ClassicSaveText) > 0))
	{
		for(i=0; i<LoadingScreens.Length; i++)
		{
			if( ForcedLoadTex == LoadingScreens[i] )
			{
				ForcedLoadTex = ClassicLoadTex[i];
			}
		}
	}
	// End

	// The perverted engine technique for loading a level is to travel to
	// the loaded game.  (Set flag to indicate pawn might be none)
	SendPlayerTo(GetPlayer(), LOADGAME_URL$Slot, true);
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PrepDifficulty()
{
	if(TheGameState != None)
	{
		//log(self$" Synchronizing and writing new difficulty to ini, was "$GameDifficulty$" is now "$TheGameState.GameDifficulty);
		// Use the game difficulty from the game state (this was the saved diff)
		GameDifficulty = TheGameState.GameDifficulty;
		// Make sure to write the difficulty to the ini, or it won't be carried to the next
		// level correctly.
		ConsoleCommand("set "@DifficultyPath@GameDifficulty);

		// Set liebermode, heston etc. bools.
		bLieberMode = TheGameState.bLieberMode;
		bHestonMode = TheGameState.bHestonMode;
		bTheyHateMeMode = TheGameState.bTheyHateMeMode;
		bInsaneoMode = TheGameState.bInsaneoMode;
		bExpertMode = TheGameState.bExpertMode;
		bLudicrousMode = TheGameState.bLudicrousMode;
		bNoEDWeapons = TheGameState.bNoEDWeapons; 				// xPatch
		bMasochistMode = TheGameState.bMasochistMode;
		bVeteranMode = TheGameState.bVeteranMode;
		bMeeleMode = TheGameState.bMeeleMode;
		bHardLieberMode = TheGameState.bHardLieberMode;
		bNukeMode = TheGameState.bNukeMode;
		ConsoleCommand("set "@LieberPath@TheGameState.bLieberMode);
		ConsoleCommand("set "@HestonPath@TheGameState.bHestonMode);
		ConsoleCommand("set "@TheyHateMePath@TheGameState.bTheyHateMeMode);
		ConsoleCommand("set "@InsaneoPath@TheGameState.bInsaneoMode);
		ConsoleCommand("set "@LudicrousPath@TheGameState.bLudicrousMode);
		ConsoleCommand("set "@ExpertPath@TheGameState.bExpertMode);
		ConsoleCommand("set "@CustomPath@TheGameState.bCustomMode);
		ConsoleCommand("set "@ClassicPath@TheGameState.bNoEDWeapons); // xPatch
		ConsoleCommand("set "@MasochistPath@TheGameState.bMasochistMode);
		ConsoleCommand("set "@VeteranPath@TheGameState.bVeteranMode);
		ConsoleCommand("set "@MeleePath@TheGameState.bMeeleMode);
		ConsoleCommand("set "@HardLieberPath@TheGameState.bHardLieberMode);
		ConsoleCommand("set "@NukeModePath@TheGameState.bNukeMode);
		//log("Set difficulty flags: Lieber/Heston/Hate/Insane/Expert/Ludicrous"@bLieberMode@bHestonMode@bTheyHateMeMode@bInsaneoMode@bExpertMode@bLudicrousMode);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Restore your errands
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
	{
	Super.PostLoadGame();

	// Restore day and errands
	RestoreDayAndErrands();

	PrepIniStartVals();

	// Always clear the pause after a game is loaded (in case the game was
	// saved in a paused state)
	GetPlayer().SetPause(false);
	
	// Added by Man Chrzan: xPatch
	bNoEDWeapons = TheGameState.bNoEDWeapons;
	xPatchManagerCheck();
	// end

	//log(self$" game difficulty ***************** "$TheGameState.GameDifficulty);
	// If the game state's difficulty was not initialized properly, then it was from
	// and old save. So offer the person a chance to set their difficulty once again
	// for this save.
	if(TheGameState.GameDifficulty < 0)
		{
		//log(self$" allowing them to set new game diff ");
		GetPlayer().GotoState('PlayerDiffPatch');
		}
	//log(self$" time elapsed ********** "$TheGameState.TimeElapsed);
	// Same as above, but for time elapsed.
	if (TheGameState.TimeElapsed <= 0)
		TheGameState.TimeElapsed = 248400;
	if (VSize(TheGameState.TimeStart) <= 0)
		TheGameState.TimeStart = Vect(69,0,0);
		
	// Load no-holiday value from gamestate
	bNoHolidays = TheGameState.bNoHolidays;
	SaveConfig();

	// After loading, run PrepDifficulty again. Should fix issues with Liebermode etc. flags carrying over to loaded games.
	PrepDifficulty();
	
	// xPatch: Change main menu map if needed.
	UpdateMainMenu();

	// Clear these after a load, so we don't repeatedly attempt to autosave.
	bDoAutoSave = false;
	bForcedAutoSave = false;
	}
	
///////////////////////////////////////////////////////////////////////////////
// Pause game
///////////////////////////////////////////////////////////////////////////////
function bool SetPause( BOOL bPause, PlayerController P )
{
	// Disallow pause if scripted sequence says so
	if (bPause && bDisallowPause)
		return false;		
	else
		return Super.SetPause(bPause, P);
}	

///////////////////////////////////////////////////////////////////////////////
// Save game to the specified slot
///////////////////////////////////////////////////////////////////////////////
function bool SaveGame(int Slot, bool bShowMessage)
	{
	local string IsCheated, EnhancedFlag, ClassicFlag; //, WorkshopFlag;
	local int SaveAttempts;
	local bool SaveResult;
	local int WasMostRecentGameSlot;
	local bool bWasNightmareSave;
	
// Man Chrzan: xPatch 2.5
	// Add a flag for Classic Mode saves
	if (TheGameState.bNoEDWeapons)
		ClassicFlag = " "$ClassicSaveText;
	//if(GetWorkshopGame())	
	//	WorkshopFlag = " [W]";
// End
	
	Log(self$" SaveGame(): Slot="$Slot$" bAutoSave="$bDoAutoSave$" bForcedAutoSave="$bForcedAutoSave$" the game state difficulty "$TheGameState.GameDifficulty);
	GetPlayer().ConsoleCommand("ResetSmoothingOnSave");
	TheGameState.bNoHolidays = bNoHolidays;

	if (bShowMessage)
		{
		if (Slot == QUICKSAVE_SLOT)
			GetPlayer().ClientMessage(EasySaveMessageString);
		else if (Slot == AUTOSAVE_SLOT && bForcedAutoSave)
			GetPlayer().ClientMessage(ForcedSaveMessageString);
		else if (Slot == AUTOSAVE_SLOT)
			GetPlayer().ClientMessage(AutoSaveMessageString);
		else if (Slot == CHECKPOINT_SLOT)
			GetPlayer().ClientMessage(CheckpointSaveMessageString);
		else
			GetPlayer().ClientMessage(NormalSaveMessageString);
		}

	// Update MostRecentGameSlot and NightmareSave here, but remember their previous values
	// just in case the save fails.
	WasMostRecentGameSlot = MostRecentGameSlot;
	bWasNightmareSave = bNightmareSave;	// This should always be false anyway if we get this far in a Nightmare save, but just for sanity's sake.

	// This slot is now the most recently used slot.  We update this BEFORE the
	// actual save so that if this game is loaded, it will refer to itself as
	// the most recently used.  In other words, whenever a game is loaded, the
	// slot it loaded from becomes the most recently used slot.
	MostRecentGameSlot = Slot;

	// if we're in nightmare mode, record that we've used our one save
	// But not if it's an auto-save (they get a freebie in this case)
	// Also not if it's a map-based checkpoint save
	if (InNightmareMode() && Slot != CHECKPOINT_SLOT && Slot != AUTOSAVE_SLOT)
		bNightmareSave = True;

    // This crashes the game. My guess would be something to do with trying to move while saving.
    // (Crash log came to the AbsorbedPaused guard)
    // Try saving 3 times. If they all fail, display an error!
    //for(SaveAttempts=0;SaveAttempts<MAX_SAVE_ATTEMPTS;SaveAttempts++)
    //{
        // JWB 12/5/13: SaveGame now returns if the it actually saved.
        // do the actual save
        SaveResult = bool(ConsoleCommand("SaveGame "$Slot));

        if(SaveResult)
        {
            log("Save Successful!");

            // if it's a cheated save, give it a "mark of shame"
            // (also helps players distinguish between cheated and non-cheated saves)
            if (TheGameState.DidPlayerCheat())
			{		
				// xPatch Change: Mark debug differently
				if (GetPlayer().DebugEnabled())
					IsCheated = "**";
				else 
					IsCheated = "*";	
			}
			
            // Save info about this slot
            MySlotInfoMgr.SetInfo(
                Slot,
                IsCheated$GetDayName()@"-"@Level.Title@"-"@GetDiffName(TheGameState.GameDifficulty)$EnhancedFlag@"-"@GameNameShort$ClassicFlag/*$WorkshopFlag*/,
                GetCurrentDay(),
                Level.Year$"-"$Val2Str(level.Month, 2)$"-"$Val2Str(Level.Day, 2)@":"@Val2Str(Level.Hour, 2)$":"$Val2Str(Level.Minute, 2),
                int(ConsoleCommand("GETGMTIME")),
				String(GetCurrentDayBase().LoadTex)
				);

            //Great it saved! No need to try again.
            //break;
		}
		//else if(SaveAttempts + 1 == MAX_SAVE_ATTEMPTS)
		//{
		//     GetPlayer().ClientMessage("Save failed after "$SaveAttempts + 1$" tries. Try again.");
		//     log("Save failed after "$SaveAttempts + 1$" tries. Try again.");
		//}
		else // No need to tell the player, but log it just in case it fails twice but works on the third attempt.
		{
			log("Save failed. Please try again...");
			GetPlayer().ClientMessage("Save failed. Please try again...");
			// The save failed. Restore previous values of NightmareSave and Most Recent Save Slot.
			MostRecentGameSlot = WasMostRecentGameSlot;
			bNightmareSave = bWasNightmareSave;
		}
    //}

    return SaveResult;

	}

///////////////////////////////////////////////////////////////////////////////
// Try to return the true, GameState difficulty
///////////////////////////////////////////////////////////////////////////////
function float GetGameDifficulty()
{
	if(TheGameState != None)
		return TheGameState.GameDifficulty;
	else
		return GameDifficulty;
}

///////////////////////////////////////////////////////////////////////////////
// Get the phrase for our difficulty level (override in p2gameinfosingle)
///////////////////////////////////////////////////////////////////////////////
function string GetDiffName(int DiffIndex)
{
	local string EnhancedFlag;

	if(DiffIndex < 0)
		DiffIndex = 0;
	else if(DiffIndex > ArrayCount(DifficultyNames))
			DiffIndex = ArrayCount(DifficultyNames);

	// Special checks for difficulty levels above Hestonworld. These all use a DiffIndex of 10.
	// If DiffIndex is another value then the player is probably using a custom difficulty.

	// Add a flag for Enhanced Mode saves
	if (VerifySeqTime())
		EnhancedFlag = EnhancedFlag$" [E]";

		// Custom
	if (InCustomMode())
		return CustomDifficultyName$" ("$TheGameState.GameDifficulty$")"$EnhancedFlag;
	// Ludicrous mode (Nightmare + Ludicrous + Veteran + Masochist)
	else if (InLudicrousDifficulty())
		DiffIndex = DIFFICULTY_NUMBER_LUDICROUS;
	// Impossible mode (Nightmare + Insane-O)
	else if (InNightmareMode() && InInsaneMode() && DiffIndex == 10)
		DiffIndex = DIFFICULTY_NUMBER_IMPOSSIBLE;
	// POSTAL mode (Nightmare + Heston)
	else if (InNightmareMode() && InHestonMode() && DiffIndex == 10)
		DiffIndex = DIFFICULTY_NUMBER_POSTAL;
	// They Hate Me mode (They Hate Me)
	else if (TheyHateMeMode() && DiffIndex == 10)
		DiffIndex = DIFFICULTY_NUMBER_THEYHATEME;
	// Insane-O (Insane-O)
	else if (InInsaneMode() && DiffIndex == 10)
		DiffIndex = DIFFICULTY_NUMBER_INSANE;
	// Hestonworld (Heston)
	else if (InHestonMode() && DiffIndex == 10)
		DiffIndex = DIFFICULTY_NUMBER_HESTON;

	return DifficultyNames[DiffIndex]$EnhancedFlag;
}

///////////////////////////////////////////////////////////////////////////////
// Try to do a quick save.
// Return value indicates whether it was actually done or not.
///////////////////////////////////////////////////////////////////////////////
function bool TryQuickSave(P2Player player, optional bool bIsCheckpoint)
	{
	local bool bDidSave;

	if (IsSaveAllowed(player, bIsCheckpoint) &&	// only if conditions are right
		(Level.Pauser == None))		// only if not paused
		{
		if(SaveGame(QUICKSAVE_SLOT, true))
		  bDidSave = true;
		else
		  bDidSave = false;
		}
	return bDidSave;
	}

///////////////////////////////////////////////////////////////////////////////
// Try to do a checkpoint save.
// Return value indicates whether it was actually done or not.
///////////////////////////////////////////////////////////////////////////////
function bool TryCheckpointSave(P2Player player, optional bool bIsCheckpoint)
	{
	local bool bDidSave;

	if (IsSaveAllowed(player, bIsCheckpoint) &&	// only if conditions are right
		(Level.Pauser == None))		// only if not paused
		{
		if(SaveGame(CHECKPOINT_SLOT, true))
		  bDidSave = true;
		else
		  bDidSave = false;
		}
	return bDidSave;
	}

///////////////////////////////////////////////////////////////////////////////
// Try to do an auto save.
// Return value indicates whether it was actually done or not.
///////////////////////////////////////////////////////////////////////////////
function bool TryAutoSave(P2Player player, optional bool bIsCheckpoint)
	{
	local bool bDidSave;

	if (IsSaveAllowed(player, bIsCheckpoint) &&	// only if conditions are right
		(Level.Pauser == None)		// only if not paused
		&& bUseAutoSave)			// Only let auto-saves through this function work if auto-saves enabled
		{
		if(SaveGame(AUTOSAVE_SLOT, true))
		  bDidSave = true;
		else
		  bDidSave = false;
		}
	return bDidSave;
	}

///////////////////////////////////////////////////////////////////////////////
// Try to do a quick load.
///////////////////////////////////////////////////////////////////////////////
function TryQuickLoad(P2Player player)
	{
	if (IsLoadAllowed(player) &&	// only if conditions are right
		!IsPreGame() &&				// only during actual game
		(player.Pawn != None) &&	// only if player has pawn (aka not during cinematics)
		(Level.Pauser == None))		// only if not paused
		{
		// Load the most recent game
		LoadMostRecentGame();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Player calls this when it's ready for a save.  It will call this repeatedly
// until it returns true, which means we agree.
///////////////////////////////////////////////////////////////////////////////
function bool ReadyForSave(P2Player player)
	{
	// Set the all-critical flag, then make sure all the other conditions
	// are right.  If it works, then we're good to go.  Otherwise, we clear
	// the flag and wait for the next call.
	bSafeToSave = true;
	if (IsSaveAllowed(player))
		{
		// If an auto save is desired, now is the perfect time to do it
		if (bDoAutoSave)
			{
			SaveGame(AutoSaveSlot, true);
			// Only clear flags after the save is done
			bDoAutoSave = false;
			bForcedAutoSave = false;
			}
		}
	else
		bSafeToSave = false;

	return bSafeToSave;
	}

///////////////////////////////////////////////////////////////////////////////
// Called when the player would have tried to autosave (even if he has it
// turned off. This brings up a menu for the player to pick the new difficulty
// for that save.
///////////////////////////////////////////////////////////////////////////////
function bool ReadyForSaveFix(P2Player player)
	{
	// Set the all-critical flag, then make sure all the other conditions
	// are right.  If it works, then we're good to go.  Otherwise, we clear
	// the flag and wait for the next call.
	bSafeToSave = true;
	if (IsSaveAllowed(player))
		{
		bDoAutoSave = false;
		P2RootWindow(GetPlayer().Player.InteractionMaster.BaseMenu).DifficultyPatch();
		}
	else
		bSafeToSave = false;

	return bSafeToSave;
	}

///////////////////////////////////////////////////////////////////////////////
// Load the most-recent game
///////////////////////////////////////////////////////////////////////////////
function LoadMostRecentGame()
	{
	Log(self$" LoadMostRecentGame(): Slot="$MostRecentGameSlot);

	if (MostRecentGameSlot != -1)
		{
		P2RootWindow(GetPlayer().Player.InteractionMaster.BaseMenu).StartingGame();
		LoadGame(MostRecentGameSlot, false);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Check whether save is allowed
// Can only save once per map in nightmare mode!
///////////////////////////////////////////////////////////////////////////////
function bool IsSaveAllowed(P2Player player, optional bool bIsCheckpoint)
	{
	if (bSafeToSave &&				// only if it's safe
		!Level.IsDemoBuild() &&		// not in demo
		!IsPreGame() &&				// only during actual game
		!IsFinishedDayMap()	&&		// not on finishedday map
		player != None &&			// only if there's a player
		(!InNightmareMode() || !bNightmareSave || bIsCheckpoint) &&	// not in nightmare mode if they used their nightmare save
		player.IsSaveAllowed() &&	// only if player agrees
		(!bDisallowSave || bIsCheckpoint))				// only if not disallowed by a scripted sequence
		return true;
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Check whether load is allowed
///////////////////////////////////////////////////////////////////////////////
function bool IsLoadAllowed(P2Player player)
	{
	if (!Level.IsDemoBuild())		// not in demo
		return true;
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Convert the specified integer to a string with the given width by preceding
// with 0's as necessary.
// This is utilized by SaveSlotInfo.
///////////////////////////////////////////////////////////////////////////////
static function string Val2Str(int iVal, int iWidth)
{
	local int		iCurDigitWeight;
	local string	strVal;

	strVal = ""$iVal;

	iCurDigitWeight = 1;
	while (iWidth > 1)
	{
		iCurDigitWeight *= 10;
		if (iVal < iCurDigitWeight)
			strVal = "0"$strVal;
		iWidth--;
	}

	return strVal;
}

function bool SeqTimeVerified()
{
	return (GameRefVal == (2*(InfoSeqTime - SEQ_ADD)));
}

///////////////////////////////////////////////////////////////////////////////
// Check last code
///////////////////////////////////////////////////////////////////////////////
function bool VerifySeqTime(optional bool bUpdate)
{
	local bool bEStartCheck;
	local bool bverified;

	// xPatch: Changed to be allowed in Custom Difficulty
	// Expert Mode always invalidates verification
	if (InNightmareMode() && !InCustomMode())
		return false;

	if(bUpdate)
		InfoSeqTime = int(ConsoleCommand("get "@InfoSeqPath));
	else
		bEStartCheck=true;

	//log(self$" gameref VerifySeqTime estart "$bEStartCheck$" game start "$TheGameState.bEGameStart);
	if(!bEStartCheck
		|| (TheGameState != None
			&& TheGameState.bEGameStart))
	{

		//log(self$" GameRefVal check "$(2*(InfoSeqTime - SEQ_ADD))$" ref "$GameRefVal$" time "$InfoSeqTime$" start "$bEStartCheck);
		bverified = SeqTimeVerified();

		// If you already beaten the game but it's not been recorded, then record it here.
		if(bverified
			&& !FinallyOver())
			RecordEnding();

		return bverified;
	}
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Calc last code
///////////////////////////////////////////////////////////////////////////////
function int GetSeqTime()
{
	return (GameRefVal/2 + SEQ_ADD);
}

///////////////////////////////////////////////////////////////////////////////
// Decide how many to drop at the start, goes with DiscardInventory
// For the player in a singleplayer game, we can fail to drop all our stuff
// and it's okay
///////////////////////////////////////////////////////////////////////////////
function DiscardPowerupStart(out int checkamount, P2PowerupInv powerupcheck, P2Pawn pawncheck)
{
	if(pawncheck.bPlayer
		&& powerupcheck.bThrowIndividually)
	{
		checkamount = POWERUP_DROP_RATIO*powerupcheck.Amount;
		if(checkamount == 0)
			checkamount = 1;
	}
	else
		checkamount = powerupcheck.Amount;
}
///////////////////////////////////////////////////////////////////////////////
// Make sure what you dropped came out, goes with DiscardInventory
// For the player in a singleplayer game, we can fail to drop all our stuff
// and it's okay
///////////////////////////////////////////////////////////////////////////////
function DiscardPowerupVerify(out int checkamount, P2PowerupInv powerupcheck, P2Pawn pawncheck)
{
	if(pawncheck.bPlayer)
	{
		if(powerupcheck.bThrowIndividually)
			checkamount--;
		else
			checkamount = 0;
	}
	else
		Super.DiscardPowerupVerify(checkamount, powerupcheck, pawncheck);
}

///////////////////////////////////////////////////////////////////////////////
// Check how cool the player is.
///////////////////////////////////////////////////////////////////////////////
function bool CheckCoolness()
{
	return (CoolStart + EndCool == COOL_FACTOR);
}
exec function WriteCoolness()
{
	if(EndCool == 0)
	{
		EndCool = COOL_FACTOR - CoolStart;
		ConsoleCommand("set "@EndCoolPath@EndCool);
	}
}
function bool FinallyOver()
{
	if(TimesBeatenGame == 0)
		CheckAchievments();
		
	return (FOVER_SUM == (FOver + GameRefVal));
}
function bool GinallyOver()
{
	if(TimesBeatenGame == 0)
		CheckAchievments();	
		
	return (GOVER_SUM == (GOver + GameRefVal));
}
function bool HinallyOver()
{
	return (FinallyOver()
		|| GinallyOver());
}

////////////////////////////////////////////////////////////////////////////////////
// If you already beaten the game but it's not been recorded in the INI.
////////////////////////////////////////////////////////////////////////////////////
function CheckAchievments()
{
	local bool bDoFOver;
	local bool bDoGOver;
	
	// check if P2 was completed.
	if (GetPlayer().GetEntryLevel().GetAchievementManager().GetAchievement('FridayComplete'))
		bDoFOver = true;

	// check if AW was completed.
	if (GetPlayer().GetEntryLevel().GetAchievementManager().GetAchievement('SundayComplete'))
		bDoGOver = true;
		
	if (bDoFOver || bDoGOver)	
	{
		PrepIniStartVals();
		TimesBeatenGame++;
	}
	
	if (bDoFOver)
	{
		FOver = FOVER_SUM - GameRefVal;
		ConsoleCommand("set "@FOverPath@FOver);
		ConsoleCommand("set "@TimesBeatenGamePath@TimesBeatenGame);
	}
	if (bDoGOver)
	{
		GOver = GOVER_SUM - GameRefVal;
		ConsoleCommand("set "@GOverPath@GOver);
		ConsoleCommand("set "@TimesBeatenGamePath@TimesBeatenGame);
	}
		
	// AWP completed - unlock Enhanced Game
	if(GetPlayer().GetEntryLevel().GetAchievementManager().GetAchievement('GameComplete'))
	{
		InfoSeqTime = GetSeqTime();
		ConsoleCommand("set "@InfoSeqPath@InfoSeqTime);
	}
}

///////////////////////////////////////////////////////////////////////////////
// When a new game is started, the game state is given this game difficulty
// from the game info (which is the ini val that the player sets). This should
// only happen then, so this value will be saved from now and forced back into
// the game info difficulty when the game is actually running.
///////////////////////////////////////////////////////////////////////////////
function SetupDifficultyOnce()
{
	TheGameState.GameDifficulty = GameDifficulty;
	//log(self$" SetupDifficultyOnce diff lieber heston insane ludicrous hate expert custom "@GameDifficulty@bLieberMode@bHestonMode@bInsaneoMode@bLudicrousMode@bTheyHateMeMode@bExpertMode@bCustomMode);

	// Now also setup flags like liebermode, hestonworld etc.
	TheGameState.bLieberMode = bLieberMode;
	TheGameState.bHestonMode = bHestonMode;
	TheGameState.bTheyHateMeMode = bTheyHateMeMode;
	TheGameState.bInsaneoMode = bInsaneoMode;
	TheGameState.bExpertMode = bExpertMode;
	TheGameState.bCustomMode = bCustomMode;
	TheGameState.bLudicrousMode = bLudicrousMode;
	TheGameState.bMasochistMode = bMasochistMode;
	TheGameState.bVeteranMode = bVeteranMode;
	TheGameState.bMeeleMode = bMeeleMode;
	TheGameState.bHardLieberMode = bHardLieberMode;
	TheGameState.bNukeMode = bNukeMode;
}

///////////////////////////////////////////////////////////////////////////////
// Only to be used when fixing a saved game's difficulty. If we had a liebermode game
// and now the person is about to patch their save with a new difficulty, say average,
// we need to undo all the baton/shovel/taser things and give them their normal weapons.
// But not for the player. Leave him alone.
///////////////////////////////////////////////////////////////////////////////
function FixDifficultyInventories()
{
	local P2Pawn checkpawn;
	log(self$" FixDifficultyInventories");
	foreach DynamicActors(class'P2Pawn', checkpawn)
	{
		if(checkpawn.Health > 0
			&& checkpawn.Controller != None
			&& P2Player(checkpawn.Controller) == None)
		{
			//log(self$" checking "$checkpawn);
			// Remove everything they had
			checkpawn.DestroyAllInventory();
			// Reset them
			checkpawn.ResetGotDefaultInventory();
			// Add in all in again, but have the new difficulty (naturally) set everything
			checkpawn.AddDefaultInventory();
			// If they are in the apocalypse, make sure to get them ready for that.
			if(TheGameState.bIsApocalypse
				&& PersonController(checkpawn.Controller) != None)
				PersonController(checkpawn.Controller).ConvertToRiotMode();
		}
	}
}

//=================================================================================================
//=================================================================================================
//=================================================================================================
//
// Traveling between levels
//
//=================================================================================================
//=================================================================================================
//=================================================================================================

// Copy over all properties from the old GameState and put them in the new one.
function ConvertToNewGameState(GameState OldGS)
{
	local int i;

	if (OldGS.DidPlayerCheat())
		TheGameState.PlayerCheated();
	//TheGameState.bCheated = OldGS.bCheated;
	TheGameState.PeopleKilled = OldGS.PeopleKilled;
	TheGameState.ZombiesKilledOverall = OldGS.ZombiesKilledOverall;
	TheGameState.HeadsLopped = OldGS.HeadsLopped;
	TheGameState.LimbsHacked = OldGS.LimbsHacked;
	TheGameState.ZombiesResurrected = OldGS.ZombiesResurrected;
	TheGameState.CopsKilled = OldGS.CopsKilled;
	TheGameState.ElephantsKilled = OldGS.ElephantsKilled;
	TheGameState.DogsKilled = OldGS.DogsKilled;
	TheGameState.CatsKilled = OldGS.CatsKilled;
	TheGameState.PistolHeadShot = OldGS.PistolHeadShot;
	TheGameState.ShotgunHeadShot = OldGS.ShotgunHeadShot;
	TheGameState.RifleHeadShot = OldGS.RifleHeadShot;
	TheGameState.CatsUsed = OldGS.CatsUsed;
	TheGameState.MoneySpent = OldGS.MoneySpent;
	TheGameState.PeeTotal = OldGS.PeeTotal;
	TheGameState.DoorsKicked = OldGS.DoorsKicked;
	TheGameState.TimesArrested = OldGS.TimesArrested;
	TheGameState.DressedAsCop = OldGS.DressedAsCop;
	TheGameState.DogsTrained = OldGS.DogsTrained;
	TheGameState.PeopleRoasted = OldGS.PeopleRoasted;
	TheGameState.CopsLuredByDonuts = OldGS.CopsLuredByDonuts;
	TheGameState.BaseballHeads = OldGS.BaseballHeads;
	TheGameState.bAddedNewHaters = OldGS.bAddedNewHaters;
	TheGameState.CurrentDay = OldGS.CurrentDay;
	TheGameState.bChangeDayPostTravel = OldGS.bChangeDayPostTravel;
	TheGameState.bChangeDayForDebug = OldGS.bChangeDayForDebug;
	TheGameState.NextDay = OldGS.NextDay;
	TheGameState.ErrandsCompletedToday = OldGS.ErrandsCompletedToday;
	TheGameState.bFirstLevelOfGame = OldGS.bFirstLevelOfGame;
	TheGameState.bFirstLevelOfDay = OldGS.bFirstLevelOfDay;
	TheGameState.JailCellNumber = OldGS.JailCellNumber;
	TheGameState.LastJailCellNumber = OldGS.LastJailCellNumber;
	TheGameState.bLastLevelExitWasReal = OldGS.bLastLevelExitWasReal;
	TheGameState.bShowGameInfo = OldGS.bShowGameInfo;
	TheGameState.CopRadioTime = OldGS.CopRadioTime;
	TheGameState.bPlayerInCell = OldGS.bPlayerInCell;
	TheGameState.bTakePlayerInventory = OldGS.bTakePlayerInventory;
	TheGameState.bNiceDude = OldGS.bNiceDude;
	TheGameState.LastWeaponGroupPee = OldGS.LastWeaponGroupPee;
	TheGameState.LastWeaponOffsetPee = OldGS.LastWeaponOffsetPee;
	TheGameState.LastWeaponGroupHands = OldGS.LastWeaponGroupHands;
	TheGameState.LastWeaponOffsetHands = OldGS.LastWeaponOffsetHands;
	TheGameState.LastSelectedInventoryGroup = OldGS.LastSelectedInventoryGroup;
	TheGameState.LastSelectedInventoryOffset = OldGS.LastSelectedInventoryOffset;
	TheGameState.CatnipUseTime = OldGS.CatnipUseTime;
	TheGameState.HudArmorClass = OldGS.HudArmorClass;
	TheGameState.bCheatGod = OldGS.bCheatGod;
	TheGameState.bEGameStart = OldGS.bEGameStart;
	TheGameState.bPreGameMode = OldGS.bPreGameMode;
	TheGameState.CurrentClothes = OldGS.CurrentClothes;
	TheGameState.TimeSinceErrandCheck = OldGS.TimeSinceErrandCheck;
	TheGameState.MapReminderCount = OldGS.MapReminderCount;
	TheGameState.bIsApocalypse = OldGS.bIsApocalypse;
	TheGameState.MostRecentGameSlot = OldGS.MostRecentGameSlot;
	TheGameState.DemoTime = OldGS.DemoTime;
	TheGameState.bGetsHeadShots = OldGS.bGetsHeadShots;
	TheGameState.GameDifficulty = OldGS.GameDifficulty;
	TheGameState.bLieberMode = OldGS.bLieberMode;
	TheGameState.bHestonMode = OldGS.bHestonMode;
	TheGameState.bTheyHateMeMode = OldGS.bTheyHateMeMode;
	TheGameState.bInsaneoMode = OldGS.bInsaneoMode;
	TheGameState.bExpertMode = OldGS.bExpertMode;
	TheGameState.bMasochistMode = OldGS.bMasochistMode;
	TheGameState.bVeteranMode = OldGS.bVeteranMode;
	TheGameState.bMeeleMode = OldGS.bMeeleMode;
	TheGameState.bHardLieberMode = OldGS.bHardLieberMode;
	TheGameState.bNukeMode = OldGS.bNukeMode;
	TheGameState.TimeElapsed = OldGS.TimeElapsed;
	TheGameState.bShovelEndingDQ = OldGS.bShovelEndingDQ;
	TheGameState.bReadMondayPaper = OldGS.bReadMondayPaper;
	TheGameState.bReadTuesdayPaper = OldGS.bReadTuesdayPaper;
	TheGameState.bReadWednesdayPaper = OldGS.bReadWednesdayPaper;
	TheGameState.bReadThursdayPaper = OldGS.bReadThursdayPaper;
	TheGameState.bReadFridayPaper = OldGS.bReadFridayPaper;
	TheGameState.DressedAsGimp = OldGS.DressedAsGimp;
	TheGameState.CrackSmoked = OldGS.CrackSmoked;
	TheGameState.CatnipSmoked = OldGS.CatnipSmoked;
	TheGameState.bCopKilla = OldGS.bCopKilla;
	TheGameState.bCharisma = OldGS.bCharisma;
	//TheGameState.bPlayaHata = OldGS.bPlayaHata;
	TheGameState.RandSeed = OldGS.RandSeed;

	// Arrays
	for (i=0; i<OldGS.DoorsArr.Length; i++)
		TheGameState.DoorsArr[i] = OldGS.DoorsArr[i];
	for (i=0; i<OldGS.PawnsArr.Length; i++)
		TheGameState.PawnsArr[i] = OldGS.PawnsArr[i];
	for (i=0; i<OldGS.WeaponsArr.Length; i++)
		TheGameState.WeaponsArr[i] = OldGS.WeaponsArr[i];
	for (i=0; i<OldGS.PowerupsArr.Length; i++)
		TheGameState.PowerupsArr[i] = OldGS.PowerupsArr[i];
	for (i=0; i<OldGS.TeleportedPawns.Length; i++)
		TheGameState.TeleportedPawns[i] = OldGS.TeleportedPawns[i];
	for (i=0; i<OldGS.CompletedErrands.Length; i++)
		TheGameState.CompletedErrands[i] = OldGS.CompletedErrands[i];
	for (i=0; i<OldGS.ActivatedErrands.Length; i++)
		TheGameState.ActivatedErrands[i] = OldGS.ActivatedErrands[i];
	for (i=0; i<OldGS.RevealedErrands.Length; i++)
		TheGameState.RevealedErrands[i] = OldGS.RevealedErrands[i];
	for (i=0; i<OldGS.CurrentHaters.Length; i++)
		TheGameState.CurrentHaters[i] = OldGS.CurrentHaters[i];
	for (i=0; i<OldGS.GottenPickups.Length; i++)
		TheGameState.GottenPickups[i] = OldGS.GottenPickups[i];
	for (i=0; i<OldGS.InactiveInvHints.Length; i++)
		TheGameState.InactiveInvHints[i] = OldGS.InactiveInvHints[i];
}
///////////////////////////////////////////////////////////////////////////////
// xPatch: New function to change the GameState.
// Called from MenuStart.StartGame2(), which needs it for a major bug fix.
///////////////////////////////////////////////////////////////////////////////
function ChangeGameState(class<GameState>NewGameStateClass)
{
	if(NewGameStateClass != None)
	{
		if (TheGameState != None)
		{
			Log(self$" ChangeGameState(): Deleting current GameState");
			GetPlayer().MyPawn.DeleteInventory(TheGameState);
			TheGameState = None;
		}
		TheGameState = spawn(NewGameStateClass);
		Log(self$" ChangeGameState(): The new GameState is:"@TheGameState@NewGameStateClass);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called from P2Player.TravelPostAccept(), which is after the player pawn
// has traveled to (or been created in) a new level.
//
// This ultimately gets called in three basic situations, shown here along
// with how to differentiate them:
//
//  Loaded game: TheGameState != None
//	New game:    TheGameState == None and player's inventory does NOT contain GameState
//  New level:   TheGameState == None and player's inventory contains GameState
//
///////////////////////////////////////////////////////////////////////////////
event PostTravel(P2Pawn PlayerPawn)
	{
	local GameState GroundhogDayGameState;
	local Mutator TestMutator;
	local class<HolidaySpawnerBase> HolidaySpawnerClass;
	local int iDay, i;

	if (TheGameState != None)
		{
		// We loaded a saved game
		bLoadedSavedGame = true;
		Log(self$" PostTravel(): Loaded a saved game (using the loaded GameState)");
		}
	else
		{
		// Try to get GameState from player's inventory
		TheGameState = GameState(PlayerPawn.FindInventoryType(GameStateClass));
		// Look for any Groundhog Day GameStates.

		if (TheGameState != None)
			{
			PlayerPawn.DeleteInventory(TheGameState);
			if (PlayerPawn.FindInventoryType(class'GameState') != None)
				{
				// "Groundhog Day Glitch" fix
				// Hotfix #2 changed P2GameInfoSingle's GameStateClass from class'GameState' to class'AWGameState'.
				// As a result, POSTAL 2 saves from before Hotfix #2 had the wrong GameState and would not cast to AWGameState.
				// This fix pulls the "old" GameState from the inventory, and replaces it with the correct GameState class, copying over
				// all of GameState's properties in the process.
				GroundhogDayGameState = GameState(PlayerPawn.FindInventoryType(class'GameState'));
				TheGameState = spawn(GameStateClass);
				PlayerPawn.DeleteInventory(GroundhogDayGameState);
				Log(self$" PostTravel(): Continuing existing game (Groundhog Day Glitch: got old GameState from player inventory)");
				ConvertToNewGameState(GroundhogDayGameState);
				GroundhogDayGameState.Destroy();
				Log(self$" Deleted old GameState, all info now in proper GameState class");
				}
			else
				Log(self$" PostTravel(): Continuing existing game (got GameState from player inventory)");
				
			}
		else
			{
			Log(self$" PostTravel(): Starting new game (creating new GameState)");
			TheGameState = spawn(GameStateClass);

			// We just created a new GameState, so if we're NOT on one of the
			// "pre game" maps then we must be testing a map by loading it directly.
			if (IsMainMenuMap() || IsIntroMap())	
				{
				TheGameState.bPreGameMode = true;
				SetupDifficultyOnce();
				}
			else
				{
				// Start new game for testing
				bTesting = true;
				TheGameState.bChangeDayPostTravel = true;
				// If they specified a certain day on the command line, set it here
				if (ForceDayOnStartup != -1)
				{
					TheGameState.NextDay = ForceDayOnStartup - 1;
					SetDayAtLaunch();
				}
				else
					TheGameState.NextDay = 0;
				TheGameState.PlayerCheated("Testing maps via command line");	// don't allow unlocking of achievements this way
				TheGameState.TimeStart = Level.GetMillisecondsNow();			// Start time is now.
				TheGameState.PreTravelTime = TheGameState.TimeStart;			// Say our pre-travel time is now, so we don't count all the initial loading shit.
				P2RootWindow(GetPlayer().Player.InteractionMaster.BaseMenu).StartingGame();
				MostRecentGameSlot = -1; // This is unknown when testing
				SetupDifficultyOnce();
				}
			}
			
			if (bWorkshopGame/* && !xManager.bWSAchievements*/)		// xPatch: Allows achievements for workshop games. (Mod-Exclusive)
				TheGameState.PlayerCheated("Workshop game");
			
			// Allows for testing enhanced game via command line
			if (bEGameStart)
				TheGameState.bEGameStart = true;
				
			// Turn on night mode if applicable
			if (IsHoliday(NIGHT_MODE_HOLIDAY))
				TheGameState.bNightMode = true;

		// xPatch: Allows achievements for workshop games. (Mod-Exclusive)
		/*if(!xManager.bWSAchievements)*/
//		{
			// Check the mutator chain. If the player added any Workshop game mods, consider the game cheated and ineligible for speedruns/achievements.
			for (TestMutator = BaseMutator; TestMutator != None; TestMutator = TestMutator.NextMutator)
			{
				if (String(TestMutator.Class) != MutatorClass)
				{
					TheGameState.PlayerCheated("Using Workshop game mod");
					break;
				}
			}
//		}

		// Check if we need to change the day (includes starting a new game)
		if (TheGameState.bChangeDayPostTravel)
			{
			// Check if starting a new game
			if (NextDay() == 0)	
				{
				TheGameState.bFirstLevelOfGame = true;
				TheGameState.bPreGameMode = false;
				
				//GetPlayer().ClientMessage("starting a new game");

				// Check for valid errand goals (only done once, reports errors to log)
				CheckForValidErrandGoals();
				}
			// xPatch: starting a new game from the selected day
			else if (TheGameState.bStartDayPostTravel)	
				{
				TheGameState.bFirstLevelOfGame = false;
				TheGameState.bFirstLevelOfDay = true;
				TheGameState.bPreGameMode = false;
				
				// Loadout
				GetLoadOut(TheGameState.StartDay);
				
				// Always give the player starting inventory 
				// from the first day (Map, Money, Stats)
				Days[0].AddInStartingInventory(PlayerPawn);
					
				// Remove inventory player can't leave the previous days with
				// It will take care of removing map on weekend etc.
				for (i = 0; i < TheGameState.StartDay; i++)
					Days[i].TakeInventoryFromPlayer(PlayerPawn);
				
				// TWO WEEKS IN PARADISE FIX:
				// Check if we are starting from second week
				if (TwoWeeksGame() && TheGameState.StartDay >= DAY_PLMONDAY)
				{
					// Give the player the 2nd Monday starting inventory 
					// (Since the map was taken away by weekend days)
					Days[DAY_PLMONDAY].AddInStartingInventory(PlayerPawn);
					
					// completing errands adds haters, but we don't want 
					// haters from P2 since they were nuked haha
					// so yeah, easy fix, set only PL errands completed
					// since we don't need P2 errands status for anything anyways.
					if(TheGameState.StartDay > DAY_PLMONDAY)
					{
						for (iDay = DAY_PLMONDAY; iDay < TheGameState.StartDay; iDay++)
						{
							for (i = 0; i < Days[iDay].Errands.Length; i++)
								SetThisErrandComplete(Days[iDay].Errands[i].UniqueName);
						}
					}
				}
				else // Set all errands from previous days as completed
				{
					for (iDay = 0; iDay < TheGameState.StartDay; iDay++)
					{
						for (i = 0; i < Days[iDay].Errands.Length; i++)
							SetThisErrandComplete(Days[iDay].Errands[i].UniqueName);
					}
				}

				// setting errands as completed added haters 
				// but we still need to set them as revealed.
				for (i = 0; i < TheGameState.CurrentHaters.length; i++)
				{
					TheGameState.CurrentHaters[i].Revealed = 1;
				}
				
				// We did add new haters but they are already revealed so make it false 
				// We don't want the game to buttsauce itself during level transition 
				TheGameState.bAddedNewHaters=false;

				// Check for valid errand goals (only done once, reports errors to log)
				CheckForValidErrandGoals();
				
				// Starting day is done
				TheGameState.bStartDayPostTravel = false;
				}
			// xPatch: End
			else
				{
				TheGameState.bFirstLevelOfGame = false;

				// Remove inventory player can't leave the current day with
				Days[TheGameState.CurrentDay].TakeInventoryFromPlayer(PlayerPawn);
				}

			// Change the day
			TheGameState.CurrentDay = NextDay();
			TheGameState.bFirstLevelOfDay = true;
			TheGameState.ErrandsCompletedToday = 0;
			TheGameState.bChangeDayPostTravel = false;
			TheGameState.bChangeDayForDebug = false;
			}
		else
			{
			// Same day, so clear flag
			TheGameState.bFirstLevelOfDay = false;
			}
			
		// Bring in a holiday spawner, if used
		HolidaySpawnerClass = class<HolidaySpawnerBase>(DynamicLoadObject(HolidaySpawnerClassName, class'Class'));
		//log("Spawn"@HolidaySpawnerClass,'HolidaySpawner');
		if (HolidaySpawner == None && HolidaySpawnerClass != None)
			HolidaySpawner = Spawn(HolidaySpawnerClass);

		// GameInfo is now valid
		GameInfoIsNowValid();

		// Tell GameState the level has changed
		TheGameState.PostLevelChange(PlayerPawn, ParseLevelName(Level.GetLocalURL()));

		// Get most recent slot
		MostRecentGameSlot = TheGameState.MostRecentGameSlot;

		// Restore day and its errands
		RestoreDayAndErrands();

		// Restore pawns that teleported with the player
		TheGameState.RestoreAllTeleportedPawns(PlayerPawn);

		// Handle changing things because we're going to the first level of a new day
		if (TheGameState.bFirstLevelOfDay)
		{
			// Check if we need to give the player the starting inventory for this day
			Days[TheGameState.CurrentDay].AddInStartingInventory(PlayerPawn);
			// Check to delete any dynamic variables expiring at the end of the day
			TheGameState.ClearDailyDynamicVariables();
		}

		// 30 Lives Cheat
		if (bContraMode)
		{
			P2Player(PlayerPawn.Controller).ContraCode();
			bContraMode = false;
			SaveConfig();
		}

		// See if the game mods want to do anything
		BaseMod.PostTravel(PlayerPawn);

		// xPatch: Change main menu map if needed.
		UpdateMainMenu();
		
		// See if holidays want to do anything
		PostTravelForHolidays(PlayerPawn);

		// Decide whether auto-save should be done (although it's not actually
		// done here).  We force an autosave at the start of the game's first level
		// even if autosave is disabled because we need something to go back to
		// when the player dies and wants to to restart (we can't assume he'll save
		// on his own).  We also force an autosave at the start of each day because
		// most players won't realize they'd have to go back to a previous day if
		// they don't manually save on a new day.
		bDoAutoSave = false;
		if (!Level.IsDemoBuild() && !IsFinishedDayMap())
			{
			if ((bUseAutoSave && !IsPreGame()) || TheGameState.bFirstLevelOfDay)
				{
				bDoAutoSave = true;
				AutoSaveSlot = AUTOSAVE_SLOT;
				if (TheGameState.bFirstLevelOfDay)
					bForcedAutoSave = true;
				}
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// PostTravel for holidays.
// See if we want to do anything to the world based on what holiday is in effect.
// For example, turn off distance fog on St. Patrick's so players can see the
// rainbow emitter from the pot of gold.
///////////////////////////////////////////////////////////////////////////////
function PostTravelForHolidays(P2Pawn PlayerPawn)
{
	const c_fFogOffValue		= 50000.0;

	local int i;
	local ZoneInfo zone;

	for (i=0; i < Holidays.Length; i++)
	{
		//log("holiday check"@holidays[i].holidayname);
		// Check against the date.
		if (IsHoliday(Holidays[i].HolidayName))
		{
			//log("holiday ok"@holidays[i].holidayname);
			// Do something based on holiday group name
			if (Holidays[i].HolidayName == 'SeasonalStPatricks')
			{
				// St. Patrick's Day - turn off distance fog so the player can see the rainbow for the pot o' gold.
				foreach AllActors(class'ZoneInfo', zone)
				{
					if (zone.class != class'SkyZoneInfo'
						&& zone.bUseGlobalFog)
					{
						// Turn off the fog in this zone, and untick UseGlobalFog so the sniper rifle won't try to change it back.
						zone.bUseGlobalFog = false;
						zone.DistanceFogStart = c_fFogOffValue;
						zone.DistanceFogEnd = c_fFogOffValue;
					}
				}
			}
			
			// xPatch: Use the Halloween startup
			if(ParseLevelName(Level.GetLocalURL()) != MainMenuURL
				&& Holidays[i].HolidayName == 'SeasonalHalloween')
			{
				default.MainMenuURL = "Startup-Halloween";
				MainMenuURL = "Startup-Halloween";
			}
		}
	}
	// Either passed all date checks or wasn't for a holiday -- keep
}

///////////////////////////////////////////////////////////////////////////////
// Our lowest-level function for sending a player to a URL.
// You should normally call SendPlayerTo() instead of this.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerEx(
	PlayerController player,
	String URL,
	optional ETravelType TravelType,
	optional ETravelItems TravelItems)
	{
	local GameState PreTravelGameState;
	
	// If we're loading a game then it implies certain options
	if (InStr(URL, LOADGAME_URL) >= 0)
		{
		TravelType = TRAVEL_Absolute;
		TravelItems = TRAV_WithoutItems;
		};

	// Clear references to day/errand objects so they will be garbage collected.
	// NOTE: Turns out there are other references to these objects so this
	// didn't have any effect.  Instead of trying to delete them, we learned to
	// accept the idea that they never go away.  See RestoreDayAndErrands().
//	for (i = 0; i < Days.Length; i++)
//		Days[i].Errands.Remove(0, Days[i].Errands.Length);
//	Days.Remove(0, Days.Length);

	// Record at what time we start loading.
	// Because the game state is already in the player's inventory we have to fish it out and change it there.
	PreTravelGameState = GameState(P2Pawn(Player.Pawn).FindInventoryType(GameStateClass));
	if (PreTravelGameState != None)
	{
		// if we're quitting or the game is over, zero out the time so it won't show on the main menu
		if (bQuitting || bGameIsOver)
		{
			PreTravelGameState.TimeStart = vect(0,0,0);
			PreTravelGameState.PreTravelTime = vect(0,0,0);
			PreTravelGameState.TimeStop = vect(0,0,0);
			//log("Strict IGT: Zeroing out timers before going to main menu");
		}
		else
		{
			PreTravelGameState.PreTravelTime = Level.GetMillisecondsNow();
			//log("Strict IGT: PreTravelTime is"@PreTravelGameState.PreTravelTime);
		}
	}
	
	// If we're going back to the main menu, make sure any leftover items, game states, etc. are not carried with us.
	if (bQuitting || bGameIsOver)
	{
		TravelType = TRAVEL_Absolute;
		TravelItems = TRAV_WithoutItems;
	}
	
	//log("Strict IGT: SendPlayerEx level time is"@Level.GetMillisecondsNow());

	Super.SendPlayerEx(player, URL, TravelType, TravelItems);
	}

///////////////////////////////////////////////////////////////////////////////
// Called to send the player to a new level.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerTo(
	PlayerController player,
	String URL,
	optional bool bMaybePawnless)
	{

	local P2PowerupPickup powerpick;
	local P2WeaponPickup weaponpick;
	local Inventory Copy;
	local int peer,pound;
	local string MapName,TelepadName,BaseURL,temp1,temp2,peerstr;
	
	if (URL == MainMenuURL)
		URL = URL $ "?Mutator=?Workshop=";

	if(TheGameState == None)
		Warn("TheGameState=none");
	if (player == None)
		Warn("player=none");
	if (player.pawn == none && !bMaybePawnless)
		Warn("player.pawn=none");

	// Fix for when the player gets arrested while in the jail, but without having
	// taken their bForTransferOnly pickups from the "evidence room".
	// This caused the player to lose all those pickups, including errand-related
	// pickups, leading to unwinnable situations like losing the clipboard on Tuesday, etc.
	// Solution: if bTakePlayerInventory is set to true in the gamestate, then go through
	// the current map BEFORE we send them, and just give them back the items they
	// had taken from them already. Then when they respawn in the jail cell, the items
	// will be taken yet again and placed in the evidence room -- creating the illusion
	// that the items were left there the entire time, which makes more sense than having
	// them disappear just because the dude was stupid enough to get himself arrested again.

	// The REAL fix for this is to get persistent pickups/weapons working again, but this will do for the hotfix
	if (TheGameState.bTakePlayerInventory && !bMaybePawnless)
	{
		foreach DynamicActors(class'P2PowerupPickup', powerpick)
		{
			// If a transfer pickup, force the Dude to take it before traveling.
			if (powerpick.bForTransferOnly)
			{
				Copy = powerpick.SpawnCopy(Player.Pawn);
				powerpick.AnnouncePickup(Player.Pawn);
				Copy.PickupFunction(Player.Pawn);
				powerpick.SetRespawn();
			}
		}
		foreach DynamicActors(class'P2WeaponPickup', weaponpick)
		{
			// If a transfer pickup, force the Dude to take it before traveling.
			if (weaponpick.bForTransferOnly)
			{
				Copy = weaponpick.SpawnCopy(Player.Pawn);
				weaponpick.AnnouncePickup(Player.Pawn);
				Copy.PickupFunction(Player.Pawn);
				weaponpick.SetRespawn();
			}
		}
	}

	// See if the game mods want to do anything
	BaseMod.SendPlayerTo(Player, URL, bMaybePawnless);
	
	// If in night mode, and a night version of the map exists, send them there
	if (TheGameState.bNightMode)
	{
		// First strip out the "?peer"
		peer = InStr(URL,"?peer");
		if (peer >= 0)
		{
			BaseURL = Left(URL, peer);
		}
		else
			BaseURL = URL;

		// String should now be "mapname#telepadname"
		pound = InStr(BaseURL, "#");
		if (pound >= 0)
		{
			MapName = Left(BaseURL, pound);
			TelepadName = Right(BaseURL, Len(BaseURL) - pound - 1);
		}
		// If no pound sign found, then they didn't specify a telepad, the string is now just the mapname.
		else
			MapName = BaseURL;
			
		// If a night version of MapName exists, change it
		if (DoesMapExist("ngt-"$MapName$".fuk"))
			MapName = "ngt-"$MapName;

		// Re-assemble the URL based on what the mods did
		// Skip the "?peer" if not provided
		if (peer >= 0)
			peerstr = "?peer";
			
		if (TelepadName != "")
			URL = MapName $ "#" $ TelePadName $ peerstr;
		else
			URL = MapName $ peerstr;
	}

	// Let player prepare to travel
	P2Player(Player).PreTravel();

	// Add GameState (and related items) to player's inventory to travel to next level
	// (unless we're heading to the main menu, in which case the game is over)
	if (!bQuitting && (Player.Pawn != None))
	{
		// Remember the most recent slot
		TheGameState.MostRecentGameSlot = MostRecentGameSlot;

		// Let GameState prepare itself and then add it to the player's inventory
		TheGameState.PreLevelChange(P2Player(Player).MyPawn, ParseLevelName(Level.GetLocalURL()));
		if (player.pawn.AddInventory(TheGameState))
			Log(self @ "SendPlayerTo(): added GameState to player's inventory");
		else
			Warn("failed to add GameState to player inventory");
	}

	player.MyHUD.bHideHud = true;

	// Check if a screen will be displayed during the transition or if it's a seamless
	// transition.  If a screen is used, it will ultimataly call SendPlayerEx(), too.

	// If we want to force no loading screen, just send them now
	if (bForceNoLoadingScreen)
	{
		bForceNoLoadingScreen = false;
		SendPlayerEx(player, URL);
	}
	// When loading saved games from the menu, force display of that day's load texture
	// Ignore the current game's days, go off of what the slot info says.
	else if (ForcedLoadTex != None)
	{
		if (bForceNoLoadFade)
			P2Player(player).DisplayLoadForcedNoFade(ForcedLoadTex, URL);
		else
			P2Player(player).DisplayLoadForced(ForcedLoadTex, URL);
		ForcedLoadTex = None;
		bForceNoLoadFade = false;
	}
	else if (bShowErrandsDuringLoad)
		P2Player(player).DisplayMapErrands(URL);
	else if(bShowHatersDuringLoad
		&& !TheyHateMeMode())	// Skip haters during They Hate Me (everyone with a gun hates you anyway)
		P2Player(player).DisplayMapHaters(URL);
	else if (bShowDayDuringLoad)
		P2Player(player).DisplayLoad(Days[DayToShowDuringLoad], URL);
	else if (TheGameState.bPreGameMode)
		P2Player(player).DisplayLoad(Days[0], URL);
	else if (TheGameState.bChangeDayPostTravel)
		P2Player(player).DisplayLoad(Days[NextDay()], URL);
	else if (bShowStatsDuringLoad)
		P2Player(player).DisplayStats(URL);
	else if (bCrossOutErrandDuringLoad)
		P2Player(player).DisplayMapCrossOut(ErrandCompletedDuringLoad, '', URL);
	else
		SendPlayerEx(player, URL);

	TheGameState = None;
	Log(self @ "SendPlayerTo(): discarded TheGameState");
	}

///////////////////////////////////////////////////////////////////////////////
// Send player across level transition.
// Player may be diverted home if the conditions are right.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerLevelTransition(PlayerController player, String URL, bool bRealLevelExit)
{
	// If this is a real level exit and we recently added new haters, then mark that
	// we want to show them during the next load, and clear the addednewhaters flag.
	if(bRealLevelExit
		&& TheGameState.bAddedNewHaters)
	{
		bShowHatersDuringLoad=true;
		TheGameState.bAddedNewHaters=false;
	}

	TheGameState.bLastLevelExitWasReal = bRealLevelExit;

	if (WillPlayerBeDivertedHome(URL, bRealLevelExit))
	{
		if (Days[TheGameState.CurrentDay].FinishedDayURL != "")
			// If the current day has a special ending URL defined, send player to that
			URL = Days[TheGameState.CurrentDay].FinishedDayURL;
		else
			URL = FinishedDayURL;
	}

	SendPlayerTo(player, URL);
}

///////////////////////////////////////////////////////////////////////////////
// Send player to the first day
///////////////////////////////////////////////////////////////////////////////
function SendPlayerToFirstDay(PlayerController player, optional bool bDontShowMap)
	{
	// Only do special movie in full game
	if(!Level.IsDemoBuild())
		{
		if (!bDontShowMap)
			bShowErrandsDuringLoad = true;

		// If player doesn't have a pawn, it's probably because a scene is running
		if (player.pawn == None)
			StopSceneManagers();
		}

	TheGameState.bChangeDayPostTravel = true;
	TheGameState.NextDay = 0;
	SendPlayerTo(player, StartFirstDayURL);
	}

///////////////////////////////////////////////////////////////////////////////
// Send player to the next day
///////////////////////////////////////////////////////////////////////////////
function SendPlayerToNextDay(PlayerController player)
	{
	// See if there's any more days
	if (TheGameState.CurrentDay + 1 < Days.length)
		{
		TheGameState.bChangeDayPostTravel = true;
		TheGameState.NextDay = TheGameState.CurrentDay + 1;
		// If the DayBase has defined the starting day, send player to it
		if (Days[TheGameState.NextDay].StartDayURL != "")
			SendPlayerTo(player, Days[TheGameState.NextDay].StartDayURL);
		// Otherwise, send the player to the "next day" map
		else
			SendPlayerTo(player, StartNextDayURL);
		}
	else
		{
		// This shouldn't happen because the end-of-game movie
		// should end up calling EndOfGame() instead.  If it does
		// happen we'll treat it like a quit.
		QuitGame();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Send player to jail.  Each time the player goes to jail, he's put in a
// different cell.  The jail map must contain a series of Telepads named
// "cell1" through "celln" where 'n' is LAST_JAIL_CELL_NUMBER.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerToJail(PlayerController player)
	{
	local P2Pawn ppawn;

	// If there is no jail map defined, use the old "demo" jail method (Workshop support)
	if (JailURL == ""
		&& Days[TheGameState.CurrentDay].JailURL == "")
	{
		P2RootWindow(Player.Player.InteractionMaster.BaseMenu).ArrestedDemo();
		return;
	}

	// Keep using a higher jail cell number until we reach the last one
	if (TheGameState.JailCellNumber < TheGameState.LastJailCellNumber)
		TheGameState.JailCellNumber++;

	// This doesn't travel, but just say that the player is going to jail
	// for the SendPlayer function
	TheGameState.bSendingPlayerToJail=true;

	// Record that we were sent to jail
	TheGameState.TimesArrested++;

	// Mark his inventory to be taken on entry to the jail level
	TheGameState.bTakePlayerInventory=true;

	// Give him up to full health (not if he's already over 100%)
	ppawn = P2Pawn(Player.Pawn);
	if(ppawn != None
		&& ppawn.Health < ppawn.HealthMax)
		ppawn.Health = ppawn.HealthMax;

	// Reset the cop radio--you're not wanted anymore
	TheGameState.ResetCopRadioTime();

	//log(self$" cop radio time "$TheGameState.CopRadioTime);
	// Send player to the appropriate jail cell
	if (Days[TheGameState.CurrentDay].JailURL != "")
		SendPlayerTo(player, Days[TheGameState.CurrentDay].JailURL $ TheGameState.JailCellNumber $ "?peer");
	else
		SendPlayerTo(player, JailURL $ TheGameState.JailCellNumber $ "?peer");
	}

///////////////////////////////////////////////////////////////////////////////
// Figure out what the next day would be
///////////////////////////////////////////////////////////////////////////////
function int NextDay()
	{
	if (TheGameState.bChangeDayPostTravel)
		return TheGameState.NextDay;
	return TheGameState.CurrentDay;
	}

///////////////////////////////////////////////////////////////////////////////
// Returns true if player will be diverted home given the specified URL and
// telepad flag.  Other conditions are also taken into account when making
// this decision.
///////////////////////////////////////////////////////////////////////////////
function bool WillPlayerBeDivertedHome(String URL, bool bRealLevelExit)
	{

	return IsPlayerReadyForHome() &&	// Only if he's ready to go home
			bRealLevelExit &&			// Only if it's a real level transition
			!Level.IsDemoBuild() &&		// Never do this for the demo version
			!IsWeekend()				// Never send player back home during the weekend
			&& !AfterFinalErrand();		// It's Day 5, we're done with the last errand, so
										// don't send him straight home--make him walk there
	}

///////////////////////////////////////////////////////////////////////////////
// The player is back at his trailer and checking to see if he's ready to go
// something different. He can beat the game, beat the demo
///////////////////////////////////////////////////////////////////////////////
function AtPlayerHouse(P2Player p2p, optional bool bForce)
{
	if(AfterFinalErrand())
	{
		if(Level.IsDemoBuild())
		{
			// You beat the demo, so go to the end demo screen
			// FIXME: This works but it's a pretty clunky way to handle this.
			// Maybe we should change the demo so you are taken home-at-night
			// when you're done, and then we'll show this screen afterwards.
			// Or something like that.
			P2RootWindow(p2p.Player.InteractionMaster.BaseMenu).BeatDemo();
		}
		else
		{
			if (TheGameState.CurrentDay + 1 >= Days.Length)
			{
				// This is the last day and we're at the house. Game is over! Call time.
				TheGameState.TimeStop = Level.GetMillisecondsNow();
			}
		
			// End the apocalypse now that you made it to your house.. shew!
			// Also keeps it from raining cats during the ending movie.
			TheGameState.bIsApocalypse=false;
			// You beat the game! Now go to home at night. The home at
			// night map will have a different move to play for the end of game sequence,
			// will then show you stat screen, and will then spit you out to the credit menu
			// at which point you'll be back to the normal menu and have been through the whole game.
			if (Days[TheGameState.CurrentDay].FinishedDayURL != "")
				// If the current day has a special ending URL defined, send player to that
				SendPlayerTo(p2p, Days[TheGameState.CurrentDay].FinishedDayURL);
			else
				SendPlayerTo(p2p, FinishedDayURL);
		}
	}
	else if(IsPlayerReadyForHome() || bForce)	// If we're at your house and you're ready for home, then send you there.
	{
		if (Days[TheGameState.CurrentDay].FinishedDayURL != "")
			// If the current day has a special ending URL defined, send player to that
			SendPlayerTo(p2p, Days[TheGameState.CurrentDay].FinishedDayURL);
		else
			SendPlayerTo(p2p, FinishedDayURL);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check if we're in the "pre-game" mode (main menu, intro, etc.)
///////////////////////////////////////////////////////////////////////////////
function bool IsPreGame()
	{
	if (TheGameState != None)
		return TheGameState.bPreGameMode;
	// There should always be a gamestate during the game, so the lack thereof
	// would indicate a non-game mode, which we'll treat as "pre-game".
	return true;
	}

///////////////////////////////////////////////////////////////////////////////
// Check if the current map is the "intro" map
///////////////////////////////////////////////////////////////////////////////
function bool IsIntroMap()
	{
	//log("IsIntroMap"@Level.GetLocalUrl()@"vs."@IntroURL);
	return (ParseLevelName(Level.GetLocalURL()) ~= ParseLevelName(IntroURL)
		|| ParseLevelName(Level.GetLocalURL()) == "Startup.fuk");
		// Hardcode to assume "Startup.fuk" is always an intro map.
		// Right now this is less risky than altering ParseLevelName to get the .fuk out (get it?!)
	}

///////////////////////////////////////////////////////////////////////////////
// Check if the current map is the "finished day" map
///////////////////////////////////////////////////////////////////////////////
function bool IsFinishedDayMap()
	{
	return ParseLevelName(Level.GetLocalURL()) ~= ParseLevelName(FinishedDayURL);
	}


//=================================================================================================
//=================================================================================================
//=================================================================================================
//
// Days and errands
//
//=================================================================================================
//=================================================================================================
//=================================================================================================


///////////////////////////////////////////////////////////////////////////////
// Returns true if player is ready to go home.  In other words, have all the
// day's errands been completed?
///////////////////////////////////////////////////////////////////////////////
function bool IsPlayerReadyForHome()
	{
	// If todays errands are completed then he's ready to go home
	// Using >= instead of == for testing/debugging where we set all
	// errands complete, regardless of whether they are active or not.
	return TheGameState.ErrandsCompletedToday >= Days[TheGameState.CurrentDay].NumActiveErrands();
	}

///////////////////////////////////////////////////////////////////////////////
// This is *THE* function for checking whether an errand has been completed.
//
// Is is called by various locations in the code where an errand could possibly
// be completed due to a particular action or pickup or whatever else might
// complete an errand.
//
// If an errand is completed by the action/pickup/whatever, then the errand
// is marked as completed and the map screen is brought up to cross it off.
///////////////////////////////////////////////////////////////////////////////
function bool CheckForErrandCompletion(
	Actor Other,
	Actor Another,
	Pawn ActionPawn,
	P2Player ThisPlayer,
	bool bPremature,
	optional string SendToURL)
{
	local bool bCompleted;
	local int Errand;
	local name CompletionTrigger;
	local name HateClass;
	local name HateDesTex;
	local name HatePicTex;
	local string SendPlayerURL;
	
	if(TheGameState == None)
		return false;

	// Check if the specified stuff has completed an errand.  Note that
	// this function will actually mark the errand as completed, so it's
	// a one-shot thing (it will return "true" once and then will return
	// "false" if called again with the same parameters).
	bCompleted = Days[TheGameState.CurrentDay].CheckForErrandCompletion(
		Other,
		Another,
		ActionPawn,
		bPremature,
		TheGameState,
		Errand,				// OUT: which errand was completed
		CompletionTrigger,	// OUT: name of trigger that must occur
		SendPlayerURL);		// OUT: URL to send player to
		
	// If the errand specified a send-to URL and we're not overriding it, set it now
	if (SendtoURL == "" && SendPlayerURL != "")
		SendToURL = SendPlayerURL;

	if(bCompleted)
	{
		TheGameState.ErrandsCompletedToday++;
		SaveCompletedErrand(TheGameState.CurrentDay, Errand);

		// Make sure to have a player when bringing up the map.
		if(ThisPlayer == None)
			ThisPlayer = GetPlayer();
			
		// Display the map to cross out the errand
		// Don't allow map display on weekend
		if (!IsWeekend())
		{
			// SendToURL requires some special handling
			if (SendToURL != "")
			{
				bCrossOutErrandDuringLoad = true;
				ErrandCompletedDuringLoad = Errand;
				SendPlayerTo(ThisPlayer, SendToURL);
			}
			else
				ThisPlayer.DisplayMapCrossOut(Errand, CompletionTrigger);
		}
			

		// Check to see if this completes any errands
		CheckForErrandCompletion(ThisPlayer, ThisPlayer, ThisPlayer.Pawn, ThisPlayer, False);
	}

	return bCompleted;
}

 ///////////////////////////////////////////////////////////////////////////////
// Add all of our haters (usually only one) for this day. This only adds them
// and makes them start hating you. It doesn't force the map to come up and tell
// the player about them. This happens at the next level transition.
///////////////////////////////////////////////////////////////////////////////
function AddTodaysHaters()
{
	local int i;
	local P2Player ThisPlayer;

	ThisPlayer = GetPlayer();

	if(Days.Length > TheGameState.CurrentDay)
		Days[TheGameState.CurrentDay].AddMyHaters(TheGameState, ThisPlayer);
}


///////////////////////////////////////////////////////////////////////////////
// Go through all the errands and see if they care about this actor, as
// marked by the errand ignoretag.
///////////////////////////////////////////////////////////////////////////////
function bool ErrandIgnoreThisTag(Actor Other)
	{
	local int i;

	for(i = 0; i < Days.Length; i++)
		{
		if(Days[i] != None)
			{
			if(Days[i].IgnoreThisTag(Other))
				return true;
			}
		}

	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Check if the specified errand is complete.
///////////////////////////////////////////////////////////////////////////////
function bool IsErrandCompleted(String UniqueName)
	{
	local int Day;
	local int Errand;

	if (FindErrand(UniqueName, Day, Errand))
		{
		if (Days[Day].IsErrandComplete(Errand))
			return true;
		}
	else
		Warn("P2GameInfoSingle.IsErrandCompleted(): Couldn't find errand with UniqueName="$UniqueName);
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Make sure the day we're on even has this errand
///////////////////////////////////////////////////////////////////////////////
function bool CorrectDayForErrand(String UniqueName, String DayName, bool bCheckForCompletion)
{
	local int Day;
	local int Errand;

	for(Day = 0; Day < Days.Length; Day++)
	{
		if(Days[Day].UniqueName == DayName)
		{
			Errand = Days[Day].FindErrand(UniqueName);
			if (Errand >= 0)
			{
				// We've found it (the errand exists on this day) now either say yes now
				// or check if they also want completion
				if(bCheckForCompletion)
				{
					return (Days[Day].IsErrandComplete(Errand));
				}
				else
					return true;
			}
		}
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Activate the specified errand.
///////////////////////////////////////////////////////////////////////////////
function ActivateErrand(String UniqueName)
	{
	local int Day;
	local int Errand;
	local int i;

	if (!TheGameState.bIsApocalypse &&
		FindErrand(UniqueName, Day, Errand))
		{
		Days[Day].ActivateErrand(Errand);
		// Add activated errand to list
		i = TheGameState.ActivatedErrands.Length;
		TheGameState.ActivatedErrands.Insert(i, 1);
		TheGameState.ActivatedErrands[i].Day = Day;
		TheGameState.ActivatedErrands[i].Errand = Errand;
		}
	else
		Warn("P2GameInfoSingle.ActiveErrand(): ERROR: Couldn't find errand with UniqueName="$UniqueName);
	}
///////////////////////////////////////////////////////////////////////////////
// DEActivate the specified errand.
///////////////////////////////////////////////////////////////////////////////
function DeActivateErrand(String UniqueName)
	{
	local int Day;
	local int Errand;
	local int i;

	if (!TheGameState.bIsApocalypse &&
		FindErrand(UniqueName, Day, Errand))
		{
		Days[Day].DeActivateErrand(Errand);
		// Add activated errand to list
		i = TheGameState.DeActivatedErrands.Length;
		TheGameState.DeActivatedErrands.Insert(i, 1);
		TheGameState.DeActivatedErrands[i].Day = Day;
		TheGameState.DeActivatedErrands[i].Errand = Errand;
		}
	else
		Warn("P2GameInfoSingle.DeActiveErrand(): ERROR: Couldn't find errand with UniqueName="$UniqueName);
	}
///////////////////////////////////////////////////////////////////////////////
// Activate the specified errand.
///////////////////////////////////////////////////////////////////////////////
function ActivateLocationTex(String UniqueName)
	{
	local int Day;
	local int Errand;
	local int i;

	if (!TheGameState.bIsApocalypse &&
		FindErrand(UniqueName, Day, Errand))
		{
		Days[Day].ActivateLocationTex(Errand);
		// Add activated errand to list
		i = TheGameState.LocationTexActivatedErrands.Length;
		TheGameState.LocationTexActivatedErrands.Insert(i, 1);
		TheGameState.LocationTexActivatedErrands[i].Day = Day;
		TheGameState.LocationTexActivatedErrands[i].Errand = Errand;
		}
	else
		Warn("P2GameInfoSingle.ActiveErrand(): ERROR: Couldn't find errand with UniqueName="$UniqueName);
	}
///////////////////////////////////////////////////////////////////////////////
// DEActivate the specified errand.
///////////////////////////////////////////////////////////////////////////////
function DeActivateLocationTex(String UniqueName)
	{
	local int Day;
	local int Errand;
	local int i;

	if (!TheGameState.bIsApocalypse &&
		FindErrand(UniqueName, Day, Errand))
		{
		Days[Day].DeActivateLocationTex(Errand);
		// Add activated errand to list
		i = TheGameState.LocationTexDeActivatedErrands.Length;
		TheGameState.LocationTexDeActivatedErrands.Insert(i, 1);
		TheGameState.LocationTexDeActivatedErrands[i].Day = Day;
		TheGameState.LocationTexDeActivatedErrands[i].Errand = Errand;
		}
	else
		Warn("P2GameInfoSingle.DeActiveErrand(): ERROR: Couldn't find errand with UniqueName="$UniqueName);
	}

///////////////////////////////////////////////////////////////////////////////
// Check if the specified errand is active.
///////////////////////////////////////////////////////////////////////////////
function bool IsErrandActivate(String UniqueName)
	{
	local int Day;
	local int Errand;

	if (FindErrand(UniqueName, Day, Errand))
		{
		if (Days[Day].IsErrandActive(Errand))
			return true;
		}
	else
		Warn("P2GameInfoSingle.IsErrandCompleted(): Couldn't find errand with UniqueName="$UniqueName);
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Find errand using its unique name.  The function returns true if the errand
// was found, in which case the Day and Errand indices are valid.  Otherwise
// it returns false and those values should not be used.
///////////////////////////////////////////////////////////////////////////////
function bool FindErrand(String UniqueName, out int Day, out int Errand)
	{
	for(Day = 0; Day < Days.Length; Day++)
		{
		Errand = Days[Day].FindErrand(UniqueName);
		if (Errand >= 0)
			return true;
		}
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Get current day index
///////////////////////////////////////////////////////////////////////////////
function int GetCurrentDay()
	{
	return TheGameState.CurrentDay;
	}

///////////////////////////////////////////////////////////////////////////////
// Get current day
///////////////////////////////////////////////////////////////////////////////
function DayBase GetCurrentDayBase()
	{
	return Days[TheGameState.CurrentDay];
	}

///////////////////////////////////////////////////////////////////////////////
// Check whether the current day matches the specified name
///////////////////////////////////////////////////////////////////////////////
function bool IsDay(String UniqueName)
	{
	return GetCurrentDayBase().UniqueName ~= UniqueName;
	}

///////////////////////////////////////////////////////////////////////////////
// Make sure it's the final day and all of our errands are done.
// *Doesn't* check to make sure it's not the demo.
///////////////////////////////////////////////////////////////////////////////
function bool AfterFinalErrand()
{
	// Last day of the real game and you're done with your errands
	return ((TheGameState.CurrentDay == Days.Length - 1)
			&& TheGameState.ErrandsCompletedToday >= Days[TheGameState.CurrentDay].NumActiveErrands());
}

///////////////////////////////////////////////////////////////////////////////
// Check to make sure at least every errand has one goal
// Only to be called in an init.
///////////////////////////////////////////////////////////////////////////////
function CheckForValidErrandGoals()
	{
	local int i;

	for(i = 0; i < Days.Length; i++)
		{
		if(Days[i] != None)
			Days[i].CheckForValidErrandGoals();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Save errand in the GameState so it will persist
///////////////////////////////////////////////////////////////////////////////
function SaveCompletedErrand(int Day, int Errand)
	{
	local int i;

	// Add completed errand to list
	i = TheGameState.CompletedErrands.Length;
	TheGameState.CompletedErrands.Insert(i, 1);
	TheGameState.CompletedErrands[i].Day = Day;
	TheGameState.CompletedErrands[i].Errand = Errand;
	}

///////////////////////////////////////////////////////////////////////////////
// Restore day and its errands using the info stored in the GameState.
//
// DayBase and ErrandBase are Objects (not Actors) so they are not destroyed
// or affected in any way by traveling between levels or by loading saved
// games.  This leads to situations where the information in those objects
// does not match the information in the GameState.  For instance, you save
// just before you complete an errand.  Then you complete the errand, so it's
// marked "complete" in the ErrandBase and it's also recorded in the GmeState.
// Now you load the game you saved just before completing the errand.  The
// GameState will say the errand is NOT complete (which is correct) while the
// ErrandBase will still say the errand is complete (which is incorrect).  A
// similar situation can occur when traveling between levels.
//
// Calling this function updates the current DayBase and all of it's
// ErrandBase objects to match the information in the GameState.
///////////////////////////////////////////////////////////////////////////////
function RestoreDayAndErrands()
	{
	local int i;

	// Reset day (day objects are not destroyed by traveling)
	Days[TheGameState.CurrentDay].PostTravelReset();

	// Reset errands (errand objects are not destroyed by traveling)
	for (i = 0; i < Days[TheGameState.CurrentDay].Errands.Length; i++)
		Days[TheGameState.CurrentDay].Errands[i].PostTravelReset();

	// Complete each errand in the completed list and update the count to ensure it's correct
	TheGameState.ErrandsCompletedToday = 0;
	for (i = 0; i < TheGameState.CompletedErrands.Length; i++)
		{
		Days[TheGameState.CompletedErrands[i].Day].Errands[TheGameState.CompletedErrands[i].Errand].PostTravelSetComplete();
		if (TheGameState.CompletedErrands[i].Day == TheGameState.CurrentDay)
			TheGameState.ErrandsCompletedToday++;
		}

	// Activate each errand in the activated list.
	for (i = 0; i < TheGameState.ActivatedErrands.Length; i++)
		Days[TheGameState.ActivatedErrands[i].Day].ActivateErrand(TheGameState.ActivatedErrands[i].Errand);
	for (i = 0; i < TheGameState.DeActivatedErrands.Length; i++)
		Days[TheGameState.DeActivatedErrands[i].Day].DeActivateErrand(TheGameState.DeActivatedErrands[i].Errand);
	}


//=================================================================================================
//=================================================================================================
//=================================================================================================
//
// Apocolypse stuff
//
//=================================================================================================
//=================================================================================================


///////////////////////////////////////////////////////////////////////////////
// Begin end sequence for single player game.
// * Set Gamestate to know Apocalypse is soooooo on!
// * Grant dude new Apocalypse newspaper and make him view it (to understand
// what's happening.
// * Go through level and make everyone guncrazy, give them a weapon and start
// the fun!
///////////////////////////////////////////////////////////////////////////////
function StartApocalypse()
{
	local Inventory thisinv;
	local P2PowerupInv pinv;
	local byte CreatedNow;
	local P2Player p2p;

	if(!TheGameState.bIsApocalypse
		&& !Level.IsDemoBuild() // Never do this for the demo version
		&& AfterFinalErrand())
	{
		p2p = GetPlayer();
		// Set it
		TheGameState.bIsApocalypse = true;
		// Give him a newspaper in case he doesn't have one
		thisinv = p2p.MyPawn.CreateInventory("Inventory.NewspaperInv", CreatedNow);
		if(CreatedNow == 0)
			// Request that it comes up if we already had a newspaper (so we always see it)
			// otherwise, just giving it to him will make it come up
			p2p.RequestNews();
		// Set everyone into riot mode
		ConvertAllPawnsToRiotMode();
		// Change the sky to scary fire clouds
		ChangeSkyByDay();
		// Put into run mode for the apocalypse
		GotoState('RunningApocalypse');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Goes through the level and changes all NPCs to riot mode (done by controllers)
///////////////////////////////////////////////////////////////////////////////
function ConvertAllPawnsToRiotMode()
{
	local P2Pawn ppawn;
	local PersonController pcont;

	//log(self$" ConvertAllPawnsToRiotMode	00000000000000000000000000");
	// Find everyone in the level and zap them
	foreach DynamicActors(class'P2Pawn', ppawn)
	{
		pcont = PersonController(ppawn.Controller);
		if(pcont != None)
		{
			pcont.ConvertToRiotMode();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get the appropriate texture for the newspaper to fly to the screen for the
// appropriate day. Except for the apocalypse paper which takes a special
// one regardless of the day.
///////////////////////////////////////////////////////////////////////////////
function Texture GetNewsTexture()
{
	if(TheGameState.bIsApocalypse)
	{
		return Texture(DynamicLoadObject(String(ApocalypseTex), class'Texture'));
	}
	else
	{
		// Kamek 5-1
		// Tell the GameState that we read the news today
		// Apocalypse news is always shown, so don't count it toward the total.
		TheGameState.ReadNewsToday();

		return GetCurrentDayBase().GetNewsTexture();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get the dude comment on this day's newspaper or the Apocalypse. Like above
// the texture.
///////////////////////////////////////////////////////////////////////////////
function Sound GetDudeNewsComment()
{
	if(TheGameState.bIsApocalypse)
	{
		return Sound(DynamicLoadObject(String(ApocalypseComment), class'Sound'));
	}
	else
		return GetCurrentDayBase().GetDudeNewsComment();
}


//=================================================================================================
//=================================================================================================
//=================================================================================================
//
// Cheats
//
//=================================================================================================
//=================================================================================================
//=================================================================================================

// Kamek 11/26/13 - set these to require debug mode

///////////////////////////////////////////////////////////////////////////////
// For testing, reset cops so you aren't wanted any more
///////////////////////////////////////////////////////////////////////////////
exec function ResetCops()
	{
	if (!GetPlayer().DebugEnabled())
		return;

	Log("CHEAT: ResetCops()");

	// Reset the cop radio so you aren't wanted any more
	TheGameState.ResetCopRadioTime();
	}

///////////////////////////////////////////////////////////////////////////////
// Change player to opposite of his current morality
///////////////////////////////////////////////////////////////////////////////
exec function ChangeDude()
	{
	if (!GetPlayer().DebugEnabled())
		return;

		TheGameState.bNiceDude = !TheGameState.bNiceDude;

	Log("CHEAT: ChangeDude(): bNiceDude is now "$TheGameState.bNiceDude);

	// Send player to the same level he's already on, but when he gets there
	// he will be opposite to the morality he started with.
	SendPlayerTo(GetPlayer(), ParseLevelName(Level.GetLocalURL()));
	}

///////////////////////////////////////////////////////////////////////////////
// For testing, go to the specified map.  This should ALWAYS be used instead
// of unreal's built-in "open" command.
///////////////////////////////////////////////////////////////////////////////
exec function Goto(String LevelName)
	{
	if (!GetPlayer().DebugEnabled())
		return;

		Log("CHEAT: Goto() LevelName="$LevelName);

	SendPlayerTo(GetPlayer(), LevelName);
	}

///////////////////////////////////////////////////////////////////////////////
// For testing, set the day you want to test and the current level will be
// "reloaded" for that day.
///////////////////////////////////////////////////////////////////////////////
exec function WarpToDay(int day)
	{
	if (!GetPlayer().DebugEnabled())
		return;

	Log("CHEAT: WarpToDay() day="$day);

	TheGameState.NextDay = day - 1;
	TheGameState.NextDay = Min(TheGameState.NextDay, Days.Length - 1);
	TheGameState.NextDay = Max(TheGameState.NextDay, 0);
	TheGameState.bChangeDayPostTravel = true;
	TheGameState.bChangeDayForDebug = true;

	// Send player to the same level he's already on, but when he gets there
	// it will be the specified day.
	SendPlayerTo(GetPlayer(), ParseLevelName(Level.GetLocalURL()));
	}

///////////////////////////////////////////////////////////////////////////////
// For testing different days via the command line or editor (?SetDay=X)
// TheGameState.NextDay is the day we need to go to.
///////////////////////////////////////////////////////////////////////////////
function SetDayAtLaunch()
{
	local P2Player p2p;
	local int startday, i;
	local Inventory inv, oldinv;

	p2p = GetPlayer();
	
	// Go through your inventory, and give all things needed for each
	// day, then remove all things to be removed for that day. Do this between
	// the day you're on and the day you've picked.

	// You've already been given everything for this day, so just remove things for this day
	Days[TheGameState.CurrentDay].TakeInventoryFromPlayer(p2p.MyPawn);
	for(i=0; i < TheGameState.NextDay; i++)
	{
		log(self$" intermediate day "$i);
		// Give him all things for that day
		Days[i].AddInStartingInventory(p2p.MyPawn);
		// Take away all necessary things
		Days[i].TakeInventoryFromPlayer(p2p.MyPawn);
		// Set those errands complete
		SetThisDaysErrandsComplete(i);
	}	
}
///////////////////////////////////////////////////////////////////////////////
// For testing, set the day you want to warp to. All errands before that day
// will be completed, along with anything you're supposed to retain
///////////////////////////////////////////////////////////////////////////////
exec function SetDay(int day, optional string URL)
	{
	local P2Player p2p;
	local int startday, i;
	local Inventory inv, oldinv;

	if (!GetPlayer().DebugEnabled())
		return;

	Log("CHEAT: SetDay() day="$day@"URL="$url);

	p2p = GetPlayer();

	TheGameState.NextDay = day - 1;
	TheGameState.NextDay = Min(TheGameState.NextDay, Days.Length - 1);
	TheGameState.NextDay = Max(TheGameState.NextDay, 0);
	TheGameState.bChangeDayPostTravel = true;
	TheGameState.bChangeDayForDebug = true;

	log(self$" Current day "$TheGameState.CurrentDay$" new day "$day - 1);
	// If you're going back in time, then remove all your inventory and start from
	// monday forward to your new day.
	if(TheGameState.CurrentDay > day - 1)
	{
		log(self$" going back ");
		inv = p2p.MyPawn.Inventory;
		while(inv != None)
		{
			oldinv = inv.Inventory;
			p2p.MyPawn.DeleteInventory(inv);
			inv = inv.Inventory;
		}
		p2p.MyPawn.Inventory = None;
		startday = -1;	// This is -1 instead of 0, so the code below will first
		// remove the items the for current day, then take us back to Monday(0). To
		// handle this case and the normal case of going forward through time, the
		// loop before needs to be one past the start day.

		// Also, reset all the errands that have been completed.
		SetAllErrandsUnComplete();
	}
	else if(TheGameState.CurrentDay < day - 1)
	{
		log(self$" going forward ");
		startday = TheGameState.CurrentDay;
		// Set this day's errands complete
		SetTodaysErrandsComplete();
	}
	else// Resetting the same day
	{
		log(self$" same day ");
		startday = TheGameState.CurrentDay;
		// Also, reset all the errands that have been completed.
		SetAllErrandsUnComplete();
	}

	// Go through your inventory, and give all things needed for each
	// day, then remove all things to be removed for that day. Do this between
	// the day you're on and the day you've picked.

	// You've already been given everything for this day, so just remove things for this day
	Days[TheGameState.CurrentDay].TakeInventoryFromPlayer(p2p.MyPawn);
	for(i=startday+1; i < day - 1; i++)
	{
		log(self$" intermediate day "$i);
		// Give him all things for that day
		Days[i].AddInStartingInventory(p2p.MyPawn);
		// Take away all necessary things
		Days[i].TakeInventoryFromPlayer(p2p.MyPawn);
		// Set those errands complete
		SetThisDaysErrandsComplete(i);
	}

	// Send player to the same level he's already on, but when he gets there
	// it will be the specified day.
	if (URL=="")
		SendPlayerTo(p2p, ParseLevelName(Level.GetLocalURL()));
	else
		SendPlayerTo(p2p, URL);
	}

///////////////////////////////////////////////////////////////////////////////
// For testing, set all errands as complete
// Turns on hate-player-groups too--Apocalypse!
///////////////////////////////////////////////////////////////////////////////
exec function SetAllErrandsComplete()
	{
	local int i,j;

	if (!GetPlayer().DebugEnabled())
		return;

	Log("CHEAT: SetAllErrandsComplete()");

	for (i = 0; i < Days.Length; i++)
		SetThisDaysErrandsComplete(i);
	}

///////////////////////////////////////////////////////////////////////////////
// For testing, reset all the errands and make hate groups not hate you anymore
//
// Warning!!
// May not work for 'write-in' errands!
//
///////////////////////////////////////////////////////////////////////////////
exec function SetAllErrandsUnComplete()
	{
	local int i,j;

	if (!GetPlayer().DebugEnabled())
		return;

	Log("CHEAT: SetAllErrandsUnComplete()");

	for (i = 0; i < Days.Length; i++)
		for (j = 0; j < Days[i].Errands.Length; j++)
			Days[i].Errands[j].ForceUnCompletion(TheGameState);

	// Remove all items from list
	TheGameState.CompletedErrands.Remove(0, TheGameState.CompletedErrands.Length);
	}

///////////////////////////////////////////////////////////////////////////////
// For testing, set all of today's errands as complete
// Turns on hate-player-groups too
///////////////////////////////////////////////////////////////////////////////
exec function SetTodaysErrandsComplete()
	{
	if (!GetPlayer().DebugEnabled())
		return;

	Log("CHEAT: SetTodaysErrandsComplete() TheGameState.CurrentDay="$TheGameState.CurrentDay);

	SetThisDaysErrandsComplete(TheGameState.CurrentDay);
	}

///////////////////////////////////////////////////////////////////////////////
// For testing, set all of the specified day's errands as complete
// Turns on hate-player-groups too
///////////////////////////////////////////////////////////////////////////////
function SetThisDaysErrandsComplete(int DayI)
	{
	local int j;

	if (!GetPlayer().DebugEnabled())
		return;

	for (j = 0; j < Days[DayI].Errands.Length; j++)
		SetThisErrandComplete(Days[DayI].Errands[j].UniqueName);
	}

///////////////////////////////////////////////////////////////////////////////
// For testing, set this unique errand complete
// Turns on hate-player-groups too
///////////////////////////////////////////////////////////////////////////////
exec function SetThisErrandComplete(String UniqueName)
	{
	local int DayI, ErrandI;

	// xPatch: Check if we are starting the game via the day select option
	// and allow this function without the need of debug menu enabled.
	if(TheGameState.bStartDayPostTravel)
	{
		Log("SetThisErrandComplete() UniqueName="$UniqueName);
	}
	else // Otherwise do the usual debug check
	{
		if (!GetPlayer().DebugEnabled())
			return;

		Log("CHEAT: SetThisErrandComplete() UniqueName="$UniqueName);
	}
	
	FindErrand(UniqueName, DayI, ErrandI);
	if(DayI >= 0 && ErrandI >= 0)
		{
		if (!Days[DayI].IsErrandComplete(ErrandI))
			{
			Days[DayI].Errands[ErrandI].ForceCompletion(TheGameState, GetPlayer());
			SaveCompletedErrand(DayI, ErrandI);
			if (DayI == TheGameState.CurrentDay)
				TheGameState.ErrandsCompletedToday++;
			}
		else
			Log("SetThisErrandComplete(): errand already complete -- ignored");
		}
	else
		Log("SetThisErrandComplete(): errand not found -- ignored");
	}

///////////////////////////////////////////////////////////////////////////////
// Reach into gamestate to do this.
// Reset any hints for inventory/weapons, so that they will show up again
///////////////////////////////////////////////////////////////////////////////
function ClearInventoryHints()
{
	if(TheGameState != None)
		TheGameState.ClearInventoryHints();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PreloadSpawnerSkinAndMesh(Actor CheckA)
{
	local int i;
	if(CheckA != None)
	{
		if(CheckA.Skins.Length > 0
			&& CheckA.Skins[0] != None)
		{
			i = SpawnerMaterials.Length;
			SpawnerMaterials.Insert(i, 1);
			SpawnerMaterials[i] = CheckA.Skins[0];
			//log(self$" preloaded tex "$SpawnerMaterials[i]);
		}
		if(CheckA.Mesh != None)
		{
			i = SpawnerMeshes.Length;
			SpawnerMeshes.Insert(i, 1);
			SpawnerMeshes[i] = CheckA.Mesh;
			//log(self$" preloaded mesh "$SpawnerMeshes[i]);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Possibly preload the models/textures to prevent a framehitch when the spawner
// spawns for the first time in a level.
///////////////////////////////////////////////////////////////////////////////
function PreloadSpawnerAssets(Spawner CheckS)
{
	local P2MocapPawn p2m;

	if(PawnSpawner(CheckS) != None)
	{
		//log(self$" class "$CheckS.SpawnClass);
		if(ClassIsChildOf(CheckS.SpawnClass, class'P2MocapPawn'))
		{
			// Force it to spawn now, so we can have it get all the proper skins/meshes for us
			p2m = P2MocapPawn(spawn(CheckS.SpawnClass,,,CheckS.Location,,CheckS.SpawnSkin));

			//log(self$" spawned "$p2m$" skin "$p2m.Skins[0]$" mesh "$p2m.Mesh);

			if(p2m != None)
			{
				// Save the body skin and mesh
				PreloadSpawnerSkinAndMesh(p2m);
				//log(self$" head "$p2m.MyHead);
				// Save the head skin, mesh
				PreloadSpawnerSkinAndMesh(p2m.MyHead);
				// Get rid of the temp pawn
				p2m.Destroy();
				p2m = None;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Go through all the actors in the level and decide if they belong in the
// level or not.
// If they have no day specified in their group, it means they want to
// be used in all the days. This is true for most actors in a level.
//
// Make sure the objects to be removed here are marked bNoDelete==false
// Also, no static objects will be allowed to take advantage of this. They will
// automatically remain in every day.
//
// DayBlockers and single paths from pathnodes should be used to make
// dynamically changing paths.
//
// Handle also, anything particular to the type of dude the player picked.
// Handle difficulty based items placed only for certain difficulties (more
// weapons on lower diffs, more enemies on higher, etc.)
//
// Connect all the pawns in the level to each other, so that each pawn will wake
// a different one up when they die. (Wake them up from stasis)
//
///////////////////////////////////////////////////////////////////////////////
function PrepActorsByGroup()
{
	local Actor CheckA;
	local FPSPawn LastPawn, FirstPawn;
	local byte Needed, NeededForDude, NeededForDay, NeededForDifficulty, NeededForDetail, NeedForHoliday, SpecifiedDay, NeedForClassicGame;
	local bool bEnhanced;

	bEnhanced=VerifySeqTime();

	// Go through all the actors and check what days they need to be in
	foreach AllActors(class'Actor', CheckA)
	{
		// Modify any static meshes as necessary
		CheckStaticMesh(StaticMeshActor(CheckA));

		// Check if we want it for this day
		NeededForThisDay(CheckA, NeededForDay, SpecifiedDay);

		// Check if we want it for a holiday
		NeededForHoliday(CheckA, NeedForHoliday);
		
		// xPatch: Check for Classic Game
		NeededForClassicGame(CheckA, NeedForClassicGame);

		// Dude check
		NeededForThisStringBool(CheckA, TheGameState.bNiceDude, GOOD_GUY_GROUP, BAD_GUY_GROUP, NeededForDude);

		// Difficulty check
		NeededForThisStringBool(CheckA, InEasyMode(), EASY_GROUP, HARD_GROUP, NeededForDifficulty);

		// Check if we want it for this detail setting.
		NeededForThisDetail(CheckA, NeededForDetail);

		// Allow this thing only if we're playing the right dude on the right day.
		Needed = NeededForDay & NeededForDude & NeededForDifficulty & NeededForDetail & NeedForHoliday & NeedForClassicGame;
		
		if(Needed == 0)
		{
			// Don't let the player start be deleted. It's the only thing that should have all the days in it
			// if it has monday-friday, plus demo, it will want to be deleted. But we check here to make specifically
			// sure it's not
			//log(self$" not needed "$CheckA);
			if(PlayerStart(CheckA) == None)
			{
				//log(CheckA$" not needed for day "$TheGameState.CurrentDay$" check group "$CheckA.Group$" static for me "$CheckA.bStatic$" bnodelete "$CheckA.bNoDelete);

				if(Telepad(CheckA) != None)
				{
					CheckA.SetCollision(false, false, false);
				}
				else if(PathNode(CheckA) != None)
				{
					// if it was a path node, don't delete these, just block them
					PathNode(CheckA).bBlocked=true;
					//log(CheckA$" set to block as "$PathNode(CheckA).bBlocked);
				}
				// Delete weapons per day in normal mode
				else if(P2WeaponPickup(CheckA) != None)
				{
					if(!bEnhanced)
						// Now delete the actual actor
						CheckA.Destroy();
				}
				// Don't destroy day blockers that aren't mean to be destroyed
				else if (DayBlocker(CheckA) != none) {
				    if (!DayBlocker(CheckA).bDestroyOnDayNeeded)
				        CheckA.Destroy();
                    else {
                        CheckA.bBlockNonZeroExtentTraces = true;
				        CheckA.bBlockZeroExtentTraces = true;
				    }
				}
				// Delete all other objects
				else
				{
					// if it's actually a pawn, check to destroy it's controller first
					if(Pawn(CheckA) != None)
					{
						//log(CheckA$" destroyed my controller too "$Pawn(CheckA).Controller);
						if(Pawn(CheckA).Controller != None)
							Pawn(CheckA).Controller.Destroy();
					}

					// Now delete the actual actor
					CheckA.Destroy();
				}
			}
			else
			{
				PlayerStart(CheckA).SetCollision(false, false, false);
			}
		}
		else// We're going to keep these objects (they are Needed for this day)
		{
			// Make sure paths aren't blocked when used
			if(PathNode(CheckA) != None)
			{
				PathNode(CheckA).bBlocked=false;
			}
			// Enforce collision on dayblockers. They are used specifically for keeping
			// people from going past things.
			else if(DayBlocker(CheckA) != None)
			{
				if (DayBlocker(CheckA).bDestroyOnDayNeeded)
				    CheckA.Destroy();
                else {
                    CheckA.bBlockNonZeroExtentTraces = true;
				    CheckA.bBlockZeroExtentTraces = true;
				}
			}
			else if(FPSPawn(CheckA) != None)
			{
				// If we're keeping this pawn, get him ready for this difficulty
				FPSPawn(CheckA).SetForDifficulty(GameDifficulty);

				if(!FPSPawn(CheckA).bPlayer)
				{
					if(FirstPawn == None)
						FirstPawn = FPSPawn(CheckA);

					FPSPawn(CheckA).StasisPartner = LastPawn;
					LastPawn = FPSPawn(CheckA);
				}
			}
			// If we're a spawner, check to preload our assets to fix the framehitch
			else if(Spawner(CheckA) != None)
			{
				PreloadSpawnerAssets(Spawner(CheckA));
			}
		}
		
		// xPatch: Delete pickups in Classic Game (ignores Needed thing)
		if(P2WeaponPickup(CheckA) != None || P2AmmoPickup(CheckA) != None)
		{
			if(!AllowedInClassicGame(CheckA))
				CheckA.Destroy();
		}
	}

	// Link the stasis pawns
	if(FirstPawn != None)
	{
		FirstPawn.StasisPartner = LastPawn;
	}
}

///////////////////////////////////////////////////////////////////////////////
// For the pawns on this day, in this level, for any with bUsePawnSlider set to
// true if the total number of them active is above the goal, it puts them in
// SliderStasis. It does this for as long as their are more pawns that are active
// than the goal says. It tries to randomly find them, and may go through the
// entire list of pawns more than once. It does this to get a better distribution
// of pawns to have active in a level. Simply going through the pawns in the level
// and allowing the first X pawns to be active would result in very lopsided distribution.
///////////////////////////////////////////////////////////////////////////////
function PrepSliderPawns()
{
	local FPSPawn fpawn;
	local int loopcount, userand, userange, rangehalf, hitcount;

	//log(self$" PrepSliderPawns pawns active "$PawnsActive$" slider pawns to start with "$SliderPawnsActive);
	//log(self$" This has the '1000000 iteration' bug fix vr 2.0");

	userange = SliderPawnsActive - SliderPawnGoal;
	rangehalf = userange/2;
	while(SliderPawnsActive > SliderPawnGoal)
	{
		//log(self$" PrepSliderPawns--loop count "$loopcount);
		foreach DynamicActors(class'FPSPawn', fpawn)
		{
			if(SliderPawnsActive > SliderPawnGoal)
			{
				userand = Rand(userange);
				//log(self$" userand is "$userand$" range "$userange$" half "$rangehalf);
				if(fpawn.bUsePawnSlider
					&& !fpawn.bPersistent
					&& !fpawn.bSliderStasis
					&& LambController(fpawn.Controller) != None
					&& userand >= rangehalf)
				{
					//log(self$" turning off "$fpawn);
					LambController(fpawn.Controller).GoIntoSliderStasis();
					userange = SliderPawnsActive - SliderPawnGoal;
					rangehalf = userange/2;
				}
				//else
				//{
				//	log(self$" leaving "$fpawn$" at "$fpawn.Location$" SliderPawnsActive "$SliderPawnsActive);
				//}
				hitcount++;
				//log(self$" Hit Count: "$hitcount);
			}
			else
				break;	// get out of loop now

			if(hitcount > 5000)
			{
				//log(self$" HIT COUNT BREAKING.... INFINITE LOOP STOPPED");
				return; // quick break for testing.
			}
		}
		loopcount++;
	}
	//log(self$" PrepSliderPawns DONE!");
}

///////////////////////////////////////////////////////////////////////////////
// Check to remove this pickup from the GottenPickups list.
///////////////////////////////////////////////////////////////////////////////
function FindInPickupList(Pickup DelMe, String Lname)
{
	local int i;
	local int loopcount;

	for(i=0; i<TheGameState.GottenPickups.Length; i++)
	{
		// xPatch: Runaway loop Crash Fix
		// Not sure what exactly causes it to go over 1000000 iterations - Don't have a save with that issue to properly debug it.
		// I'll just add a check that will reset the list and that will have to do for now.
		if (loopcount > 5000)	
		{
			Warn(self$"FindInPickupList(): HIT COUNT BREAKING.... INFINITE LOOP STOPPED");
			TheGameState.GottenPickups.Length = 0;	
			return;
		}
		loopcount++;
		
		//log(self$" RemoveGottenPickups, GottenPickups "$TheGameState.GottenPickups[i].PickupName);
		//log(self$" for level "$TheGameState.GottenPickups[i].LevelName$" checking... "$TheGameState.GottenPickups[i].PickupName$" against "$DelMe.name);
		if(TheGameState.GottenPickups[i].PickupName == DelMe.name
			&& TheGameState.GottenPickups[i].LevelName ~= Lname)
		{
			//log(self$"												Removing "$DelMe);
			DelMe.Destroy();
			DelMe = None;
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//
// Go through all the pickups in the level, and remove any that have been
// previously taken by the dude.
//
///////////////////////////////////////////////////////////////////////////////
function RemoveGottenPickups()
{
	local Pickup CheckP, DelMe;
	local String Lname;

	Lname = ParseLevelName(Level.GetLocalURL());

	//log(self$" RemoveGottenPickups, gottenpickups length "$TheGameState.GottenPickups.Length);

	foreach AllActors(class'Pickup', CheckP)
	{
		DelMe = CheckP;
		//log(self$" RemoveGottenPickups "$DelMe);
		// If you're not allowed to be recorded, you're not allowed to be restored
		if((P2WeaponPickup(DelMe) != None
				&& P2WeaponPickup(DelMe).bRecordAfterPickup)
			|| (P2PowerupPickup(DelMe) != None
					&& P2PowerupPickup(DelMe).bRecordAfterPickup)
			|| (P2AmmoPickup(DelMe) != None
					&& P2AmmoPickup(DelMe).bRecordAfterPickup))
		{
			FindInPickupList(DelMe, Lname);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Holiday Overrides
// Player can override holiday date lockouts after beating POSTAL mode
///////////////////////////////////////////////////////////////////////////////
function bool IsHolidayOverridden(name HolidayName)
{
	local int i;

	for (i=0; i < HolidayOverrides.Length; i++)
		if (HolidayOverrides[i] == HolidayName)
			return true;

	return false;
}
function AddHolidayOverride(name HolidayName)
{
	if (IsHolidayOverridden(HolidayName))
		return;	// Already present, don't add it again.

	HolidayOverrides[HolidayOverrides.Length] = HolidayName;	// append to end
	SaveConfig();
}
function DelHolidayOverride(name HolidayName)
{
	local int i;

	while (IsHolidayOverridden(HolidayName))
	{
		for (i=0; i < HolidayOverrides.Length; i++)
			if (HolidayOverrides[i] == HolidayName)
			{
				HolidayOverrides.Remove(i,1);
				break;
			}
	}
	SaveConfig();
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if the current date falls within the specified holiday's range.
///////////////////////////////////////////////////////////////////////////////
function bool IsHoliday(name HolidayName)
{
	local bool bIs;
	local int i, j, YearMin, YearMax, MonthMin, MonthMax, DayMin, DayMax;
	
	// Override: no holidays mode
	if (bNoHolidays)
		return false;

	// Override: always return true
	if (IsHolidayOverridden(HolidayName))
		return true;

	for (i=0; i < Holidays.Length; i++)
	{
		if (Holidays[i].HolidayName == HolidayName
			|| HolidayName == 'ANY_HOLIDAY')
		{
			// Check each date range and see if the current date falls within any of them.
			for (j=0; j < Holidays[i].Dates.Length; j++)
			{
				// gotta do this for day, month, and year, both min and max...
				if (Holidays[i].Dates[j].Year.Min != 0)
					YearMin = Holidays[i].Dates[j].Year.Min;
				else
					YearMin = Level.Year;
				if (Holidays[i].Dates[j].Month.Min != 0)
					MonthMin = Holidays[i].Dates[j].Month.Min;
				else
					MonthMin = Level.Month;
				if (Holidays[i].Dates[j].Day.Min != 0)
					DayMin = Holidays[i].Dates[j].Day.Min;
				else
					DayMin = Level.Day;
				if (Holidays[i].Dates[j].Year.Max != 0)
					YearMax = Holidays[i].Dates[j].Year.Max;
				else
					YearMax = Level.Year;
				if (Holidays[i].Dates[j].Month.Max != 0)
					MonthMax = Holidays[i].Dates[j].Month.Max;
				else
					MonthMax = Level.Month;
				if (Holidays[i].Dates[j].Day.Max != 0)
					DayMax = Holidays[i].Dates[j].Day.Max;
				else
					DayMax = Level.Day;

				// NOW do the comparison
				// Should return true if the date is >= DayMin/MonthMin/YearMin and <= DayMax/MonthMax/YearMax
				//log("For"@HolidayName$": compare"@Level.Day$"/"$Level.Month$"/"$Level.Year@"vs."@DayMin$"/"$MonthMin$"/"$YearMin$"-"$DayMax$"/"$MonthMax$"/"$YearMax,'HolidayDebug');
				if (Level.Day >= DayMin
					&& Level.Month >= MonthMin
					&& Level.Year >= YearMin
					&& Level.Day <= DayMax
					&& Level.Month <= MonthMax
					&& Level.Year <= YearMax
					)
				{
					return true;
				}
			}
			// If we get here, it means we've found the holiday in question, but all the date checks have failed.
			// Stop processing further holidays now to save time.
			if (HolidayName != 'ANY_HOLIDAY')
				return false;
		}
	}
	// If we get here, an invalid or non-existent holiday was input. Return false.
	return false;
}

///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////
function NeededForHoliday(Actor CheckA, out byte Needed)
{
	local int i;
	local string GroupString;
	local bool bFound;

	// Returns a 1 if the actor is needed for a specific holiday, or if no holidays are included.

	GroupString = Caps(CheckA.Group);

	Needed=1;
	for (i=0; i < Holidays.Length; i++)
	{
		if (InStr(GroupString, Caps(Holidays[i].HolidayName)) >= 0)
		{
			// Check against the date.
			if (!IsHoliday(Holidays[i].HolidayName))
			{
				// Failed date check. Delete.
				Needed=0;
				return;
			}
		}
	}
	// Either passed all date checks or wasn't for a holiday -- keep
}

function NeededForThisDay(Actor CheckA, out byte Needed, out byte SpecifiedDay)
	{
	local int i, dayI;
	local string GroupString;
	local bool bExcluded;

	Needed=0;
	SpecifiedDay=0;
	GroupString = Caps(CheckA.Group);

	// If your name in your group list was specifically mentioned in the following
	// then it will not be needed for this day
	if(Days.Length > 0)
	{
		dayI=0;
		while(dayI < Days[TheGameState.CurrentDay].ExcludeDays.Length)
		{
			i = InStr(GroupString, Days[TheGameState.CurrentDay].ExcludeDays[dayI]);
			if(i >= 0)
			{
				bExcluded=true;	// Record that it was excluded
			}
			dayI++;
		}
	}

	// Now go through and check to see if this object is needed
	// for this day, or has a specified day
	dayI=0;
	while(dayI < Days.Length)
	{
		i = InStr(GroupString, Days[dayI].UniqueName);

		if(i >= 0)
		{
			SpecifiedDay = 1;
			if(TheGameState.CurrentDay == dayI)
			{
				Needed = 1;
			}
		}
		dayI++;
	}

	// If they didn't specify a day, and you we're specifically excluded
	// then it means they're wanted for all days.
	if(SpecifiedDay == 0
		&& !bExcluded)
		Needed=1;

	//log(CheckA$" needed "$Needed$" SpecifiedDay "$SpecifiedDay$" dayI "$dayI$" GroupString "$GroupString);

	/*
	// Old method:
// This checks the group variable for string listings of the various days
// this object is in. If no days are listed, it's assumed to be needed
// for all days.
// Days are listed in the following format:
// DAY_$
// where $ is a letter. So DAY_A means the first day. DAY_C means the third day.
// The days can go from A to Z, and currently no further. So the max days is 26
// from the letters in the alphabet. Sorry, if you want a month in the dude's life
// you gotta code it yourself.
	GroupString = Caps(CheckA.Group);
	tlen = Len(GroupString);

	Needed=1;	// default it to needed
	SpecifiedDay=0;

	//	log(CheckA$" check my groups");
	while(i >= 0)
		{
		//		log(CheckA$"using this string "$GroupString);
		i = InStr(GroupString, DAY_STR);
		if(i < 0)	// no days were in this string
			{
			//			log(CheckA$" stopping check "$i);
			}
		else	// at some point, a day was specified
			{
			// Now that a day was specified, say it's not needed,
			// until the specific day is found
			SpecifiedDay=1;
			Needed=0;

			//log(CheckA$" asc: "$Asc(Mid(GroupString, i+DAY_STR_LEN, 1)));
			//log(CheckA$" number for day "$Asc(Mid(GroupString, i+DAY_STR_LEN, 1)) - DAY_START_ASCII);

			// This day is specified, so say this is needed and quit
			if(CurrentDay == Asc(Mid(GroupString, i+DAY_STR_LEN, 1)) - DAY_START_ASCII)
				{
				Needed=1;
				i=-1;	// quit
				}
			else
				GroupString = Mid(GroupString, i+DAY_STR_LEN, tlen);
			}
		}
		*/
	}

///////////////////////////////////////////////////////////////////////////////
// Checks if the dude playing is opposite the one specified in the object.
// If so, it sets Needed to 0. Otherwise, it sets it to 1.
///////////////////////////////////////////////////////////////////////////////
function NeededForThisDude(Actor CheckA, bool bNiceDude, out byte Needed)
{
	local int i;
	local string GroupString;

	GroupString = Caps(CheckA.Group);

	//log(CheckA$"using this string "$GroupString);
	i = InStr(GroupString, GOOD_GUY_GROUP);
	// Nice dude listed in group, but we're playing the bad dude, so don't use it.
	if(i >= 0
		&& !bNiceDude)
	{
		//log(self$" good guy place "$i);
		Needed=0;
		return;
	}
	// Evil dude listed in group, but we're playing the nice dude, so don't use it.
	i = InStr(GroupString, BAD_GUY_GROUP);
	if(i >= 0
		&& bNiceDude)
	{
		//log(self$" bad guy place "$i);
		Needed=0;
		return;
	}
	// everything else is needed
	Needed=1;
}

///////////////////////////////////////////////////////////////////////////////
// Check if this actor is need for either of these group, StrTrue or StrFalse.
///////////////////////////////////////////////////////////////////////////////
function NeededForThisStringBool(Actor CheckA, bool bCheck,
								 string StrTrue, string StrFalse, out byte Needed)
{
	local int i;
	local string GroupString;

	GroupString = Caps(CheckA.Group);

	i = InStr(GroupString, StrTrue);
	// Needed for true set, and we're set to false, so don't accept
	if(i >= 0
		&& !bCheck)
	{
		Needed=0;
		return;
	}

	i = InStr(GroupString, StrFalse);
	// Needed for true, but we're checking false, so don't accept.
	if(i >= 0
		&& bCheck)
	{
		Needed=0;
		return;
	}
	// everything else is needed
	Needed=1;
}

///////////////////////////////////////////////////////////////////////////////
// Check the detail level of things, if it's high, then remove certain items
///////////////////////////////////////////////////////////////////////////////
function NeededForThisDetail(Actor CheckA, out byte Needed)
{
	local int i;
	local string GroupString;

	// If this thing is for high detail only, and the game is not in high detail
	// mode then remove it.
	if(CheckA.bHighDetail
		&& !bGameHighDetail)
		Needed = 0;
	else
		// everything else is needed
		Needed=1;
}

///////////////////////////////////////////////////////////////////////////////
// Go through all the items in this level and set appropriate ones
// to be checked for errand completion. Saves level designers having to remember
///////////////////////////////////////////////////////////////////////////////
function PrepPickupsForErrands()
	{
	local P2PowerupPickup powerpick;
//	local P2Player p2p;

	//log(self$" PrepPickupsForErrands");
	// Check off errands for all players
//	foreach DynamicActors(class'P2Player', p2p)
//		{
		foreach DynamicActors(class'P2PowerupPickup', powerpick)
			{
			//log("checking "$powerpick$" tag "$powerpick.tag);
			if(Days[TheGameState.CurrentDay].CheckForErrandUse(powerpick))
				{
				//log(self$" this is used for an errand "$powerpick);
				// Mark this powerup as necessary for an errand
				powerpick.bUseForErrands=true;
				}
			}
//		}
	}

///////////////////////////////////////////////////////////////////////////////
// If the gamestate's bTakePlayerInventory is set to true, take all the
// dude's inventory items. Then, go through all the weapon and powerup pickups
// in the level, and for the matching classes with bForTransferOnly set to true,
// leave those be. For ones with bForTransferOnly set to true, but there is
// no matching item from the dude's inventory, destroy them now. Also,
// if gamestate's bTakePlayerInventory is set to false, then destroy all
// pickups with bForTransferOnly set to true.
///////////////////////////////////////////////////////////////////////////////
function CheckToTransferPlayerInventory()
{
	local P2PowerupPickup powerpick;
	local P2WeaponPickup weappick;
	local P2PowerupInv powerinv;
	local P2Weapon weapinv;
	local P2Player p2p;
	local P2Pawn usepawn, temppawn;
	local RobbedInv Robber;
	local bool bFound;
	local float Amount;

	// Get the dude controller
	p2p = GetPlayer();

	// Get the pawn out of that controller
	usepawn = p2p.MyPawn;

	// If a movie starting up on level load or something has prevented getting the player controller
	// at least get
	if(usepawn == None)
	{
		foreach AllActors(class'P2Pawn', temppawn)
		{
			//log(self$" pawn "$temppawn$" player "$temppawn.bPlayer);
			if(temppawn.bPlayer)
			{
				p2p = P2Player(temppawn.Controller);
				usepawn = temppawn;
				break;
			}
		}
	}

	// If we're not transferring, just destroy all marked powerups
	if(!TheGameState.bTakePlayerInventory)
	{
		foreach DynamicActors(class'P2PowerupPickup', powerpick)
		{
			if(powerpick.bForTransferOnly)
				powerpick.Destroy();
		}
		foreach DynamicActors(class'P2WeaponPickup', weappick)
		{
			if(weappick.bForTransferOnly)
				weappick.Destroy();
		}
	}
	else
	{
		// Go through all the powerups
		foreach DynamicActors(class'P2PowerupPickup', powerpick)
		{
			// If you are to remove them, check if the dude has the powerup
			if(powerpick.bForTransferOnly)
			{
				powerinv = P2PowerupInv(usepawn.FindInventoryType(powerpick.InventoryType));

				//log(self$" checking for "$powerpick.InventoryType$" has this "$powerinv);
				// He has it, so leave it, but transfer the count over.
				if(powerinv != None)
				{
					// Force it to drop them all
					powerinv.bThrowIndividually=false;

					// Transfer info from the inv to the pickup
					powerpick.InitDroppedPickupFor(powerinv);
					// Make sure it's persistent
					powerpick.bPersistent = true;

					// destroy the inventory for the dude
					powerinv.DetachFromPawn(powerinv.Instigator);
					usepawn.DeleteInventory(powerinv);

					// If the powerup was marked to steal it from him, do so. This
					// means that for things like donuts or money, the cops will take
					// them from your inventory and you'll never get them back
					if(powerpick.bDestroyAfterTransfer)
						powerpick.Destroy();
				}
				else	// he doesn't so destroy it
					powerpick.Destroy();
			}
		}
		// Go through all the weapons
		foreach DynamicActors(class'P2WeaponPickup', weappick)
		{
			// If you are to remove them, check if the dude has the weapon
			if(weappick.bForTransferOnly)
			{
				weapinv = P2Weapon(usepawn.FindInventoryType(weappick.InventoryType));

				//log(self$" checking for "$weappick.InventoryType$" has this "$weapinv);
				// He has it, so leave it, but transfer the count over.
				if(weapinv != None)
				{
					// transfer info from the inv to the pickup
					weappick.InitDroppedPickupFor(weapinv);
					// Make sure it's persistent
					weappick.bPersistent = true;

					// First remove the ammo for this weapon from the dude
					weapinv.AmmoType.DetachFromPawn(weapinv.Instigator);
					weapinv.AmmoType.Instigator.DeleteInventory(weapinv.AmmoType);
					// Then destroy the inventory for the dude
					weapinv.DetachFromPawn(weapinv.Instigator);
					usepawn.DeleteInventory(weapinv);

					// If the powerup was marked to steal it from him, do so. This
					// means that for things like donuts or money, the cops will take
					// them from your inventory and you'll never get them back
					if(weappick.bDestroyAfterTransfer)
						weappick.Destroy();
				}
				else	// he doesn't so destroy it
					weappick.Destroy();
			}
		}

		// Do anything special you need to, after your inventory and weapons have
		// been taken from you.
		p2p.CheckInventoryAfterItsTaken();

		// Kevlar is special because armor is in the usepawn, so strip any armor
		// from him too. And don't give any back
		usepawn.Armor = 0;

		// If you had a weapon you were currently using, it could have screwed up things
		// so just default to switching your hands (like if you're clipboard was taken and
		// was currently being used)
		if(p2p != None)
		{
			p2p.ResetHandsToggle();

			if(p2p.MyPawn != None)
				p2p.SwitchToHands(true);
		}

		// Make sure to reset this
		TheGameState.bTakePlayerInventory=false;
	}	
	
	// Handle dude robbery items
	if (usepawn != None)
	{
		Robber = RobbedInv(usepawn.FindInventoryType(class'RobbedInv'));
		// Search in powerups
		foreach DynamicActors(class'P2PowerupPickup', powerpick)
		{
			if (powerpick.bForRobberyOnly)
			{
				bFound = false;
				if (Robber != None)
				{
					// Find out how much the robber stole (if any) and put it into the pickup
					Amount = Robber.ReturnThisItem(powerpick.InventoryType);
					if (Amount != -1)
					{
						bFound = true;
						powerpick.AmountToAdd = Amount;
					}
				}
				// If the robber didn't steal this, destroy it.
				if (!bFound)
					powerpick.Destroy();
			}
		}
		// Search in weapons
		foreach DynamicActors(class'P2WeaponPickup', weappick)
		{
			if (weappick.bForRobberyOnly)
			{
				bFound = false;
				if (Robber != None)
				{
					// Find out how much the robber stole (if any) and put it into the pickup
					Amount = Robber.ReturnThisItem(weappick.InventoryType);
					if (Amount != -1)
					{
						bFound = true;
						weappick.AmmoGiveCount = int(Amount);
					}
				}
				// If the robber didn't steal this, destroy it.
				if (!bFound)
					weappick.Destroy();
			}
		}
	}
}


//=================================================================================================
//=================================================================================================
//=================================================================================================
//
// Misc
//
//=================================================================================================
//=================================================================================================
//=================================================================================================


///////////////////////////////////////////////////////////////////////////////
// Set gameplay speed but don't save it to the config file
// Like Engine SetGameSpeed.
///////////////////////////////////////////////////////////////////////////////
function SetGameSpeedNoSave( Float T )
{
	local float OldSpeed;

	OldSpeed = GameSpeed;
	GameSpeed = FMax(T, 0.1);
	Level.TimeDilation = GameSpeed;
	//if ( GameSpeed != OldSpeed )
	//	SaveConfig();
	SetTimer(Level.TimeDilation, true);
}

///////////////////////////////////////////////////////////////////////////////
// True means if the player screws around too much on the first
// day, he'll get reminders to check the map for errands to do.
//
// This checks to only show the reminder hints if it's the first day.
// The assumption is that if the player has played to the second day, then
// he must understand the errand and game structure enough to not have to be
// reminded to check the map.
// It also stops telling you about it on day one, once you've finished
// all your errands
///////////////////////////////////////////////////////////////////////////////
function bool AllowReminderHints()
{
	if(TheGameState != None
		&& TheGameState.CurrentDay == 0
		&& !IsPlayerReadyForHome())
		return Super.AllowReminderHints();
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Change the sky based on the day, using a material trigger
///////////////////////////////////////////////////////////////////////////////
function ChangeSkyByDay()
{
	local MaterialTrigger mattrig;
	local int i;

	// Find the skybox trigger, and trigger it to the correct day
	foreach AllActors(class'MaterialTrigger', mattrig, SKY_BOX_TRIGGER)
		break;

	if(mattrig != None)
	{
		// If your in the normal week, just set the skybox by the day number
		if(!TheGameState.bIsApocalypse)
			mattrig.SetCurrentMaterialSwitch(TheGameState.CurrentDay);
		else// Apocalypse is expected to be one past the last day.
			mattrig.SetCurrentMaterialSwitch(TheGameState.CurrentDay+1);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get the first player you come across in the controller list
///////////////////////////////////////////////////////////////////////////////
function P2Player GetPlayer()
{
	local controller con;

	for(con = Level.ControllerList; con != None; con = con.NextController)
		if(P2Player(con) != None)
			return P2Player(con);

	return None;
}

///////////////////////////////////////////////////////////////////////////////
// If we have fewer pawns in action than the goal, then bring the ones in
// sliderstasis out of it, until there are enough active.
// Only bring them in if they can't be seen and if they are further than SLIDER_PAWN_DIST.
///////////////////////////////////////////////////////////////////////////////
function CheckToRevivePawns()
{
	local FPSPawn fpawn, pplayer;
	local float usedist, usedot;
	local P2Player p2p;

	//log(self$" CheckToRevivePawns, active "$SliderPawnsActive$" goal "$SliderPawnGoal$" total "$SliderPawnsTotal);

	if(SliderPawnsActive < SliderPawnGoal
		&& SliderPawnsActive < SliderPawnsTotal)
	{
		//log(self$" trying to bring some back ");

		// Find the player to compare distance to.
		foreach DynamicActors(class'P2Player', p2p)
			break;

		pplayer = p2p.MyPawn;

		foreach DynamicActors(class'FPSPawn', fpawn)
		{
			//log(self$" checking "$fpawn);

			if(fpawn.bSliderStasis
				&& LambController(fpawn.Controller) != None)
			{
				usedist = VSize(fpawn.Location - pplayer.Location);

				usedot = Normal(fpawn.Location - pplayer.Location) Dot vector(pplayer.Rotation);
				//log(self$" use dot "$usedot);
				// See if he's far enough away, and outside of your view
				if(usedist > SLIDER_PAWN_DIST
					&& (usedot) < VIEW_CONE_SLIDER_PAWN)
				{
					LambController(fpawn.Controller).ComeOutOfSliderStasis();
					// If we've met our quota, then quit early
					if(SliderPawnsActive >= SliderPawnGoal
						|| SliderPawnsActive == SliderPawnsTotal)
					{
						//log(self$" STOPPING!");
						break;
					}
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to rain cats during the apocalypse
///////////////////////////////////////////////////////////////////////////////
function CheckCatRain(float DeltaTime)
{
	// STUB--found in gamesingleplayer
}

///////////////////////////////////////////////////////////////////////////////
// Cheat that says the player can kill anyone in one shot to the head from the
// pistol or machinegun.
///////////////////////////////////////////////////////////////////////////////
function bool PlayerGetsHeadShots()
{
	if(TheGameState != None)
		return TheGameState.bGetsHeadShots;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Reach into entry and put a new reference to every chameleon texture/mesh in this
// level.
///////////////////////////////////////////////////////////////////////////////
function StoreChams()
{
	// STUB -- done in GameSinglePlayer
}

//=================================================================================================
//=================================================================================================
//=================================================================================================
//
// Display debug info
//
//=================================================================================================
//=================================================================================================
//=================================================================================================


///////////////////////////////////////////////////////////////////////////////
// Type function name at the console to toggle the display of debug info.
///////////////////////////////////////////////////////////////////////////////
exec function ShowGameInfo()
	{
	TheGameState.bShowGameInfo = !TheGameState.bShowGameInfo;
	}	

///////////////////////////////////////////////////////////////////////////////
// Display debug info
///////////////////////////////////////////////////////////////////////////////
event RenderOverlays(Canvas Canvas)
	{
	local string str;
	local int i, j;
	local int count;

	if (TheGameState != None && TheGameState.bShowGameInfo)
		{
		Super.RenderOverlays(Canvas);

		DrawTextDebug(Canvas, "P2GameInfoSingle (class = "$String(Class)$")");

		DrawTextDebug(Canvas, "StartFirstDayURL = "$StartFirstDayURL, 1);
		DrawTextDebug(Canvas, "StartNextDayURL = "$StartNextDayURL, 1);
		DrawTextDebug(Canvas, "FinishedDayURL = "$FinishedDayURL, 1);
		DrawTextDebug(Canvas, "JailURL = "$JailURL, 1);
		DrawTextDebug(Canvas, "MainMenuURL = "$MainMenuURL, 1);
		DrawTextDebug(Canvas, "");
		DrawTextDebug(Canvas, "bNiceDude = "$TheGameState.bNiceDude, 1);
		DrawTextDebug(Canvas, "StartDay = "$TheGameState.StartDay, 1);	// xPatch
		DrawTextDebug(Canvas, "CurrentDay = "$TheGameState.CurrentDay$" ("$Days[TheGameState.CurrentDay].UniqueName$")", 1);
		DrawTextDebug(Canvas, "Current level = "$ParseLevelName(Level.GetLocalURL()), 1);
		DrawTextDebug(Canvas, "bFirstLevelOfGame = "$TheGameState.bFirstLevelOfGame, 1);
		DrawTextDebug(Canvas, "bFirstLevelOfDay = "$TheGameState.bFirstLevelOfDay, 1);
		DrawTextDebug(Canvas, "bPreGameMode = "$TheGameState.bPreGameMode, 1);
		DrawTextDebug(Canvas, "ErrandsCompletedToday = "$TheGameState.ErrandsCompletedToday, 1);
		DrawTextDebug(Canvas, "JailCellNumber = "$TheGameState.JailCellNumber, 1);
		DrawTextDebug(Canvas, "MostRecentGameSlot = "$MostRecentGameSlot, 1);
// xPatch:
		DrawTextDebug(Canvas, "ClassicGame = "$bNoEDWeapons, 1);
		DrawTextDebug(Canvas, "ClassicGame (GameState) = "$TheGameState.bNoEDWeapons, 1);
		DrawTextDebug(Canvas, "");
		DrawTextDebug(Canvas, "bCheated = "$TheGameState.DidPlayerCheat(), 1);
		DrawTextDebug(Canvas, "bActuallyCheated = "$TheGameState.DidPlayerCheatCode(), 1);
		DrawTextDebug(Canvas, "bWorkshopGame = "$GetWorkshopGame(), 1);
		DrawTextDebug(Canvas, "");
// End

		str = "";
		DrawTextDebug(Canvas, "Errands Still To Do Today:", 1);
		for (j = 0; j < Days[TheGameState.CurrentDay].Errands.Length; j++)
			{
			if (!Days[TheGameState.CurrentDay].IsErrandComplete(j))
				{
				if (j > 0)
					str = str $ ", ";
				str = str $ Days[TheGameState.CurrentDay].Errands[j].UniqueName;
				}
			}
		if (str == "")
			str = "(none)";
		DrawTextDebug(Canvas, str, 2);

		DrawTextDebug(Canvas, "Completed Errands (all days)", 1);
		count = 0;
		str = "";
		for (i = 0; i < Days.Length; i++)
			{
			for (j = 0; j < Days[i].Errands.Length; j++)
				{
				if (Days[i].IsErrandComplete(j))
					{
					str = str $ Days[i].Errands[j].UniqueName $ ", ";
					count++;
					}
				if (count == 10)
					{
					DrawTextDebug(Canvas, str, 2);
					str = "";
					count = 0;
					}
				}
			}
		if (count > 0)
			DrawTextDebug(Canvas, str, 2);
		else
			DrawTextDebug(Canvas, "(none)", 2);

		DrawTextDebug(Canvas, "Persistent PawnsArr ("$TheGameState.PawnsArr.Length$")", 1);
		for (i = 0; i < TheGameState.PawnsArr.Length; i++)
			DrawTextDebug(Canvas, TheGameState.PawnsArr[i].Tag$" in "$TheGameState.PawnsArr[i].LevelName, 2);

		DrawTextDebug(Canvas, "Persistent WeaponsArr ("$TheGameState.WeaponsArr.Length$")", 1);
		for (i = 0; i < TheGameState.WeaponsArr.Length; i++)
			DrawTextDebug(Canvas, TheGameState.WeaponsArr[i].ClassName$"(tag="$TheGameState.WeaponsArr[i].Tag$") in "$TheGameState.WeaponsArr[i].LevelName, 2);

		DrawTextDebug(Canvas, "Persistent PowerupsArr ("$TheGameState.PowerupsArr.Length$")", 1);
		for (i = 0; i < TheGameState.PowerupsArr.Length; i++)
			DrawTextDebug(Canvas, TheGameState.PowerupsArr[i].ClassName$"(tag="$TheGameState.PowerupsArr[i].Tag$") in "$TheGameState.PowerupsArr[i].LevelName, 2);

		DrawTextDebug(Canvas, "CurrentHaters ("$TheGameState.CurrentHaters.Length$")", 1);
		str = "";
		for (i = 0; i < TheGameState.CurrentHaters.Length; i++)
			{
			if (i > 0)
				str = str $ ", ";
			str = str $ GetItemName(String(TheGameState.CurrentHaters[i].ClassName));
			}
		if (str == "")
			str = "(none)";
		DrawTextDebug(Canvas, str, 2);

		DrawTextDebug(Canvas, "CopRadioTime ("$TheGameState.CopRadioTime$"/"$TheGameState.CopRadioMax$")", 1);
		DrawTextDebug(Canvas, "bArrestPlayerInJail = "$TheGameState.bArrestPlayerInJail, 1);
		DrawTextDebug(Canvas, "bPlayerInCell = "$TheGameState.bPlayerInCell, 1);
		DrawTextDebug(Canvas, "bIsApocalypse = "$TheGameState.bIsApocalypse, 1);
		}
	}

function InitPostTravelIGT()
{
	local Vector PreTravelTime, PostTravelTime;
	local float CurrentDays, CurrentSeconds, CurrentMilliseconds;
	
	// Don't execute this twice.
	if (bReadyToDrawTime)
		return;
	
	// Get the full amount of time it took to travel
	PreTravelTime = TheGameState.PreTravelTime;
	
	// don't do this on the first load
	if (PreTravelTime == vect(0,0,0))
		return;
		
	PostTravelTime = Level.GetMillisecondsNow();
	
	//log("Strict IGT: PreTravelTime was"@PreTravelTime@"PostTravelTime was"@PostTravelTime);
	//log("Old TimeStart:"@TheGameState.TimeStart);
	
	TheGameState.PreTravelTime = Vect(0,0,0);
	
	// Don't adjust the timer if it's already over.
	if (TheGameState.TimeStop == vect(0,0,0))
	{	
		CurrentDays = (PostTravelTime.X - PreTravelTime.X);	// this should always be zero, no matter how bad of a toaster we're running on.
		CurrentSeconds = (PostTravelTime.Y - PreTravelTime.Y);
		CurrentMilliseconds = (PostTravelTime.Z - PreTravelTime.Z);
		
		//log("Strict IGT: Adding"@CurrentDays@"days,"@CurrentSeconds@"seconds, and"@CurrentMilliseconds@"MS to start time");
		
		// ADDS this loading time into TimeStart, so it effectively "won't count" toward the strict IGT.
		TheGameState.TimeStart.X += CurrentDays;
		TheGameState.TimeStart.Y += CurrentSeconds;
		TheGameState.TimeStart.Z += CurrentMilliseconds;
	}
	//log("New TimeStart:"@TheGameState.TimeStart);
	
	bReadyToDrawTime = true;
}
	
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// StartUp
// Do things at the absolute last moment before the game starts
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state StartUp
{
	///////////////////////////////////////////////////////////////////////////////
	// The gameinfo has everything ready so now we tell the player controller
	// to prepare itself for a save. Make sure though, that it's allowed--demo versions can't save.
	// Instead, the demo version forces the map to come up, since the Intro movie isn't there
	// to have the map come up. Only do this though, on the start of the first day
	// in the first level.
	///////////////////////////////////////////////////////////////////////////////
	function PrepPlayerStartup()
	{
		local P2Player p2p;

		p2p = GetPlayer();
		// Don't ever allow saving in the demo
		if(!Level.IsDemoBuild())
			p2p.PrepForSave();
			
		// xPatch: for the new Skip Intro option 
		// we need to force the map at the start of the game.
		if(p2p != None 
			&& TheGameState.bFirstLevelOfGame
			&& TheGameState.bForceMap)
		{
			//log(self$" requesting map ");
			p2p.ForceMapUp();
			TheGameState.bForceMap = False;
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function bool StartingUp()
	{
		return true;
	}
Begin:
//Log(self @ "Startup state: !TimeBeg!");
	PrepDifficulty();
	SetZoneFogPlanes();
	ChangeSkyByDay();	// Change the skies based on the day number
	ChangeMenuBackground();	// xPatch: Change the menu background
	PrepActorsByGroup();
	PrepSliderPawns();
	PrepPickupsForErrands();
	RemoveGottenPickups();
	CheckToTransferPlayerInventory();
	StoreChams();
	// Only if we're in the Apocalypse, after a new level starts, set all NPC's into riot mode
	if(TheGameState.bIsApocalypse)
		ConvertAllPawnsToRiotMode();
//Log(self @ "Startup state: !TimeEnd!");

	// The gameinfo has everything ready so now we tell the player controller
	// to prepare itself for a save. Make sure though, that it's allowed--demo versions can't save.
	// Instead, the demo version forces the map to come up, since the Intro movie isn't there
	// to have the map come up. Only do this though, on the start of the first day
	// in the first level.
	PrepPlayerStartup();

	// Show map title
	if (!IsMainMenuMap() && !IsIntroMap() && !IsFinishedDayMap())
		if (Level.Title != "" && Level.Title != "Untitled")
			GetPlayer().ClientMessage(Level.Title);

	if(!TheGameState.bIsApocalypse)
		GotoState(RunningStateName);
	else
		GotoState('RunningApocalypse');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Running
// Monitor things in the game as it runs
// This is for the *full* version of the game. The running state for the
// demo is defined in the game info for the demo
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Running
{
Begin:
	Sleep(REVIVE_CHECK_TIME);
	CheckToRevivePawns();
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Monitor things in the game, and rain cats
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunningApocalypse
{
Begin:
	Sleep(SLEEP_TIME_INC);
	CheckReviveTime += SLEEP_TIME_INC;
	// Update only when this is equal
	if(CheckReviveTime >= REVIVE_CHECK_TIME)
	{
		CheckToRevivePawns();
		CheckReviveTime=0;
	}
	// We need this updatted each second.
	CheckCatRain(SLEEP_TIME_INC);
	Goto('Begin');
}

function AddMutator(string mutname, optional bool bUserAdded)
{
    local class<Mutator> mutClass;
    local Mutator mut;

    mutClass = class<Mutator>(DynamicLoadObject(mutname, class'Class'));
    if (mutClass == None)
        return;

	if (class<P2GameMod>(mutClass) == None)
	{
		warn(MutName@" - Cannot use Mutator as parent class for single-player game mods. Please use P2GameMod instead.");
		return;
	}

	Super.AddMutator(MutName, bUserAdded);
}

///////////////////////////////////////////////////////////////////////////////
// This is called to indicate the GameInfo has become valid.
///////////////////////////////////////////////////////////////////////////////
function GameInfoIsNowValid()
{
	local DayTrigger T;
	local P2TriggerVolume V;
	
	Super.GameInfoIsNowValid();
	
	foreach DynamicActors(class'DayTrigger', T)
		T.GameInfoIsNowValid();
		
	foreach DynamicActors(class'P2TriggerVolume', V)
		V.GameInfoIsNowValid();
		
	// Maybe modders want to do something
	BaseMod.GameInfoIsNowValid();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Man Chrzan: xPatch's Functions
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Handled through final function to make sure that any workshop mods
// won't be able to mess around with it or remove it, just to be safe.
///////////////////////////////////////////////////////////////////////////////
final function xPatchManagerCheck()
{
	if(xManager == None)
		xManager = spawn(class'xPatchManager');	
}

///////////////////////////////////////////////////////////////////////////////
// New better way to disable new dialogs for localized version 
// on it's first launch or if the game version was changed.
// NOTE: Called by ShellRootWindow initialization.
///////////////////////////////////////////////////////////////////////////////
function CountryCodeCheck(string CountryCode)
{
	local bool bLocalize;
	
	// Add xPatch Manager
	xPatchManagerCheck();
	
	// We can actually use it to assign new important controls/settings 
	// if they are launching the game for the first time after update too.
	// I don't think the Postal2.ini will update itself with new Default.ini changes... sadly.
	// This bit of code can be removed some time after the update has been released officially.
	if(SavedCountryCode == "")
	{
		GetPlayer().ConsoleCommand("set input MiddleMouse Reload");
		GetPlayer().ConsoleCommand("set input G MiddleFinger");
		GetPlayer().ConsoleCommand("set input Y GetDown");
		
		if(BodiesSliderMax >= 15)
			GetPlayer().ConsoleCommand("set P2GameInfo BodiesSliderMax 15");
	}

	// Check if game version was changed 
	// (or if it's first launch ever)
	if(SavedCountryCode != CountryCode)
	{
		// These are the only (offcial) versions with dub I think
		if(CountryCode == "RU"
		|| CountryCode == "ZH"	
		|| CountryCode == "PL")
			bLocalize = True;
		else
			bLocalize = False;
		
		// Change the setting
		GetPlayer().ConsoleCommand("set" @ LoacalizationPath @ bLocalize);
	
		// Save our current game ver
		SavedCountryCode = CountryCode;	
	}
}

///////////////////////////////////////////////////////////////////////////////
// Localized dialogue swap 
// Simplified BasePeople.u file is no longer needed 
// for localized game versions!
///////////////////////////////////////////////////////////////////////////////
function P2Dialog GetDialogObj(string strClass)
{
	local string replaceStr;
	replaceStr = strClass;

	// Replace new dialogs with old ones if desired
	if( bLocalizedDialog )
	{
		if(strClass == "BasePeople.DialogFemaleAlt"
			|| strClass == "BasePeople.DialogFemaleBlack"
			|| strClass == "BasePeople.DialogFemaleMex")
			replaceStr = "BasePeople.DialogFemale";

		if(strClass == "BasePeople.DialogMaleAlt"
			|| strClass == "BasePeople.DialogMaleBlack"
			|| strClass == "BasePeople.DialogMaleMex"
			|| strClass == "BasePeople.DialogMikeJ"
			|| strClass == "BasePeople.DialogGay")
			replaceStr = "BasePeople.DialogMale";

		if(strClass == "BasePeople.DialogFanatic"
			|| strClass == "BasePeople.DialogHabib")
			replaceStr = "BasePeople.DialogHabibLocalized";
			
		if(strClass == "BasePeople.DialogDude")
			replaceStr = "BasePeople.DialogDudeLocalized";
		
		if(strClass == "BasePeople.DialogVince")
			replaceStr = "BasePeople.DialogVinceLocalized";	
	}

	return Super.GetDialogObj(replaceStr);
}

///////////////////////////////////////////////////////////////////////////////
// Get the localized day name
///////////////////////////////////////////////////////////////////////////////
function string GetDayName()
{
	local string DayDescription;
	local int i, strcheck;
	
	DayDescription = GetCurrentDayBase().Description;

	// Check if DayDescription matches our localized DayNames
	for (i=0; i<DayNames.Length; i++)
	{
		strcheck = InStr(DayDescription, DayNames[i]);
		if(strcheck >= 0 )
			return DayNames[i];
	}
	
	// if it doesn't just return the description back
	return DayDescription;
}
		
///////////////////////////////////////////////////////////////////////////////
// New way to handle removing weapon pickups in classic mode
///////////////////////////////////////////////////////////////////////////////
function bool AllowedInClassicGame(Actor CheckA)
{
	local int i;
	local bool bException;
	local bool bNoAWWeapons;
	local bool bCheckExceptions;
	local class<Actor> PickupClass;
	local class<P2Weapon> GunClass;
	
	// ONLY PICKUPS 
	if(P2WeaponPickup(CheckA) != None
		|| P2AmmoPickup(CheckA) != None)
	{
		// Check for xManager -- just in case
		xPatchManagerCheck();
		
		if(InClassicMode() || xManager.bAlwaysOGWeapons)
		{
			if(InClassicMode()) {
				bNoAWWeapons = xManager.bNoAWWeapons;
				bCheckExceptions = xManager.bAllowExceptions;
			}
			else {
				bNoAWWeapons = xManager.bNoAWWeaponsRG;
				bCheckExceptions = xManager.bAllowExceptionsRG;
			}
			
			
			for( i = 0 ; i < NonClassicPickupList.Length ; i++ )
			{
				if( NonClassicPickupList[i].ClassName != "" )
				{
					//Log("Checking Non-Classic item: "$NonClassicPickupList[i].ClassName);
					
					// Special check for AW weapons
					if((NonClassicPickupList[i].bAWPickup == true && IsWeekend())		// It's AW pickup and it's weekend currently
					|| (NonClassicPickupList[i].bAWPickup == true && !bNoAWWeapons))	// It's always allowed by the setting option
						bException = True;
					else if(bCheckExceptions) // The ususal check for exceptions list
						bException = xManager.IsException(NonClassicPickupList[i].ClassName);
					
					if(!bException)
					{
						// See if we have loaded the class already.
						if(NonClassicPickupList[i].MyClass != None)
							PickupClass = NonClassicPickupList[i].MyClass;
						else
						{
							PickupClass = class<Actor>(DynamicLoadObject(NonClassicPickupList[i].ClassName, class'Class'));
							// Save it for later so we don't need to dynamic load every time.
							NonClassicPickupList[i].MyClass = PickupClass; 
							default.NonClassicPickupList[i].MyClass = PickupClass; 
						}
						
						if(CheckA.Class == PickupClass)
						{
							//Log("Non-Classic item NOT allowed: "$CheckA);
							return false;
						}
					}
				}
			}
		}
	}
	// Passed all checks for classic game
	//Log("Non-Classic item allowed: "$CheckA);
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Check if this actor is need for either of these groups.
///////////////////////////////////////////////////////////////////////////////
function NeededForClassicGame(Actor CheckA, out byte Needed)
{
	local int i;
	local string GroupString;

	GroupString = Caps(CheckA.Group);
	
	Needed=1;
	
	// Not needed if classic game is disabled
	i = InStr(GroupString, CLASSIC_GROUP);
	if(i >= 0 && !InClassicMode())
	{
		Needed=0;
		return;
	}

	// Not needed if classic game is enabled
	i = InStr(GroupString, UPDATE_GROUP);
	if(i >= 0 && InClassicMode())
	{
		Needed=0;
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Is it classic mode or not
///////////////////////////////////////////////////////////////////////////////
function bool InClassicMode()
{
	if (TheGameState != None)
		return (TheGameState.bNoEDWeapons);
	else
		return bNoEDWeapons;
	
	//log(self@"classic mode"@bNoEDWeapons);
}

///////////////////////////////////////////////////////////////////////////////
// Static classic game check for DayBase to get correct laoding screens.
///////////////////////////////////////////////////////////////////////////////
static function bool InClassicModeStatic()
{
	if(default.bNoEDWeapons)
		return true;
}

///////////////////////////////////////////////////////////////////////////////
// Should we get classic animations or not
///////////////////////////////////////////////////////////////////////////////
function bool GetClassicAnimations()
{
	return (xManager != None && xManager.bClassicAnimations && InClassicMode()
		|| xManager != None && xManager.bClassicAnimationsRG && !InClassicMode());
}

///////////////////////////////////////////////////////////////////////////////
// Should we get classic melee or not
///////////////////////////////////////////////////////////////////////////////
function bool GetClassicMelee()
{
	return (xManager != None && xManager.bClassicMelee && InClassicMode()
			|| xManager != None && xManager.bClassicMeleeRG && !InClassicMode());
}

///////////////////////////////////////////////////////////////////////////////
// Should we get classic zombies or not
///////////////////////////////////////////////////////////////////////////////
function bool GetClassicZombies()
{
	return (xManager != None && xManager.bClassicZombies && InClassicMode()
			|| xManager != None && xManager.bClassicZombiesRG && !InClassicMode());
}

///////////////////////////////////////////////////////////////////////////////
// Should we get classic icons or not
///////////////////////////////////////////////////////////////////////////////
function bool GetClassicIcons()
{
	return (xManager != None && xManager.bClassicHUDIcons && InClassicMode()
			|| xManager != None && xManager.bClassicHUDIconsRG && !InClassicMode());
}

///////////////////////////////////////////////////////////////////////////////
// Should we get classic police cars or not
///////////////////////////////////////////////////////////////////////////////
function bool GetClassicCars()
{
	return (xManager != None && xManager.bClassicCars && InClassicMode()
			|| xManager != None && xManager.bClassicCarsRG && !InClassicMode());
}

///////////////////////////////////////////////////////////////////////////////
// Should we get classic dude head or not
///////////////////////////////////////////////////////////////////////////////
function bool GetClassicDude()
{
	return (xManager != None && xManager.bClassicDude && InClassicMode()
			|| xManager != None && xManager.bClassicDudeRG && !InClassicMode());
}

///////////////////////////////////////////////////////////////////////////////
// Workshop game or not
///////////////////////////////////////////////////////////////////////////////
final function bool GetWorkshopGame()
{
	return bWorkshopGame;
}

function bool IsFirstLevelOfGame()
{
	return (TheGameState.bFirstLevelOfGame && TheGameState.bFirstLevelOfDay);
}

///////////////////////////////////////////////////////////////////////////////
// Changes the menu background based on the selected option
///////////////////////////////////////////////////////////////////////////////
function ChangeMenuBackground()
{
	local MaterialTrigger mattrig;
	
	// Find the background trigger, and trigger it if needed
	if(xManager != None)
	{
		foreach AllActors(class'MaterialTrigger', mattrig, MENU_BGR_TRIGGER)
			break;
			
		if(mattrig != None)
		{
			if(xManager.bClassicBackground)
				mattrig.SetCurrentMaterialSwitch(1);
			else
				mattrig.SetCurrentMaterialSwitch(0);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Allows to Toggle Classic Mode even after the game started
///////////////////////////////////////////////////////////////////////////////
function ToggleClassicMode()
{
	bNoEDWeapons = !bNoEDWeapons; 
	TheGameState.bNoEDWeapons = bNoEDWeapons; 

	if(bNoEDWeapons)
		GetPlayer().ClientMessage("Classic Mode -- ON");
	else
		GetPlayer().ClientMessage("Classic Mode -- OFF");
}

function GetLoadOut(optional int myday)
{
	local int i, j, day;
	local Inventory inv;
	local class<Actor> WeaponClass;
	local P2Pawn Dude;
	local bool bGive;
	
	if(myday != 0)
		day = myday-1;
	else
		day = GetCurrentDay();
	
	Dude = GetPlayer().MyPawn;
	
	//Log("LoadoutDays[day].Items.Length = "$LoadoutDays[day].Items.Length);
	
	// Add loadout to the dude's inventory
	for (i = 0; i < LoadoutDays[day].Items.Length; i++)
	{
		// Ignore some for Classic Game
		bGive = True;
		if(LoadoutDays[day].Items[i].NonClassic 
			&& (InClassicMode() || xManager.bAlwaysOGWeapons))
			bGive=False;
		
		if(bGive)
		{
			inv = Dude.CreateInventoryByClass(LoadoutDays[day].Items[i].Item);
			//Log("LoadOut: CreateInventoryByClass: "$LoadoutDays[day].Items[i].Item);
			
			// If we made it, possibly give them some extra ammo or whatever.
			if (inv != None)
			{
				if (P2Weapon(Inv) != None)
				{
					P2Weapon(Inv).GiveAmmoFromPickup(Dude, LoadoutDays[day].Items[i].Amount);
					P2Weapon(inv).bJustMade = false;
				}			
				else if (Ammunition(Inv) != None)
					Ammunition(Inv).AddAmmo(LoadoutDays[day].Items[i].Amount);
				else if (P2PowerupInv(Inv) != None)
					P2PowerupInv(Inv).AddAmount(LoadoutDays[day].Items[i].Amount);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Allows unique main menus, just like Apocalypse Weekend has its own
// now with this function there can be multiple for one game mode.
///////////////////////////////////////////////////////////////////////////////
function UpdateMainMenu()
{
	//STUB. It's used only for AWPGameInfo and PLGameInfo.
}

///////////////////////////////////////////////////////////////////////////////
// NEW DEBUG COMMANDS
///////////////////////////////////////////////////////////////////////////////
exec function TClassicGame()
{
	if(!GetPlayer().DebugEnabled())
		return;
	
	ToggleClassicMode();
}

exec function EndGameNow()
{
	if (!GetPlayer().DebugEnabled())
		return;
	
	EndOfGame(GetPlayer());
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MutatorClass="Postal2Game.P2GameMod"
	bWaitingToStartMatch=true
	bDelayedStart=false
	DefaultPlayerClassName="GameTypes.AWPostalDude"
    ApocalypseTex="p2misc_full.newspaper_day_5a"
	ApocalypseComment="DudeDialog.dude_news_Apocalypse"
	EasySaveMessageString="Easy Saving"
	AutoSaveMessageString="Auto Saving (can be disabled in Options menu)"
	CheckpointSaveMessageString="Checkpoint reached, saving..."
	ForcedSaveMessageString="Saving start of new day"
	NormalSaveMessageString="Saving"
	RunningStateName="Running"
	bIsValid=false
	bAllowBehindView=true
	bAllowClassicGame=true

	DifficultyNames[0]="Liebermode"
	DifficultyNames[1]="Too Easy"
	DifficultyNames[2]="Very Easy"
	DifficultyNames[3]="Easy"
	DifficultyNames[4]="Remedial"
	DifficultyNames[5]="Average"
	DifficultyNames[6]="Aggressive"
	DifficultyNames[7]="Hard"
	DifficultyNames[8]="Very Hard"
	DifficultyNames[9]="Manic"
	DifficultyNames[10]="Hestonworld"
	DifficultyNames[11]="Insane-o"
	DifficultyNames[12]="They Hate Me"
	DifficultyNames[13]="POSTAL"
	DifficultyNames[14]="Impossible"
	DifficultyNames[15]="Ludicrous"
	CustomDifficultyName="Custom"

	FinStop=41
    MultCast=10

	GameStateClass=class'GameState'
	StatsScreenClassName="Postal2Game.StatsScreen"
	MapScreenClassName="Postal2Game.MapScreen"

	// Forced loading screens when loading saved games.
	DayNames[0]="Monday"
	LoadingScreens[0]=Texture'p2misc_full.loading1'
	DayNames[1]="Tuesday"
	LoadingScreens[1]=Texture'p2misc_full.loading2'
	DayNames[2]="Wednesday"
	LoadingScreens[2]=Texture'p2misc_full.loading3'
	DayNames[3]="Thursday"
	LoadingScreens[3]=Texture'p2misc_full.loading4'
	DayNames[4]="Friday"
	LoadingScreens[4]=Texture'p2misc_full.loading5'
	DayNames[5]="Saturday"
	LoadingScreens[5]=Texture'aw_textures.loading_sat'
	DayNames[6]="Sunday"
	LoadingScreens[6]=Texture'aw_textures.loading_sun'
	ForceDayOnStartup=-1

// Holiday defs
//ErikFOV Change: For Licalization	
	HolidayDisplayName[0]="Valentine's Day"
	HolidayDisplayName[1]="St. Patrick's Day"
	HolidayDisplayName[2]="April Fool's Day"
	HolidayDisplayName[3]="Easter Sunday"
	HolidayDisplayName[4]="Halloween"
	HolidayDisplayName[5]="Night Mode"
	
	HolidayDescription[0]="Love is in the air! Don't forget to visit the Kissing Booth!"
	HolidayDescription[1]="Can you catch me lucky charms?"
	HolidayDescription[2]="Adds a new feature to the main menu!"
	HolidayDescription[3]="Go hunting for Easter eggs in the forest!"
	HolidayDescription[4]="3spooky5me"
	HolidayDescription[5]="Goes great with Halloween!"
	
	Holidays[0]=(HolidayName="SeasonalValentine",Dates=((Month=(Min=2,Max=2),Day=(Min=12,Max=16))))
	Holidays[1]=(HolidayName="SeasonalStPatricks",Dates=((Month=(Min=3,Max=3),Day=(Min=14,Max=19))))
	Holidays[2]=(HolidayName="SeasonalAprilFools",Dates=((Month=(Min=3,Max=3),Day=(Min=25,Max=31)),(Month=(Min=4,Max=4),Day=(Min=1,Max=1))))
	Holidays[3]=(HolidayName="SeasonalEaster",Dates=((Month=(Min=4,Max=4),Day=(Min=16,Max=23),Year=(Min=2014,Max=2014)),(Month=(Min=5,Max=5),Day=(Min=1,Max=7),Year=(Min=2014,Max=2014)),(Month=(Min=4,Max=4),Day=(Min=1,Max=8),Year=(Min=2015,Max=2015)),(Month=(Min=3,Max=3),Day=(Min=23,Max=30),Year=(Min=2016,Max=2016)),(Month=(Min=4,Max=4),Day=(Min=12,Max=19),Year=(Min=2017,Max=2017))))
	Holidays[4]=(HolidayName="SeasonalHalloween",Dates=((Month=(Min=10,Max=10),Day=(Min=28,Max=31)),(Month=(Min=11,Max=11),Day=(Min=1,Max=2))))
	Holidays[5]=(HolidayName="NightMode",Dates=((Month=(Min=10,Max=10),Day=(Min=28,Max=31)),(Month=(Min=11,Max=11),Day=(Min=1,Max=2))))
	
	//Holidays[0]=(HolidayName="SeasonalValentine",DisplayName="Valentine's Day",Description="Love is in the air! Don't forget to visit the Kissing Booth!",Dates=((Month=(Min=2,Max=2),Day=(Min=12,Max=16))))
	//Holidays[1]=(HolidayName="SeasonalStPatricks",DisplayName="St. Patrick's Day",Description="Can you catch me lucky charms?",Dates=((Month=(Min=3,Max=3),Day=(Min=14,Max=19))))
	//Holidays[2]=(HolidayName="SeasonalAprilFools",DisplayName="April Fool's Day",Description="Adds a new feature to the main menu!",Dates=((Month=(Min=3,Max=3),Day=(Min=25,Max=31)),(Month=(Min=4,Max=4),Day=(Min=1,Max=1))))
	//Holidays[3]=(HolidayName="SeasonalEaster",DisplayName="Easter Sunday",Description="Go hunting for Easter eggs in the forest!",Dates=((Month=(Min=4,Max=4),Day=(Min=16,Max=23),Year=(Min=2014,Max=2014)),(Month=(Min=5,Max=5),Day=(Min=1,Max=7),Year=(Min=2014,Max=2014)),(Month=(Min=4,Max=4),Day=(Min=1,Max=8),Year=(Min=2015,Max=2015)),(Month=(Min=3,Max=3),Day=(Min=23,Max=30),Year=(Min=2016,Max=2016)),(Month=(Min=4,Max=4),Day=(Min=12,Max=19),Year=(Min=2017,Max=2017))))
	//Holidays[4]=(HolidayName="SeasonalHalloween",DisplayName="Halloween",Description="3spooky5me",Dates=((Month=(Min=10,Max=10),Day=(Min=28,Max=31)),(Month=(Min=11,Max=11),Day=(Min=1,Max=2))))
	//Holidays[5]=(HolidayName="NightMode",DisplayName="Night Mode",Description="Goes great with Halloween!",Dates=((Month=(Min=10,Max=10),Day=(Min=28,Max=31)),(Month=(Min=11,Max=11),Day=(Min=1,Max=2))))
//end

	ArrestedScreenTex="P2Misc.Backgrounds.menu_busted"
	MenuTitleTex="P2Misc.Logos.postal2underlined"
	MainMenuName="Shell.MenuMain"
	StartMenuName="Shell.MenuMain"
	GameMenuName="Shell.MenuGame"
	
	// Classic displayed on saves
	ClassicSaveText="(Classic)"
	
	// Classic Mode - List of pickups to destroy 
	NonClassicPickupList[0]=(ClassName="EDStuff.MP5Pickup")
	NonClassicPickupList[1]=(ClassName="EDStuff.MP5AmmoPickup")
	NonClassicPickupList[2]=(ClassName="EDStuff.GSelectPickup")
	NonClassicPickupList[4]=(ClassName="EDStuff.GSelectAmmoPickup")
	NonClassicPickupList[5]=(ClassName="EDStuff.ShearsPickup")
	NonClassicPickupList[6]=(ClassName="EDStuff.AxePickup")
	NonClassicPickupList[7]=(ClassName="EDStuff.BaliPickup")
	NonClassicPickupList[8]=(ClassName="EDStuff.DynamitePickup")
	NonClassicPickupList[9]=(ClassName="EDStuff.GrenadeLauncherPickup")
	NonClassicPickupList[10]=(ClassName="AWPStuff.BaseballBatPickup")
	NonClassicPickupList[11]=(ClassName="AWPStuff.ChainSawPickup")
	NonClassicPickupList[12]=(ClassName="AWPStuff.DustersPickup")
	NonClassicPickupList[13]=(ClassName="AWPStuff.FlamePickup")
	NonClassicPickupList[14]=(ClassName="AWPStuff.SawnOffPickup")
	NonClassicPickupList[15]=(ClassName="AWPStuff.NukePickup")
	NonClassicPickupList[16]=(ClassName="Inventory.MrDKNadePickup")
	NonClassicPickupList[17]=(ClassName="P2R.ProtestSignPickup")
	NonClassicPickupList[18]=(ClassName="AWPStuff.NukeAmmoPickup")
	NonClassicPickupList[19]=(ClassName="AWInventory.MachetePickup",bAWPickup=True)
	NonClassicPickupList[20]=(ClassName="AWInventory.SledgePickup",bAWPickup=True)
	NonClassicPickupList[21]=(ClassName="AWInventory.ScythePickup",bAWPickup=True)
	
	// Classic Mode - Replacement Info
	ClassicModeReplace(0)=(OldClass="EDStuff.MP5Weapon",NewClass="Inventory.MachinegunWeapon")
	ClassicModeReplace(1)=(OldClass="EDStuff.GSelectWeapon",NewClass="Inventory.PistolWeapon")
	ClassicModeReplace(2)=(OldClass="EDStuff.ShearsWeapon",NewClass="AWInventory.MacheteWeapon")
	ClassicModeReplace(3)=(OldClass="EDStuff.AxeWeapon",NewClass="AWInventory.MacheteWeapon")
	ClassicModeReplace(4)=(OldClass="EDStuff.BaliWeapon",NewClass="Inventory.BatonWeapon")
	ClassicModeReplace(5)=(OldClass="EDStuff.DynamiteWeapon",NewClass="Inventory.GrenadeWeapon")
	ClassicModeReplace(6)=(OldClass="EDStuff.GrenadeLauncherWeapon",NewClass="Inventory.GrenadeWeapon")
	ClassicModeReplace(7)=(OldClass="AWPStuff.BaseballBatWeapon",NewClass="Inventory.ShovelWeapon")
	ClassicModeReplace(8)=(OldClass="AWPStuff.ChainsawWeapon",NewClass="AWInventory.ScytheWeapon")
	ClassicModeReplace(9)=(OldClass="AWPStuff.DustersWeapon",NewClass="Inventory.BatonWeapon")
	ClassicModeReplace(10)=(OldClass="AWPStuff.FlameWeapon",NewClass="Inventory.MachinegunWeapon")
	ClassicModeReplace(11)=(OldClass="AWPStuff.SawnOffWeapon",NewClass="Inventory.ShotgunWeapon")
	ClassicModeReplace(12)=(OldClass="AWPStuff.NukeWeapon",NewClass="Inventory.LauncherWeapon")
	ClassicModeReplace(13)=(OldClass="Inventory.MrDKNadeWeapon",NewClass="Inventory.GrenadeWeapon")
	ClassicModeReplace(14)=(OldClass="P2R.ProtestSignWeapon",NewClass="P2R.ProtestSignWeapon_NoDrop")
	ClassicModeReplace(15)=(OldClass="EDStuff.MP5Weapon_NPC",NewClass="Inventory.MachinegunWeapon")
	
	ClassicLoadTex[0]=Texture'xPatchTex.Loading.loading1'  
	ClassicLoadTex[1]=Texture'xPatchTex.Loading.loading2'
	ClassicLoadTex[2]=Texture'xPatchTex.Loading.loading3'
	ClassicLoadTex[3]=Texture'xPatchTex.Loading.loading4'
	ClassicLoadTex[4]=Texture'xPatchTex.Loading.loading5'
	ClassicLoadTex[5]=Texture'xPatchTex.Loading.loading_sat'
	ClassicLoadTex[6]=Texture'xPatchTex.Loading.loading_sun'
}
