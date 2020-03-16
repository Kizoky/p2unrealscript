class BloodImpactMP extends P2Emitter;

const EXIT_VEL_BLAST		   =80;
const EXIT_VEL_BLAST_RANGE_HALF=20;
const EXIT_VEL_SPLOTCH			=20;
const EXIT_VEL_SPLOTCH_RANGE_HALF=15;

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		SetDirection(vector(Rotation),0);
}

function SetDirection(vector Dir, float Dist)
{
	local vector usevect;

	// Becuase this direction goes to the center of the actor
	// cut the z in half because it looks a little goofy with blood shooting that high
//	Dir.z=Dir.z/2;

	usevect = EXIT_VEL_BLAST*Dir;
	Emitters[0].StartVelocityRange.X.Max = usevect.x+EXIT_VEL_BLAST_RANGE_HALF;
	Emitters[0].StartVelocityRange.X.Min = usevect.x-EXIT_VEL_BLAST_RANGE_HALF;
	Emitters[0].StartVelocityRange.Y.Max = usevect.y+EXIT_VEL_BLAST_RANGE_HALF;
	Emitters[0].StartVelocityRange.Y.Min = usevect.y-EXIT_VEL_BLAST_RANGE_HALF;
	Emitters[0].StartVelocityRange.Z.Max = usevect.z+EXIT_VEL_BLAST_RANGE_HALF;
	Emitters[0].StartVelocityRange.Z.Min = usevect.z-EXIT_VEL_BLAST_RANGE_HALF;
	usevect = EXIT_VEL_SPLOTCH*Dir;
	Emitters[1].StartVelocityRange.X.Max = usevect.x+EXIT_VEL_SPLOTCH_RANGE_HALF;
	Emitters[1].StartVelocityRange.X.Min = usevect.x-EXIT_VEL_SPLOTCH_RANGE_HALF;
	Emitters[1].StartVelocityRange.Y.Max = usevect.y+EXIT_VEL_SPLOTCH_RANGE_HALF;
	Emitters[1].StartVelocityRange.Y.Min = usevect.y-EXIT_VEL_SPLOTCH_RANGE_HALF;
	Emitters[1].StartVelocityRange.Z.Max = usevect.z+EXIT_VEL_SPLOTCH_RANGE_HALF;
	Emitters[1].StartVelocityRange.Z.Min = usevect.z-EXIT_VEL_SPLOTCH_RANGE_HALF;
}
/*
    Begin Object Class=SpriteEmitter Name=SpriteEmitter53
        UseColorScale=True
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        MaxParticles=2
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=70.000000,Max=100.000000))
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.500000,Max=0.700000)
        StartVelocityRange=(Z=(Max=25.000000))
        Name="SpriteEmitter53"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter53'
*/
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter52
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        MaxParticles=3
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Max=30.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=10.000000,Max=20.000000),Y=(Min=40.0000,Max=60.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodanim2'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.700000,Max=1.00000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=40.000000,Max=100.000000))
        Name="SpriteEmitter52"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter52'
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
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodimpacts'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.400000,Max=0.600000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
        Name="SpriteEmitter17"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter17'
     AutoDestroy=true
	bNetOptional=false
	RemoteRole=ROLE_None
}
