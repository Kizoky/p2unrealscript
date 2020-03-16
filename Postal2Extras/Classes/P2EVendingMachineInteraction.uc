/**
 * P2EVendingMachineInteraction
 *
 * Vending Machine Interaction that features item boxes that the player can
 * click to purchase or sell items
 *
 * NOTE: I implemented code to handle buttons a lot easier in future
 * Interactions, so that's why it's a bit messy here. I'd convert stuff over
 * but it's not really worth the time or effort since this already works fine.
 */
class P2EVendingMachineInteraction extends P2EInteraction;

const INDEX_NONE = -1;
const INDEX_EXIT = -2;

/** An extension of DrawInfo to include a text offset */
// Steven: Changed all vector2d to vector so we can use all the vector operators
// when needed.
struct TextBoxDrawInfo {
    /** Drawing position on the HUD in terms of percentage */
    var vector Pos;
    /** X and Y drawing scale for rendering both textures and text */
    var vector Scale;
    /** Offset from the box's location to start drawing the text */
    var vector TextOffset;
    /** Scale of the text inside the box */
    var vector TextScale;
};

/** Font to use for menu text rendering */
var Font MenuFont;

/** Currently highlighted item button */
var int SelectedItemButton;
/** Item button the joystick user wishes to select */
var int DesiredItemButton;
/** Range from 0.0f to some negative value we should scroll */
var Range ItemButtonScrollRange;
/** Screen percentage that's the destination value for ItemButtonScrollCurOffset */
var float ItemButtonScrollOffset;
/** Current screen percentage that's going to be updated with Hooke's Law */
var float ItemButtonScrollCurOffset;
/** Screen percentage to move up or down when the mouse wheel moves */
var float ItemButtonScrollIncrement;
/** Strength of the imaginary spring that scrolls the menu up and down */
var float ItemButtonScrollSpringConstant;
/** Screen percentage we move down for each item button */
var float ItemButtonOffset;
/** Render settings for the base item button position, scaling, and text offset */
var TextBoxDrawInfo ItemButton;

/** Money icon to draw to tell the player how much cash s/he has */
//var texture MoneyTexture;
/** Draw scale for the money icon */
//var DrawInfo MoneyIcon;
/** Render settings for the box containing detailed information on the item */
var TextBoxDrawInfo MoneyBox;

/** Screen percentage to move down for each line */
var float ItemInfoDescriptionOffset;
/** Draw scale to use for items that are tall */
var vector ItemInfoIconTallScale;
/** Render settings for the info box about the highlighted item */
var DrawInfo ItemInfoBox;
/** Render settings for the icon */
var DrawInfo ItemInfoIcon;
/** Render settings for the item's name */
var DrawInfo ItemInfoName;
/** Render settings for the item's description */
var DrawInfo ItemInfoDescription;
/** Render settings for the item's cost and quantity recieved for it */
var DrawInfo ItemInfoBuy;
/** Render settings for the item's resale quantity and value */
var DrawInfo ItemInfoSell;
/** Render settings for the player's current inventory count on the item */
var DrawInfo ItemInfoInv;
/** Render settings for the item's max quantity */
var DrawInfo ItemInfoQuantity;

/** Whether or not we can play the greeting */
var bool bPlayGreeting;
/** Time in seconds before the greeting plays */
var float GreetingDelay;

/** Time in seconds before the hints are taken down */
var float VendingHintTime;
/** Screen percentage to move down for each hint line */
var float VendingHintOffset;
/** Render settings for control hints on how to use the menu */
var DrawInfo VendingHint;

/** Whether or not the exit button has been highlighted */
var bool bExitButtonHighlighted;
/** Menu exit button, to exit the menu! */
var TextBoxDrawInfo ExitButton;

/** Help box */
var TextBoxDrawInfo HelpBox;

/** Pawn object currently using this vending machine, used to access his inventory */
var Pawn MenuUser;
/** Money object owned by the user we're gonna charge to */
var MoneyInv MenuUserMoney;
/** P2EVendingMachineTrigger object that triggered this interaction */
var P2EVendingMachineTrigger VMT;

/** Hint texts for mouse and joystick */
const HINT_LINES_MAX = 2;
var localized string HintTextMouse[HINT_LINES_MAX], HintTextJoystick[HINT_LINES_MAX];

var Sound			BuySuccessfulSound, ItemSelectedSound, SellSuccessfulSound;

/** Called to initialize the interaction with the given users and Trigger
 * @param User - Pawn object currently using this menu
 * @param VendingTrigger - P2EVendingMachineTrigger object to use information from
 */
function InitializeMenu(Pawn User, P2EVendingMachineTrigger VendingTrigger) {
    MenuUser = User;
    VMT = VendingTrigger;
    MenuUserMoney = MoneyInv(MenuUser.FindInventoryType(class'MoneyInv'));

    ItemButtonScrollRange.Max = 0.0f;
    ItemButtonScrollRange.Min = FMin(-((ItemButtonOffset * VMT.ItemList.length) - 1.0f + ItemButton.Pos.Y), 0.0f);

    PauseGame();

    if (VMT != none) {
        PlaySong(VMT.Song, VMT.SongFadeInTime, VMT.SongVolume);

        bPlayGreeting = true;
        GreetingDelay = 0.1;
    }

	UWindowRootWindow(Master.BaseMenu).bAllowJoyMouse = true;
}

function bool CanAffordItem(P2EVendingMachineTrigger.Item Tmp)
{
	if(MenuUserMoney == None)
		return false;
		
	// Say they can't afford it, if the quantity is less than 0 (sold out)
	if (Tmp.QuantityAvailable == 255)
		return false;

	return (MenuUserMoney.Amount >= Tmp.ItemBuyRate.ItemPrice);
}

