///////////////////////////////////////////////////////////////////////////////
// ACTION_PawnHealth
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Does things with a pawn's health.
///////////////////////////////////////////////////////////////////////////////
class ACTION_PawnHealth extends P2ScriptedAction;

var(Action) float NewHealth;					// Sets Pawn.Health value (0 = no change, to kill a pawn use ACTION_DamageActors, ACTION_KillPawns, or ACTION_DestroyActor)
var(Action) float NewHealthMax;					// Sets FPSPawn.HealthMax value (0 = no change)
var(Action) float DeltaHealth;					// Changes Pawn.Health value by this much (negative = reduces health, positive = restores health) Will not go above FPSPawn.HealthMax or below 1
var(Action) float DeltaHealthMax;				// Changes FPSPawn.HealthMax value by this much (negative = reduces health max, positive = increases health max) Will not go below 0
var(Action) bool bNewHealthAsPercentOfCurrent;	// If true, NewHealth value is treated as a percent of the CURRENT Pawn.Health value (1.0 = full, 0.5 = half, etc.)
var(Action) bool bNewHealthAsPercentOfMax;		// If true, NewHealth value is treated as a percent of the CURRENT FPSPawn.HealthMax value (1.0 = full, 0.5 = half, etc.)
var(Action) bool bNewHealthMaxAsPercent;		// If true, NewHealthMax value is treated as a percent of the current FPSPawn.HealthMax value (1.0 = full, 0.5 = half, etc.)
var(Action) bool bIgnoreCrackHealth;			// If true, does not take current crack usage into consideration of the pawn's max health (by default it does)
var(Action) name PawnTag;						// Tag of pawn(s) to adjust health on

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{
	local Pawn P;
	local FPSPawn FPawn;
	local float Health;
	local float HealthMax;
	
	foreach C.DynamicActors(class'Pawn', P, PawnTag)
	{
		// Get health and healthmax values
		Health = P.Health;
		FPawn = FPSPawn(P);		
		if (FPawn == None)
		{
			// No FPSPawn, assume current health is healthmax
			warn(self@"and"@P@" - No FPSPawn detected, cannot perform operations with HealthMax.");
			HealthMax = Health;
		}
		else
		{
			HealthMax = FPawn.HealthMax;
			// Set max health if player is in crack addiction
			if (!bIgnoreCrackHealth && P2Pawn(P) != None && P2Pawn(P).CrackAddictionTime > 0)
				HealthMax *= P2Pawn(P).CrackMaxHealthPercentage;
		}
		
		// Set new health
		if (NewHealth != 0)
		{
			if (bNewHealthAsPercentOfCurrent)
				Health = NewHealth * Health;
			else if (bNewHealthAsPercentOfMax)
				Health = NewHealth * HealthMax;
			else
				Health = NewHealth;
		}
		
		// Set new max
		if (NewHealthMax != 0)
		{
			if (bNewHealthMaxAsPercent)
				HealthMax = NewHealthMax * HealthMax;
			else
				HealthMax = NewHealthMax;
		}
		
		// Set delta
		Health += DeltaHealth;
		HealthMax += DeltaHealthMax;
		
		// Sanity check, don't go below 1 or above healthmax.
		HealthMax = FClamp(HealthMax, 1.0, HealthMax);
		Health = FClamp(Health, 1.0, HealthMax);

		// Reset max health if player is in crack addiction
		if (!bIgnoreCrackHealth && P2Pawn(P) != None && P2Pawn(P).CrackAddictionTime > 0)
			HealthMax /= P2Pawn(P).CrackMaxHealthPercentage;
			
		// Sanity check, don't go below 1
		HealthMax = FClamp(HealthMax, 1.0, HealthMax);
		
		// If we were above max and this was intended to heal but we lost health, make no changes (accounts for weed actor)
		if (Health < P.Health && P.Health > FPawn.HealthMax && (DeltaHealth > 0 || (NewHealth >= 1.0 && bNewHealthAsPercentOfMax)))
			continue;
		
		// Now actually set the values
		P.Health = Health;
		if (FPawn != None)
			FPawn.SetMaxHealth(HealthMax);
	}
	
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	NewHealth=0
	NewHealthMax=0
	//bNewHealthAsPercent=false
	bNewHealthMaxAsPercent=false
	//bNewHealthMaxAsMax=false
}