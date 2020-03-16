///////////////////////////////////////////////////////////////////////////////
// Foot ammo
///////////////////////////////////////////////////////////////////////////////

class MightyFootAmmoInv extends InfiniteAmmoInv;

var Sound	FootKickWall;
var Sound	FootKickGuy;
var Sound	FootKickDoor;

const MIN_Z_MOMENTUM	=	0.25;

///////////////////////////////////////////////////////////////////////////////
// Spawns THREE heads and sends them flying (enhanced mode only)
///////////////////////////////////////////////////////////////////////////////
function PopTheirHeadOff(P2MoCapPawn Victim, vector HitLocation, vector Momentum)
{
	local PoppedHeadEffects headeffects;
	local P2Emitter HeadBloodTrail;			// Blood trail I drip if I'm detached.
	local int i;
	local PersonPawn PVict;
	const MAX_HEADS = 3;

	// Create blood from neck hole	
	if (PersonPawn(Victim) != None)
	{
		PVict = PersonPawn(Victim);
		if(PVict.FluidSpout == None
			&& P2GameInfo(Level.Game).AllowBloodSpouts())
		{
			// If we're puking at the time our head goes away, then
			// keep puke going out the neckhole
			if(Head(PVict.MyHead).PukeStream != None)
			{
				PVict.FluidSpout = spawn(class'PukePourFeeder',PVict,,Location);
				// Make it the same type of puke
				PVict.FluidSpout.SetFluidType(Head(PVict.MyHead).PukeStream.MyType);
			}
			else// If our head is removed while not puking, then make blood squirt out
				PVict.FluidSpout = spawn(class'BloodSpoutFeeder',PVict,,Location);

			PVict.FluidSpout.MyOwner = self;
			PVict.FluidSpout.SetStartSpeeds(100, 10.0);
			PVict.AttachToBone(PVict.FluidSpout, PVict.BONE_HEAD);
			PVict.SnapSpout(true);
		}
	}

	for (i=0; i<MAX_HEADS; i++)
	{
		if (Victim.MyHead == None)
			Victim.SetupHead();

		// Pop off the head
		Victim.DetachFromBone(Victim.MyHead);

		// Get it ready to fly
		Head(Victim.MyHead).StopPuking();
		Head(Victim.MyHead).StopDripping();
		Victim.MyHead.SetupAfterDetach();
		// Make a blood drip effect come out of the head
		HeadBloodTrail = Spawn(class'BloodChunksDripping ',Victim);
		HeadBloodTrail.Emitters[0].RespawnDeadParticles=false;
		HeadBloodTrail.SetBase(Victim);

		Victim.MyHead.GotoState('Dead');

		// Send it flying
		Victim.MyHead.GiveMomentum(Momentum);

		// Make some blood mist where it hit
		headeffects = spawn(class'PoppedHeadEffects',,,HitLocation);
		headeffects.SetRelativeMotion(Momentum, Velocity);

		//Remove connection to head but don't destroy it
		Victim.DissociateHead(false);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local float UseMom, UseDamage;
	local vector Momentum;
	local float PercentUpBody;
	local int OutDamage;

	if ( Other == None )
		return;

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
		//
		UseMom = 4*UseMom;
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
				Other.TakeDamage(UseDamage, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);

				PercentUpBody = (HitLocation.Z - Other.Location.Z) / Other.CollisionHeight;

				// Critical Hit chance: Blows off head and all limbs on a critical hit
				// But don't do it if they're already beheaded/belimbed
				if (FRand() <= 0.1
					&& AWPerson(Other) != None
					&& P2Pawn(Other).bHasHead
					&& P2Pawn(Other).bHeadCanComeOff
					&& P2MoCapPawn(Other).MyHead != None)
				{
					// we can pass in UseDamage because we're done with it
					AWPerson(Other).BlowOffHeadAndLimbs(Pawn(Owner), Momentum, OutDamage);
					if (PlayerController(Pawn(Owner).Controller) != None)
						PlayerController(Pawn(Owner).Controller).ClientMessage("CRITICAL HIT!"); // cheesy but effective
				}
				// If this kills them, or it's a zombie, take off the head
				else If (P2MoCapPawn(Other) != None
					&& P2Pawn(Other).bHasHead
					&& P2Pawn(Other).bHeadCanComeOff
					&& (Pawn(Other).Health <= 0 || AWZombie(Other) != None)
					&& P2MoCapPawn(Other).MyHead != None
					&& PercentUpBody > P2Pawn(Other).HEAD_RATIO_OF_FULL_HEIGHT)
				{
					// knock off the head
					if (P2GameInfoSingle(Level.Game) != None && P2GameInfoSingle(Level.Game).VerifySeqTime() && Pawn(Owner).Controller.bIsPlayer)
						PopTheirHeadOff(P2MoCapPawn(Other), HitLocation, Momentum);
					else
						P2MoCapPawn(Other).PopOffHead(HitLocation, Momentum);
				}
			}
		}
	}
}

defaultproperties
{
	DamageAmount=3000
	bInstantHit=true
	Texture=None
	DamageTypeInflicted=class'KickingDamage'
	MomentumHitMag=120000
     FootKickWall=Sound'WeaponSounds.foot_kickwall'
//	FootKickWall=Sound'AW7Sounds.MightyFoot.Thunk'
	FootKickDoor=Sound'WeaponSounds.Foot_KickDoor'
	TransientSoundRadius=80
}