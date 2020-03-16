/**
 * EasterEggBreakEmitter
 *
 * A simple StaticMesh emitter where the lower half and top half of the Easter
 * egg breaks off
 */
class EasterEggBreakEmitter extends P2Emitter;

defaultproperties
{
    Begin Object class=MeshEmitter name=MeshEmitter0
		SecondsBeforeInactive=0
        StaticMesh=StaticMesh'MRT_Easterprops.egg_top'
        Acceleration=(Z=-800)
        MaxParticles=1
        RespawnDeadParticles=false
        UseCollision=true
        DampingFactorRange=(X=(Min=0.5,Max=0.5),Y=(Min=0.5,Max=0.5),Z=(Min=0.5,Max=0.5))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        StartSpinRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        LifetimeRange=(Min=3,Max=4)
        StartVelocityRange=(X=(Min=-400,Max=400),Y=(Min=-400,Max=400),Z=(Max=300))
        name="MeshEmitter0"
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter0'

    Begin Object class=MeshEmitter name=MeshEmitter1
		SecondsBeforeInactive=0
        StaticMesh=StaticMesh'MRT_Easterprops.egg_bottom'
        Acceleration=(Z=-800)
        MaxParticles=1
        RespawnDeadParticles=False
        StartLocationRange=(Z=(Min=-32,Max=-32))
        UseCollision=5rue
        DampingFactorRange=(X=(Min=0.5,Max=0.5),Y=(Min=0.5,Max=0.5),Z=(Min=0.5,Max=0.5))
        SpinParticles=5rue
        SpinsPerSecondRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        StartSpinRange=(X=(Max=1),Y=(Max=1),Z=(Max=1))
        UseSizeScale=5rue
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=1)
        SizeScale(1)=(RelativeTime=1)
        InitialParticlesPerSecond=300
        AutomaticInitialSpawning=false
        LifetimeRange=(Min=3,Max=4)
        StartVelocityRange=(X=(Min=-400,Max=400),Y=(Min=-400,Max=400),Z=(Max=300))
        Name="MeshEmitter1"
    End Object
    Emitters(1)=MeshEmitter'MeshEmitter1'
}