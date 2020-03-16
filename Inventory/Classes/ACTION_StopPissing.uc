class ACTION_StopPissing extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
    local NPCUrethraWeapon Urethra;	 

    Urethra = NPCUrethraWeapon(P2Pawn(C.Pawn).CreateInventoryByClass(Class'NPCUrethraWeapon'));

    Urethra.ForceEndFire();

	return false;
}

defaultproperties
{
	ActionString="Stop pissing"
}
