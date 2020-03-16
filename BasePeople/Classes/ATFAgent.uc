///////////////////////////////////////////////////////////////////////////////
// ATFAgent
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Field officers. good shots
//
//	BaseEquipment[0]=(weaponclass=class'Inventory.HandCuffsWeapon')
//	BaseEquipment[1]=(weaponclass=class'Inventory.BatonWeapon')
//	BaseEquipment[2]=(weaponclass=class'Inventory.PistolWeapon')
///////////////////////////////////////////////////////////////////////////////
class ATFAgent extends Police
	placeable;


defaultproperties
	{
	ActorID="ATFAgent"
	// Default to chameleon mode
	Skins[0]=Texture'ChameleonSkins.XX__140__Avg_M_SS_Pants'
	Mesh=Mesh'Characters.Avg_M_SS_Pants'
	ChameleonSkins(0)="ChameleonSkins.FW__111__Fat_F_SS_Pants"
	ChameleonSkins(1)="ChameleonSkins.FW__116__Fem_LS_Pants"
	ChameleonSkins(2)="ChameleonSkins.MW__023__Avg_M_SS_Pants"
	ChameleonSkins(3)="ChameleonSkins.MW__101__Fat_M_SS_Pants"
	ChameleonSkins(4)="end"	// end-of-list marker (in case super defines more skins)

	HealthMax=110
	WillDodge=0.5
	WillKneel=0.1
	WillUseCover=0.9
	Champ=0.55
	DonutLove=0.1
	Glaucoma=0.5
	BaseEquipment[0]=(weaponclass=class'Inventory.HandCuffsWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.BatonWeapon')
	BaseEquipment[2]=(weaponclass=class'Inventory.PistolWeapon')
	TakesShotgunHeadShot=	0.2
	TakesRifleHeadShot=		1.0
	TakesShovelHeadShot=	1.0
	TakesOnFireDamage=		0.6
	TakesAnthraxDamage=		1.0
	TakesShockerDamage=		0.3
	TakesChemDamage=		0.5
	Boltons[0]=(bone="cop_badge",staticmesh=None,bCanDrop=false,bInActive=true)

	Begin Object Class=BoltonDef Name=BoltonDefBallcap_ATF
		UseChance=1
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_High',Skin=Texture'Boltons_Tex.baseballcap_ATF',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_ATF',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefBallcap_ATF_Fem
		UseChance=1
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_ATF',bAttachToHead=True)
		AllowedHeads(0)=Mesh'heads.FemSHCropped'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefShades4
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Aviators_F',bAttachToHead=True)
		//Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Sports_Shades_F',bAttachToHead=True)		
		UseChance=0.5
		Gender=Gender_Female
		Tag="Glasses"
		ExcludeTags(0)="Glasses"
		InvalidHoliday="NightMode"
	End Object

	RandomizedBoltons(0)=BoltonDef'BoltonDefAfro'
	RandomizedBoltons(1)=BoltonDef'BoltonDefBallcap_ATF'
	RandomizedBoltons(2)=BoltonDef'BoltonDefBallcap_ATF_Fem'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(4)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(5)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(6)=None
	}
