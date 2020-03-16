///////////////////////////////////////////////////////////////////////////////
// ErrandGoalUseUpInventory
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Errand Goal that requires the dude use up all of a specified item
///////////////////////////////////////////////////////////////////////////////
class ErrandGoalUseUpInventory extends ErrandGoal;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var() Name	InvClassName;		// Class of item we want to trigger the end of the errand
var() bool	bAllowSubclass;		// True if subclasses of this item can also trigger the errand

///////////////////////////////////////////////////////////////////////////////
// Returns true if this is a class we care about
///////////////////////////////////////////////////////////////////////////////
function bool ValidClass(class UseClass)
{
	local Class CheckClass;
	
	CheckClass = Class(DynamicLoadObject(String(InvClassName), class'Class'));
	if (UseClass == CheckClass
		|| (bAllowSubclass && ClassIsChildOf(UseClass, CheckClass)))
		return true;
		
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check to see if this errand is done
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCompletion(Actor Other, Actor Another, Pawn ActionPawn)
{
	local P2PowerupInv pcheck;
	
	pcheck = P2PowerupInv(Other);
	
	// If there are no more left, the errand is complete
	if (pcheck != None		
		&& ValidClass(Other.Class)
		&& pcheck.Amount <= 0)
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check if Other is used by an errand
///////////////////////////////////////////////////////////////////////////////
function bool CheckForErrandUse(Actor Other)
{
	if(ValidClass(Other.Class))
		return true;

	return false;
}

defaultproperties
{
}
