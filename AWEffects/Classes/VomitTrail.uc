///////////////////////////////////////////////////////////////////////////////
// VomitTrail
// 
// vomit trail on a vomit projectile from a zombie
///////////////////////////////////////////////////////////////////////////////
class VomitTrail extends P2Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter8
         StaticMesh=StaticMesh'awpeoplestatic.Limbs.Gutling'
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SpinParticles=True
         SpinsPerSecondRange=(X=(Min=0.500000,Max=1.500000),Y=(Min=0.500000,Max=1.500000),Z=(Min=0.500000,Max=1.500000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=1.500000,Max=2.000000),Y=(Min=1.500000,Max=2.000000),Z=(Min=3.000000,Max=4.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         Name="MeshEmitter8"
     End Object
     Emitters(0)=MeshEmitter'AWEffects.MeshEmitter8'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter83
         MaxParticles=15
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=20.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodimpacts'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         Name="SpriteEmitter83"
     End Object
     Emitters(1)=SpriteEmitter'AWEffects.SpriteEmitter83'
     Begin Object Class=MeshEmitter Name=MeshEmitter7
         StaticMesh=StaticMesh'Timb_mesh.fooo.nasty_deli2_timb'
         Acceleration=(Z=-200.000000)
         MaxParticles=3
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=0.100000,Max=0.300000),Y=(Min=0.100000,Max=0.300000),Z=(Min=0.400000,Max=0.600000))
         LifetimeRange=(Min=2.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-60.000000,Max=60.000000))
         Name="MeshEmitter7"
     End Object
     Emitters(2)=MeshEmitter'AWEffects.MeshEmitter7'
     AutoDestroy=True
     bTrailerSameRotation=True
     bReplicateMovement=True
     Physics=PHYS_Trailer
     LifeSpan=25.000000
}
