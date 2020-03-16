//=============================================================================
// MrDTNadeAmmoInv.
//=============================================================================
class MrDKNadeAmmoInv extends P2AmmoInv;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     DamageAmount=500.000000
     MomentumHitMag=500000.000000
     DamageTypeInflicted=Class'MrDKNadeDamage'
     MaxAmmo=6
     bLeadTarget=True
     ProjectileClass=Class'MrDKNadeProjectile'
     WarnTargetPct=0.200000
     RefireRate=0.990000
     PickupClass=Class'MrDKNadePickup'
     Texture=Texture'P2R_Tex_D.Weapons.IconKNade'
}
