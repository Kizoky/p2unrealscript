///////////////////////////////////////////////////////////////////////////////
// MenuMain.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The Main menu.
//
// History:
//
//	01/19/03 JMI	Removed multiplayer choice.
//
//	01/13/03 JMI	Added strHelp parameter to AddChoice() allowing us to pass
//					in many help strings that had been created but were not 
//					being used for standard menu choices.  Added generic 
//					RestoreHelp for menus sporting a Restore option.
//
//	09/04/02 MJR	Major rework for new system.
//
///////////////////////////////////////////////////////////////////////////////
// This class describes the main menu details and processes main menu events.
///////////////////////////////////////////////////////////////////////////////
class MenuMain extends BaseMenuBig;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var ShellMenuChoice		NewChoice;
var localized string	NewGameText;
var localized string	NewGameHelp;

// For when you beat the game
var ShellMenuChoice		EnhancedChoice;
var localized string	EnhancedText;

var ShellMenuChoice		LoadChoice;
var localized string	LoadGameHelp;

var ShellMenuChoice		MultiChoice;
var localized string	MultiText;
var localized string	MultiHelp;

var ShellMenuChoice		ActualDLCChoice;
var localized string	ActualDLCText;
var localized string	ActualDLCHelp;

var ShellMenuChoice		LaunchPLChoice;
var localized string	LaunchPLText;
var localized string	LaunchPLHelp;	

var ShellMenuChoice		LaunchEDChoice;
var localized string	LaunchEDText;
var localized string	LaunchEDHelp;	

var ShellMenuChoice		DLCChoice;
var localized string	DLCText;
var color				DLCTextColor;
var color				DLCHighlightTextColor;

var ShellMenuChoice		ExitChoice;
var localized string	ExitGameText;

const DLC_Holiday = 'SeasonalAprilFools';
const PL_DLC_APPID = 360960;
const ED_DLC_APPID = -1;
const P4_GAME_APPID = 707030;

var ShellMenuChoice		DebugChoice;
var localized string	DebugText;
var localized string	DebugHelp;

var ShellBitmapSocial	FacebookIcon;
var ShellBitmapSocial	TwitterIcon;
var ShellBitmapSocial	WebsiteIcon;
var Texture				FacebookTexture;
var Texture				TwitterTexture;
var Texture				WebsiteTexture;
var localized string FacebookText, TwitterText, WebsiteText;
var localized string SocialLaunchFailedTitle, SocialLaunchFailedText;

var ShellBitmapSocial	ParadiseLostIcon;
var Texture				ParadiseLostTexture;
var localized string		ParadiseLostText;

var ShellBitmapSocial	Postal4Icon;
var Texture				Postal4Texture;
var localized string	Postal4Text;

