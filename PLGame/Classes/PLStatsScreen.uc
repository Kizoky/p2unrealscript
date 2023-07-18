///////////////////////////////////////////////////////////////////////////////
// PLStatsScreen
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
class PLStatsScreen extends AWStatsScreen;

const	INC_Y			=	0.024;
	
var localized string CockAsianKills;
var localized string PUKills;
var localized string FarciiKills;
var localized string RobotKills;
var localized string BanditKills;
var localized string SurvivalistKills;
var localized string AnimalKills;
//var localized string RaptorKills;
var localized string ExecutionKills;
var localized string MoneySpentOnVendors;
var localized string SnowmenPeedOn;
var localized string NutShots;
var localized string BirdsFlipped;
var localized string MonkeysLost;
//var localized string ErrandsPeaceful;

///////////////////////////////////////////////////////////////////////////////
// Render the screen
///////////////////////////////////////////////////////////////////////////////
function RenderScreen(canvas Canvas)
	{
	local int i;
	local float sxl, sxr, sy,NearestFourByThree, OffsetX;
	local string ustr, Mods;
	local PLGameState newgs;
	local P2GameInfoSingle useinfo;	

	if(!bEnableRender
		|| gamest == None) return;

	UseInfo = GetGameSingle();
	newgs = PLGameState(gamest);

	// Let super draw background texture
	Super(P2Screen).RenderScreen(Canvas);
	
	// For whatever dumbass reason, the text renders super-tiny until the message below is drawn.
	// Just pop it up real quick for one frame and then hide it until it's ready to be drawn.
	if (!bTest)
	{		
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, MsgX * Canvas.ClipX, MsgY * Canvas.ClipY, Message, 0, false, EJ_Center);	
		bTest = true;
	}

    NearestFourByThree = GetPlayer().GetFourByThreeResolution(canvas);
	OffsetX = ((canvas.ClipX - NearestFourByThree) /2);

	// Show our stats
	sxl = LEFT_START_X;
	sxr = RIGHT_START_X;

	sy = START_Y;
	if(StatNum == 0) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PeopleKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.PeopleKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 1) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ZombiesKilledOverall, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ZombiesKilledOverall, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 2) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CockAsianKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.CockAsianKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 3) return;
	
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PUKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.PUKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 4) return;
	
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, FarciiKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.FarciiKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 5) return;
	
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, RobotKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.RobotKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 6) return;
	
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, BanditKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.BanditKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 7) return;
	
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, SurvivalistKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.SurvivalistKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 8) return;
	
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CopsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.CopsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 9) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PeopleRoasted, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.PeopleRoasted, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 10) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, AnimalKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.AnimalKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 11) return;
	
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ExecutionKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ExecutionKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 12) return;
	
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ShotgunHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.ShotgunHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 13) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, RifleHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.RifleHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 14) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CatsUsed, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.CatsUsed, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 15) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, MoneySpentOnVendors, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.MoneySpentOnVendors, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 16) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, SnowmenPeedOn, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.SnowmenPeedOn, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 17) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, LimbsHacked, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.LimbsHacked, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 18) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, HeadsLopped, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.HeadsLopped, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 19) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ChainsawKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ChainsawKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 20) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DoorsKicked, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DoorsKicked, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 21) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, NutShots, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.NutShots, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 22) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, BirdsFlipped, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.BirdsFlipped, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 23) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, TimesArrested, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.TimesArrested, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 24) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DressedAsCop, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DressedAsCop, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 25) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DogsTrained, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DogsTrained, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 26) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, MonkeysLost, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.MonkeysLost, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 27) return;
	
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, GameMode, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$GetGameSingle().GameName, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 28) return;
	
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, Difficulty, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$GetGameSingle().GetDiffName(gamest.GameDifficulty), 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 29) return;

	if (URL == "") return;

	// Hide this if they cheated
	if (!gamest.DidPlayerCheat())
	{
		if (gamest.GetPlayerRankingSpeedRun() != "")
			MyFont.TextColor=YellowC;
		if (P2GameInfoSingle(GetPlayer().Level.Game).bStrictTime)
			MyFont.TextColor=GreenC;
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, TimeElapsed@newgs.GetPlayerRankingSpeedRun(), 0, false, EJ_Left);
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.HoursPlayed()$":"$newgs.MinutesPlayed()$":"$newgs.SecondsPlayed()@newgs.GetSingleSegmentString(), 0, false, EJ_Left);
		MyFont.TextColor=MyFont.default.TextColor;
		sy += INC_Y;
	}
	if (StatNum == 30) return;
	
	// Mods
	Mods = newgs.GetModList();
	if (Mods != "")
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, ModsUsed@Mods, 0, false, EJ_Center);
		
	if (StatNum < 35) return;
		
	sy += INC_Y;
	sy += INC_Y;
	
	// Final summary
	MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, Ranking, 2, false, EJ_Center);
	sy += INC_Y;
	MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, ustr$PlayerRank, 3, false, EJ_Center);
	sy += INC_Y;
	sy += INC_Y;
	if (UseInfo.FinallyOver())
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, CheatsNow, 1, false, EJ_Center);
	}

defaultproperties
{
	StatMax=36
	
	PeopleKilled="Total people murdered:"
	ZombiesKilledOverall="Zombies sent to Hell:"
	CockAsianKills="Slaughterers butchered:"
	PUKills="Game devs game-over'd:"
	FarciiKills="Gingervitis treated:"
	RobotKills="Automatons terminated:"
	BanditKills="Bandits beat down:"
	SurvivalistKills="Survivalists Trixie'd:"
	CopsKilled="Lawmen served justice:"
	PeopleRoasted="People roasted:"
	AnimalKills="Animals euthanized:"
	//RaptorKills="Raptors killed:"
	ExecutionKills="Unlucky punks blown away:"
	ShotgunHeadShot="Heads exploded by shotgun:"
	RifleHeadShot="Total rifle head shots:"
	CatsUsed="Cats violated with a weapon:"
	MoneySpentOnVendors="Money spent on vending machines:"
	SnowmenPeedOn="Snowmen peed on:"
	LimbsHacked="Limbs hacked:"
	HeadsLopped="Heads lopped:"
	ChainsawKills="Bodies pruned:"
	DoorsKicked="Doors kicked in:"
	NutShots="Nuts kicked in:"
	BirdsFlipped="Birds flipped:"
	TimesArrested="Times arrested:"
	DressedAsCop="Number of times dressed up as a Lawman:"
	DogsTrained="Times a dog was befriended:"
	MonkeysLost="Monkeys lost in combat:"
	//ErrandsPeaceful="Errands completed peacefully:"
	GameMode="Game mode:"
	Difficulty="Difficulty level:"
	TimeElapsed="Time elapsed:"
	ModsUsed="Mods used:"
	
	Ranking="Summary:  "
	CheatsNow="Cheats now accessible with in-game menu (press Esc)!"
	Song="map_muzak.ogg"
	BackgroundName="P2Misc_full.InkyBlackness"
	TileName="nathans.Inventory.blackbox64"
	YellowC=(G=200,R=255,A=255)
}
