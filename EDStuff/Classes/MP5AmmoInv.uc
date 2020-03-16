///////////////////////////////////////////////////////////////////////////////
// In gun ammo
///////////////////////////////////////////////////////////////////////////////
class MP5AmmoInv extends P2AmmoInv;

const FLESH_HIT_MAX	=	4;

var Sound FleshHit[FLESH_HIT_MAX];
var float FleshRad;
var array<Sound> BotHit, SkelHit;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Rotator NewRot;

	UseAmmoForShot();

	if ( Other == None )
		return;

	if(Other.bStatic)
	{
		spawn(class'MachinegunBulletHitPack',W.Owner, ,HitLocation, Rotator(HitNormal));
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
			Other.PlaySound(FleshHit[Rand(ArrayCount(FleshHit))],SLOT_Pain,,,FleshRad,GetRandPitch());
		}
		else // anything else--make a spark hit
		{
			spawn(class'BulletSparkPack',W.Owner, ,HitLocation, Rotator(HitNormal));
		}
	}
}

defaultproperties
	{
//	ProjectileClass=Class'MachineGunBulletProj'
	PickupClass=class'MP5AmmoPickup'
	bInstantHit=true
	WarnTargetPct=+0.2
	bLeadTarget=true
	RefireRate=0.990000
	MaxAmmo=400
	MaxAmmoMP=200
	DamageAmount=12
	DamageAmountMP=12
	MomentumHitMag=50000
	DamageTypeInflicted=class'MachineGunDamage'
	Texture=Texture'EDHud.hud_mp5'

	FleshHit[0]=Sound'WeaponSounds.bullet_hitflesh1'
	FleshHit[1]=Sound'WeaponSounds.bullet_hitflesh2'
	FleshHit[2]=Sound'WeaponSounds.bullet_hitflesh3'
	FleshHit[3]=Sound'WeaponSounds.bullet_hitflesh4'
	BotHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	BotHit[1]=Sound'WeaponSounds.bullet_ricochet2'
	SkelHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	SkelHit[1]=Sound'WeaponSounds.bullet_ricochet2'

	FleshRad=200
	}