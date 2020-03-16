///////////////////////////////////////////////////////////////////////////////
// Limb
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Cut off from the person, acts similar to a disembodied head
// Skins[0] should be the same texture as the person this limb was connected to
//
///////////////////////////////////////////////////////////////////////////////
//class Limb extends PeoplePart
class Limb extends BodyPart
	placeable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var bool bFat;					// from a fat person
var bool bFemale;				// from a girl
var bool bPants;				// has pant leg showing

var float WaitTime;				// Time to wait in Exploding before you destroy yourself.
var float  SameSpotTime;		// Last time since you've moved
var vector LastSpot;			// Spot where you're stuck

// Special variables to attract animals
var String	AnimalClassString;
var class<AnimalPawn>	MyAnimalClass;
var P2Pawn PlayerMovedMe;		// If the limb is disembodied and the player knocked us around, notice
								// this, so we can report it to dogs.
var Sound ExplodeLimbSound;
var array<Sound> LimbBounce;
var bool bCanPlayBounceSound;

var PartDrip LimbDrips;			// Gas or pee on the limb
var P2Emitter BloodFlow;		// blood dripping from the stump end

var float SpinStartRate;		// How fast we start spinning
var float MaxSpeed;				// Fastest we can go
var float SplitMag;				// How fast we fly after a split

var	Material	BurnSkin;			// Texture for my burned limb
var bool bExtraFlammable;		// Means just a match will catch this on fire if true
var const array<StaticMesh> Meshes;	// various limbs
var const array<StaticMesh> SleeveMeshes; // same limbs, but with sleeves
var bool bCanCutInHalf;			// starts true, for basic limbs

var byte LeftLegI, RightLegI, LeftArmI, RightArmI;	// indices into Meshes array

var float TimeTillDissolve;			// gotten from your zombie parent
var float DissolveTime;				// Actual time we bubble for when dissolving
var float DissolveRate;				// DissolveRate*DeltaTime is subtracted from the scale each time
									// so have the time this takes be about the same as DissolveTime
var float MinDissolveSize;
var class<ZDissolvePuddle> dissolveclass;
var Sound DissolveSound;			// sound we make as we dissolve

// Make limbs blow up into chunks if damaged much more
var float Health;
var float TakesExploded;			// 0.0 to 1.0 for normal ranges

var bool bTakeDamageTimer;

///////////////////////////////////////////////////////////////////////////////
// CONSTS
///////////////////////////////////////////////////////////////////////////////
// farthest distance from limb, that this weapon can cause damage and make the limb explode
const DISTANCE_TO_EXPLODE_LIMB_SHOTGUN=200;

const BLOOD_CHECK_DIST	= 50;	// Distance from me to wall I just hit, to see if I can put blood there

const SPEED_READY_TO_STOP=	50;
const SPEED_HARD_BOUNCE =	200;	// leave a blood splat and make noise

const DAMPEN_VELOCITY	=	0.3;
const PAWN_DAMPEN_VELOCITY= 0.1;
const DAMPEN_ROTATION	=	0.9;
const DAMPEN_ROTATION_ADD=	0.1;

const STOP_TIME	=	1.0;

const DOG_RADIUS	=	2048;

const CAT_ATTACH_LOC	=	-20;
const CAT_ATTACH_ROT	=	16000;

const JUST_MADE_TIME	=	2.0;

const WAIT_FOR_DISSOLVE_TIME	=	3.0;

