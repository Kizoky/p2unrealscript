///////////////////////////////////////////////////////////////////////////////
// MenuCheats.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The Cheats menu.
//
///////////////////////////////////////////////////////////////////////////////
class P2DebugMenu_Main extends ShellMenuCW;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var localized string TitleText;

var ShellMenuChoice StartGameAW7;
var ShellMenuChoice StartGameWeekend;
var ShellMenuChoice StartGameMF;

var localized string StartAW7Text;
var localized string StartMFText;
var localized string StartWeekendText;
var localized string StartAW7Help;
var localized string StartMFHelp;
var localized string StartWeekendHelp;


var int					CustomMapWidth;
var int					CustomMapHeight;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	local int i;

	Super.CreateMenuContents();
	
	ItemFont	= F_FancyM;
	ItemAlign = TA_Center;
	AddTitle(TitleText, TitleFont, TitleAlign);

	StartGameAW7 =		AddChoice(StartAW7Text,		StartAW7Help,		ItemFont,	TA_Left);
	StartGameMF =		AddChoice(StartMFText,		StartMFHelp,		ItemFont,	TA_Left);
	StartGameWeekend =	AddChoice(StartWeekendText,	StartWeekendHelp,	ItemFont,	TA_Left);
	
	BackChoice			= AddChoice(BackText, "", ItemFont, TitleAlign, true);
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
					case StartGameAW7:
						LaunchMapSelect("GameTypes.AWPGameInfo");
						break;
					case StartGameMF:
						LaunchMapSelect("GameTypes.GameSinglePlayer");
						break;
					case StartGameWeekend:
						LaunchMapSelect("GameTypes.AWGameSPFinal");
						break;
					case BackChoice:
						GoBack();
						break;
				}
			break;
	}
}

function LaunchMapSelect(string GameType)
{
	Root.ShowModal(Root.CreateWindow(class'DebugShellMapListFrame_StartNew',
					(Root.WinWidth - CustomMapWidth) /2, 
					(Root.WinHeight - CustomMapHeight) /2, 
					CustomMapWidth, CustomMapHeight, self));

	if (DebugShellMapListFrame_StartNew(Root.ModalWindow) != None)
		DebugShellMapListFrame_StartNew(Root.ModalWindow).SetGameType(GameType);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ItemHeight	= 20
	MenuWidth	= 500
					
	TitleText = "Debug Menu"
	
	StartAW7Help="Play all seven days."
	StartMFHelp="Play Monday through Friday only."
	StartWeekendHelp="Play Saturday and Sunday only."
	StartAW7Text="A Week In Paradise"
	StartMFText="POSTAL 2"
	StartWeekendText="Apocalypse Weekend"

	CustomMapWidth	= 350
	CustomMapHeight	= 250
}
