///////////////////////////////////////////////////////////////////////////////
// MenuAdmin.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The Admin Options menu.
//
// History:
//	10/17/03 CRK	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuAdmin extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var ShellMenuChoice		RestartChoice;
var localized string	RestartText;
var localized string	RestartHelp;

var ShellMenuChoice		GameMapChoice;
var localized string	GameMapText;
var localized string	GameMapHelp;

var ShellMenuChoice		NextChoice;
var localized string	NextText;
var localized string	NextHelp;

var ShellMenuChoice		KickChoice;
var localized string	KickText;
var localized string	KickHelp;

var ShellMenuChoice		MessageChoice;
var localized string	MessageHelp;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	
	TitleAlign = TA_Center;
	ItemAlign = TA_Center;
	AddTitle(AdminMenuText, TitleFont, TitleAlign);

	NextChoice			= AddChoice(NextText,			NextHelp,    ItemFont, ItemAlign);
	RestartChoice		= AddChoice(RestartText,		RestartHelp, ItemFont, ItemAlign);
	GameMapChoice		= AddChoice(GameMapText,		GameMapHelp, ItemFont, ItemAlign);
	KickChoice			= AddChoice(KickText,			KickHelp,    ItemFont, ItemAlign);
	MessageChoice		= AddChoice(AdminMessageText,	MessageHelp, ItemFont, ItemAlign);

	BackChoice			= AddChoice(BackText,			"", ItemFont, ItemAlign, true);
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
					case NextChoice:
						GetPlayerOwner().ConsoleCommand("admin" @ "nextmap");
						break;
					case RestartChoice:
						GetPlayerOwner().ConsoleCommand("admin" @ "restartmap");
						break;
					case GameMapChoice:
						GoToMenu(class'MenuAdminGameType');
						break;
					case KickChoice:
						GoToMenu(class'MenuAdminKickBan');
						break;
					case MessageChoice:
						GoToMenu(class'MenuAdminMessage');
						break;
					case BackChoice:
						GoBack();
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
	MenuWidth	= 400
	NextText	= "Next Map"
	NextHelp	= "Go to the next map in the map list"
	RestartText	= "Restart Map"
	RestartHelp	= "Restart the current level"
	GameMapText	= "Change Game Type/Map"
	GameMapHelp	= "Switch to a different game type or map"
	KickText	= "Kick/Ban a Player"
	KickHelp	= "Force a player to leave the game"
	MessageHelp	= "Send an administrator announcement to all the players"
}
