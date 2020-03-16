///////////////////////////////////////////////////////////////////////////////
// FlameWeapon
// By: Dopamine, Kamek
// For: Eternal Damnation
//
// Flamethrower weapon for ED.
// Uses a Zippo Lighter and a spray can of some flammable material to shoot
// flames at hapless bystanders.
///////////////////////////////////////////////////////////////////////////////

class FlameWeapon extends P2WeaponStreaming;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, etc.
///////////////////////////////////////////////////////////////////////////////
var() class<P2Projectile> ProjClass;	// Class of projectile spawned

var bool bBotFiring;
var bool bBotDone;
var() float BotFireTime;				// How often AI pawns should fire this

///////////////////////////////////////////////////////////////////////////////
// BotFire()
//  called by NPC firing weapon.  Weapon chooses appropriate firing mode to use (typically no change)
//  bFinished should only be true if called from the Finished() function
//  FiringMode can be passed in to specify a firing mode (used by scripted sequences)
//
// This was copied from Weapon but changed a lot.
///////////////////////////////////////////////////////////////////////////////
function bool BotFire(bool bFinished, optional name FiringMode)
{
	if ( !bFinished && !IsIdle() )
		return false;
	Instigator.Controller.bFire = 1;
	Instigator.Controller.bAltFire = 0;

	bBotFiring = True;
	bBotDone = False;
	Fire(1.0);

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Initialize the spawned projectile
///////////////////////////////////////////////////////////////////////////////
function SpecificInits(P2Projectile SpawnedProj)
{
	// STUB. Nothing needed here yet.
}

///////////////////////////////////////////////////////////////////////////////
// Set first person hands texture
///////////////////////////////////////////////////////////////////////////////
simulated function ChangeHandTexture(Texture NewHandsTexture, Texture DefHandsTexture, Texture NewFootTexture)
{
	Skins[2] = NewHandsTexture;
}

///////////////////////////////////////////////////////////////////////////////
// Spawn the flamethrower projectile
// Technically, we're supposed to do this in the ammo, not here in the weapon
///////////////////////////////////////////////////////////////////////////////
function SpawnFlame()
{
	local vector StartTrace, X,Y,Z;
	local P2Projectile FProj;

	// Get spawn location
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);

	// Spawn the projectile
	FProj = spawn(ProjClass, Instigator,, StartTrace, AdjustedAim);

	// Initialize the projectile
	SpecificInits(FProj);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Streaming
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Streaming
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			// Let bystanders shoot us
			if(AmmoType.HasAmmo() && (
			Instigator.PressingFire()
			|| (bBotFiring && bBotDone)
			)
			)
			{
				PlayFiring();
			}
			else
			{
				EndStreaming();
				ServerEndStreaming();
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Reduce our ammo, spawn flames
	///////////////////////////////////////////////////////////////////////////////
	simulated event Tick( float DeltaTime )
	{
		if (Role == ROLE_Authority)
			if (ReduceAmmo(DeltaTime))
				SpawnFlame();

		Super.Tick(DeltaTime);
/*
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
				if(Level.NetMode != NM_Standalone)
					EndStreaming();
			}
		}
*/
	}
	///////////////////////////////////////////////////////////////////////////////
	// Set to seeking when you get to this state
	///////////////////////////////////////////////////////////////////////////////
	simulated event BeginState()
	{
		PlayFiring();
		if (bBotFiring)
			SetTimer(BotFireTime, false);
	}

	simulated event Timer()
	{
		bBotDone = True;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ProjClass=class'FlameProjectile'

	bNoHudReticle=True
	ItemName="Flamethrower"
	AmmoName=class'FlameAmmoInv'
	PickupClass=class'FlamePickup'
	AttachmentClass=class'FlameAttachment'
	bMeleeWeapon=false

	Mesh=SkeletalMesh'ED_Weapons.ED_FlameThrower_NEW'
	Skins[0]=Texture'ED_WeaponSkins.Melee.trippo'
	Skins[1]=Texture'ED_WeaponSkins.Melee.lynx'
	Skins[2]=Texture'MP_FPArms.LS_arms.LS_hands_dude'

	//PlayerViewOffset=(X=0.0000,Y=-1.000000,Z=-2.0000)
	PlayerViewOffset=(X=0.0000,Y=-8.000000,Z=-10.0000)
	FireOffset=(X=50.0000,Y=-10.00000,Z=0.00000)

    bDrawMuzzleFlash=False

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Single
	firingstyle=WEAPONHOLDSTYLE_Single

	aimerror=0.000000
	ShakeOffsetMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetTime=0
	ShakeRotMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotTime=0

	CombatRating=1.2
	AIRating=0.1
	AutoSwitchPriority=1
	InventoryGroup=5
	GroupOffset=10
	BobDamping=0.975000
	ReloadCount=0
	ViolenceRank=1
	TraceAccuracy=0.01
	AI_BurstCountExtra=10
	AI_BurstCountMin=5
	AI_BurstTime=0.0

	soundStart = Sound'AW7Sounds.Flame.FlameIn'
	soundLoop1 = Sound'AW7Sounds.Flame.FlameLoop'
	soundEnd = Sound'AW7Sounds.Flame.FlameOut'

	WeaponSpeedHolster = 1.0
	WeaponSpeedLoad    = 1.2
	WeaponSpeedReload  = 1.25
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=1.0
	WeaponSpeedShoot2  = 1.0

	WeaponSpeedPrep=0.8
	WeaponSpeedEnd=0.8

	RecognitionDist=500
	PlayerMeleeDist=120
	NPCMeleeDist=80.0
	MaxRange=100

	AmmoUseRate=10.0
	AmmoGainRate=0.0

	bDelayedStartSound=true

	BotFireTime=5.00
	
	ThirdPersonRelativeLocation=(X=8.000000,Y=-3.000000,Z=-5.000000)	
}
