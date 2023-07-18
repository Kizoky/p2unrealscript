///////////////////////////////////////////////////////////////////////////////
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Team version of multiplayer scoreboard.
//
///////////////////////////////////////////////////////////////////////////////
class TeamScoreBoard extends MpScoreBoard;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string		WaitingPlayerString;

var float					ColumnCenterPX[2];
var float					ColumnCenterFlagPX[2];

var float					GameLogoPW;
var Texture					GameLogo;

var float					TeamFlagPH;

var float					TeamWindowPW;
var float					TeamWindowPH;
var Texture					TeamWindow[2];

var float					ScoreCenterPX[2];
var float					ScoreOffsetPY;
var byte					DrawAlpha;

var localized string		TeamHints[48];
var const int				TeamHintMax;


///////////////////////////////////////////////////////////////////////////////
// Determine whether the common replication info this class uses is available
///////////////////////////////////////////////////////////////////////////////
function bool IsReady()
{
	return
		PlayerController(Owner) != None &&
		PlayerController(Owner).GameReplicationInfo != None &&
		MPTeamInfo(PlayerController(Owner).GameReplicationInfo.Teams[0]) != None &&
		MPTeamInfo(PlayerController(Owner).GameReplicationInfo.Teams[1]) != None &&
		MPTeamInfo(PlayerController(Owner).GameReplicationInfo.Teams[0]).TeamTextureNoMips != None;
}

///////////////////////////////////////////////////////////////////////////////
// Draw the header for the players section
///////////////////////////////////////////////////////////////////////////////
function DrawPlayerSectionHeader(Canvas Canvas, float Y)
{
	local int team;

	DrawMatchScore(Canvas, Y);

	// Draw team flags to the left and right
	for (team = 0; team < 2; team++)
		DrawTeamFlag(Canvas, team, ColumnCenterFlagPX[team] * Canvas.ClipX, Y + TeamWindowPH * Canvas.ClipY, TeamFlagPH * Canvas.ClipY);
}

///////////////////////////////////////////////////////////////////////////////
// Draw match score
// Y is top of score area
///////////////////////////////////////////////////////////////////////////////
function DrawMatchScore(Canvas Canvas, float Y)
{
	MpHud(Playercontroller(Owner).MyHud).DrawMatchScore(Canvas, Y);
}

///////////////////////////////////////////////////////////////////////////////
// Draw team flag
// X is center of flag
// Y is bottom of flag
// H is desired flag height
///////////////////////////////////////////////////////////////////////////////
function DrawTeamFlag(Canvas Canvas, int team, float X, float Y, float H)
{
	local MPTeamInfo TI;
	local float XL, YL;
	local float Scale;
	local float LogoW;

	TI = MPTeamInfo(PlayerController(Owner).GameReplicationInfo.Teams[team]);

	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = WhiteColor;
	Canvas.DrawColor.A = DrawAlpha;
	Scale = H / TI.TeamTextureNoMips.VSize;
	LogoW = Scale * TI.TeamTextureNoMips.USize;
	Canvas.SetPos(X - LogoW/2, Y - H);
	Canvas.DrawIcon(TI.TeamTextureNoMips, Scale);
}

