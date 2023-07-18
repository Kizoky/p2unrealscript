///////////////////////////////////////////////////////////////////////////////
// MenuStart_AW.uc
// by Man Chrzan
//
// Menu to choose difficulty, checkboxes and start previously selected Gamemode.
// 
///////////////////////////////////////////////////////////////////////////////
class MenuStart_AW extends MenuStart_AWP;

///////////////////////////////////////////////////////////////////////////////
// Create the start option for this menu.
///////////////////////////////////////////////////////////////////////////////
function CreateStartOption()
{
	StartWeekend =	AddChoice(StartText,		StartWeekendHelp,	ItemFont,	TA_Left);
}

///////////////////////////////////////////////////////////////////////////////
// Gets unlocked if we have completed the game or it is debug mode.
///////////////////////////////////////////////////////////////////////////////
function bool GameModeCompleted()
{
	return (GetGameSingle().GinallyOver() || FPSPlayer(GetPlayerOwner()).bEnableDebugMenu);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	TitleText = "Apocalypse Weekend"
	Days[0] = "Saturday"
	Days[1] = "Sunday"
	MaxDays=2
}