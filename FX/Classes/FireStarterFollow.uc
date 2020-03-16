///////////////////////////////////////////////////////////////////////////////
// FireStarterFollow
//
// Extends emitter because this thing doesn't actually cause damage, it just sets fires.
///////////////////////////////////////////////////////////////////////////////
class FireStarterFollow extends P2Emitter;

///////////////////////////////////////////////////////////////////////////////
// exported variables
var ()class<FireEmitter> SpawnClass;
var ()bool			bAllowDirChange;

// internal variables
//var vector StartPos;
var FireEmitter FireSource;
var bool bGoingToEnd;
var Fluid GasSource;
var float VelMag;

// consts
const WAIT_TIME = 3;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
//	StartPos = Location;
//	SetTimer(LifeSpan - WAIT_TIME, false);
	Super.PostBeginPlay();
	bGoingToEnd=true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetLifeSpan(float newlife)
{
	LifeSpan = newlife + WAIT_TIME;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	if(FireSource != None
		&& !FireSource.bDeleteMe
		&& FireSource.Emitters.Length > 0)
		// drag the line emitter behind it
		SuperSpriteEmitter(FireSource.Emitters[0]).LineEnd = Location;
	// check to stop the flame if it hasn't been stopped yet
	if(LifeSpan < WAIT_TIME && AutoDestroy == false)
	{
		StopStarter(true);
	}
	Super.Tick(DeltaTime);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	TriggerNextPuddle();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TriggerNextPuddle()
{
//	log("trigger next gassource "$GasSource$" next "$GasSource.Next$" ndel "$GasSource.Next.bDeleteMe$" nfire "$GasSource.Next.bOnFire$" prev "$GasSource.Prev$" del "$GasSource.Prev.bDeleteMe$" fire "$GasSource.Prev.bOnFire);
	if(GasSource != None)
	{
		if(GasSource.Next != None 
			&& !GasSource.Next.bDeleteMe
			&& !GasSource.Next.bOnFire)
		{
//				log("next not already on fire "$Location);
			GasSource.Next.SetAblaze(Location, false);
		}
//			log("going to start");
		if(GasSource.Prev != None
			&& !GasSource.Prev.bDeleteMe
			&& !GasSource.Prev.bOnFire)
		{
//				log("prev not already on fire "$Location);
			GasSource.Prev.SetAblaze(Location, false);
		}
//		}
		// And now get rid of the fuel you were burning
		if(GasSource.Next != None 
			&& !GasSource.Next.bDeleteMe)
		{
			// Sever old link back to this one we're about to destroy
			// if it was linked to you
			if(GasSource.Next.Prev == GasSource)
			{
//				log("GasSource.Next.Prev "$GasSource.Next.Prev);
				GasSource.Next.Prev = None;
			}
		}
		if(GasSource.Prev != None
			&& !GasSource.Prev.bDeleteMe)
		{
			// Sever old link back to this one we're about to destroy
			// if it was linked to you
			if(GasSource.Prev.Next == GasSource)
			{
//				log("GasSource.Prev.Next "$GasSource.Prev.Next);
				GasSource.Prev.Next = None;
			}
		}
		GasSource.Prev = None;
		GasSource.Next = None;
		if(!GasSource.bDeleteMe)
			GasSource.Destroy();
		GasSource = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function StopStarter(bool TriggerNext)
{
	if(FireSource != None)
		FireSource.StarterAtEnd(0);
	if(TriggerNext)
		TriggerNextPuddle();
	AutoDestroy=true;
	// Stop the emitter from emitting
	if(Emitters.Length > 0
		&& Emitters[0] != None)
	{
		Emitters[0].RespawnDeadParticles=False;
		Emitters[0].ParticlesPerSecond=0;
	}
	// stop the motion
	Velocity=vect(0, 0, 0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function FireEmitter SpawnStreak()
{
	if(SpawnClass != None)
	{
		FireSource = spawn(SpawnClass,Instigator,,Location);
		if(FireSource.Emitters[0].IsA('SuperSpriteEmitter'))
		{
			// save the current streak we're updatting
			SuperSpriteEmitter(FireSource.Emitters[0]).LocationShapeExtend=PTLSE_Line;
			SuperSpriteEmitter(FireSource.Emitters[0]).LineEnd = Location;
			SuperSpriteEmitter(FireSource.Emitters[0]).LineStart=Location;
		}
	}
	return FireSource;
}

defaultproperties
{
     bAllowDirChange=True
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter3
         FadeOutStartTime=1.000000
         FadeOut=True
         MaxParticles=20
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=20.000000,Max=45.000000))
		 DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.fireblue'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.800000,Max=1.500000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=30.000000,Max=100.000000))
         Name="SuperSpriteEmitter3"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter3'
     bDynamicLight=True
     Physics=PHYS_Projectile
     LifeSpan=2.000000
     CollisionRadius=5.000000
     CollisionHeight=5.000000
	 VelMag=400
}
