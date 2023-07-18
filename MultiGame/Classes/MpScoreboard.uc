///////////////////////////////////////////////////////////////////////////////
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Multiplayer scoreboard.
//
///////////////////////////////////////////////////////////////////////////////
class MpScoreBoard extends ScoreBoard;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string MapTitleIn, ElapsedTimeString, RemainingTimeString;
var localized string ScoreGoalString, TimeLimitString, MaxLivesString;
var localized string PlayerString, ScoreString, FragsString, DeathsString, PingString, NetString;
var localized string TimeString;
var localized string PreGameEndMessage,PostGameEndMessage,TieGameMessage;
var localized string SomePlayersNotShownPrefix;
var localized string SomePlayersNotShownSuffix;
var localized string DeadFireText, OutFireText, WaitingToSpawn, InitialViewingString, StartFireText;
var localized string ReadyText, NotReadyText, OutText;
var localized string MatchHintText1;
var localized string MatchHintText2;
var localized string ForNextText;
var localized string ToggleScoreText;

var color						LocalPlayerColorHigh;
var color						LocalPlayerColorLow;
var color						OtherPlayerColorHigh;
var color						OtherPlayerColorLow;
var color						WinnerColor;
var color						WhiteColor;
var color						GeneralTextColor;

var GameReplicationInfo			GRI;
var FontInfo					MyFont;

var MpPlayerReplicationInfo		PlayerList[32];
var int							PlayerCount;
var int							BotCount;
var int							PlayerTeamCount[2];
var int							DesiredPlayerRows;

var PlayerController			PlayerOwner;
var bool						bTimeDown;

var const float					MatchTitlePY;			// Position of match title
var const float					PlayerSectionHeaderPY;	// Position of player section header
var const float					PlayerSectionBodyPY;	// Position of player section
var const float					PlayerSectionBottomPY;	// Position of bottom edge of player section
var const float					MatchStatusPY;			// Position of match status
var const float					MatchHintPY;			// Position of match hint

var const Texture				PlayerWindow;			// Texture for player window

var const float					PlayerWindowPW;			// Total player window width
var const float					PlayerBorderPH;			// Total player window border height (top and bottom)
var const float					PlayerSpacingPH;		// Spacing between player windows

var const float					PlayerNamePX;			// Position of player name
var const float					PlayerNamePW;			// Width allocated to player name
var const float					PlayerScorePX;			// Position of player score
var const float					PlayerScorePW;			// Width allocated to player score
var const float					PlayerKillsPX;			// Position of player kills
var const float					PlayerDeathsPX;			// Position of player deaths
var const float					PlayerNetPX;			// Position of player net stats

var int							PlayerRows;				// Calculated number of rows (may be less than desired)
var float						PlayerRowH;				// Calculated player row height
var float						PlayerWindowH;			// Calculated player window height
var float						PlayerWindowW;			// Calculated player window width
var float						PlayerClientH;			// Calculated player client height (area inside the border)

var Font						PlayerFontLg;
var Font						PlayerFontMd;
var Font						PlayerFontSm;
var float						PlayerFontLgYL;
var float						PlayerFontMdYL;
var float						PlayerFontSmYL;

var int							OldDeathCount;			// Save this so you know when to repick hints
var array<string>				AllHints;
var int							CurrentHint;
var int							NumGameHints;
var config int					CurrentUserHint;
var config int					CurrentGameHint;
var config int					CurrentGenericHint;

var localized string			MpHints[48];
var const int					MpHintMax;

var const float					ServerNamePY;			// Position of server name
var localized string			ServerText;				// says 'server: '


///////////////////////////////////////////////////////////////////////////////
// Startup
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	MyFont = FontInfo(spawn(Class<Actor>(DynamicLoadObject(class'MpHUD'.default.FontInfoClass, class'Class'))));
	PlayerOwner = PlayerController(Owner);
	InitGRI();

	SetupHints();
}

///////////////////////////////////////////////////////////////////////////////
// Destroy
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if ( MyFont != None )
		MyFont.Destroy();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Init GRI
///////////////////////////////////////////////////////////////////////////////
simulated function InitGRI()
{
	GRI = PlayerOwner.GameReplicationInfo;
}

