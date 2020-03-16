/**
 * P2EWeaponSelectionMenu
 *
 * A template interaction to iron out the main functionality for a weapon
 * selection menu before being moved to the P2HUD.
 */
class P2EWeaponSelectionMenu extends P2EInteraction;

const INDEX_NONE = -1;

/** Struct continaing information on weapon slot settings such as the last highlighted weapon */
struct WeaponSlot {
    /** Weapon that was selected last */
    var int SelectedIndex;
    /** Time in seconds */
    var float SelectedCurTime;
    /** Current radian region of the radius list... kinda hard to explain */
    var float ScrollRadian;
    /** Desired radian browsing region to go to */
    var float DesScrollRadian;
    /** Texture to render in black if the weapon slot is currently empty */
    var texture EmptySlotTexture;
    /** List of weapons that belong in this weapon slot */
    var array<Weapon> WeaponList;
};

/** Font to use for weapon ammo rendering */
var Font AmmoFont;
/** Box texture to draw */
var texture WeaponBoxTexture;

/** Screen percentage position for the first weapon slot */
var vector WeaponBarPos;
/** X and Y scale for each of the weapon bar box textures */
var vector WeaponBarScale;
/** Screen percentage offset from the weapon box's position to draw the ammo */
var vector WeaponBarAmmoOffset;
/** X and Y scale for the ammo text */
var vector WeaponBarAmmoScale;
/** Screen percentage offset from the weapon box's position to draw the icon */
var vector WeaponBarIconOffset;
/** Screen percentage offset, except this one is for the wider weapon icons */
var vector WeaponBarIconWideOffset;
/** X and Y scale for the weapon icon drawn inside the weapon box */
var vector WeaponBarIconScale;
/** Screen percentage to move to the right before drawing the next weapon box slot */
var float WeaponBoxOffset;

/** Number of previous and next weapons to display */
var int SelectedSlotSize;
/** Percentage bigger the selected weapon box should grow to when selected */
var float SelectedScaleOffset;
/** Screen percentage upwards and to the left to move the selected slot */
var vector SelectedOffset;
/** Exponent for the weapon slot box interpolation */
var float SelectedInterpExponent;
/** Time in seconds for the slot to reach it's raised selected position */
var float SelectedInterpTime;

/** Screen percentage higher and lower than the base selected position */
var float ScrollWheelOffset;
/** Ironically it's not a constant! */
var float ScrollSpringConstant;

/** Five weapon slots consisting of the list of weapons and HUD information */
var WeaponSlot WeaponSlots[5];

/** Currently expanded weapon slot */
var byte SelectedSlot;
/** Weapon that is currently highlighted */
var Weapon SelectedWeapon;

/** Initializes the menu by giving it a Pawn to check the inventory of and the
 * initial weapon slot button pressed
 * @param P - Pawn this interaction will display the weapons for
 */
function IntializeWeaponMenu(Pawn P) {
    local Inventory Inv;

    for (Inv=P.Inventory;Inv!=none;Inv=Inv.Inventory)
        if (Weapon(Inv) != none)
            NotifyNewWeapon(Weapon(Inv));

    log(self$": Initialized Weapon Menu");
}

/** Moves to the previous weapon on the weapon slot list in a loop */
simulated function PreviousWeapon() {
    local float SlotRadianInterval;

    if (SelectedSlot != INDEX_NONE &&
        WeaponSlots[SelectedSlot].WeaponList.length > 0) {
        WeaponSlots[SelectedSlot].SelectedIndex--;

        if (WeaponSlots[SelectedSlot].SelectedIndex < 0)
            WeaponSlots[SelectedSlot].SelectedIndex = WeaponSlots[SelectedSlot].WeaponList.length - 1;

        SlotRadianInterval = Pi / SelectedSlotSize;
        WeaponSlots[SelectedSlot].DesScrollRadian = SlotRadianInterval * WeaponSlots[SelectedSlot].SelectedIndex;
    }
}

/** Moves to the next weapon on the weapon slot list in a loop */
simulated function NextWeapon() {
    local float SlotRadianInterval;

    if (SelectedSlot != INDEX_NONE &&
        WeaponSlots[SelectedSlot].WeaponList.length > 0) {
        WeaponSlots[SelectedSlot].SelectedIndex++;

        if (WeaponSlots[SelectedSlot].SelectedIndex == WeaponSlots[SelectedSlot].WeaponList.length)
            WeaponSlots[SelectedSlot].SelectedIndex = 0;

        SlotRadianInterval = Pi / SelectedSlotSize;
        WeaponSlots[SelectedSlot].DesScrollRadian = SlotRadianInterval * WeaponSlots[SelectedSlot].SelectedIndex;
    }
}

/** Called whenever a new weapon has been added to the inventory so we can add
 * it to our weapon slot list
 * @param NewWeapon - Weapon
 */
