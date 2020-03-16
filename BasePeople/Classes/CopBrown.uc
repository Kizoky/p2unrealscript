///////////////////////////////////////////////////////////////////////////////
// CopBrown
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Toughest cops
//
//	BaseEquipment[0]=(weaponclass=class'Inventory.HandCuffsWeapon')
//	BaseEquipment[1]=(weaponclass=class'Inventory.BatonWeapon')
//	BaseEquipment[2]=(weaponclass=class'Inventory.ShotgunWeapon')
///////////////////////////////////////////////////////////////////////////////
class CopBrown extends Police
	placeable;

function PreBeginPlay()
	{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	//ChameleonOnlyHasGender = Gender_Male;
	}

defaultproperties
	{
	Skins[0]=Texture'ChameleonSkins.XX__145__Avg_M_SS_Pants'
	Mesh=Mesh'Characters.Avg_M_SS_Pants'

	ChameleonSkins(0)="ChameleonSkins.MB__036__Avg_M_SS_Pants"
	ChameleonSkins(1)="ChameleonSkins.MM__037__Avg_M_SS_Pants"
	ChameleonSkins(2)="ChameleonSkins.MW__038__Avg_M_SS_Pants"
	ChameleonSkins(3)="ChameleonSkins2.MW__200__Avg_M_SS_Pants"
	ChameleonSkins(4)="ChameleonSkins2.MW__201__Fat_M_SS_Pants"
	ChameleonSkins(5)="ChameleonSkins2.FW__202__Fem_LS_Pants"
	//ChameleonSkins(6)="ChameleonSkins2.MB__216__Tall_M_SS_Pants"
	//ChameleonSkins(7)="ChameleonSkins2.MW__217__Tall_M_SS_Pants"
	ChameleonSkins(6)="end"	// end-of-list marker (in case super defines more skins)

	HealthMax=160
	WillDodge=0.4
	WillKneel=0.1
	WillUseCover=0.7
	Champ=0.45
	Cajones=0.8
	DonutLove=0.3
	BaseEquipment[0]=(weaponclass=class'Inventory.HandCuffsWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.BatonWeapon')
	BaseEquipment[2]=(weaponclass=class'Inventory.ShotgunWeapon')
	TakesShotgunHeadShot=	0.2
	TakesRifleHeadShot=		1.0
	TakesShovelHeadShot=	1.0
	TakesOnFireDamage=		0.8
	TakesAnthraxDamage=		1.0
	TakesShockerDamage=		0.5
	TakesChemDamage=		0.9

	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Brown_Male
		UseChance=0.6
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_M_Avg',Skin=Shader'Boltons_Tex.CopHat_Brown_s',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Brown_Fem_LH
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_F_LH',Skin=Shader'Boltons_Tex.CopHat_Brown_s',bAttachToHead=True)
		AllowedHeads(0)=Mesh'Heads.FemLH'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Brown_Fem_SH
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_F_SH',Skin=Shader'Boltons_Tex.CopHat_Brown_s',bAttachToHead=True)
		AllowedHeads(0)=Mesh'Heads.FemSH'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Brown_Fem_SH_Crop
		UseChance=0.6
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_F_SH_Crop',Skin=Shader'Boltons_Tex.CopHat_Brown_s',bAttachToHead=True)
		AllowedHeads(0)=Mesh'Heads.FemSHcropped'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Brown_Fat
		UseChance=0.6
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_M_Fat',Skin=Shader'Boltons_Tex.CopHat_Brown_s',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Fat
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_TrooperHat_Male
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.TrooperHat_M',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_TrooperHat_Female
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.TrooperHat_F_SH_Crop',bAttachToHead=True)
		Gender=Gender_Female
		BodyType=Body_Avg
		AllowedHeads(0)=Mesh'Heads.FemSHcropped'
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_TrooperHat_Male_Fat
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.TrooperHat_M_Fat',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Fat
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object

	RandomizedBoltons(0)=BoltonDef'BoltonDefAfro'
	RandomizedBoltons(1)=BoltonDef'BoltonDefHat_CopHat_Brown_Male'
	RandomizedBoltons(2)=BoltonDef'BoltonDefHat_CopHat_Brown_Fem_LH'
	RandomizedBoltons(3)=BoltonDef'BoltonDefHat_CopHat_Brown_Fem_SH'
	RandomizedBoltons(4)=BoltonDef'BoltonDefHat_CopHat_Brown_Fem_SH_Crop'
	RandomizedBoltons(5)=BoltonDef'BoltonDefHat_CopHat_Brown_Fat'
	RandomizedBoltons(6)=BoltonDef'BoltonDefHat_TrooperHat_Male'
	RandomizedBoltons(7)=BoltonDef'BoltonDefHat_TrooperHat_Female'
	RandomizedBoltons(8)=BoltonDef'BoltonDefHat_TrooperHat_Male_Fat'
	RandomizedBoltons(9)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(10)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(11)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(11)=None
	}
