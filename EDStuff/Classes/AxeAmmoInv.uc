//=============================================================
//   Axe
//   Eternal Damnation
//   MaDJacKaL
//=============================================================
class AxeAmmoInv extends InfiniteAmmoInv;

var Sound MacheteHitBody;
var Sound MacheteStab;
var Sound MacheteHitWall;
var Sound MacheteHitBot, MacheteHitSkel;
var class<DamageType> BodyDamage;	// damaged caused when we hit the body instead of a limb
var float SeverMag, MaxDamageAmount;
//var float ChargeTime;
var bool bCharged;

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
	local class<DamageType> UseDamageType;
	local float UseDamageAmount;

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
			Personpawn(Other).CheckBlockMelee(W.Owner.Location, BlockedHit);
			if(BlockedHit == 1)
				Other = None;	// don't let them hit Other!
		}
	}

	if (Other.bStatic)//Other.bWorldGeometry )
	{
		//spawn(class'SliceSplatMaker',W.Owner, ,HitLocation, Rotator(HitNormal));

		// randomly orient the splat on the wall (rotate around the normal)
		NewRot = Rotator(-vector(Rotation));
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
		// xPatch: Handle damage depending on alt fire charge and stuff
		UseDamageType = DamageTypeInflicted;
		UseDamageAmount = DamageAmount;
		//if(ChargeTime > 0)
		if(bCharged)
		{
			//if(ChargeTime >= 0.05)
				UseDamageType = AltDamageTypeInflicted;
				
			/*UseDamageAmount = DamageAmountMP * (ChargeTime * 5);
			
			if(UseDamageAmount > MaxDamageAmount)
				UseDamageAmount = MaxDamageAmount;
			
			// DEBUG
			//P2Player(Instigator.Controller).ClientMessage("UseDamageType"@AltDamageTypeInflicted);
			//P2Player(Instigator.Controller).ClientMessage("UseDamageAmount"@UseDamageAmount);
			
			ChargeTime = 0;	// Reset charge time
			*/
			UseDamageAmount = MaxDamageAmount;
			bCharged=False;
		}
		
		// Sever limbs first (sever people is picked in the machete weapon itself)
		if(PeoplePart(Other) != None)
		{
			Momentum = SeverMag*(-X + VRand()/2);
			if(Momentum.z<0)
				Momentum.z=-Momentum.z;
			
			Other.TakeDamage(UseDamageAmount, Pawn(Owner), HitLocation, Momentum, UseDamageType);
			//Instigator.PlayOwnedSound(MacheteHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = -MomentumHitMag*(Z/2);

				// xPatch: for doors and non-FPSPawn things still use AxeDamage
				if(FPSPawn(Other) == None)
					UseDamageType = DamageTypeInflicted;

				Other.TakeDamage(UseDamageAmount, Pawn(Owner), HitLocation, Momentum, UseDamageType);
                //Instigator.PlayOwnedSound(MacheteHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			}
		}

		if (P2MocapPawn(Other) != None)
		{
			if (P2MocapPawn(Other).MyRace < RACE_Automaton)
			{
				Instigator.PlayOwnedSound(MacheteHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				Instigator.PlaySound(MacheteHitBody, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); // Change by NickP: MP fix
			}
			else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
			{
				Instigator.PlayOwnedSound(MacheteHitBot, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				Instigator.PlaySound(MacheteHitBot, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); // Change by NickP: MP fix
			}
			else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
			{
				Instigator.PlayOwnedSound(MacheteHitSkel, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				Instigator.PlaySound(MacheteHitSkel, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); // Change by NickP: MP fix
			}
		}
		else if(FPSPawn(Other) != None
			|| PeoplePart(Other) != None)
		{
			Instigator.PlayOwnedSound(MacheteHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			Instigator.PlaySound(MacheteHitBody, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); // Change by NickP: MP fix
		}
		else
		{
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(MacheteHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else
			{
				Instigator.PlayOwnedSound(MacheteHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				Instigator.PlaySound(MacheteHitWall, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); // Change by NickP: MP fix
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

	if(HurtingAttacker(Other))
	{
		Momentum = -SeverMag*((Z/2) + VRand());

		Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
	        Instigator.PlayOwnedSound(MacheteHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
        }
}

defaultproperties
{
     MacheteHitBody=Sound'AWSoundFX.Machete.machetelimbhit'
     MacheteStab=Sound'AWSoundFX.Machete.macheteslice'
     MacheteHitWall=Sound'AWSoundFX.Machete.machetehitwall'
     MacheteHitBot=Sound'AWSoundFX.Machete.machetehitwall'
     MacheteHitSkel=Sound'AWSoundFX.Machete.machetehitwall'
     BodyDamage=Class'AxeDamage'
     SeverMag=40000.000000
     DamageAmount=50.000000
	 DamageAmountMP=100.000000
	 MaxDamageAmount=500.000000		// max damage we can reach by alt-fire charge
     MomentumHitMag=50000.000000
     DamageTypeInflicted=Class'AxeDamage'
     AltDamageTypeInflicted=Class'ScytheDamage'
     bInstantHit=True
     Texture=Texture'EDHud.hud_Axe'
     TransientSoundRadius=80.000000
}
