///////////////////////////////////////////////////////////////////////////////
// New Game Mode Selection Menu
// by Man Chrzan for xPatch 2.0
//
// Made to make starting new game less confusing, 
// especially when there's so many checkboxes and options now. 
///////////////////////////////////////////////////////////////////////////////
class PLMenuGameMode extends MenuGameMode;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var ShellMenuChoice		PLChoice, TWPChoice, BaseGameChoice;
var localized string	PLStartText, TWPStartText, BaseGameText;
var localized string	PLStartHelp, TWPStartHelp, BaseGameHelp;

var class<ShellMenuCW> StartMenuClass;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super(ShellMenuCW).CreateMenuContents();
	
	AddTitle(TitleText, F_FancyXL, ItemAlign);
	
	// Font 
	ItemHeight = 32;
	ItemFont = F_FancyL;
	
	// Game Modes: Paradise Lost, Two Weeks, Original
	PLChoice 		=		AddChoice(PLStartText,			PLStartHelp,		ItemFont,	ItemAlign);
	TWPChoice 		=		AddChoice(TWPStartText,			TWPStartHelp,		ItemFont,	ItemAlign);
	BaseGameChoice 	=		AddChoice(BaseGameText,			BaseGameHelp,		ItemFont,	ItemAlign);
	
	// Custom Difficulty
	if (SeekritOptionAllowed())
	{
		CustomDifficultyChoice =	    AddChoice(CustomDifficultyText,	"",	ItemFont,	ItemAlign);
	}

	// Workshop / Custom
	if (GetLevel().IsSteamBuild())
		StartWorkshop =	AddChoice(StartWorkshopText,StartWorkshopHelp,	ItemFont,	ItemAlign);
	else
		StartWorkshop =	AddChoice(StartCustomText,StartCustomHelp,	ItemFont,	ItemAlign);
	
	// Go Back
	BackChoice  = AddChoice(BackText,   "", ItemFont, TA_Left, true);
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local String NewGameURL;
	local class<UMenuStartGameWindow> StartGameClass;
	local bool bUseSuper;
	
	bUseSuper = true;

	switch(E)
	{
		case DE_Click:
			if (C != None)
				switch (C)
					{
					case PLChoice:
						SetSingleplayer();
						GotoStartMenu(class'PLMenuStart');
						bUseSuper = false;
						break;

					case TWPChoice:
						SetSingleplayer();
						GotoStartMenu(class'PLMenuStart_TwoWeeks');
						bUseSuper = false;
						break;

					// Custom Difficulty
					case CustomDifficultyChoice:
						GotoMenu(class'PLMenuSeekrit');
						bUseSuper = false;
						break;
						
					// Base Game
					case BaseGameChoice:
						GotoMenu(class'PLMenuGameModeToo');
						bUseSuper = false;
						break;
					}
				break;
	}
	if (bUseSuper)
		Super.Notify(C, E);
}

function bool SeekritCodeAllowed()
{
	return GetGameSingle().FinallyOver();
}

function SeekritKodeEntered()
{
	GotoMenu(class'PLMenuSeekrit');
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
		class'PLMenuEnhanced'.default.PickStartMenu = StartMenuClass;
		GotoMenu(class'PLMenuEnhanced');
	}
	else
		GotoMenu(StartMenuClass);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PLStartText="Paradise Lost"
	TWPStartText="Two Weeks In Paradise"
	BaseGameText="Base Game..."
	BaseGameHelp="Play the base POSTAL 2."
	
	PLStartHelp="Play Paradise Lost."
	TWPStartHelp="Play POSTAL 2, Apocalypse Weekend, and Paradise Lost combined together into one 14 day long campaign!"
}