simulated function NotifyNewWeapon(Weapon NewWeapon) {
    local int Group;

    //Group = NewWeapon.InventoryGroup - 1;
    Group = Min(NewWeapon.InventoryGroup - 1, 4);

    WeaponSlots[Group].WeaponList.Insert(WeaponSlots[Group].WeaponList.length, 1);
    WeaponSlots[Group].WeaponList[WeaponSlots[Group].WeaponList.length-1] = NewWeapon;

    log("P2EWeaponMenu: Added " $ WeaponSlots[Group].WeaponList[WeaponSlots[Group].WeaponList.length-1]);
    log("P2EWeaponMenu: WeaponList.length: " $ WeaponSlots[Group].WeaponList.length);
}

/** Called whenever a weapon has been discarded so we'll have to remove it from
 * our weapon slot list
 * @param DroppedWeapon - Weapon that has just been dropped
 */
simulated function NotifyDroppedWeapon(Weapon DroppedWeapon) {
    local int i, Group;

    //Group = DroppedWeapon.InventoryGroup - 1;
    Group = Min(DroppedWeapon.InventoryGroup - 1, 4);

    for (i=0;i<WeaponSlots[Group].WeaponList.length;i++) {
        if (WeaponSlots[Group].WeaponList[i] == DroppedWeapon) {
            log("P2EWeaponMenu: Removing " $ WeaponSlots[Group].WeaponList[i] $ " from weapon list");
            WeaponSlots[Group].WeaponList.Remove(i, 1);
        }
    }

    if (WeaponSlots[Group].SelectedIndex >= WeaponSlots[Group].WeaponList.length)
        WeaponSlots[Group].SelectedIndex = WeaponSlots[Group].WeaponList.length - 1;

    log("P2EWeaponMenu: WeaponList.length: " $ WeaponSlots[Group].WeaponList.length);
}

/** Subclassed to implement calling various functions */
simulated function PostRender(Canvas Canvas) {
    DrawWeaponBar(Canvas);
}

/** Draws the weapon box and weapon in the list
 * @param Canvas - Canvas to use to draw the weapon icon and ammo
 * @param Slot - Weapon Slot to draw
 * @param Index - Weapon index of the weapon slot's weapon list to draw
 * @param Pos - Screen percentage of the screen to draw the weapon box at
 * @param ScaleOffset - Scale to modify the draw by
 */
simulated function DrawWeaponBox(Canvas Canvas, int Slot, int Index,
                                 vector Pos, float ScaleOffset) {
    local bool bIsWideIcon, bIsTallIcon;
    local float CanvasScale;
    local vector CanvasDimensions, AmmoPos, IconPos, WideIconPos;
    local vector BoxScale, IconScale;
    local texture Icon;

    CanvasScale = Canvas.ClipY / 768.0f;

    CanvasDimensions.X = ((4.0f / 3.0f) * Canvas.ClipY);
    CanvasDimensions.Y = Canvas.ClipY;

    AmmoPos.X = Pos.X + WeaponBarAmmoOffset.X * CanvasDimensions.X;
    AmmoPos.Y = Pos.Y + WeaponBarAmmoOffset.Y * CanvasDimensions.Y;

    IconPos.X = Pos.X + WeaponBarIconOffset.X * CanvasDimensions.X;
    IconPos.Y = Pos.Y + WeaponBarIconOffset.Y * CanvasDimensions.Y;

    WideIconPos.X = Pos.X + WeaponBarIconWideOffset.X * CanvasDimensions.X;
    WideIconPos.Y = Pos.Y + WeaponBarIconWideOffset.Y * CanvasDimensions.Y;

    if (WeaponBoxTexture != none) {
        Canvas.SetDrawColor(255, 255, 255, 255);
        Canvas.SetPos(Pos.X, Pos.Y);

        BoxScale.X = WeaponBarScale.X * (1.0f + ScaleOffset);
        BoxScale.Y = WeaponBarScale.Y * (1.0f + ScaleOffset);

        DrawTexture(Canvas, WeaponBoxTexture, BoxScale, CanvasScale);
    }

    if (WeaponSlots[Slot].WeaponList.length == 0 &&
        WeaponSlots[Slot].EmptySlotTexture != none) {
        Canvas.SetDrawColor(16, 16, 16, 255);
        Icon = WeaponSlots[Slot].EmptySlotTexture;
    }
    else if (WeaponSlots[Slot].WeaponList[Index] != none &&
             WeaponSlots[Slot].WeaponList[Index].AmmoType != none &&
             WeaponSlots[Slot].WeaponList[Index].AmmoType.Texture != none) {
        if (WeaponSlots[Slot].WeaponList[Index].AmmoType.AmmoAmount == 0 &&
            InfiniteAmmoInv(WeaponSlots[Slot].WeaponList[Index].AmmoType) == none)
            Canvas.SetDrawColor(128, 128, 128, 255);
        else
            Canvas.SetDrawColor(255, 255, 255, 255);
        Icon = Texture(WeaponSlots[Slot].WeaponList[Index].AmmoType.Texture);
    }

    if (Icon != none) {
        bIsWideIcon = (Icon.USize / Icon.VSize == 2);
        bIsTallIcon = (Icon.VSize / Icon.USize == 2);

        if (bIsWideIcon)
            Canvas.SetPos(WideIconPos.X, WideIconPos.Y);
        else
            Canvas.SetPos(IconPos.X, IconPos.Y);

        if (bIsTallIcon) {
            IconScale.X = (WeaponBarIconScale.X / 2) * (1.0f + ScaleOffset);
            IconScale.Y = (WeaponBarIconScale.Y / 2) * (1.0f + ScaleOffset);
        }
        else {
            IconScale.X = WeaponBarIconScale.X * (1.0f + ScaleOffset);
            IconScale.Y = WeaponBarIconScale.Y * (1.0f + ScaleOffset);
        }

        DrawTexture(Canvas, Icon, IconScale, CanvasScale);
    }

    if (WeaponSlots[Slot].WeaponList.length > 0 &&
        WeaponSlots[Slot].WeaponList[Index] != none &&
        WeaponSlots[Slot].WeaponList[Index].AmmoType != none &&
        InfiniteAmmoInv(WeaponSlots[Slot].WeaponList[Index].AmmoType) == none) {
        Canvas.SetPos(AmmoPos.X, AmmoPos.Y);
        Canvas.SetDrawColor(255, 0, 0, 255);
        SetCanvasFontScale(Canvas, WeaponBarAmmoScale);
        Canvas.DrawText(WeaponSlots[Slot].WeaponList[Index].AmmoType.AmmoAmount);
    }
}

