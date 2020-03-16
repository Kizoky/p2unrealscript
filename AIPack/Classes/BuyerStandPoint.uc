///////////////////////////////////////////////////////////////////////////////
// Where a buyer stands, before the cashier. 
// When someone hits this, the cashier linked to this will deal with
// them appropriately. Not required to make a queue work, but it does 
// extend QPoint's functionality.
///////////////////////////////////////////////////////////////////////////////
class BuyerStandPoint extends StandHerePoint;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
// External variables

// Internal variables
var CashierController	CashOp;	// Controller for pawn that cares about me
								// This gets linked up by the cashregpoint


///////////////////////////////////////////////////////////////////////////////
// Someone is within range of the cashier
///////////////////////////////////////////////////////////////////////////////
function Touch(Actor Other)
{
	local P2Player p2p;

	if(P2Pawn(Other) != None
		&& CashOp != None)
	{
//		if(P2Player(P2Pawn(Other).Controller) != None)
//		{
//			CashOp.InterestPawn = None; // your interest will get set to the player
				// now as we call this next function, and will force him to get used.
			CashOp.HandleThisPerson(P2Pawn(Other));
//		}
	}
}
///////////////////////////////////////////////////////////////////////////////
// Tell cashier to get off her butt, if somone is using me
///////////////////////////////////////////////////////////////////////////////
function UnTouch(Actor Other)
{
	if(P2Pawn(Other) != None
		&& CashOp != None)
		CashOp.ThisPersonLeftYouWhileHandling(P2Pawn(Other));
}

defaultproperties
{
	bCollideActors=true
	Texture=Texture'PostEd.Icons_256.BuyerStandPoint'
	DrawScale=0.25
}
