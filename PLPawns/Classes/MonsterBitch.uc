///////////////////////////////////////////////////////////////////////////////
// Demon Bitch Monster
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Grown to massive proportions by radiation. The true final boss.
///////////////////////////////////////////////////////////////////////////////
class MonsterBitch extends PLBossPawn
	placeable;
	
/*

Attacks planning

(IMPLEMENTED) Fist Slam
	Slams her clenched fist at the Dude. Good damage but low knockback.
	
(IMPLEMENTED) Open Palm Slam
	Slams an open palm at the Dude. Not as much damage but does high knockback, attempting to knock the Dude out of the arena and into the deadly lava.
	
(IMPLEMENTED) Fire Breath
	Same as the Mutant Champ battle
	
(IMPLEMENTED) Spit Up
	The bitch spits up one of the many things that's fallen into the hell hole:
		(IMPLEMENTED) Flaming Rocks - Explodes on contact, sends flaming shrapnel flying
		(IMPLEMENTED) Car - Explodes on contact as with KActorExplodable. Stays in the arena though, can be used as cover or for making the Bitch inhale it and smack her in the face
		Dervish Cats - 3-5 dervish cats that home in on the Dude
		(IMPLEMENTED) Gary Heads - Circle the bitch and give her a shield ala AW Cowboss. No more than 3-4 of these though.
	Additionally the bitch has a chance of vomiting up medkits, weapons, and/or ammo, in addition to (or instead of) any of the above
	
(SCRAPPED) Grab Object
	Bitch grabs off a chunk of the stage and hurls it at the Dude. The chunks remain on the field and can be used for cover or for making the Bitch inhale it later
	
(IMPLEMENTED) Inhale
	Bitch attempts to suck in and eat the Dude. If it works he gets teleported to the Bitch's interior and slowly takes damage, must shoot his way out.
	However the primary reason for this attack is to give the peaceful route a way to finish the game without dealing damage directly. If the Dude hides behind a movable object, such
	as one of the rocks the Bitch has thrown or cars she's spit up, the rock or car will fly at her and smack her in the face. This takes off about 20-30% of her health and can be used
	in addition to, or instead of, conventional attack
	
(IMPLEMENTED) Poison Gas Attack
	The Bitch burps up a cloud of toxic anthrax (cow head) gas
	
(IMPLEMENTED) Lava Dive
	Might not work because the hole the Bitch is in is so small, but I'd like to make an attack where she dives into the lava, and then bursts back out, spewing lava everywhere. Maybe could do a rising/falling lava texture/painvolume, which would give the illusion that she could dive in.
	
(IMPLEMENTED) Banshee Scream
	Obligatory catnip canceller
	
(IMPLEMENTED) Ground Pound
	Pounds the ground quickly, causing debris to rain from the ceiling and possibly hit the Dude.

*/

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() bool bForMovieOnly;			// If true, we don't spawn collision parts, early checks, or any of that shit

// Collision struct. As proven by Gordon, we can make individual invisible collision boxes
// and attach them to the pawn like boltons. Through these boxes we can deliver and receive
// TakeDamage calls, allowing us to ditch the cylinder collision for giant pawns like MB.
struct MBCollision
{
	var() Name Bone;				// Name of bone this collision model attaches to
	var() StaticMesh StaticMesh;	// Static mesh for collision model
	var() float DrawScale;			// Draw scale of model
	var() Vector DrawScale3D;		// 3D drawscale of model
	var() Vector RelativeLocation;	// Relative offset of model
	var() Rotator RelativeRotation;	// Relative rotation of model
	var() float DamageMult;			// Damage multiplier of model
	var MonsterBitchCollision Part;	// Actual collision part
};

var class<MonsterBitchCollision> CollisionClass;	// Class of collision model
var array<MBCollision> CollisionParts;	// Array of collision parts

// Gary Head mode
var vector EyeOffset;						// offset above me from where the great eye exists and protects me
var class<AWBossEye> BossEyeClass;			// Class of boss eye to use
var AWBossEye GreatEye;						// The EYE is protecting the BITCH!
var class<BossEarlyCheck> EarlyClass;		// Class of early check to use
var BossEarlyCheck EarlyCheck;				// Boss early check actor
var class<GaryHeadOrbit> OrbitHeadClass;	// Class of Gary Head to use
var array<GaryHeadOrbit> OrbitHeads;		// heads orbiting me to protect me
var float ZapFactor;			// how much closer to get to the dude from the zap damage
var Sound RicHit[2];								// Ricochet noises.
var class<SparkHitMachineGun> sparkclass;
const MOUTH_DIST		=	300;
const HEAD_LAUNCH_SPEED	=	500;
const SPARK_SND_RADIUS	=	800;

