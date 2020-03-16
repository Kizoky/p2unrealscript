//=============================================================================
// Bums
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// This is a base class for all people of this type and it can also be placed
// into the level to generate a random person of this type.
//
//=============================================================================
class Bums extends Bystander
	placeable;

function PreBeginPlay()
	{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
	}

defaultproperties
	{
	ActorID="Bum"
	bUsePawnSlider=true

	// Default to chameleon mode
	Skins[0]=Texture'ChameleonSkins.XX__143__Avg_M_Jacket_Pants'
	Mesh=Mesh'Characters.Avg_M_Jacket_Pants'
	ChameleonSkins(0)="ChameleonSkins.MB__014__Avg_M_Jacket_Pants"
	ChameleonSkins(1)="ChameleonSkins.MW__013__Avg_M_Jacket_Pants"
	ChameleonSkins(2)="end"	// end-of-list marker (in case super defines more skins)
	
	DonutLove=0.8
	Greed=0.9
	bInnocent=true
	}
