///////////////////////////////////////////////////////////////////////////////
// Dude on the Run
//
// This is a sample Workshop mod based off of P2GameMod.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This is a mod that keeps the Dude's wanted meter at maximum at all times.
// Additionally, cops, SWAT, and military will occasionally spawn in and
// hunt down the Dude, keeping him on his toes at all times.
//
// This mod can be easily altered if you want other groups to attack the Dude
// randomly. Simply remove the functions that alter the cop radio time
// and prevent bribery, and make your own struct filled with bad guys
//
// This is a rather complex mod, especially with regards to spawning in
// the police, so this mod is heavily commented so you can understand what's going on
///////////////////////////////////////////////////////////////////////////////
class DudeOnTheRun extends P2GameMod;

var float SpawnIntervalInSecs;					// Every n game seconds we'll check to spawn some baddies.
var float SpawnChancePct;						// n% chance of spawning baddies
var float SpawnRadiusMax;						// Maximum range at which to spawn baddies
var float SpawnRadiusMin;						// Minimum range at which to spawn baddies
var GameState TheGameState;						// Contains a reference to the current game's GameState

// Struct that defines groups of bad guys to spawn in and attack the player.
struct AttackGroup
{
	var array< class<FPSPawn> > Attackers;	// List of attacking pawns
			// To define an array of class definitions, put spaces between the "class<X>" definition
			// Otherwise, you will receive a compiler error.
	var string GangName;					// Attackers will be placed in this gang
											// For examples, look in BasePeople and People and check their gang tags
	var array<string> DaysToUse;			// This attack group will only spawn during DayBases matching one of these UniqueNames.
											// For example, an Attack Group with DaysToUse values of "DAY_A","DAY_C" would spawn on
											// Monday and Wednesday, but not Tuesday or any other day.
};

var array<AttackGroup> AttackGroups;	// List of attack groups

///////////////////////////////////////////////////////////////////////////////
// Add a controller to our newly spawned baddie
// This is not defined in P2GameMod or any of its superclasses - this is a
// custom function for this class.
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
// SetUpDudeWanted
// This is not defined in P2GameMod or any of its superclasses - this is a
// custom function for this class.
// This function makes the cops hunt down the dude and sets up the spawn timer.
// This can be called either in Tick or in ModifyPlayer, so instead of repeating
// the same code in both functions, it's a better practice to make it into a
// callable function -- this way if you need to change anything, you only
// have to change the code here, and not in two (or more!) different places
///////////////////////////////////////////////////////////////////////////////
function SetUpDudeWanted()
{
	// Max out wanted level
	TheGameState.CopRadioTime = TheGameState.CopRadioMax;
	
	// Zero out the CopRadioTimerInterval. This ensures that the timer to tick down the wanted level will never occur.
	TheGameState.CopRadioTimerInterval = 0;
	
	// Get our spawn timer going
	SetTimer(SpawnIntervalInSecs, true);

	// Disable "tick" if we're not in jail. We won't need it.
	Disable('Tick');
}

///////////////////////////////////////////////////////////////////////////////
// MutatorIsAllowed
// Lets you check for arbitrary conditions under which this mod should
// not be allowed to run.
///////////////////////////////////////////////////////////////////////////////
function bool MutatorIsAllowed()
{
	// Don't allow during Apocalypse Weekend - dude has enough shit to deal with
	if (P2GameInfoSingle(Level.Game).IsWeekend())
		return false;
	else
		return Super.MutatorIsAllowed();
}

///////////////////////////////////////////////////////////////////////////////
// ModifyPlayer
// Called by the PlayerController after traveling.
// Do not add inventory here -- that is defined in another function
// You can also use this function to do anything that needs to be done
// after the player travels to another map.
///////////////////////////////////////////////////////////////////////////////
function ModifyPlayer(Pawn Other)
{
	Super.ModifyPlayer(Other);
	
	// Find the GameState
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None)
		TheGameState = P2GameInfoSingle(Level.Game).TheGameState;
		
	// Before we do anything, see if the player is in jail.
	// If he's in a jail cell, the cops aren't going to bother trying to arrest him again.
	// But if he breaks out...
	if (!TheGameState.bPlayerInCell)
		SetUpDudeWanted();	// make the cops hunt us down
	else
		Enable('Tick');	// turn on our tick to watch when the dude gets out
}

