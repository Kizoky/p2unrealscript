//=============================================================================
// LevelInfo contains information about the current level. There should
// be one per level and it should be actor 0. UnrealEd creates each level's
// LevelInfo automatically so you should never have to place one
// manually.
//
// The ZoneInfo properties in the LevelInfo are used to define
// the properties of all zones which don't themselves have ZoneInfo.
//=============================================================================
class LevelInfo extends ZoneInfo
	native
	nativereplication;

cpptext
{
	#include "ALevelInfo.h"
}

// Textures.
#exec Texture Import File=Textures\WireframeTexture.tga
#exec Texture Import File=Textures\WhiteSquareTexture.pcx
#exec Texture Import File=Textures\S_Vertex.tga Name=LargeVertex

//-----------------------------------------------------------------------------
// Level time.

// Time passage.
var() float TimeDilation;          // Normally 1 - scales real time passage.

// Current time.
var           float	TimeSeconds;   // Time in seconds since level began play.
var           float TimeSecondsAlways; // RWS CHANGE: Time in seconds, always updated even when paused
var transient int   Year;          // Year.
var transient int   Month;         // Month.
var transient int   Day;           // Day of month.
var transient int   DayOfWeek;     // Day of week.
var transient int   Hour;          // Hour.
var transient int   Minute;        // Minute.
var transient int   Second;        // Second.
var transient int   Millisecond;   // Millisecond.
var			  float	PauseDelay;		// time at which to start pause
//-----------------------------------------------------------------------------
// Text info about level.

// RWS CHANGE: Merged new level summary vars from 2110
var(LevelSummary) localized String Title;
var(LevelSummary) String Author;
var(LevelSummary) String Description;

var(LevelSummary) Material Screenshot;
var(LevelSummary) String DecoTextName;

var(LevelSummary) int IdealPlayerCountMin;
var(LevelSummary) int IdealPlayerCountMax;

// RWS CHANGE: Added new GrabBag flag
var(LevelSummary) bool	bGrabBagCompatible;		// Whether this map is compatible with GrabBag game type

var(SinglePlayer) int   SinglePlayerTeamSize;

var() localized string	LevelEnterText;			// Message to tell players when they enter.
var()           string LocalizedPkg;    // Package to look in for localizations.
var             PlayerReplicationInfo Pauser;          // If paused, name of person pausing the game.
var		LevelSummary Summary;
var           string VisibleGroups;			// List of the group names which were checked when the level was last saved
var transient string SelectedGroups;		// A list of selected groups in the group browser (only used in editor)
//-----------------------------------------------------------------------------
// Flags affecting the level.

// RWS CHANGE: Merged new level summary vars from 2110
var(LevelSummary) bool HideFromMenus;
var() bool           bLonePlayer;     // No multiplayer coordination, i.e. for entranceways.
var bool             bBegunPlay;      // Whether gameplay has begun.
var bool             bPlayersOnly;    // Only update players.
var bool             bHighDetailMode; // Client high-detail mode.
var bool			 bDropDetail;	  // frame rate is below DesiredFrameRate, so drop high detail actors
var bool			 bAggressiveLOD;  // frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool             bStartup;        // Starting gameplay.
var	bool			 bPathsRebuilt;	  // True if path network is valid
var transient const bool		 bPhysicsVolumesInitialized;	// true if physicsvolume list initialized
// RWS CHANGE: Merged new level change flag from UT2003
var	bool			 bLevelChange;

//-----------------------------------------------------------------------------
// Legend - used for saving the viewport camera positions
var() vector  CameraLocationDynamic;
var() vector  CameraLocationTop;
var() vector  CameraLocationFront;
var() vector  CameraLocationSide;
var() rotator CameraRotationDynamic;

//-----------------------------------------------------------------------------
// Audio properties.

var(Audio) string	Song;			// Filename of the streaming song.
var(Audio) float	PlayerDoppler;	// Player doppler shift, 0=none, 1=full.

//-----------------------------------------------------------------------------
// Miscellaneous information.

