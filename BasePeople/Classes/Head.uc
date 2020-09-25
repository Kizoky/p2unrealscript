//=============================================================================
// Head
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Any head that attaches to a person's body.
//
// Heads have their own skeletal system and are capable of facial expressions
// and lip-sync, as well as getting blown off, bouncing, bleeding, etc.
//=============================================================================
class Head extends BodyPart
	placeable;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var bool bKillTalk;
var byte EyeState;				// Keep a state so we don't repeat things too often
var PukePourFeeder PukeStream;	// what comes out of my mouth
var PartDrip HeadDrips;			// Gas or pee on your face
var float SpinStartRate;		// How fast we start spinning
var float MaxSpeed;				// Fastest we can go

var	Material	BurnVictimHeadSkin;	// Texture for my burned head
var bool bExtraFlammable;		// Means just a match will catch this on fire if true

var EMood	MyMood;				// mood of my head

var bool bChanting;				// If I'm chanting or not. This has the person talking most
								// of the time, but then sometimes stopping to look around some
var float WaitTime;				// Time to wait in Exploding before you destroy yourself.
var float  SameSpotTime;		// Last time since you've moved
var vector LastSpot;			// Spot where you're stuck

// Special variables to attract animals
var String	AnimalClassString;
var class<AnimalPawn>	MyAnimalClass;
var P2Pawn PlayerMovedMe;		// If the head is disembodied and the player knocked us around, notice
								// this, so we can report it to dogs.
var bool bCanPlayBounceSound;
var Sound ExplodeHeadSound;
var array<Sound> HeadBounce;

var PersonPawn myBody;	// Body I'm connected to

var TimedMarker MyMarker;		// Marks me when I'm disembodied. Handles when I disappear

var vector RealScale;

// Time between blinks
const BLINK_TIME		= 1.5;

// Bone for making puke come out
const BONE_PUKE_EXIT = 'lower_lip';

// Animation channel usage
const CHANNEL_BASE		= 0;
const CHANNEL_EMOTION	= 1;
const CHANNEL_MOUTH		= 2;
const CHANNEL_EYES		= 3;
const CHANNEL_BLINK		= 4;

const HEAD_GRAVITY		= -1200;
const BLOOD_CHECK_DIST	= 50;	// Distance from me to wall I just hit, to see if I can put blood there

const SPEED_READY_TO_STOP=	50;
const SPEED_HARD_BOUNCE =	200;	// leave a blood splat and make noise

const DAMPEN_VELOCITY	=	0.75;
const PAWN_DAMPEN_VELOCITY= 0.07;
const DAMPEN_ROTATION	=	0.9;
const DAMPEN_ROTATION_ADD=	0.1;

// farthest distance from head, that this weapon can cause damage and make the head explode
const DISTANCE_TO_EXPLODE_HEAD_PISTOL=70;
const DISTANCE_TO_EXPLODE_HEAD_SHOTGUN=300;

const MAX_EYE_BLEND = 0.6;
const MIN_EYE_BLEND = 0.2;

const STOP_TIME	=	1.0;

const LOOKED_CENTER=2;
const LOOKED_LEFT=	4;
const LOOKED_RIGHT=	6;
const LOOKED_DOWN=	8;
const LOOKED_UP	=	9;
const BLINKED	=	10;

const DOG_RADIUS	=	2048;

const REPORT_TIME	=	0.5;

const REMOVE_ME_TIME	= 10.0;

// Keep these the same as their values in P2Pawn
const REMOVE_DEAD_START_TIME	=	12.0;
const REMOVE_DEAD_TIME			=	2.0;

// Kamek 5-1 - check how far we've flown after being shoveled and maybe give an achievement.
var vector StartPos;
var bool bBeingShoveled;
const UNITS_PER_METER = 80.000000;
const METERS_FOR_ACHIEVEMENT = 30.000000;

var() class<BodyEffects> HeadExplosionEffect;	// Class of emitter to spawn when exploded

// Change by NickP: fix
//var bool bTakeDamageTimer;
var float fTakeDamageDelay;
const DAMAGE_DELAY = 0.1;
// End

