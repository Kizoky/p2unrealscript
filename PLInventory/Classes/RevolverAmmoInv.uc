///////////////////////////////////////////////////////////////////////////////
// RevolverAmmoInv
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Revolver ammo
//
// Edited by Man Chrzan: Bug fixes, rebalance
///////////////////////////////////////////////////////////////////////////////
class RevolverAmmoInv extends PistolBulletAmmoInv;

var() class<DamageType> EnhancedDamageTypeInflicted;
var bool bExecuting;
var float ExecutingDamageMultiplier;

///////////////////////////////////////////////////////////////////////////////
// Process a trace hitting something during execution
///////////////////////////////////////////////////////////////////////////////
function ProcessExecutionTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	bExecuting = True;
	ProcessTraceHit(W,Other,HitLocation,HitNormal,X,Y,Z);
}

///////////////////////////////////////////////////////////////////////////////
// Process a trace hitting something
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local class<DamageType> UseDamageType;
	local float UseDamageAmount;
	local bool bEnhancedMode;

	// reduce the ammo
	UseAmmoForShot();

	if ( Other == None )
		return;

	if ( Other.bStatic)//Other.bWorldGeometry ) 
	{
		spawn(class'PistolBulletHitPack',W.Owner, ,HitLocation, Rotator(HitNormal));
	}
	else 
	{
		// Revolver gains some crazy-ass powers in Enhanced Game
		bEnhancedMode = (P2GameInfoSingle(Level.Game).VerifySeqTime() && Pawn(Owner).Controller.bIsPlayer);
			
		// Check if it's a perfect headshot, the multiplayer way
		if (P2MoCapPawn(Other) != None && P2MoCapPawn(Other).IsMPHeadshot(hitlocation))
		{
			UseDamageType = DamageTypeInflicted;
			UseDamageAmount = AltDamageAmount;
			
			// Enhanced Game: Insta-kills almost anyone with the headshot, 
			// the exact same way as alt-fire execution, checks for exceptions! 
			if (bEnhancedMode && !RevolverWeapon(W).IsException(Pawn(Other))
				|| Other.IsA('AWZombie')) // Also, use this to kill zombies.
			{
				P2MoCapPawn(Other).Died(Instigator.Controller, UseDamageType, HitLocation);
				P2MoCapPawn(Other).ExplodeHead(HitLocation, vect(0,0,0));
			}
		}
		else
		{
			// Enhanced Game: Dismember limbs with SuperRifleDamage!
			if(bEnhancedMode)
				UseDamageType = EnhancedDamageTypeInflicted; 
			else
				UseDamageType = DamageTypeInflicted;
			
			UseDamageAmount = DamageAmount;
		}
			
		// Executing increases the damage some more.
		if(bExecuting) {
			UseDamageAmount = UseDamageAmount * ExecutingDamageMultiplier;
			bExecuting = False;
		}

		Other.TakeDamage(UseDamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, UseDamageType);
			
		if (P2MocapPawn(Other) != None)
		{
			if (P2MocapPawn(Other).MyRace < RACE_Automaton)
				Other.PlaySound(FleshHit[Rand(ArrayCount(FleshHit))],SLOT_Pain,,,FleshRad,GetRandPitch());
			else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
				Other.PlaySound(BotHit[Rand(BotHit.Length)],SLOT_Pain,,,FleshRad,GetRandPitch());
			else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
				Other.PlaySound(SkelHit[Rand(SkelHit.Length)],SLOT_Pain,,,FleshRad,GetRandPitch());
		}
		else if((Pawn(Other) != None 
				&& Other != Owner)
			|| PeoplePart(Other) != None
			|| CowheadProjectile(Other) != None)
		{
			Other.PlaySound(FleshHit[Rand(ArrayCount(FleshHit))],SLOT_Pain,,,FleshRad,GetRandPitch());
		}
		else // anything else--make a spark hit
		{
			spawn(class'BulletSparkPack',W.Owner, ,HitLocation, Rotator(HitNormal));
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Pick damage amount and type
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	DamageAmount=36
	AltDamageAmount=68				// Higher damage for perfect headshot
	ExecutingDamageMultiplier=1.50	// if pawn is an exception it doesn't die instantly but we will increase the damage instead
    PickupClass=class'RevolverAmmoPickup'	
	MaxAmmo=120
	DamageTypeInflicted=class'SuperBulletDamage'
	EnhancedDamageTypeInflicted=class'SuperRifleDamage'
}