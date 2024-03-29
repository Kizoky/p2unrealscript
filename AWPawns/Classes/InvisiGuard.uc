//=============================================================================
// InvisiGuard
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Partially visible military/swat guy
//
//=============================================================================
class InvisiGuard extends AWBystander
	placeable;

defaultproperties
{
	ActorID="InvisiGuard"
	StumpClass=Class'StumpBigGuy'
	LimbClass=Class'LimbBigGuy'
	BlockMeleeFreq=0.970000
	HeadSkin=Texture'AW_Characters.Special.Elite_Guard_Head1'
	HeadMesh=SkeletalMesh'heads.Masked'
	bRandomizeHeadScale=False
	boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'boltons.Swat_Goggles',bAttachToHead=True)
	Psychic=0.400000
	Champ=0.700000
	Cajones=0.700000
	Temper=0.350000
	Glaucoma=0.450000
	Rat=1.000000
	Compassion=0.000000
	WarnPeople=0.000000
	Conscience=0.000000
	Beg=0.000000
	PainThreshold=1.000000
	Reactivity=0.750000
	Rebel=1.000000
	WillDodge=0.400000
	WillKneel=0.200000
	WillUseCover=0.800000
	Stomach=1.000000
	Armor=100.000000
	ArmorMax=100.000000
	TalkWhileFighting=0.100000
	TakesShotgunHeadShot=0.250000
	TakesRifleHeadShot=1.0 //0.300000
	TakesPistolHeadShot=0.75
	TakesShovelHeadShot=0.350000
	TakesOnFireDamage=0.400000
	TakesAnthraxDamage=0.500000
	TakesShockerDamage=0.100000
	TalkBeforeFighting=0.100000
	Fitness=0.900000
	dialogclass=Class'BasePeople.DialogMaleMilitary'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.MachineGunWeapon')
	BaseEquipment(1)=(WeaponClass=Class'Inventory.PistolWeapon')
	ViolenceRankTolerance=0
	HealthMax=150.000000
	Gang="PublisherGuard"
	AttackRange=(Min=512.000000,Max=4096.000000)
	ControllerClass=Class'AWPawns.AWMilitaryController'
	Mesh=SkeletalMesh'Characters.Big_M_LS_Pants'
	Skins(0)=Texture'AW_Characters.Special.Elite_Guard_1'
	RandomizedBoltons(0)=None
}
