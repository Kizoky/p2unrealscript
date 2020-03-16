//=============================================================================
// Machine Gun Ammo Box
// Boxes filled with 5.56 rounds. These will set your ammo to 400.
// Gamefan74
// March 1st, 2008
//=============================================================================
class MachineGunAmmoBox extends P2AmmoPickup;

function AnnouncePickup(Pawn Receiver);

auto state Pickup
{
	function bool ValidTouch(Actor Other)
	{
	    if (Pawn(Other) != None && PlayerController(Pawn(Other).Controller) != None)
            return true;
        else
            return false;
    }

    function Touch(Actor Other)
	{
	    local Ammunition WeaponAmmo;

	    if (ValidTouch(Other))
	    {
	        WeaponAmmo = Ammunition(Pawn(Other).FindInventoryType(InventoryType));

	        if (WeaponAmmo != None)
	            WeaponAmmo.AmmoAmount = Min(WeaponAmmo.AmmoAmount + AmmoAmount, WeaponAmmo.MaxAmmo);

            Destroy();
	    }
    }
}

defaultproperties
{
     MPAmmoAmount=400
     AmmoAmount=400
     InventoryType=Class'Inventory.MachineGunBulletAmmoInv'
     PickupMessage="You loaded up with Machinegun rounds."
     StaticMesh=StaticMesh'Zo_Meshes.Compound.zo_ammobox1'
}
