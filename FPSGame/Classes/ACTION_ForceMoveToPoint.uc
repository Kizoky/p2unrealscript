class ACTION_ForceMoveToPoint extends ScriptedAction;

var(Action) name DestinationTag;	// tag of destination - if none, then use the ScriptedSequence
var byte originalPhys;

function bool InitActionFor(ScriptedController C)
{
	local Actor Dest;

	Dest = C.SequenceScript.GetMoveTarget();

	if ( (DestinationTag != 'None') && (DestinationTag != '') )
	{
		ForEach C.AllActors(class'Actor',Dest,DestinationTag)
			break;
	}

	originalPhys = C.Pawn.Physics;

	C.Pawn.SetCollision(False, False, False);
	C.Pawn.bCollideWorld = false;

	//Log("SetLocation:"$Dest.Location);
	C.Pawn.SetLocation(Dest.Location);
	//Log("NewLocation:"$C.Pawn.Location);

	//Log("SetRotation:"$Dest.Rotation);
	C.Pawn.SetRotation(Dest.Rotation);

	C.Pawn.SetPhysics(PHYS_None);

	return false;
}

