//=============================================================================
// Small gas splash for a stream of gasoline pouring on a surface
//=============================================================================
class GasSplashEmitterSmall extends FluidSplashEmitter;

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
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter7
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        FadeOut=True
        MaxParticles=10
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.200000)
        StartSizeRange=(X=(Min=5.000000,Max=8.000000),Y=(Min=15.000000,Max=25.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.gassplash'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        LifetimeRange=(Min=0.300000,Max=0.700000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=40.000000,Max=60.000000))
        VelocityLossRange=(Z=(Min=1.000000,Max=5.000000))
        Name="SuperSpriteEmitter7"
    End Object
    Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter7'
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
    AutoDestroy=true
}