///////////////////////////////////////////////////////////////////////////////
// ErrandGoalGetInvClass
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Errand Goal that requires the dude get a certain item into his inventory
// and have it be sold to him by a certain person
//
///////////////////////////////////////////////////////////////////////////////
class ErrandGoalGetInvClassFromPerson extends ErrandGoalGetInvClass;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var ()name TalkToMeTag;			// If the person you're talking to is has
								// this tag, then you're done

///////////////////////////////////////////////////////////////////////////////
// Check to see if this errand is done
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCompletion(Actor Other, Actor Another, Pawn ActionPawn)
{
	local Inventory invcheck;

	invcheck = Inventory(Other);

	if(invcheck != None
		&& InvClassName != ''
		&& invcheck.IsA(InvClassName)
		&& ActionPawn != None
		&& ActionPawn.Health > 0	// Must be alive
		&& ActionPawn.Tag == TalkToMeTag)
		return true;

	// something didn't work just write
	return false;
}

defaultproperties
{
}
