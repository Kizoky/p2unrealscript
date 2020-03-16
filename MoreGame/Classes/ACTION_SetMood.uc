class ACTION_SetMood extends ScriptedAction;

var(Action) Actor.EMood Mood;					// Mood to set
var(Action) float Amount;						// How much of this mood to set (0.0-1.0, when in doubt just use 1.0)

function bool InitActionFor(ScriptedController C)
{
	local P2Pawn P;
	
	P = P2Pawn(C.Pawn);
	if (P == None)
		warn(C@"Pawn is missing or not a P2Pawn, cannot setmood");
	else
		P.SetMood(Mood,Amount);
	return false;	
}

function string GetActionString()
{
	return ActionString@Mood;
}

defaultproperties
{
	ActionString="set mood"
	Mood=MOOD_Normal
	Amount=1.0
}
