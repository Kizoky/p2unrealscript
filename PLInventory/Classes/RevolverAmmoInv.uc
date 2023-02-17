///////////////////////////////////////////////////////////////////////////////
// RevolverAmmoInv
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Revolver ammo
///////////////////////////////////////////////////////////////////////////////
class RevolverAmmoInv extends PistolBulletAmmoInv;

var() class<DamageType> EnhancedDamageTypeInflicted;

///////////////////////////////////////////////////////////////////////////////
// Process a trace hitting something
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Rotator NewRot;
	local float PercentUpBody;
	local class<DamageType> UseDamageType;
	
	// Revolver gains some crazy-ass powers in enhanced game
	if (P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
	{
		// reduce the ammo
		UseAmmoForShot();

		if ( Other == None )
			return;

		if ( Other.bStatic)//Other.bWorldGeometry ) 
			spawn(class'PistolBulletHitPack',W.Owner, ,HitLocation, Rotator(HitNormal));
		else if (Other.IsA('Head'))
			Head(Other).PinataStyleExplodeEffects(HitLocation, MomentumHitMag*X);
		else 
		{
			PercentUpBody = (HitLocation.Z - Other.Location.Z) / Other.CollisionHeight;
			UseDamageType = EnhancedDamageTypeInflicted;
			
			// If it's a headshot, explode the head
			If (P2MoCapPawn(Other) != None				// MoCap pawns only
				&& P2Pawn(Other).bHasHead				// Pawns with heads only
				&& P2Pawn(Other).bHeadCanComeOff		// Pawns with REMOVABLE heads only
				&& P2MoCapPawn(Other).MyHead != None	// Pawn has a head
				&& PercentUpBody > P2Pawn(Other).HEAD_RATIO_OF_FULL_HEIGHT	// Headshot ok
				&& !Other.IsA('PLBossPawn')				// Not a boss
				)
			{
				// knock off the head
				P2MocapPawn(Other).ExplodeHead(HitLocation, MomentumHitMag*X);
				
				// Zombies: say their head came off
				if (Other.IsA('AWZombie'))
					UseDamageType = class'HeadKillDamage';

				// set damage = life
				if (Pawn(Other).Health > 0)
					DamageAmount = Pawn(Other).Health;
			}
			
			Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, UseDamageType);
			
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
	else
		Super.ProcessTraceHit(W, Other, HitLocation, HitNormal, X, Y, Z);
}

defaultproperties
{
	DamageAmount=36
    PickupClass=class'RevolverAmmoPickup'	
	MaxAmmo=300
	EnhancedDamageTypeInflicted=class'BulletDamage'
}