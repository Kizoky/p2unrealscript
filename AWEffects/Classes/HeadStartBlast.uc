class HeadStartBlast extends P2Emitter;


const BURN_TIME = 4.0;

auto state Burning
{
Begin:
	Sleep(BURN_TIME);
	SelfDestroy();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter89
         UseDirectionAs=PTDU_Up
         Acceleration=(Z=100.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=100,G=200))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
         FadeOutStartTime=0.400000
         FadeOut=True
         FadeInEndTime=0.200000
         FadeIn=True
         MaxParticles=50
         StartLocationOffset=(Z=-30.000000)
         StartLocationRange=(X=(Min=-45.000000,Max=45.000000),Y=(Min=-45.000000,Max=45.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=40.000000,Max=60.000000),Y=(Min=110.000000,Max=150.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.500000,Max=0.700000)
         StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=300.000000,Max=500.000000))
         VelocityLossRange=(Z=(Max=1.500000))
         Name="SpriteEmitter89"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter89'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter88
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         ColorScale(0)=(Color=(B=100,G=200))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
         FadeOutStartTime=0.400000
         FadeOut=True
         FadeInEndTime=0.200000
         FadeIn=True
         MaxParticles=6
         SpinParticles=True
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Min=0.400000,Max=0.600000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=140.000000,Max=180.000000))
         UniformSize=True
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.bigfluidripple'
         LifetimeRange=(Min=0.600000,Max=0.700000)
         StartVelocityRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000))
         Name="SpriteEmitter88"
     End Object
     Emitters(1)=SpriteEmitter'AWEffects.SpriteEmitter88'
     AutoDestroy=True
     AmbientSound=Sound'LevelSoundsToo.Napalm.napalmBallRoll'
     SoundRadius=600.000000
     SoundVolume=200
     SoundPitch=1
     TransientSoundVolume=100.000000
     TransientSoundRadius=600.000000
}
