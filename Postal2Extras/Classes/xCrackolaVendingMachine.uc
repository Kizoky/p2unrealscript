///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// xCrackolaVendingMachine
///////////////////////////////////////////////////////////////////////////////
class xCrackolaVendingMachine extends P2EVendingMachineTrigger;

function InitializeDayItemList() 
{
	local int i, j, DayIndex;
	DayIndex = GetDayIndex();

    // A Week In Paradise's Weekend Fix
	switch(DayIndex) 
	{
        case 5:	// Saturnday
            ItemList = MondayItemList;
            break;

        case 6: // Sunday
            ItemList = TuesdayItemList;
            break;
    }
	
	Super.InitializeDayItemList();
}

defaultproperties
{
    bDayInventoryStacks=False

    MondayItemList(0)=(ItemPickupName="Postal2Extras.CrackColaPickup",ItemName="Crackola",ItemDescription="Doubles your fire power!",ItemIconName="xPatchTex.HUD.Icon_Inv_Cola",ItemBuyRate=(ItemPrice=15,ItemAmount=1),QuantityAvailable=3)
    TuesdayItemList(0)=(ItemPickupName="Postal2Extras.CrackColaPickup",ItemName="Crackola",ItemDescription="Doubles your fire power!",ItemIconName="xPatchTex.HUD.Icon_Inv_Cola",ItemBuyRate=(ItemPrice=25,ItemAmount=1),QuantityAvailable=2)
    WednesdayItemList(0)=(ItemPickupName="Postal2Extras.CrackColaPickup",ItemName="Crackola",ItemDescription="Doubles your fire power!",ItemIconName="xPatchTex.HUD.Icon_Inv_Cola",ItemBuyRate=(ItemPrice=35,ItemAmount=1),QuantityAvailable=6)
	ThursdayItemList(0)=(ItemPickupName="Postal2Extras.CrackColaPickup",ItemName="Crackola",ItemDescription="Doubles your fire power!",ItemIconName="xPatchTex.HUD.Icon_Inv_Cola",ItemBuyRate=(ItemPrice=45,ItemAmount=1),QuantityAvailable=3)
	FridayItemList(0)=(ItemPickupName="Postal2Extras.CrackColaPickup",ItemName="Crackola",ItemDescription="Doubles your fire power!",ItemIconName="xPatchTex.HUD.Icon_Inv_Cola",ItemBuyRate=(ItemPrice=69,ItemAmount=1),QuantityAvailable=1)
	
	Background=Texture'xVendingTex.Vending.Cola_screen_bg'
	MoneyBox=Texture'xVendingTex.Vending.cash_bg'
	//ItemButton=Texture'xVendingTex.Vending.button_bg'
	ItemBox=Texture'xVendingTex.Vending.button_bg256x256'
    
	Song="mall_muzak1.ogg"
	
	Texture=Texture'Engine.S_UseTrigger'	
	
	DrawScale=0.25
	
	HUDIcon=Texture'xVendingTex.Vending.Icon_Vendor_Cola'
	
	Message="Press %KEY_InventoryActivate% to buy crackola!"
}