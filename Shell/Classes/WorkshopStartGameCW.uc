class WorkshopStartGameCW extends UTMenuBotmatchCW;

var bool bEnhanced;
var bool bNoHolidays;
var Texture DefaultLoadingTexture;
var string SelectedMap;

var UWindowLabelControl NoAchievementsWindow;
var localized string NoAchievementsText;
var localized string NoAchievementsText2;
var localized string ResetText;

var UWindowPageControlPage MutatorTabPage;

// Window
var UWindowSmallButton ResetButton;

const NIGHT_MODE_HOLIDAY = 'NightMode';

///////////////////////////////////////////////////////////////////////////////
// Get the single player info.
// 02/10/03 JMI Started to macroify this which we seem to be doing commonly
//				lately. 
///////////////////////////////////////////////////////////////////////////////
function P2GameInfoSingle GetGameSingle()
	{
	return P2GameInfoSingle(Root.GetLevel().Game);
	}

function CreatePages()
{
	local class<UWindowPageWindow> PageClass;

	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);

	// GameType/Custom Map Tab
	StartTab = Pages.AddPage(StartMatchTab, class'WorkshopStartMatchSC');

	if(GameClass == None)
		return;

	// Mutator Settings Tab
	MutatorTabPage = Pages.AddPage(MutatorTab, class'WorkshopMutatorCW');
}

function Resized()
{
	Pages.WinWidth = WinWidth;
	Pages.Winheight = WinHeight - 24;

	CloseButton.WinLeft = WinWidth-52;
	CloseButton.WinTop = WinHeight-20;
	ResetButton.WinLeft = WinWidth-102;
	ResetButton.WinTop = WinHeight-20;
	StartButton.WinLeft = WinWidth-152;
	StartButton.WinTop = WinHeight-20;

	NoAchievementsWindow.WinLeft = 10;
	NoAchievementsWindow.WinTop = WinHeight-45;
}

function Created()
{
	NoAchievementsWindow = UWindowLabelControl(CreateWindow(class'UWindowLabelControl', 10, Winheight-45, 450, 64));
	if (GetLevel().IsSteamBuild())
		NoAchievementsWindow.SetText(NoAchievementsText);
	else
		NoAchievementsWindow.SetText(NoAchievementsText2);
	NoAchievementsWindow.SetFont(F_Smallbold);

	if(!bKeepMutators)
		MutatorList = "";

	CreatePages();

	CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-56, WinHeight-24, 48, 16));
	CloseButton.SetText(BackText);
	ResetButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-106, WinHeight-24, 48, 16));
	ResetButton.SetText(ResetText);
	StartButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-156, WinHeight-24, 48, 16));
	StartButton.SetText(StartText);

	Super(UWindowDialogClientWindow).Created();

	CloseButton.SetFont(F_SmallBold);
	StartButton.SetFont(F_SmallBold);
	ResetButton.SetFont(F_Smallbold);
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
	case DE_Click:
		switch (C)
		{
			case StartButton:
				//UTMenuStartMatchCW(UTMenuStartMatchSC(StartTab.Page).ClientArea).MapWindow.SaveConfigs();
				StartPressed();
				return;
			case ResetButton:
				ResetPressed();
				return;
			default:
				Super.Notify(C, E);
				return;
		}
	default:
		Super.Notify(C, E);
		return;
	}
}

function GameChanged()
{
	// stub
}

// Reset all tabs and game selections
function ResetPressed()
{
	local UMenuMutatorExclude Exclude;
	local UMenuMutatorInclude Include;
	local int i;

	// Wipe mutator list
	MutatorList="";
	bKeepMutators=false;
	SaveConfig();
	
	// Reset gametype
	WorkshopStartMatchCW(UTMenuStartMatchSC(StartTab.Page).ClientArea).GameCombo.SetSelectedIndex(0);
	
	// Reset Enhanced
	WorkshopStartMatchCW(UTMenuStartMatchSC(StartTab.Page).ClientArea).EnhancedCheck.bChecked = false;
	
	// Reset difficulty
	WorkshopStartMatchCW(UTMenuStartMatchSC(StartTab.Page).ClientArea).DifficultyCombo.SetSelectedIndex(5);
	
	// Reset map
	WorkshopMapListCW(WorkshopStartMatchCW(UTMenuStartMatchSC(StartTab.Page).ClientArea).MapWindow).Exclude.SetSelected(0,0);
	
	// Reset mutators
	WorkshopMutatorCW(MutatorTabPage.Page).KeepCheck.bChecked = false;
	Exclude = WorkshopMutatorCW(MutatorTabPage.Page).Exclude;
	Include = WorkshopMutatorCW(MutatorTabPage.Page).Include;
	
	while (Include.Items.Next != None)
		Include.DoubleClickItem(UWindowListBoxItem(Include.Items.Next));
}

