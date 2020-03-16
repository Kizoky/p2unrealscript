///////////////////////////////////////////////////////////////////////////////
// Baton ammo
///////////////////////////////////////////////////////////////////////////////
class BatonAmmoInv extends InfiniteAmmoInv;

var Sound BatonHit;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local vector mom;
	local float UseDamage;

	if ( Other == None )
		return;

	if(Pawn(Other) == None
		&& PeoplePart(Other) == None)
	{
		// randomly orient the splat on the wall (rotate around the normal)
		NewRot = Rotator(-HitNormal);
		NewRot.Roll=(65536*FRand());

		smoke1 = Spawn(class'Fx.SmokeHitPuffMelee',,,HitLocation, Rotator(HitNormal));
		if(FRand()<0.3)
		{
			dirt1 = Spawn(class'Fx.DirtClodsMachineGun',,,HitLocation, Rotator(HitNormal));
		}
		if(FRand()<0.15)
		{
			spark1 = Spawn(class'Fx.SparkHitMachineGun',,,HitLocation, Rotator(HitNormal));
		}
	}


	if ( (Other != self) && (Other != Owner) ) 
	{
		Instigator.PlaySound(BatonHit, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());

		if(Level.Game != None
			&& Level.Game.bIsSinglePlayer)
			UseDamage = DamageAmount;
		else
			UseDamage = DamageAmountMP;

		if(!P2Weapon(W).bAltFiring)
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, -MomentumHitMag*Y  + MomentumHitMag*vect(0, 0, 1.0)*(FRand() + 0.2), DamageTypeInflicted);
		}
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				mom = VRand();
				mom.z=0;
				mom.x*=0.1;
				mom.y*=0.1;

				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, -MomentumHitMag*Z + MomentumHitMag*mom, DamageTypeInflicted);
			}
		}
		// If we hit a pawn make the weapon a little bloody
		if ((W.Class == class'BatonWeapon')
			&& Pawn(Other) != None
			&& (P2MocapPawn(Other) == None
			|| P2MocapPawn(Other).MyRace < RACE_Automaton))
		{
			//log(W.Class@Other@P2MoCapPawn(Other)@P2MoCapPawn(Other).MyRace);
			P2BloodWeapon(W).DrewBlood();
		}
	}
}

defaultproperties
{
	DamageAmount=10
	DamageAmountMP=25
	bInstantHit=true
	Texture=Texture'HUDPack.Icons.Icon_Weapon_Baton'
	DamageTypeInflicted=class'BatonDamage'
	MomentumHitMag=30000
	BatonHit=Sound'WeaponSounds.baton_hit'
	TransientSoundRadius=80
}