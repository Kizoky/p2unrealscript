///////////////////////////////////////////////////////////////////////////////
// ACTION_ChangeTag
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Changes one of more actor's Tag values to something else.
///////////////////////////////////////////////////////////////////////////////
class ACTION_ChangeTag extends P2ScriptedAction;

var(Action) name ChangeFrom;	// Tags of actors you want to change. If left blank, changes the pawn's own tag (the one controlled by the scripted sequence)
var(Action) name ChangeTo;		// Tag you want to change to.

function bool InitActionFor(ScriptedController C)
{
	local Actor A;
	if (ChangeFrom != '')
	{
		foreach C.AllActors(class'Actor', A, ChangeFrom)
			A.Tag = ChangeTo;
	}
	else if (C.Pawn != None)
		C.Pawn.Tag = ChangeTo;
	else
		warn("Attempted to change no pawn's tag!");
	return false;
}

function string GetActionString()
{
	if (ChangeFrom == '')
		return ActionString@"Change own pawn's tag to '"$ChangeTo$"'";
	else
		return ActionString@"Change all '"$ChangeFrom$"' to '"$ChangeTo$"'";
}
	
defaultproperties
{
	ActionString="Change pawn tags: "
}
