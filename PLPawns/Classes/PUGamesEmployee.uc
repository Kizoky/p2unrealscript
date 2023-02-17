///////////////////////////////////////////////////////////////////////////////
// PUGamesEmployee
// Copyright 2014, Running With Scissors, Inc.
//
// Employee of the much-hated PU Games
///////////////////////////////////////////////////////////////////////////////
class PUGamesEmployee extends Bystander
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
	ActorID="PUGamesEmployee"

	Gang="PuGames"
	HomeTag="PuGames"
	Mesh=SkeletalMesh'Characters.Avg_M_SS_Shorts'
	Skins(0)=Texture'PLCharacterSkins.PuGames.XX__320__Avg_M_SS_Shorts'

	bIsTrained=false
	BaseEquipment[0]=(weaponclass=class'Inventory.PistolWeapon')
	Psychic=0.15
	Cajones=1.0
	Rebel=1.0
	PainThreshold=1.0
	Glaucoma=0.8

	ViolenceRankTolerance=1
	bAngryWithHomeInvaders=true

	ChameleonSkins(0)="PLCharacterSkins.PuGames.MW__320__Avg_M_SS_Shorts"
	ChameleonSkins(1)="PLCharacterSkins.PuGames.MW__321__Fat_M_SS_Pants"
	ChameleonSkins(2)="End"
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
	ChamelHeadSkins(11)="ChamelHeadSkins.Male.MWF__025__FatMale"
	ChamelHeadSkins(12)="End"
	AmbientGlow=30
	bCellUser=false
}
