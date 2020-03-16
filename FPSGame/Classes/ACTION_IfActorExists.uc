///////////////////////////////////////////////////////////////////////////////
// ACTION_IfActorExists
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Scripted action that checks for the existence of a particular actor
// class and/or tag. If found, executes the next action, otherwise skips to
// end of section.
///////////////////////////////////////////////////////////////////////////////
class ACTION_IfActorExists extends ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var(Action) class<Actor> ActorClass;		// Optional. Specifies class of actor to search for.
var(Action) Name ActorTag;					// Required. Specifics tag of actor to search for.

function ProceedToNextAction(ScriptedController C)
{
	local Actor A;
	local class<Actor> UseClass;
	
	if (ActorClass == None)
		UseClass = class'Actor';
	else
		UseClass = ActorClass;
		
	foreach C.AllActors(UseClass, A, ActorTag)
		break;
		
	C.ActionNum += 1;
	if (A == None)
		ProceedToSectionEnd(C);
}

function bool StartsSection()
{
	return true;
}

function string GetActionString()
{
	return ActionString@ActorClass@ActorTag;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActionString="If exists"
}