class AWPStatsScreen extends AWStatsScreen;

const	INC_Y			=	0.025;
	
///////////////////////////////////////////////////////////////////////////////
// Render the screen
///////////////////////////////////////////////////////////////////////////////
function RenderScreen(canvas Canvas)
	{
	local int i;
	local float sxl, sxr, sy,NearestFourByThree, OffsetX;
	local string ustr, Mods;
	local AWGameState newgs;
	local P2GameInfoSingle useinfo;	

	if(!bEnableRender
		|| gamest == None) return;

	UseInfo = GetGameSingle();
	newgs = AWGameState(gamest);

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

	// Number of zombies killed
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ZombiesKilledOverall, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ZombiesKilledOverall, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 2) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ZombiesResurrected, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ZombiesResurrected, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 3) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CopsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.CopsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 4) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PeopleRoasted, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.PeopleRoasted, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 5) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ElephantsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.ElephantsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 6) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DogsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DogsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 7) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CatsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.CatsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 8) return;

	// Fanatics killed
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, FanaticsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.FanaticsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 9) return;

	// Army killed
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ArmyKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ArmyKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 10) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ShotgunHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.ShotgunHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 11) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, RifleHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.RifleHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 12) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CatsUsed, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.CatsUsed, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 13) return;

	// Sledges lost in cow
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, LostSledgeInCow, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.LostSledgeInCow, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 14) return;

	// Limbs hacked
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, LimbsHacked, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.LimbsHacked, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 15) return;

	// Heads lopped
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, HeadsLopped, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.HeadsLopped, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 16) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, HeadsBattedOff, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.BaseballHeads, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 17) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, ChainsawKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.ChainsawKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 18) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, MoneySpent, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.MoneySpent, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 19) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, PeeTotal, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$(0.1*float(gamest.PeeTotal)), 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 20) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DoorsKicked, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DoorsKicked, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 21) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, TimesArrested, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.TimesArrested, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 22) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DressedAsCop, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DressedAsCop, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 23) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, DogsTrained, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.DogsTrained, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 24) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, CopsLuredByDonuts, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$gamest.CopsLuredByDonuts, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 25) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, GameMode, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$GetGameSingle().GameName, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 26) return;
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
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, TimeElapsed@newgs.GetPlayerRankingSpeedRun(), 0, false, EJ_Left);
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$newgs.HoursPlayed()$":"$newgs.MinutesPlayed()$":"$newgs.SecondsPlayed()@newgs.GetSingleSegmentString(), 0, false, EJ_Left);
		MyFont.TextColor=MyFont.default.TextColor;
		sy += INC_Y;
		if (StatNum == 27) return;
	}
	
	if (StatNum < 28) return;
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
	if (UseInfo.FinallyOver())
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, CheatsNow, 1, false, EJ_Center);
	if(StatNum < 30) return;
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

defaultproperties
{
	StatMax = 31
}
