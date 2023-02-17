/**
 * WeaponsVendingMachine
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Here we define our vending machine background and music for weapons vending.
 * for now, we have our item list configurable so there's nothing in here
 *
 * @author Gordon Cheng
 */
class WeaponsVendingMachine extends P2EVendingMachineTrigger;

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

    MondayItemList(0)=(ItemPickupName="Inventory.ShockerPickup",ItemName="Shock Rocket",ItemDescription="Perfect for self defense or if you're into that stuff",ItemIconName="HUDPack.Icons.Icon_Weapon_Tazer",ItemBuyRate=(ItemPrice=69))
    MondayItemList(1)=(ItemPickupName="Inventory.PistolPickup",ItemName="Old Faithful Combat Pistol",ItemDescription="Homies trippin? Bust a cap in they ass!",ItemIconName="HUDPack.Icons.Icon_Weapon_Pistol",ItemBuyRate=(ItemPrice=10))
    MondayItemList(2)=(ItemPickupName="Inventory.PistolAmmoPickup",ItemName="Pistol Cartridges",ItemDescription=".50 Action Express cartridges",ItemIconName="PLHud.Icons.Icon_Pistol_Ammo",ItemBuyRate=(ItemPrice=10,ItemAmount=20))
    MondayItemList(3)=(ItemPickupName="Inventory.ShotGunPickup",ItemName="Mansweeper Riot Gun",ItemDescription="Angry mob got you in their sights? Teach'em the Mansweeper way!",ItemIconName="HUDPack.Icons.Icon_Weapon_Shotgun",ItemBuyRate=(ItemPrice=20))
    MondayItemList(4)=(ItemPickupName="Inventory.ShotgunAmmoPickup",ItemName="Shotgun Shells",ItemDescription="12 Gauge Shotgun Shells",ItemIconName="PLHud.Icons.Icon_Shotgun_Ammo",ItemBuyRate=(ItemPrice=10,ItemAmount=12))
    MondayItemList(5)=(ItemPickupName="Inventory.GasCanPickup",ItemName="Gasoline",ItemDescription="Totally doesn't contain any lead",ItemIconName="HUDPack.Icons.Icon_Weapon_Gascan",ItemBuyRate=(ItemPrice=20,ItemAmount=50),bWeaponIsAlsoAmmo=True)
    MondayItemList(6)=(ItemPickupName="PLInventory.FGrenadePickup",ItemName="Flashbang Grenades",ItemDescription="Blind'em and bag'em",ItemIconName="MrD_PL_Tex.HUD.SmokeNade_HUD",ItemBuyRate=(ItemPrice=20,ItemAmount=5),bWeaponIsAlsoAmmo=True)

    TuesdayItemList(0)=(ItemPickupName="EDStuff.GSelectPickup",ItemName="Glock",ItemDescription="Fully automatic and fits in your pocket",ItemIconName="EDHud.hud_Glock",ItemBuyRate=(ItemPrice=45))
    TuesdayItemList(1)=(ItemPickupName="EDStuff.GSelectAmmoPickup",ItemName="Glock Cartridges",ItemDescription=".45 ACP cartridges",ItemIconName="PLHud.Icons.Icon_Glock_Ammo",ItemBuyRate=(ItemPrice=15,ItemAmount=15))
    TuesdayItemList(2)=(ItemPickupName="Inventory.MachineGunPickup",ItemName="Machine Gun",ItemDescription="Come on. You know you wanna",ItemIconName="HUDPack.Icons.Icon_Weapon_Machinegun",ItemBuyRate=(ItemPrice=40))
    TuesdayItemList(3)=(ItemPickupName="Inventory.MachinegunAmmoPickup",ItemName="MachineGun Cartridges",ItemDescription="5.56x45mm cartridges",ItemIconName="PLHud.Icons.Icon_MachineGun_Ammo",ItemBuyRate=(ItemPrice=15,ItemAmount=25))
    TuesdayItemList(4)=(ItemPickupName="Inventory.GrenadePickup",ItemName="Grenades",ItemDescription="One-step Stump Remover\\n\\nWARNING: Not for consumption",ItemIconName="HUDPack.Icons.Icon_Weapon_Grenade",ItemBuyRate=(ItemPrice=40,ItemAmount=4),bWeaponIsAlsoAmmo=true)
    TuesdayItemList(5)=(ItemPickupName="Inventory.LauncherPickup",ItemName="Rocket Launcher",ItemDescription="For when you've pissed off a lot of people",ItemIconName="HUDPack.Icons.Icon_Weapon_Launcher",ItemBuyRate=(ItemPrice=150))
    TuesdayItemList(6)=(ItemPickupName="Inventory.LauncherAmmoPickup",ItemName="Rocket Fuel",ItemDescription="Fuel for rocket propelled grenades",ItemIconName="PLHud.Icons.Icon_Launcher_Ammo",ItemBuyRate=(ItemPrice=15,ItemAmount=50))

    WednesdayItemList(0)=(ItemPickupName="PLInventory.LeverActionShotgunPickup",ItemName="Lever Action Shotgun",ItemDescription="Easily concealed weapon for terminating your enemies",ItemIconName="MrD_PL_Tex.HUD.LeverHUD",ItemBuyRate=(ItemPrice=125))
    WednesdayItemList(1)=(ItemPickupName="EDStuff.MP5Pickup",ItemName="MP5",ItemDescription="Drug trafficker hated, SWAT approved",ItemIconName="EDHud.hud_mp5",ItemBuyRate=(ItemPrice=60))
    WednesdayItemList(2)=(ItemPickupName="EDStuff.MP5AmmoPickup",ItemName="MP5 Cartridges",ItemDescription="9x19mm Parabellum cartridges",ItemIconName="PLHud.Icons.Icon_MP5_Ammo",ItemBuyRate=(ItemPrice=15,ItemAmount=25))
    WednesdayItemList(3)=(ItemPickupName="Inventory.MolotovPickup",ItemName="Molotov Cocktail",ItemDescription="Perfect for the rioter on a budget",ItemIconName="HUDPack.Icons.Icon_Weapon_Molotov",ItemBuyRate=(ItemPrice=20,ItemAmount=5))

    ThursdayItemList(0)=(ItemPickupName="PLInventory.RevolverPickup",ItemName="Revolver",ItemDescription="Brings out your inner gunslinger",ItemIconName="MrD_PL_Tex.HUD.Revolver_HUD",ItemBuyRate=(ItemPrice=200))
    ThursdayItemList(1)=(ItemPickupName="PLInventory.RevolverAmmoPickup",ItemName="Revolver Cartridges",ItemDescription=".357 Magnum cartridges",ItemIconName="PLHud.Icons.Icon_Revolver_Ammo",ItemBuyRate=(ItemPrice=15,ItemAmount=12))
    ThursdayItemList(2)=(ItemPickupName="Inventory.RiflePickup",ItemName="Pappy's Pride",ItemDescription="Kills potgut real good\\n-Jethro",ItemIconName="HUDPack.Icons.Icon_Weapon_Rifle",ItemBuyRate=(ItemPrice=80))
    ThursdayItemList(3)=(ItemPickupName="Inventory.RifleAmmoPickup",ItemName="Hunting Rifle cartridges",ItemDescription=".30-06 cartridges",ItemIconName="PLHud.Icons.Icon_Rifle_Ammo",ItemBuyRate=(ItemPrice=15,ItemAmount=7))
    ThursdayItemList(4)=(ItemPickupName="Inventory.NapalmPickup",ItemName="Napalm Launcher",ItemDescription="Makes weed removal easy!",ItemIconName="HUDPack.Icons.Icon_Weapon_Napalm",ItemBuyRate=(ItemPrice=150))
    ThursdayItemList(5)=(ItemPickupName="Inventory.NapalmAmmoPickup",ItemName="Napalm Cannisters",ItemDescription="Cannisters of Napalm",ItemIconName="PLHud.Icons.Icon_Napalm_Ammo",ItemBuyRate=(ItemPrice=10,ItemAmount=2))
    ThursdayItemList(6)=(ItemPickupName="PLInventory.BeanBagGunPickup",ItemName="Beanbag Gun",ItemDescription="For when the angry mob happens to be your friends and family",ItemIconName="MrD_PL_Tex.HUD.BeanBagGun_HUD",ItemBuyRate=(ItemPrice=175))
    ThursdayItemList(7)=(ItemPickupName="PLInventory.BeanBagGunAmmoPickup",ItemName="Beanbag",ItemDescription="Fabic pillow of lead shot",ItemIconName="PLHud.Icons.Icon_BeanBag_Ammo",ItemBuyRate=(ItemPrice=15,ItemAmount=15))
	
	Background=Texture'PLVendingMenuTextures.Screens.ATF_screen_bg'
	MoneyBox=Texture'PLVendingMenuTextures.Screens.cash_bg'
	ItemButton=Texture'PLVendingMenuTextures.Buttons.button_bg'
	ItemBox=Texture'PLVendingMenuTextures.Buttons.button_bg256x256'
    
	Song="mall_muzak1.ogg"
	
	Texture=Texture'PL-KamekTex.Actors.Trigger_WeaponsVendor'
	
	DrawScale=0.25
	
	HUDIcon=Texture'PLHud.Icons.UseTrigger_WeaponsVendor'
	
	Message="Press %KEY_InventoryActivate% to buy weapons and ammo!"
}