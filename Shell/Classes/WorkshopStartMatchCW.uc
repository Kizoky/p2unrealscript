class WorkshopStartMatchCW extends UTMenuStartMatchCW;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized, InGameChanged;

// Game Type
var UWindowComboControl GameCombo;
var localized string GameTypeText;
var localized string GameTypeHelp;
var localized string CustomDiffText;
var string Games[256];
var int MaxGames;
var UWindowCheckbox EnhancedCheck;
var localized string EnhancedText;
var localized string EnhancedHelp;

// Difficulty Combo
var UWindowComboControl DifficultyCombo;
var localized string DifficultyText;
var localized string DifficultyHelp;
var UWindowCheckBox NoHolidaysCheckbox;
var localized string NoHolidaysText, NoHolidaysHelp;

// xPatch:
var UWindowCheckbox ClassicCheck;
var localized string ClassicText;
var localized string ClassicHelp;
var UWindowCheckbox SkipCheck;
var localized string SkipText;
var localized string SkipHelp;

// Game summary
var UWindowDynamicTextArea GameSummaryWindow;
var localized string GameDescriptionMissingText;
var localized string GameTitleMissingText;

// Map List
var UMenuMapListCW MapWindow;
var float MapWindowHeight;
var string MapTitle;

// Map screenshot
var UMenuScreenshotCW ScreenshotWindow;
var float ScreenshotSize;
var Texture DefaultMapPreview;

// Map summary
var UWindowDynamicTextArea SummaryWindow;
var localized string MapDescriptionMissingText;
var localized string MapTitleMissingText;
var localized string DefaultMapTitleText;
var localized string DefaultMapDescriptionText;

const c_strDifficultyPath = "Postal2Game.P2GameInfo GameDifficulty";
const c_strDifficultyNumberPath = "Postal2Game.P2GameInfo GameDifficultyNumber";
const LieberPath = "Postal2Game.P2GameInfo bLieberMode";
const HestonPath = "Postal2Game.P2GameInfo bHestonMode";
const TheyHateMePath = "Postal2Game.P2GameInfo bTheyHateMeMode";
const InsaneoPath = "Postal2Game.P2GameInfo bInsaneoMode";
const ExpertPath = "Postal2Game.P2GameInfo bExpertMode";
const ContraPath = "Postal2Game.P2GameInfoSingle bContraMode";
const LudicrousPath = "Postal2Game.P2GameInfo bLudicrousMode";
const MasochistPath = "Postal2Game.P2GameInfo bMasochistMode";
const VeteranPath = "Postal2Game.P2GameInfo bVeteranMode";
const MeleePath = "Postal2Game.P2GameInfo bMeeleMode";
const HardLieberPath = "Postal2Game.P2GameInfo bHardLieberMode";
const NukeModePath = "Postal2Game.P2GameInfo bNukeMode";
const CustomPath = "Postal2Game.P2GameInfo bCustomMode";

const EnhancedPath = "Shell.ShellMenuCW bShowedEnhancedMode";

const DIFFICULTY_NUMBER_CUSTOM = 16;

var bool bInCustomMode;

///////////////////////////////////////////////////////////////////////////////
// Get the single player info.
// 02/10/03 JMI Started to macroify this which we seem to be doing commonly
//				lately. 
///////////////////////////////////////////////////////////////////////////////
function P2GameInfoSingle GetGameSingle()
	{
	return P2GameInfoSingle(Root.GetLevel().Game);
	}

