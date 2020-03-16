//=============================================================================
// Bystanders
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// This is a base class for all people of this type and it can also be placed
// into the level to generate a random person of this type.
//
//=============================================================================
class Bystanders extends Bystander
	placeable;

defaultproperties
	{
	bUsePawnSlider=true

	// Default to chameleon skin and associated mesh
	Skins[0]=Texture'ChameleonSkins.BystandersF.XX__096__Fem_SS_Shorts'
	Mesh=Mesh'Characters.Fem_SS_Shorts'

	ChameleonSkins(0) ="ChameleonSkins.FB__094__Fem_SS_Shorts"
	ChameleonSkins(1) ="ChameleonSkins.MW__022__Avg_M_SS_Pants"
	ChameleonSkins(2) ="ChameleonSkins.FB__112__Fat_F_SS_Pants"
	ChameleonSkins(3) ="ChameleonSkins.MB__015__Avg_M_Jacket_Pants"
	ChameleonSkins(4) ="ChameleonSkins.FB__120__Fem_LS_Pants"
	ChameleonSkins(5) ="ChameleonSkins.MB__026__Avg_M_SS_Pants"
	ChameleonSkins(6) ="ChameleonSkins.FM__095__Fem_SS_Shorts"
	ChameleonSkins(7) ="ChameleonSkins.MB__048__Avg_M_SS_Pants"
	ChameleonSkins(8) ="ChameleonSkins.FM__118__Fem_LS_Pants"
	ChameleonSkins(9) ="ChameleonSkins.MB__060__Avg_M_SS_Shorts"
	ChameleonSkins(10)="ChameleonSkins.FW__083__Fem_LS_Skirt"
	ChameleonSkins(11)="ChameleonSkins.MB__104__Fat_M_SS_Pants"
	ChameleonSkins(12)="ChameleonSkins.FW__084__Fem_LS_Skirt"
	ChameleonSkins(13)="ChameleonSkins.MM__018__Avg_M_Jacket_Pants"
	ChameleonSkins(14)="ChameleonSkins.FW__085__Fem_LS_Skirt"
	ChameleonSkins(15)="ChameleonSkins.MM__027__Avg_M_SS_Pants"
	ChameleonSkins(16)="ChameleonSkins.FW__092__Fem_LS_Skirt"
	ChameleonSkins(17)="ChameleonSkins.MM__102__Fat_M_SS_Pants"
	ChameleonSkins(18)="ChameleonSkins.FW__096__Fem_SS_Shorts"
	ChameleonSkins(19)="ChameleonSkins.MM__061__Avg_M_SS_Shorts"
	ChameleonSkins(20)="ChameleonSkins.FW__113__Fat_F_SS_Pants"
	ChameleonSkins(21)="ChameleonSkins.MM__105__Fat_M_SS_Pants"
	ChameleonSkins(22)="ChameleonSkins.FW__119__Fem_LS_Pants"
	ChameleonSkins(23)="ChameleonSkins.MM__107__Fat_M_SS_Pants"
	ChameleonSkins(24)="ChameleonSkins.FW__124__Fem_LS_Pants"
	ChameleonSkins(25)="ChameleonSkins.MW__016__Avg_M_Jacket_Pants"
	ChameleonSkins(26)="ChameleonSkins.MW__017__Avg_M_Jacket_Pants"
	ChameleonSkins(27)="ChameleonSkins.MW__019__Avg_M_Jacket_Pants"
	ChameleonSkins(28)="ChameleonSkins.MW__021__Avg_M_Jacket_Pants"
	ChameleonSkins(29)="ChameleonSkins.MW__024__Avg_M_SS_Pants"
	ChameleonSkins(30)="ChameleonSkins.MW__025__Avg_M_SS_Pants"
	ChameleonSkins(31)="ChameleonSkins.MW__028__Avg_M_SS_Pants"
	ChameleonSkins(32)="ChameleonSkins.MW__062__Avg_M_SS_Shorts"
	ChameleonSkins(33)="ChameleonSkins.MW__098__Fat_M_Jacket_Pants"
	ChameleonSkins(34)="ChameleonSkins.MW__106__Fat_M_SS_Pants"
	ChameleonSkins(35)="ChameleonSkins.MW__160__Avg_M_SS_Pants"
	ChameleonSkins(36)="ChameleonSkins.FM__082__Fem_LS_Skirt"
	//ChameleonSkins(37)="ChameleonSkins2.Bystanders.MB__207__Tall_M_LS_Pants"
	//ChameleonSkins(38)="ChameleonSkins2.Bystanders.MB__209__Tall_M_SS_Pants"
	//ChameleonSkins(39)="ChameleonSkins2.Bystanders.MM__210__Tall_M_SS_Pants"
	//ChameleonSkins(40)="ChameleonSkins2.Bystanders.MW__208__Tall_M_LS_Pants"
	ChameleonSkins(37)="end"	// end-of-list marker (in case super defines more skins)

	bInnocent=true
	bCellUser=True
	}