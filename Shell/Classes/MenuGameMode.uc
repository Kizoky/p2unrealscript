///////////////////////////////////////////////////////////////////////////////
// New Game Mode Selection Menu
// by Man Chrzan for xPatch 2.0
//
// Made to make starting new game less confusing, 
// especially when there's so many checkboxes and options now. 
///////////////////////////////////////////////////////////////////////////////
class MenuGameMode extends MenuStart;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var ShellMenuChoice		AWPChoice, P2Choice, AWChoice, CustomDifficultyChoice, OldStartChoice;
var localized string	OldStartText, CustomDifficultyText;

var class<ShellMenuCW> StartMenuClass;

// Finished A Week In Paradise on POSTAL difficulty.
const UNLOCK_ACHIEVEMENT = 'NightmareEnding';

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
		CustomDifficultyChoice =	    AddChoice(CustomDifficultyText,	"",	ItemFont,	ItemAlign);

	// Workshop / Custom
	if (GetLevel().IsSteamBuild())
		StartWorkshop =	AddChoice(StartWorkshopText,StartWorkshopHelp,	ItemFont,	ItemAlign);
	else
		StartWorkshop =	AddChoice(StartCustomText,StartCustomHelp,	ItemFont,	ItemAlign);
	
	// Go Back
	BackChoice  = AddChoice(BackText,   "", ItemFont, TA_Left, true);
}

// We show the secret option if it's allowed to work
// + we beaten AWP on POSTAL difficulty (or are in Debug Mode)
function bool SeekritOptionAllowed()
{
	return ( (SeekritCodeAllowed() && GetGameSingle().bSeekritKodeEntered) 
		|| (SeekritCodeAllowed() && FPSPlayer(GetPlayerOwner()).bEnableDebugMenu) );
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local String NewGameURL;
	local class<UMenuStartGameWindow> StartGameClass;

	Super(ShellMenuCW).Notify(C, E);
	
	switch(E)
		{
		case DE_Click:
			if (C != None)
				switch (C)
					{
					case AWPChoice:
						SetSingleplayer();
						GotoStartMenu(class'MenuStart_AWP');
						break;

					case P2Choice:
						SetSingleplayer();
						GotoStartMenu(class'MenuStart_P2');
						break;

					case AWChoice:
						SetSingleplayer();
						GotoStartMenu(class'MenuStart_AW');
						break;

					// Custom Difficulty
					case CustomDifficultyChoice:
						SetSingleplayer();
						GotoMenu(class'MenuSeekrit');
						break;
					
					// Old Start menu
					case OldStartChoice:
						GotoMenu(class'MenuStart');
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
						
					case BackChoice:
						GoBack();
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
// Go to the start menu for selected game mode
///////////////////////////////////////////////////////////////////////////////
function GotoStartMenu(class<ShellMenuCW> StartMenuClass)
{
	local bool bShowEnhanced;
	local int diffnum;
	
	bShowEnhanced = bool(GetPlayerOwner().ConsoleCommand("get"@EnhancedPath));
	diffnum = int(GetPlayerOwner().ConsoleCommand("get "@c_strDifficultyNumberPath));
	
	// Before we start check if we were on custom difficulty
	if(diffnum == 16) // fix it by restoring to average
		GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyNumberPath@5);
	
	// They just unlocked enhanced mode!
	if (!bShowEnhanced && GetGameSingle().SeqTimeVerified())
	{
		class'MenuEnhanced'.default.PickStartMenu = StartMenuClass;
		GotoMenu(class'MenuEnhanced');
	}
	else
		GotoMenu(StartMenuClass);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	CustomDifficultyText="Custom Difficulty..."
	OldStartText="(DEBUG) Old start menu"
	
	bBlockConsole=false
	
	//MenuWidth = 550
	//MenuWidth  = 375
	//TitleHeight = 80 //100
	//TitleSpacingY = 0
	//ItemHeight = 42 //50
	//ItemSpacingY = 5
	}