function Created()
{
	local int Selection;
	local class<P2GameInfoSingle> UseClass;
	local string Desc;
	local int val;
	local bool CustomBool;
	local int ControlOffset2;

	Super(UMenuPageWindow).Created();
	
	// turn off no-holiday-mode thing
	GetGameSingle().bNoHolidays = false;
	GetGameSingle().SaveConfig();

	// If launched from the custom difficulty window, remove difficulty combo and enhanced tickbox
	val = int(GetPlayerOwner().ConsoleCommand("get"@c_strDifficultyNumberPath));

	if (val == DIFFICULTY_NUMBER_CUSTOM
		&& (ShellRootWindow(Root).MyMenu.Class == class'MenuSeekrit' || ShellRootWindow(Root).MyMenu.IsA('PLMenuSeekrit')))
		bInCustomMode = true;	

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		warn(self @ "Error: Missing UMenuBotmatchClientWindow parent.");

	// Game Type
	GameCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', /*ControlLeft*/ 10, ControlOffset, ControlWidth, ControlHeight));
	GameCombo.SetButtons(True);
	GameCombo.SetText(GameTypeText);
	GameCombo.SetHelpText(GameTypeHelp);
	GameCombo.SetFont(ControlFont);
	GameCombo.SetEditable(False);
	GameCombo.EditBoxWidth = 240;
	
	// Difficulty Combo
	if (!bInCustomMode)
	{
		DifficultyCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 365, ControlOffset, ControlWidth, ControlHeight));
		DifficultyCombo.SetButtons(True);
		DifficultyCombo.SetText(DifficultyText);
		DifficultyCombo.SetHelpText(DifficultyHelp);
		DifficultyCombo.SetFont(ControlFont);
		DifficultyCombo.SetEditable(False);
		//DifficultyCombo.Align = TA_Left;
		DifficultyCombo.EditBoxWidth = 150;
	}
	
	ControlOffset += (ControlHeight * 1.5);	
	
	ControlLeft = 10;
	ControlWidth = 130;
	
	// Classic Mode Checkbox
	ClassicCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ClassicCheck.SetText(ClassicText);
	ClassicCheck.SetHelpText(ClassicHelp);
	ClassicCheck.SetFont(F_SmallBold);
	ClassicCheck.bChecked = false;
	ClassicCheck.bDisabled = false;
	ClassicCheck.Align = TA_LeftofText;
	if (bInCustomMode)
	{
		// Pull classic setting from custom difficulty menu
		CustomBool = MenuStart(ShellRootWindow(Root).MyMenu).ClassicGameCheckbox.bChecked;
		WorkshopStartGameCW(BotmatchParent).bClassic = CustomBool;
		ClassicCheck.SetValue(CustomBool);
	}
	
	// Enhanced Mode Checkbox
	if (GetGameSingle().SeqTimeVerified())
	{
		ControlLeft += ControlWidth + 15;
		
		EnhancedCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
		EnhancedCheck.SetText(EnhancedText);
		EnhancedCheck.SetHelpText(EnhancedHelp);
		EnhancedCheck.SetFont(F_SmallBold);
		EnhancedCheck.bChecked = false;
		EnhancedCheck.Align = TA_LeftofText;
		if(bInCustomMode)
		{
			// Pull enhanced setting from custom difficulty menu
			CustomBool = MenuStart(ShellRootWindow(Root).MyMenu).EnhancedCheckbox.bChecked;
			WorkshopStartGameCW(BotmatchParent).bEnhanced = CustomBool;
			EnhancedCheck.SetValue(CustomBool);
		}
	}
	
	
	
	// Right Side
	ControlLeft += ControlWidth + 15;
	
	SkipCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	SkipCheck.SetText(SkipText);
	SkipCheck.SetHelpText(SkipHelp);
	SkipCheck.SetFont(F_SmallBold);
	SkipCheck.bChecked = false;
	SkipCheck.Align = TA_LeftofText;
	if(bInCustomMode)
	{
		// Pull enhanced setting from custom difficulty menu
		CustomBool = MenuStart(ShellRootWindow(Root).MyMenu).SkipCheckbox.bChecked;
		WorkshopStartGameCW(BotmatchParent).bSkipIntro = CustomBool;
		SkipCheck.SetValue(CustomBool);
	}
	
	if (GetGameSingle().IsHoliday('ANY_HOLIDAY'))
	{
		ControlLeft += ControlWidth + 15;
		
		NoHolidaysCheckbox = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
		NoHolidaysCheckbox.SetText(NoHolidaysText);
		NoHolidaysCheckbox.SetHelpText(NoHolidaysHelp);
		NoHolidaysCheckbox.SetFont(F_SmallBold);
		NoHolidaysCheckbox.bChecked = false;
		NoHolidaysCheckbox.Align = TA_LeftofText;
		
		if(bInCustomMode)
		{
			// Pull holiday setting from custom difficulty menu
			CustomBool = MenuStart(ShellRootWindow(Root).MyMenu).NoHolidaysCheckbox.bChecked;
			WorkshopStartGameCW(BotmatchParent).bNoHolidays = CustomBool;
			NoHolidaysCheckbox.SetValue(CustomBool);	
		}
	}
	
	ControlOffset += (ControlHeight * 4.0);	
	
	// Game Summary Window
	GameSummaryWindow = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	GameSummaryWindow.bAutoScrollbar = true;
	GameSummaryWindow.bScrollOnResize = false;
	GameSummaryWindow.bTopCentric = true;

	// Summary Window
	SummaryWindow = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	SummaryWindow.bAutoScrollbar = true;
	SummaryWindow.bScrollOnResize = false;
	SummaryWindow.bTopCentric = true;
	
	// Screenshot Window
	ScreenshotWindow = UMenuScreenshotCW(CreateWindow(class'WorkshopScreenshotCW', 0, 0, 100, 100));

	Selection = FillInGameCombo();
	BotmatchParent.GameType = Games[Selection];
	BotmatchParent.GameClass = Class<GameInfo>(DynamicLoadObject(BotmatchParent.GameType, class'Class'));
	GameCombo.SetSelectedIndex(Selection);
	
	UseClass = class<P2GameInfoSingle>(BotmatchParent.GameClass);
	desc = UseClass.Default.GameDescription;
	if (desc == "")
		Desc = GameDescriptionMissingText;
	
	GameSummaryWindow.Clear();
	GameSummaryWindow.AddText(Desc);
	
	if (ClassicCheck != None)
	{
		if(!UseClass.Default.bAllowClassicGame)
		{
			ClassicCheck.bDisabled = true;
			ClassicCheck.bChecked = false;
		}
		else
			ClassicCheck.bDisabled = false;
	}
}

