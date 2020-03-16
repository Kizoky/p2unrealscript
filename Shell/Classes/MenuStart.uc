///////////////////////////////////////////////////////////////////////////////
// MenuStart.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Menu to force difficulty choice and to drive home the fact that it cannot be
// changed after a game is started--aren't all games this way?
//
// 8-15 Kamek - add in P2/AW/AWP selection backport from AW7
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
	
	if (GetGameSingle().IsHoliday('ANY_HOLIDAY'))
	{
		NoHolidaysCheckbox = AddCheckbox(NoHolidaysText, NoHolidaysHelp, ItemFont);
		NoHolidaysCheckbox.SetValue(False);
	}

	if (GetGameSingle().SeqTimeVerified())
	{
		EnhancedCheckbox = AddCheckbox(EnhancedText, EnhancedHelp, ItemFont);
		EnhancedCheckbox.SetValue(False);
	}

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
	
	if (NoHolidaysCheckbox.GetValue())
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
// Allows for use of enhanced mode
///////////////////////////////////////////////////////////////////////////////
function StartGame2(bool bEnhanced)
{
	local P2Player p2p;
	local P2GameInfoSingle usegame;

	usegame = GetGameSingle();
	p2p = usegame.GetPlayer();
	// Force sissy off on a new game
	p2p.UnSissy();
	P2RootWindow(Root).StartingGame();

	// Stop any active SceneManager so player will have a pawn
	usegame.StopSceneManagers();

	usegame.PrepIniStartVals();
	usegame.TheGameState.bEGameStart = bEnhanced;
	if (NoHolidaysCheckbox != None)
		usegame.bNoHolidays = NoHolidaysCheckbox.GetValue();
	else
		usegame.bNoHolidays = false;
		
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
	
	// Force game to display "Saturday" when loading on weekends.
	if (DayToShowDuringLoad != 0)
	{
		usegame.bShowDayDuringLoad = True;
		usegame.DayToShowDuringLoad = DayToShowDuringLoad;
	}
	
//	PossibleConvertToNightMode(StartGameURL);
	
	// Actually start the game with the first level
	//usegame.bQuitting = true;	// discard gamestate
	usegame.SendPlayerTo(p2p, StartGameURL$"?Mutator=?Workshop=0");
}

function SeekritKodeEntered()
{
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
							else  // Normal game, tell them about the keys
								GotoMenu(class'MenuImageKeys');
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
					StartURL = class'AWPGameInfo'.Static.GetStartURL(true);
					PossibleConvertToNightMode(StartURL);
					if (GetGameSingle().HinallyOver())
					{
						StartGameURL = StartURL;
						StartGame2(EnhancedCheckbox.GetValue());
						ShellRootWindow(Root).bLaunchedMultiplayer = false;
					}
					// If they haven't finished the game yet, show 'em how to play
					else 
					{
						ShellRootWindow(Root).bEnhancedMode = EnhancedCheckbox.GetValue();
						ShellRootWindow(Root).bNoHolidays = NoHolidaysCheckbox.GetValue();
						ShellRootWindow(Root).StartGameURL = StartURL;
						GotoMenu(class'MenuImageKeys');
					}
					break;
				case StartMF:
					StartURL = class'GameSinglePlayer'.Static.GetStartURL(true);
					PossibleConvertToNightMode(StartURL);
					if (GetGameSingle().HinallyOver())
					{
						StartGameURL = StartURL;
						StartGame2(EnhancedCheckbox.GetValue());
						ShellRootWindow(Root).bLaunchedMultiplayer = false;
					}
					// If they haven't finished the game yet, show 'em how to play
					else 
					{
						ShellRootWindow(Root).bEnhancedMode = EnhancedCheckbox.GetValue();
						ShellRootWindow(Root).bNoHolidays = NoHolidaysCheckbox.GetValue();
						ShellRootWindow(Root).StartGameURL = StartURL;
						GotoMenu(class'MenuImageKeys');
					}
					break;
				case StartWeekend:
					StartURL = class'AWGameSPFinal'.Static.GetStartURL(true);
					PossibleConvertToNightMode(StartURL);
					if (GetGameSingle().HinallyOver())
					{
						// During weekend, show "Saturday" instead of "Monday" on the title card
						DayToShowDuringLoad = DAY_SATURDAY;
						StartGameURL = StartURL;
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

	MenuWidth  = 375
	MenuHeight = 400
	ItemSpacingY = 15

	TitleText	= "Select Game Mode"

	StartGameAW7="intro.fuk?Game=GameTypes.AWPGameInfo"
	StartGameWeekend="MovieIntro.fuk?Game=GameTypes.AWGameSPFinal"
	StartGameMF="intro.fuk?Game=GameTypes.GameSinglePlayer"
	StartAW7Help="Play all seven days"
	StartMFHelp="Play Monday through Friday only"
	StartWeekendHelp="Play Saturday and Sunday only"
	StartWorkshopHelp="Launch a browser for playing Workshop content."
	StartCustomHelp="Launch a browser for playing custom content."
	StartAW7Text="A Week In Paradise"
	StartMFText="POSTAL 2"
	StartWeekendText="Apocalypse Weekend"
	StartWorkshopText="Workshop..."
	StartCustomText="Custom..."
	EnhancedText="Enhanced Game"
	EnhancedHelp="Play the Enhanced Game"
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
	}
