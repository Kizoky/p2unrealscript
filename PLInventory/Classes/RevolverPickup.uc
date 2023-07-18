/**
 * RevolverPickup
 */
class RevolverPickup extends P2DualWieldWeaponPickup;

var byte SaveExecutionLevel;			// xPatch: Keep execution level after you dropped the revolver

///////////////////////////////////////////////////////////////////////////////
// Make sure the amount we had carries over
///////////////////////////////////////////////////////////////////////////////
function InitDroppedPickupFor(Inventory Inv)
{
	Super.InitDroppedPickupFor(Inv);
	
	if(RevolverWeapon(Inv) != None)
		SaveExecutionLevel = RevolverWeapon(Inv).ExecutionLevel;
}

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	Copy = Super.SpawnCopy(Other);

	if(RevolverWeapon(Copy) != None && Owner != None)
		RevolverWeapon(Copy).ExecutionLevel = SaveExecutionLevel;

	return Copy;
}

defaultproperties
{
	AmmoGiveCount=6
	MPAmmoGiveCount=20
	DeadNPCAmmoGiveRange=(Min=2,Max=5)
	InventoryType=class'RevolverWeapon'
	ShortSleeveType=class'RevolverWeapon'
	PickupMessage="You picked up a Revolver"
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'PLPickupMesh.Weapons.PU_Revolver'
	CollisionRadius=40
	CollisionHeight=5
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	DrawScale=1.0
}
