class ACTION_FindTarget extends ScriptedAction;

var(Action) bool bRandomize;
var(Action) array<name> TargetTag;

var int TargetIndex;
var transient Pawn Target;

function bool InitActionFor(ScriptedController C)
{
    local int i;

    C.ScriptedFocus = None;
    Target = None;

    /*
    log("Target Index: " $ string(TargetIndex));
    log("Targets:");

    if (TargetTag.length > 0)
        for (i=0;i<TargetTag.length;i++)
            log("Target: " $ string(TargetTag[i]));
    */

    if (TargetTag.length > 0)
    {
        if (bRandomize)
            TargetIndex = Rand(TargetTag.length);

        if (TargetTag[TargetIndex] == 'Player')
            C.ScriptedFocus = C.GetMyPlayer();
        else if (TargetTag[TargetIndex] == 'Enemy')
		    C.ScriptedFocus = C.Enemy;
	    else if ((TargetTag[TargetIndex] == 'None') || (TargetTag[TargetIndex] == ''))
		    C.ScriptedFocus = None;
	    else
	    {
		    if ((Target == None) && (TargetTag[TargetIndex] != 'None'))
			    foreach C.AllActors(class'Pawn', Target, TargetTag[TargetIndex])
				    break;

		    //if (Target == None)
			    //C.bBroken = true;

            C.ScriptedFocus = Target;
        }

        if (TargetTag.length > 0)
            TargetTag.Remove(TargetIndex, 1);

        if (Target == None)
            InitActionFor(C);
    }

    return false;
}

function ProceedToNextAction(ScriptedController C)
{
    if (Target == None && TargetTag.length == 0)
        C.ActionNum += 5;
    else if (Target != None && Target.Health > 0)
        C.ActionNum++;
    else
        C.ActionNum += 3;
}

function String GetActionString()
{
	return ActionString@TargetTag[TargetIndex];
}

defaultproperties
{
     ActionString="set target "
     bValidForTrigger=False
}
