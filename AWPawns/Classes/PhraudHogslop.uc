//=============================================================================
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class PhraudHogslop extends AWBystander
	placeable;

///////////////////////////////////////////////////////////////////////////////
// Take damage (pawn call) but also save who attacked me
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	local int HealthOld;
	local int Diff;
	local P2PowerupInv MoneysInv;
	local Vector TossMom;
	
	HealthOld = Health;
	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
	
	Diff = HealthOld - Health;
	if (Diff > 0)
	{
		// Make Phraud drop stacks of money every time he gets hit... because he's made of money
		// it's funny, laugh dammit!
		MoneysInv = Spawn(class'MoneyInv', Self);
		MoneysInv.AddAmount(Diff);
		TossMom = Normal(Momentum);
		TossThisInventory(TossMom, MoneysInv);
	}
}

/*
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	log(self@"killed by"@Killer@DamageType@HitLocation@"calling super",'Debug');
	Super.Died(Killer, DamageType, HitLocation);
}
*/

///////////////////////////////////////////////////////////////////////////////
// If I'm used for an errand, delete my seeking rockets when i die
// so that it doesnt mess up anything after (like a cinematic)
///////////////////////////////////////////////////////////////////////////////
function CheckForErrandCompleteOnDeath(Controller Killer)
{
	local LauncherSeekingProjectileTrad rkt;	

	if(bUseForErrands)
	{
		//log("used for errands",'Debug');
		// Phraud always triggers died early
		TriggerEvent(DIED_EARLY_EVENT, self, None);
		foreach AllActors(class'LauncherSeekingProjectileTrad', rkt)
		{
			if(rkt.Dropper == Controller)
				rkt.Destroy();
		}
	}

	Super.CheckForErrandCompleteOnDeath(Killer);
	//log("back from super",'Debug');
}

defaultproperties
{
	ActorID="Phraud"
	TakesSledgeDamage=0.010000
	TakesMacheteDamage=0.010000
	TakesScytheDamage=0.010000
	TakesDervishDamage=0.010000
	TakesZombieSmashDamage=0.010000
	BlockMeleeFreq=1.000000
	HeadSkin=Texture'AW_Characters.Special.Phred'
	HeadMesh=SkeletalMesh'AW_Heads.AW_Fraud'
	bRandomizeHeadScale=False
	bStartupRandomization=False
	Psychic=1.000000
	Champ=0.900000
	Cajones=1.000000
	Temper=1.000000
	Glaucoma=0.700000
	Twitch=1.000000
	Compassion=0.000000
	WarnPeople=0.000000
	Conscience=0.000000
	Beg=0.000000
	PainThreshold=1.000000
	Reactivity=0.500000
	Confidence=1.000000
	Rebel=1.000000
	Patience=0.500000
	WillKneel=0.050000
	WillUseCover=0.100000
	Talkative=0.200000
	Stomach=1.000000
	TalkWhileFighting=0.250000
	TakesShotgunHeadShot=0.010000
	TakesRifleHeadShot=0.2 //0.100000
	TakesPistolHeadShot=0.15
	TakesShovelHeadShot=0.100000
	TakesOnFireDamage=0.200000
	TakesAnthraxDamage=0.400000
	TakesShockerDamage=0.100000
	TalkBeforeFighting=1.000000
	WeapChangeDist=500.000000
	bAdvancedFiring=True
	dialogclass=Class'AWPawns.DialogPhraud'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.MachineGunWeapon')
	BaseEquipment(1)=(WeaponClass=Class'Inventory.LauncherWeapon')
	TakesChemDamage=0.300000
	HealthMax=1000.000000
	bPlayerIsEnemy=True
	bPersistent=True
	bCanTeleportWithPlayer=False
	bKeepForMovie=True
	Mesh=SkeletalMesh'Characters.Avg_M_LS_Pants'
	Skins(0)=Texture'AW_Characters.Special.Phred_Suit'
	ControllerClass=Class'AWPawns.AWBystanderController'
	RandomizedBoltons(0)=None
	bHeadCanComeOff=false
}
