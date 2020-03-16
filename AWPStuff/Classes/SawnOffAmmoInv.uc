class SawnOffAmmoInv extends P2AmmoInv;

var float FleshRad;
var Sound FleshHit[4];
var class<DamageType> HeadDamage;
var class<DamageType> BodyDamage;

const DISTANCE_FOR_DISMEMBERMENT = 600;

///////////////////////////////////////////////////////////////////////////////
// Process a trace hitting something
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Rotator NewRot;
	local float PercentUpBody;
	local bool bHeadDamage, bZombieDamage;

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
				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, HeadDamage);
			else
				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, BodyDamage);
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
				if (!Other.IsA('AWPerson') && !Other.IsA('AWZombie'))
					bHeadDamage = True;
					
				if (bZombieDamage)
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, class'ShotgunBulletAmmoInv'.Default.DamageTypeInflicted);
				else if (bHeadDamage)
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, HeadDamage);
				else if (Other.IsA('AWPerson')
					&& !Other.IsA('AWZombie')	// Never do dismemberment on zombies, makes it too hard to get their head.
					&& VSize(Instigator.Location - Other.Location) < DISTANCE_FOR_DISMEMBERMENT)	// Only offer dismemberment if they're in close proximity
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, BodyDamage);
				else
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, DamageTypeInflicted);
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
     FleshRad=200.000000
     FleshHit(0)=Sound'WeaponSounds.bullet_hitflesh1'
     FleshHit(1)=Sound'WeaponSounds.bullet_hitflesh2'
     FleshHit(2)=Sound'WeaponSounds.bullet_hitflesh3'
     FleshHit(3)=Sound'WeaponSounds.bullet_hitflesh4'
     DamageAmount=8
     MomentumHitMag=100000.000000
     DamageTypeInflicted=Class'SuperShotgunDamage'
     HeadDamage=class'ShotgunDamage'
	 BodyDamage=class'SuperShotgunBodyDamage'
     DamageAmountMP=8
     MaxAmmoMP=20
     MaxAmmo=60
     bLeadTarget=True
     bInstantHit=True
     WarnTargetPct=0.200000
     RefireRate=0.990000
     PickupClass=Class'SawnOffAmmoPickup'
     Texture=Texture'AW7EDTex.Icons.hud_SawnOff'
}
