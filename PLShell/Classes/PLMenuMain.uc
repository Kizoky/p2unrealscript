///////////////////////////////////////////////////////////////////////////////
// PLMenuMain
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Main menu for Paradise Lost.
///////////////////////////////////////////////////////////////////////////////
class PLMenuMain extends MenuMain;

var ShellMenuChoice		DebugChoice;
var localized string	DebugText;
var localized string	DebugHelp;
var int					CustomMapWidth;
var int					CustomMapHeight;
var texture 			PLTitleTex;
///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super(BaseMenuBig).CreateMenuContents();
	TitleTexture = PLTitleTex; // Always PL Logo in this menu
	AddTitleBitmap(TitleTexture);
	NewChoice     = AddChoice(NewGameText,		"",									ItemFont, ItemAlign);

	if(GetGameSingle() != None && GetGameSingle().VerifySeqTime(true))
		ShellRootWindow(Root).bVerified = true;
	// Only add this option in after you've beaten the game
	// 8/15 - Kamek - moved this to MenuStart
	//if(ShellRootWindow(Root).bVerified)
	//	EnhancedChoice= AddChoice(EnhancedText,		"",									ItemFont, ItemAlign);
	LoadChoice    = AddChoice(LoadGameText,		OptionUnavailableInDemoHelpText,	ItemFont, ItemAlign);
	//MultiChoice   = AddChoice(MultiText,		"",									ItemFont, ItemAlign);
	if (FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
		DebugChoice = AddChoice(DebugText, DebugHelp, ItemFont, ItemAlign);
	
	if (GetGameSingle().IsHoliday(DLC_Holiday))
	{
		DLCChoice	= AddChoice(DLCText,		"",									ItemFont, ItemAlign);
		DLCChoice.SetTextColor(DLCTextColor);
	}
	
	OptionsChoice = AddChoice(OptionsText,		"",									ItemFont, ItemAlign);
	ExitChoice    = AddChoice(ExitGameText,		"",									ItemFont, ItemAlign);

	// 01/23/03 JMI Don't allow access to load or save in demos.
	//				NOTE: This only works for ShellMenuChoices--not actual controls.
	LoadChoice.bActive = !GetLevel().IsDemoBuild();

	// Reset this value. When MenuDifficultyPatch starts up, it's the only one that needs it
	// and it will set it when necessary.
	ShellRootWindow(Root).bFixSave=false;
	
	AddSocialIcons();
}


///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local bool bUseSuper;
	local bool bShowEnhanced;
	
	bUseSuper = true;
	switch(E)
	{
		case DE_Click:
			if (C != None)
				switch (C)
				{
					case NewChoice:
						// Start new game
						SetSingleplayer();
						ShellRootWindow(Root).bVerifiedPicked=false;
// xPatch: We use Game Mode menu now.						
/*						bShowEnhanced = bool(GetPlayerOwner().ConsoleCommand("get"@EnhancedPath));
						if (!bShowEnhanced
							&& GetGameSingle().SeqTimeVerified())
							GotoMenu(class'PLMenuEnhanced');
						else
							// Allow them to pick the difficulty
							GotoMenu(class'PLMenuStart');
*/
						GotoMenu(class'PLMenuGameMode');
						bUseSuper = false;
						break;
					case OptionsChoice:
						GoToMenu(class'PLMenuOptions');
						bUseSuper = false;
						break;
					case DebugChoice:
						Root.ShowModal(Root.CreateWindow(class'PLShellMapListFrame',
										(Root.WinWidth - CustomMapWidth) /2, 
										(Root.WinHeight - CustomMapHeight) /2, 
										CustomMapWidth, CustomMapHeight, self));
						bUseSuper = false;
						break;
				}
	}
	if (bUseSuper)
		Super.Notify(C, E);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	DebugText = "Start on Map..."
	DebugHelp = "(DEBUG) Starts new game on specified map on Monday. Skips difficulty, intro etc"
	CustomMapWidth	= 350
	CustomMapHeight	= 250
	PLTitleTex=Texture'PL_Product.PL_title'
}
