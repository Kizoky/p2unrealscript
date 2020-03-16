///////////////////////////////////////////////////////////////////////////////
// MolotovAmmoInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Molotov ammo inventory item (as opposed to pickup).
//
///////////////////////////////////////////////////////////////////////////////

class MolotovAmmoInv extends P2AmmoInv;



///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ProjectileClass=Class'MolotovProjectile'
	bInstantHit=false
	WarnTargetPct=+0.2
	bLeadTarget=true
	RefireRate=0.990000
	MaxAmmo=20
	DamageAmount=13
	MomentumHitMag=10000
	DamageTypeInflicted=class'ExplodedDamage'
	Texture=Texture'HUDPack.Icon_Weapon_Molotov'
	}
