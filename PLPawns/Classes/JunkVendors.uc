///////////////////////////////////////////////////////////////////////////////
// JunkVendors
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Junk vendors in the Trainyard, they sell things like A/C parts and other
// assorted crap, but some of them have useful items. They are well-armed and
// friendly with the Lawmen, so pissing them off is a bad idea.
///////////////////////////////////////////////////////////////////////////////
class JunkVendors extends Bystanders;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActorID="JunkVendors"

	ControllerClass=class'FFCashierController'
	Gang="Lawmen"
	bIsTrained=True
	
	bFriendWithAuthority=true
	ChameleonSkins(0)="ChameleonSkins.MB__014__Avg_M_Jacket_Pants"
	ChameleonSkins(1)="ChameleonSkins.MW__013__Avg_M_Jacket_Pants"
	ChameleonSkins(2)="ChameleonSkins.FM__122__Fem_LS_Pants"
	ChameleonSkins(3)="ChameleonSkins.FW__138__Fem_LS_Pants"
	ChameleonSkins(4)="end"	// end-of-list marker (in case super defines more skins)
	
	bCellUser=False
	BaseEquipment[0]=(weaponclass=class'Inventory.ShotgunWeapon')
	PainThreshold=0.85
	Rebel=1.000000
	Glaucoma=0.8
	Cajones=0.8
	Stomach=0.65
	TalkBeforeFighting=0.75
	AmbientGlow=30
}