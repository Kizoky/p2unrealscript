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

	if (GetGameSingle().SeqTimeVerified()
		/*|| FPSPlayer(GetPlayerOwner()).bEnableDebugMenu*/)
	{
		EnhancedCheckbox = AddCheckbox(EnhancedText, EnhancedHelp, ItemFont);
		EnhancedCheckbox.SetValue(False);
	}

	StartChoice	= AddChoice(StartText,	"", ItemFont, TA_Left);
	if (GetLevel().IsSteamBuild())
		StartWorkshop =	AddChoice(StartWorkshopText,StartWorkshopHelp,	ItemFont,	TA_Left);
	else
		StartWorkshop =	AddChoice(StartCustomText,StartCustomHelp,	ItemFont,	TA_Left);
	BackChoice  = AddChoice(BackText,   "", ItemFont, TA_Left, true);
	
	LoadValues();
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local int val;
	local class<UMenuStartGameWindow> StartGameClass;
	local string StartURL;

	Super(ShellMenuCW).Notify(C, E);
	switch(E)
		{
		case DE_Change:
			switch (C)
				{
				case DifficultyCombo:
					DiffChanged(bUpdate);
					break;
				}
			break;
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				case StartChoice:
					StartURL = class'PLGameInfo'.Static.GetStartURL(true);
					if (GetGameSingle().HinallyOver())
					{
						StartGameURL = StartURL;
						StartGame2(EnhancedCheckbox.GetValue());
						ShellRootWindow(Root).bLaunchedMultiplayer = false;
					}
					// If they haven't finished the game yet, show 'em how to play
					else 
					{
						ShellRootWindow(Root).bEnhancedMode = EnhancedCheckbox.GetValue();
						ShellRootWindow(Root).StartGameURL = StartURL;
						GotoMenu(class'MenuImageKeys');
					}
					break;
				case StartWorkshop:
					// Launch specialized workshop menu
					if (Root.GetLevel().SteamGetWorkshopStatus() != "")
					{
						MessageBox(WaitforWorkshopTitle, WaitforWorkshopText, MB_OK, MR_OK, MR_OK);
					}
					else
					{
						StartGameClass = class<UMenuStartGameWindow>(DynamicLoadObject("Shell.WorkshopStartGameWindow", class'Class'));
						GotoWindow(Root.CreateWindow(StartGameClass, 100, 100, 200, 200, Self, True));
					}
					break;
				}
			break;
		}
	}

function bool SeekritCodeAllowed()
{
	return GetGameSingle().FinallyOver();
}

function SeekritKodeEntered()
{
	GotoMenu(class'PLMenuSeekrit');
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MenuHeight = 325
	TitleText	= "Select Difficulty"
}