// Disallow purchase of certain items under certain circumstances
function bool DisallowPurchase()
{
	local class<P2PowerupPickup> PowerPick;
	local Ammunition AmmoInv;
	local class<Ammo> AmmoPick;
	local Inventory Inv;
	
	PowerPick = class<P2PowerupPickup>(VMT.ItemList[SelectedItemButton].ItemPickup);
	if (PowerPick != None && MenuUser != None)
	{
		// Kevlar and body armor: no purchase if the dude wouldn't get any more armor than he already has
		if (class<KevlarPickup>(PowerPick) != None
			&& P2Pawn(MenuUser).Armor >= class<KevlarPickup>(PowerPick).Default.ArmorAmount)
			return true;
			
		// Medkits: disallow at max health
		if (class<MedkitPickup>(PowerPick) != None
			&& MenuUser.Health >= FPSPawn(MenuUser).HealthMax)
			return true;
			
	}
	// Ammo: disallow at full ammo
	AmmoPick = class<Ammo>(VMT.ItemList[SelectedItemButton].ItemPickup);
	if (AmmoPick != None && MenuUser != None)
	{
		for (Inv = MenuUser.Inventory; Inv != None; Inv = Inv.Inventory)
			if (Ammunition(Inv) != None && AmmoPick.Default.InventoryType == Inv.Class)
			{
				AmmoInv = Ammunition(Inv);
				if (AmmoInv.AmmoAmount >= AmmoInv.MaxAmmo)
					return true;
				else
					return false;
			}
	}
	
	return false;
}

// Steven: Check to make sure the dude cannot buy if he's maxed out or already
// has the weapon in question (e.g. baton and shovel).
//
// TODO: Maybe spawn the inventory actor rather than a pickup.
function AttemptPurchase() {
    local int ItemAmount, ItemPrice;
    local Pickup ItemPickup;
	local P2PowerupPickup PowerPick;
    local class<Pickup> ItemClass;
	local Inventory MyItem;

    if (SelectedItemButton != INDEX_NONE && MenuUser != none && MenuUserMoney != none &&
        VMT != none && MenuUserMoney.Amount >= VMT.ItemList[SelectedItemButton].ItemBuyRate.ItemPrice
		&& VMT.ItemList[SelectedItemButton].QuantityAvailable != 255 && !DisallowPurchase()) {
        ItemClass = VMT.ItemList[SelectedItemButton].ItemPickup;

        if (ItemClass == none)
            return;

        ItemAmount = VMT.ItemList[SelectedItemButton].ItemBuyRate.ItemAmount;
        ItemPrice = VMT.ItemList[SelectedItemButton].ItemBuyRate.ItemPrice;

	MyItem = MenuUser.FindInventoryType(ItemClass.Default.InventoryType);

	if(MyItem != None)
	{
		if(P2Weapon(MyItem) != None)
		{
			// Should request to dev team that AddAmmo() truly return false if maxed out!!!
			if(!(P2Weapon(MyItem).AmmoType.AmmoAmount < P2AmmoInv(P2Weapon(MyItem).AmmoType).MaxAmmo)
			|| (P2AmmoInv(P2Weapon(MyItem).AmmoType).bInfinite))
				return;
		}
		else if(P2PowerupInv(MyItem) != None)
		{
			if(!(P2PowerupInv(MyItem).MaxAmount == 0) && !(P2PowerupInv(MyItem).Amount < P2PowerupInv(MyItem).MaxAmount))
				return;
		}
	}
        ItemPickup = VMT.Spawn(ItemClass,,, MenuUser.Location);

        if (ItemPickup != none)
            ItemPickup.SetPhysics(PHYS_Falling);
        else
            return;

        if (!ClassIsChildOf(ItemClass, class'WeaponPickup') ||
            VMT.ItemList[SelectedItemButton].bWeaponIsAlsoAmmo) {
            if (Ammo(ItemPickup) != none)
                Ammo(ItemPickup).AmmoAmount = ItemAmount;

            if (P2WeaponPickup(ItemPickup) != none)
                P2WeaponPickup(ItemPickup).AmmoGiveCount = ItemAmount;

            if (P2PowerupPickup(ItemPickup) != none)
                P2PowerupPickup(ItemPickup).AmountToAdd = ItemAmount;
        }

        MenuUserMoney.Amount -= ItemPrice;
		// Gotta do special things with these to get them to pick up instantly.
		PowerPick = P2PowerupPickup(ItemPickup);
		if (PowerPick != None)
		{
			PowerPick.GotoState('Pickup');
			PowerPick.bOKToGrab = true;
		}
        ItemPickup.Touch(MenuUser);
		
		// Decrement total quantity
		if (VMT.ItemList[SelectedItemButton].QuantityAvailable != 0)
		{
			VMT.ItemList[SelectedItemButton].QuantityAvailable--;
			// if we sell out set it to -1, NOT 0 - 0 means infinite
			if (VMT.ItemList[SelectedItemButton].QuantityAvailable == 0)
				VMT.ItemList[SelectedItemButton].QuantityAvailable = 255;
		}
        VMT.RecordMoneySpent(ItemPrice);

	GetSoundActor().PlaySound(BuySuccessfulSound);
    }
}

/**
 * Attempt to sell the currently highlighted product type in your inventory
 *
 * Not used for Paradise Lost in that we don't want the player to be able to
 * sell items such as ammunition and various powerups
 */
