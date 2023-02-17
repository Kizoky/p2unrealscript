///////////////////////////////////////////////////////////////////////////////
// CockButchers
// Copyright 2014, Running With Scissors, Inc.
//
// Butchers for Cock Asian, hence the name
///////////////////////////////////////////////////////////////////////////////
class CockButchers extends Bystander
	placeable;
	
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
}

defaultproperties
{
	ActorID="CockButchers"

	Gang="CockAsian"
	Mesh=SkeletalMesh'Characters.Avg_M_SS_Pants'
	Skins(0)=Texture'PLCharacterSkins.cockasian.MW__306__Avg_M_SS_Pants'
	Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.cockasian.cockhat_avgmale',Skin=Texture'PLCharacterSkins.cockasian.ChicHat',bAttachToHead=True)
	
	bNoChamelBoltons=True

	BaseEquipment[0]=(weaponclass=class'Inventory.PistolWeapon')
	ViolenceRankTolerance=1
	PainThreshold=0.95
	Rebel=1.0
	Cajones=1.0
	Stomach=1.0
	bAngryWithHomeInvaders=true

	ChameleonSkins(0)="PLCharacterSkins.cockasian.MW__306__Avg_M_SS_Pants"
	ChameleonSkins(1)="End"
	ChamelHeadSkins(0)="ChamelHeadSkins.MWA__001__AvgMale"
	ChamelHeadSkins(1)="ChamelHeadSkins.MWA__002__AvgMale"
	ChamelHeadSkins(2)="ChamelHeadSkins.MWA__004__AvgMale"
	ChamelHeadSkins(3)="ChamelHeadSkins.MWA__005__AvgMale"
	ChamelHeadSkins(4)="ChamelHeadSkins.MWA__007__AvgMale"
	ChamelHeadSkins(5)="ChamelHeadSkins.MWA__008__AvgMale"
	ChamelHeadSkins(6)="ChamelHeadSkins.MWA__009__AvgMale"
	ChamelHeadSkins(7)="ChamelHeadSkins.MWA__010__AvgMale"
	ChamelHeadSkins(8)="ChamelHeadSkins.MWA__011__AvgMale"
	ChamelHeadSkins(9)="ChamelHeadSkins.MWA__015__AvgMale"
	ChamelHeadSkins(10)="ChamelHeadSkins.MWA__035__AvgMale"
	ChamelHeadSkins(11)="End"
	AmbientGlow=30
	bCellUser=false
}
