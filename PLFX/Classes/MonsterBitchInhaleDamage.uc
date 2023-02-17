///////////////////////////////////////////////////////////////////////////////
// MonsterBitchMeleeDamage
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Class of damage for the Bitch Monster's inhale attack
// Not a real damage type, just a marker for the collision actors to trigger
// a special event if the Dude gets eaten.
///////////////////////////////////////////////////////////////////////////////
class MonsterBitchInhaleDamage extends BludgeonDamage;

defaultproperties
{
	DeathString="%o was eaten alive by %k."
	MaleSuicide="%k decided to practice autocannibalism... oh dear"
	FemaleSuicide="%k decided to practice autocannibalism... oh dear"
}