///////////////////////////////////////////////////////////////////////////////
// ACTION_ResizeActor
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Resizes an actor (usually a pawn) by a certain amount over a certain time
///////////////////////////////////////////////////////////////////////////////
class ACTION_ResizeActor extends P2ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, structs, etc.
///////////////////////////////////////////////////////////////////////////////
var(Action) Name ActorTag;		// Tag of actor(s) to resize
var(Action) float ResizePct;	// How much to scale by (2.0 = double, 0.5 = half etc)
var(Action) float ResizeTime;	// How long we should resize, in seconds

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{
	local Actor A;
	local ResizeHelper Helper;
	
	foreach C.DynamicActors(class'Actor', A, ActorTag)
	{
		Helper = C.Spawn(class'ResizeHelper');
		Helper.Setup(A, ResizePct, ResizeTime);
	}
	
	return false;
}

defaultproperties
{
	ActionString="Resize Actor"
}