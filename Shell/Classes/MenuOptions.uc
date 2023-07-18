///////////////////////////////////////////////////////////////////////////////
// MenuOptions.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The Options menu.
//
// History:
//	01/26/03 JMI	Added Credits option.
//	01/13/03 JMI	Added strHelp parameter to AddChoice() allowing us to pass
//					in many help strings that had been created but were not 
//					being used for standard menu choices.  Added generic 
//					RestoreHelp for menus sporting a Restore option.
//	01/12/03 JMI	Changed bDontAsk to bAsk.
//	01/12/03 JMI	Added intermediate menu introducing Wizard and Advanced.
//	12/18/02 JMI	Per Mike's suggestion, reversed the order of the menus.
//					The old Performance menu became the Advanced menu and the
//					Performance Wizard became the Performance menu.
//  12/17/02 NPF	Moved performance menu here from Video
//	06/29/02 MJR	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuOptions extends ShellMenuCW;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var ShellMenuChoice     AchChoice;
var localized string	AchText;
var localized string	AchHelp;

var ShellMenuChoice		CreditsChoice;
var localized string	CreditsText;
var localized string	CreditsHelp;

var ShellMenuChoice		CustomMapChoice;
var localized string	CustomMapText;
var localized string	CustomMapHelp;

var ShellMenuChoice		LockedChoice;
var localized string	LockedText;
var localized string	LockedHelp;

var ShellMenuChoice		UnlockedChoice;
var localized string	UnlockedText;
var localized string	UnlockedHelp;

var ShellMenuChoice		PurgeChoice;
var localized string	PurgeText;
var localized string	PurgeHelp;

const UNLOCK_ACHIEVEMENT = 'HestonworldEnding';
//const UNLOCK_ACHIEVEMENT = 'PissInFace';

var int					CustomMapWidth;
var int					CustomMapHeight;

var string RollCreditsURL;
var Texture BlackBackground;

// xPatch:
var ShellMenuChoice		xPatchChoice;
var localized string	xPatchText;
var localized string	xPatchHelp;

var ShellMenuChoice		ClassicChoice;
var localized string	ClassicText;
var localized string	ClassicHelp;

var color MyTextColor;
var color MyHighlightColor;
// End