///////////////////////////////////////////////////////////////////////////////
// ModifyNPC
// Called by PersonController/AnimalController after adding default inventory.
// Use this function to alter any aspect of the NPC you like.
// This function is called AFTER ModifyAppearance -- at this point, the pawn
// is all set up with head, skins, dialog, default inventory, and so on.
// If you want to change things before the pawn is set up, use ModifyAppearance.
// Note that there is no ModifyNPCInventory -- if you want to mess with
// their inventory, you do it here.
// This function works on most people and animals!
///////////////////////////////////////////////////////////////////////////////
function ModifyNPC(Pawn Other)
{
	Super.ModifyNPC(Other);
	
	// Police officers can be bribed -- doing this zeroes out the wanted meter.
	// Obviously we do not want this to happen, so for all police officers,
	// we'll set a flag that says that the Dude has already attempted a bribe.
	// This will cause them to reject future bribes.
	if (Other.Controller != None		// 99.999% of the time, this will be false.
										// However, it's good practice to check for None
										// when there's even a slight chance that it could
										// be None (for instance, if it got destroyed by another P2GameMod)
										// This helps prevent Accessed None log spam and other errors
		&& PoliceController(Other.Controller) != None)
		PoliceController(Other.Controller).bRejectedBribe = true;	// Set them as having already rejected a bribe
}

