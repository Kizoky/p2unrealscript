///////////////////////////////////////////////////////////////////////////////
// WeedWeapon
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Functionally identical to the chainsaw. However, unlike the chainsaw, we're
// going for a bit more realism, and have it spin up to full speed when we
// start firing, then spin down again once we're done.
///////////////////////////////////////////////////////////////////////////////
class WeedWeapon extends ChainsawWeapon;

///////////////////////////////////////////////////////////////////////////////
// Properties
///////////////////////////////////////////////////////////////////////////////
var() float SpinUpTime, SpinDownTime;	// Time in seconds to spend in SpinUp and SpinDown
var() float DeltaTimeForHit;			// How much time needs to pass before we do a hit
var() StaticMesh WeedMesh;				// StaticMesh of weed actors
var() class<Emitter> WeedHitEmitter;	// Class of emitter spawned when we hit a weed actor
var() Sound WeedHitSound;				// Sound made when we hit a weed actor

///////////////////////////////////////////////////////////////////////////////
// Internal vars
///////////////////////////////////////////////////////////////////////////////
var float CurrentDeltaTimeForHit;	// How much time since the last hit
var WeedBlade MyBlade;				// Actual spinning sawblade thing
var float BladeRotationRate;		// Rotation rate of sawblade
var float BladeRotation;			// Current rotation of sawblade

const BASE_BLADE_ROTATION = 8192.0;
const MAX_BLADE_ROTATION = 327680.0;
const COMPOUND_MAP = "PL-Compound";
const WeedPath = "PLBase.PLPlayer bWeed";

///////////////////////////////////////////////////////////////////////////////
// Failsafe in case the player wastes all the gasoline on killing DEETs or
// fanatics or something. While in the compound the player will always have
// at least 1 unit of fuel left.
///////////////////////////////////////////////////////////////////////////////
function bool ShouldRunOutOfAmmo()
{
	if (InStr(Caps(Level.GetLocalURL()), Caps(COMPOUND_MAP)) > -1)
		return false;
	else
		return true;
}

///////////////////////////////////////////////////////////////////////////////
// Same as super but check if we should stay at 1 unit of fuel left.
///////////////////////////////////////////////////////////////////////////////
function bool ReduceAmmo(float DeltaTime)
{
	if (AmmoType.AmmoAmount > 1 || ShouldRunOutOfAmmo())
		Super.ReduceAmmo(DeltaTime);
}

///////////////////////////////////////////////////////////////////////////////
// Spawn and attach our blade
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	Super.PostBeginPlay();
	//MyBlade=Spawn(class'WeedBlade',Self);
	//AttachToBone(MyBlade, 'attachment_saw');
	BladeRotationRate=BASE_BLADE_ROTATION;
	
	// We have to set the weed path here too, because the first time the player gets it is through a matinee, not a pickup
	if (P2Pawn(Owner).bPlayer)
		Level.ConsoleCommand("set" @ WeedPath @ "true");
}

///////////////////////////////////////////////////////////////////////////////
// Destroy blade
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
{
	//DetachFromBone(MyBlade);
	//MyBlade.Destroy();
}
///////////////////////////////////////////////////////////////////////////////
// Rotate blade
///////////////////////////////////////////////////////////////////////////////
event Tick(float dT)
{
	local rotator R;
	local name SeqName;
	local float AnimFrame, AnimRate;
	local float DeltaSpeed;

	// DON'T call super, sending out notifies constantly was causing unwanted behavior at the Compound during the herb errand
	//Super.Tick(dT);

	// Make sure we have a blade, or this is all pointless
	//if (MyBlade == None)
		//return;	

	// Reduce blade speed based on delta time
	if (BladeRotationRate > BASE_BLADE_ROTATION)
	{
		DeltaSpeed = dT * (MAX_BLADE_ROTATION - BASE_BLADE_ROTATION) / SpinDownTime;
		BladeRotationRate -= DeltaSpeed;
		if (BladeRotationRate < BASE_BLADE_ROTATION)
			BladeRotationRate = BASE_BLADE_ROTATION;
	}

	BladeRotation = (BladeRotation - BladeRotationRate * dT) % 65536;
	R.Yaw = BladeRotation;
	SetBoneRotation('attachment_saw',R,0,1);	// Apparently you can rotate the bone by itself. Nifty
}

