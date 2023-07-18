class LeverActionShotgunWeapon extends DualCatableWeapon;//PLDualWieldWeapon;

// Extra damage inflicted in the Enhanced Game
var() class<DamageType> AltDamageTypeInflicted;
var() float AltDamageAmount;

// xPatch
var sound LeverSound;

/*
///////////////////////////////////////////////////////////////////////////////
// Go through all your weapons and change out the hands texture for this new one
///////////////////////////////////////////////////////////////////////////////
simulated function ChangeHandTexture(Texture NewHandsTexture, Texture DefHandsTexture, Texture NewFootTexture)
{
	Skins[0] = NewHandsTexture;
	LeftWeapon.ChangeHandTexture(NewHandsTexture, DefHandsTexture, NewFootTexture);
}
*/

/** Copied from the default ShotgunWeapon */
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local int i;
	local bool bProj;

	// Reduce the ammo only by 1 here, for the shotgun, but shoot
	// ShotCountMaxForNotify number of pellets each time.
	P2AmmoInv(AmmoType).UseAmmoForShot();
	
	// Reduce the cat ammo if we're using one
	if(CatOnGun == 1)
		CatAmmoLeft--;

	for(i=0; i<ShotCountMaxForNotify; i++)
	{	
		// FIXME this could probably be handled better by having the aim assist pick a vector to fire in and then let the gun's accuracy handle the
		// pellet hits but... whatever, we're on a time constraint here.
		if (i == 0)
			bAllowAimAssist = Default.bAllowAimAssist;
		else
			bAllowAimAssist = false;
		Super.TraceFire(Accuracy, YOffset, ZOffset);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Overridden so we can add cool stuff in enhanced mode without needing a new
// ammo class.
///////////////////////////////////////////////////////////////////////////////
function TraceAltFire(float Accuracy, float YOffset, float ZOffset)
{
	local int i;
	local vector markerpos, markerpos2;
	local bool secondary;
	local BulletTracer bullt;
	local vector usev, Extent;
	local Rotator newrot;
	local Pawn P;

	// Weapon.TraceFire (modified to save where it hit inside LastHitLocation
	local vector HitNormal, StartTrace, EndTrace, EndTracePerfect, X,Y,Z;
	local vector TempHit, TempNormal;
	local actor Other, AimAssistHit;
	local float AimAngle;
	
	local bool bDoEnhanced;

	P2AmmoInv(AmmoType).UseAmmoForShot();
	Owner.MakeNoise(1.0);
	
	// Reduce the cat ammo if we're using one
	if(CatOnGun == 1)
		CatAmmoLeft--;
	
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
		bDoEnhanced=true;

	for (i=0;i<ShotCountMaxForNotify;i++)
	{
		if (i == 0)
			bAllowAimAssist = Default.bAllowAimAssist;
		else
			bAllowAimAssist = false;
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z);
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
			+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
		X = vector(AdjustedAim);
		EndTrace += (TraceDist * X);
		EndTracePerfect = StartTrace + TraceDist * X;
		
		// This performs the collision but also records where it hit
		Other = Trace(LastHitLocation,HitNormal,EndTrace,StartTrace,True);
		if (bAllowAimAssist && (Other == None || Other.bStatic) && Level.NetMode == NM_Standalone && Level.Game.AutoAim < 1 && 
			Owner != None && Pawn(Owner) != None && Pawn(Owner).Controller != None && Pawn(Owner).Controller.bIsPlayer)
		{
			AimAssistHit = GetAssistedAimTarget(StartTrace, TraceDist);
			if (AimAssistHit != None)
				Other = AimAssistHit;
		}

		AmmoType.ProcessTraceHit(self, Other, LastHitLocation, HitNormal, X,Y,Z);
		
		// Enhanced game only: add extra incendiary damage.
		if (bDoEnhanced)
			Other.TakeDamage(AltDamageAmount, Pawn(Owner), LastHitLocation, P2AmmoInv(AmmoType).MomentumHitMag*X, AltDamageTypeInflicted);
			
		// Say we just fired
		ShotCount++;

		// Only show tracers if the user wants it, and if he's not the player
		// in first person (so show 3rd person player tracers if wanted)
		if(P2GameInfo(Level.Game).bShowTracers)
		{
			// Make a tracer through the air (this is only for the single player side
			// of things. And inferior version gets made in MP in an effect maker pack)
			usev = (LastHitLocation - StartTrace);
			if(Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
			{
				bullt = spawn(class'BulletTracer',Owner,,(LastHitLocation + StartTrace)/2);
				bullt.SetDirection(Normal(usev), VSize(usev));
			}
		}

		// Set your enemy as the one you attacked.
		if(P2Player(Instigator.Controller) != None
			&& FPSPawn(Other) != None)
			P2Player(Instigator.Controller).Enemy = FPSPawn(Other);

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
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
{
	PlayFiring();
}

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function bool GetHints(out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bShowHints
		&& bAllowHints
		&& P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
	{
		str1=HudHint1;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerAltFire()
{
	TurnOffHint();
	Super.ServerAltFire();
}

///////////////////////////////////////////////////////////////////////////////
// AltFire - shoots incendiary rounds
// Enhanced only.
///////////////////////////////////////////////////////////////////////////////
simulated function AltFire( float Value )
{
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
	{
		Super.AltFire(Value);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// Play our new lever sound
///////////////////////////////////////////////////////////////////////////////
function Notify_PlayLeverSound()
{
	PlayOwnedSound(LeverSound, SLOT_Interact, 1.0);
}

defaultproperties
{
    //MuzzleFlashBone="dummy_muzzle"
    //MuzzleFlashEmitterClass=class'LeverShotgunMuzzleFlashEmitter'
	bSpawnMuzzleFlash=True
	MFBoneName="dummy_muzzle"
	MFClass=class'xMuzzleFlashEmitter'
	MFTex=Texture'Timb.muzzleflash.shotgun_corona'

    ItemName="Lever-Action Shotgun"
	AmmoName=class'ShotGunBulletAmmoInv'
	PickupClass=class'LeverActionShotgunPickup'
	AttachmentClass=class'LeverActionShotgunAttachment'

	Mesh=SkeletalMesh'PL_Win_1887.pl_win_1887_viewmodel'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'

	FirstPersonMeshSuffix="Shotgun"

    bDrawMuzzleFlash=false
	MuzzleScale=1.0
	FlashOffsetY=-0.05
	FlashOffsetX=0.06
	FlashLength=0.05
	MuzzleFlashSize=128
    MFTexture=texture'Timb.muzzleflash.shotgun_corona'

	MuzzleFlashStyle=STY_Normal
    MuzzleFlashScale=2.4

	holdstyle=WEAPONHOLDSTYLE_Double
	switchstyle=WEAPONHOLDSTYLE_Double
	firingstyle=WEAPONHOLDSTYLE_Double

	ShakeOffsetMag=(X=20.0,Y=4.0,Z=4.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2.5
	ShakeRotMag=(X=400.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2.5

	FireSound=Sound'WeaponSounds.shotgun_fire'
	LeverSound=Sound'WeaponSoundsToo.1887Lever'		// Added by Man Chrzan: xPatch 2.0
	SoundRadius=255
	CombatRating=4
	AIRating=0.3
	AutoSwitchPriority=3
	InventoryGroup=3
	GroupOffset=1
	BobDamping=1.12 //0.975
	ReloadCount=0
	TraceAccuracy=0.7
	ShotCountMaxForNotify=4
	AI_BurstCountExtra=0
	AI_BurstCountMin=3
	ViolenceRank=3

	WeaponSpeedIdle=1
	WeaponSpeedHolster=1
	WeaponSpeedLoad=1
	WeaponSpeedReload=1
	WeaponSpeedShoot1=1
	WeaponSpeedShoot2=1

	PlayerViewOffset=(X=8,Y=0,Z=-12)

	AimError=400
	RecognitionDist=1100

	MaxRange=512
	MinRange=200

	ShotMarkerMade=class'GunfireMarker'
	BulletHitMarkerMade=class'BulletHitMarker'
	PawnHitMarkerMade=class'PawnShotMarker'

	HudHint1="Press %KEY_AltFire% for incendiary rounds."
	bAllowHints=true
	bShowHints=true
	bUsesAltFire=true

	OverrideHUDIcon=Texture'MrD_PL_Tex.HUD.LeverHUD'
	
	AltDamageTypeInflicted=class'BurnedDamage'
	AltDamageAmount=1
	
	// Meow! 
	bAttachCat=True
	CatFireSound=Sound'WeaponSounds.shotgun_catfire'
	CatBoneName="dummy_muzzle"
	CatRelativeLocation=(X=0,Y=2,Z=3)
	CatRelativeRotation=(Pitch=0,Roll=0,Yaw=16384)
	StartShotsWithCat=9
}
