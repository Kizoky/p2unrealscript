///////////////////////////////////////////////////////////////////////////////
// LauncherWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Rocket launcher
//
// Charged weapon. Needs to fuel each rocket.
// If fired before it reaches the red in the fuel, it's a normal, forward
// thrusting rocket.
// If it reaches the red point and is fired, it shoots a seeking rocket,
// which targets the highest threat/ then nearest character.
// Alt-fire just is the same but doesn't shoot a seeking rocket at the end.
//
///////////////////////////////////////////////////////////////////////////////

class LauncherWeapon extends DualGrenadeWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var bool bZoomed;
var Texture SniperReticleCorner;
var Texture SniperReticleCenter;

var bool	bSeeking;		// if you shoot seeking rockets... changes with each fire.
var int SeekingChargeMultiplier;	// how much more fuel/charge time seeking rockets get

var float   AmmoRemainder;	// float remainder for when the ammo is reduced in the tick
var float	AmmoUseRate;	// How fast to take ammo for a rocket (to give it fuel)
var float   InitialAmmoCost;// How much ammo it takes just to start a rocket fueling

var Actor	CurrentTarget;	// What we're going to shoot with our seeking rocket
							// Try to wait a little while to give them some lee-way when aiming
							// at a target.
var float   CurrentTargetPickTime;	// When we started aiming at this guy.
var vector  ProjectedHitLoc;// Point on a wall we'we aiming at--use if CurrentTarget is none.
var float   ChargeStartAmmo;// Ammo amount we had before we started to charge a rocket
var travel bool	bShootTradSeeker;// Shoot out a traditional seeking rocket (defaults to new seeker style)
var int		ShootStyleChanger; // Count the number of times you press AltFire while holding Fire
							// and only change styles when you reach a certain point. Before, when you
							// only had to click it once, it was too easy for people to accidentally do it.
var bool	bPressedAltFire; // To know if he pressed it and we cared
var Sound FuelingSound;
var Sound SeekerSound;
var Sound TradSwitchSound;
var Sound NewSwitchSound;

const ZOOM_FOV				=	7;
const KEEP_TARGET_TIME		=	1.0;
const CHANGE_COUNT			=	2;


replication
{
	// functions client sends to server
	reliable if (Role < ROLE_Authority)
		ShootIt;

	// functions server sends to client
	reliable if (Role == ROLE_Authority)
		SetReticleOnTarget, SetReticleOffTarget, ClientGotoState;
}


///////////////////////////////////////////////////////////////////////////////
// Server uses this to force client into NewState
///////////////////////////////////////////////////////////////////////////////
simulated function ClientGotoState(name NewState, optional name NewLabel)
{
	if(Role != ROLE_Authority)
	    GotoState(NewState,NewLabel);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	AnimEnd(0);
}

///////////////////////////////////////////////////////////////////////////////
// This is not your friend/teammate, so he's okay to target (for the seeking
// rocket)
///////////////////////////////////////////////////////////////////////////////
function bool ValidTarget(FPSPawn TestTarget)
{
	if(TestTarget != None
		&& TestTarget.Health > 0
		&& !TestTarget.bPlayerIsFriend
		&& (TestTarget.PlayerReplicationInfo == None
			|| TestTarget.PlayerReplicationInfo.Team == None
			|| TestTarget.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team))
			return true;
}

///////////////////////////////////////////////////////////////////////////////
// Pretravel so you can clean up before the player goes to the next level
///////////////////////////////////////////////////////////////////////////////
function GiveBackChargingAmmo()
{
	local float giveback;

	giveback = ChargeStartAmmo - AmmoType.AmmoAmount;
	if(giveback > 0)
		AmmoType.AddAmmo(giveback);
}

