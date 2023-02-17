/**
 * HealthVendingMachine
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Here we define our vending machine background and music for weapons vending.
 * for now, we have our item list configurable so there's nothing in here
 *
 * @author Gordon Cheng
 */
class HealthVendingMachine extends P2EVendingMachineTrigger;

function RecordMoneySpent(int MoneyUsed) {
	local P2Player p2p;
	local int i, j;
	local GameState gs;
	
	if (P2GameInfoSingle(Level.Game) != none &&
        P2GameInfoSingle(Level.Game).TheGameState != none &&
		PLGameState(P2GameInfoSingle(Level.Game).TheGameState) != None
		)
	{
		p2p = P2GameInfoSingle(Level.Game).GetPlayer();
		if(Level.NetMode != NM_DedicatedServer ) p2p.GetEntryLevel().GetAchievementManager().UpdateStatInt(p2p, 'PLVendingSpent', MoneyUsed, true);
		PLGameState(P2GameInfoSingle(Level.Game).TheGameState).MoneySpentOnVendors += MoneyUsed;
		
		// Update gamestate quantities
		gs = P2GameInfoSingle(Level.Game).TheGameState;
		for (i = 0; i < gs.VendorInfo.Length; i++)
			for (j = 0; j < ItemList.Length; j++)
				if (gs.VendorInfo[i].PickupClass == ItemList[j].ItemPickupName)
					gs.VendorInfo[i].Quantity = ItemList[j].QuantityAvailable;
	}
}

defaultproperties
{
    bDayInventoryStacks=true

    MondayItemList(0)=(ItemPickupName="Inventory.MedKitPickup",ItemName="Medkit",ItemDescription="Fully heals all bullet, burn, chemical, bludgeon, slashing, and shrapnel wounds",ItemIconName="nathans.Inventory.medkitinv",ItemBuyRate=(ItemPrice=30,ItemAmount=1))
    MondayItemList(1)=(ItemPickupName="Inventory.KevlarPickup",ItemName="Kevlar Armor",ItemDescription="Rugged anti-death gear",ItemIconName="HUDPack.Icons.Icon_Special_Vest",ItemBuyRate=(ItemPrice=50,ItemAmount=1))
    MondayItemList(2)=(ItemPickupName="Inventory.DogTreatBoxPickup",ItemName="Yappee's Dog Treats",ItemDescription="Make a friend for life!",ItemIconName="HUDPack.Icons.Icon_Inv_DogTreats",ItemBuyRate=(ItemPrice=10,ItemAmount=5))
    MondayItemList(3)=(ItemPickupName="Inventory.RadarPickup",ItemName="Bass Sniffer",ItemDescription="Get that slimy bastard with our fish radar!",ItemIconName="HUDPack.Icons.Icon_Inv_Bass_Sniffer",ItemBuyRate=(ItemPrice=15,ItemAmount=60))

    TuesdayItemList(0)=(ItemPickupName="PLInventory.DualWieldPickup",ItemName="Habib's Power Station",ItemDescription="Doubles your penetration power, for pleasing all your wives!\\n-Habib",ItemIconName="MrD_PL_Tex.HUD.Ballz_HUD",ItemBuyRate=(ItemPrice=125,ItemAmount=1),QuantityAvailable=2)
    TuesdayItemList(1)=(ItemPickupName="Inventory.CrackPickup",ItemName="Health Pipe",ItemDescription="Incredible healing vapors*\\n*may cause brain tumors and/or mild retardation",ItemIconName="HUDPack.Icons.Icon_Inv_Crack",ItemBuyRate=(ItemPrice=75,ItemAmount=1),QuantityAvailable=2)
    TuesdayItemList(2)=(ItemPickupName="Inventory.CatnipPickup",ItemName="Catnip",ItemDescription="Spend some quality time with your cat!",ItemIconName="HUDPack.Icons.Icon_Inv_Catnip",ItemBuyRate=(ItemPrice=125,ItemAmount=1),QuantityAvailable=2)

    WednesdayItemList(0)=(ItemPickupName="Inventory.BodyArmorPickup",ItemName="Silicon Carbide Armor",ItemDescription="Even more rugged anti-death gear",ItemIconName="HUDPack.Icons.icon_inv_KevlarHeavy",ItemBuyRate=(ItemPrice=150,ItemAmount=1))
	
	ThursdayItemList(0)=(ItemPickupName="PLInventory.WaterBottlePickup",ItemName="Nuka Aqua",ItemDescription="Stay hydrated with a refreshing bottle of water-like substance!",ItemIconName="PLHud.Icons.Icon_Inv_WaterBottle",ItemBuyRate=(ItemPrice=10,ItemAmount=1))
	
	Background=Texture'PLVendingMenuTextures.Screens.HEALTH_screen_bg'
	MoneyBox=Texture'PLVendingMenuTextures.Screens.cash_bg'
	ItemButton=Texture'PLVendingMenuTextures.Buttons.button_bg'
	ItemBox=Texture'PLVendingMenuTextures.Buttons.button_bg256x256'
    
	Song="mall_muzak1.ogg"
	
	Texture=Texture'PL-KamekTex.Actors.Trigger_HealthVendor'
	
	DrawScale=0.25
	
	HUDIcon=Texture'PLHud.Icons.UseTrigger_HealthVendor'
	
	Message="Press %KEY_InventoryActivate% to buy health and powerups!"
}