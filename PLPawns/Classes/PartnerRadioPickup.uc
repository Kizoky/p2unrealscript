class PartnerRadioPickup extends P2WeaponPickup;

defaultproperties
{
     AmmoGiveCount=1
     BounceSound=sound'MiscSounds.PickupSounds.BookDropping'
     MPAmmoGiveCount=1
     ShortSleeveType=class'PartnerRadioWeapon'
     bNoBotPickup=true
     MaxDesireability=-1.0f
     InventoryType=class'PartnerRadioWeapon'
     PickupMessage="You picked up a Radio."
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'boltons.cop_radio'
     CollisionRadius=35.000000
     CollisionHeight=20.000000
}
