///////////////////////////////////////////////////////////////////////////////
// PLRootWindow
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Root window for Paradise Lost.
///////////////////////////////////////////////////////////////////////////////
class PLRootWindow extends ShellRootWindow;

const COPYRIGHT_TEXT_X			= 0.98;
const COPYRIGHT_TEXT_Y			= 0.94;
const MUSIC_TEXT_X				= 0.98;
const MUSIC_TEXT_Y				= 0.96;

///////////////////////////////////////////////////////////////////////////////
// Call this to quit the current game.
// This only works in game menu mode.
///////////////////////////////////////////////////////////////////////////////
function QuitCurrentGame()
{
	// DIRTY, DIRTY HACK. When quitting a credits game we want to completely get rid of it and go back to a regular PLGameInfo
	// But some flags aren't set properly and it breaks the main menu, so we do that here.
	if (CreditsGameInfo(GetGameSingle()) != None)
	{
		EndingGame();
		bDontPauseOrUnPause = true;
		bMainMenuShownViaESC = false;
	
		// Use the console command version here, we want to completely discard the credits gameinfo and start fresh in a PLGameInfo.
		GetPlayerOwner().ConsoleCommand("open startup?Game=PLGame.PLGameInfo");
	}
	else
		Super.QuitCurrentGame();
}

///////////////////////////////////////////////////////////////////////////////
// Display stuff
///////////////////////////////////////////////////////////////////////////////
function PostRender(canvas Canvas)
	{
	local int i;
	local float XL, YL, YPos;
	local string CurrentLevel;
	local LevelInfo LI;

	// If we're in entry, hide the level with a background for multiplayer only
	LI = Root.GetLevel();
	CurrentLevel = ParseLevelName(LI.GetLocalURL());
	if(Right(CurrentLevel, 4) ~= ".fuk")
		CurrentLevel = Left(CurrentLevel, Len(CurrentLevel) - 4);
	if((CurrentLevel ~= "Entry" || CurrentLevel ~= "Index") && bLaunchedMultiplayer)
		{
		if(LoadingTexture.USize == 0 || LoadingTexture.VSize == 0)
		{
			i = InStr(LoadingTexture, ".");
			SetLoadingTexture(Left(LoadingTexture, i));
		}
		Canvas.Style = 1; //ERenderStyle.STY_Normal;
		Canvas.SetDrawColor(255, 255, 255, 255);
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(LoadingTexture, Canvas.ClipX, Canvas.ClipY, 0, 0, LoadingTexture.USize, LoadingTexture.VSize);

		if(MenuConnecting(MyMenu) != None && Root.GetLevel().LevelAction == LEVACT_Connecting)
		{
			MyMenu.Close();
			MyMenu = None;
			HideMenu();
		}

			// Check if we're connecting and show connecting or loading text
		if(!IsInState('MenuShowing'))
			{
			if ( Root.GetLevel().LevelAction == LEVACT_Connecting )
				DrawStatusMessage(Canvas, ConnectingMessage);
			else
				{
				DrawStatusMessage(Canvas, LoadingMessage);
				if(!bDisabled)
					DisableMenu();
				}
			}
		bShowedLoadTexture = true;
		}
	else if(bShowedLoadTexture && CAPS(CurrentLevel) != CAPS(GetStartupMap()))
	{
		LoadingTexture = Default.LoadingTexture;
		bShowedLoadTexture = false;
	}
	
	// Draw Workshop status updates always, no matter what's happening
	DrawWorkshopStatus(Canvas);

	if(IsInState('MenuShowing'))
		{
		Super(P2RootWindow).PostRender(Canvas);

		if (MyFont == None)
			MyFont = FontInfo(ViewportOwner.Actor.spawn(Class<Actor>(DynamicLoadObject(FontInfoClass, class'Class')),ViewportOwner.Actor));
	/*
		Canvas.SetDrawColor(255, 255, 255, 255);
		for (XL = 0.0; XL < 1.0; XL += 0.025)
			{
			Canvas.SetPos(0, 0);
			Canvas.DrawVertical(XL * Canvas.ClipX, Canvas.ClipY);
			}

		YPos = 0.1 * Canvas.ClipX;
		for (i = 0; i < 4; i++)
			{
			MyFont.GetStringSize(Canvas, "M", i, false, XL, YL);
			MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.1 * Canvas.ClipX, YPos, "Fancy"$i, i, false);
			YPos += YL + 2;
			MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.1 * Canvas.ClipX, YPos, "Plain"$i, i, true);
			YPos += YL + 2;
			}
	*/

//		DrawPreMsg(Canvas);

		// Display info about installed game
		if (MyMenu.class == GetMainMenuClass() || MyMenu.class == class'MenuGame')
			{
			MyFont.DrawTextEx(
				Canvas,
				Canvas.ClipX,
				VERSION_TEXT_X * Canvas.ClipX,
				VERSION_TEXT_Y * Canvas.ClipY,
				InstalledDescription$"-"$EngineVersion$HotfixText,
				0, true, EJ_Left);

			MyFont.DrawTextEx(
				Canvas,
				Canvas.ClipX,
				COPYRIGHT_TEXT_X * Canvas.ClipX,
				COPYRIGHT_TEXT_Y * Canvas.ClipY,
				"Copyright 2003-2015 RWS  All Rights Reserved",
				0, true, EJ_Right);

				MyFont.DrawTextEx(
				Canvas,
				Canvas.ClipX,
				MUSIC_TEXT_X * Canvas.ClipX,
				MUSIC_TEXT_Y * Canvas.ClipY,
				"Seek Irony - www.SeekIrony.com",
				0, true, EJ_Right);
			}
		
		if (HelpText != "")
			{
			MyFont.DrawTextEx(
				Canvas,
				Canvas.ClipX,
				COPYRIGHT_TEXT_X * Canvas.ClipX,
				COPYRIGHT_TEXT_Y * Canvas.ClipY,
				HelpText,
				0, true, EJ_Right);
			}

		if (bPrecache)
			{
			// Hide precache by covering the screen with a black box
			Canvas.Style = 1; //ERenderStyle.STY_Normal;
			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.SetPos(0, 0);
			Canvas.DrawTile(BlackBox, Canvas.SizeX, Canvas.SizeY, 0, 0, BlackBox.USize, BlackBox.VSize);

			bDidPrecache = true;
			}
		}
	}

	
///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	EngineVersion="5025"
	HotfixText=""
	bBuildDateAsHotfixText=false
}
