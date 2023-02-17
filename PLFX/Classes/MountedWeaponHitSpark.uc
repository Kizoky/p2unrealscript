/**
 * MountedWeaponHitSpark
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Spark hit for mounted weapons bullet hits
 *
 * @author Gordon Cheng
 */
class MountedWeaponHitSpark extends PLPersistantEmitter;

/** Copied over from SparkHit */
var float velmax;

/** Also copied over from SparkHit */
simulated function FitToNormal(vector HNormal) {

    Emitters[0].StartVelocityRange.X.Max += HNormal.x * velmax;
	Emitters[0].StartVelocityRange.Y.Max += HNormal.y * velmax;
	Emitters[0].StartVelocityRange.Z.Max += HNormal.z * velmax;
	Emitters[0].StartVelocityRange.X.Min += HNormal.x * velmax;
	Emitters[0].StartVelocityRange.Y.Min += HNormal.y * velmax;
	Emitters[0].StartVelocityRange.Z.Min += HNormal.z * velmax;
}

/** Overriden so we can use the function above to prep our particles */
function SpawnParticle(int Index, int Amount) {

    //FitToNormal(vector(Rotation));

    super.SpawnParticle(Index, Amount);
}

defaultproperties
{
    Begin Object class=SpriteEmitter name=SpriteEmitter0
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        DampingFactorRange=(Z=(Min=0.5))
        UseColorScale=true
        ColorScale(0)=(color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1,color=(R=255))
		MaxParticles=100
        RespawnDeadParticles=false
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        StartSizeRange=(X=(Min=0.5,Max=1),Y=(Min=10,Max=25))
        InitialParticlesPerSecond=0
        AutomaticInitialSpawning=false
        Texture=texture'nathans.Skins.softwhitedot'
        LifetimeRange=(Min=0.7,Max=1)
        StartVelocityRange=(X=(Min=-300,Max=300),Y=(Min=-300,Max=300),Z=(Min=-300,Max=300))
        VelocityLossRange=(X=(Min=4,Max=4),Y=(Min=4,Max=4),Z=(Min=4,Max=4))
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'
	bNetOptional=true

	velmax=400
}
