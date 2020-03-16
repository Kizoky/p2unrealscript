///////////////////////////////////////////////////////////////////////////////
// NapalmTrail
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// a trail of napalm fuel on a surface
// We say napalm is so volatile that it will eventually ignite no matter
// what, like say just from the heat energy of getting moved around too much or
// something. So slowly eat off it's time
///////////////////////////////////////////////////////////////////////////////
class NapalmTrail extends GasTrail;

var float HealthReduction;		// how quickly to reduce your health from the environment

///////////////////////////////////////////////////////////////////////////////
// Slowly eat away your health so you'll ignite after a while no matter what
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	Health-=HealthReduction*DeltaTime;

	// set ablaze eventually.
	if(Health < MIN_HEALTH)
	{
		SetAblaze(Location, true);
	}
}

defaultproperties
{
   Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter8
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        FadeOut=True
        MaxParticles=40
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=30.000000))
        UseSizeScale=True
		UniformSize=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.005000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=22.000000,Max=32.000000),Y=(Min=22.000000,Max=32.000000))
        ParticlesPerSecond=0.000000
        InitialParticlesPerSecond=0.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.napalmsplat1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        Name="SuperSpriteEmitter8"
   End Object
   Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter8'
   DripTrailClass=None
   MyType=FLUID_TYPE_Napalm
   CollisionRadius=600.000000
   CollisionHeight=600.000000
   UseColRadius=50
   bCollideActors=true
   LifeSpan=10.000000
   FireClass=class'FireNapalmStreak'
   StarterClass=class'NapalmStarterFollow'
   HealthReduction=500.0
   AutoDestroy=true
}