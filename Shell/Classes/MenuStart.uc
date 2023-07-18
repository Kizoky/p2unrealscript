///////////////////////////////////////////////////////////////////////////////
// MenuStart.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Menu to force difficulty choice and to drive home the fact that it cannot be
// changed after a game is started--aren't all games this way?
//
// 8-15 Kamek - add in P2/AW/AWP selection backport from AW7
//
// 2022-09-12 Piotr S. - Added Classic Game, Skip Intro and few 
// minor changes / fixes. This class is used as a base from now on as 
// the Game Mode selection and Difficulty + Checkboxes are saparated now. 
//
// 2022-09-26 Piotr S. - Added Day Selection
///////////////////////////////////////////////////////////////////////////////
class MenuStart extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var string StartGameAW7;
var string StartGameWeekend;
var string StartGameMF;
var UWindowCheckBox NoHolidaysCheckbox;
var UWindowCheckBox EnhancedCheckbox;
var ShellMenuChoice StartAW7;
var ShellMenuChoice StartMF;
var ShellMenuChoice StartWeekend;
var ShellMenuChoice StartWorkshop;
var localized string EnhancedText;
var localized string NoHolidaysText, NoHolidaysHelp;
var localized string StartAW7Text;
var localized string StartMFText;
var localized string StartWeekendText;
var localized string StartWorkshopText;
var localized string StartCustomText;
var localized string EnhancedHelp;
var localized string StartAW7Help;
var localized string StartMFHelp;
var localized string StartWeekendHelp;
var localized string StartWorkshopHelp;
var localized string StartCustomHelp;
var localized string WaitforWorkshopTitle, WaitforWorkshopText;

var localized string	TitleText;

var ShellMenuChoice		StartChoice;

var bool bUpdate;

var string StartGameURL;

var int DayToShowDuringLoad;

var string ExplainedDifficulty;	// Name of difficulty option we explained to the joystick user

const DAY_SATURDAY = 5;
const NIGHT_MODE_HOLIDAY = 'NightMode';

// xPatch:
var UWindowCheckBox ClassicGameCheckbox;
var localized string ClassicGameText, ClassicGameHelp;

var UWindowCheckBox SkipCheckbox;
var localized string SkipText, SkipHelp;
var bool bShouldForceMap;

var UWindowComboControl DayCombo;
var localized string DayComboText, DayComboHelp;
var localized array<string> Days;
var int MaxDays;	// Max days to show in this menu

var class<P2GameInfoSingle> StartGameInfo;
var name UNLOCK_DAYSELECT_ACHIEVEMENT;
// End

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	
	AddTitle(TitleText, F_FancyXL, TA_Left);
	
	ItemFont = F_FancyL;
	DifficultyCombo = AddComboBox(DifficultyText, DifficultyHelp, ItemFont);
	DifficultyCombo.List.MaxVisible = ArrayCount(P2GameInfoSingle(GetPlayerOwner().Level.Game).DifficultyNames);
	
	// turn off no-holiday-mode thing
	GetGameSingle().bNoHolidays = false;
	GetGameSingle().SaveConfig();
	
	ItemFont = F_FancyM;	// Medium font for checkboxes
	ItemHeight = 23;		// and closer to each other
	
	if (GetGameSingle().IsHoliday('ANY_HOLIDAY')
		&& !GetGameSingle().IsHoliday('SeasonalAprilFools'))	// April Fools do not affect the game itself so ignore it.
	{
		NoHolidaysCheckbox = AddCheckbox(NoHolidaysText, NoHolidaysHelp, ItemFont);
		NoHolidaysCheckbox.SetValue(False);
	}

	if (GetGameSingle().SeqTimeVerified())
	{
		EnhancedCheckbox = AddCheckbox(EnhancedText, EnhancedHelp, ItemFont);
		EnhancedCheckbox.SetValue(False);
	}
	
	ClassicGameCheckbox = AddCheckbox(ClassicGameText, ClassicGameHelp, ItemFont);
	ClassicGameCheckbox.SetValue(False);
	
	SkipCheckbox = AddCheckbox(SkipText, SkipHelp, ItemFont);
	SkipCheckbox.SetValue(False);
	
	ItemFont = F_FancyL;	// Back to normal
	ItemHeight = 32;
	
