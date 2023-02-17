///////////////////////////////////////////////////////////////////////////////
// EnsmallenAttachment
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// 3rd person actor for ensmallen cure
///////////////////////////////////////////////////////////////////////////////
class EnsmallenAttachment extends P2WeaponAttachment;

defaultproperties
{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'MrD_PL_Mesh.Weapons.Needle_3rd'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=0)
	FiringMode="BATON1"
	WeapClass=class'EnsmallenWeapon'
}
