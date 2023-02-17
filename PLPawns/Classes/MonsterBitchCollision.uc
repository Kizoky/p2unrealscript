///////////////////////////////////////////////////////////////////////////////
// MonsterBitchCollision
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// Collision boltons for the Monster Bitch: invisible actors that attach
// to various bones on the skeleton and pass TakeDamage calls to the main pawn,
// as well as dealing damage to the Dude.
//
// For damaging the Dude, bBlockPlayers must be true or else this actor
// won't get any touch/bump notifications. In fact no Touch event is sent,
// just a Bump, so that redirects to the Touch function, which deals damage
// and immediately turns off blocking, allowing the Dude to be sent flying
// and not actually get stuck inside the Bitch's arm or whatever.
///////////////////////////////////////////////////////////////////////////////
class MonsterBitchCollision extends PeoplePart;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////

// Actor refs.
var MonsterBitch MyPawn;				// Ref to our monster bitch pawn. Assigned by monster bitch after being spawned.

// Dealing damage.
var int DamageDealt;					// If nonzero, this collision bolton is "active" and will damage anything it touches
var float MomentumMag;					// Amount of momentum we deal to anything we hit
var class<DamageType> MyDamageType;		// Type of damage we deal
var Sound HitSound;						// Sound made when hitting

// Taking damage.
var float DamageMult;					// How much damage we take (0.0 = none, 1.0 = full)

// Debug.
var Material CollisionTexture;			// Alpha material for viewing collision boxes in-game
var Material ActiveTexture;				// Alpha material for viewing attack boxes in-game
var Material InvisiTexture;
var int PartIndex;						// Part index (for debugging)
const DRAW_DEBUG_TEX = false;			// If true, renders an alpha over the collision box for debugging
const DEBUG_LOG = false;				// If true, logs debug output.

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Debug.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function dlog(coerce string S, optional name Tag, optional bool bTimestamp)
{
	if (DEBUG_LOG)
	{
		if (Tag != '')
			log(S, Tag, bTimestamp);
		else
			log(S, 'MonsterBitchDebug', bTimestamp);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw debug textures
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	// Disable Touch event by default
	//Disable('Touch');
	
	if (DRAW_DEBUG_TEX)
		Skins[0] = CollisionTexture;
	else
		//bHidden = true;
		Skins[0] = InvisiTexture;
}

///////////////////////////////////////////////////////////////////////////////
// When we take damage, pass that on to our pawn
///////////////////////////////////////////////////////////////////////////////
event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	//dlog("Part index"@PartIndex@"took damage:"@Damage@EventInstigator@HitLocation@Momentum@DamageType);
	if (MyPawn != None)
		MyPawn.TakeDamage(Damage * DamageMult, EventInstigator, HitLocation, Momentum, DamageType);
}

///////////////////////////////////////////////////////////////////////////////
// Activate this bolton so it will cause damage
///////////////////////////////////////////////////////////////////////////////
function Activate(int Damage, float MomentumHitMag, class<DamageType> DamageType, Sound UseSound)
{
	// Set up our damage parameters and enable Touch event.
	DamageDealt = Damage;
	MomentumMag = MomentumHitMag;
	MyDamageType = DamageType;
	HitSound = UseSound;
	//Enable('Touch');
	
	if (DRAW_DEBUG_TEX)
		Skins[0]=ActiveTexture;
		
	//dlog("Part index"@PartIndex@"activated. Damage:"@Damage@MomentumHitMag@DamageType@HitSound);
	
	// Turn on bBlockPlayers when activating, so that we'll be notified of hits.
	SetCollision(true,true,true);
}

///////////////////////////////////////////////////////////////////////////////
// Deactivate this bolton, so it will no longer do damage
///////////////////////////////////////////////////////////////////////////////
function Deactivate()
{
	// Turn off damage and disable Touch event.
	DamageDealt = 0;
	MyDamageType = None;
	//Disable('Touch');
	
	if (DRAW_DEBUG_TEX)
		Skins[0]=CollisionTexture;
		
	//dlog("Part index"@PartIndex@"deactivated.");
	SetCollision(true, false, false);
}

