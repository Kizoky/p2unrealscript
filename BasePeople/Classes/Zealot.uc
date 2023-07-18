///////////////////////////////////////////////////////////////////////////////
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
//  Zealots hang out with Uncle Dave at his Waco-like compound.
//
///////////////////////////////////////////////////////////////////////////////
class Zealot extends Bystander
	placeable;


defaultproperties
	{
	ActorID="Zealot"
	Skins[0]=Texture'ChameleonSkins.XX__161__Avg_M_SS_Pants'
	Mesh=Mesh'Characters.Avg_M_SS_Pants'

	ChameleonSkins(0)="ChameleonSkins.FW__090__Fem_LS_Skirt"
	ChameleonSkins(1)="ChameleonSkins.FW__091__Fem_LS_Skirt"
	ChameleonSkins(2)="ChameleonSkins.MW__058__Avg_M_SS_Pants"
	ChameleonSkins(3)="ChameleonSkins.MW__059__Avg_M_SS_Pants"
	ChameleonSkins(4)="end"	// end-of-list marker (in case super defines more skins)

	bIsTrained=false
	BaseEquipment[0]=(weaponclass=class'Inventory.MachinegunWeapon')
	Gang="DaveGang"
	Psychic=0.4
	HealthMax=100
	PainThreshold=0.95
	Glaucoma=0.8
	Rebel=1.0
	Cajones=0.8
	Stomach=0.9
	Greed=0.8
	ViolenceRankTolerance=1

	bNoChamelBoltons=True
	RandomizedBoltons(0)=None
	BlockMeleeFreq=0.25
	bAllowRandomGuns=True	// xPatch
	}
