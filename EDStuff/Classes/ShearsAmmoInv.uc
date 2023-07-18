//=============================================================
//   Hedge Clippers Ammo
//   Eternal Damnation
//   Dopamine|Silent-Scope
//=============================================================
class ShearsAmmoInv extends MacheteAmmoInv;

var Sound ShovelHitBody;
var Sound ShovelStab;
var Sound ShovelHitWall;
var Sound ShovelHitBot, ShovelHitSkel;

const MIN_Z_MOMENTUM = 0.3;

// xPatch: 
var class<DamageType> LowerDamageTypeInflicted;

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

				// Use weaker damage type if the damage amount is not enough to kill them.
				if (PersonPawn(Other) != None && PersonPawn(Other).Health > DamageAmount && AWZombie(Other) == None)
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, LowerDamageTypeInflicted);
				else
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
            }                     
		}
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = MomentumHitMag*X + MomentumHitMag*vect(0, 0, 1.0)*FRand();
				
				// Use weaker damage type if the damage amount is not enough to kill them.
				if (PersonPawn(Other) != None && PersonPawn(Other).Health > DamageAmount 
					&& AWZombie(Other) == None || Other.IsA('DoorMover'))
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, LowerDamageTypeInflicted);
				else
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, AltDamageTypeInflicted);
			}
		}

		if(FPSPawn(Other) != None)
		{
			if(P2Weapon(W).bAltFiring)
			{
				if (P2MocapPawn(Other) != None)
				{
					if (P2MocapPawn(Other).MyRace < RACE_Automaton)
						Instigator.PlaySound(ShovelStab, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
					else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
						Instigator.PlaySound(ShovelHitBot, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
					else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
						Instigator.PlaySound(ShovelHitSkel, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				}
			}
			else if (P2MocapPawn(Other) != None)
			{
				if (P2MocapPawn(Other).MyRace < RACE_Automaton)
					Instigator.PlaySound(ShovelHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
					Instigator.PlaySound(ShovelHitBot, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
					Instigator.PlaySound(ShovelHitSkel, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			}
			else if(AnimalPawn(Other) != None
				|| FPSPawn(Other).Health <= 0)
				Instigator.PlaySound(ShovelHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				//Instigator.PlayOwnedSound(ShovelHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
		else
		{
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(ShovelHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else
			    Instigator.PlaySound(ShovelHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
				//Instigator.PlayOwnedSound(ShovelHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
	}
}

defaultproperties
{
     ShovelHitBody=Sound'AWSoundFX.Machete.machetelimbhit'
     ShovelStab=Sound'AWSoundFX.Machete.macheteslice'
     ShovelHitWall=Sound'AWSoundFX.Machete.machetehitwall'
     ShovelHitBot=Sound'AWSoundFX.Machete.machetehitwall'
     ShovelHitSkel=Sound'AWSoundFX.Machete.machetehitwall'
     DamageAmount=80 //25
	 DamageAmountMP=160 //50.000000
     MomentumHitMag=20000.000000
     DamageTypeInflicted=Class'MacheteDamage'
	 AltDamageTypeInflicted=Class'SledgeDamage'		//Was ShotGunDamage	
	 LowerDamageTypeInflicted=Class'CuttingDamage'
     bInstantHit=True
     Texture=Texture'EDHud.hud_Shears'
     TransientSoundRadius=80.000000
}
