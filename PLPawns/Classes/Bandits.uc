///////////////////////////////////////////////////////////////////////////////
// Bandits
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Every post-apocalyptic game has to have a bandit faction.
// There's like, some kind of video game law stating as such.
///////////////////////////////////////////////////////////////////////////////
class Bandits extends Bystander
	placeable;
	
defaultproperties
{
	ActorID="Bandits"

	Skins[0]=Texture'PLCharacterSkins.Bandits.XX__410__Avg_Bandit'
	Mesh=SkeletalMesh'PLCharacters.Avg_Bandit'
	ChameleonMeshPkgs(0)="PLCharacters"
	ChameleonSkins(0)="PLCharacterSkins.Bandits.MW__410__Avg_Bandit"
	ChameleonSkins(1)="end"	// end-of-list marker (in case super defines more skins)
	ChamelHeadSkins(0)="ChamelHeadSkins.MWA__001__AvgMale"
	ChamelHeadSkins(1)="ChamelHeadSkins.MBA__013__AvgBrotha"
	ChamelHeadSkins(2)="ChamelHeadSkins.MBA__014__AvgBrotha"
	ChamelHeadSkins(3)="ChamelHeadSkins.MMA__016__AvgMale"
	ChamelHeadSkins(4)="ChamelHeadSkins.MMF__024__FatMale"
	ChamelHeadSkins(5)="ChamelHeadSkins.MWA__002__AvgMale"
	ChamelHeadSkins(6)="ChamelHeadSkins.MMA__003__AvgMale"
	ChamelHeadSkins(7)="ChamelHeadSkins.MWA__004__AvgMale"
	ChamelHeadSkins(8)="ChamelHeadSkins.MWA__005__AvgMale"
	ChamelHeadSkins(9)="ChamelHeadSkins.FBA__063__FemSH"
	ChamelHeadSkins(10)="ChamelHeadSkins.MWA__007__AvgMale"
	ChamelHeadSkins(11)="ChamelHeadSkins.MWA__008__AvgMale"
	ChamelHeadSkins(12)="ChamelHeadSkins.MWA__009__AvgMale"
	ChamelHeadSkins(13)="ChamelHeadSkins.MWA__010__AvgMale"
	ChamelHeadSkins(14)="ChamelHeadSkins.MWA__011__AvgMale"
	ChamelHeadSkins(15)="ChamelHeadSkins.MWA__015__AvgMale"
	ChamelHeadSkins(16)="ChamelHeadSkins.MWA__035__AvgMale"
	ChamelHeadSkins(17)="ChamelHeadSkins.MWF__025__FatMale"
	ChamelHeadSkins(18)="ChamelHeadSkins.FBA__033__FemSH"
	ChamelHeadSkins(19)="ChamelHeadSkins.FMA__028__FemSH"
	ChamelHeadSkins(20)="ChamelHeadSkins.FMA__034__FemSH"
	ChamelHeadSkins(21)="ChamelHeadSkins.FWA__026__FemLH"
	ChamelHeadSkins(22)="ChamelHeadSkins.FWA__027__FemLH"
	ChamelHeadSkins(23)="ChamelHeadSkins.FWA__029__FemSH"
	ChamelHeadSkins(24)="ChamelHeadSkins.FWA__032__FemSH"
	ChamelHeadSkins(25)="ChamelHeadSkins.FWF__023__FatFem"
	ChamelHeadSkins(26)="ChamelHeadSkins.FWA__037__FemSHcropped"
	ChamelHeadSkins(27)="ChamelHeadSkins.FMA__038__FemSHcropped"
	ChamelHeadSkins(28)="ChamelHeadSkins.FMA__039__FemSHcropped"
	ChamelHeadSkins(29)="ChamelHeadSkins.FWA__040__FemSHcropped"
	ChamelHeadSkins(30)="ChamelHeadSkins.MBF__042__FatMale"
	ChamelHeadSkins(31)="ChamelHeadSkins.FBF__043__FatFem"
	ChamelHeadSkins(32)="ChamelHeadSkins.FMF__044__FatFem"
	ChamelHeadSkins(33)="ChamelHeadSkins.FWA__031__FemSH"
	ChamelHeadSkins(34)="End"
	ChamelHeadMeshPkgs(0)="heads"
	ChameleonOnlyHasGender=Gender_Male
	Gang="Bandits"
	BaseEquipment[0]=(weaponclass=class'Inventory.PistolWeapon')
	HealthMax=130
	BlockMeleeFreq=0.65
	Compassion=0
	WarnPeople=0
	Conscience=0
	Beg=0
	PainThreshold=0.95
	Cajones=0.9
	Rebel=1.000000
	WillDodge=0.400000
	WillKneel=0.200000
	WillUseCover=0.700000
	Stomach=0.8
	TalkWhileFighting=0.200000
	TalkBeforeFighting=0.200000
	
	Begin Object Class=BoltonDef Name=BoltonDef_Bandit_Helmet_Red
		UseChance=0.3
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.Bandit.bandit_crash_helmet',Skin=Texture'PLCharacterSkins.Bandits.bandit_crashhelmet_red',bAttachToHead=True)
		Tag="BanditHelm"
		ExcludeTags(0)="BanditHelm"
		SpecialFlags=(bIsHelmet=true)
	End Object
	Begin Object Class=BoltonDef Name=BoltonDef_Bandit_Helmet_Murika
		UseChance=0.3
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.Bandit.bandit_crash_helmet',Skin=Texture'PLCharacterSkins.Bandits.bandit_helmet_murica',bAttachToHead=True)
		Tag="BanditHelm"
		ExcludeTags(0)="BanditHelm"
		SpecialFlags=(bIsHelmet=true)
	End Object
	Begin Object Class=BoltonDef Name=BoltonDef_Bandit_Mask
		UseChance=0.65
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.Bandit.bandit_leather_mask',bAttachToHead=True)
		Tag="BanditMask"
		ExcludeTags(0)="BanditMask"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDef_Bandit_Shades_Down
		UseChance=0.3
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.Bandit.bandit_shades_down',bAttachToHead=True)
		Tag="BanditShades"
		ExcludeTags(0)="BanditShades"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDef_Bandit_Shades_Up
		UseChance=0.3
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.Bandit.bandit_shades_up',bAttachToHead=True)
		Tag="BanditShades"
		ExcludeTags(0)="BanditShades"
	End Object
	Begin Object Class=BoltonDef Name=BoltonDef_Bandit_Shoulderpad_R
		UseChance=0.75
		Boltons(0)=(Bone="ShoulderR",StaticMesh=StaticMesh'PLCharacterMeshes.Bandit.bandit_shoulderpad_R')
	End Object
	Begin Object Class=BoltonDef Name=BoltonDef_Bandit_Shoulderpad_L
		UseChance=0.75
		Boltons(0)=(Bone="ShoulderL",StaticMesh=StaticMesh'PLCharacterMeshes.Bandit.bandit_shoulderpad_R')
	End Object
	
	RandomizedBoltons(0)=BoltonDef'BoltonDef_Bandit_Helmet_Red'
	RandomizedBoltons(1)=BoltonDef'BoltonDef_Bandit_Helmet_Murika'
	RandomizedBoltons(2)=BoltonDef'BoltonDef_Bandit_Mask'
	RandomizedBoltons(3)=BoltonDef'BoltonDef_Bandit_Shades_Down'
	RandomizedBoltons(4)=BoltonDef'BoltonDef_Bandit_Shades_Up'
	RandomizedBoltons(5)=BoltonDef'BoltonDef_Bandit_Shoulderpad_R'
	RandomizedBoltons(6)=BoltonDef'BoltonDef_Bandit_Shoulderpad_L'
	RandomizedBoltons(7)=None
	
	AmbientGlow=30
	bCellUser=false
}