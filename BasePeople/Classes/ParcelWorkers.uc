//=============================================================================
// ParcelWorkers
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// This is a base class for all people of this type and it can also be placed
// into the level to generate a random person of this type.
//
//=============================================================================
class ParcelWorkers extends Bystander
	placeable;


defaultproperties
	{
	ActorID="Carrier"
	Skins[0]=Texture'ChameleonSkins.XX__153__Fem_SS_Shorts'
	Mesh=Mesh'Characters.Fem_SS_Shorts'

	ChameleonSkins(0)="ChameleonSkins.FB__115__Fat_F_SS_Pants"
	ChameleonSkins(1)="ChameleonSkins.FW__097__Fem_SS_Shorts"
	ChameleonSkins(2)="ChameleonSkins.MB__063__Avg_M_SS_Shorts"
	ChameleonSkins(3)="end"	// end-of-list marker (in case super defines more skins)

	BaseEquipment[0]=(weaponclass=class'Inventory.PistolWeapon')
	bIsTrained=true
	Gang="ParcelGang"
	HealthMax=120
	PainThreshold=0.95
	Rebel=1.0
	Cajones=1.0
	Stomach=0.95

	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades3'
	RandomizedBoltons(4)=None
	BlockMeleeFreq=0.5
	bAllowRandomGuns=True	// xPatch
	}