// Change by NickP: MP fix
var globalconfig bool bShowMP;
// End

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	
    if (PlatformIsSteamDeck())
        log("Test - PlatformIsSteamDeck() worked and returned TRUE.");
    else
        log("Test - PlatformIsSteamDeck() worked and returned FALSE.");

	// Change by Man Chrzan: xPatch 2.0
	// Fix for having a mod title after returning to Main Game menu.
	if(class == class'MenuMain')
		TitleTexture = Default.TitleTexture;

	AddTitleBitmap(TitleTexture);
	
	NewChoice     = AddChoice(NewGameText,		NewGameHelp,									ItemFont, ItemAlign);

	if(GetGameSingle() != None && GetGameSingle().VerifySeqTime(true))
		ShellRootWindow(Root).bVerified = true;
	// Only add this option in after you've beaten the game
	// 8/15 - Kamek - moved this to MenuStart
	//if(ShellRootWindow(Root).bVerified)
	//	EnhancedChoice= AddChoice(EnhancedText,		"",									ItemFont, ItemAlign);
	LoadChoice    = AddChoice(LoadGameText,		LoadGameHelp,	ItemFont, ItemAlign);
	
	if (FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
		DebugChoice = AddChoice(DebugText, DebugHelp, ItemFont, ItemAlign);
		
	//!! FIXME - launching DLC doesn't seem to work properly in Linux.
	// Change by NickP: MP fix
	//if (PlatformIsWindows())
	if (bShowMP)
		MultiChoice   = AddChoice(MultiText,		MultiHelp,									ItemFont, ItemAlign);
	// End

	if (BuyParadiseLost())
		ActualDLCChoice = AddChoice(ActualDLCText, ActualDLCHelp, ItemFont, ItemAlign);
	else if (PlatformIsWindows())
		LaunchPLChoice = AddChoice(LaunchPLText, LaunchPLHelp, ItemFont, ItemAlign);
		
	if (GetLevel().SteamOwnsDLC(ED_DLC_APPID) && PlatformIsWindows())
		LaunchEDChoice = AddChoice(LaunchEDText, LaunchEDHelp, ItemFont, ItemAlign);
	
	if (GetGameSingle().IsHoliday(DLC_Holiday))
	{
		DLCChoice	= AddChoice(DLCText,		"",									ItemFont, ItemAlign);
		DLCChoice.SetTextColor(DLCTextColor);
		DLCChoice.SetHighlightTextColor(DLCHighlightTextColor);
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

// xPatch: extra check, detects Paradise Lost even if you  
// are playing offline and are not connected with Steam.
function bool BuyParadiseLost()
{
	local bool DLCInstalled;
	local int n;

	n = FileSize("..\\Paradise Lost\\System\\PLGame.u");
	if( n > -1 )
		DLCInstalled=True;
	
	return (!GetLevel().SteamOwnsDLC(PL_DLC_APPID) && GetLevel().IsSteamBuild() && !DLCInstalled);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function AddSocialIcons()
{
	const SOCIAL_ICON_X = 0.02;
	const SOCIAL_ICON_Y = 0.92;
	const DLC_ICON_X = 0.02;
	const DLC_ICON_Y = 0.65;
	local float X, Y;
	
	// FIXME does not work yet on Linux
	if (!PlatformIsWindows())
		return;
		
	// Don't add anything unless we're the "real" main menu
	if (Root.WinWidth == 0 || Root.WinHeight == 0)
		return;
	
	X = Root.WinWidth * SOCIAL_ICON_X;
	Y = Root.WinHeight * SOCIAL_ICON_Y;
	
	WebsiteIcon = ShellBitmapSocial(Root.CreateWindow(class'ShellBitmapSocial', X, Y, WebsiteTexture.USize, WebsiteTexture.VSize));
	WebsiteIcon.bFit = true;
	WebsiteIcon.bAlpha = false;
	WebsiteIcon.T = WebsiteTexture;
	WebsiteIcon.R.X = 0;
	WebsiteIcon.R.Y = 0;
	WebsiteIcon.R.W = WebsiteIcon.T.USize;
	WebsiteIcon.R.H = WebsiteIcon.T.VSize;
	WebsiteIcon.MyMenu = Self;
	
	X += WebsiteIcon.T.USize + WebsiteIcon.T.USize / 4;

	FacebookIcon = ShellBitmapSocial(Root.CreateWindow(class'ShellBitmapSocial', X, Y, FacebookTexture.USize, FacebookTexture.VSize));
	FacebookIcon.bFit = true;
	FacebookIcon.bAlpha = false;
	FacebookIcon.T = FacebookTexture;
	FacebookIcon.R.X = 0;
	FacebookIcon.R.Y = 0;
	FacebookIcon.R.W = FacebookIcon.T.USize;
	FacebookIcon.R.H = FacebookIcon.T.VSize;
	FacebookIcon.MyMenu = Self;
	
	X += FacebookIcon.T.USize + FacebookIcon.T.USize / 4;

	TwitterIcon = ShellBitmapSocial(Root.CreateWindow(class'ShellBitmapSocial', X, Y, TwitterTexture.USize, TwitterTexture.VSize));
	TwitterIcon.bFit = true;
	TwitterIcon.bAlpha = false;
	TwitterIcon.T = TwitterTexture;
	TwitterIcon.R.X = 0;
	TwitterIcon.R.Y = 0;
	TwitterIcon.R.W = TwitterIcon.T.USize;
	TwitterIcon.R.H = TwitterIcon.T.VSize;
	TwitterIcon.MyMenu = Self;

	if (GetLevel().IsSteamBuild())
	{
		if (!GetLevel().SteamOwnsGame(P4_GAME_APPID))
		{
			X = Root.WinWidth * DLC_ICON_X;
			Y -= 255;
			
			Postal4Icon = ShellBitmapSocial(Root.CreateWindow(class'ShellBitmapSocial', X, Y, 300, 235));
			Postal4Icon.bStretch = true;
			Postal4Icon.bCenter = true;
			Postal4Icon.T = Postal4Texture;
			Postal4Icon.R.X = 0;
			Postal4Icon.R.Y = 0;
			Postal4Icon.R.W = Postal4Icon.T.USize;
			Postal4Icon.R.H = Postal4Icon.T.VSize;
			Postal4Icon.MyMenu = Self;
		}
		else if (!GetLevel().SteamOwnsDLC(PL_DLC_APPID))
		{
			X = Root.WinWidth * DLC_ICON_X;
			Y -= 255;
			
			ParadiseLostIcon = ShellBitmapSocial(Root.CreateWindow(class'ShellBitmapSocial', X, Y, 300, 235));
			ParadiseLostIcon.bStretch = true;
			ParadiseLostIcon.bCenter = true;
			ParadiseLostIcon.T = ParadiseLostTexture;
			ParadiseLostIcon.R.X = 0;
			ParadiseLostIcon.R.Y = 0;
			ParadiseLostIcon.R.W = ParadiseLostIcon.T.USize;
			ParadiseLostIcon.R.H = ParadiseLostIcon.T.VSize;
			ParadiseLostIcon.MyMenu = Self;
		}
	}
}

function RemoveSocialIcons()
{
	if (FacebookIcon != None)
		FacebookIcon.Close();
	if (TwitterIcon != None)
		TwitterIcon.Close();
	if (WebsiteIcon != None)
		WebsiteIcon.Close();
	if (ParadiseLostIcon != None)
		ParadiseLostIcon.Close();
	if (Postal4Icon != None)
		Postal4Icon.Close();
}

function SocialIconNotify(ShellBitmapSocial C, byte E)
{
	local String Error;
	local String HintText;
	
	switch(E)
	{
		case DE_Click:
			switch(C)
			{
				case FacebookIcon:
					Error = GetPlayerOwner().Player.InteractionMaster.LaunchSocialNetwork(SN_Facebook);
					break;
				case TwitterIcon:
					Error = GetPlayerOwner().Player.InteractionMaster.LaunchSocialNetwork(SN_Twitter);
					break;
				case WebsiteIcon:
					Error = GetPlayerOwner().Player.InteractionMaster.LaunchSocialNetwork(SN_Website);
					break;
				case ParadiseLostIcon:
					GetLevel().SteamViewStorePage(PL_DLC_APPID);
					break;
				case Postal4Icon:
					GetLevel().SteamViewStorePage(P4_GAME_APPID);
					break;
			}
			ShellLookAndFeel(LookAndFeel).PlayThisLocalSound(self, ShellLookAndFeel(LookAndFeel).ClickSound, ShellLookAndFeel(LookAndFeel).ClickVolume);
			break;
		case DE_MouseEnter:
			switch(C)
			{
				case FacebookIcon:
					HintText = FacebookText;
					break;
				case TwitterIcon:
					HintText = TwitterText;
					break;
				case WebsiteIcon:
					HintText = WebsiteText;
					break;
				case ParadiseLostIcon:
					HintText = ParadiseLostText;
					break;
				case Postal4Icon:
					HintText = Postal4Text;
					break;
			}
			if (HintItem != None && HintText != "")
			{
				HintItem.SetText(HintText);
				HintItem.ShowWindow();
			}
			ShellLookAndFeel(LookAndFeel).PlayEnterSound(C);
			break;
		case DE_MouseLeave:
			HintItem.SetText("");
			HintItem.HideWindow();
			break;		
	}
	
	if (Error != "")
		MessageBox(SocialLaunchFailedTitle, SocialLaunchFailedText@Error, MB_OK, MR_OK, MR_OK);
}

function OnCleanUp()
{
	RemoveSocialIcons();
}
	
///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local String NewGameURL;
	local bool bShowEnhanced;
	local class<UMenuStartGameWindow> StartGameClass;

	Super.Notify(C, E);
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
// xPatch: It's now handled by the new Game Mode Menu
/*						bShowEnhanced = bool(GetPlayerOwner().ConsoleCommand("get"@EnhancedPath));
						if (!bShowEnhanced
							&& GetGameSingle().SeqTimeVerified())
							GotoMenu(class'MenuEnhanced');
						else*/ if(!GetLevel().IsDemoBuild())
							// If not in the demo--allow them to pick the difficulty
							//GotoMenu(class'MenuStart');
							GotoMenu(class'MenuGameMode');		// Change by Man Chrzan: xPatch 2.0	
						else
							// The difficulty is set to default for the demo.
							// Go to the explaination instead.
							GotoMenu(class'MenuImageDemoExplain');
						break;

					case EnhancedChoice:
						SetSingleplayer();
						ShellRootWindow(Root).bVerifiedPicked=true;
						GotoMenu(class'MenuEnhanced');
						break;

					case LoadChoice:
						SetSingleplayer();
						GotoMenu(class'MenuLoad');
						break;

					case MultiChoice:
						GotoMenu(class'MenuMulti');
						//GotoMenu(class'MenuDLCLaunchMulti'); // not technically DLC, but is launched in the same manner.
						break;

					case OptionsChoice:
						GoToMenu(class'MenuOptions');
						break;

					case DebugChoice:
						GoToMenu(class'P2DebugMenu_Main');
						break;
						
					// Fake April Fools "DLC" (maybe get rid of this now that we have actual DLC?)
					case DLCChoice:
						// Launch specialized workshop menu
						StartGameClass = class<UMenuStartGameWindow>(DynamicLoadObject("Shell.DLCMainWindow", class'Class'));
						GotoWindow(Root.CreateWindow(StartGameClass, 100, 100, 200, 200, Self, True));
						break;
						
					// Actual DLC choice, displayed if the user does not have Paradise Lost installed.
					// Launches Steam store page.
					case ActualDLCChoice:
						GetLevel().SteamViewStorePage(PL_DLC_APPID);						
						break;
						
					// Actual DLC choice, displayed if the user owns PL.
					case LaunchPLChoice:
						GotoMenu(class'MenuDLCLaunchPL');
						break;
						
					// Actual DLC choice, displayed if the user owns ED.
					case LaunchEDChoice:
						GotoMenu(class'MenuDLCLaunchED');
						break;

					case ExitChoice:
						GoToMenu(class'MenuQuitExitConfirmation');	// 01/21/03 JMI Now looks for confirmation.
						break;
					}
				break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Set temp options for singleplayer game
///////////////////////////////////////////////////////////////////////////////
function SetSingleplayer()
	{
	ShellRootWindow(Root).bLaunchedMultiplayer = false;
	GetPlayerOwner().UpdateURL("Name", class'GameInfo'.Default.DefaultPlayerName, false);
	GetPlayerOwner().UpdateURL("Class", "GameTypes.AWPostalDude", false);
	}

///////////////////////////////////////////////////////////////////////////////
// Handle a key event
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
	if (HandleJoystick(Key, Action, Delta))
		return true;
	
	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_ESCAPE:
				// Only allow ESC to hide the main menu if it was also used to show it
				if (ShellRootWindow(root).bMainMenuShownViaESC)
					HideMenu();
				return true;
			}
		}
	
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	NewGameText = "New Game"
	NewGameHelp = "Begins a new game. Overwrites Autosave if present."
	LoadGameHelp = "Loads a previously-saved game."
	EnhancedText = "Enhanced Game"
	MultiText = "Multiplayer"
	MultiHelp = "Launches POSTAL 2: Share The Pain."
	ExitGameText = "Exit"
	DLCText = "Paid DLC (NEW!!)"
	DLCTextColor=(G=255)
	DLCHighlightTextColor=(R=75,G=255,B=75,A=255)
	ActualDLCText = "DLC: Paradise Lost"
	ActualDLCHelp = "No foolin'! We made real, actual DLC! No Champ Armor here, this is a full-blown 5-day expansion with the REAL Dude voice!"
	LaunchPLText = "Paradise Lost"
	LaunchPLHelp = "Launches POSTAL 2: Paradise Lost."
	LaunchEDText = "Eternal Damnation"
	LaunchEDHelp = "Launches Eternal Damnation."
	DebugText = "Start on Map..."
	DebugHelp = "(DEBUG) Starts a new game on specified map on Monday (P2/AWP) or Saturday (AW). Skips difficulty, intro etc"

	bBlockConsole=false
	FacebookTexture=Texture'P2Misc.social.icon_social_facebook'
	TwitterTexture=Texture'P2Misc.social.icon_social_twitter'
	WebsiteTexture=Texture'P2Misc.social.icon_social_star'
	SocialLaunchFailedTitle="Can't open browser"
	SocialLaunchFailedText="Could not open web browser: "
	FacebookText="Like Running With Scissors on Facebook!"
	TwitterText="Follow Running With Scissors on Twitter!"
	WebsiteText="Visit Running With Scissors on the Web!"
	ParadiseLostTexture=Texture'P2Misc.dlc.paradiselost_menubutton'
	ParadiseLostText="Buy Paradise Lost, the full-blown 5-day expansion, now!"
	Postal4Texture=Texture'DLCBanner.postal4_menubutton'
	Postal4Text="A long-awaited sequel, finally available on the steam!"
	}
