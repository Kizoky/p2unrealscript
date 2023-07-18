///////////////////////////////////////////////////////////////////////////////
// MenuOptionsMulti.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The Multiplayer Options menu.
// Can't set Performance Options, Audio Options, load a Custom Map, or see the Credits.
// Can only change Game Options, Controls, and Video Options from multiplayer.
//
// History:
//	10/13/03 CRK	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuOptionsMulti extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	
	AddTitle(OptionsText, TitleFont, TitleAlign);

	GameChoice			= AddChoice(GameOptionsText,	GameOptionsHelp,	ItemFont, ItemAlign);
	ControlsChoice		= AddChoice(ControlOptionsText, ControlOptionsHelp,	ItemFont, ItemAlign);
	VideoChoice			= AddChoice(VideoOptionsText,	VideoOptionsHelp,	ItemFont, ItemAlign);

	BackChoice			= AddChoice(BackText, "", ItemFont, ItemAlign, true);
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
			if (C != None)
				switch (C)
					{
					case BackChoice:
						GoBack();
						break;
					case VideoChoice:
						GoToMenu(class'MenuVideo');
						break;
					case ControlsChoice:
						GoToMenu(class'MenuControls');
						break;
					case GameChoice:
						GoToMenu(class'MenuGameSettings');
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
	MenuWidth	= 250
	HintLines	= 4
}
