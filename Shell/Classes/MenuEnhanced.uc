///////////////////////////////////////////////////////////////////////////////
// MenuEnhanced.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Menu to explain Enhanced mode. Then connects to menustart to pick the
// difficulty.
//
///////////////////////////////////////////////////////////////////////////////
class MenuEnhanced extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var localized string		EnhancedTitleText;
var localized string		Msg[5];
var ShellMenuChoice			StartChoice;
var bool bUpdate;

var Color MsgColor;
var class<ShellMenuCW> 		PickStartMenu;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local int i;
	local array<string> Msg2;
	local ShellWrappedTextControl ctl;

	// Dynamic arrays don't localize properly, so copy static array to dynamic array
	Msg2.insert(0, ArrayCount(Msg));
	for (i = 0; i < Msg2.length; i++)
		Msg2[i] = Msg[i];
		
	Super.CreateMenuContents();
	
	AddTitle(EnhancedTitleText, F_FancyL, TA_Left);

	// xPatch: Changed font to be easier to read (was F_FancyS)
	ctl = AddWrappedTextItem(Msg2, 300, F_Bold, TA_Left);
	ctl.SetTextColor(MsgColor);

	ItemFont = F_FancyL;
	ItemAlign = TA_Left;
	StartChoice	= AddChoice(StartText,	"", ItemFont, ItemAlign);
	BackChoice  = AddChoice(BackText,   "", ItemFont, ItemAlign, true);
	
	GetPlayerOwner().ConsoleCommand("set"@EnhancedPath@"true");
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
				case StartChoice:
					// xPatch: Go to the previously selected start menu
					if(PickStartMenu != None)
						JumpToMenu(PickStartMenu);
					else // This should not happen but if it somehow does go to the old start menu.
						JumpToMenu(class'MenuStart');
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
	MenuWidth  = 375
	MenuHeight = 450

	EnhancedTitleText = "Enhanced Game"

	Msg[0] = "Congratulations on beating the game! The Enhanced Game is now available.\\n"
	Msg[1] = "\\n"
    Msg[2] = "This mode has more power-ups, several enhanced weapons, and "
	Msg[3] = "some useful inventory items right from the start.\\n"
    Msg[4] = "You already beat the game once, so go ahead and make it harder this time..."
	
	MsgColor=(R=245,G=245,B=245,A=245)
	}
