///////////////////////////////////////////////////////////////////////////////
// CowHeadAmmoInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// CowHead ammo inventory item (as opposed to pickup).
//
///////////////////////////////////////////////////////////////////////////////

class CowHeadAmmoInv extends P2AmmoInv;



///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ProjectileClass=Class'CowHeadProjectile'
	bInstantHit=false
	WarnTargetPct=+0.2
	bLeadTarget=true
	RefireRate=0.990000
	MaxAmmo=4
	DamageAmount=13
	MomentumHitMag=10000
	DamageTypeInflicted=class'ExplodedDamage'
	Texture=Texture'HUDpack.icons.Icons.Icon_Weapon_CowHead'
	}
