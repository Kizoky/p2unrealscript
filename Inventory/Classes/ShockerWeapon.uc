///////////////////////////////////////////////////////////////////////////////
// ShockerWeapon
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Shocker weapon (first and third person).
//
///////////////////////////////////////////////////////////////////////////////

class ShockerWeapon extends P2WeaponStreaming;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
const RAND_SCALE_FLASH	=	0.075;

var GasPourFeeder gaspour;
var ShockerSparks	mysparks;		// sparks for when you hit someone/something
var ShockerLightning mylightning;
var ShockerPawnLightning mypawnlightning;
var Pawn EffectsPawn;			// pawn we have lightning shooting out of
var vector sparkoffset;			// sparks are connected to the gun, but offset by this relative position



const PERSON_PELVIS	= 'MALE01 pelvis';
const ANIMAL_PELVIS	= 'bip01 pelvis';


///////////////////////////////////////////////////////////////////////////////
// Stop our effects
///////////////////////////////////////////////////////////////////////////////
simulated function DetachFromPawn(Pawn P)
{
	Super.DetachFromPawn(P);

	EndLightning(true);
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
	LightHue=150 + FRand()*5;
	LightRadius=12+FRand()*6;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the muzzle flash renders, and move it around some
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
// DrawMuzzleFlash()
///////////////////////////////////////////////////////////////////////////////
simulated function DrawMuzzleFlash(Canvas Canvas)
{
	// Form dynamic muzzle flash size
	MuzzleScale = FRand()*RAND_SCALE_FLASH;
	// Form offset based on that
	FlashOffsetX = -(MuzzleScale/64) + default.FlashOffsetX + Instigator.WalkBob.X/1024;
	FlashOffsetY = -(MuzzleScale/64) + default.FlashOffsetY + Instigator.WalkBob.Y/1024;

	MuzzleScale += default.MuzzleScale;

	Super.DrawMuzzleFlash(Canvas);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
	{
	Super.PlayFiring();
	SetupMuzzleFlash();
	}

///////////////////////////////////////////////////////////////////////////////
// Stub these out to keep it from doing them--we regenerate our ammo
// so they're not needed because we want to stay on this weapon
///////////////////////////////////////////////////////////////////////////////
function ForceFinish();
function ServerForceFinish();
simulated function ClientForceFinish();

///////////////////////////////////////////////////////////////////////////////
// Always be regaining your ability to shoot
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	GainAmmo(DeltaTime);
}

///////////////////////////////////////////////////////////////////////////////
// Put effects shooting out of this pawn
///////////////////////////////////////////////////////////////////////////////
function MakePawnLightning(Pawn AttachPawn)
{
	// For the moment in MP don't put extra electrical effects on player pawns (only NPCs).
	// Make MP player effects for this be much more like blood splats that occur with
	// each 'damage' from the weapon
	if(PlayerController(AttachPawn.Controller) == None)
	{
		if(mypawnlightning != None
			&& EffectsPawn != None)
			DetachFromBone(mypawnlightning);

		if(mypawnlightning == None)
			mypawnlightning = spawn(class'ShockerPawnLightning',self);

		EffectsPawn = AttachPawn;
		if(P2MoCapPawn(EffectsPawn) != None)
		{
			EffectsPawn.AttachToBone(mypawnlightning, PERSON_PELVIS);
		}
		else
		{
			EffectsPawn.AttachToBone(mypawnlightning, ANIMAL_PELVIS);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Stop all your effects
///////////////////////////////////////////////////////////////////////////////
simulated function EndLightning(bool bForce)
{
	if(!Instigator.PressingFire()
			|| !AmmoType.HasAmmo()
			|| bForce)
	{
		if(mylightning != None)
		{
			DetachFromBone(mylightning);
			mylightning.Destroy();
			mylightning = None;
		}
		if(mypawnlightning != None)
		{
			if(mypawnlightning != None
				&& EffectsPawn != None)
			{
				DetachFromBone(mypawnlightning);
				EffectsPawn = None;
			}
			mypawnlightning.Destroy();
			mypawnlightning = None;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Stop the electricity on the pawn you're hitting
///////////////////////////////////////////////////////////////////////////////
function EndPawnLightning()
{
	if(mypawnlightning != None)
	{
		if(mypawnlightning != None
			&& EffectsPawn != None)
		{
			DetachFromBone(mypawnlightning);
			EffectsPawn = None;
		}
		mypawnlightning.Destroy();
		mypawnlightning = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Normal trace fire, plus check where to make the danger marker to
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local vector markerpos, markerpos2;
	local bool secondary;

	// Weapon.TraceFire (modified to save where it hit inside LastHitLocation
	local vector HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
	EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (UseMeleeDist * X);
	// This performs the collision but also records where it hit
	Other = Trace(LastHitLocation,HitNormal,EndTrace,StartTrace,True);
	AmmoType.ProcessTraceHit(self, Other, LastHitLocation, HitNormal, X,Y,Z);

	// If we're not continually hitting the pawn we're electricuting, then
	// stop his effect.
	if(Other != EffectsPawn)
		EndPawnLightning();

	// Say we just fired
	ShotCount++;

	// Set your enemy as the one you attacked.
	if(P2Player(Instigator.Controller) != None
		&& FPSPawn(Other) != None)
	{
		P2Player(Instigator.Controller).Enemy = FPSPawn(Other);
	}

	// Only make a new danger marker if the consecutive fires were as high
	// as the max
	if(ShotCount >= ShotCountMaxForNotify
		&& Instigator.Controller != None)
	{
		// tell it we know this just happened, by recording it.
		ShotCount -= ShotCountMaxForNotify;

		// Records the first (gun fire)
		markerpos = Instigator.Location;
		// Secondary records the bullet hit
		markerpos2 = LastHitLocation;
		secondary = true;

		// Primary (the gun shooting, making a loud noise)
		if(ShotMarkerMade != None)
		{
			ShotMarkerMade.static.NotifyControllersStatic(
				Level,
				ShotMarkerMade,
				FPSPawn(Instigator),
				FPSPawn(Instigator),
				ShotMarkerMade.default.CollisionRadius,
				markerpos);
		}
		// This is if a pawn is hit by a bullet (or hurt bad), so it's really scary
		if(P2Pawn(Other) != None
			&& PawnHitMarkerMade != None)
		{
			PawnHitMarkerMade.static.NotifyControllersStatic(
				Level,
				PawnHitMarkerMade,
				FPSPawn(Instigator),
				FPSPawn(Other),
				PawnHitMarkerMade.default.CollisionRadius,
				markerpos2);
		}
		// secondary (if bullet hit something other than a man, like a wall)
		else if(secondary
			&& BulletHitMarkerMade != None)
		{
			BulletHitMarkerMade.static.NotifyControllersStatic(
				Level,
				BulletHitMarkerMade,
				FPSPawn(Instigator),
				None,
				BulletHitMarkerMade.default.CollisionRadius,
				markerpos2);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Idle
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
	{
	simulated function BeginState()
		{
		// If instigator doesn't want to fire anymore then we can finally
		// end the whole pouring sequence.
		if (!Instigator.PressingFire())
			{
			if (Owner != None)
				ForceEndFire();
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Normal fire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Streaming
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick( float DeltaTime )
	{
		if(ReduceAmmo(DeltaTime))
			TraceFire(TraceAccuracy, 0, 0);
		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			// Cut immediately if you stop early
			if(!Instigator.PressingFire())
			{
				// Replicate to the tell the server to stop
				ServerEndStreaming();
				// Client stops using this
				if(Level.NetMode != NM_Standalone )
					EndStreaming();
			}
		}
	}

	simulated function BeginState()
	{
		if(mylightning == None
			&& Level.NetMode != NM_DedicatedServer)
		{
			mylightning = spawn(class'ShockerLightning',Instigator);
			AttachToBone(mylightning, 'bip01 r hand');
			mylightning.SetRelativeLocation(sparkoffset);
		}
		Super.BeginState();
	}
	simulated function EndState()
	{
		Super.EndState();
		EndLightning(false);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DownWeapon
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DownWeapon
{
	simulated function BeginState()
	{
		Super.BeginState();
		EndLightning(true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bNoHudReticle=true
	ItemName="Shocker"
	AmmoName=class'ShockerAmmoInv'
	PickupClass=class'ShockerPickup'
	AttachmentClass=class'ShockerAttachment'
	bMeleeWeapon=true

//	Mesh=Mesh'FP_Weapons.FP_Dude_Tazer'
	Mesh=Mesh'MP_Weapons.MP_LS_Tazer'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="Tazer"
    //PlayerViewOffset=(X=1.0000,Y=-1.000000,Z=-2.0000)
	PlayerViewOffset=(X=1.0000,Y=-1.000000,Z=-6.0000)
	FireOffset=(X=0.0000,Y=1.30000,Z=-1.00000)

    bDrawMuzzleFlash=True
	MuzzleScale=0.15
	FlashOffsetY=0.16
	FlashOffsetX=0.12
	FlashLength=0.1
	MuzzleFlashSize=128
    MFTexture=None

	MuzzleFlashStyle=STY_Normal
    MuzzleFlashScale=2.40000

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Single
	firingstyle=WEAPONHOLDSTYLE_Single

	aimerror=0.000000
	//shakemag=0.000000
	//shaketime=0.000000
	//shakevert=(X=0.0,Y=0.0,Z=0.00000)
	//shakespeed=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetTime=0
	ShakeRotMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotTime=0

	CombatRating=1.2
	AIRating=0.1
	AutoSwitchPriority=1
	InventoryGroup=1
	GroupOffset=1
	BobDamping=0.975000
	ReloadCount=0
	ViolenceRank=1
	TraceAccuracy=0.01
	AI_BurstCountExtra=10
	AI_BurstCountMin=5
	AI_BurstTime=0.0

	soundStart = Sound'WeaponSounds.tazer_fire'
	soundLoop1 = Sound'WeaponSounds.tazer_loop'
	soundLoop2 = Sound'WeaponSounds.tazer_loop'
	soundEnd = Sound'WeaponSounds.tazer_end'

	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.5
	WeaponSpeedReload  = 1.25
	WeaponSpeedShoot1  = 2.0
	WeaponSpeedShoot1Rand=1.0
	WeaponSpeedShoot2  = 1.0

	RecognitionDist=500
	PlayerMeleeDist=120
	NPCMeleeDist=80.0
	MaxRange=100
	AmmoUseRate=5.0
	AmmoGainRate=1.0
	sparkoffset=(X=20,Y=-4.0,Z=2.0)
	bDelayedStartSound=true
	}