///////////////////////////////////////////////////////////////////////////////
// Update the GRI.
// Returns true if the GRI is available and its PRIArray is sorted
///////////////////////////////////////////////////////////////////////////////
function bool UpdateGRI()
{
	if (GRI == None)
	{
		InitGRI();
		if ( GRI == None )
			return false;
	}
	SortPRIArray();
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Master drawing function
// WARNING: This should only be called if UpdateGRI() returned true!
///////////////////////////////////////////////////////////////////////////////
simulated function DrawScoreboard(canvas Canvas)
{
	UpdatePlayerList();

	// Draw match title at the top
	DrawMatchTitle(Canvas, MatchTitlePY * Canvas.ClipY);

	// Draw server name right under the match name
	DrawServerName(Canvas, ServerNamePY * Canvas.ClipY);

	// Draw match explanation a little up from the bottom
	// No room for this when the scoreboard has more than a few players
	// DrawMatchHint(Canvas, MatchHintPY * Canvas.ClipY);

	// Draw match status at the bottom
	DrawMatchStatus(Canvas, MatchStatusPY * Canvas.ClipY);

	// Next comes the player section header and body
	LayoutPlayerSection(Canvas, (PlayerSectionBottomPY - PlayerSectionBodyPY) * Canvas.ClipY);

	DrawPlayerSectionHeader(Canvas, PlayerSectionHeaderPY * Canvas.ClipY);
	DrawPlayerSectionBody(Canvas, PlayerSectionBodyPY * Canvas.ClipY);
}

///////////////////////////////////////////////////////////////////////////////
// Draw the match title
///////////////////////////////////////////////////////////////////////////////
function DrawMatchTitle(Canvas Canvas, float Y)
{
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.bCenter = true;
	Canvas.Font = MyFont.GetFont(2, false, Canvas.ClipX );
	Canvas.DrawColor = GeneralTextColor;
	Canvas.SetPos(0, Y);
	// Says "'Game name' in 'Level name'
	MyFont.DrawText(Canvas, PlayerOwner.GameReplicationInfo.GameName @ MapTitleIn @ Level.Title );
}

///////////////////////////////////////////////////////////////////////////////
// Draw the server name
///////////////////////////////////////////////////////////////////////////////
function DrawServerName(canvas Canvas, float Y)
{
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.bCenter = true;
	Canvas.Font = MyFont.GetFont(1, false, Canvas.ClipX );
	Canvas.DrawColor = GeneralTextColor;
	Canvas.SetPos(0, Y);
	// Says "Server: 'Server name'"
	MyFont.DrawText(Canvas, ServerText @ PlayerOwner.GameReplicationInfo.ServerName);
}

///////////////////////////////////////////////////////////////////////////////
// Draw match status.  The actual type of message depends on all sorts of
// things, like whether there's a winner, whether you're dead, whether you're
// only a spectator, etc.
///////////////////////////////////////////////////////////////////////////////
function DrawMatchStatus(Canvas Canvas, optional float Y, optional bool bCriticalOnly, optional bool bIncludeStartup)
{
	local string str;
	local bool bShowToggleTip;
	local float XL, YL;

	// Clear this if it's about to be deleted
	if ( PlayerOwner.GameReplicationInfo.Winner != None
		&& PlayerOwner.GameReplicationInfo.Winner.bDeleteMe)
		PlayerOwner.GameReplicationInfo.Winner = None;

	// Check if there's a winner
	if ( PlayerOwner.GameReplicationInfo.Winner != None )
	{
		DrawWinner(Canvas, Y);
	}
	// Check if player is temporarily spectating
	else if ( (PlayerOwner.Pawn == None) && !PlayerOwner.PlayerReplicationInfo.bOnlySpectator )
	{
		if (GRI != None && GRI.bMatchHasBegun)
		{
			if (PlayerOwner.IsDead())
			{
				if ( (PlayerOwner.PlayerReplicationInfo != None) && PlayerOwner.PlayerReplicationInfo.bOutOfLives)
					str = OutFireText;
				else
				{
					str = DeadFireText;
					// Show how to toggle the scoreboard back off, only when you're dead. It's an important
					// new key introduced that isn't explained anywhere, so we'll show it all the time (in
					// tiny font at least to not be too annoying)
					if(P2Player(PlayerOwner) != None
						&& P2Player(PlayerOwner).bMpHints)
						bShowToggleTip=true;
				}
			}
			else if ( (PlayerOwner.PlayerReplicationInfo != None) && PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
				str = WaitingToSpawn;
			else
				str = InitialViewingString;
		}
		else
		{
			if (bIncludeStartup)
			{
				// If it's an early startup stage then show the startup message, but we don't
				// want to frustrate the player with "match is about to begin" if he's stuck
				// in the match intro.
				if (MpPlayer(PlayerOwner).MostRecentStartupStage <= 1)
					str = class'StartupMessage'.static.GetString(PlayerOwner, MpPlayer(PlayerOwner).MostRecentStartupStage, MpPlayer(PlayerOwner).PlayerReplicationInfo);
				else
					str = StartFireText;
			}
		}

		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.bCenter = true;
		Canvas.Font = MyFont.GetFont(2, false, Canvas.ClipX );
		Canvas.DrawColor = GeneralTextColor;
		Canvas.StrLen(str, XL, YL);
		Canvas.SetPos(0, Y);
		//MyFont.DrawText(Canvas, str);

		// Change by NickP: MP fix
		MyFont.TextColor = GeneralTextColor;
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, Canvas.ClipX/2, Y, str, 2, false, EJ_Center);
		// End

		if(bShowToggleTip)
		{
			Canvas.bCenter = true;
			Canvas.Font = MyFont.GetFont(0, false, Canvas.ClipX );
			Canvas.DrawColor = GeneralTextColor;
			Canvas.SetPos(0, Y + YL);
			//MyFont.DrawText(Canvas, ToggleScoreText);

			// Change by NickP: MP fix
			MyFont.TextColor = GeneralTextColor;
			MyFont.DrawTextEx(Canvas, Canvas.ClipX, Canvas.ClipX/2, Y + YL*1.25, str, 0, false, EJ_Center);
			// End
		}
	}
	// If all else fails, draw victory conditions
	else if (!bCriticalOnly)
		DrawVictoryConditions(Canvas, Y);
}

///////////////////////////////////////////////////////////////////////////////
// Setup hints
///////////////////////////////////////////////////////////////////////////////
function SetupHints()
{
	local int i;
	local int existing;

	// Add game-specific hints first
	NumGameHints = AddHints();

	// Add generic hints
	existing = AllHints.length;
	for (i = 0; i < MpHintMax; i++)
	{
		AllHints.insert(existing + i, 1);
		AllHints[existing + i] = MpHints[i];
	}

	// Ensure value is in range
	if (CurrentGenericHint < NumGameHints || CurrentGenericHint >= AllHints.length)
		CurrentGenericHint = NumGameHints;

	// Ensure value is in range
	if (CurrentGameHint < 0 || CurrentGameHint >= NumGameHints)
		CurrentGameHint = 0;

	// The first right-click hint should be a game-specific one
	if (CurrentUserHint < 0 || CurrentUserHint >= NumGameHints)
		CurrentUserHint = 0;
}

///////////////////////////////////////////////////////////////////////////////
// Extended classes use this to add their own hints
///////////////////////////////////////////////////////////////////////////////
function int AddHints();

///////////////////////////////////////////////////////////////////////////////
// Go to the next hint in the list
///////////////////////////////////////////////////////////////////////////////
function UseNextHint()
{
	CurrentUserHint += 2;
	if(CurrentUserHint >= AllHints.length)
		CurrentUserHint = 0;

	CurrentHint = CurrentUserHint;
}

///////////////////////////////////////////////////////////////////////////////
// Get match hint
///////////////////////////////////////////////////////////////////////////////
function GetMatchHint()
{
	if(PlayerOwner != None
		&& PlayerOwner.PlayerReplicationInfo != None)
	{
		// Pick a new hint whenever we die or restart
		if(OldDeathCount != PlayerOwner.PlayerReplicationInfo.Deaths)
		{
			OldDeathCount = PlayerOwner.PlayerReplicationInfo.Deaths;

			// Pick game-specific hints more often than generic hints
			if (FRand() < 0.66)
			{
				// Cycle through game hints
				CurrentGameHint += 2;
				if (CurrentGameHint >= NumGameHints)
					CurrentGameHint = 0;
				CurrentHint = CurrentGameHint;
			}
			else
			{
				// Cycle through generic hints
				CurrentGenericHint += 2;
				if (CurrentGenericHint >= AllHints.length)
					CurrentGenericHint = NumGameHints;
				CurrentHint = CurrentGenericHint;
			}
		}

		// Update out here since other code can update CurrentHint
		MatchHintText1 = AllHints[CurrentHint];
		MatchHintText2 = AllHints[CurrentHint+1];
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw match hint (give people clues on how to play)
///////////////////////////////////////////////////////////////////////////////
function DrawMatchHint(Canvas Canvas, optional float Y, optional bool bCriticalOnly, optional bool bIncludeStartup)
{
	local string str;
	local float XL, YL;
	local bool bShowHint;
	local bool bShowUseNextTip;

	local int i;

	if(P2Player(PlayerOwner) != None
		&& P2Player(PlayerOwner).bMpHints)
	{
		GetMatchHint();

		if(MatchHintText1 != ""
			|| MatchHintText2 != "")
		{
			// Check if there's a winner
			if ( PlayerOwner.GameReplicationInfo.Winner != None )
			{
			}
			// Check if player is temporarily spectating
			else if ( (PlayerOwner.Pawn == None) && !PlayerOwner.PlayerReplicationInfo.bOnlySpectator )
			{
				if (GRI != None && GRI.bMatchHasBegun)
				{
					if (PlayerOwner.IsDead())
					{
						if ( (PlayerOwner.PlayerReplicationInfo != None) && PlayerOwner.PlayerReplicationInfo.bOutOfLives)
							;
						else
						{
							bShowHint=true;
							bShowUseNextTip=true;
						}
					}
					else if ( (PlayerOwner.PlayerReplicationInfo != None) && PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
						bShowHint=true;
					else
						;
				}
				else
				{
					if (bIncludeStartup)
					{
						bShowUseNextTip=true;
						bShowHint=true;
					}
					else if(bCriticalOnly)
					{
						bShowUseNextTip=true;
						bShowHint=true;
					}
				}
			}

			if(bShowHint)
			{
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.bCenter = true;
				Canvas.Font = MyFont.GetFont(2, false, Canvas.ClipX );
				Canvas.DrawColor = GeneralTextColor;
				Canvas.StrLen(MatchHintText1, XL, YL);
				if (MatchHintText2 != "")
					Canvas.SetPos(0, Y);
				else
					Canvas.SetPos(0, Y + YL/2);
				//MyFont.DrawText(Canvas, MatchHintText1);

				// Change by NickP: MP fix
				MyFont.TextColor = GeneralTextColor;
				MyFont.DrawTextEx(Canvas, Canvas.ClipX, Canvas.ClipX/2, Y + YL*0.4, MatchHintText1, 2, false, EJ_Center);
				// End

				if (MatchHintText2 != "")
				{
					Canvas.SetPos(0, Y + YL);
					//MyFont.DrawText(Canvas, MatchHintText2);

					// Change by NickP: MP fix
					MyFont.TextColor = GeneralTextColor;
					MyFont.DrawTextEx(Canvas, Canvas.ClipX, Canvas.ClipX/2, Y + YL, MatchHintText2, 2, false, EJ_Center);
					// End
				}
			}
			if(bShowUseNextTip)
			{
				Canvas.bCenter = true;
				Canvas.Font = MyFont.GetFont(0, false, Canvas.ClipX );
				Canvas.DrawColor = GeneralTextColor;
				Canvas.SetPos(0, Y + 2*YL);
				//MyFont.DrawText(Canvas, ForNextText);

				// Change by NickP: MP fix
				MyFont.TextColor = GeneralTextColor;
				MyFont.DrawTextEx(Canvas, Canvas.ClipX, Canvas.ClipX/2, Y + 2.5*YL, ForNextText, 0, false, EJ_Center);
				// End
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw the header for the players section
///////////////////////////////////////////////////////////////////////////////
function DrawPlayerSectionHeader(Canvas Canvas, float Y)
{
	local float XL, YL;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.bCenter = false;
	Canvas.Font = MyFont.GetFont(3, true, Canvas.ClipX);
	Canvas.DrawColor = GeneralTextColor;

	Canvas.SetPos(Canvas.ClipX * PlayerNamePX, Y);
	MyFont.DrawText(Canvas, PlayerString);

	Canvas.StrLen(ScoreString, XL, YL);
	Canvas.SetPos(Canvas.ClipX * PlayerScorePX - XL/2, Y);
	MyFont.DrawText(Canvas, ScoreString);

	Y = Y + YL / 2;
	Canvas.Font = MyFont.GetFont(2, true, Canvas.ClipX);

	Canvas.StrLen(FragsString, XL, YL);
	Canvas.SetPos(Canvas.ClipX * PlayerKillsPX - XL/2, Y - YL/2);
	MyFont.DrawText(Canvas, FragsString);

	Canvas.StrLen(DeathsString, XL, YL);
	Canvas.SetPos(Canvas.ClipX * PlayerDeathsPX - XL/2, Y - YL/2);
	MyFont.DrawText(Canvas, DeathsString);

	if (Level.NetMode != NM_Standalone)
	{
		Canvas.SetPos(Canvas.ClipX * PlayerNetPX, Y - YL/2);
		MyFont.DrawText(Canvas, NetString);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw the players section (info about each player)
///////////////////////////////////////////////////////////////////////////////
function DrawPlayerSectionBody(Canvas Canvas, float Y)
{
	local int i;

	// Draw each visible player's info
	for ( i = 0; i < PlayerRows; i++)
		DrawPlayerInfo(Canvas, PlayerList[i], 0, Y + (i * PlayerRowH));

	// If some players aren't shown then display a message saying so
	if (PlayerRows < DesiredPlayerRows)
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.bCenter = true;
		Canvas.DrawColor = GeneralTextColor;
		Canvas.Font = PlayerFontLg;
		Canvas.SetPos(0, PlayerRows * PlayerRowH);
		MyFont.DrawText(Canvas, SomePlayersNotShownPrefix $ DesiredPlayerRows-PlayerRows $ SomePlayersNotShownSuffix);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw winner stuff
///////////////////////////////////////////////////////////////////////////////
function DrawWinner(Canvas Canvas, float Y)
{
	local float XL, YL;
	local string str;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.bCenter = true;
	Canvas.Font = MyFont.GetFont(3, false, Canvas.ClipX);
	Canvas.DrawColor = WinnerColor;
	Canvas.SetPos(0, Y);
	if (PlayerOwner.GameReplicationInfo.Winner == PlayerOwner.GameReplicationInfo)
		str = TieGameMessage;
	else
		str = PreGameEndMessage$PlayerOwner.GameReplicationInfo.Winner.GetHumanReadableName()$PostGameEndMessage;
	Canvas.StrLen(str, XL, YL);
	MyFont.DrawText(Canvas, str);
}

///////////////////////////////////////////////////////////////////////////////
// Draw victory conditions
///////////////////////////////////////////////////////////////////////////////
function DrawVictoryConditions(Canvas Canvas, float Y)
{
	local float XL, YL;
	local int Hours, Minutes, Seconds;
	local String Cond1, Cond2, Cond3;
	local String str;

	if ( PlayerOwner.GameReplicationInfo.GoalScore > 0 )
		Cond1 = ScoreGoalString @ PlayerOwner.GameReplicationInfo.GoalScore;

	if ( bTimeDown || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) )
	{
		bTimeDown = true;
		if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 0 )
			Cond2 = RemainingTimeString @ "00:00";
		else
		{
			Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
			Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
			Cond2 = RemainingTimeString @ TwoDigitString(Minutes)$":"$TwoDigitString(Seconds);
		}
	}
	else
	{
		Seconds = PlayerOwner.GameReplicationInfo.ElapsedTime;
		Minutes = Seconds / 60;
		Hours   = Minutes / 60;
		Seconds = Seconds - (Minutes * 60);
		Minutes = Minutes - (Hours * 60);
		Cond2 = ElapsedTimeString @ TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds);
	}

	if ( PlayerOwner.GameReplicationInfo.MaxLives > 0 )
	{
		Cond3 = MaxLivesString @ PlayerOwner.GameReplicationInfo.MaxLives;
	}

	str = CombineConditions(CombineConditions(Cond1, Cond2), Cond3);

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.bCenter = true;
	Canvas.Font = MyFont.GetFont(3, false, Canvas.ClipX);
	Canvas.DrawColor = GeneralTextColor;
	Canvas.SetPos(0, Y);
	Canvas.StrLen(str, XL, YL);
	if (XL > Canvas.ClipX)
		Canvas.Font = MyFont.GetFont(2, false, Canvas.ClipX);
	MyFont.DrawText(Canvas, str);
}

///////////////////////////////////////////////////////////////////////////////
// Combine two conditions into one with a separator between them
///////////////////////////////////////////////////////////////////////////////
function string CombineConditions(string a, string b)
{
	if (a != "")
	{
		if (b != "")
			return a$"   "$b;
		else
			return a;
	}
	return b;
}

///////////////////////////////////////////////////////////////////////////////
// Get height of player client area based on current font sizes.
// The size value is used to request a smaller client height if possible.
///////////////////////////////////////////////////////////////////////////////
function GetPlayerClientHeight(Canvas Canvas, int Size, out float MinH, out float MaxH)
{
	// One row of large text
	MinH = PlayerFontLgYL;
	MaxH = PlayerFontLgYL * 3;	// extra padding looks better
}

///////////////////////////////////////////////////////////////////////////////
// Draw player info
///////////////////////////////////////////////////////////////////////////////
function DrawPlayerInfo(Canvas Canvas, MpPlayerReplicationInfo PRI, float X, float Y)
{
	local float XL, YL;
	local float TextY;
	local bool bLocalPlayer;
	local string str;

	bLocalPlayer = ( PRI == PlayerOwner.PlayerReplicationInfo );

	// Draw window behind player info
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = WhiteColor;
	Canvas.DrawColor.A = 100;
	Canvas.SetPos((Canvas.ClipX - PlayerWindowW) / 2, Y);
	Canvas.DrawTile(PlayerWindow, PlayerWindowW, PlayerWindowH, 0, 0, PlayerWindow.USize, PlayerWindow.VSize);

	if ( bLocalPlayer ) 
		Canvas.DrawColor = LocalPlayerColorHigh;
	else 
		Canvas.DrawColor = OtherPlayerColorHigh;

	// Draw Name
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.bCenter = false;
	Canvas.Font = PlayerFontLg;
	ReduceFontToFit(Canvas, PRI.PlayerName, PlayerNamePW * Canvas.ClipX, XL, YL);
	Canvas.SetPos(Canvas.ClipX * PlayerNamePX, Y + (PlayerWindowH - YL) / 2);
	MyFont.DrawText(Canvas, PRI.PlayerName);
	// Useful for adjusting name width
	//Canvas.SetPos(Canvas.ClipX * PlayerNamePX, Y + (PlayerWindowH - YL) / 2);
	//Canvas.DrawHorizontal(Canvas.CurY, Canvas.ClipX * PlayerNamePW);

	// Draw Score or short status string (if string is too wide, switch to smaller font)
	str = GetScoreOrStatus(PRI);
	Canvas.Font = PlayerFontLg;
	ReduceFontToFit(Canvas, str, PlayerScorePW * Canvas.ClipX, XL, YL);
	TextY = Y + (PlayerWindowH - PlayerFontLgYL) / 2;
	Canvas.SetPos(Canvas.ClipX * PlayerScorePX - XL/2, Y + (PlayerWindowH - YL) / 2);
	MyFont.DrawText(Canvas, str);
	// Useful for adjusting score width
	//Canvas.SetPos(Canvas.ClipX * PlayerScorePX - (Canvas.ClipX * PlayerScorePW/2), Y + (PlayerWindowH - YL) / 2);
	//Canvas.DrawHorizontal(Canvas.CurY + 5, Canvas.ClipX * PlayerScorePW);

	// Use smaller font for kills and deaths
	Canvas.Font = PlayerFontMd;
	TextY = Y + (PlayerWindowH - PlayerFontMdYL) / 2;

	// Draw Kills
	Canvas.StrLen(PRI.Kills, XL, YL);
	Canvas.SetPos(Canvas.ClipX * PlayerKillsPX - XL/2, TextY);
	MyFont.DrawText(Canvas, PRI.Kills);

	// Draw Deaths
	Canvas.StrLen(int(PRI.Deaths), XL, YL );
	Canvas.SetPos( Canvas.ClipX * PlayerDeathsPX - XL/2, TextY);
	MyFont.DrawText(Canvas, int(PRI.Deaths));

	// Draw net info
	DrawPlayerNetInfo(Canvas, PRI, X, Y);
}

///////////////////////////////////////////////////////////////////////////////
// Reduce font until string fits available space
///////////////////////////////////////////////////////////////////////////////
function ReduceFontToFit(Canvas Canvas, string str, float AvailableWidth, out float XL, out float YL)
{
	Canvas.StrLen(str, XL, YL);
	while (XL > AvailableWidth)
	{
		if (Canvas.Font == PlayerFontLg)
		{
			Canvas.Font = PlayerFontMd;
			Canvas.StrLen(str, XL, YL);
		}
		else if (Canvas.Font == PlayerFontMd)
		{
			Canvas.Font = PlayerFontSM;
			Canvas.StrLen(str, XL, YL);
			break;
		}
		else
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get player score or a very short status string
///////////////////////////////////////////////////////////////////////////////
function string GetScoreOrStatus(MpPlayerReplicationInfo PRI)
{
	local string str;

	if (GRI.bMatchHasBegun)
	{
		if (PRI.bOutOfLives)
			str = OutText;
		else
			str = string(int(PRI.Score));
	}
	else if (PRI.bReadyToPlay)
		str = ReadyText;
	else
		str = NotReadyText;

	return str;
}

///////////////////////////////////////////////////////////////////////////////
// Assumes color is set to desired color!
///////////////////////////////////////////////////////////////////////////////
function DrawPlayerNetInfo(Canvas Canvas, MpPlayerReplicationInfo PRI, float X, float Y)
{
	local int NetRows;
	local float CenterY;
	local int Seconds, Minutes, Hours;
	local string str;

	if (Level.NetMode != NM_Standalone)
	{

		if ( PRI == PlayerOwner.PlayerReplicationInfo ) 
			Canvas.DrawColor = LocalPlayerColorLow;
		else 
			Canvas.DrawColor = OtherPlayerColorLow;

		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.bCenter = false;
		Canvas.Font = PlayerFontSm;

		NetRows = Min(PlayerClientH / PlayerFontSmYL, 2);
		CenterY = Y + (PlayerWindowH - (NetRows * PlayerFontSmYL)) / 2;

		// Draw Ping
		Canvas.SetPos(X + Canvas.ClipX * PlayerNetPX, CenterY);
		if (!PRI.bbot)
			str = string(PRI.Ping);
		else
			str = "--";
		MyFont.DrawText(Canvas, PingString @ str);
		CenterY += PlayerFontSmYL;

		if (NetRows > 1)
		{
			// Draw Time
			Seconds = Level.TimeSeconds + PlayerOwner.PlayerReplicationInfo.StartTime - PRI.StartTime;
			Hours = Seconds / 3600;
			Seconds -= Hours * 3600;
			Minutes = Seconds / 60;
			Seconds -= Minutes * 60;
			//str = TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds);
			str = TwoDigitString(Minutes)$":"$TwoDigitString(Seconds);
			Canvas.SetPos(X + Canvas.ClipX * PlayerNetPX, CenterY);
			MyFont.DrawText(Canvas, str);
			CenterY += PlayerFontSmYL;
		}

//		if (NetRows > 2)
//		{
//			// Draw FPH
//			Canvas.SetPos(X + Canvas.ClipX * PlayerNetPX, CenterY);
//			MyFont.DrawText(Canvas, FPHString @ int(60 * PRI.Score/Time));
//			CenterY += YL;
//		}

	}
}

///////////////////////////////////////////////////////////////////////////////
// Update player list and related info.
// IMPORTANT: PRIArray must be sorted before calling this.
///////////////////////////////////////////////////////////////////////////////
simulated function UpdatePlayerList()
{
	local int i;
	local MpPlayerReplicationInfo PRI;

	// Wipe everything.
	for (i = 0; i < ArrayCount(PlayerList); i++)
		PlayerList[i] = None;
	PlayerCount = 0;
	BotCount = 0;
	PlayerTeamCount[0] = 0;
	PlayerTeamCount[1] = 0;

	// We only include the actual players (no spectators) in our list
	for (i = 0; i < GRI.PRIArray.Length; i++)
	{
		PRI = MpPlayerReplicationInfo(GRI.PRIArray[i]);

		if (IncludeOnScoreboard(PRI))
		{
			PlayerList[PlayerCount] = PRI;

			if (PRI.bBot)
				BotCount++;

			if (PRI.Team != None)
				PlayerTeamCount[PRI.Team.TeamIndex]++;

			PlayerCount++;
			if ( PlayerCount == ArrayCount(PlayerList) )
				break;
		}
	}

	if (PlayerTeamCount[0] > 0 || PlayerTeamCount[1] > 0)
		DesiredPlayerRows = Max(PlayerTeamCount[0], PlayerTeamCount[1]);
	else
		DesiredPlayerRows = PlayerCount;
}

///////////////////////////////////////////////////////////////////////////////
// Sort GRI's PRIArray (bOnlySpectator players are put at the end of the list)
///////////////////////////////////////////////////////////////////////////////
simulated function SortPRIArray()
{
    local int i,j;
    local PlayerReplicationInfo tmp;
	local MpPlayerReplicationInfo PRI;

    for (i = 0; i < GRI.PRIArray.Length-1; i++)
    {
        for (j = i + 1; j < GRI.PRIArray.Length; j++)
        {
            if(!PlayersInOrder(GRI.PRIArray[i], GRI.PRIArray[j]))
            {
                tmp = GRI.PRIArray[i];
                GRI.PRIArray[i] = GRI.PRIArray[j];
                GRI.PRIArray[j] = tmp;
            }
        }
    }

    // Update rankings using only the real players
	j = 1;
	for (i = 0; i < GRI.PRIArray.Length; i++)
    {
		PRI = MpPlayerReplicationInfo(GRI.PRIArray[i]);
		if (PRI != None)
			PRI.Ranking = 0;
		if (IncludeOnScoreboard(PRI))
			PRI.Ranking = j++;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Return true if P1 should come before P2, false otherwise.
///////////////////////////////////////////////////////////////////////////////
simulated function bool PlayersInOrder( PlayerReplicationInfo P1, PlayerReplicationInfo P2 )
{
    // Non-spectators come first
	if( P1.bOnlySpectator )
        return P2.bOnlySpectator;
    if ( P2.bOnlySpectator )
        return true;

    // Higher scores come first
	if( P1.Score > P2.Score )
        return true;
    if( P1.Score == P2.Score )
    {
		// Higher kills come first
		if ( P1.Kills > P2.Kills )
			return true;
		else if ( P1.Kills == P2.Kills )
		{
			// Lower deaths come first
			if ( P1.Deaths < P2.Deaths )
				return true;
			if ( P1.Deaths == P2.Deaths )
			{
				// In the case of a tie, list the local player first.  By doing this
				// test "backwards" (meaning we test P2 instead of P1) it somehow stabilizes
				// the sorting in situations where two non-local-players are tied.
				if (PlayerController(P2.Owner) != None && Viewport(PlayerController(P2.Owner).Player) != None)
					return false;
				return true;
			}
			return false;
		}
		return false;
	}
    return false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if this player should be on the scoreboard
///////////////////////////////////////////////////////////////////////////////
simulated function bool IncludeOnScoreboard(MpPlayerReplicationInfo PRI)
{
	return	( PRI != None && !PRI.bOnlySpectator &&	(!PRI.bIsSpectator || PRI.bWaitingPlayer) );
}

///////////////////////////////////////////////////////////////////////////////
// Pad out number to a 2 digit string
///////////////////////////////////////////////////////////////////////////////
function string TwoDigitString(int Num)
{
	if ( Num < 10 )
		return "0"$Num;
	else
		return string(Num);
}

///////////////////////////////////////////////////////////////////////////////
// Calculate how many players can fit in the available space.  This can
// dynamically reduce the area size to maximize the number of visible players.
///////////////////////////////////////////////////////////////////////////////
function LayoutPlayerSection(Canvas Canvas, float AvailableH)
{
	local float XL, YL;
	local float MinH;
	local float MaxH;
	local float RowH;
	local float BorderH;
	local float SpacingH;
	local bool bRepeat;
	local bool bReservedSpace;
	local int FontSize;

	FontSize = 3;

	do
	{
		bRepeat = false;

		// Select fonts
		PlayerFontLg = MyFont.GetFont(FontSize, true, Canvas.ClipX);
		Canvas.Font = PlayerFontLg;
		Canvas.StrLen("TEST", XL, PlayerFontLgYL);
		PlayerFontMd = MyFont.GetFont(Max(0, FontSize - 1), true, Canvas.ClipX);
		Canvas.Font = PlayerFontMD;
		Canvas.StrLen("TEST", XL, PlayerFontMdYL);
		PlayerFontSm = MyFont.GetFont(0, true, Canvas.ClipX);
		Canvas.Font = PlayerFontSm;
		Canvas.StrLen("TEST", XL, PlayerFontSmYL);

		// Get player section heights based on selected fonts
		GetPlayerClientHeight(Canvas, FontSize, MinH, MaxH);

		// Adjust min and max to include borders and spacing to make it easier
		// to work out the actual height (see below)
		BorderH = PlayerBorderPH * Canvas.ClipY;
		SpacingH = PlayerSpacingPH * Canvas.ClipY;
		MinH += BorderH + SpacingH;
		MaxH += BorderH + SpacingH;

		// Calc raw height based on available space and desired rows.  If it's too small
		// then figure out the max number of rows and use that to determine the height.
		PlayerRows = DesiredPlayerRows;
		RowH = AvailableH / PlayerRows;
		if (RowH < MinH)
		{
			PlayerRows = AvailableH / MinH;
			RowH = AvailableH / PlayerRows;
		}
		if (RowH > MaxH)
		{
			RowH = MaxH;
		}
		PlayerRows = Min(DesiredPlayerRows, PlayerRows);

		// Set our various heights
		PlayerRowH    = RowH;
		PlayerWindowH = RowH - SpacingH;
		PlayerClientH = RowH - SpacingH - BorderH;
		//Log("AvailableH="$AvailableH$" DesiredPlayerRows="$DesiredPlayerRows$" PlayerFontLgYL="$PlayerFontLgYL$" PlayerFontSmYL="$PlayerFontSmYL$" MinH="$MinH$" MaxH="$MaxH$" PlayerRowH="$PlayerRowH);

		// Set width
		PlayerWindowW = PlayerWindowPW * Canvas.ClipX;

		// If we can't fit all the rows we want, try reducing the font size, and
		// if it still doesn't fit, reserve an area at the bottom to display a
		// message indicating that some players aren't shown.
		if (PlayerRows < DesiredPlayerRows)
		{
			if (FontSize > 2)
			{
				FontSize--;
				bRepeat = true;
			} else if (!bReservedSpace)
			{
				Canvas.Font = PlayerFontLg;
				AvailableH -= (PlayerFontLgYL + SpacingH);
				bReservedSpace = true;
				bRepeat = true;
			}
		}

	} until (!bRepeat);
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PlayerString="Player"
	ScoreString="Score"
	FragsString="Frags"
	DeathsString="Deaths"
	NetString="Net"
	PingString="Ping"
	TimeString="Time"
	MapTitleIn="in"
	SomePlayersNotShownPrefix="["
	SomePlayersNotShownSuffix=" additional players not shown]"

	ElapsedTimeString="Elapsed Time:"
	RemainingTimeString="Time Remaining:"
	ScoreGoalString="Score Limit:"
	MaxLivesString="Max Lives:"

	PreGameEndMessage""
	PostGameEndMessage=" won the round!"
	TieGameMessage="Round ends with no winner."

	LocalPlayerColorHigh=(R=244,G=237,B=160,A=255)
	LocalPlayerColorLow=(R=244,G=237,B=160,A=128)
	OtherPlayerColorHigh=(R=244,G=237,B=213,A=255)
	OtherPlayerColorLow=(R=244,G=237,B=213,A=128)
	WinnerColor=(R=249,G=183,B=97,A=255)
	GeneralTextColor=(R=211,G=199,B=156,A=255)

	WhiteColor=(R=255,G=255,B=255,A=255)

	MatchTitlePY=0.009
	PlayerSectionHeaderPY=0.095
	PlayerSectionBodyPY=0.145
	PlayerSectionBottomPY=0.94
	// Change by NickP: MP fix
	//MatchStatusPY=0.94
	MatchStatusPY=0.90
	//MatchHintPY=0.78
	MatchHintPY=0.74
	// End

	PlayerWindow=Texture'MpHud.field_gray'
	PlayerNamePX=0.140
	PlayerNamePW=0.330
	PlayerScorePX=0.525		// center of score
	PlayerScorePW=0.085
	PlayerKillsPX=0.640		// center of kills
	PlayerDeathsPX=0.740
	PlayerNetPX=0.800
	PlayerWindowPW=0.80
	PlayerBorderPH=0.005
	PlayerSpacingPH=0.005

	DeadFireText="You were killed.  Press %KEY_Fire% to restart."
	OutFireText="You are OUT.  Press %KEY_Fire% to view other players."
	WaitingToSpawn="Press %KEY_Fire% to join the match!"
	InitialViewingString="Press %KEY_Fire% to track other players or %KEY_AltFire% for free cam"
	StartFireText="Press %KEY_Fire% to start"
	ReadyText="READY"
	NotReadyText="NOT"
	OutText="OUT"
	ForNextText="Press %KEY_AltFire% for next tip."
	ToggleScoreText="Press %KEY_ShowScores% to toggle scoreboard."

	OldDeathCount=-1

	MpHints[0]="Guns have much less recoil when standing still or crouching."
	MpHints[1]=""

	MpHints[2]="Shooting a gun while running makes it much harder to control."
	MpHints[3]=""

	MpHints[4]="Shots to the head (headshots) will always"
	MpHints[5]="do more damange than shots to the body."

	MpHints[6]="Extra skull fragments squirt out when you shoot"
	MpHints[7]="someone in the head.  That signals a headshot!"

	MpHints[8]="A single shotgun to the head at close range will kill anyone."
	MpHints[9]="Instantly."

	MpHints[10]="Kick doors open to go through them faster!"
	MpHints[11]=""

	MpHints[12]="Alt-Fire grenades to drop them as grenade traps."
	MpHints[13]="You can kick your own grenade three times before it blows up."

	MpHints[14]="Shoot seeking rockets out of the air"
	MpHints[15]="or kick them away to buy yourself some time!"

	MpHints[16]="The fish radar only tracks people that are moving."
	MpHints[17]="Stand still to hide your position!"

	MpHints[18]="When snipers aim at you, your screen will go dark."
	MpHints[19]="When your screen goes dark, run for it!"

	MpHints[20]="When your sniper scope is up it will reflect"
	MpHints[21]="flashes of light and give away your position."

	MpHints[22]="Keep the Fire button down for grenades, molotovs"
	MpHints[23]="and rockets to have them ready to use!"

	MpHints[24]="Close-range shotgun blasts to the head"
	MpHints[25]="will kill anyone with one shot."

	MpHints[26]="Watch out for grenade traps -- they look like"
	MpHints[27]="grenade pickups but the grenade traps don't glow."

	MpHints[28]="Piss yourself out if you're on fire!"
	MpHints[29]="Or run into other people to catch them on fire!"

	MpHints[30]="A white puff coming from someone's head means they"
	MpHints[31]="just smoked a health pipe and regained 125 in health!"
	
	MpHints[32]="Use the Quickhealth key to quickly"
	MpHints[33]="regain health during a fire-fight!"
	
	MpHints[34]="Breadcrumbs falling from someone's face means"
	MpHints[35]="they just ate fast food and regained health!"
	
	MpHints[36]="Kevlar does not stop headshots."
	MpHints[37]="Kevlar protects the entire body but not the head."
	
	MpHints[38]="If you're shooting someone and they're just not dying,"
	MpHints[39]="they're probably eating food or smoking a health pipe."

	MpHints[40]="Bigger items on the radar are ABOVE you."
	MpHints[41]="Smaller items on the radar are BELOW you."
	// UPDATE ME!!!
	MpHintMax=42

	ServerText="Server: "
	// Change by NickP: MP fix
	//ServerNamePY=0.045
	ServerNamePY=0.05
	// End
}