// Attacks.
var array<Actor> DamagedActors;		// Actors we've damaged during the current attack (don't damage them again)
var class<DamageType> InhaleEventDamageType;	// Class of damage used to inhale the Dude
var Name InhaleDudeEvent;			// Name of event triggered if we inhale the Dude

// Dialog.
var array<Sound> DialogMelee;		// Dialog played when using melee attack
var array<Sound> DialogAttack;		// Dialog played for other attacks
var array<Sound> DialogHurt;		// Dialog played when hurt
var array<Sound> DialogCantHurt;	// Dialog played when damage blocked by gary heads
var float SayTime;					// Amount of time we have left to talk

// Other
const BONE_MOUTH = 'mouf';	// FIXME needs to be an actual mouth socket
var bool bCanDamage;
var bool bSmerpWhenKilled;			// True if we're on the upper level and should go back down to ground floor
var float SmerpToZStart;			// Smerp from this Z-loc when killed
var float SmerpToZFinish;			// Smerp to this Z-loc when killed
var float SmerpTime;
var float VerticalMoveTime;

// Debug.
const DEBUG_LOG = false;					// If true, logs debug output.
const DEBUG_NO_COLLISION = false;		// If true, doesn't spawn collision models (for debugging)

var Rotator StartRotation;

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
// PostBeginPlay.
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (!bForMovieOnly)
	{
		SetupCollision();
		
		// Make early check system
		if(earlyclass != None)
		{
			earlycheck = spawn(earlyclass, self, , Location);
			earlycheck.SetBase(self);
		}
	}
	StartRotation = Rotation;
}