///////////////////////////////////////////////////////////////////////////////
// Timer
// Any non-static class can use timer functions. You can call them based on
// an interval of your choosing, and even make it automatically repeat.
// Our timer is used to occasionally spawn in enemies to attack the Dude.
//
// This is a pretty hefty function that defines where to spawn in the enemies.
// You don't need to understand everything here to make mods, but it does
// cover some advanced topics like iterators that can be extremely useful
//
// This function has a lot of commented-out log statements -- log statements
// can be extremely useful for debugging, because there is no proper
// debugging tool for UnrealScript
///////////////////////////////////////////////////////////////////////////////
event Timer()
{
	local int GroupToSpawn, i, SpawnAttempts, BadGuySpawnAttempts;
	local FPSPawn PlayerPawn, SpawnedPawn;
	local P2Player Player;
	local bool bSuccess, bUseThisGroup;
	local Vector RandDir, HitLocation, HitNormal, SpawnLoc, SpawnLocMin, SpawnLocMax, TraceStart, TraceEnd;
	local PathNode SpawnPoint;
	local float MaxCollisionRadius, RandSeed;
	local Actor CollidedActor;
	local DayBase CurrentDay;
	
	const MAX_SPAWN_ATTEMPTS = 100;
	
	// No need to call super here, Timer has no functionality by default in
	// P2GameMod or any of its superclasses.
	
	// Roll the dice and see if it's time to spawn some bad guys!
	RandSeed = FRand();
	//log("Spawn chance:"@SpawnChancePct@"Seed:"@RandSeed,'DudeOnTheRun');
	if (RandSeed <= SpawnChancePct)	// FRand() returns a pseudorandom float between 0.0 and 1.0
	{
		//log("Find random hate group",'DudeOnTheRun');
		// Pick a random hate group to spawn
		bUseThisGroup = false;
		while (!bUseThisGroup)
		{
			GroupToSpawn = Rand(AttackGroups.Length);	// Rand(n) returns a pseudorandom integer between 0 and n-1
			// Check if it's valid to use on this day
			CurrentDay = P2GameInfoSingle(Level.Game).GetCurrentDayBase();
			//log("Is"@GroupToSpawn@"okay to spawn on"@CurrentDay.UniqueName$"?",'DudeOnTheRun');
			for (i=0; i < AttackGroups[GroupToSpawn].DaysToUse.Length; i++)
			{
				//log("Checking"@AttackGroups[GroupToSpawn].DaysToUse[i]@"vs."@CurrentDay.UniqueName,'DudeOnTheRun');
				if (AttackGroups[GroupToSpawn].DaysToUse[i] ~= CurrentDay.UniqueName)
				{
					bUseThisGroup = true;
					break;
				}
			}
		}
		
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
		//log("Got player:"@Player,'DudeOnTheRun');
		
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
				//log("Spawn attempt"@SpawnAttempts,'DudeOnTheRun');
				
				// Find a place to actually spawn them in. We'll use another iterator for this
				RandDir = Vector(RotRand());
				RandDir.Z = 0;
				SpawnLocMin = RandDir * SpawnRadiusMin;
				SpawnLocMax = RandDir * SpawnRadiusMax;			// This funky equation generates a vector of magnitude SpawnRadiusMax
																// pointing in a random direction from the dude on the z-axis.
																// We'll do a TraceActors along this path, looking for a good place to
																// spawn our bad guys.
				//log("random direction:"@RandDir,'DudeOnTheRun');
															
				// We need to make sure there's enough room here to spawn our entire group of baddies.
				// What we'll do here is add up all the collision details of our spawn group, and make sure nothing will collide with them when spawned.
				// Anything that spawns into the world needs a nice "bubble" to spawn in, or else the spawn will fail due to colliding with another actor.
				MaxCollisionRadius = 0;
				for (i=0; i < AttackGroups[GroupToSpawn].Attackers.Length; i++)
					MaxCollisionRadius += FMax(AttackGroups[GroupToSpawn].Attackers[i].Default.CollisionRadius, AttackGroups[GroupToSpawn].Attackers[i].Default.CollisionHeight);
						// This simply picks the greater of their CollisionRadius or CollisionHeight and adds it to our "bubble".
				// Add a bit of buffer to our bubble, just in case
				MaxCollisionRadius *= 1.5;
				
				TraceStart = PlayerPawn.Location + SpawnLocMax;
				TraceEnd = PlayerPawn.Location + SpawnLocMin;
				//log("Picking random point from"@TraceStart@"to"@TraceEnd,'DudeOnTheRun');
				HitLocation.X = RandRange(TraceStart.X, TraceEnd.X);
				HitLocation.Y = RandRange(TraceStart.Y, TraceEnd.Y);
				HitLocation.Z = RandRange(TraceStart.Z, TraceEnd.Z);
				
				//log("finding pathnode near"@HitLocation,'DudeOnTheRun');
				// Find a nearby PathNode to use as our base, so that we can ensure the spawned-in baddie has a path to the Dude.
				SpawnPoint = None;
				foreach RadiusActors(class'PathNode', SpawnPoint, 500, HitLocation)
				{
					//log("Found PathNode:"@SpawnPoint,'DudeOnTheRun');
					HitLocation = SpawnPoint.Location;
					break;
				}
				
				// Don't spawn in plain view of the Dude. Spawn behind walls, barriers, etc.
				// Also don't spawn directly behind him, that's cheap and lame
				if (SpawnPoint != None
					&& !FastTrace(PlayerPawn.Location, HitLocation))
				{					
					//log("try"@HitLocation,'DudeOnTheRun');					
					// Now use the max collision radius to see if anything hits it
					CollidedActor = None;
					foreach CollidingActors(class'Actor', CollidedActor, MaxCollisionRadius, HitLocation)
						// Seems to be an engine bug with VisibleCollidingActors. Use CollidingActors instead
					{
						if (!CollidedActor.bHidden)
							break;	// No need to continue the loop -- if we find one, we can't use it
					}
					//log("collided actor:"@CollidedActor,'DudeOnTheRun');
					
					if (CollidedActor == None)
					{
						// We're safe! Start spawning in our baddies.
						BadGuySpawnAttempts = 0;
						for (i=0; i < AttackGroups[GroupToSpawn].Attackers.Length; i++)
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
								//log("spawning"@AttackGroups[GroupToSpawn].Attackers[i]@"at"@SpawnLoc,'DudeOnTheRun');
								SpawnedPawn = Spawn(AttackGroups[GroupToSpawn].Attackers[i], , , SpawnLoc);
								if (SpawnedPawn != None)
								{
									// It spawned in! Set up their gang tag and have them attack the Dude.
									SpawnedPawn.Gang = AttackGroups[GroupToSpawn].GangName;
									// Add a controller for our newly-spawned pawn
									AddController(SpawnedPawn);
									// Set it to attack the dude.
									if (SpawnedPawn.Controller != None
										&& FPSController(SpawnedPawn.Controller) != None)
										FPSController(SpawnedPawn.Controller).SetToAttackPlayer(PlayerPawn);
									//log("spawn SUCCESS"@SpawnedPawn,'DudeOnTheRun');
								}
							}
							if (BadGuySpawnAttempts > MAX_SPAWN_ATTEMPTS)
								break;
						}
						// If we made it here, all of our pawns should have been spawned, and we're good to go.
						if (BadGuySpawnAttempts <= MAX_SPAWN_ATTEMPTS)
						{
							bSuccess = true;
							//log("Success! All pawns spawned",'DudeOnTheRun');
						}
					}
				}
				
				// Break out if we fail too many times.
				if (!bSuccess
					&& SpawnAttempts >= MAX_SPAWN_ATTEMPTS)
					return;		// Abandon ship! You can use return at any point in your function
								// to quit immediately, even if you're in the middle of a loop
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Tick
// Tick is similar to Timer in that they're both called at set intervals.
// Unlike Timer, Tick is constantly being called for all dynamic actors
// once every "game tick", which is more or less once every frame or so.
// Be careful not to do a lot of CPU-intensive calls like iterators and traces
// while in Tick -- they can add up and bog down the game
///////////////////////////////////////////////////////////////////////////////
event Tick(float DeltaTime)
{
	// The variable DeltaTime indicates how much time (in seconds) has passed
	// since the last Tick. We won't need it here.

	// Don't need to call Super here. Like with Timer, Tick is an empty function
	// by default
	
	// Okay so now that we're in here, we're going to check to see if the dude
	// escaped from jail. To do that we'll check the GameState.
	// Problem is, the Game State isn't immediately set -- it has to "unpack"
	// from the Dude's inventory and be assigned to the GameInfo.
	// When ModifyPlayer above is called, the GameState is guaranteed to be valid
	// and it sets TheGameState to a reference of the game's GameState.
	// So if TheGameState is currently null, then don't do anything -- just wait
	if (TheGameState == None)
		return;
		
	// Did the dude escape? If so, go ahead and set up our spawns and wanted meter.
	if (TheGameState.bArrestPlayerInJail)
		SetUpDudeWanted();	// Set up wanted meter and spawns.
							// This function also disables Tick, because once
							// the dude is out of jail he's not going back in
							// unless he's in cuffs
}


