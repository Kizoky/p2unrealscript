///////////////////////////////////////////////////////////////////////////////
// PhotoAttachment
// Copyright 2014 Running With Scissors Inc, All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
class PhotoAttachment extends P2WeaponAttachment;

defaultproperties
{	
	DrawType=DT_StaticMesh
	DrawScale=1.0
	StaticMesh=StaticMesh'PL_Weapons_Mesh.Photo.PhotoTP' 
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(X=0.000000,Y=1.0000,Z=-0.3000)
	WeapClass=class'PhotoWeapon'
}
