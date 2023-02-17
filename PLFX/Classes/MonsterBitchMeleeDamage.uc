///////////////////////////////////////////////////////////////////////////////
// MonsterBitchMeleeDamage
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Class of damage for the Bitch Monster's melee attacks (punch, slap, slam)
///////////////////////////////////////////////////////////////////////////////
class MonsterBitchMeleeDamage extends CuttingDamage;
// Cutting damage so that player armor doesn't become useless during boss fights. - K

defaultproperties
{
	bMeleeDamage=true
	bAllowZThrow=true
	DeathString="%o was crushed under %k's massive blubber."
	MaleSuicide="%k drowned in his own blubber... oh dear"
	FemaleSuicide="%k drowned in her own blubber... oh dear"
}