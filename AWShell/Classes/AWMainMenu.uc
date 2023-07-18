///////////////////////////////////////////////////////////////////////////////
// AWMainMenu.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
// This class describes the main menu details and processes main menu events.
///////////////////////////////////////////////////////////////////////////////
class AWMainMenu extends MenuMain;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var string				DudeClassStr;	// dude class to pick for single player AW
var class<ShellMenuCW>	MenuOptionsClass;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super(BaseMenuBig).CreateMenuContents();
	AddTitleBitmap(TitleTexture);

	NewChoice     = AddChoice(NewGameText,		"",									ItemFont, ItemAlign);
	LoadChoice    = AddChoice(LoadGameText,		OptionUnavailableInDemoHelpText,	ItemFont, ItemAlign);
	LoadChoice.bActive = !GetLevel().IsDemoBuild();
	OptionsChoice = AddChoice(OptionsText,		"",									ItemFont, ItemAlign);
	ExitChoice    = AddChoice(ExitGameText,		"",									ItemFont, ItemAlign);

	// Reset this value. When MenuDifficultyPatch starts up, it's the only one that needs it
	// and it will set it when necessary.
	ShellRootWindow(Root).bFixSave=false;
 	}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local bool bHandled;

	switch(E)
		{
		case DE_Click:
			if (C != None)
				switch (C)
					{
					case OptionsChoice:
						GoToMenu(MenuOptionsClass);
						bHandled = true;
						break;
					case NewChoice:
						// Start new game
						SetSingleplayer();
						ShellRootWindow(Root).bVerifiedPicked=false;
						GotoMenu(class'AWMenuStart');
						bHandled = true;
						break;
					}
			break;
		}

	if (!bHandled)
		Super.Notify(C, E);
	}

///////////////////////////////////////////////////////////////////////////////
// Set temp options for singleplayer game
///////////////////////////////////////////////////////////////////////////////
function SetSingleplayer()
{
	ShellRootWindow(Root).bLaunchedMultiplayer = false;
	GetPlayerOwner().UpdateURL("Name", class'GameInfo'.Default.DefaultPlayerName, false);
	GetPlayerOwner().UpdateURL("Class", DudeClassStr, false);
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     DudeClassStr="AWWrapGame.AWPostalDude"
     MenuOptionsClass=Class'AWShell.AWMenuOptions'
     TitleTexture=Texture'AW_ProductName.ProductMenu'
     astrTextureDetailNames(0)="UltraLow"
     astrTextureDetailNames(1)="Low"
     astrTextureDetailNames(2)="Medium"
     astrTextureDetailNames(3)="High"
}
