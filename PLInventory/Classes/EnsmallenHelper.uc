///////////////////////////////////////////////////////////////////////////////
// EnsmallenHelper
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Ensmallen Cure helper class
// This class helps "bind" the target to the syringe and feeds it constant
// TakeDamage calls so it can't move until it's been fed the cure.
// After that, it either calls an event or simply shrinks the target
///////////////////////////////////////////////////////////////////////////////
class EnsmallenHelper extends Actor
	notplaceable;
	
///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() float PercentToShrinkTarget;		// How much we should shrink the target to, as a percent of current drawscale. (1.0 = no change, 0.5 = half, 0.25 = quarter etc)
var() float TimeToShrinkTarget;			// How long the shrinking process should take, in seconds

var P2Pawn HitPawn;			// Ref to the pawn that we hit
var P2Pawn MyPawn;			// Ref to the pawn using the syringe
var float ShrinkTimeStart;	// What time we started the shrinking process

var float StartDrawScale, StartCollisionRadius, StartCollisionHeight;
var float HeadStartDrawScale, HeadStartCollisionRadius, HeadStartCollisionHeight;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Setup(P2Pawn Attacker, P2Pawn TargetPawn)
{
	HitPawn = TargetPawn;
	MyPawn = Attacker;
	StartDrawScale = HitPawn.DrawScale;
	StartCollisionRadius = HitPawn.CollisionRadius;
	StartCollisionHeight = HitPawn.CollisionHeight;
	if (P2MocapPawn(HitPawn) != None && P2MoCapPawn(HitPawn).MyHead != None)
	{
		HeadStartDrawScale = P2MoCapPawn(HitPawn).MyHead.DrawScale;
		HeadStartCollisionRadius = P2MoCapPawn(HitPawn).MyHead.CollisionRadius;
		HeadStartCollisionHeight = P2MoCapPawn(HitPawn).MyHead.CollisionHeight;
	}
	GotoState('StunningTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
{
	HitPawn = None;
	MyPawn = None;
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// StunningTarget
// While in this state we constantly feed "fake" damage to the pawn and
// controller. This will cause them to "take damage but not really" effectively
// keeping them frozen in place until the injection is complete.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StunningTarget
{
	///////////////////////////////////////////////////////////////////////////
	// Tick
	// Feed "fake" damage to NotifyTakeHit and PlayHit
	///////////////////////////////////////////////////////////////////////////
	event Tick(float Delta)
	{
		if (HitPawn != None && MyPawn != None)
		{
			HitPawn.PlayHit(1, HitPawn.Location, class'EnsmallenDamage', Vect(0,0,0));
			HitPawn.Velocity=Vect(0,0,0);
			if (HitPawn.Controller != None)
				HitPawn.Controller.NotifyTakeHit(MyPawn, HitPawn.Location, 1, class'EnsmallenDamage', Vect(0,0,0));			
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShrinkingTarget
// Gradually shrink down the target until we hit the size we need.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShrinkingTarget extends StunningTarget
{
	///////////////////////////////////////////////////////////////////////////
	// BeginState
	// Record time start. Weakens target, makes them toss weapon etc.
	///////////////////////////////////////////////////////////////////////////
	event BeginState()
	{
		local Inventory Inv;
		local array<Inventory> TossMe;
		local int i;
		
		ShrinkTimeStart = Level.TimeSeconds;

		if (HitPawn != None && HitPawn.Health > 0)
		{
			// Zero out/minimize a bunch of these, being tiny and unable to hold a weapon kinda puts a damper on you
			HitPawn.Cajones *= 0.25;
			HitPawn.Beg *= 2;
			HitPawn.PainThreshold *= 2;
			HitPawn.Confidence *= 0.25;
			HitPawn.VoicePitch *= 2;
			HitPawn.Health *= 0.5;
			HitPawn.HealthMax *= 0.5;
			HitPawn.GroundSpeed *= 0.5;
			HitPawn.AccelRate *= 0.5;
			HitPawn.AirSpeed *= 0.5;
			HitPawn.LadderSpeed *= 0.5;
			
			// Make them drop all of their weapons
			for (Inv = HitPawn.Inventory; Inv != None; Inv = Inv.Inventory)
				if (Weapon(Inv) != None)
				{
					// Can't drop it directly in the loop, it ruins the chain.
					TossMe.Insert(0,1);
					TossMe[0] = Inv;
				}
				
			for (i = 0; i < TossMe.Length; i++)
				HitPawn.TossThisInventory(Vector(HitPawn.Rotation) * 500 + vect(0,0,220), TossMe[i]);
			
			// If it's a mocap pawn, forbid ragdolling (the ragdolls look all stretched)
			if (P2MoCapPawn(HitPawn) != None)
				P2MoCapPawn(HitPawn).bForbidRagdoll = true;
				
			// if it's an AW pawn turn off dismemberment so we don't have to scale the spawned limbs and shit
			if (AWPerson(HitPawn) != None)
				AWPerson(HitPawn).bNoDismemberment = true;
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// Tick
	// Gradually shrink down the target
	///////////////////////////////////////////////////////////////////////////
	event Tick(float Delta)
	{
		local float ShrinkPercent;
		local int i;
		
		if (HitPawn != None && MyPawn != None)
		{
			// Keep the target stunned until the shrinking is done
			Super.Tick(Delta);
			
			// Calculate shrink percent based on current time
			ShrinkPercent = 1.0 - (Level.TimeSeconds - ShrinkTimeStart) / TimeToShrinkTarget * (1.0 - PercentToShrinkTarget);
			ShrinkPercent = FClamp(ShrinkPercent, PercentToShrinkTarget, 1.0);
			
			// Do the actual shrinking
			HitPawn.SetDrawScale(StartDrawScale * ShrinkPercent);
			HitPawn.SetCollisionSize(StartCollisionRadius * ShrinkPercent, StartCollisionHeight * ShrinkPercent);
			if (P2MocapPawn(HitPawn) != None)
			{
				P2MocapPawn(HitPawn).MyHead.SetDrawScale(HeadStartDrawScale * ShrinkPercent);
				P2MocapPawn(HitPawn).MyHead.SetCollisionSize(HeadStartCollisionRadius * ShrinkPercent, HeadStartCollisionHeight * ShrinkPercent);
				
				for (i = 0; i < ArrayCount(P2MocapPawn(HitPawn).Boltons); i++)
					if (P2MocapPawn(HitPawn).Boltons[i].part != None)
						P2MocapPawn(HitPawn).Boltons[i].part.SetDrawScale(P2MocapPawn(HitPawn).Boltons[i].part.default.DrawScale * ShrinkPercent);
					
			}
			
			// We're done
			if (ShrinkPercent <= PercentToShrinkTarget)
			{
				// If it's a bystander, make it run away forever
				if (PersonController(HitPawn.Controller) != None)
					HitPawn.Controller.GotoState('FleeForever');
					
				Destroy();
			}
		}
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