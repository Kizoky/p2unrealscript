//=============================================================================
// GrenadeLauncherWeapon.uc
// Brand new re-written code by Man Chrzan
// for xPatch 2.0
//=============================================================================

class GrenadeLauncherWeapon extends DualCatableWeapon;//P2DualWieldWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, Bools, etc.
///////////////////////////////////////////////////////////////////////////////
var() class<CatRocket> CatRocketClass;	// Class of cat rocket spawned in the Enhanced Game
var() class<CatGrenadePawn> CatGrenadeClass;	// Class of explosive cat pawn 
var travel bool bShowHint1;

var GrenadeLauncherFPAttachment HandGrenade;
var() vector AttachLocation, AttachLocation2;
//var() rotator AttachRotation, AttachRotation2;
var() rotator GrenadeRotation;
var() float AttachScale, AttachScale2;
var Texture InvisSkinTex, HGSkinTex;

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

///////////////////////////////////////////////////////////////////////////////
// Fire the weapon
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	// 3rd and FP Muzzle Flashes
	IncrementFlashCount();
	SetupMuzzleFlashEmitter();
	
	// Play MP sounds on everyone's computers
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(FireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else // just on yours in SP games
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
		
	// Enhanced Game
	if(P2GameInfoSingle(Level.Game).VerifySeqTime() 
		&& Pawn(Owner).Controller.bIsPlayer)
	{
		PlayAnim('Shoot1', WeaponSpeedShoot1, 0.05);	
	}
	else
	{
		if (bDualWielding || (RightWeapon != none && RightWeapon.bDualWielding))	
			PlayAnim('DualFire', WeaponSpeedShoot2, 0.05);	
		else
			PlayAnim('Shoot1', WeaponSpeedShoot1, 0.05);		
	}
	
	if(bAltFiring)
		return;
	
	if(bShowHint1)
	{
		bShowHint1=false;
		UpdateHudHints();
	}
}

simulated function PlayAltFiring()
{
	PlayFiring();
	
	if(!bShowHint1)
		TurnOffHint();
}

///////////////////////////////////////////////////////////////////////////////
// Play reloading
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	Instigator.PlaySound(ReloadSound, SLOT_Misc, 1.0);
	P2MocapPawn(Instigator).PlayWeaponReload(self);		// 3rd person reload anim.
}

///////////////////////////////////////////////////////////////////////////////
// Normal projectile fire, plus check where to make the danger marker to
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function ProjectileFire()
{
	// bug fix for firing grenades from other weapon after quick weapon switch 
	if (Instigator.Weapon != self 
		&& RightWeapon == none)	// not dual wielding
		return;
	
	if(P2GameInfoSingle(Level.Game).xManager != None
		&& P2GameInfoSingle(Level.Game).xManager.bSteamGrenadeLauncher)
		//LaunchHandGrenade();
		LaunchGrenade(True);
	else 
		LaunchGrenade(False);

	if( HandGrenade != None )
	{
		DetachFromBone(HandGrenade);
		HandGrenade.Destroy();
		HandGrenade = None;
	}
	
	if(CatOnGun==1)
	{
		CatAmmoLeft--;
		
		if(P2GameInfoSingle(Level.Game).VerifySeqTime()
			&& Pawn(Owner).Controller.bIsPlayer )
		{
			// Remove our cat and shoot him off after 9 shoots
			if (CatAmmoLeft==0
			|| !AmmoType.HasAmmo())
			{
			SwapCatOff();
			CatOnGun=0;
			}
		}
		else
		{	
			// Remove our cat instantly
			SwapCatOff();
			CatOnGun=0;
			CatAmmoLeft=0;
		}
	}
}

function ProjectileAltFire()
{
	ProjectileFire();
}

