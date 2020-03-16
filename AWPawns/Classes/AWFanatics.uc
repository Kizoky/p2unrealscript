///////////////////////////////////////////////////////////////////////////////
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Fanatics. One of the groups to end up hating the dude.
//
///////////////////////////////////////////////////////////////////////////////
class AWFanatics extends AWBystander
	placeable;

function PreBeginPlay()
	{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
	}

///////////////////////////////////////////////////////////////////////////////
// Record pawn dead, if player killed them
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	// Moved to P2Pawn/GameState
	/*
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
	{
		// Record him dying as a fanatic
		AWGameState(P2GameInfoSingle(Level.Game).TheGameState).FanaticsKilled++;
	}
	*/

	// use DudeSuicideDamage now instead of trying to hunt down a possibly-invalid Killer.
	if (damageType == class'DudeSuicideDamage')
	{
		if( Level.NetMode != NM_DedicatedServer ) P2GameInfoSingle(Level.Game).GetPlayer().GetEntryLevel().EvaluateAchievement(P2Player(Killer),'ReversePsychology');
	}

	Super.Died(Killer, damageType, HitLocation);
}

defaultproperties
{
	ActorID="Terrorist"
	bPants=True
	BlockMeleeFreq=0.600000
	bIsTrained=True
	ChameleonSkins(0)="ChameleonSkins.MF__009__Avg_Dude"
	ChameleonSkins(1)="ChameleonSkins.MF__010__Avg_Dude"
	ChameleonSkins(2)="ChameleonSkins.MF__011__Avg_Dude"
	ChameleonSkins(3)="End"
	ChamelHeadSkins(0)="ChamelHeadSkins.MFA__018__AvgFanatic"
	ChamelHeadSkins(1)="ChamelHeadSkins.MFA__019__AvgFanatic"
	ChamelHeadSkins(2)="ChamelHeadSkins.MFA__020__AvgFanatic"
	ChamelHeadSkins(3)="End"
	Cajones=1.000000
	Glaucoma=0.700000
	PainThreshold=1.000000
	Rebel=1.000000
	Stomach=0.900000
	TalkWhileFighting=0.000000
	TakesShotgunHeadShot=0.400000
	TakesRifleHeadShot=0.500000
	TakesShovelHeadShot=0.500000
	TakesOnFireDamage=0.100000
	TakesAnthraxDamage=0.700000
	TakesShockerDamage=0.200000
	TalkBeforeFighting=0.000000
	dialogclass=Class'BasePeople.DialogHabib'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.MachineGunWeapon')
	ViolenceRankTolerance=1
	HealthMax=80.000000
	Gang="Fanatics"
	Mesh=SkeletalMesh'Characters.Avg_Dude'
	Skins(0)=Texture'ChameleonSkins.Fanatic.XX__147__Avg_Dude'
	ControllerClass=Class'AWPawns.AWBystanderController'
	RandomizedBoltons(0)=None
	RandomizedBoltons(1)=None
	RandomizedBoltons(2)=None
	RandomizedBoltons(3)=None
	RandomizedBoltons(4)=None
	RandomizedBoltons(5)=None
	RandomizedBoltons(6)=None
	RandomizedBoltons(7)=None
}