var() float Brightness;
// RWS CHANGE: New level summary info from 2110 moves this up, see above
//var() texture Screenshot;
var texture DefaultTexture;
var texture WireframeTexture;
var texture WhiteSquareTexture;
var texture LargeVertex;
var int HubStackLevel;
var transient enum ELevelAction
{
	LEVACT_None,
	LEVACT_Loading,
	LEVACT_Saving,
	LEVACT_Connecting,
	LEVACT_Precaching,
	LEVACT_EasySaving,	// RWS CHANGE: added
	LEVACT_AutoSaving,	// RWS CHANGE: added
	LEVACT_ForcedSaving,// RWS CHANGE: added
	LEVACT_Restarting,	// RWS CHANGE: added
	LEVACT_Quitting		// RWS CHANGE: added
	} LevelAction;

//-----------------------------------------------------------------------------
// Renderer Management.
var() bool bNeverPrecache;

//-----------------------------------------------------------------------------
// Networking.

var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string MinNetVersion; // Min engine version that is net compatible.

//-----------------------------------------------------------------------------
// Gameplay rules

var() string DefaultGameType;
var GameInfo Game;

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var const NavigationPoint NavigationPointList;
var const Controller ControllerList;
var PhysicsVolume PhysicsVolumeList;

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//-----------------------------------------------------------------------------
// Global object recycling pool.
var transient ObjectPool	ObjectPool;

//-----------------------------------------------------------------------------
// Steam Achievements (Kamek added 4/13)
// Valid only in Entry.fuk

var private AchievementManager AchievementManager;
var private bool bStatsValid;
//var private const native Steam SteamHelper;

//-----------------------------------------------------------------------------
// Functions.

//
// Return the URL of this level on the local machine.
//
native simulated function string GetLocalURL();

//
// Demo build flag
//
native simulated final function bool IsDemoBuild();  // True if this is a demo build.


//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
native simulated function string GetAddressURL();

// Gets the total number of milliseconds since January 1, 2000 based on a date passed in.
// Float cannot properly handle the total result, so the result is split up as a vector:
//	X = total days
//	Y = seconds
//	Z = milliseconds
native final function vector GetMillisecondsFrom(int InYear, int InMonth, int InDay, int InMinute, int InSecond, int InMillisecond);

// Gets the total number of milliseconds elapsed since January 1, 2000.
// See above for return format.
final function vector GetMillisecondsNow()
{
	return GetMillisecondsFrom(Year, Month, Day, Minute, Second, Millisecond);
}

//
// Jump the server to a new level.
//
event ServerTravel( string URL, bool bItems )
{
	if( NextURL=="" )
	{
		// RWS CHANGE: Merged new level change flag from UT2003
		bLevelChange = true;
		bNextItems          = bItems;
		NextURL             = URL;
		if( Game!=None )
			Game.ProcessServerTravel( URL, bItems );
		else
			NextSwitchCountdown = 0;
	}
}

//
// ensure the DefaultPhysicsVolume class is loaded.
//
function ThisIsNeverExecuted()
{
	local DefaultPhysicsVolume P;
	P = None;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	// perform garbage collection of objects (not done during gameplay)
	ConsoleCommand("OBJ GARBAGE");
	Super.Reset();
}

simulated function AddPhysicsVolume(PhysicsVolume NewPhysicsVolume)
{
	local PhysicsVolume V;

	for ( V=PhysicsVolumeList; V!=None; V=V.NextPhysicsVolume )
		if ( V == NewPhysicsVolume )
			return;

	NewPhysicsVolume.NextPhysicsVolume = PhysicsVolumeList;
	PhysicsVolumeList = NewPhysicsVolume;
}

simulated function RemovePhysicsVolume(PhysicsVolume DeletedPhysicsVolume)
{
	local PhysicsVolume V,Prev;

	for ( V=PhysicsVolumeList; V!=None; V=V.NextPhysicsVolume )
	{
		if ( V == DeletedPhysicsVolume )
		{
			if ( Prev == None )
				PhysicsVolumeList = V.NextPhysicsVolume;
			else
				Prev.NextPhysicsVolume = V.NextPhysicsVolume;
			return;
		}
		Prev = V;
	}
}
//-----------------------------------------------------------------------------
// Network replication.

replication
{
	reliable if( bNetDirty && Role==ROLE_Authority )
		Pauser, TimeDilation;
}

simulated event PreBeginPlay()
{
	// Create the object pool.
	Super.PreBeginPlay();

	ObjectPool = new(xLevel) class'ObjectPool';
}

// ============================================================================
// Stats and Achievements

// Achievement Manager placed in Entry will call this on the LevelInfo.
// Anything placed in Entry stays in memory until the game quits, so we'll have
// a valid achievement manager all game.

