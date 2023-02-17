///////////////////////////////////////////////////////////////////////////////
// CoreyDude
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Corey Cruise dude, aka PIII dude
///////////////////////////////////////////////////////////////////////////////
class CoreyDude extends Bystander
	placeable;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActorID="CoreyDude"

	TakesSledgeDamage=0.010000
	TakesMacheteDamage=0.200000
	TakesScytheDamage=0.200000
	TakesDervishDamage=0.200000
	TakesZombieSmashDamage=0.900000
	HeadClass=Class'CoreyDudeHead'
	HeadSkin=Texture'PLCharacterSkins.CoreyCruise.P3DudeHead_Goatee'
	HeadMesh=SkeletalMesh'PLHeads.Head_Corey'
	bRandomizeHeadScale=False
	bIsTrained=True
	bStartupRandomization=False
	TakesMachinegunDamage=0.750000
	ReportLooksRadius=2048.000000
	dialogclass=Class'BasePeople.DialogDude'
	HealthMax=300.000000
	DamageMult=2.400000
	Mesh=SkeletalMesh'Characters.Avg_Dude'
	Skins(0)=Texture'PLCharacterSkins.CoreyCruise.CoreyCruiseDude'
	TransientSoundRadius=1024.000000
	ADJUST_RELATIVE_HEAD_Y=-2

	RandomizedBoltons(0)=None
	bNoChamelBoltons=True
	Boltons(0)=(Bone="CoreyHair",StaticMesh=StaticMesh'PLCharacterMeshes.CoreyCruise.Corey_HairBolton',bAttachToHead=True)
	CrouchHeight=+40.0
	ExtraAnims(2)=MeshAnimation'MP_Characters.Anim_MP'
	AmbientGlow=30
	bCellUser=false
	bNoDismemberment=True
	TakesShotgunHeadShot=0.1
}
