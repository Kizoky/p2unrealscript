//=============================================================
//   Butterfly Knife Ammo
//   Eternal Damnation
//   Dopamine
//=============================================================
class BaliAmmoInv extends InfiniteAmmoInv;

var Sound ShovelHitBody;
var Sound ShovelStab;
var Sound ShovelHitWall, ShovelHitBot, ShovelHitSkel;

const MIN_Z_MOMENTUM = 0.3;
const MIN_YAW_DIFF = 8192.0;

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
		if(FPSPawn(Other) == None
			|| HurtingAttacker(FPSPawn(Other)))
		{
			Momentum = (Y+Z)/2;
			// Ensure things go up always at least some.
			if(Momentum.z < 2*MIN_Z_MOMENTUM)
				Momentum.z = (MIN_Z_MOMENTUM*FRand()) + MIN_Z_MOMENTUM;
			Momentum = MomentumHitMag*Momentum;
			
			// Fatal damage from behind.
			if (AWPerson(Other) != None
				&& AWPerson(Other).TakesMacheteDamage == 1.0	// Don't allow if they resist machete damage
				&& AuthorityFigure(Other) == None
				&& AWAuthorityFigure(Other) == None	// Don't allow on cops, etc.
				&& Abs(Other.Rotation.Yaw - Owner.Rotation.Yaw) <= MIN_YAW_DIFF)
				Other.TakeDamage(Pawn(Other).Health, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
			else
				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
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
     DamageAmount=12.000000
     MomentumHitMag=45000.000000
     DamageTypeInflicted=Class'BaliDamage'
     AltDamageTypeInflicted=Class'BaliDamage'
     bInstantHit=True
     Texture=Texture'EDHud.hud_Bali'
     TransientSoundRadius=80.000000
}