// Everything here is considered final and cannot be screwed with by subclasses
// (not that you can really subclass LevelInfo anyway)
// ============================================================================
final function RegisterAchievementManager(AchievementManager this)
{
	if (AchievementManager == None) {
		AchievementManager = this;
	}
	else
		warn(self@"attempted to register another achievement manager!");
}

// Get Achievement Manager.
final function AchievementManager GetAchievementManager()
{
	if (AchievementManager == None)
		return None;
	else
		return AchievementManager;
}

// Attempt to unlock an achievement.
final function bool EvaluateAchievement(PlayerController Achiever, name AchievementName, optional bool bDisplayInConsole)
{
	if (AchievementManager == None)
	{
		warn ("Tried to call EvaluateAchievement with no AchievementManager!!!");
		return false;
	}
	else if (AchievementManager.EvaluateAchievement(Achiever, AchievementName, bDisplayInConsole))
	{
		if (IsSteamBuild())
			SteamUnlockAchievement(string(AchievementName));
		else
			AchievementManager.UnlockAchievement(AchievementName);
			
		return true;
	}
	else
		return false;
}

// Locks an achievement (for debugging)
final function bool LockAchievement(name AchievementName)
{
	if (AchievementManager == None)
	{
		warn ("Tried to call EvaluateAchievement with no AchievementManager!!!");
		return false;
	}
	else
	{
		if (IsSteamBuild())
			SteamLockAchievement(string(AchievementName));
		else
			AchievementManager.LockAchievement(AchievementName);
			
		return true;
	}
}

// Requests initial download of stats and achievements from Steam.
// Already handled by native code, so there should be no need to call this ever
final function RequestStats()
{
	if (AchievementManager != None && !bStatsValid)
	{
		// If not a steam build, just say the stats are ready already -- they're saved locally
		if (!IsSteamBuild())		
			SteamStatsReady();
		else
		{
			SteamRequestStats();
			
			// Steam callbacks broken -- just consider the stats to be valid now
			//SteamStatsReady();
			// Steam callbacks FIXED -- no need for this hack anymore.
		}
	}
	else
		warn("TRIED TO DOWNLOAD STEAM ACHIEVEMENTS WHEN NOT READY!!!");
}

// Called by Steam when the download is complete.
final event SteamStatsReady()
{
	//log("SteamStatsReady called");
	if (AchievementManager == None)
		warn("TRIED TO DOWNLOAD STEAM ACHIEVEMENTS WITH NO ACHIEVEMENT MANAGER!!!");
	else // Let the ACM know
	{
		bStatsValid = true;
		AchievementManager.StatsReady();
	}
}

// Called by Achievement Manager to request a particular achievement status
final function bool RequestAchievementStatus(name AchievementName)
{
	if (!bStatsValid)
		warn("TRIED TO GET ACHIEVEMENT STATUS WITH INVALID STATS!!!");
	else if (IsSteamBuild())
		return SteamGetAchievement(string(AchievementName));
	else
		return AchievementManager.GetAchievement(AchievementName);
}

// Called by AchievementManager to request the value of a given stat (int)
final function int RequestSteamStatInt(name StatName)
{
	if (!bStatsValid)
		warn("TRIED TO GET STAT VALUE WITH INVALID STATS!!!");
	else if (IsSteamBuild())
		return SteamGetStatInt(string(StatName));
	else
		return AchievementManager.GetStatInt(StatName);
}

// Called by AchievementManager to request the value of a given stat (float)
final function int RequestSteamStatFloat(name StatName)
{
	if (!bStatsValid)
		warn("TRIED TO GET STAT VALUE WITH INVALID STATS!!!");
	else if (IsSteamBuild())
		return SteamGetStatFloat(string(StatName));
	else
		return AchievementManager.GetStatFloat(StatName);
}

// Called by AchievementManager to update a given stat (int)
final function RequestUpdateStatInt(name StatName, int NewValue)
{
	if (!bStatsValid)
		warn("TRIED TO UPDATE STATS WITH INVALID STATS!!!");
	else if (IsSteamBuild())
		SteamSetStatInt(string(StatName), NewValue);
	else
		AchievementManager.SetStatInt(StatName, NewValue);
}

