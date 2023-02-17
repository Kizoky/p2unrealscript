///////////////////////////////////////////////////////////////////////////////
// EnsmallenDamage
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Ensmallen cure "damage". No damage is ever actually done, but a damage type
// is required for calls to PlayHit and NotifyTakeHit, and NoKillDamage
// has Z Throw turned on, which we don't want.
///////////////////////////////////////////////////////////////////////////////
class EnsmallenDamage extends P2Damage;

defaultproperties
{
	bCanKill=false
	bInstantHit=true
	bArmorStops=false
	DeathString="%o was shrunk to microscopic proportions by %k."
	MaleSuicide="%k somehow managed to shrink himself to death."
	FemaleSuicide="%k somehow managed to shrink herself to death."
}
