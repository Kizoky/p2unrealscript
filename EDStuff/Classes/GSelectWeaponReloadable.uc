class GSelectWeaponReloadable extends GSelectWeapon;

///////////////////////////////////////////////////////////////////////////////
// Just like in Eternal Damnation
///////////////////////////////////////////////////////////////////////////////
function ServerFire()
{
	// Don't allow holding LMB to fire in Burst and Semi
	if (FireMode == FM_Semi || FireMode == FM_Burst)
        Instigator.Controller.bFire = 0;
	
	Super(EDWeapon).ServerFire();
}

defaultproperties
{
     bReloadableWeapon=True
	 bAllowReloadHints=True
	 bDisableDualWielding=True
	 ReloadCount=17
     GroupOffset=3
     PickupClass=Class'GSelectPickupReloadable'
}