// Called by AchievementManager to update a given stat (float)
final function RequestUpdateStatFloat(name StatName, float NewValue)
{
	if (!bStatsValid)
		warn("TRIED TO UPDATE STATS WITH INVALID STATS!!!");
	else if (IsSteamBuild())
		SteamSetStatFloat(string(StatName), NewValue);
	else
		AchievementManager.SetStatFloat(StatName, NewValue);
}

// ============================================================================
// Native Calls
// ============================================================================
// Returns true if a Steam build; false if not.
final native function bool IsSteamBuild();

// Returns true if running on Steam Deck; false if not.
final native function bool IsSteamDeck();

// Returns true if build is compatible with Workshop (Steam), false if not (GOG Galaxy, DRM-free)
final native function bool IsWorkshopBuild();

// Calls Steam to unlock the named achievement.
final private native function SteamUnlockAchievement(string AchievementName);
/*
final private function SteamUnlockAchievement(string AchievementName)
{
	// STUB
	log(self@"unlocking achievement"@AchievementName,'Debug');
	// Temporary use until native Steam integration available.
	AchievementManager.SaveConfig();
}
*/

// For debugging purposes only
final private native function SteamLockAchievement(string AchievementName);

// Called to get the unlocked status of an achievement.
final private native function bool SteamGetAchievement(string AchievementName);
/*
final private function bool SteamGetAchievement(string AchievementName)
{
	// STUB
	log(self@"requesting achievement status"@AchievementName);
	return False;
}
*/

// Called to get a particular stat (float)
final private native function float SteamGetStatFloat(string StatName);
/*
final private function float SteamGetStatFloat(string StatName)
{
	// STUB
	log(self@"requesting float stat info of"@StatName);
	return 0.000000;
}
*/

// Called to get a particular stat (int)
final private native function int SteamGetStatInt(string StatName);
/*
final private function int SteamGetStatInt(string StatName)
{
	// STUB
	log(self@"requesting int stat info of"@StatName);
	return 0;
}
*/

// Calls Steam to start the initial download of stats and achievements.
// Once complete, this should call SteamStatsReady() in the Uscript above.
final native function SteamRequestStats();
/*
final function SteamRequestStats()
{
	// STUB
	log(self@"requesting stats from Steam",'Debug');
}
*/

// Called to set a particular stat (int)
final private native function SteamSetStatInt(string StatName, int NewValue);
/*
final private function SteamSetStatInt(string StatName, int NewValue)
{
	// STUB
	log(self@"setting Steam stat"@StatName@"to"@NewValue,'Debug');
	// Temporary use until native Steam integration available.
	AchievementManager.SaveConfig();
}
*/

// Called to set a particular stat (float)
final private native function SteamSetStatFloat(string StatName, float NewValue);
/*
final private function SteamSetStatFloat(string StatName, float NewValue)
{
	// STUB
	log(self@"setting Steam stat"@StatName@"to"@NewValue,'Debug');
	// Temporary use until native Steam integration available.
	AchievementManager.SaveConfig();
}
*/

// Called to reset all stats (and optionally achievements)
// For testing only, should be stubbed out in release build.
final native function SteamResetStats(bool bAchievementsToo);
//final function SteamResetStats(bool bAchievementsToo); // STUB

// Called to display achievement progress indicator (IndicateAchievementProgress)
final native function SteamIndicateAchievementProgress(string AchievementName, int CurProgress, int MaxProgress);
// final function SteamIndicateAchievementProgress(string AchievementName, int CurProgress, int MaxProgress); // STUB

// Returns a string describing what Workshop is doing
final native function string SteamGetWorkshopStatus();

// Purge unsubscribed Steam Workshop files
final native function SteamPurgeWorkshop();

// Detects ownership of DLC title.
final native function bool SteamOwnsDLC(int appID);

// Detects ownership of game.
final native function bool SteamOwnsGame(int appID);

// Displays DLC page.
final native function SteamViewStorePage(int appID);

defaultproperties
{
	 bAlwaysRelevant=true
     TimeDilation=+00001.000000
	 Brightness=1
     Title="Untitled"
     Author="Anonymous"
     bHiddenEd=True
	 DefaultTexture=DefaultTexture
	 WireframeTexture=WireframeTexture
	 WhiteSquareTexture=WhiteSquareTexture
	 LargeVertex=LargeVertex
	 HubStackLevel=0
	 bHighDetailMode=True
	 PlayerDoppler=0
	 bWorldGeometry=true
	 VisibleGroups="None"
     IdealPlayerCountMin=6
     IdealPlayerCountMax=10
}
