///////////////////////////////////////////////////////////////////////////////
// ACTION_ForceMoveLatent
// Copyright 2014, Running With Scissors, Inc
//
// super ultra bullshit hackjob move action
///////////////////////////////////////////////////////////////////////////////
class ACTION_ForceMoveLatent extends LatentScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// vars, consts enums other bullshit
///////////////////////////////////////////////////////////////////////////////
var(Action) float MoveTime;			// amount of time to move
var(Action) float Velocity;			// Forward velocity to apply, UU/sec

var float TimeElapsed;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{
	C.CurrentAction = self;

	// Turn off physics and collision so we can move the pawn however we want
	C.Pawn.SetPhysics(PHYS_None);
	C.Pawn.SetCollision(False, False, False);
	C.Pawn.bCollideWorld = false;
	
	return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool TickedAction()
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool StillTicking(ScriptedController C, float DeltaTime)
{
	local vector newpos;

	// move the pawn in the direction it's facing
	newpos = C.Pawn.Location + (vector(C.Pawn.Rotation) * DeltaTime * Velocity);
	C.Pawn.SetLocation(newpos);	
	TimeElapsed += DeltaTime;
	
	if (TimeElapsed >= MoveTime)
	{
		// turn collision back on (physics is set automatically somewhere)
		C.Pawn.SetPhysics(PHYS_None);
		C.Pawn.SetCollision(C.Pawn.Default.bCollideActors, C.Pawn.Default.bBlockActors, C.Pawn.Default.bBlockPlayers);
		C.Pawn.bCollideWorld = C.Pawn.default.bCollideWorld;
		
		// There's no way to force an action completion, so we just do it here manually. Fuck the police >:O
		C.CurrentAction = None;
		C.ActionNum++;
		C.GotoState('Scripting','Begin');
		return false;
	}
	else
	{
		// force PHYS_None
		C.Pawn.SetPhysics(PHYS_None);
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActionString="force move"
}