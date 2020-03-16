///////////////////////////////////////////////////////////////////////////////
// Action
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_MoveToPoint extends LatentScriptedAction;

var(Action) name DestinationTag;	// tag of destination - if none, then use the ScriptedSequence
var(Action) bool bLookAtDestination;// true if we want to focus on the destination
var transient Actor Movetarget;

function bool InitActionFor(ScriptedController C)
{
	local Actor ViewTarget;
	
	if (bLookAtDestination)
	{
		if ( DestinationTag == 'Enemy' )
			C.ScriptedFocus = C.Enemy;
		else if ( (DestinationTag == 'None') || (DestinationTag == '') )
			C.ScriptedFocus = None;
		else
			{
			if ( (ViewTarget == None) && (DestinationTag != 'None') )
				ForEach C.AllActors(class'Actor',ViewTarget,DestinationTag)
					break;

			if ( ViewTarget == None )
			{
				// Disabled this, FUCK THE BROKEN FLAG
				//warn(C@"is BROKEN in ACTION_MoveToPoint!! Reason: ViewTarget == None and bLookAtDestination was True!!");
				//C.bBroken = true;
				return false;
			}
			C.ScriptedFocus = ViewTarget;
			}
	}
	return Super.InitActionFor(C);
}

function bool MoveToGoal()
{
	return true;
}

function Actor GetMoveTargetFor(ScriptedController C)
{
	if ( Movetarget != None )
		return MoveTarget;

	MoveTarget = C.SequenceScript.GetMoveTarget();
	if ( (DestinationTag != 'None') && (DestinationTag != '') )
		{
		ForEach C.AllActors(class'Actor',MoveTarget,DestinationTag)
			break;
		}
	if ( AIScript(MoveTarget) != None )
		MoveTarget = AIScript(MoveTarget).GetMoveTarget();
	return MoveTarget;
}


function string GetActionString()
{
	return ActionString@DestinationTag;
}

defaultproperties
{
	ActionString="Move to point"
	bValidForTrigger=false
}