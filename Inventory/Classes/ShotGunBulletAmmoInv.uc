///////////////////////////////////////////////////////////////////////////////
// ShotGunBulletAmmoInv
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Shotgun ammo inventory item (as opposed to pickup).
//
//	History:
//		01/29/02 MJR	Started history, probably won't be updated again until
//							the pace of change slows down.
// 		
//		11/20/22 Piotr S.	Rebalanced and fixed the way Sawn-Off Shotgun deals damage, added Beta Shotgun support too.
//
///////////////////////////////////////////////////////////////////////////////

class ShotGunBulletAmmoInv extends P2AmmoInv;

var class<DamageType>	AltHeadDamage;	// Not used anymore, still better keep it for backward compability.
var class<DamageType>	AltBodyDamage;	// What type of altdamage you take from the thing hit
const DISTANCE_FOR_DISMEMBERMENT = 440; // was 600; 	NOTE: 440 equals shotgun's dist to explode head x 2

var travel int CatAmmoLeft;		// How many shots we've taken with the cat, when this reaches
								// 0, the cat shoots off
var int ShotsWithCat;			// total shots we get with a cat, probably 9 for 9 lives
var float FleshRad;
var Sound FleshHit[4];

var array<Sound> BotHit, SkelHit;

///////////////////////////////////////////////////////////////////////////////
// Process a trace hitting something
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Rotator NewRot;

	if ( Other == None )
		return;
		
	// If fired from a Sawn-Off Shotgun, send control to the sawn-off ammo
																	// Change by Man Chrzan: xPatch
	if (W.IsA('SawnOffWeapon') && !P2Weapon(W).bAltFiring			// Ignore when alt firing Sawn-Off. (Unused)
		|| W.IsA('BetaShotgunWeapon') && P2Weapon(W).bAltFiring )	// Allow when alt firing Beta Shotgun.
	{
		ProcessAltTraceHit(W, Other, HitLocation, HitNormal, X, Y, Z);
		return;
	}
	
	if (Other.bStatic)//Other.bWorldGeometry ) 
	{
		spawn(class'ShotgunBulletHitPack',W.Owner, ,HitLocation, Rotator(HitNormal));
	}
	else 
	{
		Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, DamageTypeInflicted);

		if (P2MocapPawn(Other) != None)
		{
			if (P2MocapPawn(Other).MyRace < RACE_Automaton)
				Other.PlaySound(FleshHit[Rand(ArrayCount(FleshHit))],SLOT_Pain,,,FleshRad,GetRandPitch());
			else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
				Other.PlaySound(BotHit[Rand(BotHit.Length)],SLOT_Pain,,,FleshRad,GetRandPitch());
			else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
				Other.PlaySound(SkelHit[Rand(SkelHit.Length)],SLOT_Pain,,,FleshRad,GetRandPitch());
		}
		else if((Pawn(Other) != None && Other != Owner)
			|| PeoplePart(Other) != None
			|| CowheadProjectile(Other) != None)
		{
			if(Rand(2) == 0)
				Other.PlaySound(FleshHit[Rand(ArrayCount(FleshHit))],SLOT_Pain,,,FleshRad,GetRandPitch());
		}
		else // anything else--make a spark hit
		{
			spawn(class'BulletSparkPack',W.Owner, ,HitLocation, Rotator(HitNormal));
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Process a trace hitting something
// for Sawn-Off and Beta Shotgun Alt-Fire
// NOTE: This function was completly rewritten.
///////////////////////////////////////////////////////////////////////////////
function ProcessAltTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local float PercentUpBody;
	local class<DamageType> DamageTypeUsed;
	local float DamageAmountUsed;
	local bool bHeadShot;

	if ( Other == None )
		return;

	if (Other.bStatic)//Other.bWorldGeometry )
	{
		spawn(class'ShotgunBulletHitPack',W.Owner, ,HitLocation, Rotator(HitNormal));
	}
	else
	{
		if(PeoplePart(Other) != None)
			Other.TakeDamage(AltDamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, DamageTypeInflicted);
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				// Check for headshot
				PercentUpBody = (HitLocation.Z - Other.Location.Z) / Other.CollisionHeight;
				if (P2MoCapPawn(Other) != None && PercentUpBody >= P2MoCapPawn(Other).HEAD_RATIO_OF_FULL_HEIGHT)
					bHeadShot = True;
				
				// Pick damage amount
				if(W.IsA('BetaShotgunWeapon') || Other.IsA('AWDude'))
					DamageAmountUsed = DamageAmount;
				else
					DamageAmountUsed = AltDamageAmount;

				// Pick damage type depending on distance and toughness of the NPC
				if(VSize(Instigator.Location - Other.Location) < DISTANCE_FOR_DISMEMBERMENT)
				{
					DamageTypeUsed = AltDamageTypeInflicted;
					
					if(!bHeadShot && P2MoCapPawn(Other) != None)
					{
						// To balance things a little, alter body damage based on TakesShotgunHeadShot
						if(P2MoCapPawn(Other).TakesShotgunHeadShot <= 0.50)
							DamageAmountUsed = DamageAmount;
						
						// And dismember only if the damage is enough to kill or it is a zombie.
						if(P2MoCapPawn(Other).Health <= DamageAmountUsed || Other.IsA('AWZombie'))
							DamageTypeUsed = AltBodyDamage;
					}
				}
				else
					DamageTypeUsed = DamageTypeInflicted;
				
				Other.TakeDamage(DamageAmountUsed, Pawn(Owner), HitLocation, MomentumHitMag*X, DamageTypeUsed);
			}
		}

		if((Pawn(Other) != None && Other != Owner)
			|| PeoplePart(Other) != None
			|| CowheadProjectile(Other) != None)
		{
			if(Rand(2) == 0)
				Other.PlaySound(FleshHit[Rand(ArrayCount(FleshHit))],SLOT_Pain,,,FleshRad,GetRandPitch());
		}
		else // anything else--make a spark hit
		{
			spawn(class'BulletSparkPack',W.Owner, ,HitLocation, Rotator(HitNormal));
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
//	ProjectileClass=Class'ShotGunBulletProj'
	PickupClass=class'ShotgunAmmoPickup'
	bInstantHit=true
	WarnTargetPct=+0.2
	bLeadTarget=true
	RefireRate=0.990000
	MaxAmmo=100
	MaxAmmoMP=40
	DamageAmount=11
	DamageAmountMP=16
	MomentumHitMag=100000
	DamageTypeInflicted=class'ShotGunDamage'
	Texture=Texture'hudpack.icons.Icon_Weapon_Shotgun'

	FleshHit[0]=Sound'WeaponSounds.bullet_hitflesh1'
	FleshHit[1]=Sound'WeaponSounds.bullet_hitflesh2'
	FleshHit[2]=Sound'WeaponSounds.bullet_hitflesh3'
	FleshHit[3]=Sound'WeaponSounds.bullet_hitflesh4'
	BotHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	BotHit[1]=Sound'WeaponSounds.bullet_ricochet2'
	SkelHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	SkelHit[1]=Sound'WeaponSounds.bullet_ricochet2'
	FleshRad=200

    AltDamageAmount=22
    AltHeadDamage=class'ShotgunDamage'		
	AltBodyDamage=class'SuperShotgunBodyDamage'			// Dismembers bodies
    AltDamageTypeInflicted=Class'SuperShotgunDamage'	// Explodes heads (new), destroys doors, cars etc.
	}
