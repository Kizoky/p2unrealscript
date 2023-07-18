///////////////////////////////////////////////////////////////////////////////
// MenuGame.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The In-Game menu.
//
// History:
//	01/22/03 JMI	Save option now brings up Save menu.
//
//	01/13/03 JMI	Added Load option.
//
//	01/13/03 JMI	Added strHelp parameter to AddChoice() allowing us to pass
//					in many help strings that had been created but were not 
//					being used for standard menu choices.  Added generic 
//					RestoreHelp for menus sporting a Restore option.
//
//	09/04/02 MJR	Major rework for new system.
//
//  03/22/21 Man Chrzan: Added Quit to desktop, moved achievements. 
//
///////////////////////////////////////////////////////////////////////////////
// This class describes the game menu details and processes game menu events.
///////////////////////////////////////////////////////////////////////////////
class MenuGame extends BaseMenuBig;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var ShellMenuChoice		ResumeChoice;
var localized string	ResumeText;

var ShellMenuChoice		CheatsChoice;
var localized string	CheatsText;
var localized string	CheatsHelp;

var ShellMenuChoice		AchChoice;
var localized string	AchText;
var localized string	AchHelpText;

var ShellMenuChoice		LoadChoice;

var ShellMenuChoice		SaveChoice;
var localized string	SaveText;

var ShellMenuChoice		QuitChoice;
var localized string	QuitText;

var ShellMenuChoice		DesktopQuitChoice;
var localized string	DesktopQuitText;

var localized string	DisabledForCinematicHelpText;
var localized string	DisabledNowText;

const WarnedCheaterPath = "Postal2Game.P2GameInfoSingle bWarnedCheater";
var localized string CheatWarningTitle, CheatWarningText;

var ShellMenuChoice		DebugChoice;
var localized string	DebugText;
var localized string	DebugHelp;

// xPatch: In-Game Workshop Menu
var ShellMenuChoice		WorkshopChoice;
var localized string	WorkshopText, WorkshopHelpText;
var localized string 	WaitforWorkshopTitle, WaitforWorkshopText;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local String OptionsHelpText;
	local bool bOptionsActive;
	local String LoadHelpText;
	local String SaveHelpText;
	local bool bLoadActive;
	local bool bSaveActive;

	Super.CreateMenuContents();

	bOptionsActive = true;
	bLoadActive = true;
	bSaveActive = true;

	if (GetGameSingle().IsCinematic())
		{
		OptionsHelpText = DisabledForCinematicHelpText;
		bOptionsActive = false;
		LoadHelpText = DisabledForCinematicHelpText;
		SaveHelpText = DisabledForCinematicHelpText;
		bLoadActive = false;
		bSaveActive = false;
		}

	if (!GetGameSingle().IsSaveAllowed(P2Player(GetPlayerOwner())))
		{
		bSaveActive = false;
		SaveHelpText = DisabledNowText;
		}

	// Check for demo last so this help text will override other help text
	if (GetLevel().IsDemoBuild())
		{
		LoadHelpText = OptionUnavailableInDemoHelpText;
		SaveHelpText = OptionUnavailableInDemoHelpText;
		bLoadActive = false;
		bSaveActive = false;
		}

	AddTitleBitmap(TitleTexture);
	if(GetGameSingle() != None && GetGameSingle().FinallyOver() && !GetLevel().IsDemoBuild())
		CheatsChoice	= AddChoice(CheatsText,	CheatsHelp,			ItemFont, ItemAlign);
	if (FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
		DebugChoice		= AddChoice(DebugText,		DebugHelp,			ItemFont, ItemAlign);
	SaveChoice		= AddChoice(SaveText,		SaveHelpText,		ItemFont, ItemAlign);
	LoadChoice		= AddChoice(LoadGameText,	LoadHelpText,		ItemFont, ItemAlign);
	OptionsChoice	= AddChoice(OptionsText,	OptionsHelpText,	ItemFont, ItemAlign);
	if(GetGameSingle().GetWorkshopGame())	// xPatch: QoL addition, in-game Workshop Menu for workshop games.
		WorkshopChoice	= AddChoice(WorkshopText,		WorkshopHelpText,		ItemFont, ItemAlign); 
	if(!GetGameSingle().xManager.bMoveAchevements)
		AchChoice		= AddChoice(AchText,		AchHelpText,		ItemFont, ItemAlign); 
	QuitChoice		= AddChoice(QuitText,		"",					ItemFont, ItemAlign);
	DesktopQuitChoice		= AddChoice(DesktopQuitText,		"",					ItemFont, ItemAlign);
	ResumeChoice	= AddChoice(ResumeText,		"",					ItemFont, ItemAlign);

	// Enable/disable various options (only works with MenuChoice)
	OptionsChoice.bActive = bOptionsActive;
	SaveChoice.bActive = bSaveActive;
	LoadChoice.bActive = bLoadActive;
	}

