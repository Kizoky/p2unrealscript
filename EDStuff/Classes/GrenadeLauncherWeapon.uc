//=============================================================================
// PistolWeapon
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Pistol weapon (first and third person).
//
// For AI characters, this weapon scales the number of times it's shot continuously
// with the difficulty level. Higher difficulty--more they shoot in one burst.
//
//	History:
//		07/22/03 NPF	Fires faster per click only in single player. In MP, it
//						fires faster just by holding down the fire button.
//
//		01/11/03 NPF	Allowed pistol to fire faster than firing animation
//						normally permits, if player clicks Fire again.
//
//		01/29/02 MJR	Started history, probably won't be updated again until
//							the pace of change slows down.
//
//
//=============================================================================

class GrenadeLauncherWeapon extends P2weapon;


var bool bCanFireAgain;		// If you're the player and this is set to true, then you
							// shoot again if even you're still in NormalFire

var float WeaponSpeedShoot1MP;	// Allow faster shooting in multiplayer.
var bool bForceReload;
var int ReloadCount;	       // Amount of ammo depletion before reloading. 0 if no reloading is done.
var float SPAccuracy;				// How accurate we are in single player games.

const FIRING_WAIT_TIME = 0.4;
var vector AltFireOffset;

var() class<CatRocket> CatRocketClass;	// Class of cat rocket spawned in the Enhanced Game

