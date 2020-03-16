///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShellRootWindow.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the root window for our menu system.
//
///////////////////////////////////////////////////////////////////////////////
//
// Note: UWindowRootWindow is hardwired use IK_ESC to close it.
//
///////////////////////////////////////////////////////////////////////////////
class ShellRootWindow extends P2RootWindow
	config;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var ShellMenuCW					MyMenu;
var bool						bShowedEULA;
var bool						bMainMenuShownViaESC;
var bool						bGameMenu;
var bool						bVirgin;
var bool						bPrecache;
var bool						bDidPrecache;
var bool						bLaunchedMultiplayer;
// Disable the menu for level changes
var bool						bDisabled;
var float						DisableMenuTimer;
const							DISABLE_MENU_TIME = 20;

var Texture						LoadingTexture;
var localized string			ConnectingMessage;
var localized string			LoadingMessage;
var bool						bShowedLoadTexture;
var bool						bLockErrorWindow;

var string						FontInfoClass;			// which FontInfo class to use
var FontInfo					MyFont;					// current FontInfo (various sizes, etc)

var globalconfig String			InstalledTitle;
var globalconfig String			InstalledType;
var globalconfig String			InstalledCountry;
var globalconfig String			InstalledVersion;
var String						EngineVersion;
var String						InstalledDescription;
var String						HotfixText;
var bool						bBuildDateAsHotfixText;

var /*globalconfig*/ String			MinRes;					// Minimum res that menu system will fit into
var String						LowGameRes;				// Res to use for game if less than MinRes

var array<class<ShellMenuCW> >	BackStack;				// Stack used to implement "go back" functionality

var class<ShellMenuCW>			BeatDemoMenu;			// Menu you get to sent to when you beat the demo
var class<ShellMenuCW>			TimedOutDemoMenu;		// Menu you get when you just timed out the demo (didn't beat it)
var class<ShellMenuCW>			ArrestedDemoMenu;		// Menu you get when you get arrested in demo.
var class<ShellMenuCW>			DifficultyPatchMenu;	// Menu letting you set difficulty on old saves.

var bool						bVerified;				// Good to go
var bool						bVerifiedPicked;		// picking it

var Texture						BlackBox;				// Blacks out some screen for text to show up better

var bool						bFixSave;				// If true, we need to fix an old saved game

var UWindowWindow				openWindow;				// Current Join Browser Window or Host Server Window
var bool						bClosing;				// In middle of closing browser window

var string HelpText;

var float						PreMsgX;
var float						PreMsgY;
var float						PreMsgDX;
var float						PreMsgDY;

// No longer used -- define startup map in the gameinfo, so custom games can hook into this
//var string						StartupMapName;

const VERSION_TEXT_X			= 0.02;
const VERSION_TEXT_Y			= 0.96;
const COPYRIGHT_TEXT_X			= 0.98;
const COPYRIGHT_TEXT_Y			= 0.96;
const WORKSHOP_TEXT_X			= 0.02;
const WORKSHOP_TEXT_Y			= 0.02;

// Backport from aw7
var bool bEnhancedMode;
var bool bNoHolidays;
var string StartGameURL;
var int DayToShowDuringLoad;

// blah
var bool bHandledConfirm;

var localized string			WorkshopStatus;

///////////////////////////////////////////////////////////////////////////////
// Get startup map
///////////////////////////////////////////////////////////////////////////////
function string GetStartupMap()
{
	//log("get startup map:"@GetGameSingle().MainMenuURL);
	return GetGameSingle().MainMenuURL;
}