/** Draws all the weapons slots
 * @param Canvas - Canvas to use to draw the weapon bars
 */
simulated function DrawWeaponBar(Canvas Canvas) {
    local int i, j;
    local float Alpha, InterpScaleOffset;
    local float WeaponBoxIncrement;

    local vector TopLeft, CanvasDimensions;
    local vector BasePos, SelectedPos, SelectedPosOffset, FinalPos;

    local float WheelScale;
    local vector WheelPos;

    local float SlotRadianInterval, SlotRadianLength, RenderRadian, WeaponScrollRadian;

    if (AreAnyRootWindowsRunning())
        return;

    /** Setup initial rendering stuff like the style and font */
    Canvas.Style = 1;
    Canvas.Font = AmmoFont;
    Canvas.SetDrawColor(255, 255, 255, 255);

    TopLeft.X = GetLeftBound(Canvas);

    /** We want to ignore the extra X space as a result from widescreen resolutions */
    CanvasDimensions.X = ((4.0f / 3.0f) * Canvas.ClipY);
    CanvasDimensions.Y = Canvas.ClipY;

    BasePos.X = TopLeft.X * Canvas.ClipX + WeaponBarPos.X * CanvasDimensions.X;
    BasePos.Y = TopLeft.Y * Canvas.ClipY + WeaponBarPos.Y * CanvasDimensions.Y;

    WeaponBoxIncrement = WeaponBoxOffset * CanvasDimensions.X;

    /** Render the non selected slots first */
    for (i=0;i<5;i++) {
        /*if (i == SelectedSlot) {
            SelectedPos.X = BasePos.X;
            SelectedPos.Y = BasePos.Y;
            BasePos.X += WeaponBoxIncrement;
            continue;
        }*/

        Alpha = WeaponSlots[i].SelectedCurTime / SelectedInterpTime;

        SelectedPosOffset.X = FInterpEaseIn(0.0f, SelectedOffset.X, Alpha, SelectedInterpExponent) * CanvasDimensions.X;
        SelectedPosOffset.Y = FInterpEaseIn(0.0f, SelectedOffset.Y, Alpha, SelectedInterpExponent) * CanvasDimensions.Y;

        FinalPos.X = BasePos.X + SelectedPosOffset.X;
        FinalPos.Y = BasePos.Y + SelectedPosOffset.Y;

        InterpScaleOffset = FInterpEaseIn(0.0f, SelectedScaleOffset, Alpha, SelectedInterpExponent);

        DrawWeaponBox(Canvas, i, WeaponSlots[i].SelectedIndex, FinalPos, InterpScaleOffset);
        BasePos.X += WeaponBoxIncrement;
    }

    /** If a slot has been selected by the player, we render that above everything */
    /*if (SelectedSlot != INDEX_NONE) {

        // Calculate the base position for the currently weapon list focus
        Alpha = WeaponSlots[SelectedSlot].SelectedCurTime / SelectedInterpTime;

        SelectedPosOffset.X = FInterpEaseIn(0.0f, SelectedOffset.X, Alpha, SelectedInterpExponent) * CanvasDimensions.X;
        SelectedPosOffset.Y = FInterpEaseIn(0.0f, SelectedOffset.Y, Alpha, SelectedInterpExponent) * CanvasDimensions.Y;

        FinalPos.X = SelectedPos.X + SelectedPosOffset.X;
        FinalPos.Y = SelectedPos.Y + SelectedPosOffset.Y;

        InterpScaleOffset = FInterpEaseIn(0.0f, SelectedScaleOffset, Alpha, SelectedInterpExponent);

        SlotRadianInterval = Pi / SelectedSlotSize;
        SlotRadianLength = WeaponSlots[SelectedSlot].WeaponList.length;

        for (i=0;i<WeaponSlots[SelectedSlot].WeaponList.length;i++) {
            WeaponScrollRadian = i * SlotRadianInterval;

            if (WeaponScrollRadian - WeaponSlots[SelectedSlot].ScrollRadian < Pi / 2) {
                RenderRadian = WeaponScrollRadian - WeaponSlots[SelectedSlot].ScrollRadian;

                WheelPos.X = SelectedPos.X + SelectedPosOffset.X * sin(RenderRadian);
                WheelPos.Y = SelectedPos.Y + SelectedPosOffset.Y + (cos(RenderRadian) * ScrollWheelOffset * CanvasDimensions.Y);

                WheelScale = InterpScaleOffset * sin(RenderRadian);

                DrawWeaponBox(Canvas, SelectedSlot, i, WheelPos, WheelScale);
            }
        }

        // Draw the selected index last
        //DrawWeaponBox(Canvas, SelectedSlot, WeaponSlots[SelectedSlot].SelectedIndex, FinalPos, InterpScaleOffset);
    }*/

    ResetCanvasFontScale(Canvas);
}

