///////////////////////////////////////////////////////////////////////////////
// MpHUD.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Adds multiplayer elements to our singleplayer HUD.
//
///////////////////////////////////////////////////////////////////////////////
class MpHUD extends MpHUDBase
	config;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var PlayerReplicationInfo		PawnOwnerPRI;

var float						IdentityFadeTime;
var float						IdentityFadeDuration;
var MpPlayerReplicationInfo		IdentityTarget;
var float						IdentityInfoPY;
var float						IdentityHealthPW;
var float						IdentityHealthPH;
var float						IdentityBorderPS;

var Texture						ScoreWindow;
var Texture						MessageWindow;

var float						BlinkVal;
var float						BlinkDir;

var int							LastReportedTime;
var bool						bTimeValid;

var bool						bHideOwnScore;

var float						WeaponFadeTime;
var float						MessageFadeTime;

var string						TimeMessageClassName;
var class<TimeMessage>			TimeMessageClass;

var float						LastTime;
var float						CurrentDeltaTime;

var localized string			ViewFrom;
var localized string			LoadoutMessage;
var localized string			LoadoutCycle;

var localized string			RankingText[16];
var int							PrevRanking;
var bool						bBlinkRanking;
var float						RankingBlinkDuration;
var float						RankingBlinkExpiration;

var const float					OwnScoreWindowPX;
var const float					OwnScoreWindowPY;
var const float					OwnScoreWindowPW;
var const float					OwnScoreInfoPY;
var const float					OwnScoreRankPX;
//var const float				OwnScoreKillsPX;
//var const float				OwnScoreDeathsPX;

var float						MatchScorePY;

var bool						bPlayersSorted;


///////////////////////////////////////////////////////////////////////////////
// Init
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	TimeMessageClass = class<TimeMessage>(DynamicLoadObject(TimeMessageClassName, class'Class'));
}

///////////////////////////////////////////////////////////////////////////////
// Setup stuff
///////////////////////////////////////////////////////////////////////////////
simulated function HUDSetup(canvas canvas)
{
	Super.HUDSetup(Canvas);
	
	if (OurPlayer == None)
		PawnOwnerPRI = None;
	else if ((PawnOwner != None) && (PawnOwner.Controller != None))
		PawnOwnerPRI = PawnOwner.PlayerReplicationInfo;
	else
		PawnOwnerPRI = OurPlayer.PlayerReplicationInfo;
	
	CurrentDeltaTime = Level.TimeSeconds - LastTime;
	LastTime = Level.TimeSeconds;
}

