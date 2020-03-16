///////////////////////////////////////////////////////////////////////////////
// MenuDifficultyPatch.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// If you have a saved game from before the 1st patch, then the difficulty setting
// was only stored in the postal2.ini and not in your save. This menu explains
// this and then continues to the start menu to pick your difficulty.
//
///////////////////////////////////////////////////////////////////////////////
class MenuDifficultyPatch extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string		DiffTitleText;

var localized string		Msg[8];

var ShellMenuChoice			StartChoice;

var bool bUpdate;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local int i;
	local array<string> Msg2;

	// Dynamic arrays don't localize properly, so copy static array to dynamic array
	Msg2.insert(0, ArrayCount(Msg));
	for (i = 0; i < Msg2.length; i++)
		Msg2[i] = Msg[i];

	Super.CreateMenuContents();
	
	AddTitle(DiffTitleText, F_FancyL, TA_Left);

	AddWrappedTextItem(Msg2, 300, F_FancyS, TA_Left);

	ItemFont = F_FancyL;
	ItemAlign = TA_Left;

	StartChoice	= AddChoice(NextText,	"", ItemFont, ItemAlign);
	// Can't back up in this menu.
	BackChoice  = None;

	// We want to fix a saved game, so set this for later menus to use
	ShellRootWindow(Root).bFixSave=true;
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
				//case BackChoice:
				//	GoBack();
				//	break;
				case StartChoice:
					// Pick the difficulty
					GotoMenu(class'MenuStart');
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
	MenuWidth  = 500
	MenuHeight = 450

	DiffTitleText = "Difficulty Fix"

	Msg[0] = "This file was last saved before the update patch was applied.\\n"
	Msg[1] = "\\n"
	Msg[2] = "There was a bug which prevented the difficulty settings from "
	Msg[3] = "being saved correctly.  It is now fixed.  You're welcome.\\n"
	Msg[4] = "\\n"
	Msg[5] = "The next screen will ask you to choose the difficulty setting "
   	Msg[6] = "you want to use with this file.  It will not effect other saved "
	Msg[7] = "game files, only this one." 
	}