///////////////////////////////////////////////////////////////////////////////
// use weedwhacker anims
///////////////////////////////////////////////////////////////////////////////
simulated function PlayStreamStart()
{
	PlayAnim('Shoot1_In', WeaponSpeedPrep, 0.05);
}
simulated function PlayStreamEnd()
{
	PlayAnim('Shoot1_Out', WeaponSpeedEnd, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	IncrementFlashCount();
	// Play MP sounds on everyone's computers
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(FireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else // just on yours in SP games
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
	PlayAnim('Shoot1_Loop', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// CheckToDoHit
// Instead of causing a hit every single tick, only hit once every X times
// Also, don't hit anything if we're out of ammo (can happen during spinup/spindown)
///////////////////////////////////////////////////////////////////////////////
function bool CheckToDoHit(float DeltaTime)
{
	CurrentDeltaTimeForHit += DeltaTime;
	if (CurrentDeltaTimeForHit >= DeltaTimeForHit
		&& AmmoType.HasAmmo())
	{
		DoHit(TraceAccuracy, 0, 0);
		CurrentDeltaTimeForHit -= DeltaTimeForHit;	// instead of zeroing out, subtract the max time, so any leftover time is counted toward the next hit
		return true;
	}
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Alt-fire hit
///////////////////////////////////////////////////////////////////////////////
function Notify_AltFireHit()
{
	DoHit(TraceAccuracy, 0, 0);
	ReduceAmmo(1.0 / AmmoUseRate);
}

/*
///////////////////////////////////////////////////////////////////////////////
// Goto SpinDown instead of EndStream
///////////////////////////////////////////////////////////////////////////////
simulated function EndStreaming()
{
	//log(self$" client endstream ");
	GotoState('SpinDown');
}
function ServerEndStreaming()
{
	//log(self$" server endstream ");
	GotoState('SpinDown');
}
*/

///////////////////////////////////////////////////////////////////////////////
// We have to check for weed to do special hits and FX, so unfortunately
// this entire function must be copied over.
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Emitter weed1;
	local Rotator NewRot;
	local vector Momentum;
	local byte BlockedHit;
	local bool bHitWeed;

	if ( Other == None )
		return;

	// Check if they're allowed to hit the person they did, if not, None out Other
	// so it's like a wall hit
	if(P2MoCapPawn(Other) != None)
	{
		// Instead of using hit location, ensure the block knows it comes from the
		// attacker originally, so use the weapon's owner
		P2MoCapPawn(Other).CheckBlockMelee(Owner.Location, BlockedHit);
		if(BlockedHit == 1)
			Other = None;	// don't let them hit Other!
	}
	
	// Do special sounds and effects if we hit weed
	if (Other.StaticMesh == WeedMesh)
		bHitWeed = true;

	if(Pawn(Other) == None
		&& PeoplePart(Other) == None)
	{
		// randomly orient the splat on the wall (rotate around the normal)
		NewRot = Rotator(-HitNormal);
		NewRot.Roll=(65536*FRand());

		smoke1 = Spawn(class'Fx.SmokeHitPuffMelee',Owner,,HitLocation, Rotator(HitNormal));
		
		if (bHitWeed)
			weed1 = Spawn(WeedHitEmitter, Owner,, HitLocation, Rotator(HitNormal));
		else
		{
			if(FRand()<0.3)
			{
				dirt1 = Spawn(class'Fx.DirtClodsMachineGun',Owner,,HitLocation, Rotator(HitNormal));
			}
			if(FRand()<0.15)
			{
				spark1 = Spawn(class'Fx.SparkHitMachineGun',Owner,,HitLocation, Rotator(HitNormal));
			}
		}
	}


	if ( (Other != self) && (Other != Owner) )
	{
		// Sever limbs first (sever people is picked in the machete weapon itself)
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

				// If alt-firing and we hit a weed, does extra bonus damage
				if (bAltFiring)
					Other.TakeDamage(DamageAmount*15, Pawn(Owner), HitLocation, Momentum, BodyDamage);
				else
					Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, BodyDamage);
			}
		}

		if(FPSPawn(Other) != None
			|| PeoplePart(Other) != None)
		{
			Instigator.PlayOwnedSound(BodySound[Rand(BodySound.Length)], SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
		else if (bHitWeed)
		{
			if (weed1 != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				weed1.PlaySound(WeedHitSound, SLOT_None, 1.0,, TransientSoundRadius, GetRandPitch());
			else
				Instigator.PlayOwnedSound(WeedHitSound, SLOT_None, 1.0,, TransientSoundRadius, GetRandPitch());
		}
		else
		{
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(HitWallSound, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else
				Instigator.PlayOwnedSound(HitWallSound, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// StartStream
// Go to SpinUp instead of Streaming, so we can gradually "spin up" the blade
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StartStream
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		//log(self$" going to streaming");
		GotoState('SpinUp');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// SpinUp
// We're firing, but gradually spinning up the blade to full.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SpinUp extends Streaming
{
	///////////////////////////////////////////////////////////////////////////////
	// Play firing animation
	///////////////////////////////////////////////////////////////////////////////
	simulated function PlayFiring()
	{
		IncrementFlashCount();
		PlayAnim('Shoot1_Loop', WeaponSpeedShoot1, 0.05);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set to seeking when you get to this state
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		BladeRotationRate=BASE_BLADE_ROTATION;
		PlayFiring();
	}
	
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event Tick(float DeltaTime)
	{
		local name SeqName;
		local float AnimFrame, AnimRate;
		local float DeltaSpeed;
		
		// Global crap
		Global.Tick(DeltaTime);
		
		// Raise weapon speed based on delta time
		DeltaSpeed = DeltaTime * (MAX_BLADE_ROTATION - BASE_BLADE_ROTATION) / SpinUpTime;
		BladeRotationRate += DeltaSpeed;
		
		// At full speed, go to Firing state.
		if (BladeRotationRate >= MAX_BLADE_ROTATION)
		{
			BladeRotationRate = MAX_BLADE_ROTATION;
			GotoState('Streaming');	
		}
		else
		{			
			// Possibly cause a hit. Use the weapon speed here so we drain and hit slower during spinup
			ReduceAmmo(DeltaTime * ((BladeRotationRate - BASE_BLADE_ROTATION) / (MAX_BLADE_ROTATION - BASE_BLADE_ROTATION)));
			CheckToDoHit(DeltaTime * ((BladeRotationRate - BASE_BLADE_ROTATION) / (MAX_BLADE_ROTATION - BASE_BLADE_ROTATION)));
		}
		// Stop streaming if, at any time, the player lets go of Fire (don't check just on AnimEnd)
		if(!Instigator.PressingFire() || !AmmoType.HasAmmo())
		{
			EndStreaming();
			ServerEndStreaming();
		}		
	}

	///////////////////////////////////////////////////////////////////////////////
	// Skip turning off the sound, SpinDown will do that.
	///////////////////////////////////////////////////////////////////////////////
	simulated function EndState()
	{
		// Reset instigator's sound pitch
		//Instigator.SoundPitch = 1.0;
	}
Begin:
	if(!bDelayedStartSound)
		Instigator.AmbientSound = soundLoop1;
	else
	{
		Instigator.PlaySound(soundStart, SLOT_None, 1.0, false, 1000.0, 1.0);
		Sleep(Instigator.GetSoundDuration(soundStart));
		Instigator.AmbientSound = soundLoop1;
	}
	//Instigator.SoundPitch = CurrentWeaponSpeed;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Streaming
// 'Fire' this weapon in a looping fashion, till it's done
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Streaming
{
	///////////////////////////////////////////////////////////////////////////////
	// Skip turning off the sound, SpinDown will do that.
	///////////////////////////////////////////////////////////////////////////////
	simulated function EndState()
	{
		// Reset instigator's sound pitch
		//Instigator.SoundPitch = 1.0;
	}
	simulated function BeginState()
	{
		Instigator.AmbientSound = SoundLoop1;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event Tick(float Delta)
	{
		Global.Tick(Delta);
		BladeRotationRate = MAX_BLADE_ROTATION;
		ReduceAmmo(Delta);
		CheckToDoHit(Delta);
		// Stop streaming if, at any time, the player lets go of Fire (don't check just on AnimEnd)
		if(!Instigator.PressingFire() || !AmmoType.HasAmmo())
		{
			EndStreaming();
			ServerEndStreaming();
		}		
	}
// Null out the sound crap, that's handled in SpinUp
Begin:
}
/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// SpinDown
// No longer firing, but spin down the blade speed
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SpinDown extends Idle
{
	///////////////////////////////////////////////////////////////////////////////
	// Play idle when the animation ends
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		PlayIdleAnim();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set to seeking when you get to this state
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		//CurrentWeaponSpeed = WeaponSpeedShoot1;
		//Instigator.AmbientSound = IdleSound;
		Super.BeginState();
		PlayStreamEnd();
	}
	
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event Tick(float DeltaTime)
	{
		local name SeqName;
		local float AnimFrame, AnimRate;
		local float DeltaSpeed;
		
		// Global crap
		Global.Tick(DeltaTime);
		
		// Reduce blade speed based on delta time
		DeltaSpeed = DeltaTime * (MAX_BLADE_ROTATION - BASE_BLADE_ROTATION) / SpinDownTime;
		BladeRotationRate -= DeltaSpeed;
		
		// At full speed, go to Firing state.
		if (BladeRotationRate <= BASE_BLADE_ROTATION)
		{
			BladeRotationRate = BASE_BLADE_ROTATION;
			//GotoState('Idle');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Turn off the sound
	///////////////////////////////////////////////////////////////////////////////
	simulated function EndState()
	{
		Super.EndState();
		//Instigator.AmbientSound = None;
		// Reset instigator's sound pitch
		//Instigator.SoundPitch = 1.0;
	}
// skip the sound crap, SpinUp handles that
//Begin:
}
*/

/*
simulated event RenderOverlays(Canvas Canvas) {
    local int i;
    local float CanvasScale;
    local vector HeadDrawPos;

    super.RenderOverlays(Canvas);

    Canvas.Style = 1;
    Canvas.Font = Font'P2Fonts.Fancy24';
    Canvas.SetDrawColor(255, 0, 0, 255);

    CanvasScale = Canvas.ClipY / 768;

    Canvas.SetPos(0, 0);
    Canvas.DrawText("Blade Rotation / RotationRate: " $ BladeRotation $ "/" $ BladeRotationRate);
}
*/

///////////////////////////////////////////////////////////////////////////////
// Set first person hands texture
///////////////////////////////////////////////////////////////////////////////
simulated function ChangeHandTexture(Texture NewHandsTexture, Texture DefHandsTexture, Texture NewFootTexture)
{
	Skins[1] = NewHandsTexture;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PickupClass=class'WeedPickup'
	Mesh=SkeletalMesh'PLWeedwhackerMESH.pl_weedwhacker'
	Skins[1]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins[0]=Texture'PLWeedwhackerTEX.WeedBuddy_Diff'
	InventoryGroup=5
	GroupOffset=96
	WeaponSpeedLoad=1.0
	WeaponSpeedHolster=1.0
	WeaponSpeedShoot1Rand=0.0
	WeaponSpeedPrep=1.0
	WeaponSpeedEnd=1.0
	WeaponSpeedShoot1=1.0
	SpinUpTime=0.75
	SpinDownTime=2.0
	DeltaTimeForHit=0.05
	bUsesAltFire=true
	AttachmentClass=Class'WeedAttachment'
	holdstyle=WEAPONHOLDSTYLE_Melee
	switchstyle=WEAPONHOLDSTYLE_Melee
	firingstyle=WEAPONHOLDSTYLE_Melee
	ThirdPersonRelativeRotation=(Pitch=34000,Yaw=8000,Roll=26000)
	ThirdPersonRelativeLocation=(X=24,Y=-18,Z=-20)

	SelectSound=Sound'PL_WeedWhackerSounds.weed_select'
	HolsterSound=Sound'PL_WeedWhackerSounds.weed_holster'
	SoundStart=Sound'PL_WeedWhackerSounds.weed_streamstart'
	SoundLoop1=Sound'PL_WeedWhackerSounds.weed_streamloop'
	SoundEnd=Sound'PL_WeedWhackerSounds.weed_streamend'
	AltFireSound=Sound'PL_WeedWhackerSounds.weed_altfire'
	IdleSound=Sound'PL_WeedWhackerSounds.weed_idle'
	HitWallSound=Sound'AWSoundFX.Machete.macheterichochet'
	BodySound(0)=Sound'Slawterhaus.BoneRip01'
	BodySound(1)=Sound'Slawterhaus.BoneRip02'
	BodySound(2)=Sound'Slawterhaus.BoneRip03'
	
	OverrideHUDIcon=Texture'MrD_PL_Tex.HUD.WeedHUD'
	ItemName="Weed Whacker"
	WeedMesh=StaticMesh'PL_tylermesh2.Compound_GREEN.weed_plant'
	WeedHitSound=Sound'LevelSoundsToo.Bush.bush04'
	WeedHitEmitter=class'WeedShredEmitter'
}
