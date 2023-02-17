/**
 * ObeseBitchMeleeDamage
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * DamageType for Obese Bitch when she smacks you with her folds
 *
 * @author Gordon Cheng
 */
class ObeseBitchMeleeDamage extends CuttingDamage;
// Cutting damage so that player armor doesn't become useless during boss fights. - K

defaultproperties
{
	bMeleeDamage=true
	bAllowZThrow=true

	DeathString="%o was suffocated by %k's fat folds"

	MaleSuicide="%k suffocated under his own fat"
	FemaleSuicide="%k suffocated under her own fat"
}
