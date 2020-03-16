class PickupSpawner extends Spawner
	hidecategories (Spawner);

// SpawnedPickup Properties
var(SpawnedPickup) bool bAllowMovement;				// If true, spawned pickup can be kicked etc.
var(SpawnedPickup) float DestroyTime;				// If not picked up before this amount of time passes, pickup will vanish
var(SpawnedPickup) StaticMesh MyStaticMesh;			// Static mesh to assign to pickup
var(SpawnedPickup) name MyTag;						// Tag to assign to pickup
var(SpawnedPickup) name MyEvent;					// Event to assign to pickup
var(SpawnedPickup) class<Pickup> PickupClass;		// Class of pickup to spawn

// SpawnedPowerup Properties
var(SpawnedPowerup) float AmountToAdd;				// Number of pickups this should grant
var(SpawnedPowerup) bool bTainted;					// Whether it's been tainted/pissed on/etc.

// SpawnedWeapon Properties
var(SpawnedWeapon) int Ammo;						// Amount of ammunition to grant

// Skip Spawner PostBeginPlay
function PostBeginPlay()
{
	Super(Actor).PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Get the class of the thing to spawn
///////////////////////////////////////////////////////////////////////////////
function class<Actor> GetSpawnClass()
{
	return PickupClass;
}

///////////////////////////////////////////////////////////////////////////////
// Do specific things to the spawned object, like to pawns
///////////////////////////////////////////////////////////////////////////////
function SpecificInits(Actor spawned)
{
	local P2PowerupPickup powerpick;
	local P2WeaponPickup weaponpick;

	// Use this mesh
	if(MyStaticMesh != None)
	{
		spawned.SetStaticMesh(MyStaticMesh);
		spawned.SetDrawType(DT_StaticMesh);
	}

	if (P2PowerupPickup(spawned) != None)
	{
		powerpick = P2PowerupPickup(spawned);

		// Properties that apply to all spawned pickups
		powerpick.RespawnTime = 0;

		// SpawnedPickup properties set by LD
		powerpick.bAllowMovement=bAllowMovement;
		powerpick.LifeSpan=DestroyTime;

		// SpawnedPowerup properties set by LD
		if (bTainted)
			powerpick.Taint();
		if (AmountToAdd != 0)
			powerpick.AmountToAdd = AmountToAdd;
	}

	if (P2WeaponPickup(spawned) != None)
	{
		weaponpick = P2WeaponPickup(spawned);

		// Properties that apply to all spawned pickups
		weaponpick.RespawnTime = 0;

		// SpawnedPickup properties set by LD
		weaponpick.bAllowMovement=bAllowMovement;
		weaponpick.LifeSpan=DestroyTime;

		// SpawnedWeapon properties set by LD
		if (Ammo > -1)
		{
			weaponpick.AmmoGiveCount = Ammo;
			weaponpick.MPAmmoGiveCount = Ammo;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Perform the actual spawn
///////////////////////////////////////////////////////////////////////////////
function DoSpawn()
{
	local class<Actor> UseClass;
	local vector SpawnLoc;
	local Rotator SpawnRot;
	local Actor spawned;
	local Actor HitActor;

	// Check to make sure you're not going to smash anybody
	ForEach CollidingActors(class'Actor', HitActor, CollisionRadius, Location)
	{
		//log("hit this stuff "$HitActor);
		// If you hit something not static, then don't allow a spawn
		if(HitActor != None
			&& HitActor.bBlockActors
			&& HitActor.bBlockPlayers
			&& !HitActor.bStatic)
			return;
	}

	// Set the location as where the spawner is, and
	// let the LD's determine how the things are rotated/spit out when they spawn
	SpawnLoc = Location;
	SpawnRot = Rotation;

	UseClass = GetSpawnClass();

	if(UseClass != None)
		spawned = spawn(UseClass,,MyTag,SpawnLoc,SpawnRot);

	// If the spawning worked, check to do specific stuff to it
	// and record that you successfully spawned one
	if(spawned != None)
	{
		// Do special things to the newly spawned
		if (MyEvent != '')
			spawned.Event = MyEvent;
		SpecificInits(spawned);
	}
	//log("total spawned "$TotalSpawned);
}

function Trigger( actor Other, pawn EventInstigator )
{
	DoSpawn();
}

defaultproperties
{
	// SpawnedPickup Properties
	bAllowMovement=True
	DestroyTime=300
	PickupClass=class'Pickup'

	// SpawnedPowerup Properties
	AmountToAdd=0
	bTainted=False

	// SpawnedWeapon Properties
	Ammo=-1
}
