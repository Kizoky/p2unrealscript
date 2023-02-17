/**
 * MutantChampMeleeDamage
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * DamageType for Mutant Champ where he bats your around with his giant paws
 *
 * @author Gordon Cheng
 */
class MutantChampMeleeDamage extends CuttingDamage;

defaultproperties
{
	bMeleeDamage=true
	bAllowZThrow=true

	DeathString="%o was crushed by %k's little doggie paws"

	MaleSuicide="%k punched himself with his own paw"
	FemaleSuicide="%k punched herself with her own paw"
}
