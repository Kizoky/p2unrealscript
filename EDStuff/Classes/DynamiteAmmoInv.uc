///////////////////////////////////////////////////////////////////////////////
// GrenadeAmmoInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Grenade ammo inventory item (as opposed to pickup).
//
///////////////////////////////////////////////////////////////////////////////

class DynamiteAmmoInv extends P2AmmoInv;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     DamageAmount=13.000000
     MomentumHitMag=10000.000000
     DamageTypeInflicted=Class'ScytheDamage'
     MaxAmmoMP=5
     MaxAmmo=30
     bLeadTarget=True
     ProjectileClass=Class'DynamiteProjectile'
     WarnTargetPct=0.200000
     RefireRate=0.990000
     Texture=Texture'EDHud.hud_Dynamite'
}
