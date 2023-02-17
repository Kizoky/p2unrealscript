//=============================================================================
// FunlandGuard
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
//=============================================================================
class FunlandGuard extends Bystander
	placeable;

defaultproperties
{
	ActorID="FunlandGuard"

	ChamelHeadSkins(0)="ChamelHeadSkins.MWA__002__AvgMale"
	ChamelHeadSkins(1)="ChamelHeadSkins.MMA__003__AvgMale"
	ChamelHeadSkins(2)="ChamelHeadSkins.MWA__004__AvgMale"
	ChamelHeadSkins(3)="ChamelHeadSkins.MWA__005__AvgMale"
	ChamelHeadSkins(4)="ChamelHeadSkins.MWA__015__AvgMale"
	ChamelHeadSkins(5)="ChamelHeadSkins.MWA__007__AvgMale"
	ChamelHeadSkins(6)="ChamelHeadSkins.MWA__008__AvgMale"
	ChamelHeadSkins(7)="ChamelHeadSkins.MWA__009__AvgMale"
	ChamelHeadSkins(8)="ChamelHeadSkins.MWA__010__AvgMale"
	ChamelHeadSkins(9)="ChamelHeadSkins.MWA__011__AvgMale"
	ChamelHeadSkins(10)="End"
	ViolenceRankTolerance=1
	PainThreshold=0.95
	Rebel=1.0
	Cajones=1.0
	Stomach=1.0
	Armor=25
	ArmorMax=25	
	Champ=0.400000
	Temper=0.350000
	Glaucoma=0.450000
	Rat=1.000000
	Compassion=0.000000
	WarnPeople=0.000000
	Conscience=0.000000
	Beg=0.000000
	Reactivity=0.750000
	WillDodge=0.400000
	WillKneel=0.200000
	WillUseCover=0.800000
	TalkWhileFighting=0.100000
	TalkBeforeFighting=0.100000
	Fitness=0.900000
	dialogclass=Class'BasePeople.DialogMaleMilitary'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.PistolWeapon')
	HealthMax=80.000000
	Gang="FunlandGang"
	Mesh=SkeletalMesh'Characters.Avg_M_SS_Pants'
	Skins(0)=Texture'AW_Characters.Special.Bullfish_Security'
	bNoChamelBoltons=True
	AmbientGlow=30
	bCellUser=false
}
