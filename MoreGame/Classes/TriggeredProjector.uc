///////////////////////////////////////////////////////////////////////////////
// TriggeredProjector
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// A regular projector that can be triggered on and off.
///////////////////////////////////////////////////////////////////////////////
class TriggeredProjector extends Projector;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var(Projector) bool bActive;		// Whether or not we should currently be displaying this projector

// Turns projector on
function TurnOnProjector()
{
	bActive = true;
	AttachProjector();
	if( bLevelStatic )
	{
		AbandonProjector();
		// Save that we projected and are waiting for a reload to reproject. 
		// Don't destroy us though. We must be saved, in order to come back
		bReprojectAfterLoad=true;
	}
	else
		bReprojectAfterLoad=false;
}

// Turns projector off
function TurnOffProjector()
{
	bActive = false;
	DetachProjector();
}

event PostBeginPlay()
{
	// RWS Change 01/22/03 If the game specifies no projectors, kill them right here, now
	if(!bUseProjectors)
	{
		Destroy();
	}
	else
	{
		if (bActive)
			TurnOnProjector();			

		if( bProjectActor )
		{
			SetCollision(True, False, False);
			// GotoState('ProjectActors');  //FIXME - state doesn't exist
		}
	}
}

// RWS Change 02/20/02
// Reproject after the load if we need to
event PostLoadGame()
{
	if (bActive)
		Super.PostLoadGame();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state() TriggerToggles				// Trigger turns on and off in toggle fashion
{
	event Trigger( Actor Other, Pawn EventInstigator )
	{
		if (bActive)
			TurnOffProjector();
		else
			TurnOnProjector();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state() TriggerControls				// Trigger/UnTrigger turns on and off.
{
	event Trigger( Actor Other, Pawn EventInstigator )
	{
		if (bActive)
			TurnOffProjector();
		else
			TurnOnProjector();
	}
	event UnTrigger( Actor Other, Pawn EventInstigator )
	{
		Trigger(Other, EventInstigator);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state() TriggerTurnsOn				// Trigger turns ON only
{
	event PostBeginPlay()
	{
		bActive = false;
		Global.PostBeginPlay();
	}
	event Trigger( Actor Other, Pawn EventInstigator )
	{
		TurnOnProjector();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state() TriggerTurnsOff				// Trigger turns OFF only
{
	event PostBeginPlay()
	{
		bActive = true;
		Global.PostBeginPlay();
	}
	event Trigger( Actor Other, Pawn EventInstigator )
	{
		TurnOffProjector();
	}
}

defaultproperties
{
	bStatic=false
	bActive=true
	InitialState=TriggerToggles
}