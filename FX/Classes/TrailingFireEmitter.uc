///////////////////////////////////////////////////////////////////////////////
// TrailingFireEmitter
// 
// fire particles just time out, they don't move.. trailer does the moving
//
///////////////////////////////////////////////////////////////////////////////
class TrailingFireEmitter extends P2Emitter;
/*
const WAIT_TIME = 5.0;

function Timer()
{
	if(!AutoDestroy)
	{
		AutoDestroy=true;
		// Stop the emitter from emitting
		if(Emitters[0] != None)
		{
			Emitters[0].RespawnDeadParticles=False;
			Emitters[0].ParticlesPerSecond=0;
		}
	}
}

auto state Burn
{
Begin:
	SetTimer(LifeSpan - WAIT_TIME, false);
}
*/
defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter13
		SecondsBeforeInactive=0.0
        UseColorScale=False
        ColorScale(1)=(RelativeTime=0.000000,Color=(B=180,G=240,R=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(G=41,R=137))
        Acceleration=(Z=60.000000)
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Max=10.000000))
        FadeOut=True
        MaxParticles=20
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=0.30000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=120.000000,Max=180.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.firegroup2'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=3.000000)
        Name="SpriteEmitter13"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter13'
	AutoDestroy=false
    Physics=PHYS_Trailer
	LifeSpan=20.0
}
