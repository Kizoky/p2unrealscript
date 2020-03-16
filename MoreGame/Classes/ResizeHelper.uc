///////////////////////////////////////////////////////////////////////////////
// ResizeHelper
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// ACTION_ResizeActor helper class
///////////////////////////////////////////////////////////////////////////////
class ResizeHelper extends Actor
	notplaceable;
	
///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var float PercentToShrinkTarget;		// How much we should shrink the target to, as a percent of current drawscale. (1.0 = no change, 0.5 = half, 2.0 = double etc.)
var float TimeToShrinkTarget;			// How long the shrinking process should take, in seconds

var Actor HitActor;			// Ref to the pawn that we hit
var float ShrinkTimeStart;	// What time we started the shrinking process

var float StartDrawScale, StartCollisionRadius, StartCollisionHeight;
var float HeadStartDrawScale, HeadStartCollisionRadius, HeadStartCollisionHeight;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Setup(Actor TargetActor, float ResizePct, float ResizeTime)
{
	PercentToShrinkTarget = ResizePct;
	TimeToShrinkTarget = ResizeTime;
	HitActor = TargetActor;
	StartDrawScale = HitActor.DrawScale;
	StartCollisionRadius = HitActor.CollisionRadius;
	StartCollisionHeight = HitActor.CollisionHeight;
	if (P2MocapPawn(HitActor) != None && P2MoCapPawn(HitActor).MyHead != None)
	{
		HeadStartDrawScale = P2MoCapPawn(HitActor).MyHead.DrawScale;
		HeadStartCollisionRadius = P2MoCapPawn(HitActor).MyHead.CollisionRadius;
		HeadStartCollisionHeight = P2MoCapPawn(HitActor).MyHead.CollisionHeight;
	}
	GotoState('ShrinkingTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
{
	HitActor = None;
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShrinkingTarget
// Gradually shrink down the target until we hit the size we need.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShrinkingTarget
{
	///////////////////////////////////////////////////////////////////////////
	// BeginState
	// Record time start. Weakens target, makes them toss weapon etc.
	///////////////////////////////////////////////////////////////////////////
	event BeginState()
	{
		ShrinkTimeStart = Level.TimeSeconds;
	}

	///////////////////////////////////////////////////////////////////////////
	// Tick
	// Gradually shrink down the target
	///////////////////////////////////////////////////////////////////////////
	event Tick(float Delta)
	{
		local float ShrinkPercent;
		local int i;
		
		if (HitActor != None)
		{
			// Calculate shrink percent based on current time
			if (PercentToShrinkTarget < 1)
			{
				ShrinkPercent = 1.0 - (Level.TimeSeconds - ShrinkTimeStart) / TimeToShrinkTarget * (1.0 - PercentToShrinkTarget);
				ShrinkPercent = FClamp(ShrinkPercent, PercentToShrinkTarget, 1.0);
			}
			else
			{
				ShrinkPercent = 1.0 + (Level.TimeSeconds - ShrinkTimeStart) / TimeToShrinkTarget * (PercentToShrinkTarget - 1.0);
				ShrinkPercent = FClamp(ShrinkPercent, 1.0, PercentToShrinkTarget);
			}
			
			// Do the actual shrinking
			HitActor.SetDrawScale(StartDrawScale * ShrinkPercent);
			HitActor.SetCollisionSize(StartCollisionRadius * ShrinkPercent, StartCollisionHeight * ShrinkPercent);
			if (P2MocapPawn(HitActor) != None && P2MoCapPawn(HitActor).MyHead != None)
			{
				P2MocapPawn(HitActor).MyHead.SetDrawScale(HeadStartDrawScale * ShrinkPercent);
				P2MocapPawn(HitActor).MyHead.SetCollisionSize(HeadStartCollisionRadius * ShrinkPercent, HeadStartCollisionHeight * ShrinkPercent);
				
				for (i = 0; i < ArrayCount(P2MocapPawn(HitActor).Boltons); i++)
					if (P2MocapPawn(HitActor).Boltons[i].part != None)
						P2MocapPawn(HitActor).Boltons[i].part.SetDrawScale(P2MocapPawn(HitActor).Boltons[i].part.default.DrawScale * ShrinkPercent);
					
			}			
		}
		// We're done
		if (Level.TimeSeconds - ShrinkTimeStart > TimetoShrinkTarget)
			Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PercentToShrinkTarget=0.5
	TimeToShrinkTarget=1.0

	bHidden=true
	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	bBlockPlayers=false
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false
}