class ACTION_Piss extends LatentScriptedAction;

var(Action) bool bGonorrhea;
var(Action) float PissTime;
var(Action) bool bWaitUntilFinished;

function bool InitActionFor(ScriptedController C)
{
    local NPCUrethraWeapon Urethra;	 

    Urethra = NPCUrethraWeapon(P2Pawn(C.Pawn).CreateInventoryByClass(Class'NPCUrethraWeapon'));

    Urethra.LeakTime = PissTime;
    Urethra.bGonorrheaPiss = bGonorrhea;
    Urethra.Fire(1);

	if (bWaitUntilFinished)
	{
		C.CurrentAction = self;
		C.SetTimer(PissTime, false);
		return true;
	}

	return false;
}

function bool CompleteWhenTimer()
{
	return bWaitUntilFinished;
}

defaultproperties
{
	ActionString="Piss"
}
