///////////////////////////////////////////////////////////////////////////////
// WipeHouseCashier
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Class for Wipe House Cashier.
///////////////////////////////////////////////////////////////////////////////
class WipeHouseCashier extends Bystander
	placeable;

defaultproperties
{
	ActorID="CashierDialogPawn"

	bUsePawnSlider=false
	bInnocent=true
	ControllerClass=class'WipeHouseCashierController'
	Skins[0]=Texture'PLCharacterSkins.WipeHouseSecurity.MW__390__Avg_M_SS_Shorts'
	Mesh=SkeletalMesh'Characters.Avg_M_SS_Shorts'
	DialogClass=class'DialogWipeHouseCashier'
	bStartupRandomization=false
	
	Gang="WipeHouse"

	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades3'
	RandomizedBoltons(4)=None
	bCellUser=false
}
