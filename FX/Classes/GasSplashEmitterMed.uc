//=============================================================================
// Small gas splash for a stream of gasoline pouring on a surface
//=============================================================================
class GasSplashEmitterMed extends FluidSplashEmitter;

const VEL_MAX		=   100;

function FitToNormal(vector HNormal)
{
	Emitters[0].StartVelocityRange.X.Max=(HNormal.x+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.X.Min=(HNormal.x-1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Max=(HNormal.y+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Min=(HNormal.y-1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Max=(HNormal.z+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Min=(HNormal.z-1)*VEL_MAX;
}

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter8
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        FadeOut=True
        MaxParticles=10
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
        StartLocationOffset=(Z=5.000000)
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.200000)
        StartSizeRange=(X=(Min=10.000000,Max=14.000000),Y=(Min=25.000000,Max=35.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.gassplash'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        LifetimeRange=(Min=0.300000,Max=0.600000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=70.000000,Max=120.000000))
        VelocityLossRange=(Z=(Min=1.000000,Max=5.000000))
        Name="SuperSpriteEmitter8"
    End Object
    Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter8'
	AutoDestroy=true
}