///////////////////////////////////////////////////////////////////////////////
// Destruction.
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
{
	local int i;
	
	if (earlycheck != None)
	{
		earlycheck.Destroy();
		earlycheck = None;
	}
	for (i = 0; i < CollisionParts.Length; i++)
	{
		if (CollisionParts[i].Part != None)
		{
			CollisionParts[i].Part.Destroy();
			CollisionParts[i].Part = None;
		}
	}
	if (GreatEye != None)
	{
		GreatEye.Destroy();
		GreatEye = None;
	}
	
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Projectile approaching--tell the great eye!
///////////////////////////////////////////////////////////////////////////////
function ProjectileComing(Actor Other)
{
	if(GreatEye != None
		&& !GreatEye.bDeleteMe)
	{
		GreatEye.ZapActor(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Dervish or not, this cat is toast!
///////////////////////////////////////////////////////////////////////////////
function DervishComing(Actor Other)
{
	if(GreatEye != None
		&& !GreatEye.bDeleteMe)
	{
		GreatEye.ZapActor(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Setup our collision boltons
///////////////////////////////////////////////////////////////////////////////
function SetupCollision()
{
	local int i;
	local MonsterBitchCollision NewPart;
	
	if (DEBUG_NO_COLLISION)
		return;
	
	for (i = 0; i < CollisionParts.Length; i++)
	{
		NewPart = Spawn(CollisionClass, self);
		if (NewPart != None)
		{
			// Setup actor ref
			NewPart.MyPawn = self;
			NewPart.PartIndex = i;
			
			// Setup appearance
			NewPart.SetStaticMesh(CollisionParts[i].StaticMesh);
			NewPart.AmbientGlow = AmbientGlow;
			if (CollisionParts[i].DrawScale != 0)
				NewPart.SetDrawScale(CollisionParts[i].DrawScale);
			if (CollisionParts[i].DrawScale3D != Vect(0,0,0))
				NewPart.SetDrawScale3D(CollisionParts[i].DrawScale3D);
			if (CollisionParts[i].DamageMult != 0)
				NewPart.DamageMult = CollisionParts[i].DamageMult;
			
			// Attach part
			AttachToBone(NewPart, CollisionParts[i].Bone);
			
			NewPart.SetRelativeLocation(CollisionParts[i].RelativeLocation);
			NewPart.SetRelativeRotation(CollisionParts[i].RelativeRotation);

			// Set collision
			NewPart.SetCollision(true, false, false);
			NewPart.bBlockZeroExtentTraces = true;
			NewPart.bBlockNonZeroExtentTraces = true;
			
			// Setup actor ref
			CollisionParts[i].Part = NewPart;
		}
		else
			warn(self@"failed to spawn collision bolton #"$i);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Activate collision boltons so they'll do damage
///////////////////////////////////////////////////////////////////////////////
function ActivateAttack(int CollisionNum, int Damage, float MomentumHitMag, class<DamageType> DamageType, Sound HitSound)
{
	if (CollisionParts[CollisionNum].Part != None)
		CollisionParts[CollisionNum].Part.Activate(Damage, MomentumHitMag, DamageType, HitSound);
}

///////////////////////////////////////////////////////////////////////////////
// Deactivate just this collision bolton (-1 = deactivate all)
///////////////////////////////////////////////////////////////////////////////
function DeactivateAttack(int CollisionNum)
{
	local int i;
	
	if (CollisionNum == -1)
	{
		// Reset damaged actors list
		DamagedActors.Length = 0;
		
		// Deactivate parts
		for (i = 0; i < CollisionParts.Length; i++)
			if (CollisionParts[i].Part != None)
				CollisionParts[i].Part.Deactivate();
	}
	else if (CollisionParts[CollisionNum].Part != None)
		CollisionParts[CollisionNum].Part.Deactivate();
}

function StopBlockingPlayers()
{
	local int i;
	
	for (i = 0; i < CollisionParts.Length; i++)
		if (CollisionParts[i].Part != None)
			CollisionParts[i].Part.SetCollision(true, false, false);
	
}

function DoRadiusAttack(float UseRadius, optional bool bScale)
{
	local int i;
	
	for (i = 0; i < CollisionParts.Length; i++)
		if (CollisionParts[i].Part != None)
			CollisionParts[i].Part.DoRadiusAttack(UseRadius, bScale);
	
}

///////////////////////////////////////////////////////////////////////////////
// SetupHead
///////////////////////////////////////////////////////////////////////////////
function SetupHead()
{
	Super.SetupHead();
	
	// Krotchy doesn't really want a head, so scale the head way down so it isn't seen
	if (myHead != None)
		myHead.SetDrawScale(0.1);
}

///////////////////////////////////////////////////////////////////////////////
// Take damage (pawn call) but also save who attacked me
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local int actualDamage;
	local Controller Killer;
	local Vector useloc;	
	
	// If we don't have a controller then we're either the player in a movie, or
	// we're an NPC starting out in a pain volume--either way, we don't
	// want to take damage in this state, without a controller.
	// For the player, this gives him god mode, while a movie is playing.
	if(Controller == None || !bCanDamage)
		return;
		
	// Ignore certain types of damage
	if (DamageType == class'AnthDamage')
		Damage = 0;
	if (ClassIsChildOf(DamageType, class'BurnedDamage'))
		Damage = 0;
		
	// Null out the greateye reference if it's deleted
	if (GreatEye == None || GreatEye.bDeleteMe)
		GreatEye = None;
		
	// if we have an eye, block the damage with it
	if(GreatEye != None
		&& !GreatEye.bDeleteMe)
	{
		if(ClassIsChildOf(damageType, class'BulletDamage')
			|| ClassIsChildOf(damageType, class'ExplodedDamage')
			|| ClassIsChildOf(damageType, class'BludgeonDamage'))
		{
			useloc = ZapFactor*(instigatedBy.Location - hitlocation) + hitlocation;
			GreatEye.BlastSpot(useloc, damageType);
			// Add in ricochet for bullets
			if(ClassIsChildOf(damageType, class'BulletDamage'))
				SparkHit(useloc, momentum, 1);
		}
		Damage = -Damage;
	}
	
	// Modify as necessary per game
	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	
	// For shotguns, we take four times the normal damage, because the other three pellets are going to miss due to bCanDamage.
	if (ClassIsChildOf(DamageType, class'ShotgunDamage'))
		actualDamage *= 4;

	// Save the type that just hurt us
	LastDamageType = class<P2Damage>(DamageType);
	
	// Armor check.
	// Intercept damage, and if you have armor on, and it's a certain type of damage, 
	// modify the damage amount, based on the what hurt you.
	// Armor doesn't do anything for head shots
	if(Armor > 0
		&& bHasHead
		&& (Controller == None
			|| !Controller.bGodMode))
		ArmorAbsorbDamage(instigatedby, actualDamage, DamageType, HitLocation);
	
	// Don't call at all if you didn't get hurt
	if(Damage <= 0)
	{
		// Tell the character about the non-damage. Most of them will ignore this damage
		// but some people (like Krotchy) will use this to do things
		// Report the original damage asked to be delivered as a negative, so it's not
		// used as actual damage, but it's used to know how bad the damage would have been.
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, Damage, DamageType, Momentum);
		return;
	}

	dlog("Took damage"@Damage@InstigatedBy@HitLocation@Momentum@DamageType);
	
	// Say that we can't be damaged any more this tick. Prevents explosions from hitting several
	// collision points at once and causing damage to us multiple times
	bCanDamage = false;
	
	// Send the real momentum to this function, please
	PlayHit(actualDamage, hitLocation, damageType, Momentum);
		
	// Take off health from damage
	Health = Health - actualDamage;
	
	// Check if he's dead
	if ( Health <= 0 )
	{
		// pawn died
		if ( instigatedBy != None )
			Killer = InstigatedBy.GetKillerController();
		Died(Killer, damageType, HitLocation);
	}
	else
	{
		// Tell the character about the damage
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, Damage, DamageType, Momentum);
	}	
}

///////////////////////////////////////////////////////////////////////////////
// DamageThisActor - attempts to damage actor
///////////////////////////////////////////////////////////////////////////////
singular function DamageThisActor(Actor Victim, int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	local int i;
	local Vector NewLoc;
	
	// Only attempt to damage live pawns.
	if (Pawn(Victim) == None
		|| Pawn(Victim).Health <= 0)
		return;

	// Make sure we didn't already damage them
	if (Victim == None
		|| Victim.bDeleteMe)
		return;
		
	// Don't allow collision-model self-damage (Flamethrower etc)
	if (Victim == Self)
		return;
		
	for (i = 0; i < DamagedActors.Length; i++)
		if (DamagedActors[i] == Victim)
			return;
			
	// Do the actual damage
	Victim.TakeDamage(Damage, EventInstigator, HitLocation, Vect(0,0,0), DamageType);
	
	// Apply momentum here instead of in TakeDamage.
	if (Pawn(Victim) != None && VSize(Momentum) > 0)
	{
		// If on the ground, kick them in the air
		//if (Victim.Physics == PHYS_Walking)
		//{
			NewLoc = Victim.Location;
			NewLoc.Z += FClamp(Momentum.Z * 2,0.f,512.f);
			Victim.SetLocation(NewLoc);
			Victim.SetPhysics(PHYS_Falling);
		//}
		Victim.Velocity += Momentum;
		//Victim.Velocity.Z=30000.f;
		dlog("Target velocity set to"@Victim.Velocity);
	}

	// Record that we damaged them
	DamagedActors.Insert(0,1);
	DamagedActors[0] = Victim;
}

///////////////////////////////////////////////////////////////////////////////
// Spark effects for a hit impact
///////////////////////////////////////////////////////////////////////////////
function SparkHit(vector HitLocation, vector Momentum, byte PlayRicochet)
{
	local SparkHitMachineGun spark1;

	if(sparkclass != None)
	{
		spark1 = Spawn(sparkclass,,,HitLocation);
		spark1.FitToNormal(-Normal(Momentum));
		if(PlayRicochet > 0)
			spark1.PlaySound(RicHit[Rand(ArrayCount(RicHit))],,255,,SPARK_SND_RADIUS,GetRandPitch());
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add orbiting head
//////////////////////////////////////////////////////////////////////////////
function SpawnOrbitHead()
{
	local coords usecoords;
	local vector useloc;
	local Rotator userot;
	local GaryHeadOrbit ghead;

	if(orbitheadclass != None)
	{
		usecoords = GetBoneCoords(BONE_MOUTH);
		userot = GetBoneRotation(BONE_MOUTH, 1);
		useloc = usecoords.Origin + MOUTH_DIST*vector(userot);
		ghead = spawn(orbitheadclass, self, , useloc);
		ghead.PrepVelocity(HEAD_LAUNCH_SPEED*vector(userot));
		orbitheads.Insert(orbitheads.Length, 1);
		orbitheads[orbitheads.Length-1] = ghead;
		//AWCowBossController(Controller).MadeHead();
	}
}
function RemoveOrbitHead(GaryHeadOrbit ghead)
{
	local int i;

	for(i=0; i<orbitheads.Length; i++)
	{
		if(orbitheads[i] != None
			&& orbitheads[i] == ghead)
		{
			orbitheads.Remove(i, 1);
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Is it good touch or bad touch
///////////////////////////////////////////////////////////////////////////////
singular event Touch(Actor Other)
{
	if (MonsterBitchCollision(Other) != None)
		return;
		
	dlog(self@"TOUCH"@Other);
	
	// Tell the controller, they might want to do something.
	Controller.Touch(Other);
	
	Super.Touch(Other);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dialog
// Could probably use the P2Dialog system for this instead, but we don't have
// many lines.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PlayDialog(Sound Line, optional bool bForce)
{
	if (SayTime <= 0 || bForce)
	{
		SayTime = GetSoundDuration(Line);
		PlaySound(Line, SLOT_Talk);
	}
}
// Play this dialog when doing melee attacks.
function PlayDialogMelee(optional bool bForce)
{
	PlayDialog(DialogMelee[Rand(DialogMelee.Length)], bForce);
}
// Play this dialog for other attacks.
function PlayDialogAttack(optional bool bForce)
{
	PlayDialog(DialogAttack[Rand(DialogAttack.Length)], bForce);
}
// Play this dialog when getting hurt.
function PlayDialogHurt(optional bool bForce)
{
	PlayDialog(DialogHurt[Rand(DialogHurt.Length)], bForce);
}
// Play this dialog when you have gary heads out and can't be hurt.
function PlayDialogCantHurt(optional bool bForce)
{
	PlayDialog(DialogCantHurt[Rand(DialogCantHurt.Length)], bForce);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Anim notifies - pass directly to controller
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_StartAttack()	// Called by animation to activate collision bits
{
	if (MonsterBitchController(Controller) != None)
		MonsterBitchController(Controller).Notify_StartAttack();
}
function Notify_StopAttack()	// Called by animation to deactivate collision bits
{
	if (MonsterBitchController(Controller) != None)
		MonsterBitchController(Controller).Notify_StopAttack();
}
function Notify_DoAttack()		// Called by animation for a one-time attack (spawn projectile, do radius attack etc.)
{
	if (MonsterBitchController(Controller) != None)
		MonsterBitchController(Controller).Notify_DoAttack();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Anim sequences
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Stubs.
///////////////////////////////////////////////////////////////////////////////
simulated function PlayWaiting();
simulated function PlayMoving();
simulated function PlayCrouchBeggingAnim();
simulated function PlayProneBeggingAnim();
simulated function PlayShockedAnim();
simulated function PlayDazedAnim();
simulated function PlayStunnedAnim();
simulated function PlayKickedInTheBalls();
simulated function PlayStunnedByFlashbang_In();
simulated function PlayStunnedByFlashbang_Loop();
simulated function PlayStunnedByFlashbang_Out();
simulated function PlayLaughingAnim();
simulated function PlayClappingAnim();
simulated function PlayDancingAnim();
simulated function PlaySmokingAnim();
simulated function PlayArcadeAnim();
simulated function PlayCustomAnim();
simulated function PlayGuitarAnim();
simulated function PlayKeyboardTypeAnim();
simulated function PlayPantingAnim();
simulated function PlayTurnHeadLeftAnim(float fRate, float BlendFactor);
simulated function PlayTurnHeadRightAnim(float fRate, float BlendFactor);
simulated function PlayTurnHeadDownAnim(float fRate, float BlendFactor);
simulated function PlayTurnHeadUpAnim(float fRate, float BlendFactor);
simulated function PlayTurnHeadStraightAnim(float fRate);
simulated function PlayEyesLookLeftAnim(float fRate, float BlendFactor);
simulated function PlayEyesLookRightAnim(float fRate, float BlendFactor);
simulated function PlayTalkingGesture(float userate);
simulated function PlayHelloGesture(float userate);
simulated function PlayTellOffAnim();
simulated function PlayPointThatWayAnim();
simulated function PlayYourFiredAnim();
simulated function PlayGiveGesture();
simulated function PlayTakeGesture();
simulated function PlayCoweringInBallAnim();
simulated function PlayKnockedOutAnim();
simulated function PlayCoweringInBallShockedAnim(float playspeed, float blendrate);
simulated function PlayFallOverAfterShocked();
simulated function PlayRestStanding();
simulated function PlayPatFireAnim();
simulated function PlayIdleAnim();
simulated function PlayIdleAnimQ();
simulated function PlayScreamingStillAnim();
simulated function PlayWipeFaceAnim();
simulated function PlayKissGimp();
simulated function PlayKissing();
function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType);
simulated function SwapToBurnVictim();
function SetOnFire(FPSPawn Doer, optional bool bIsNapalm); // we live in the lava, a little fire won't hurt us

///////////////////////////////////////////////////////////////////////////////
// Setup.
///////////////////////////////////////////////////////////////////////////////
simulated function SetupAnims()
{
	LinkAnims();
		
	TurnLeftAnim		= 'Idle2';
	TurnRightAnim		= 'Idle2';
	MovementAnims[0]	= 'Idle2';
	MovementAnims[1]	= 'Idle2';
	MovementAnims[2]	= 'Idle2';
	MovementAnims[3]	= 'Idle2';
}

///////////////////////////////////////////////////////////////////////////////
// Idle.
///////////////////////////////////////////////////////////////////////////////
function name GetAnimIdle()
{
	//return 'SlamPalm';
	if (FRand() <= 0.25)
		return 'Idle';
	else
		return 'Idle2';
}
function PlayIdle()
{
	LoopAnim(GetAnimIdle(), 1.0, 0.15);
}

///////////////////////////////////////////////////////////////////////////////
// Palm attack.
///////////////////////////////////////////////////////////////////////////////
function name GetAnimPalmAttack()
{
	return 'SlamPalm';
}
function PlayPalmAttack()
{
	PlayAnim(GetAnimPalmAttack(), 1.0, 0.15);
	if (FRand() < 0.75)
		PlayDialogMelee();
}

///////////////////////////////////////////////////////////////////////////////
// Fist attack.
///////////////////////////////////////////////////////////////////////////////
function name GetAnimFistAttack()
{
	return 'SlamFistDouble';
}
function PlayFistAttack()
{
	PlayAnim(GetAnimFistAttack(), 1.0, 0.15);
	if (FRand() < 0.75)
		PlayDialogMelee();
}
function PlayGroundPound()
{
	PlayAnim(GetAnimFistAttack(), 1.5, 0.15);
	if (FRand() < 0.75)
		PlayDialogMelee();
}

///////////////////////////////////////////////////////////////////////////////
// Flamethrower.
///////////////////////////////////////////////////////////////////////////////
function name GetAnimFlamethrower()
{
	return 'Flamethrower';
}
function PlayFlamethrower()
{
	PlayAnim(GetAnimFlamethrower(), 1.0, 0.15);
	if (FRand() < 0.75)
		PlayDialogAttack();
}

///////////////////////////////////////////////////////////////////////////////
// Spit up
///////////////////////////////////////////////////////////////////////////////
function name GetAnimSpit()
{
	return 'Spit';
}
function PlaySpit()
{
	PlayAnim(GetAnimSpit(), 1.0, 0.15);
	if (FRand() < 0.75)
		PlayDialogAttack();
}

///////////////////////////////////////////////////////////////////////////////
// Long Punch
///////////////////////////////////////////////////////////////////////////////
function name GetAnimLongPunch()
{
	return 'LongPunch';
}
function PlayLongPunch()
{
	PlayAnim(GetAnimLongPunch(), 1.0, 0.15);
	if (FRand() < 0.75)
		PlayDialogMelee();
}

///////////////////////////////////////////////////////////////////////////////
// Dive
///////////////////////////////////////////////////////////////////////////////
function name GetAnimDiveStart()
{
	return 'Dive_In';
}
function name GetAnimDiveWait()
{
	return 'Dive_On';
}
function name GetAnimDiveFinish()
{
	return 'Dive_Out';
}
function PlayDiveStart()
{
	PlayAnim(GetAnimDiveStart(), 1.0, 0.15);
}
function PlayDiveWait()
{
	LoopAnim(GetAnimDiveWait(), 1.0, 0.15);
}
function PlayDiveFinish()
{
	PlayAnim(GetAnimDiveFinish(), 1.0, 0.15);
	if (FRand() < 0.5)
		PlayDialogAttack();
}

///////////////////////////////////////////////////////////////////////////////
// Inhale
///////////////////////////////////////////////////////////////////////////////
function name GetAnimInhale()
{
	return 'Inhale';
}
function name GetAnimInhale_TakeHit()
{
	return 'Inhale_Hit';
}
function PlayInhale()
{
	PlayAnim(GetAnimInhale(), 0.5, 0.15);
	if (FRand() < 0.75)
		PlayDialogAttack();
}
function PlayInhale_TakeHit()
{
	PlayAnim(GetAnimInhale_TakeHit(), 1.0, 0.15);
	PlayDialogHurt();
}

///////////////////////////////////////////////////////////////////////////////
// Banshee Scream
///////////////////////////////////////////////////////////////////////////////
function name GetAnimScream()
{
	return 'Scream';
}
function PlayScream()
{
	PlayAnim(GetAnimScream(), 1.0, 0.15);
	PlayDialogAttack();
}

///////////////////////////////////////////////////////////////////////////////
// Victory Dance
///////////////////////////////////////////////////////////////////////////////
function name GetAnimDance()
{
	return 'Victory_Dance';
}
function PlayDance()
{
	LoopAnim(GetAnimDance(), 1.0, 0.15);
}

///////////////////////////////////////////////////////////////////////////////
// Living
///////////////////////////////////////////////////////////////////////////////
auto simulated state Living
{
	// Update our say-time and bCanDamage
	event Tick(float dT)
	{
		Super.Tick(dT);
		if (SayTime > 0)
			SayTime = FMin(SayTime - dT, 0.f);
		bCanDamage = true;
	}
}
	
///////////////////////////////////////////////////////////////////////////////
// Dying
///////////////////////////////////////////////////////////////////////////////
function name GetAnimDying()
{
	return 'death';
}
function name GetAnimDyingIdle()
{
	return 'Dead_idle';
}
simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	PlayAnim(GetAnimDying(), 1.0, 0.15);
}
function PlayDyingIdle()
{
	PlayAnim(GetAnimDyingIdle(), 1.0, 0.15);
}
function bool AllowRagdoll(class<DamageType> DamageType)
{
	return false;
}
// Same as super but we skip reporting to the stats/game.
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( bDeleteMe )
		return; //already destroyed

	// If I'm used for an errand, check to see if I did anything important
	CheckForErrandCompleteOnDeath(Killer);

	// mutator hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	Health = Min(0, Health);

	Level.Game.Killed(Killer, Controller, self, damageType);

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	// This was from the engine. I changed it to a constant at least.
	// It apparently bumps up a person who's moving when they die, to make it
	// a little more dramatic.
	Velocity.Z *= DIE_Z_MULT;

	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();

	PlayDying(DamageType, HitLocation);

	if ( Level.Game.bGameEnded )
		return;
	if ( !bPhysicsAnimUpdate && !IsLocallyControlled() )
		ClientDying(DamageType, HitLocation);
}
state Dying
{
	event AnimEnd(int Channel)
	{
		// just keep looping the idle anim
		PlayDyingIdle();
	}
	// Perform vertical movement via smerp
	event Tick(float dT)
	{
		local float Z, ZStart, ZFinish, Alpha;
		local Vector NewPos;
		
		if (!bSmerpWhenKilled)
			return;

		Global.Tick(dT);
		VerticalMoveTime += dT;
		
		// Figure out the Z-values
		ZStart = SmerpToZStart;
		ZFinish = SmerpToZFinish;
		
		// Calculate new Z-pos
		Alpha = FClamp(VerticalMoveTime / SmerpTime, 0.f, 1.f);
		Z = Smerp(Alpha, ZStart, ZFinish);
		
		// Set the new Z-pos
		NewPos = Location;
		NewPos.Z = Z;
		SetLocation(NewPos);
		
		// When finished return to idling
		if (Alpha == 1.f)
			bSmerpWhenKilled = false;
	}
WaitToResetFire:
	Sleep(FIRE_RESET_TIME);
	MyBodyFire=None;
Begin:
	Sleep(5.0);
	SetRotation(StartRotation);
}

defaultproperties
{
	ActorID="MonsterBitch"

	Mesh=SkeletalMesh'PLCharacters.MonsterBitch'
	Skins[0]=Texture'PLCharacterSkins.MonsterBitch.fatmonsterbody'
	Skins[1]=Texture'PLCharacterSkins.MonsterBitch.fatmonster_head'
	Skins[2]=Texture'PLCharacterSkins.MonsterBitch.dress_ripped_dark'
	CullDistance=0
	
	RotationRate=(Yaw=20480)
	//CollisionRadius=600
	//CollisionHeight=1024
	CollisionRadius=0
	CollisionHeight=0
	
	HealthMax=6000

	EyeOffset=(Z=2000.000000)
	ZapFactor=0.250000
	RicHit(0)=Sound'WeaponSounds.bullet_ricochet1'
	RicHit(1)=Sound'WeaponSounds.bullet_ricochet2'
	sparkclass=Class'FX.SparkHitMachineGun'	
	BossEyeClass=class'MonsterBitchBossEye'
	OrbitHeadClass=class'MonsterBitchGaryHeadOrbit'
	EarlyClass=class'MonsterBitchEarlyCheck'
	InhaleEventDamageType=class'MonsterBitchInhaleDamage'
	InhaleDudeEvent="AteDude"
	
	bIsFemale=true
	bNoDismemberment=true
	DeathVelMag=0
	bChameleon=false
	bLookForZombies=false
	bCellUser=false
	bNoChamelBoltons=true
	
	ControllerClass=class'MonsterBitchController'	

    CoreMeshAnim=MeshAnimation'PLCharacters.animMonsterBitch'
    AW_SPMeshAnim=None
	ExtraAnims(0)=None
	ExtraAnims(1)=None
	ExtraAnims(2)=None
	ExtraAnims(3)=None
	ExtraAnims(4)=None
	ExtraAnims(5)=None
	ExtraAnims(6)=None

	CollisionClass=class'MonsterBitchCollision'
	CollisionParts[0]=(Bone="Bip001 Spine",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Torsobox',DrawScale3D=(X=0.4,Y=0.75,Z=0.85))
	CollisionParts[1]=(Bone="Bip001 Spine1",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Torsobox',DrawScale3D=(X=0.5,Y=0.75,Z=0.85),RelativeLocation=(X=-90))
	CollisionParts[2]=(Bone="Bip001 Spine2",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Torsobox',DrawScale3D=(X=0.45,Y=0.73,Z=0.85),RelativeLocation=(X=-150))
	CollisionParts[3]=(Bone="Bip001 Spine3",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Torsobox',DrawScale3D=(X=0.45,Y=0.7,Z=0.85),RelativeLocation=(X=-121))
	CollisionParts[4]=(Bone="Bip001 Spine4",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Torsobox',DrawScale3D=(X=0.43,Y=0.75,Z=0.74),RelativeLocation=(Y=-93))
	CollisionParts[5]=(Bone="Bip001 Spine5",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Torsobox',DrawScale3D=(X=0.55,Y=0.68,Z=0.65),RelativeLocation=(X=180))
	CollisionParts[6]=(DamageMult=1.35,Bone="Bip001 Neck",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Headbox',DrawScale3D=(X=1,Y=0.97,Z=0.85))
	CollisionParts[7]=(DamageMult=0.9,Bone="Bip001 L UpperArm",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Armbox',DrawScale3D=(X=1.5,Y=1,Z=1),RelativeLocation=(X=190))
	CollisionParts[8]=(DamageMult=0.8,Bone="Bip001 L Forearm",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Armbox',DrawScale3D=(X=1.58,Y=0.56,Z=1),RelativeLocation=(X=292,Z=-30))
	CollisionParts[9]=(DamageMult=0.8,Bone="Bip001 L Hand",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Handbox',DrawScale3D=(X=1.16,Y=1,Z=1),RelativeLocation=(Y=-24,Z=-37))
	CollisionParts[10]=(DamageMult=0.8,Bone="Bip001 L Finger0",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Fingerbox',DrawScale3D=(X=0.88,Y=1.16,Z=1.21),RelativeLocation=(Y=8,Z=-10),RelativeRotation=(Yaw=-1280))
	CollisionParts[11]=(DamageMult=0.8,Bone="Bip001 L Finger1",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Fingerbox',DrawScale3D=(X=0.74,Y=1,Z=1))
	CollisionParts[12]=(DamageMult=0.8,Bone="Bip001 L Finger2",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Fingerbox',DrawScale3D=(X=0.83,Y=1,Z=1))
	CollisionParts[13]=(DamageMult=0.8,Bone="Bip001 L Finger3",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Fingerbox',DrawScale3D=(X=0.71,Y=1,Z=1))
	CollisionParts[14]=(DamageMult=0.8,Bone="Bip001 L Finger4",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Fingerbox',DrawScale3D=(X=0.55,Y=1,Z=1))
	CollisionParts[15]=(DamageMult=0.9,Bone="Bip001 R UpperArm",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Armbox',DrawScale3D=(X=1.5,Y=1,Z=1),RelativeLocation=(X=190))
	CollisionParts[16]=(DamageMult=0.8,Bone="Bip001 R Forearm",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Armbox',DrawScale3D=(X=1.58,Y=0.56,Z=1),RelativeLocation=(X=292,Z=20))
	CollisionParts[17]=(DamageMult=0.8,Bone="Bip001 R Hand",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Handbox',DrawScale3D=(X=1.16,Y=1,Z=1),RelativeLocation=(Y=-24,Z=-37))
	CollisionParts[18]=(DamageMult=0.8,Bone="Bip001 R Finger0",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Fingerbox',DrawScale3D=(X=0.88,Y=1.16,Z=1.21),RelativeLocation=(Y=8,Z=-10),RelativeRotation=(Yaw=-1280))
	CollisionParts[19]=(DamageMult=0.8,Bone="Bip001 R Finger1",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Fingerbox',DrawScale3D=(X=0.74,Y=1,Z=1))
	CollisionParts[20]=(DamageMult=0.8,Bone="Bip001 R Finger2",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Fingerbox',DrawScale3D=(X=0.83,Y=1,Z=1))
	CollisionParts[21]=(DamageMult=0.8,Bone="Bip001 R Finger3",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Fingerbox',DrawScale3D=(X=0.71,Y=1,Z=1))
	CollisionParts[22]=(DamageMult=0.8,Bone="Bip001 R Finger4",StaticMesh=StaticMesh'PL-KamekMesh.BitchMonster.Fingerbox',DrawScale3D=(X=0.55,Y=1,Z=1))
	
	DialogMelee[0]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-2CrushYouLikeABug'
	DialogMelee[1]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-2GrindYourBones'
	DialogMelee[2]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-2FeelMyWrath'
	DialogAttack[0]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-2NoChanceInHell'
	DialogAttack[1]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-2OnYourKnees'
	DialogAttack[2]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-2PatheticCreature'
	DialogAttack[3]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-2TimeToDie'
	DialogAttack[4]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-2YoullNeverWin'
	DialogHurt[0]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-3Aarrgh'
	DialogHurt[1]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-3Ack'
	DialogHurt[2]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-3Auugh'
	DialogHurt[3]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-3Owww'
	DialogHurt[4]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-3Uhh'
	DialogCantHurt[0]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-3ThatHardlyHurt'
	DialogCantHurt[1]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-3ThatsPathetic'
	DialogCantHurt[2]=Sound'PL-Dialog2.FridayShowdownDemonBitchBattleVersion3.TheBitch-3YouCantHurtMe'
	TransientSoundVolume=255.f
	TransientSoundRadius=2048.f
	SoundOcclusion=OCCLUSION_None
	AmbientGlow=30
	bCellUser=false
}