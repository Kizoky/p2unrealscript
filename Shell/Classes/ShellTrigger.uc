///////////////////////////////////////////////////////////////////////////////
// ShellTrigger.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Special trigger that sends commands to the shell.
//
//	History:
//		05/14/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
//
// OBSOLETE!
// OBSOLETE!
// OBSOLETE!
//
// You should be using a ScriptedTrigger and then using the ACTION_ShellMenu.
// It does the same thing this did but also allows for much more to be done
// due via all the ACTION's available to ScriptedTrigger.
//
///////////////////////////////////////////////////////////////////////////////
class ShellTrigger extends Triggers
	notplaceable;	// obsolete

//#exec Texture Import File=Textures\MaterialTrigger.pcx Name=S_MaterialTrigger Mips=Off MASKED=1

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

enum EShellCommands
	{
	ETC_Show,
	ETC_Hide
	};

var(Title) EShellCommands	Command;	// Command to execute


///////////////////////////////////////////////////////////////////////////////
// When this trigger is triggered, we pass the specified info on to the
// TitleThing so it will be displayed.
///////////////////////////////////////////////////////////////////////////////
function Trigger( Actor Other, Pawn EventInstigator )
	{
	local Controller P;
	local ShellRootWindow shell;

	for (P = Level.ControllerList; P != None; P = P.nextController)
		{
		if (P.IsA('PlayerController'))
			{
			shell = ShellRootWindow(PlayerController(P).Player.InteractionMaster.BaseMenu);
			if (shell != None)
				{
				if (Command == ETC_Show)
					shell.ShowMenu();
				else if (Command == ETC_Hide)
					shell.HideMenu();
				}
			break;
			}
		}
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bObsolete=true
	Texture=Texture'Engine.S_MaterialTrigger'
	bCollideActors=False
	}
