///////////////////////////////////////////////////////////////////////////////
// ScissorsWake
// 
// Blurry effect of particles behind the scissors
//
///////////////////////////////////////////////////////////////////////////////
class ScissorsWake extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter22
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=0.300000,Z=1.000000)
        FadeOut=True
        MaxParticles=8
        CoordinateSystem=PTCS_Relative
        SpinParticles=True
        SpinCCWorCW=(X=1.000000)
        SpinsPerSecondRange=(X=(Min=3.00000,Max=3.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        StartSizeRange=(X=(Min=12.000000,Max=12.000000),Y=(Min=12.000000,Max=12.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.scissorsspin'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.200000,Max=1.200000)
        StartVelocityRange=(X=(Min=500.000000,Max=500.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
        Name="SpriteEmitter22"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter22'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter23
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(Y=1.000000,Z=0.000000)
        FadeOut=True
        MaxParticles=8
        CoordinateSystem=PTCS_Relative
        SpinParticles=True
        SpinCCWorCW=(X=1.000000)
        SpinsPerSecondRange=(X=(Min=3.00000,Max=3.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        StartSizeRange=(X=(Min=12.000000,Max=12.000000),Y=(Min=12.000000,Max=12.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.scissorsspin'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.200000,Max=1.200000)
        StartVelocityRange=(X=(Min=500.000000,Max=500.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
        Name="SpriteEmitter23"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter23'
    AutoDestroy=true
    RemoteRole=ROLE_None
}
