///////////////////////////////////////////////////////////////////////////////
// New Game Mode Selection Menu
// by Man Chrzan for xPatch 2.0
//
// Made to make starting new game less confusing, 
// especially when there's so many checkboxes and options now. 
//
// Edit for Paradise Lost (removed workshop since it's alredy in the main one)
///////////////////////////////////////////////////////////////////////////////
class PLMenuGameModeToo extends MenuGameMode;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super(ShellMenuCW).CreateMenuContents();
	
	AddTitle(TitleText, F_FancyXL, ItemAlign);
	
	// Medium Font
	ItemHeight = 20;
	ItemFont = F_FancyM;
	
	if (FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
	OldStartChoice = AddChoice(OldStartText,	"",	ItemFont,	ItemAlign);
	
	// Large Font again
	ItemHeight = 32;
	ItemFont = F_FancyL;
	
	// Game Modes: A Week in Paradise, POSTAL 2, Apocalypse Weekend
	P2Choice 	=		AddChoice(StartMFText,			StartMFHelp,		ItemFont,	ItemAlign);
	AWChoice 	=		AddChoice(StartWeekendText,		StartWeekendHelp,	ItemFont,	ItemAlign);
	AWPChoice 	=		AddChoice(StartAW7Text,			StartAW7Help,		ItemFont,	ItemAlign);
	
	// Custom Difficulty
	if (SeekritOptionAllowed())
	{
		CustomDifficultyChoice =	    AddChoice(CustomDifficultyText,	"",	ItemFont,	ItemAlign);
	}

	// Workshop / Custom
	//if (GetLevel().IsSteamBuild())
	//	StartWorkshop =	AddChoice(StartWorkshopText,StartWorkshopHelp,	ItemFont,	ItemAlign);
	//else
	//	StartWorkshop =	AddChoice(StartCustomText,StartCustomHelp,	ItemFont,	ItemAlign);
	
	// Go Back
	BackChoice  = AddChoice(BackText,   "", ItemFont, TA_Left, true);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
}
