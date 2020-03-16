///////////////////////////////////////////////////////////////////////////////
// TorsoGutsCurl
// 
// Intestine chunks, in half circle shape
//
///////////////////////////////////////////////////////////////////////////////
class TorsoGutsCurl extends P2Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter14
         StaticMesh=StaticMesh'awpeoplestatic.Limbs.Gutling2'
         Acceleration=(Z=-800.000000)
         UseCollision=True
         DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.400000,Max=0.400000))
         MaxParticles=2
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000))
         UseRotationFrom=PTRS_Actor
         SpinParticles=True
         SpinCCWorCW=(Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         DampRotation=True
         RotationDampingFactorRange=(X=(Min=0.400000,Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         StartSizeRange=(X=(Min=1.500000,Max=2.500000),Y=(Min=1.500000,Max=2.500000))
         UniformSize=True
         InitialParticlesPerSecond=3.000000
         AutomaticInitialSpawning=False
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=10.000000,Max=20.000000)
         StartVelocityRange=(X=(Min=-60.000000,Max=-150.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=40.000000,Max=-40.000000))
         Name="MeshEmitter14"
     End Object
     Emitters(0)=MeshEmitter'AWEffects.MeshEmitter14'
     AutoDestroy=True
     RemoteRole=ROLE_None
     LifeSpan=60.000000
     AmbientGlow=128
}
