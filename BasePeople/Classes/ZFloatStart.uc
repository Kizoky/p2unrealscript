///////////////////////////////////////////////////////////////////////////////
// Can die if not constantly revived
///////////////////////////////////////////////////////////////////////////////
class ZFloatStart extends P2Emitter;


var bool bSelfDestroying;

const FLOW_TIME = 1.5;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(AWZombie(Owner) != None)
		AWZombie(Owner).RemoveZStartEffect();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function SelfDestroy(optional bool bDisable)
{
	bSelfDestroying=true;

	Super.SelfDestroy(bDisable);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Revive(out byte StateChange)
{
	if(!bSelfDestroying)
	{
		StateChange=1;
		GotoState('Flowing', 'Rebegin');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Flowing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Flowing
{
Begin:
Rebegin:
	Sleep(FLOW_TIME);
	SelfDestroy();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter93
         UseDirectionAs=PTDU_Up
         Acceleration=(Z=100.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=179,G=179,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
         FadeOutStartTime=1.000000
         FadeOut=True
         FadeInEndTime=0.500000
         FadeIn=True
         MaxParticles=30
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=30.000000),Y=(Min=60.000000,Max=90.000000))
         DrawStyle=PTDS_Darken
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=1.500000,Max=2.000000)
         StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=10.000000,Max=20.000000))
         VelocityLossRange=(Z=(Max=1.500000))
         Name="SpriteEmitter93"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter93'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter94
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         ColorScale(0)=(Color=(B=128,G=128,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
         FadeOutStartTime=1.000000
         FadeOut=True
         FadeInEndTime=0.500000
         FadeIn=True
         MaxParticles=6
         SpinParticles=True
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=105.000000,Max=110.000000))
         UniformSize=True
         DrawStyle=PTDS_Darken
         Texture=Texture'nathans.Skins.bigfluidripple'
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000))
         Name="SpriteEmitter94"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter94'
     AutoDestroy=True
     AmbientSound=Sound'LevelSounds.wind_forest'
     SoundRadius=150.000000
     SoundVolume=255
     SoundPitch=1
     TransientSoundVolume=255.000000
     TransientSoundRadius=150.000000
}
