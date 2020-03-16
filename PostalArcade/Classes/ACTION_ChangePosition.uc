class ACTION_ChangePosition extends LatentScriptedAction;

var/*(Action)*/ bool bShootWhileMove;		// Not functional
var(Action) bool bFacePath;					// Whether we should face our destination
var(Action) float MoveChance;				// Chance to actually move, from 0.0 (no chance) to 1.0 (guaranteed).
var(Action) array<name> DestinationTags;	// Picks a random destination from these points.

var name DestinationTag;
var Actor MoveTarget;
var transient Pawn MyPawn;
var bool bDeterminedDestination;

function bool MoveToGoal()
{
    bDeterminedDestination = false;

    //if (bShootWhileMove && MyPawn != None && MyPawn.Weapon.IsA('MachineGunWeapon_Partner'))
        //MachineGunWeapon_Partner(MyPawn.Weapon).SetAutoFire(false);

    return true;
}

function Actor GetMoveTargetFor(ScriptedController C)
{
	if (MyPawn == None)
        MyPawn = C.Pawn;

    if (FRand() > MoveChance)
	{
	    MoveTarget = C.Pawn;

        return MoveTarget;
    }

    if (bFacePath)
        C.ScriptedFocus = None;

    if (!bDeterminedDestination)
	{
        //if (bShootWhileMove && MyPawn != None && MyPawn.Weapon.IsA('MachineGunWeapon_Partner'))
	        //MachineGunWeapon_Partner(MyPawn.Weapon).SetAutoFire(true, C.ScriptedFocus);

        DestinationTag = DestinationTags[Rand(DestinationTags.length)];
        bDeterminedDestination = true;
    }

	if ((DestinationTag != 'None') && (DestinationTag != ''))
	{
		foreach C.AllActors(class'Actor', MoveTarget, DestinationTag)
			break;
	}

	if (AIScript(MoveTarget) != None)
		MoveTarget = AIScript(MoveTarget).GetMoveTarget();

	return MoveTarget;
}


function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
     bFacePath=True
     MoveChance=1.000000
     ActionString="Move to point"
     bValidForTrigger=False
}
