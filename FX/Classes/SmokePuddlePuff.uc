//=============================================================================
// SmokePuddlePuff. Puff of smoke to accompany FirePuddleBurst
//=============================================================================
class SmokePuddlePuff extends Wemitter;

const EMISSION_RATIO=2.0;

function SetBurstSize()
{
	local int usenum;

	usenum = Rand(Emitters[0].MaxParticles) + Emitters[0].MaxParticles;
	// Decrease smoke detail
	usenum = P2GameInfo(Level.Game).ModifyBySmokeDetail(usenum);
	if(usenum != 0)
	{
		SuperSpriteEmitter(Emitters[0]).SetMaxParticles(usenum);
		Emitters[0].InitialParticlesPerSecond = Emitters[0].MaxParticles*EMISSION_RATIO;
		Emitters[0].StartLocationRange.X.Max = 2*usenum;
		Emitters[0].StartLocationRange.X.Min = -Emitters[0].StartLocationRange.X.Max;
		Emitters[0].StartLocationRange.Y.Max = Emitters[0].StartLocationRange.X.Max;
		Emitters[0].StartLocationRange.Y.Min = Emitters[0].StartLocationRange.X.Min;
		Emitters[0].StartLocationRange.Z.Max = Emitters[0].StartLocationRange.X.Max;
		Emitters[0].StartLocationRange.Z.Min = Emitters[0].StartLocationRange.X.Min;
	}
	else
		Emitters[0].Disabled=true;
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
	}
}

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter22
		SecondsBeforeInactive=0.0
        MaxParticles=10
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=80.000000,Max=150.000000))
        DrawStyle=PTDS_AlphaBlend
        InitialParticlesPerSecond=20.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=160.000000))
        Name="SuperSpriteEmitter22"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter22'
     AutoDestroy=true
}
