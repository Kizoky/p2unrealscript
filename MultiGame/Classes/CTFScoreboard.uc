///////////////////////////////////////////////////////////////////////////////
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// CTF version of team scoreboard
//
///////////////////////////////////////////////////////////////////////////////
class CTFScoreBoard extends TeamScoreBoard;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var float						FlagHolderIconPX;	// Position of flag
var float						FlagHolderIconPW;	// Width of flag

var localized string			CTFHints[48];
var const int					CTFHintMax;


///////////////////////////////////////////////////////////////////////////////
// Add our hints to pool of hints
// Returns the number of game-specific hints that were added.
///////////////////////////////////////////////////////////////////////////////
function int AddHints()
{
	local int i;
	local int existing;

	// This is written to allow this class to be extended and to have the
	// extended class add additional game-specific hints before calling this.
	existing = AllHints.length;
	for (i = 0; i < CTFHintMax; i++)
	{
		AllHints.insert(existing + i, 1);
		AllHints[existing + i] = CTFHints[i];
	}
	i = AllHints.length;

	Super.AddHints();

	return i;
}

///////////////////////////////////////////////////////////////////////////////
// Add flag stuff onto player info
///////////////////////////////////////////////////////////////////////////////
function DrawPlayerInfo(Canvas Canvas, MpPlayerReplicationInfo PRI, float X, float Y)
{
	local Texture Icon;
	local float Scale, W, H;
	local int Team, OtherTeam;

	Super.DrawPlayerInfo(Canvas, PRI, X, Y);

	Team = PRI.Team.TeamIndex;
	if (Team == 0)
		OtherTeam = 1;

	// If this player has the flag then draw team logo next to his name
	if ( (GRI.FlagState[OtherTeam] != EFlagState.FLAG_Home) && (GRI.FlagState[OtherTeam] != EFlagState.FLAG_Down) )
	{
		if ( (PRI.HasFlag != None) || (PRI == GRI.FlagHolder[Team]))
		{
			Icon = PRI.Team.TeamIcon;
			W = FlagHolderIconPW * Canvas.ClipX;
			Scale = W / Icon.USize;
			H = Icon.VSize * Scale;
			Canvas.DrawColor = WhiteColor;
			Canvas.Style = ERenderStyle.STY_Alpha;
			Canvas.SetPos(X + (FlagHolderIconPX * Canvas.ClipX) - (W/2), Y + (PlayerWindowH - H) / 2);
			Canvas.DrawIcon(Icon, Scale);
		}
	}
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	FlagHolderIconPX=0.01
	FlagHolderIconPW=0.04

	ScoreGoalString="Capture Limit:"

	CTFHints[0]="Snatch the enemy's Babe and get her"
	CTFHints[1]="in bed with your own Babe to score!"

	CTFHints[2]="Try storming the enemy base in a group"
	CTFHints[3]="to increase your chances!"

	CTFHints[4]="Litter your base with grenade traps"
	CTFHints[5]="for protection and early alerts!"

	CTFHints[6]="Use the fish finder radar to find out"
	CTFHints[7]="where the Babes are!"

	CTFHints[8]="Drop cowheads around your Babe to injure"
	CTFHints[9]="those trying to snatch her!"

	CTFHints[10]="Try to keep at least one person guarding"
	CTFHints[11]="your Babe at all times."

	CTFHints[12]="Use cowheads to hinder movement through"
	CTFHints[13]="important chokepoints!"
	// UPDATE ME!!!
	CTFHintMax=14
}
