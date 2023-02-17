//=============================================================================
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class PUGamesBoss extends Bystander
	placeable;

defaultproperties
{
	ActorID="PUGamesBoss"

	HeadSkin=Texture'PLCharacterSkins.PuGames.PU_CEO_Head'
	HeadMesh=SkeletalMesh'PLHeads.Head_Sockfer'
	bRandomizeHeadScale=False
	bStartupRandomization=False
	ViolenceRankTolerance=1
	PainThreshold=0.95
	Rebel=1.0
	Cajones=1.0
	Stomach=0.5
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
	TalkWhileFighting=0.250000
	TalkBeforeFighting=0.000000
	Fitness=0.900000
	WeapChangeDist=500.000000
	dialogclass=Class'DialogMale'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.MachineGunWeapon')
	TakesChemDamage=0.300000
	HealthMax=350
	Mesh=SkeletalMesh'Characters.Fat_M_Jacket_Pants'
	bIsFat=true
	Skins(0)=Texture'PLCharacterSkins.PuGames.PU_CEO_Body'
	bNoChamelBoltons=True
	Gang="PuGames"
	ControllerClass=class'BystanderController'
	AmbientGlow=30
	bCellUser=false
}
