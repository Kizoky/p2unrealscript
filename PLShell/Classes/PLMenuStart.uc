///////////////////////////////////////////////////////////////////////////////
// PLMenuStart
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Start menu for Paradise Lost.
///////////////////////////////////////////////////////////////////////////////
class PLMenuStart extends MenuStart;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super(ShellMenuCW).CreateMenuContents();
	
	AddTitle(TitleText, F_FancyXL, TA_Left);
	
	ItemFont = F_FancyL;
	DifficultyCombo = AddComboBox(DifficultyText, DifficultyHelp, ItemFont);
	DifficultyCombo.List.MaxVisible = ArrayCount(P2GameInfoSingle(GetPlayerOwner().Level.Game).DifficultyNames);
	
	// Day Selection (unlockled after completing the game)
	if (DaySelectUnlocked())
	{
		DayCombo = AddComboBox(DayComboText, DayComboHelp, ItemFont);	
		DayCombo.EditBoxWidth = DayCombo.WinWidth * 0.50;
	}
	
	ItemFont = F_FancyM;	// Medium font for checkboxes
	ItemHeight = 25;		// and closer to each other
	
	// Enhanced game
	if (GetGameSingle().SeqTimeVerified()
		/*|| FPSPlayer(GetPlayerOwner()).bEnableDebugMenu*/)
	{
		EnhancedCheckbox = AddCheckbox(EnhancedText, EnhancedHelp, ItemFont);
		EnhancedCheckbox.SetValue(False);
	}
	
	// (DEBUG) Classic Game in Paradise Lost ??? Needs to be tested!
/*	if (FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
	{
		ClassicGameCheckbox = AddCheckbox(ClassicGameText, ClassicGameHelp, ItemFont);
		ClassicGameCheckbox.SetValue(False);
	}
*/	
	// Skip Intro 	
	SkipCheckbox = AddCheckbox(SkipText, SkipHelp, ItemFont);
	SkipCheckbox.SetValue(False);
	
	ItemFont = F_FancyL;	// Back to normal
	ItemHeight = 32;

	StartChoice	= AddChoice(StartText,	"", ItemFont, TA_Left);
	
	// Already present in the new Game Mode menu
/*	if (GetLevel().IsSteamBuild())
		StartWorkshop =	AddChoice(StartWorkshopText,StartWorkshopHelp,	ItemFont,	TA_Left);
	else
		StartWorkshop =	AddChoice(StartCustomText,StartCustomHelp,	ItemFont,	TA_Left);	*/

	BackChoice  = AddChoice(BackText,   "", ItemFont, TA_Left, true);
	
	LoadValues();
    
    // Lana edit - remove Ludicrous from PL for now
	if (!FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
    DifficultyCombo.List.RemoveItem(15);
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local int val;
	local class<UMenuStartGameWindow> StartGameClass;
	local string StartURL;
	local bool bUseSuper;
	
	bUseSuper = true;

	switch(E)
	{
		case DE_Click:
			switch (C)
				{
				case StartChoice:
					StartGameInfo = class'PLGameInfo';
					StartURL = StartGameInfo.Static.GetStartURL(true, SkipCheckbox.bChecked);
					if (GetGameSingle().FinallyOver() || DayCombo != None )
					{
						StartGameURL = StartURL;
						bShouldForceMap = False; 				// xPatch
						StartGame2(EnhancedCheckbox.GetValue());
						ShellRootWindow(Root).bLaunchedMultiplayer = false;
					}
					// If they haven't finished the game yet, show 'em how to play
					else 
					{
						ShellRootWindow(Root).bEnhancedMode = EnhancedCheckbox.GetValue();
						ShellRootWindow(Root).StartGameURL = StartURL;
						ShellRootWindow(Root).bNoEDWeapons = ClassicGameCheckbox.GetValue();	// xPatch
						ShellRootWindow(Root).bForceMap = False;								// xPatch
						SetDiff();
						
						if (PlatformIsSteamDeck())
                            GotoMenu(class'MenuImageKeys_SteamDeck');
						else
							GotoMenu(class'MenuImageKeys');
					}
					bUseSuper = false;
					break;
				}
			break;
	}
	if (bUseSuper)
		Super.Notify(C, E);
}

function bool SeekritCodeAllowed()
{
	return GetGameSingle().FinallyOver();
}

function SeekritKodeEntered()
{
	GotoMenu(class'PLMenuSeekrit');
}

// Gets unlocked if we have completed Paradise Lost or it is debug mode.
function bool DaySelectUnlocked()
{
	return (GetGameSingle().FinallyOver() || GetPlayerOwner().GetEntryLevel().GetAchievementManager().GetAchievement('PLFridayComplete')
			|| FPSPlayer(GetPlayerOwner()).bEnableDebugMenu);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	//MenuHeight = 325
	fCommonCtlArea=0.50		// Checkboxes a bit more to the left.
	
	TitleText	=  "Paradise Lost"
	
	Days[0] = "Monday"
	Days[1] = "Tuesday"
	Days[2] = "Wednesday"
	Days[3] = "Thursday"
	Days[4] = "Friday"
	Days[5] = "The Showdown"
	Days[6] = "The Apocalypse"
	MaxDays = 7
}
