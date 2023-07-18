///////////////////////////////////////////////////////////////////////////////
// CowHeadWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Cow heads that you throw.
//
///////////////////////////////////////////////////////////////////////////////

class CowHeadWeapon extends CowHeadBaseWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////

var Sound BuzzingSound;

///////////////////////////////////////////////////////////////////////////////
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
// Alt projectile fire, plus check where to make the danger marker to
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function ProjectileAltFire()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	PlayAnim('Load', WeaponSpeedReload, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// Called on client's side to make the gun fire
// Check here to throw out danger markers to let people know the gun has gone
// off.
///////////////////////////////////////////////////////////////////////////////
simulated function LocalFire()
{
	local P2Player P;

	bPointing = true;

	// Same as the one in P2Weapon, but we don't do the camera shake here
	// We make it shake when he throws

	if ( Affector != None )
		Affector.FireEffect();
	PlayFiring();
	if(Role < ROLE_Authority)
		GotoState('ClientFiring');
}

///////////////////////////////////////////////////////////////////////////////
// Same as above.. we don't want the shake here
///////////////////////////////////////////////////////////////////////////////
simulated function LocalAltFire()
{
	local PlayerController P;

	bPointing = true;

	// Same as the one in P2Weapon, but we don't do the camera shake here
	// We make it shake when he throws

	if ( Affector != None )
		Affector.FireEffect();
	PlayAltFiring();
	if(Role < ROLE_Authority)
		GotoState('ClientFiring');
}

///////////////////////////////////////////////////////////////////////////////
// Actually throw the head
///////////////////////////////////////////////////////////////////////////////
function ThrowIt(float StartSpeed)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local CowheadProjectile cowh;
	local P2Player p2p;

	if(AmmoType != None
		&& AmmoType.HasAmmo())
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z);
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		// Make sure we're not generating this on the other side of a thin wall
		// Also, bump anything along the way, so the grenade can break a window if
		// you're standing really close to one.
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			cowh = spawn(class'CowheadProjectile',Instigator,,StartTrace, AdjustedAim);
			if(cowh != None)
			{
				P2AmmoInv(AmmoType).UseAmmoForShot();
				cowh.Instigator = Instigator;
				cowh.CalcStartVelocity(StartSpeed);
				cowh.AddRelativeVelocity(Instigator.Velocity);

				// Shake the view when you throw it (primary fire only)
				if(!bAltFiring)
				{
					if ( Instigator != None)
					{
						p2p = P2Player(Instigator.Controller);
						if (p2p!=None)
						{
							p2p.ClientShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime,
										ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
						}
					}
				}
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
					HitActor.Bump(cowh);
			}
		}
	}
	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None)
		ThirdPersonActor.bHidden=true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_ThrowCowhead()
{
	ThrowIt(1.0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_AltThrowCowhead()
{
	ThrowIt(0.15);
	TurnOffHint();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Idle
//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
{
	simulated function EndState()
	{
		Super.EndState();
		Instigator.AmbientSound=None;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Make sure you're attachment is visible on idle start
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		Super.BeginState();
		if(ThirdPersonActor != None)
			ThirdPersonActor.bHidden=false;
		Instigator.AmbientSound = BuzzingSound;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DownWeapon
// Make sure if you're told to put down a weapon when already putting down
// one, you short circuit and say it's down now.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DownWeapon
{
	///////////////////////////////////////////////////////////////////////////////
	// Turn off buzzing, just in case Idle was short-circuited
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		if (Instigator.AmbientSound == BuzzingSound)
			Instigator.AmbientSound = None;
			
		Super.BeginState();
	}
}

// xPatch: Make sure that this gun is not extension!
function bool CanSwapHands()
{
	return (Class == Class'CowHeadWeapon');
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bNoHudReticle=true
	bUsesAltFire=true
	ItemName="Cow Head"
	AmmoName=class'CowHeadAmmoInv'
	PickupClass=class'CowHeadPickup'
	AttachmentClass=class'CowHeadAttachment'

	OldMesh=Mesh'FP_Weapons.FP_Dude_Cowhead'
	Mesh=Mesh'MP_Weapons.MP_LS_Cowhead'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="Cowhead"

	FireOffset=(X=20.0000,Y=0.0000,Z=-10.0000)

    bDrawMuzzleFlash=False

	holdstyle=WEAPONHOLDSTYLE_Carry
	switchstyle=WEAPONHOLDSTYLE_Carry
	firingstyle=WEAPONHOLDSTYLE_Carry

	//shakemag=350.000000
	//shaketime=0.200000
	//shakevert=(X=1.0,Y=0.0,Z=1.00000)
	ShakeOffsetMag=(X=20.0,Y=3.0,Z=3.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2.5
	ShakeRotMag=(X=400.0,Y=50.0,Z=200.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2.5

	FireSound=Sound'WeaponSounds.cowhead_fire'
	AIRating=0.5
	AutoSwitchPriority=7
	InventoryGroup=7
	GroupOffset=3
	//BobDamping=0.975000
	BobDamping=1.12 
	ReloadCount=0
	TraceAccuracy=0.1
	ShotCountMaxForNotify=0
	ViolenceRank=1
	bBumpStartsFight=false
	bHideFoot=false 		// Change by Man Chrzan: xPatch 2.0
	bThrownByFiring=true

	WeaponSpeedHolster = 1.0
	WeaponSpeedLoad    = 1.0
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.5
	WeaponSpeedShoot2  = 1.0

	AimError=500
	MaxRange=1024
	RecognitionDist=900

	NoAmmoChangeState = "EmptyDownWeapon"

	HudHint1="Stand still and press %KEY_AltFire% to place it safely."
	HudHint2="Then shoot it at a distance to trigger."
	bAllowHints=true
	bShowHints=true

	BuzzingSound=Sound'WeaponSounds.Cowhead_idle_loop'
	
	bDropInVeteranMode=1
	VeteranModeDropChance=0.05
	}
