/**
 * P2DualWieldWeaponPickup
 * Copyright 2014, Running With Scissors, Inc.
 *
 * A simple extension of the normal P2WeaponPickup where we notify our weapon
 * that we have picked up another of the same kind.
 *
 * @author Gordon Cheng
 */
class P2DualWieldWeaponPickup extends P2WeaponPickup;

/** For some reason this method is called for each subsequent pickup, but not
 * the SpawnCopy method, so whatever, we'll do dual wielding stuff here
 */
function AnnouncePickup(Pawn Receiver) {
    local P2DualWieldWeapon DualWieldWeapon;

    DualWieldWeapon = P2DualWieldWeapon(Receiver.FindInventoryType(InventoryType));

    if (DualWieldWeapon != none)
        DualWieldWeapon.NotifyWeaponPickup();

    super.AnnouncePickup(Receiver);
}

defaultproperties
{
}