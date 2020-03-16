//=============================================================================
// ChemHurtEmitter.
//=============================================================================
class ChemHurtEmitter extends P2Emitter;

const START_OFFSET = 20.0;
const SPEED_MAG = 30.0;
const SPEED_ADD = 15.0;

///////////////////////////////////////////////////////////////////////////////
// Dir here is our additional velocity
///////////////////////////////////////////////////////////////////////////////
function SetDirection(vector Dir, float Dist)
{
	local vector usedir, usevel;
	local int i;

	usedir = vector(Rotation);

	for(i=0; i<Emitters.Length; i++)
	{
		Emitters[i].StartLocationOffset = START_OFFSET*usedir;
		Emitters[i].StartVelocityRange.X.Max += Dir.x;
		Emitters[i].StartVelocityRange.X.Min += Dir.x;
		Emitters[i].StartVelocityRange.Y.Max += Dir.y;
		Emitters[i].StartVelocityRange.Y.Min += Dir.y;
		Emitters[i].StartVelocityRange.Z.Max += Dir.z;
		Emitters[i].StartVelocityRange.Z.Min += Dir.z;
	}
}

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
	 	 SecondsBeforeInactive=0.0
         UseColorScale=true
         ColorScale(0)=(RelativeTime=0.000000,Color=(B=50,G=200,R=150))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
         FadeOut=True
         MaxParticles=4
        RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         SizeScaleRepeats=3.000000
         StartSizeRange=(X=(Min=1.000000,Max=1.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
         Texture=Texture'nathans.Skins.bubbles'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.500000,Max=0.600000)
         StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         Name="SuperSpriteEmitter6"
     End Object
     Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter6'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter14
        FadeOutStartTime=0.000000
        FadeOut=True
		SecondsBeforeInactive=0.0
        UseColorScale=true
        ColorScale(0)=(RelativeTime=0.000000,Color=(B=50,G=150,R=150))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
        MaxParticles=4
        RespawnDeadParticles=False
        SpinParticles=True
        StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseRegularSizeScale=True
        StartSizeRange=(X=(Min=50.000000,Max=60.000000))
		DrawStyle=PTDS_Brighten
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.500000,Max=0.600000)
        StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
        Name="SuperSpriteEmitter14"
    End Object
    Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter14'
	AutoDestroy=true
}