function AfterCreate()
{
	local int i;
	local P2GameInfoSingle psg;
	local float val;
	
	Super(UMenuPageWindow).AfterCreate();

	// Map List Window (must create after GameCombo has been created and filled in)
	MapWindow = UMenuMapListCW(CreateWindow(class'WorkshopMapListCW', BodyLeft, ControlOffset, 100, MapWindowHeight, BotmatchParent));
	MapWindow.HelpArea = helparea;
	
	// Fill in difficulty box
	if (!bInCustomMode)
	{
		psg = GetGameSingle();
		DifficultyCombo.List.MaxVisible = ArrayCount(psg.DifficultyNames);
		DifficultyCombo.Clear();

		for(i=0; i<ArrayCount(psg.DifficultyNames); i++)
			DifficultyCombo.AddItem(psg.DifficultyNames[i]);

		val = int(GetPlayerOwner().ConsoleCommand("get"@c_strDifficultyNumberPath));

		if (val == DIFFICULTY_NUMBER_CUSTOM)
			// resets Custom to Average
			val = 5;

		DifficultyCombo.SetValue(psg.DifficultyNames[int(val)]);
	}
		
	Initialized = true;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int lines, SummarySpace;
	local float XL, YL;
	local Font oldFont;
	
	Super(UMenuPageWindow).BeforePaint(C, X, Y);

	MapWindowHeight = (BodyHeight - (ControlOffset - BodyTop)) * 0.40;
	ScreenshotSize = ((BodyHeight - (ControlOffset - BodyTop)) * 0.60) - 6;
	
	oldFont = C.Font;
	C.Font = root.Fonts[GameCombo.EditBox.Font];
	C.StrLen(GameTypeText, XL, YL);
	GameCombo.SetSize(XL + 15 + GameCombo.EditBoxWidth, ControlHeight);
	//GameCombo.WinLeft = BodyLeft + (BodyWidth - GameCombo.WinWidth) / 2;
	GameCombo.SetTextColor(TC);
	C.Font = oldFont;
	
	DifficultyCombo.SetSize(60 + DifficultyCombo.EditBoxWidth, ControlHeight);

	MapWindow.SetSize(BodyWidth - 6, MapWindowHeight);
	MapWindow.WinLeft = BodyLeft + 3;

	ScreenshotWindow.SetSize(ScreenshotSize, ScreenshotSize);
	ScreenshotWindow.WinLeft = BodyLeft + BodyWidth - ScreenshotSize - 3;
	ScreenshotWindow.WinTop = ControlOffset + MapWindowHeight + 3;
	
	oldFont = C.Font;
	C.Font = root.Fonts[SummaryWindow.Font];
	C.StrLen("Try", XL, YL);
	SummarySpace = ScreenshotSize - YL;
	for(lines = 0; lines * YL < SummarySpace; lines++);
	SummaryWindow.SetSize(BodyWidth - (ScreenshotSize + 6), (lines-1)*YL);
	SummaryWindow.WinLeft = BodyLeft;
	SummaryWindow.WinTop = ScreenshotWindow.WinTop + YL;
	C.Font = oldFont;

	oldFont = C.Font;
	C.Font = root.Fonts[GameSummaryWindow.Font];
	C.StrLen("Try", XL, YL);
	SummarySpace = ScreenshotSize - YL;
	lines = 4;
	GameSummaryWindow.SetSize(BodyWidth, (lines-1)*YL);
	GameSummaryWindow.WinLeft = BodyLeft;
	GameSummaryWindow.WinTop = GameCombo.WinTop + YL + (ControlHeight * 2.0);
	C.Font = oldFont;
}

