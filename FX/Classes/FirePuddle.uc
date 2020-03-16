//=============================================================================
// FirePuddle.
//=============================================================================
class FirePuddle extends FireEmitter;

var		float BurstTimer;
var		class<FirePuddleBurst> BurstClass;
var		float RadVel;

//const RADIUS_FUZZ_INCREASE = 1.2;
const EMISSION_RATIO = 1.3;
const PARTICLE_RATIO = 0.75;
const MIN_PARTICLE_USE=40;
const DAMAGE_RADIUS_RATIO=3.0;
const FLAT_GROUND_RATIO = vect(0, 0, 0.5);
const PLACEMENT_RATIO = 0.4;
const MAKE_BURST_TIME = 6.0;
const HURT_PAWN_RADIUS_MULT	=	1.3;
const HURT_GAS_RADIUS_MULT	=	2.5;


replication
{
	// variables sent from server to client
	reliable if(Role == ROLE_Authority)
		RadVel;

	// functions sent from server to client
	reliable if(Role == ROLE_Authority)
		ClientPrepExpansion, ClientSynchSize;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	if(SuperSpriteEmitter(Emitters[0]) != None)
	{
		SuperSpriteEmitter(Emitters[0]).LocationShapeExtend=PTLSE_Circle;
		SuperSpriteEmitter(Emitters[0]).SphereRadiusRange.Max=0;
	}
	Super.PostBeginPlay();
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
// Hurt locally authoritative actors within the raduis.
///////////////////////////////////////////////////////////////////////////////
/*
function PickyHurtRadius( float DamageAmount, 
						 float DamageRadiusOuter, 
						 float DamageRadiusInner,
						 class<DamageType> DamageType, 
						 float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist, useradius, hurtdamage;
	local vector dir;
	local bool bAllowHit;
	
	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadiusOuter, HitLocation )
	{
		if( (Victims != self) && (Victims.Role == ROLE_Authority) )
		{
			if(Instigator == Victims)
			{
				// Only if it's the guy who made this then we check
				// a smaller radius, internally here, to be nice to the owner,
				// everyone else, including other pawns, we mess up bad...
				if(VSize(Victims.Location - HitLocation) < DamageRadiusInner - Victims.CollisionRadius)
				{
					useradius = DamageRadiusInner;
					bAllowHit=true;
				}
			}
			else
			{
				useradius = DamageRadiusOuter;
				bAllowHit=true;
			}

			if(bAllowHit)
			{
				dir = Victims.Location - HitLocation;
				dist = FMax(1,VSize(dir));
				dir = dir/dist; 
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/useradius);
				hurtdamage = damageScale * DamageAmount;
				if(hurtdamage < 1)
					hurtdamage = 1;
				Victims.TakeDamage
				(
					hurtdamage,
					Instigator, 
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					vect(0,0,0),
					DamageType
				);
				bAllowHit=false;
			}
		} 
	}
	bHurtEntry = false;
}
*/

///////////////////////////////////////////////////////////////////////////////
// Try to hurt actors around you
///////////////////////////////////////////////////////////////////////////////
function DealDamage(float DeltaTime)
{
	if(Damage != 0)
	{
		// Like most games, it's nicer to players and pawns than it is
		// to gasoline. A bigger radius is used to light the gas, than
		// hurt the players
		/*
		PickyHurtRadius(DeltaTime*Damage, 
			DefCollRadius,
			Emitters[0].SphereRadiusRange.Max,
			MyDamageType, 0, Location );
		*/
		// Call "picky" version of HurtRadiusEX
		HurtRadiusEX(DeltaTime * Damage, DefCollRadius, MyDamageType, 0, Location,,,,,,,,,,Emitters[0].SphereRadiusRange.Max);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide if we should play sounds or lights
// We check around us, and see if any other 
///////////////////////////////////////////////////////////////////////////////
function DoSoundAndLight()
{
	// we always want sound
	AmbientSound = BurningSound;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PrepExpansion(float UseRadius, float MinRadius, vector FinalLocation,
								float UseRadVel)
{
	local float count;

	DamageDistMag = UseRadius*DAMAGE_RADIUS_RATIO;

	CollisionLocation = FinalLocation + DamageDistMag*FLAT_GROUND_RATIO;

	// Used when initially moving outwards
	RadVel = UseRadVel;

	DoSoundAndLight();

	// Figure out the particle count on the server because we have access to the 
	// game info. 
	count = UseRadius-2*MinRadius;
	if(count < 0)
		count = 0;
	count+=MIN_PARTICLE_USE;
	// Decrease fire detail 
	if(P2GameInfo(Level.Game) != None)
		count = P2GameInfo(Level.Game).ModifyByFireDetail(count);

	ClientPrepExpansion(count);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientPrepExpansion(float count)
{
	SuperSpriteEmitter(Emitters[0]).SetMaxParticles(count);
	//log("use radius "$UseRadius);
	//log("new max particles "$Emitters[0].MaxParticles);
	Emitters[0].ParticlesPerSecond = Emitters[0].MaxParticles*EMISSION_RATIO;
	//log("new particles per second"$Emitters[0].ParticlesPerSecond);
	Emitters[0].InitialParticlesPerSecond = Emitters[0].ParticlesPerSecond;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientSynchSize(float newsize)
{
	Emitters[0].SphereRadiusRange.Max = newsize;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function StarterAtEnd(float SetDist)
{
	local SmokePuddle spuddle;
	local vector useloc;

	// Snap now to proper radius
	Emitters[0].SphereRadiusRange.Max = SetDist;
	ClientSynchSize(Emitters[0].SphereRadiusRange.Max);

	// starter has made the full fire puddle, so make some smoke now
	useloc = Location;
	useloc.z += (Emitters[0].StartVelocityRange.Z.Max*PLACEMENT_RATIO);
	if(Level.NetMode == NM_DedicatedServer
		|| P2GameInfoSingle(Level.Game) != None)
	{
		spuddle = spawn(class'SmokePuddle',Instigator,,useloc);
		spuddle.PrepSize(Emitters[0].SphereRadiusRange.Max);
		// point fire to your smoke
		MySmoke = spuddle;
		// update your smoke's lifespan
		MySmoke.SetupLifetime(OrigLifeSpan);
	}

	// Use this for the inner check against a pawn (as opposed to the one 
	// calculated below which we use to hurt gasoline.
	// Like most games, it's nicer to players and pawns than it is
	// to gasoline. A bigger radius is used to light the gas, than
	// hurt the players
	DefCollRadius=HURT_PAWN_RADIUS_MULT*Emitters[0].SphereRadiusRange.Max;

	// set the real collision radius only after you're all set up
	SetCollisionSize(HURT_GAS_RADIUS_MULT*Emitters[0].SphereRadiusRange.Max, CollisionHeight);

	// Now start hurting things
	GotoState('Burning');
	ClientGotoState('Burning');
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
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{	
		DealDamage(DeltaTime);
		if(Emitters.Length > 0)
		{
			Emitters[0].SphereRadiusRange.Max += RadVel*DeltaTime;
		}

		Super.Tick(DeltaTime);
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function EndState()
	{
		// stop the motion
		Velocity=vect(0, 0, 0);
		SetPhysics(PHYS_None);
		RadVel=0;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		// stub
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Burning
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated state Burning
{
	function Tick(float DeltaTime)
	{
		local vector useloc;
		local float tworad, onerad;

		Super.Tick(DeltaTime);

		// Check every once in a while, to make a burst of flames shoot out
		BurstTimer-=DeltaTime;
		if(BurstTimer < 0)
		{
			BurstTimer = Rand(MAKE_BURST_TIME);
			useloc = Location;
			tworad = 2*Emitters[0].SphereRadiusRange.Max;
			onerad = Emitters[0].SphereRadiusRange.Max;
			useloc.x += Rand(tworad) - onerad;
			useloc.y += Rand(tworad) - onerad;
			if(BurstClass != None)
				spawn(BurstClass,Instigator,,useloc);
		}
	}

	simulated function BeginState()
	{
		Super.BeginState();
		BurstTimer = Rand(MAKE_BURST_TIME);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{
	local color tempcolor;
	local vector usevect, usevect2;

		// position
		tempcolor.B=255;
		Canvas.DrawColor = tempcolor;
		usevect = Location;
		usevect.z+=CollisionHeight;
		usevect2 = Location;
		usevect2.z-=CollisionHeight;
		Canvas.Draw3DLine(usevect, usevect2);
		// col radius
		tempcolor.R=255;
		tempcolor.G=0;
		tempcolor.B=0;
		Canvas.DrawColor = tempcolor;
		usevect = Location;
		usevect.x+=CollisionRadius;
		usevect2 = Location;
		usevect2.x-=CollisionRadius;
		Canvas.Draw3DLine(usevect, usevect2);
}

defaultproperties
{
	 DamageDistMag=60;

	 BurstClass=class'FirePuddleBurst'

     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter8
		SecondsBeforeInactive=0.0
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=80
         RespawnDeadParticles=False
         StartLocationOffset=(Z=-5.000000)
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=40.000000,Max=80.000000))
         ParticlesPerSecond=50.000000
         InitialParticlesPerSecond=50.000000
         AutomaticInitialSpawning=False
		 DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.firegroup3'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.600000,Max=0.900000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=160.000000,Max=400.000000))
         Name="SuperSpriteEmitter8"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter8'
     LifeSpan=35.000000
	 DefCollRadius=50
	 DefCollHeight=0
	 bCollideActors=true
	 CollisionHeight=200
	 CollisionRadius=1
	 AutoDestroy=true
	 RemoteRole=ROLE_SimulatedProxy
     Physics=PHYS_Projectile
}
