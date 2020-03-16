///////////////////////////////////////////////////////////////////////////////
// MenuImageKeys.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The how-to-use-the-keys screen.
//
///////////////////////////////////////////////////////////////////////////////
class MenuImagekeys extends MenuImage;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var ShellMenuChoice		StartChoice;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();

	ItemAlign  = TA_Left;
	ItemFont = F_FancyL;

	StartChoice	= AddChoice(StartText,	"", ItemFont, ItemAlign);
	BackChoice = AddChoice(BackText,	"", ItemFont, ItemAlign, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Allows for use of enhanced mode
///////////////////////////////////////////////////////////////////////////////
function StartGame2(bool bEnhanced)
{
	local P2Player p2p;
	local P2GameInfoSingle usegame;

	usegame = GetGameSingle();
	p2p = usegame.GetPlayer();
	// Force sissy off on a new game
	p2p.UnSissy();
	P2RootWindow(Root).StartingGame();

	// Reset the game timer
	usegame.TheGameState.TimeElapsed = 0;
	usegame.TheGameState.TimeStart = usegame.Level.GetMillisecondsNow();

	// Stop any active SceneManager so player will have a pawn
	usegame.StopSceneManagers();

	usegame.PrepIniStartVals();
	usegame.TheGameState.bEGameStart = bEnhanced;
	usegame.bNoHolidays = ShellRootWindow(Root).bNoHolidays;
	usegame.SaveConfig();

	// Turn off night mode if holidays are off
	if (usegame.bNoHolidays)
		usegame.TheGameState.bNightMode = false;

	// Get the difficulty ready for this game state.
	usegame.SetupDifficultyOnce();

	// Get rid of any things in his inventory before a new game starts
	P2Pawn(p2p.pawn).DestroyAllInventory();
	usegame.TheGameState.HudArmorClass = None;
	p2p.MyPawn.Armor = 0;

	// Game doesn't actually start until player is sent to first day,
	// which *should* happen at the end of the intro sequence.
	usegame.TheGameState.bChangeDayPostTravel = true;
	usegame.TheGameState.NextDay = 0;

	// Force game to display "Saturday" when loading on weekends.
	if (ShellRootWindow(Root).DayToShowDuringLoad != 0)
	{
		usegame.bShowDayDuringLoad = True;
		usegame.DayToShowDuringLoad = ShellRootWindow(Root).DayToShowDuringLoad;
	}

	// Actually start the game with the first level
	//usegame.bQuitting = true;	// discard gamestate
	usegame.SendPlayerTo(p2p, ShellRootWindow(Root).StartGameURL$"?Mutator=?Workshop=0");
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;

				case StartChoice:
					StartGame2(ShellRootWindow(Root).bEnhancedMode);
					ShellRootWindow(Root).bLaunchedMultiplayer = false;
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	TextureImageName = "p2misc.Vital_Keys"

	aregButtons[0]=(X=560,Y=410,W=80,H=30)	// Using 640x480 locations to determine percentages.
	aregButtons[1]=(X=560,Y=440,W=80,H=30)	// Using 640x480 locations to determine percentages.
	}