///////////////////////////////////////////////////////////////////////////////
// Reduce the real time ammo
// Only reduce it when we've gone through a single unit of fuel.
// Then reset the remainder and start again
// This is to handle the fact that AmmoAmount is stored as an int and we want
// to steadily stream the ammo for this weapon
///////////////////////////////////////////////////////////////////////////////
function ReduceAmmo(float DeltaTime)
{
	// don't reduce it any more, if we're already out
	if(AmmoType.AmmoAmount <= 0)
		return;

	AmmoRemainder-=(AmmoUseRate*DeltaTime);
	if(AmmoRemainder < 0)
	{
		P2AmmoInv(AmmoType).UseAmmoForShot();
		AmmoRemainder=AmmoRemainder+1;
	}

	// We've ran out, so hold the charge where you are and wait till they release the button
	if(AmmoType.AmmoAmount <= 0)
	{
		RecordChargeTime();
		GotoState('ChargingNoAmmo');
		ClientGotoState('ChargingNoAmmo');
	}
}

///////////////////////////////////////////////////////////////////////////////
// We're ready to fire a seeking rocket and it has a target
///////////////////////////////////////////////////////////////////////////////
simulated function SetReticleOnTarget()
{
	ReticleColor.A = 255;
}

///////////////////////////////////////////////////////////////////////////////
// It's not targetting anything currently, or we've just shot the rocket, and
// it's resetting
///////////////////////////////////////////////////////////////////////////////
simulated function SetReticleOffTarget()
{
	ReticleColor = ReticleDefaultColor;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayCharging()
{
	if(bAltFiring)
		PlayAnim('Shoot2Prep', WeaponSpeedCharge, 0.05);
	else
		PlayAnim('Shoot1Prep', WeaponSpeedCharge, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayChargeWait()
{
	if(bAltFiring)
		PlayAnim('Shoot2DistanceMax', 1.0, 0.05);
	else
		PlayAnim('ShootDistanceMax', 1.0, 0.05);
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
// WE don't throw grenades
///////////////////////////////////////////////////////////////////////////////
function ThrowGrenade()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// AI characters determine by distance how far to throw/shoot projectiles
// Check for pawns shooting seeking rockets
///////////////////////////////////////////////////////////////////////////////
function CalcAIChargeTime()
{
	local PersonController perc;
	local vector dir;

	perc = PersonController(Instigator.Controller);

	if(perc != None
		&& perc.Target != None)
	{
		if(perc.MyPawn.bAdvancedFiring)
			bSeeking=true;
	}

	Super.CalcAIChargeTime();

	// Always make seeking npc rockets travel for a long time.
	if(bSeeking)
		ChargeTime=ChargeTimeMaxAI;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_ShootLauncher()
{
	local vector StartTrace, X,Y,Z, markerpos, HitNormal, HitLocation;
	local actor HitActor;
	local LauncherProjectile lpro;
	local LauncherSeekingProjectileTrad lspro;
	local float giveback;

	if(AmmoType != None)
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z);
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		CalcAIChargeTime();
		ShootStyleChanger=0;
		// Make sure we're not generating this on the other side of a thin wall
		//if(FastTrace(Instigator.Location, StartTrace))
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			if(!bSeeking)
				// fire a normal rocket
			{
				lpro = spawn(class'LauncherProjectile',Instigator,,StartTrace, AdjustedAim);
				if(lpro != None)
				{
					lpro.Instigator = Instigator;
					// Compensate for catnip time, if necessary. Don't do this for NPCs
					if(FPSPawn(Instigator) != None
						&& FPSPawn(Instigator).bPlayer)
						ChargeTime /= Level.TimeDilation;
					lpro.SetupShot(ChargeTime);
					lpro.AddRelativeVelocity(Instigator.Velocity);
					// Touch any actor that was in between, just in case.
					if(HitActor != None)
						HitActor.Bump(lpro);
				}
			}
			else // fire a seeking rocket
			{
				// Shoot either a traditional seeking rocket or a new super seeker
				if(!bShootTradSeeker)
					lspro = spawn(class'LauncherSeekingProjectile',Instigator,,StartTrace, AdjustedAim);
				else
					lspro = spawn(class'LauncherSeekingProjectileTrad',Instigator,,StartTrace, AdjustedAim);

				if(lspro != None)
				{
					lspro.Instigator = Instigator;

					// if we're not aimed at anything, figure out a target
					if(CurrentTarget == None)
					{
						lspro.DetermineTarget(ProjectedHitLoc);
					}
					else
						lspro.SetNewTarget(CurrentTarget);

					lspro.SetupShot(SeekingChargeMultiplier*ChargeTime);

					lspro.AddRelativeVelocity(Instigator.Velocity);

					// Touch any actor that was in between, just in case.
					if(HitActor != None)
						HitActor.Bump(lspro);
				}
			}
		}

		// Clear our target regardless
		CurrentTarget = None;
		// If we didn't make a valid rocket, then give him his ammo back
		if(lpro == None
			&& lspro == None)
		{
			giveback = ChargeStartAmmo - AmmoType.AmmoAmount;
			if(giveback > 0)
				AmmoType.AddAmmo(giveback);
		}
		else
		{
			// Say we just fired
			ShotCount++;

			// Only make a new danger marker if the consecutive fires were as high
			// as the max
			if(ShotCount >= ShotCountMaxForNotify
				&& Instigator.Controller != None
				&& ShotMarkerMade != None)
			{
				// tell it we know this just happened, by recording it.
				ShotCount -= ShotCountMaxForNotify;

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
		// Reset the ammo you started with
		ChargeStartAmmo = AmmoType.AmmoAmount;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Skip the charge intro (in grenade) -- go straight to charging
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	if ( AmmoType == None
		|| !AmmoType.HasAmmo() )
	{
		ClientForceFinish();
		ServerForceFinish();
		return;
	}


	bAltFiring=false;
	ServerFire();

	if ( Role < ROLE_Authority )
	{
		PrepCharge();
		GotoState('Charging');
	}
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerFire()
{
	bAltFiring=false;
	PrepCharge();
	GotoState('Charging');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PrepCharge()
{
	// play our charge up anim
	PlayCharging();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function AltFire( float Value )
{
	if ( !AmmoType.HasAmmo() )
		return;

	bAltFiring=true;
	ServerAltFire();

	if ( Role < ROLE_Authority )
	{
		PrepCharge();
		GotoState('Charging');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerAltFire()
{
	bAltFiring=true;
	PrepCharge();
	GotoState('Charging');
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
		Notify_ShootLauncher();
	}

	Super.DropFrom(StartLocation);
}

///////////////////////////////////////////////////////////////////////////////
// Is zooming
///////////////////////////////////////////////////////////////////////////////
simulated function bool IsZoomed()
{
	return bZoomed;
}

///////////////////////////////////////////////////////////////////////////////
// Start the zoom
///////////////////////////////////////////////////////////////////////////////
simulated function Zoom()
{
	if(AmmoType.HasAmmo())
	{
		// END zoom mode
		if ( bZoomed )
		{
			GotoState('ZoomingOut');
		}
		else
		// START zoom mode
		{
			GotoState('ZoomingIn');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Do the work in the FOV to change the zoom mode.
///////////////////////////////////////////////////////////////////////////////
simulated function EnterZoomMode()
{
	PlayAnim('StartZoom');
	bZoomed = true;
}
simulated function ExitZoomMode()
{
	PlayerController(Instigator.Controller).ClientAdjustGlow(0,vect(0,0,0));
	PlayAnim('EndZoom');
	bZoomed = false;
	PlayerController(Instigator.Controller).ResetFOV();
}

///////////////////////////////////////////////////////////////////////////////
// Make sure you're not zoomed
///////////////////////////////////////////////////////////////////////////////
simulated function bool ForceEndFire()
	{
	if(PlayerController(Instigator.Controller) != None)
		PlayerController(Instigator.Controller).ResetFOV();
	return Super.ForceEndFire();
	}

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
// Actually shoot the projectile
///////////////////////////////////////////////////////////////////////////////
function ShootIt()
{
	GotoState('NormalFire');
	PlayFiring();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientShootIt()
{
	LocalFire();
	GotoState('ClientFiring');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ZoomingIn
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ZoomingIn
{
	ignores Fire, AltFire, ForceReload, NextWeapon, PrevWeapon, WeaponChange;

	simulated function bool IsZoomed()
	{
		return false;
	}

	simulated function bool PutDown()
	{
		bChangeWeapon = true;
		return True;
	}

	simulated function AnimEnd(int Channel)
	{
		// switch to close up FOV
		if ( bZoomed )
		{
			PlayerController(Instigator.Controller).SetFOV(ZOOM_FOV);
			PlayerController(Instigator.Controller).ClientAdjustGlow(0.5,vect(0,255,0));
		}

		if ( Role == ROLE_Authority )
			Finish();
		else
			ClientFinish();
	}

	simulated function BeginState()
	{
		EnterZoomMode();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ZoomingOut
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ZoomingOut extends ZoomingIn
{
	simulated function BeginState()
	{
		ExitZoomMode();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Charging
// Charge until you let go of the fire button
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Charging
{
	ignores Zoom;

	///////////////////////////////////////////////////////////////////////////////
	// Pretravel so you can clean up before the player goes to the next level
	///////////////////////////////////////////////////////////////////////////////
	function PreTravel()
	{
		Super.PreTravel();
		GiveBackChargingAmmo();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		// As long as you're pressing fire, suck ammo down
		// and fuel up the rocket
		ReduceAmmo(DeltaTime);

		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			// Implement dual wielding shoot logic
			if ((bDualWielding && LeftWeapon != none && !Instigator.PressingAltFire()) ||
			    (RightWeapon != none && !Instigator.PressingFire())) {
				RecordChargeTime();
				ShootIt();
				ClientShootIt();
			}
			
			// If we're dual wielding, forget about the single wielding shoot logic
			if (bDualWielding || RightWeapon != none)
			    return;
			
			if((!bAltFiring
					&& !Instigator.PressingFire())
				|| (bAltFiring
					&& !Instigator.PressingAltFire()))
			{
				// Save the time you've been charging up for, since you left before
				// ChargeWaiting. That is, we've left before the max charge time.
				// So record it here.
				RecordChargeTime();

				ShootIt();
				ClientShootIt();
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Reset seeking
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		Super.BeginState();

		// reset seeking
		bSeeking=false;
		// Save how much we started with in case we need to give it back
		// if the rocket messes up
		ChargeStartAmmo = AmmoType.AmmoAmount;
		// Use an initial cost amount for each rocket, in terms of fuel
		// This could be more ammo than we have, if it is, immidiately freeze
		// the animation and record the charge time now
		AmmoRemainder = 1;

		// Take the fuel needed
		P2AmmoInv(AmmoType).UseAmmoForShot(InitialAmmoCost);

		if(Role == ROLE_Authority)
		{
			if(AmmoType.AmmoAmount <= 0)
			{
				AmmoType.AmmoAmount = 0;
				RecordChargeTime();
				GotoState('ChargingNoAmmo');
				ClientGotoState('ChargingNoAmmo');
			}
		}

		// Start fueling sound
		Instigator.PlaySound(FuelingSound, SLOT_Misc, 1.0);
	}
	simulated function EndState()
	{
		Super.EndState();
		// End fueling sound
		Instigator.PlaySound(FuelingSound, SLOT_Misc, 0.01);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Trying to charge, but you're out of ammo, so you're holding till you
// fire, or find more ammo
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ChargingNoAmmo extends Charging
{
	ignores AnimEnd, ReduceAmmo;
/*
	///////////////////////////////////////////////////////////////////////////////
	// If come across more ammo, reset him to charging again (leave this state)
	///////////////////////////////////////////////////////////////////////////////
	function ReduceAmmo(float DeltaTime)
	{
		if(AmmoType.HasAmmo())
		{
			GotoState('Charging');
			if(AmmoType.AmmoAmount >= InitialAmmoCost)
				ClientGotoState('Charging');
		}
	}
*/
	simulated function BeginState()
	{
		StopAnimating();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ChargeWaitLauncher
// Just wait and idle till they unpress fire and let you throw it, shoot it
// Must be different that the grenade one, because we extend Charging,
// the base state, here
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ChargeWaitLauncher extends ChargeWaitGrenade
{
	ignores RecordChargeTime, ReduceAmmo, Zoom;

	///////////////////////////////////////////////////////////////////////////////
	// Pretravel so you can clean up before the player goes to the next level
	///////////////////////////////////////////////////////////////////////////////
	function PreTravel()
	{
		Super.PreTravel();
		GiveBackChargingAmmo();
	}

	///////////////////////////////////////////////////////////////////////////////
	// While waiting to fire, also check to see if we'll hit anything good
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		local vector HitNormal, StartTrace, EndTrace, X,Y,Z;
		local Actor TestTarget;

		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			// Implement dual wielding shoot logic
			if (bDualWielding || RightWeapon != none) {
			    
				if ((bDualWielding && LeftWeapon != none && !Instigator.PressingAltFire()) ||
			        (RightWeapon != none && !Instigator.PressingFire())) {
				    RecordChargeTime();
				    ShootIt();
				    ClientShootIt();
			    }
			}
			else {
			    if ((!bAltFiring && !Instigator.PressingFire()) ||
				    (bAltFiring && !Instigator.PressingAltFire())) {
				// Save the time you've been charging up for, since you left before
				// ChargeWaiting. That is, we've left before the max charge time.
				// So record it here.
				RecordChargeTime();

				ShootIt();
				ClientShootIt();
			    }
			}
			
			if (((bDualWielding && Instigator.PressingAltFire()) ||
			     (RightWeapon != none && Instigator.PressingFire()) ||
				 (!bDualWielding && Instigator.PressingFire())) && bSeeking)
			{
//				if(Level.Game != None
//					&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				if(Level.NetMode == NM_Standalone
					|| Level.NetMode == NM_ListenServer)
				{
					// Check if you're hitting a person
					// shoot a trace out and see where they are pointing.
					GetAxes(Instigator.GetViewRotation(),X,Y,Z);
					StartTrace = Instigator.Location + Instigator.EyePosition();//GetFireStart(X,Y,Z);
					EndTrace = StartTrace + TraceDist*X;
					TestTarget = Trace(ProjectedHitLoc, HitNormal, EndTrace, StartTrace, true);
					// Pick this new target. Only pick alive, non-friend people
					if(ValidTarget(FPSPawn(TestTarget)))
					{
						CurrentTargetPickTime = Level.TimeSeconds;
						CurrentTarget = TestTarget;
						SetReticleOnTarget();
					}
					// If he's not been on the target for too long, then clear it.
					else if((CurrentTargetPickTime + KEEP_TARGET_TIME) < Level.TimeSeconds)
					{
						CurrentTarget = None;
						SetReticleOffTarget();
					}
				}

				// If you pressed alt fire and let up, switch seeking types
				if (Instigator.PressingAltFire())
					bPressedAltFire=true;
				else if(bPressedAltFire)
				{
					// Let them press it again
					bPressedAltFire=false;
					// Record that they pressed it once
					ShootStyleChanger++;
					if(ShootStyleChanger >= CHANGE_COUNT)
					{
						ShootStyleChanger=0;
						bShootTradSeeker=!bShootTradSeeker;
						if(bShootTradSeeker)
							Instigator.PlaySound(TradSwitchSound, SLOT_Misc, 1.0);
						else
							Instigator.PlaySound(NewSwitchSound, SLOT_Misc, 1.0);
					}
				}
			}
		}
		else if(bSeeking)// server side only in MP game (not single player
		{
			// Check if you're hitting a person
			// shoot a trace out and see where they are pointing.
			GetAxes(Instigator.GetViewRotation(),X,Y,Z);
			StartTrace = Instigator.Location + Instigator.EyePosition();//GetFireStart(X,Y,Z);
			EndTrace = StartTrace + TraceDist*X;
			TestTarget = Trace(ProjectedHitLoc, HitNormal, EndTrace, StartTrace, true);
			// Pick this new target. Only pick alive, non-friend people
			if(CurrentTarget != TestTarget)
			{
				// New pawn
				if(ValidTarget(FPSPawn(TestTarget)))
				{
					CurrentTargetPickTime = Level.TimeSeconds;
					CurrentTarget = TestTarget;
					SetReticleOnTarget();
				}
			}
			else if(FPSPawn(CurrentTarget) != None) // if still centered on him, update pick time
				CurrentTargetPickTime = Level.TimeSeconds;

			if(CurrentTarget != None
				&& (CurrentTargetPickTime + KEEP_TARGET_TIME) < Level.TimeSeconds)
			{
				CurrentTarget = None;
				SetReticleOffTarget();
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		PlayChargeWait();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Reset out reticle
	///////////////////////////////////////////////////////////////////////////////
	simulated function EndState()
	{
		Super.EndState();
		SetReticleOffTarget();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set to seeking when you get to this state
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		PlayChargeWait();
		if(!bAltFiring)
		{
			bSeeking=true;
			Instigator.PlaySound(SeekerSound, SLOT_Misc, 1.0);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Downweapon
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DownWeapon
{
	ignores Zoom;

	simulated function BeginState()
	{
		Super.BeginState();
		bZoomed = false;
		if ( PlayerController(Instigator.Controller) != None )
			PlayerController(Instigator.Controller).ResetFOV();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bUsesAltFire=true
	ItemName="Rocket Launcher"
	AmmoName=class'LauncherAmmoInv'
	PickupClass=class'LauncherPickup'
	AttachmentClass=class'LauncherAttachment'

//	Mesh=Mesh'FP_Weapons.FP_Dude_Launcher'
	Mesh=Mesh'MP_Weapons.MP_LS_Launcher'

//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="Launcher"
    //Orginally didn't have a PlayerViewOffset
    PlayerViewOffset=(X=2.0000,Y=0.000000,Z=-15.0000)
	FireOffset=(X=60.0000,Y=35.000000,Z=0.00000)

    bDrawMuzzleFlash=True
	MuzzleScale=1.0
	FlashOffsetY=0.015
	FlashOffsetX=0.06
	FlashLength=0.1
	MuzzleFlashSize=128
    MFTexture=Texture'nathans.muzzleflashes.mf_shotgun_new'
    //MuzzleFlashStyle=STY_Translucent
	MuzzleFlashStyle=STY_Normal
    //MuzzleFlashMesh=Mesh'Weapons.Shotgun3'
    MuzzleFlashScale=2.40000
    //MuzzleFlashTexture=Texture'MuzzyPulse'

	holdstyle=WEAPONHOLDSTYLE_Both
	switchstyle=WEAPONHOLDSTYLE_Both
	firingstyle=WEAPONHOLDSTYLE_Both
	
	dualholdstyle=WEAPONHOLDSTYLE_DualBig
	dualswitchstyle=WEAPONHOLDSTYLE_DualBig
	dualfiringstyle=WEAPONHOLDSTYLE_DualBig

	//ShakeMag=1000.000000
	//ShakeRollRate=20000
	//ShakeOffsetTime=3.0
	//ShakeTime=0.500000
	//ShakeVert=(Z=5.0)
	ShakeOffsetMag=(X=1.0,Y=1.0,Z=1.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2
	ShakeRotMag=(X=700.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2

	SoundRadius=255
	FireSound=Sound'WeaponSounds.launcher_fire'
	FuelingSound=Sound'WeaponSounds.launcher_fueling'
	SeekerSound=Sound'WeaponSounds.launcher_seeker'
	AIRating=0.9
	AutoSwitchPriority=9
	InventoryGroup=9
	GroupOffset=1
	BobDamping=0.975000
	ReloadCount=0
	TraceAccuracy=0.3
	ShotCountMaxForNotify=0
	ShotMarkerMade=class'GunfireMarker'
	ViolenceRank=9

	WeaponSpeedIdle	   = 0.2
	WeaponSpeedHolster = 1.5
	WeaponSpeedCharge  = 0.9
	WeaponSpeedLoad    = 1.0
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.3
	WeaponSpeedShoot2  = 1.0
	bThrownByFiring=false

    TraceDist=10000.0
	AimError=1000

	AmmoUseRate=2.5
	InitialAmmoCost=5
	ChargeTimeModifier=1.25
	SeekingChargeMultiplier=10.0
	ChargeWaitState="ChargeWaitLauncher"
	ChargeDistRatio=2200
	RecognitionDist=1600
	TradSwitchSound=Sound'MiscSounds.Radar.PluginActivate'
	NewSwitchSound=Sound'MiscSounds.PickupSounds.gun_bounce'

	MaxRange=3000
	MinRange=1024

	HudHint1="Hold %KEY_Fire% to fuel"
	HudHint2="rockets for longer travel."
	AltHint1=""
	AltHint2=""
	}
