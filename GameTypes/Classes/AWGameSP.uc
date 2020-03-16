///////////////////////////////////////////////////////////////////////////////
// Apocalypse Weekend Single Player game info
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Game info that drives the add on pack.
//
// Kamek 8/11 backport from AW.
///////////////////////////////////////////////////////////////////////////////
//class AWGameSP extends AWInvGameSP;
class AWGameSP extends P2GameInfoSingle;

const DAY_SUNDAY = 1;
var() string SundayUrl;

///////////////////////////////////////////////////////////////////////////////
// Don't allow reminder hints in add-on. No map here.
///////////////////////////////////////////////////////////////////////////////
function bool AllowReminderHints()
{
	return false;
}

// Always the weekend in AW.
function bool IsWeekend()
{
	return true;
}
// returns true for AW-only game
function bool WeekendOnlyGame()
{
	return true;
}
// returns true if we use saturday or sunday at all
function bool WeekendGame()
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function RecordEnding()
{
	GOver = GOVER_SUM - GameRefVal;
	TimesBeatenAW++;
	ConsoleCommand("set "@GOverPath@GOver);
	ConsoleCommand("set "@TimesBeatenAWPath@TimesBeatenAW);
}	

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
		if (TheGameState.NextDay == DAY_SUNDAY)
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

defaultproperties
{
    GameStateClass=Class'AWGameState'
	Begin Object Class=ErrandGoalKillMe Name=KillPhraud
		KillMeTag="Phraud"
		TriggerOnCompletionTag="DiedEarly"
		Name="KillPhraud"
	End Object
	Begin Object Class=ErrandBase Name=SaturdayErrand
		UniqueName="Saturday Errand"
		Goals(0)=ErrandGoalKillMe'KillPhraud'
		Name="SaturdayErrand"
	End Object
	Begin Object Class=DayBase Name=DayBase8
		Description="Saturday"
		UniqueName="DAY_A"
		ExcludeDays(0)="DEMO"
		LoadTex="aw_textures.loading_sat"
		DudeStartComment="DudeDialog.dude_map_exit1"
		Errands(0)=ErrandBase'SaturdayErrand'
		PlayerInvList(0)=(InvClassName="Inventory.MoneyInv",NeededAmount=50)
		PlayerInvList(1)=(InvClassName="Inventory.HandsWeapon")
		PlayerInvList(2)=(InvClassName="Inventory.StatInv")
		TakeFromPlayerList(0)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(1)=(InvClassName="Inventory.MapInv")
		Name="DayBase8"
	End Object
	Days(0)=DayBase'DayBase8'
	Begin Object Class=DayBase Name=DayBase9
		Description="Sunday"
		UniqueName="DAY_B"
		ExcludeDays(0)="DEMO"
		LoadTex="aw_textures.loading_sun"
		DudeStartComment="DudeDialog.dude_map_exit1"
		Errands(0)=None
		PlayerInvList(0)=(InvClassName="Inventory.CatnipInv",NeededAmount=5,bEnhancedOnly=true)
		PlayerInvList(0)=(InvClassName="Inventory.RocketCamInv",bEnhancedOnly=true)
		TakeFromPlayerList(0)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(1)=(InvClassName="Inventory.MapInv")
		Name="DayBase9"
	End Object
	Days(1)=DayBase'DayBase9'
	IntroURL="MovieIntro.fuk"
	StartFirstDayURL="custest.fuk"
	StartNextDayURL="custest.fuk"
	SundayURL="VincesHouse.fuk#Pad1?peer"
	MatSwaps(0)=(OrigMat=Texture'Josh-textures.signs.game_banner_2',NewMat=Texture'Josh-textures.signs.game_banner_5')
	MatSwaps(1)=(OrigMat=Texture'Timb.arcade.Game_FagHunter',NewMat=Texture'Timb.arcade.Game_BastardFish')
	DefaultPlayerClassName="AWPawns.AWDude"
	HUDType="Postal2Game.P2HUD"
	DefaultPlayerName="TheDude"
	GameName="Apocalypse Weekend"
	PlayerControllerClassName="GameTypes.AWPlayer"
	StatsScreenClassName="GameTypes.AWStatsScreen"
	ChameleonClass=class'ChameleonPlus'
	MainMenuURL="AWstartup"
}
