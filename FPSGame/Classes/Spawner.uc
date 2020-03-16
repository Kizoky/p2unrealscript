///////////////////////////////////////////////////////////////////////////////
// Spawner
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Non-visible actor that simply spawns other actors till it's out, time is
// out, it dies, or something like that.
///////////////////////////////////////////////////////////////////////////////

class Spawner extends Actor
	hidecategories(Collision,Force,Karma,Lighting,LightColor,Shadow,Sound)
	placeable;

var ()float SpawnRate;			// How often to spawn. Set SpawnRate to 0 to not spawn automatically
								// but to still allow spawns via a Trigger
var ()class<Actor> SpawnClass;	// Class to be spawned
var ()Name SpawnTag;			// Tag to give to spawnee
var ()int  MaxSpawned;			// Total number of this that you spawn
								// When TotalSpawned reaches this, this is destroyed.
								// 0 is default and means an infinite amount
var ()int  NumToKeepAlive;		// How many to make sure are alive in the world
								// 0 means you don't care
var ()bool bSpawnWhenNotSeen;	// spawn only when you can't be seen
var ()bool bRandomizeRate;		// Goes from SpawnRate/2 to 3*SpawnRate/2
var ()bool bActive;				// Really just to be used by LD's when testing things. False means nothing spawns
var ()StaticMesh UseStaticMesh;	// What gets used as the static mesh for the thing we're spawning
var ()bool bSetActiveAfterTrigger;// If true, then all a Trigger call does set bActive to false so it starts spawning
								// before we spawn a new actor.
var ()bool bMonitorWorld;		// If true, then use NumToKeepAlive to monitor all the things with the same tag
								// as SpawnTag. So if there's already a few of this thing in the world, still alive
								// then don't make any more till they are gone. If it's false, then NumToKeepAlive
								// applies only locally, in that, that number are made for this spawner, then it waits
								// till those die to make more.
var ()float PostTriggerStartTime;// Time we wait before we start normal spawning, after a trigger has turned
								// us on.
var ()Material SpawnSkin;		// Skin given to the thing just spawned

// Internal
var int  TotalSpawned;			// Total number spawned
var int  TotalAlive;			// Total number still alived (<=TotalSpawned)
var float LocalTime;			// Time since last spawn when auto spawning
var bool bDisabled;				// Set to true when we don't want to spawn anything else, ever again


const BUFFER_TIME	=	0.5;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Because we don't want it to render, but DO want to know about renders
	// for visibility's sake, switch the rendering mode to something that
	// we know it won't render with. This way, LastRenderTime will get updatted
	// and we can do checks based on it, if we need to.
	SetDrawType(DT_StaticMesh);

	// if we want to do this then do let it start active
	if(bSetActiveAfterTrigger)
		bActive=false;

	if(SpawnRate > 0
		&& bActive)
		SetTimer(GetRate(), false);

	if(GetSpawnClass() == class'Pawn')
		Warn(self$" ERROR, pawn won't spawn anything");

	// If we monitor the world and only want to make a finite amount
	// then init TotalSpawned to how many things of this tag are already
	// alive in the world, essentially treating the things already alive
	// in the world as spawned by us (though they weren't really).
	if(bMonitorWorld
		&& bActive)
		InitMonitor();
}

///////////////////////////////////////////////////////////////////////////////
// Get dynamic rate this time, in case it's random
///////////////////////////////////////////////////////////////////////////////
function float GetRate()
{
	local float userate;

	if(bRandomizeRate)
		userate = FRand()*SpawnRate + SpawnRate*0.5;
	else
		userate = SpawnRate;

	//log("use rate "$userate);

	return userate;
}

