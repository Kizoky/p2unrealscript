///////////////////////////////////////////////////////////////////////////////
// PlagueAmmoInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Plague ammo inventory item (as opposed to pickup).
//
///////////////////////////////////////////////////////////////////////////////

class PlagueAmmoInv extends P2AmmoInv;



///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ProjectileClass=Class'PlagueProjectile'
	PickupClass=class'PlagueAmmoPickup'
	bInstantHit=false
	WarnTargetPct=+0.2
	bLeadTarget=true
	RefireRate=0.990000
	MaxAmmo=12
	DamageAmount=15
	MomentumHitMag=10000
	DamageTypeInflicted=class'ExplodedDamage'
	Texture=Texture'Patch1_Skins.Weapons.WMD_Inv'
	}
