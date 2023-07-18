///////////////////////////////////////////////////////////////////////////////
// MolotovWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Molotovs that you throw.
//
///////////////////////////////////////////////////////////////////////////////

class MolotovWeapon extends GrenadeWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
// Set here that we want to reload after each throw
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	Super.PlayFiring();
	bForceReload=true;
}
simulated function PlayAltFiring()
{
	Super.PlayAltFiring();
	bForceReload=true;
}

///////////////////////////////////////////////////////////////////////////////
// Normal projectile fire, plus check where to make the danger marker to 
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function ProjectileFire()
{
	// STUB
}
///////////////////////////////////////////////////////////////////////////////
// Normal projectile fire, plus check where to make the danger marker to 
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function ProjectileAltFire()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// WE don't throw grenades
///////////////////////////////////////////////////////////////////////////////
function ThrowGrenade()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_ThrowMolotov()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local MolotovProjectile molot;
	
	if(P2AmmoInv(AmmoType) != None
		&& AmmoType.HasAmmo())
	{
		CalcAIChargeTime();
		// Alt-firing the grenade, drops it at your feet, and doesn't
		// arm it
		if(bAltFiring)
		{
			ChargeTime = 0.0;
			FireOffset = AltFireOffset;
		}
		else
		{
			FireOffset = default.FireOffset;
		}

		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z); 
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
		// Make sure we're not generating this on the other side of a thin wall
		//if(FastTrace(Instigator.Location, StartTrace))
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			if(bAltFiring)
				molot = spawn(class'MolotovAltProjectile',Instigator,,StartTrace, AdjustedAim);
			else
				molot = spawn(class'MolotovProjectile',Instigator,,StartTrace, AdjustedAim);

			// Only use up the shot and perform the setup if we successfully spawned
			// a cocktail
			if(molot != None)
			{
				molot.Instigator = Instigator;
				
				// Compensate for catnip time, if necessary. Don't do this for NPCs
				if(FPSPawn(Instigator) != None
					&& FPSPawn(Instigator).bPlayer)
					ChargeTime /= Level.TimeDilation;

				molot.SetupThrown(ChargeTime);
				P2AmmoInv(AmmoType).UseAmmoForShot();
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
					HitActor.Bump(molot);
			}
		}
	}
	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None)
		ThirdPersonActor.bHidden=true;
}

///////////////////////////////////////////////////////////////////////////////
// If you drop your weapon, and you were charging (probably when you were dying)
// then drop a molotov too.
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
	// If you were charging, throw out a live one now
	if(IsInState('BeforeCharging')
		|| IsInState('Charging')
		|| IsInState('ChargeWaitGrenade'))
	{
		ChargeTime = ChargeTimeMinAI;
		Notify_ThrowMolotov();
	}

	Super.DropFrom(StartLocation);
}

// xPatch: Make sure that this gun is not extension!
function bool CanSwapHands()
{
	return (Class == Class'MolotovWeapon');
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ItemName="Molotov Cocktail"
	AmmoName=class'MolotovAmmoInv'
	PickupClass=class'MolotovPickup'
	AttachmentClass=class'MolotovAttachment'

	OldMesh=Mesh'FP_Weapons.FP_Dude_Molotov'
	Mesh=Mesh'MP_Weapons.MP_LS_Molotov'

	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	FirstPersonMeshSuffix="Molotov"

    bDrawMuzzleFlash=False

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Toss
	firingstyle=WEAPONHOLDSTYLE_Toss

	FireSound=Sound'WeaponSounds.Molotov_fire'
	AIRating=0.53
	AutoSwitchPriority=6
	InventoryGroup=6
	GroupOffset=2
	BobDamping=0.975000
	ReloadCount=0
	TraceAccuracy=0.1
	ShotCountMaxForNotify=0
	ViolenceRank=2
	bThrownByFiring=true

	WeaponSpeedIdle	   = 0.5
	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.25
	WeaponSpeedReload  = 1.25
	WeaponSpeedChargeIntro  = 1.5
	WeaponSpeedCharge  = 0.5
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.1
	WeaponSpeedShoot2  = 1.10 //2.0

	AimError=500
	ChargeDistRatio=1600
	ChargeTimeMaxAI=1.5
	ChargeTimeMinAI=0.7

	MaxRange=2048
	MinRange=512
	RecognitionDist=500

	NoAmmoChangeState = "EmptyDownWeapon"

	AltHint1="Press %KEY_AltFire% to place bombs."
	AltHint2="They explode after several seconds."
	
	BobDamping=1.12 
	bDropInVeteranMode=1
	VeteranModeDropChance=0.75
	}
