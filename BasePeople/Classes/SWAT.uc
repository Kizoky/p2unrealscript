//=============================================================================
// SWAT
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all SWAT characters.
//
//=============================================================================
class SWAT extends AuthorityFigure
	placeable;


function PreBeginPlay()
	{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
	}

defaultproperties
	{
	ActorID="SWAT"
	Skins[0]=Texture'ChameleonSkins.XX__159__Big_M_LS_Pants'
	Mesh=Mesh'Characters.Big_M_LS_Pants'

	ChameleonSkins(0)="ChameleonSkins.MW__071__Big_M_LS_Pants"
	ChameleonSkins(1)="end"	// end-of-list marker (in case super defines more skins)

	bRandomizeHeadScale=false	// don't let head scale or it may clip with helmets

	HeadSkin=Texture'ChamelHeadSkins.Special.Robber'
	HeadMesh=Mesh'Heads.Masked'

	HealthMax=225
	Psychic=0.4
	Rat=1.0
	Temper=0.35
	Compassion=0.0
	WarnPeople=0.0
	Conscience=0.0
	Beg=0.0
	Champ=0.7
	Cajones=0.7
	Reactivity=0.75
	PainThreshold=1.0
	Glaucoma=0.45
	Rebel=1.0
	WillDodge=0.4
	WillKneel=0.2
	WillUseCover=0.8
	Stomach=1.0
	Fitness=0.9
	Armor=100
	ArmorMax=100
	AttackRange=(Min=512,Max=4096)
	BaseEquipment[0]=(weaponclass=class'Inventory.MachineGunWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.PistolWeapon')
	TalkWhileFighting=0.1
	TalkBeforeFighting=0.1
    ControllerClass=class'MilitaryController'
	DialogClass=class'BasePeople.DialogMaleMilitary'
	Gang="SWAT"

	ViolenceRankTolerance=0
	TakesShotgunHeadShot=	0.25
	TakesRifleHeadShot=		0.3
	TakesShovelHeadShot=	0.35
	TakesOnFireDamage=		0.4
	TakesAnthraxDamage=		0.5
	TakesShockerDamage=		0.1

	// Give all SWAT helmets
	Boltons[0]=(bone="NODE_Parent",staticmesh=staticmesh'boltons.Swat_Goggles',bCanDrop=false,bAttachToHead=true)

	bNoChamelBoltons=True
	RandomizedBoltons(0)=None
	}
