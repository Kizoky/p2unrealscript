class ACTION_SetViewTarget extends ScriptedAction;

var(Action) name ViewTargetTag;
// why? - K
//var transient Actor ViewTarget;

function bool InitActionFor(ScriptedController C)
{
	local Actor ViewTarget;
	
	if ( ViewTargetTag == 'Enemy' )
		C.ScriptedFocus = C.Enemy;
	else if ( (ViewTargetTag == 'None') || (ViewTargetTag == '') )
		C.ScriptedFocus = None;
	else
		{
		if ( (ViewTarget == None) && (ViewTargetTag != 'None') )
			ForEach C.AllActors(class'Actor',ViewTarget,ViewTargetTag)
				break;

		if ( ViewTarget == None )
		{
			// Disabled this, FUCK THE BROKEN FLAG
			//warn(C@"is BROKEN in ACTION_SetViewTarget!! Reason: ViewTarget was None!");
			//C.bBroken = true;
			return false;
		}
		C.ScriptedFocus = ViewTarget;
		}
	return false;	
}

function String GetActionString()
{
	return ActionString@ViewTargetTag;
}

defaultproperties
{
	ActionString="set viewtarget"
	bValidForTrigger=false
}
	
