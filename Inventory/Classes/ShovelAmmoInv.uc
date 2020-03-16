///////////////////////////////////////////////////////////////////////////////
// shovel ammo
///////////////////////////////////////////////////////////////////////////////
class ShovelAmmoInv extends InfiniteAmmoInv;

var Sound ShovelHitBody;
var Sound ShovelStab;
var Sound ShovelHitWall;

const MIN_Z_MOMENTUM = 0.3;

var() class<DamageType> AltDamageTypeInflictedSever;
const MIN_HEALTH_FOR_SEVER = 0.25;
const SEVER_CHANCE = 0.5;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local vector Momentum;

	if ( Other == None )
		return;

	if(Pawn(Other) == None
		&& PeoplePart(Other) == None)
	{
		// randomly orient the splat on the wall (rotate around the normal)
		NewRot = Rotator(-HitNormal);
		NewRot.Roll=(65536*FRand());

		smoke1 = Spawn(class'Fx.SmokeHitPuffMelee',Owner,,HitLocation, Rotator(HitNormal));
		if(FRand()<0.3)
		{
			dirt1 = Spawn(class'Fx.DirtClodsMachineGun',Owner,,HitLocation, Rotator(HitNormal));
		}
		if(FRand()<0.15)
		{
			spark1 = Spawn(class'Fx.SparkHitMachineGun',Owner,,HitLocation, Rotator(HitNormal));
		}
	}


	if ( (Other != self) && (Other != Owner) ) 
	{
		if(!P2Weapon(W).bAltFiring)
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = (Y+Z)/2;
				// Ensure things go up always at least some.
				if(Momentum.z < 2*MIN_Z_MOMENTUM)
					Momentum.z = (MIN_Z_MOMENTUM*FRand()) + MIN_Z_MOMENTUM;
				Momentum = MomentumHitMag*Momentum;

				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
			}
		}
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = MomentumHitMag*X + MomentumHitMag*vect(0, 0, 1.0)*FRand();
				
				// If they're low on health, sometimes chop off limbs
				if (FPSPawn(Other) != None
					&& FPSPawn(Other).Health / FPSPawn(Other).HealthMax <= MIN_HEALTH_FOR_SEVER
					&& FRand() <= SEVER_CHANCE
					)
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, AltDamageTypeInflictedSever);
				else
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, AltDamageTypeInflicted);
			}
		}

		if(FPSPawn(Other) != None)
		{
			if(P2Weapon(W).bAltFiring)
				Instigator.PlayOwnedSound(ShovelStab, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else if(AnimalPawn(Other) != None
				|| FPSPawn(Other).Health <= 0)
				Instigator.PlayOwnedSound(ShovelHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				
			// HACK: We only want this to activate on the Shovel, not on anything that subclasses this because it may not have the blood textures set up
			// If we hit a pawn make the weapon a little bloody
			if ((W.Class == class'ShovelWeapon')
				&& Pawn(Other) != None
				&& (P2MocapPawn(Other) == None
				|| P2MocapPawn(Other).MyRace < RACE_Automaton))
				P2BloodWeapon(W).DrewBlood();
		}
		else
		{
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(ShovelHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else
				Instigator.PlayOwnedSound(ShovelHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
	}
}

defaultproperties
{
	DamageAmount=12
	bInstantHit=true
	Texture=Texture'HUDPack.Icon_Weapon_Shovel'
	DamageTypeInflicted=class'ShovelDamage'
	AltDamageTypeInflicted=class'CuttingDamageShovel'
	AltDamageTypeInflictedSever=class'MacheteDamageShovel'
	MomentumHitMag=120000
	ShovelStab=Sound'WeaponSounds.Shovel_Stab'
	ShovelHitWall=Sound'WeaponSounds.Shovel_HitWall'
	ShovelHitBody=Sound'WeaponSounds.Shovel_HitBody'
	TransientSoundRadius=80
}