// Go to the cheat menu, but pop up a warning if this is their first time.	
function GotoCheatMenu()
{
	local bool bWarnedCheater;

	GoToMenu(class'MenuCheats');

	bWarnedCheater = bool(GetPlayerOwner().ConsoleCommand("get"@WarnedCheaterPath));
	if (!bWarnedCheater)
	{
		MessageBox(CheatWarningTitle, CheatWarningText, MB_OK, MR_OK, MR_OK);
		GetPlayerOwner().ConsoleCommand("SET"@WarnedCheaterPath@"TRUE");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local String StartURL;

	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			switch (C)
				{
				case ResumeChoice:
					ResumeGame();
					break;
				case CheatsChoice:
					GotoCheatMenu();
					break;
				case SaveChoice:
					GoToMenu(class'MenuSave');
					break;
				case LoadChoice:
					GoToMenu(class'MenuLoad');
					break;
				case QuitChoice:
					GoToMenu(class'MenuQuitExitConfirmation');	// 01/21/03 JMI Now looks for confirmation.
					break;
				case OptionsChoice:
					GoToMenu(class'MenuOptions');
					break;
				case AchChoice:
					GoToMenu(class'MenuAchievementList');
					break;
				case DebugChoice:
					LaunchDebugMenu();
					break;
				// Added by Man Chrzan: xPatch 2.0
				case DesktopQuitChoice:
					GoToMenu(class'MenuQuitToDesktop');	
					break;	
				case WorkshopChoice:
					if (Root.GetLevel().SteamGetWorkshopStatus() != "")
						MessageBox(WaitforWorkshopTitle, WaitforWorkshopText, MB_OK, MR_OK, MR_OK);
					else
						GotoWindow(Root.CreateWindow(Class'WorkshopGameWindow', 0, 0, 1, 1, Self, True));
					break;
				// End
				}
			break;
		}
	}

function LaunchDebugMenu()
{
	local GameInfo GameInfo;
	GameInfo = GetPlayerOwner().Level.Game;
	if (AWPGameInfo(GameInfo) != None)
		GotoMenu(class'P2DebugMenu_AWP');
	else if (GameSinglePlayer(GameInfo) != None)
		GotoMenu(class'P2DebugMenu_P2');
	else if (AWGameSP(GameInfo) != None)
		GotoMenu(class'P2DebugMenu_AW');
	else // Fallback to AWP menu.
		GotoMenu(class'P2DebugMenu_AWP');
}
	
///////////////////////////////////////////////////////////////////////////////
// Handle a key event
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
	if (HandleJoystick(Key, Action, Delta))
		return true;
	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_ESCAPE:
				ResumeGame();
				return true;
			}
		}
	
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Resume playing game
///////////////////////////////////////////////////////////////////////////////
function ResumeGame()
	{
	HideMenu();
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ResumeText = "Resume Game"
	SaveText = "Save Game"
	QuitText = "Quit Game"
	DesktopQuitText = "Quit to Desktop"
	
	CheatsText = "Cheats"
	CheatsHelp = "Grant yourself various cheats for extra fun!"
	
	AchText = "Achievements"
	AchHelpText = "View super-cool achievements."
	
	DisabledForCinematicHelpText = "Not available during cinematic"
	DisabledNowText = "Not available in this state"

	bBlockConsole=false

	CheatWarningTitle = "Warning"
	CheatWarningText = "Using cheat codes will disable achievements for the current save file. This is your only warning!"
	
	DebugText="Debug"
	DebugHelp="Various features for debug/QA purposes."
	
	WorkshopText="Mods/Maps"
	WorkshopHelpText="Toggle mods or load maps as you wish!"
	
	WaitforWorkshopTitle="Warning"
	WaitforWorkshopText="Wait for all Workshop content to initialize before attempting to start a Workshop game."
	}
