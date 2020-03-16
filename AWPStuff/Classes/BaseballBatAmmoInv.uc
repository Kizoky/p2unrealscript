///////////////////////////////////////////////////////////////////////////////
// Baseball ammo
///////////////////////////////////////////////////////////////////////////////
class BaseballBatAmmoInv extends ShovelAmmoInv;

///////////////////////////////////////////////////////////////////////////////
// Public vars
///////////////////////////////////////////////////////////////////////////////
var() sound BatCrack;	// "Crack" sound made when contacting something hard, like a wall or a skull
var() sound BatSmash;	// Smash sound made when contacting something like a body

var() float AltMomentumHitMag; // Alt-fire momentum hit mag

///////////////////////////////////////////////////////////////////////////////
// Spawns THREE heads and sends them flying (enhanced mode only)
///////////////////////////////////////////////////////////////////////////////
function PopTheirHeadOff(PersonPawn Victim, vector HitLocation, vector Momentum)
{
	local PoppedHeadEffects headeffects;
	local P2Emitter HeadBloodTrail;			// Blood trail I drip if I'm detached.
	local int i;
	const MAX_HEADS = 3;

	// Create blood from neck hole
	if(Victim.FluidSpout == None
		&& P2GameInfo(Level.Game).AllowBloodSpouts())
	{
		// If we're puking at the time our head goes away, then
		// keep puke going out the neckhole
		if(Head(Victim.MyHead).PukeStream != None)
		{
			Victim.FluidSpout = spawn(class'PukePourFeeder',Victim,,Location);
			// Make it the same type of puke
			Victim.FluidSpout.SetFluidType(Head(Victim.MyHead).PukeStream.MyType);
		}
		else// If our head is removed while not puking, then make blood squirt out
			Victim.FluidSpout = spawn(class'BloodSpoutFeeder',Victim,,Location);

		Victim.FluidSpout.MyOwner = self;
		Victim.FluidSpout.SetStartSpeeds(100, 10.0);
		Victim.AttachToBone(Victim.FluidSpout, Victim.BONE_HEAD);
		Victim.SnapSpout(true);
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
// process a trace hitting something
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local vector Momentum;
	//local BaseballBatJingleMaker Jingler;
	local float PercentUpBody;
	local PersonController perc;
	local bool bDoAlt;
	local byte BlockedHit;
	local TeamRocketizer BlastingOffAgain;

	if (Other == None)
		return;

	// Check if they're allowed to hit the person they did, if not, None out Other
	// so it's like a wall hit
	if(P2MoCapPawn(Other) != None)
	{
		if(W != None
			&& W.Owner != None)
		{
			// Instead of using hit location, ensure the block knows it comes from the
			// attacker originally, so use the weapon's owner
			P2MoCapPawn(Other).CheckBlockMelee(W.Owner.Location, BlockedHit);
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
		perc = PersonController(Instigator.Controller);

        bDoAlt = False;
		if (P2Weapon(W).bAltFiring)
			bDoAlt = True;

		if(perc != None
			&& perc.Target != None)
		{
			if(perc.MyPawn.bAdvancedFiring)
				bdoAlt=true;
		}

		if(!bDoAlt)
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = (-Y+Z)/2;
				// Ensure things go up always at least some.
				if(Momentum.z < 2*MIN_Z_MOMENTUM)
					Momentum.z = (MIN_Z_MOMENTUM*FRand()) + MIN_Z_MOMENTUM;
				Momentum = MomentumHitMag*Momentum;

				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);

				// If we hit a pawn make the weapon a little bloody
				if ((W.Class == class'BaseballBatWeapon')
					&& Pawn(Other) != None
					&& (P2MocapPawn(Other) == None
					|| P2MocapPawn(Other).MyRace < RACE_Automaton))
					P2BloodWeapon(W).DrewBlood();
			
				PercentUpBody = (HitLocation.Z - Other.Location.Z) / Other.CollisionHeight;

				// If this kills them, or it's a zombie, take off the head
				If (PersonPawn(Other) != None
					&& P2Pawn(Other).bHasHead
					&& P2Pawn(Other).bHeadCanComeOff
					&& (Pawn(Other).Health <= 0 || AWZombie(Other) != None)
					&& PersonPawn(Other).MyHead != None
					&& PercentUpBody > P2Pawn(Other).HEAD_RATIO_OF_FULL_HEIGHT)
				{
					// play a nice "crack"
					PersonPawn(Other).MyHead.PlaySound(BatCrack, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());

					// set up the stupid jingler
					//Jingler = spawn(class'BaseballBatJingleMaker', Instigator,, PersonPawn(Other).MyHead.Location);
					//Jingler.SetupFor(PersonPawn(Other).MyHead);

					// knock off the head
					if (P2GameInfoSingle(Level.Game) != None && P2GameInfoSingle(Level.Game).VerifySeqTime() && Pawn(Owner).Controller.bIsPlayer)
						PopTheirHeadOff(PersonPawn(Other), HitLocation, Momentum);
					else
						PersonPawn(Other).PopOffHead(HitLocation, Momentum);

					// Tell the gamestate
					if (Instigator.Controller.bIsPlayer)
						P2GameInfoSingle(Level.Game).TheGameState.BaseballHeads++;
				}
			}
			/*
			else if (AW7Head(Other) != None)
			{
				Jingler = spawn(class'BaseballBatJingleMaker', Instigator,, Other.Location);
				Jingler.SetupFor(Other);
			}
			*/
		}
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = AltMomentumHitMag*X + AltMomentumHitMag*vect(0, 0, 1.0)*FRand();
				// Send things comically airborne in Enhanced game, if this kills them
				if (P2GameInfoSingle(Level.Game).VerifySeqTime() && AWPerson(Other) != None && AWPerson(Other).TakesSledgeDamage == 1)
				{
					Momentum.Z += 250000;
					Momentum *= 3;
				}
				Other.TakeDamage(AltDamageAmount, Pawn(Owner), HitLocation, Momentum, AltDamageTypeInflicted);
				if (P2GameInfoSingle(Level.Game).VerifySeqTime() && AWPerson(Other) != None && AWPerson(Other).TakesSledgeDamage == 1)
				{
					BlastingOffAgain = Spawn(class'TeamRocketizer',Owner,,Other.Location,Owner.Rotation + rot(16384,0,0));
					BlastingOffAgain.SetupShot();
					BlastingOffAgain.ProcessTouch(Other, Other.Location);
				}
			}
		}

		if(FPSPawn(Other) != None)
		{
			if(bDoAlt)				
				Instigator.PlaySound(BatCrack, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else if (P2MocapPawn(Other) == None || P2MocapPawn(Other).MyRace < RACE_Automaton)
				Instigator.PlaySound(BatSmash, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else
				Instigator.PlaySound(BatCrack, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
					
		}
		else
		{
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(BatCrack, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else
				Instigator.PlaySound(BatCrack, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	BatCrack=Sound'AW7Sounds.MiscWeapons.BatWalll'
	BatSmash=Sound'AWSoundFX.Sledge.hammersmashbody'
	MomentumHitMag=480000.000000
	AltMomentumHitMag=120000.000000
	DamageAmount=80
	AltDamageAmount=40
	DamageTypeInflicted=Class'BludgeonDamage'
	AltDamageTypeInflicted=Class'BaseballBatDamage'
	Texture=Texture'EDHud.hud_WoodenBat'
}