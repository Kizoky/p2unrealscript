///////////////////////////////////////////////////////////////////////////////
// ErrandGoalCompleteSuberrands
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// This errand has no goal in of itself, but rather consists of one or more
// "sub-errands" that aren't displayed on the Dude's list, but on the map.
// Used for the get A/C parts errand
///////////////////////////////////////////////////////////////////////////////
class ErrandGoalCompleteSuberrands extends ErrandGoal;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var() array<String> SuberrandName;	// Array of suberrands to complete

///////////////////////////////////////////////////////////////////////////////
// Check to see if this errand is done
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCompletion(Actor Other, Actor Another, Pawn ActionPawn)
{
	local int i;	
	local P2GameInfoSingle psg;
	
	if (Other != None)
		psg = P2GameInfoSingle(Other.Level.Game);
	else if (Another != None)
		psg = P2GameInfoSingle(Another.Level.Game);
	else if (ActionPawn != None)
		psg = P2GameInfoSingle(ActionPawn.Level.Game);
	else
		warn(self@"COULD NOT GET VALID LEVEL INFO!!!!!");
	
	for (i = 0; i < SuberrandName.Length; i++)
	{
		log(self@"check if"@SuberrandName[i]@"completed");
		// When checking for this errand, ActionPawn will be the player.
		if (!psg.IsErrandCompleted(SuberrandName[i]))
			return false;
	}

	return true;
}

defaultproperties
{
}
