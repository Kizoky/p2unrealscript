//=============================================================================
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class Farmer extends Bystander
	placeable;

defaultproperties
{
	ActorID="Farmer"

	HeadSkin=Texture'PLCharacterSkins.Farmer.Farmer_Head'
	HeadMesh=SkeletalMesh'PLHeads.Head_Grandpa'
	//HeadMesh=SkeletalMesh'Heads.AvgMale'
	Skins[0]=Texture'PLCharacterSkins.Farmer.Farmer_Body'
	Mesh=SkeletalMesh'Characters.Avg_Grandpa'
	bRandomizeHeadScale=False
	bStartupRandomization=False
	dialogclass=Class'DialogMale'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.ShotgunWeapon')
	bChameleon=false
	bNoChamelBoltons=True
	Gang="Farmer"
	ControllerClass=class'BystanderController'
	AmbientGlow=30
	bCellUser=false
}
