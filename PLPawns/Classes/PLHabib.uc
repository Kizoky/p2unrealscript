//=============================================================================
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class PLHabib extends Bystander
	placeable;

defaultproperties
	{
	ActorID="PLHabib"
	
	bRandomizeHeadScale=false
	bPersistent=true
	bKeepForMovie=true
	bCanTeleportWithPlayer=false

	Psychic=1.0
	Champ=0.9
	Cajones=1.0
	Temper=1.0
	Glaucoma=0.7
	Twitch=1.0
	Rat=0.1
	Compassion=0.0
	WarnPeople=0.0
	Conscience=0.0
	Beg=0.0
	PainThreshold=1.0
	Reactivity=0.5
	Confidence=1.0
	Rebel=0.0
	Curiosity=0.5
	Patience=0.5
	WillDodge=0.1
	WillKneel=0.05
	WillUseCover=0.1
	Talkative=0.2
	Stomach=1.0
	VoicePitch=1.0
	TalkWhileFighting=0.25
	TalkBeforeFighting=1.0
	HealthMax=175.0
	bStartupRandomization=false
	Mesh=Mesh'Characters.Avg_M_SS_Pants'
	Skins[0]=Texture'ChameleonSkins.Special.Habib'
	HeadSkin=Texture'ChamelHeadSkins.Special.Habib'
	HeadMesh=Mesh'Heads.AvgMale'
	DialogClass=class'BasePeople.DialogHabib'
	bIsHindu=true
	ControllerClass=class'PLHabibController'
	BaseEquipment[0]=(weaponclass=class'Inventory.MachinegunWeapon')

	TakesShotgunHeadShot=	0.15
	TakesRifleHeadShot=		0.3
	TakesShovelHeadShot=	0.25
	TakesOnFireDamage=		0.3
	TakesAnthraxDamage=		0.4
	TakesShockerDamage=		0.1
	TakesChemDamage=		0.5

	RandomizedBoltons(0)=None
	RandomizedBoltons(1)=None
	RandomizedBoltons(2)=None
	RandomizedBoltons(3)=None
	RandomizedBoltons(4)=None
	RandomizedBoltons(5)=None
	RandomizedBoltons(6)=None
	RandomizedBoltons(7)=None
	AmbientGlow=30
	bCellUser=false
	bNoDismemberment=True
	}
