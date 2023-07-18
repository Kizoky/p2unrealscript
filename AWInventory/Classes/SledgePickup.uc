class SledgePickup extends P2BloodWeaponPickup;
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
     BounceSound=Sound'AWSoundFX.Sledge.hammerhitground'
     InventoryType=Class'AWInventory.SledgeWeapon'
     PickupMessage="You picked up a Sledgehammer."
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AWWeaponStatic.Weapons.Sledge_1'
}
