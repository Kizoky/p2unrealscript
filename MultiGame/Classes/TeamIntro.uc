///////////////////////////////////////////////////////////////////////////////
// TeamIntro.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Team intro sequence.
//
///////////////////////////////////////////////////////////////////////////////
class TeamIntro extends MatchIntro;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var TeamScoreboard			MyScoreboard;

var localized string		YourTeamString;
var localized string		EnemyTeamString;

var float					MatchScoreTime1;
var float					MatchScoreTime2;
var float					MatchScoreTime3;

var float					Team1LogoTime1;
var float					Team1LogoTime2;
var float					Team1LogoTime3;

var float					Team2LogoTime1;
var float					Team2LogoTime2;
var float					Team2LogoTime3;

var float					PlayerTeamTime1;
var float					PlayerTeamTime2;
var float					PlayerTeamTime3;

var float					GrudgeTime1;
var float					GrudgeTime2;
var float					GrudgeTime3;
var float					GrudgeTotalTime;
var float					GrudgeSoundTime;

var float					MatchTime1;
var float					MatchTime2;

var float					MatchScorePY;
var float					TeamLogoPY;
var float					TeamLogoPH;
var float					TeamLogoPX[2];
var float					PressFirePY;
var float					PlayerTeamPY;

var float					ShakeAmount;

var Texture					GrudgeMatchTexture;
var float					GrudgeMatchPW;
var float					GrudgeMatchPY;

var Sound					MetalSound;
var Sound					GrudgeSound;
var Sound					ExplosionSound;

var int						NextSoundSlot;


