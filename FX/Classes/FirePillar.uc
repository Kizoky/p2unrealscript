///////////////////////////////////////////////////////////////////////////////
// FirePillar
// 
// Fire comes from an outside ring and forms into a quick pillar
//
///////////////////////////////////////////////////////////////////////////////
class FirePillar extends P2Emitter;

var float BallHeight;

const BALL_SIZE	= 100;	// average radius of the actual fireball

///////////////////////////////////////////////////////////////////////////////
// Look for a ceiling above us, and squish ourselves if there is one
///////////////////////////////////////////////////////////////////////////////
function CheckCeiling(vector UseNormal)
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, endp;
	local float rat;

	// move away from the wall/ground a little
	endp = Location;
	endp.z += (BallHeight + BALL_SIZE);
	// Do check
	HitActor = Trace(HitLocation, HitNormal, endp, Location, true);
	// If you hit something, then stop there
	if(HitActor != None)
	{
		BallHeight = (HitLocation.z - Location.z) - BALL_SIZE;
		if(BallHeight < BALL_SIZE) 
			BallHeight = BALL_SIZE;
		rat = BallHeight/default.BallHeight;
		Emitters[0].StartVelocityRange.Z.Max*=rat;
		Emitters[0].StartVelocityRange.Z.Min*=rat;
	}
}

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter14
		SecondsBeforeInactive=0.0
        LocationShapeExtend=PTLSE_Circle
        UseColorScale=False
        ColorScale(1)=(RelativeTime=0.000000,Color=(B=180,G=240,R=255))
        ColorScale(2)=(RelativeTime=0.000000,Color=(B=180,G=240,R=255))
        FadeOut=True
        MaxParticles=15
        RespawnDeadParticles=False
        SphereRadiusRange=(Max=50.000000)
        SpinParticles=True
		StartLocationOffset=(Z=-20.0)
        SpinsPerSecondRange=(X=(Max=0.200000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.750000)
        StartSizeRange=(X=(Min=50.000000,Max=100.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.firegroup2'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.000000,Max=1.100000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=150.000000,Max=600.000000))
        StartVelocityRadialRange=(Min=300.000000,Max=300.000000)
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        Name="SuperSpriteEmitter14"
    End Object
    Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter14'
	AutoDestroy=true
	BallHeight = 250;
}
