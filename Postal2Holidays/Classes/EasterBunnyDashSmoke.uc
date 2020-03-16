/**
 * EasterBunnyDashSmoke
 *
 * A simple puff of smoke on the ground to add to the visual effect of the
 * default dash attack
 */
class EasterBunnyDashSmoke extends P2Emitter;

defaultproperties
{
    Begin Object class=SpriteEmitter name=SpriteEmitter0
        UseColorScale=true
        ColorScale(0)=(Color=(B=175,G=199,R=209))
        ColorScale(1)=(RelativeTime=1,Color=(B=56,G=102,R=122))
        FadeOut=true
        MaxParticles=12
        RespawnDeadParticles=false
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1))
        StartSizeRange=(X=(Min=80,Max=90))
        InitialParticlesPerSecond=100
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.wispsmoke'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=true
        SecondsBeforeInactive=0
        LifetimeRange=(Min=5,Max=3)
        StartVelocityRange=(X=(Min=-240,Max=240),Y=(Min=-240,Max=240),Z=(Min=-240,Max=80))
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'
}