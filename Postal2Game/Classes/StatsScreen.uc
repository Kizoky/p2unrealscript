///////////////////////////////////////////////////////////////////////////////
// StatsScreen.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Screen of game statistics.
// This screen can load a URL, but waits till the player is done, and has
// pressed spacebar to do it.
//
//	History:
//		11/08/02 NPF	Started.
//
///////////////////////////////////////////////////////////////////////////////
class StatsScreen extends P2Screen;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var localized string PeopleKilled;
var localized string CopsKilled;		
var localized string PeopleRoasted;
var localized string ElephantsKilled;	
var localized string DogsKilled;		
var localized string CatsKilled;		
var localized string PistolHeadShot;	
var localized string ShotgunHeadShot;	
var localized string RifleHeadShot;	
var localized string CatsUsed;		
var localized string MoneySpent;		
var localized string PeeTotal;		
var localized string LimbsHacked;			// Any limb (no heads) cut off
var localized string HeadsLopped;			// Any heads cut off (not exploded)
var localized string HeadsBattedOff;		// Heads knocked off with Baseball Bat
var localized string ChainsawKills;			// Kills made with Chainsaw
var localized string DoorsKicked;		
var localized string TimesArrested;	
var localized string DressedAsCop;	
var localized string DogsTrained;		
var localized string CopsLuredByDonuts;		
var localized string TimeElapsed;
var localized string Difficulty;
var localized string Ranking;
var localized string GameMode;
var localized string ModsUsed;
var string PlayerRank;

var int StatNum;
var int StatMax;				// This must include all the localized strings above

var String URL;

var GameState gamest;

var localized string CheatsNow;

var Color	YellowC;
var Color	GreenC;

const	LEFT_START_X	=	0.20; 
const	RIGHT_START_X	=	0.7; 
const	START_Y			=	0.06; 
const	INC_Y			=	0.03;
const	REVEAL_TIME		=	0.1;
const   FINAL_WAIT_TIME	=	2.0;

var bool bTest;

///////////////////////////////////////////////////////////////////////////////
// Call this to bring up the screen
///////////////////////////////////////////////////////////////////////////////
function Show(String URLin)
	{
	URL = URLin;
	
	gamest = GetGameSingle().TheGameState;
	PlayerRank = gamest.GetPlayerRanking();

	// Set our first state and start it up
	AfterFadeInScreen = 'RevealScreen1';
	StatNum=0;
	Super.Start();
	}

///////////////////////////////////////////////////////////////////////////////
// Called before player travels to a new level
///////////////////////////////////////////////////////////////////////////////
function PreTravel()
	{
	Super.PreTravel();

	// Get rid of all actors because they'll be invalid in the new level (not
	// doing this will lead to intermittent crashes!)
	gamest = None;
	}

///////////////////////////////////////////////////////////////////////////////
// Default tick function.
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
	{
	Super.Tick(DeltaTime);

	if (bPlayerWantsToEnd)
		{
		// Clear flag (it may get set again)
		bPlayerWantsToEnd = false;
		ChangeExistingDelay(0.1);
		End();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Render the screen
///////////////////////////////////////////////////////////////////////////////
function RenderScreen(canvas Canvas)
	{
	local int i;
	local float sxl, sxr, sy,NearestFourByThree, OffsetX;
	local string ustr, Mods;
	
	

	if(!bEnableRender
		|| gamest == None) return;

	// Let super draw background texture
	Super.RenderScreen(Canvas);
	
	// For whatever dumbass reason, the text renders super-tiny until the message below is drawn.
	// Just pop it up real quick for one frame and then hide it until it's ready to be drawn.
	if (!bTest)
	{		
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, MsgX * Canvas.ClipX, MsgY * Canvas.ClipY, Message, 0, false, EJ_Center);	
		bTest = true;
	}

    NearestFourByThree = GetPlayer().GetFourByThreeResolution(canvas);
	OffsetX = (canvas.ClipX - NearestFourByThree) /2;

	// Show our stats
	sxl = LEFT_START_X;
	sxr = RIGHT_START_X;
	sy = START_Y;
	if(StatNum == 0) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PeopleKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.PeopleKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 1) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CopsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.CopsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 2) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PeopleRoasted, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.PeopleRoasted, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 3) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ElephantsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.ElephantsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 4) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DogsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DogsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 5) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CatsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.CatsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 6) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PistolHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.PistolHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 7) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ShotgunHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.ShotgunHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 8) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, RifleHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.RifleHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 9) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CatsUsed, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.CatsUsed, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 10) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, MoneySpent, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.MoneySpent, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 11) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PeeTotal, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$(0.1*float(gamest.PeeTotal)), 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 12) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, LimbsHacked, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.LimbsHacked, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 13) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, HeadsLopped, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.HeadsLopped, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 14) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, HeadsBattedOff, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.BaseballHeads, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 15) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ChainsawKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.ChainsawKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 16) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DoorsKicked, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DoorsKicked, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 17) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, TimesArrested, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.TimesArrested, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 18) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DressedAsCop, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DressedAsCop, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 19) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DogsTrained, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DogsTrained, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 20) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CopsLuredByDonuts, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.CopsLuredByDonuts, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 21) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, GameMode, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$GetGameSingle().GameName, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 22) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, Difficulty, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$GetGameSingle().GetDiffName(gamest.GameDifficulty), 0, false, EJ_Left);
	sy += INC_Y;
	
	if (URL == "") return;

	// Hide this if they cheated
	if (!gamest.DidPlayerCheat())
	{
		if (gamest.GetPlayerRankingSpeedRun() != "")
			MyFont.TextColor=YellowC;
		if (P2GameInfoSingle(GetPlayer().Level.Game).bStrictTime)
			MyFont.TextColor=GreenC;
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, TimeElapsed@gamest.GetPlayerRankingSpeedRun(), 0, false, EJ_Left);
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.HoursPlayed()$":"$gamest.MinutesPlayed()$":"$gamest.SecondsPlayed()@gamest.GetSingleSegmentString(), 0, false, EJ_Left);
		MyFont.TextColor=MyFont.default.TextColor;
		sy += INC_Y;
		if (StatNum < 23) return;
	}
	
	if (StatNum < 24) return;

	// Mods
	Mods = gamest.GetModList();
	if (Mods != "")
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, ModsUsed@Mods, 0, false, EJ_Center);

	sy += INC_Y;
	sy += INC_Y;

	// Final summary
	MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, Ranking, 2, false, EJ_Center);
	sy += INC_Y;
	MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, ustr$PlayerRank, 3, false, EJ_Center);
	sy += INC_Y;
	sy += INC_Y;
	if (GetGameSingle().FinallyOver())
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, CheatsNow, 1, false, EJ_Center);
	}