///////////////////////////////////////////////////////////////////////////////
// Start the intro sequence.
///////////////////////////////////////////////////////////////////////////////
function Start()
{
	Super.Start();

	MyScoreboard = TeamScoreboard(PlayerController(Owner).MyHud.Scoreboard);
	if (MyScoreboard != None)
		bRunning = true;
	else
		bRunning = false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	MyScoreboard = None;
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if intro is ready for calls to Run()
///////////////////////////////////////////////////////////////////////////////
function bool IsReadyForRun()
{
	return MyScoreboard.IsReady();
}

///////////////////////////////////////////////////////////////////////////////
// This is the core function that "runs" the whole sequence
///////////////////////////////////////////////////////////////////////////////
function Run(Canvas Canvas)
{
	local float SubPercent;
	local float Y;
	local float GrudgeAdjust;
	local float GrudgeHeight;
	local string str;

	Super.Run(Canvas);

	// Team score stuff
	Y = MatchScorePY * Canvas.ClipY;
	InRangeTime(MatchScoreTime1, MatchScoreTime2, SubPercent);
	if (SubPercent > 0.0)
		MyScoreboard.DrawMatchScore(Canvas, SlideUpTo(Canvas, Y, SubPercent));
	if (IsAtTime(MatchScoreTime2))
		DoPlaySound(MetalSound);
	InRangeTime(MatchScoreTime2, MatchScoreTime3, SubPercent);
	if (SubPercent > 0.0)
		MyScoreboard.DrawMatchScore(Canvas, Shake(Canvas, Y, SubPercent));

	// Team 1 logo
	Y = TeamLogoPY * Canvas.ClipY + TeamLogoPH * Canvas.ClipY;
	InRangeTime(Team1LogoTime1, Team1LogoTime2, SubPercent);
	if (SubPercent > 0.0)
		DrawTeamLogo(Canvas, 0, SlideUpTo(Canvas, Y, SubPercent));
	if (IsAtTime(Team1LogoTime2))
		DoPlaySound(MetalSound);
	InRangeTime(Team1LogoTime2, Team1LogoTime3, SubPercent);
	if (SubPercent > 0.0)
		DrawTeamLogo(Canvas, 0, Shake(Canvas, Y, SubPercent));

	// Team 2 logo
	InRangeTime(Team2LogoTime1, Team2LogoTime2, SubPercent);
	if (SubPercent > 0.0)
		DrawTeamLogo(Canvas, 1, SlideUpTo(Canvas, Y, SubPercent));
	if (IsAtTime(Team2LogoTime2))
		DoPlaySound(MetalSound);
	InRangeTime(Team2LogoTime2, Team2LogoTime3, SubPercent);
	if (SubPercent > 0.0)
		DrawTeamLogo(Canvas, 1, Shake(Canvas, Y, SubPercent));

	// Tell player which team he's on
	Y = PlayerTeamPY * Canvas.ClipY;
	InRangeTime(PlayerTeamTime1, PlayerTeamTime2, SubPercent);
	if (SubPercent > 0.0)
		DrawPlayerTeam(Canvas, SlideUpTo(Canvas, Y, SubPercent));
	InRangeTime(PlayerTeamTime2, PlayerTeamTime3, SubPercent);
	if (SubPercent > 0.0)
		DrawPlayerTeam(Canvas, Shake(Canvas, Y, SubPercent));

	// Grudge match thingy (usually doesn't getting replicated until after the intro starts)
	if (MpGameReplicationInfo(PlayerController(Owner).GameReplicationInfo) != None &&
		MpGameReplicationInfo(PlayerController(Owner).GameReplicationInfo).bGrudgeMatch)
	{
		GrudgeAdjust = 0.0;
		InRangeTime(GrudgeTime1, GrudgeTime2, SubPercent);
		if (SubPercent > 0.0)
			GrudgeHeight = DrawGrudgeMatch(Canvas, SlideDownTo(Canvas, GrudgeMatchPY * Canvas.ClipY, SubPercent));
		if (IsAtTime(GrudgeTime1))
			DoPlaySound(ExplosionSound);
		InRangeTime(GrudgeTime2, GrudgeTime3, SubPercent);
		if (SubPercent > 0.0)
			GrudgeHeight = DrawGrudgeMatch(Canvas, Shake(Canvas, GrudgeMatchPY * Canvas.ClipY, SubPercent));
		if (IsAtTime(GrudgeSoundTime))
			DoPlaySound(MpPlayer(Owner).CustomizeAnnouncer(GrudgeSound));
	}
	else
	{
		GrudgeAdjust = GrudgeTotalTime;
		GrudgeHeight = 0.0;
	}

	// Match title
	InRangeTime(MatchTime1 - GrudgeAdjust, MatchTime2 - GrudgeAdjust, SubPercent);
	if (SubPercent > 0.0)
	{
		MyScoreboard.DrawMatchTitle(Canvas, SlideDownTo(Canvas, MyScoreboard.MatchTitlePY * Canvas.ClipY, SubPercent));
		if (SubPercent >= 1.0)
			JumpToEnd();
	}

	// Draw match status (which tells player what to do next) when we reach the end of the intro
	if (Percent >= 1.0)
		MyScoreboard.DrawMatchStatus(Canvas, PressFirePY * Canvas.ClipY + GrudgeHeight, false, true);
}

///////////////////////////////////////////////////////////////////////////////
// Draw which team player is on
// Y is the top of the team logo
///////////////////////////////////////////////////////////////////////////////
function DrawPlayerTeam(Canvas Canvas, float Y)
{
	local string str;
	local float XL, YL;
	local int team;
	local float Fade;

	// Make sure this stuff has been replicated (it should be by the time this is displayed)
	if (PlayerController(Owner).PlayerReplicationInfo != None &&
		PlayerController(Owner).PlayerReplicationInfo.Team != None)
	{
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.bCenter = false;
		Canvas.Font = MyScoreboard.MyFont.GetFont(3, true, Canvas.ClipX);
		for (team = 0; team < 2; team++)
		{
			if (team == 0)
				Canvas.SetDrawColor(240, 20, 20, 255);
			else
				Canvas.SetDrawColor(20, 20, 240, 255);

			if (MpHud(MyScoreboard.PlayerOwner.myHUD) != None)
				Fade = MpHud(MyScoreboard.PlayerOwner.myHUD).BlinkVal;
			else
				Fade = 1.0;

			if (PlayerController(Owner).PlayerReplicationInfo.Team.TeamIndex == team)
				str = YourTeamString;
			else
				str = EnemyTeamString;

			Canvas.StrLen(str, XL, YL);
			Canvas.SetPos(TeamLogoPX[team] * Canvas.ClipX - XL/2, Y);
			Canvas.DrawColor.A = Fade * 255;
			MyScoreboard.MyFont.DrawText(Canvas, str, Fade);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw grudge match thingy
// Y is the top of the grudge match logo
// returns the height of the grudge match area
///////////////////////////////////////////////////////////////////////////////
function float DrawGrudgeMatch(Canvas Canvas, float Y)
{
	local float W, H;
	local float Scale;

	// Draw scores in the center
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = WhiteColor;
	W = GrudgeMatchPW * Canvas.ClipX;
	Scale = W / GrudgeMatchTexture.USize;
	H = GrudgeMatchTexture.VSize * Scale;
	Canvas.SetPos((Canvas.ClipX - W)/2, Y);
	Canvas.DrawIcon(GrudgeMatchTexture, Scale);

	return H * 1.1;
}

///////////////////////////////////////////////////////////////////////////////
// Draw team logo
///////////////////////////////////////////////////////////////////////////////
function DrawTeamLogo(Canvas Canvas, int team, float Y)
{
	MyScoreboard.DrawTeamFlag(Canvas, team, TeamLogoPX[team] * Canvas.ClipX, Y, TeamLogoPH * Canvas.ClipY);
}

///////////////////////////////////////////////////////////////////////////////
// Slide down to specified goal
///////////////////////////////////////////////////////////////////////////////
function float SlideDownTo(Canvas Canvas, float GoalY, float Perc)
{
	return GoalY * Perc;
}

///////////////////////////////////////////////////////////////////////////////
// Slide down to specified goal and shake when it gets there
///////////////////////////////////////////////////////////////////////////////
function float SlideUpTo(Canvas Canvas, float GoalY, float Perc)
{
	return Canvas.ClipY - ((Canvas.ClipY - GoalY) * Perc);
}

///////////////////////////////////////////////////////////////////////////////
// Shake 
///////////////////////////////////////////////////////////////////////////////
function float Shake(Canvas Canvas, float GoalY, float Perc)
{
	local float rnd;

	rnd = (1.0 - Perc) * ShakeAmount;
	return GoalY + (FRand() * rnd*2 - rnd);
}

///////////////////////////////////////////////////////////////////////////////
// Play sound
///////////////////////////////////////////////////////////////////////////////
function DoPlaySound(Sound snd)
{
	local ESoundSlot Slot;

	NextSoundSlot++;
	if (NextSoundSlot == 0)
		slot = SLOT_None;
	else if (NextSoundSlot == 1)
		slot = SLOT_Misc;
	else if (NextSoundSlot == 2)
		slot = SLOT_Pain;
	else if (NextSoundSlot == 3)
		slot = SLOT_Interact;
//	else if (NextSoundSlot == 4)
//		slot = SLOT_Ambient;
	else if (NextSoundSlot == 4)
		slot = SLOT_Talk;
	else if (NextSoundSlot >= 5)
	{
		slot = SLOT_Interface;
		NextSoundSlot = -1;
	}
	//Log(self @ "DoPlaySound(): snd="$snd$" slot="$slot);
	PlayerController(Owner).PlaySound(snd, slot, 1.0);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	YourTeamString="Your Team"
	EnemyTeamString = "Enemy Team"

	TotalDuration=5.0

	MatchScoreTime1=0.0
	MatchScoreTime2=0.4
	MatchScoreTime3=0.6

	Team1LogoTime1=0.6
	Team1LogoTime2=1.0
	Team1LogoTime3=1.2
	
	Team2LogoTime1=1.2
	Team2LogoTime2=1.6
	Team2LogoTime3=1.8

	PlayerTeamTime1=1.8
	PlayerTeamTime2=2.2
	PlayerTeamTime3=2.4

	GrudgeTime1=2.4
	GrudgeTime2=2.6
	GrudgeTime3=3.4
	GrudgeSoundTime=3.9
	GrudgeTotalTime=1.0

	MatchTime1=3.5
	MatchTime2=3.8
	
	MatchScorePY=0.10
	TeamLogoPY=0.20
	TeamLogoPH=0.20
	TeamLogoPX[0]=0.20
	TeamLogoPX[1]=0.80
	PlayerTeamPY=0.41
	PressFirePY=0.55

	ShakeAmount=26

	GrudgeMatchTexture=Texture'MpHUD.GrudgeMatch'
	GrudgeMatchPW=0.50
	GrudgeMatchPY=0.50

	MetalSound=Sound'MiscSounds.MetalHitsGround3'
	GrudgeSound=Sound'MpAnnouncer.AnnouncerGrudgeMatch'
	ExplosionSound=Sound'MiscSounds.Props.CarExplode'
}
