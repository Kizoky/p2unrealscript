// abstract stub class to allow third-person anims in awperson
class FistsWeapon extends ShovelWeapon;

var int ThirdAnimUsed;
var int AnimPlayed;
var bool bRightFist;

// Added by Man Chrzan: xPatch 2.0
var travel int FistsBloodTextureIndex;			   // index into following array
var array<Material> FistsBloodTextures;    // bloodier versions of this weapon skin
var() int FistBloodSkinIndex;			   // Index of hands model that gets more and more bloody.
var Texture CurrentHandsTex;


simulated function PlayFiring()
{
	if (bRightFist)
	{
		//randomly pick the animation to use (right)
		AnimPlayed = rand(2);
		switch (AnimPlayed)
		{
		   case 0:
				PlayAnim('right_jab', WeaponSpeedShoot2 + (WeaponSpeedShoot2Rand*FRand()));
				break;
		   case 1:
				PlayAnim('right_uppercut', WeaponSpeedShoot2 + (WeaponSpeedShoot2Rand*FRand()));
				break;
		}
		ThirdAnimUsed = AnimPlayed + 2;
		if ( WeaponAttachment(ThirdPersonActor) != None )
		{
			WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
		}
	}
	else
	{	
		//randomly pick the animation to use (left)
		AnimPlayed = rand(2);
		switch (AnimPlayed)
		{
		   case 0:
				PlayAnim('left_jab', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()));
				break;
	//       case 1:
	//            PlayAnim('left_downwards', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()));
	//            break;
		   case 1:
				PlayAnim('left_uppercut', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()));
				break;
		}
		ThirdAnimUsed = AnimPlayed;
		if ( WeaponAttachment(ThirdPersonActor) != None )
		{
			WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
		}
	}
	bRightFist = !bRightFist;

	if(bShowHint1)
	{
		bShowHint1=false;
		UpdateHudHints();
	}
}

simulated function PlayAltFiring()
{
	PlayAnim('left_downwards', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()));
	ThirdAnimUsed = 1;
	if ( WeaponAttachment(ThirdPersonActor) != None )
	{
		WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
	}
	if(!bShowHint1)
		TurnOffHint();
}

///////////////////////////////////////////////////////////////////////////////
// Changed by Man Chrzan: xPatch 2.0
// Set first person hands texture
///////////////////////////////////////////////////////////////////////////////
simulated function ChangeHandTexture(Texture NewHandsTexture, Texture DefHandsTexture, Texture NewFootTexture)
{
	CurrentHandsTex = NewHandsTexture;
	Skins[BloodSkinIndex] = Default.Skins[BloodSkinIndex];
	Skins[FistBloodSkinIndex] = NewHandsTexture;
}

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// Set our super-duper hands texture combiner
///////////////////////////////////////////////////////////////////////////////
function SetHandsBloodTexture(Material NewTex)
{
	local Combiner usetex;

	usetex = new(Outer) class'Combiner';
	usetex.CombineOperation = CO_Multiply;

	if(CurrentHandsTex != None)
		usetex.Material1 = CurrentHandsTex;
	else
		usetex.Material1 = Default.Skins[FistBloodSkinIndex];
	usetex.Material2 = NewTex;
	Skins[FistBloodSkinIndex] = usetex;
}


///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// Remove all blood from hands and dusters
///////////////////////////////////////////////////////////////////////////////
function CleanWeapon()
{
	BloodTextureIndex = 0;
	FistsBloodTextureIndex = 0;
	
	//Skins[0] = default.Skins[0];
	SetBloodTexture(default.Skins[BloodSkinIndex]);
	if(CurrentHandsTex != None)
		Skins[FistBloodSkinIndex] = CurrentHandsTex;
	else
		Skins[FistBloodSkinIndex] = default.Skins[FistBloodSkinIndex];
	//log(self$" clean weapon "$BloodTextureIndex$" new skin "$Skins[1]);
}


///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// Add more blood the weapon by incrementing into the blood texture array for
// skins
///////////////////////////////////////////////////////////////////////////////
function DrewBlood()
{
	// Can add blood, so do
    if(BloodTextureIndex < BloodTextures.Length)
	{
		// update the texture
	    SetBloodTexture(BloodTextures[BloodTextureIndex]);
		BloodTextureIndex++;
	}
	//log(self$" drew blood "$BloodTextureIndex$" new skin "$Skins[1]);

	// Can add more blood, so do
    if(FistsBloodTextureIndex < FistsBloodTextures.Length)
	{
		// update the texture
	    SetHandsBloodTexture(FistsBloodTextures[FistsBloodTextureIndex]);
		FistsBloodTextureIndex++;
	}
	//log(self$" drew blood "$BloodTextureIndex$" new skin "$Skins[1]);
}

