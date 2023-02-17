//=============================================================================
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// It's the gimp!
//
//=============================================================================
class PLGimp extends Gimp_AMW;

defaultproperties
{
	ActorID="PLGimp"

	Talkative=0.0
	Beg=0.0
	Champ=0.7
	Cajones=1.0
	PainThreshold=1.0
	Stomach=1.0
	HealthMax=150
	ControllerClass=class'GimpController'
	BaseEquipment[0]=(weaponclass=class'PLInventory.PL_DildoWeapon')
	GroundSpeed=700.0
	RandomizedBoltons(0)=None
	RandomizedBoltons(1)=None
	RandomizedBoltons(2)=None
	RandomizedBoltons(3)=None
	RandomizedBoltons(4)=None
	RandomizedBoltons(5)=None
	RandomizedBoltons(6)=None
	RandomizedBoltons(7)=None
	AmbientGlow=30
	bCellUser=false
}
