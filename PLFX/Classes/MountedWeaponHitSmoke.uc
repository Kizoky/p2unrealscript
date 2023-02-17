/**
 * MountedWeaponHitSmoke
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Smoke puff for mounted weapon bullet impacts
 *
 * @author Gordon Cheng
 */
class MountedWeaponHitSmoke extends PLPersistantEmitter;

/** Variables copied over from SmokeHitPuff */
var float velmax;
var float velloss;
var float timemax;
var float timediv;
var float timeminratio;

/** Copied over from SmokeHitPuff */
simulated function RandomizeStart() {

	Emitters[0].LifetimeRange.Max = (timemax * FRand() + timediv) / timediv;
	Emitters[0].LifetimeRange.Min = Emitters[0].LifetimeRange.Max * timeminratio;
}

/** Copied over from SmokeHitPuff */
simulated function FitToNormal(vector HNormal) {

    Emitters[0].StartVelocityRange.X.Max += HNormal.x * velmax;
	Emitters[0].StartVelocityRange.Y.Max += HNormal.y * velmax;
	Emitters[0].StartVelocityRange.Z.Max += HNormal.z * velmax;

	Emitters[0].VelocityLossRange.X.Max = abs(HNormal.x * velloss);
	Emitters[0].VelocityLossRange.X.Min = Emitters[0].VelocityLossRange.X.Max;
	Emitters[0].VelocityLossRange.Y.Max = abs(HNormal.y * velloss);
	Emitters[0].VelocityLossRange.Y.Min = Emitters[0].VelocityLossRange.Y.Max;
	Emitters[0].VelocityLossRange.Z.Max = abs(HNormal.z * velloss);
	Emitters[0].VelocityLossRange.Z.Min = Emitters[0].VelocityLossRange.Z.Max;
}

/** Overriden so we can use the above two functions to prepare the particles */
function SpawnParticle(int Index, int Amount) {

    RandomizeStart();
	//FitToNormal(vector(Rotation));

    super.SpawnParticle(Index, Amount);
}

defaultproperties
{
    Begin Object class=SpriteEmitter name=SpriteEmitter0
        SecondsBeforeInactive=0.0
        UsecolorScale=true
        colorScale(0)=(color=(B=58,G=84,R=126))
        colorScale(1)=(RelativeTime=1,color=(B=61,G=100,R=182))
		MaxParticles=100
        RespawnDeadParticles=false
		SpinParticles=true
		SpinsPerSecondRange=(X=(Max=0.2))
        StartSpinRange=(X=(Max=1))
		UseSizeScale=true
		UseRegularSizeScale=false
		SizeScale(0)=(RelativeSize=0.3)
		SizeScale(1)=(RelativeTime=1,RelativeSize=1)
		StartSizeRange=(X=(Min=30,Max=45))
        InitialParticlesPerSecond=0
        AutomaticInitialSpawning=false
		DrawStyle=PTDS_Brighten
        Texture=texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
		BlendBetweenSubdivisions=true
		LifetimeRange=(Min=0.7,Max=1.1)
		StartVelocityRange=(X=(Min=-10,Max=10),Y=(Min=-10,Max=10),Z=(Min=-10,Max=10),)
		VelocityLossRange=(Z=(Min=5,Max=5))
		Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    velmax=150
    timemax=150
    timediv=100
    timeminratio=0.3
    TransientSoundRadius=50
}
