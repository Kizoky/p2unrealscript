class ChainsawPickup extends P2WeaponPickup;

defaultproperties
{
	AmmoGiveCount=10
	DeadNPCAmmoGiveRange=(Min=5.000000,Max=10.000000)
	BounceSound=Sound'MiscSounds.Props.MetalCrateDoor'
	ShortSleeveType=Class'ChainsawWeapon'
	InventoryType=Class'ChainsawWeapon'
	PickupMessage="You picked up a Chainsaw!"
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ED_TPMeshes.Weapons.TP_Chainsaw'
}