function AttemptSell() {
    local bool bSaleSuccessful;
    local int ItemAmount, ItemValue;
    local Inventory InvItem;
    local class<Pickup> ItemClass;

    if (SelectedItemButton != INDEX_NONE && MenuUser != none) {
        ItemClass = VMT.ItemList[SelectedItemButton].ItemPickup;
        ItemAmount = VMT.ItemList[SelectedItemButton].ItemSellRate.ItemAmount;
        ItemValue = VMT.ItemList[SelectedItemButton].ItemSellRate.ItemPrice;
        InvItem = MenuUser.FindInventoryType(ItemClass.default.InventoryType);

        if (InvItem == none)
            return;

        if (VMT.ItemList[SelectedItemButton].bWeaponIsAlsoAmmo &&
            Weapon(InvItem) != none && Weapon(InvItem).AmmoType != none)
            InvItem = Weapon(InvItem).AmmoType;

        if (Ammunition(InvItem) != none && Ammunition(InvItem).AmmoAmount >= ItemAmount) {
            Ammunition(InvItem).AmmoAmount -= ItemAmount;
            bSaleSuccessful = true;
        }

        if (P2PowerupInv(InvItem) != none && P2PowerupInv(InvItem).Amount >= ItemAmount) {
            P2PowerupInv(InvItem).Amount -= ItemAmount;
            bSaleSuccessful = true;
        }

	// Steven: Changed this a bit.
        if (bSaleSuccessful)
	{
		MenuUserMoney = MoneyInv(MenuUser.FindInventoryType(class'MoneyInv'));

		if(MenuUserMoney == None)
		{
			MenuUserMoney = MoneyInv(P2Pawn(MenuUser).CreateInventoryByClass(class'MoneyInv'));
			MenuUserMoney.Amount = ItemValue;
		}
		else
			MenuUserMoney.AddAmount(ItemValue);

		GetSoundActor().PlaySound(SellSuccessfulSound);
        }
    }
}

/** Subclassed to implement menu functionality */
function bool KeyEvent(out EInputKey Key, out EInputAction Action, float Delta) {
	if (Action == IST_Axis)
	{
		if (Key == IK_MouseX || Key == IK_MouseY)
			// Player is using mouse, so draw the mouse cursor.
			UWindowRootWindow(Master.BaseMenu).bUsingJoystick = false;			
	}

	if (Key == IK_MouseWheelUp)
        ItemButtonScrollOffset = FClamp(ItemButtonScrollOffset + ItemButtonScrollIncrement,
                                        ItemButtonScrollRange.Min,
                                        ItemButtonScrollRange.Max);
    else if (Key == IK_MouseWheelDown)
        ItemButtonScrollOffset = FClamp(ItemButtonScrollOffset - ItemButtonScrollIncrement,
                                        ItemButtonScrollRange.Min,
                                        ItemButtonScrollRange.Max);

    if (Key == IK_LeftMouse && Action == IST_Release) {
        if (bExitButtonHighlighted) {
            ResumeGame();
            CloseMenu();
        }

        AttemptPurchase();
    }
	
	// Exit out on ESC
	if (Key == IK_Escape && Action == IST_Release)
	{
		ResumeGame();
		CloseMenu();
	}

    //if (Key == IK_RightMouse && Action == IST_Release)
    //    AttemptSell();

	HandleJoystick(Key, Action, Delta);

    return true;
}

/** Renders the item menu and related information such as the money the player
 * has and more information on the item s/he has currently highlighted. To
 * "support" widescreen, I decided to just not use the extra X space.
 */
