///////////////////////////////////////////////////////////////////////////////
// PlaugeWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Plague missle launcher (Weapon of Mass Destruction)

//
///////////////////////////////////////////////////////////////////////////////

class PlagueWeapon extends NapalmWeapon;

var Sound SqueakSound;

const POLICE_LEVEL_NAME = "police.fuk";


///////////////////////////////////////////////////////////////////////////////
// When you're sent to jail most weapons are taken. The matches aren't. Perhaps
// they want to do something now.
///////////////////////////////////////////////////////////////////////////////
function AfterItsTaken(P2Pawn CheckPawn)
{
	local P2Weapon weapinv;

	//Police.fuk
	// Hard code to remove this weapon when you get sent to jail. The police would never
	// let you have this back! Okay.. so sure, they let you have back the rocket launcher.. but not
	// the crack, money, donuts, or cats! And not this either!
	//log(self$" checking me, with this pawn "$CheckPawn$" out here AfterItsTaken in this level "$P2GameInfo(Level.Game).ParseLevelName(Level.GetLocalURL()));
	if(P2GameInfo(Level.Game).ParseLevelName(Level.GetLocalURL()) ~= POLICE_LEVEL_NAME)
	{
		log(self$" REMOVING me, because we don't give this back when they get sent to jail.");
		weapinv = P2Weapon(CheckPawn.FindInventoryType(class));

		//log(self$" checking for "$weappick.InventoryType$" has this "$weapinv);
		// He has it, so leave it, but transfer the count over.
		if(weapinv != None)
		{
			// First remove the ammo for this weapon from the dude
			weapinv.AmmoType.DetachFromPawn(weapinv.Instigator);	
			weapinv.AmmoType.Instigator.DeleteInventory(weapinv.AmmoType);
			// Then destroy the inventory for the dude
			weapinv.DetachFromPawn(weapinv.Instigator);	
			CheckPawn.DeleteInventory(weapinv);
		}
		Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Use same shoot for both, but different load
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
{
	IncrementFlashCount();
	// Play MP sounds on everyone's computers
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(AltFireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else // just on yours in SP games
		Instigator.PlaySound(AltFireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
	
	if (!bDualWielding && RightWeapon == none) 
		bForceReload=true;
		
	PlayAnim('Shoot2', WeaponSpeedShoot2, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// play reloading for each type of shot
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	// temp speed up because with no animation, you can't tell you're
	// why you can't shoot (becuase it's playing a reload anim)
	if(bAltFiring)
		PlayAnim('Shoot2Unload', WeaponSpeedReload, 0.05);
	else
		PlayAnim('Shoot1Unload', WeaponSpeedReload, 0.05);

	Instigator.PlayOwnedSound(ReloadSound, SLOT_Misc, 1.0);
}

///////////////////////////////////////////////////////////////////////////////
// Squeaking noise when turning knob... we needed to pitch it, so we couldn't
// just use an AnimNotify_Sound.
///////////////////////////////////////////////////////////////////////////////
function Notify_WMDSqueak()
{
	Instigator.PlaySound(SqueakSound, SLOT_None, 1.0, true, , (1.0 + GetRandPitch()));
}
function Notify_WMDSqueak2()
{
	Instigator.PlaySound(SqueakSound, SLOT_None, 1.0, true, , (0.5 + GetRandPitch()));
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_ShootPlague()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local PlagueProjectile ppro;
	local float ChargeTime;
	local PersonController perc;

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
			perc = PersonController(Instigator.Controller);
			if(perc != None
				&& perc.MyPawn != None
				&& perc.MyPawn.bAdvancedFiring)
					bAltFiring=true;

			if(!bAltFiring)
				ppro = spawn(class'PlagueProjectile',Instigator,,StartTrace, AdjustedAim);
			else
				ppro = spawn(class'PlagueBounceProjectile',Instigator,,StartTrace, AdjustedAim);

			if(ppro != None)
			{
				P2AmmoInv(AmmoType).UseAmmoForShot();
				ChargeTime=30;
				ppro.Instigator = Instigator;
				// Compensate for catnip time, if necessary. Don't do this for NPCs
				if(FPSPawn(Instigator) != None
					&& FPSPawn(Instigator).bPlayer)
					ChargeTime /= Level.TimeDilation;
				ppro.SetupShot(ChargeTime);
				ppro.AddRelativeVelocity(Instigator.Velocity);
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
					HitActor.Bump(ppro);
			}
			// Touch any actor that was in between, just in case.
			if(HitActor != None)
				HitActor.Bump(ppro);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Clear alt-firing here instead, each time before we fire.
///////////////////////////////////////////////////////////////////////////////
function ServerFire()
{
	bAltFiring=false;
	Super.ServerFire();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayDownAnim()
{
	Super(P2Weapon).PlayDownAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// NormalFire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
	{
	function EndState()
		{
		if ( Instigator != None )
			Instigator.StopPlayFiring();
		Super(Weapon).EndState();
		// Don't clear it here. Set it on fire of normal fire/alt fire
		//bAltFiring=false;
		}
	}
	
// xPatch: Make sure that this gun is not extension!
function bool CanSwapHands()
{
	return (Class == Class'PlagueWeapon');
}

// xPatch: Dual Wielding
function SetLeftArmVisibility() 
{
	Super(P2DualWieldWeapon).SetLeftArmVisibility();
}

simulated function PlayFiring()
{
	if (!bDualWielding && RightWeapon == none) 
		bForceReload=true;
		
	Super(P2DualWieldWeapon).PlayFiring();
	if(bShowHint1)
	{
		bShowHint1=false;
		UpdateHudHints();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bUsesAltFire=true
	ItemName="Weapon of Mass Destruction"
	AmmoName=class'PlagueAmmoInv'
	PickupClass=class'PlaguePickup'
	ErrandPickupClass = None
	AttachmentClass=class'PlagueAttachment'

	OldMesh=Mesh'Patch1_FP_Weapons.FP_Dude_WMD'
	Mesh=Mesh'MP_Weapons.MP_LS_WMD'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="WMD"
	WeaponsPackageStr = "Patch1_FP_Weapons."

	PlayerViewOffset=(X=1.7000,Y=0.000000,Z=-15.3000)
	FireOffset=(X=30.0000,Y=20.000000,Z=0.00000)

    bDrawMuzzleFlash=False

	holdstyle=WEAPONHOLDSTYLE_Both
	switchstyle=WEAPONHOLDSTYLE_Both
	firingstyle=WEAPONHOLDSTYLE_Both

	ShakeOffsetMag=(X=20.0,Y=3.0,Z=3.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2.5
	ShakeRotMag=(X=400.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2.5

	FireSound=Sound'WeaponSounds.napalm_fire'
	AltFireSound=Sound'WeaponSounds.napalm_fire'
	SqueakSound=Sound'LevelSoundsToo.library.wood_hingeGroan01'
	AIRating=0.95
	AutoSwitchPriority=9
	InventoryGroup=9
	GroupOffset=2
//	BobDamping=0.975000
	BobDamping=1.12 
	ReloadCount=0
	TraceAccuracy=0.3
	ShotCountMaxForNotify=0
	ViolenceRank=8

	WeaponSpeedIdle	   = 0.4
	WeaponSpeedHolster = 0.5
	WeaponSpeedLoad    = 1.0
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.1
	WeaponSpeedShoot2  = 1.0
	WeaponSpeedShoot2Rand=0.1

	AimError=50
	RecognitionDist=1500

	MaxRange=2048
	MinRange=512

	bShowHint1=true
	bAllowHints=true
	bShowHints=true
	HudHint1="Press %KEY_Fire% for light-weight rocket."
	HudHint2="Press %KEY_AltFire% for a bouncing heavy rocket."
	
	LeftHandBoneName="Bip01 L UpperArm"
	bDisableDualWielding=False
	}
