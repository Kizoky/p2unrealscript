///////////////////////////////////////////////////////////////////////////////
// MenuSave.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The Save menu.
//
// History:
//  02/02/03 JMI	Removed c_strGamePrefix, added help string, and put in
//					message box notifying the game was saved..
//
//	01/22/03 JMI	Started it.
//
///////////////////////////////////////////////////////////////////////////////
// Extended MenuSave class merely chooses what to do when a slot is chosen.
///////////////////////////////////////////////////////////////////////////////
class MenuSave extends MenuLoadSave;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string	SavedGameTitle;
var localized string	SavedGameText;

var localized string	ReplaceGameTitle;
var localized string	ReplaceGameText;

var localized string    SavedGameFailTitle;
var localized string    SavedGameFailText;

var int					iCurSlot;

var UWindowMessageBox	SaveConfirmationBox;
var UWindowMessageBox	SaveCompleteBox;

///////////////////////////////////////////////////////////////////////////////
// Behavior for when a slot is chosen.
///////////////////////////////////////////////////////////////////////////////
function OnSlotChoice(int i)
{
	if (IsSlotEmpty(i) )
		SaveSlot(i);
	else
		{
		iCurSlot = i;
		SaveConfirmationBox = MessageBox(ReplaceGameTitle, ReplaceGameText, MB_YESNO, MR_NO, MR_YES);
		}
}

///////////////////////////////////////////////////////////////////////////////
// Actually save the game to the current slot.
///////////////////////////////////////////////////////////////////////////////
function SaveSlot(int i)
	{
	if (i >= 0)
		{
		// NOTE: I had tried to make sure the game was not paused prior to
		// saving it so that when it is loaded it won't be paused, but that
		// didn't work and I don't know why.  Instead, it seemed just as
		// easy to handle this after a game has been loaded.
		
		// xPatch: A bit tricky method but at least it works, FINALLY!
		if(GetGameSingle().TheGameState.DidPlayerCheat())
			ShellLookAndFeel(LookAndFeel).SaveTextColor = CheatedColor;
		else
			ShellLookAndFeel(LookAndFeel).SaveTextColor = ShellLookAndFeel(LookAndFeel).NormalTextColor;

		// 02/19/03 JMI Slot value is now represented in a separate sorted
		//				array and the slots themselves are not sorted.
		if(GetGameSingle().SaveGame(aiSlotOrder[i], false))
		{
		UpdateSlotUI(i);
		SaveCompleteBox = MessageBox(SavedGameTitle, SavedGameText, MB_OK, MR_OK, MR_OK);
		}
		else
		{
          MessageBox(SavedGameFailTitle, SavedGameFailText, MB_OK, MR_OK, MR_OK);
		}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Notification that the message box has finished.
///////////////////////////////////////////////////////////////////////////////
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	Super.MessageBoxDone(W, Result);
	
	// Silly, not checking to make sure that the dialog box they clicked on was the one we put up.
	if (W == SaveConfirmationBox)
	{
		switch (Result)
			{
			case MR_YES:
				// Replace existing slot.
				SaveSlot(iCurSlot);
				break;
			case MR_NO:
				// Whimped out..carry on.
				break;
			}

		iCurSlot = -1;
	}
	if (W == SaveCompleteBox)
	{
		// If it's the game menu then resume the game
		if (IsGameMenu())
			HideMenu();		
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MenuTitleText = "Save Game"

	strSlotHelp = "Save game to this slot. Right-click deletes saved game.";

	SavedGameTitle = "Save Game"
	SavedGameText  = "Your game has been saved"

	ReplaceGameTitle = "Save Over Game"
	ReplaceGameText  = "Are you sure you want to save over this slot?"

	SavedGameFailTitle = "Save Game Failed"
    SavedGameFailText  = "Your game has not been saved due to an error. Please try again."

	// 02/16/03 JMI No longer changing the sort between menus--it's weird.
	// bSortSlotsAscending = true	// Oldest entries on top as we probably want to overwrite these.

	bShowSpecialSlots = false;
}
