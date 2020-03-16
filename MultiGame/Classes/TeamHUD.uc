///////////////////////////////////////////////////////////////////////////////
// TeamHUD.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Adds team support to our multiplayer HUD.
//
///////////////////////////////////////////////////////////////////////////////
class TeamHUD extends MpHUD;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var() name					OrderNames[16];
var() int					NumOrders;

var localized string		StartupTeamPrefix;
var localized string		StartupTeamSuffix;
var localized string		StartupTeamChange;

var Texture					MatchScoreWindow[2];
var float					MatchScoreWindowPW;		// width of team score window
var	float					MatchScoreWindowPX;		// center of window, relative to center of screen (- for left, + for right)
var float					MatchScorePX;			// center of score, relative to team score window width
var float					TeamIconPX;				// center of icon, relative to team score window width
var float					TeamIconPY;				// center of icon, relative to team score window height
var float					TeamIconPW;				// width of team icon

var const float				TeamMirrorX[2];

///////////////////////////////////////////////////////////////////////////////
// Init
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Draw match score (typically only for team games)
// Y is the top of the match score area
///////////////////////////////////////////////////////////////////////////////
simulated function DrawMatchScore(Canvas Canvas, float Y)
{
	local int i;

	for ( i=0 ;i<2; i++ )
		DrawTeamGameWindow(Canvas, PlayerOwner.GameReplicationInfo.Teams[i], Y);
}

///////////////////////////////////////////////////////////////////////////////
// Draw the team game window (which contains various game info)
// NOTE: The two sets of team info are drawn "mirrored" around the center of
// the screen, which is primarily handled by setting x positions to negative
// and positive values.
//
// Y is the top of the team info area
///////////////////////////////////////////////////////////////////////////////
simulated function DrawTeamGameWindow(Canvas Canvas, TeamInfo TI, float Y)
{
	local float X, W, H;
	local int team;
	local float Scale;
	local Texture tex;

	if (TI != None)
	{
		team = TI.TeamIndex;

		// Team info window
		tex = MatchScoreWindow[team];
		W = MatchScoreWindowPW * Canvas.ClipX;
		Scale = W / tex.USize;
		H = tex.VSize * Scale;
		X = Canvas.ClipX / 2 + (MatchScoreWindowPX * Canvas.ClipX * TeamMirrorX[team]) - W/2;
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.DrawColor = WhiteColor;
		Canvas.SetPos(X, Y);
		Canvas.DrawIcon(tex, Scale);

		DrawTeamGameInfo(Canvas, TI, team, X + W/2, Y, W, H);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw team game info
///////////////////////////////////////////////////////////////////////////////
simulated function DrawTeamGameInfo(Canvas Canvas, TeamInfo TI, int team, float CenterX, float Y, float W, float H)
{
	local float XL, YL;
	local float IconSize;

	// Team logo
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = WhiteColor;
	Canvas.DrawColor.A = 170;
	IconSize = TeamIconPW * Canvas.ClipX;
	Canvas.SetPos(CenterX + (W * TeamIconPX * TeamMirrorX[team]) - IconSize/2, Y + H * TeamIconPY - IconSize/2);
	Canvas.DrawIcon(TI.TeamIcon, IconSize / TI.TeamIcon.USize);

	// Team score
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.Font = MyFont.GetFont(3, false, Canvas.ClipX );
	Canvas.bCenter = false;
	Canvas.DrawColor = WhiteColor;
	Canvas.StrLen(int(TI.Score), XL, YL);
	Canvas.SetPos(CenterX + W * MatchScorePX * TeamMirrorX[team] - XL/2, Y + H * TeamIconPY - YL / 2);
	MyFont.DrawText(Canvas, int(TI.Score));
}

///////////////////////////////////////////////////////////////////////////////
// Determine if pawn is valid
///////////////////////////////////////////////////////////////////////////////
simulated function bool PawnIsValid(vector vecPawnView, vector X, pawn P)
{
	// Pawn is only valid if it's on owner's team
	if ( (P.PlayerReplicationInfo == None) || ( P.PlayerReplicationInfo.Team != PlayerOwner.PlayerReplicationInfo.Team) )
		return false; 
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Draw info for specified pawn
///////////////////////////////////////////////////////////////////////////////
simulated function DrawPawnInfo(Canvas canvas, float screenX, float screenY, pawn P)
{
/* RWS CHANGE: Need to decide at some point if we want this crap floating over teammate's heads
	// draw range to target info
	local int Team, Width, Health;
	local string Name, H;
	
	local float xl,yl,y, perc;
	local PlayerReplicationInfo PRI;
	local vector TLoc;

	Canvas.Font = Canvas.SmallFont;
	Canvas.bCenter = false;

	PRI = P.PlayerReplicationInfo;
	Canvas.StrLen(PRI.PlayerName,xl,yl);
	
	ScreenY -= YL*2;
	
	if (PRI.Team != None)
		Canvas.DrawColor = PRI.Team.TeamColor;
	else
		Canvas.DrawColor = MyFont.TextColor;

	Canvas.SetPos(screenX - (xl/2),ScreenY);
	Canvas.DrawText(PRI.PlayerName, false);
	Canvas.Style = 1;

	ScreenY+= YL + 3;

	Perc = float(FPSPawn(P).GetHealthPercent()) / 100.0;
	if (Perc > 1.0)
		Perc = 1.0;

	DrawPercBar(Canvas, ScreenX, ScreenY, Canvas.ClipX * IdentityHealthPW, Canvas.ClipY * IdentityHealthPH, Canvas.DrawColor, Perc);
*/
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	OrderNames(0)=Defend
	OrderNames(1)=Hold
	OrderNames(2)=Attack
	OrderNames(3)=Follow
	OrderNames(4)=FreeLance
	OrderNames(5)=Point
	OrderNames(10)=Attack
	OrderNames(11)=FreeLance
	NumOrders=5

	StartupTeamPrefix="You are on "
	StartupTeamSuffix=""
	StartupTeamChange="(F4 changes)"

	MatchScorePY=0.008

	MatchScoreWindow(0)=Texture'MpHUD.scoreboard_L'
	MatchScoreWindow(1)=Texture'MpHUD.scoreboard_R'
	MatchScoreWindowPX=0.11
	MatchScoreWindowPW=0.22
	MatchScorePX=-0.10
	TeamIconPX=0.12
	TeamIconPY=0.50
	TeamIconPW=0.040

	TeamMirrorX(0)=-1
	TeamMirrorX(1)=1

	CriticalMessageYP=0.17
}