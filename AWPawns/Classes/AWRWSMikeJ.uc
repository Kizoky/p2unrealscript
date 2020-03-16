//=============================================================================
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class AWRWSMikeJ extends AWRWSStaff
	placeable;

defaultproperties
{
	ActorID="MikeJ"
	HeadSkin=Texture'ChamelHeadSkins.Male.MWA__006__AvgMale'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.PistolWeapon')
	BaseEquipment(1)=(WeaponClass=Class'Inventory.MachineGunWeapon')
	//Mesh=SkeletalMesh'Characters.Avg_M_SS_Shorts'
	//Skins(0)=Texture'ChameleonSkins.Special.RWS_Shorts'
	ChameleonSkins[2]="ChameleonSkins2.RWS.MW__206__Avg_M_SS_Shorts"
	bNoChamelBoltons=true
	ControllerClass=class'RWSMikeJController'
}