function PostRender(Canvas Canvas) {
    local bool bWidescreen, bFoundButton;
    local int i;
    local float CanvasScale, ItemButtonIncrement;
	local int SetMouseX, SetMouseY;

    local vector CanvasDimensions, TopLeft;
    local vector BackgroundPos;
    local vector ItemButtonPos, ItemButtonTextPos;
    local vector MoneyBoxPos, MoneyBoxTextPos;// MoneyIconPos;
    local vector ItemInfoPos, ItemIconPos, ItemNamePos, ItemDescPos;
    local vector ItemBuyPos, ItemSellPos, ItemInvPos;
    local vector HintPos;
    local vector ExitButtonPos, ExitButtonTextPos;
	local vector HelpBoxPos, HelpBoxTextPos;

	local string Copy, S;
	local vector TS;

    local Inventory Item;
    local class<Pickup> ItemClass;

    local texture ItemIconTexture;

    if (MenuFont == none || VMT == none)
        return;

    /** Half assed fix for preventing the menu from persisting during Pausing
     * and then quitting back to the main menu
     */
    if (AreAnyRootWindowsRunning())
        CloseMenu();

    /** Setup initial rendering stuff like the style and font */
    Canvas.Style = 5; // Steven: Changed to STY_Alpha.
    Canvas.Font = MenuFont;
    Canvas.SetDrawColor(255, 255, 255, 255);

    /** Find our draw scale, left bound, and record original font scale */
    CanvasScale = Canvas.ClipY / 768.0f;

    TopLeft.X = GetLeftBound(Canvas);

    /** We want to ignore the extra X space as a result from widescreen resolutions */
    CanvasDimensions.X = ((4.0f / 3.0f) * Canvas.ClipY);
    CanvasDimensions.Y = Canvas.ClipY;

    bFoundButton = false;

    /** Draw the background first */
    if (VMT.Background != none) {
        BackgroundPos.X = TopLeft.X * Canvas.ClipX;
        BackgroundPos.Y = TopLeft.Y * Canvas.ClipY;

        Canvas.SetPos(BackgroundPos.X, BackgroundPos.Y);
        Canvas.DrawTile(VMT.Background, CanvasDimensions.X, CanvasDimensions.Y,
                        0, 0, VMT.Background.USize, VMT.Background.VSize);
    }

    /** Calculate the initial position for the top item button */
    ItemButtonPos.X = TopLeft.X * Canvas.ClipX + ItemButton.Pos.X * CanvasDimensions.X;
	// Steven: Removed ItemButton.Pos.Y since it will be handled by Canvas.OrgY.
    ItemButtonPos.Y = TopLeft.Y * Canvas.ClipY + (/*ItemButton.Pos.Y +*/ ItemButtonScrollCurOffset) * CanvasDimensions.Y;
    ItemButtonTextPos.X = ItemButtonPos.X + ItemButton.TextOffset.X * CanvasDimensions.X;
    ItemButtonTextPos.Y = ItemButtonPos.Y + ItemButton.TextOffset.Y * CanvasDimensions.Y;

    ItemButtonIncrement = ItemButtonOffset * CanvasDimensions.Y;

    SetCanvasFontScale(Canvas, ItemButton.TextScale);

    /** Draw the entire item list. We also calculate which button has been
     * highlighted while we have the button dimensions
     * I'm lazy and don't feel like clipping. :P
     *
     * @Gamefan: Looks like someone else felt like clipping  :)
     * @Steve: Freakin' sweet!
     */
	// Steven: Add clipping regions.
	GetP2EUtils().SetDrawingRegion(Canvas, 0, Canvas.ClipY * ItemButton.Pos.Y, Canvas.ClipX, Canvas.ClipY - (Canvas.ClipY * ItemButton.Pos.Y));

    for (i=0;i<VMT.ItemList.length;i++) {
	// If this is the item we want, snap the mouse to it. - Rick
	if (i == DesiredItemButton)
	{
		// If the button is off-screen, scroll to it and auto-select when it comes up.
		//log("Desired button"@i@"scroll"@ItemButtonScrollOffset@ItemButtonScrollCurOffset);
		if (ItemButtonPos.Y + VMT.ItemButton.VSize * ItemButton.Scale.Y * CanvasScale > Canvas.ClipY
			&& ItemButtonScrollOffset > ItemButtonScrollRange.Min)
		{
			//log("Desired button"@i@"off-screen, scrolling down");
			ItemButtonScrollOffset = FClamp(ItemButtonScrollOffset - ItemButtonScrollIncrement,
											ItemButtonScrollRange.Min,
											ItemButtonScrollRange.Max);
		}
		else if (ItemButtonPos.Y < 0
			&& ItemButtonScrollOffset < ItemButtonScrollRange.Max)
		{
			//log("Desired button"@i@"off-screen, scrolling up");
			ItemButtonScrollOffset = FClamp(ItemButtonScrollOffset + ItemButtonScrollIncrement,
											ItemButtonScrollRange.Min,
											ItemButtonScrollRange.Max);
		}
		// Really hard to get these to be equal for some reason... so just check to see if they're "close enough"
		else if (abs(ItemButtonScrollOffset - ItemButtonScrollCurOffset) < 0.01)
		{
			SetMouseX = Int(ItemButtonPos.X + VMT.ItemButton.USize * ItemButton.Scale.X * CanvasScale / 2.0);
			SetMouseY = Int(ItemButtonPos.Y + Canvas.OrgY + VMT.ItemButton.VSize * ItemButton.Scale.Y * CanvasScale / 2.0);
			MoveMouseTo(SetMouseX, SetMouseY);
			DesiredItemButton = INDEX_NONE;
		}
	}
	
	// Steven: Dim the item if the player can't afford it.
	if(!CanAffordItem(VMT.ItemList[i]))
		Canvas.DrawColor.A = Max(1, Canvas.DrawColor.A / 2);

        Canvas.SetPos(ItemButtonPos.X, ItemButtonPos.Y);
        DrawTextureClipped(Canvas, VMT.ItemButton, ItemButton.Scale, CanvasScale);

	// Steven: Undo clipping regions when determining the cursor pos.
        if (ViewportOwner.WindowsMouseX > ItemButtonPos.X &&
            ViewportOwner.WindowsMouseY - Canvas.OrgY > ItemButtonPos.Y &&
            ViewportOwner.WindowsMouseX < ItemButtonPos.X + (VMT.ItemButton.USize * ItemButton.Scale.X * CanvasScale) &&
            ViewportOwner.WindowsMouseY - Canvas.OrgY < ItemButtonPos.Y + (VMT.ItemButton.VSize * ItemButton.Scale.Y * CanvasScale)) {
            bFoundButton = true;
            SelectedItemButton = i;

		if(CanAffordItem(VMT.ItemList[i]))
			Canvas.SetDrawColor(255, 0, 0, 255);
		else
			Canvas.SetDrawColor(127, 0, 0, Canvas.DrawColor.A);
        }

        Canvas.SetPos(ItemButtonTextPos.X, ItemButtonTextPos.Y);
        Canvas.DrawTextClipped(VMT.ItemList[i].ItemName);

        Canvas.SetDrawColor(255, 255, 255, 255);

        ItemButtonPos.Y += ItemButtonIncrement;
        ItemButtonTextPos.Y += ItemButtonIncrement;
    }

    if (!bFoundButton)
        SelectedItemButton = INDEX_NONE;

	// Steven: Restore clipping regions.
	GetP2EUtils().UnsetDrawingRegion(Canvas);

    /** Draw the player's current funds */
    MoneyBoxPos.X = TopLeft.X * Canvas.ClipX + MoneyBox.Pos.X * CanvasDimensions.X;
    MoneyBoxPos.Y = TopLeft.Y * Canvas.ClipY + MoneyBox.Pos.Y * CanvasDimensions.Y;

    //MoneyIconPos.X = (TopLeft.X + MoneyIcon.Pos.X) * CanvasDimensions.X;
    //MoneyIconPos.Y = (TopLeft.Y + MoneyIcon.Pos.Y) * CanvasDimensions.Y;

    if (VMT.MoneyBox != none) {
        MoneyBoxTextPos.X = MoneyBoxPos.X + MoneyBox.TextOffset.X * CanvasDimensions.X;
        MoneyBoxTextPos.Y = MoneyBoxPos.Y + MoneyBox.TextOffset.Y * CanvasDimensions.Y;

        Canvas.SetPos(MoneyBoxPos.X, MoneyBoxPos.Y);
        DrawTexture(Canvas, VMT.MoneyBox, MoneyBox.Scale, CanvasScale);
    }

    /*
    if (MoneyTexture != none) {
        Canvas.SetPos(MoneyIconPos.X, MoneyIconPos.Y);
        DrawTexture(Canvas, MoneyTexture, MoneyIcon.Scale, CanvasScale);
    }
    */

    SetCanvasFontScale(Canvas, MoneyBox.TextScale);

    Canvas.SetPos(MoneyBoxTextPos.X, MoneyBoxTextPos.Y);
    if (MenuUserMoney != none)
        Canvas.DrawText(int(MenuUserMoney.Amount));
    else
        Canvas.DrawText("0");
		
	/** Draw the help box */
    SetCanvasFontScale(Canvas, HelpBox.TextScale);

    HelpBoxPos.X = TopLeft.X * Canvas.ClipX + HelpBox.Pos.X * CanvasDimensions.X;
    HelpBoxPos.Y = TopLeft.Y * Canvas.ClipY + HelpBox.Pos.Y * CanvasDimensions.Y;

    HelpBoxTextPos.X = HelpBoxPos.X + HelpBox.TextOffset.X * CanvasDimensions.X;
    HelpBoxTextPos.Y = HelpBoxPos.Y + HelpBox.TextOffset.Y * CanvasDimensions.Y;
	
    Canvas.SetPos(HelpBoxPos.X, HelpBoxPos.Y);
    DrawTexture(Canvas, VMT.ItemButton, HelpBox.Scale, CanvasScale);

	for (i = 0; i < HINT_LINES_MAX; i++)
	{
		Canvas.SetPos(HelpBoxTextPos.X, HelpBoxTextPos.Y);
		if (UWindowRootWindow(Master.BaseMenu).bUsingJoystick)
			GetFontInfo().DrawText(Canvas, HintTextJoystick[i]);
		else
			GetFontInfo().DrawText(Canvas, HintTextMouse[i]);

		HelpBoxTextPos.Y += VendingHintOffset * CanvasDimensions.Y;
	}
    
    Canvas.SetDrawColor(255, 255, 255, 255);

    /** Draw the menu exit button */
    SetCanvasFontScale(Canvas, ExitButton.TextScale);

    ExitButtonPos.X = TopLeft.X * Canvas.ClipX + ExitButton.Pos.X * CanvasDimensions.X;
    ExitButtonPos.Y = TopLeft.Y * Canvas.ClipY + ExitButton.Pos.Y * CanvasDimensions.Y;

    ExitButtonTextPos.X = ExitButtonPos.X + ExitButton.TextOffset.X * CanvasDimensions.X;
    ExitButtonTextPos.Y = ExitButtonPos.Y + ExitButton.TextOffset.Y * CanvasDimensions.Y;
	
	if (DesiredItemButton == INDEX_EXIT)
	{
		SetMouseX = Int(ExitButtonPos.X + VMT.ItemButton.USize * ItemButton.Scale.X * CanvasScale / 2.0);
		SetMouseY = Int(ExitButtonPos.Y + Canvas.OrgY + VMT.ItemButton.VSize * ItemButton.Scale.Y * CanvasScale / 2.0);
		MoveMouseTo(SetMouseX, SetMouseY);
		DesiredItemButton = INDEX_NONE;
	}

    if (ViewportOwner.WindowsMouseX > ExitButtonPos.X &&
        ViewportOwner.WindowsMouseY > ExitButtonPos.Y &&
        ViewportOwner.WindowsMouseX < ExitButtonPos.X + (VMT.ItemButton.USize * ExitButton.Scale.X * CanvasScale) &&
        ViewportOwner.WindowsMouseY < ExitButtonPos.Y + (VMT.ItemButton.VSize * ExitButton.Scale.Y * CanvasScale))
        bExitButtonHighlighted = true;
    else
        bExitButtonHighlighted = false;

    Canvas.SetPos(ExitButtonPos.X, ExitButtonPos.Y);
    DrawTexture(Canvas, VMT.ItemButton, ExitButton.Scale, CanvasScale);

    if (bExitButtonHighlighted)
        Canvas.SetDrawColor(255, 0, 0, 255);

    Canvas.SetPos(ExitButtonTextPos.X, ExitButtonTextPos.Y);
    Canvas.DrawText("EXIT MENU");

    Canvas.SetDrawColor(255, 255, 255, 255);

    /** Draw the item info box */
    ItemInfoPos.X = TopLeft.X * Canvas.ClipX + ItemInfoBox.Pos.X * CanvasDimensions.X;
    ItemInfoPos.Y = TopLeft.Y * Canvas.ClipY + ItemInfoBox.Pos.Y * CanvasDimensions.Y;

    Canvas.SetPos(ItemInfoPos.X, ItemInfoPos.Y);
    DrawTexture(Canvas, VMT.ItemBox, ItemInfoBox.Scale, CanvasScale);

    if (VendingHintTime > 0.0f) {
        HintPos.X = TopLeft.X * Canvas.ClipX + VendingHint.Pos.X * CanvasDimensions.X;
        HintPos.Y = TopLeft.Y * Canvas.ClipY + VendingHint.Pos.Y * CanvasDimensions.Y;

        SetCanvasFontScale(Canvas, VendingHint.Scale);
		
		for (i = 0; i < HINT_LINES_MAX; i++)
		{
			Canvas.SetPos(HintPos.X, HintPos.Y);
			if (UWindowRootWindow(Master.BaseMenu).bUsingJoystick)
				GetFontInfo().DrawText(Canvas, HintTextJoystick[i]);
			else
				GetFontInfo().DrawText(Canvas, HintTextMouse[i]);

			HintPos.Y += VendingHintOffset * CanvasDimensions.Y;
		}

		/*
        Canvas.SetPos(HintPos.X, HintPos.Y);
        Canvas.DrawText("Left Mouse Button - Purchase Item");

        HintPos.Y += VendingHintOffset * CanvasDimensions.Y;

        Canvas.SetPos(HintPos.X, HintPos.Y);
        Canvas.DrawText("Right Mouse Button - Sell Item (No Weapons)");

        HintPos.Y += VendingHintOffset * CanvasDimensions.Y;

        Canvas.SetPos(HintPos.X, HintPos.Y);
        Canvas.DrawText("Mouse Wheel - Scroll Up and Down");
		*/
    }
    /** Draw information on the item if one has been highlighted */
    else if (SelectedItemButton != INDEX_NONE) {
	// Steven: Attempt to pull an appropriate icon from the pickup's
	// inventory class if none was specified in entry.
	if(VMT.ItemList[SelectedItemButton].ItemIcon == None)
		VMT.ItemList[SelectedItemButton].ItemIcon = Texture(VMT.ItemList[SelectedItemButton].ItemPickup.Default.InventoryType.Default.Texture);

		ItemIconTexture = VMT.ItemList[SelectedItemButton].ItemIcon;

        if (ItemIconTexture != none) {
            ItemIconPos.X = TopLeft.X * Canvas.ClipX + ItemInfoIcon.Pos.X * CanvasDimensions.X;
            ItemIconPos.Y = TopLeft.Y * Canvas.ClipY + ItemInfoIcon.Pos.Y * CanvasDimensions.Y;

            Canvas.SetPos(ItemIconPos.X, ItemIconPos.Y);

            if (ItemIconTexture.VSize / ItemIconTexture.USize == 2)
                Canvas.DrawTile(ItemIconTexture, 64 * CanvasScale, 128 * CanvasScale, 0, 0, ItemIconTexture.USize, ItemIconTexture.VSize);
            else if (ItemIconTexture.USize / ItemIconTexture.VSize == 2)
                Canvas.DrawTile(ItemIconTexture, 256 * CanvasScale, 128 * CanvasScale, 0, 0, ItemIconTexture.USize, ItemIconTexture.VSize);
            else
                Canvas.DrawTile(ItemIconTexture, 128 * CanvasScale, 128 * CanvasScale, 0, 0, ItemIconTexture.USize, ItemIconTexture.VSize);
        }

        ItemNamePos.X = TopLeft.X * Canvas.ClipX + ItemInfoName.Pos.X * CanvasDimensions.X;
        ItemNamePos.Y = TopLeft.Y * Canvas.ClipY + ItemInfoName.Pos.Y * CanvasDimensions.Y;

        Canvas.SetPos(ItemNamePos.X, ItemNamePos.Y);
        SetCanvasFontScale(Canvas, ItemInfoName.Scale);
        Canvas.DrawText(VMT.ItemList[SelectedItemButton].ItemName);

        ItemDescPos.X = TopLeft.X * Canvas.ClipX + ItemInfoDescription.Pos.X * CanvasDimensions.X;
        ItemDescPos.Y = TopLeft.Y * Canvas.ClipY + ItemInfoDescription.Pos.Y * CanvasDimensions.Y;

	// Steven: Use only one string var. I hate it when people do MyString[N] instead
	// of using clipping regions to wrap text.

	// TODO: Use condensed typeface (by that I don't mean Canvas.FontScaleX).

	// Set clipping regions.
	GetP2EUtils().SetDrawingRegion(Canvas, ItemDescPos.X,
						ItemDescPos.Y,
						(Canvas.ClipX * ((1 - ItemInfoDescription.Pos.X) * ItemInfoBox.Scale.X)) - (Canvas.ClipX * ItemInfoDescription.Pos.X),
						Canvas.ClipY );

	ItemDescPos.X = 0.0;
	ItemDescPos.Y = 0.0;

	// Draw the text.
        SetCanvasFontScale(Canvas, ItemInfoDescription.Scale);
	Copy = VMT.ItemList[SelectedItemButton].ItemDescription;

	// Draw each line separated by "\n".
	while(GetP2EUtils().EatString(Copy, "\\n", S))
	{
		if(S == "")
			Canvas.StrLen("A", TS.X, TS.Y);
		else
			Canvas.StrLen(S, TS.X, TS.Y);

		Canvas.SetPos(ItemDescPos.X, ItemDescPos.Y);
		Canvas.DrawText(S);
		ItemDescPos.Y += TS.Y;
	}
	GetP2EUtils().UnsetDrawingRegion(Canvas);

        ItemClass = VMT.ItemList[SelectedItemButton].ItemPickup;

        if (ItemClass != none) {
            Item = MenuUser.FindInventoryType(ItemClass.default.InventoryType);

            ItemBuyPos.X = TopLeft.X * Canvas.ClipX + ItemInfoBuy.Pos.X * CanvasDimensions.X;
            ItemBuyPos.Y = TopLeft.Y * Canvas.ClipX + ItemInfoBuy.Pos.Y * CanvasDimensions.Y;
            Canvas.SetPos(ItemBuyPos.X, ItemBuyPos.Y);

            SetCanvasFontScale(Canvas, ItemInfoBuy.Scale);

            /** If it's a weapon, just show the price, we don't buy back weapons */
            if (ClassIsChildOf(ItemClass, class'WeaponPickup') &&
                !VMT.ItemList[SelectedItemButton].bWeaponIsAlsoAmmo) {
                Canvas.DrawText("Price: $" $ VMT.ItemList[SelectedItemButton].ItemBuyRate.ItemPrice);

                ItemInvPos.X = TopLeft.X * Canvas.ClipX + ItemInfoInv.Pos.X * CanvasDimensions.X;
                ItemInvPos.Y = TopLeft.Y * Canvas.ClipY + ItemInfoInv.Pos.Y * CanvasDimensions.Y;
                Canvas.SetPos(ItemInvPos.X, ItemInvPos.Y);

                SetCanvasFontScale(Canvas, ItemInfoSell.Scale);

                if (Item == none)
                    Canvas.DrawText("Weapon is currently not owned");
                else if (Weapon(Item) != none && Weapon(Item).AmmoType != none)
                    Canvas.DrawText("Ammo currently loaded: " $ Weapon(Item).AmmoType.AmmoAmount);
            }
            /** Otherwise we show the ammunition exchange rates. Sometimes, a
             * weapon is also ammunition such as the case with grenades and molotovs
             */
            else {
                Canvas.DrawText(VMT.ItemList[SelectedItemButton].ItemBuyRate.ItemAmount $
                                " for $" $ VMT.ItemList[SelectedItemButton].ItemBuyRate.ItemPrice);

                // We decided selling items back may break the game, so took it out
                /*ItemSellPos.X = TopLeft.X * Canvas.ClipX + ItemInfoSell.Pos.X * CanvasDimensions.X;
                ItemSellPos.Y = TopLeft.Y * Canvas.ClipY + ItemInfoSell.Pos.Y * CanvasDimensions.Y;
                Canvas.SetPos(ItemSellPos.X, ItemSellPos.Y);

                SetCanvasFontScale(Canvas, ItemInfoSell.Scale);
                Canvas.DrawText("Buys back " $ VMT.ItemList[SelectedItemButton].ItemSellRate.ItemAmount $
                                " for $" $ VMT.ItemList[SelectedItemButton].ItemSellRate.ItemPrice);*/

                ItemInvPos.X = TopLeft.X * Canvas.ClipX + ItemInfoInv.Pos.X * CanvasDimensions.X;
                ItemInvPos.Y = TopLeft.Y * Canvas.ClipY + ItemInfoInv.Pos.Y * CanvasDimensions.Y;
                Canvas.SetPos(ItemInvPos.X, ItemInvPos.Y);

                SetCanvasFontScale(Canvas, ItemInfoInv.Scale);

                if (Item == none)
                    Canvas.DrawText("0 in inventory");
                else if (Ammunition(Item) != none)
                    Canvas.DrawText(Ammunition(Item).AmmoAmount $ " in inventory");
                else if (P2PowerupInv(Item) != none)
                    Canvas.DrawText(int(P2PowerupInv(Item).Amount) $ " in inventory");
                else if (Weapon(Item) != none && Weapon(Item).AmmoType != none)
                    Canvas.DrawText(Weapon(Item).AmmoType.AmmoAmount $ " in inventory");
            }
			/** Draw quantity limit, if any */
			if (VMT.ItemList[SelectedItemButton].QuantityAvailable != 0)
			{
                ItemInvPos.X = TopLeft.X * Canvas.ClipX + ItemInfoQuantity.Pos.X * CanvasDimensions.X;
                ItemInvPos.Y = TopLeft.Y * Canvas.ClipY + ItemInfoQuantity.Pos.Y * CanvasDimensions.Y;
                Canvas.SetPos(ItemInvPos.X, ItemInvPos.Y);

                SetCanvasFontScale(Canvas, ItemInfoInv.Scale);
				if (VMT.ItemList[SelectedItemButton].QuantityAvailable != 255)
					Canvas.DrawText(VMT.ItemList[SelectedItemButton].QuantityAvailable@" in stock");
				else if (VMT.ItemList[SelectedItemButton].QuantityAvailable != 0)
					Canvas.DrawText("SOLD OUT");
			}
        }
    }

    /** Draw the player's cursor last so it goes over everything */
    if (CursorTexture != none
		&& !UWindowRootWindow(Master.BaseMenu).bUsingJoystick) {
        Canvas.SetPos(ViewportOwner.WindowsMouseX, ViewportOwner.WindowsMouseY);
        DrawTexture(Canvas, CursorTexture, CursorDrawScale, CanvasScale);
    }

    ResetCanvasFontScale(Canvas);
}

