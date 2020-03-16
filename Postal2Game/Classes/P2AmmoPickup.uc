///////////////////////////////////////////////////////////////////////////////
// P2AmmoPickup.
//
// Base class for ammo pickups you find lying around.
// These don't give you the weapon they go to, they only add ammo.
//
///////////////////////////////////////////////////////////////////////////////
class P2AmmoPickup extends Ammo
	abstract;

var() bool	bRecordAfterPickup;	// Independent (possibly) of bPeristent, this defaults to true, meaning
								// when a level designer places this, and a pawn comes across it and picks
								// it up, it's rememebered that it's been picked up. If a pawn drops an
								// item and makes a pickup, it's turned off, so dropped items are re-recorded
								// after pickup
var() bool	bAllowMovement;		// True for most things.. means if you damage it, it will get moved.
								// If it's false, you can't move it, until the player picks it up once
								// and then drops it again
var Sound   BounceSound;		// Noise to make as you hit the ground
var	bool    bBounced;			// If it's bounced yet or not

var(Ammo) int MPAmmoAmount;		// Multiplayer amount of ammo this gives you. Needed for different balancing
								// in MP games.


const BOUNCE_AWAY_VEL		=	150;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
	Super.PreBeginPlay();
	// Level-placed ones don't start falling, so put them into stasis immediately.
	// If they're thrown out, the thrower will set them up properly.
	SetPhysics(PHYS_None);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	// Don't let powerups move in MP
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		bAllowMovement=false;
}

///////////////////////////////////////////////////////////////////////////////
// Record that you picked up this object
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	local P2GameInfoSingle checkg;

	Super.AnnouncePickup(Receiver);

	// Check if you've just been deleted.. if so, record yourself
	// in the list of dropped pickups per level, ONLY if you've been
	// placed in there by the level designers
	if(bDeleteMe
		&& bRecordAfterPickup)
	{
		checkg = P2GameInfoSingle(Level.Game);
		if(checkg != None)
			// Remember it was picked up
			checkg.TheGameState.RecordPickup(name);
	}
}

///////////////////////////////////////////////////////////////////////////////
// I've fallen to the ground
///////////////////////////////////////////////////////////////////////////////
event Landed(Vector HitNormal)
{
	Super.Landed(HitNormal);

	// Set not moving or ticking
	HandleBounceEffects(HitNormal);
	SetPhysics(PHYS_None);
}

///////////////////////////////////////////////////////////////////////////////
// Always allow movement after it's dropped.
///////////////////////////////////////////////////////////////////////////////
function InitDroppedPickupFor(Inventory Inv)
{
	Super.InitDroppedPickupFor(Inv);
	// Always allow movement after it's dropped.
	bAllowMovement=true;
	// Don't let it respawn once you've dropped it
	RespawnTime=0;
}

