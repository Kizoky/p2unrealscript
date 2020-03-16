///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ZombieHead
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// If I get killed my zombie body dies
//
///////////////////////////////////////////////////////////////////////////////
class ZombieHead extends AWHead;

var AWZombie MyZombie;		// Same as MyBody but we keep it becuase
							// zombies don't die till the head is dead (usually)
var Pawn LastHurter;		// Person who last hurt us

var float TimeTillDissolve;	// Time the head can sit around, undisturbed, before it dissolves
var float DissolveTime;				// Actual time we bubble for when dissolving
var float DissolveRate;				// DissolveRate*DeltaTime is subtracted from the scale each time
									// so have the time this takes be about the same as DissolveTime
var float MinDissolveSize;
var class<ZDissolvePuddle> dissolveclass;
var Sound DissolveSound;			// sound we make as we dissolve


///////////////////////////////////////////////////////////////////////////////
// Move around or explode
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, class<DamageType> ThisDamage)
{
	local vector dir;
	local float DistToMe, CheckDist;
	local bool bCheckExplode, bDoExplode;

	// Don't let me hurt myself
	if(instigatedBy == Owner)
		return;

	// Save who last hurt you
	LastHurter = instigatedBy;
	// even in none blood mode, you still can kill there heads
	//if(class'P2Player'.static.BloodMode())
	//{
		// Any bullet damage will kill heads off body
		if(myBody == None
			&& ClassIsChildOf(ThisDamage, class'BulletDamage'))
		{
			bDoExplode=true;
		}
		// Close range shotgun will kill head on body
		else if(ThisDamage == class'ShotgunDamage')
		{
			CheckDist = DISTANCE_TO_EXPLODE_HEAD_SHOTGUN;
			bCheckExplode=true;
		}
		// sniper rifle blows them up too, any distance
		else if(ClassIsChildOf(ThisDamage, class'RifleDamage'))
		{
			bDoExplode=true;
		}
		// sledge hammer
		else if(ClassIsChildOf(ThisDamage, class'SledgeDamage'))
		{
			bDoExplode=true;
		}
		// zombie smashing them between it's hands blows up another zombie's head
		else if(ClassIsChildOf(ThisDamage, class'SwipeSmashDamage'))
		{
			bDoExplode=true;
		}
		// zombie heads explode from explosions
		else if(ClassIsChildOf(ThisDamage, class'ExplodedDamage'))
		{
			bDoExplode=true;
		}
		// Chainsaw always explodes the head
		else if (ClassIsChildOf(ThisDamage, class'ChainsawDamage')
			|| ClassIsChildOf(ThisDamage, class'ChainsawBodyDamage'))
			bDoExplode = true;
		// Don't let the scythe kill a head until it's off the body for a while
		else if(MyBody == None
			&& (ClassIsChildOf(ThisDamage, class'ScytheDamage')
				|| ClassIsChildOf(ThisDamage, class'MacheteDamage'))
			&& Level.TimeSeconds - TimeAtCut > TIME_TILL_SCYTHE_KILL)
		{
			bDoExplode=true;
		}

		if(bCheckExplode
			|| bDoExplode)
		{
			dir = HitLocation - InstigatedBy.Location;

			DistToMe = VSize(dir);
					
			if(DistToMe < CheckDist
				|| bDoExplode)
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
					// Tell the dude if he did it
					if(AWDude(InstigatedBy) != None)
						AWDude(InstigatedBy).CrushedHead(FPSPawn(Owner));
					PinataStyleExplodeEffects(HitLocation, Momentum);
				}

				return;
			}
		}
	//}

	Super(Head).TakeDamage(Dam, instigatedBy, hitlocation, momentum, thisdamage);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	local P2MocapPawn checkpawn;

	Super.PostNetBeginPlay();

	SetZombieBody(MyBody);
	SetZombieBodyHead();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetZombieBody(Pawn newbody)
{
	MyZombie = AWZombie(newbody);
}
function SetZombieBodyHead()
{
	MyZombie.MyZombieHead = self;
}

///////////////////////////////////////////////////////////////////////////////
// When I blow up, kill my zombie body, unless we're floating
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(MyZombie != None)
	{
		MyZombie.MyZombieHead = None;

		if(!MyZombie.bFloating)
			MyZombie.TakeDamage(MyZombie.Health, LastHurter, MyZombie.Location, vect(0,0,0), class'HeadKillDamage');
	}

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool IsDissolving()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Don't call dogs because I'm trying to dissolve myself, usually
///////////////////////////////////////////////////////////////////////////////
function bool CallDog(P2Pawn Tosser)
{
	// STUB
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RemoveMe
// Make sure it dissovles after a time
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RemoveMe
{
	///////////////////////////////////////////////////////////////////////////////
	// If they get hurt, then reset their timer
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, class<DamageType> ThisDamage)
	{
		// Reset timer
		SetTimer(TimeTillDissolve, false);
		Global.TakeDamage(Dam, InstigatedBy, hitlocation, momentum, ThisDamage);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Dissolve out of existence
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		GotoState('Dissolving');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		// Set the timer on the zombie head to have it fizzle out after a time
		SetTimer(TimeTillDissolve, false);
	}
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// My body is dead, so I close my eyes
// Make sure it dissovles after a time
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dead
{
	///////////////////////////////////////////////////////////////////////////////
	// If they get hurt, then reset their timer
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, class<DamageType> ThisDamage)
	{
		// Reset timer
		SetTimer(TimeTillDissolve, false);
		Global.TakeDamage(Dam, InstigatedBy, hitlocation, momentum, ThisDamage);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Dissolve out of existence
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		GotoState('Dissolving');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		// Set the timer on the zombie head to have it fizzle out after a time
		SetTimer(TimeTillDissolve, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dissolving
// bubble effects play as dissolve
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dissolving
{
	ignores EncroachedBy, PinataStyleExplodeEffects, TearOffNetworkConnection, TakeDamage,
		HitWall, SetMood, AnimEnd;

	///////////////////////////////////////////////////////////////////////////////
	// Keep head dog from coming after me
	///////////////////////////////////////////////////////////////////////////////
	function bool IsDissolving()
	{
		return true;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		local vector newd;
		local float usef;
		newd = DrawScale3D;
		usef = (DeltaTime*DissolveRate);
		newd.x -= usef;
		newd.y -= usef;
		newd.z -= usef;
		// Shrink me!
		if(newd.x < MinDissolveSize)
		{
			newd.x = MinDissolveSize;
			newd.y = MinDissolveSize;
			newd.z = MinDissolveSize;
		}
		SetDrawScale3D(newd);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Make him fall out of the world now
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
		endpt.z -= 2*default.CollisionHeight;
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
	// Modify sound also
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local vector stpt;
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
			stpt = Location;
			stpt.z -= (0.5*default.CollisionHeight);
			MakeDissolvePuddle(stpt);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     TimeTillDissolve=120.000000
     DissolveTime=6.000000
     DissolveRate=0.200000
     MinDissolveSize=0.050000
     dissolveclass=Class'AWEffects.ZDissolvePuddle'
     DissolveSound=Sound'LevelSounds.potBoil'
     HeadBounce(0)=Sound'MiscSounds.People.head_bounce'
     HeadBounce(1)=Sound'MiscSounds.People.head_bounce2'
}
