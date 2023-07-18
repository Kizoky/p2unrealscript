///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// New shared 9mm ammo class for MP5 and Glock. 
///////////////////////////////////////////////////////////////////////////////

class NineAmmoInv extends P2AmmoInv;

const FLESH_HIT_MAX	=	4;

var Sound FleshHit[FLESH_HIT_MAX];
var float FleshRad;
var array<Sound> BotHit, SkelHit;

var	class<Pickup>  AltPickupClass;
var float AltDamageAmount;
var MP5Weapon MP5;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Rotator NewRot;

	// Reduce ammo only if it's not reloadable weapon
	if (!P2Weapon(W).bReloadableWeapon)
		UseAmmoForShot();

	if ( Other == None )
		return;

	if(Other.bStatic)
	{
		spawn(class'PistolBulletHitPack',Owner, ,HitLocation, Rotator(HitNormal));
	}
	else 
	{
		if (W.IsA('MP5Weapon'))
		{
			if(PickupClass == default.PickupClass)
				PickupClass = AltPickupClass;
				
			Other.TakeDamage(AltDamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, AltDamageTypeInflicted);
		}
		else
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
			Other.PlaySound(FleshHit[Rand(ArrayCount(FleshHit))],SLOT_Pain,,,FleshRad,GetRandPitch());
		}
		else // anything else--make a spark hit
		{
			spawn(class'PistolBulletHitPack',W.Owner, ,HitLocation, Rotator(HitNormal));
		}
	}
}

defaultproperties
{
     FleshRad=200.000000
     MomentumHitMag=10000.000000
     MaxAmmoMP=500
     MaxAmmo=500 
     bLeadTarget=True
     bInstantHit=True
     WarnTargetPct=0.200000
     RefireRate=0.990000
	 PickupClass=Class'GSelectAmmoPickup'
	 AltPickupClass=Class'MP5AmmoPickup'

     Texture=Texture'EDHud.hud_mp5'
	 
	 // Glock's Damage Ammount
	 DamageAmount=13.000000 //15
	 // SMG's Damage Ammount	 
	 AltDamageAmount=12.000000 //12 		
	 
	 // Glock's Damage Type
	 DamageTypeInflicted=Class'MachineGunDamage' //'BulletDamage'	
	 // SMG's Damage Type	 
	 AltDamageTypeInflicted=class'MachineGunDamage' 
	 
	 FleshHit[0]=Sound'WeaponSounds.bullet_hitflesh1'
	 FleshHit[1]=Sound'WeaponSounds.bullet_hitflesh2'
	 FleshHit[2]=Sound'WeaponSounds.bullet_hitflesh3'
	 FleshHit[3]=Sound'WeaponSounds.bullet_hitflesh4'
	 BotHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	 BotHit[1]=Sound'WeaponSounds.bullet_ricochet2'
	 SkelHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	 SkelHit[1]=Sound'WeaponSounds.bullet_ricochet2'
}
