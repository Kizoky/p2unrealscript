///////////////////////////////////////////////////////////////////////////////
// ACTION_SendPlayer.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This action lets you send the player somewhere.
//
//	History:
//		07/15/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_SendPlayer extends P2ScriptedAction;

enum EWhere
	{
	EW_StartFirstDay,				// Start the first day 
	EW_StartNextDay,				// Start the next day after current day
	EW_HomeAtEndOfDay,				// Home at the end of a day
	EW_Jail,						// Jail
	EW_Specified_URL,				// Wherever you want
	EW_MainMenu_Quit,				// Back to main menu
	};

var(Action) EWhere Where;			// Where to send him
var(Action) String URL;				// URL (if needed)
var(Action) bool bNice;				// Nice guy or not (if needed)
var(Action) bool bTakeHisInventory;	// Take all the dude's inventory before you send him
var(Action) bool bQuit;				// Whether this is a quit (versus a game over)
var(Action) Texture LoadScreen;		// If specified, displays this loading screen during the transition

function bool InitActionFor(ScriptedController C)
	{
	if (LoadScreen != None)
		P2GameInfoSingle(C.Level.Game).ForcedLoadTex = LoadScreen;
		
	switch(Where)
		{
		case EW_StartFirstDay:
			P2GameInfoSingle(C.Level.Game).SendPlayerToFirstDay(GetPlayer(C));
			break;
		
		case EW_StartNextDay:
			P2GameInfoSingle(C.Level.Game).SendPlayerToNextDay(GetPlayer(C));
			break;

		case EW_HomeAtEndOfDay:
			P2GameInfoSingle(C.Level.Game).AtPlayerHouse(GetPlayer(C), true);
			break;

		case EW_Jail:
			P2GameInfoSingle(C.Level.Game).SendPlayerToJail(GetPlayer(C));
			break;

		case EW_Specified_URL:
			// If we need to take his inventory, set that too.
			// Level designer must put pickups in to support this!
			P2GameInfoSingle(C.Level.Game).TheGameState.bTakePlayerInventory = bTakeHisInventory;
			// Actually send him to the new place
			P2GameInfoSingle(C.Level.Game).SendPlayerTo(GetPlayer(C), URL);
			break;

		case EW_MainMenu_Quit:
			P2GameInfoSingle(C.Level.Game).QuitGame();
			break;

		default:
			break;
		}
	return false;
	}

function string GetActionString()
	{
	switch(Where)
		{
		case EW_StartFirstDay:
			return ActionString@"to first day";
			break;
		
		case EW_StartNextDay:
			return ActionString@"to next day";
			break;

		case EW_HomeAtEndOfDay:
			return ActionString@"home at end of day";
			break;

		case EW_Jail:
			return ActionString@"to jail";
			break;

		case EW_Specified_URL:
			return ActionString@"to URL="$URL;
			break;

		case EW_MainMenu_Quit:
			return ActionString@"EW_MainMenu_Quit is obsolete!";

		default:
			break;
		}
	return ActionString@"unknown";
	}

defaultproperties
	{
	ActionString="Send player"
	bRequiresValidGameInfo=true
	}
