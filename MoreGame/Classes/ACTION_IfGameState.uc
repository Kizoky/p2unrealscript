///////////////////////////////////////////////////////////////////////////////
// ACTION_IfGameState.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Executes a section of actions only if the specified errand status is met.
//
//	History:
//		05/14/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_IfGameState extends P2ScriptedAction;

enum ETest
	{
	ET_FirstLevelOfGame,								// Check to see if this is the very first level of the game.
	ET_FirstLevelOfDay,									// Check to see if this is the first level of the day.
	ET_PlayerPickedNiceDude,							// DOES NOTHING (nice/evil dude selection scrapped)
	ET_CurrentDay_Number,								// Checks the current day (number - 1 = Monday, etc.)
	ET_ErrandCompleted_Name,							// Checks to see if an errand is completed (name)
	ET_CurrentDay_Name,									// Checks the current day (name)
	ET_ErrandActivated_Name,							// Checks to see if an errand is activated (name)
	ET_CopsWantPlayer,									// Checks to see if the player is wanted by the cops
	ET_Apocalypse,										// Checks to see if the apocalypse is running
	ET_JesusRun,										// Checks to see if the player is eligible for a Jesus rating (zero people, zombies, and animals killed)
	ET_LudicrousRun										// xPatch: Checks if the player is on the hardest ever Ludicrous difficulty
	};

var(Action) ETest Test;
var(Action) bool Is;
var(Action) int Number;
var(Action) String Name;

function ProceedToNextAction(ScriptedController C)
	{
	local bool bResult;
	local P2GameInfoSingle game;

	game = P2GameInfoSingle(C.Level.Game);
	if(game != None)
		{
		switch (Test)
			{
			case ET_FirstLevelOfGame:
				bResult = (game.TheGameState.bFirstLevelOfGame == Is);
				break;

			case ET_FirstLevelOfDay:
				bResult = (game.TheGameState.bFirstLevelOfDay == Is);
				break;

			case ET_PlayerPickedNiceDude:
				bResult = (game.TheGameState.bNiceDude == Is);
				break;

			case ET_CurrentDay_Number:
				bResult = ((game.GetCurrentDay() == Number-1) == Is);
				break;

			case ET_CurrentDay_Name:
				bResult = (game.IsDay(Name) == Is);
				break;

			case ET_ErrandCompleted_Name:
				bResult = (game.IsErrandCompleted(Name) == Is);
				break;

			case ET_ErrandActivated_Name:
				bResult = (game.IsErrandActivate(Name) == Is);
				break;

			case ET_CopsWantPlayer:
				bResult = ((game.TheGameState.CopsWantPlayer() > 0) == Is);
				break;

			case ET_Apocalypse:
				bResult = (game.TheGameState.bIsApocalypse == Is);
				break;
				
			case ET_JesusRun:
				bResult = (game.TheGameState.PeopleKilled + game.TheGameState.CatsKilled + game.TheGameState.ElephantsKilled + game.TheGameState.DogsKilled + game.TheGameState.ZombiesKilledOverall == 0) == Is;
				break;
				
			case ET_LudicrousRun:
				bResult = (game.InLudicrousDifficulty()) == Is;
				break;

			default:
				break;
			}
		}

	C.ActionNum += 1;
	if (!bResult)
		ProceedToSectionEnd(C);
	}

function bool StartsSection()
	{
	return true;
	}

function string GetActionString()
	{
	switch (Test)
		{
		case ET_FirstLevelOfGame:
			return ActionString@"check if bFirstLevelOfGame is "$Is;
			break;

		case ET_FirstLevelOfDay:
			return ActionString@"check if bFirstLevelOfDay is "$Is;
			break;

		case ET_PlayerPickedNiceDude:
			return ActionString@"check if bDudeIsGood is "$Is;
			break;

		case ET_CurrentDay_Number:
			return ActionString@"check if CurrentDay is "$Number;
			break;

		case ET_CurrentDay_Name:
			return ActionString@"check if CurrentDay is "$Name;
			break;

		case ET_ErrandCompleted_Name:
			return ActionString@"check if errand "$Name$" completed is "$Is;
			break;

		case ET_ErrandActivated_Name:
			return ActionString@"check if errand "$Name$" activated is "$Is;
			break;

		case ET_CopsWantPlayer:
			return ActionString@"check if cops wanting player is "$Is;
			break;

		case ET_Apocalypse:
			return ActionString@"check if bApocalypse is "$Is;
			break;
			
		case ET_JesusRun:
			return ActionString@"check if jesus run is "$Is;
			break;
			
		case ET_LudicrousRun:
			return ActionString@"check if Ludicrous run is "$Is;
			break;			

		default:
			break;
		}
	return ActionString@"unknown";
	}

defaultproperties
	{
	Is=true
	ActionString="If GameState: "
	bRequiresValidGameInfo=true
	}