///////////////////////////////////////////////////////////////////////////////
// Called after this object has been created
///////////////////////////////////////////////////////////////////////////////
event Initialized()
	{
	Super.Initialized();

	// Insert install info into the log to make tech support a little easier
	// Leave version out of the description until we can access the LevelInfo
	InstalledDescription = InstalledTitle$": "$InstalledType$"-"$GetCountryCode();

	Log(InstalledDescription$"-"$InstalledVersion);

	bVirgin = true;
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system that a game is starting.
///////////////////////////////////////////////////////////////////////////////
function StartingGame()
	{
	HideMenu();
	bGameMenu = true;
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system that a game is ending.
///////////////////////////////////////////////////////////////////////////////
function EndingGame()
	{
	HideMenu();
	bGameMenu = false;
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system that demo has been beaten.
///////////////////////////////////////////////////////////////////////////////
function BeatDemo()
	{
	JumpToMenu(BeatDemoMenu);
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system that demo has timed out.
///////////////////////////////////////////////////////////////////////////////
function TimedOutDemo()
	{
	JumpToMenu(TimedOutDemoMenu);
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system that player is arrested and therefore
// done with the demo
///////////////////////////////////////////////////////////////////////////////
function ArrestedDemo()
	{
	JumpToMenu(ArrestedDemoMenu);
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to tell menu system when and Old save needs it's difficulty patched.
///////////////////////////////////////////////////////////////////////////////
function DifficultyPatch()
	{
	JumpToMenu(DifficultyPatchMenu);
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetHelp(String str)
{
	HelpText = str;
}

///////////////////////////////////////////////////////////////////////////////
// Determine whether any menu is showing
///////////////////////////////////////////////////////////////////////////////
function bool IsMenuShowing()
	{
	return IsInState('MenuShowing');
	}
	
function bool IsMainMenuShowing()
{
	return (IsInState('MainMenuShowing')
		|| IsInState('MainMenuShowingVirgin'));
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if current menu wants to block the console from being opened.
// The primary reason for blocking the consoles is if the user may need to
// press a key while on the menu and that happens to be the same key that
// brings up the console(s).  For example, TAB brings up the console by
// default, but it is also used to move from control to control in some menus.
///////////////////////////////////////////////////////////////////////////////
function bool MenuBlocksConsole()
{
	if (IsMenuShowing())
	{
		if (openWindow != None)
			return true;

		if (MyMenu != None && MyMenu.WindowIsVisible() && MyMenu.bBlockConsole)
			return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if current menu wants to use menu sound effects.
///////////////////////////////////////////////////////////////////////////////
function bool UseLookAndFeelSounds()
{
	return openWindow == None;
}

///////////////////////////////////////////////////////////////////////////////
// Call this to toggle between main and game menus (intended as a cheat)
///////////////////////////////////////////////////////////////////////////////
function MenuMode()
	{
	HideMenu();
	bGameMenu = !bGameMenu;
	// CRK: ShowMenu sets bGameMenu, so we can't call it
	//ShowMenu();
	if (bGameMenu)
		GotoState('GameMenuShowing');
	else
		GotoState('MainMenuShowing');
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to display the specified menu.
///////////////////////////////////////////////////////////////////////////////
function JumpToMenu(class<ShellMenuCW> MenuClass)
	{
	// Show the normal menu first so that "Back" buttons will work on the
	// specified menu (in case it has any)
	ShowMenu();

	// Now go to the specified menu
	GotoMenu(MyMenu.class, MenuClass);
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to display the specified menu,
// clearing out any menus the user has gone through.
///////////////////////////////////////////////////////////////////////////////
function FreshJumpToMenu(class<ShellMenuCW> MenuClass)
	{
	// Close the open window before we jump to the new one
	if(openWindow != None && !bClosing)
	{
		bClosing = true;
		openWindow.Close();
		openWindow = None;
		bClosing = false;
	}

	// Wipe out any menus the user has gone through
	if(BackStack.Length > 0)
		BackStack.Remove(0, BackStack.Length);

	HideMenu();
	
	JumpToMenu(MenuClass);
	}

///////////////////////////////////////////////////////////////////////////////
// Determine whether the game menu is the current menu.  This does not
// indicate whether it's showing or hiding, just that it's the current menu.
///////////////////////////////////////////////////////////////////////////////
function bool IsGameMenu()
	{
	return bGameMenu;
	}

///////////////////////////////////////////////////////////////////////////////
// Determine whether the menu system is in virgin (unused) condition.
// This will be true until any menu is shown, after which it will be false
// until the app exits.
///////////////////////////////////////////////////////////////////////////////
function bool IsVirgin()
	{
	return bVirgin;;
	}

///////////////////////////////////////////////////////////////////////////////
// Jump to the specified menu.  Brings up menu immediately.
///////////////////////////////////////////////////////////////////////////////
function GoToMenu(class<ShellMenuCW> CurrentMenu, class<ShellMenuCW> NewMenu)
	{
	local int i;
	
	// Push current menu onto stack
	if(CurrentMenu != None)
	{
		i = BackStack.length;
		BackStack.insert(i, 1);
		BackStack[i] = CurrentMenu;
	}
	
	// Create new menu and show it
	CreateMenu(NewMenu);
	MyMenu.ShowWindow();
	
	LastConfirmTime=0;
	LastBackTime=0;
	}

///////////////////////////////////////////////////////////////////////////////
// Jump to the specified window and hide the previous menu.
///////////////////////////////////////////////////////////////////////////////
function GoToWindow(UWindowWindow newWindow)
{
	if (MyMenu != None)
		MyMenu.HideWindow();
	openWindow = newWindow;
	LastConfirmTime=0;
	LastBackTime=0;
}

///////////////////////////////////////////////////////////////////////////////
// Jump to the password menu for joining a server.
///////////////////////////////////////////////////////////////////////////////
function GoToPasswordWindow(string URL)
{
	if(MenuError(MyMenu) != None)
		MyMenu.Close();

	// If the user cancels, let them go back to the multiplayer menu
	if(IsGameMenu())
		FreshJumpToMenu(class'MenuGameMulti');
	else
		FreshJumpToMenu(class'MenuMulti');

	GoToMenu(MyMenu.class, class'MenuPassword');

	MenuPassword(MyMenu).URL = URL;
	LastConfirmTime=0;
	LastBackTime=0;
}

///////////////////////////////////////////////////////////////////////////////
// Jump to the error window for handling server disconnect errors.
///////////////////////////////////////////////////////////////////////////////
function GoToErrorWindow(string Msg1, string Msg2, optional bool bLock)
{
	if(bLockErrorWindow || MenuPassword(MyMenu) != None || MenuUpgrade(MyMenu) != None)
		return;

	// Already have error window open, just set new messages
	if(MenuError(MyMenu) != None)
	{
		if((Msg1 != "" && MenuError(MyMenu).Msg1 != Msg1) || (Msg2 != "" && MenuError(MyMenu).Msg2 != Msg2))
			MenuError(MyMenu).SetupMessageBox(Msg1, Msg2);
		return;
	}

	FreshJumpToMenu(class'MenuError');

	MenuError(MyMenu).SetupMessageBox(Msg1, Msg2);

	if(bLock)
		bLockErrorWindow = true;
	LastConfirmTime=0;
	LastBackTime=0;
}

///////////////////////////////////////////////////////////////////////////////
// Connecting Menu for just before joining a server.
///////////////////////////////////////////////////////////////////////////////
function GoToConnectingWindow(string Msg1, string Msg2, bool bDownloading)
{
	if(MenuError(MyMenu) != None || MenuUpgrade(MyMenu) != None || MenuPassword(MyMenu) != None)
		return;

	if(MenuConnecting(MyMenu) != None)
	{
		if(InStr(Caps(Msg2), Caps("Index")) == -1)
			MenuConnecting(MyMenu).SetStatus(Msg1, Msg2, bDownloading);
		return;
	}

	FreshJumpToMenu(class'MenuConnecting');

	SetLoadingTexture(Msg2);
	MenuConnecting(MyMenu).SetStatus(Msg1, Msg2, bDownloading);
	LastConfirmTime=0;
	LastBackTime=0;
}

///////////////////////////////////////////////////////////////////////////////
// Upgrade menu when outdated client tries to join an updated server.
///////////////////////////////////////////////////////////////////////////////
function GoToUpgradeWindow()
{
	FreshJumpToMenu(class'MenuUpgrade');
	LastConfirmTime=0;
	LastBackTime=0;
}

///////////////////////////////////////////////////////////////////////////////
// Go back to the previous menu.
///////////////////////////////////////////////////////////////////////////////
function GoBack()
	{
	local int i;
	local class<ShellMenuCW> BackMenu;

	if(openWindow != None)
	{
		if(bClosing)
			return;
		bClosing = true;
		openWindow.Close();
		bClosing = false;
		openWindow = None;
		MyMenu.ShowWindow();
		return;
	}

	// Pop menu off stack
	i = BackStack.length - 1;
	if (i >= 0)
		{
		BackMenu = BackStack[i];
		BackStack.remove(i, 1);
		
		// Create menu and show it
		CreateMenu(BackMenu);
		MyMenu.ShowWindow();
		MyMenu.RestoreMousePos();
		}
	LastConfirmTime=0;
	LastBackTime=0;
	}

///////////////////////////////////////////////////////////////////////////////
// Precache menu
///////////////////////////////////////////////////////////////////////////////
function Precache()
	{
	if (!bDidPrecache)
		{
		bPrecache = true;
		ShowMenu();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Show menu
///////////////////////////////////////////////////////////////////////////////
function ShowMenu()
	{
	local string CurrentLevel;
	local bool bWasVirgin;
	local DudePlayer DP;

	bWasVirgin = bVirgin;
	if(!bPrecache)
		bVirgin = false;

	// if we're in startup, show main menu, otherwise, show in-game menu
	CurrentLevel = ParseLevelName(Root.GetLevel().GetLocalURL());
	if(Right(CurrentLevel, 4) ~= ".fuk")
		CurrentLevel = Left(CurrentLevel, Len(CurrentLevel) - 4);
	if(CurrentLevel ~= GetStartupMap())
		bGameMenu = false;
	else
		bGameMenu = true;

	if (bGameMenu)
		GotoState('GameMenuShowing');
	else if (bWasVirgin)
		GotoState('MainMenuShowingVirgin');
	else
		GotoState('MainMenuShowing');
	LastConfirmTime=0;
	LastBackTime=0;
	
	// Shut off the weapon selector, if any
	DP = DudePlayer(GetPlayerOwner());
	if (DP != None)
		DP.HideWeaponSelector();
	}

///////////////////////////////////////////////////////////////////////////////
// Hide menu
///////////////////////////////////////////////////////////////////////////////
function HideMenu()
	{
	if(openWindow != None && !bClosing)
		{
		bClosing = true;
		openWindow.Close();
		openWindow = None;
		bClosing = false;
		}

	GotoState('');
	LastConfirmTime=0;
	LastBackTime=0;
	bUsingJoystick = false;
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to quit the current game.
// This only works in game menu mode.
// NOTE: This is very different from Super.QuitGame()!
///////////////////////////////////////////////////////////////////////////////
function QuitCurrentGame()
	{
	local string GamePath;

	if (IsGameMenu())
		{
		// Kill cinematics
		ViewportOwner.Actor.ConsoleCommand("CINEMATICS 0");
		if(GetGameSingle() != None)							// SINGLEPLAYER
			GetGameSingle().QuitGame();
		else												// MULTIPLAYER
			{
			GetPlayerOwner().ConsoleCommand("disconnect");
			EndingGame();
			// RWS FIXME: Read the game type value from ini
			GamePath = "GameTypes.GameSinglePlayer";
			GetPlayerOwner().ClientTravel(GetStartupMap()$".fuk?Mutator=?Workshop=0?Game=" $ GamePath, TRAVEL_Absolute, false);
			//ConsoleCommand("open Startup.fuk?Game=Postal2Game.P2GameInfoSingle");
			}
		}
	LastConfirmTime=0;
	LastBackTime=0;
	}

///////////////////////////////////////////////////////////////////////////////
// Call this to exit the app
///////////////////////////////////////////////////////////////////////////////
function ExitApp()
	{
	// UWindowRootWindow uses different nomenclature -- this means exit app
	Super.QuitGame();
	}

///////////////////////////////////////////////////////////////////////////////
// Get single player gameinfo
///////////////////////////////////////////////////////////////////////////////
function P2GameInfoSingle GetGameSingle()
	{
	return P2GameInfoSingle(Root.GetLevel().Game);
	}

///////////////////////////////////////////////////////////////////////////////
// Create the main(root) menu for the current level.
///////////////////////////////////////////////////////////////////////////////
function CreateMenu(class<ShellMenuCW> clsMenu)
	{
	local int iMenuW;
	local int iMenuH;
	
	if (MyMenu != None)
		MyMenu.HideWindow();
	
	iMenuW = 100;
	iMenuH = 100;
	
	MyMenu = ShellMenuCW(CreateWindow(
		clsMenu,
		WinLeft + WinWidth / 2 - iMenuW / 2, 
		WinTop + WinHeight / 2 - iMenuH / 2, 
		iMenuW, iMenuH));
	
	// Make sure it's hidden initially.
	MyMenu.HideWindow();
	LastConfirmTime=0;
	LastBackTime=0;
	}

///////////////////////////////////////////////////////////////////////////////
// Called when window is created
///////////////////////////////////////////////////////////////////////////////
function Created() 
	{
	Super.Created();

	// Simulate resizing to get everything to adjust properly
	Resized();
	
	// Update hotfix text
	if (bBuildDateAsHotfixText)
		HotfixText = HotfixText$"("$GetBuildDate()$")";
	LastConfirmTime=0;
	LastBackTime=0;
	}

///////////////////////////////////////////////////////////////////////////////
// Called when this window is resized
///////////////////////////////////////////////////////////////////////////////
function Resized()
	{
	Super.Resized();
	}

///////////////////////////////////////////////////////////////////////////////
// Called by UWindowRootWindow a short time after QuitGame() is called.
// This quits the entire app, not just the current game.
///////////////////////////////////////////////////////////////////////////////
function DoQuitGame()
	{
	if(MyMenu != None)
		MyMenu.SaveConfig();
	if (Root.GetLevel().Game != None)
		{
		Root.GetLevel().Game.SaveConfig();
		Root.GetLevel().Game.GameReplicationInfo.SaveConfig();
		}
	Super.DoQuitGame();
	}

///////////////////////////////////////////////////////////////////////////////
// Setup our fonts. 
///////////////////////////////////////////////////////////////////////////////
function SetupFonts()
	{
	// Let's avoid calling the super class to avoid unnecessary 
	// loads.  But, if we need to do it, we should do it before our loads
	// so they can fill gaps.
	if(GUIScale == 2)
		{
		Fonts[F_Small]     = Font(DynamicLoadObject("P2Fonts.Plain19", class'Font'));
		Fonts[F_SmallBold] = Font(DynamicLoadObject("P2Fonts.Plain20", class'Font'));
		Fonts[F_Normal]    = Font(DynamicLoadObject("P2Fonts.Plain24", class'Font'));
		Fonts[F_Bold]      = Font(DynamicLoadObject("P2Fonts.Plain30", class'Font'));
		Fonts[F_Large]     = Font(DynamicLoadObject("P2Fonts.Plain38", class'Font'));
		Fonts[F_LargeBold] = Font(DynamicLoadObject("P2Fonts.Plain48", class'Font'));
		
		Fonts[F_FancyS]    = Font(DynamicLoadObject("P2Fonts.Fancy24", class'Font'));
		Fonts[F_FancyM]    = Font(DynamicLoadObject("P2Fonts.Fancy30", class'Font'));
		Fonts[F_FancyL]    = Font(DynamicLoadObject("P2Fonts.Fancy38", class'Font'));
		Fonts[F_FancyXL]   = Font(DynamicLoadObject("P2Fonts.Fancy48", class'Font'));
		}
	else
		{
		Fonts[F_Small]     = Font(DynamicLoadObject("P2SmallFonts.Plain10", class'Font'));
		Fonts[F_SmallBold] = Font(DynamicLoadObject("P2SmallFonts.Bold12", class'Font'));
		Fonts[F_Normal]    = Font(DynamicLoadObject("P2Fonts.Plain15", class'Font'));
		Fonts[F_Bold]      = Font(DynamicLoadObject("P2Fonts.Plain19", class'Font'));
		Fonts[F_Large]     = Font(DynamicLoadObject("P2Fonts.Plain24", class'Font'));
		Fonts[F_LargeBold] = Font(DynamicLoadObject("P2Fonts.Plain30", class'Font'));
		
		Fonts[F_FancyS]    = Font(DynamicLoadObject("P2Fonts.Fancy15", class'Font'));
		Fonts[F_FancyM]    = Font(DynamicLoadObject("P2Fonts.Fancy19", class'Font'));
		Fonts[F_FancyL]    = Font(DynamicLoadObject("P2Fonts.Fancy24", class'Font'));
		Fonts[F_FancyXL]   = Font(DynamicLoadObject("P2Fonts.Fancy30", class'Font'));
		}	
	}

///////////////////////////////////////////////////////////////////////////////
// Handle a key event
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
	local bool bBlockESC;
	local SceneManager SM;
	
	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_Escape:
				// If the menu's disabled (for level changes), don't show it
				if(bDisabled)
				{
					//Log("ESC pressed, but Menu is disabled. DisableTimer="$DisableMenuTimer$" LevelTime="$Root.GetLevel().TimeSeconds);
					return true;
				}
				// If single player, handle normally, otherwise we're in multiplayer and can bring up the in-game menu
				if(GetGameSingle() != None)
				{
					// Don't let user bring up the menu during any special maps
					if (GetGameSingle() != None && (GetGameSingle().IsPreGame() || GetGameSingle().IsFinishedDayMap()))
						bBlockESC = true;
		
					// Don't let user bring up the menu if any P2Screens are running
					if (P2Player(ViewportOwner.Actor).CurrentScreen != None)
						bBlockESC = true;
						
					// Don't let user being up the menu if the Inventory Selector is up
					// but don't block the key entirely, the Inventory Selector needs it to close.
					if (DudePlayer(ViewportOwner.Actor).InventoryMenuVisible())
						return false;
						
					// Don't let user bring up menu if SceneManager forbids pausing
					SM = ViewportOwner.Actor.GetCurrentSceneManager();
					if (SM != None
						&& SM.bForbidPausing)
						bBlockESC = true;

					// If allowed then bring up the menu
					if (!bBlockESC)
						{
						if (!IsGameMenu())
							bMainMenuShownViaESC = true;
						ShowMenu();
						}
					return true;
				}
				else
				{
					ShowMenu();
					return true;
				}
				break;
			}
		}
	
	// Otherwise let super handle it
	return Super.KeyEvent(Key,Action,Delta);
	}

function PreRender( canvas Canvas )
	{
	if(IsInState('MenuShowing'))
		Super.PreRender(Canvas);
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
		Super.PostRender(Canvas);

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

function DrawStatusMessage(canvas Canvas, string StatusMessage)
	{
	local float XL, YL;

	Canvas.Font = Fonts[F_FancyXL];
	Canvas.bCenter = false;
	Canvas.StrLen( StatusMessage, XL, YL );
	Canvas.SetPos(0.5 * (Canvas.ClipX - XL) + 2, 0.5 * (Canvas.ClipY - YL) + 2);
	Canvas.SetDrawColor(0,0,0);
	Canvas.DrawText( StatusMessage, false );
	Canvas.SetPos(0.5 * (Canvas.ClipX - XL), 0.5 * (Canvas.ClipY - YL));
	Canvas.SetDrawColor(200,0,0);
	Canvas.DrawText( StatusMessage, false );
	}

function DrawPreMsg(Canvas Canvas)
	{
	local byte OldStyle;
	local string Line1, Line2;
	local float w1, h1, w2, h2, w, h, SpacingY;

	Line1 = "BETA TEST";
	Line2 = "NOT FOR PUBLIC RELEASE";
	Canvas.Font = MyFont.GetFont(3, false, Canvas.ClipX);
	Canvas.TextSize(Line1, w1, h1);
	SpacingY = h1 * 0.25;
	Canvas.Font = MyFont.GetFont(2, false, Canvas.ClipX);
	Canvas.TextSize(Line2, w2, h2);
	w += Max(w1, w2);
	h += h1 + h2 + SpacingY;

	Canvas.Style = 5; //ERenderStyle.STY_Alpha;
	Canvas.SetDrawColor(255, 255, 0, 128);
	Canvas.SetPos(PreMsgX + ((w - w1) / 2), PreMsgY);
	Canvas.DrawText(Line1);
	Canvas.SetPos(PreMsgX + ((w - w2) / 2), PreMsgY + h1 + SpacingY);
	Canvas.DrawText(Line2);
	
	Canvas.Style = OldStyle;

	PreMsgX += PreMsgDX;
	if (PreMsgX < 0 || (PreMsgX + w) >= Canvas.ClipX)
		PreMsgDX = -PreMsgDX;
	PreMsgY += PreMsgDY;
	if (PreMsgY < 0 || (PreMsgY + h) >= Canvas.ClipY)
		PreMsgDY = -PreMsgDY;
	}

function DrawWorkshopStatus(Canvas Canvas)
{
	local string WSStatus;
	local float w1, h1, w2, h2, w, h, SpacingY;

	WSStatus = Root.GetLevel().SteamGetWorkshopStatus();
	if (WSStatus != "")
	{
		MyFont.DrawTextEx(
			Canvas,
			Canvas.ClipX,
			WORKSHOP_TEXT_X * Canvas.ClipX,
			WORKSHOP_TEXT_Y * Canvas.ClipY,
			WorkshopStatus@WSStatus,
			1, true, EJ_Left);
	}
}

function Tick(float Delta)
	{
	if(IsInState('MenuShowing'))
	{
		Super.Tick(Delta);

		// Propogate the tick through the window hierarchy
		if (MyMenu != None)
			MyMenu.DoTick(Delta);
		if (ModalWindow != None)
			ModalWindow.DoTick(Delta);

		if (bPrecache && bDidPrecache)
			{
			bPrecache = false;
			HideMenu();
			}
	}

	if (bDisabled &&
		(MenuConnecting(MyMenu) == None) &&
		//(!MyMenu.WindowIsVisible()) &&
		(Root.ViewportOwner.Actor != None && Root.GetLevel() != None) &&
		(Root.GetLevel().LevelAction != LEVACT_Connecting) && 
		(Root.GetLevel().LevelAction != LEVACT_Loading) &&
		(Root.GetLevel().TimeSeconds < 20 || Root.GetLevel().TimeSeconds > DisableMenuTimer))
			EnableMenu();
	}

///////////////////////////////////////////////////////////////////////////////
// Get and set game resolution, which may be different from menu resolution.
///////////////////////////////////////////////////////////////////////////////
function SetLowGameRes(String LowRes)
	{
	LowGameRes = LowRes;
	}

function ClearLowGameRes()
	{
	LowGameRes = "";
	}

function String GetLowGameRes()
	{
	return LowGameRes;
	}

///////////////////////////////////////////////////////////////////////////////
// Check if specified resolution (ex: 320x240) is less than the minimum menu
// resolution.
///////////////////////////////////////////////////////////////////////////////
function bool IsBelowMinRes(String Res)
	{
	local bool bBelow;

	return (int(Left(Res, InStr(Res, "x"))) < int(Left(MinRes, InStr(MinRes, "x"))));
	}
	
///////////////////////////////////////////////////////////////////////////////
// function to get the main menu class as defined by either the gametype
// or the default main menu
///////////////////////////////////////////////////////////////////////////////
function class<BaseMenuBig> GetMainMenuClass()
{
	local class<BaseMenuBig> MainMenuClass;
	
	if (GetGameSingle() == None)
		return None;

	// Allow workshop games to define their own menus.
	if (IsInState('MainMenuShowingVirgin'))
		// If in the 'virgin' main menu, bring up the game's StartMenuClass if it has one.		
		MainMenuClass = class<BaseMenuBig>(DynamicLoadObject(String(GetGameSingle().StartMenuName), class'Class'));
	else
		MainMenuClass = class<BaseMenuBig>(DynamicLoadObject(String(GetGameSingle().MainMenuName), class'Class'));

	if (MainMenuClass != None)
		return MainMenuClass;
	else
		return class'MenuMain';
}

///////////////////////////////////////////////////////////////////////////////
// Confirm button: issue mouse click
///////////////////////////////////////////////////////////////////////////////
function execConfirmButton()
{
	local UWindowWindow CurrentWindow;
	local float MouseX, MouseY;
	local UWindowMessageBox Box;
	local UWindowMessageBoxCW BoxCW;
	
	//log(self@"hit Confirm on"@MouseWindow@"open window is"@OpenWindow@"modal"@ModalWindow);
	
	// ShellMenuCW handled this action, don't do it here too.
	if (bHandledConfirm)
	{
		bHandledConfirm = false;
		return;
	}
	
	CurrentWindow = MouseWindow;
	
	// Ignore if no modal present (otherwise the ShellMenuCW handles it)
	if (ModalWindow == None)
		return;
		
	//log("ROOT: hit confirm on"@CurrentWindow@"open window is"@OpenWindow@"modal"@ModalWindow);

	// If the current window is NOT a button, close modal with default option
	if (UWindowButton(CurrentWindow) == None)	
	{
		if (UWindowMessageBox(ModalWindow) != None)
		{
			Box = UWindowMessageBox(ModalWindow);
			BoxCW = UWindowMessageBoxCW(Box.ClientArea);
			Box.Result = BoxCW.EnterResult;
		}
		ModalWindow.Close();
	}
	else
	{
		// convert global root coordinates to window coordinates
		CurrentWindow.GlobalToWindow(Root.MouseX, Root.MouseY, MouseX, MouseY);
		
		CurrentWindow.LMouseDown(MouseX, MouseY);
		CurrentWindow.LMouseUp(MouseX, MouseY);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Cancel button: choose non-default option on modal
///////////////////////////////////////////////////////////////////////////////
function execBackButton()
{
	local UWindowWindow CurrentWindow;
	local UWindowMessageBox Box;
	local UWindowMessageBoxCW BoxCW;
	
	CurrentWindow = MouseWindow;
	
	//log(self@"hit Back on"@CurrentWindow@"open window is"@OpenWindow@"modal"@ModalWindow);
	
	// Ignore if no modal present (otherwise the ShellMenuCW handles it)
	if (ModalWindow == None)
		return;		

	// If the current window is NOT a button, close modal with NON-default option
	if (UWindowButton(CurrentWindow) == None)	
	{
		if (UWindowMessageBox(ModalWindow) != None)
		{
			Box = UWindowMessageBox(ModalWindow);
			BoxCW = UWindowMessageBoxCW(Box.ClientArea);
			
			switch (BoxCW.Buttons)
			{
				// Not used in P2 but we'll try to account for it anyway.
				case MB_YesNoCancel:
					if (BoxCW.EnterResult == MR_Cancel)
						Box.Result = MR_Yes;
					else
						Box.Result = MR_Cancel;
					break;
				case MB_YesNo:
					if (BoxCW.EnterResult == MR_Yes)
						Box.Result = MR_No;
					else
						Box.Result = MR_Yes;
					break;
				case MB_OKCancel:
					if (BoxCW.EnterResult == MR_OK)
						Box.Result = MR_Cancel;
					else
						Box.Result = MR_OK;
					break;
				default:
					Box.Result = MR_OK;
					break;
			}
			ModalWindow.Close();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//////// General //////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state MenuShowing extends UWindows
	{
	function BeginState()
		{
		local String CurRes;
		
		bAllowConsole = false;

		// If current res is less than minimum res then switch to the min res
		// here and restore original resolution when state ends.
		CurRes = ViewportOwner.Actor.ConsoleCommand("GetCurrentRes");
		if (IsBelowMinRes(CurRes))
			{
			SetLowGameRes(CurRes);
			ViewportOwner.Actor.ConsoleCommand("SetRes "$MinRes);
			}

		if (!bAllowConsole && (MyMenu != None))
			MyMenu.ShowWindow();

		Super.BeginState();
		}

	function EndState()
		{
		local String CurrentRes;

		if(MyMenu != None)
			MyMenu.HideWindow();

		Super.EndState();

		// Super turns this off, we always want it on
		bVisible = true;
		if(bDisabled)
			bRequiresTick = true;

		// If a low game res was set then switch to it now
		if (GetLowGameRes() != "")
			ViewportOwner.Actor.ConsoleCommand("SetRes "$LowGameRes);

		bAllowConsole = true;
		}

	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
		{
		// 01/26/03 JMI Observe modality.
		if (WaitModal() == false)
			{
			if (MyMenu.KeyEvent(Key, Action, Delta) )
				return true;
			}
		else
			{
			// Menu isn't handling joystick, so do it now.
			if (HandleJoystick(Key, Action, Delta))
				return true;			
			}
		return Super.KeyEvent(Key, Action, Delta);
		}
	
	function Resized()
		{
		if (MyMenu != none)
			{
			MyMenu.WinLeft = WinLeft + WinWidth / 2 - MyMenu.GetMenuWidth() / 2;
			MyMenu.WinTop  = WinTop + WinHeight / 2 - MyMenu.GetContentHeight() / 2;	// 01/19/03 GetCenterHeight() biases this value to center
																						//			in a more aesthetically pleasing way.
			MyMenu.SetSize(MyMenu.GetMenuWidth(), MyMenu.GetMenuHeight() );
			}
		Super.Resized();
		}
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//////// Main Menu ////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state MainMenuShowing extends MenuShowing
	{
	function BeginState()
		{
		local class<BaseMenuBig> MainMenuClass;
		
		bGameMenu = false;

		// If game was issued to a particular party then show the EULA once before we do anything else
		if ((!bShowedEULA) && (P2GameInfo(Root.GetLevel().Game) != None) && (P2GameInfo(Root.GetLevel().Game).GetIssuedTo() != ""))
			{
			bShowedEULA = true;
			CreateMenu(class'MenuEula');
			}
		else
			{
			CreateMenu(GetMainMenuClass());
			}

		// If the main menu was not started with the ESC key then don't pause.
		// If it was started with ESC then we're testing/debugging, in which
		// case it's convenient to pause.
		if (!bMainMenuShownViaESC)
			bDontPauseOrUnPause = true;

		Super.BeginState();
		bDontPauseOrUnPause = false;
		}
	
	function EndState()
		{
		Super.EndState();
		bMainMenuShownViaESC = false;
		}
	}

state MainMenuShowingVirgin extends MenuShowing
// Same as MainMenuShowing, but we show the gameinfo's START menu instead of the MAIN menu.
// For stock P2 games this will be the main menu anyway, but for workshop games it will be a simple "Start/Quit" menu
	{
	function BeginState()
		{
		local class<BaseMenuBig> MainMenuClass;
		
		bGameMenu = false;

		// If game was issued to a particular party then show the EULA once before we do anything else
		if ((!bShowedEULA) && (P2GameInfo(Root.GetLevel().Game) != None) && (P2GameInfo(Root.GetLevel().Game).GetIssuedTo() != ""))
			{
			bShowedEULA = true;
			CreateMenu(class'MenuEula');
			}
		else
			{
			CreateMenu(GetMainMenuClass());
			}

		// If the main menu was not started with the ESC key then don't pause.
		// If it was started with ESC then we're testing/debugging, in which
		// case it's convenient to pause.
		if (!bMainMenuShownViaESC)
			bDontPauseOrUnPause = true;

		Super.BeginState();
		bDontPauseOrUnPause = false;
		}	
	function EndState()
		{
		Super.EndState();
		bMainMenuShownViaESC = false;
		}
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//////// Game Menu ////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GameMenuShowing extends MenuShowing
	{
	function BeginState()
		{
		local class<BaseMenuBig> GameMenuClass;

		bGameMenu = true;
		
		if(P2GameInfoSingle(Root.GetLevel().Game) != None)
		{
			// Allow workshop games to define their own menus.
			GameMenuClass = class<BaseMenuBig>(DynamicLoadObject(String(GetGameSingle().GameMenuName), class'Class'));
			if (GameMenuClass != None)
				CreateMenu(GameMenuClass);
			else
				CreateMenu(class'MenuGame');
		}
		else
			CreateMenu(class'MenuGameMulti');

		Super.BeginState();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Parse the level name out of the URL.  This only handles simple URL's that
// look like any of the following:
//
//		LevelName
//		LevelName?anything_else
//		LevelName#TelepadName
//		LevelName#TelepadName?anything_else
//		IP/LevelName...
//		Postal2://IP/LevelName...
//
///////////////////////////////////////////////////////////////////////////////
function String ParseLevelName(String URL)
	{
	local int i, j;

	// Check if Postal2:// is in front
	if(InStr(Caps(URL), Caps("Postal2://")) == 0)
		URL = Right(URL, Len(URL) - 10);

	// Check if IP address is at the front, before the level name
	j = InStr(URL, "/");
	if(j >= 0)
		URL = Right(URL, Len(URL) - j - 1);

	// Not sure which of these will come first in the string, so use whichever
	// occurs sooner and whatever is to the left of it is the level name.
	i = InStr(URL, "#");
	j = InStr(URL, "?");
	if (i >= 0)
		{
		if (j >= 0)
			i = Min(i, j);
		}
	else
		i = j;

	if (i >= 0)
		return Left(URL, i);

	return URL;
	}

// Disable the menu for level transitions
function DisableMenu()
{
	if(bDisabled)
		return;

	//Log(self$" disabling menu");
	// Close the menu unless it's the connecting window
	if(IsMenuShowing() && (MyMenu == None || MenuConnecting(MyMenu) == None))
	{
		Close();
		HideMenu();
	}

	DisableMenuTimer = Root.GetLevel().TimeSeconds + DISABLE_MENU_TIME;
	//Log("DISABLING MENU - DisableTimer=" $ DisableMenuTimer $ " LevelTime=" $ Root.GetLevel().TimeSeconds);
	bDisabled = true;
	// allow ticks to fall through while menu is disabled for our timer
	bRequiresTick = true;
}

function EnableMenu()
{
	if(!bDisabled)
		return;

	//Log(self$" enabling menu");
	DisableMenuTimer = 0;
	bDisabled = false;
	if(!IsMenuShowing())
		bRequiresTick = false;
	bLockErrorWindow = false;
}

function SetLoadingTexture(string MapName)
{
	local Object LevSumObject;
	local LevelSummary LevSum;
	local int i;

	MapName = ParseLevelName(MapName);
	i = InStr(Caps(MapName), ".FUK");
	if(i != -1)
		MapName = Left(MapName, i);

	LevSumObject = DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary', true);
	if(LevSumObject != None && LevelSummary(LevSumObject) != None && Caps(MapName) != Caps(GetStartupMap()) && Caps(MapName) != Caps("entry") && Caps(MapName) != Caps("index"))
	{
		LevSum = LevelSummary(LevSumObject);
		if(Texture(LevSum.Screenshot) != None)
			LoadingTexture = Texture(LevSum.Screenshot);
		else
			LoadingTexture = Default.LoadingTexture;
	}
	else if( (LevSumObject == None || LevelSummary(LevSumObject) == None)  && Caps(MapName) != Caps(GetStartupMap()) && Caps(MapName) != Caps("entry") && Caps(MapName) != Caps("index"))
		LoadingTexture = Default.LoadingTexture;
}

///////////////////////////////////////////////////////////////////////////////
// Menu Button: brings up main game menu during gameplay.
///////////////////////////////////////////////////////////////////////////////
function execMenuButton()
{
	local EInputKey key;
	local EInputAction action;
	
	// Brings up the start menu if possible.
	if (!IsMenuShowing())
	{
		key = IK_Escape;
		action = IST_Release;
		KeyEvent(key, action, 0);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	LookAndFeelClass="Shell.ShellLookAndFeel"
	FontInfoClass="FPSGame.FontInfo"
	MinRes="1024x768"
	BeatDemoMenu=class'MenuImageDemoDone'
	TimedOutDemoMenu=class'MenuDemoTimedOut'
	ArrestedDemoMenu=class'MenuImageBusted'
	DifficultyPatchMenu=class'MenuDifficultyPatch'
	BlackBox=Texture'nathans.Inventory.BlackBox64'
	PreMsgX=256;
	PreMsgDX=1.0;
	PreMsgDY=1.0;
	LoadingTexture=Texture'MP_misc.Loading_MP'
	ConnectingMessage="JOINING"
	LoadingMessage="LOADING"
//	StartupMapName="Startup"
	EngineVersion="5023"
	HotfixText=""
	bBuildDateAsHotfixText=false
	WorkshopStatus="Workshop Status:"
	}
