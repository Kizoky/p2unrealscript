///////////////////////////////////////////////////////////////////////////////
// seeing stars
///////////////////////////////////////////////////////////////////////////////
class InjuryStartEffects extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter54
         CoordinateSystem=PTCS_Relative
         MaxParticles=25
         RespawnDeadParticles=False
         StartLocationOffset=(Z=70.000000)
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=100.000000,Max=150.000000)
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=15.000000))
         InitialParticlesPerSecond=15.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'Zo_Smeg.Special_Brushes.zo_corona2'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         Name="SpriteEmitter54"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter54'
     AutoDestroy=True
}
