///////////////////////////////////////////////////////////////////////////////
// AWStatsScreen.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWStatsScreen extends StatsScreen;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var localized string ZombiesKilledOverall;
var localized string BryanSurvived;
var localized string LostSledgeInCow;
var localized string KillElephantsScythe;
var localized string FanaticsKilled;
var localized string ArmyKilled;
//var localized string LimbsHacked;			// Any limb (no heads) cut off
//var localized string HeadsLopped;			// Any heads cut off (not exploded)
var localized string ZombiesResurrected;
var localized string NewC1;
var localized string NewC2;
var localized string NewC3;
var localized string NewItemNow;

var localized string YesStr;
var localized string NoStr;

var bool bMPupdate;
var bool bMP1, bMP2, bMP3;

const	INC_Y			=	0.025;	//0.0365;

///////////////////////////////////////////////////////////////////////////////
// Call this to bring up the screen
///////////////////////////////////////////////////////////////////////////////
function Show(String URLin)
{
	Super.Show(URLin);
	bMPupdate=true;
}

///////////////////////////////////////////////////////////////////////////////
// Call this to bring up the screen. Store vals here that are used every render.
///////////////////////////////////////////////////////////////////////////////
function DoMPupdate()
{
	local P2GameInfoSingle useinfo;
	local AWGameState newgs;
	const FIN_BLAST		= 23;
	const STOP_VAL = 5;

	useinfo = GetGameSingle();
	newgs = AWGameState(gamest);

	if(newgs != None)
	{
		if(newgs.BryanSurvived != 0)
			useinfo.MultCast = STOP_VAL + Rand(STOP_VAL) + 1;
		if(newgs.KillElephantsScythe != 0)
			useinfo.FinStop = FIN_BLAST + Rand(FIN_BLAST) + 1;
	}
	//bMP1 = useinfo.ChangedMP1();
	//bMP2 = useinfo.ChangedMP2();
	//bMP3 = useinfo.ChangedMP3();
	bMP1 = false;
	bMP2 = false;
	bMP3 = false;

	//log(Self$" show 1 "$bMp1$" 2 "$bMp2$" 3 "$bMp3$" newgs "$newgs);

	bMPupdate=false;
}