///////////////////////////////////////////////////////////////////////////////
// Draw the players section (info about each player)
///////////////////////////////////////////////////////////////////////////////
function DrawPlayerSectionBody(Canvas Canvas, float Y)
{
	local int i;
	local int team;
	local int TeamRow[2];
	local float XL, YL;
	local string Msg;

	// Draw the info for each player
	for (i = 0; i < PlayerCount; i++)
	{
		if (PlayerList[i].Team != None)
		{
			team = PlayerList[i].Team.TeamIndex;
			if (TeamRow[team] < PlayerRows)
			{
				DrawPlayerInfo(
					Canvas,
					PlayerList[i],
					(ColumnCenterPX[team] - PlayerWindowPW / 2) * Canvas.ClipX,
					Y + (TeamRow[team] * PlayerRowH));
				TeamRow[team]++;
			}
		}
	}

	// If some players aren't shown then display a message saying so
	for (team = 0; team < 2; team++)
	{
		if (PlayerTeamCount[team] > PlayerRows)
		{
			Canvas.Style = ERenderStyle.STY_Normal;
			Canvas.bCenter = false;
			Canvas.DrawColor = WhiteColor;
			Canvas.Font = PlayerFontLg;
			Msg = SomePlayersNotShownPrefix $ PlayerTeamCount[team]-PlayerRows $ SomePlayersNotShownSuffix;
			Canvas.StrLen(Msg, XL, YL);
			Canvas.SetPos(ColumnCenterPX[team] - XL/2, PlayerRows * PlayerRowH);
			MyFont.DrawText(Canvas, Msg);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get height of player client area based on current font sizes.
// The size value is used to request a smaller client height if possible.
///////////////////////////////////////////////////////////////////////////////
function GetPlayerClientHeight(Canvas Canvas, int Size, out float MinH, out float MaxH)
{
	if (Size == 3)
	{
		// Large player name with two small items under it
		MinH = PlayerFontLgYL + (PlayerFontSmYL * 2);
		MaxH = MinH + PlayerFontLgYL;	// extra padding looks better
	}
	else
	{
		// Large player name with one small item under it
		MinH = PlayerFontLgYL + (PlayerFontSmYL * 1);
		MaxH = MinH + PlayerFontLgYL;	// extra padding looks better
	}
 }

///////////////////////////////////////////////////////////////////////////////
// Draw player info
///////////////////////////////////////////////////////////////////////////////
function DrawPlayerInfo(Canvas Canvas, MpPlayerReplicationInfo PRI, float X, float Y)
{
	local float XL, YL;
	local float TextY;
	local float XOffset;
	local PlayerController PlayerOwner;
	local int Time;
	local string str;
	local int team;
	local bool bSkipOrders;
	local int TextHeight;

	PlayerOwner = PlayerController(Owner);
	team = PRI.Team.TeamIndex;

	// Draw window
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(X, Y);
	Canvas.DrawTile(TeamWindow[team], PlayerWindowW, PlayerWindowH, 0, 0, TeamWindow[team].USize, TeamWindow[team].VSize);

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.bCenter = false;

	// Ideal size is 1 line of large text and 2 lines of small text, but if that
	// won't fit, or if we don't need to show orders because there are no bots,
	// then reduce to 1 large line and 1 small line.
	TextHeight = PlayerFontLgYL + (PlayerFontSmYL * 2);
	if (PlayerClientH < TextHeight || BotCount == 0)
	{
		TextHeight = PlayerFontLgYL + PlayerFontSmYL;
		bSkipOrders = true;
	}
	TextY = Y + (PlayerWindowH - TextHeight) / 2;

	// Draw Name
	XOffset = X + PlayerNamePX * Canvas.ClipX;
	if ( PRI == PlayerOwner.PlayerReplicationInfo )
		Canvas.DrawColor = LocalPlayerColorHigh;
	else
		Canvas.DrawColor = OtherPlayerColorHigh;
	Canvas.Font = PlayerFontLg;
	ReduceFontToFit(Canvas, PRI.PlayerName, PlayerNamePW * Canvas.ClipX, XL, YL);
	Canvas.SetPos(XOffset, TextY + (PlayerFontLgYL - YL)/2);
	MyFont.DrawText(Canvas, PRI.PlayerName);
	// Useful for adjusting name width
	//Canvas.SetPos(XOffset, TextY);
	//Canvas.DrawHorizontal(Canvas.CurY, Canvas.ClipX * PlayerNamePW);

	// If this is a teammate then draw additional info under the name
	if ( PRI.Team == Controller(Owner).PlayerReplicationInfo.Team )
	{
		Canvas.Font = PlayerFontSm;
		if ( PRI == PlayerOwner.PlayerReplicationInfo )
			Canvas.DrawColor = LocalPlayerColorLow;
		else
			Canvas.DrawColor = OtherPlayerColorLow;

		// Draw location or special string if you're a waiting player
		if (PRI.bIsSpectator && PRI.bWaitingPlayer)
			str = WaitingPlayerString;
		else
			str = PRI.GetLocationName();
		Canvas.SetPos(XOffset, TextY + PlayerFontLgYL);
		MyFont.DrawText(Canvas, str);

		// Draw orders (only applies to bots)
		if (!bSkipOrders && PRI.bBot && PRI.Squad != None)
		{
			str = PRI.Squad.GetOrderStringFor(PRI);
			if (str != "")
			{
				Canvas.SetPos(XOffset, TextY + PlayerFontLgYL + PlayerFontSmYL);
				MyFont.DrawText(Canvas, str);
			}
		}
	}

	// Draw Score or status string
	if ( PRI == PlayerOwner.PlayerReplicationInfo )
		Canvas.DrawColor = LocalPlayerColorHigh;
	else
		Canvas.DrawColor = OtherPlayerColorHigh;
	str = GetScoreOrStatus(PRI);
	Canvas.Font = PlayerFontLg;
	ReduceFontToFit(Canvas, str, PlayerScorePW * Canvas.ClipX, XL, YL);
	Canvas.SetPos(X + PlayerScorePX * Canvas.ClipX - XL/2, Y + (PlayerWindowH - YL) / 2);
	MyFont.DrawText(Canvas, str);
	// Useful for adjusting score width
	//Canvas.SetPos(X + PlayerScorePX * Canvas.ClipX - (Canvas.ClipX * PlayerScorePW/2), Y + (PlayerWindowH - PlayerFontLgYL) / 2);
	//Canvas.DrawHorizontal(Canvas.CurY + 10, Canvas.ClipX * PlayerScorePW);

	// Draw kills and deaths
	Canvas.Font = PlayerFontMd;
	str = PRI.Kills$"-"$int(PRI.Deaths);
	Canvas.StrLen(str, XL, YL);
	Canvas.SetPos(X + PlayerKillsPX * Canvas.ClipX - XL/2, Y + (PlayerWindowH - PlayerFontMdYL) / 2);
	MyFont.DrawText(Canvas, str);

	// Draw net info
	DrawPlayerNetInfo(Canvas, PRI, X, Y);
}

///////////////////////////////////////////////////////////////////////////////
// Add our hints to pool of hints.
// Returns the number of game-specific hints that were added.
///////////////////////////////////////////////////////////////////////////////
function int AddHints()
{
	local int i;
	local int existing;

	existing = AllHints.length;
	for (i = 0; i < TeamHintMax; i++)
	{
		AllHints.insert(existing + i, 1);
		AllHints[existing + i] = TeamHints[i];
	}

	Super.AddHints();

	return 0;
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	WaitingPlayerString="Spectating"

	PlayerSectionHeaderPY=0.075
	PlayerSectionBodyPY=0.240
	PlayerWindowPW=0.470

	PlayerNamePX=0.020
	PlayerNamePW=0.220
	PlayerScorePX=0.280
	PlayerScorePW=0.050
	PlayerKillsPX=0.350
	PlayerNetPX=0.39

	ColumnCenterPX[0]=0.25;
	ColumnCenterPX[1]=0.75;

	ColumnCenterFlagPX[0]=0.15;
	ColumnCenterFlagPX[1]=0.85;

	GameLogoPW=0.20
	GameLogo=Texture'MpHUD.postal_logo'

	TeamFlagPH=0.15

	TeamWindowPW=0.26
	TeamWindowPH=0.16

	TeamWindow[0]=Texture'MpHUD.field_gray'
	TeamWindow[1]=Texture'MpHUD.field_gray'

	DrawAlpha=255

	ScoreCenterPX[0]=0.45
	ScoreCenterPX[1]=0.55
	ScoreOffsetPY=0.75

	TeamHints[0]="If you're shooting someone and they're not"
	TeamHints[1]="getting hurt, they're probably on your team!"

	TeamHints[2]="Travel in packs with your teammates to"
	TeamHints[3]="increase your chances."

	TeamHints[4]="Switch to your hands and press Fire"
	TeamHints[5]="to tell teammates to follow you."

	TeamHints[6]="Switch to your hands and press Secondary Fire"
	TeamHints[7]="to tell teammates to stay put."

	TeamHints[8]="Explosions hurt everyone, regardless of team."
	TeamHints[9]=""

	// UPDATE ME!!!
	TeamHintMax=10
}