///////////////////////////////////////////////////////////////////////////////
// Fire the weapon and launch original M79 grenade projectile.
///////////////////////////////////////////////////////////////////////////////
function LaunchGrenade(bool bHandGrenade)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, markerpos;
	local actor HitActor;
	local GrenadeLauncherProjectile grn;

	if(AmmoType != None
		&& AmmoType.HasAmmo())
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z); 
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);

		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor != None && (HitActor.bStatic || HitActor.bWorldGeometry))
			return;
		
		if ( CatOnGun == 1 ) // Cat on launcher
			SpawnCatRocket(Instigator, StartTrace, Rotator(X));
		else // Normal fire
            grn = spawn(class'GrenadeLauncherProjectile',Instigator,,StartTrace, AdjustedAim);
		
		// Make sure it got made
		if(grn == None)
			return;
		else 
		{
			if(!PersonPawn(Instigator).bPlayer)
			{
				// We reverse it here, alt fire is easier to dodge
				if(PersonPawn(Instigator) != None 
				&& !PersonPawn(Instigator).bAdvancedFiring)
					bAltFiring = True;
			}
			
			grn.SetupShot(bHandGrenade, bAltFiring, PersonPawn(Instigator).bPlayer);
			if(bHandGrenade)
			{
				GrenadeRotation = grn.Rotation;
				grn.SetRelativeRotation(GrenadeRotation + default.GrenadeRotation);
			}
		}
			
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

///////////////////////////////////////////////////////////////////////////////
// Old function for shooting Hand-Grenades (Not used anymore)
///////////////////////////////////////////////////////////////////////////////
/*
function LaunchHandGrenade()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, markerpos;
	local actor HitActor;
	local GrenadeProjectile gren;
	local float ChargeTime;

	if(P2AmmoInv(AmmoType) != None
		&& AmmoType.HasAmmo())
	{

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
			if ( CatOnGun == 1 ) // Cat on launcher
				SpawnCatRocket(Instigator, StartTrace, Rotator(X));
			else
			{
				gren = spawn(class'GrenadeProjectile',Instigator,,StartTrace, AdjustedAim);

				// Make sure it got made, it could have gotten spawned in a wall and not made
				if(gren != None)
				{
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
}
*/

///////////////////////////////////////////////////////////////////////////////
// Cat-Rocket for "Cat-Silencer"
///////////////////////////////////////////////////////////////////////////////
function SpawnCatRocket(Pawn Instigator, Vector StartLoc, Rotator StartRot)
{
	local CatRocket CatR;
	local CatGrenadePawn CatG;
	local vector MarkerPos, Dir, UseVel;
	local float GrenadeScale;
	
	if(bAltFiring)
	{
		CatR = spawn(CatRocketClass, Instigator,, StartLoc, StartRot);
		if (CatR != None)
		{
			CatR.bDoBounces=true;	
			CatR.Instigator = Instigator;
			CatR.AddRelativeVelocity(Instigator.Velocity);
			CatR.speed=6000.000000;
			CatR.MaxSpeed=6000.000000;
			CatR.Skins[0] = CatSkin;	// Add correct Skin!
			
			// Enhanced Game
			if(P2GameInfoSingle(Level.Game).VerifySeqTime() 
				&& Pawn(Owner).Controller.bIsPlayer
				&& CatRocketGrenade(CatR) != None)
				CatRocketGrenade(CatR).MaxBounces = 50;
		
			P2AmmoInv(AmmoType).UseAmmoForShot();
		}
	}
	else
	{
		CatG = spawn(CatGrenadeClass,,,StartLoc, StartRot);
		if(CatG != None) 
		{
			Dir = vector(Instigator.GetViewRotation());
			UseVel = 2000 * Dir;
			
			if(HandGrenade != None)
				GrenadeScale = 0.9;
			
			if ( CatG.Controller == None
				&& CatG.Health > 0 )
			{
				if ( (CatG.ControllerClass != None))
					CatG.Controller = spawn(CatG.ControllerClass);
				if ( CatG.Controller != None )
				{
					CatG.Controller.Possess(CatG);
					CatG.Controller.GotoState('FallingGrenade');
				}
				// Check for AI Script
				CatG.CheckForAIScript();
			}
	
			CatG.AddVelocity(UseVel);
			CatG.AddGrenade(GrenadeScale);
			CatG.Skins[0] = CatSkin;	// Add correct Skin!
			
			P2AmmoInv(AmmoType).UseAmmoForShot();
		}
	}
}