//	StartChoice	= AddChoice(StartText,	"", ItemFont, TA_Left);
	StartAW7 =		AddChoice(StartAW7Text,		StartAW7Help,		ItemFont,	TA_Left);
//	StartAW7.bActive = False;
	StartMF =		AddChoice(StartMFText,		StartMFHelp,		ItemFont,	TA_Left);
	StartWeekend =	AddChoice(StartWeekendText,	StartWeekendHelp,	ItemFont,	TA_Left);
	if (GetLevel().IsSteamBuild())
		StartWorkshop =	AddChoice(StartWorkshopText,StartWorkshopHelp,	ItemFont,	TA_Left);
	else
		StartWorkshop =	AddChoice(StartCustomText,StartCustomHelp,	ItemFont,	TA_Left);
	BackChoice  = AddChoice(BackText,   "", ItemFont, TA_Left, true);
	
	LoadValues();
	}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
	{
	local float val;
	local bool flag;
	local String detail;
	local int i;
	local P2GameInfoSingle psg;

	psg = P2GameInfoSingle(GetPlayerOwner().Level.Game);
	
	// Controls will generate Notify() events when their values are updated, so we
	// use this flag to block the events from actually doing anything.  In other
	// words, we're only setting the initial values of the controls and we don't
	// want that to count as a change.
	bUpdate = False;
	
	// xPatch: Day Select
	if (DayCombo != none)
	{
		DayCombo.Clear();

		for(i=0; i<MaxDays; i++)
			DayCombo.AddItem(Days[i]);
		DayCombo.SetValue(Days[0]);
	}
	// End
	
	if (DifficultyCombo != none)
		{
		DifficultyCombo.Clear();

		for(i=0; i<ArrayCount(psg.DifficultyNames); i++)
			DifficultyCombo.AddItem(psg.DifficultyNames[i]);

		val = int(GetPlayerOwner().ConsoleCommand("get"@c_strDifficultyNumberPath));

		// resets Custom to Average
		if(psg.InCustomMode())
			val = 5;
		
		DifficultyCombo.SetValue(psg.DifficultyNames[int(val)]);
		
		// Seems too wide on the text side.
		DifficultyCombo.EditBoxWidth = DifficultyCombo.WinWidth * 0.50;
		}
	bUpdate = True;
	DiffChanged(true, true);
	ExplainedDifficulty = DifficultyCombo.GetValue();
	}
	
function DiffChanged(bool bUpdate, optional bool bSkipExplanation)
{
	local int diffnum;
	
	Super.DiffChanged(bUpdate, bSkipExplanation);
	diffnum = int(GetPlayerOwner().ConsoleCommand("get "@c_strDifficultyNumberPath));
	if (EnhancedCheckbox != None)
	{
		if (diffnum >= 13)
			EnhancedCheckbox.bDisabled = True;
		else
			EnhancedCheckbox.bDisabled = False;
		}
}	

