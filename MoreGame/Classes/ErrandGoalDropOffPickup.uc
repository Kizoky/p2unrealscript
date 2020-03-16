///////////////////////////////////////////////////////////////////////////////
// ErrandGoalDropOffPickup
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Errand goal that requires the dude to drop off a certain item in a trigger box
//
///////////////////////////////////////////////////////////////////////////////
class ErrandGoalDropOffPickup extends ErrandGoalGetPickup;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var ()name DropIntoHereTriggerTag;	// This is the trigger that the pickup is to touch
								// that you are throwing

///////////////////////////////////////////////////////////////////////////////
// Check to see if this errand is done
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCompletion(Actor Other, Actor Another, Pawn ActionPawn)
{
	local Pickup pcheck;

	pcheck = Pickup(Other);

	// If the player is throwing it, and if it's hitting the tag of the
	// trigger we want
	if(pcheck != None
		&& ActionPawn != None
		&& P2Player(ActionPawn.Controller) != None
		&& Another != None
		&& Another.Tag == DropIntoHereTriggerTag)
	{
		log(self$" pickup tag "$PickupTag$" pickup class "$PickupClassName$" thing "$Other$" thing class name "$pcheck.class.name$" thing tag "$pcheck.Tag);
		// if the same tag
		if(pcheck.Tag == PickupTag)
			return true;
		// if the same class
		if(PickupClassName != '' && pcheck.IsA(PickupClassName))
			return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check if Other is used by an errand
///////////////////////////////////////////////////////////////////////////////
function bool CheckForErrandUse(Actor Other)
{
//	if(Other.Tag == PickupTag
//		|| Other.ClassIsChildOf(Other.class, PickupClass))
//		return true;

	return false;
}


defaultproperties
{
}
