///////////////////////////////////////////////////////////////////////////////
// FPSGameInfo.
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Common game stuff for a first person shooter.
//
//	History:
//		07/28/02 MJR	Added debug stuff.
//
///////////////////////////////////////////////////////////////////////////////
class FPSGameInfo extends GameInfo
	config
	native;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

enum ETravelItems
	{
	TRAV_WithItems,					// default mode
	TRAV_WithoutItems					// only for special cases, like when game is over
	};

const SPECIAL_RESTORATION_HANDLE = -1;

var int			LivePawns;				// Total number of pawns alive in the level, in stasis or not
var int			StasisPawns;			// Total number of pawns currently in stasis
var() float		MaxStasisPercent;		// Maximum percentage in stasis (StasisPawns/LivePawns)

// Whether this is a demo version of the game
var() bool		bIsDemo;

// Whether the GameInfo is valid.  Defaults to true but complex GameInfo's
// should default to false and set it true when they become valid.
var bool		bIsValid;

// List of ScriptedControllers that want to be informed when GameInfo becomes valid.
var array<ScriptedTrigger>	WaitingList;

// Dynamic array of home nodes that represent the starts of linked lists of home nodes
// all with the same tag. Each home node in this array is the start of a linked lists of
// home nodes. Each home node in that particular list has the same tag as all the others like
// it in the current level.
// These are used to speed up the random walks bystanders take

struct HomeListInfo
{
	var HomeNode node;	// Start of looped list
	var int Length;		// Length of that list
};
var array<HomeListInfo> HomeNodeLists;

// Single list of pathnodes in level, used for random pawn walking.
struct PathListInfo
{
	var PathNode node;	// Start of looped list
	var int Length;		// Length of that list
};
var PathListInfo PathNodeList;

// Info about currently playing songs.
struct SongInfo
	{
	var int RealHandle;
	var actor Actor;
	var string Song;
	var float Volume;
	var float Radius;
	var float Pitch;
	var float VolumeOverride;
	var bool bLegacy;
	};
var SongInfo SongInfos[9];

var localized string UnknownDiffStr;

// Debug stuff
var float		DebugTextX;
var float		DebugTextY;
var float		DebugTextHeight;
var float		DebugTextIndent;

native function BuildHomeNodeLists();
native function BuildPathNodeLists();
native static function string GetGameMap( string GameCode, string PrevMapName, int Dir );


///////////////////////////////////////////////////////////////////////////////
// Startup stuff
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Link together all the home nodes of the same tag in this level and
	// store a link to the start of these linked lists.
	//Log("!TimeBeg!BuildHomeNodeLists");
	BuildHomeNodeLists();
	BuildPathNodeLists();
	//Log("!TimeEnd!BuildHomeNodeLists");
	}

///////////////////////////////////////////////////////////////////////////////
// Called after loading a saved game
///////////////////////////////////////////////////////////////////////////////
function PostLoadGame()
	{
	Super.PostLoadGame();

	// Music needs to be restarted after a reboot
	RestoreMusicAfterAudioReboot();
	}

///////////////////////////////////////////////////////////////////////////////
// Outside, we're not starting up. This is only to return true when we're
// inside the state of StartUp, where we prep pawns, the apocalypse, day block
// levels, etc.
///////////////////////////////////////////////////////////////////////////////
function bool StartingUp()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Send player to specified URL.
//
// This is our own version of SendPlayer() except it allows additional
// travel options to be specified.
//
// This safely handles the case of the player not having a pawn (the engine
// version crashes to let you know the pawn is missing).
//
// This also cleans up various things that should be done prior to travel.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerEx(PlayerController player, String URL, ETravelType TravelType, ETravelItems TravelItems)
	{
	local bool bTravelItems;

	// Must cleanup music before going to new level
	StopAllMusicExt(0.0);

	// If the URL doesn't have a "#" in it then append one here.  This fixes
	// the problem where the engine uses the # prefix from the last URL if
	// the current URL doesn't have one.
	if (InStr(URL, "#") < 0)
		URL = URL $ "#";

	// It's possible that the player doesn't have a pawn because he's dead,
	// in which case we use an alternate way to reach the specified URL.
	// The alternate method doesn't necessarily preserve the player's inventory
	// or other travel vars -- extended classes should be well aware of this.
	if (player.Pawn != None)
		{
		// Start the travel process
		if (TravelItems == TRAV_WithItems)
			bTravelItems = true;
		player.ClientTravel(URL, TRAVEL_Relative, bTravelItems);
		}
	else
		ConsoleCommand("OPEN" @ URL);
	}

