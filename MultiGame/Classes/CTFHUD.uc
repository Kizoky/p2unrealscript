///////////////////////////////////////////////////////////////////////////////
// CTFHUD.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Adds CTF elements to our team HUD.
//
///////////////////////////////////////////////////////////////////////////////
class CTFHUD extends TeamHUD;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var Texture						FlagIcons[4];
var float						FlagIconPX;
var float						FlagIconPY;
var float						FlagIconPW;


///////////////////////////////////////////////////////////////////////////////
// Setup
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, true);
}

///////////////////////////////////////////////////////////////////////////////
// Timer updates
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	Super.Timer();

    if ( (PawnOwnerPRI == None) 
		|| (PlayerOwner.IsSpectating() && (PlayerOwner.bBehindView || (PlayerOwner.ViewTarget == PlayerOwner))) )
        return;

	if ( PawnOwnerPRI.HasFlag != None )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFMessage2', 0);

	if ( (PlayerOwner.GameReplicationInfo != None)
		&& (PlayerOwner.GameReplicationInfo.FlagState[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex] == EFlagState.FLAG_HeldEnemy) )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFMessage2', 1);
}

///////////////////////////////////////////////////////////////////////////////
// Draw team game info
///////////////////////////////////////////////////////////////////////////////
simulated function DrawTeamGameInfo(Canvas Canvas, TeamInfo TI, int team, float CenterX, float Y, float W, float H)
{
	local CTFFlag Flag;
	local float IconSize;
	local Texture Icon;
	local float Scale;
	local float NewX, NewW;

	Super.DrawTeamGameInfo(Canvas, TI, team, CenterX, Y, W, H);

	if (PlayerOwner.GameReplicationInfo != None)
	{
		Icon = FlagIcons[PlayerOwner.GameReplicationInfo.FlagState[team]];

		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = WhiteColor;

		IconSize = FlagIconPW * Canvas.ClipX;
		NewX = CenterX + (W * FlagIconPX * TeamMirrorX[team]) - IconSize/2;
		Scale = IconSize / Icon.USize;
		NewW = Icon.USize * Scale;
		if (team == 1)
		{
			NewX += NewW;
			NewW = -NewW;
		}
		Canvas.SetPos(NewX, Y + H * FlagIconPY - IconSize/2);
		Canvas.DrawTile( Icon, NewW, Icon.VSize*Scale, 0, 0, Icon.USize, Icon.VSize );
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	FlagIcons(0)=texture'MpHUD.FlagHome'
	FlagIcons(1)=texture'MpHUD.FlagCaptured'
	FlagIcons(2)=texture'MpHUD.FlagCaptured'
	FlagIcons(3)=texture'MpHUD.FlagDown'

	FlagIconPX=-0.35
	FlagIconPY=0.40
	FlagIconPW=0.04

	bHideOwnScore=true
}
