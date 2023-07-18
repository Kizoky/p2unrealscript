///////////////////////////////////////////////////////////////////////////////
// MenuDemoArrested.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
//	Menu shown when you're arrested by the police in the demo.
//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class MenuDemoArrested extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string    TitleText;

var localized string	Msg[7];

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
	TextItem = AddWrappedTextItem(Msg2, 300, F_FancyM, ItemAlign);

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
	MenuHeight = 480
	TitleHeight = 50
	TitleSpacingY = 5
	
	TitleText	= "The Demo is over."

	Msg[ 0] = "You've been arrested by Paradise's finest--nice going!\\n"
    Msg[ 1] = "In the real game, you'd be transported to a luxurious suite in "
    Msg[ 2] = "the Paradise Police station where you'd have to bust your "
	Msg[ 3] = "way out by fighting or out-smarting the police.\\n"
    Msg[ 4] = "Unfortunately, this is not included in the demo, so we're just "
    Msg[ 5] = "going to return you to the main menu.\\n"
    Msg[ 6] = "Simply start a new game to play the demo again."
				
	MainMenuText="Return to Menu"

	bDarkenBackground=true
	}
