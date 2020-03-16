///////////////////////////////////////////////////////////////////////////////
// ScissorsAmmoInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Scissors ammo inventory item (as opposed to pickup or projectile).
//
///////////////////////////////////////////////////////////////////////////////

class ScissorsAmmoInv extends P2AmmoInv;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	MaxAmmoMP=48
	MaxAmmo=144
	ProjectileClass=class'ScissorsProjectile'
	bInstantHit=false
	WarnTargetPct=+0.2
	bLeadTarget=false
	RefireRate=0.990000
	DamageAmount=20
	MomentumHitMag=10000
	DamageTypeInflicted=class'CuttingDamage'
	Texture=Texture'HUDPack.Icon_Weapon_Scissors'
	}
