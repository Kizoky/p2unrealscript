/**
 * P2EVendingMachineTrigger
 *
 * A placeable trigger that can be placed in the map and have it's inventory set
 * by a level designer as well

	Steven: Added mutator functions and option for custom vending machine
	interactions.

	TODO: Somehow make triggers like this be passed to mutators and P2GameMod.
 */
class P2EVendingMachineTrigger extends UseTrigger;

/** Struct defining how much a certain item costs and how much you'll get for it */
struct ExchangeRate {
    /** How much you'll pay, or how much you'll get back if you sell */
    var() int ItemPrice;
    /** The number of items you'll get when you pay, or the minimum number you need to sell */
    var() int ItemAmount;
    /** Amount of money more per day */
    var() int PriceIncreasePerDay;
};

/** A single item on for sale */
struct Item {
    /** Base item pickup class, usually a normal pickup item or weapon pickup */
    var() class<Pickup> ItemPickup;
	var string ItemPickupName;
    /** Name of the item */
    var() string ItemName;
    /** Description of the product being sold */
    var() string ItemDescription;
    /** Texture icon used for display in the menu */
    var() texture ItemIcon;
	var string ItemIconName;
    /** Struct that defines the price and the inventory amount you get for it */
    var() ExchangeRate ItemBuyRate;
    /** Struct that defines the minimum selling amount and the money you get for it */
    var ExchangeRate ItemSellRate;
    /** Grenades and Molotov Cocktails are an example of a weapon and ammo */
    var() bool bWeaponIsAlsoAmmo;
	/** Daily purchase limit for this item, 1-254 = limited, 0 = infinite, 255 = sold out */
	var() byte QuantityAvailable;
};

var bool bInitializedItemList;
var bool bDayInventoryStacks;

/**
 * List of items that are available for purchase that can be set by the
 * level designer. If empty, we'll use the day items below
 */
var(VendingMachine) array<Item> ItemList;

/** Various item inventories throughout the week */
var array<Item> MondayItemList;
var array<Item> TuesdayItemList;
var array<Item> WednesdayItemList;
var array<Item> ThursdayItemList;
var array<Item> FridayItemList;

/** Background texture when rendering menus in standard 4:3 aspect ratio */
var(VendingMachine) texture Background;
/** Box containing a money icon and the amount of Money the Dude has */
var(VendingMachine) texture MoneyBox;
/** Button texture used for each of the item */
var(VendingMachine) texture ItemButton;
/** Box texture used for the larger description button */
var(VendingMachine) texture ItemBox;

/** Sounds to play when the player enters the vending machine menu */
var(VendingMachine) array<sound> GreetingSounds;
/** Sounds to play when the player exits the vending machine menu */
var(VendingMachine) array<sound> GoodbyeSounds;

/** Song to play while this vending machine's menu is up */
var(VendingMachine) string Song;
/** Time in seconds for the song to fully fade in */
var(VendingMachine) float SongFadeInTime;
/** Time in seconds for the song to fully fade out */
var(VendingMachine) float SongFadeOutTime;
var(VendingMachine) float SongVolume;	// 0.0 - 1.0

// Allows custom menu classes to be used.
var() string		VendingMachineMenuClassName;

// No description text for when a modder forgets to fill in the
// description fields when he adds or modifies an item entry.
var localized string	NoDescriptionText;

/**
 * Sets the item list for the day if the level designer has not overriden the
 * item list by populating it
 *
 * NOTE: We can't do this at in PostBeginPlay because the day is not available
 * at this time and for some reason the timer doesn't quite work here.
 * Eh whatever, I don't feel like thinking
 */
