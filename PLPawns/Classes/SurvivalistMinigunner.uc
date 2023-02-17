/**
 * SurvivalistMinigunner
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Basically just like the Bandit Leader, only much much weaker
 *
 * @author Gordon Cheng
 */
class SurvivalistMinigunner extends PLMountedWeaponPawn
    placeable;

function PreBeginPlay() {
	super.PreBeginPlay();

	ChameleonOnlyHasGender = Gender_Male;
}

defaultproperties
{
	ActorID="Survivalist"

    Skins[0]=Texture'PLCharacterSkins.Survivalist.MW__300__Avg_Survivalist'
	Mesh=SkeletalMesh'PLCharacters.Avg_Survivalist'

	ChameleonMeshPkgs(0)="PLCharacters"
	ChameleonSkins(0)="PLCharacterSkins.Survivalist.MW__300__Avg_Survivalist"
	ChameleonSkins(1)="end"	// end-of-list marker (in case super defines more skins)

	ChamelHeadMeshPkgs(0)="PLHeads"
	ChamelHeadSkins(0)="PLCharacterSkins.Survivalist_Head.MWA__300__Head_Survivalist"
	ChamelHeadSkins(1)="end"

	ADJUST_RELATIVE_HEAD_X=-8
	bRandomizeHeadScale=false	// don't let head scale or it may clip with helmets

	MountedWeaponRotationRate=(Pitch=0,Yaw=4000,Roll=0)

	HealthMax=225
	BlockMeleeFreq=0.9
	Psychic=0.4
	Champ=0.7
	Cajones=0.7
	Temper=0.35
	Glaucoma=0.45
	Rat=1
	Compassion=0
	WarnPeople=0
	Conscience=0
	Beg=0
	PainThreshold=1
	Reactivity=0.75
	Rebel=1
	WillDodge=0.4
	WillKneel=0.2
	WillUseCover=0.8
	Stomach=1
	Armor=100
	ArmorMax=100
	TalkWhileFighting=0.2
	TakesShotgunHeadShot=0.25
	TakesRifleHeadShot=0.3
	TakesShovelHeadShot=0.35
	TakesOnFireDamage=0.4
	TakesAnthraxDamage=0.5
	TakesShockerDamage=0.1
	TalkBeforeFighting=0.2
	Fitness=0.9
	AttackRange=(Min=512,Max=4096)
	BaseEquipment[0]=(weaponclass=class'Inventory.MachineGunWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.PistolWeapon')
	TalkWhileFighting=0.1
	TalkBeforeFighting=0.1
    ControllerClass=none
	DialogClass=class'DialogSurvivalist'
	Gang="Survivalists"

	ViolenceRankTolerance=0
	TakesShotgunHeadShot=0.25
	TakesRifleHeadShot=0.3
	TakesShovelHeadShot=0.35
	TakesOnFireDamage=0.4
	TakesAnthraxDamage=0.5
	TakesShockerDamage=0.1

	bNoChamelBoltons=true
	RandomizedBoltons(0)=none
	bFriendWithAuthority=false

	StumpClass=class'StumpSurvivalist'
	LimbClass=class'LimbSurvivalist'
	StumpAdjust=(X=5)

	PawnInitialState=EP_Turret
	AmbientGlow=30
}