/** Subclassed to implement updating the item list scroll using Hooke's Law */
function Tick(float DeltaTime) {
    local float ScrollDelta, ScrollAccel, ScrollVel;

    ScrollDelta = ItemButtonScrollOffset - ItemButtonScrollCurOffset;
    ScrollAccel = ItemButtonScrollSpringConstant * ScrollDelta;
    ScrollVel = ScrollAccel * DeltaTime;

    ItemButtonScrollCurOffset = FClamp(ItemButtonScrollCurOffset + ScrollVel * DeltaTime,
                                       ItemButtonScrollRange.Min,
                                       ItemButtonScrollRange.Max);

    GreetingDelay = FMax(GreetingDelay - DeltaTime, 0.0f);

    if (bPlayGreeting && GreetingDelay == 0) {
        bPlayGreeting = false;
        GetSoundActor().PlaySound(VMT.GreetingSounds[Rand(VMT.GreetingSounds.length)]);
    }
}

/** Close the menu by unpausing the game and then removing
 *
 * NOTE TO SELF: The reason why I didn't place the ResumeGame() function in here
 * is because if the player hits the Esc key to go to the Pause menu, this
 * menu needs to be removed, but the game must remained Paused.
 */
function CloseMenu() {
    /** Remove the money inventory if the player is completely out */
    if (MenuUserMoney != none && MenuUserMoney.Amount <= 0)
        MenuUserMoney.UsedUp();

    if (VMT != none)
        GetSoundActor().PlaySound(VMT.GoodbyeSounds[Rand(VMT.GoodbyeSounds.length)]);

    StopSong();
	UWindowRootWindow(Master.BaseMenu).bAllowJoyMouse = false;
    Master.RemoveInteraction(self);
}

