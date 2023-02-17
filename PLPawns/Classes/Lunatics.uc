///////////////////////////////////////////////////////////////////////////////
// Lunatics
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Lunatics who inhabit the asylum. They're *almost* as fucked up in the
// head as I am!
///////////////////////////////////////////////////////////////////////////////
class Lunatics extends Bystander
	placeable;
	
defaultproperties
{
	ActorID="Lunatics"

	Skins[0]=Texture'PLCharacterSkins.Lunatic.XX__370__Avg_M_LS_Pants'
	Mesh=SkeletalMesh'Characters.Avg_M_LS_Pants'
	ChameleonSkins[0]="PLCharacterSkins.Lunatic.FW__372__Fem_LS_Skirt"
	ChameleonSkins[1]="PLCharacterSkins.Lunatic.FW__373__Fem_SS_Pants"
	ChameleonSkins[2]="PLCharacterSkins.Lunatic.MW__370__Avg_M_LS_Pants"
	ChameleonSkins[3]="PLCharacterSkins.Lunatic.MW__371__Avg_M_LS_Pants"
	ChameleonSkins[4]="PLCharacterSkins.Lunatic.MW__374__Avg_M_SS_Pants"
	ChameleonSkins[5]="End"
	
	BlockMeleeFreq=0.2
	BlockMeleeTime=1.0
	bNoChamelBoltons=true
	Cajones=0.8
	Temper=1.0
	Compassion=0.0
	WarnPeople=0.0
	Conscience=0.0
	Rebel=0.9
	Patience=0.0
	bGunCrazy=true
	
	BaseEquipment(0)=(WeaponClass=Class'ScissorsWeapon')
	bPlayerIsEnemy=true
	Gang="Lunatics"
	AmbientGlow=30
	bCellUser=false
}
