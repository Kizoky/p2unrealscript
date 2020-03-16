//////////////////////////////////////////////////////////////////////////////
// GaryHeadBurnProjectile.
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// laughing gary heads on fire--hurts things on contact
//
///////////////////////////////////////////////////////////////////////////////
class GaryHeadBurnProjectile extends GaryHeadProjectile;

defaultproperties
{
     splatmakerclass=None
     TrailClass=Class'AWEffects.GaryHeadFire'
     explclass=Class'FX.GrenadeExplosion'
     explflyclass=Class'FX.GrenadeExplosion'
     speed=1200.000000
     MaxSpeed=1500.000000
     Acceleration=(Z=0.000000)
     SoundRadius=100.000000
     TransientSoundRadius=100.000000
}
