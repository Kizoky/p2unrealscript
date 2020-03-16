class BloodImpactMachineGun extends P2Emitter;

const EXIT_VEL_DRIP				=220;
const EXIT_VEL_DRIP_RANGE_HALF	=40;
const EXIT_VEL_SPLOTCH			=20;
const EXIT_VEL_SPLOTCH_RANGE_HALF=15;

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
		SetDirection(vector(Rotation),0);
}

function SetDirection(vector Dir, float Dist)
{
	local vector usevect;

	// Becuase this direction goes to the center of the actor
	// cut the z in half because it looks a little goofy with blood shooting that high
	Dir.z=Dir.z/2;

	usevect = EXIT_VEL_SPLOTCH*Dir;
	Emitters[0].StartVelocityRange.X.Max = usevect.x+EXIT_VEL_SPLOTCH_RANGE_HALF;
	Emitters[0].StartVelocityRange.X.Min = usevect.x-EXIT_VEL_SPLOTCH_RANGE_HALF;
	Emitters[0].StartVelocityRange.Y.Max = usevect.y+EXIT_VEL_SPLOTCH_RANGE_HALF;
	Emitters[0].StartVelocityRange.Y.Min = usevect.y-EXIT_VEL_SPLOTCH_RANGE_HALF;
	Emitters[0].StartVelocityRange.Z.Max = usevect.z+EXIT_VEL_SPLOTCH_RANGE_HALF;
	Emitters[0].StartVelocityRange.Z.Min = usevect.z-EXIT_VEL_SPLOTCH_RANGE_HALF;
	//log("start normal "$Dir);
	usevect = EXIT_VEL_DRIP*Dir;
	Emitters[1].StartVelocityRange.X.Max = usevect.x+EXIT_VEL_DRIP_RANGE_HALF;
	Emitters[1].StartVelocityRange.X.Min = usevect.x-EXIT_VEL_DRIP_RANGE_HALF;
	Emitters[1].StartVelocityRange.Y.Max = usevect.y+EXIT_VEL_DRIP_RANGE_HALF;
	Emitters[1].StartVelocityRange.Y.Min = usevect.y-EXIT_VEL_DRIP_RANGE_HALF;
	Emitters[1].StartVelocityRange.Z.Max = usevect.z+EXIT_VEL_DRIP_RANGE_HALF;
	Emitters[1].StartVelocityRange.Z.Min = usevect.z-EXIT_VEL_DRIP_RANGE_HALF;
}
/*
     Begin Object Class=SpriteEmitter Name=SpriteEmitter17
        FadeOutStartTime=0.400000
        FadeOut=True
        MaxParticles=3
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.400000)
        StartSizeRange=(X=(Min=5.000000,Max=20.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodimpacts'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        UseRandomSubdivision=True
        LifetimeRange=(Min=0.600000,Max=1.000000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
        Name="SpriteEmitter17"
     End Object
     Emitters(0)=SpriteEmitter'Fx.SpriteEmitter17'
*/
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter17
		SecondsBeforeInactive=0.0
        FadeOut=True
        MaxParticles=4
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=11.000000,Max=19.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodimpacts'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.400000,Max=0.600000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
        Name="SpriteEmitter10"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter17'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter10
        Acceleration=(Z=-300.000000)
        MaxParticles=4
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=4.000000,Max=7.000000))
        InitialParticlesPerSecond=35.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodchunks1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.600000,Max=0.800000)
        StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=100.000000,Max=500.000000))
        Name="SpriteEmitter10"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter10'
     AutoDestroy=true
}
