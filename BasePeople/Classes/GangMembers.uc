//=============================================================================
// Gangmembers
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// This is a base class for all people of this type and it can also be placed
// into the level to generate a random person of this type.
//
//=============================================================================
class GangMembers extends Bystander
	placeable;


defaultproperties
	{
	ActorID="Gangster"
	bUsePawnSlider=true
	Skins[0]=Texture'ChameleonSkins.XX__149__Fem_LS_Pants'
	Mesh=Mesh'Characters.Fem_LS_Pants'

	ChameleonSkins(0)="ChameleonSkins.FB__132__Fem_LS_Pants"
	ChameleonSkins(1)="ChameleonSkins.FM__131__Fem_LS_Pants"
	ChameleonSkins(2)="ChameleonSkins.MB__051__Avg_M_SS_Pants"
	ChameleonSkins(3)="ChameleonSkins.MM__052__Avg_M_SS_Pants"
	ChameleonSkins(4)="end"	// end-of-list marker (in case super defines more skins)

	bInnocent=true
	}
