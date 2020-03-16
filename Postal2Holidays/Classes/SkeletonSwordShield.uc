/**
 * SkeletonSwordShield
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * This skeleton is basically the same as the Sword Skeleton, only this one
 * carries a shield as well that it deflect some fire. It's not full proof
 * but it definitely increases durability
 *
 * @author Gordon Cheng
 */
class SkeletonSwordShield extends SkeletonSword
    placeable;

/** StaticMesh to check for in a bolton to change the collision settings */
var StaticMesh ShieldStaticMesh;

/** Overriden so we can modify the shield's collision properties */
function SetupBoltons() {
    local int i;

    super.SetupBoltons();

    for (i=0;i<MAX_BOLTONS;i++) {
        if (boltons[i].part != none && boltons[i].part.StaticMesh == ShieldStaticMesh) {
            boltons[i].part.SetCollision(true, true, true);
            boltons[i].part.bBlockZeroExtentTraces = true;
            boltons[i].part.bBlockNonZeroExtentTraces = false;
        }
    }
}

defaultproperties
{
    ControllerClass=class'SkeletonSwordShieldController'

    ShieldStaticMesh=StaticMesh'MRT_Holidays.shield_bolton'

    Boltons(2)=(Bone="MALE01 l forearm",StaticMesh=StaticMesh'MRT_Holidays.shield_bolton',bCanDrop=false)
}