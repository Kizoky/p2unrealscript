///////////////////////////////////////////////////////////////////////////////
// MenuTheyHateMe.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Menu to explain TheyHateMe difficulty. This is extra hard and has most
// people attacking the dude on sight.
//
///////////////////////////////////////////////////////////////////////////////
class AW7MenuNightmare extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string		HateTitleText;

var localized string		Msg[7];

var ShellMenuChoice			StartChoice;

var bool bUpdate;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local int i;
	local array<string> Msg2;

	// Dynamic arrays don't localize properly, so copy static array to dynamic array
	Msg2.insert(0, ArrayCount(Msg));
	for (i = 0; i < Msg2.length; i++)
		Msg2[i] = Msg[i];

	Super.CreateMenuContents();

	AddTitle(HateTitleText, F_FancyL, TA_Left);

	AddWrappedTextItem(Msg2, 200, F_FancyS, TA_Left);

	ItemFont = F_FancyL;
	ItemAlign = TA_Left;
	StartChoice	= AddChoice(StartText,	"", ItemFont, ItemAlign);
	BackChoice  = AddChoice(BackText,   "", ItemFont, ItemAlign, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Resume playing game
///////////////////////////////////////////////////////////////////////////////
function ResumeGame()
	{
	HideMenu();
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
// Allows for use of enhanced mode
///////////////////////////////////////////////////////////////////////////////
function StartGame2(bool bEnhanced)
{
	local P2Player p2p;
	local P2GameInfoSingle usegame;

	usegame = GetGameSingle();
	p2p = usegame.GetPlayer();
	P2RootWindow(Root).StartingGame();

	// Stop any active SceneManager so player will have a pawn
	usegame.StopSceneManagers();

	usegame.PrepIniStartVals();
	usegame.TheGameState.bEGameStart = bEnhanced;

	// Get the difficulty ready for this game state.
	usegame.SetupDifficultyOnce();

	// Get rid of any things in his inventory before a new game starts
	P2Pawn(p2p.pawn).DestroyAllInventory();

	// Game doesn't actually start until player is sent to first day,
	// which *should* happen at the end of the intro sequence.
	usegame.TheGameState.bChangeDayPostTravel = true;
	usegame.TheGameState.NextDay = 0;
	// Actually start the game with the first level
	//usegame.bQuitting = true;	// discard gamestate
	usegame.SendPlayerTo(p2p, ShellRootWindow(Root).StartGameURL);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	HateTitleText="POSTAL Mode"
	Msg(0)="You're about to play in a new difficulty level..."
	Msg(1)="In POSTAL Mode, not only do all bystanders get guns (like Hestonworld), "
	Msg(2)="but they also hate your guts (like They Hate Me)! "
	Msg(3)="As if that weren't bad enough, you are only allowed one save per level, "
	Msg(4)="and you can no longer store health powerups (except for crack)! "
	Msg(5)="Only the most hardcore POSTAL fanatics should attempt this difficulty."
	Msg(6)=""

	StartText="I'm ready for some pain!"
	BackText="I'm scared!"

	MenuWidth=600.000000
	MenuHeight=450.000000
	astrTextureDetailNames(0)="UltraLow"
	astrTextureDetailNames(1)="Low"
	astrTextureDetailNames(2)="Medium"
	astrTextureDetailNames(3)="High"
}
