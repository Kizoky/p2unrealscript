class ACTION_SetOtherPawnScript extends ScriptedAction;

var(Action)		Name	PawnTag;
var(Action)		Name	ScriptTag;

function bool InitActionFor(ScriptedController C)
	{
	local FPSPawn pawn;

	ForEach C.DynamicActors(class'FPSPawn', pawn, PawnTag)
		break;
	if (pawn != None)
		{
		pawn.AIScriptTag = ScriptTag;
		pawn.CheckForAIScript();
		}
	else
		Warn(self$" can't find FPSPawn with tag '"$PawnTag$"'");

	return false;
	}

defaultproperties
	{
	ActionString="SetOtherPawnScript"
	}