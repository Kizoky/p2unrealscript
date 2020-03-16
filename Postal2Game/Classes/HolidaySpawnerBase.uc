///////////////////////////////////////////////////////////////////////////////
// HolidaySpawner
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Class that handles dynamically spawning in enemies to fight during
// certain holiday events. Made for Halloween but could be adapted for other
// purposes
//
// Featuring code poached from my very own DudeOnTheRun mod :>
///////////////////////////////////////////////////////////////////////////////
class HolidaySpawnerBase extends Info;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, structs, etc
///////////////////////////////////////////////////////////////////////////////
enum ESpawnLocation
{
	ES_Anywhere,			// Spawn anywhere in the map (uses defined spawn radius from a random PathNode)
	ES_SpawnRadius,			// Use defined spawn radius
	ES_SpawnRadius_NotSeen,	// Use defined spawn radius, but spawn only when not in sight
	ES_SpawnRadius_WhenSeen	// Use defined spawn radius, but spawn only when in sight
};

struct SpawnDef
{
	///////////////////////////////////////////////////////////////////////////////	
	// External
	///////////////////////////////////////////////////////////////////////////////
	var() array< class<FPSPawn> > Pawns;				// List of spawning pawns
	var() string GangName;								// Pawns will be placed in this gang
	var() name HolidayName;								// Pawns will spawn on this holiday only
	var() float SpawnChancePct;							// n% chance of spawning baddies
	var() float SpawnRadiusMax;							// Maximum range at which to spawn baddies
	var() float SpawnRadiusMin;							// Minimum range at which to spawn baddies
	var() ESpawnLocation SpawnLocation;					// Where to spawn the pawn
	var() class<P2Emitter> SpawnEffect;					// Class of effect to spawn along with pawn (like a smoke puff, hellfire, etc)
	var() FPSPawn.EPawnInitialState PawnInitialState;	// Pawn's initial state (only works with FPSControllers, not P2EAIControllers)
	var() class<TimedMarker> SpawnMarker;				// Type of AI marker we make, to alert others
	var() float SpawnMarkerRadius;						// Radius to notify AI controllers
	var() int MaxSpawnedPerLevel;						// After spawning this many, we won't spawn any more (0 = infinite)
	
	///////////////////////////////////////////////////////////////////////////////
	// Internal
	///////////////////////////////////////////////////////////////////////////////
	var int NumSpawnedThisLevel;						// Number of these we've spawned so far (for checking MaxSpawnedPerLevel)	
};

var() float SpawnIntervalInSecs;					// Every n game seconds we'll check to spawn some baddies.
var() array<SpawnDef> Spawns;						// Array of spawn definitions

var P2GameInfoSingle PSG;				// Pointer to P2GameInfoSingle version of Level.Game
var array<Vector> SpawnLocations;		// Array of possible spawn locations for ES_Anywhere

