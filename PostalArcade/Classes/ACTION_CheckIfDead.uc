class ACTION_CheckIfDead extends ScriptedAction;

function ProceedToNextAction(ScriptedController C)
{
    local Pawn Target;

    Target = Pawn(C.ScriptedFocus);

    if (Target != None && Target.Health > 0)
        C.ActionNum -= 3;
    else
    {
        //if (C.Pawn.Weapon.IsA('MachineGunWeapon_Partner'))
            //MachineGunWeapon_Partner(C.Pawn.Weapon).SetAutoFire(false);

        C.ActionNum -= 4;
    }
}

defaultproperties
{
     ActionString="Checked Target if dead"
}
