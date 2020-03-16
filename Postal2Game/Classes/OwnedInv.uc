///////////////////////////////////////////////////////////////////////////////
// This is an inventory item, that used to be a OwnedPickup that said it
// was owned by someone else (in the legal sense) and you've have it now.
// It can interface with a Cashier Controller to have BuyIt called and
// actually be purchased.
///////////////////////////////////////////////////////////////////////////////
class OwnedInv extends P2PowerupInv
	abstract;

// External variables

// Internal variables
var travel bool bPaidFor;// This item has been paid for to the appropriate person and 
						// is legally owned by the person who now has it
var travel int  Price;	// How much it costs (in money)
						// This is transferred from the pickup
var P2Pawn LegalOwner;	// Who really owns me
var travel Name LegalOwnerTag;// Tag for who really owns me
var bool bUseCashierHints;	// If this is true, then Hint1 tells you how to give
										// things to the cashier while Hint2 tells you what
										// to do with the thing when you're not at the correct cashier.
var bool bUsePaidHints;	// Whether or not to use the paid hints below
var localized string PaidHint1;	// How to pay for it
var localized string PaidHint2;



///////////////////////////////////////////////////////////////////////////////
// Try to link you tag on creation
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	local Actor CheckA;

	Super.PostBeginPlay();

	// find owner
	if(LegalOwner == None)
	{
		//log(self$" owner tag "$LegalOwnerTag);
		UseTagToNearestActor(LegalOwnerTag, CheckA, 1.0, , true);
		LegalOwner = P2Pawn(CheckA);
		//log(self$" got owner "$LegalOwner);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Reassign your owner if you can
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	local Actor CheckA;

	Super.TravelPostAccept();

	// find owner
	if(LegalOwner == None)
	{
		//log(self$" owner tag "$LegalOwnerTag);
		UseTagToNearestActor(LegalOwnerTag, CheckA, 1.0, , true);
		LegalOwner = P2Pawn(CheckA);
		//log(self$" got owner "$LegalOwner);
	}
}

///////////////////////////////////////////////////////////////////////////////
// copy your important things over from your maker
///////////////////////////////////////////////////////////////////////////////
function TransferOwnership(OwnedPickup maker)
{
	//log(self$" transfer ownership "$maker.Tainted);
	bPaidFor = maker.bPaidFor;
	Price = maker.Price;
	LegalOwner = maker.LegalOwner;
	LegalOwnerTag = maker.LegalOwnerTag;
	if(maker.bUseForErrands)
		UseForErrands = 1;
	else
		UseForErrands = 0;
}

///////////////////////////////////////////////////////////////////////////////
// Check to give this inventory item to whom you're talking
// Used when you activate some items
///////////////////////////////////////////////////////////////////////////////
function CheckToGiveToInterest()
{
	local P2Pawn thispawn;
	local P2Player checkp;
	local PersonController Personc;
	local float AmountTaken;

	thispawn = P2Pawn(Owner);
	checkp = P2Player(thispawn.Controller);
	// If your interest is valid
// not sure this is necessary--
// and if this item has a specified person to go to, then
// check that too.
	if(checkp.InterestPawn != None)
//
//		&& (LegalOwnerTag == "" 
//		|| (LegalOwnerTag != "" 
//		&& LegalOwnerTag == checkp.InterestPawn.Tag)))
	{
		Personc = PersonController(checkp.InterestPawn.Controller);

		if(Personc != None)
		{
			Personc.AcceptItem(thispawn, self, AmountTaken, Amount);
			// Dont reduce the item here, reduce in the cashier that takes it
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Combines all owned invs that are the same
///////////////////////////////////////////////////////////////////////////////
function ConsolidateItems(P2Pawn Other, OwnedInv LikeMe)
{
	local Inventory inv, dinv;

	inv = Other.Inventory;

	if ( inv == None )
		return;

//	log("consolidating with "$LikeMe);

	while(inv != None)
	{
		if(inv != LikeMe
			&& inv.class == LikeMe.class
			&& OwnedInv(inv) != None
			&& OwnedInv(inv).bPaidFor == LikeMe.bPaidFor
			&& OwnedInv(inv).LegalOwner == LikeMe.LegalOwner)
		{
//			log("added in "$inv);
			LikeMe.AddAmount(OwnedInv(inv).Amount);
			// Zero after the transfer. 
			//  For some reason -- investigate?-- no inventory gets deleted even after
			// DeleteInventory is called. It's simply unused.
			OwnedInv(inv).Amount=0;
			dinv = inv;
			inv = inv.Inventory;		// move along

			Other.DeleteInventory(dinv);
			dinv.destroy();
		}
		else
			inv = inv.Inventory;		// move along
	}
}

///////////////////////////////////////////////////////////////////////////////
// Say it's been paid for and all
///////////////////////////////////////////////////////////////////////////////
function BuyIt(P2Pawn Other)
{
	local P2Player p2pl;

	bPaidFor=true;
	LegalOwner = Other;
	
	ConsolidateItems(Other, self);
}

///////////////////////////////////////////////////////////////////////////////
// If legal owner or paid status is same than my status
///////////////////////////////////////////////////////////////////////////////
function bool SameAsMe(pickup Item)
{
	local OwnedPickup ownp;

	ownp = OwnedPickup(Item);
//	log("ownp. paid "$ownp.bPaidFor);
//	log("ownp. legal "$ownp.LegalOwner);

	return (bPaidFor == ownp.bPaidFor
		&& LegalOwner == ownp.LegalOwner);
}

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function CashierGetHints(P2Pawn PawnOwner, out String str1, out String str2, out String str3,
				  out byte InfiniteHintTime)
{
	local P2Player checkp;

	if(!bPaidFor)
	{
		checkp = P2Player(PawnOwner.Controller);

		if(checkp.InterestPawn != None
			&& PersonController(checkp.InterestPawn.Controller) != None
			&& (PersonController(checkp.InterestPawn.Controller).InterestInventoryClass == class))
		{
			str1 = Hint1;
			InfiniteHintTime=1;
		}
		else if(bUsePaidHints
			&& LegalOwner != None)
		{
			str1 = PaidHint1;
			str2 = PaidHint2$Price;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function GetHints(P2Pawn PawnOwner, out String str1, out String str2, out String str3,
				  out byte InfiniteHintTime)
{
	if(bAllowHints)
	{
		if(bUseCashierHints)
			CashierGetHints(PawnOwner, str1, str2, str3, InfiniteHintTime);
		// This happens if the ownership status says it's
		// NOT currently and legally owned by ME.
		else if(!bPaidFor
			&& LegalOwner != None
			&& bUsePaidHints)
		{
			str1 = PaidHint1;
			str2 = PaidHint2$Price;
		}
		else
		{
			str1 = Hint1;
			str2 = Hint2;
			str3 = Hint3;
		}
	}
}

defaultproperties
{
	LegalOwnerTag=""
	PaidHint1 = "Go pay the cashier... or not."
	PaidHint2 = "Price: $"
	bUsePaidHints=true
}