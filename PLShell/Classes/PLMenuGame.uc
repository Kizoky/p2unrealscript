///////////////////////////////////////////////////////////////////////////////
// PLMenuGame
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
class PLMenuGame extends MenuGame;

var ShellMenuChoice		DebugChoice;
var localized string	DebugText;
var localized string	DebugHelp;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
// DEBUG Rig cheats menu on, and also show debugging menu
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local String OptionsHelpText;
	local bool bOptionsActive;
	local String LoadHelpText;
	local String SaveHelpText;
	local bool bLoadActive;
	local bool bSaveActive;

	Super(BaseMenuBig).CreateMenuContents();

	bOptionsActive = true;
	bLoadActive = true;
	bSaveActive = true;

	if (GetGameSingle().IsCinematic())
		{
		OptionsHelpText = DisabledForCinematicHelpText;
		bOptionsActive = false;
		LoadHelpText = DisabledForCinematicHelpText;
		SaveHelpText = DisabledForCinematicHelpText;
		bLoadActive = false;
		bSaveActive = false;
		}

	if (!GetGameSingle().IsSaveAllowed(P2Player(GetPlayerOwner())))
		{
		bSaveActive = false;
		SaveHelpText = DisabledNowText;
		}

	// Check for demo last so this help text will override other help text
	if (GetLevel().IsDemoBuild())
		{
		LoadHelpText = OptionUnavailableInDemoHelpText;
		SaveHelpText = OptionUnavailableInDemoHelpText;
		bLoadActive = false;
		bSaveActive = false;
		}

	AddTitleBitmap(TitleTexture);
	if(GetGameSingle() != None && GetGameSingle().FinallyOver() && !GetLevel().IsDemoBuild())
		CheatsChoice	= AddChoice(CheatsText,		CheatsHelp,			ItemFont, ItemAlign);
	if (FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
		DebugChoice		= AddChoice(DebugText,		DebugHelp,			ItemFont, ItemAlign);
	SaveChoice		= AddChoice(SaveText,		SaveHelpText,		ItemFont, ItemAlign);
	LoadChoice		= AddChoice(LoadGameText,	LoadHelpText,		ItemFont, ItemAlign);
	OptionsChoice	= AddChoice(OptionsText,	OptionsHelpText,	ItemFont, ItemAlign);
	AchChoice		= AddChoice(AchText,		AchHelpText,		ItemFont, ItemAlign);
	QuitChoice		= AddChoice(QuitText,		"",					ItemFont, ItemAlign);
	DesktopQuitChoice = AddChoice(DesktopQuitText,	"",				ItemFont, ItemAlign);	// Added by Man Chrzan: xPatch 2.0 
	ResumeChoice	= AddChoice(ResumeText,		"",					ItemFont, ItemAlign);

	// Enable/disable various options (only works with MenuChoice)
	OptionsChoice.bActive = bOptionsActive;
	SaveChoice.bActive = bSaveActive;
	LoadChoice.bActive = bLoadActive;
	}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local bool bUseSuper;
	
	bUseSuper = true;

	switch(E)
	{
		case DE_Click:
			switch (C)
			{
				case CheatsChoice:
					GotoMenu(class'PLMenuCheats');
					bUseSuper = false;
					break;
				case OptionsChoice:
					GoToMenu(class'PLMenuOptions');
					bUseSuper = false;
					break;
				case DebugChoice:
					//GotoMenu(class'PLDebugMenu');
					LaunchDebugMenu();
					bUseSuper = false;
					break;
			}
			break;
	}
	
	if (bUseSuper)
		Super.Notify(C, E);
	else
		Super(BaseMenuBig).Notify(C, E);
}

function LaunchDebugMenu()
{
	local GameInfo GameInfo;
	GameInfo = GetPlayerOwner().Level.Game;
	if (TWPGameInfo(GameInfo) != None)
		GotoMenu(class'PLDebugMenu_TwoWeeks');
	else 
		GotoMenu(class'PLDebugMenu');
}

defaultproperties
{
	DebugText="Debug"
	DebugHelp="Various features for debug/QA purposes."
}