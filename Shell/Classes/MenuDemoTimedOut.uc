///////////////////////////////////////////////////////////////////////////////
// MenuDemoTimedOut.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
//	Menu shown when you're demo game has timed out.
//
///////////////////////////////////////////////////////////////////////////////
class MenuDemoTimedOut extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string    TitleText;

var localized string	Msg[2];

var localized string    MainMenuText;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local int i;
	local array<string> Msg2;
	local string str;
	local ShellWrappedTextControl TextItem;

	// Dynamic arrays don't localize properly, so copy static array to dynamic array
	Msg2.insert(0, ArrayCount(Msg));
	for (i = 0; i < Msg2.length; i++)
		Msg2[i] = Msg[i];

	Super.CreateMenuContents();
	
	AddTitle(TitleText, F_FancyL, TA_Center);

	ItemAlign = TA_Center;
	TextItem = AddWrappedTextItem(Msg2, 200, F_FancyM, ItemAlign);

	BackChoice  = AddChoice(MainMenuText,"", F_FancyL, ItemAlign, true);
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
					ShellRootWindow(root).QuitCurrentGame();
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
	MenuWidth  = 540
	MenuHeight = 300
	TitleHeight = 50
	TitleSpacingY = 4
	
	TitleText	= "The Demo has timed out."

	Msg[ 0] = "This game session is over.\\n"
    Msg[ 1] = "Go back to the main menu and start a new game to play again."
				
	MainMenuText="Return to Menu"
	
	bDarkenBackground=true
	}