// We're not shooting off our Cat Silencer... 
// We're shooting Cat-Grenades!
function ShootOffCat()
{
}

///////////////////////////////////////////////////////////////////////////////
// Grenade Launcher doesn't have separate fire and reload animations.
// So here's a little trick to avoid reloading in some certain cases.
///////////////////////////////////////////////////////////////////////////////
function Notify_SkipReload()
{
	if(P2AmmoInv(AmmoType).AmmoAmount == 0 // We are out of ammo
	|| (P2GameInfoSingle(Level.Game).VerifySeqTime() && Pawn(Owner).Controller.bIsPlayer)) 	// or Enhanced Mode
		GotoState('Idle');																 
	else
		PlayReloading();	// If we can't skip. Play the reload (3rd Person).
}

///////////////////////////////////////////////////////////////////////////////
// Load animation does have a second or two of doing nothing, skip it.
///////////////////////////////////////////////////////////////////////////////
function Notify_GoIdle()
{
	GotoState('Idle');																 
}

///////////////////////////////////////////////////////////////////////////////
// Actually inserts Hand Grenade into the M79 barrel (LMAO)
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	AttachFPPart();
}

simulated function BringUp()
{
    Super.BringUp();
	AttachFPPart();
}

simulated function AttachFPPart()
{
    local PlayerController PC;
	local Pawn P;
	
	if(P2GameInfoSingle(Level.Game).xManager != None
		&& P2GameInfoSingle(Level.Game).xManager.bSteamGrenadeLauncher)
	{
		P  = Pawn(Owner);
		PC = PlayerController(P.Controller);
		
		Skins[0] = HGSkinTex;

		if( P.IsLocallyControlled() && PC != None && !PC.bBehindView )
		{
			if( HandGrenade == None )
				HandGrenade = Spawn(class'GrenadeLauncherFPAttachment',self);
				
			if( HandGrenade != None )
			{
				AttachToBone(HandGrenade, 'mesh_shellprojectile');
				HandGrenade.SetRelativeLocation(AttachLocation);
				//HandGrenade.SetRelativeRotation(AttachRotation);
				HandGrenade.SetDrawScale(AttachScale);
				HandGrenade.AmbientGlow = AmbientGlow;
			}
		}

		if( HandGrenade != None && HandGrenade.AttachmentBone == '' )
			HandGrenade.Skins[0] = InvisSkinTex;
	}
	else // Disable Hand Grenades
	{
		if(Skins[0] != default.Skins[0])
			Skins[0] = default.Skins[0];
		
		if( HandGrenade != None )
		{
			DetachFromBone(HandGrenade);
			HandGrenade.Destroy();
			HandGrenade = None;
		}
	}
}

exec function Loc()
{
	HandGrenade.SetRelativeLocation(AttachLocation);
	//HandGrenade.SetRelativeRotation(AttachRotation);
	HandGrenade.SetDrawScale(AttachScale); 
}

exec function Loc2()
{
	HandGrenade.SetRelativeLocation(AttachLocation2);
	//HandGrenade.SetRelativeRotation(AttachRotation2);
	HandGrenade.SetDrawScale(AttachScale2); 
}

function Notify_GetGrenade()
{
	if(P2GameInfoSingle(Level.Game).xManager != None
		&& P2GameInfoSingle(Level.Game).xManager.bSteamGrenadeLauncher)
	{
		if( HandGrenade == None )
		{
			HandGrenade = Spawn(class'GrenadeLauncherFPAttachment',self);
			AttachToBone(HandGrenade, 'mesh_shellprojectile');
		}

		if( HandGrenade != None )
		{
			HandGrenade.SetRelativeLocation(AttachLocation2);
			HandGrenade.SetDrawScale(AttachScale2);
			HandGrenade.AmbientGlow = AmbientGlow;
		}
	}
}

