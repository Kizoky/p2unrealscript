///////////////////////////////////////////////////////////////////////////////
// Testing Protestors
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for animal testing protestors.
///////////////////////////////////////////////////////////////////////////////
class TestingProtestor_F_NoRand extends TestingProtestors;

defaultproperties
{
	ActorID="TestingProtestors"

	Skins[0]=Texture'PLCharacterSkins.TestingProtestors.FW__302__Fem_LS_Skirt'
	Mesh=Mesh'Characters.Fem_LS_Skirt'
	bStartupRandomization=false
	bCellUser=false
}
