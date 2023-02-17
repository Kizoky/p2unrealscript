///////////////////////////////////////////////////////////////////////////////
// Farcii
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Farcii gingers, one of the groups to eventually hate the dude.
///////////////////////////////////////////////////////////////////////////////
class Farcii extends Bystander
	placeable;

defaultproperties
{
	ActorID="Farcii"

	Skins[0]=Texture'PLCharacterSkins.Farcii.XX__380__Avg_M_Jacket_Pants'
	Mesh=SkeletalMesh'Characters.Avg_M_Jacket_Pants'
	ChameleonOnlyHasGender=1
	ChamelHeadSkins[0]="PLCharacterSkins.Farcii_Head.MWA__380__AvgMale"
	ChamelHeadSkins[1]="PLCharacterSkins.Farcii_Head.MWA__381__AvgMale"
	ChamelHeadSkins[2]="PLCharacterSkins.Farcii_Head.MWA__382__AvgMale"
	ChamelHeadSkins[3]="PLCharacterSkins.Farcii_Head.MWA__383__AvgMale"
	ChamelHeadSkins[4]="PLCharacterSkins.Farcii_Head.MWA__384__AvgMale"
	ChamelHeadSkins[5]="PLCharacterSkins.Farcii_Head.MWA__385__AvgMale"
	ChamelHeadSkins[6]="PLCharacterSkins.Farcii_Head.MWA__386__AvgMale"
	ChamelHeadSkins[7]="PLCharacterSkins.Farcii_Head.MWA__387__AvgMale"
	ChamelHeadSkins[8]="End"
	ChameleonSkins(0)="PLCharacterSkins.Farcii.MW__380__Avg_M_Jacket_Pants"
	ChameleonSkins(1)="end"	// end-of-list marker (in case super defines more skins)
	bNoChamelBoltons=true

	bIsTrained=false
	BaseEquipment[0]=(weaponclass=class'AWPStuff.DustersWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.ShotgunWeapon')
	CloseWeaponIndex=0
	FarWeaponIndex=1
	WeapChangeDist=128
	Gang="Farcii"
	HealthMax=100
	PainThreshold=0.95
	Glaucoma=0.8
	Rebel=1.0
	Cajones=0.8
	Stomach=0.9
	Greed=0.8
	ViolenceRankTolerance=1
	TalkWhileFighting=0.3
	TalkBeforeFighting=0.5
	ControllerClass=class'FarciiController'
	bCellUser=false
	AmbientGlow=30
}