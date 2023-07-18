///////////////////////////////////////////////////////////////////////////////
// AWPGameInfo
///////////////////////////////////////////////////////////////////////////////
class AWPGameInfo extends GameSinglePlayer;

///////////////////////////////////////////////////////////////////////////////
// Config Vars
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Consts
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Public Vars
///////////////////////////////////////////////////////////////////////////////
var() string WeekendStartURL, SundayUrl;
var() array<string> DynamicMainMenuURL;	// xPatch: Makes us return to the AW Menu if it's weekend etc :D

///////////////////////////////////////////////////////////////////////////////
// Internal Vars
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// More Consts
///////////////////////////////////////////////////////////////////////////////
const DAY_FRIDAY = 4;
const DAY_SATURDAY = 5;
const DAY_SUNDAY = 6;

///////////////////////////////////////////////////////////////////////////////
// Returns true if we're on Saturday or Sunday
///////////////////////////////////////////////////////////////////////////////
function bool IsWeekend()
{
	//log(self@"is weekend? current day is"@TheGameState.CurrentDay,'Debug');
	return (TheGameState.CurrentDay >= DAY_SATURDAY);
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if this game is only Saturday and Sunday
///////////////////////////////////////////////////////////////////////////////
function bool WeekendOnlyGame()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if this game includes Saturday and Sunday
///////////////////////////////////////////////////////////////////////////////
function bool WeekendGame()
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure it's the final day and all of our errands are done.
// *Doesn't* check to make sure it's not the demo.
///////////////////////////////////////////////////////////////////////////////
function bool AfterFinalErrand()
{
	// Last day of the real game and you're done with your errands
	return ((TheGameState.CurrentDay == DAY_FRIDAY)
			&& TheGameState.ErrandsCompletedToday >= Days[TheGameState.CurrentDay].NumActiveErrands());
}

///////////////////////////////////////////////////////////////////////////////
// Send player to the AW intro movie
///////////////////////////////////////////////////////////////////////////////
function StartWeekend(PlayerController Player)
{
	// Don't show the "Saturday" splash screen after whiting out, just go to the movie
	// The "Saturday" splash shows when we go to the hospital proper
	//debuglog("Starting weekend");
	//bShowDayDuringLoad = False;
	//bForceNoLoadingScreen = True;
	SendPlayerTo(Player, WeekendStartURL);
}

// NOTE: StartNextDayURL is defined in Days now, just like Paradise Lost.
/*
///////////////////////////////////////////////////////////////////////////////
// Send player to the next day
///////////////////////////////////////////////////////////////////////////////
function SendPlayerToNextDay(PlayerController player)
{
	// See if there's any more days
	if (TheGameState.CurrentDay + 1 < Days.length)
	{
		TheGameState.bChangeDayPostTravel = true;
		TheGameState.NextDay = TheGameState.CurrentDay + 1;
//		log(self@"SendPlayerToNextDay: Next day is"@TheGameState.NextDay);
		if (TheGameState.NextDay == DAY_SATURDAY)
			StartWeekend(Player);
		else if (TheGameState.NextDay == DAY_SUNDAY)
			SendPlayerTo(player, SundayURL);
		else
			SendPlayerTo(player, StartNextDayURL);
	}
	else
	{
		// This shouldn't happen because the end-of-game movie
		// should end up calling EndOfGame() instead.  If it does
		// happen we'll treat it like a quit.
		QuitGame();
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// Change the sky based on the day, using a material trigger
///////////////////////////////////////////////////////////////////////////////
function ChangeSkyByDay()
{
	local MaterialTrigger mattrig;
	local int Day;
	
	// xPatch: Fix for the saturday skybox looking like if it was the apocalypse.
	if (IsWeekend())
		Day = 1;
	else
		Day = TheGameState.CurrentDay;
		
	// Find the skybox trigger, and trigger it to the correct day
	foreach AllActors(class'MaterialTrigger', mattrig, SKY_BOX_TRIGGER)
		break;

	if(mattrig != None)
	{
		// If your in the normal week, just set the skybox by the day number
		if(!TheGameState.bIsApocalypse)
			mattrig.SetCurrentMaterialSwitch(Day);
		else// Apocalypse is expected to be one past the last day.
			mattrig.SetCurrentMaterialSwitch(Day+1);
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Update Main Menu depending on the time of week.
///////////////////////////////////////////////////////////////////////////////
function UpdateMainMenu()
{
	local string NewMenuURL;
	
	if(ParseLevelName(Level.GetLocalURL()) != MainMenuURL)
	{
		if(IsWeekend())
			NewMenuURL = DynamicMainMenuURL[1];
		else
			NewMenuURL = DynamicMainMenuURL[0];
		
		default.MainMenuURL = NewMenuURL;
		MainMenuURL = NewMenuURL;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	// the week is defined here
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////

	Days(0)=DayBase'DayBase0'
	Days(1)=DayBase'DayBase1'
	Days(2)=DayBase'DayBase2'
	Days(3)=DayBase'DayBase3'
	Days(4)=DayBase'DayBase4'
	Days(5)=DayBase'DayBase8'
    Days(6)=DayBase'DayBase9'

    WeekendStartURL="MovieIntro.fuk"
	SundayURL="VincesHouse.fuk#Pad1?peer"
	
	DynamicMainMenuURL[0]="Startup"
	DynamicMainMenuURL[1]="AWStartup"

    DefaultPlayerClassName="GameTypes.AWPostalDude"
    PlayerControllerClassName="GameTypes.AWDudePlayer"
	ApocalypseTex="AW7Tex.Misc.ApocalypseNewspaper"
	ChameleonClass=class'ChameleonPlus'
	HUDType="GameTypes.AWWrapHUD"
	StatsScreenClassName="GameTypes.AWPStatsScreen"
	GameStateClass=class'AWGameState'
	MenuTitleTex="P2Misc.Logos.postal2underlined"

	GameName="POSTAL 2: A Week In Paradise"
    GameNameShort="A Week In Paradise"
	GameDescription="The smash-hit POSTAL 2 mod that combines the free-roam action of POSTAL 2 with the slicing and dicing of Apocalypse Weekend, stringing all seven days together into one massive game."
}
