///////////////////////////////////////////////////////////////////////////////
// TriggeredBlockingVolume
// Copyright 2014 Running With Scissors, Inc. All Rights Reserved
//
// This is a regular BlockingVolume, except when used with a TriggerStatic
// it can toggle the blocking volume on and off.
//
// InitialStates:
//		TriggerTurnsOn - LD sets desired collision flags. When map starts,
//			flags are turned off, and turned back on when triggered.
//		TriggerTurnsOff - All collision flags turned off when triggered.
//		TriggerToggles_StartOn - Collision flags toggled on each trigger.
//		TriggerToggles_StartOff - Same as above, but collision flags are
//			turned off on map start, as with TriggerTurnsOn.
///////////////////////////////////////////////////////////////////////////////
class TriggeredBlockingVolume extends BlockingVolume;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var bool bCollisionStatus;									// True if collision on, false if off.
var bool bOCollideActors, bOCollideWorld, bOBlockActors,	// Saves initial collision values.
			bOBlockPlayers, bOBlockZeroExtentTraces,
			bOBlockNonZeroExtentTraces, bOBlockKarma;

///////////////////////////////////////////////////////////////////////////////
// Saves initial collision settings.
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	Super.PostBeginPlay();
	bOCollideActors = bCollideActors;
	bOCollideWorld = bCollideWorld;
	bOBlockActors = bBlockActors;
	bOBlockPlayers = bBlockPlayers;
	bOBlockZeroExtentTraces = bBlockZeroExtentTraces;
	bOBlockNonZeroExtentTraces = bBlockNonZeroExtentTraces;
	bOBlockKarma = bBlockKarma;
	bCollisionStatus = true;
}

///////////////////////////////////////////////////////////////////////////////
// Toggles collision to on or off.
///////////////////////////////////////////////////////////////////////////////
function ToggleCollisionTo(bool bNewCollision)
{
	if (bNewCollision)
	{
		SetCollision(bOCollideActors, bOBlockActors, bOBlockPlayers);
		bCollideWorld = bOCollideWorld;
		bBlockZeroExtentTraces = bOBlockZeroExtentTraces;
		bBlockNonZeroExtentTraces = bOBlockNonZeroExtentTraces;
		KSetBlockKarma(bOBlockKarma);
		bCollisionStatus = true;		
	}
	else
	{
		SetCollision(false, false, false);
		bCollideWorld = false;
		bBlockZeroExtentTraces = false;
		bBlockNonZeroExtentTraces = false;
		KSetBlockKarma(false);
		bCollisionStatus = false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Toggles collision to opposite of current collision state.
///////////////////////////////////////////////////////////////////////////////
function ToggleCollision()
{
	ToggleCollisionTo(!bCollisionStatus);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Statedefs
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state() TriggerTurnsOn
{
	event BeginState()
	{
		ToggleCollisionTo(false);
	}

	event Trigger(Actor Other, Pawn EventInstigator)
	{
		ToggleCollisionTo(true);
	}
}
state() TriggerTurnsOff
{
	event Trigger(Actor Other, Pawn EventInstigator)
	{
		ToggleCollisionTo(false);
	}
}
state() TriggerToggles_StartOn
{
	event Trigger(Actor Other, Pawn EventInstigator)
	{
		ToggleCollision();
	}
}
state() TriggerToggles_StartOff extends TriggerToggles_StartOn
{
	event BeginState()
	{
		ToggleCollisionTo(false);
	}
}

defaultproperties
{
	bBlockZeroExtentTraces=false
	bWorldGeometry=true
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
	
	InitialState=TriggerToggles_StartOn
}
