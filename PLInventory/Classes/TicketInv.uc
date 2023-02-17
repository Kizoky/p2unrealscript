///////////////////////////////////////////////////////////////////////////////
// TicketInv
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Waiting ticket for the chemical plant.
///////////////////////////////////////////////////////////////////////////////
class TicketInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PickupClass=class'TicketPickup'
	Icon=Texture'PL_PlaceholderTex.nssign.hud_ticket_placeholder'
	UseForErrands=1
	Hint1="Your number is 30, apparently."
	bCanThrow=false
	bAllowHints=true
	InventoryGroup=102
	GroupOffset=18
	PowerupName="Waiting Room Ticket"
	PowerupDesc="Your number is 30, apparently!"
}
