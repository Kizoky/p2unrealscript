///////////////////////////////////////////////////////////////////////////////
// LawmenWaistcoat
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// The long arm of the law in Paradise Lost.
// Equivalent to blue cops in P2.
///////////////////////////////////////////////////////////////////////////////
class LawmenWaistcoat extends LawmenBase
	placeable;

defaultproperties
{
	ActorID="Lawman"

	Skins[0]=Texture'PLCharacterSkins.Lawmen.XX__310__Avg_Lawman_Waistcoat'
//	Mesh=Mesh'PLCharacters.Avg_Lawman_Waistcoat'
	Mesh=Mesh'LawmanCharacters.Avg_Lawman_Waistcoat'

	ChameleonMeshPkgs(0)="LawmanCharacters"
	ChameleonSkins(0)="PLCharacterSkins.Lawmen.MW__313__Avg_Lawman_Waistcoat"
	ChameleonSkins(1)="PLCharacterSkins.Lawmen.MW__314__Avg_Lawman_Waistcoat"
	ChameleonSkins(2)="PLCharacterSkins.Lawmen.MW__315__Avg_Lawman_Waistcoat"
	ChameleonSkins(3)="end"	// end-of-list marker (in case super defines more skins)
	ChamelJacketSkins(0)="PLCharacterSkins.Lawmen.Lawman_Coat_Hidden"
	ChamelJacketSkins(1)="end"

	HealthMax=125
	Reactivity=0.2
	Glaucoma=0.85
	WillDodge=0.25
	DonutLove=0.9

	RandomizedBoltons(0)=None
}
