///////////////////////////////////////////////////////////////////////////////
// SmokePuddleCeiling. 
// Emits on the ceiling above a SmokePuddle
///////////////////////////////////////////////////////////////////////////////
class SmokePuddleCeiling extends SmokeEmitter;

var	int		OrigLifeSpan;

const EMISSION_RATIO = 0.10;
const PARTICLE_RATIO = 0.23;
const MIN_PARTICLE_USE=10;

replication
{
	// functions server sends to client
	unreliable if(Role == ROLE_Authority)
		ClientSquishZ;
}

///////////////////////////////////////////////////////////////////////////////
// A wall has been detected in a certain direction, restrict spawning in that dir
///////////////////////////////////////////////////////////////////////////////
function InitialWallHitX(float X)
{
	if(X > 0)
	{
		Emitters[0].StartLocationRange.X.Max = 0;
		Emitters[0].StartVelocityRange.X.Max = 0;
	}
	else
	{
		Emitters[0].StartLocationRange.X.Min = 0;
		Emitters[0].StartVelocityRange.X.Min = 0;
	}
}
function InitialWallHitY(float Y)
{
	if(Y > 0)
	{
		Emitters[0].StartLocationRange.Y.Max = 0;
		Emitters[0].StartVelocityRange.Y.Max = 0;
	}
	else
	{
		Emitters[0].StartLocationRange.Y.Min = 0;
		Emitters[0].StartVelocityRange.Y.Min = 0;
	}
}

function PrepSize(float UseRadius)
{
	local float count;

	count = UseRadius*PARTICLE_RATIO;
	count+=MIN_PARTICLE_USE;
	// Decrease smoke detail 
	count = P2GameInfo(Level.Game).ModifyBySmokeDetail(count);
	ClientPrepSize(UseRadius, count);
}

simulated function ClientPrepSize(float UseRadius, float count)
{
	Emitters[0].SphereRadiusRange.Max = UseRadius;
	if(count != 0)
	{
		SuperSpriteEmitter(Emitters[0]).SetMaxParticles(count);
		Emitters[0].ParticlesPerSecond = Emitters[0].MaxParticles*EMISSION_RATIO;
		if(Emitters[0].ParticlesPerSecond < 0)
			Emitters[0].ParticlesPerSecond=1;
		Emitters[0].InitialParticlesPerSecond = Emitters[0].ParticlesPerSecond;
		SuperSpriteEmitter(Emitters[0]).LocationShapeExtend=PTLSE_Circle;
		WindCheckDist = 3*UseRadius;
		//log("set WindCheckDist to "$WindCheckDist);
		CheckWallsForWind();
	}
	else
		Emitters[0].Disabled=true;
}

simulated function ClientSquishZ(float newz)
{
	Emitters[0].StartLocationRange.Z.Min = newz;
}

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter2
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(Z=-1.000000)
        MaxParticles=30
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-150.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        UseSizeScale=True
		UniformSize=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=100.000000,Max=200.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000))
        Name="SuperSpriteEmitter2"
     End Object
     Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter2'
     LifeSpan=30.000000
     AutoDestroy=true
}
