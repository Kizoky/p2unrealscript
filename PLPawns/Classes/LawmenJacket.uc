///////////////////////////////////////////////////////////////////////////////
// LawmenJacket
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// The long arm of the law in Paradise Lost.
// Equivalent to black cops in P2. The longcoat makes them more badass.
///////////////////////////////////////////////////////////////////////////////
class LawmenJacket extends LawmenBase
	placeable;
	
defaultproperties
{
	ActorID="Lawman"

	Skins[0]=Texture'PLCharacterSkins.Lawmen.XX__310__Avg_Lawman_Jacket'
	Mesh=Mesh'PLCharacters.Avg_Lawman_Jacket'

	ChameleonMeshPkgs(0)="PLCharacters"
	ChameleonSkins(0)="PLCharacterSkins.Lawmen.MW__310__Avg_Lawman_Jacket"
	ChameleonSkins(1)="PLCharacterSkins.Lawmen.MW__311__Avg_Lawman_Jacket"
	ChameleonSkins(2)="PLCharacterSkins.Lawmen.MW__312__Avg_Lawman_Jacket"
	ChameleonSkins(3)="end"	// end-of-list marker (in case super defines more skins)
	ChamelJacketSkins(0)="PLCharacterSkins.Lawmen.Lawman_Coat_Black"
	ChamelJacketSkins(1)="PLCharacterSkins.Lawmen.Lawman_Coat_Brown"
	ChamelJacketSkins(2)="end"

	RandomizedBoltons(0)=None
}