///////////////////////////////////////////////////////////////////////////////
// Touch: hurt this pawn if we're set up for it.
///////////////////////////////////////////////////////////////////////////////
event Bump(Actor Other)
{
	// Don't collide with other MB collision actors or MB herself
	//if (MonsterBitchCollision(Other) == None && Other != MyPawn)
		//dlog(self@"BUMP"@Other);
	
	// Send all Bump events to Touch
	Touch(Other);
}	
singular event Touch(Actor Other)
{
	local vector dir, Momentum;
	local float dist;
	
	// Don't collide with other MB collision actors or MB herself
	if (Other != None && !Other.bDeleteMe && MyPawn != None && MonsterBitchCollision(Other) == None && Other != MyPawn && MonsterBitchGaryHeadOrbit(Other) == None)
	{
		//dlog("Part index"@PartIndex@"registered a TOUCH on"@Other@"with velocity"@Other.Velocity);
		// Projectiles don't seem to register hits on these.
		if (Projectile(Other) != None && Other.Owner != MyPawn)
			Projectile(Other).ProcessTouch(MyPawn, Other.Location);
		// Special Dude Event for being eaten.
		if (MyDamageType == MyPawn.InhaleEventDamageType && Pawn(Other) != None && Pawn(Other).Controller != None && PlayerController(Pawn(Other).Controller) != None)
		{
			//dlog("TRIGGERING INHALE DUDE EVENT"@MyPawn.InhaleDudeEvent);
			TriggerEvent(MyPawn.InhaleDudeEvent, Self, MyPawn);
		}		
		else if (DamageDealt > 0)
		{
			dir = Normal(Other.Location - MyPawn.Location);
			Momentum = (MomentumMag * dir);
			// Always kick them upwards, not downwards
			Momentum.Z = abs(Momentum.Z);
			
			//dlog("Dealing damage:"@Other@DamageDealt@MyPawn@Location@Momentum@MyDamageType@HitSound);
			MyPawn.DamageThisActor(Other, DamageDealt, MyPawn, Location, Momentum, MyDamageType);
			PlaySound(HitSound,,MyPawn.TransientSoundVolume,,MyPawn.TransientSoundRadius);
			
			// Turn off bBlockPlayers now that we've hit the Dude.
			SetCollision(true, false, false);
		}
	}
	
	// Tell the pawn about it, they may want to do something.	
	if (MyPawn != None)
	{
		MyPawn.Touch(Other);
		MyPawn.StopBlockingPlayers();
		//MyPawn.DeactivateAttack(-1);
	}
}
function DoRadiusAttack(float UseRadius, optional bool bScale)
{
	local Pawn P;
	local float Dist, UseDam;
	local Vector UseMom, dir;
	
	if (DamageDealt == 0)
		return;
	
	foreach VisibleCollidingActors(class'Pawn', P, UseRadius, Location)
	{
		if (bScale)
		{
			Dist = VSize(P.Location - Location);
			UseDam = float(DamageDealt) * ((UseRadius - Dist) / UseRadius);
			dir = P.Location - MyPawn.Location;
			UseMom = MomentumMag * dir;
			UseMom = UseMom * ((UseRadius - Dist) / UseRadius);
			//dlog("RADIUS ATTACK on"@P@"dist"@Dist@"Damage"@UseDam);
			MyPawn.DamageThisActor(P, int(UseDam), MyPawn, Location, UseMom, MyDamageType);
		}
		else
		{
			Dist = VSize(P.Location - Location);
			dir = Normal(P.Location - MyPawn.Location);
			UseMom = (MomentumMag * dir);
			// Always kick them upwards, not downwards
			UseMom.Z = abs(UseMom.Z);
			
			//dlog("NON-SCALED RADIUS ATTACK on"@P@Dist@DamageDealt@MyPawn@Location@UseMom@MyDamageType);
			MyPawn.DamageThisActor(P, DamageDealt, MyPawn, Location, UseMom, MyDamageType);
		}
	}
}

defaultproperties
{
	DrawType=DT_StaticMesh
	CollisionTexture=Texture'PL-KamekTex.derp.ColAlphaTex'
	ActiveTexture=Texture'PL-KamekTex.derp.ColAlphaTexActive'
	InvisiTexture=Shader'PL-KamekTex.derp.invisitex'
	DamageMult=1.0
	PartIndex=-1
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
	bCollideWorld=True
	bBlockZeroExtentTraces=True
	bBlockNonZeroExtentTraces=True
	bUseCylinderCollision=False
	bProjTarget=True
	Physics=PHYS_None
	bStopsRifle=true
}