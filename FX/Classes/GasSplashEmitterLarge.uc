//=============================================================================
// Gas splash for a stream of gasoline pouring on a surface
//=============================================================================
class GasSplashEmitterLarge extends FluidSplashEmitter;

const VEL_MAX		=   100;
const VEL_Z_MAX		=	80;

function FitToNormal(vector HNormal)
{
	Emitters[0].StartVelocityRange.X.Max=(HNormal.x+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.X.Min=(HNormal.x-1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Max=(HNormal.y+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Min=(HNormal.y-1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Max=(HNormal.z+1)*VEL_Z_MAX;
	Emitters[0].StartVelocityRange.Z.Min=(HNormal.z-1)*VEL_MAX/2;
}

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter4
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-150.000000)
        FadeOut=True
        MaxParticles=15
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.200000)
        StartSizeRange=(X=(Min=10.000000,Max=14.000000),Y=(Min=25.000000,Max=35.000000))
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.gassplash'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        LifetimeRange=(Min=0.400000,Max=0.600000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=40.000000,Max=80.000000))
        Name="SuperSpriteEmitter4"
    End Object
    Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter4'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter18
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        FadeOut=True
        MaxParticles=3
        StartLocationRange=(X=(Min=-7.000000,Max=7.000000),Y=(Min=-7.000000,Max=7.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=25.000000,Max=30.000000),Y=(Min=25.000000,Max=30.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.fluidripple'
        LifetimeRange=(Min=0.500000,Max=0.800000)
        Name="SuperSpriteEmitter18"
    End Object
    Emitters(1)=SuperSpriteEmitter'Fx.SuperSpriteEmitter18'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter38
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        FadeOut=True
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=35.000000,Max=40.000000),Y=(Min=35.000000,Max=40.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.gassplash'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=0.600000,Max=1.500000)
        StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000))
        VelocityLossRange=(X=(Min=3.000000,Max=4.000000),Y=(Min=3.000000,Max=4.000000))
        WarmupTicksPerSecond=0.100000
        RelativeWarmupTime=1.000000
        Name="SpriteEmitter38"
    End Object
    Emitters(2)=SpriteEmitter'Fx.SpriteEmitter38'
	AutoDestroy=true
}