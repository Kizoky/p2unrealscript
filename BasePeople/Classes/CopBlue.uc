///////////////////////////////////////////////////////////////////////////////
// CopBlue
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Generally act as security guards. Weakest of cops. Don't have radios.
//
///////////////////////////////////////////////////////////////////////////////
class CopBlue extends Police
	placeable;

defaultproperties
	{
	Skins[0]=Texture'ChameleonSkins.XX__146__Avg_M_SS_Pants'
	Mesh=Mesh'Characters.Avg_M_SS_Pants'

	// No fat female cops -- they look stupid
	ChameleonSkins(0)="ChameleonSkins.FB__128__Fem_LS_Pants"
	ChameleonSkins(1)="ChameleonSkins.FM__129__Fem_LS_Pants"
	ChameleonSkins(2)="ChameleonSkins.FW__130__Fem_LS_Pants"
	ChameleonSkins(3)="ChameleonSkins.MB__033__Avg_M_SS_Pants"
	ChameleonSkins(4)="ChameleonSkins.MM__034__Avg_M_SS_Pants"
	ChameleonSkins(5)="ChameleonSkins.MW__035__Avg_M_SS_Pants"
	ChameleonSkins(6)="ChameleonSkins.MW__108__Fat_M_SS_Pants"
	//ChameleonSkins(7)="ChameleonSkins.MB__214__Tall_M_SS_Pants"
	//ChameleonSkins(8)="ChameleonSkins.MW__215__Tall_M_SS_Pants"
	ChameleonSkins(7)="end"	// end-of-list marker (in case super defines more skins)

	HealthMax=125
	Reactivity=0.2
	Glaucoma=0.85
	WillDodge=0.25
	DonutLove=0.9

	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Blue_Male
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_M_Avg',Skin=Shader'Boltons_Tex.CopHat_Blue_s',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Blue_Fem_LH
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_F_LH',Skin=Shader'Boltons_Tex.CopHat_Blue_s',bAttachToHead=True)
		AllowedHeads(0)=Mesh'Heads.FemLH'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Blue_Fem_SH
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_F_SH',Skin=Shader'Boltons_Tex.CopHat_Blue_s',bAttachToHead=True)
		AllowedHeads(0)=Mesh'Heads.FemSH'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Blue_Fem_SH_Crop
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_F_SH_Crop',Skin=Shader'Boltons_Tex.CopHat_Blue_s',bAttachToHead=True)
		AllowedHeads(0)=Mesh'Heads.FemSHcropped'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Blue_Fat
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_M_Fat',Skin=Shader'Boltons_Tex.CopHat_Blue_s',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Fat
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object

	RandomizedBoltons(0)=BoltonDef'BoltonDefAfro'
	RandomizedBoltons(1)=BoltonDef'BoltonDefHat_CopHat_Blue_Male'
	RandomizedBoltons(2)=BoltonDef'BoltonDefHat_CopHat_Blue_Fem_LH'
	RandomizedBoltons(3)=BoltonDef'BoltonDefHat_CopHat_Blue_Fem_SH'
	RandomizedBoltons(4)=BoltonDef'BoltonDefHat_CopHat_Blue_Fem_SH_Crop'
	RandomizedBoltons(5)=BoltonDef'BoltonDefHat_CopHat_Blue_Fat'
	RandomizedBoltons(6)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(7)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(8)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(9)=None
	}
