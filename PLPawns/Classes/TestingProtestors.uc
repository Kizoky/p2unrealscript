///////////////////////////////////////////////////////////////////////////////
// Testing Protestors
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for animal testing protestors.
///////////////////////////////////////////////////////////////////////////////
class TestingProtestors extends Protestors
	placeable;

defaultproperties
{
	ActorID="TestingProtestors"

	Skins[0]=Texture'PLCharacterSkins.TestingProtestors.XX__300__Avg_M_SS_Pants'
	Mesh=Mesh'Characters.Avg_M_SS_Pants'

	ChameleonSkins(0)="PLCharacterSkins.TestingProtestors.MW__301__Avg_M_SS_Pants"
	ChameleonSkins(1)="PLCharacterSkins.TestingProtestors.FW__302__Fem_LS_Skirt"
	ChameleonSkins(2)="End"
	ChameleonMeshPkgs(0)="Characters"

	Gang="TestingProtestors"
	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades3'
	RandomizedBoltons(4)=None
	AmbientGlow=30
	bCellUser=false
}
