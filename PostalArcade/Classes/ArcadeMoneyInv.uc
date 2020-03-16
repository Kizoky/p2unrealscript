///////////////////////////////////////////////////////////////////////////////
// Token Inventory
// The player activates this to use an ArcadePoint.
///////////////////////////////////////////////////////////////////////////////
class ArcadeMoneyInv extends MoneyInv;

/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Activate()
{
	local ArcadePoint P;
	local PlayerController PC;

	PC = PlayerController(Pawn(Owner).Controller);
	if (PC == None)
		return;

	foreach Owner.TouchingActors(class'ArcadePoint', P)
		if (P.AcceptToken(PC, self))
		{
			ReduceAmount(1);
			return;
		}
}
*/

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	function CheckToPayInterest()
	{
		local ArcadePointPlus P;
		local PlayerController PC;

		PC = PlayerController(Pawn(Owner).Controller);
		if (PC == None)
			return;

		Super.CheckToPayInterest();

		foreach Owner.TouchingActors(class'ArcadePointPlus', P)
			if (P.AcceptToken(PC, self))
			{
				ReduceAmount(P.TokensRequired);
				return;
			}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	InventoryGroup=103
	GroupOffset=52
	PowerupName="Tokens"
	PowerupDesc="For playing various arcade games."
}