///////////////////////////////////////////////////////////////////////////////
// Slowly reveal all the stats
///////////////////////////////////////////////////////////////////////////////
state RevealScreen1 extends ShowScreen
	{
	///////////////////////////////////////////////////////////////////////////////
	// Don't let them skip
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
		{
		Super.Tick(DeltaTime);
		}
	function BeginState()
		{
		StatNum++;
		DelayedGotoState(REVEAL_TIME, 'RevealScreen2');
		}
	}
state RevealScreen2 extends ShowScreen
	{
	///////////////////////////////////////////////////////////////////////////////
	// Don't let them skip
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
		{
		Super.Tick(DeltaTime);
		}
	function BeginState()
		{
		if(StatNum == StatMax)
			{
			// Finished
			DelayedGotoState(0.0, 'WaitMore');
			}
		else
			{
			// Go back
			DelayedGotoState(0.0, 'RevealScreen1');
			}
		}
	}
state WaitMore extends ShowScreen
	{
	///////////////////////////////////////////////////////////////////////////////
	// Don't let them skip
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
		{
		Super.Tick(DeltaTime);
		}
	function BeginState()
		{
		//ViewportOwner.Actor.bWantsToSkip=0;	// Clear key entries
		//bPlayerWantsToEnd=false;
		//bEndNow = false;
		DelayedGotoState(FINAL_WAIT_TIME, 'HoldScreen');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// View screen until player decides to stop
///////////////////////////////////////////////////////////////////////////////
state HoldScreen extends ShowScreen
	{
	function BeginState()
		{
		ShowMsg();
		if (URL != "")
			WaitForEndThenGotoState('LoadingScreen');
		else
			WaitForEndThenGotoState('FadeOutScreen');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// View the screen while the main menu loads
///////////////////////////////////////////////////////////////////////////////
state LoadingScreen extends ShowScreen
{
	function BeginState()
	{
		SendThePlayerTo(URL, 'FadeOutScreen');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	PeopleKilled="Total people murdered:"
	CopsKilled="Cops killed:"
	PeopleRoasted="People roasted:"
	ElephantsKilled="Elephants slaughtered:"
	DogsKilled="Dogs eliminated:"
	CatsKilled="Cats destroyed:"
	PistolHeadShot="Instant kill, pistol head shots:"
	ShotgunHeadShot="Heads exploded by shotgun:"
	RifleHeadShot="Total rifle head shots:"
	CatsUsed="Cats violated with a weapon:"
	MoneySpent="Total money spent:"
	PeeTotal="Gallons of piss pissed:"
	DoorsKicked="Doors kicked in:"
	TimesArrested="Times arrested:"
	DressedAsCop="Number of times dressed up as a cop:"
	DogsTrained="Times a dog was befriended:"
	CopsLuredByDonuts="Number of cops you lured with donuts:"
	Ranking="Summary:  "
	StatMax=25
	CheatsNow="Cheats now accessible with in-game menu (press Esc)!"
	Song="map_muzak.ogg"
	BackgroundName="P2Misc_full.InkyBlackness"
	TileName="nathans.Inventory.blackbox64"
	Difficulty="Difficulty Level:"
	TimeElapsed="Time Elapsed:"
	YellowC=(G=200,R=255,A=255)
	GreenC=(G=255,R=200,A=200)
	HeadsBattedOff="Heads batted off:"
	ChainsawKills="People chainsawed to bits:"
	LimbsHacked="Limbs hacked:"
	HeadsLopped="Heads lopped:"
	GameMode="Game mode:"
	ModsUsed="Mods used:"
}
