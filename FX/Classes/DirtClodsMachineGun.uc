//=============================================================================
// DirtClodsMachineGun.
//=============================================================================
class DirtClodsMachineGun extends P2Emitter;

const VEL_MAX = 280;
//const LIFETIME_MAX = 400;
//const LIFETIME_DIV = 100;
//const LIFETIME_MIN_RATIO=0.6;

//replication
//{
	// server sends this to client if enough bandwidth available
//	unreliable if(Role==ROLE_Authority)
//		FitToNormal;
//}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	RandomizeStart();
	FitToNormal(vector(Rotation));
}

function RandomizeStart()
{
//	Emitters[0].LifetimeRange.Max=(LIFETIME_MAX*FRand() + LIFETIME_DIV)/LIFETIME_DIV;
//	Emitters[0].LifetimeRange.Min=Emitters[0].LifetimeRange.Max*LIFETIME_MIN_RATIO;
}

simulated function FitToNormal(vector HNormal)
{
	Emitters[0].StartVelocityRange.X.Max+=HNormal.x*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Max+=HNormal.y*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Max+=HNormal.z*VEL_MAX;
	Emitters[0].StartVelocityRange.X.Min+=HNormal.x*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Min+=HNormal.y*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Min+=HNormal.z*VEL_MAX;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter12
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-1000.000000)
        UseCollision=True
        DampingFactorRange=(Z=(Min=0.500000))
		MaxParticles=2
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=2.000000))
        StartSpinRange=(X=(Max=1.000000))
        DampRotation=True
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=2.000000,Max=4.000000))
        InitialParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.darkchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-250.000000,Max=250.000000),Y=(Min=-250.000000,Max=250.000000),Z=(Min=-250.000000,Max=250.000000))
        Name="SpriteEmitter12"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter12'
	AutoDestroy=true
	bNetOptional=true
	RemoteRole=ROLE_None
	CullDistance=3500.0
}