///////////////////////////////////////////////////////////////////////////////
// Controller support - Rick
///////////////////////////////////////////////////////////////////////////////
function execMenuButton()
{
	ResumeGame();
	CloseMenu();
}
function execConfirmButton()
{
	if (bExitButtonHighlighted) {
		ResumeGame();
		CloseMenu();
	}
	else
		AttemptPurchase();
}
function NextMenuItem(int Offset)
{
	// The "buttons" aren't UWindows but are drawn onto the canvas, so let PostRender handle the actual selecting of the item.
	if (SelectedItemButton != INDEX_NONE)
		DesiredItemButton = SelectedItemButton + Offset;
	else
		DesiredItemButton = 0;
		
	DesiredItemButton = Clamp(DesiredItemButton, 0, VMT.ItemList.Length);
}
function execBackButton()
{
	//AttemptSell();
	// Can't "sell back" items anymore, so just have the back button close out the menu
	execMenuButton();
}
function execMenuUpButton()
{
	NextMenuItem(-1);
}
function execMenuDownButton()
{
	NextMenuItem(1);
}
function execMenuLeftButton()
{
	NextMenuItem(-8);
	/*
	if (SelectedItemButton > INDEX_NONE)
		DesiredItemButton = INDEX_EXIT;
	else
		DesiredItemButton = 0;
	*/
}
function execMenuRightButton()
{
	//execMenuLeftButton();
	NextMenuItem(8);
}
function MoveMouseTo(coerce int MouseX, coerce int MouseY)
{
	if (MenuUser.Controller != None
		&& PlayerController(MenuUser.Controller) != None)			
		PlayerController(MenuUser.Controller).ConsoleCommand("SETMOUSE"@MouseX@MouseY);
	UWindowRootWindow(Master.BaseMenu).MoveMouse(MouseX, MouseY);
	UWindowRootWindow(Master.BaseMenu).bUsingJoystick = true;	// MoveMouse resets this value.
	//log(Master.BaseMenu@"SETMOUSE"@MouseX@MouseY);
}

