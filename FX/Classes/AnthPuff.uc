//=============================================================================
// Puff of deadly gas
//=============================================================================
class AnthPuff extends Anth;

const VEL_MAX = 120;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	FitToNormal(vector(Rotation));
}

function FitToNormal(vector HNormal)
{
	Emitters[0].StartVelocityRange.X.Max=(HNormal.x+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.X.Min=(HNormal.x-1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Max=(HNormal.y+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Min=(HNormal.y-1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Max=(HNormal.z+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Min=(HNormal.z-1)*VEL_MAX;
}

function ApplyWindEffects(vector WindAcc, vector OldWindAcc)
{
	WindAcc/=16;
	OldWindAcc/=16;
	Super.ApplyWindEffects(WindAcc, OldWindAcc);
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter12
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(G=100,R=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(G=16,R=128))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=5
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=150.000000,Max=250.000000))
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.wispsmoke'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=4.000000,Max=7.500000)
        StartVelocityRange=(X=(Min=-350.000000,Max=350.000000),Y=(Min=-350.000000,Max=350.000000),Z=(Min=50.000000,Max=150.000000))
        VelocityLossRange=(X=(Min=1.800000,Max=1.800000),Y=(Min=1.800000,Max=1.800000),Z=(Min=1.800000,Max=1.800000))
        Name="SpriteEmitter12"
    End Object
    Emitters(0)=SpriteEmitter'Fx.SpriteEmitter12'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter13
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=31,G=58,R=78))
        MaxParticles=5
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-130.000000,Max=130.000000),Y=(Min=-130.000000,Max=130.000000),Z=(Min=-130.000000,Max=130.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        SizeScaleRepeats=3.000000
        StartSizeRange=(X=(Min=2.000000,Max=4.000000))
        InitialParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bubbles'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Max=3.000000)
        StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-9.000000,Max=30.000000))
        Name="SpriteEmitter13"
    End Object
    Emitters(1)=SpriteEmitter'Fx.SpriteEmitter13'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter14
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=38,G=72,R=89))
        MaxParticles=5
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-130.000000,Max=130.000000),Y=(Min=-130.000000,Max=130.000000),Z=(Min=-130.000000,Max=130.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        SizeScaleRepeats=2.000000
        StartSizeRange=(X=(Min=2.000000,Max=4.000000))
        InitialParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.bubbles'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Max=3.000000)
        StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-9.000000,Max=30.000000))
        Name="SpriteEmitter14"
    End Object
    Emitters(2)=SpriteEmitter'Fx.SpriteEmitter14'
	LifeSpan=8.000000
	AutoDestroy=true
	CollisionHeight=160;
	DamageDistMag=200
}