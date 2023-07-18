///////////////////////////////////////////////////////////////////////////////
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
//  Butchershop workers. One of the groups to end up hating the dude.
//
///////////////////////////////////////////////////////////////////////////////
class Slaughterers extends Bystander
	placeable;


function PreBeginPlay()
	{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
	}

defaultproperties
	{
	ActorID="Butcher"
	Skins[0]=Texture'ChameleonSkins.XX__157__Avg_M_SS_Pants'
	Mesh=Mesh'Characters.Avg_M_SS_Pants'

	ChameleonSkins(0)="ChameleonSkins.MW__056__Avg_M_SS_Pants"
	ChameleonSkins(1)="ChameleonSkins.MW__109__Fat_M_SS_Pants"
	ChameleonSkins(2)="end"	// end-of-list marker (in case super defines more skins)

	bIsTrained=false
	BaseEquipment[0]=(weaponclass=class'Inventory.PistolWeapon')
	Gang="ButcherGang"
	HealthMax=100
	PainThreshold=0.95
	Rebel=1.0
	Cajones=1.0
	Stomach=1.0
	ViolenceRankTolerance=1
	bNoChamelBoltons=True
	bAllowRandomGuns=True	// xPatch
	}
