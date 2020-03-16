///////////////////////////////////////////////////////////////////////////////
// MenuMulti.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The multiplayer menu.
//
// History:
//	01/13/03 JMI	Added strHelp parameter to AddChoice() allowing us to pass
//					in many help strings that had been created but were not 
//					being used for standard menu choices.  Added generic 
//					RestoreHelp for menus sporting a Restore option.
//
//	01/12/03 JMI	Changed bDontAsk to bAsk.
//
//	01/08/03 JMI	bDontUpdate's usage was backward from the name of the
//					var and the associated comment.  Renamed the var and changed
//					the comment rather than risking changing the code.
//
//	09/25/02 MJR	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuMulti extends ShellMenuCW
	config;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var ShellMenuChoice		JoinChoice;
var UBrowserMainWindow	JoinBrowserWindow;

var ShellMenuChoice		HostChoice;
var localized string	HostText;
var localized string	HostHelp;

var ShellMenuChoice		OpenChoice;

var ShellMenuChoice		PlayerChoice;

var config string		MultiPlayerName;
var config string		MultiPlayerClass;

var bool bUpdate;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();

	bUpdate = false;

	TitleAlign = TA_Left;
	ItemAlign = TA_Left;

	AddTitle(MultiTitleText, TitleFont, TitleAlign);
	
	PlayerChoice	= AddChoice		(PlayerSetupText,	PlayerSetupHelp,	ItemFont, ItemAlign);
	JoinChoice		= AddChoice		(JoinText,			JoinHelp,			ItemFont, ItemAlign);
	HostChoice		= AddChoice		(HostText,			HostHelp,			ItemFont, ItemAlign);
	OpenChoice		= AddChoice		(OpenText,			OpenHelp,			ItemFont, ItemAlign);

	BackChoice = AddChoice(BackText, "", ItemFont, ItemAlign, true);

	// Set Multiplayer Options
	ShellRootWindow(Root).bLaunchedMultiplayer = true;
	GetPlayerOwner().PlayerReplicationInfo.SetPlayerName(MultiPlayerName);
	GetPlayerOwner().UpdateURL("Name", MultiPlayerName, True);
	GetPlayerOwner().UpdateURL("Class", MultiPlayerClass, True);
	GetPlayerOwner().UpdateURL("Team", GetPlayerOwner().GetDefaultURL("Team"), True);

	LoadValues();
	bUpdate = true;
	}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
	{
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
		case DE_Change:
			switch (C)
				{
				}
			break;
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				case JoinChoice:
					JoinBrowserWindow = UBrowserMainWindow(Root.CreateWindow(class'UTBrowserMainWindow', 50, 30, 500, 300));
					//JoinBrowserWindow.SelectLAN();
					JoinBrowserWindow.SelectInternet();
					GotoWindow(JoinBrowserWindow);
					break;
				case HostChoice:
					// Create start network game dialog.
					StartGameClass = class<UMenuStartGameWindow>(DynamicLoadObject("UTBrowser.UTStartGameWindow", class'Class'));
					GotoWindow(Root.CreateWindow(StartGameClass, 100, 100, 200, 200, Self, True));
					break;
				case OpenChoice:
					JoinBrowserWindow = UBrowserMainWindow(Root.CreateWindow(class'UTBrowserMainWindow', 50, 30, 500, 300));
					JoinBrowserWindow.ShowOpenWindow();
					GotoWindow(JoinBrowserWindow);
					break;
				case PlayerChoice:
					GotoMenu(class'MenuPlayer');
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Update values when controls have changed.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	MenuWidth = 350
	HintLines = 4	// CRK - If set to 3, letters on the 3rd line can get cut off at the bottom

	HostText = "Host Game"
	HostHelp = "Start a multiplayer game that other players can join"

	MultiPlayerName = "Player"
	MultiPlayerClass = "MultiStuff.MpDude"
	}

