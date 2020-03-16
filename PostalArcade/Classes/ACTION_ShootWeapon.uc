class ACTION_ShootWeapon extends LatentScriptedAction;

var(Action) bool bPrimaryFire;
var(Action) bool bMustBeVisable;
var(Action) bool bAvoidsShootingPlayer;
var(Action) name AvoidTag;

var Actor AvoidActor;

function bool InitActionFor(ScriptedController C)
{
    local vector HitLocation, HitNormal, StartTrace, EndTrace;
    local rotator EnemyDir;
    local Actor Other;

    if (C.Pawn.Weapon == None)
        return false;

    if (AvoidTag != 'None' || AvoidTag != '')
        foreach C.AllActors(class'Actor', AvoidActor, AvoidTag)
            break;

    StartTrace = C.Pawn.Location + C.Pawn.EyePosition();

    if (C.ScriptedFocus != None)
        EndTrace = C.ScriptedFocus.Location;
    else
        EndTrace = StartTrace + vector(C.Pawn.GetViewRotation());

    EnemyDir = rotator(EndTrace - StartTrace);
    Other = C.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

    if (Other != None)
    {
        if (bAvoidsShootingPlayer && Pawn(Other) != None && Pawn(Other).Controller.bIsPlayer)
            return false;

        if (bMustBeVisable && Other != None && Other != C.ScriptedFocus && !Other.IsA('KActor') && !Other.IsA('Pawn'))
            return false;

        if ((AvoidTag != 'None' || AvoidTag != '') && AvoidActor != None && Other == AvoidActor)
            return false;
    }

    C.Pawn.Weapon.SetRotation(EnemyDir);

    if (bPrimaryFire)
        C.Pawn.Weapon.Fire(1);
    else
        C.Pawn.Weapon.AltFire(1);

    return false;
}

defaultproperties
{
     bPrimaryFire=True
     bMustBeVisable=True
     bAvoidsShootingPlayer=True
     ActionString="Shoot Weapon"
}
