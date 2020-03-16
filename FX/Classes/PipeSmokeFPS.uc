///////////////////////////////////////////////////////////////////////////////
// PipeSmokeFPS
// 
// Smoke from a smoking pipe to be seen in first person
//
///////////////////////////////////////////////////////////////////////////////
class PipeSmokeFPS extends P2Emitter;

const START_OFFSET = 20.0;
const SPEED_MAG = 20.0;
const SPEED_ADD = 3.0;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetDirection(vector addspeed, float pheight)
{
	local vector usedir, usevel;

	usedir = vector(Rotation);

	Emitters[0].StartLocationOffset = START_OFFSET*usedir;
	Emitters[0].StartLocationOffset.z += pheight;
	usevel = SPEED_MAG*usedir;
	Emitters[0].StartVelocityRange.X.Max = usevel.x + SPEED_ADD + addspeed.x;
	Emitters[0].StartVelocityRange.X.Min = usevel.x - SPEED_ADD + addspeed.x;
	Emitters[0].StartVelocityRange.Y.Max = usevel.y + SPEED_ADD + addspeed.y;
	Emitters[0].StartVelocityRange.Y.Min = usevel.y - SPEED_ADD + addspeed.y;
	Emitters[0].StartVelocityRange.Z.Max = usevel.z + SPEED_ADD + addspeed.z;
	Emitters[0].StartVelocityRange.Z.Min = usevel.z - SPEED_ADD + addspeed.z;
}

function TintIt(vector Tinting)
{
	local int i, j;

	for(i=0; i<Emitters.Length; i++)
	{
		Emitters[i].UseColorScale=True;

		for(j=0; j<Emitters[i].ColorScale.Length; j++)
		{
			Emitters[i].ColorScale[j].Color.R=Tinting.x;
			Emitters[i].ColorScale[j].Color.G=Tinting.y;
			Emitters[i].ColorScale[j].Color.B=Tinting.z;
		}
	}
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter37
		SecondsBeforeInactive=0.0
        ColorScale(0)=(Color=(R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255,G=255,B=255))
        Acceleration=(Z=20.000000)
        RespawnDeadParticles=False
        SpinParticles=True
		MaxParticles=8
        SpinsPerSecondRange=(X=(Max=0.300000))
        StartLocationRange=(X=(Min=-3.00000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=8.000000,Max=12.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=2.500000)
        StartVelocityRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter37'
    AutoDestroy=true
}
