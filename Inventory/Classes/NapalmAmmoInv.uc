///////////////////////////////////////////////////////////////////////////////
// NapalmAmmoInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Napalm ammo inventory item (as opposed to pickup).
//
///////////////////////////////////////////////////////////////////////////////

class NapalmAmmoInv extends P2AmmoInv;



///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ProjectileClass=Class'NapalmProjectile'
	PickupClass=class'NapalmAmmoPickup'
	bInstantHit=false
	WarnTargetPct=+0.2
	bLeadTarget=true
	RefireRate=0.990000
	MaxAmmo=6
	DamageAmount=13
	MomentumHitMag=10000
	DamageTypeInflicted=class'ExplodedDamage'
	Texture=Texture'HUDPack.Icons.Icon_Weapon_Napalm'
	}
