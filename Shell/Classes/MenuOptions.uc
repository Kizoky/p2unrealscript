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
	if (GetPlayerOwner().GetEntryLevel().GetAchievementManager().GetAchievement(UNLOCK_ACHIEVEMENT))
	{
		UnlockedChoice	= AddChoice(UnlockedText,		UnlockedHelp,		ItemFont, ItemAlign);
	}
	else
	{
		LockedChoice	= AddChoice(LockedText,			LockedHelp,			ItemFont, ItemAlign);
	}
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
	MenuWidth=275	// 01/26/03 JMI Decreased menu size for better centered
						//				appearance.
	HintLines=4		// 01/26/03 JMI Increased hint lines b/c we made this menu
						//				even thinner.
						// 01/19/03 JMI Increased number of hint lines required
						//				b/c this is a particularly thin menu.

	CreditsText="Credits"
	CreditsHelp=""

	CustomMapText="Custom Map"
	CustomMapHelp="Opens a browser for playing user-made levels created with the editor."
	CustomMapWidth=350
	CustomMapHeight=250
	
	LockedText="??????????"
	LockedHelp="Beat 'A Week in Paradise' on Hestonworld difficulty to unlock this option!"
	
	UnlockedText="Holidays"
	UnlockedHelp="Turn on date-restricted holiday content at any time!"
	
	PurgeText="Purge Workshop"
	PurgeHelp="Permanently erase unsubscribed Workshop items."

	SeekritKode[9]=38
	SeekritKode[8]=38
	SeekritKode[7]=40
	SeekritKode[6]=40
	SeekritKode[5]=37
	SeekritKode[4]=39
	SeekritKode[3]=37
	SeekritKode[2]=39
	SeekritKode[1]=66
	SeekritKode[0]=65
	KeyAccepted=Sound'arcade.arcade_12'
	KodeAccepted=Sound'arcade.arcade_138'
	KodeWrong=Sound'arcade.arcade_126'	

	RollCreditsURL	= "Credits?Game=GameTypes.CreditsGameInfoP2?Mutator=?Workshop=0"
	BlackBackground=Texture'Nathans.Inventory.BlackBox64'
}
