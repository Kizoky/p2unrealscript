///////////////////////////////////////////////////////////////////////////////
// BookInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Book inventory item.
//
///////////////////////////////////////////////////////////////////////////////

class BookInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Check to give this inventory item to whom you're talking
// AND pay them money for it. (like an overdue library book or traffic ticket)
// Used when you activate some items
///////////////////////////////////////////////////////////////////////////////
function CheckToGiveToInterestAndPay()
{
	local P2Pawn thispawn;
	local P2Player checkp;
	local PersonController Personc;
	local float AmountTaken;
	local int cashamount;
	local MoneyInv cash;

	thispawn = P2Pawn(Owner);
	checkp = P2Player(thispawn.Controller);
	if(checkp.InterestPawn != None)
	{
		Personc = PersonController(checkp.InterestPawn.Controller);

//			log(self$" interest pawn "$checkp.InterestPawn);
//			log(self$" Person is "$Personc);

		if(Personc != None)
		{
			cash = MoneyInv(checkp.GetInv(class'MoneyInv'.default.InventoryGroup,
							class'MoneyInv'.default.GroupOffset));

			Personc.AcceptItemAndCash(thispawn, self, cash, AmountTaken, Amount);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
Begin:
	CheckToGiveToInterestAndPay();
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'BookPickup'
	Icon=Texture'HUDPack.Icon_Inv_LibraryBook'
	InventoryGroup=102
	GroupOffset=3
	PowerupName="Library Book"
	PowerupDesc="Return this to the Library."
	ExamineAnimType="Book"
	ExamineDialog=Sound'DudeDialog.dude_ithinkineedthat'
	}
