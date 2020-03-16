///////////////////////////////////////////////////////////////////////////////
// Scissors attachment for 3rd person
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// It's a Scissors in a guy's hand, that you can see in 3rd person
//
///////////////////////////////////////////////////////////////////////////////
class ScissorsAttachment extends P2DualWeaponAttachment;

defaultproperties
	{	
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'TP_Weapons.Scissors3'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	RelativeLocation=(X=0.000000,Y=1.0000,Z=-0.3000)
	FiringMode="SCISSORS1"
	WeapClass=class'ScissorsWeapon'
	}