///////////////////////////////////////////////////////////////////////////////
// Do specific things to the spawned object, like to pawns
///////////////////////////////////////////////////////////////////////////////
function SpecificInits(Actor spawned)
{
	local KActor kat;

	// Tell them they used the wrong spawner
	if(FPSPawn(spawned) != None)
		log(self$" Use a pawn spawner instead "$spawned);

	// Use this mesh
	if(UseStaticMesh != None)
	{
		spawned.SetStaticMesh(UseStaticMesh);
		spawned.SetDrawType(DT_StaticMesh);
	}

	kat = KActor(spawned);
	if(kat != None)
	{
		kat.KWake();
//		kat.KStartEnabled=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get the class of the thing to spawn
///////////////////////////////////////////////////////////////////////////////
function class<Actor> GetSpawnClass()
{
	return SpawnClass;
}

///////////////////////////////////////////////////////////////////////////////
// Active or not, check right now for any that are spawned and count them
// as our own
///////////////////////////////////////////////////////////////////////////////
function InitMonitor()
{
	local Actor CheckA;

	TotalSpawned=0;
	// Check the world and see if anyone is still alive--slow!
	foreach DynamicActors(class'Actor', CheckA, SpawnTag)
	{
		// Link up the live ones to have me as an event, to trigger
		// me when they die (even if we already did this)
		CheckA.Event = Tag;

		log(self$" initting with "$CheckA);
		TotalSpawned++;
	}
	log(self$" total already is "$TotalSpawned);

	// If we have enough already, delete me now
	if(MaxSpawned != 0 
		&& TotalSpawned >= MaxSpawned)
//		Destroy();
		bDisabled = true;
}

///////////////////////////////////////////////////////////////////////////////
// Tally up the current number of alive of the class we care about.
///////////////////////////////////////////////////////////////////////////////
function MonitorWorld()
{
	local Actor CheckA;

	TotalAlive=0;
	// Check the world and see if anyone is still alive--slow!
	foreach DynamicActors(class'Actor', CheckA, SpawnTag)
	{
		// Link up the live ones to have me as an event, to trigger
		// me when they die (even if we already did this)
		CheckA.Event = Tag;

		log(self$" monitoring "$CheckA);
		TotalAlive++;
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
/*
///////////////////////////////////////////////////////////////////////////////
// Record times and do spawns
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
//	log("last render time "$LastRenderTime);
//	log("current time "$CurrentTime);

	if(SpawnRate <= 0)
		return;

	// Check to do the actual spawning

	// By only allowing one, we keep the spawns from building up, when you stare at a spawner
	// or something. Otherwise, you could look for twenty seconds and when you turn away, 
	// the spawner could try to make lots of things in just one go, if this were a loop below.
	if(LocalTime < SpawnRate)
		LocalTime+=DeltaTime;

	if(LocalTime >= SpawnRate)
	{
		LocalTime-=SpawnRate;
		DoSpawn();
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// Do spawns every time the timer goes off
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	DoSpawn();
}

///////////////////////////////////////////////////////////////////////////////
// Trigger a spawn
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
{
	if(bSetActiveAfterTrigger)
	{
		bSetActiveAfterTrigger=false;
		bActive=true;
		// If we monitor the world and only want to make a finite amount
		// then init TotalSpawned to how many things of this tag are already
		// alive in the world, essentially treating the things already alive
		// in the world as spawned by us (though they weren't really).
		if(bMonitorWorld
			&& bActive)
			InitMonitor();
		if(!bDeleteMe)
		{
			if(PostTriggerStartTime > 0.0)
			{
				SetTimer(PostTriggerStartTime, false);
			}
			else
				DoSpawn();
		}
		else
			return;
	}
	else
	{
		// Get ready for another check
		GotoState('');

		// Check to update if someone died before this trigger or not
		if(ClassIsChildOf(Other.class, GetSpawnClass()))
		{
			TotalAlive--;
			//log("num alive now "$TotalAlive);
		}

		//log("other "$Other$" event maker "$EventInstigator);
		if(SpawnRate != 0)
			SetTimer(GetRate(), false);
		else
			DoSpawn();
	}
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait here if you have made enough and are waiting on someone to die
// We don't recieve timer commands.. we're completely driven by the Trigger
// of when something dies. 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Waiting
{
	ignores Timer;
}

defaultproperties
{
	bMovable=False
	SpawnClass=class'Pawn'
	SpawnRate=5
	NumToKeepAlive=3
	bRandomizeRate=true
	bSpawnWhenNotSeen=true
	bActive=true

	CollisionRadius=150
	bDirectional=true
    bCollideActors=False
    bCollideWorld=False
    bBlockActors=False
    bBlockPlayers=False
	bBlockZeroExtentTraces=False
	bBlockNonZeroExtentTraces=False
	Texture=Texture'PostEd.Icons_256.Spawner'
	DrawScale=0.25
}