function ProjectileFire();

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	local float diffoffset;

	Super.PostBeginPlay();

	// If it's a single player game, make our accuracy much worse
	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		TraceAccuracy = SPAccuracy;

		// Based on the difficulty, bump up the number of times AI will continuously
		// shoot this weapon
		diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset();
		if(diffoffset > 0)
		{
			AI_BurstCountExtra+=(diffoffset/2);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// This will randomly change the color and the size of the dynamic
// light associate with the flash. Change in each weapon's file,
// but call each time you start up the flash again.
// This function is also used by the third-person muzzle flash, so the
// colors will look the same
///////////////////////////////////////////////////////////////////////////////
simulated function PickLightValues()
{
	LightBrightness=150;
	LightSaturation=150;
	LightHue=22+FRand()*10;
	LightRadius=24+FRand()*6;
}

///////////////////////////////////////////////////////////////////////////////
// DrawMuzzleFlash()
//Default implementation assumes that flash texture can be drawn inverted in X and/or Y direction to increase apparent
//number of flash variations
// We might need to draw a dark blood splat
///////////////////////////////////////////////////////////////////////////////
simulated function SetupMuzzleFlash()
{
	bMuzzleFlash = true;
	bSetFlashTime = false;
	// Gets turned off in weapon, in RenderOverlays
	// Slightly change colors each time
	if(IsFirstPersonView()
		&& bDrawMuzzleFlash)
	{
		PickLightValues();
		bDynamicLight=bAllowDynamicLights;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Fire the weapon
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
	{
	// Basics
	IncrementFlashCount();
	bForceReload = true;

	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
	{

		// Play your sound in MP in your attachment to save bandwidth
		PlayAnim('Idle', WeaponSpeedShoot1MP + (WeaponSpeedShoot1Rand*FRand()), 0.05);
		PlayOwnedSound(FireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	}
	else
	{
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
		PlayAnim('Idle', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
	}

	// Adv.
	SetupMuzzleFlash();
	LaunchGrenade();
	// Once the player started his fire, don't let it fire again
	// until the sleep in the NormalFire state let's him
	if(PlayerController(Instigator.Controller) != None)
		bCanFireAgain=false;
	}

function SpawnCatRocket(Pawn Instigator, Vector StartLoc, Rotator StartRot)
{
	local CatRocket CatR;
	local vector MarkerPos;

	CatR = spawn(CatRocketClass, Instigator,, StartLoc, StartRot);
	if (CatR != None)
	{
		CatR.Instigator = Instigator;
		CatR.AddRelativeVelocity(Instigator.Velocity);

		// Records the first (gun fire)
		markerpos = Instigator.Location;

		// Primary (the gun shooting, making a loud noise)
		if(ShotMarkerMade != None)
		{
			ShotMarkerMade.static.NotifyControllersStatic(
				Level,
				ShotMarkerMade,
				FPSPawn(Instigator),
				None,
				ShotMarkerMade.default.CollisionRadius,
				markerpos);
		}
	}
}

function LaunchGrenade()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, markerpos;
	local actor HitActor;
	local GrenadeProjectile gren;
	local float ChargeTime;

	if(P2AmmoInv(AmmoType) != None
		&& AmmoType.HasAmmo())
	{
				//FireOffset = AltFireOffset;
		// Alt-firing the grenade, drops it at your feet, and doesn't
		// arm it

                //FireOffset = default.FireOffset;

		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z);
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		// Make sure we're not generating this on the other side of a thin wall
		// Also, bump anything along the way, so the grenade can break a window if
		// you're standing really close to one.
		//if(FastTrace(Instigator.Location, StartTrace))
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			if (P2GameInfoSingle(Level.Game).VerifySeqTime() && Pawn(Owner).Controller.bIsPlayer)
				SpawnCatRocket(Instigator, StartTrace, Rotator(X));
			else
			{
				if(!bAltFiring)
					gren = spawn(class'GrenadeProjectile',Instigator,,StartTrace, AdjustedAim);
				else     //alt
					gren = spawn(class'GrenadeProjectile',Instigator,,StartTrace, AdjustedAim);

				// Make sure it got made, it could have gotten spawned in a wall and not made
				if(gren != None)
				{
					/*
					gren.Instigator = Instigator;

					// Compensate for catnip time, if necessary. Don't do this for NPCs
					//if(FPSPawn(Instigator) != None
					//	&& FPSPawn(Instigator).bPlayer)
					//	ChargeTime /= Level.TimeDilation;

					gren.SetupThrown(2);
					//gren.AddRelativeVelocity(Instigator.Velocity);
					P2AmmoInv(AmmoType).UseAmmoForShot();
					ReloadCount--;
					// Touch any actor that was in between, just in case.
					if(HitActor != None)
						HitActor.Bump(gren);
					*/
					ChargeTime=0.8;
					gren.Instigator = Instigator;
					// Compensate for catnip time, if necessary. Don't do this for NPCs
					if(FPSPawn(Instigator) != None
						&& FPSPawn(Instigator).bPlayer)
						ChargeTime /= Level.TimeDilation;
					gren.SetupThrown(ChargeTime);
					gren.AddRelativeVelocity(Instigator.Velocity);
					// Touch any actor that was in between, just in case.
					if(HitActor != None)
						HitActor.Bump(gren);
					P2AmmoInv(AmmoType).UseAmmoForShot();

					// Records the first (gun fire)
					markerpos = Instigator.Location;

					// Primary (the gun shooting, making a loud noise)
					if(ShotMarkerMade != None)
					{
						ShotMarkerMade.static.NotifyControllersStatic(
							Level,
							ShotMarkerMade,
							FPSPawn(Instigator),
							None,
							ShotMarkerMade.default.CollisionRadius,
							markerpos);
					}
				}
			}
		}
	}
	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None)
		ThirdPersonActor.bHidden=False;
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// NormalFire
// If we're in here, and it's the player and he presses fire before the fire
// anim is done and *after* the FIRING_WAIT_TIME sleep is over, then we
// let him fire again.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
	///////////////////////////////////////////////////////////////////////////////
	// Same as standard ServerFire
	///////////////////////////////////////////////////////////////////////////////
	function ServerFire()
{
        /*
	if ( AmmoType == None )
	{
		// ammocheck
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}

	//log(self$" serverfire, ammo "$AmmoType.AmmoAmount$" get state "$GetStateName());

	if ( AmmoType.HasAmmo() )
	{
		GotoState('NormalFire');

		// Don't do reloadcount because we usually force reloads (grenades) or don't
		// do them at all (machinegun)

		//Dopamine fuck that, DO THE RELOAD COUNT!!!!
		LocalFire();
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Same as original, but we remove ReloadCount
// Don't do reloadcount because we usually force reloads (grenades) or don't
// do them at all (machinegun)
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
  /*
	//log(self$" Fire, ammo "$AmmoType.AmmoAmount);
	if ( AmmoType == None
		|| !AmmoType.HasAmmo() )
	{
		ClientForceFinish();
		ServerForceFinish();
		return;
	}

	if ( !RepeatFire() )
		ServerFire();
	else if ( StopFiringTime < Level.TimeSeconds + 0.3 )
	{
		StopFiringTime = Level.TimeSeconds + 0.6;
		ServerRapidFire();
	}
	if ( Role < ROLE_Authority )
	{
		// Don't do reloadcount because we usually force reloads (grenades) or don't
		// do them at all (machinegun)
		LocalFire();
		//log(self$" going to client firing");
		GotoState('ClientFiring');
	}
	*/
}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function EndState()
	{
		bCanFireAgain=true;
		Super.EndState();
	}
Begin:
	Sleep(FIRING_WAIT_TIME);
	bCanFireAgain=true;
}
state ClientFiring
{
}

///////////////////////////////////////////////////////////////////////////////
// Play reloading
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
	{
//        P2MocapPawn(Instigator).PlayWeaponReload(self);
         PlayAnim('Shoot1', WeaponSpeedReload, 0.05);
	Instigator.PlaySound(ReloadSound, SLOT_Misc, 1.0);
	}

/* Force reloading even though clip isn't empty.  Called by player controller exec function,
and implemented in idle state */
simulated function ForceReload();

function ServerForceReload()
{
	bForceReload = true;
}

simulated function ClientForceReload()
{
	bForceReload = true;
	GotoState('Reloading');
}

simulated function bool NeedsToReload()
{
	return ( bForceReload || (Default.ReloadCount > 0) && (ReloadCount == 0) );
}

state Reloading
{
	function ServerForceReload() {}
	function ClientForceReload() {}
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire()
	{
		bForceFire = true;
	}

	function ServerAltFire()
	{
		bForceAltFire = true;
	}

	simulated function bool PutDown()
	{
		bChangeWeapon = true;
		return True;
	}

	simulated function BeginState()
	{
		if ( !bForceReload )
		{
			if ( Role < ROLE_Authority )
				ServerForceReload();
			else
				ClientForceReload();
		}
		bForceReload = false;
		PlayReloading();
	}

	simulated function AnimEnd(int Channel)
	{
		ReloadCount = Default.ReloadCount;
		if ( Role < ROLE_Authority )
			ClientFinish();
		else
			Finish();
		CheckAnimating();
	}

	function CheckAnimating()
	{
		if ( !IsAnimating() )
			warn(self$" stuck in Reloading and not animating!");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     bCanFireAgain=True
     WeaponSpeedShoot1MP=1.700000
     ReloadCount=1
     SPAccuracy=0.150000
     FireOffset=(X=35.000000,Y=18.000000)
     ViolenceRank=3
     RecognitionDist=900.000000
     AI_BurstCountExtra=3
     AI_BurstTime=0.800000
     ShotMarkerMade=Class'Postal2Game.GunfireMarker'
     BulletHitMarkerMade=Class'Postal2Game.BulletHitMarker'
     holdstyle=WEAPONHOLDSTYLE_Double
     switchstyle=WEAPONHOLDSTYLE_Double
     firingstyle=WEAPONHOLDSTYLE_Double
     MinRange=250.000000
     ShakeOffsetTime=2.200000
     CombatRating=3.000000
     FirstPersonMeshSuffix="ED_M79_NEW"
     WeaponsPackageStr="ED_Weapons."
     WeaponSpeedLoad=1.500000
     WeaponSpeedReload=1.500000
     WeaponSpeedHolster=1.500000
     WeaponSpeedShoot1Rand=3.000000
     AmmoName=Class'GrenadeAmmoInv'
     AutoSwitchPriority=2
     ShakeRotMag=(X=220.000000,Y=30.000000,Z=30.000000)
     ShakeRotTime=2.200000
     ShakeOffsetMag=(X=10.000000,Y=2.000000,Z=2.000000)
     TraceAccuracy=0.020000
     aimerror=600.000000
     AIRating=0.200000
     MaxRange=1024.000000
     FireSound=Sound'EDWeaponSounds.Heavy.m79_fire_tom'
     FlashOffsetY=-0.050000
     FlashOffsetX=0.060000
     FlashLength=0.050000
     MuzzleFlashSize=128.000000
     MFTexture=Texture'Timb.muzzle_flash.shotgun_corona'
     bDrawMuzzleFlash=True
     MuzzleFlashScale=3.400000
     MuzzleFlashStyle=STY_Normal
     InventoryGroup=9
     GroupOffset=3
     PickupClass=Class'GrenadeLauncherPickup'
     //PlayerViewOffset=(X=0.000000,Z=-1.000000)
     BobDamping=0.975000
     AttachmentClass=Class'GrenadeLauncherAttachment'
     ItemName="Grenade Launcher"
//     Texture=Texture'ED_Hud.HUDM79'
     Mesh=SkeletalMesh'ED_Weapons.ED_M79_NEW'
     Skins(0)=Texture'ED_WeaponSkins.Launching.grenuvmap'
     Skins(1)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     AmbientGlow=128
     SoundRadius=255.000000
	 OverrideHUDIcon=Texture'EDHud.hud_M79'
	CatRocketClass=class'CatRocketGrenade'
}
