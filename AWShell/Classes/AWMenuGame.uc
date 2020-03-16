///////////////////////////////////////////////////////////////////////////////
// AWMenuGame.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// The In-Game menu for AW.
//
///////////////////////////////////////////////////////////////////////////////
// This class describes the game menu details and processes game menu events.
///////////////////////////////////////////////////////////////////////////////
class AWMenuGame extends MenuGame;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var class<ShellMenuCW> MenuCheatsClass;
var class<ShellMenuCW> MenuSaveClass;
var class<ShellMenuCW> MenuLoadClass;
var class<ShellMenuCW> MenuQuitClass;
var class<ShellMenuCW> MenuOptionsClass;


///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super(BaseMenuBig).Notify(C, E);
	switch(E)
		{
		case DE_Click:
			switch (C)
				{
				case ResumeChoice:
					ResumeGame();
					break;
				case CheatsChoice:
					GoToMenu(MenuCheatsClass);
					break;
				case SaveChoice:
					GoToMenu(MenuSaveClass);
					break;
				case LoadChoice:
					GoToMenu(MenuLoadClass);
					break;
				case QuitChoice:
					GoToMenu(MenuQuitClass);	// 01/21/03 JMI Now looks for confirmation.
					break;
				case OptionsChoice:
					GoToMenu(MenuOptionsClass);
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
     MenuCheatsClass=Class'AWShell.AWMenuCheats'
     MenuSaveClass=Class'Shell.MenuSave'
     MenuLoadClass=Class'Shell.MenuLoad'
     MenuQuitClass=Class'Shell.MenuQuitExitConfirmation'
     MenuOptionsClass=Class'AWShell.AWMenuOptions'
     astrTextureDetailNames(0)="UltraLow"
     astrTextureDetailNames(1)="Low"
     astrTextureDetailNames(2)="Medium"
     astrTextureDetailNames(3)="High"
}
