//=============================================================================
// FireEmitter.
//=============================================================================
class FireEmitter extends Wemitter;

// internal
var		int OrigLifeSpan;
var		float SizeChange;
var		float VelZChange;
var		float EmissionChange;

var		float Damage;
var		float DamageDistMag;		// How far the radius or trace should go to hurt stuff
									// Make it seperate from the official CollisionRadius
									// because this is just for damage and the other is const
									// and this needs to change dynamically sometimes.
//var		float MomentumTransfer; // Momentum magnitude imparted by impacting projectile.
var		class<DamageType> MyDamageType;
var		vector CollisionLocation;
var		float	DefCollRadius;
var		float	DefCollHeight;
var		float	Health;
var		SmokeEmitter	MySmoke;
var		Sound   BurningSound;		// Sound for the fire

var		bool	bAllowDynamicLight;	// This is supposed to be a global, like settable
									// in the menu for the user. Defaults to false, for speed
var		float   FadeTime;			// You're ready to die, so before you wait and fade, you fade for this time
var		float	WaitAfterFadeTime;	// After the fading, you wait this time before you quit completely

// Kamek additions -- if our instigator is disconnected, reset it
var bool bDCdInstigator;

const SHOW_LINES=0;

const OTHER_FIRE_SEARCH_RADIUS	=	1024;
const LIGHT_RAD	= 64;

replication
{
	// functions sent from server to client
	reliable if(Role == ROLE_Authority)
		ClientGotoState;
}


// Functions 
///////////////////////////////////////////////////////////////////////////////
// setup lifetimes
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	// Check if we're turned off or not
	// Only check first one
	if(!Emitters[0].Disabled)
		SetupLifetime(LifeSpan);
	else
	{
		OrigLifeSpan=LifeSpan;
		LifeSpan=0;
	}
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Blank out the owner, but keep the instigator, so it won't play the ambient
// sounds in your ears in MP.
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	SetOwner(None);
}

///////////////////////////////////////////////////////////////////////////////
// Server uses this to force client into NewState
///////////////////////////////////////////////////////////////////////////////
simulated function ClientGotoState(name NewState, optional name NewLabel)
{
	if(Role != ROLE_Authority)
	    GotoState(NewState,NewLabel);
}

///////////////////////////////////////////////////////////////////////////////
// Turn on and set lifetime
///////////////////////////////////////////////////////////////////////////////
function Trigger( Actor Other, Pawn EventInstigator )
{
	Super.Trigger(Other, EventInstigator);

	SetupLifetime(OrigLifeSpan);
	GotoState('Burning');
	ClientGotoState('Burning');
}

