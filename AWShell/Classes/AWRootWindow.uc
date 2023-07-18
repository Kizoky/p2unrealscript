///////////////////////////////////////////////////////////////////////////////
// AWRootWindow.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWRootWindow extends ShellRootWindow;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var class<MenuMain> MenuMainClass;
var class<MenuGame> MenuGameClass;
var class<MenuGameMulti> MenuGameMPClass;


///////////////////////////////////////////////////////////////////////////////
// Display stuff
// Gay--make sure to respecify this new menu here too, so we'll get
// copyright info in--too bad it wasn't set up like this before. 
///////////////////////////////////////////////////////////////////////////////
function PostRender(canvas Canvas)
	{
	local LevelInfo LI;

	// If we're in entry, hide the level with a background for multiplayer only
	LI = Root.GetLevel();

	Super.PostRender(Canvas);

	if(IsInState('MenuShowing'))
		{
		// Display info about installed game
		if (MyMenu.class == MenuMainClass)
			{
			MyFont.DrawTextEx(
				Canvas,
				Canvas.ClipX,
				VERSION_TEXT_X * Canvas.ClipX,
				VERSION_TEXT_Y * Canvas.ClipY,
				InstalledDescription$"-"$LI.EngineVersion,
				0, true, EJ_Left);

			MyFont.DrawTextEx(
				Canvas,
				Canvas.ClipX,
				COPYRIGHT_TEXT_X * Canvas.ClipX,
				COPYRIGHT_TEXT_Y * Canvas.ClipY,
				"Copyright 2003 RWS  All Rights Reserved",
				0, true, EJ_Right);
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to toggle between main and game menus (intended as a cheat)
///////////////////////////////////////////////////////////////////////////////
function MenuMode()
	{
	HideMenu();
	bGameMenu = !bGameMenu;
	// CRK: ShowMenu sets bGameMenu, so we can't call it
	//ShowMenu();
	if (bGameMenu)
		GotoState('NewGameMenuShowing');
	else
		GotoState('NewMainMenuShowing');
	}

///////////////////////////////////////////////////////////////////////////////
// Show menu
///////////////////////////////////////////////////////////////////////////////
function ShowMenu()
	{
	local string CurrentLevel;

	if(!bPrecache)
		bVirgin = false;

	// if we're in startup, show main menu, otherwise, show in-game menu
	CurrentLevel = ParseLevelName(Root.GetLevel().GetLocalURL());
	if(Right(CurrentLevel, 4) ~= ".fuk")
		CurrentLevel = Left(CurrentLevel, Len(CurrentLevel) - 4);
	if(CurrentLevel ~= GetStartupMap())
		bGameMenu = false;
	else
		bGameMenu = true;

	if (bGameMenu)
		GotoState('NewGameMenuShowing');
	else
		GotoState('NewMainMenuShowing');
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//////// Main Menu ////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NewMainMenuShowing extends MenuShowing
	{
	function BeginState()
		{
		bGameMenu = false;

		// If game was issued to a particular party then show the EULA once before we do anything else
		if ((!bShowedEULA) && (P2GameInfo(Root.GetLevel().Game) != None) && (P2GameInfo(Root.GetLevel().Game).GetIssuedTo() != ""))
			{
			bShowedEULA = true;
			CreateMenu(class'MenuEula');
			}
		else
			{
			CreateMenu(MenuMainClass);
			}

		// If the main menu was not started with the ESC key then don't pause.
		// If it was started with ESC then we're testing/debugging, in which
		// case it's convenient to pause.
		if (!bMainMenuShownViaESC)
			bDontPauseOrUnPause = true;

		Super.BeginState();

		bDontPauseOrUnPause = false;
		}
	}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//////// Game Menu ////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NewGameMenuShowing extends MenuShowing
	{
	function BeginState()
		{
		local String CurRes;

		bGameMenu = true;
		
		if(P2GameInfoSingle(Root.GetLevel().Game) != None)
			CreateMenu(MenuGameClass);
		else
			CreateMenu(MenuGameMPClass);

		Super.BeginState();
		}
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     MenuMainClass=Class'AWShell.AWMainMenu'
     MenuGameClass=Class'AWShell.AWMenuGame'
     MenuGameMPClass=Class'Shell.MenuGameMulti'
//     StartupMapName="AWStartup"
}
