///////////////////////////////////////////////////////////////////////////////
// ACTION_IfPlayerWeaponState.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Executes a section of actions only if the player has the specified weapon out.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_IfPlayerWeaponState extends P2ScriptedAction;

var(Action) class<Weapon> WeaponClass;

function ProceedToNextAction(ScriptedController C)
{
	local bool bResult;
	local P2Player p2p;

	p2p = GetPlayer(C);
	if (p2p != None)
	{
		bResult = (p2p.MyPawn.Weapon.class == WeaponClass);
	}

	C.ActionNum += 1;

	if (!bResult)
		ProceedToSectionEnd(C);
}

function bool StartsSection()
	{
	return true;
	}

defaultproperties
	{
	ActionString="If PlayerWeaponState: "
	}
