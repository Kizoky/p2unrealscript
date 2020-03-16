///////////////////////////////////////////////////////////////////////////////
// ACTION_AttachActor
// Attaches one actor to another
///////////////////////////////////////////////////////////////////////////////
class ACTION_AttachActor extends ScriptedAction;

var() name RiderTag;			// Tag of actor to attach
var() name TargetTag;			// Tag of target actor to attach to
var() name TargetBone;			// Bone of target actor to attach to
var() vector RelativeLocation;
var() rotator RelativeRotation;

// Currently this immediately attaches the source pawn to the target
// (No animation or other handling is performed)

function bool InitActionFor(ScriptedController C)
{
	local Actor RiderActor, TargetActor;

	foreach C.AllActors(class'Actor', RiderActor, RiderTag)
		break;
		
	foreach C.AllActors(class'Actor', TargetActor, TargetTag)
		break;
		
	if (RiderActor == None)
		warn(self@"could not find a rider! ====================================");
	else if (TargetActor == None)
		warn(self@"could not find a target! ===================================");
	else if (TargetBone == '')
		warn(self@"no bone defined for attachment! ============================");
	else
	{
		if (!TargetActor.AttachToBone(RiderActor, TargetBone))
			warn(self@"failed to attach"@RiderActor@"to"@TargetActor@"at"@TargetBone@"! ==================");
		else
		{
			RiderActor.SetRelativeLocation(RelativeLocation);
			RiderActor.SetRelativeRotation(RelativeRotation);
		}
	}
	
	return false;
}

defaultproperties
{
	ActionString="attach to"
}