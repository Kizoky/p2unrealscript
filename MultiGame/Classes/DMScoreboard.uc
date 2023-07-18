///////////////////////////////////////////////////////////////////////////////
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Deathmatch version of multiplayer scoreboard.
//
///////////////////////////////////////////////////////////////////////////////
class DMScoreBoard extends MpScoreBoard;


var localized string			DMHints[48];
var const int					DMHintMax;


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
	for (i = 0; i < DMHintMax; i++)
	{
		AllHints.insert(existing + i, 1);
		AllHints[existing + i] = DMHints[i];
	}
	i = AllHints.length;

	Super.AddHints();

	return i;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	DMHints[0]="Deaths count against your score."
	DMHints[1]="Try to stay alive as long as possible!"

	MpHints[2]="It takes 2 pistol headshots to kill someone will full health,"
	MpHints[3]="or 3 if they just used a health pipe."

	DMHints[4]="It takes 6 machinegun headshots to kill someone will full health,"
	DMHints[5]="or 8 if they just used a health pipe."

	DMHints[6]="Shotguns are not very effective at long distances."
	DMHints[7]=""
	// UPDATE ME!!!
	DMHintMax=8
}
