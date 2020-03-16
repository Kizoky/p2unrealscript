///////////////////////////////////////////////////////////////////////////////
// NapalmWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Napalm cannister launcher
//
///////////////////////////////////////////////////////////////////////////////

class NapalmWeapon extends P2Weapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var travel bool bShowHint1;
var bool bAltFired;

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function bool GetHints(out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bAllowHints)
	{
		if(bShowHint1)
			str1=HudHint1;
		else
			str2=HudHint2;
		return true;
	}
	return false;
}
///////////////////////////////////////////////////////////////////////////////
// Allow hints again
///////////////////////////////////////////////////////////////////////////////
function RefreshHints()
{
	Super.RefreshHints();
	bShowHint1=true;
}

simulated function PlayFiring()
{
	bForceReload=true;
	Super.PlayFiring();
	if(bShowHint1)
	{
		bShowHint1=false;
		UpdateHudHints();
	}
}
simulated function PlayAltFiring()
{
	bForceReload=true;
	Super.PlayAltFiring();
	if(!bShowHint1)
		TurnOffHint();
}

///////////////////////////////////////////////////////////////////////////////
// play reloading sounds
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	// temp speed up because with no animation, you can't tell you're
	// why you can't shoot (becuase it's playing a reload anim)
	PlayAnim('Shoot1Unload', WeaponSpeedReload, 0.05);
	Instigator.PlayOwnedSound(ReloadSound, SLOT_Misc, 1.0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayDownAnim()
{
	if(HasAmmo())
		Super.PlayDownAnim();
	else
		PlayAnim('HolsterEmpty', WeaponSpeedHolster, 0.05);
		Instigator.PlayOwnedSound(HolsterSound, SLOT_Misc, 1.0);
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
function Notify_ShootNapalm()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local NapalmProjectile npro;

	if(AmmoType != None
		&& AmmoType.HasAmmo())
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z);
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		//  Make sure there's nothing right in the way
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			// Reset our dude's burn count
			if (P2Pawn(Instigator) != None)
				P2Pawn(Instigator).PeopleBurned = 0;
			npro = spawn(class'NapalmProjectile',Instigator,,StartTrace, AdjustedAim);
			if(npro != None)
			{
				P2AmmoInv(AmmoType).UseAmmoForShot();
				npro.Instigator = Instigator;
				npro.SetupShot(!bAltFiring, !bAltFiring);
				npro.AddRelativeVelocity(Instigator.Velocity);
			}
			// Touch any actor that was in between, just in case.
			if(HitActor != None)
				HitActor.Bump(npro);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bUsesAltFire=true
	ItemName="Napalm Launcher"
	AmmoName=class'NapalmAmmoInv'
	PickupClass=class'NapalmPickup'
	ErrandPickupClass = class'NapalmPickupErrand'
	AttachmentClass=class'NapalmAttachment'

//	Mesh=Mesh'FP_Weapons.FP_Dude_Napalm'
	Mesh=Mesh'MP_Weapons.MP_LS_Napalm'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="Napalm"
    //PlayerViewOffset=(X=1.7000,Y=0.000000,Z=-1.3000)
	PlayerViewOffset=(X=1.7000,Y=0.000000,Z=-6.3000)
	FireOffset=(X=20.0000,Y=20.000000,Z=0.00000)

    bDrawMuzzleFlash=False

	holdstyle=WEAPONHOLDSTYLE_Both
	switchstyle=WEAPONHOLDSTYLE_Both
	firingstyle=WEAPONHOLDSTYLE_Both

	//ShakeMag=1000.000000
	//ShakeRollRate=20000
	//ShakeOffsetTime=3.0
	//ShakeTime=0.500000
	//ShakeVert=(Z=5.0)
	ShakeOffsetMag=(X=20.0,Y=3.0,Z=3.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2.5
	ShakeRotMag=(X=400.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2.5

	FireSound=Sound'WeaponSounds.napalm_fire'
	AltFireSound=Sound'WeaponSounds.napalm_fire'
	AIRating=0.99
	AutoSwitchPriority=10
	InventoryGroup=10
	GroupOffset=1
	BobDamping=0.975000
	ReloadCount=0
	TraceAccuracy=0.3
	ShotCountMaxForNotify=0
	ViolenceRank=8

	WeaponSpeedIdle	   = 0.4
	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.0
	WeaponSpeedReload  = 0.5
	WeaponSpeedShoot1  = 0.9
	WeaponSpeedShoot1Rand=0.1
	WeaponSpeedShoot2  = 0.5
	WeaponSpeedShoot2Rand=0.1

	AimError=300
	RecognitionDist=1500

	MaxRange=2048
	MinRange=512

	bShowHint1=true
	bAllowHints=true
	bShowHints=true
	HudHint1="Press %KEY_Fire% for a straight ahead shot."
	HudHint2="Press %KEY_AltFire% and be careful with this in-doors."
	}
