///////////////////////////////////////////////////////////////////////////////
// ACTION_DoorMover
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// For when simply triggering a DoorMover just won't do what you want it to do.
// Now you can make that door do just about anything you want.
///////////////////////////////////////////////////////////////////////////////
class ACTION_DoorMover extends P2ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, structs, etc.
///////////////////////////////////////////////////////////////////////////////
enum EToggleValue
{
	TV_NoChange,			// Does not change value.
	TV_SetFalse,			// Sets toggle to false.
	TV_SetTrue,				// Sets toggle to true.
	TV_ToggleValue			// Sets toggle to the opposite of whatever it currently is
};

/*
var(Action) enum EDoorAction
{
	DA_Nothing,				// Does nothing
	DA_OpenDoor_FromFront,	// Opens door from the front
	DA_OpenDoor_FromBack	// Opens door from the back
} DoorAction;				// Action to take (besides setting values)
*/

var(Action) Name DoorTag;	// Tag of DoorMover(s) to alter.
var(Action) EToggleValue NewLockedFront;
var(Action) EToggleValue NewLockedBack;
var(Action) EToggleValue NewStaysLocked;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{
	local DoorMover D;
	
	foreach C.DynamicActors(class'DoorMover', D, DoorTag)
	{
		if (NewLockedFront == TV_SetFalse)
			D.LockedFront = false;
		if (NewLockedFront == TV_SetTrue)
			D.LockedFront = true;
		if (NewLockedFront == TV_ToggleValue)
			D.LockedFront = !D.LockedFront;
		if (NewLockedBack == TV_SetFalse)
			D.LockedBack = false;
		if (NewLockedBack == TV_SetTrue)
			D.LockedBack = true;
		if (NewLockedBack == TV_ToggleValue)
			D.LockedBack = !D.LockedFront;
		if (NewStaysLocked == TV_SetFalse)
			D.StaysLocked = false;
		if (NewStaysLocked == TV_SetTrue)
			D.StaysLocked = true;
		if (NewStaysLocked == TV_ToggleValue)
			D.StaysLocked = !D.LockedFront;
	}
	
	return false;
}

defaultproperties
{
	ActionString="Door Mover"
}