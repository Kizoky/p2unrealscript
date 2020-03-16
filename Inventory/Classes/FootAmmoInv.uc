///////////////////////////////////////////////////////////////////////////////
// Foot ammo
///////////////////////////////////////////////////////////////////////////////

class FootAmmoInv extends InfiniteAmmoInv;

var Sound	FootKickWall;
var Sound	FootKickGuy;
var Sound	FootKickDoor;

const MIN_Z_MOMENTUM	=	0.25;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local float UseMom, UseDamage, OldHealth;
	local vector Momentum;

	if ( Other == None )
		return;
		
	// Skip on emitters and etc
	if (Emitter(Other) != None
		|| Keypoint(Other) != None)
		return;
		
	// Kamek 4-30 boottothehead
	if (Other.IsA('Head')
		&& Pawn(Owner) != None
		&& PlayerController(Pawn(Owner).Controller) != None)
		{
		if(Level.NetMode != NM_DedicatedServer ) PlayerController(Pawn(Owner).Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Pawn(Owner).Controller),'KickSeveredHead');
		}

	if(Pawn(Other) == None)
	{
		// randomly orient the splat on the wall (rotate around the normal)
		NewRot = Rotator(-HitNormal);
		NewRot.Roll=(65536*FRand());

		smoke1 = Spawn(class'Fx.SmokeHitPuffMelee',Owner,,HitLocation,rotator(HitNormal));
		if(FRand()<0.3
			&& Other.bStatic)
		{
			dirt1 = Spawn(class'Fx.DirtClodsMachineGun',Owner,,HitLocation);
			dirt1.FitToNormal(HitNormal);
		}
	}


	if ( (Other != self) && (Other != Owner) ) 
	{
		// If we're jumping, deliver more damage, and have more range
		// for extra-strong flying karate kicks!
		if(Instigator.Physics == PHYS_Falling)
		{
			UseMom = 2*MomentumHitMag;
			UseDamage = 2*DamageAmount;
		}
		// Have the kick strength if he's crouched
		else if(Instigator.bIsCrouched)
		{
			UseMom = MomentumHitMag/3;
			UseDamage = DamageAmount/3;
		}
		else
		{
			UseMom = MomentumHitMag;
			UseDamage = DamageAmount;
		}

		// Kicking a door open
		if(SplitMover(Other) != None)
		{
			// Record how many times you kick doors in
			if(P2GameInfoSingle(Level.Game) != None
				&& P2GameInfoSingle(Level.Game).TheGameState != None
				&& P2Pawn(Instigator) != None
				&& P2Pawn(Instigator).bPlayer)
			{
				P2GameInfoSingle(Level.Game).TheGameState.DoorsKicked++;
				if(Level.NetMode != NM_DedicatedServer ) PlayerController(Instigator.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Instigator.Controller),'DoorKick');
			}

			SplitMover(Other).KickedIn(Instigator);
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(FootKickDoor, , 1.0,,TransientSoundRadius,GetRandPitch());
			else
			{
				Instigator.PlaySound(FootKickDoor, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch());
				Instigator.PlayOwnedSound(FootKickDoor, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch());
			}
		}
		// You've kicked something (other than a door)--send it in the direction aimed
		// Plus make it go more forward, sort of like a football kick
		else
		{
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(FootKickWall, , 1.0,,TransientSoundRadius,GetRandPitch());
			else
			{
				Instigator.PlaySound(FootKickWall, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch());
				Instigator.PlayOwnedSound(FootKickWall, SLOT_Misc, 1.0,,TransientSoundRadius,GetRandPitch());
			}

			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = (X+Z)/2;
				// Ensure things go up always at least some.
				if(Momentum.z < 2*MIN_Z_MOMENTUM)
					Momentum.z = (MIN_Z_MOMENTUM*FRand()) + MIN_Z_MOMENTUM;
				Momentum = UseMom*Momentum;
				if (Pawn(Other) != None)
					OldHealth = Pawn(Other).Health;
				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
				// If we hit a pawn make the weapon a little bloody
				if (Pawn(Other) != None
					&& (P2MocapPawn(Other) != None
					|| P2MocapPawn(Other).MyRace < RACE_Automaton))
					P2BloodWeapon(W).DrewBlood();
				// Kamek 5-1
				// If this damage killed them and we're jumping, CHUCK NORRIS BITCH
				if (P2MoCapPawn(Other) != None
					&& P2MoCapPawn(Other).Health <= 0
					&& OldHealth > 0
					&& PlayerController(Pawn(Owner).Controller) != None
					&& Instigator.Physics == PHYS_FALLING)
				{
					//log("Killed Pawn"@Pawn(Other)@"with a boot to the head",'Debug');
					if(Level.NetMode != NM_DedicatedServer ) PlayerController(Pawn(Owner).Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Pawn(Owner).Controller),'BootTotheHead');					
				}
			}
		}
	}
}

defaultproperties
{
	DamageAmount=3
	bInstantHit=true
	Texture=None
	DamageTypeInflicted=class'KickingDamage'
	MomentumHitMag=120000
	FootKickWall=Sound'WeaponSounds.Foot_KickWall'
	FootKickDoor=Sound'WeaponSounds.Foot_KickDoor'
	TransientSoundRadius=80
	//bCannotBeStolen=true
}