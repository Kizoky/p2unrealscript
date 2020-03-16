class ZFloatRevive extends P2Emitter;

const GO_TIME	=	1.5;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Burning
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Burning
{
Begin:
	Sleep(GO_TIME);
	if(AWZombie(Owner) != None)
		AWZombie(Owner).RemoveZReviveEffect();
	SelfDestroy();
}

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter0
         LowFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         LowFrequencyPoints=5
         HighFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=1.000000,Max=3.000000))
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=128))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,R=255))
         ColorScaleRepeats=1.000000
         FadeOut=True
         MaxParticles=5
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=3.000000,Max=10.000000))
         Texture=Texture'nathans.Skins.lightning5'
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Min=-80.000000,Max=80.000000))
         Name="BeamEmitter0"
     End Object
     Emitters(0)=BeamEmitter'BeamEmitter0'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter40
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=128))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,R=255))
         FadeOut=True
         MaxParticles=8
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.blast1'
         LifetimeRange=(Min=0.500000,Max=0.600000)
         Name="SpriteEmitter40"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter40'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter96
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         ColorScale(0)=(Color=(B=128,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
         FadeOutStartTime=0.600000
         FadeOut=True
         FadeInEndTime=0.400000
         FadeIn=True
         MaxParticles=30
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=15.000000,Max=15.000000)
         StartSizeRange=(X=(Min=2.000000,Max=5.000000),Y=(Min=15.000000,Max=30.000000))
         DrawStyle=PTDS_Darken
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRadialRange=(Min=-30.000000,Max=-40.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         Name="SpriteEmitter96"
     End Object
     Emitters(2)=SpriteEmitter'SpriteEmitter96'
     AutoDestroy=True
}
