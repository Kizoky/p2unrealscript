/**
 * ATFRUSVendingMachine
 *
 * Preset vending machines owned by ATF R US placed around town that sells
 * basic weapons that civilians can own, like grenades!
 */
class ATFRUSVendingMachine extends P2EVendingMachineTrigger;

defaultproperties
{
    ItemList(0)=(ItemPickup=class'PistolPickup',ItemName="Old Faithful Combat Pistol",ItemDescription="Homies trippin? Bust a cap in they ass!",ItemIcon=texture'HUDPack.Icons.Icon_Weapon_Pistol',ItemBuyRate=(ItemPrice=20))
    ItemList(1)=(ItemPickup=class'PistolAmmoPickup',ItemName="Pistol Cartridges",ItemDescription=".50 caliber cartridges",ItemIcon=texture'HUDPack.Icons.Icon_Weapon_Pistol',ItemBuyRate=(ItemPrice=20,ItemAmount=20),ItemSellRate=(ItemPrice=10,ItemAmount=20))
    ItemList(2)=(ItemPickup=class'ShotGunPickup',ItemName="Mansweeper Riot Gun",ItemDescription="Angry mob got you in their sights? Teach'em the Mansweeper way!",ItemIcon=texture'HUDPack.Icons.Icon_Weapon_Shotgun',ItemBuyRate=(ItemPrice=30))
    ItemList(3)=(ItemPickup=class'ShotgunAmmoPickup',ItemName="Shotgun Shells",ItemDescription="12 Gauge Shotgun Shells",ItemIcon=texture'HUDPack.Icons.Icon_Weapon_Shotgun',ItemBuyRate=(ItemPrice=20,ItemAmount=12),ItemSellRate=(ItemPrice=10,ItemAmount=12))
    ItemList(4)=(ItemPickup=class'MachineGunPickup',ItemName="Machine Gun",ItemDescription="Come on. You know you wanna",ItemIcon=texture'HUDPack.Icons.Icon_Weapon_Machinegun',ItemBuyRate=(ItemPrice=40))
    ItemList(5)=(ItemPickup=class'MachinegunAmmoPickup',ItemName="MachineGun Cartridges",ItemDescription="5.56x45mm cartridges",ItemIcon=texture'HUDPack.Icons.Icon_Weapon_Machinegun',ItemBuyRate=(ItemPrice=15,ItemAmount=25),ItemSellRate=(ItemPrice=7,ItemAmount=25))
    ItemList(6)=(ItemPickup=class'RiflePickup',ItemName="Pappy's Pride Hunting Rifle",ItemDescription="\"Kills potgut real good!\" -Jethro",ItemIcon=texture'HUDPack.Icons.Icon_Weapon_Rifle',ItemBuyRate=(ItemPrice=100))
    ItemList(7)=(ItemPickup=class'RifleAmmoPickup',ItemName="Rifle Cartridges",ItemDescription=".30-06 cartridges",ItemIcon=texture'HUDPack.Icons.Icon_Weapon_Rifle',ItemBuyRate=(ItemPrice=70,ItemAmount=7),ItemSellRate=(ItemPrice=35,ItemAmount=7))
    ItemList(8)=(ItemPickup=class'GrenadePickup',ItemName="Grenades",ItemDescription="One-step Stump Remover\\n\\nWARNING: Not for consumption",ItemIcon=texture'HUDPack.Icons.Icon_Weapon_Grenade',ItemBuyRate=(ItemPrice=40,ItemAmount=4),ItemSellRate=(ItemPrice=20,ItemAmount=4),bWeaponIsAlsoAmmo=true)

    Background=texture'P2ETextures.VendingMachine.ATF_screen_bg'

    Song="mall_muzak1.ogg"
}