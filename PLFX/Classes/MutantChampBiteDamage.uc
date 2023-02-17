/**
 * MutantChampBiteDamage
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * DamageType for getting chomped by Mutant Champ. Worst part though is the
 * doggie breath
 *
 * @author Gordon Cheng
 */
class MutantChampBiteDamage extends CuttingDamage;
// Cutting damage so that player armor doesn't become useless during boss fights. - K

defaultproperties
{
	bMeleeDamage=true
	bAllowZThrow=true

	DeathString="%o turned into peanut butter in %k's mouth"

	MaleSuicide="%k at himself"
	FemaleSuicide="%k at herself"
}
