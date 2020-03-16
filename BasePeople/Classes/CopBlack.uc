///////////////////////////////////////////////////////////////////////////////
// CopBlack
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Traditional city police.
//
///////////////////////////////////////////////////////////////////////////////
class CopBlack extends Police
	placeable;

defaultproperties
	{
	Skins[0]=Texture'ChameleonSkins.XX__144__Avg_M_SS_Pants'
	Mesh=Mesh'Characters.Avg_M_SS_Pants'

	ChameleonSkins(0)="ChameleonSkins.FB__126__Fem_LS_Pants"
	ChameleonSkins(1)="ChameleonSkins.FM__125__Fem_LS_Pants"
	ChameleonSkins(2)="ChameleonSkins.FW__127__Fem_LS_Pants"
	ChameleonSkins(3)="ChameleonSkins.MB__032__Avg_M_SS_Pants"
	ChameleonSkins(4)="ChameleonSkins.MM__030__Avg_M_SS_Pants"
	ChameleonSkins(5)="ChameleonSkins.MW__031__Avg_M_SS_Pants"
	//ChameleonSkins(6)="ChameleonSkins2.MB__212__Tall_M_SS_Pants"
	//ChameleonSkins(7)="ChameleonSkins2.MW__213__Tall_M_SS_Pants"
	ChameleonSkins(6)="end"	// end-of-list marker (in case super defines more skins)

	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Black_Male
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_M_Avg',Skin=Shader'Boltons_Tex.CopHat_Black_s',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Black_Fem_LH
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_F_LH',Skin=Shader'Boltons_Tex.CopHat_Black_s',bAttachToHead=True)
		AllowedHeads(0)=Mesh'Heads.FemLH'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Black_Fem_SH
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_F_SH',Skin=Shader'Boltons_Tex.CopHat_Black_s',bAttachToHead=True)
		AllowedHeads(0)=Mesh'Heads.FemSH'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Black_Fem_SH_Crop
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_F_SH_Crop',Skin=Shader'Boltons_Tex.CopHat_Black_s',bAttachToHead=True)
		AllowedHeads(0)=Mesh'Heads.FemSHcropped'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefHat_CopHat_Black_Fat
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.CopHat_M_Fat',Skin=Shader'Boltons_Tex.CopHat_Black_s',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Fat
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
		Begin Object Class=BoltonDef Name=BoltonDefBallcap_CopBlack
		UseChance=0.75
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M_High',Skin=Texture'Boltons_Tex.baseballcap_police',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_police',bAttachToHead=True)
		Gender=Gender_Male
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDefBallcap_CopBlack_Fem
		UseChance=0.5
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_F_SH_Crop',Skin=Texture'Boltons_Tex.baseballcap_police',bAttachToHead=True)
		AllowedHeads(0)=Mesh'Heads.FemSHcropped'
		Gender=Gender_Female
		BodyType=Body_Avg
		ExcludedHeads(0)=Mesh'Heads.AvgBrotha'
		ExcludedHeads(1)=Mesh'Heads.AvgMaleBig'
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object

	RandomizedBoltons(0)=BoltonDef'BoltonDefAfro'
	RandomizedBoltons(1)=BoltonDef'BoltonDefHat_CopHat_Black_Male'
	RandomizedBoltons(2)=BoltonDef'BoltonDefHat_CopHat_Black_Fem_LH'
	RandomizedBoltons(3)=BoltonDef'BoltonDefHat_CopHat_Black_Fem_SH'
	RandomizedBoltons(4)=BoltonDef'BoltonDefHat_CopHat_Black_Fem_SH_Crop'
	RandomizedBoltons(5)=BoltonDef'BoltonDefHat_CopHat_Black_Fat'
	RandomizedBoltons(6)=BoltonDef'BoltonDefBallcap_CopBlack'
	RandomizedBoltons(7)=BoltonDef'BoltonDefBallcap_CopBlack_Fem'
	RandomizedBoltons(8)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(9)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(10)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(11)=None
	}
