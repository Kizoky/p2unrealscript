///////////////////////////////////////////////////////////////////////////////
// ErrandGoalGiveInventory
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Errand Goal that requires the dude give someone a certain item
//
///////////////////////////////////////////////////////////////////////////////
class ErrandGoalGiveInventory extends ErrandGoal;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var () Name	InvClassName;		// Class of item we want to trigger
								// the end of the errand
var () Name	GiveToMeTag;		// If this is specified, check it to make sure the
								// person you're giving this to, is the right one

///////////////////////////////////////////////////////////////////////////////
// Check to see if this errand is done
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCompletion(Actor Other, Actor Another, Pawn ActionPawn)
{
	local P2PowerupInv pcheck;

	pcheck = P2PowerupInv(Other);

	// As long as someone other than the player is getting this item, then
	// it's over
	if(pcheck != None
		&& ActionPawn != None
		&& ActionPawn.Health > 0	// Must be alive
		&& P2Player(ActionPawn.Controller) == None)
	{
		//log("action pawn "$ActionPawn.Tag);
		//log("give me pawn "$GiveToMeTag);
		// If it's given to the WRONG person, then don't allow the errand to complete
		// but don't bother the actual transaction.
		if(GiveToMeTag != ActionPawn.Tag)
			return false;
		// if the same class
		if(InvClassName != '' && pcheck.IsA(InvClassName))
			return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check if Other is used by an errand
///////////////////////////////////////////////////////////////////////////////
function bool CheckForErrandUse(Actor Other)
{
	if(InvClassName != '' && Other.IsA(InvClassName))
		return true;

	return false;
}


defaultproperties
{
}
