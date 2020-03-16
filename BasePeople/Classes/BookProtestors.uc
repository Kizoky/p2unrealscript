//=============================================================================
// BookProtestors
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for the book protestor characters.
//
//=============================================================================
class BookProtestors extends Protestors
	placeable;

defaultproperties
	{
	ActorID="BookProtestor"
	// Default to chameleon mode
	Skins[0]=Texture'ChameleonSkins.XX__160__Fem_LS_Skirt'
	Mesh=Mesh'Characters.Fem_LS_Skirt'
	ChameleonSkins(0)="ChameleonSkins.FW__087__Fem_LS_Skirt"
	ChameleonSkins(1)="ChameleonSkins.MW__041__Avg_M_SS_Pants"
	//ChameleonSkins(2)="ChameleonSkins2.MW__218__Tall_M_SS_Pants"
	ChameleonSkins(2)="end"	// end-of-list marker (in case super defines more skins)

	Glaucoma=0.8
	BaseEquipment[0]=(weaponclass=class'Inventory.ShotgunWeapon')
	Gang="BookProtestors"
	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades3'
	RandomizedBoltons(4)=None
	}
