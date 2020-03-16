///////////////////////////////////////////////////////////////////////////////
// RocketSmokePuff
// 
// Puff to occur when rocket has problems or spurts
///////////////////////////////////////////////////////////////////////////////
class RocketSmokePuff extends P2Emitter;

///////////////////////////////////////////////////////////////////////////////
// Scale the effect down or down
///////////////////////////////////////////////////////////////////////////////
function ScaleEffect(float UseScale)
{
	local int i;

	for(i=0; i<Emitters.Length; i++)
	{
		// scale size
		Emitters[i].StartSizeRange.X.Min*=UseScale;
		Emitters[i].StartSizeRange.X.Max*=UseScale;
		// scale time
		Emitters[i].LifetimeRange.Min*=UseScale;
		Emitters[i].LifetimeRange.Max*=UseScale;
		// velocity
		Emitters[i].StartVelocityRange.X.Min*=UseScale;
		Emitters[i].StartVelocityRange.X.Max*=UseScale;
		Emitters[i].StartVelocityRange.Y.Min*=UseScale;
		Emitters[i].StartVelocityRange.Y.Max*=UseScale;
		Emitters[i].StartVelocityRange.Z.Min*=UseScale;
		Emitters[i].StartVelocityRange.Z.Max*=UseScale;
	}
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter21
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=100,R=180))
        MaxParticles=3
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000),Z=(Min=-8.000000,Max=8.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.1000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=160.000000,Max=240.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.500000,Max=3.000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
        Name="SpriteEmitter21"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter21'
    AutoDestroy=true
}