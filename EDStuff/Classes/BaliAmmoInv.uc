//============================================================================================
//   Butterfly Knife Ammo
//   by Man Chrzan, for xPatch 2.5
//
//   Completly rewritten, fixed sounds, stab from behind now uses StabDamageAmount instead    
//   of killing everyone (even some bosses) except AuthorityFigures.
//============================================================================================
class BaliAmmoInv extends InfiniteAmmoInv;

const MIN_Z_MOMENTUM = 0.3;
const MIN_YAW_DIFF = 8192.0;

var Sound FleshHit;
var Sound StabHit;
var Sound BotHit;
var Sound SkelHit;

var float FleshRad;
var float StabDamageAmount;

///////////////////////////////////////////////////////////////////////////////////////////////////
// New ProcessTraceHit with correctly working stab sound
///////////////////////////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Rotator NewRot;
	local vector Momentum;
	local bool StabFromBehind;
	local float GetDamageAmount;

	if ( Other == None )
		return;

	if(Other.bStatic)
	{
		spawn(class'Fx.SmokeHitPuffMelee',Owner, ,HitLocation, Rotator(HitNormal));
		Instigator.PlaySound(BotHit, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); 
	}
	else 
	{
		Momentum = (Y+Z)/2;
		// Ensure things go up always at least some.
		if(Momentum.z < 2*MIN_Z_MOMENTUM)
			Momentum.z = (MIN_Z_MOMENTUM*FRand()) + MIN_Z_MOMENTUM;
		Momentum = MomentumHitMag*Momentum;

		// Check for nape stab.
		if (AWPerson(Other) != None
			&& AWPerson(Other).TakesMacheteDamage == 1.0	// Don't allow if they resist machete damage
			&& AWPerson(Other).Health > 0					// Alive 
			&& Abs(Other.Rotation.Yaw - Owner.Rotation.Yaw) <= MIN_YAW_DIFF)
		StabFromBehind=true;
			
		if(StabFromBehind)	// Fatal damage from behind.
			GetDamageAmount = StabDamageAmount;	
		else if (P2Weapon(W).bAltFiring) // Alt-Firing - deal less damage but attack faster.
			GetDamageAmount = AltDamageAmount;
		else // Normal damage
			GetDamageAmount = DamageAmount;
		
		Other.TakeDamage(GetDamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
			
		if(StabFromBehind)
		{
			// They are dead now, tell the gamestate
			if(AWPerson(Other).Health <= 0 && Instigator.Controller.bIsPlayer)
				P2GameInfoSingle(Level.Game).TheGameState.BaliStabs++;
		}

		if (P2MocapPawn(Other) != None)
		{
			if (P2MocapPawn(Other).MyRace < RACE_Automaton)
			{
				if(StabFromBehind)	// Play special sound for it
					Instigator.PlaySound(StabHit, SLOT_Pain, 1.5,,FleshRad,GetRandPitch()); 
				else
					Instigator.PlaySound(FleshHit,SLOT_Pain,,,FleshRad,GetRandPitch()); 
			}
			else if (P2MocapPawn(Other).MyRace == RACE_Automaton)
				Instigator.PlaySound(BotHit, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); 
			else if (P2MocapPawn(Other).MyRace == RACE_Skeleton)
				Instigator.PlaySound(SkelHit, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch()); 
				
			if (Pawn(Other) != None
				&& (P2MocapPawn(Other) == None
				|| P2MocapPawn(Other).MyRace < RACE_Automaton))
				P2BloodWeapon(W).DrewBlood();
		}
		else if((Pawn(Other) != None && Other != Owner)
			|| PeoplePart(Other) != None
			|| CowheadProjectile(Other) != None)
		{
			Instigator.PlaySound(FleshHit,SLOT_Pain,,,FleshRad,GetRandPitch()); 
		}
		else if(Other.IsA('Mover') || Other.IsA('KActor'))
		{
			Instigator.PlaySound(BotHit, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch());
			spawn(class'Fx.SmokeHitPuffMelee',W.Owner, ,HitLocation, Rotator(HitNormal));			
		}
		else // anything else--make a hit puff
		{
			spawn(class'Fx.SmokeHitPuffMelee',W.Owner, ,HitLocation, Rotator(HitNormal));
		}
	}
}

defaultproperties
{
     DamageAmount=20.000000 
	 AltDamageAmount=12.000000
     MomentumHitMag=45000.000000
     DamageTypeInflicted=Class'BaseFX.BaliDamage'
     AltDamageTypeInflicted=Class'BaseFX.BaliDamage'
     bInstantHit=True
     Texture=Texture'EDHud.hud_Bali'
     TransientSoundRadius=80.000000
	 
	 FleshRad=200
	 FleshHit=Sound'AWSoundFX.Machete.limbcut1'
	 StabHit=Sound'AWSoundFX.Machete.macheteslice'
	 BotHit=Sound'AWSoundFX.Machete.macheterichochet'
	 SkelHit=Sound'AWSoundFX.Machete.macheterichochet'
	 
	 StabDamageAmount=300
}
