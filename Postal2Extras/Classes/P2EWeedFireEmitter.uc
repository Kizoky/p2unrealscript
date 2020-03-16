/**
 * P2EWeedFireEmitter
 *
 * Small damageless fire emitter to attach to the weed
 */
class P2EWeedFireEmitter extends FireEmitter;

var float SmokeSizeChange;
var float SmokeVelZChange;
var float SmokeEmissionChange;

/** Stubbed out, we don't deal damage */
function DealDamage(float DeltaTime);

state Fading
{
    function BeginState() {
		LifeSpan = FadeTime + WaitAfterFadeTime;
		SetTimer(FadeTime, false);

		SizeChange = -Emitters[0].StartSizeRange.X.Min / (2 * FadeTime);
		VelZChange = -Emitters[0].StartVelocityRange.Z.Min / FadeTime;
		EmissionChange = -Emitters[0].ParticlesPerSecond / 2 * FadeTime;

		SmokeSizeChange = -Emitters[1].StartSizeRange.X.Min / (2 * FadeTime);
		SmokeVelZChange = -Emitters[1].StartVelocityRange.Z.Min / FadeTime;
		SmokeEmissionChange = -Emitters[1].ParticlesPerSecond / 2 * FadeTime;
	}

	simulated function Timer() {
		GotoState('WaitAfterFade');
	}

	function Tick(float DeltaTime) {
		Emitters[0].StartSizeRange.X.Max += (2 * SizeChange * DeltaTime);
		Emitters[0].StartSizeRange.X.Min += (SizeChange * DeltaTime);
		Emitters[0].StartVelocityRange.Z.Max += (VelZChange * DeltaTime);
		Emitters[0].StartVelocityRange.Z.Min += (VelZChange * DeltaTime);
		Emitters[0].InitialParticlesPerSecond += (EmissionChange * DeltaTime);
		Emitters[0].ParticlesPerSecond += (EmissionChange * DeltaTime);

		Emitters[1].StartSizeRange.X.Max += (2 * SmokeSizeChange * DeltaTime);
		Emitters[1].StartSizeRange.X.Min += (SmokeSizeChange * DeltaTime);
		Emitters[1].StartVelocityRange.Z.Max += (SmokeVelZChange * DeltaTime);
		Emitters[1].StartVelocityRange.Z.Min += (SmokeVelZChange * DeltaTime);
		Emitters[1].InitialParticlesPerSecond += (SmokeEmissionChange * DeltaTime);
		Emitters[1].ParticlesPerSecond += (SmokeEmissionChange * DeltaTime);
	}
}

defaultproperties
{
    Begin Object class=SuperSpriteEmitter name=SuperSpriteEmitter0
        FadeOutStartTime=0.400000
        FadeOut=true
        MaxParticles=30
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-50.000000))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=0.500000))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=25.000000,Max=45.000000))
        ParticlesPerSecond=25.000000
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.firegroup3'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=true
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.500000,Max=0.700000)
        StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=270.000000,Max=380.000000))
        Name="SuperSpriteEmitter0"
    End Object
    Emitters(0)=SuperSpriteEmitter'Postal2Extras.SuperSpriteEmitter0'
    Begin Object class=SuperSpriteEmitter name=SuperSpriteEmitter1
        MaxParticles=200
        //StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=100.000000))
        SpinParticles=true
        SpinsPerSecondRange=(X=(Max=0.300000))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=50.000000,Max=50.000000))
        ParticlesPerSecond=20.000000
        InitialParticlesPerSecond=20.000000
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=true
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-240.000000,Max=240.000000),Y=(Min=-240.000000,Max=240.000000),Z=(Min=0.000000,Max=240.000000))
        Name="SuperSpriteEmitter1"
    End Object
    Emitters(1)=SuperSpriteEmitter'Postal2Extras.SuperSpriteEmitter1'
    bDynamicLight=true
    CollisionRadius=100.000000
    CollisionHeight=100.000000
}