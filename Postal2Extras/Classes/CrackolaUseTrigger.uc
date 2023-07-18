///////////////////////////////////////////////////////////////////////////////
// Crackola Vending Machine Use Trigger
// by Man Chrzan for xPatch 3.0.
///////////////////////////////////////////////////////////////////////////////
class CrackolaUseTrigger extends UseTrigger; //ATMTrigger;

var() int QuantityAvailable;
var() int ItemPrice;
var() int ItemAmount;
var() class<Pickup> ItemClass;
var() localized string CantAffordMessage, SoldOutMessage;

var MoneyInv UserMoney;

function bool CanAffordItem()
{
	if(UserMoney == None)
		return false;

	return (UserMoney.Amount >= ItemPrice);
}

function UsedBy( Pawn user )
{
	if (bInitiallyActive)
	{
		if(UserMoney == None)
			UserMoney = MoneyInv(user.FindInventoryType(class'MoneyInv'));
		
		//TriggerEvent(Event, self, user);
		if(CanAffordItem())
			AttemptPurchase(user);
		else
		{	
			if( (CantAffordMessage != "") && (user.Instigator != None) )
				user.Instigator.ClientMessage( CantAffordMessage );
		}	
		
		if (QuantityAvailable <= 0)
		{
			bInitiallyActive = false;
			user.Instigator.ClientMessage( SoldOutMessage );
			//bTriggered=True;
			return;
		}
		
		if (bTriggerOnceOnly)
		{
			bInitiallyActive = false;
			//bTriggered=True;
		}
			
		if (ReTriggerDelay > 0)
		{
			bInitiallyActive = false;
			SetTimer(ReTriggerDelay, false);
		}
	}
}

function AttemptPurchase( Pawn User )
{
    local Pickup ItemPickup;
	local P2PowerupPickup PowerPick;
	
    if (ItemClass == none)
        return;	

    ItemPickup = Spawn(ItemClass,,, User.Location);

    if (ItemPickup != none)
        ItemPickup.SetPhysics(PHYS_Falling);
    else
		return;

    UserMoney.Amount -= ItemPrice;
		
	// Gotta do special things with these to get them to pick up instantly.
	PowerPick = P2PowerupPickup(ItemPickup);
	if (PowerPick != None)
	{
		PowerPick.GotoState('Pickup');
		PowerPick.bOKToGrab = true;
	}
    ItemPickup.Touch(User);
		
	// Decrement total quantity
	if (QuantityAvailable != 0)
		QuantityAvailable--;
}

defaultproperties
{
	Message="Press %KEY_InventoryActivate% to buy crackola. Price: $10"
	CantAffordMessage="You don't have enough money!"
	SoldOutMessage="Sold out..."
	
	ItemClass=Class'CrackColaPickup'
	QuantityAvailable=1
	ItemAmount=1
	ItemPrice=10
}