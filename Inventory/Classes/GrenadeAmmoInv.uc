///////////////////////////////////////////////////////////////////////////////
// GrenadeAmmoInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Grenade ammo inventory item (as opposed to pickup).
//
///////////////////////////////////////////////////////////////////////////////

class GrenadeAmmoInv extends P2AmmoInv;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ProjectileClass=Class'GrenadeProjectile'
	bInstantHit=false
	WarnTargetPct=+0.2
	bLeadTarget=true
	RefireRate=0.990000
	MaxAmmo=50
	MaxAmmoMP=40
	DamageAmount=13
	MomentumHitMag=10000
	DamageTypeInflicted=class'GrenadeDamage'
	Texture=Texture'HUDPack.Icon_Weapon_Grenade'
	}