///////////////////////////////////////////////////////////////////////////////
// Default properties required by all P2GameMods.
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	// GroupName - any Game Mods with the same GroupName will be considered incompatible, and only one will be allowed to run.
	// Use this if you make mods that are not designed to run alongside each other.
	GroupName=""
	// FriendlyName - the name of your Game Mod, displayed in the game mod menu.
	FriendlyName="Dude on the Run"
	// Description - optional short description of your Game Mod
	Description="Your relentless murdering sprees have caught up with you -- now the police have your number. Complete the week while avoiding the fuzz... and watch out for ambushes!"
	
	// Rates for spawning in baddies
	SpawnIntervalInSecs=30
	SpawnChancePct=0.2
	SpawnRadiusMax=5000
	SpawnRadiusMin=1000
	
	// Definition of attack groups
	// Note to self: Military starts showing up on DAY_D, and the SWAT convention is in town on DAY_E.
	// Police pawn classes ranked by toughness: ATFAgent, CopBlue, CopBlack, CopBrown, Military, InvisiGuard, SWAT
	AttackGroups[0]=(Attackers=(class'BasePeople.CopBlue',class'BasePeople.CopBlue'),GangName="Police",DaysToUse=("DAY_A"))
	AttackGroups[1]=(Attackers=(class'People.DogPawn',class'BasePeople.CopBlack'),GangName="Police",DaysToUse=("DAY_A","DAY_B"))
	AttackGroups[2]=(Attackers=(class'BasePeople.CopBlue',class'BasePeople.CopBlue',class'BasePeople.CopBlack'),GangName="Police",DaysToUse=("DAY_A","DAY_B","DAY_C"))
	AttackGroups[3]=(Attackers=(class'BasePeople.CopBlue',class'BasePeople.CopBlack',class'BasePeople.CopBlack'),GangName="Police",DaysToUse=("DAY_B","DAY_C"))
	AttackGroups[4]=(Attackers=(class'BasePeople.CopBlue',class'BasePeople.CopBlack',class'People.DogPawn'),GangName="Police",DaysToUse=("DAY_A","DAY_B","DAY_C"))
	AttackGroups[5]=(Attackers=(class'People.DogPawn',class'People.DogPawn',class'BasePeople.CopBlack'),GangName="Police",DaystoUse=("DAY_B","DAY_C"))
	AttackGroups[6]=(Attackers=(class'People.DogPawn',class'People.DogPawn',class'BasePeople.CopBrown'),GangName="Police",DAysToUse=("DAY_C","DAY_D","DAY_E"))
	AttackGroups[7]=(Attackers=(class'BasePeople.CopBlue',class'BasePeople.CopBlack',class'BasePeople.CopBrown'),GangName="Police",DaysToUse=("DAY_C","DAY_D","DAY_E"))
	AttackGroups[8]=(Attackers=(class'BasePeople.CopBlue',class'BasePeople.CopBlue',class'BasePeople.CopBlue',class'BasePeople.CopBrown'),GangName="Police",DaysToUse=("DAY_D","DAY_E"))
	AttackGroups[9]=(Attackers=(class'BasePeople.Military',class'BasePeople.Military',class'BasePeople.Military'),GangName="Police",DaysToUse=("DAY_D","DAY_E"))
	AttackGroups[10]=(Attackers=(class'People.DogPawn',class'BasePeople.Military',class'People.DogPawn'),GangName="Police",DaysToUse=("DAY_D","DAY_E"))
	AttackGroups[11]=(Attackers=(class'BasePeople.SWAT',class'BasePeople.SWAT',class'BasePeople.SWAT'),GangName="Police",DaysToUse=("DAY_E"))
	AttackGroups[12]=(Attackers=(class'BasePeople.SWAT',class'BasePeople.SWAT',class'AWPawns.InvisiGuard'),GangName="Police",DaysToUse=("DAY_E"))
	
	// Monday (4): CopBlue x2, DogPawn/CopBlack, CopBlue x2/CopBlack, CopBlue/CopBlack/DogPawn
	// Tuesday (4): DogPawn/CopBlack, CopBlue x2/CopBlack, CopBlue/CopBlack x2, DogPawn x2/CopBlack
	// Wednesday (6): CopBlue x2/CopBlack, CopBlue/CopBlack x2, CopBlue/CopBlack/DogPawn, DogPawnx x2/CopBlack, DogPawn x2/CopBrown, CopBlue/CopBlack/CopBrown
	// Thursday (5): DogPawn x2/CopBrown, CopBlue/CopBlack/CopBrown, CopBlue x3/CopBrown, Military x3, Military/DogPawn x2
	// Friday (6): DogPawn x2/CopBrown, CopBlue x3/CopBrown, Military x3, Military/DogPawn x2, SWAT x3, SWAT x2/InvisiGuard	
}