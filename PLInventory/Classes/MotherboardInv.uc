///////////////////////////////////////////////////////////////////////////////
// MotherboardInv
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Motherboards for RWS's latest arcade hit!
///////////////////////////////////////////////////////////////////////////////
class MotherboardInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	///////////////////////////////////////////////////////////////////////////////
	// Attempt to use on open arcade cabinet
	///////////////////////////////////////////////////////////////////////////////
	function UseOnArcadeCabinet()
	{
		local MotherboardInstallPoint InstallPoint;
		
		// For every successful install, reduce amount by 1
		foreach Owner.TouchingActors(class'MotherboardInstallPoint', InstallPoint)
			if (!InstallPoint.bInstalled
				&& InstallPoint.InstallMotherboard(Pawn(Owner)))
				{
					log(self@"successfully installed to"@InstallPoint);
					ReduceAmount(1);	// Use up a motherboard
					TurnOffHints();		// Turn off the hint
				}
	}

Begin:
	UseOnArcadeCabinet();
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PickupClass=class'MotherboardPickup'
	Icon=Texture'MrD_PL_Tex.HUD.motherboard_HUD'
	UseForErrands=1
	Hint1="Press %KEY_InventoryActivate% to install motherboard."
	bCanThrow=false
	bAllowHints=false
	InventoryGroup=102
	GroupOffset=16
	PowerupName="Motherboard"
	PowerupDesc="Deliver these to Yeeland's Fun Land."
}