function PossibleConvertToNightMode(out String URL)
{
	local int qmark,pound;
	local string BaseURL,qmarkparams,poundparams;
	
	if (bNoHolidays)
		return;

	// If in night mode, and a night version of the map exists, send them there
	if (P2GameInfoSingle(GetPlayerOwner().Level.Game).IsHoliday(NIGHT_MODE_HOLIDAY))
	{
		qmark = InStr(URL,"?");
		if (qmark >= 0)
		{
			qmarkparams = Right(URL, Len(URL) - qmark);
			BaseURL = Left(URL, qmark);
		}
		else
			BaseURL = URL;
			
		pound = InStr(BaseURL,"#");
		if (pound >= 0)
		{
			poundparams = Right(BaseURL, Len(BaseURL) - pound);
			BaseURL = Left(BaseURL, pound);
		}		
		
		// If a night version of MapName exists, change it
		if (GetPlayerOwner().DoesMapExist("ngt-"$BaseURL))
			BaseURL = "ngt-"$BaseURL;
			
		URL = BaseURL $ poundparams $ qmarkparams;
	}
}

// Override botmatch's start behavior
function StartPressed()
{
	// SelectedMap = string of map name -- will be class'WorkshopMapListCW'.Default.DefaultText if no map selected and we should just run the intro map.
	// GameClass = gameinfo class
	// GameType = string of gameinfo class
	// MutatorList = comma-separated list of mutators
	// bEnhanced = true if enhanced mode
	
	local P2Player p2p;
	local P2GameInfoSingle usegame;
	local string StartGameURL;
	local Texture LoadTex;
	local class<P2GameInfoSingle> UseClass;
	local bool bGoingToStartup;
	local int peer,pound;
	local string URL,MapName,TelepadName,BaseURL,temp1,temp2,peerstr;
	
	UseClass = class<P2GameInfoSingle>(GameClass);
	
	// Assemble start-game URL based on user selection.
	if (SelectedMap == class'WorkshopMapListCW'.Default.DefaultText)
	{
		// Using the default selection.
		// If the game wants us to go to a startup map first, do that instead of starting the game.
		// But not if we're already on that startup map
		if (UseClass.Default.bShowStartupOnNewGame
			&& GetGameSingle().ParseLevelName(UseClass.Default.MainMenuUrl) != GetGameSingle().ParseLevelName(Root.GetLevel().GetLocalUrl()))
		{
			// Travel to the game's startup map, and set the root window as virgin so the startup sequence plays.
			ShellRootWindow(Root).bVirgin = true;
			bGoingToStartup = true;
			StartGameURL = UseClass.Default.MainMenuURL $ UseClass.Static.GetStartURL(false);
		}
		else // Otherwise, just start the game with the specified startup URL
			StartGameURL = UseClass.Static.GetStartURL(true);
	}
	else
		StartGameURL = SelectedMap $ UseClass.Static.GetStartURL(false);

	PossibleConvertToNightMode(StartGameURL);
		
	StartGameURL = StartGameURL $ "?Workshop=1";
		
	// Add in the player class (some games will most likely use their own player pawn)
	StartGameURL = StartGameUrl $ "?Class=" $ UseClass.Default.DefaultPlayerClassName;
		
	// Start URL now contains game info and map. Add in mutators
	StartGameURL = StartGameURL $ "?Mutator=" $ MutatorList;

	// Now we have a URL to send them to, do the actual sending
	usegame = GetGameSingle();
	p2p = usegame.GetPlayer();
	// Force sissy off on a new game
	p2p.UnSissy();
	P2RootWindow(Root).StartingGame();

	// Stop any active SceneManager so player will have a pawn
	usegame.StopSceneManagers();

	usegame.PrepIniStartVals();
	usegame.TheGameState.bEGameStart = bEnhanced;

	usegame.bNoHolidays = bNoHolidays;
		
	// Turn off night mode if holidays are off
	if (usegame.bNoHolidays)
		usegame.TheGameState.bNightMode = false;

	usegame.SaveConfig();
	
	// Get the difficulty ready for this game state.
	usegame.SetupDifficultyOnce();

	// Get rid of any things in his inventory before a new game starts
	P2Pawn(p2p.pawn).DestroyAllInventory();
	usegame.TheGameState.HudArmorClass = None;
	p2p.MyPawn.Armor = 0;

	// Game doesn't actually start until player is sent to first day,
	// which *should* happen at the end of the intro sequence.
	usegame.TheGameState.bChangeDayPostTravel = true;
	usegame.TheGameState.NextDay = 0;

	if (!bGoingToStartup)
	{
		// Set our loading texture
		// Reach into the new game class and get the first day's loading screen.
		LoadTex = UseClass.Default.Days[0].GetLoadTexture();
		
		// If none, revert to default
		if (LoadTex == None)	
			LoadTex = DefaultLoadingTexture;

		usegame.bShowDayDuringLoad = True;
		usegame.ForcedLoadTex = LoadTex;
	}
	else
	{		
		usegame.ForcedLoadTex = DefaultLoadingTexture;
		usegame.bForceNoLoadFade = true;
	}
	
	// Actually start the game with the selected level
	//usegame.bQuitting = true;	// discard gamestate
	usegame.SendPlayerTo(p2p, StartGameURL);
}

function Close(optional bool bByParent) 
{
	if(Root != None)
		Root.GoBack();

	Super.Close(bByParent);
}

defaultproperties
{
	StartMatchTab="Game/Map"
	MutatorTab="Mods"
	StartText="Start"
	bNetworkGame=False
	DefaultLoadingTexture=Texture'p2misc_full.Load.loading-screen'
	NoAchievementsText="Notice: Achievements cannot be unlocked when playing Workshop"
	NoAchievementsText2="Notice: Achievements cannot be unlocked in custom games"
	ResetText="Reset"
}
