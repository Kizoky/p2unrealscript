///////////////////////////////////////////////////////////////////////////////
// StumpBlood
///////////////////////////////////////////////////////////////////////////////
class StumpBlood extends P2Emitter;

var float spewtime;		// time (plus half random of it) it spews before petering out

const BLOOD_DIST=250;
const SQUIRT_TIME_BASE = 0.2;
const SQUIRT_TIME_RAND = 0.8;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function MakeBloodSplat()
{
	local vector HitNormal, HitLocation;
	local vector endpt, dir;
	local Actor HitActor;

	dir = vector(Rotation) + 0.1*Vrand();
	// make sure it always point downward some, unless it's already pointing upwards a lot
	if(dir.z < 0.7)
		dir.z -= 0.4;
	endpt = BLOOD_DIST*dir + Location;
	HitActor = Trace(HitLocation, HitNormal, endpt, Location, true);
	if ( HitActor != None
		&& HitActor.bWorldGeometry)
	{
		spawn(class'BloodDripSplatMaker',self,,HitLocation,rotator(HitNormal));
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	SelfDestroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Spew
{
begin:
	SetTimer(SpewTime+0.5*SpewTime*Frand(), false);
squirt:
	Sleep(SQUIRT_TIME_BASE + SQUIRT_TIME_RAND*Frand());
	MakeBloodSplat();
	goto('squirt');
}

// Kamek edit for log despam
event Tick(float Delta)
{
//	log(self@"tick super");
	Super.Tick(Delta);
//	log(self@"tick; base is"@base@"owner is"@owner);
	if (!AutoDestroy
		&& (Base == None || Owner == None || Base.bDeleteMe || Owner.bDeleteMe)
		)
	{
//		log(self@"destroying");
		SelfDestroy();
	}
}

defaultproperties
{
     spewtime=5.000000
     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
         UseDirectionAs=PTDU_Up
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         SpinsPerSecondRange=(X=(Max=0.100000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=3.000000,Max=10.000000),Y=(Min=25.000000,Max=35.000000))
         InitialParticlesPerSecond=3.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodanim2'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.300000,Max=0.350000)
         StartVelocityRange=(X=(Min=150.000000,Max=200.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         Name="SpriteEmitter14"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter14'
     AutoDestroy=True
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     AmbientSound=Sound'WeaponSounds.blood_squirt_loop'
     SoundRadius=20.000000
     SoundVolume=80
     SoundPitch=128
     Mass=40.000000
}
