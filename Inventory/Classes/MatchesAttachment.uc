///////////////////////////////////////////////////////////////////////////////
// Matches attachment for 3rd person
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
//		05/31/02 NPF	Started history, probably won't be updated again until
//							the pace of change slows down.
///////////////////////////////////////////////////////////////////////////////
class MatchesAttachment extends P2WeaponAttachment;

defaultproperties
	{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'TP_Weapons.Matches3'
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	FiringMode="MATCHES1"
	WeapClass=class'MatchesWeapon'
	}
