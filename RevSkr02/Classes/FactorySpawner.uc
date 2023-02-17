//=============================================================================
// Erik Rossik.
// Revival Games 2015.
// FactorySpawner.
//=============================================================================
class FactorySpawner extends Spawner;

var () class<Actor> SpawnClases[10];
var () int MaxClasses;

function class<Actor> GetSpawnClass()
{
 return SpawnClases[rand(MaxClasses)];
}

function DoSpawn()
{
	local class<Actor> UseClass;
	local vector SpawnLoc;
	local Rotator SpawnRot;
	local Actor spawned;
	local Actor HitActor;

	// Check if active
	if(!bActive || bDisabled)
		return;

	// Try to spawn again, if necessary
	if(SpawnRate > 0)
		SetTimer(GetRate(), false);

	// If we only spawn when not seen, and this was rendered recently, then
	// fail.
	if(bSpawnWhenNotSeen
		&& (LastRenderTime + BUFFER_TIME >= Level.TimeSeconds))
	{
		//log("failed to spawn based on visibility");
		return;
	}

	// If we're trying to spawn now, and we have our TotalAlive connected to the whole level
	// as a oppposed to just locally, then count up all that are still alive in the level
	// with our use tag
	if(bMonitorWorld)
		MonitorWorld();

	// If we already have enough alive
	// and we don't want an infinite amount
	if(NumToKeepAlive > 0
		&& TotalAlive >= NumToKeepAlive)
	{
		GotoState('Waiting');
		return;
	}

	//log("last render time "$LastRenderTime);
	//log("current time "$Level.TimeSeconds);
	//log("TotalSpawned "$TotalSpawned);
	//log("TotalAlive "$TotalAlive);

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
   // SpawnRot.Yaw = rand(65536);

	UseClass = GetSpawnClass();

	if(UseClass != None)
		spawned = spawn(UseClass,,SpawnTag,SpawnLoc,SpawnRot,SpawnSkin);

	// If the spawning worked, check to do specific stuff to it
	// and record that you successfully spawned one
	if(spawned != None)
	{
		// Link me to the spawner so when I die, the spawner is triggered to make more
		spawned.Event = Tag;

		// Do special things to the newly spawned
		SpecificInits(spawned);

		// Successful spawn
		TotalSpawned++;
		TotalAlive++;

		// Check if you've made enough
		// 0 for MaxSpawned is infinite
		if(MaxSpawned != 0
			&& TotalSpawned >= MaxSpawned)
		{
//			Destroy();
			bDisabled = true;
			return;
		}
	}
	//log("total spawned "$TotalSpawned);
}

defaultproperties
{
}