defaultproperties
{
    MenuFont=Font'P2Fonts.Fancy48'

    ItemButtonOffset=0.1f
    ItemButtonScrollIncrement=0.04f
    ItemButtonScrollSpringConstant=2048.0f
    ItemButton=(Pos=(X=0.025f,Y=0.225f),Scale=(X=1.8f,Y=1.0f),TextOffset=(X=0.0375f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f))

    MoneyBox=(Pos=(X=0.525f,Y=0.025f),Scale=(X=0.9f,Y=0.5f),TextOffset=(X=0.17f,Y=0.03f),TextScale=(X=1.75f,Y=1.75f))

    ItemInfoDescriptionOffset=0.035f
    ItemInfoIconTallScale=(X=1.0f,Y=1.0f)
    ItemInfoBox=(Pos=(X=0.525f,Y=0.2f),Scale=(X=1.8f,Y=1.75f))
    ItemInfoIcon=(Pos=(X=0.55f,Y=0.25f),Scale=(X=2.0f,Y=2.0f))
    ItemInfoName=(Pos=(X=0.55f,Y=0.45f),Scale=(X=0.85f,Y=0.85f))
    ItemInfoDescription=(Pos=(X=0.55f,Y=0.5f),Scale=(X=0.5f,Y=0.5f)) // Made the font size a bit smaller for now (was 0.6)
    ItemInfoBuy=(Pos=(X=0.55f,Y=0.665f),Scale=(X=0.75f,Y=0.75f))
    ItemInfoSell=(Pos=(X=0.55f,Y=0.665f),Scale=(X=0.75f,Y=0.75f))
    ItemInfoInv=(Pos=(X=0.55f,Y=0.705f),Scale=(X=0.75f,Y=0.75f))
	ItemInfoQuantity=(Pos=(X=0.55f,Y=0.6f),Scale=(X=0.75f,Y=0.75f))

	VendingHintTime=0.f
    VendingHintOffset=0.035f
    VendingHint=(Pos=(X=0.54f,Y=0.25f),Scale=(X=0.525f,Y=0.525f))

    ExitButton=(Pos=(X=0.525f,Y=0.9f),Scale=(X=1.8f,Y=1.0f),TextOffset=(X=0.1f,Y=0.005f),TextScale=(X=1.25f,Y=1.25f))
	HelpBox=(Pos=(X=0.525f,Y=0.8f),Scale=(X=1.8f,Y=1.0f),TextOffset=(X=0.01f,Y=0.01f),TextScale=(X=0.5f,Y=0.5f))

	BuySuccessfulSound=Sound'MiscSounds.Menu.MenuNew'
	ItemSelectedSound=Sound'MiscSounds.Menu.MenuClick'
	SellSuccessfulSound=Sound'MiscSounds.Menu.MenuNew'
	
	HintTextMouse[0]="%KEY_228% to select item, %KEY_001% to buy."
	HintTextMouse[1]="%KEY_004% to scroll list, %KEY_027% to exit."
	HintTextJoystick[0]="%KEY_MenuUpButton%/%KEY_MenuDownButton% to select item, %KEY_ConfirmButton% to buy."
	HintTextJoystick[1]="%KEY_MenuLeftButton%/%KEY_MenuRightButton% to scroll list, %KEY_BackButton% to exit."
}