function Notify_InsertGrenade()
{
	if(P2GameInfoSingle(Level.Game).xManager != None
		&& P2GameInfoSingle(Level.Game).xManager.bSteamGrenadeLauncher)
	{
		if( HandGrenade != None )
		{
			HandGrenade.SetDrawScale(AttachScale); 
			HandGrenade.SetRelativeLocation(AttachLocation);
			//HandGrenade.SetRelativeRotation(AttachRotation);
		}
	}
}

simulated function Destroyed()
{
    Super.Destroyed();

	if( HandGrenade != None )
	{
		DetachFromBone(HandGrenade);
		HandGrenade.Destroy();
		HandGrenade = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	 bUsesAltFire=True
     TraceAccuracy=0.150000
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
     WeaponSpeedReload=1.000000 	
	 WeaponSpeedShoot1=1.100000
	 WeaponSpeedShoot2=1.500000		// Speed of firing in Dual Wield 
     WeaponSpeedHolster=1.500000
     WeaponSpeedShoot1Rand=3.000000
     AmmoName=Class'GrenadeAmmoInv'
     AutoSwitchPriority=2
     ShakeRotMag=(X=220.000000,Y=30.000000,Z=30.000000)
     ShakeRotTime=2.200000
     ShakeOffsetMag=(X=10.000000,Y=2.000000,Z=2.000000)
     aimerror=600.000000
     AIRating=0.200000
     MaxRange=1024.000000
     FireSound=Sound'EDWeaponSounds.Heavy.m79_fire_tom'
     InventoryGroup=10
     GroupOffset=2
     PickupClass=Class'GrenadeLauncherPickup'
     BobDamping=1.120000
     AttachmentClass=Class'GrenadeLauncherAttachment'
     ItemName="Grenade Launcher"
     Mesh=SkeletalMesh'ED_Weapons.ED_M79_NEW'
     Skins(0)=Texture'ED_WeaponSkins.Launching.grenuvmap'
     Skins(1)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     SoundRadius=255.000000
	 OverrideHUDIcon=Texture'EDHud.hud_M79'
	 CatRocketClass=class'EDStuff.CatRocketGrenade'
	 CatGrenadeClass=class'People.CatGrenadePawn'
	 bDrawMuzzleFlash=False // We don't want old MF
	 bSpawnMuzzleFlash=True // We want new one.
	 
     MFBoneName="Muzzle"
	 MFClass=class'EDPistolPuff' //'MuzzleSmoke03'
	 MFRelativeLocation=(X=0,Y=0,Z=0)
	 bMFAlwaysSpawn=True
	 
	 // Meow! 
	 bAttachCat=True
	 CatFireSound=Sound'WeaponSounds.machinegun_catfire'
	 CatBoneName="sights"
	 CatRelativeLocation=(X=0,Y=-0.7,Z=15)
	 CatRelativeRotation=(Pitch=16384,Yaw=0,Roll=-16384)
	 StartShotsWithCat=9	// for enhanced game
	 
	 InvisSkinTex=Shader'P2R_Tex_D.Weapons.fake'
	 HGSkinTex=Texture'xPatchTex.Weapons.gren_noshell'
	 
	 AttachScale=0.42
	 AttachLocation=(X=-3.3,Y=1.96,Z=-3)
	 //AttachRotation=(Pitch=0,Yaw=0,Roll=-16384)
	 AttachScale2=0.8
	 AttachLocation2=(X=-5,Y=4,Z=-3)
	 //AttachRotation2=(Pitch=0,Yaw=0,Roll=32768)
	 GrenadeRotation=(Pitch=0,Yaw=16384,Roll=-16384)
	 
	bShowHint1=true
	bAllowHints=true
	bShowHints=true
	HudHint1="Press %KEY_Fire% for a straight ahead shot."
	HudHint2="Press %KEY_AltFire% for a bouncing grenade."
}