///////////////////////////////////////////////////////////////////////////////
// Master HUD render function.
///////////////////////////////////////////////////////////////////////////////
simulated function DrawHUD( canvas Canvas )
{
	// Setup hud (also allows super to set itself up)
	HUDSetup(Canvas);

	// Lots of things rely on the scoreboard updating the GRI so do this first
	bPlayersSorted = false;
	if (MpScoreboard(Scoreboard) != None)
		bPlayersSorted = MpScoreboard(Scoreboard).UpdateGRI();

	// If match intro is running, show it
	if (IsMatchIntroRunning())
	{
		if (bShowScores && bPlayersSorted)
			MpScoreboard(Scoreboard).DrawScoreboard(Canvas);
		else
			UpdateMatchIntro(Canvas);
	}
	else
	{
		if (!bHideHUD && (PawnOwnerPRI != None))
		{
		
			// Display scoreboard when requested
			if (bShowScores && bPlayersSorted)
			{
				MpScoreboard(Scoreboard).DrawScoreboard(Canvas);

				// Only draw critical portions of normal hud
				if (!PawnOwnerPRI.bIsSpectator && (PawnOwner != None))
					DrawPlayerStatus(Canvas, true);
			}
			else
			{
				// If we're viewing a pawn other than our own then say who it is
				if ( Pawn(PlayerOwner.ViewTarget) != None && Pawn(PlayerOwner.ViewTarget) != PlayerOwner.Pawn && Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo != None)
					DrawViewFrom(Canvas, Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo, MpScoreboard(Scoreboard).MatchStatusPY * Canvas.ClipY);

				// Draw local messages
				DrawLocalMessages(Canvas);

				// Perform player tracking
				DrawPawnTrackers(Canvas);
				
				// Specators don't get to see this stuff
				if (!PawnOwnerPRI.bIsSpectator)
				{
					if (PawnOwner != None)
					{
						// Draw player status (health/armor, weapons/ammo, inventory, suicide)
						DrawPlayerStatus(Canvas);
					}

					// Draw own score, unless the game wants it hidden
					if ( !bHideOwnScore )
						DrawOwnScore(Canvas);

					// Draw match score
					DrawMatchScore(Canvas, MatchScorePY * Canvas.ClipY);
				}

				// If looking at a pawn, draw it's ID
				if ( (Canvas.ClipY > 320) && TraceIdentity(Canvas) )
					DrawIdentityInfo(Canvas, IdentityTarget);

				// Notify player about remaining time
				NotifyRemainingTime();

				// Have scoreboard draw critical status info
				if (MpScoreboard(Scoreboard) != None)
				{
					MpScoreboard(Scoreboard).DrawMatchStatus(Canvas, MpScoreboard(Scoreboard).MatchStatusPY * Canvas.ClipY, true);
					MpScoreboard(Scoreboard).DrawMatchHint(Canvas, MpScoreboard(Scoreboard).MatchHintPY * Canvas.ClipY, true);
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Update various stuff on tick
///////////////////////////////////////////////////////////////////////////////
simulated function Tick(float DeltaTime)
{
	local int i;

	Super.Tick(DeltaTime);

	IdentityFadeTime = FMax(0.0, IdentityFadeTime - DeltaTime);
	
	BlinkVal += BlinkDir * DeltaTime;
	if ( BlinkVal >= 1 )
	{
		BlinkDir *= -1;
		BlinkVal = 1;
	}
	else if ( BlinkVal <= 0 )
	{
		BlinkDir *= -1;
		BlinkVal = 0.004;  // RWS CHANGE: This times 255 is 1, which means alpha will never hit 0, which is a good thing
	}

	if ( MessageFadeTime < 1.0 )
	{
		MessageFadeTime += DeltaTime * 8;
		if (MessageFadeTime > 1.0)
			MessageFadeTime = 1.0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Identify the pawn the player is looking at.
// Returns true if a pawn was found, false otherwise.
///////////////////////////////////////////////////////////////////////////////
simulated function bool TraceIdentity(canvas Canvas)
{
	local actor Other;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;

	if ( (PawnOwner == None) || (PawnOwner != PlayerOwner.Pawn) )
		return false;

	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;
	EndTrace = StartTrace + vector(PlayerOwner.Rotation) * 2048.0;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	
	if ( IdentityFadeTime == 0.0 )
		IdentityTarget = None;

	if ( Pawn(Other) != None )
	{
		if ( (Pawn(Other).PlayerReplicationInfo != None) && !Other.bHidden )
		{
			IdentityTarget = MpPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo);
			IdentityFadeTime = IdentityFadeDuration;
		}
	}
	else if ( (Other != None) && SpecialIdentity(Canvas, Other) )
		return false;

	if ( (IdentityFadeTime == 0.0) || (IdentityTarget == None) || (IdentityTarget.PlayerName == "") )
		return false;

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Draw Identity info
///////////////////////////////////////////////////////////////////////////////
simulated function DrawIdentityInfo(canvas Canvas, MpPlayerReplicationInfo PRI)
{
	local float Y, XL, YL, XOffset, X1;
	local string str;
	local float Fade;
	local float Perc;

	str = PRI.PlayerName;
	if (bPlayersSorted)
		str = str$" ("$GetRankingString(PRI.Ranking)$")";

	Y = Canvas.ClipY * IdentityInfoPY;

//	if (PRI.Team != None)
//		Canvas.DrawColor = PRI.Team.TeamColor;
//	else
		Canvas.DrawColor = MyFont.TextColor;

	Fade = IdentityFadeTime / IdentityFadeDuration;
	Canvas.DrawColor.A = Fade * 128;
	if (Canvas.DrawColor.A > 0)
	{
		Canvas.Style = 	ERenderStyle.STY_Alpha;
		Canvas.bCenter = false;
		Canvas.Font = MyFont.GetFont(0, true, Canvas.ClipX);

		Canvas.StrLen(str, XL, YL);
		Canvas.SetPos((Canvas.ClipX - XL)/2, Y);
		Canvas.DrawText(str);

/* Pawn health isn't replicated to all clients to we dropped this
		if (Controller(PRI.Owner) != None && Controller(PRI.Owner).Pawn != None)
		{
			Perc = float(FPSPawn(Controller(PRI.Owner).Pawn).GetHealthPercent()) / 100.0;
			if (Perc > 1.0)
				Perc = 1.0;
			DrawPercBar(Canvas, Canvas.ClipX/2, Y + (YL * 1.25), Canvas.ClipX * IdentityHealthPW, Canvas.ClipY * IdentityHealthPH, Canvas.ClipX * IdentityBorderPS, Canvas.DrawColor, Perc);
		}*/
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check if it's a special identity
///////////////////////////////////////////////////////////////////////////////
simulated function bool SpecialIdentity(Canvas Canvas, Actor Other )
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Issue new orders to the currently identified bot
///////////////////////////////////////////////////////////////////////////////
exec function Order( name NewOrders )
{
	if ( (IdentityTarget == None) || (Bot(IdentityTarget.Owner) == None) )
		return;

	// FIXME - need to replicate orders to server
	Bot(IdentityTarget.Owner).SetOrders(NewOrders,PlayerOwner);
}

///////////////////////////////////////////////////////////////////////////////
// Draw your own score
///////////////////////////////////////////////////////////////////////////////
simulated function DrawOwnScore(Canvas Canvas)
{
	local float X, Y, W, H;
	local float XL, YL;
	local float Scale;
	local int Value;
	local string str;

	if ( PawnOwnerPRI == None )
		return;

	// Draw score window background
	Canvas.DrawColor = WhiteColor;
	Canvas.DrawColor.A = 128;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.bCenter = false;
	X = OwnScoreWindowPX * Canvas.ClipX;
	Y = OwnScoreWindowPY * Canvas.ClipY;
	W = OwnScoreWindowPW * Canvas.ClipX;
	Scale = W / ScoreWindow.USize;
	H = ScoreWindow.VSize * Scale;
	Canvas.SetPos(X,Y);
	Canvas.DrawIcon(ScoreWindow, Scale);

	Y = OwnScoreInfoPY * Canvas.ClipY;

	if (bPlayersSorted)
	{
		// Draw current ranking and have it blink whenever it changes
		Canvas.Font = MyFont.GetFont(1, false, Canvas.ClipX);
		
		Value = MpPlayerReplicationInfo(PawnOwnerPRI).Ranking;
		if (Value != PrevRanking)
		{
			bBlinkRanking = true;
			RankingBlinkExpiration = Level.TimeSeconds + RankingBlinkDuration;
			BlinkVal = 1.0;
			BlinkDir = -2.0;
			PrevRanking = Value;
		}

		if (RankingBlinkExpiration < Level.TimeSeconds)
			bBlinkRanking = false;

		str = GetRankingString(Value);
		Canvas.StrLen(Str, XL, YL);
		Canvas.SetPos(X + OwnScoreRankPX * W - XL/2, Y - YL/2);
		if (bBlinkRanking)
		{
			Canvas.Style = ERenderStyle.STY_Translucent;
			Canvas.DrawColor = MyFont.TextColor * BlinkVal;
			MyFont.DrawText(Canvas, Str, BlinkVal);
		}
		else
		{
			Canvas.DrawColor = MyFont.TextColor;
			Canvas.Style = ERenderStyle.STY_Normal;
			MyFont.DrawText(Canvas, Str, 1.0);
		}
	}

/*	Canvas.Font = MyFont.GetFont(2, true, Canvas.ClipX);
	Value = Clamp(int(PawnOwnerPRI.Score), -99, 999);
	Canvas.StrLen(Value, XL, YL);
	Canvas.SetPos(X + OwnScoreScorePX * W - XL/2, Y - YL/2);
	Canvas.DrawText(Value, false);

	Canvas.Font = MyFont.GetFont(1, true, Canvas.ClipX);
	Value = Clamp(int(MpPlayerReplicationInfo(PawnOwnerPRI).Kills), -99, 999);
	Canvas.StrLen(Value, XL, YL);
	Canvas.SetPos(X + OwnScoreKillsPX * W - XL/2, Y - YL/2);
	Canvas.DrawText(Value, false);

	Value = Clamp(int(PawnOwnerPRI.Deaths), -99, 999);
	Canvas.StrLen(Value, XL, YL);
	Canvas.SetPos(X + OwnScoreDeathsPX * W - XL/2, Y - YL/2);
	Canvas.DrawText(Value, false);
*/
}

///////////////////////////////////////////////////////////////////////////////
// Get ranking string for specified ranking (0 mean unknown, 1 to N is ranking)
///////////////////////////////////////////////////////////////////////////////
simulated function string GetRankingString(int Ranking)
{
	if (Ranking == 0)
		return "--";
	else
	{
		if (Ranking <= ArrayCount(RankingText))
			return RankingText[Ranking - 1];
		else
			return String(Ranking);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw match score (typically only for team games)
// Y is the top of the match score area
///////////////////////////////////////////////////////////////////////////////
simulated function DrawMatchScore(Canvas Canvas, float Y);

///////////////////////////////////////////////////////////////////////////////
// Draw trackers (info) above teammates heads
///////////////////////////////////////////////////////////////////////////////
simulated function DrawPawnTrackers(Canvas Canvas)
{
	local Pawn P, PlayerPawn;
	local vector vecPawnView;
	local vector X, Y, Z, L, V;

	// Only do this if the owner has a pawn (aka is alive) and only show
	// pawn trackers that owner would see, even if currently viewing from
	// another player's point of view.
	PlayerPawn = PlayerOwner.Pawn;
	if (PlayerPawn==None)
		return;
	
	GetAxes(PlayerPawn.GetViewRotation(), X, Y, Z);

	foreach DynamicActors(Class'Pawn', P)
	{
		if ((P != PlayerPawn) && !P.bInvulnerableBody)
		{
			// Get a vector from the player to the pawn and check if he's visible to the player
			vecPawnView = P.Location - PlayerPawn.Location - (PlayerPawn.EyeHeight * vect(0,0,1));
			if (PawnIsVisible(vecPawnView, X, P))
			{
				// Convert to screen coordinates
				L = P.Location + (Vect(0,0,1) * P.CollisionHeight);
				V = PlayerOwner.Player.Console.WorldToScreen(L, PlayerPawn.Location + (PlayerPAwn.EyeHeight * Vect(0,0,1)), PlayerPawn.Rotation);

				if (PawnIsValid(vecPawnView, X, P) && PawnIsInRange(P))
					DrawPawnInfo(Canvas, V.X, V.Y, P);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Determine if pawn is visible
///////////////////////////////////////////////////////////////////////////////
simulated function bool PawnIsVisible(vector vecPawnView, vector X, pawn P)
{
	local vector StartTrace, EndTrace;

    if ( (PawnOwner == None) || (PlayerOwner==None) )
		return false;

	if ( PawnOwner != PlayerOwner.Pawn )
		return false;

	if ( (vecPawnView Dot X) <= 0.70 )
		return false;
		
	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;

	EndTrace = P.Location;
	EndTrace.Z += P.BaseEyeHeight;

	if ( !FastTrace(EndTrace, StartTrace) )
		return false;

	return true;		
}

///////////////////////////////////////////////////////////////////////////////
// Determine if pawn is in range
///////////////////////////////////////////////////////////////////////////////
simulated function bool PawnIsInRange(pawn P)
{
	if ( Vsize(P.Location - PawnOwner.Location) > 4096)
		return false;
		
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Determine if pawn is valid
///////////////////////////////////////////////////////////////////////////////
simulated function bool PawnIsValid(vector vecPawnView, vector X, pawn P)
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Draw info for specified pawn
///////////////////////////////////////////////////////////////////////////////
simulated function DrawPawnInfo(Canvas canvas, float screenX, float screenY, pawn P);

///////////////////////////////////////////////////////////////////////////////
// Draw percentage bar
///////////////////////////////////////////////////////////////////////////////
simulated function DrawPercBar(Canvas Canvas, float ScreenX, float ScreenY, float Width, float Height, float Border, Color Fore, float Perc)
{
	local float InnerWidth;
	local float InnerHeight;

	Canvas.Style = ERenderStyle.STY_Alpha;

	Canvas.SetPos(ScreenX - (Width/2), ScreenY);
	Canvas.SetDrawColor(0,0,0,byte(float(Fore.A)*0.75));
	if (Canvas.DrawColor.A > 0)
		Canvas.DrawRect(Texture'engine.WhiteSquareTexture', Width, Height);

	InnerWidth = Width - 2 * Border;
	InnerHeight = Height - 2 * Border;

	Canvas.SetPos(ScreenX - (InnerWidth/2), ScreenY + Border);
	Canvas.DrawColor = Fore;
	if (Canvas.DrawColor.A > 0)
		Canvas.DrawRect(Texture'engine.WhiteSquareTexture', InnerWidth * Perc, InnerHeight);
}
	
///////////////////////////////////////////////////////////////////////////////
// Draw message when local player is dead
///////////////////////////////////////////////////////////////////////////////
simulated function DrawDeadMessage(canvas Canvas)
{
}

///////////////////////////////////////////////////////////////////////////////
// Draw message when viewing from another player
///////////////////////////////////////////////////////////////////////////////
simulated function DrawViewFrom(canvas Canvas, PlayerReplicationInfo FromPRI, float Y)
{
	local float XL, YL;
	local string str;

	Canvas.Font = MyFont.GetFont(2, false, Canvas.ClipX);
	Canvas.bCenter = true;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = MpScoreboard(Scoreboard).GeneralTextColor;
	str = ViewFrom$FromPRI.PlayerName;
	Canvas.StrLen(str, XL, YL);
	Canvas.SetPos(0, Y - YL);
	MyFont.DrawText(Canvas, str);
}

///////////////////////////////////////////////////////////////////////////////
// Draw weapon name
///////////////////////////////////////////////////////////////////////////////
/*simulated function DrawWeaponName(canvas Canvas)
{
	local float XL, YL, YPos;

	if ( (PawnOwner !=None) && (Canvas.ClipY > 300) )
	{
		// draw weapon name when it changes
		YPos = Canvas.ClipY - 48;
		Canvas.Font = MyFont.GetFont(2, true, Canvas.ClipX);
		Canvas.Style=ERenderStyle.STY_Translucent;
		Canvas.bCenter = false;
		if ( PawnOwner.PendingWeapon != None )
		{
			WeaponFadeTime = Level.TimeSeconds + 1.0;
			Canvas.DrawColor = PawnOwner.PendingWeapon.NameColor;
			Canvas.StrLen( PawnOwner.PendingWeapon.ItemName, XL, YL );
			Canvas.SetPos(0.5 * (Canvas.ClipX - XL), YPos);
			Canvas.DrawText(PawnOwner.PendingWeapon.ItemName, False);
		}
		else if ( (WeaponFadeTime > Level.TimeSeconds) && (PawnOwner.Weapon != None) )
		{
			Canvas.DrawColor = PawnOwner.Weapon.NameColor;
			if ( WeaponFadeTime - Level.TimeSeconds < 1 )
				Canvas.DrawColor = Canvas.DrawColor * (WeaponFadeTime - Level.TimeSeconds);
			Canvas.StrLen( PawnOwner.Weapon.ItemName, XL, YL );
			Canvas.SetPos(0.5 * (Canvas.ClipX - XL), YPos);
			Canvas.DrawText(PawnOwner.Weapon.ItemName, False);
		}
	}
}*/

///////////////////////////////////////////////////////////////////////////////
// Notify player of remaining time when it reaches certain points
///////////////////////////////////////////////////////////////////////////////
simulated function NotifyRemainingTime()
{
	if ( (PlayerOwner.GameReplicationInfo != None) && (PlayerOwner.GameReplicationInfo.RemainingTime > 0) ) 
	{
		if ( (PlayerOwner.GameReplicationInfo.RemainingTime <= 300)
		  && (PlayerOwner.GameReplicationInfo.RemainingTime != LastReportedTime) )
		{
			LastReportedTime = PlayerOwner.GameReplicationInfo.RemainingTime;
			if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 30 )
			{
				bTimeValid = ( bTimeValid || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) );	
				if ( PlayerOwner.GameReplicationInfo.RemainingTime == 30 )
					TellTime(30);
				else if ( bTimeValid && PlayerOwner.GameReplicationInfo.RemainingTime <= 10 )
					TellTime(PlayerOwner.GameReplicationInfo.RemainingTime);
			}
			else if ( PlayerOwner.GameReplicationInfo.RemainingTime % 60 == 0 )
				TellTime(PlayerOwner.GameReplicationInfo.RemainingTime);
		}
	}
}

simulated function TellTime(int num)
{
	PlayerOwner.ReceiveLocalizedMessage( TimeMessageClass, Num );
}



///////////////////////////////////////////////////////////////////////////////
// Draw flags for ctf game
///////////////////////////////////////////////////////////////////////////////
simulated function DrawRadarFlags(canvas Canvas, float radarx, float radary)
{
	local float dist;
	local float pheight, iconsize, fishx, fishy;
	local vector radarf;
	local int i;
	local vector dir;

	// Show flags on radar too (only 2 flags)
	for(i = 0; i<2; i++)
	{
		if(CTFGameReplicationInfo(OurPlayer.GameReplicationInfo) != None)
		{
			// convert 3d world coords to around the player in the radar coords
			radarf = OurPlayer.GameReplicationInfo.FlagPos[i];
			dir = radarf - PawnOwner.Location;
			pheight = dir.z;
			
			CalcRadarDists(true, dir, dist);

			// if the flag is outside the radius, draw it at the max--special
			// for flags
			if(dist > MP_RADAR_RADIUS)
				dist = MP_RADAR_RADIUS;
			// If you're within the appropriate radius from the player, be drawn
			RadarFindFishLoc(dist, Scale, pheight, true, dir, fishx, fishy, iconsize);
			Canvas.SetPos(radarx + fishx, radary + fishy);
			Canvas.Style = ERenderStyle.STY_Normal;

			// red flag/blue flag
			if(i == 0) // 0 == red
				Canvas.DrawColor = RedColor;
			else // 1 == blue
				Canvas.DrawColor = BlueColor;

			// Draw the fish/flag/girl
			Canvas.DrawIcon(RadarNPC, iconsize);

			Canvas.Style = ERenderStyle.STY_Alpha;
			Canvas.DrawColor = WhiteColor;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	IdentityFadeDuration=1.0
	IdentityInfoPY=0.55
	IdentityHealthPW=0.060
	IdentityHealthPH=0.004
	IdentityBorderPS=0.001

	ViewFrom="Tracking "
	LoadOutMessage="Your next character:"
	LoadOutCycle=" (F7 cycles)"

	TimeMessageClassName="MultiGame.TimeMessage"
	BlinkDir=+2.0

	FontInfoClass="FPSGame.FontInfo"
    SmallFont=Font'Engine.SmallFont'
    MedFont=font'P2Fonts.Plain24'
    BigFont=font'P2Fonts.Plain30'
    LargeFont=font'P2Fonts.Plain38'
//	ScoreWindow=Texture'MpHUD.FragsWindow'
	ScoreWindow=Texture'nathans.Inventory.bloodsplat-1'
	MessageWindow=Texture'MpHUD.MessageWindow'

	RankingText(0)="1st"
	RankingText(1)="2nd"
	RankingText(2)="3rd"
	RankingText(3)="4th"
	RankingText(4)="5th"
	RankingText(5)="6th"
	RankingText(6)="7th"
	RankingText(7)="8th"
	RankingText(8)="9th"
	RankingText(9)="10th"
	RankingText(10)="11th"
	RankingText(11)="12th"
	RankingText(12)="13th"
	RankingText(13)="14th"
	RankingText(14)="15th"
	RankingText(15)="16th"
	RankingBlinkDuration=2.0

	OwnScoreWindowPX=0.01
	OwnScoreWindowPY=0.01
	OwnScoreWindowPW=0.08
	OwnScoreInfoPY=0.05
	OwnScoreRankPX=0.5;
//	OwnScoreScorePX=0.166	// 1/6
//	OwnScoreKillsPX=0.500	// 3/6
//	OwnScoreDeathsPX=0.833	// 5/6

	// Console messages -- near bottom left corner
	CategoryFormats(0)=(XP=0.02,YP=0.94,HAlign=THA_Left,VAlign=TVA_Bottom,Stack=TS_Up,FontSize=1,bPlainFont=false)
	// Default messages -- not expected in multiplayer but define just in case
	CategoryFormats(1)=(XP=0.02,YP=0.50,HAlign=THA_Left,VAlign=TVA_Bottom,Stack=TS_None,FontSize=0,bPlainFont=false);
	// Pickup messages -- bottom left corner
	CategoryFormats(2)=(XP=0.02,YP=0.97,HAlign=THA_Left,VAlign=TVA_Bottom,Stack=TS_None,FontSize=1,bPlainFont=false);
	// Critical messages -- top center
	CategoryFormats(3)=(XP=0.00,YP=0.13,HAlign=THA_Center,VAlign=TVA_Top,Stack=TS_Down,FontSize=2,bPlainFont=false);
	// Startup messages -- lower center
	CategoryFormats(4)=(XP=0.00,YP=0.75,HAlign=THA_Center,VAlign=TVA_Top,Stack=TS_Down,FontSize=2,bPlainFont=false);
}
