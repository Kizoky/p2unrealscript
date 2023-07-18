class ScythePickup extends P2BloodWeaponPickup;
// Added by Man Chrzan: xPatch 2.0
var bool bForceSwitch;

// Force switching to this weapon.
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	Copy = Super.SpawnCopy(Other);
	
	if(bForceSwitch)
		P2Player(Other.Controller).PickupThrownWeapon(Copy.InventoryGroup, Copy.GroupOffset, true);
		
	return Copy;
}
// End

defaultproperties
{
     ZombieSearchFreq=0.300000
     BounceSound=Sound'AWSoundFX.Scythe.scythehitground'
     InventoryType=Class'AWInventory.ScytheWeapon'
     PickupMessage="You picked up a Scythe."
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AWWeaponStatic.Weapons.Scythe_1'
}
