class ACTION_WaitForTimerVariable extends LatentScriptedAction;

var(Action) float MinPauseTime;
var(Action) float MaxPauseTime;

function bool InitActionFor(ScriptedController C)
{
	local float PauseTime;

	PauseTime = MinPauseTime + FRand() * (MaxPauseTime - MinPauseTime);

    C.CurrentAction = self;
	C.SetTimer(PauseTime, false);
	return true;
}

function bool CompleteWhenTriggered()
{
	return true;
}

function bool CompleteWhenTimer()
{
	return true;
}

function string GetActionString()
{
	return "";
}

defaultproperties
{
     ActionString="Wait for timer"
}
