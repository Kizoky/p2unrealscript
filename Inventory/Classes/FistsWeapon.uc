// abstract stub class to allow third-person anims in awperson
class FistsWeapon extends ShovelWeapon;

var int ThirdAnimUsed;
var int AnimPlayed;
var bool bRightFist;

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
// Set first person hands texture
///////////////////////////////////////////////////////////////////////////////
simulated function ChangeHandTexture(Texture NewHandsTexture, Texture DefHandsTexture, Texture NewFootTexture)
{
	Skins[1] = NewHandsTexture;
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

	Mesh=SkeletalMesh'AW7_EDWeapons.ED_Dusters_NEW'
	Skins[0]=Shader'AW7Tex.Weapons.InvisiblePistol'
	Skins[1]=Texture'MP_FPArms.LS_arms.LS_hands_dude'

	FirstPersonMeshSuffix="ED_Dusters_NEW"

	WeaponsPackageStr="AW7_EDWeapons."

	PlayerViewOffset=(X=10.000,Y=0.000,Z=-10.000)

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
	bBumpStartsFight=true
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
	BloodTextures[0]=Texture'WeaponSkins_Bloody.LS_hands_dude_blood01'
	BloodTextures[1]=Texture'WeaponSkins_Bloody.LS_hands_dude_blood02'
	BloodSkinIndex=1
}
