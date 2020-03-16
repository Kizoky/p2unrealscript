///////////////////////////////////////////////////////////////////////////////
// MenuGameMulti.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The Multiplayer In-Game menu.
//
// History:
//	10/17/03	CRK		Added Admin Menu
//	07/23/03	CRK		Started
//
///////////////////////////////////////////////////////////////////////////////
// This class describes the game menu details and processes game menu events.
///////////////////////////////////////////////////////////////////////////////
class MenuGameMulti extends BaseMenuBig;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var ShellMenuChoice		ResumeChoice;
var localized string	ResumeText;
var localized string	ResumeHelp;

var ShellMenuChoice		JoinChoice;
var UBrowserMainWindow	JoinBrowserWindow;
var localized string	JoinAnotherText;

var ShellMenuChoice		PlayerChoice;

var ShellMenuChoice		AdminChoice;
var ShellMenuChoice		AdminLoginChoice;

var ShellMenuChoice		QuitChoice;
var localized string	LeaveGameHlep;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();

	AddTitleBitmap(TitleTexture);

	PlayerChoice	= AddChoice		(PlayerChangeText,	PlayerChangeHelp,	ItemFont, ItemAlign);
	OptionsChoice	= AddChoice		(OptionsText,		"",					ItemFont, ItemAlign);
	JoinChoice		= AddChoice		(JoinAnotherText,	JoinHelp,			ItemFont, ItemAlign);

	if(GetPlayerOwner().PlayerReplicationInfo.bAdmin)
		AdminChoice	= AddChoice		(AdminMenuText,		"",					ItemFont, ItemAlign);
	else
		AdminLoginChoice = AddChoice(AdminLoginText,	"",					ItemFont, ItemAlign);

	QuitChoice		= AddChoice		(LeaveGameText,		"",					ItemFont, ItemAlign);
	ResumeChoice	= AddChoice		(ResumeText,		"",					ItemFont, ItemAlign);
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
				case JoinChoice:
					JoinBrowserWindow = UBrowserMainWindow(Root.CreateWindow(class'UTBrowserMainWindow', 50, 30, 500, 300));
					JoinBrowserWindow.SelectInternet();
					GotoWindow(JoinBrowserWindow);
					break;
				case PlayerChoice:
					GotoMenu(class'MenuPlayer');
					break;
				case QuitChoice:
					GoToMenu(class'MenuDisconnectConfirmation');
					break;
				case OptionsChoice:
					GoToMenu(class'MenuOptionsMulti');
					break;
				case AdminChoice:
					GoToMenu(class'MenuAdmin');
					break;
				case AdminLoginChoice:
					GoToMenu(class'MenuAdminLogin');
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Handle a key event
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_ESCAPE:
				if(ShellRootWindow(Root) != None && ShellRootWindow(Root).openWindow != None)
				{
					ShellRootWindow(Root).openWindow.Close();
					return true;
				}
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
	JoinAnotherText = "Join New Game"
	ResumeText = "Resume Game"
	}
