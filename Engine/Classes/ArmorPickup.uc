class ArmorPickup extends Pickup
	abstract;

function float BotDesireability( pawn Bot )
{
	local Inventory AlreadyHas;
	local Armor AlreadyHasArmor;
	local float desire;
	local bool bChecked;

	desire = MaxDesireability;

	if ( RespawnTime < 10 )
	{
		bChecked = true;
		AlreadyHas = Bot.FindInventoryType(InventoryType); 
		if ( AlreadyHas != None ) 
		{
			if ( Inventory != None )
			{
				if( Inventory.Charge <= AlreadyHas.Charge )
					return -1;
			}
			else if ( InventoryType.Default.Charge <= AlreadyHas.Charge )
				return -1;
		}
	}

	if ( !bChecked )
		AlreadyHasArmor = Armor(Bot.FindInventoryType(InventoryType)); 
	if ( AlreadyHasArmor != None )
		desire *= (1 - AlreadyHasArmor.Charge * AlreadyHasArmor.ArmorAbsorption * 0.00003);
	
	if ( Armor(Inventory) != None )
	{
		// pointing to specific, existing item
		desire *= (Inventory.Charge * 0.005);
		desire *= (Armor(Inventory).ArmorAbsorption * 0.01);
	}
	else
	{
		desire *= (InventoryType.default.Charge * 0.005);
		desire *= (class<Armor>(InventoryType).default.ArmorAbsorption * 0.01);
	}
	return desire;
}
