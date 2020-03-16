
//=============================================================================
// Blood splash for a stream pouring on a surface
//=============================================================================
class BloodSplashEmitter extends FluidSplashEmitter;

const VEL_MAX			=   30;

function FitToNormal(vector HNormal)
{
	Emitters[0].StartVelocityRange.X.Max=(HNormal.x+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.X.Min=(HNormal.x-1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Max=(HNormal.y+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Min=(HNormal.y-1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Max=(HNormal.z+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Min=(HNormal.z-1)*VEL_MAX;
	//SpriteEmitter(Emitters[1]).ProjectionNormal = HNormal;
}

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter7
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        FadeOut=True
        MaxParticles=8
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.200000)
        StartSizeRange=(X=(Min=1.000000,Max=5.000000),Y=(Min=3.000000,Max=8.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.bloodpour1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        LifetimeRange=(Min=0.300000,Max=0.600000)
        StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=1.000000,Max=10.000000))
        Name="SuperSpriteEmitter7"
    End Object
    Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter7'
	AutoDestroy=true
}
