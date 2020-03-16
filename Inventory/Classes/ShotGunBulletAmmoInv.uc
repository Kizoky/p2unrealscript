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
///////////////////////////////////////////////////////////////////////////////

class ShotGunBulletAmmoInv extends P2AmmoInv;

var class<DamageType>	AltHeadDamage;	// What type of altdamage you take from the thing hit
var class<DamageType>	AltBodyDamage;	// What type of altdamage you take from the thing hit
const DISTANCE_FOR_DISMEMBERMENT = 600;

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
	if (W.IsA('SawnOffWeapon'))
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
// Sawnoff version
///////////////////////////////////////////////////////////////////////////////
function ProcessAltTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Rotator NewRot;
	local float PercentUpBody;
	local bool bHeadDamage, bZombieDamage;
	local class<DamageType> DamageTypeUsed;

	if ( Other == None )
		return;

	if (Other.bStatic)//Other.bWorldGeometry )
	{
		spawn(class'ShotgunBulletHitPack',W.Owner, ,HitLocation, Rotator(HitNormal));
	}
	else
	{
		// smash people and things with the sledge
		if(PeoplePart(Other) != None)
		{
			if (Other.IsA('Head'))
				Other.TakeDamage(AltDamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, AltHeadDamage);
			else
				Other.TakeDamage(AltDamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, AltBodyDamage);
		}
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				PercentUpBody = (HitLocation.Z - Other.Location.Z) / Other.CollisionHeight;

				// If it's a headshot, explode the head
				If (P2MoCapPawn(Other) != None				// MoCap pawns only
					&& P2Pawn(Other).bHasHead				// Pawns with heads only
					&& P2Pawn(Other).bHeadCanComeOff		// Pawns with REMOVABLE heads only
					&& P2MoCapPawn(Other).MyHead != None	// Pawn has a head
					&& PercentUpBody > P2Pawn(Other).HEAD_RATIO_OF_FULL_HEIGHT	// Headshot ok
					&& VSize(Instigator.Location - Other.Location) < P2MoCapPawn(Other).DISTANCE_TO_EXPLODE_HEAD	// Close enough to explode head
					)
					//&& AWZombie(Other) == None)				// Zombies handle headshots differently
				{
					// Zombies handle headshots differently
					if (Other.IsA('AWZombie'))
					{
						// Turn it into regular shotgun damage to destroy their head.
						bZombieDamage = True;
					}
					else
					{
						// knock off the head
						P2MocapPawn(Other).ExplodeHead(HitLocation, MomentumHitMag*X);

						// set damage = life
						if (Pawn(Other).Health > 0)
							DamageAmount = Pawn(Other).Health;
					}
				}
				if (!Other.IsA('AWPerson') && !Other.IsA('AWZombie') && !Other.IsA('DoorMover'))
					bHeadDamage = True;
					
				if (bZombieDamage)
					DamageTypeUsed = DamageTypeInflicted;
				else if (bHeadDamage)
					DamageTypeUsed = AltHeadDamage;
				else if (Other.IsA('AWPerson')
					&& !Other.IsA('AWZombie')	// Never do dismemberment on zombies, makes it too hard to get their head.
					&& VSize(Instigator.Location - Other.Location) < DISTANCE_FOR_DISMEMBERMENT)	// Only offer dismemberment if they're in close proximity
					DamageTypeUsed = AltBodyDamage;
				else
					DamageTypeUsed = AltDamageTypeInflicted;
					
				//log(self@"attacking"@other@"with damage type"@damagetypeused@bZombieDamage@bHeadDamage,'Debug');
					
				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, DamageTypeUsed);
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

    AltDamageAmount=8
    AltHeadDamage=class'ShotgunDamage'
	AltBodyDamage=class'SuperShotgunBodyDamage'
    AltDamageTypeInflicted=Class'SuperShotgunDamage'
	}
