//=============================================================================
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class JunkyardGuy extends Bystander
	placeable;

defaultproperties
	{
	ActorID="JunkyardGuy"
	Mesh=Mesh'Characters.Fat_M_SS_Pants'
	Skins[0]=Texture'ChameleonSkins.MM__107__Fat_M_SS_Pants'
	HeadSkin=Texture'ChamelHeadSkins.Male.MMF__024__FatMale'
	HeadMesh=Mesh'Heads.FatMale'
	bIsFat=true

	bRandomizeHeadScale=false
	bPersistent=true
	bKeepForMovie=true
	bCanTeleportWithPlayer=false

	ControllerClass=class'JunkyardController'
	bIsTrained=false
	BaseEquipment[0]=(weaponclass=class'Inventory.ShotgunWeapon')
	bFriendWithAuthority=true
	bPlayerIsFriend=false
	Gang=""
	bStartupRandomization=false
	HealthMax=200
	PainThreshold=0.95
	Rebel=1.0
	Cajones=1.0
	Stomach=0.95
	TakesShotgunHeadShot=	0.1
	TakesRifleHeadShot=		1.0 //0.2
	TakesShovelHeadShot=	0.3
	TakesOnFireDamage=		0.35
	TakesAnthraxDamage=		0.35
	TakesShockerDamage=		0.1
	TakesPistolHeadShot=	1.0 //0.3
	RandomizedBoltons(0)=None
	RandomizedBoltons(1)=None
	RandomizedBoltons(2)=None
	RandomizedBoltons(3)=None
	RandomizedBoltons(4)=None
	RandomizedBoltons(5)=None
	RandomizedBoltons(6)=None
	RandomizedBoltons(7)=None
	}
