//=============================================================================
// SmokeFireMatch.
//=============================================================================
class SmokeFireMatch extends Wemitter;

var float SizeChange;

auto state Rise
{
	function Tick(float DeltaTime)
	{
		Emitters[0].StartSizeRange.X.Max+=(SizeChange*DeltaTime);
		Emitters[0].StartSizeRange.X.Min+=(SizeChange*DeltaTime);
	}
	
	function BeginState()
	{
		SizeChange=-(2*Emitters[0].StartSizeRange.X.Max)/(LifeSpan+1);
	}
}

defaultproperties
{
     Begin Object Class=StripEmitter Name=StripEmitter1
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-6.000000)
        FadeOut=True
        MaxParticles=15
		RespawnDeadParticles=False
        StartLocationOffset=(Z=-20.000000)
        StartSizeRange=(X=(Min=1.000000,Max=2.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'nathans.Skins.pour1'
        LifetimeRange=(Min=8.000000,Max=8.000000)
        StartVelocityRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=40.000000,Max=40.000000))
        Name="StripEmitter1"
     End Object
	 LifeSpan=20;
     Emitters(0)=StripEmitter'Fx.StripEmitter1'
     AutoDestroy=true
}
