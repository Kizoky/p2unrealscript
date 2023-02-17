/**
 * RevolverMuzzleSmoke
 */
class RevolverMuzzleSmoke extends Wemitter;

var float SizeChange;

auto state Rise
{
	function Tick(float DeltaTime) {
		Emitters[0].StartSizeRange.X.Max += (SizeChange * DeltaTime);
		Emitters[0].StartSizeRange.X.Min += (SizeChange * DeltaTime);
	}

	function BeginState() {
		SizeChange =- (2 * Emitters[0].StartSizeRange.X.Max) / (LifeSpan + 1);
	}
}

defaultproperties
{
     Begin Object class=StripEmitter name=StripEmitter0
        InitialParticlesPerSecond=40
        ParticlesPerSecond=40
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-6.000000)
        FadeOut=true
        MaxParticles=40
		RespawnDeadParticles=false
        StartSizeRange=(X=(Min=1.000000,Max=2.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'nathans.Skins.pour1'
        LifetimeRange=(Min=8.000000,Max=8.000000)
        StartVelocityRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=40.000000,Max=40.000000))
        Name="StripEmitter0"
     End Object
     Emitters(0)=StripEmitter'PLInventory.StripEmitter0'
     LifeSpan=5
     AutoDestroy=true
}