// xPatch: Returns if we should clean or not + restores blood if needed. 
function bool RestoreBlood()
{
	if((P2GameInfoSingle(Level.Game) != None && P2GameInfoSingle(Level.Game).xManager.bKeepBlood && BloodTextureIndex != 0)
	|| (bForceBlood && BloodTextureIndex != 0))
	{
		SetBloodTexture(BloodTextures[BloodTextureIndex - 1]);	// NOTE: BloodTextureIndex defines the next blood skin so do -1
		SetHandsBloodTexture(FistsBloodTextures[FistsBloodTextureIndex - 1]);
		bForceBlood=False;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bUsesAltFire=true
	ItemName="Fists"
	AmmoName=class'FistsAmmoInv'
	PickupClass=None
	AttachmentClass=class'FistsAttachment'

	//Mesh=SkeletalMesh'AW7_EDWeapons.ED_Dusters_NEW'
	Mesh=SkeletalMesh'ED_Weapons.ED_Dusters_NEW'
	Skins[0]=Shader'AW7Tex.Weapons.InvisiblePistol'
	Skins[1]=Texture'MP_FPArms.LS_arms.LS_hands_dude'

	FirstPersonMeshSuffix="ED_Dusters_NEW"

	WeaponsPackageStr="AW7_EDWeapons."

	PlayerViewOffset=(X=4.5,Y=0.000,Z=-7.5)

	bMeleeWeapon=true
	ShotMarkerMade=None
	BulletHitMarkerMade=None
	PawnHitMarkerMade=class'PawnBeatenMarker'
    bDrawMuzzleFlash=false

	holdstyle=WEAPONHOLDSTYLE_Melee
	switchstyle=WEAPONHOLDSTYLE_Single
	firingstyle=WEAPONHOLDSTYLE_Melee

	//shakemag=350.000000
	//shaketime=0.200000
	//shakevert=(X=0.0,Y=0.0,Z=4.00000)
	FireOffset=(X=2.000000,Y=0.00000,Z=-1.00000)
	ShakeOffsetMag=(X=0,Y=6,Z=0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=3.0
	ShakeRotMag=(X=30.0,Y=250.0,Z=30.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=3.0

	//FireSound=Sound'WeaponSounds.baton_fire1'
	//AltFireSound=Sound'WeaponSounds.baton_fire2'
	CombatRating=1.0
	AIRating=0.05
	AutoSwitchPriority=1
	InventoryGroup=1
	GroupOffset=99
	BobDamping=0.975000
	ReloadCount=0
	TraceAccuracy=0.1
	ViolenceRank=1
	// Change by Man Chrzan: xPatch 2.0
	//bBumpStartsFight=true
	bBumpStartsFight=false
	bArrestableWeapon=false
	bCanThrow=false
	AI_BurstCountExtra=2
	AI_BurstCountMin=1
	AI_BurstTime=1.0

	WeaponSpeedIdle	   = 0.3
	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.25
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1=1.10
	WeaponSpeedShoot2=1.10
	WeaponSpeedShoot1Rand=0.100000
	WeaponSpeedShoot2Rand=0.100000
	AimError=200

	HudHint1="Press %KEY_Fire% to punch."
	HudHint2="Press %KEY_AltFire% for a powerful knockout blow!"
	DropWeaponHint1="Press %KEY_ToggleToHands% to put down your fists."
	DropWeaponHint2=""
	bCanThrowMP=false

	PlayerMeleeDist=100
	NPCMeleeDist=90.0
	MaxRange=90
	RecognitionDist=600
	
// Change by Man Chrzan: xPatch 2.0
// BloodTextures are now used for dusters
// FistsBloodTextures for hands 
	BloodSkinIndex=0
	BloodTextures[0]=Shader'AW7Tex.Weapons.InvisiblePistol'
	BloodTextures[1]=Shader'AW7Tex.Weapons.InvisiblePistol' 	
//	BloodTextures[0]=Texture'WeaponSkins_Bloody.LS_hands_dude_blood01'
//	BloodTextures[1]=Texture'WeaponSkins_Bloody.LS_hands_dude_blood02'
	
	FistBloodSkinIndex=1
	FistsBloodTextures[0]=Texture'xPatchTex.Weapons.Fists_Bloody1'
	FistsBloodTextures[1]=Texture'xPatchTex.Weapons.Fists_Bloody2'
	FistsBloodTextures[2]=Texture'xPatchTex.Weapons.Fists_Bloody3'
	
// Added by Man Chrzan: xPatch 2.0
	bCannotBeStolen=true
}
