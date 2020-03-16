///////////////////////////////////////////////////////////////////////////////
// MenuLoad.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The Load menu.
//
// History:
//  02/02/03 JMI	Removed c_strGamePrefix and added help string.
//
//	01/22/03 JMI	Started it.
//
///////////////////////////////////////////////////////////////////////////////
// Extended MenuLoad class merely chooses what to do when a slot is chosen.
///////////////////////////////////////////////////////////////////////////////
class MenuLoad extends MenuLoadSave;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Behavior for when a slot is chosen.
///////////////////////////////////////////////////////////////////////////////
function OnSlotChoice(int i)
{
	// 02/09/03 JMI Try to prevent failed loads by not allowing load of easily
	//				identifiable missing save games.
	if (IsSlotEmpty(i) == false)
	{
		// 02/19/03 JMI Slot value is now represented in a separate sorted 
		//				array and the slots themselves are not sorted.
		// 02/17/03 JMI Load wasn't using the Slot value so it was loading a
		//				somewhat random level dependent upon the sort.  Oops.
		GetGameSingle().LoadGame(aiSlotOrder[i], true);
		ShellRootWindow(Root).bLaunchedMultiplayer = false;
		// Kill cinematics
		ViewportOwner.Actor.ConsoleCommand("CINEMATICS 0");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MenuTitleText = "Load Game"

	strSlotHelp = "Load game from this slot. Right-click deletes saved game.";
}
