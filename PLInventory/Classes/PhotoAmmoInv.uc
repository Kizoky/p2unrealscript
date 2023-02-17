///////////////////////////////////////////////////////////////////////////////
// PhotoAmmoInv
// Copyright 2014 Running With Scissors Inc, All Rights Reserved
//
// Champ photo "ammo"
// About the same as the clipboard ammo, except we hide the ammo indicator,
// as there is no definite goal in mind besides getting someone to not run
// away screaming. Still caps out at 9, though.
///////////////////////////////////////////////////////////////////////////////
class PhotoAmmoInv extends ClipboardAmmoInv;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bShowAmmoOnHud=false
	bShowMaxAmmoOnHud=false

	// This determines how many signatures to get
	// Starts at 1 ammo, so make 10 the max to get the dude to question nine people.
	MaxAmmo=9

	Texture=Texture'MrD_PL_Tex.HUD.LostDog_HUD'
}
