/**
 * P2DualWeaponAttachment
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Expends upon the P2WeaponAttachment to support the proper attachment of
 * third person muzzle flashes on both the right and left weapons
 *
 * @author Gordon Cheng
 */
class P2DualWeaponAttachment extends P2WeaponAttachment;

/** Overriden so we perform the attachment from InitFor instead */
simulated function PostBeginPlay();

/**
 * Moved the MuzzleFlash initialization back here so we can take into
 * consideration whether we're a left or right weapon
 */
function InitFor(Inventory I) {
    local vector LocationOffset;
    local name BoneName;
	
	Super.InitFor(I);

    if (Pawn(Owner) != none && MuzzleFlashClass != none) {

		MuzzleFlash3rd = Spawn(MuzzleFlashClass, Owner);
		BoneName = Pawn(Owner).GetWeaponBoneFor(I);

        if (BoneName == '') {
			MuzzleFlash3rd.SetLocation(Owner.Location);
			MuzzleFlash3rd.SetBase(Owner);
		}
		else
			Owner.AttachToBone(MuzzleFlash3rd, BoneName);

		LocationOffset = MuzzleOffset;

        if (P2DualWieldWeapon(I) != none &&
            P2DualWieldWeapon(I).RightWeapon != none)
            LocationOffset.Z *= -1;

		MuzzleFlash3rd.SetRelativeRotation(MuzzleRotationOffset);
		MuzzleFlash3rd.SetRelativeLocation(LocationOffset);
	}

	bStasis = true;

	if (Weapon(Owner) != none)
		Weapon(Owner).FlashCount = 0;

	if (Instigator != none)
		Instigator.FlashCount = 0;
}

defaultproperties
{
}