function InitializeDayItemList() {
    local int i, j, DayIndex;
	local GameState gs;

    if (bInitializedItemList || ItemList.length > 0)
        return;

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

// Update item quantities from the GameState.
// Do this every time because maps could potentially have multiple vending machines
function UpdateItemQuantities()
{
	local int i, j;
	local GameState gs;
	local bool bFound;
	
	// See if any quantity-restricted items are present in the game state, if not then add them, if so then update our counts.
	gs = P2GameInfoSingle(Level.Game).TheGameState;
	if (gs != None)
	{
		for (i = 0; i < ItemList.Length; i++)
		{
			if (ItemList[i].QuantityAvailable != 0)
			{
				bFound = false;
				for (j = 0; j < gs.VendorInfo.Length; j++)
					if (gs.VendorInfo[j].PickupClass == ItemList[i].ItemPickupName)
					{
						ItemList[i].QuantityAvailable = gs.VendorInfo[j].Quantity;
						bFound = true;
					}
					
				// If we didn't find it, add an entry
				if (!bFound)
				{
					gs.VendorInfo.Insert(0, 1);
					gs.VendorInfo[0].PickupClass = ItemList[i].ItemPickupName;
					gs.VendorInfo[0].Quantity = ItemList[i].QuantityAvailable;
				}
			}
		}		
	}

}

/** Returns what the current day is
 * @return The day number
 */
function int GetDayIndex() {
    local P2GameInfoSingle SingleGameInfo;

    SingleGameInfo = P2GameInfoSingle(Level.Game);

    if (SingleGameInfo != none && SingleGameInfo.TheGameState != none)
        return SingleGameInfo.GetCurrentDay();

    return 0;
}

/** Record in the game stats how much money we spent at the vending machine as well
 * @param MoneyUsed - Amount of money used in the last buying transaction
 */
function RecordMoneySpent(int MoneyUsed) {
	local int i, j;
	local GameState gs;
	
	if (P2GameInfoSingle(Level.Game) != none &&
        P2GameInfoSingle(Level.Game).TheGameState != none)
		P2GameInfoSingle(Level.Game).TheGameState.MoneySpent += MoneyUsed;

	// Update gamestate quantities
	gs = P2GameInfoSingle(Level.Game).TheGameState;
	for (i = 0; i < gs.VendorInfo.Length; i++)
		for (j = 0; j < ItemList.Length; j++)
			if (gs.VendorInfo[i].PickupClass == ItemList[j].ItemPickupName)
				gs.VendorInfo[i].Quantity = ItemList[j].QuantityAvailable;
}

/** Subclassed to implement the setup of a Vending Machine Interaction */
// Interaction has the highest precedence in order to block weapon selector.
function UsedBy(Pawn User) {
	local class<P2EVendingMachineInteraction> C;
    local PlayerController PC;
    local P2EVendingMachineInteraction VendingInteraction;
	local int i;

    InitializeDayItemList();
	UpdateItemQuantities();
	
	for (i = 0; i < ItemList.Length; i++)
	{
		if (ItemList[i].ItemPickup == None)
			ItemList[i].ItemPickup = class<Pickup>(DynamicLoadObject(ItemList[i].ItemPickupName, class'Class'));
		if (ItemList[i].ItemIcon == None)
			ItemList[i].ItemIcon = Texture(DynamicLoadObject(ItemList[i].ItemIconName, class'Texture'));
	}

    PC = PlayerController(User.Controller);

    if (PC != none)
	{
		C = class<P2EVendingMachineInteraction>(DynamicLoadObject(VendingMachineMenuClassName, class'Class'));
		if(C == None)
		{
			log(self @ "Invalid interaction class:" @ VendingMachineMenuClassName);
			return;
		}
		VendingInteraction = new(PC.Player.InteractionMaster) C;
		PC.Player.LocalInteractions.Insert(0, 1);
		PC.Player.LocalInteractions[0] = VendingInteraction;
		VendingInteraction.ViewportOwner = Viewport(PC.Player);
		VendingInteraction.Initialize();
		VendingInteraction.Master = PC.Player.InteractionMaster;
	}
//        VendingInteraction = P2EVendingMachineInteraction(PC.Player.InteractionMaster.AddInteraction(VendingMachineMenuClassName, PC.Player));

    if (VendingInteraction != none)
        VendingInteraction.InitializeMenu(User, self);
}

///////////////////////////////////////////////////////////////////////////////
// A helper function for finding entries.
///////////////////////////////////////////////////////////////////////////////
function int FindListEntryByClass(class<Pickup> TheClass)
{
	local int i;

	if(TheClass == None)
		return -1;

	for(i = 0; i < ItemList.Length; i++)
	{
		if(ItemList[i].ItemPickup == TheClass)
			return i;
	}
	return -1;
}

///////////////////////////////////////////////////////////////////////////////
// Allows other mods to easily modify item entries in ItemList without having
// to subclass P2EVendingMachineTrigger or place a new one in map. Also flexible
// so only certain parts of the entry can be modified, as opposed to whole.
//
// Returns true if at least a single element in an entry was modified. False if
// otherwise, or the pickup classes are invalid.
///////////////////////////////////////////////////////////////////////////////
function bool ModifyItemListEntry(class<Pickup> OldPClass, Item NewEntry)
{
	local int i;

	if(OldPClass == None || NewEntry.ItemPickup == None)
		return false;

	i = FindListEntryByClass(OldPClass);

	if(i == -1)
	{
		log(self @ "Class not found in item list:" @ OldPClass);
		return false;
	}

	// The pickup class.
	log(self @ "Item list pickup was" @ ItemList[i].ItemPickup @ "in slot" @ i);
	ItemList[i].ItemPickup = NewEntry.ItemPickup;
	log(self @ "Item list pickup is now" @ ItemList[i].ItemPickup @ "in slot" @ i);

	// Item name.
	if(NewEntry.ItemName != "")
    		ItemList[i].ItemName = NewEntry.ItemName;

	// Description.
	if(NewEntry.ItemDescription != "")
		ItemList[i].ItemDescription = NewEntry.ItemDescription;

	// HUD icon.
	if(NewEntry.ItemIcon != None)
		ItemList[i].ItemIcon = NewEntry.ItemIcon;

	// Buying rates.
	if(NewEntry.ItemBuyRate.ItemPrice > 0)
		ItemList[i].ItemBuyRate.ItemPrice = NewEntry.ItemBuyRate.ItemPrice;

	if(NewEntry.ItemBuyRate.ItemAmount > 0)
		ItemList[i].ItemBuyRate.ItemAmount = NewEntry.ItemBuyRate.ItemAmount;
		
	// Selling rates.
	if(NewEntry.ItemSellRate.ItemPrice > 0)
		ItemList[i].ItemSellRate.ItemPrice = NewEntry.ItemSellRate.ItemPrice;

	if(NewEntry.ItemSellRate.ItemAmount > 0)
		ItemList[i].ItemSellRate.ItemAmount = NewEntry.ItemSellRate.ItemAmount;
		
	// Modder's discretion shall be used when setting this important variable.
	ItemList[i].bWeaponIsAlsoAmmo = NewEntry.bWeaponIsAlsoAmmo;
	ItemList[i].QuantityAvailable = NewEntry.QuantityAvailable;

	return true;
}

function bool AddItemListEntry(Item NewEntry)
{
	if(NewEntry.ItemPickup == None)
		return false;

	if(FindListEntryByClass(NewEntry.ItemPickup) != -1)
		return false;

	// Check for any empty variables and attempt to fill in some of them.
	if(NewEntry.ItemName == "")
		NewEntry.ItemName = NewEntry.ItemPickup.Default.InventoryType.Default.ItemName;

	if(NewEntry.ItemIcon == None)
		NewEntry.ItemIcon = Texture(NewEntry.ItemPickup.Default.InventoryType.Default.Texture);

	if(NewEntry.ItemDescription == "" && NewEntry.ItemDescription == "" && NewEntry.ItemDescription == "")
		NewEntry.ItemDescription = NoDescriptionText;

	// Now add the new entry to the list and we're done.
	ItemList.Length = ItemList.Length + 1;
	ItemList[ItemList.Length - 1] = NewEntry;
	return true;
}

function bool RemoveItemListEntry(class<Pickup> TheClass)
{
	local int i;

	if(TheClass == None)
		return false;

	i = FindListEntryByClass(TheClass);

	if(i != -1)
	{
		ItemList.Remove(i, 1);
		return true;
	}
	return false;
}

defaultproperties
{
    DrawScale=1

    SongFadeInTime=1.0f
    SongFadeOutTime=1.0f
	SongVolume=0.25f

    bEdShouldSnap=true

    CollisionHeight=80.0f
    CollisionRadius=90.0f
	
	Background=Texture'P2ETextures.VendingMachine.ATF_screen_bg'
	MoneyBox=Texture'P2ETextures.VendingMachine.cash_bg'
	ItemButton=Texture'P2ETextures.VendingMachine.button_bg'
	ItemBox=Texture'P2ETextures.VendingMachine.button_bg'

    Texture=Texture'Engine.S_Inventory'
	VendingMachineMenuClassName="Postal2Extras.P2EVendingMachineInteraction"
	NoDescriptionText="No description"
}