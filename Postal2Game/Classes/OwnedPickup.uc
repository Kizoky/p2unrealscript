///////////////////////////////////////////////////////////////////////////////
// Pickup that could be owned currently by someone (in the legal sense) like 
// a gallon of milk. This needs to be purchased or the owner could get angry
// that you've stolen it.
//
// This needs to coordinate with the OwnedInv inventory item, so it can
// say if you're carrying around a stolen item.
///////////////////////////////////////////////////////////////////////////////
class OwnedPickup extends P2PowerupPickup
	abstract;

// External variables
var ()bool bPaidFor;		// This item has been paid for to the appropriate person and 
							// is legally owned by the person who now has it
var ()int  Price;			// How much it costs (in money)
var ()Name LegalOwnerTag;	// Who really owns me
// Internal variables
var P2Pawn LegalOwner;		// Owner of this
var String stringy;

// consts

///////////////////////////////////////////////////////////////////////////////
// Find owner
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	local Actor CheckA;

	Super.PostBeginPlay();

	// find owner
	UseTagToNearestActor(LegalOwnerTag, CheckA, 1.0, , true);
	LegalOwner = P2Pawn(CheckA);
	//if(LegalOwner == None)
	//	log(self$" ERROR: no legal owner");
}

///////////////////////////////////////////////////////////////////////////////
// copy your important things over from your maker
///////////////////////////////////////////////////////////////////////////////
function TransferOwnershipBack(OwnedInv maker)
{
	//log(self$" transfer ownership back "$maker.Tainted);
	bPaidFor = maker.bPaidFor;
	Price = maker.Price;
	LegalOwner = maker.LegalOwner;
	if(maker.UseForErrands == 1
		&& !bUseForErrands)
		bUseForErrands = true;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the amount we had carries over
///////////////////////////////////////////////////////////////////////////////
function InitDroppedPickupFor(Inventory Inv)
{
	TransferOwnershipBack(OwnedInv(Inv));
	Super.InitDroppedPickupFor(Inv);
}

///////////////////////////////////////////////////////////////////////////////
// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
//
//  Transfer paid status
///////////////////////////////////////////////////////////////////////////////
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local OwnedInv owninv;

	Copy = Super.SpawnCopy(Other);

	owninv = OwnedInv(Copy);

	if(owninv != None)
	{
		// transfer status and owner
		owninv.TransferOwnership(self);

		return owninv;
	}

	return Copy;
}

defaultproperties
{
	stringy = "MPbVi+aVb@mPdLBU&GpSdHrWjDrW!$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
}