///////////////////////////////////////////////////////////////////////////////
// Render the screen
// Returns with each increment of StatNum as it slowly reveals the numbers
///////////////////////////////////////////////////////////////////////////////
function RenderScreen(canvas Canvas)
	{
	local int i, CheckStatNum;
	local float sxl, sxr, sy,NearestFourByThree, OffsetX;
	local string ustr, Mods;
	local AWGameState newgs;
	local P2GameInfoSingle useinfo;

	newgs = AWGameState(gamest);

	if(!bEnableRender
		|| newgs == None) return;

	if(bMPupdate)
		DoMPupdate();

	// Let super draw background texture
	Super(P2Screen).RenderScreen(Canvas);

	// For whatever dumbass reason, the text renders super-tiny until the message below is drawn.
	// Just pop it up real quick for one frame and then hide it until it's ready to be drawn.
	if (!bTest)
	{		
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, MsgX * Canvas.ClipX, MsgY * Canvas.ClipY, Message, 0, false, EJ_Center);	
		bTest = true;
	}

	useinfo = GetGameSingle();
	

    NearestFourByThree = GetPlayer().GetFourByThreeResolution(canvas);
	OffsetX = ((canvas.ClipX - NearestFourByThree) /2);

	// Show our stats
	sxl = LEFT_START_X;
	sxr = RIGHT_START_X;
	
	// xPatch: Added CheckStatNum instead of numbers so it can be automatic 
	// and we can now hide some stats in Classic Game without breaking the whole thing.
	CheckStatNum = 0;	

	sy = START_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PeopleKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.PeopleKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ZombiesKilledOverall, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ZombiesKilledOverall, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	if(newgs.BryanSurvived != 0)
	{
		if(bMP1)
		{
			MyFont.TextColor=YellowC;
			MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, BryanSurvived$NewC1, 0, false, EJ_Left);
			MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$YesStr, 0, false, EJ_Left);
			MyFont.TextColor=MyFont.default.TextColor;
		}
		else
		{
			MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, BryanSurvived, 0, false, EJ_Left);
			MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$YesStr, 0, false, EJ_Left);
		}
	}
	else
	{
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, BryanSurvived, 0, false, EJ_Left);
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$NoStr, 0, false, EJ_Left);
	}
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, FanaticsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.FanaticsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ArmyKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ArmyKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, LostSledgeInCow, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.LostSledgeInCow, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	if(newgs.KillElephantsScythe != 0)
	{
		if(bMP2)
		{
			MyFont.TextColor=YellowC;
			MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, KillElephantsScythe$NewC2, 0, false, EJ_Left);
			MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$YesStr, 0, false, EJ_Left);
			MyFont.TextColor=MyFont.default.TextColor;
		}
		else
		{
			MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, KillElephantsScythe, 0, false, EJ_Left);
			MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$YesStr, 0, false, EJ_Left);
		}
	}
	else
	{
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, KillElephantsScythe, 0, false, EJ_Left);
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$NoStr, 0, false, EJ_Left);
	}
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, RifleHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.RifleHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ShotgunHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ShotgunHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CatsUsed, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.CatsUsed, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CatsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.CatsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PeeTotal, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$(0.1*float(newgs.PeeTotal)), 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, LimbsHacked, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.LimbsHacked, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, HeadsLopped, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.HeadsLopped, 0, false, EJ_Left);
	sy += INC_Y;
	
	// xPatch: Don't need these in Classic Mode
	if(!GetGameSingle().InClassicMode()) {
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, HeadsBattedOff, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.BaseballHeads, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, BaliStabs, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.BaliStabs, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ChainsawKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ChainsawKills, 0, false, EJ_Left);
	sy += INC_Y;
	}
	
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	if(newgs.ZombiesResurrected > 0
		&& bMP3)
	{
		MyFont.TextColor=YellowC;
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ZombiesResurrected$NewC3, 0, false, EJ_Left);
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ZombiesResurrected, 0, false, EJ_Left);
		MyFont.TextColor=MyFont.default.TextColor;
	}
	else
	{
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ZombiesResurrected, 0, false, EJ_Left);
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ZombiesResurrected, 0, false, EJ_Left);
	}
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, GameMode, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$GetGameSingle().GameName@classicmode, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == CheckStatNum) return;
	CheckStatNum++;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, Difficulty, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$GetGameSingle().GetDiffName(gamest.GameDifficulty), 0, false, EJ_Left);
	sy += INC_Y;
	
	// xPatch: Day the game started on
	if(dayname != "")
	{
		if(StatNum == CheckStatNum) return;
		CheckStatNum++;
		
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, StartDay, 0, false, EJ_Left);
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$dayname, 0, false, EJ_Left);
		sy += INC_Y;
	}
	
	if (URL == "") return;

	// Hide this if they cheated
	if (!gamest.DidPlayerCheat())
	{
		// Don't show speed rankings for AW... too short
		if (P2GameInfoSingle(GetPlayer().Level.Game).bStrictTime)
			MyFont.TextColor=GreenC;
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, TimeElapsed, 0, false, EJ_Left);
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.HoursPlayed()$":"$newgs.MinutesPlayed()$":"$newgs.SecondsPlayed()@newgs.GetSingleSegmentString(), 0, false, EJ_Left);
		sy += INC_Y;
		if (StatNum == CheckStatNum) return;
		CheckStatNum++;
	}

	if (StatNum < CheckStatNum) return;	
	CheckStatNum++;

	// Mods
	Mods = newgs.GetModList();
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
	if (useinfo.FinallyOver())
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, CheatsNow, 1, false, EJ_Center);
	if(StatNum < CheckStatNum) return;
	if(
		useinfo.VerifyGH()
		&& useinfo.SeqTimeVerified())
		{
		sy += INC_Y;
		MyFont.TextColor=YellowC;
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, NewItemNow, 1, false, EJ_Center);
		MyFont.TextColor=MyFont.default.TextColor;
		}	
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     ZombiesKilledOverall="Zombie-people put down:"
     BryanSurvived="Bryan survived:"
     LostSledgeInCow="Sledges lost in a cow's butt:"
     KillElephantsScythe="All elephants killed with Scythe:"
     FanaticsKilled="Taliban beat down:"
     ArmyKilled="Army FUBAR'd:"
     ZombiesResurrected="Zombie-people resurrected:"
     NewC1=" (New Sledge Cheats!)"
     NewC2=" (New Cheat: Reaper of Love)"
     NewC3=" (New Cheat: Bladey)"
//   NewItemNow="Make sure to check out the Apocalypse Weekend levels for a new powerup!"
     NewItemNow="Make sure to check out the levels in Enhanced Game for a new powerup!"
     YesStr="Yes"
     NoStr="No"
	 StatMax=23
}
