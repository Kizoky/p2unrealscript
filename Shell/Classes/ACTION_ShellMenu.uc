///////////////////////////////////////////////////////////////////////////////
// ACTION_ShellMenu.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This action lets you send various commands to the shell menu.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_ShellMenu extends P2ScriptedAction;

enum EShellCommand
	{
	Shell_ShowMenu,
	Shell_HideMenu,
	Shell_QuitGame,
	Shell_JumpToMenu,
	Shell_Precache
	};

var(Action) EShellCommand			Command;	// Command
var(Action) class<ShellMenuCW>		WhichMenu;	// Menu to bring up

function bool InitActionFor(ScriptedController C)
	{
	local ShellRootWindow shell;

	shell = ShellRootWindow(GetPlayer(C).Player.InteractionMaster.BaseMenu);
	if (shell != None)
		{
		//log("action shell"@command@"open window"@Shell.OpenWindow@"shell menu"@Shell.MyMenu,'ShellDebug');
		if (Command == Shell_ShowMenu
			&& shell.OpenWindow == None
			&& !Shell.MyMenu.WindowIsVisible())
			shell.ShowMenu();
		else if (Command == Shell_HideMenu)
			shell.HideMenu();
		else if (Command == Shell_QuitGame)
			shell.QuitCurrentGame();
		else if (Command == Shell_JumpToMenu)
			shell.JumpToMenu(WhichMenu);
		else if (Command == Shell_Precache)
			shell.Precache();
		}
	return false;
	}

function string GetActionString()
	{
	if (Command == Shell_ShowMenu)
		return ActionString@"- show menu";
	else if (Command == Shell_HideMenu)
		return ActionString@"- hide menu";
	else if (Command == Shell_QuitGame)
		return ActionString@"- quit game";
	else if (Command == Shell_JumpToMenu)
		return ActionString@"- jump to menu "$WhichMenu;
	else if (Command == Shell_Precache)
		return ActionString@"- precache";
	else
		return ActionString@"- unknown";
	}

defaultproperties
	{
	ActionString="shell menu"
	}
