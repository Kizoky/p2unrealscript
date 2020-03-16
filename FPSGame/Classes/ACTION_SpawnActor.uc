class ACTION_SpawnActor extends ScriptedAction;

var(Action)		class<Actor>	ActorClass;
var(Action)		vector			LocationOffset;
var(Action)		rotator			RotationOffset;
var(Action)		bool			bOffsetFromScriptedPawn;
var(Action)		name			ActorTag;
var(Action)		name			ActorEvent;

function bool InitActionFor(ScriptedController C)
{
	local vector loc;
	local rotator rot;
	local actor a;

	if ( bOffsetFromScriptedPawn )
	{
		loc = C.Pawn.Location + LocationOffset;
		rot = C.Pawn.Rotation + RotationOffset;
	}
	else
	{
		loc = C.SequenceScript.Location + LocationOffset;
		rot = C.SequenceScript.Rotation + RotationOffset;
	}
	a = C.Spawn(ActorClass,,,loc,rot);
	a.Instigator = C.Pawn;
	if ( ActorTag != 'None' )
		a.Tag = ActorTag;
	if (ActorEvent != 'None')
		a.Event = ActorEvent;
	return false;	
}

function string GetActionString()
{
	return ActionString@ActorClass;
}

defaultproperties
{
	ActionString="Spawn actor"
}
