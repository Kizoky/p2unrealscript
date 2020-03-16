class ACTION_TeleportToPoint extends LatentScriptedAction;

var(Action) name DestinationTag;	// tag of destination - if none, then use the ScriptedSequence

function bool InitActionFor(ScriptedController C)
{
	local Actor Dest;
	local Pawn P;
	Dest = C.SequenceScript.GetMoveTarget();

	if ( (DestinationTag != 'None') && (DestinationTag != '') )
	{
		ForEach C.AllActors(class'Actor',Dest,DestinationTag)
			break;
	}
	P = C.GetInstigator();
	P.SetLocation(Dest.Location);
	P.SetRotation(Dest.Rotation);
	P.OldRotYaw = P.Rotation.Yaw;
	return false;	
}

defaultproperties
{
	ActionString="TeleportToPoint"
}