///////////////////////////////////////////////////////////////////////////////
// Some effects for pickups hitting the ground
///////////////////////////////////////////////////////////////////////////////
function HandleBounceEffects(vector HitNormal)
{
	local PickupHitPuff smoke1;
	if(!bBounced)
	{
		// Throw out some hit effects, like dust or sparks
		smoke1 = spawn(class'PickupHitPuff',,,Location);

		// Bouncy noise
		PlaySound(BounceSound);
		bBounced=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// When touched by an actor.
///////////////////////////////////////////////////////////////////////////////
function CheapBounce( actor Other )
{
	local Inventory Copy;
	local vector BounceVel, HitNormal;

	// don't allow inventory to pile up (frame rate hit)
	if (Pickup(Other) != None
		&& bAllowMovement)
	{
		// Allow it to move on both client and server
		bAlwaysRelevant = false;
		bOnlyReplicateHidden = false;
		// Instead of destroying it like Epic does, we'll bounce ours
		// in two different directions
		// Same as in P2PowerupPickup
		HitNormal = Normal(Other.Location - Location);
		BounceVel = HitNormal;
		BounceVel.z += 1.0;	// make sure it goes up
		BounceVel = (FRand()*BOUNCE_AWAY_VEL + BOUNCE_AWAY_VEL)*BounceVel;
		// pop both up in the air, away from one another
		SetPhysics(PHYS_Falling);
		bBounced=false;
		Velocity = -BounceVel;
		Velocity.z = abs(Velocity.z);

		if((P2PowerupPickup(Other) != None
				&& P2PowerupPickup(Other).bAllowMovement)
			|| (P2AmmoPickup(Other) != None
				&& P2AmmoPickup(Other).bAllowMovement)
			|| (P2WeaponPickup(Other) != None
				&& P2WeaponPickup(Other).bAllowMovement))
		{
			// Make other pickup bounce away
			// Wake it up
			Other.bAlwaysRelevant = false;
			Pickup(Other).bOnlyReplicateHidden = false;
			Other.SetPhysics(PHYS_Falling);
			Other.bBounce=false;
			Other.GotoState('Pickup');
			Other.Velocity = BounceVel;
			Other.Velocity.z = abs(Other.Velocity.z);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Take damage and be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	if(bAllowMovement
		&& VSize(Momentum) > 0
		&& Dam > 0)
	{
		// Allow it to move on both client and server
		bAlwaysRelevant = false;
		bOnlyReplicateHidden = false;

		// Dampen the momentum from explosions so you don't get thrown too far
		if(ClassIsChildOf(damageType, class'ExplodedDamage'))
			Momentum=Momentum/2;
		SetPhysics(PHYS_Falling);
		bBounced=false;
		Velocity = (Momentum/Mass);
		// Make sure it never gets hit down (caused it to go into the ground too much)
		if(Velocity.z < 0)
			Velocity.z = abs(Velocity.z);
	}
}

///////////////////////////////////////////////////////////////////////////////
// SpawnCopy
///////////////////////////////////////////////////////////////////////////////
function inventory SpawnCopy( Pawn Other )
{
	local Inventory Copy;

	Copy = Super.SpawnCopy(Other);
	// Multiplayer has different balancing for how much ammo you get with things
	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
		Ammunition(Copy).AmmoAmount = AmmoAmount;
	else
		Ammunition(Copy).AmmoAmount = MPAmmoAmount;
	return Copy;
}

///////////////////////////////////////////////////////////////////////////////
// Pickup state: this inventory item is sitting on the ground.
///////////////////////////////////////////////////////////////////////////////
auto state Pickup
{
	///////////////////////////////////////////////////////////////////////////////
	// ValidTouch()
	// Validate touch (if valid return true to let other pick me up and trigger event).
	//
	///////////////////////////////////////////////////////////////////////////////
	function bool ValidTouch( actor Other )
	{
		local vector Top, Bottom, OtherTop, OtherBottom;

		// make sure its a live player
		if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).Health <= 0) )
			return false;

		// Form top and bottom of pickup
		Top = Location;
		Top.z += CollisionRadius;
		Bottom = Location;
		Bottom.z -= CollisionRadius;
		// form top and bottom of other
		OtherTop = Other.Location;
		OtherTop.z += Other.CollisionRadius;
		OtherBottom = Other.Location;
		OtherBottom.z -= Other.CollisionRadius;
		// make sure not touching through wall
		// But do a better job, by testing from the feet, the head, and the center
		if (!FastTrace(Other.Location, Location)	// check middle
			&& !FastTrace(OtherTop, Top)			// check top
			&& !FastTrace(OtherBottom, Bottom))		// check bottom
			return false;

		// make sure game will let player pick me up
		if( Level.Game.PickupQuery(Pawn(Other), self) )
		{
			TriggerEvent(Event, self, Pawn(Other));
			return true;
		}
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// When touched by an actor.
	///////////////////////////////////////////////////////////////////////////////
	function Touch( actor Other )
	{
		local Inventory Copy;
		local vector BounceVel;

		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			Copy = SpawnCopy(Pawn(Other));
			AnnouncePickup(Pawn(Other));
			Copy.PickupFunction(Pawn(Other));
			// Destroy possibly here instead of inside SpawnCopy
			SetRespawn();
		}
		// don't allow inventory to pile up (frame rate hit)
		else 
		{
			//if ( (Inventory != None) && Other.IsA('Pickup')
			//	&& (Pickup(Other).Inventory != None) )
			CheapBounce(Other);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Waiting to respawn, make sure it can't be kicked/moved here
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
State Sleeping
{
	ignores TakeDamage;
}

defaultproperties
{
    RotationRate=(Yaw=0)
    CollisionRadius=30.000000
    CollisionHeight=20.000000
    bCollideActors=True
	DrawType=DT_StaticMesh
	MessageClass=class'PickupMessagePlus'
    PickupSound=Sound'WeaponSounds.weapon_picked_up'
	BounceSound=Sound'MiscSounds.PickupSounds.PickupBounce'
	bRecordAfterPickup=true
	bAllowMovement=true
	AmbientGlow=255
    RespawnTime=30.000000
}
