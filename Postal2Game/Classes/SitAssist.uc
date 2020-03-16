///////////////////////////////////////////////////////////////////////////////
// SitAssist
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Invisible actor that turns off collision for a static mesh, then monitors
// to see when the collision can be safely turned back on. This allows
// pawns to "sit" on an object, then get up and walk away.
///////////////////////////////////////////////////////////////////////////////
class SitAssist extends Info;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var array<Actor> DisabledMeshes;			// List of static meshes we "disable"
var Pawn SitPawn;							// Pawn that's sitting on our disabled mesh/meshes
var float CheckRadius;						// Radius that must be clear to re-enable collision

///////////////////////////////////////////////////////////////////////////////
// Initialize for this pawn
///////////////////////////////////////////////////////////////////////////////
function SetupFor(Name DisableTag, float Rad)
{
	local Actor CheckA;
	
	// Nope
	if (DisableTag == '')
	{
		Destroy();
		return;
	}
	
	foreach AllActors(class'Actor', CheckA, DisableTag)
	{
		DisabledMeshes.Insert(0,1);
		DisabledMeshes[0] = CheckA;
		CheckA.SetCollision(false, false, false);
	}
	
	Tag = DisableTag;
	CheckRadius = Rad;
}

///////////////////////////////////////////////////////////////////////////////
// Go through our meshes, if no pawns are nearby then turn collision back on.
///////////////////////////////////////////////////////////////////////////////
event Trigger(Actor Other, Pawn EventInstigator)
{
	Timer();
}

///////////////////////////////////////////////////////////////////////////////
// Turn collision back on
///////////////////////////////////////////////////////////////////////////////
event Timer()
{
	local bool bClear;
	local int i;
	local Pawn CheckP;
	
	// now see if we're colliding anything
	bClear = true;
	for (i = 0; i < DisabledMeshes.Length; i++)
	{
		// If this iterator returns anything, we're blocking someone
		foreach RadiusActors(class'Pawn', CheckP, CheckRadius, DisabledMeshes[i].Location)
		{
			bClear = false;
			break;
		}
		if (!bClear)
			break;
	}
			
	// Cave Johnson, we're done here
	if (bClear)
	{
		for (i = 0; i < DisabledMeshes.Length; i++)
			DisabledMeshes[i].SetCollision(DisabledMeshes[i].Default.bCollideActors, DisabledMeshes[i].Default.bBlockActors, DisabledMeshes[i].Default.bBlockPlayers);
		
		Destroy();
		return;
	}
	
	SetTimer(1.0, false);
}