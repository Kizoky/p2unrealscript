//=============================================================================
// FirePuddleBurst. burst of flames that shoots a little higher, out of a puddle of fire
//=============================================================================
class FirePuddleBurst extends Wemitter;

const EMISSION_RATIO=2.0;
const SMOKE_DELAY_CREATION_TIME = 0.4;

function SetBurstSize()
{
	local int usenum;

	usenum = Rand(Emitters[0].MaxParticles) + Emitters[0].MaxParticles;
	// Decrease fire detail 
	usenum = P2GameInfo(Level.Game).ModifyByFireDetail(usenum);
	SuperSpriteEmitter(Emitters[0]).SetMaxParticles(usenum);
	Emitters[0].InitialParticlesPerSecond = Emitters[0].MaxParticles*EMISSION_RATIO;
	Emitters[0].StartLocationRange.X.Max = 2*usenum;
	Emitters[0].StartLocationRange.X.Min = -Emitters[0].StartLocationRange.X.Max;
	Emitters[0].StartLocationRange.Y.Max = Emitters[0].StartLocationRange.X.Max;
	Emitters[0].StartLocationRange.Y.Min = Emitters[0].StartLocationRange.X.Min;
	Emitters[0].StartLocationRange.Z.Max = Emitters[0].StartLocationRange.X.Max;
	Emitters[0].StartLocationRange.Z.Min = Emitters[0].StartLocationRange.X.Min;
}

// SLOW: put the wind variable into level info or something, and just access
// it through there, rather than searching the level for the wind when you need it.
function AssessWind()
{
	local Wind usewind;

	ForEach DynamicActors(class 'Wind', usewind)
	{
		ApplyWindEffects(usewind.Acc, usewind.OldAcc);
		return;
	}
}

auto state Starting
{
	function BeginState()
	{
		SetBurstSize();
		// Try to find the wind in the level and apply some to us
		// since we're so short-lived.
		AssessWind();
		// Make some smoke to accompany the fire
		SetTimer(SMOKE_DELAY_CREATION_TIME, false);
	}
}

// Make the accompanying smoke here
function Timer()
{
	local vector loc;

	loc = Location;
	loc.x+=Emitters[0].Acceleration.X/2;
	loc.y+=Emitters[0].Acceleration.Y/2;
	loc.z+=Emitters[0].StartVelocityRange.Z.Min;
	spawn(class'SmokePuddlePuff',,,loc);
}

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter22
		SecondsBeforeInactive=0.0
        FadeOutStartTime=0.500000
        FadeOut=True
        MaxParticles=15
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=40.000000,Max=80.000000))
        InitialParticlesPerSecond=30.000000
        AutomaticInitialSpawning=False
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.firegroup3'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.200000,Max=1.400000)
        StartVelocityRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=300.000000,Max=400.000000))
        Name="SuperSpriteEmitter22"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter22'
	 AutoDestroy=true
}
