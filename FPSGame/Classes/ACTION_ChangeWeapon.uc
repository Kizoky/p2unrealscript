class ACTION_ChangeWeapon extends LatentScriptedAction;

var(Action) class<Weapon> NewWeapon;	// Class of weapon to switch to
var(Action) bool bWaitUntilReady;		// If true, don't advance to the next action until the new weapon is up and ready
var(Action) bool bSwitchToHands;		// If true, switches to hands instead of the specified weapon

const HANDS_WEAPON_GROUP = 0;

function bool TickedAction()
{
	return bWaitUntilReady;
}

function bool StillTicking(ScriptedController C, float DeltaTime)
{
	// Don't bother if we're not using this
	if (!bWaitUntilReady)
		return false;
		
	if (C.Pawn.Weapon.IsInState('Idle'))
	{
		// There's no way to force an action completion, so we just do it here manually. Fuck the police >:O
		C.CurrentAction = None;
		C.ActionNum++;
		C.GotoState('Scripting','Begin');
		return false;
	}
	else
		return true;
}

function bool InitActionFor(ScriptedController C)
{
	local Weapon SwitchedWeapon;
	local Inventory Inv;
	local int BestOffset;
	
	// Get hands class as defined by the pawn.
	if ((NewWeapon == None || bSwitchToHands) && FPSPawn(C.Pawn) != None)
		SwitchedWeapon = Weapon(C.Pawn.FindInventoryType(FPSPawn(C.Pawn).GetHandsClass()));

	if (SwitchedWeapon == None)
		SwitchedWeapon = Weapon(C.Pawn.FindInventoryType(newWeapon));
		
	C.Log(C.Pawn@"switching to weapon"@SwitchedWeapon);

	// Mark script as broken if the weapon doesn't exist
	if (SwitchedWeapon == None)
	{
		// Disabled this, FUCK THE BROKEN FLAG
		//warn(C@"is BROKEN in ACTION_ChangeWeapon!! Reason: Target weapon"@NewWeapon@"does not exist!!");
		//C.bBroken = true;
		return false;
	}	
	
	C.Pawn.PendingWeapon = SwitchedWeapon;
	C.Pawn.ChangedWeapon();
	
	if (bWaitUntilReady)
		C.CurrentAction = self;

	return bWaitUntilReady;
}

defaultproperties
{
	ActionString="Change Weapon"
	bWaitUntilReady=false
}