///////////////////////////////////////////////////////////////////////////////
// Drug Eradication Enforcement Team (DEET)
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// "I like saying DEET. DEET, DEET, DEET, DEET, DEET, DEET, DEET, DEET, DEET."
//      - Meatwad
///////////////////////////////////////////////////////////////////////////////
class DEET extends Bystander
	placeable;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Cowardice=0.0;
	Cajones=1.0;
	PainThreshold=1.0;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActorID="DEET"

	bIsTrained=true	

	Mesh=SkeletalMesh'Characters.Avg_M_SS_Pants'
	Skins[0]=Texture'PLCharacterSkins.DEET.XX__400__Avg_M_SS_Pants'
	ChameleonSkins(0)="PLCharacterSkins.DEET.MW__400__Avg_M_SS_Pants"
	ChameleonSkins(1)="End"
	HealthMax=110
	
	bStartupRandomization=false
	Psychic=0.2
	Rat=1.0
	Compassion=0.3
	WarnPeople=0.4
	Conscience=0.2
	Reactivity=0.4
	Cajones=1.0
	Cowardice=0.0
	PainThreshold=1.0
	TalkWhileFighting=0.1
	TalkBeforeFighting=0.1
	Rebel=1.0
	Temper=0.12
	Fitness=0.55
	AttackRange=(Min=256,Max=4096)
	
	WillDodge=0.5
	WillKneel=0.1
	WillUseCover=0.9
	Champ=0.55
	DonutLove=0.1
	Glaucoma=0.5
	BaseEquipment[0]=(weaponclass=class'Inventory.BatonWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.PistolWeapon')
	TakesShotgunHeadShot=	0.2
	TakesRifleHeadShot=		1.0
	TakesShovelHeadShot=	1.0
	TakesOnFireDamage=		0.6
	TakesAnthraxDamage=		1.0
	TakesShockerDamage=		0.3
	TakesChemDamage=		0.5
	RandomizedBoltons(0)=BoltonDef'BoltonDefAfro'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(4)=None
	Gang="DEET"
	
	bCellUser=False
	BlockMeleeFreq=0.7
	AmbientGlow=30
}

// "DEET, DEET, DEET, DEET, DEET, DEET, DEET, DEET, DEET, DEET, DEET, DEET..."
