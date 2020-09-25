class ZFloatMove extends P2Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter56
         UseDirectionAs=PTDU_Up
         Acceleration=(Z=-100.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=179,G=179,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
         FadeOut=True
         MaxParticles=25
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=8.000000,Max=15.000000),Y=(Min=40.000000,Max=50.000000))
         DrawStyle=PTDS_Darken
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(Z=(Min=-10.000000,Max=-20.000000))
         VelocityLossRange=(Z=(Max=1.000000))
         Name="SpriteEmitter56"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter56'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter90
         UseColorScale=True
         ColorScale(0)=(Color=(G=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=128,R=255))
         MaxParticles=3
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.100000)
         StartSizeRange=(X=(Min=5.000000,Max=10.000000))
         UniformSize=True
         DrawStyle=PTDS_Darken
         Texture=Texture'nathans.Skins.blast1'
         StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-2.000000,Max=-1.000000))
         Name="SpriteEmitter90"
     End Object
     Emitters(1)=SpriteEmitter'AWEffects.SpriteEmitter90'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter95
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         ColorScale(0)=(Color=(G=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=128,R=255))
         FadeOutStartTime=0.600000
         FadeOut=True
         FadeInEndTime=0.300000
         FadeIn=True
         MaxParticles=20
         StartLocationOffset=(Z=-3.000000)
         StartLocationRange=(Z=(Min=-3.000000,Max=3.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         UniformSize=True
         DrawStyle=PTDS_Darken
         Texture=Texture'nathans.Skins.bigfluidripple'
         LifetimeRange=(Min=0.800000,Max=0.800000)
         Name="SpriteEmitter95"
     End Object
     Emitters(2)=SpriteEmitter'AWEffects.SpriteEmitter95'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter130
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=128))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,R=255))
         FadeOut=True
         MaxParticles=20
         StartLocationRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000),Z=(Min=-10.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.blast1'
         LifetimeRange=(Min=0.500000,Max=0.600000)
         Name="SpriteEmitter130"
     End Object
     Emitters(3)=SpriteEmitter'AWEffects.SpriteEmitter130'
     AutoDestroy=True
     AmbientSound=Sound'LevelSounds.wind_light'
     SoundRadius=60.000000
     SoundVolume=255
     SoundPitch=0
     TransientSoundVolume=255.000000
     TransientSoundRadius=60.000000

	// Change by NickP: MP fix
	bReplicateMovement=true
	bUpdateSimulatedPosition=true
	// End
}
