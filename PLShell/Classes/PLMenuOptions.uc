///////////////////////////////////////////////////////////////////////////////
// PLMenuOptions
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Options menu for Paradise Lost.
///////////////////////////////////////////////////////////////////////////////
class PLMenuOptions extends MenuOptions;

var string RollCreditsURL;
var Texture BlackBackground;
const UNLOCK_ACHIEVEMENT = 'PLJesusRun';

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super(ShellMenuCW).CreateMenuContents();
	
	AddTitle(OptionsText, TitleFont, TitleAlign);

	GameChoice			= AddChoice(GameOptionsText,	GameOptionsHelp,	ItemFont, ItemAlign);
	ControlsChoice		= AddChoice(ControlOptionsText, ControlOptionsHelp,	ItemFont, ItemAlign);
	VideoChoice			= AddChoice(VideoOptionsText,	VideoOptionsHelp,	ItemFont, ItemAlign);
	AudioChoice			= AddChoice(AudioOptionsText,	AudioOptionsHelp,	ItemFont, ItemAlign);
	PerformanceChoice	= AddChoice(PerformanceText,	PerformanceHelp,	ItemFont, ItemAlign);
		
	/*
	// Holiday stuff.
	if (GetPlayerOwner().GetEntryLevel().GetAchievementManager().GetAchievement(UNLOCK_ACHIEVEMENT))
	{
		UnlockedChoice	= AddChoice(UnlockedText,		UnlockedHelp,		ItemFont, ItemAlign);
	}
	else
	{
		LockedChoice	= AddChoice(LockedText,			LockedHelp,			ItemFont, ItemAlign);
	}
	*/
	
	if (GetLevel().IsSteamBuild())
		PurgeChoice			= AddChoice(PurgeText,			PurgeHelp,			ItemFont, ItemAlign);
	if (!GetLevel().IsDemoBuild())
		CreditsChoice	= AddChoice(CreditsText,		CreditsHelp,		ItemFont, ItemAlign);
	BackChoice			= AddChoice(BackText, "", ItemFont, ItemAlign, true);
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
					/*
					case GameChoice:
						GoToMenu(class'PLMenuGameSettings');
						bUseSuper = false;
						break;
					*/
					case AudioChoice:
						GoToMenu(class'PLMenuAudio');
						bUseSuper = false;
						break;
					case PerformanceChoice:
						GoToMenu(class'PLMenuPerformanceAdvanced');
						bUseSuper = false;
						break;
					case CreditsChoice:
						RollCredits();
						bUseSuper = false;
						break;
				}
	}
	if (bUseSuper)
		Super.Notify(C, E);
}

///////////////////////////////////////////////////////////////////////////////
// RollCredits
// Sends player to the credits map.
///////////////////////////////////////////////////////////////////////////////
function RollCredits()
{
	local P2GameInfoSingle UseGame;
	UseGame = GetGameSingle();

	UseGame.ForcedLoadTex = BlackBackground;
						GoBack();
						HideMenu();
	//P2RootWindow(Root).StartingGame();
	usegame.StopSceneManagers();
	UseGame.SendPlayerTo(UseGame.GetPlayer(), RollCreditsURL);
}

defaultproperties
{
	LockedText		= "??????????"
	LockedHelp		= "Beat 'Paradise Lost' with no kills to unlock this option!"
	RollCreditsURL	= "PL-Credits?Game=PLGame.CreditsGameInfo?Mutator=?Workshop=0"
	BlackBackground=Texture'Nathans.Inventory.BlackBox64'
}