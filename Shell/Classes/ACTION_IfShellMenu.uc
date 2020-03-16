///////////////////////////////////////////////////////////////////////////////
// ACTION_IfShellMenu.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Executes a section of actions only if the specified condition is met.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_IfShellMenu extends P2ScriptedAction;

enum ETest
	{
	Test_VirginMenu_Is
	};

var(Action) ETest Test;
var(Action) bool Is;

function ProceedToNextAction(ScriptedController C)
	{
	local bool bResult;
	local ShellRootWindow shell;

	shell = ShellRootWindow(GetPlayer(C).Player.InteractionMaster.BaseMenu);
	if (shell != None)
		{
		switch (Test)
			{
			case Test_VirginMenu_Is:
				bResult = (shell.IsVirgin() == Is);
				break;

			default:
				break;
			}
		}

	C.ActionNum += 1;
	if (!bResult)
		ProceedToSectionEnd(C);
	}

function bool StartsSection()
	{
	return true;
	}

function string GetActionString()
	{
	switch (Test)
		{
		case Test_VirginMenu_Is:
			return ActionString@"if VirginMenu is "$Is;
			break;

		default:
			break;
		}
	return ActionString@"unknown";
	}

defaultproperties
	{
	Is=true
	ActionString="IfShellMenu: "
	bRequiresValidGameInfo=true
	}
