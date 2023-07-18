///////////////////////////////////////////////////////////////////////////////
// KevlarMesh
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Third person mesh for kevlar as seen attached to someone. 
// This is especially useful in MP so you know when someone has this extra
// advantage.
//
// Undamaged version. Use for first third or so of damage
//
///////////////////////////////////////////////////////////////////////////////
class KevlarMesh extends PeoplePart;


defaultproperties
	{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'MpMeshes.Kevlar.Kevlar_avg'
	Skins[0]=Texture'MP_Misc.Kevlar.Kevlar_1'
	RelativeRotation=(Pitch=-16267,Yaw=32768,Roll=32768)
					// down			back		side
	RelativeLocation=(X=-9.500000,Y=-0.2000,Z=0.600)
	DrawScale3D=(X=1.1,Y=1.2,Z=1.1)
	AmbientGlow=180
	}