///////////////////////////////////////////////////////////////////////////////
// setup lifetimes
///////////////////////////////////////////////////////////////////////////////
simulated function SetupLifetime(float uselife)
{
	if(uselife > 0)
	{
		OrigLifeSpan=uselife;
		LifeSpan = uselife + (FadeTime+WaitAfterFadeTime);
	}
	else
	{
		OrigLifeSpan=uselife;
		LifeSpan=0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide if we should play sounds or lights
// We check around us, and see if any other 
///////////////////////////////////////////////////////////////////////////////
function DoSoundAndLight()
{
	local FireEmitter fe;
	local float dist;
	local int lightcount, soundcount;
	
	// Do a search around you for other fire, if there is some, decide
	// whether or not to make sound
	ForEach CollidingActors(class'FireEmitter', fe, OTHER_FIRE_SEARCH_RADIUS, Location)
	{
		if(!fe.bDynamicLight)
			lightcount++;

		if(fe.AmbientSound != None)
			soundcount++;

		dist = VSize(fe.Location-Location);
//		log(self$" other fire I hit "$fe$" dist "$dist);
	}

//	log(self$" total count making sound "$soundcount$" lightcount "$lightcount);
	if(soundcount == 0)
	{
		AmbientSound=BurningSound;
		//log(self$" using sound!");
	}

	if(lightcount == 0
		&& bAllowDynamicLight)
	{
		SetupAsLight(LIGHT_RAD);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make me a light
///////////////////////////////////////////////////////////////////////////////
function SetupAsLight(float Rad)
{
	bDynamicLight=true;
	LightType=LT_Flicker;
    LightEffect=LE_None;
    LightBrightness=150;
	LightSaturation=150;
	LightHue=15;
    LightRadius=Rad;
}

///////////////////////////////////////////////////////////////////////////////
// handle new collision location
///////////////////////////////////////////////////////////////////////////////
function SetCollisionLocation(vector SurfaceNormal)
{
	CollisionLocation = Location + DamageDistMag*SurfaceNormal;
}

///////////////////////////////////////////////////////////////////////////////
// stub out for when starter gets to end
///////////////////////////////////////////////////////////////////////////////
simulated function StarterAtEnd(float SetDist)
{
	// STUB for child actor
}

///////////////////////////////////////////////////////////////////////////////
// Try to hurt actors around you
///////////////////////////////////////////////////////////////////////////////
function DealDamage(float DeltaTime)
{
	if(Damage != 0)
	{
		//log("deal damage "$self);
		//log("CollisionLoc "$CollisionLocation);
		//log("Location "$Location);
		// 0 here for momentumtransfer (second from end)
		// And project the hurting radius off the ground(the hitnormal) by the radius.
		HurtRadius(DeltaTime*Damage, CollisionRadius, MyDamageType, 0, Location );
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get put out by non-flammable liquids
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	if(damageType == class'ExtinguishDamage'
		&& Health > 0)
	{
		Health-=Damage;
		//log(self$" this hit by water "$Health);

		if(Health <= 0)
		{
			Health = 0;
			// Tell server about fading
			GotoState('Fading');
			// Tell all clients so visually all emitters will be in synch
			spawn(class'FireEmitterTalk', self);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// hurt things in your tick
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	DealDamage(DeltaTime);

	// Kamek additions to stop log spam when cow head users disconnect
	if (!bDCdInstigator && Instigator == None)
	{
		Instigator = None;
		bDCdInstigator = True;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Expanding
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto simulated state Expanding
{
	function Tick(float DeltaTime)
	{
		// STUB
	}
	simulated function BeginState()
	{
		if(LifeSpan == 0)
		{
			GotoState('');
			ClientGotoState('');
		}
		else
		{
			GotoState('Burning');	// no start up for default, go now to burning
			ClientGotoState('Burning');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Make sure if you do anything in Expanding that you move Burning along the appopriate
// distance in time
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated state Burning
{
	simulated function Timer()
	{
		GotoState('Fading');
		// Tell all clients so visually all emitters will be in synch
		spawn(class'FireEmitterTalk', self);
	}
	simulated function SetupLifetime(float uselife)
	{
		Global.SetupLifetime(uselife);
		if(LifeSpan > 0)
			SetTimer(OrigLifeSpan, false);
	}
	simulated function BeginState()
	{
		if(LifeSpan > 0)
			SetTimer(OrigLifeSpan, false);
		// otherwise burn forever
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Fading
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated state Fading
{
	simulated function Timer()
	{
		GotoState('WaitAfterFade');
		ClientGotoState('WaitAfterFade');
	}
	simulated function Tick(float DeltaTime)
	{
//		Emitters[0].StartSizeRange.X.Max+=(2*SizeChange*DeltaTime);
//		Emitters[0].StartSizeRange.X.Min+=(SizeChange*DeltaTime);
		Emitters[0].StartVelocityRange.Z.Max+=(VelZChange*DeltaTime);
		Emitters[0].StartVelocityRange.Z.Min+=(VelZChange*DeltaTime);
		Emitters[0].InitialParticlesPerSecond+=EmissionChange*DeltaTime;
		Emitters[0].ParticlesPerSecond+=EmissionChange*DeltaTime;

		// Don't hurt stuff here, in this state
	}
	
	simulated function BeginState()
	{
		SetTimer(FadeTime, false);
//		SizeChange=-Emitters[0].StartSizeRange.X.Min/(4*FadeTime);
		VelZChange=-Emitters[0].StartVelocityRange.Z.Min/(FadeTime);
		EmissionChange = -(Emitters[0].ParticlesPerSecond)/(2*FadeTime);

		// make your smoke go away too
		if(MySmoke != None)
		{
			MySmoke.GotoState('Fading');
			// Tell all clients so visually all emitters will be in synch
			// Fade the smoke the same way
			spawn(class'FireEmitterTalk', MySmoke);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait after the fade
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated state WaitAfterFade
{
	function Tick(float DeltaTime)
	{
		// STUB
	}

	// Don't hurt stuff here, in this state
	simulated function BeginState()
	{
		local int i;
		for(i=0; i<Emitters.Length; i++)
		{
			Emitters[i].RespawnDeadParticles = false;
			if(SuperSpriteEmitter(Emitters[i]) != None)
				SuperSpriteEmitter(Emitters[i]).AllowParticleSpawn=false;
		}
		LifeSpan = WaitAfterFadeTime;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw debug info
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{

	//local vector endline;
	local color tempcolor;

	if(Damage != 0 && SHOW_LINES==1)
	{
		// show collision radius
		//endline = Location + vect(200, 0, 200);
		tempcolor.R=255;
		Canvas.DrawColor = tempcolor;
		//Canvas.Draw3Circle(CollisionLocation, DamageDistMag, 0);
		//log("damage dist "$DamageDistMag);
		//Location, endline, 0);
	}
}

defaultproperties
{
	Damage=100
	DamageDistMag=60
	MyDamageType=Class'BurnedDamage'
	bCollideActors=false
	Health=60
	BurningSound=Sound'WeaponSounds.fire_large'
	FadeTime=3.0
	WaitAfterFadeTime=1.0
	Texture=Texture'PostEd.Icons_256.FireEmitter'
	DrawScale=0.25
}
