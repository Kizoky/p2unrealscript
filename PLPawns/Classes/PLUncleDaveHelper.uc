//=============================================================================
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class PLUncleDaveHelper extends PartnerPawn
	placeable;

defaultproperties
{
	ActorID="PLUncleDave"

	Mesh=Mesh'Characters.Avg_M_SS_Pants'
	Skins[0]=Texture'PLCharacterSkins.UncleDave.UncleDavie'
	HeadSkin=Texture'ChamelHeadSkins.Special.UncleDave'
	HeadMesh=Mesh'Heads.AvgMale'
	ControllerClass=class'PLUncleDaveController'

	bRandomizeHeadScale=false
	bPersistent=true
	bKeepForMovie=true
	bCanTeleportWithPlayer=false

	bIsTrained=true
	BlockMeleeFreq=0.75
	BaseEquipment[0]=(weaponclass=class'Inventory.MachineGunWeapon')
	bPlayerIsFriend=true
	Gang="Fanatics"	// Not technically a Fanatic, but keep him in the same gang so he assists them in battle
	bStartupRandomization=false
	HealthMax=200
	PainThreshold=0.95
	VoicePitch=1.15
	Rebel=1.0
	Cajones=1.0
	Stomach=0.95
	TakesShotgunHeadShot=	0.2
	TakesRifleHeadShot=		0.3
	TakesShovelHeadShot=	0.3
	TakesOnFireDamage=		0.3
	TakesAnthraxDamage=		0.4
	TakesShockerDamage=		0.1
	TakesPistolHeadShot=	0.3
	TakesChemDamage=		0.3

	RandomizedBoltons(0)=None
	RandomizedBoltons(1)=None
	RandomizedBoltons(2)=None
	RandomizedBoltons(3)=None
	RandomizedBoltons(4)=None
	RandomizedBoltons(5)=None
	RandomizedBoltons(6)=None
	RandomizedBoltons(7)=None
	Boltons[0]=(bone="NODE_Parent",staticmesh=staticmesh'PLCharacterMeshes.UncleDave.HugeAfro_Vtex',bCanDrop=false,bAttachToHead=true,Skin=Texture'PLCharacterSkins.UncleDave.Davefro')
	AmbientGlow=30
	ExtraAnims(2)=MeshAnimation'MP_Characters.Anim_MP'
	bMPAnims=true
}