function Paint(Canvas C, float X, float Y)
{
	local float XL, YL;
	local string str;

	Super(UMenuPageWindow).Paint(C, X, Y);

	C.Font = Root.Fonts[F_SmallBold];
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	// Draw map title
	str = MapTitle;
	C.StrLen(str, XL, YL);
	ClipText(C, BodyLeft + (SummaryWindow.WinWidth - XL)/2, ScreenshotWindow.WinTop, str, True);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super(UMenuPageWindow).Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case GameCombo:
			GameChanged();
			break;
		case ClassicCheck:
			WorkshopStartGameCW(BotmatchParent).bClassic = ClassicCheck.bChecked; 
		case EnhancedCheck:
			WorkshopStartGameCW(BotmatchParent).bEnhanced = EnhancedCheck.bChecked;
			break;
		case SkipCheck:
			WorkshopStartGameCW(BotmatchParent).bSkipIntro = SkipCheck.bChecked;
			break;	
		case NoHolidaysCheckbox:
			WorkshopStartGameCW(BotmatchParent).bNoHolidays = NoHolidaysCheckbox.bChecked;		
			break;
		case DifficultyCombo:
			DiffChanged();
			break;
		}
		break;
	case DE_Click:
		switch(C)
		{
		}
		break;
	}
}

function DiffChanged()
{
	local string diffname;
	local int val, diffnum;
	local P2GameInfoSingle psg;
	local bool bLieberMode, bHestonMode, bTheyHateMeMode, bInsaneoMode, bExpertMode, bMasochistMode, bVeteranMode, bLudicrousMode;
	local bool bTheyHateMeWarning, bPOSTALWarning, bImpossibleWarning, bLudicrousWarning;
	local class<P2GameInfoSingle> GameClass;

	psg = GetGameSingle();

	diffname = DifficultyCombo.GetValue();
	//log(self$" DiffChanged diffname after change "$diffname,'Debug');
	
	// Lieber Mode
	if(diffname == psg.DifficultyNames[0])
	{
		val = 0;
		diffnum = 0;
		bLieberMode = True;
	}
	else if(diffname == psg.DifficultyNames[1])
	{
		val = 1;
		diffnum = 1;
	}
	else if(diffname == psg.DifficultyNames[2])
	{
		val = 2;
		diffnum = 2;
	}
	else if(diffname == psg.DifficultyNames[3])
	{
		val = 3;
		diffnum = 3;
	}
	else if(diffname == psg.DifficultyNames[4])
	{
		val = 4;
		diffnum = 4;
	}
	else if(diffname == psg.DifficultyNames[5])
	{
		val = 5;
		diffnum = 5;
	}
	else if(diffname == psg.DifficultyNames[6])
	{
		val = 6;
		diffnum = 6;
	}
	else if(diffname == psg.DifficultyNames[7])
	{		
		val = 7;
		diffnum = 7;
	}
	else if(diffname == psg.DifficultyNames[8])
	{
		val = 8;
		diffnum = 8;
	}
	else if(diffname == psg.DifficultyNames[9])
	{
		val = 9;
		diffnum = 9;
	}
	// Heston Mode
	else if(diffname == psg.DifficultyNames[10])
	{
		val = 10;
		diffnum = 10;
		bHestonMode = True;
	}
	// Insaneo Mode
	// Game doesn't get any more difficult past this point in terms of AI --
	// just various bullshit things we throw at the player like NPC's with big guns.
	// Otherwise, POSTAL and Impossible mode would truly be impossible.
	else if(diffname == psg.DifficultyNames[11])
	{
		val = 10;
		diffnum = 11;
		bInsaneoMode = True;
	}
	// They Hate Me Mode
	else if(diffname == psg.DifficultyNames[12])
	{
		val = 10;
		diffnum = 12;
		bTheyHateMeMode = True;
		bTheyHateMeWarning = True;
	}
	// POSTAL mode - turns on Hestonworld, They Hate Me, and Expert
	else if(diffname == psg.DifficultyNames[13])
	{
		val = 10;
		diffnum = 13;
		bHestonMode = True;
		bTheyHateMeMode = True;
		bExpertMode = True;
		bPOSTALWarning = True;
	}
	// Impossible Mode - turns on Insaneo, They Hate Me, and Expert
	else if(diffname == psg.DifficultyNames[14])
	{
		val = 10;
		diffnum = 14;
		bInsaneoMode = True;
		bTheyHateMeMode = True;
		bExpertMode = True;
		bPOSTALWarning = True;
	}
	// Ludicrous Mode - turns on Masochist, They Hate Me, and Expert... EVERYTHING!
	else if(diffname == psg.DifficultyNames[15])
	{
		val = 15;
		diffnum = 15;
		bVeteranMode = True;
		bMasochistMode = True;
		bLudicrousMode = True;
		bTheyHateMeMode = True;
		bExpertMode = True;
		bLudicrousWarning = True;
	}
	// Custom mode - reset to Average difficulty
	else
	{
		val = 5;
		diffnum = 5;
	}
	// set diff
	GameClass = class<P2GameInfoSingle>(BotmatchParent.GameClass);
	//log(self$" DiffChanged"@GameClass@"diff value "$val@"diff num"@diffnum@"Lieber Heston Hate Insane Expert"@bLieberMode@bHestonMode@bTheyHateMeMode@bInsaneoMode@bExpertMode,'Debug');

	GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyPath@val);
	GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyNumberPath@diffnum);
	GetPlayerOwner().ConsoleCommand("set"@LieberPath@bLieberMode);
	psg.TheGameState.bLieberMode = bLieberMode;
	GameClass.Default.bLieberMode = bLieberMode;
	GetPlayerOwner().ConsoleCommand("set"@HestonPath@bHestonMode);
	psg.TheGameState.bHestonMode = bHestonMode;
	GameClass.Default.bHestonMode = bHestonMode;
	GetPlayerOwner().ConsoleCommand("set"@TheyHateMePath@bTheyHateMeMode);
	psg.TheGameState.bTheyHateMeMode = bTheyHateMeMode;
	GameClass.Default.bTheyHateMeMode = bTheyHateMeMode;
	GetPlayerOwner().ConsoleCommand("set"@InsaneoPath@bInsaneoMode);
	psg.TheGameState.bInsaneoMode = bInsaneoMode;
	GameClass.Default.bInsaneoMode = bInsaneoMode;
	GetPlayerOwner().ConsoleCommand("set"@ExpertPath@bExpertMode);
	psg.TheGameState.bExpertMode = bExpertMode;
	GameClass.Default.bExpertMode = bExpertMode;
	// xPatch:
	GetPlayerOwner().ConsoleCommand("set"@LudicrousPath@bLudicrousMode);
	psg.TheGameState.bLudicrousMode = bLudicrousMode;
	GameClass.Default.bLudicrousMode = bLudicrousMode;
	GetPlayerOwner().ConsoleCommand("set"@VeteranPath@bVeteranMode);
	psg.TheGameState.bVeteranMode = bVeteranMode;
	GameClass.Default.bVeteranMode = bVeteranMode;
	GetPlayerOwner().ConsoleCommand("set"@MasochistPath@bMasochistMode);
	psg.TheGameState.bMasochistMode = bMasochistMode;
	GameClass.Default.bMasochistMode = bMasochistMode;
	GetPlayerOwner().ConsoleCommand("set"@MeleePath@"false");
	psg.TheGameState.bMeeleMode = false;
	GameClass.Default.bMeeleMode = false;
	GetPlayerOwner().ConsoleCommand("set"@HardLieberPath@"false");
	psg.TheGameState.bHardLieberMode = false;
	GameClass.Default.bHardLieberMode = false;
	GetPlayerOwner().ConsoleCommand("set"@NukeModePath@"false");
	psg.TheGameState.bNukeMode = false;
	GameClass.Default.bNukeMode = false;
	// End
	GetPlayerOwner().ConsoleCommand("set"@CustomPath@"false");
	psg.TheGameState.bCustomMode = false;
	GameClass.Default.bCustomMode = false;
	
	GameClass.StaticSaveConfig();
	psg.GameDifficulty = val;
	// Update the gamestate here, also, if we have one
	if(psg.TheGameState != None)
		psg.TheGameState.GameDifficulty = val;
	if (EnhancedCheck != None)
	{
		if (diffnum >= 13)
		{
			EnhancedCheck.bDisabled = True;
			EnhancedCheck.bChecked = False;
		}
		else
			EnhancedCheck.bDisabled = False;
	}
}