///////////////////////////////////////////////////////////////////////////////
// Get ready
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
	{
	Super.PostBeginPlay();

	if (Mesh != None && Skins[0] != None)
		Setup(Mesh, Skins[0], vect(1,1,1), AmbientGlow);

	MyAnimalClass = class<AnimalPawn>(DynamicLoadObject(AnimalClassString, class'Class'));
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	local P2MocapPawn checkpawn;

	Super.PostNetBeginPlay();

	foreach DynamicActors(class'P2MocapPawn', checkpawn)
	{
		// If they own us, then hook us up
		if(checkpawn == Owner
			&& checkpawn.MyHead == None)
		{
			checkpawn.MyHead = self;
			MyBody = PersonPawn(checkpawn);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Ensure we remove the puke stream
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	StopPuking();
	StopDripping();
	if(MyMarker != None)
		MyMarker.Destroy();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Make sure both the head and the both are independtly running on the client
// after this. 
// Since most remote client pawns don't have their MyHead hooked up correctly
// we do this here.
///////////////////////////////////////////////////////////////////////////////
simulated function TearOffNetworkConnection(class<DamageType> DamageType)
{
	// Maintain the connection if you're ... disconnected from the head. It's weird
	// sounding, but otherwise the head sticks in midair. We disconnect it, then
	// when it stops, we tear it off
	if(DamageType != class'ShovelDamage')
	{
		bTearOff=true;
		bReplicateMovement = false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set new scale
///////////////////////////////////////////////////////////////////////////////
simulated function SetScale(float NewScale)
{
	SetDrawScale3D(RealScale * NewScale);
}

///////////////////////////////////////////////////////////////////////////////
// Setup the head
///////////////////////////////////////////////////////////////////////////////
simulated function Setup(Mesh NewMesh, Material NewSkin, Vector NewScale, byte NewAmbientGlow)
	{
	// Ambient glow should match body
	AmbientGlow = NewAmbientGlow;

	// Each head can be differently shaped
	RealScale = NewScale;
	SetDrawScale3D(NewScale);
	
	Skins[0] = NewSkin;
	if (NewMesh != None)
		{
		LinkMesh(NewMesh);
		LinkSkelAnim(GetDefaultAnim(SkeletalMesh(NewMesh)));
		SetupAnims();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Blow up when you're encroached by things
///////////////////////////////////////////////////////////////////////////////
event EncroachedBy( actor Other )
{
	local vector Momentum;

	if(!bDeleteMe)
	{
		PinataStyleExplodeEffects(Location, Momentum);
		Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Just a little randomness for the pitch, around 1.0
///////////////////////////////////////////////////////////////////////////////
function float GetRandPitch()
{
	return (0.96 + FRand()*0.08);
}

///////////////////////////////////////////////////////////////////////////////
// Check if we have valid stuff for it to steam
///////////////////////////////////////////////////////////////////////////////
function bool WillSteam()
{
	return (MyPartFire != None
			&& !MyPartFire.bDeleteMe);
}

///////////////////////////////////////////////////////////////////////////////
// Do crazy effects
///////////////////////////////////////////////////////////////////////////////
function PinataStyleExplodeEffects(vector HitLocation, vector Momentum)
{
	local BodyEffects headeffects;

	if(MyBody != None)
		MyBody.DestroyHeadBoltons();

	headeffects = spawn(HeadExplosionEffect,,,HitLocation);
	headeffects.SetRelativeMotion(Momentum, Velocity);

	headeffects.PlaySound(ExplodeHeadSound,,,,100,GetRandPitch());

	if (Level.NetMode != NM_StandAlone)
		bHidden = true;

	// Have the head wait just a moment
	GotoState('Exploding');
}

///////////////////////////////////////////////////////////////////////////////
// Remove head from body and prep the collision because it's flying off his body
// and through the air, so it needs to bounce around
///////////////////////////////////////////////////////////////////////////////
function bool SetupAfterDetach()
{
	bCollideWorld=true;
	SetCollision(true,true,false);
 	bBlockZeroExtentTraces=true;
 	bBlockNonZeroExtentTraces=true;
	if(IsInState('Exploding'))
		return false;
	else
		return true;
}

///////////////////////////////////////////////////////////////////////////////
// Set the starting physics for the head flying off
///////////////////////////////////////////////////////////////////////////////
function GiveMomentum(vector momentum)
{
	SetPhysics(PHYS_PROJECTILE);
	Velocity = Momentum/Mass;
	Acceleration.z=HEAD_GRAVITY;

	bFixedRotationDir=true;
	RotationRate.Pitch =	2*SpinStartRate*FRand() - SpinStartRate;
	RotationRate.Yaw =		2*SpinStartRate*FRand() - SpinStartRate;
	RotationRate.Roll =		2*SpinStartRate*FRand() - SpinStartRate;
	bBounce=true;
}

///////////////////////////////////////////////////////////////////////////////
// You tossed the head around! If a dog is around, he'll come and want to play
// This will call the first dog it comes across, only one dog
// This *used* to check your animal friend
// first, but once I made it possible to train multiple ones, still attracting
// the closest dog first was best.
///////////////////////////////////////////////////////////////////////////////
function bool CallDog(P2Pawn Tosser)
{
	local AnimalPawn CheckP, UseP;
	local AnimalController cont;
	local byte StateChange;
	local P2Player p2p;
	local float dist, keepdist;
	local int i;

	dist = 65536;
	keepdist = dist;
	// Tell the closest dog around, about the fun head to pick up
	ForEach CollidingActors(class'AnimalPawn', CheckP, DOG_RADIUS)
	{
		// If it's a dog and he's alive and he can see it,
		// then check for him to run over
		// and grab up the pickup and bring it back to you.
		if(CheckP.class == MyAnimalClass
			&& CheckP.Health > 0
			&& CheckP.Controller != None)
		{
			dist = VSize(CheckP.Location - Location);
			if(dist < keepdist)
				//&& FastTrace(CheckP.Location, Location))
			{
				keepdist = dist;
				UseP = CheckP;
			}
		}
	}

	if(UseP != None)
	{
		cont = AnimalController(UseP.Controller);
		cont.RespondToAnimalCaller(Tosser, self, StateChange);
		if(StateChange == 1)
			return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Bounce off the wall
// Taken from Fragment.uc and modified (warfare code 829)
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall (vector HitNormal, actor HitWallActor)
{
	local Actor HitActor;
	local float speed, dampval;
	local vector checkpoint, NewHitNormal, HitLocation, addvel;
	local PlayerController P;
	local float DistFlew;
	local float MetersFlew;

	// If we're hitting an person, lose a lot of speed, so it will be around him
	// to kick it.
	if(P2Pawn(HitWallActor) != None)
	{
		speed = VSize(Velocity);
		// If it's too slow, or if it's on top of the pawn, don't slow down
		if(speed <= SPEED_READY_TO_STOP
			|| (Location.z - HitWallActor.Location.z) > HitWallActor.CollisionHeight)
			dampval = 1.0;
		else
			dampval = PAWN_DAMPEN_VELOCITY;
	}
	else
		dampval = DAMPEN_VELOCITY;

	Velocity = dampval*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping

	// Bounce the head
	speed = VSize(Velocity);

	// Record time if you weren't in the same spot. When you are, the time is recorded the last time
	// you moved, so it'll lock in that spot if you sit there too long
	if(LastSpot != Location)
	{
		LastSpot = Location;
		SameSpotTime = Level.TimeSeconds;
	}


	// We've landed
	if ( (speed < SPEED_READY_TO_STOP
			&& FPSPawn(HitWallActor) == None)
		|| (Level.TimeSeconds - SameSpotTime) > STOP_TIME)
	{
		// If the surface we've hit is vaguely flat, allow the head to stop
		if(HitNormal.Z > 0.7
			|| (Level.TimeSeconds - SameSpotTime) > STOP_TIME)
		{
			bFixedRotationDir=false;
			RotationRate.Yaw = 0;//RotationRate.Yaw*(DAMPEN_ROTATION);
			RotationRate.Roll = 0;//RotationRate.Roll*(DAMPEN_ROTATION);
			RotationRate.Pitch = 0;//RotationRate.Pitch*(DAMPEN_ROTATION + FRand()*DAMPEN_ROTATION_ADD);

			SetPhysics(PHYS_none);
			bBounce = false;
			TearOffNetworkConnection(None);
			GoToState('RemoveMe');
			// If the player tossed us around somehow (kicked us, hit us), then
			// tell dogs in the area, so they can go retrieve us
			if(PlayerMovedMe != None)
			{
				CallDog(PlayerMovedMe);
				PlayerMovedMe=None;
			}
			// If the player shoveled us, maybe give an achievement for it.
			if (bBeingShoveled)
			{
				DistFlew = VSize(Location - StartPos);
				MetersFlew = DistFlew/UNITS_PER_METER;
				//P2GameInfoSingle(Level.Game).GetPlayer().ClientMessage("head flew"@MetersFlew$"m");
				if (MetersFlew >= METERS_FOR_ACHIEVEMENT)
				{
					foreach DynamicActors(class'PlayerController', P)
						break;
					if( Level.NetMode != NM_DedicatedServer ) P.GetEntryLevel().EvaluateAchievement(P,'ArodWho');
				}
			}
		}
		else if(speed < SPEED_READY_TO_STOP) // If it's not, pick a random new direction to bounce slowly in
		{
			addvel = VRand();
			if(addvel.z < 0)
				addvel.z = -addvel.z;
			addvel.z +=0.25;
			addvel = SPEED_READY_TO_STOP*addvel;
			Velocity += addvel;
		}
	}
	else if (speed > SPEED_HARD_BOUNCE)		// we're still bouncing around
	{
		// Make it rotate slower sometimes and faster sometimes
		RotationRate.Yaw = RotationRate.Yaw*(DAMPEN_ROTATION + FRand()*DAMPEN_ROTATION_ADD);
		RotationRate.Roll = RotationRate.Roll*(DAMPEN_ROTATION + FRand()*DAMPEN_ROTATION_ADD);
		RotationRate.Pitch = RotationRate.Pitch*(DAMPEN_ROTATION + FRand()*DAMPEN_ROTATION_ADD);

		if(class'P2Player'.static.BloodMode())
		{
			// Blood effects!
			// Check wall surface and leave blood splat on this wall
			checkpoint = Location - BLOOD_CHECK_DIST*HitNormal;
			HitActor = Trace(HitLocation, NewHitNormal, checkpoint, Location, true);
			if ( HitActor != None
				&& HitActor.bWorldGeometry)
			{
				spawn(class'BloodDripSplatMaker',Owner,,HitLocation,rotator(NewHitNormal));
			}
		}
		// play a noise
		if(bCanPlayBounceSound)
		{
			PlaySound(HeadBounce[Rand(HeadBounce.Length)],,1.0,,,GetRandPitch());
			//SetTimer(GetSoundDuration(HeadBounce), false);
			//bCanPlayBounceSound=false;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// The NPC that a head just hit him (only if it's travelling fast enough)
///////////////////////////////////////////////////////////////////////////////
event Bump( Actor Other )
{
	// Only care about a bump if you are disembodied
	if(myBody == None)
	{
		if(bBounce)
		{
			// Make sure you bounced in a live person
			if(FPSPawn(Other) != None
				&& LambController(FPSPawn(Other).Controller) != None)
			{
				LambController(FPSPawn(Other).Controller).GetHitByDeadThing(self, FPSPawn(Instigator));
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Move around or explode
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, class<DamageType> ThisDamage)
{
	local vector dir;
	local float DistToMe, CheckDist;
	local bool bCheckExplode;

	if(class'P2Player'.static.BloodMode())
	{
		if(ThisDamage == class'ShotgunDamage')
		{
			CheckDist = DISTANCE_TO_EXPLODE_HEAD_SHOTGUN;
			bCheckExplode=true;
		}
		else if(ThisDamage == class'BulletDamage'
			|| ThisDamage == class'RifleDamage')
		{
			CheckDist = DISTANCE_TO_EXPLODE_HEAD_PISTOL;
			bCheckExplode=true;
		}

		if(bCheckExplode)
		{
			dir = HitLocation - InstigatedBy.Location;

			DistToMe = VSize(dir);
					
			if(DistToMe < CheckDist)
			{
				// If we're still attached, then handle body effects and detach
				if(myBody != None)
				{
					// Calling it this way should only happen AFTER THE BODY IS DEAD
					// So when the body dies, the head collision is turned on
					// so head craziness can occur, after death. And the head is
					// still attached and all.
					myBody.ExplodeHead(HitLocation, Momentum);
				}
				else
				{
					PinataStyleExplodeEffects(HitLocation, Momentum);
				}

				return;
			}
		}
	}

	// Only allow free movement if we're not still attached to a body
	if(myBody == None && Level.TimeSeconds > fTakeDamageDelay) //!bTakeDamageTimer)
	{
		// Save who last hit us
		Instigator = InstigatedBy;
		// Otherwise, just bounce the head around
		GotoState(''); // in case we were in the RemoveMe state, get us back to normal
		
		// If the player shoveled us, record our start position
		if (ThisDamage == class'ShovelDamage')
		{
			StartPos = Location;
			bBeingShoveled = true;
		}
		else // Kamek 5-19 clear this if not being shoveled
			bBeingShoveled = false;

		// Move it
		if(VSize(Momentum) > 0 && Dam > 0)
			GiveMomentum(Momentum);

		// If the player bumped us around mark us as such.
		if(ClassIsChildOf(ThisDamage, class'BludgeonDamage'))
		{
			if(P2Pawn(InstigatedBy) != None
				&& P2Pawn(InstigatedBy).bPlayer)
			{
				PlayerMovedMe = P2Pawn(InstigatedBy);
			}
		}

		// He needs to catch on fire because this was a real fire (not just a match)
		if(ClassIsChildOf(ThisDamage, class'BurnedDamage'))
		{
			CatchOnFire(FPSPawn(instigatedBy), (ThisDamage==class'NapalmDamage'));
		}

		// We got hit with a plague. You're infected now.
		if(ThisDamage == class'ChemDamage')
		{
			ChemicalInfection(FPSPawn(instigatedBy));
			return;
		}

		// Check if the head is getting pissed on, then put out the fire associated
		// with it
		if(ClassIsChildOf(ThisDamage, class'ExtinguishDamage'))
		{
			if(WillSteam())
				MyPartFire.TakeDamage(Dam, instigatedBy, hitlocation, momentum, ThisDamage);
		}
		else
		{
			// If we didn't explode, check to make normal blood
			// We make this blood, only if we've been detached, otherwise, the pawn
			// will handle that.
			if(class'P2Player'.static.BloodMode()
				&& ClassIsChildOf(ThisDamage, class'BloodMakingDamage'))
			{
				spawn(class'BloodImpactMaker',self,,HitLocation,Rotator(-momentum));
			}
		}
		// Change by NickP: fix
		//bTakeDamageTimer = true;
		//SetTimer(0.1, false);
		fTakeDamageDelay = Level.TimeSeconds + DAMAGE_DELAY;
		// End
	}
}

///////////////////////////////////////////////////////////////////////////////
// Gas is splashing on us
///////////////////////////////////////////////////////////////////////////////
function HitByGas()
{
	// Disembodied heads can catch on fire on their own
	if(myBody == None
		&& MyPartFire == None)
	{
		bExtraFlammable=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// A lit match hit us
///////////////////////////////////////////////////////////////////////////////
function HitByMatch(FPSPawn Doer)
{
	if(bExtraFlammable)
	{
		CatchOnFire(Doer);
	}
}

///////////////////////////////////////////////////////////////////////////////
// We're catching on fire
///////////////////////////////////////////////////////////////////////////////
function CatchOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
	local FireHeadEmitter tfire;

	if(MyPartFire == None)
	{
		tfire = Spawn(class'FireHeadEmitter',self,,Location);
		tfire.SetOwners(self, Doer);
		tfire.SetFireType(bIsNapalm);
		bExtraFlammable=false;
		SwapToBurnVictim();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Switch to a burned texture
///////////////////////////////////////////////////////////////////////////////
simulated function SwapToBurnVictim()
{
	if(class'P2Player'.static.BloodMode())
		Skins[0] = BurnVictimHeadSkin;
}

///////////////////////////////////////////////////////////////////////////////
// Infected and ready to spread it...
///////////////////////////////////////////////////////////////////////////////
function ChemicalInfection(FPSPawn Doer)
{
	if(MyPartChem == None)
	{
		MyPartChem = Spawn(class'ChemHeadEmitter',self,,Location);
		ChemHeadEmitter(MyPartChem).SetOwners(self, Doer);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Mark us as drippy, and put various drips on us
///////////////////////////////////////////////////////////////////////////////
function MakeDrip(class<PartDrip> useclass)
{
	local vector noffset;

	if(HeadDrips != None)
	{
		if(HeadDrips.LifeSpan == 0
			|| HeadDrips.bDeleteMe)
		{
			HeadDrips=None;
		}
		else if(HeadDrips.class != useclass)
		{
			// get rid of the previous emitter slowly
			HeadDrips.LifeSpan = 1.0;
			HeadDrips.SetTimer(0.0, false);
			HeadDrips=None;
		}
	}

	if(HeadDrips == None)
	{
		HeadDrips = spawn(useclass,self,,Location);
		HeadDrips.SetBase(Owner);
//		HeadDrips.AddOffset(noffset);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make it pour out the correct direction
///////////////////////////////////////////////////////////////////////////////
function SnapPukeStream(optional bool bInitArc)
{
	local vector startpos, X,Y,Z;
	local vector forward;
	local coords checkcoords;

	checkcoords = GetBoneCoords(BONE_PUKE_EXIT);
	PukeStream.SetLocation(checkcoords.Origin);
	PukeStream.SetDir(checkcoords.Origin, checkcoords.YAxis, ,bInitArc);
}

// Called when puke feeder destroyed
function ZeroPukeFeeder(Fluid caller)
{
	if (PukeStream == caller)
		PukeStream = None;
}

///////////////////////////////////////////////////////////////////////////////
// Actually start streaming
///////////////////////////////////////////////////////////////////////////////
function StartPuking(int newftype)
{
	//log(self@"start puking current stream"@PukeStream,'Debug');
	if(PukeStream == None)
	{
		// For when we're puking while deathcrawling (from chemical effects)
		if(newftype == 6)
			PukeStream =  spawn(class'PukePourFeederDeathCrawl',myBody,,Location,Rotation);
		else // normal puking
			PukeStream =  spawn(class'PukePourFeeder',myBody,,Location,Rotation);
		PukeStream.MyOwner = Owner;	// set the puke stream actually be owned by the pawn
		PukeStream.HeadOwner = Self;

		if(newftype == 5
			&& class'P2Player'.static.BloodMode())
			PukeStream.SetFluidType(FLUID_TYPE_BloodyPuke);
		else if(newftype == 4)
			PukeStream.SetFluidType(FLUID_TYPE_Puke);
		AttachToBone(PukeStream, BONE_PUKE_EXIT);
		SnapPukeStream(true);
		SetMood(MOOD_Puking, 1.0);
		//log(self@"created puke stream"@pukestream,'Debug');
	}
	else	
		PukeStream.ToggleFlow(0, true);
}

///////////////////////////////////////////////////////////////////////////////
// Ensure we remove the puke stream
///////////////////////////////////////////////////////////////////////////////
function StopPuking()
{
	//log(self@"stop puking current stream"@pukestream,'Debug');
	if(PukeStream != None)
	{
		SetMood(MOOD_Normal, 1.0);
		//PukeStream.Destroy();
		PukeStream.ToggleFlow(0, false);
		PukeStream=None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Ensure we remove the dripping
///////////////////////////////////////////////////////////////////////////////
function StopDripping()
{
	if(HeadDrips != None)
	{
		HeadDrips.SlowlyDestroy();
		HeadDrips = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Tick( float DeltaTime )
{
	// continuously update the puke stream if we have one
	if(PukeStream != None)
		SnapPukeStream();
}

///////////////////////////////////////////////////////////////////////////////
// Setup animations
///////////////////////////////////////////////////////////////////////////////
function SetupAnims()
	{
	// PlayAnim
	// LoopAnim
	// name Sequence, optional float Rate, optional float TweenTime, optional int Channel

	// Base channel gets base pose and is always at 100%
	PlayAnim('base', 1.0, 0.1, CHANNEL_BASE);

	// Use timer to blink eyes every so often
	bKillTalk = false;
	SetTimer(BLINK_TIME, false);

	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		if (MyMood != MOOD_Normal)
			SimAnimChannel = 1;
		else SimAnimChannel = 0;
	}
	// End
	}


///////////////////////////////////////////////////////////////////////////////
// Play the eyes close animation, and turn off all blending
///////////////////////////////////////////////////////////////////////////////
function PlayAnimDead()
{
	AnimBlendParams(CHANNEL_EMOTION, 0.0);
	AnimBlendParams(CHANNEL_MOUTH, 0.0);
	AnimBlendParams(CHANNEL_EYES, 0.0);
	AnimBlendParams(CHANNEL_BLINK, 0.0);
	LoopAnim('Dead');
}

///////////////////////////////////////////////////////////////////////////////
// Flick the eyes left or right
///////////////////////////////////////////////////////////////////////////////
simulated function PlayLookLeft(float fRate, float BlendFactor)
{
	AnimBlendParams(CHANNEL_EYES, BlendFactor);
	LoopAnim('Left', fRate, 0.0, CHANNEL_EYES);
}
simulated function PlayLookRight(float fRate, float BlendFactor)
{
	AnimBlendParams(CHANNEL_EYES, BlendFactor);
	LoopAnim('Right', fRate, 0.0, CHANNEL_EYES);
}
simulated function PlayLookDown(float fRate, float BlendFactor)
{
	AnimBlendParams(CHANNEL_EYES, BlendFactor);
	LoopAnim('Down', fRate, 0.0, CHANNEL_EYES);
}
simulated function PlayLookUp(float fRate, float BlendFactor)
{
	AnimBlendParams(CHANNEL_EYES, BlendFactor);
	LoopAnim('Up', fRate, 0.0, CHANNEL_EYES);
}

///////////////////////////////////////////////////////////////////////////////
// Set the mood
///////////////////////////////////////////////////////////////////////////////
function SetMood(EMood moodNew, float amount)
	{
	amount = FClamp(amount, 0.0, 1.0);

	MyMood = moodNew;

	switch (moodNew)
		{
		case MOOD_Happy:
		case MOOD_Normal:
			AnimBlendParams(CHANNEL_EMOTION, 0);
			break;

		case MOOD_Paranoid:
		case MOOD_Sad:
		case MOOD_Scared:
			AnimBlendParams(CHANNEL_EMOTION, amount);
			LoopAnim('sad', 1.0, 0.1, CHANNEL_EMOTION);
			break;

		case MOOD_Angry:
		case MOOD_Combat:
			AnimBlendParams(CHANNEL_EMOTION, amount);
			LoopAnim('angry', 1.0, 0.1, CHANNEL_EMOTION);
			break;

		case MOOD_Puking:
			AnimBlendParams(CHANNEL_EMOTION, amount);
			LoopAnim('barf', 1.0, 0.1, CHANNEL_EMOTION);
			break;

		default:
			Log("SetMood(): Unrecognized mood!");
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Talk for specified amount of time.
///////////////////////////////////////////////////////////////////////////////
function Talk(float fDuration)
	{
	AnimBlendParams(CHANNEL_BLINK, 0.0);
	AnimBlendParams(CHANNEL_EYES, 0.0);
	// Loop the talking animation
	AnimBlendParams(CHANNEL_MOUTH, 1);
	LoopAnim('talk', 1.0, 0.1, CHANNEL_MOUTH);

	// Set timer to stop talking when the audio stops.  This is a ugly
	// because we're also using the timer to blink the eyes, but we'll
	// eventually switch to full lip-sync, so this is a temporary hack.
	SetTimer(fDuration, false);
	bKillTalk = true;

	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		SimAnimChannel = 2;
	}
	// End
	}

///////////////////////////////////////////////////////////////////////////////
// Turn on/off chanting
///////////////////////////////////////////////////////////////////////////////
function SetChant(bool bNewChant)
	{
	bChanting = bNewChant;
	if(bChanting)
		AnimBlendParams(CHANNEL_MOUTH, 1.0, 0.1);
	else
		AnimBlendParams(CHANNEL_MOUTH, 0.0, 0.1);
	LoopAnim('yell', 1.0, 0.1, CHANNEL_MOUTH);
	SetTimer(BLINK_TIME, false);
	/*
	AnimBlendParams(CHANNEL_BLINK, 0.0);
	AnimBlendParams(CHANNEL_EYES, 0.0);
	// Loop the talking animation
	AnimBlendParams(CHANNEL_MOUTH, 1);
	LoopAnim('talk', 1.0, 0.1, CHANNEL_MOUTH);

	// Set timer to stop talking when the audio stops.  This is a ugly
	// because we're also using the timer to blink the eyes, but we'll
	// eventually switch to full lip-sync, so this is a temporary hack.
	SetTimer(fDuration, false);
	bKillTalk = true;
	*/
	}

///////////////////////////////////////////////////////////////////////////////
// Yell for specified amount of time.
///////////////////////////////////////////////////////////////////////////////
function Yell(float fDuration)
	{
	AnimBlendParams(CHANNEL_BLINK, 0.0);
	AnimBlendParams(CHANNEL_EYES, 0.0);
	// Loop the talking animation
	AnimBlendParams(CHANNEL_MOUTH, 1);
	LoopAnim('yell', 1.0, 0.1, CHANNEL_MOUTH);

	// Set timer to stop talking when the audio stops.  This is a ugly
	// because we're also using the timer to blink the eyes, but we'll
	// eventually switch to full lip-sync, so this is a temporary hack.
	SetTimer(fDuration, false);
	bKillTalk = true;

	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		SimAnimChannel = 2;
	}
	// End
	}

///////////////////////////////////////////////////////////////////////////////
// Spit disgustedly for specified amount of time.
///////////////////////////////////////////////////////////////////////////////
function DisgustedSpitting(float fDuration)
	{
	AnimBlendParams(CHANNEL_BLINK, 0.0);
	AnimBlendParams(CHANNEL_EYES, 0.0);
	// Loop the talking animation
	AnimBlendParams(CHANNEL_MOUTH, 1);
	LoopAnim('sad', 1.0, 0.1, CHANNEL_MOUTH);

	// Set timer to stop talking when the audio stops.  This is a ugly
	// because we're also using the timer to blink the eyes, but we'll
	// eventually switch to full lip-sync, so this is a temporary hack.
	SetTimer(fDuration, false);
	bKillTalk = true;

	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		SimAnimChannel = 2;
	}
	// End
	}

///////////////////////////////////////////////////////////////////////////////
// Time has expired
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	local float lookamount, looktime;
	local int randcheck;
	local bool bDoBlink;

	// Temporary hack to stop talking
	if (bKillTalk)
	{
		// Stop mouth animation
		// We probably ought to stop the animation from playing, but
		// I'm not sure how to do that.
		AnimBlendParams(CHANNEL_MOUTH, 0, 0.1);
		bKillTalk = false;

		// Change by NickP: MP fix
		if (bReplicateAnimations)
		{
			if (MyMood != MOOD_Normal)
				SimAnimChannel = 1;
			else SimAnimChannel = 0;
		}
		// End
	}
	
	// For the moment, wait until the eyes come off a seperate parent bone 'NODE_Eyes' so that
	// eyes can be blended with other emotions. Until then, playing eye anims will block
	// playing emotions. So as long as you need emtions, don't play eye anims
	if(MyMood == MOOD_Angry
		|| MyMood == MOOD_Combat
		|| MyMood == MOOD_Scared
		|| MyMood == MOOD_Sad
		|| MyMood == MOOD_Puking)
	{
		bDoBlink=false;
	}
	else
	{
	
	bDoBlink=true;



		randcheck = Rand(10);

		if(randcheck < LOOKED_CENTER)
		{
			EyeState = randcheck;
			AnimBlendParams(CHANNEL_EYES, 0.0);
			//SetTimer(BLINK_TIME, false);
		}
		else
		{
			// Never allow the eyes to turn the full amount...(not fully 1.0)
			// but always turn some
			lookamount = FRand()*MAX_EYE_BLEND + MIN_EYE_BLEND;
			
			looktime = FRand()/2;

			if(randcheck < LOOKED_LEFT)
			{
				EyeState = randcheck;
				// The smaller the rate, the longer the time it takes. So assuming the look
				// anim is 1.0, we factor this from 0.5 to 1.0, then calculate the time to wait
				PlayLookLeft(1.0 - looktime, lookamount);
				//SetTimer(2*looktime + 1.0, false);
			}
			else if(randcheck < LOOKED_RIGHT)
			{
				EyeState = randcheck;
				PlayLookRight(1.0 - looktime, lookamount);
				//SetTimer(2*looktime + 1.0, false);
			}
			else if(randcheck < LOOKED_DOWN)
			{
				EyeState = randcheck;
				PlayLookDown(1.0 - looktime, lookamount);
				//SetTimer(2*looktime + 1.0, false);
			}
			else if(randcheck < LOOKED_UP)
			{
				EyeState = randcheck;
				PlayLookUp(1.0 - looktime, lookamount);
				//SetTimer(2*looktime + 1.0, false);
			}
		}
	}

	if(bDoBlink)
	{
		EyeState = BLINKED;
		// Blink eyes and reset timer
		AnimBlendParams(CHANNEL_BLINK, 1);
		PlayAnim('blink', 1.0, 0.0, CHANNEL_BLINK);
	}

	SetTimer(BLINK_TIME, false);
}


///////////////////////////////////////////////////////////////////////////////
// Handle end of animation on specified channel
///////////////////////////////////////////////////////////////////////////////
simulated event AnimEnd(int channel)
	{
	switch (channel)
		{
		case CHANNEL_BASE:
			break;

		case CHANNEL_EMOTION:
			AnimBlendToAlpha(CHANNEL_EYES, 0, 0.0);
//			AnimBlendToAlpha(CHANNEL_EMOTION, 0, 0.1);
			break;

		case CHANNEL_MOUTH:
			AnimBlendToAlpha(CHANNEL_EYES, 0, 0.0);
//			AnimBlendToAlpha(CHANNEL_MOUTH, 0, 0.1);
			break;

		case CHANNEL_BLINK:
			AnimBlendToAlpha(CHANNEL_BLINK, 0, 0.1);
			break;

		case CHANNEL_EYES:
			AnimBlendToAlpha(CHANNEL_EYES, 0, 0.0);
			break;

		default:
			Log("Unexpected channel ended!");
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Getting ready to commit suicide with a grenade in your mouth
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Suicide
{
	ignores Timer;
	function BeginState()
	{
		AnimBlendToAlpha(CHANNEL_BLINK, 0, 0.1);
		AnimBlendToAlpha(CHANNEL_EYES, 0, 0.1);
		AnimBlendParams(CHANNEL_MOUTH, 0, 0.1);
		PlayAnim('suicide', 1.0, 0.1);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// My body is dead, so I close my eyes
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dead
{
	ignores SetMood, AnimEnd;

	///////////////////////////////////////////////////////////////////////////////
	// Don't allow damage of heads in MP after death. We want them to go away quickly
	// We have to keep the network connection at least until they come to a stop
	// though, but block people from continuing to hurt them.
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, class<DamageType> ThisDamage)
	{
		//ErikFOV Change: Fix problem
		if( bPendingDelete || bDeleteMe )
			return;
		//end
			
		if(Level.Game != None
			&& Level.Game.bIsSinglePlayer)
			Global.TakeDamage(Dam, InstigatedBy, hitlocation, momentum, ThisDamage);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function Timer()
	{
		// Change by NickP: fix
		//if (bTakeDamageTimer)
		//	bTakeDamageTimer = false;
		// End

		if(Level.NetMode == NM_Client
			|| Level.NetMode == NM_ListenServer)
		{
			if (!PlayerCanSeeMe() 
				&& (MyBody == None
					|| MyBody.bDeleteMe
					|| MyBody.Health <= 0) )
				Destroy();
			else
				SetTimer(REMOVE_DEAD_TIME, false);	
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		//ErikFOV Change: Fix problem
		if( bPendingDelete || bDeleteMe )
			return;
		//end
		
		PlayAnimDead();

		if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else if(Level.NetMode == NM_Client
			|| Level.NetMode == NM_ListenServer)
			// Clients in MP remove dead bodies after a while
			SetTimer(REMOVE_DEAD_START_TIME, false);
	}
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Get rid of me carefully
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RemoveMe extends Dead
{
	ignores SetMood, AnimEnd;

	simulated function BeginState()
	{
		Super.BeginState();

		// Check to mark me as a disembodied head for all to see.
		if(MyMarker == None)
			MyMarker = spawn(class'DeadHeadMarker',self,,Location);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Exploding
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Exploding
{
	ignores EncroachedBy, PinataStyleExplodeEffects, TearOffNetworkConnection;

	function ReportExplosion(class<HeadExplodeMarker> ADanger)
	{
		// Tell everyone that your head exploded and let them decide what to do 
		// about it
		ADanger.static.NotifyControllersStatic(
			Level,
			ADanger,
			MyBody, 
			MyBody, 
			ADanger.default.CollisionRadius,
			Location);
	}
Begin:
	Sleep(WaitTime);
	bHidden=true;
	Sleep(REPORT_TIME);
	ReportExplosion(class'HeadExplodeMarker');
	Sleep(WaitTime);
	if(myBody != None)
		myBody.DestroyHead();
	else
		Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You got knocked the fuck out
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state KnockedOutState
{
	ignores SetMood, AnimEnd;
	event BeginState()
	{
		PlayAnimDead();
	}
	event EndState()
	{
		SetupAnims();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	// Change by NickP: fix
	LODBias=2.0
	bReplicateAnimations=true
	bReplicateSkin=true
	// End

	SpinStartRate=100000
	MaxSpeed = 800
	CollisionRadius=10
	CollisionHeight=10
    bAcceptsProjectors=true
	AnimalClassString="People.DogPawn"
	bCollideWorld=false
	bCollideActors=false
    bBlockActors=false
    bBlockPlayers=false
	bProjTarget=true
 	bBlockZeroExtentTraces=false
 	bBlockNonZeroExtentTraces=false
	ExplodeHeadSound=Sound'WeaponSounds.flesh_explode'
	HeadBounce[0]=Sound'MiscSounds.People.head_bounce'
	HeadBounce[1]=Sound'MiscSounds.People.head_bounce2'
	bCanPlayBounceSound=true
	BurnVictimHeadSkin = Texture'ChamelHeadSkins.Special.BurnVictim'
	WaitTime=0.05
	bAlwaysZeroBoneOffset=true
	HeadExplosionEffect=class'ExplodedHeadEffects'
	}
