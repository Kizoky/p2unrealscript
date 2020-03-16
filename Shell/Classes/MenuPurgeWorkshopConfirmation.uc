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
class MenuPurgeWorkshopConfirmation extends ShellMenuCW;

var localized string		ConfirmText;
var localized string		ConfirmTitleText;
var localized string		PurgedTitle, PurgedText;
var ShellMenuChoice			YesChoice;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
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
					GetLevel().SteamPurgeWorkshop();
					GoBack();
					MessageBox(PurgedTitle, PurgedText, MB_OK, MR_OK, MR_OK);
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
	ConfirmTitleText = "Delete all unsubscribed Workshop content?"
	PurgedTitle = "Items purged"
	PurgedText = "Unused Workshop items purged."

	MenuWidth	= 625
	MenuHeight	= 200
	}
