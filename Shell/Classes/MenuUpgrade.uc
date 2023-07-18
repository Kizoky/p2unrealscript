///////////////////////////////////////////////////////////////////////////////
// MenuUpgrade.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The window for an outdated client. Can go to upgrade webpage, too.
//
// History:
//	09/09/03 CRK	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuUpgrade extends ShellMenuCW;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var array<string> UpgradeString, UpgradeQuestion;
var string UpgradeURL;

var ShellWrappedTextControl UpgradeControl;
var ShellWrappedTextControl UpgradeQuestionControl;

var ShellMenuChoice UpgradeChoice;
var ShellMenuChoice CancelChoice;

const LARGE_TEXT_HEIGHT = 40;
const BOLD_TEXT_HEIGHT = 30;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super.CreateMenuContents();

	UpgradeString[0] = Localize("General", "Upgrade", "Engine");
	UpgradeQuestion[0] = Localize("General", "UpgradeQuestion", "Engine");
	UpgradeURL = Localize("General", "UpgradeURL", "Engine");

	TitleAlign = TA_Center;
	ItemAlign = TA_Center;
	//AddTitle(TitleText, TitleFont, TitleAlign);
	UpgradeControl = AddWrappedTextItem(UpgradeString, LARGE_TEXT_HEIGHT*2, F_Large, ItemAlign);
	UpgradeQuestionControl = AddWrappedTextItem(UpgradeQuestion, BOLD_TEXT_HEIGHT*2, F_Bold, ItemAlign);
//	UpgradeQuestionControl.bActive = false;
//	UpgradeQuestionControl.Align = TA_Center;
//	UpgradeQuestionControl.ValueAlign = TA_Center;
	UpgradeChoice = AddChoice(UpgradeText, "", ItemFont, ItemAlign, false);
	CancelChoice = AddChoice(CancelText, "", ItemFont, ItemAlign, true);

	//BackChoice = AddChoice(BackText, "", ItemFont, ItemAlign, true);

	GetPlayerOwner().ClearProgressMessages();
	ShellRootWindow(Root).bLaunchedMultiplayer = true;
}

function Upgrade()
{
	if(UpgradeURL != "")
	{
		GetPlayerOwner().ClientTravel(UpgradeURL, TRAVEL_Absolute, false);
		ShellRootWindow(root).ExitApp();
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	local string CurrentLevel;

	Super.BeforePaint(C, X, Y);
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local class<UMenuStartGameWindow> StartGameClass;

	Super.Notify(C, E);

	switch(E)
		{
		case DE_EnterPressed:
			Upgrade();
			break;
		case DE_Click:
			switch (C)
				{
				case UpgradeChoice:
					Upgrade();
					break;
				case CancelChoice:
					GoBack();
					break;
				}
			break;
		}
}

// Take user back to startup level
function GoBack()
{
	local string CurrentLevel, GamePath;

	//Log(Self $ " Closing and Cancelling");
	GetPlayerOwner().ConsoleCommand("MenuCancel");

	CurrentLevel = ShellRootWindow(Root).ParseLevelName(Root.GetLevel().GetLocalURL());
	if(Right(CurrentLevel, 4) ~= ".fuk")
		CurrentLevel = Left(CurrentLevel, Len(CurrentLevel) - 4);

	if(GetGameSingle() != None && Caps(CurrentLevel) != Caps(ShellRootWindow(Root).GetStartupMap()))	// SINGLEPLAYER
		GetGameSingle().QuitGame();
	else																	// MULTIPLAYER
		{
		if(CurrentLevel ~= "Entry")
			{
			GetPlayerOwner().ConsoleCommand("disconnect");
			P2RootWindow(Root).HideMenu();
			// RWS FIXME: Read the game type value from ini
			GamePath = "GameTypes.GameSinglePlayer";
			GetPlayerOwner().ClientTravel(ShellRootWindow(Root).GetStartupMap()$".fuk?Mutator=?Workshop=0?Game=" $ GamePath, TRAVEL_Absolute, false);
			}
		}
	P2RootWindow(Root).EnableMenu();
	Super.GoBack();
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MenuWidth = 600
}

