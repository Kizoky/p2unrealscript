///////////////////////////////////////////////////////////////////////////////
// MonsterBitchInhaleEmitter
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
class MonsterBitchInhaleEmitter extends P2Emitter;

var MonsterBitchController MyBitch;
var config float Range, Angle;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	SetTimer(0.5, true);
	Super.PostBeginPlay();
}

event Timer()
{
    local float MinAngle;
    local vector TargetDir;
    local Actor Other;
	local int i;
	
	if (MyBitch == None)
		return;
		
	//StopwatchStart('InhaleTimer');
	
	i = 0;
	Other = MyBitch.GetSnaggedActor(i);
	while (Other != None)
	{
		//log(other@i);
        TargetDir = Normal(Other.Location - Location);
        MinAngle = 1 - Angle / 180;

        if (TargetDir dot vector(Rotation) < MinAngle)
		{
			MyBitch.LostSnaggedActor(Other);
			//i--;
		}
		Other = MyBitch.GetSnaggedActor(++i);
	}

    foreach VisibleCollidingActors(class'Actor', Other, Range) {
        TargetDir = Normal(Other.Location - Location);
        MinAngle = 1 - Angle / 180;

        if (TargetDir dot vector(Rotation) >= MinAngle)
			MyBitch.SnagThisActor(Other);
    }
	
	//StopwatchStop('InhaleTimer');
}

state DieOut
{
	ignores Timer;
	
	event BeginState()
	{
		local int i;
		
		SetTimer(0, false);
		
		for (i = 0; i < Emitters.Length; i++)
		{
			Emitters[i].ParticlesPerSecond=0;
			Emitters[i].RespawnDeadParticles=false;
		}
			
		AutoDestroy=true;
	}
}

defaultproperties
{
	Range=3500.000000
	Angle=5.000000
	
    Begin Object Class=SpriteEmitter Name=SpriteEmitter102
		CoordinateSystem=PTCS_Relative
        Acceleration=(X=-750.000000)
        FadeOutStartTime=1.750000
        FadeOut=True
        FadeInEndTime=2.000000
        FadeIn=True
        MaxParticles=15
        StartLocationOffset=(X=1500.000000)
        StartLocationRange=(X=(Min=500.000000,Max=500.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=100.000000,Max=100.000000)
        StartLocationPolarRange=(X=(Min=-500.000000,Max=500.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000),Y=(Max=0.100000),Z=(Max=0.100000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=5.000000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=2.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.200000)
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'PLFXSkins.Particles.Dust02'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        Name="SpriteEmitter102"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter102'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter24
		CoordinateSystem=PTCS_Relative
        Acceleration=(X=-750.000000)
        FadeOutStartTime=1.750000
        FadeOut=True
        FadeInEndTime=2.000000
        FadeIn=True
        MaxParticles=15
        StartLocationOffset=(X=1500.000000)
        StartLocationRange=(X=(Min=500.000000,Max=500.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=100.000000,Max=100.000000)
        StartLocationPolarRange=(X=(Min=-500.000000,Max=500.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000),Y=(Max=0.100000),Z=(Max=0.100000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=5.000000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=2.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.200000)
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'PLFXSkins.Particles.Dust01'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        Name="SuperSpriteEmitter24"
    End Object
    Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter24'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter26
		CoordinateSystem=PTCS_Relative
        Acceleration=(X=-750.000000)
        FadeOutStartTime=2.000000
        FadeOut=True
        FadeInEndTime=2.000000
        FadeIn=True
        MaxParticles=5
        StartLocationOffset=(X=1500.000000)
        StartLocationRange=(Y=(Min=-150.000000,Max=150.000000),Z=(Min=-150.000000,Max=150.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.150000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.010000)
        SizeScale(2)=(RelativeTime=0.750000)
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'nathans.Skins.softwhitedot'
        LifetimeRange=(Min=8.000000)
        Name="SuperSpriteEmitter26"
    End Object
    Emitters(2)=SuperSpriteEmitter'SuperSpriteEmitter26'
}