///////////////////////////////////////////////////////////////////////////////
// Get ready
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	MyAnimalClass = class<AnimalPawn>(DynamicLoadObject(AnimalClassString, class'Class'));
	Mass = FRand()*Mass + Mass;
	
	// Disable physics if desired
	if (!P2GameInfo(Level.Game).bEnableDismembermentPhysics)
		SetCollision(false,false,false);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(BloodFlow != None)
	{
		BloodFlow.SelfDestroy();
		BloodFlow = None;
	}
	if(MyPartFire != None)
	{
		MyPartFire.SelfDestroy();
		MyPartFire=None;
	}
	if(MyPartChem != None)
	{
		MyPartChem.SelfDestroy();
		MyPartChem=None;
	}
	if(LimbDrips != None)
	{
		LimbDrips.SelfDestroy();
		LimbDrips=None;
	}
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Blow up when you're encroached by things
///////////////////////////////////////////////////////////////////////////////
event EncroachedBy( actor Other )
{
	local vector Momentum;

	if(!bDeleteMe)
	{
		ExplodeLimb(Location, Momentum);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Conversion functions to keep all the various classes and permutations down
// a little. This is only for single player. MP games will want each class
// created seperately.
///////////////////////////////////////////////////////////////////////////////
function ConvertToLeftArm()
{
	SetStaticMesh(Meshes[LeftArmI]);
}
function ConvertToRightArm()
{
	SetStaticMesh(Meshes[RightArmI]);
}
function ConvertToLeftLeg()
{
	if(!bPants)
		SetStaticMesh(Meshes[LeftLegI]);
	else
		SetStaticMesh(SleeveMeshes[LeftLegI]);
}
function ConvertToRightLeg()
{
	if(!bPants)
		SetStaticMesh(Meshes[RightLegI]);
	else
		SetStaticMesh(SleeveMeshes[RightLegI]);
}

///////////////////////////////////////////////////////////////////////////////
// Setup the limb
///////////////////////////////////////////////////////////////////////////////
simulated function SetupLimb(Material NewSkin, byte NewAmbientGlow, rotator LimbRot,
							 bool bNewFat, bool bNewFemale, bool bNewPants)
{
	// Ambient glow should match body
	AmbientGlow = NewAmbientGlow;

	// setup appropriate skin
	Skins[0]=NewSkin;

	// orient along original limb direction
	//log(self$" start rot "$Rotation$" limb rot "$LimbRot);
	SetRotation(LimbRot);

	bFat=bNewFat;
	bFemale=bNewFemale;
	bPants = bNewPants;
}

///////////////////////////////////////////////////////////////////////////////
// If you can, cut this limb in half
///////////////////////////////////////////////////////////////////////////////
function bool CutInHalf(Pawn InstigatedBy)
{
	local vector usev, X, Y, Z;
	local Limb FirstHalf;
	local Material OrigSkin;

	if(bCanCutInHalf)
	{
		// Tell the dude if he did it
		if(AWDude(InstigatedBy) != None)
			AWDude(InstigatedBy).CutLimb(AWPerson(Owner));

		// Begin cutting
		OrigSkin = Skins[0];
		GetAxes(Rotation, X, Y, Z);
		// Do visual blood effects of cut
		spawn(class'LimbExplode',self,,Location);
		// Move original to one side
		SetLocation(Location + 2*CollisionRadius*X);
		// Spawn the first half
		//log(self$" x "$X$" y "$Y$" z "$Z);
		FirstHalf = spawn(class,Owner,,Location - 2*CollisionRadius*X,Rotation);
		// Throw second half (this one)
		GiveMomentum(SplitMag*(X + vect(0,0,0.5)) + Velocity*Mass);
		//log(self$" my speed "$velocity$" my loc "$Location$" new speed "$FirstHalf.Velocity$" his loc "$FirstHalf.Location);
		// Their both in half, and can go no further
		if(FirstHalf != None)
		{
			FirstHalf.bCanCutInHalf=false;
			FirstHalf.SetLimbToDissolve(TimeTillDissolve);
		}
		bCanCutInHalf=false;
		// Pick your half, based on you
		if(StaticMesh == Meshes[LeftArmI])
			// Swap your current one and throw it outwards
			// The next two slots after each main one is the two limbs that
			// represents the whole one before it
		{
			// Set first half mesh (new limb)
			if(FirstHalf != None)
				FirstHalf.SetStaticMesh(Meshes[LeftArmI+1]);
			// Convert this limb to the second half
			SetStaticMesh(Meshes[LeftArmI+2]);
		}
		else if(StaticMesh == Meshes[RightArmI])
		{
			// Set first half mesh (new limb)
			if(FirstHalf != None)
				FirstHalf.SetStaticMesh(Meshes[RightArmI+1]);
			// Convert this limb to the second half
			SetStaticMesh(Meshes[RightArmI+2]);
		}
		else if(StaticMesh == Meshes[LeftLegI])
		{
			// Set first half mesh (new limb)
			if(FirstHalf != None)
				FirstHalf.SetStaticMesh(Meshes[LeftLegI+1]);
			// Convert this limb to the second half
			SetStaticMesh(Meshes[LeftLegI+2]);
		}
		else if(StaticMesh == Meshes[RightLegI])
		{
			// Set first half mesh (new limb)
			if(FirstHalf != None)
				FirstHalf.SetStaticMesh(Meshes[RightLegI+1]);
			// Convert this limb to the second half
			SetStaticMesh(Meshes[RightLegI+2]);
		}
		else if(StaticMesh == SleeveMeshes[LeftLegI])
		{
			// Set first half mesh (new limb)
			if(FirstHalf != None)
				FirstHalf.SetStaticMesh(SleeveMeshes[LeftLegI+1]);
			// Convert this limb to the second half
			SetStaticMesh(SleeveMeshes[LeftLegI+2]);
		}
		else if(StaticMesh == SleeveMeshes[RightLegI])
		{
			// Set first half mesh (new limb)
			if(FirstHalf != None)
				FirstHalf.SetStaticMesh(SleeveMeshes[RightLegI+1]);
			// Convert this limb to the second half
			SetStaticMesh(SleeveMeshes[RightLegI+2]);
		}
		// Setup the new half that was just spawned (do it after the mesh
		// is changed so the skin takes effect
		if(FirstHalf != None)
		{
			FirstHalf.SetupLimb(Skins[0], AmbientGlow, Rotation, bFat, bFemale, bPants);
			// Throw first half back
			FirstHalf.GiveMomentum(SplitMag*(-X + vect(0,0,0.5)) + Velocity*Mass);
		}
		// Redo the skin again for the original one, after the mesh is set
		Skins[0]=OrigSkin;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Just a little randomness for the pitch, around 1.0
///////////////////////////////////////////////////////////////////////////////
function float GetRandPitch()
{
	return (0.96 + FRand()*0.08);
}

///////////////////////////////////////////////////////////////////////////////
// You tossed the limb around! If a dog is around, he'll come and want to play
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
	// Tell the closest dog around, about the fun limb to pick up
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
	local Rotator userot, normalrot;

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

	// Bounce the limb
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
		// If the surface we've hit is vaguely flat, allow the limb to stop
		if(HitNormal.Z > 0.7
			|| (Level.TimeSeconds - SameSpotTime) > STOP_TIME)
		{
			normalrot = rotator(HitNormal);
			userot.Pitch = normalrot.Pitch - 16383;
			userot.Roll = normalrot.Roll;
			userot.Yaw = Rotation.Yaw;
			// snap to ground
			bFixedRotationDir=false;
			RotationRate=rotator(vect(0,0,0));
			SetRotation(userot);

			// stop moving
			SetPhysics(PHYS_None);

			// stop blood
			if(BloodFlow != None)
			{
				BloodFlow.SelfDestroy();
				BloodFlow = None;
			}

			bBounce = false;

			// If the player tossed us around somehow (kicked us, hit us), then
			// tell dogs in the area, so they can go retrieve us
			if(PlayerMovedMe != None)
			{
				CallDog(PlayerMovedMe);
				PlayerMovedMe=None;
			}
			// Force a noise to be play when it lands
			bCanPlayBounceSound=true;
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
	}
	// play a noise
	if(bCanPlayBounceSound)
	{
		PlaySound(LimbBounce[Rand(LimbBounce.Length)],,1.0,,,GetRandPitch());
		SetTimer(2.0, false);
		bCanPlayBounceSound=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// reset bounce sound
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	bCanPlayBounceSound=true;
	bTakeDamageTimer = false;
}

///////////////////////////////////////////////////////////////////////////////
// The NPC that a limb just hit him (only if it's travelling fast enough)
///////////////////////////////////////////////////////////////////////////////
event Bump( Actor Other )
{
	if(MyPartFire != None)
		Other.TakeDamage(MyPartFire.Damage, Instigator, Location, vect(0,0,0),MyPartFire.mydamagetype);
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

///////////////////////////////////////////////////////////////////////////////
// Catch things on fire if you interpenetrate
///////////////////////////////////////////////////////////////////////////////
event Touch(Actor Other)
{
	if(MyPartFire != None)
		Other.TakeDamage(MyPartFire.Damage, Instigator, Location, vect(0,0,0),MyPartFire.mydamagetype);
}

///////////////////////////////////////////////////////////////////////////////
// Move around or explode
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, class<DamageType> ThisDamage)
{
	local vector dir;
	local float DistToMe, CheckDist;
	local bool bCheckExplode;
	local int usedam;
	
	if (bTakeDamageTimer)
		return;
	
	if(class'P2Player'.static.BloodMode())
	{
		if(ClassIsChildOf(ThisDamage, class'MacheteDamage')
			|| ClassIsChildOf(ThisDamage, class'ScytheDamage'))
		{
			if(CutInHalf(instigatedBy))
				return;
			else // if it didn't slice it, convert the damage
				ThisDamage = class'CuttingDamage';
		}
		else
		{
			if(ThisDamage == class'ShotgunDamage')
			{
				CheckDist = DISTANCE_TO_EXPLODE_LIMB_SHOTGUN;
				bCheckExplode=true;
			}

			if(bCheckExplode)
			{
				dir = HitLocation - InstigatedBy.Location;

				DistToMe = VSize(dir);
						
				if(DistToMe < CheckDist)
				{
					ExplodeLimb(HitLocation, vect(0,0,0));

					return;
				}
			}
		}
	}

	// Save who last hit us
	Instigator = InstigatedBy;
	// Otherwise, just bounce the limb around
	GotoState('BouncingAround','DoDissolve'); // in case we were in the RemoveMe state, get us back to normal

	// Move it
	if(VSize(Momentum) > 0 && Damage > 0)
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
		return;
	}

	// We got hit with a plague. You're infected now.
	if(ThisDamage == class'ChemDamage')
	{
		ChemicalInfection(FPSPawn(instigatedBy));
		return;
	}

	// Check if the limb is getting pissed on, then put out the fire associated
	// with it
	if(ClassIsChildOf(ThisDamage, class'ExtinguishDamage'))
	{
		if(WillSteam())
			MyPartFire.TakeDamage(Damage, instigatedBy, hitlocation, momentum, ThisDamage);
	}
	else
	{
		// Bullets, anthrax and electric won't explode limbs
		if(!ClassIsChildOf(ThisDamage, class'BulletDamage')
			&& !ClassIsChildOf(ThisDamage, class'AnthDamage')
			&& !ClassIsChildOf(ThisDamage, class'ElectricalDamage'))
		{
			// Lowered exploded damage so it'll get tossed around more and be cooler
			if(ClassIsChildOf(ThisDamage, class'ExplodedDamage'))
				Damage *= TakesExploded;
			// To Make things a little random, cutting damages are randomized
			if(ClassIsChildOf(ThisDamage, class'CuttingDamage'))
			{
				usedam = Damage/2;
				Damage = Rand(usedam) + usedam;
			}

			Health-=Damage;
		}

		// Blow up from too much damage
		if(Health <= 0)
		{
			ExplodeLimb(HitLocation, vect(0,0,0));
			return;
		}
		// If we didn't explode, check to make normal blood
		// We make this blood, only if we've been detached, otherwise, the pawn
		// will handle that.
		else if(class'P2Player'.static.BloodMode()
			&& ClassIsChildOf(ThisDamage, class'BloodMakingDamage'))
		{
			spawn(class'BloodImpactMaker',self,,Location,Rotator(-momentum));
		}
	}
	
	bTakeDamageTimer = true;
	SetTimer(0.1, false);
}

///////////////////////////////////////////////////////////////////////////////
// Do crazy effects
///////////////////////////////////////////////////////////////////////////////
function ExplodeLimb(vector HitLocation, vector Momentum)
{
	local LimbExplode lex;
	/*
	local ExplodedHeadEffects headeffects;

	headeffects = spawn(class'ExplodedHeadEffects',,,HitLocation);
	headeffects.SetRelativeMotion(Momentum, Velocity);
	headeffects.PlaySound(ExplodeLimbSound,,,,100,GetRandPitch());
*/

	lex = spawn(class'LimbExplode', , , HitLocation);

	// Have the Limb wait just a moment
	GotoState('Exploding');
}

///////////////////////////////////////////////////////////////////////////////
// Switch to a burned texture
///////////////////////////////////////////////////////////////////////////////
simulated function SwapToBurnVictim()
{
	if(class'P2Player'.static.BloodMode())
		Skins[0] = BurnSkin;
}

///////////////////////////////////////////////////////////////////////////////
// When we get moved usually, we start making blood
///////////////////////////////////////////////////////////////////////////////
function MakeBloodFlow()
{
	if(BloodFlow == None)
	{
		BloodFlow=spawn(class'LimbBlood',self,,Location);
		BloodFlow.SetBase(self);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set the starting physics for this flying off
///////////////////////////////////////////////////////////////////////////////
function GiveMomentum(vector momentum)
{
	SetPhysics(PHYS_PROJECTILE);
	Velocity = Momentum/Mass;
	Acceleration.z=PART_GRAVITY;

	MakeBloodFlow();
	
	bRotateToDesired=false;
	bFixedRotationDir=true;
	RotationRate.Pitch =	2*SpinStartRate*FRand() - SpinStartRate;
	RotationRate.Yaw =		2*SpinStartRate*FRand() - SpinStartRate;
	RotationRate.Roll =		2*SpinStartRate*FRand() - SpinStartRate;
	bBounce=true;
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
// Gas is splashing on us
///////////////////////////////////////////////////////////////////////////////
function HitByGas()
{
	// Disembodied limbs can catch on fire on their own
	if(MyPartFire == None)
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
	local FireLimbEmitter tfire;

	// Only catch on fire again, if we haven't already burned once
	if(MyPartFire == None
		&& Skins[0] != BurnSkin)
	{
		tfire = Spawn(class'FireLimbEmitter',self,,Location);
		tfire.SetOwners(self, Doer);
		tfire.SetFireType(bIsNapalm);
		bExtraFlammable=false;
		SwapToBurnVictim();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Mark us as drippy, and put various drips on us
///////////////////////////////////////////////////////////////////////////////
function MakeDrip(class<PartDrip> useclass)
{
	local vector noffset;

	if(LimbDrips != None)
	{
		if(LimbDrips.LifeSpan == 0
			|| LimbDrips.bDeleteMe)
		{
			LimbDrips=None;
		}
		else if(LimbDrips.class != useclass)
		{
			// get rid of the previous emitter slowly
			LimbDrips.LifeSpan = 1.0;
			LimbDrips.SetTimer(0.0, false);
			LimbDrips=None;
		}
	}

	if(LimbDrips == None)
	{
		LimbDrips = spawn(useclass,self,,Location);
		LimbDrips.SetBase(Owner);
//		LimbDrips.AddOffset(noffset);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Ensure we remove the dripping
///////////////////////////////////////////////////////////////////////////////
function StopDripping()
{
	if(LimbDrips != None)
	{
		LimbDrips.SlowlyDestroy();
		LimbDrips = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Return true if you're allowed to be grabbed up by a cat and ground down
///////////////////////////////////////////////////////////////////////////////
function bool CanBeGround()
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Snap to cat (usually a cat grinding it up)
///////////////////////////////////////////////////////////////////////////////
function SnapToCat(Actor Other, name BName)
{
	local Rotator setrot;
	local vector setloc;

	GotoState('GrabbedByPawn');
	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);
	SetPhysics(PHYS_None);
	SetCollision(false, false, false);
	bCollideWorld=false;
	// We have to attach to the bone first, to get the relative position to work
	Other.AttachToBone(self, BName);
	setrot.Yaw=CAT_ATTACH_ROT;
	SetRelativeRotation(setrot);
	setloc.y=CAT_ATTACH_LOC;
	SetRelativeLocation(setloc);
}

///////////////////////////////////////////////////////////////////////////////
// Drop from cat
///////////////////////////////////////////////////////////////////////////////
function DropFromCat(Actor Other)
{
	GotoState('BouncingAround','DoDissolve');
	Other.DetachFromBone(self);
	SetCollision(true, true, false);
	bCollideWorld=true;
	SetRelativeRotation(default.RelativeRotation);
}

///////////////////////////////////////////////////////////////////////////////
// Zombie limbs dissolve after a time
///////////////////////////////////////////////////////////////////////////////
function SetLimbToDissolve(float dtime)
{
	TimeTillDissolve=dtime;
	GotoState('BouncingAround');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// JustMade, don't let things cut me in half just yet, otherwise
// the flying blade with turn all limbs in halves by touching them on spawns
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state JustMade
{
	ignores TakeDamage;
Begin:
	Sleep(JUST_MADE_TIME*Level.TimeDilation);
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Waiting to be dissolved
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state BouncingAround
{
Begin:
DoDissolve:
	// Start dissolving after a time
	if(TimeTillDissolve > 0)
	{
		Sleep(TimeTillDissolve);
		GotoState('PrepForDissolving');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// A cat has us and will probably grind us down to the bone
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GrabbedByPawn
{
	ignores GiveMomentum, TakeDamage, ExplodeLimb, EncroachedBy, CanBeGround;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Being ground down
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GettingGroundDown extends GrabbedByPawn
{
	function Tick(float DeltaTime)
	{
		local vector newd;
		newd = DrawScale3D;
		newd.x-=DeltaTime;
		if(newd.x < 0.0)
			newd.x = 0.0;			
		SetDrawScale3D(newd);
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
	ignores EncroachedBy, ExplodeLimb, CanBeGround;
Begin:
	Sleep(WaitTime);
	bHidden=true;
	Sleep(WaitTime);
	Destroy();
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PrepForDissolving
// Hold him to he doesn't move around for a few seconds first, before
// removing him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepForDissolving
{
	ignores CanBeGround, TakeDamage;

	///////////////////////////////////////////////////////////////////////////////
	// Do actual dissolve now
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		GotoState('Dissolving');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Turn off our collision with players/damage first
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		bBlockZeroExtentTraces=false;
		bBlockNonZeroExtentTraces=false;
		SetCollision(false, false, false);
		SetTimer(WAIT_FOR_DISSOLVE_TIME, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dissolving
// bubble effects play as I 'sink' into the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dissolving
{
	ignores CanBeGround, TakeDamage;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		local vector newd;
		newd = DrawScale3D;
		// shrink mostly up and down
		newd.z-=(DeltaTime*DissolveRate);
		if(newd.z < MinDissolveSize)
			newd.z = MinDissolveSize;
		SetDrawScale3D(newd);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get rid of the guy now
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		Destroy();
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function MakeDissolvePuddle(vector loc)
	{
		local ZDissolvePuddle dissolver;
		local vector endpt, hitlocation, hitnormal;
		local Actor HitActor;

		// Trace down and find the ground first
		endpt = loc;
		endpt.z -= default.CollisionHeight;
		HitActor = Trace(HitLocation, HitNormal, endpt, loc, true);
		if(HitActor != None
			&& HitActor.bStatic)
		{
			loc = HitLocation;
		}
		// Set emitter at neck line
		dissolver = spawn(dissolveclass,self,,loc);
		dissolver.SetTimer(DissolveTime, false);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Turn off our collision with players/damage first
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local coords usecoords;
		// How long we dissolve for
		SetTimer(DissolveTime, false);

		// Setup boiling sound
		AmbientSound=DissolveSound;
		SoundRadius=30;
		TransientSoundRadius=SoundRadius;
		SoundVolume=255;
		TransientSoundVolume=SoundVolume;
		SoundPitch=0.75;

		// Make effects to go with shrinking
		if(dissolveclass != None)
		{
			// Make only one emitter for the limb
			MakeDissolvePuddle(Location);
		}
	}
}

defaultproperties
{
     WaitTime=0.050000
     AnimalClassString="People.DogPawn"
     ExplodeLimbSound=Sound'AWSoundFX.Body.meathit'
     LimbBounce(0)=Sound'AWSoundFX.Body.limbflop1'
     LimbBounce(1)=Sound'AWSoundFX.Body.limbflop2'
     bCanPlayBounceSound=True
     SpinStartRate=70000.000000
     MaxSpeed=800.000000
     SplitMag=30000.000000
     BurnSkin=Texture'ChameleonSkins.Special.BurnVictim'
     Meshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_limb'
     Meshes(1)=StaticMesh'awpeoplestatic.Limbs.L_leg_calf'
     Meshes(2)=StaticMesh'awpeoplestatic.Limbs.L_leg_foot'
     Meshes(3)=StaticMesh'awpeoplestatic.Limbs.R_leg_limb'
     Meshes(4)=StaticMesh'awpeoplestatic.Limbs.R_leg_calf'
     Meshes(5)=StaticMesh'awpeoplestatic.Limbs.R_leg_foot'
     Meshes(6)=StaticMesh'awpeoplestatic.Limbs.L_arm_limb'
     Meshes(7)=StaticMesh'awpeoplestatic.Limbs.L_arm_forearm'
     Meshes(8)=StaticMesh'awpeoplestatic.Limbs.L_hand'
     Meshes(9)=StaticMesh'awpeoplestatic.Limbs.R_arm_limb'
     Meshes(10)=StaticMesh'awpeoplestatic.Limbs.R_arm_forearm'
     Meshes(11)=StaticMesh'awpeoplestatic.Limbs.R_hand'
     SleeveMeshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_limb_pants'
     SleeveMeshes(1)=StaticMesh'awpeoplestatic.Limbs.L_leg_foot_pants'
     SleeveMeshes(2)=StaticMesh'awpeoplestatic.Limbs.L_leg_calf_pants'
     SleeveMeshes(3)=StaticMesh'awpeoplestatic.Limbs.R_leg_limb_pants'
     SleeveMeshes(4)=StaticMesh'awpeoplestatic.Limbs.R_leg_foot_pants'
     SleeveMeshes(5)=StaticMesh'awpeoplestatic.Limbs.R_leg_calf_pants'
     bCanCutInHalf=True
     RightLegI=3
     LeftArmI=6
     RightArmI=9
     DissolveTime=6.000000
     DissolveRate=0.200000
     MinDissolveSize=0.300000
     dissolveclass=Class'AWEffects.ZDissolvePuddle'
     DissolveSound=Sound'AWSoundFX.Body.acidsizzle'
     Health=70.000000
     TakesExploded=0.200000
     DrawType=DT_StaticMesh
     LifeSpan=60.000000
     StaticMesh=StaticMesh'awpeoplestatic.Limbs.L_arm_limb'
     Skins(0)=Texture'ChameleonSkins.Special.RWS_Shorts'
     CollisionRadius=10.000000
     CollisionHeight=6.000000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
     Mass=90.000000
}