///////////////////////////////////////////////////////////////////////////////
// Seekrit code allowed?
// Defaults to false, must override if your menu has a seekrit code.
///////////////////////////////////////////////////////////////////////////////
function bool SeekritCodeAllowed()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Seekrit code entered
// Triggered when the seekrit code is entered in full.
///////////////////////////////////////////////////////////////////////////////
function SeekritKodeEntered()
{
	GotoMenu(class'MenuHolidays');
}

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	
	AddTitle(OptionsText, TitleFont, TitleAlign);

	GameChoice			= AddChoice(GameOptionsText,	GameOptionsHelp,	ItemFont, ItemAlign);
	ClassicChoice		= AddChoice(ClassicText,		ClassicHelp,	ItemFont, ItemAlign);
	ControlsChoice		= AddChoice(ControlOptionsText, ControlOptionsHelp,	ItemFont, ItemAlign);
	VideoChoice			= AddChoice(VideoOptionsText,	VideoOptionsHelp,	ItemFont, ItemAlign);
	AudioChoice			= AddChoice(AudioOptionsText,	AudioOptionsHelp,	ItemFont, ItemAlign);
	PerformanceChoice	= AddChoice(PerformanceText,	PerformanceHelp,	ItemFont, ItemAlign);
	/*
	if(GetLevel().IsDemoBuild())
		{
		CustomMapChoice	= AddChoice(CustomMapText,		OptionUnavailableInDemoHelpText,ItemFont, ItemAlign);
		CustomMapChoice.bActive=false;
		}
	else
		CustomMapChoice	= AddChoice(CustomMapText,		CustomMapHelp,		ItemFont, ItemAlign);
	*/
		
	// Holiday stuff.
	if (GetPlayerOwner().GetEntryLevel().GetAchievementManager().GetAchievement(UNLOCK_ACHIEVEMENT) || FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
	{
		UnlockedChoice	= AddChoice(UnlockedText,		UnlockedHelp,		ItemFont, ItemAlign);
	}
	else
	{
		LockedChoice	= AddChoice(LockedText,			LockedHelp,			ItemFont, ItemAlign);
		//UnlockedChoice	= AddChoice(UnlockedText,		UnlockedHelp,		ItemFont, ItemAlign);
	}
	
	// xPatch: 
	if (!IsGameMenu() || GetGameSingle().xManager.bMoveAchevements)	// Show if we are in main menu or if the setting to move it here is on
		AchChoice		= AddChoice(AchText,	        AchHelp,        	ItemFont, ItemAlign);
		
	//	xPatchChoice         = AddChoice(xPatchText,	        xPatchHelp,        	ItemFont, ItemAlign);
	//if(!bShowedXPatch) {
	//	xPatchChoice.SetTextColor(MyTextColor);
	//	xPatchChoice.SetHighlightTextColor(MyHighlightColor);
	//}
	// End
	
	if (GetLevel().IsSteamBuild())
		PurgeChoice			= AddChoice(PurgeText,			PurgeHelp,			ItemFont, ItemAlign);
	if (!GetLevel().IsDemoBuild())
		CreditsChoice	= AddChoice(CreditsText,		CreditsHelp,		ItemFont, ItemAlign);
	BackChoice			= AddChoice(BackText, "", ItemFont, ItemAlign, true);
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
			if (C != None)
				switch (C)
					{
					case BackChoice:
						GoBack();
						break;
					case VideoChoice:
						GoToMenu(class'MenuVideo');
						break;
					case AudioChoice:
						GoToMenu(class'MenuAudio');
						break;
					case ControlsChoice:
						GoToMenu(class'MenuControls');
						break;
					case GameChoice:
						GoToMenu(class'MenuGameSettings');
						break;
					// xPatch:
					case AchChoice:		
					    GoToMenu(class'MenuAchievementList');
						break;
					case ClassicChoice:
						GotoWindow(Root.CreateWindow(Class'xPatchWindow', 0, 0, 1, 1, Self, True));
						break;	
					// End
					case PerformanceChoice:
						GoToMenu(class'MenuPerformanceAdvanced');
						break;
					case CreditsChoice:
						//GoToMenu(class'MenuImageCredits');
						RollCredits();
						break;
					case UnlockedChoice:
						GotoMenu(class'MenuHolidays');
						break;
					case PurgeChoice:
						GotoMenu(class'MenuPurgeWorkshopConfirmation');
						break;
					/*
					case CustomMapChoice:
						Root.ShowModal(Root.CreateWindow(class'ShellMapListFrame', 
										(Root.WinWidth - CustomMapWidth) /2, 
										(Root.WinHeight - CustomMapHeight) /2, 
										CustomMapWidth, CustomMapHeight, self));
					*/
						break;
					}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// RollCredits
// Sends player to the credits map.
///////////////////////////////////////////////////////////////////////////////
function RollCredits()
{
	local P2GameInfoSingle UseGame;
	UseGame = GetGameSingle();

	UseGame.ForcedLoadTex = BlackBackground;
						GoBack();
						HideMenu();
	//P2RootWindow(Root).StartingGame();
	usegame.StopSceneManagers();
	UseGame.SendPlayerTo(UseGame.GetPlayer(), RollCreditsURL);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     AchText="Achievements"
     AchHelp="View super-cool achievements."
     CreditsText="Credits"
     CustomMapText="Custom Map"
     CustomMapHelp="Opens a browser for playing user-made levels created with the editor."
     LockedText="??????????"
     LockedHelp="Beat 'A Week In Paradise' on Hestonworld difficulty to unlock this option!"
     UnlockedText="Holidays"
     UnlockedHelp="Turn on date-restricted holiday content at any time!"
     PurgeText="Purge Workshop"
     PurgeHelp="Permanently erase unsubscribed Workshop items."
     xPatchText="xPatch Settings"
	 xPatchHelp="You can change some pretty nice stuff there, yup."
	 ClassicText="Classic"
	 ClassicHelp="Customize Classic Mode or apply some of its features to the regular game."
     CustomMapWidth=350
     CustomMapHeight=250
     RollCreditsURL="Credits?Game=GameTypes.CreditsGameInfoP2?Mutator=?Workshop=0"
     BlackBackground=Texture'nathans.Inventory.blackbox64'
     MenuWidth=275.000000
     HintLines=4
     KeyAccepted=Sound'arcade.arcade_12'
     KodeAccepted=Sound'arcade.arcade_138'
     KodeWrong=Sound'arcade.arcade_126'
	 MyTextColor=(R=0,G=255,B=0,A=255)
	 MyHighlightColor=(R=160,G=255,B=160,A=255)
}
