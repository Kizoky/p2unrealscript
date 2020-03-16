//=============================================================================
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//=============================================================================
class Priest_AMW extends Bystander
	placeable;

defaultproperties
	{
	ActorID="Priest"
	VoicePitch=1.0
	bStartupRandomization=false
	Skins[0]=Texture'ChameleonSkins.Special.Priest'
	Mesh=Mesh'Characters.Avg_M_Jacket_Pants'
	HeadSkin=Texture'ChamelHeadSkins.MWA__007__AvgMale'
	ControllerClass=class'PriestController'
	DialogClass=class'BasePeople.DialogPriest'

	RandomizedBoltons(0)=None
	RandomizedBoltons(1)=None
	RandomizedBoltons(2)=None
	RandomizedBoltons(3)=None
	RandomizedBoltons(4)=None
	RandomizedBoltons(5)=None
	RandomizedBoltons(6)=None
	RandomizedBoltons(7)=None
	}
