//=============================================================================
// MallWorkers
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// This is a base class for all people of this type and it can also be placed
// into the level to generate a random person of this type.
//
//=============================================================================
class MallWorkers extends Bystander
	placeable;


defaultproperties
	{
	ActorID="Employee"
	bUsePawnSlider=true
	Skins[0]=Texture'ChameleonSkins.XX__150__Fem_LS_Pants'
	Mesh=Mesh'Characters.Fem_LS_Pants'

	ChameleonSkins(0)="ChameleonSkins.FM__122__Fem_LS_Pants"
	ChameleonSkins(1)="ChameleonSkins.FW__138__Fem_LS_Pants"
	ChameleonSkins(2)="ChameleonSkins.MW__053__Avg_M_SS_Pants"
	ChameleonSkins(3)="end"	// end-of-list marker (in case super defines more skins)

	bInnocent=true

	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades3'
	RandomizedBoltons(4)=None
	}
