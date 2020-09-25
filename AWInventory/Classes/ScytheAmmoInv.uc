///////////////////////////////////////////////////////////////////////////////
// Scythe ammo
///////////////////////////////////////////////////////////////////////////////
class ScytheAmmoInv extends InfiniteAmmoInv;

var Sound ScytheHitBody;
var Sound ScytheStab;
var Sound ScytheHitWall;
var class<DamageType> BodyDamage;	// damaged caused when we hit the body instead of a limb
var float SeverMag;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local vector Momentum;
	local byte BlockedHit;

	if ( Other == None )
		return;

	// Change by NickP: MP fix
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		DamageAmount = DamageAmountMP;
	else DamageAmount = default.DamageAmount;
	// End

	// Check if they're allowed to hit the person they did, if not, None out Other
	// so it's like a wall hit
	if(PersonPawn(Other) != None)
	{
		if(W != None
			&& W.Owner != None)
		{
			// Instead of using hit location, ensure the block knows it comes from the 
			// attacker originally, so use the weapon's owner
			PersonPawn(Other).CheckBlockMelee(W.Owner.Location, BlockedHit);
			if(BlockedHit == 1)
				Other = None;	// don't let them hit Other!
		}
	}

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
		// Sever limbs first (sever people is picked in the Scythe weapon itself)
		if(PeoplePart(Other) != None)
		{
			Momentum = SeverMag*(-X + VRand()/2);
			if(Momentum.z<0)
				Momentum.z=-Momentum.z;
			Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
		}
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = -MomentumHitMag*(Z/2);

				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, BodyDamage);
			}
		}

		if(FPSPawn(Other) != None
			|| PeoplePart(Other) != None)
		{
			Instigator.PlayOwnedSound(ScytheHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			Instigator.PlaySound(ScytheHitBody, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); // Change by NickP: MP fix
		}
		else
		{
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(ScytheHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else
			{
				Instigator.PlayOwnedSound(ScytheHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				Instigator.PlaySound(ScytheHitWall, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); // Change by NickP: MP fix
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle a specific hit on a pawn that causes something to sever
///////////////////////////////////////////////////////////////////////////////
function ProcessSeverHit(Weapon W, FPSPawn Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector Momentum;

	if(Other == None)
		return;

	// Change by NickP: MP fix
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		DamageAmount = DamageAmountMP;
	else DamageAmount = default.DamageAmount;
	// End

	if(AnimalPawn(Other) != None)
		Instigator.PlayOwnedSound(ScytheHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());

	if(HurtingAttacker(Other))
	{
		Momentum = -SeverMag*((Z/2) + VRand());

		Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
	}
}

defaultproperties
{
     ScytheHitBody=Sound'AWSoundFX.Scythe.scythelimbhit'
     ScytheStab=Sound'AWSoundFX.Scythe.scythestick'
     scythehitwall=Sound'AWSoundFX.Scythe.scythehitwall'
     BodyDamage=Class'BaseFX.CuttingDamage'
     SeverMag=40000.000000
     DamageAmount=70.000000
	 DamageAmountMP=140.000000
     MomentumHitMag=50000.000000
     DamageTypeInflicted=Class'ScytheDamage'
     AltDamageTypeInflicted=Class'AWEffects.FlyingScytheDamage'
     bInstantHit=True
     Texture=Texture'AWHUD.Icons.Scythe_Icon'
     TransientSoundRadius=80.000000
}
