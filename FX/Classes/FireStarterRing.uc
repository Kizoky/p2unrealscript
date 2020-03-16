//=============================================================================
// FireStarterRing
//=============================================================================
class FireStarterRing extends P2Emitter;
// Extends emitter because this thing doesn't actually cause damage, it just sets fires.

// exported variables
var ()class<FireEmitter> SpawnClass;

// internal variables
var FireEmitter FireSource;
var Fluid GasSource;
var float RadVel;
var bool bKillMeNow;
var int ccount;

// consts
const WAIT_TIME = 3;


replication
{
	// server sends these variable to client
	reliable if(Role == ROLE_Authority)
		RadVel;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
//	StartPos = Location;
//	SetTimer(LifeSpan - WAIT_TIME, false);
	Super.PostBeginPlay();
	SuperSpriteEmitter(Emitters[0]).LocationShapeExtend=PTLSE_Circle;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function SetLifeSpan(float newlife)
{
	LifeSpan = newlife + WAIT_TIME;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Tick(float DeltaTime)
{
	if(Emitters.Length > 0)
	{
		Emitters[0].SphereRadiusRange.Max += RadVel*DeltaTime;
		Emitters[0].SphereRadiusRange.Min = Emitters[0].SphereRadiusRange.Max;
	}
	// check to stop the flame if it hasn't been stopped yet
	if(LifeSpan < WAIT_TIME && bKillMeNow == false)
	{
		StopStarter();
	}

	Super.Tick(DeltaTime);
}

simulated function Destroyed()
{
	TriggerNextPuddle();
	Super.Destroyed();
}

function TriggerNextPuddle()
{
//	log("checked to trigger next trail "$self);
//	log("gassource "$GasSource);
	if(GasSource != None)
	{
//	log("next "$GasSource.Next);
//	log("prev "$GasSource.Prev);
//		log("calling stop starter");
		
		//if(!bGoingToEnd)
		//{
//			log("going to end");
			if(GasSource.Next != None 
				&& !GasSource.Next.bDeleteMe
				&& !GasSource.Next.bOnFire)
			{
//				log("next not already on fire "$Location);
				GasSource.Next.SetAblaze(Location, false);
			}
//		}
//		else
//		{
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
			GasSource.SlowlyDestroy();
		GasSource = None;
	}
}

simulated function StopStarter()
{
//	log("Stop Starter got called for ring");
//	log("Final radius requested "$Emitters[0].SphereRadiusRange.Max);
//	log(" here was our lifespan "$LifeSpan);

	if(FireSource != None)
		FireSource.StarterAtEnd(Emitters[0].SphereRadiusRange.Max);

	TriggerNextPuddle();
	// Stop the emitter from emitting
	if(Emitters[0] != None)
	{
		bKillMeNow=true;
		Emitters[0].RespawnDeadParticles=False;
		Emitters[0].ParticlesPerSecond=0;
	}
	if(GasSource != None)
		GasSource.SlowlyDestroy();
	// stop the motion
	Velocity=vect(0, 0, 0);
	RadVel=0;
}
/*
simulated function HitWall (vector HitNormal, actor Wall)
{
	local string str;
//	local float tmp;
//	tmp = VSize(Velocity);
//	Velocity = tmp*(HitNormal*Velocity);
	//log("vx");
	//str = String(Velocity.x);
	//log(str);

	//log("vy");
	//str = String(Velocity.y);
	//log(str);

	
	if(bAllowDirChange)
	{
		// make a new streak since we've changed directions
		SpawnStreak();
		// velocity runs along wall (like liquid)
		Velocity.x*=(1 - abs(HitNormal.x));
		Velocity.y*=(1 - abs(HitNormal.y));
		Velocity.z*=(1 - abs(HitNormal.z));
	}
	else if(LifeSpan > WAIT_TIME)// kill the streak now
	{
		LifeSpan=WAIT_TIME;
		StopStarter();
	}


	log("vx");
	str = String(Velocity.x);
	log(str);

	log("vy");
	str = String(Velocity.y);
	log(str);

//	tmp = Velocity.x;
//	Velocity.x = Velocity.y;
//	Velocity.y = tmp;
//		Velocity = (( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity); 

	Super.HitWall(HitNormal, Wall);
}
*/

function FireEmitter SpawnPuddle()
{
	if(SpawnClass != None)
		FireSource = spawn(SpawnClass,Instigator,,Location);

	return FireSource;
}

defaultproperties
{
     SpawnClass=Class'Fx.FirePuddle'
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter2
		SecondsBeforeInactive=0.0
        FadeOutStartTime=0.500000
        FadeOut=True
        MaxParticles=50
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=10.000000,Max=40.000000))
        ParticlesPerSecond=50.000000
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
    	DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.fireblue'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.400000,Max=0.600000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=30.000000,Max=150.000000))
        Name="SuperSpriteEmitter2"
     End Object
     Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter2'
     bDynamicLight=True
     Physics=PHYS_Projectile
     LifeSpan=2.000000
     CollisionRadius=5.000000
     CollisionHeight=5.000000
	 AutoDestroy=true
	 RemoteRole=ROLE_SimulatedProxy
}
