class WeedEmitter extends P2Emitter;

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter1
        StaticMesh=StaticMesh'MrD_PL_Mesh.Compound.Singleleaf'
        RenderTwoSided=True
        Acceleration=(Z=-60.000000)
        MaxParticles=20
        RespawnDeadParticles=False
        Name="WeedFx"
        StartLocationOffset=(X=7.000000,Y=7.000000)
        StartLocationRange=(X=(Max=7.000000),Y=(Max=7.000000),Z=(Min=100.000000,Max=100.000000))
        SpinParticles=True
        RotationOffset=(Pitch=1,Yaw=1,Roll=1)
        SpinsPerSecondRange=(X=(Max=0.200000),Y=(Max=0.200000),Z=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        DampRotation=True
        RotationNormal=(X=1.000000,Y=1.000000,Z=1.000000)
        StartSizeRange=(X=(Min=0.100000,Max=0.800000),Y=(Min=0.100000,Max=0.800000),Z=(Min=0.100000,Max=0.800000))
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-30.000000,Max=40.000000),Y=(Min=-30.000000,Max=40.000000),Z=(Min=30.000000,Max=50.000000))
        Name="MeshEmitter1"
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter1'
}
