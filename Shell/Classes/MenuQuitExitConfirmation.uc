///////////////////////////////////////////////////////////////////////////////
// MenuQuitExitConfirmation.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The confirmation menu for quiting a running game or exiting the application.
//
// History:
//	01/19/03 JMI	Started to confirm changes made by MenuPerformanceWizard.
//
///////////////////////////////////////////////////////////////////////////////
// This class defines a menu that merely displays a confirmation regarding
// quiting or exiting and, if yes is chosen, performs the action.  If no is
// chosen, it executes a GoBack.
//
///////////////////////////////////////////////////////////////////////////////
class MenuQuitExitConfirmation extends ShellMenuCW;

var localized string		ConfirmText;
var string					ConfirmTitleText;
var localized string		ExitText;
var localized string		QuitText;
var ShellMenuChoice			YesChoice;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	if (IsGameMenu())
		ConfirmTitleText = QuitText;
	else
		ConfirmTitleText = ExitText;

	TitleFont = F_FancyL;
	TitleAlign = TA_Center;
	AddTitle(ConfirmTitleText, TitleFont, TitleAlign);

	ItemFont = F_FancyL;
	ItemAlign = TA_Center;
	YesChoice  = AddChoice(YesText,	"", ItemFont, ItemAlign, false);
	BackChoice = AddChoice(NoText,	"", ItemFont, ItemAlign, true);
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
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				case YesChoice:
					if (IsGameMenu())
						{
						ShellRootWindow(root).QuitCurrentGame();
						}
					else
						{
						if (GetLevel().IsDemoBuild())
							GotoMenu(class'MenuImageBuy');
						else
							ShellRootWindow(root).ExitApp();
						}
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
	ExitText = "Are you sure you want to Exit?"
	QuitText = "Are you sure you want to Quit?"

	MenuWidth	= 600
	MenuHeight	= 200
	}
