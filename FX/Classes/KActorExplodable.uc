///////////////////////////////////////////////////////////////////////////////
//
// KActorExplodable
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Karma object that blows up when hit by somethings
// (it's filled with gasoline)
//
// Be nice if it could derive from PropBreakable, but it must be KActor.
//
///////////////////////////////////////////////////////////////////////////////
class KActorExplodable extends KActor;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
// external
var ()float DamageThreshold;		// How much damage in a single shot you have to
									// do in order to break the prop
var ()float Health;					// How much health we have. At 0, we break
var ()sound ExplodingSound;			// Sound played when it breaks
var ()StaticMesh BrokenStaticMesh;	// Mesh subbed assigned to StaticMesh when the 
									// prop is broken
var ()float ExplosionMag;			// How hard it throws the car
var ()class<Wemitter>BurningEmitterClass; // Fire that burns on the thing after you've blown it up
var ()class<FireWoof>ExplosionEmitterClass; // Fire woof effect used for explosion

var() class<DamageType> DamageFilter;// Damage type we're concerned about.
									// To allow all damage types, have this be none (default)
var() bool bBlockFilter;			// true means you'll accept all damages except DamageFilter
									// false means you'll only accept DamageFilter.(default is false)
var() bool bTriggerControlled;		// Triggers are the only things that allow these kactors to explode, if true
var() Texture DamageSkin;			// What texture to put on the damaged mesh
var() bool bBulletsMoveMe;			// Cars for instance don't want to move with bullet damage.. they just
									// wake it up.
var() vector ExplodeDirection;		// Vague direction it gets thrown in when it blows up. Normalized vector.
									// ExplodeDirectionRandom below gets added on to it.
var() float ExplodeDirectionRandom; // 0 to 1.0 of total ExplosionMag that is used to throw it in a random direction
var() bool	bReadyForImpact;		// Will make a noise when it hits something, only if true


///////////////////////////////////////////////////////////////////////////////
// internal
var vector OldLocation;				// Where we exploded at
var float ExplosionDamage;			// calced from the magnitude
var float ExplosionRadius;			// calced from the magnitude
var float WoofConversion;			// calced from the magnitude
var float DelayToHurtTime;			// Time you need to wait till you hurt things with your explosion blast
									// This usually only gets set when you are triggered/hurt by a another explosion
									// in order to make good 'explosion chains'
var bool  bBlownUp;					// It's already dead
var WEmitter BurningEmitter;		// Emitter that is of class BurningEmitterClass.

///////////////////////////////////////////////////////////////////////////////
// CONST
///////////////////////////////////////////////////////////////////////////////

const DEFAULT_DELAY_HURT_TIME	= 0.5;

// Buffer size for catching pawns on fire when they get near the burning thing.
const PAWN_RAD					= 90;

const BULLET_DAMP				= 1000;

///////////////////////////////////////////////////////////////////////////////
// Triggers explosion
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
{
	local vector Momentum, HitLocation;
	local float tempf;

	Super.Trigger(Other, EventInstigator);
	
	tempf = CollisionRadius/2;
	HitLocation.x = Location.x + (CollisionRadius*FRand() - tempf);
	HitLocation.y = Location.y + (CollisionRadius*FRand() - tempf);
	HitLocation.z = Location.z;

	// Stubbed this out because it was preventing a Jesus run on the Napalm factory.
	//Instigator = EventInstigator;
	BlowThisUp(HitLocation, Momentum); // momentum gets initted in this function, so don't worry about
			// setting it before hand
	return;
}

///////////////////////////////////////////////////////////////////////////////
// Make kactor explodabes not make sounds when other kactors hit them (like
// having a dog dish hit a car will make it make a big noise)
///////////////////////////////////////////////////////////////////////////////
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	if(KActor(Other) == None
		&& bReadyForImpact)
	{
		//log(self$" doing kimpact "$Other$" vel "$impactVel$" norm "$impactNorm);
		Super.KImpact(Other, pos, impactVel, impactNorm);
	}
}

