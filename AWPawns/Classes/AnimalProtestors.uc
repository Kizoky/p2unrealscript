//=============================================================================
// AnimalProtestors
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//=============================================================================
class AnimalProtestors extends AWBystander
	placeable;

defaultproperties
{
	ActorID="LAMEProtestor"
	ChameleonSkins(0)="ChameleonSkins.FW__088__Fem_LS_Skirt"
	ChameleonSkins(1)="ChameleonSkins.MW__042__Avg_M_SS_Pants"
	ChameleonSkins(2)="End"
	ChameleonMeshPkgs(0)="Characters"
	Psychic=0.150000
	Cajones=1.000000
	Glaucoma=0.700000
	PainThreshold=1.000000
	Rebel=1.000000
	Talkative=0.000000
	BaseEquipment(0)=(WeaponClass=Class'Inventory.PistolWeapon')
	ViolenceRankTolerance=1
	Gang="AnimalProtestors"
	Mesh=SkeletalMesh'Characters.Avg_M_SS_Pants'
	Skins(0)=Texture'ChameleonSkins.MeatProtestors.XX__151__Avg_M_SS_Pants'
	ControllerClass=Class'AWPawns.AWBystanderController'
	RandomizedBoltons(0)=None
	bAllowRandomGuns=True	// xPatch
}
