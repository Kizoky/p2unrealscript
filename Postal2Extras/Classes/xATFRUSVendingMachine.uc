///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// Updated version of ATFRUSVendingMachine. 
// New class to prevent uncompability with workshop mods.
///////////////////////////////////////////////////////////////////////////////
class xATFRUSVendingMachine extends P2EVendingMachineTrigger;

var array<Item> DLCMondayItemList;
var array<Item> DLCTuesdayItemList;
var array<Item> DLCWednesdayItemList;
var array<Item> DLCThursdayItemList;
var array<Item> DLCFridayItemList;

///////////////////////////////////////////////////////////////////////////////
// Overwritten to add weekend and DLC weapons support.
///////////////////////////////////////////////////////////////////////////////
function InitializeDayItemList() {
    local int i, j, DayIndex;
	local GameState gs;
	local bool AddDLCWeapons;

    if (bInitializedItemList || ItemList.length > 0)
        return;
		
	if(P2GameInfoSingle(Level.Game).TwoWeeksGame())
		AddDLCWeapons = True;

	// Make everything available in Enhanced Game and Weekend
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		|| P2GameInfoSingle(Level.Game).IsWeekend())
		DayIndex = 4;
	else // Based on day
		DayIndex = GetDayIndex();

    if (bDayInventoryStacks) {

        // Add Monday's inventory into the main list
        if (DayIndex >= 0) {

            for (i=0;i<MondayItemList.length;i++) {

                ItemList.Insert(ItemList.length, 1);

                ItemList[ItemList.length-1].ItemPickup = MondayItemList[i].ItemPickup;
                ItemList[ItemList.length-1].ItemName = MondayItemList[i].ItemName;
                ItemList[ItemList.length-1].ItemDescription = MondayItemList[i].ItemDescription;
                ItemList[ItemList.length-1].ItemIcon = MondayItemList[i].ItemIcon;
                ItemList[ItemList.length-1].ItemBuyRate = MondayItemList[i].ItemBuyRate;
                ItemList[ItemList.length-1].ItemSellRate = MondayItemList[i].ItemSellRate;
                ItemList[ItemList.length-1].bWeaponIsAlsoAmmo = MondayItemList[i].bWeaponIsAlsoAmmo;
                ItemList[ItemList.length-1].ItemPickupName = MondayItemList[i].ItemPickupName;
                ItemList[ItemList.length-1].ItemIconName = MondayItemList[i].ItemIconName;
                ItemList[ItemList.length-1].QuantityAvailable = MondayItemList[i].QuantityAvailable;
            }
			
			if (AddDLCWeapons)
			{
				for (i=0;i<DLCMondayItemList.length;i++) {

					ItemList.Insert(ItemList.length, 1);

					ItemList[ItemList.length-1].ItemPickup = DLCMondayItemList[i].ItemPickup;
					ItemList[ItemList.length-1].ItemName = DLCMondayItemList[i].ItemName;
					ItemList[ItemList.length-1].ItemDescription = DLCMondayItemList[i].ItemDescription;
					ItemList[ItemList.length-1].ItemIcon = DLCMondayItemList[i].ItemIcon;
					ItemList[ItemList.length-1].ItemBuyRate = DLCMondayItemList[i].ItemBuyRate;
					ItemList[ItemList.length-1].ItemSellRate = DLCMondayItemList[i].ItemSellRate;
					ItemList[ItemList.length-1].bWeaponIsAlsoAmmo = DLCMondayItemList[i].bWeaponIsAlsoAmmo;
					ItemList[ItemList.length-1].ItemPickupName = DLCMondayItemList[i].ItemPickupName;
					ItemList[ItemList.length-1].ItemIconName = DLCMondayItemList[i].ItemIconName;
					ItemList[ItemList.length-1].QuantityAvailable = DLCMondayItemList[i].QuantityAvailable;
				}
			}
        }

        // Add Tuesday's inventory into the main list
        if (DayIndex >= 1) {

            for (i=0;i<TuesdayItemList.length;i++) {

                ItemList.Insert(ItemList.length, 1);

                ItemList[ItemList.length-1].ItemPickup = TuesdayItemList[i].ItemPickup;
                ItemList[ItemList.length-1].ItemName = TuesdayItemList[i].ItemName;
                ItemList[ItemList.length-1].ItemDescription = TuesdayItemList[i].ItemDescription;
                ItemList[ItemList.length-1].ItemIcon = TuesdayItemList[i].ItemIcon;
                ItemList[ItemList.length-1].ItemBuyRate = TuesdayItemList[i].ItemBuyRate;
                ItemList[ItemList.length-1].ItemSellRate = TuesdayItemList[i].ItemSellRate;
                ItemList[ItemList.length-1].bWeaponIsAlsoAmmo = TuesdayItemList[i].bWeaponIsAlsoAmmo;
                ItemList[ItemList.length-1].ItemPickupName = TuesdayItemList[i].ItemPickupName;
                ItemList[ItemList.length-1].ItemIconName = TuesdayItemList[i].ItemIconName;
                ItemList[ItemList.length-1].QuantityAvailable = TuesdayItemList[i].QuantityAvailable;

                ItemList[ItemList.length-1].ItemBuyRate.ItemPrice += ItemList[ItemList.length-1].ItemBuyRate.PriceIncreasePerDay * (DayIndex - 1);
            }
			
			if (AddDLCWeapons)
			{
				for (i=0;i<DLCTuesdayItemList.length;i++) {

					ItemList.Insert(ItemList.length, 1);

					ItemList[ItemList.length-1].ItemPickup = DLCTuesdayItemList[i].ItemPickup;
					ItemList[ItemList.length-1].ItemName = DLCTuesdayItemList[i].ItemName;
					ItemList[ItemList.length-1].ItemDescription = DLCTuesdayItemList[i].ItemDescription;
					ItemList[ItemList.length-1].ItemIcon = DLCTuesdayItemList[i].ItemIcon;
					ItemList[ItemList.length-1].ItemBuyRate = DLCTuesdayItemList[i].ItemBuyRate;
					ItemList[ItemList.length-1].ItemSellRate = DLCTuesdayItemList[i].ItemSellRate;
					ItemList[ItemList.length-1].bWeaponIsAlsoAmmo = DLCTuesdayItemList[i].bWeaponIsAlsoAmmo;
					ItemList[ItemList.length-1].ItemPickupName = DLCTuesdayItemList[i].ItemPickupName;
					ItemList[ItemList.length-1].ItemIconName = DLCTuesdayItemList[i].ItemIconName;
					ItemList[ItemList.length-1].QuantityAvailable = DLCTuesdayItemList[i].QuantityAvailable;
				}
			}
        }

        // Add Wednesday's inventory into the main list
        if (DayIndex >= 2) {

            for (i=0;i<WednesdayItemList.length;i++) {

                ItemList.Insert(ItemList.length, 1);

                ItemList[ItemList.length-1].ItemPickup = WednesdayItemList[i].ItemPickup;
                ItemList[ItemList.length-1].ItemName = WednesdayItemList[i].ItemName;
                ItemList[ItemList.length-1].ItemDescription = WednesdayItemList[i].ItemDescription;
                ItemList[ItemList.length-1].ItemIcon = WednesdayItemList[i].ItemIcon;
                ItemList[ItemList.length-1].ItemBuyRate = WednesdayItemList[i].ItemBuyRate;
                ItemList[ItemList.length-1].ItemSellRate = WednesdayItemList[i].ItemSellRate;
                ItemList[ItemList.length-1].bWeaponIsAlsoAmmo = WednesdayItemList[i].bWeaponIsAlsoAmmo;
                ItemList[ItemList.length-1].ItemPickupName = WednesdayItemList[i].ItemPickupName;
                ItemList[ItemList.length-1].ItemIconName = WednesdayItemList[i].ItemIconName;
                ItemList[ItemList.length-1].QuantityAvailable = WednesdayItemList[i].QuantityAvailable;

                ItemList[ItemList.length-1].ItemBuyRate.ItemPrice += ItemList[ItemList.length-1].ItemBuyRate.PriceIncreasePerDay * (DayIndex - 2);
            }
			
			if (AddDLCWeapons)
			{
				for (i=0;i<DLCWednesdayItemList.length;i++) {

					ItemList.Insert(ItemList.length, 1);

					ItemList[ItemList.length-1].ItemPickup = DLCWednesdayItemList[i].ItemPickup;
					ItemList[ItemList.length-1].ItemName = DLCWednesdayItemList[i].ItemName;
					ItemList[ItemList.length-1].ItemDescription = DLCWednesdayItemList[i].ItemDescription;
					ItemList[ItemList.length-1].ItemIcon = DLCWednesdayItemList[i].ItemIcon;
					ItemList[ItemList.length-1].ItemBuyRate = DLCWednesdayItemList[i].ItemBuyRate;
					ItemList[ItemList.length-1].ItemSellRate = DLCWednesdayItemList[i].ItemSellRate;
					ItemList[ItemList.length-1].bWeaponIsAlsoAmmo = DLCWednesdayItemList[i].bWeaponIsAlsoAmmo;
					ItemList[ItemList.length-1].ItemPickupName = DLCWednesdayItemList[i].ItemPickupName;
					ItemList[ItemList.length-1].ItemIconName = DLCWednesdayItemList[i].ItemIconName;
					ItemList[ItemList.length-1].QuantityAvailable = DLCWednesdayItemList[i].QuantityAvailable;
				}
			}
        }

        // Add Thursday's inventory into the main list
        if (DayIndex >= 3) {

            for (i=0;i<ThursdayItemList.length;i++) {

                ItemList.Insert(ItemList.length, 1);

                ItemList[ItemList.length-1].ItemPickup = ThursdayItemList[i].ItemPickup;
                ItemList[ItemList.length-1].ItemName = ThursdayItemList[i].ItemName;
                ItemList[ItemList.length-1].ItemDescription = ThursdayItemList[i].ItemDescription;
                ItemList[ItemList.length-1].ItemIcon = ThursdayItemList[i].ItemIcon;
                ItemList[ItemList.length-1].ItemBuyRate = ThursdayItemList[i].ItemBuyRate;
                ItemList[ItemList.length-1].ItemSellRate = ThursdayItemList[i].ItemSellRate;
                ItemList[ItemList.length-1].bWeaponIsAlsoAmmo = ThursdayItemList[i].bWeaponIsAlsoAmmo;
                ItemList[ItemList.length-1].ItemPickupName = ThursdayItemList[i].ItemPickupName;
                ItemList[ItemList.length-1].ItemIconName = ThursdayItemList[i].ItemIconName;
                ItemList[ItemList.length-1].QuantityAvailable = ThursdayItemList[i].QuantityAvailable;

                ItemList[ItemList.length-1].ItemBuyRate.ItemPrice += ItemList[ItemList.length-1].ItemBuyRate.PriceIncreasePerDay * (DayIndex - 3);
            }
			
			if (AddDLCWeapons)
			{
				for (i=0;i<DLCThursdayItemList.length;i++) {

					ItemList.Insert(ItemList.length, 1);

					ItemList[ItemList.length-1].ItemPickup = DLCThursdayItemList[i].ItemPickup;
					ItemList[ItemList.length-1].ItemName = DLCThursdayItemList[i].ItemName;
					ItemList[ItemList.length-1].ItemDescription = DLCThursdayItemList[i].ItemDescription;
					ItemList[ItemList.length-1].ItemIcon = DLCThursdayItemList[i].ItemIcon;
					ItemList[ItemList.length-1].ItemBuyRate = DLCThursdayItemList[i].ItemBuyRate;
					ItemList[ItemList.length-1].ItemSellRate = DLCThursdayItemList[i].ItemSellRate;
					ItemList[ItemList.length-1].bWeaponIsAlsoAmmo = DLCThursdayItemList[i].bWeaponIsAlsoAmmo;
					ItemList[ItemList.length-1].ItemPickupName = DLCThursdayItemList[i].ItemPickupName;
					ItemList[ItemList.length-1].ItemIconName = DLCThursdayItemList[i].ItemIconName;
					ItemList[ItemList.length-1].QuantityAvailable = DLCThursdayItemList[i].QuantityAvailable;
				}
			}
        }

        // Add Friday's inventory into the main list
        if (DayIndex == 4) {

            for (i=0;i<FridayItemList.length;i++) {

                ItemList.Insert(ItemList.length, 1);

                ItemList[ItemList.length-1].ItemPickup = FridayItemList[i].ItemPickup;
                ItemList[ItemList.length-1].ItemName = FridayItemList[i].ItemName;
                ItemList[ItemList.length-1].ItemDescription = FridayItemList[i].ItemDescription;
                ItemList[ItemList.length-1].ItemIcon = FridayItemList[i].ItemIcon;
                ItemList[ItemList.length-1].ItemBuyRate = FridayItemList[i].ItemBuyRate;
                ItemList[ItemList.length-1].ItemSellRate = FridayItemList[i].ItemSellRate;
                ItemList[ItemList.length-1].bWeaponIsAlsoAmmo = FridayItemList[i].bWeaponIsAlsoAmmo;
                ItemList[ItemList.length-1].ItemPickupName = FridayItemList[i].ItemPickupName;
                ItemList[ItemList.length-1].ItemIconName = FridayItemList[i].ItemIconName;
                ItemList[ItemList.length-1].QuantityAvailable = FridayItemList[i].QuantityAvailable;

                ItemList[ItemList.length-1].ItemBuyRate.ItemPrice += ItemList[ItemList.length-1].ItemBuyRate.PriceIncreasePerDay * (DayIndex - 4);
            }
			
			if (AddDLCWeapons)
			{
				for (i=0;i<DLCFridayItemList.length;i++) {

					ItemList.Insert(ItemList.length, 1);

					ItemList[ItemList.length-1].ItemPickup = DLCFridayItemList[i].ItemPickup;
					ItemList[ItemList.length-1].ItemName = DLCFridayItemList[i].ItemName;
					ItemList[ItemList.length-1].ItemDescription = DLCFridayItemList[i].ItemDescription;
					ItemList[ItemList.length-1].ItemIcon = DLCFridayItemList[i].ItemIcon;
					ItemList[ItemList.length-1].ItemBuyRate = DLCFridayItemList[i].ItemBuyRate;
					ItemList[ItemList.length-1].ItemSellRate = DLCFridayItemList[i].ItemSellRate;
					ItemList[ItemList.length-1].bWeaponIsAlsoAmmo = DLCFridayItemList[i].bWeaponIsAlsoAmmo;
					ItemList[ItemList.length-1].ItemPickupName = DLCFridayItemList[i].ItemPickupName;
					ItemList[ItemList.length-1].ItemIconName = DLCFridayItemList[i].ItemIconName;
					ItemList[ItemList.length-1].QuantityAvailable = DLCFridayItemList[i].QuantityAvailable;
				}
			}
        }
    }
    else {

        switch(DayIndex) {
            case 0:
                ItemList = MondayItemList;
                break;

            case 1:
                ItemList = TuesdayItemList;
                break;

            case 2:
                ItemList = WednesdayItemList;
                break;

            case 3:
                ItemList = ThursdayItemList;
                break;

            case 4:
                ItemList = FridayItemList;
                break;
        }
    }
	
    bInitializedItemList = true;
}