/** Updates various information on slots such as the it's position and scale
 * @param DeltaTime - Time in seconds since the last game tick
 */
simulated function UpdateSlots(float DeltaTime) {
    local int i;
    local float ScrollDelta, ScrollAccel, ScrollVel;

    for (i=0;i<5;i++) {
        ScrollDelta = WeaponSlots[i].DesScrollRadian - WeaponSlots[i].ScrollRadian;
        ScrollAccel = ScrollSpringConstant * ScrollDelta;
        ScrollVel = ScrollAccel * DeltaTime;

        WeaponSlots[i].ScrollRadian += ScrollVel * DeltaTime;

        if (i == SelectedSlot) {
            WeaponSlots[i].SelectedCurTime = FMin(WeaponSlots[i].SelectedCurTime + DeltaTime, SelectedInterpTime);
        }
        else {
            WeaponSlots[i].SelectedCurTime = FMax(WeaponSlots[i].SelectedCurTime - DeltaTime, 0.0f);
        }
    }
}

/** Subclassed to update */
function Tick(float DeltaTime) {
    UpdateSlots(DeltaTime);
}

/** Causes the interaction to remove itself */
function CloseMenu() {
    Master.RemoveInteraction(self);
}

defaultproperties
{
    AmmoFont=Font'P2Fonts.Fancy48'

    WeaponBoxTexture=texture'MpHUD.HUD.field_gray'

    WeaponBarPos=(X=0.255f,Y=0.93f)
    WeaponBarScale=(X=0.175f,Y=0.35f)
    WeaponBarAmmoOffset=(X=0.005f,Y=0.025f)
    WeaponBarAmmoScale=(X=0.55f,Y=0.55f)
    WeaponBarIconOffset=(X=0.025f,Y=0.005f)
    WeaponBarIconWideOffset=(X=0.005f,Y=0.005f)
    WeaponBarIconScale=(X=0.6f,Y=0.6f)
    WeaponBoxOffset=0.099f

    WeaponSlots(0)=(EmptySlotTexture=texture'HUDPack.Icons.Icon_Weapon_Shovel')
    WeaponSlots(1)=(EmptySlotTexture=texture'HUDPack.Icons.Icon_Weapon_Pistol')
    WeaponSlots(2)=(EmptySlotTexture=texture'HUDPack.Icons.Icon_Weapon_Shotgun')
    WeaponSlots(3)=(EmptySlotTexture=texture'HUDPack.Icons.Icon_Weapon_Machinegun')
    WeaponSlots(4)=(EmptySlotTexture=texture'HUDPack.Icons.Icon_Weapon_Launcher')

    SelectedSlotSize=2
    SelectedScaleOffset=0.55f
    SelectedOffset=(X=-0.025f,Y=-0.1f)
    SelectedInterpExponent=2.0f
    SelectedInterpTime=0.5f

    ScrollWheelOffset=0.1f
    ScrollSpringConstant=1000.0f
}