///////////////////////////////////////////////////////////////////////////////
// Puddle zombie bodies dissolve into--but not connected to the liquid physics
///////////////////////////////////////////////////////////////////////////////
class ZDissolvePuddle extends P2Emitter;

#exec TEXTURE IMPORT NAME=whitecircle FILE=Textures\whitecircle.dds MIPS=on

var float randsizepct;		// range of percentages, from 0.0 to this
var float randstarttimepct;		// range of percentages, from 0.0 to this

///////////////////////////////////////////////////////////////////////////////
// Randomize the size some
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();
	RandomizePuddle();
}

///////////////////////////////////////////////////////////////////////////////
// when the timer is called, selfdestroy the emitter
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	SelfDestroy();
}

///////////////////////////////////////////////////////////////////////////////
// Randomizes size and start time
///////////////////////////////////////////////////////////////////////////////
function RandomizePuddle()
{
	local int i;
	local float sizer, timer;

	if(Emitters.Length > 0)
	{
		sizer = randsizepct*FRand();
		timer = randstarttimepct*FRand();
		// Randomize the size of the first one
		Emitters[0].StartSizeRange.X.Min += sizer*(Emitters[0].StartSizeRange.X.Min);
		Emitters[0].StartSizeRange.X.Max += sizer*(Emitters[0].StartSizeRange.X.Max);
		// Randomize the times for the first one
		Emitters[0].LifetimeRange.Min += timer*Emitters[0].LifetimeRange.Min;
		Emitters[0].LifetimeRange.Max += timer*Emitters[0].LifetimeRange.Max;
		Emitters[0].FadeOutStartTime += timer*Emitters[0].FadeOutStartTime;
		Emitters[0].FadeInEndTime += timer*Emitters[0].FadeInEndTime;
		// increase the start location area for the next two
		if(Emitters.Length > 2)
		{
			for(i=1; i<3; i++)
			{
				Emitters[i].StartLocationRange.X.Min += sizer*(Emitters[i].StartLocationRange.X.Min);
				Emitters[i].StartLocationRange.X.Max += sizer*(Emitters[i].StartLocationRange.X.Max);
				Emitters[i].StartLocationRange.Y.Min += sizer*(Emitters[i].StartLocationRange.Y.Min);
				Emitters[i].StartLocationRange.Y.Max += sizer*(Emitters[i].StartLocationRange.Y.Max);
			}
		}
	}
}

defaultproperties
{
     randsizepct=0.700000
     randstarttimepct=1.000000
     Begin Object Class=SpriteEmitter Name=SpriteEmitter81
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         ColorScale(0)=(Color=(B=38,G=26,R=37))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=64))
         FadeOutStartTime=2.000000
         FadeOut=True
         FadeInEndTime=1.000000
         FadeIn=True
         MaxParticles=8
         StartLocationOffset=(Z=5.000000)
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=35.000000,Max=35.000000))
         UniformSize=True
         DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
         Texture=Texture'whitecircle'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         UseRandomSubdivision=True
         SecondsBeforeInactive=5.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         Name="SpriteEmitter81"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter81'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter85
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         ColorScale(0)=(Color=(B=186,G=186,R=224))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=213,G=213,R=238))
         MaxParticles=6
         StartLocationOffset=(Z=6.000000)
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000))
         StartSizeRange=(X=(Min=5.000000,Max=2.000000))
         UniformSize=True
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.bubbles'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         SecondsBeforeInactive=5.000000
         LifetimeRange=(Min=2.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000))
         Name="SpriteEmitter85"
     End Object
     Emitters(1)=SpriteEmitter'AWEffects.SpriteEmitter85'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter86
         UseColorScale=True
         ColorScale(0)=(Color=(B=98,G=98,R=157))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=154,G=133,R=154))
         MaxParticles=8
         StartLocationOffset=(Z=5.000000)
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000))
         StartSizeRange=(X=(Min=5.000000,Max=1.000000))
         UniformSize=True
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.Bubble'
         SecondsBeforeInactive=5.000000
         LifetimeRange=(Min=2.000000,Max=3.000000)
         StartVelocityRange=(Z=(Min=20.000000,Max=40.000000))
         VelocityLossRange=(Z=(Min=0.300000,Max=1.000000))
         Name="SpriteEmitter86"
     End Object
     Emitters(2)=SpriteEmitter'AWEffects.SpriteEmitter86'
     AutoDestroy=True
     LifeSpan=40.000000
}
