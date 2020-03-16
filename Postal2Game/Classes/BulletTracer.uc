///////////////////////////////////////////////////////////////////////////
// BulletTracer
// Path of actual bullet? Let's you 'see' it, but after it's happened.
//
///////////////////////////////////////////////////////////////////////////
class BulletTracer extends P2Emitter;

const SIZE_FACTOR = 0.6;
const SIZE_MAX	  =	3000;
const VEL_FACTOR  = 10;
const VECTOR_RATIO = 128;	// This is for multiplayer. When vectors are sent
// with a replicated functions as fields in that function, they can be
// truncated especially on the right side of the decimal. Multiplying
// first by a given large-ish amount then dividing by it ensures the
// precision. (it's slow, but necessary).


///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		// We were made halfway from the hit point to the guy that made
		// us, so just use double this distance as the size of the tracer
		if(Owner != None)
			SetDirection(vector(Rotation),2*VSize(Owner.Location - Location));
	}
}

///////////////////////////////////////////////////////////////////////////
// Make it go in a certain direction and stretch a certain distance
///////////////////////////////////////////////////////////////////////////
simulated function SetDirection(vector Dir, float Dist)
{
	if(Emitters.Length > 0)
	{
		// Divide by a given value that ensures precision in multiplayer
		// to bring it back to the original values to now use below.
		//Dir = Dir/VECTOR_RATIO;
		Emitters[0].StartVelocityRange.X.Max=VEL_FACTOR*Dir.X;
		Emitters[0].StartVelocityRange.X.Min=VEL_FACTOR*Dir.X;
		Emitters[0].StartVelocityRange.Y.Max=VEL_FACTOR*Dir.Y;
		Emitters[0].StartVelocityRange.Y.Min=VEL_FACTOR*Dir.Y;
		Emitters[0].StartVelocityRange.Z.Max=VEL_FACTOR*Dir.Z;
		Emitters[0].StartVelocityRange.Z.Min=VEL_FACTOR*Dir.Z;
		if(Dist > SIZE_MAX)
			Dist = SIZE_MAX;
		Emitters[0].StartSizeRange.Y.Max=SIZE_FACTOR*Dist;
		Emitters[0].StartSizeRange.Y.Min=SIZE_FACTOR*Dist;
	}
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter58
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
		FadeOutStartTime=-0.3
        FadeOut=True
        MaxParticles=1
        RespawnDeadParticles=False
        SpinsPerSecondRange=(X=(Max=0.100000))
        UseRegularSizeScale=True
        StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=500.000000,Max=500.000000))
        InitialParticlesPerSecond=500.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'Zo_Smeg.Particles.zo_falls'
        LifetimeRange=(Min=0.300000,Max=0.400000)
        Name="SpriteEmitter58"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter58'
	AutoDestroy=true
	bNetOptional=false
	RemoteRole=ROLE_None
}