///////////////////////////////////////////////////////////////////////////////
// AWMenuStart.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWMenuStart extends MenuStart;

var string StartGameURL;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function StartGame()
{
	local P2Player p2p;
	local P2GameInfoSingle usegame;

	usegame = GetGameSingle();
	p2p = usegame.GetPlayer();
	P2RootWindow(Root).StartingGame();

	// Stop any active SceneManager so player will have a pawn
	usegame.StopSceneManagers();

	usegame.PrepIniStartVals();
	usegame.TheGameState.bEGameStart = false;

	// Get the difficulty ready for this game state.
	usegame.SetupDifficultyOnce();

	// Get rid of any things in his inventory before a new game starts
	P2Pawn(p2p.pawn).DestroyAllInventory();

	// Game doesn't actually start until player is sent to first day,
	// which *should* happen at the end of the intro sequence.
	usegame.TheGameState.bChangeDayPostTravel = true;
	usegame.TheGameState.NextDay = 0;
	// Actually start the game with the first level
	usegame.SendPlayerTo(p2p, StartGameURL);
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local int val;

	Super(ShellMenuCW).Notify(C, E);
	switch(E)
		{
		case DE_Change:
			switch (C)
				{
				case DifficultyCombo:
					DiffChanged(bUpdate);
					break;
				}
			break;
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				case StartChoice:
					StartGame();
					ShellRootWindow(Root).bLaunchedMultiplayer = false;
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
     StartGameURL="MovieIntro.fuk?Game=AWWrapGame.AWGameSPFinal"
     astrTextureDetailNames(0)="UltraLow"
     astrTextureDetailNames(1)="Low"
     astrTextureDetailNames(2)="Medium"
     astrTextureDetailNames(3)="High"
}