defaultproperties
{
	Background=texture'P2ETextures.VendingMachine.ATF_screen_bg'
	//MoneyBox=Texture'xVendingTex.Vending.cash_bg'
	//ItemButton=Texture'xVendingTex.Vending.button_bg'
	ItemBox=Texture'xVendingTex.Vending.button_bg256x256'
    Song="mall_muzak2.ogg"
	
	Texture=Texture'Engine.S_UseTrigger'	
	HUDIcon=Texture'xVendingTex.Vending.Icon_Vendor_ATF'
	DrawScale=0.25
	
	Message="Press %KEY_InventoryActivate% to buy weapons and ammo!"
	
	bDayInventoryStacks=true

    MondayItemList(0)=(ItemPickupName="Inventory.ShockerPickup",ItemName="Shock Rocket",ItemDescription="Perfect for self defense or if you're into that stuff",ItemIconName="HUDPack.Icons.Icon_Weapon_Tazer",ItemBuyRate=(ItemPrice=5))
    MondayItemList(1)=(ItemPickupName="Inventory.PistolPickup",ItemName="Old Faithful Combat Pistol",ItemDescription="Homies trippin? Bust a cap in they ass!",ItemIconName="HUDPack.Icons.Icon_Weapon_Pistol",ItemBuyRate=(ItemPrice=20),QuantityAvailable=5)
    MondayItemList(2)=(ItemPickupName="Inventory.PistolAmmoPickup",ItemName="Pistol Cartridges",ItemDescription=".50 Action Express cartridges",ItemIconName="xVendingTex.Icons.Icon_Pistol_Ammo",ItemBuyRate=(ItemPrice=10,ItemAmount=7),QuantityAvailable=20)
    MondayItemList(3)=(ItemPickupName="Inventory.ShotGunPickup",ItemName="Mansweeper Riot Gun",ItemDescription="Angry mob got you in their sights? Teach'em the Mansweeper way!",ItemIconName="HUDPack.Icons.Icon_Weapon_Shotgun",ItemBuyRate=(ItemPrice=30),QuantityAvailable=5)
    MondayItemList(4)=(ItemPickupName="Inventory.ShotgunAmmoPickup",ItemName="Shotgun Shells",ItemDescription="12 Gauge Shotgun Shells",ItemIconName="xVendingTex.Icons.Icon_Shotgun_Ammo",ItemBuyRate=(ItemPrice=25,ItemAmount=10),QuantityAvailable=10)
    MondayItemList(5)=(ItemPickupName="Inventory.GasCanPickup",ItemName="Gasoline",ItemDescription="Totally doesn't contain any lead",ItemIconName="HUDPack.Icons.Icon_Weapon_Gascan",ItemBuyRate=(ItemPrice=20,ItemAmount=25),bWeaponIsAlsoAmmo=True,QuantityAvailable=2)
    DLCMondayItemList(0)=(ItemPickupName="PLInventory.FGrenadePickup",ItemName="Flashbang Grenades",ItemDescription="Blind'em and bag'em",ItemIconName="MrD_PL_Tex.HUD.SmokeNade_HUD",ItemBuyRate=(ItemPrice=20,ItemAmount=5),bWeaponIsAlsoAmmo=True)
    DLCMondayItemList(1)=(ItemPickupName="PLInventory.BeanBagGunPickup",ItemName="Beanbag Gun",ItemDescription="For when the angry mob happens to be your friends and family",ItemIconName="MrD_PL_Tex.HUD.BeanBagGun_HUD",ItemBuyRate=(ItemPrice=69))
    DLCMondayItemList(2)=(ItemPickupName="PLInventory.BeanBagGunAmmoPickup",ItemName="Beanbag",ItemDescription="Fabic pillow of lead shot",ItemIconName="xVendingTex.Icons.Icon_BeanBag_Ammo",ItemBuyRate=(ItemPrice=15,ItemAmount=15))
	DLCMondayItemList(3)=(ItemPickupName="PLInventory.PL_DildoPickup",ItemName="Dildo",ItemDescription="[insert some penis joke here]",ItemIconName="MrD_PL_Tex.HUD.chud",ItemBuyRate=(ItemPrice=10))
	
    TuesdayItemList(0)=(ItemPickupName="EDStuff.GSelectPickup",ItemName="Machine Pistol",ItemDescription="Fully automatic and fits in your pocket",ItemIconName="EDHud.hud_Glock",ItemBuyRate=(ItemPrice=30),QuantityAvailable=5)
    TuesdayItemList(1)=(ItemPickupName="EDStuff.GSelectAmmoPickup",ItemName="Machine Pistol Cartridges",ItemDescription="9x19mm Parabellum cartridges",ItemIconName="xVendingTex.Icons.Icon_Glock_Ammo",ItemBuyRate=(ItemPrice=19,ItemAmount=15),QuantityAvailable=10)
    TuesdayItemList(2)=(ItemPickupName="Inventory.MachineGunPickup",ItemName="Machine Gun",ItemDescription="Come on. You know you wanna",ItemIconName="HUDPack.Icons.Icon_Weapon_Machinegun",ItemBuyRate=(ItemPrice=40),QuantityAvailable=4)
    TuesdayItemList(3)=(ItemPickupName="Inventory.MachinegunAmmoPickup",ItemName="MachineGun Cartridges",ItemDescription="5.56x45mm cartridges",ItemIconName="xVendingTex.Icons.Icon_MachineGun_Ammo",ItemBuyRate=(ItemPrice=35,ItemAmount=30),QuantityAvailable=12)
    TuesdayItemList(4)=(ItemPickupName="Inventory.GrenadePickup",ItemName="Grenades",ItemDescription="One-step Stump Remover\\n\\nWARNING: Not for consumption",ItemIconName="HUDPack.Icons.Icon_Weapon_Grenade",ItemBuyRate=(ItemPrice=40,ItemAmount=4),bWeaponIsAlsoAmmo=true,QuantityAvailable=20)
	DLCTuesdayItemList(0)=(ItemPickupName="PLInventory.LeverActionShotgunPickup",ItemName="Lever Action Shotgun",ItemDescription="Easily concealed weapon for terminating your enemies",ItemIconName="MrD_PL_Tex.HUD.LeverHUD",ItemBuyRate=(ItemPrice=125))

    WednesdayItemList(0)=(ItemPickupName="EDStuff.MP5Pickup",ItemName="Submachine Gun",ItemDescription="Drug trafficker hated, SWAT approved",ItemIconName="EDHud.hud_mp5",ItemBuyRate=(ItemPrice=50),QuantityAvailable=3)
    WednesdayItemList(1)=(ItemPickupName="EDStuff.MP5AmmoPickup",ItemName="SMG Cartridges",ItemDescription="9x19mm Parabellum cartridges",ItemIconName="xVendingTex.Icons.Icon_MP5_Ammo",ItemBuyRate=(ItemPrice=38,ItemAmount=30),QuantityAvailable=10)
    WednesdayItemList(2)=(ItemPickupName="Inventory.MolotovPickup",ItemName="Molotov Cocktail",ItemDescription="Perfect for the rioter on a budget",ItemIconName="HUDPack.Icons.Icon_Weapon_Molotov",ItemBuyRate=(ItemPrice=20,ItemAmount=5),QuantityAvailable=7)
    DLCWednesdayItemList(0)=(ItemPickupName="PLInventory.RevolverPickup",ItemName="Revolver",ItemDescription="Brings out your inner gunslinger",ItemIconName="MrD_PL_Tex.HUD.Revolver_HUD",ItemBuyRate=(ItemPrice=200))
    DLCWednesdayItemList(1)=(ItemPickupName="PLInventory.RevolverAmmoPickup",ItemName="Revolver Cartridges",ItemDescription=".357 Magnum cartridges",ItemIconName="xVendingTex.Icons.Icon_Revolver_Ammo",ItemBuyRate=(ItemPrice=15,ItemAmount=12))
    DLCWednesdayItemList(2)=(ItemPickupName="PLInventory.PLSwordPickup",ItemName="Katana",ItemDescription="-What does 'katana' mean? \\n-It means 'Japanese sword'.",ItemIconName="PLHud.Icons.Icon_Inv_Katana",ItemBuyRate=(ItemPrice=2500))
    
	ThursdayItemList(0)=(ItemPickupName="Inventory.RiflePickup",ItemName="Pappy's Pride",ItemDescription="Kills potgut real good\\n-Jethro",ItemIconName="HUDPack.Icons.Icon_Weapon_Rifle",ItemBuyRate=(ItemPrice=100),QuantityAvailable=2)
    ThursdayItemList(1)=(ItemPickupName="Inventory.RifleAmmoPickup",ItemName="Hunting Rifle cartridges",ItemDescription=".30-06 cartridges",ItemIconName="xVendingTex.Icons.Icon_Rifle_Ammo",ItemBuyRate=(ItemPrice=85,ItemAmount=5),QuantityAvailable=5)
	ThursdayItemList(2)=(ItemPickupName="Inventory.LauncherPickup",ItemName="Rocket Launcher",ItemDescription="For when you've pissed off a lot of people",ItemIconName="HUDPack.Icons.Icon_Weapon_Launcher",ItemBuyRate=(ItemPrice=350),QuantityAvailable=2)
    ThursdayItemList(3)=(ItemPickupName="Inventory.LauncherAmmoPickup",ItemName="Rocket Fuel",ItemDescription="Fuel for rocket propelled grenades",ItemIconName="xVendingTex.Icons.Icon_Launcher_Ammo",ItemBuyRate=(ItemPrice=100,ItemAmount=50),QuantityAvailable=10)
	
    FridayItemList(0)=(ItemPickupName="Inventory.NapalmPickup",ItemName="Napalm Launcher",ItemDescription="Makes weed removal easy!",ItemIconName="HUDPack.Icons.Icon_Weapon_Napalm",ItemBuyRate=(ItemPrice=250),QuantityAvailable=1)
    FridayItemList(1)=(ItemPickupName="Inventory.NapalmAmmoPickup",ItemName="Napalm Cannisters",ItemDescription="Cannisters of Napalm",ItemIconName="xVendingTex.Icons.Icon_Napalm_Ammo",ItemBuyRate=(ItemPrice=100,ItemAmount=1),QuantityAvailable=12)
	DLCFridayItemList(0)=(ItemPickupName="PLInventory.WeedPickup",ItemName="Weed Whacker",ItemDescription="",ItemIconName="MrD_PL_Tex.HUD.WeedHUD",ItemBuyRate=(ItemPrice=1250))
}