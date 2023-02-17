///////////////////////////////////////////////////////////////////////////////
// MonsterBitchBossEye
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// MB variant of AWBossEye
///////////////////////////////////////////////////////////////////////////////
class MonsterBitchBossEye extends AWBossEye;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function RemoveGreatEyeFromBoss()
{
	// If it's pointing to me, unhook it
	if(MonsterBitch(Owner) != None
		&& MonsterBitch(Owner).GreatEye == self)
		MonsterBitch(Owner).GreatEye = None;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter145
         UseColorScale=True
         ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255))
         FadeOutStartTime=0.500000
         FadeOut=True
         FadeInEndTime=0.300000
         FadeIn=True
         MaxParticles=7
         SpinParticles=True
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.300000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.900000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=420.000000,Max=440.000000))
         UniformSize=True
         Texture=Texture'nathans.Skins.bigfluidripple'
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000))
         Name="SpriteEmitter145"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter145'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter100
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,R=255))
         FadeOutStartTime=1.000000
         FadeOut=True
         FadeInEndTime=0.500000
         FadeIn=True
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=240.000000,Max=360.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.wispsmoke'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=1.500000,Max=1.500000)
         Name="SpriteEmitter100"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter100'
     Begin Object Class=BeamEmitter Name=BeamEmitter6
         LowFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         LowFrequencyPoints=2
         HighFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=1.000000,Max=3.000000))
         HighFrequencyPoints=3
         UseColorScale=True
         ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
         MaxParticles=5
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=120.000000,Max=180.000000))
         UniformSize=True
         Texture=Texture'nathans.Skins.lightning6'
         LifetimeRange=(Min=0.400000,Max=0.500000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-150.000000,Max=150.000000))
         Name="BeamEmitter6"
     End Object
     Emitters(2)=BeamEmitter'BeamEmitter6'
}