function GameChanged()
{
	local int CurrentGame, i;
	local string Desc;
	local class<P2GameInfoSingle> UseClass;

	if (!Initialized || InGameChanged)
		return;

	CurrentGame = GameCombo.GetSelectedIndex();
	if(BotmatchParent.GameType == Games[CurrentGame])
		return;

	MapWindow.SaveConfigs();
	Initialized = false;
	InGameChanged = True;

	BotmatchParent.GameType = Games[CurrentGame];
	if(BotmatchParent.GameClass != None)
		BotmatchParent.GameClass.static.StaticSaveConfig();

	BotmatchParent.GameClass = Class<GameInfo>(DynamicLoadObject(BotmatchParent.GameType, class'Class'));
	if ( BotmatchParent.GameClass == None )
	{
		MaxGames--;
		if ( MaxGames > CurrentGame )
		{
			for ( i=CurrentGame; i<MaxGames; i++ )
				Games[i] = Games[i+1];
		}
		else if ( CurrentGame > 0 )
			CurrentGame--;
		GameCombo.SetSelectedIndex(CurrentGame);
		InGameChanged = False;
		return;
	}

	Initialized = true;
	BotmatchParent.GameChanged();
	InGameChanged = False;
	
	UseClass = class<P2GameInfoSingle>(BotmatchParent.GameClass);
	desc = UseClass.Default.GameDescription;
	if (desc == "")
		Desc = GameDescriptionMissingText;
	
	GameSummaryWindow.Clear();
	GameSummaryWindow.AddText(Desc);
	
	// don't load the map list again...
	//MapWindow.LoadMapList();
	
	// xPatch: new checkboxes
	if(!UseClass.Default.bAllowClassicGame)
	{
		ClassicCheck.bDisabled = true;
		ClassicCheck.bChecked = false;
	}
	else
		ClassicCheck.bDisabled = false;

	if(UseClass.Default.IntroURL == UseClass.Default.StartFirstDayURL
		|| UseClass.Default.StartFirstDayURL == ""
		|| UseClass.Default.IntroURL == "")
	{
		SkipCheck.bDisabled = true;
		SkipCheck.bChecked = false;
	}
	else
		SkipCheck.bDisabled = false;
}