///////////////////////////////////////////////////////////////////////////////
// Begin play
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	//log("Created"@Self,'HolidaySpawner');

	if (P2GameInfoSingle(Level.Game) != None)
	{
		// Setup PSG
		PSG = P2GameInfoSingle(Level.Game);
		// Populate spawn locations
		PopulateSpawnLocations();
		// Setup timer
		SetTimer(SpawnIntervalInSecs, true);
		Disable('Tick');
	}
	else
	{
		// Failsafe
		warn(self@"No P2GameInfoSingle found; terminating");
		Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Populate spawn locations for ES_Anywhere
///////////////////////////////////////////////////////////////////////////////
function PopulateSpawnLocations()
{
	local NavigationPoint N;
	
	for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
		if (PathNode(N) != None)
		{
			SpawnLocations.Insert(0, 1);
			SpawnLocations[0] = N.Location;
			//log("Spawn location added:"@SpawnLocations[0],'HolidaySpawner');
		}
}

///////////////////////////////////////////////////////////////////////////////
// Add a controller to our newly spawned baddie
///////////////////////////////////////////////////////////////////////////////
function AddController(FPSPawn newcat)
{
	if ( newcat.Controller == None
		&& newcat.Health > 0 )
	{
		if ( (newcat.ControllerClass != None))
			newcat.Controller = spawn(newcat.ControllerClass);
		if ( newcat.Controller != None )
			newcat.Controller.Possess(newcat);
		// Check for AI Script
		newcat.CheckForAIScript();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set up our timed spawns
///////////////////////////////////////////////////////////////////////////////
event Timer()
{
	local int GroupToSpawn, i, SpawnAttempts, BadGuySpawnAttempts, NumSpawned;
	local FPSPawn PlayerPawn, SpawnedPawn, TestPawn;
	local P2Player Player;
	local bool bSuccess, bUseThisGroup, bCheckSpawn;
	local Vector SpawnOrigin, RandDir, HitLocation, HitNormal, SpawnLoc, SpawnLocMin, SpawnLocMax, TraceStart, TraceEnd;
	local PathNode SpawnPoint;
	local float MaxCollisionRadius, RandSeed;
	local Actor CollidedActor;
	local DayBase CurrentDay;
	
	const MAX_SPAWN_ATTEMPTS = 100;
	
	// Never attempt a spawn during a cutscene
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).GetPlayer() != None
		&& P2GameInfoSingle(Level.Game).GetPlayer().GetCurrentSceneManager() != None)
		return;
	
	for (i = 0; i < Spawns.Length; i++)
	{
		// Roll the dice and see if it's time to spawn some bad guys!
		RandSeed = FRand();
		
		//log("Spawn chance for Spawns["$i$"]:"@Spawns[i].SpawnChancePct@"Seed:"@RandSeed,'HolidaySpawner');
		//log("Holiday:"@Spawns[i].HolidayName@PSG.IsHoliday(Spawns[i].HolidayName),'HolidaySpawner');
		if (RandSeed <= Spawns[i].SpawnChancePct		// If the percent chance is correct
			&& PSG.IsHoliday(Spawns[i].HolidayName)		// And it is the correct holiday
			&& (Spawns[i].MaxSpawnedPerLevel == 0 || Spawns[i].NumSpawnedThisLevel < Spawns[i].MaxSpawnedPerLevel))	// And we haven't exceeded our quota
		{
			GroupToSpawn = i;
			
			// Spawn in the actual group. First, find the player on the map.
			foreach DynamicActors(class'P2Player', Player)
				// DynamicActors is an iterator function, which goes through all dynamic (non-static) objects in the level
				// matching the specified class. There are other iterators -- see Actor.uc in Engine for more
			{
				// We've found our player controller. Get a reference to the player's pawn, if there is one.
				if (Player.MyPawn != None)
				{
					PlayerPawn = Player.MyPawn;
					break;
				}
			}
			//log("Got player:"@Player,'HolidaySpawner');
			
			// Proceed if we found a pawn.
			if (PlayerPawn != None)
			{
				// Attempt to spawn in the baddies. When successful, bSuccess is set to true.
				bSuccess = false;
				SpawnAttempts = 0;
				while (!bSuccess)
				{
					SpawnAttempts++;		// Keep track of how many spawn attempts we've done.
											// If we exceed a certain amount without a successful spawn, abort and try again later.
					//log("Spawn attempt"@SpawnAttempts,'HolidaySpawner');
					
					// Decide spawn type
					if (Spawns[GroupToSpawn].SpawnLocation == ES_Anywhere)
						SpawnOrigin = SpawnLocations[Rand(SpawnLocations.Length)];
					else
						SpawnOrigin = PlayerPawn.Location;
					
					// Find a place to actually spawn them in. We'll use another iterator for this
					RandDir = Vector(RotRand());
					RandDir.Z = 0;
					SpawnLocMin = RandDir * Spawns[GroupToSpawn].SpawnRadiusMin;
					SpawnLocMax = RandDir * Spawns[GroupToSpawn].SpawnRadiusMax;			// This funky equation generates a vector of magnitude SpawnRadiusMax
																	// pointing in a random direction from the dude on the z-axis.
																	// We'll do a TraceActors along this path, looking for a good place to
																	// spawn our bad guys.
					//log("random direction:"@RandDir,'HolidaySpawner');
																
					// We need to make sure there's enough room here to spawn our entire group of baddies.
					// What we'll do here is add up all the collision details of our spawn group, and make sure nothing will collide with them when spawned.
					// Anything that spawns into the world needs a nice "bubble" to spawn in, or else the spawn will fail due to colliding with another actor.
					MaxCollisionRadius = 0;
					for (i=0; i < Spawns[GroupToSpawn].Pawns.Length; i++)
						MaxCollisionRadius += FMax(Spawns[GroupToSpawn].Pawns[i].Default.CollisionRadius, Spawns[GroupToSpawn].Pawns[i].Default.CollisionHeight);
							// This simply picks the greater of their CollisionRadius or CollisionHeight and adds it to our "bubble".
					// Add a bit of buffer to our bubble, just in case
					MaxCollisionRadius *= 1.5;
					
					TraceStart = SpawnOrigin + SpawnLocMax;
					TraceEnd = SpawnOrigin + SpawnLocMin;
					//log("Picking random point from"@TraceStart@"to"@TraceEnd,'HolidaySpawner');
					HitLocation.X = RandRange(TraceStart.X, TraceEnd.X);
					HitLocation.Y = RandRange(TraceStart.Y, TraceEnd.Y);
					HitLocation.Z = RandRange(TraceStart.Z, TraceEnd.Z);
					
					//log("finding pathnode near"@HitLocation,'HolidaySpawner');
					// Find a nearby PathNode to use as our base, so that we can ensure the spawned-in baddie has a path to the Dude.
					SpawnPoint = None;
					foreach RadiusActors(class'PathNode', SpawnPoint, 500, HitLocation)
					{
						//log("Found PathNode:"@SpawnPoint,'HolidaySpawner');
						HitLocation = SpawnPoint.Location;
						break;
					}
					
					// Check if OK to spawn in this location
					bCheckSpawn = (SpawnPoint != None);
					
					// If "spawn when unseen", a simple fast trace will determine this
					if (bCheckSpawn && Spawns[GroupToSpawn].SpawnLocation == ES_SpawnRadius_NotSeen)
						bCheckSpawn = !FastTrace(PlayerPawn.Location, HitLocation);
						
					// If "spawn when seen", the spawn point should be reasonably in front of the player as well as a clear line of sight
					if (bCheckSpawn && Spawns[GroupToSpawn].SpawnLocation == ES_SpawnRadius_WhenSeen)
						bCheckSpawn = (vector(PlayerPawn.Controller.GetViewRotation()) dot Normal(HitLocation - PlayerPawn.Location) > 0
							&& FastTrace(PlayerPawn.Location, HitLocation));
					
					if (bCheckSpawn)
					{
						//log("try"@HitLocation,'HolidaySpawner');
						// Now use the max collision radius to see if anything hits it
						CollidedActor = None;
						foreach CollidingActors(class'Actor', CollidedActor, MaxCollisionRadius, HitLocation)
							// Seems to be an engine bug with VisibleCollidingActors. Use CollidingActors instead
						{
							if (!CollidedActor.bHidden)
								break;	// No need to continue the loop -- if we find one, we can't use it
						}
						//log("collided actor:"@CollidedActor,'HolidaySpawner');
						
						if (CollidedActor == None)
						{
							// We're safe! Start spawning in our baddies.
							BadGuySpawnAttempts = 0;
							for (i=0; i < Spawns[GroupToSpawn].Pawns.Length; i++)
							{
								// Set SpawnedPawn to None, and try to find a random location within that radius to drop in our actor.
								SpawnedPawn = None;
								while (SpawnedPawn == None)
								{
									BadGuySpawnAttempts++;
									if (BadGuySpawnAttempts > MAX_SPAWN_ATTEMPTS)
										break;
									SpawnLoc = HitLocation;
									SpawnLoc.X += FRand()*2*MaxCollisionRadius - MaxCollisionRadius;
									SpawnLoc.Y += FRand()*2*MaxCollisionRadius - MaxCollisionRadius;
									SpawnLoc.Z += FRand()*2*MaxCollisionRadius - MaxCollisionRadius;
									// Try to fit it to the ground
									TraceEnd = SpawnLoc;
									TraceEnd.Z -= 2048;
									CollidedActor = Trace(HitLocation, HitNormal, TraceEnd, SpawnLoc, false);
									if (CollidedActor != None)
									{
										SpawnLoc = HitLocation;
										SpawnLoc += Spawns[GroupToSpawn].Pawns[i].Default.CollisionHeight * HitNormal;
									}
									//log("spawning"@Spawns[GroupToSpawn].Pawns[i]@"at"@SpawnLoc,'HolidaySpawner');
									SpawnedPawn = Spawn(Spawns[GroupToSpawn].Pawns[i], , , SpawnLoc);
									if (SpawnedPawn != None)
									{
										// It spawned in! Set up their gang tag and have them attack the Dude.
										if (Spawns[GroupToSpawn].GangName != "")
											SpawnedPawn.Gang = Spawns[GroupToSpawn].GangName;
										// Add a controller for our newly-spawned pawn
										AddController(SpawnedPawn);
										// Set it to attack the dude.
										if (SpawnedPawn.Controller != None)
											SpawnedPawn.SetupNextState(Spawns[GroupToSpawn].PawnInitialState, PlayerPawn);
										//log("spawn SUCCESS"@SpawnedPawn,'HolidaySpawner');
										Spawn(Spawns[GroupToSpawn].SpawnEffect,,,HitLocation);
										
										// Notify nearby controllers, maybe.
										if (Spawns[GroupToSpawn].SpawnMarker != None)
											Spawns[GroupToSpawn].SpawnMarker.Static.NotifyControllersStatic(Level, Spawns[GroupToSpawn].SpawnMarker, SpawnedPawn, SpawnedPawn, Spawns[GroupToSpawn].SpawnMarkerRadius, SpawnLoc);
											
										// Increment counter
										Spawns[GroupToSpawn].NumSpawnedThisLevel++;
									}
								}
								if (BadGuySpawnAttempts > MAX_SPAWN_ATTEMPTS)
									break;
							}
							// If we made it here, all of our pawns should have been spawned, and we're good to go.
							if (BadGuySpawnAttempts <= MAX_SPAWN_ATTEMPTS)
							{
								bSuccess = true;
								//log("Success! All pawns spawned",'HolidaySpawner');
							}
						}
					}
					
					// Break out if we fail too many times.
					if (!bSuccess
						&& SpawnAttempts >= MAX_SPAWN_ATTEMPTS)
						// Say it was spawned and move on to the next group
						bSuccess = true;
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Defaults
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	SpawnIntervalInSecs=10.0
}
