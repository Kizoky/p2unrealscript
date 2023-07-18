///////////////////////////////////////////////////////////////////////////////
// MenuStart_AWP.uc
// by Man Chrzan
//
// Menu to choose difficulty, checkboxes and start previously selected Gamemode.
// 
///////////////////////////////////////////////////////////////////////////////
class MenuStart_AWP extends MenuStart;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	// Call super to ShellMenuCW
	Super(ShellMenuCW).CreateMenuContents();
	
	AddTitle(TitleText, F_FancyXL, TA_Left);
	
	ItemFont = F_FancyL;
	
	// If launched from the custom difficulty window, remove difficulty combo 
	if (!StartCustomMode())
	{
		DifficultyCombo = AddComboBox(DifficultyText, DifficultyHelp, ItemFont);
		DifficultyCombo.List.MaxVisible = ArrayCount(P2GameInfoSingle(GetPlayerOwner().Level.Game).DifficultyNames);
	}
	
	// Day Selection (unlockled after completing the game)
	if (GameModeCompleted())
		DayCombo = AddComboBox(DayComboText, DayComboHelp, ItemFont);	
	
	// turn off no-holiday-mode thing
	GetGameSingle().bNoHolidays = false;
	GetGameSingle().SaveConfig();
	
	ItemFont = F_FancyM;	// Medium font for checkboxes
	ItemHeight = 20;		// and closer to each other
	
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
	
	// Classic Mode
	ClassicGameCheckbox = AddCheckbox(ClassicGameText, ClassicGameHelp, ItemFont);
	ClassicGameCheckbox.SetValue(False);
	
	// Skip Intro 
	SkipCheckbox = AddCheckbox(SkipText, SkipHelp, ItemFont);
	SkipCheckbox.SetValue(False);
	
	// Normal height
	ItemHeight = 32;
	ItemFont = F_FancyL;
	
	// Start 
	CreateStartOption();
	
	BackChoice  = AddChoice(BackText,   "", ItemFont, TA_Left, true);
	
	LoadValues();
	}
	
///////////////////////////////////////////////////////////////////////////////
// Create the start option for this menu.
///////////////////////////////////////////////////////////////////////////////
function CreateStartOption()
{
	StartAW7 =		AddChoice(StartText,		StartAW7Help,		ItemFont,	TA_Left);
}

///////////////////////////////////////////////////////////////////////////////
// Gets unlocked if we have completed the game or it is debug mode.
///////////////////////////////////////////////////////////////////////////////
function bool GameModeCompleted()
{
	return (GetGameSingle().HinallyOver() || FPSPlayer(GetPlayerOwner()).bEnableDebugMenu);
}

///////////////////////////////////////////////////////////////////////////////
// Handle custom difficulty
///////////////////////////////////////////////////////////////////////////////
function bool StartCustomMode()
{
	local int diffnum;
	diffnum = int(GetPlayerOwner().ConsoleCommand("get "@c_strDifficultyNumberPath));
	
	return (diffnum == 16);
}

function DiffChanged(bool bUpdate, optional bool bSkipExplanation)
{
	if (!StartCustomMode())
		Super.DiffChanged(bUpdate, bSkipExplanation);
}	

function SetDiff()
{
	if (!StartCustomMode())
		Super.SetDiff();
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	TitleText = "A Week In Paradise"
	MaxDays=7
	
	fCommonCtlArea=0.50		// Checkboxes a bit more to the left.
}
