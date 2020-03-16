///////////////////////////////////////////////////////////////////////////////
// Sledgehammer ammo and hurting things
///////////////////////////////////////////////////////////////////////////////
class SledgeAmmoInv extends InfiniteAmmoInv;

var Sound SledgeHitBody;
var Sound SledgeStab;
var Sound SledgeHitWall;
var Sound SledgeHitBot;
var Sound SledgeHitSkel;
var class<DamageType> BodyDamage;	// damaged caused when we hit the body instead of a limb

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

		smoke1 = Spawn(class'SmokeHitPuffSledge',Owner,,HitLocation, Rotator(HitNormal));

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
		// smash people and things with the sledge
		if(PeoplePart(Other) != None)
		{
			Momentum = MomentumHitMag*(-X + VRand()/2);
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

				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
			}
		}

		if (P2MocapPawn(Other) != None)
		{
			if (P2MocapPawn(Other).MyRace < RACE_Automaton)
				Instigator.PlayOwnedSound(SledgeHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
				Instigator.PlayOwnedSound(SledgeHitBot, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
				Instigator.PlayOwnedSound(SledgeHitSkel, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
		else if(FPSPawn(Other) != None
			|| PeoplePart(Other) != None)
		{
			Instigator.PlayOwnedSound(SledgeHitBody, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
		else
		{
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(SledgeHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else
				Instigator.PlayOwnedSound(SledgeHitWall, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
	}
}

defaultproperties
{
     SledgeHitBody=Sound'AWSoundFX.Sledge.hammersmashbody'
     SledgeStab=Sound'AWSoundFX.Sledge.hammersmashbody'
     SledgeHitWall=Sound'AWSoundFX.Sledge.hammerhitwall_metalhit'
     SledgeHitBot=Sound'AWSoundFX.Sledge.hammerhitwall_metalhit'
     SledgeHitSkel=Sound'AWSoundFX.Sledge.hammerhitwall_metalhit'
     DamageAmount=100.000000
     MomentumHitMag=50000.000000
     DamageTypeInflicted=Class'SledgeDamage'
     AltDamageTypeInflicted=Class'FlyingSledgeDamage'
     bInstantHit=True
     Texture=Texture'AWHUD.Icons.Sledge_Icon'
     TransientSoundRadius=80.000000
}
