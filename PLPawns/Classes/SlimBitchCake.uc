/**
 * SlimBitchCake
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * A delicious cake that's been sitting in the rain... and in a dirty junkyard.
 *
 * @author Gordon Cheng
 */
class SlimBitchCake extends PropBreakable;

var array<vector> AdditionalEmitterOffsets;

/** Make them impossible to destroy by conventional means */
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType);

/** Overriden so we can spawn additional particles in additional locations */
function BlowThisUp(int Damage, vector HitLocation, vector Momentum) {
    local int i;
    local vector SpawnOffset;

    if (BreakEffectClass != none) {
        for (i=0;i<AdditionalEmitterOffsets.length;i++) {
            SpawnOffset = class'P2EMath'.static.GetOffset(Rotation, AdditionalEmitterOffsets[i]);
            Spawn(BreakEffectClass,,, Location + SpawnOffset);
        }
    }

    super.BlowThisUp(Damage, HitLocation, Momentum);
}

defaultproperties
{
    bEdShouldSnap=true

    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'PL_tylermesh.JunkyardArena.cake'

    AdditionalEmitterOffsets(0)=(X=64,Y=64,Z=48)
    AdditionalEmitterOffsets(1)=(X=-64,Y=64,Z=48)
    AdditionalEmitterOffsets(2)=(X=64,Y=-64,Z=48)
    AdditionalEmitterOffsets(3)=(X=-64,Y=-64,Z=48)
    AdditionalEmitterOffsets(4)=(X=48,Y=48,Z=128)
    AdditionalEmitterOffsets(5)=(X=-48,Y=48,Z=128)
    AdditionalEmitterOffsets(6)=(X=48,Y=-48,Z=128)
    AdditionalEmitterOffsets(7)=(X=-48,Y=-48,Z=128)
    AdditionalEmitterOffsets(8)=(X=32,Y=32,Z=208)
    AdditionalEmitterOffsets(9)=(X=-32,Y=32,Z=208)
    AdditionalEmitterOffsets(10)=(X=-32,Y=32,Z=208)
    AdditionalEmitterOffsets(11)=(X=-32,Y=-32,Z=208)
    AdditionalEmitterOffsets(12)=(X=0,Y=0,Z=256)

    BreakEffectClass=class'CakeExplosion'

    BreakingSound=sound'WeaponSounds.flesh_explode'
}