function MapChanged()
{
	if (!Initialized)
		return;
}

function int FillInGameCombo()
{
	local int i, j, Selection;
	local class<GameInfo> TempClass;
	local string NextGame, NextCategory;
	local string TempGames[256];
	local bool bFoundSavedGameClass, bAlreadyHave;

	// Compile a list of all gametypes.
	i=0;
	TempClass = class'P2GameInfoSingle';
	GetPlayerOwner().GetNextIntDesc("P2GameInfoSingle", 0, NextGame, NextCategory);
	while (NextGame != "")
	{
		// xPatch: Check for dupilcates
		bAlreadyHave=False;
		for (j=0; j<256; j++)
		{
			if(TempGames[j] == NextGame) 
			{
				bAlreadyHave=True;
				warn("Already have:"@NextGame);
			}
		}
		
		if(!bAlreadyHave)
			TempGames[i] = NextGame;
		
		i++;
		if(i == 256)
		{
			warn("More than 256 gameinfos listed in int files");
			break;
		}
		GetPlayerOwner().GetNextIntDesc("P2GameInfoSingle", i, NextGame, NextCategory);
	}

	// Fill the control.
	for (i=0; i<256; i++)
	{
		if (TempGames[i] != "")
		{
			Games[MaxGames] = TempGames[i];
			if ( !bFoundSavedGameClass && (Games[MaxGames] ~= BotmatchParent.GameType) )
			{
				bFoundSavedGameClass = true;
				Selection = MaxGames;
			}
			TempClass = Class<GameInfo>(DynamicLoadObject(Games[MaxGames], class'Class'));
			if (TempClass != None)
			{
				GameCombo.AddItem(TempClass.Default.GameName);
				MaxGames++;
			}
		}
	}

	return Selection;
}