///////////////////////////////////////////////////////////////////////////////
// If DamageFilter is set, 
// and bBlockFilter is false only allow this damage
// else don't allow only this damage
///////////////////////////////////////////////////////////////////////////////
function bool AcceptThisDamage(class<DamageType> damageType)
{
	if(bTriggerControlled)
		return false;

	if(damageType == None)
		return true;

	if(DamageFilter != None)
	{
		// accept only filter
		if(!bBlockFilter)
		{
			if(!ClassIsChildOf(damageType, DamageFilter))
				return false;
		}
		else	// block the filter type
		{
			if(ClassIsChildOf(damageType, DamageFilter))
				return false;
		}
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// For some reason HurtRadius is flakey, so we use this slower version to
// make sure it hits stuff
///////////////////////////////////////////////////////////////////////////////
simulated final function CheckHurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	HurtRadius(DamageAmount, DamageRadius, DamageType, Momentum, HitLocation);
	/*
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	
//	if( bHurtEntry )
//		return;

//	bHurtEntry = true;
	foreach CollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
//	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
//		log("victim one "$Victims);
		if( (!Victims.bHidden)
			&& (Victims != self) 
			&& (Victims.Role == ROLE_Authority) )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist; 
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator, 
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
		} 
	}

//	bHurtEntry = false;
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Modify the hit information, so it ridiculously flies up into the air
// and falls back over, while on fire
// put it below the object
///////////////////////////////////////////////////////////////////////////////
function CalcExplosionPhysics(out vector HitLocation, 
							  out vector Momentum)
{
	local float expm, exph;

	HitLocation = Location;
	HitLocation.x += (FRand()*2*CollisionRadius) - CollisionRadius;
	HitLocation.y += (FRand()*2*CollisionRadius) - CollisionRadius;
	HitLocation.z -= CollisionRadius;

	expm = ExplosionMag*ExplodeDirectionRandom;
	exph = expm/2;
	Momentum.z = Frand()*expm;
	Momentum.x = (FRand()*expm - exph);
	Momentum.y = (FRand()*expm - exph);
	Momentum = Momentum + ExplosionMag*Normal(ExplodeDirection);
}

///////////////////////////////////////////////////////////////////////////////
// Set it to dead, trigger sounds and all, and blow it up, setting off the physics
///////////////////////////////////////////////////////////////////////////////
function BlowThisUp(vector HitLocation, vector Momentum)
{
	local P2Emitter p2e;
	local FireWoof fw;
	local Actor HitActor;
	local vector exploc, startloc, NewHit, NewNormal;

	// Can't blow up twice
	if(bBlownUp)
		return;

	// set me to all blowed up
	bBlownUp=true;

	// set to dead
	Health=0;

	// Spawn effect so we don't have to record the hit values and 
	// do it later in Broken beginstate or something. It's just
	// more efficient here
//			p2e = spawn(ExplosionEffect, self,,Location);

	// Play the breaking sound
	// We must make sure the place where we play this sound is above the ground, so
	// first move the kactor up from out of the bsp, if it's inside it.
	// Use the z of the hitlocation to start, and the x,y of the original location.
	// Trace down from there and pick the ground below if you were stuck in the ground before
	startloc = Location;
	startloc.z = HitLocation.z;
	if(Trace(NewHit, NewNormal, Location, startloc, false) != None)
	{
		// we're stuck the ground, somehow, trying to get from the hit point the center of the
		// karma
		// So move up to where we last hit something
		SetLocation(NewHit);
	}

	// Now safely play our sound, as we should be well out of the ground.
	PlaySound(ExplodingSound,SLOT_Interact);

	// Modify the hit information, so it ridiculously flies up into the air
	// and falls back over, while on fire
	// put it below the object
	CalcExplosionPhysics(HitLocation, Momentum);

	exploc = Location;
	// Make explosion effect
	if(ExplosionEmitterClass != None)
	{
		fw = spawn(ExplosionEmitterClass,,,exploc);
		fw.SetSize(ExplosionMag*WoofConversion);
		fw.ShakeCamera(ExplosionMag*WoofConversion*0.3);
	}

	// Turn on burning fire effect
	if(BurningEmitterClass != None)
	{
		BurningEmitter = spawn(BurningEmitterClass,,,exploc);
		BurningEmitter.SetBase(self);
		if(bUseCylinderCollision)
			BurningEmitter.SetCollisionSize(CollisionRadius + PAWN_RAD, CollisionHeight + PAWN_RAD);
		else
			BurningEmitter.SetCollisionSize(PAWN_RAD, PAWN_RAD);
	}

	// Calc nums
	ExplosionDamage = ExplosionMag/1500;
	ExplosionRadius = ExplosionMag/100;

	// Save where we blew up
	OldLocation = Location;

	// move us
	if(bKTakeShot)
		KAddImpulse(momentum, hitlocation);

	// Trigger breaking event, if any.
	if (Event != '')
		TriggerEvent(Event, self, Instigator);

	// Say we're broken so we won't break anymore
	GotoState('Broken');
}

///////////////////////////////////////////////////////////////////////////////
// Check if we have valid stuff for it to steam
///////////////////////////////////////////////////////////////////////////////
function bool WillSteam()
{
	return (BurningEmitter != None
			&& !BurningEmitter.bDeleteMe);
}

///////////////////////////////////////////////////////////////////////////////
// If strong enough, it breaks the prop
///////////////////////////////////////////////////////////////////////////////
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	// If it's trying to extinguish a flame, see if we can pass it along
	// to the burning fire on this one
	if(damageType == class'ExtinguishDamage')
	{
		if(WillSteam())
			BurningEmitter.TakeDamage(Damage, InstigatedBy, hitlocation, momentum, damageType);
	}
	else	// Take other damages.
	{
		if(!AcceptThisDamage(damageType))
			return;
			
		// Skip if dead
		if (Health <= 0)
			return;

		// vastly increase fire damage, to make them explode better with gasoline
		if (ClassIsChildOf(DamageType, class'BurnedDamage')
			&& Damage < 1)
			Damage = 1;

		// Only remove health if the singular damage was strong enough
		if(damage > DamageThreshold
			|| ClassIsChildOf(DamageType, class'BurnedDamage'))
		{
			// Will make noises when hitting stuff now
			bReadyForImpact=true;

			Health -= damage;
			// if you run out of health, break
			if(Health <= 0 && !bBlownUp)
			{
				// Kamek 4-23
				// If the dude blew us up, record it and give them an acheivement.
				if (!bBlownUp && Self.IsA('CarExplodable') && PlayerController(InstigatedBy.Controller) != None)
				{
					if( Level.NetMode != NM_DedicatedServer ) PlayerController(InstigatedBy.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(InstigatedBy.Controller),'CarsDestroyed',1,true);
				}
				
				if(ClassIsChildOf(damageType, class'ExplodedDamage'))
					DelayToHurtTime=DEFAULT_DELAY_HURT_TIME;
				Instigator = InstigatedBy;
				BlowThisUp(HitLocation, Momentum);
				return;
			}

			// If a bullet hit me, then use a very reduce momentum to shake it
			if(!bBulletsMoveMe
				&& ClassIsChildOf(damageType, class'BulletDamage'))
				momentum = BULLET_DAMP*Normal(momentum);

			Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Broken
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Broken
{
//	ignores TakeDamage;

	///////////////////////////////////////////////////////////////////////////////
	// You've just been freshly broken, generate effects
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		// Will make noises when hitting stuff now
		bReadyForImpact=true;

		// Swap the mesh to the broken mesh if you have one
		if(BrokenStaticMesh != None)
		{
			SetDrawType(DT_StaticMesh);
			SetStaticMesh(BrokenStaticMesh);
			if(DamageSkin != None)
			{
				if(Skins.Length < 1)
					Skins.Insert(Skins.Length, 1);
				Skins[0]=DamageSkin;
			}
		}
		else	// If we don't have a broken mesh, they don't want to
				// see it anymore, so just destroy it
			Destroy();
	}
Begin:
	Sleep(DelayToHurtTime);
	// wait just a second before you hurt things with the explosion
	CheckHurtRadius(ExplosionDamage, ExplosionRadius, class'ExplodedDamage', ExplosionMag, OldLocation );
}


defaultproperties
{
    Begin Object Class=KarmaParams Name=KarmaParams0
        Name="KarmaParams0"
        KFriction=0.970000
    End Object
    KParams=KarmaParams'KarmaParams0'

	Health=10
	CollisionRadius=100
	CollisionHeight=100
	ExplosionMag=40000
	BurningEmitterClass=class'FireSizeableEmitter'
	ExplosionEmitterClass=class'SizeableWoof'
	WoofConversion=0.0025

	ExplodingSound=Sound'MiscSounds.Props.CarExplode'
	TransientSoundRadius=512

	bUseCylinderCollision=true
	bPawnMovesMe=false

	bBulletsMoveMe=true
	ExplodeDirection=(x=0.0,y=0.0,z=1.0)
	ExplodeDirectionRandom=0.5
}

