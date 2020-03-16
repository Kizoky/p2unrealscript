//=============================================================================
// BandMembers
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// This is a base class for all people of this type and it can also be placed
// into the level to generate a random person of this type.
//
//=============================================================================
class BandMembers extends Marchers
	placeable;


defaultproperties
	{
	ActorID="BandMember"
	// Default to chameleon mode
	Skins[0]=Texture'ChameleonSkins.XX__141__Avg_M_Jacket_Pants'
	Mesh=Mesh'Characters.Avg_M_Jacket_Pants'
	ChameleonSkins(0)="ChameleonSkins.FW__117__Fem_LS_Pants"
	ChameleonSkins(1)="ChameleonSkins.MW__012__Avg_M_Jacket_Pants"
	ChameleonSkins(2)="ChameleonSkins.MW__099__Fat_M_Jacket_Pants"
	ChameleonSkins(3)="end"	// end-of-list marker (in case super defines more skins)

	ControllerClass=class'BandController'
	bIsTrained=false
	// give band members an instrument (derived classes can assign different instruments)
	Boltons[0]=(bone="instrument",staticmesh=staticmesh'timb_mesh.instruments.saxophone_dj',bCanDrop=true)
	bInnocent=true
	bNoChamelBoltons=True
	bCellUser=False

	// "None" Bolton
	// Useful for stubbing out individual boltons in subclasses without messing up the bolton chain.
	Begin Object Class=BoltonDef Name=BoltonDefNone
		UseChance=0.0
		Tag="None"
	End Object

	RandomizedBoltons(0)=BoltonDef'BoltonDefNone'	// Stubs out the valentine vase but leaves the santa hat
	}