function SetMap(string MapName)
{
	local int i;
	local LevelSummary L;

	i = InStr(Caps(MapName), ".FUK");
	if(i != -1)
		MapName = Left(MapName, i);
		
	WorkshopStartGameCW(BotmatchParent).SelectedMap = MapName;

	L = LevelSummary(DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary'));

	SummaryWindow.Clear();
	MapTitle = "";
	if(L != None)
	{
		if (L.Screenshot == None)
			L.Screenshot = DefaultMapPreview;
		ScreenshotWindow.SetMap(L);

		if(L.Description != "")
			SummaryWindow.AddText(L.Description);
		else
			SummaryWindow.AddText(MapDescriptionMissingText);

		if (L.Title != "")
			MapTitle = L.Title;
		else
			MapTitle = MapTitleMissingText;
	}
	else if (MapName == class'WorkshopMapListCW'.Default.DefaultText)
	{
		SummaryWindow.AddText(DefaultMapDescriptionText);
		MapTitle = DefaultMapTitleText;
	}
}

defaultproperties
{
	PageHeaderText="Choose your game mode and custom map (if desired)"
	GameTypeText="Game Mode"
	GameTypeHelp="Pick the type of game you want to play."
	MapDescriptionMissingText="No description has been provided for this map."
	MapTitleMissingText="Untitled"
	EnhancedText="Enhanced Game"
	EnhancedHelp="Play the Enhanced Game"
	ClassicText="Classic Mode"
	ClassicHelp="Play Classic Mode"
	SkipText="Skip Intro"
	GameDescriptionMissingText="No description has been provided for this game mode."
	GameTitleMissingText="Untitled Game"
	DefaultMapTitleText="Intro Map"
	DefaultMapDescriptionText="Loads the selected game's intro or default map."
	DifficultyText="Difficulty"
	DifficultyHelp="Sets game difficulty.  Cannot be changed after game begins.  Note: Custom game modes may override or ignore this setting."
	CustomDiffText="Custom"
	NoHolidaysText="No Holidays"
	NoHolidaysHelp="Starts a new game without any special holiday events."
	DefaultMapPreview=Texture'p2misc_full.Workshop.DefaultMapPreview'	
}
