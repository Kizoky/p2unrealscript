/**
 * MutantChampFireballDamage
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * DamageType for those flaming, sentient, ignited fireballs of doggy breath
 *
 * @author Gordon Cheng
 */
class MutantChampFireballDamage extends BludgeonDamage;

defaultproperties
{
	bMeleeDamage=true
	bAllowZThrow=true

	DeathString="%o was exploded by %k's fireball"

	MaleSuicide="%k's fireballs decided to revolt and turn on himself"
	FemaleSuicide="%k's fireballs decided to revolt and turn on herself"
}
