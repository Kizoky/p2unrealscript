///////////////////////////////////////////////////////////////////////////////
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// A scientist.
//
///////////////////////////////////////////////////////////////////////////////
class Scientist extends Bystander
	placeable;


function PreBeginPlay()
	{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
	}

defaultproperties
	{
	ActorID="Scientist"
	bUsePawnSlider=true
	Skins[0]=Texture'ChameleonSkins.XX__156__Avg_Dude'
	Mesh=Mesh'Characters.Avg_Dude'

	ChameleonSkins(0)="ChameleonSkins.MW__005__Avg_Dude"
	ChameleonSkins(1)="ChameleonSkins.MW__006__Avg_Dude"
	ChameleonSkins(2)="end"	// end-of-list marker (in case super defines more skins)

	bInnocent=true
	bNoChamelBoltons=True
	}
