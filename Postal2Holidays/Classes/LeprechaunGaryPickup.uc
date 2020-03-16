/**
 * LeprechaunGaryPickup
 *
 * A Pickup object that's not really meant to be placed into the map, but
 * simply for completeness sakes for the LeprechaunGaryInv. You can still place
 * it in the map though for some fun.
 */
class LeprechaunGaryPickup extends OwnedPickup;

defaultproperties
{
    Price=0
	InventoryType=class'LeprechaunGaryInv'
	PickupMessage="You picked up Leprechaun Gary."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Stuff.stuff1.garybook'
	bPaidFor=false
	BounceSound=sound'MiscSounds.PickupSounds.BookDropping'
}