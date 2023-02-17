/**
 * MountedWeaponHitDirtClods
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Dirt clods that fly into the air for mounted weapon hits
 *
 * @author Gordon Cheng
 */
class MountedWeaponHitDirtClods extends PLPersistantEmitter;

/** Constant copied over from DirtClodsMachineGun */
const VEL_MAX = 280;

/** Copied over from DirtClodsMachineGun */
simulated function FitToNormal(vector HNormal) {

    Emitters[0].StartVelocityRange.X.Max += HNormal.x * VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Max += HNormal.y * VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Max += HNormal.z * VEL_MAX;
	Emitters[0].StartVelocityRange.X.Min += HNormal.x * VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Min += HNormal.y * VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Min += HNormal.z * VEL_MAX;
}

/**  Overriden so we can prep our particles using the function above */
function SpawnParticle(int Index, int Amount) {

    //FitToNormal(vector(Rotation));

    super.SpawnParticle(Index, Amount);
}

defaultproperties
{
    Begin Object class=SpriteEmitter name=SpriteEmitter0
		SecondsBeforeInactive=0
        Acceleration=(Z=-1000)
        UseCollision=true
        DampingFactorRange=(Z=(Min=0.5))
		MaxParticles=100
        RespawnDeadParticles=false
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=2))
        StartSpinRange=(X=(Max=1))
        DampRotation=true
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=2,Max=4))
        InitialParticlesPerSecond=0
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaBlend
        Texture=texture'nathans.Skins.darkchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=true
        LifetimeRange=(Min=2,Max=2)
        StartVelocityRange=(X=(Min=-250,Max=250),Y=(Min=-250,Max=250),Z=(Min=-250,Max=250))
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    bNetOptional=true
	RemoteRole=ROLE_None
}
