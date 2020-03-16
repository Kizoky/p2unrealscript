///////////////////////////////////////////////////////////////////////////////
// RocketTrail
// 
// Smoke trail for rockets (fire is seperate)
///////////////////////////////////////////////////////////////////////////////
class RocketTrail extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter22
		SecondsBeforeInactive=0.0
        MaxParticles=10
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=70.000000,Max=110.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
        Name="SpriteEmitter22"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter22'
    bTrailerSameRotation=True
    Physics=PHYS_Trailer
	RelativeLocation=(X=100.000)
    AutoDestroy=true
	bReplicateMovement=true
}