///////////////////////////////////////////////////////////////////////////////
// This is called to indicate the GameInfo has become valid.
///////////////////////////////////////////////////////////////////////////////
function GameInfoIsNowValid()
	{
	local int i;

	bIsValid = true;

	// Tell everyone on the list that gameinfo is now valid
	for (i = 0; i < WaitingList.Length; i++)
		{
		if (WaitingList[i] != None && !WaitingList[i].bDeleteMe)
			WaitingList[i].GameInfoIsNowValid();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Add to a list of of items that are waiting for the gameinfo to
// become valid.  When it does become valid, these items are notified.
///////////////////////////////////////////////////////////////////////////////
function AddToWaitingList(ScriptedTrigger script)
	{
	local int i;
	i = WaitingList.Length;
	WaitingList.insert(i, 1);
	WaitingList[i] = script;
	}

///////////////////////////////////////////////////////////////////////////////
// Increment the total number of live pawns in the level
///////////////////////////////////////////////////////////////////////////////
function AddPawn(Pawn AddMe)
{
	LivePawns++;
	//log(self$" added me "$AddMe$" count now "$LivePawns);
}

///////////////////////////////////////////////////////////////////////////////
// Decrement the total number of live pawns in the level
///////////////////////////////////////////////////////////////////////////////
function RemovePawn(Pawn RemoveMe)
{
	LivePawns--;
	//log(self$" removed me "$RemoveMe$" count now "$LivePawns);
	if(LivePawns < 0)
		log(self$" ERROR: negative pawn num hit");
}

///////////////////////////////////////////////////////////////////////////////
// New pawn goes into stasis
///////////////////////////////////////////////////////////////////////////////
function PawnInStasis(Pawn CheckP)
{
	local float Pct;
	local FPSPawn remp;
	local int pickhim, i;

	return;

	// New guy in stasis
	StasisPawns++;

	// Check if there's too many in stasis already
	Pct=float(StasisPawns)/LivePawns;

	//log(self$" pct "$Pct$" add stasis num "$StasisPawns);

	// We're over our limit of who's allowed to be in stasis, so 
	// bring someone else out
	if(Pct > MaxStasisPercent)
	{
		pickhim = Rand(StasisPawns);

		//log(self$" bring someone out of stasis");
		log(self$" guy to bring out of stasis "$pickhim$" and putting him in stasis "$CheckP);

		// Go through all the pawns and count the stasis pawns till you get to the one you want
		ForEach AllActors(class'FPSPawn',remp)
		{
			// if in stasis mode, the randomly decide to remove him
			if(remp.Controller.bStasis)
			{
				if(i == pickhim)
				// We've found the guy to bring out, so wake him up and set him
				// moving for a while again
				// This may well be the guy we just sent into stasis, but that's okay too
				{
					//log(self$"found pickhim "$pickhim);
					FPSController(remp.Controller).ReviveFromStasis();
					return;
				}
				// count this guy here, we started at 0
				i++;
			}
		}
	}
//	log(self$" done with PawnInStasis");
}

///////////////////////////////////////////////////////////////////////////////
// New pawn comes out of stasis
///////////////////////////////////////////////////////////////////////////////
function PawnOutOfStasis(Pawn CheckP)
{
	return;
	// This guy is coming out of stasis
	StasisPawns--;

	if(StasisPawns < 0)
		log(self$" ERROR: negative stasis pawn num hit in PawnOutOfStasis");
	//log(self$" remove stasis num "$StasisPawns);
}

///////////////////////////////////////////////////////////////////////////////
// Given a tag, return the start of a home node list
///////////////////////////////////////////////////////////////////////////////
function FindHomeListInfo(name UseTag, out HomeListInfo returninfo)
{
	local int i;

	for(i=0; (i < HomeNodeLists.Length); i++)
	{
		if(HomeNodeLists[i].node.Tag == UseTag)
		{
			returninfo = HomeNodeLists[i];
			return;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Return the start of a path node list
///////////////////////////////////////////////////////////////////////////////
function FindPathListInfo(out PathListInfo returninfo)
{
	returninfo = PathNodeList;
}

///////////////////////////////////////////////////////////////////////////////
// Get the splat detail.. longer lasting splats, the higher the number
///////////////////////////////////////////////////////////////////////////////
function int GetSplatDetail()
{
	// STUB--defined in p2gameinfo
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// Modifies lifetime based on fluid life
///////////////////////////////////////////////////////////////////////////////
function float ModifyByFluidDetail(float startnum)
{
	// STUB -- filled out in P2GameInfo
	return startnum;
}

///////////////////////////////////////////////////////////////////////////////
// All music should be controlled through these functions instead of the
// similar functions in the Actor class.  Calling those functions directly
// will lead to serious problems if the audio system is rebooted, which can
// happen at any time during the game if the player changes certain options
// in the audio menu.  Using these following functions instead will prevent
// those problems and will also restore any songs that were playing after
// the audio system is rebooted.
///////////////////////////////////////////////////////////////////////////////
function int PlayMusicExt(string Song, float FadeInTime, optional float VolumeOverride, optional bool bAllowPause)
	{
	local int i;
	local int handle;

	// Pass it on to the real function, preserving the info we need to restore song if necessary
	i = GetFreeSongInfo();
	SongInfos[i].RealHandle = PlayMusic(Song, FadeInTime, VolumeOverride, bAllowPause);
	if (SongInfos[i].RealHandle > 0)
		{
		SongInfos[i].Actor = None;
		SongInfos[i].Song = Song;
		handle = i + 1;
		}
//	Log("FPSGameInfo.PlayMusicExt(): Song="$Song$" FadeInTime="$FadeInTime$" RealHandle="$SongInfos[i].RealHandle$" returning handle="$handle);
	return handle;
	}

function int PlayMusicAttenuateExt(actor Actor, string Song, float FadeInTime, optional float Volume, optional float Radius, optional float Pitch, optional float VolumeOverride, optional bool bLegacy)
	{
	local int i;
	local int handle;

	if (Actor != None)
		{
		// Pass it on to the real function, preserving the info we need to restore song if necessary
		i = GetFreeSongInfo();
		SongInfos[i].RealHandle = Actor.PlayMusicAttenuate(Song, FadeInTime, Volume, Radius, Pitch, VolumeOverride,, bLegacy);
		if (SongInfos[i].RealHandle > 0)
			{
			SongInfos[i].Actor = Actor;
			SongInfos[i].Song = Song;
			SongInfos[i].Volume = Volume;
			SongInfos[i].Radius = Radius;
			SongInfos[i].Pitch = Pitch;
			SongInfos[i].VolumeOverride = VolumeOverride;
			SongInfos[i].bLegacy = bLegacy;
			handle = i + 1;
			}
		}
	else
		Warn("Didn't specify Actor");

//	Log("FPSGameInfo.PlayMusicAttenuateExt(): Actor="$Actor$" Song="$Song$" FadeInTime="$FadeInTime$" Volume="$Volume$" Radius="$Radius$" Pitch="$Pitch$" RealHandle="$SongInfos[i].RealHandle$" returning handle="$handle);
	return handle;
	}

function RestoreMusicAfterAudioReboot()
	{
	local int i;

	for (i = 0; i < ArrayCount(SongInfos); i++)
		{
		if (SongInfos[i].RealHandle > 0 || SongInfos[i].RealHandle == SPECIAL_RESTORATION_HANDLE)
			{
			if (SongInfos[i].Actor == None)
				SongInfos[i].RealHandle = PlayMusic(SongInfos[i].Song, 0.1);
			else
				SongInfos[i].RealHandle = SongInfos[i].Actor.PlayMusicAttenuate(SongInfos[i].Song, 0.1, SongInfos[i].Volume, SongInfos[i].Radius, SongInfos[i].Pitch, SongInfos[i].VolumeOverride,, SongInfos[i].bLegacy);

			// If the global music volume is set to 0 then no music will be played and the
			// handles will be 0.  But we don't want to give up restoring the music the next
			// time this function is called, so we set the handle to a special value and if
			// it's that value the next time then we'll try to restore it.
			if (SongInfos[i].RealHandle == 0)
				SongInfos[i].RealHandle = SPECIAL_RESTORATION_HANDLE;
			}
		}
	}

function StopMusicExt(int SongHandle, float FadeOutTime )
	{
	SongHandle--;
	Super.StopMusic(SongInfos[SongHandle].RealHandle, FadeOutTime);
	SongInfos[SongHandle].RealHandle = 0;
//	Log("FPSGameInfo.StopAllMusicExt("$SongHandle$")");
	}

function StopAllMusicExt(float FadeOutTime)
	{
	local int i;

	StopAllMusic(FadeOutTime);
	for (i = 0; i < ArrayCount(SongInfos); i++)
		SongInfos[i].RealHandle = 0;
//	Log("FPSGameInfo.StopAllMusicExt()");
	}

function int GetFreeSongInfo()
	{
	local int i;

	for (i = 1; i < ArrayCount(SongInfos); i++)
		{
		if (SongInfos[i].RealHandle == 0)
			return i;
		}
	return -1;
	}

///////////////////////////////////////////////////////////////////////////////
// Display debug info
///////////////////////////////////////////////////////////////////////////////
event RenderOverlays(Canvas Canvas)
	{
	local string str;
	local int i, j;
	local int count;

	Canvas.Font = Canvas.SmallFont;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(255,0,0);
	Canvas.StrLen("TEST", DebugTextIndent, DebugTextHeight);
	DebugTextX = 4;
	DebugTextY = 4 + DebugTextHeight;
	
	DrawTextDebug(canvas, "FPSGameInfo (class = "$String(Class)$")");
	DrawTextDebug(canvas, "StasisPawns/LivePawns: "$StasisPawns$"/"$LivePawns$" = "$StasisPawns/LivePawns$"%", 1);
	DrawTextDebug(canvas, "MaxStasisPercent: "$MaxStasisPercent$"%", 1);
	DrawTextDebug(canvas, "");
	}

///////////////////////////////////////////////////////////////////////////////
// Draw text for debugging
///////////////////////////////////////////////////////////////////////////////
function DrawTextDebug(Canvas Canvas, String str, optional int indent)
	{
	Canvas.SetPos(DebugTextX + (indent * DebugTextIndent), DebugTextY);
	Canvas.DrawText(str, false);
	DebugTextY += DebugTextHeight;
	}

///////////////////////////////////////////////////////////////////////////////
// Get the phrase for our difficulty level (override in p2gameinfosingle)
///////////////////////////////////////////////////////////////////////////////
function string GetDiffName(int DiffIndex)
{
	return UnknownDiffStr;
}

///////////////////////////////////////////////////////////////////////////////
// Set the specified option in the URL.
// If the option already exists in the URL, it is replaced with the new value.
// Options are the of the form "?name=value".
///////////////////////////////////////////////////////////////////////////////
function string SetURLOption(string URL, string Name, string Value)
{
	local string NewStr;
	local int i;

	// Remove the option in case it already exists
	URL = RemoveURLOption(URL, Name);

	// Construct the new "?name=value" string
	NewStr = "?"$Name$"="$Value;

	// If the "#" exists then insert the new option before it, otherwise
	// just add the new option to the end of the url
	i = InStr(URL, "#");
	if (i >= 0)
		URL = Left(URL, i) $ NewStr $ Right(URL, Len(URL) - i);
	else
		URL = URL $ NewStr;

	return URL;
}

///////////////////////////////////////////////////////////////////////////////
// Remove the specified option from the URL, ignoring case.
// If the option doesn't exist, the URL is returned unchanged.
///////////////////////////////////////////////////////////////////////////////
function string RemoveURLOption(string URL, string Name)
{
	local int start;
	local int end1;
	local int end2;
	local string tmp;

	// Check if name is already an option in the url
	start = InStr(Caps(URL), "?"$Caps(Name));
	if (start >= 0)
	{
		// Remove the "?name=value" from the url.  We do this by looking for the
		// next "?" or the "#", either of which mark the end of the string we
		// want to remove.  If neither of those are found then it means the
		// string goes to the end of the url.
		tmp = Right(URL, (Len(URL)-start)-1);
		end1 = InStr(tmp, "?");
		end2 = InStr(tmp, "#");
		if (end1 < 0 && end2 < 0)
		{
			URL = Left(URL, start);
		}
		else
		{
			if (end2 < end1 && end2 >= 0)
				end1 = end2;
			URL = Left(URL, start) $ Right(URL, Len(URL) - start - end1 - 1);
		}
	}

	return URL;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	GameMessageClass=class'GameMessagePlus'
	DeathMessageClass=class'LocalMessagePlus'
	MaxStasisPercent=0.8
	bIsValid=true
	UnknownDiffStr = "Difficulty ?"
	bIsSingleplayer=true;
}