function PossibleConvertToNightMode(out String URL)
{
	local int qmark,pound;
	local string BaseURL,qmarkparams,poundparams;
	
	if (NoHolidaysCheckbox != None 
		&& NoHolidaysCheckbox.GetValue())
		return;
	
	//log("Breaking down URL:"@URL);
	
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
			
		//log("URL broken down:"@BaseURL@"---"@qmarkparams);
			
		pound = InStr(BaseURL,"#");
		if (pound >= 0)
		{
			poundparams = Right(BaseURL, Len(BaseURL) - pound);
			BaseURL = Left(BaseURL, pound);
		}
		
//		log("Broken down further:"@BaseURL@"---"@poundparams);
		
		// If a night version of MapName exists, change it
		if (GetPlayerOwner().DoesMapExist("ngt-"$BaseURL))
			BaseURL = "ngt-"$BaseURL;
			
		//log("Final map to travel to:"@BaseURL);
			
		URL = BaseURL $ poundparams $ qmarkparams;
		
		//log("Reassembled URL:"@URL);
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Functions to start various days
///////////////////////////////////////////////////////////////////////////////
function int GetDayNumber()
{
	local string SelectedDay;
	local int i;
	
	if(DayCombo != None)
	{
		SelectedDay = DayCombo.GetValue();
		
		//for (i=0; i<ArrayCount(Days); i++)
		for (i=0; i<MaxDays; i++)
		{
			if (SelectedDay == Days[i])	
				return i;
		}
	}
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// Allows for use of enhanced mode, day selection and intro skip
///////////////////////////////////////////////////////////////////////////////
function StartGame2(bool bEnhanced)
{
	local P2Player p2p;
	local P2GameInfoSingle usegame;
	local Texture LoadTex;
	local int day, startday, i;
	
	usegame = GetGameSingle();
	p2p = usegame.GetPlayer();
	
	// Setup difficulty
	SetDiff();
	
	// Force sissy off on a new game
	p2p.UnSissy();
	P2RootWindow(Root).StartingGame();

	// Stop any active SceneManager so player will have a pawn
	usegame.StopSceneManagers();
	
	// xPatch: Okay so it seems like if the last game we played had different GameState
	// than the new one we are starting currently causes some weird issues with the game. 
	// Like the day selection option not changing the day, save being marked as cheated for "Testing maps via command line" 
	// and other wierd stuff. Thankfully, changing the GameState here and now fixes these issues.
	if(usegame.TheGameState != None && StartGameInfo != None)
		usegame.ChangeGameState(StartGameInfo.Default.GameStateClass);
	// End

	usegame.PrepIniStartVals();
	usegame.TheGameState.bEGameStart = bEnhanced;
	if (NoHolidaysCheckbox != None)
		usegame.bNoHolidays = NoHolidaysCheckbox.GetValue();
	else
		usegame.bNoHolidays = false;
		
	// xPatch: Classic Game
	if (ClassicGameCheckbox != None)
	{
		usegame.bNoEDWeapons = ClassicGameCheckbox.GetValue();
		usegame.TheGameState.bNoEDWeapons = ClassicGameCheckbox.GetValue(); 
	}

	// Turn off night mode if holidays are off
	if (usegame.bNoHolidays)
		usegame.TheGameState.bNightMode = false;
	
	usegame.SaveConfig();

	// Get the difficulty ready for this game state.
	usegame.SetupDifficultyOnce();

	// Reset the game timer
	usegame.TheGameState.TimeElapsed = 0;
	usegame.TheGameState.TimeStart = usegame.Level.GetMillisecondsNow();

	// Get rid of any things in his inventory before a new game starts
	P2Pawn(p2p.pawn).DestroyAllInventory();
	usegame.TheGameState.HudArmorClass = None;
	p2p.MyPawn.Armor = 0;

	// Game doesn't actually start until player is sent to first day,
	// which *should* happen at the end of the intro sequence.
	usegame.TheGameState.bChangeDayPostTravel = true;
	usegame.TheGameState.NextDay = 0;
	
	// xPatch: This method gets bugged if we play P2, AW or Workshop Game and then return to main menu.
	// Shows either wrong day or the texture is completly missing as it uses the game we played last to get load screens...
/*  // Force game to display "Saturday" when loading on weekends.
	if (DayToShowDuringLoad != 0)
	{
		usegame.bShowDayDuringLoad = True;
		usegame.DayToShowDuringLoad = DayToShowDuringLoad;
	}
*/
	// xPatch: Here's new and better method:
	if (StartGameInfo != None)
	{
		// Use defined game info to always get correct loading texture of the first day
		LoadTex = StartGameInfo.Default.Days[0].GetLoadTexture();
	}
	else // Should not happen -- but if does use AWPGameInfo (it has all 7 days) 
	{	
		if (DayToShowDuringLoad != 0)
			LoadTex = class'AWPGameInfo'.Default.Days[DayToShowDuringLoad].GetLoadTexture();
		else
			LoadTex = class'AWPGameInfo'.Default.Days[0].GetLoadTexture();
	}
	
	// xPatch: Starting from the selected day
	if(DayCombo != None 
		&& DayCombo.GetValue() != Days[0]
		&& StartGameInfo != None)
	{
		day = GetDayNumber();
		
		if(day != 0)	// Monday should never happen here
		{
			// Get URL to Start the game from
			if(StartGameInfo.default.Days[day].StartDayURL != "")
				StartGameURL = StartGameInfo.default.Days[day].StartDayURL $ StartGameInfo.Static.GetStartURL(false);
			else
				StartGameURL = StartGameInfo.default.StartNextDayURL $ StartGameInfo.Static.GetStartURL(false);

			// Night Mode
			PossibleConvertToNightMode(StartGameURL);
			
			// Paradise Lost TWP Mode
			PossibleConvertToSecondWeek(day);
			
			// Get loading texture for that day
			LoadTex = StartGameInfo.Default.Days[day].GetLoadTexture();
			
			// Change to the selected day
			usegame.TheGameState.bChangeDayPostTravel = true;
			usegame.TheGameState.NextDay = day;
			
			// Properly setup the game
			usegame.TheGameState.bStartDayPostTravel = True;
			usegame.TheGameState.StartDay = day;
		}
	}
	
	// xPatch: Force map for intro skip
	if (SkipCheckbox != None && bShouldForceMap)
		usegame.TheGameState.bForceMap = SkipCheckbox.GetValue();
	
	// xPatch: Use loading texture we got
	if (LoadTex != None)	
	{
		usegame.bShowDayDuringLoad = True;
		usegame.ForcedLoadTex = LoadTex;
	}
	
	//log("StartGameURL:"@StartGameURL);
	//log("ForcedLoadTex:"@LoadTex);
	
	// Actually start the game with the first level
	usegame.SendPlayerTo(p2p, StartGameURL$"?Mutator=?Workshop=0");
}

function PossibleConvertToSecondWeek(int Day)
{
	// STUB - Used in PLMenuStart_TwoWeeks.
}

function SeekritKodeEntered()
{
	GetGameSingle().bSeekritKodeEntered = True;
	GetGameSingle().SaveConfig();
	
	GotoMenu(class'MenuSeekrit');
}

function bool SeekritCodeAllowed()
{
	return GetGameSingle().HinallyOver();
}

// So, with controller support being a thing, the Konami code won't work (because B is the default key for execBackButton)
// Plus the original seekrit code implementation only works on the keyboard
// So we simplify it here... and by "simplify" I mean "make it more complex than it needs to be because of the hackjob way I implemented controller support"
function HandleSeekritCode(int KeyIn)
{
	local bool bAccepted;
	if (SeekritCodeAllowed()
		&& KodeEntered < SeekritKode.Length)
	{
		// Up
		if (KodeEntered == 0 || KodeEntered == 1)
			if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@KeyIn@MENU_UP_BUTTON) == "1")
				bAccepted = true;
				
		// Down
		if (KodeEntered == 2 || KodeEntered == 3)
			if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@KeyIn@MENU_DOWN_BUTTON) == "1")
				bAccepted = true;
				
		// Left
		if (KodeEntered == 4 || KodeEntered == 6)
			if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@KeyIn@MENU_LEFT_BUTTON) == "1")
				bAccepted = true;
				
		// Right
		if (KodeEntered == 5 || KodeEntered == 7)
			if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@KeyIn@MENU_RIGHT_BUTTON) == "1")
				bAccepted = true;
				
		if (bAccepted)
		{
			KodeEntered++;
			if (KodeEntered >= SeekritKode.Length)			
			{
				if (KodeAccepted != None)
					ShellLookAndFeel(LookAndFeel).PlayThisLocalSound(Self, KodeAccepted, 1.0);				
				SeekritKodeEntered();
			}
			else if (KeyAccepted != None)
				ShellLookAndFeel(LookAndFeel).PlayThisLocalSound(Self, KeyAccepted, 1.0);
		}
		else
		{		
			if (KodeEntered > 0 && KodeWrong != None)
				ShellLookAndFeel(LookAndFeel).PlayThisLocalSound(Self, KodeWrong, 1.0);
			KodeEntered = 0;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local int val;
	local class<UMenuStartGameWindow> StartGameClass;
	local string StartURL;

	Super.Notify(C, E);
	switch(E)
		{
		case DE_Change:
			switch (C)
				{
				case DifficultyCombo:
					// If they're using the joystick to cycle through the difficulty settings, don't pop up the They Hate Me explanation yet.
					// Wait for them to arrow off the difficulty option, first.
					DiffChanged(bUpdate, Root.bUsingJoystick);
					break;
				// xPatch: changing day disables skip intro.
				case DayCombo:
					if (SkipCheckbox != None)
					{
						if(DayCombo.GetValue() != Days[0])
						{
							SkipCheckbox.bDisabled = True;
							SkipCheckbox.SetValue(False);
						}
						else
							SkipCheckbox.bDisabled = False;
					}
					break;
				// End
				}
			break;
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				/*
				case StartChoice:
					// No special explanation, get ready to play
					if(!P2GameInfo(GetPlayerOwner().Level.Game).TheyHateMeMode())
					{
						// Normal game start
						if(!ShellRootWindow(Root).bFixSave)
						{
							// Start new (enhanced) game (they already know about the keys)
							if(ShellRootWindow(Root).bVerified
								&& ShellRootWindow(Root).bVerifiedPicked)
								GetGameSingle().StartGame(true);
							else if (!PlatformIsSteamDeck()) // Normal game, tell them about the keys
								GotoMenu(class'MenuImageKeys');
                            else
                                GotoMenu(class'MenuImageKeys_SteamDeck');
						}
						else // Just return back to the game you were dealing with
							// But save the difficulty and the game first
						{
							ResumeGameSaveDifficulty();
						}
					}
					else
						GotoMenu(class'MenuTheyHateMe');

					ShellRootWindow(Root).bLaunchedMultiplayer = false;
					break;
				*/
				case StartAW7:
					StartGameInfo = class'AWPGameInfo';
					StartURL = StartGameInfo.Static.GetStartURL(true, SkipCheckbox.GetValue());
					PossibleConvertToNightMode(StartURL);
					if (GetGameSingle().HinallyOver() && GetGameSingle().bShowedControls
						|| (DayCombo != None && DayCombo.GetValue() != Days[0]))	// xPatch: we need to do day select in this menu
					{
						StartGameURL = StartURL;
						bShouldForceMap = True;	// xPatch
						StartGame2(EnhancedCheckbox.GetValue());
						ShellRootWindow(Root).bLaunchedMultiplayer = false;
					}
					// If they haven't finished the game yet, show 'em how to play
					else 
					{
						ShellRootWindow(Root).bEnhancedMode = EnhancedCheckbox.GetValue();
						ShellRootWindow(Root).bNoHolidays = NoHolidaysCheckbox.GetValue();
						ShellRootWindow(Root).StartGameURL = StartURL;
						ShellRootWindow(Root).bNoEDWeapons = ClassicGameCheckbox.GetValue();	// xPatch
						ShellRootWindow(Root).bForceMap = SkipCheckbox.GetValue();				// xPatch
						ShellRootWindow(Root).StartGameInfo = StartGameInfo;					// xPatch
						
						SetDiff();
						
                        if (PlatformIsSteamDeck())
                            GotoMenu(class'MenuImageKeys_SteamDeck');
                        else
                            GotoMenu(class'MenuImageKeys');
					}
					break;
				case StartMF:
					StartGameInfo = class'GameSinglePlayer';
					StartURL = StartGameInfo.Static.GetStartURL(true, SkipCheckbox.GetValue());
					PossibleConvertToNightMode(StartURL);
					if (GetGameSingle().HinallyOver() && GetGameSingle().bShowedControls
						|| (DayCombo != None && DayCombo.GetValue() != Days[0]))	// xPatch: we need to do day select in this menu
					{
						StartGameURL = StartURL;
						bShouldForceMap = True;	// xPatch
						StartGame2(EnhancedCheckbox.GetValue());
						ShellRootWindow(Root).bLaunchedMultiplayer = false;
					}
					// If they haven't finished the game yet, show 'em how to play
					else 
					{
						ShellRootWindow(Root).bEnhancedMode = EnhancedCheckbox.GetValue();
						ShellRootWindow(Root).bNoHolidays = NoHolidaysCheckbox.GetValue();
						ShellRootWindow(Root).StartGameURL = StartURL;
						ShellRootWindow(Root).bNoEDWeapons = ClassicGameCheckbox.GetValue();	// xPatch
						ShellRootWindow(Root).bForceMap = SkipCheckbox.GetValue();				// xPatch
						ShellRootWindow(Root).StartGameInfo = StartGameInfo;					// xPatch
						
						SetDiff();
						
                        if (PlatformIsSteamDeck())
                            GotoMenu(class'MenuImageKeys_SteamDeck');
                        else
                            GotoMenu(class'MenuImageKeys');
					}
					break;
				case StartWeekend:
					StartGameInfo = class'AWGameSPFinal';
					StartURL = StartGameInfo.Static.GetStartURL(true, SkipCheckbox.GetValue());
					PossibleConvertToNightMode(StartURL);
					if (GetGameSingle().HinallyOver() && GetGameSingle().bShowedControls
						|| (DayCombo != None && DayCombo.GetValue() != Days[0]))	// xPatch: we need to do day select in this menu
					{
						// During weekend, show "Saturday" instead of "Monday" on the title card
						DayToShowDuringLoad = DAY_SATURDAY;
						StartGameURL = StartURL;
						bShouldForceMap = False;	// xPatch: Never force map in AW
						StartGame2(EnhancedCheckbox.GetValue());
						ShellRootWindow(Root).bLaunchedMultiplayer = false;
					}
					// If they haven't finished the game yet, show 'em how to play
					else 
					{
						ShellRootWindow(Root).bEnhancedMode = EnhancedCheckbox.GetValue();
						ShellRootWindow(Root).bNoHolidays = NoHolidaysCheckbox.GetValue();
						ShellRootWindow(Root).StartGameURL = StartURL;
						ShellRootWindow(Root).DayToShowDuringLoad = DAY_SATURDAY;
						ShellRootWindow(Root).bNoEDWeapons = ClassicGameCheckbox.GetValue();	// xPatch
						ShellRootWindow(Root).bForceMap = False;								// xPatch: Never force map in AW
						ShellRootWindow(Root).StartGameInfo = StartGameInfo;					// xPatch
						
						SetDiff();
						
                        if (PlatformIsSteamDeck())
                            GotoMenu(class'MenuImageKeys_SteamDeck');
                        else
                            GotoMenu(class'MenuImageKeys');
					}
					break;					
				case StartWorkshop:
					// Launch specialized workshop menu
					if (Root.GetLevel().SteamGetWorkshopStatus() != "")
					{
						MessageBox(WaitforWorkshopTitle, WaitforWorkshopText, MB_OK, MR_OK, MR_OK);
					}
					else
					{
						StartGameClass = class<UMenuStartGameWindow>(DynamicLoadObject("Shell.WorkshopStartGameWindow", class'Class'));
						GotoWindow(Root.CreateWindow(StartGameClass, 100, 100, 200, 200, Self, True));
					}
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Up and down: select menu items
// If the player arrows off the difficulty option and they changed it,
// explain They Hate Me etc. mode.
///////////////////////////////////////////////////////////////////////////////
function execMenuUpButton()
{
	// If they're on the difficulty option and arrow off, and it doesn't match the difficulty we last explained, explain it to them.
	if (Root.MouseWindow == DifficultyCombo
		&& DifficultyCombo.GetValue() != ExplainedDifficulty)
	{
		// Save in the new difficulty as the one we explained
		ExplainedDifficulty = DifficultyCombo.GetValue();
		// Dummy call to DiffChanged just to trigger the explanation
		DiffChanged(true);
	}
	NextMenuItem(-1);
}
function execMenuDownButton()
{
	// If they're on the difficulty option and arrow off, and it doesn't match the difficulty we last explained, explain it to them.
	if (Root.MouseWindow == DifficultyCombo
		&& DifficultyCombo.GetValue() != ExplainedDifficulty)
	{
		// Save in the new difficulty as the one we explained
		ExplainedDifficulty = DifficultyCombo.GetValue();
		// Dummy call to DiffChanged just to trigger the explanation
		DiffChanged(true);
	}
	NextMenuItem(1);
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	TitleSpacingY = 15

//	MenuWidth  = 375
	MenuWidth  = 475
//	MenuHeight = 400
	ItemSpacingY = 15
	HintLines=7

	TitleText	= "Select Game Mode"

	StartGameAW7="intro.fuk?Game=GameTypes.AWPGameInfo"
	StartGameWeekend="MovieIntro.fuk?Game=GameTypes.AWGameSPFinal"
	StartGameMF="intro.fuk?Game=GameTypes.GameSinglePlayer"
	StartAW7Help="Play all seven days."
	StartMFHelp="Play Monday through Friday only."
	StartWeekendHelp="Play Saturday and Sunday only."
	StartWorkshopHelp="Launch a browser for playing Workshop content."
	StartCustomHelp="Launch a browser for playing custom content."
	StartAW7Text="A Week In Paradise"
	StartMFText="POSTAL 2"
	StartWeekendText="Apocalypse Weekend"
	StartWorkshopText="Workshop..."
	StartCustomText="Custom..."
	EnhancedText="Enhanced Game"
	EnhancedHelp="This mode has more power-ups, several enhanced weapons, and some useful inventory items right from the start.\\nNOTICE: Speedrun achievements cannot be unlocked in this mode."
	SeekritKode[0]=38
	SeekritKode[1]=38
	SeekritKode[2]=40
	SeekritKode[3]=40
	SeekritKode[4]=37
	SeekritKode[5]=39
	SeekritKode[6]=37
	SeekritKode[7]=39
	KeyAccepted=None
	KodeAccepted=Sound'arcade.arcade_123'
	KodeWrong=None
	WaitforWorkshopTitle="Warning"
	WaitforWorkshopText="Wait for all Workshop content to initialize before attempting to start a Workshop game."
	NoHolidaysText="No Holidays"
	NoHolidaysHelp="Starts a new game without any special holiday events."
	
	// xPatch
	SkipText="Skip Intro"
	SkipHelp="Skips intro movie and immediately begins the game."
	ClassicGameText="Classic Mode"
	ClassicGameHelp="Disables some of the updated content to give that early 2003 feel."
	
	DayComboText = "Select Day"
	DayComboHelp = "Select day you want to start the game with.\\nNOTICE: Achievements for beating the game in certain ways cannot be unlocked when you don't start from the first day."
	Days[0] = "Monday"
	Days[1] = "Tuesday"
	Days[2] = "Wednesday"
	Days[3] = "Thursday"
	Days[4] = "Friday"
	Days[5] = "Saturday"
	Days[6] = "Sunday"
	
	UNLOCK_DAYSELECT_ACHIEVEMENT = SundayComplete
}
