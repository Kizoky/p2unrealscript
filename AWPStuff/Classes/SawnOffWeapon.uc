//////////////////////////////////////////////////////////////////////////////////////////////////
// SawnOffWeapon.uc
//
// Edited by Man Chrzan
// Brand new clean code, better balancing and new feature -- dual wielding!
//
// Short summary of the rebalance. Weapon now uses 2 shells per shot.
// ShotCountMaxForNotify (pellets) is now 12, should be 8 (2x Normal Shotgun) but whatever, 
// it was 16 originally but it was way too much for performance, I increased DamageAmount 
// per pellet instead (see ShotgunBulletAmmoInv) to keep the original damage per shot close to original. 
// 
// Also to let them have some fun with the whole "overpowerd" feeling
// This weapon can be now dual-wielded allowing to fire 2 times as it used to originally.
// The only difference being that it will still use up 2x more ammunition and is time limited.
//
// PS. Hopefully I wont get cricificated for the whole rebalance thing.
// But just in case, if it's my last message... I regret nothing!
//////////////////////////////////////////////////////////////////////////////////////////////////
class SawnOffWeapon extends DualCatableWeapon;

var int ShotAmmoUse;

///////////////////////////////////////////////////////////////////////////////
// Fire the weapon
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	if (!HasAmmo())		
	{
		ClientForceFinish();
		ServerForceFinish();
		return;
	}
	
	Super.Fire(Value);
	
	// We do that reload stuff only if it's not Enhanced Game or if its NPC using the gun.
	if(!P2GameInfoSingle(Level.Game).VerifySeqTime() || !Pawn(Owner).Controller.bIsPlayer)
	{	
		if(HasAmmo())
			bForceReload=True;
	}
}

///////////////////////////////////////////////////////////////////////////////
// See what we hit
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local int i;
	local bool bProj;

	P2AmmoInv(AmmoType).UseAmmoForShot(ShotAmmoUse);

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
// Reloading 
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	// First-Person Reload
	if (bDualWielding && LeftWeapon != none || RightWeapon != none) 
	{
		PlayAnim('DualReload', WeaponSpeedReload, 0.05);
		return;	// Return to prevent 3rd person reload issues.
	}
	else
		PlayAnim('Reload', WeaponSpeedReload, 0.05);
	
	// Third-Person Reload
	P2MocapPawn(Instigator).PlayWeaponReload(self);
}

///////////////////////////////////////////////////////////////////////////////
// Sawn-Off needs to have more than 1 ammo to be used
///////////////////////////////////////////////////////////////////////////////
simulated function bool HasAmmo()
{
	if(P2AmmoInv(AmmoType) != None)
	{
		return ( AmmoType.AmmoAmount > 1 ); 	
	}
	return false;
}

simulated function bool HasAmmoFinished()
{
	return HasAmmo();	
}

///////////////////////////////////////////////////////////////////////////////
// Cat-Silencer 
///////////////////////////////////////////////////////////////////////////////
function SwapCatOn()
{
	Super.SwapCatOn();
	
	TraceAccuracy=0.8;
}

function SwapCatOff()
{
	Super.SwapCatOff();
	
	TraceAccuracy=default.TraceAccuracy;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	OverrideHUDIcon=Texture'EDHud.hud_SawnOffShotgun'
	ShotAmmoUse = 2

	ItemName="Sawed-Off Shotgun"
	AmmoName=class'ShotGunBulletAmmoInv'
	PickupClass=class'SawnOffPickup'
	AttachmentClass=class'SawnOffAttachment'

	Mesh=SkeletalMesh'AW7_EDWeapons.ED_SawnOff_NEW'
	Skins(0)=Texture'AW7EDTex.Weapons.SawnOff'
	Skins(1)=Texture'MP_FPArms.LS_arms.LS_hands_dude'

	holdstyle=WEAPONHOLDSTYLE_Double
	switchstyle=WEAPONHOLDSTYLE_Double
	firingstyle=WEAPONHOLDSTYLE_Double

	ShakeOffsetMag=(X=40.0,Y=8.0,Z=8.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=3.5
	ShakeRotMag=(X=800.0,Y=100.0,Z=100.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=3.5

	FireSound=Sound'AW7Sounds.MiscWeapons.SawnOff_Fire'
	SoundRadius=255
	CombatRating=4.0
	AIRating=1.0
	AutoSwitchPriority=3
	InventoryGroup=3
	GroupOffset=3
	BobDamping=1.125000
	ReloadCount=0
	TraceAccuracy=2.0
	ShotCountMaxForNotify=12
	//AltShotCountMaxForNotify=6
	AI_BurstCountMin=12
	ViolenceRank=8

	WeaponSpeedIdle	   = 0.8
	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.5
	WeaponSpeedReload  = 1.35
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.3
	WeaponSpeedShoot2  = 1.0

	AimError=400
	RecognitionDist=1100

	MaxRange=512
	MinRange=200

	HudHint1="Press %KEY_AltFire% to reload manually."
	bAllowHints=false
	bShowHints=false

	bUsesAltFire=False
	bDrawMuzzleFlash=False
	
	ShotMarkerMade=class'GunfireMarker'
	BulletHitMarkerMade=class'BulletHitMarker'
	PawnHitMarkerMade=class'PawnShotMarker'
	
	// Muzzle Flash
	bSpawnMuzzleFlash=True
	MFBoneName="tube2"
	MFClass=class'MuzzleFlash_SawnOff'
	MFClass[2]=class'FX2.MuzzleFlash02'
	MFRelativeLocation=(X=0,Y=0,Z=0)
	MFRelativeRotation=(Yaw=15000)
	MFScale=(Min=0.8,Max=1.3) 
	MFSizeRange=(Min=20,Max=25) 
	MFLifetime=(Min=0.1,Max=0.1)
	
	// Meow! 
	CatFireSound=Sound'WeaponSounds.shotgun_catfire'
	CatBoneName="MESH_Barrel"
	CatRelativeLocation=(X=0,Y=-4.5,Z=16)
	CatRelativeRotation=(Pitch=16384,Yaw=0,Roll=-16384)
	StartShotsWithCat=4
	bAttachCat=True
}
