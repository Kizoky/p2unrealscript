///////////////////////////////////////////////////////////////////////////////
// ErrandGoalGetInvClass
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Errand Goal that requires the dude get a certain item into his inventory
// Called it this so you don't too easily get it confused with 'GetInventory'
//
///////////////////////////////////////////////////////////////////////////////
class ErrandGoalGetInvClass extends ErrandGoal;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var () Name		InvClassName;		// Inventory class to get

///////////////////////////////////////////////////////////////////////////////
// Check to see if this errand is done
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCompletion(Actor Other, Actor Another, Pawn ActionPawn)
{
	local Inventory invcheck;

	invcheck = Inventory(Other);

	// If it's an inventory item, and of the class we want, we're complete.
	if(invcheck != None
		&& InvClassName != ''
		&& invcheck.IsA(InvClassName))
		return true;

	// something didn't work just write
	return false;
}

defaultproperties
{
}
