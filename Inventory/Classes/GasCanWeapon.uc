///////////////////////////////////////////////////////////////////////////////
// GasCanWeapon
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Gas can weapon (first and third person).
//
//	History:
//		01/29/02 MJR	Started history, probably won't be updated again until
//							the pace of change slows down.
//
///////////////////////////////////////////////////////////////////////////////

class GasCanWeapon extends P2WeaponStreaming;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////

var GasPourFeeder gaspour;
var bool	bPerformingAltFire;
var Sound	soundMatchStrike;
var() Rotator FireRotator;

const MATCH_LAUNCH_VEL_MAG	=	800;

// Change by NickP: MP fix
replication
{
	// functions client sends to server
	reliable if (Role < ROLE_Authority)
		xCallEndStream;
}

function xCallEndStream()
{
	GotoState('EndStream');
}
// End

///////////////////////////////////////////////////////////////////////////////
// Play animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
	{
	// This "throw the match" animation must include a notification that
	// call Notify_LightMatch() in order for the match to actually work!
	PlayAnim('Shoot2', WeaponSpeedShoot2, 0.05);
	}

///////////////////////////////////////////////////////////////////////////////
// we don't shoot things
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
	{
	// STUB
	}

///////////////////////////////////////////////////////////////////////////////
// Make the gas pour go to the end of the gun and orient itself
///////////////////////////////////////////////////////////////////////////////
function SnapGasPourToGun(optional bool bInitArc)
	{
	local vector startpos, X,Y,Z;
	local vector forward;
	local Rotator myrot;

	// orient gas pour and reposition
	myrot = Instigator.GetViewRotation();
	myrot.Pitch += FireRotator.Pitch;
	myrot.Pitch = myrot.Pitch & 65535;
	myrot.Yaw += FireRotator.Yaw;
	myrot.Yaw = myrot.Yaw & 65535;
	myrot.Roll += FireRotator.Roll;
	myrot.Roll = myrot.Roll & 65535;

	GetAxes(myrot,X,Y,Z);
	forward = Normal(vector(myrot));
	startpos = GetFireStart(X,Y,Z);// + forward*4;
	gaspour.SetLocation(startpos);
	gaspour.SetDir(startpos, vector(myrot),,bInitArc);
	}


///////////////////////////////////////////////////////////////////////////////
// Generate a match
///////////////////////////////////////////////////////////////////////////////
function GenerateMatch()
	{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local FireMatch thematch;

	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
	thematch = spawn(class'FireMatch',Instigator,,StartTrace, AdjustedAim);
	if(thematch != None)
		thematch.Velocity = MATCH_LAUNCH_VEL_MAG*Normal(vector(thematch.Rotation));
	}
/*
///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////
simulated function LocalAltFire()
	{
	PlayAltFiring();
	}
*/

///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////
function ServerAltFire()
	{
	bPerformingAltFire=true;

	GotoState('AltFireState');
	LocalAltFire();
	}


///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////
function ServerFire()
	{
	bPerformingAltFire=false;

	Super.ServerFire();
	}

///////////////////////////////////////////////////////////////////////////////
// Terminate the stream
///////////////////////////////////////////////////////////////////////////////
simulated function bool ForceEndFire()
	{
	if(gaspour != None)
		{
		gaspour.ToggleFlow(0.0, false);
		gaspour = None;
		return Super.ForceEndFire();
		}
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Animation notification called when the correct point is reached in the
// "light the match" animation.
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_LightMatch()
	{
	// Generates this in anim
	//Instigator.PlaySound(soundMatchStrike, SLOT_None, 1.0);
	GenerateMatch();
	TurnOffHint();
	}

///////////////////////////////////////////////////////////////////////////////
// Streaming, make gas come out in this mode
///////////////////////////////////////////////////////////////////////////////
simulated state Streaming
{
	simulated function Tick( float DeltaTime )
	{
		// Change by NickP: MP fix
		/*// Cut immediately if you stop early
		if(!Instigator.PressingFire())
			GotoState('EndStream');
		else
		{
			SnapGasPourToGun();

			ReduceAmmo(DeltaTime);
		}*/
		// Cut immediately if you stop early
		if( NotDedOnServer() )
		{
			if( !Instigator.PressingFire() )
			{
				xCallEndStream();
				GotoState('EndStream');
			}
		}
		///steam 12/10/2016
		if( AmmoType != None && AmmoType.HasAmmo() )
		{
			SnapGasPourToGun();
			ReduceAmmo(DeltaTime);
		}
		else
		{
			xCallEndStream();
			GotoState('EndStream');
		}
		// End
	}

	simulated function EndState()
	{
		Super.EndState();
		ForceEndFire();
	}

	simulated function BeginState()
	{
		Super.BeginState();
		gaspour = spawn(class'GasPourFeeder',Instigator,,,Rotation);
		gaspour.MyOwner = Owner;
		SnapGasPourToGun(true);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
	{
	function BeginState()
		{

		bPerformingAltFire=false;

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
///////////////////////////////////////////////////////////////////////////////
state AltFireState extends NormalFire
{
	function Tick( float DeltaTime )
		{
		if(!bPerformingAltFire)
			SnapGasPourToGun();
		}
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bNoHudReticle=true
	bUsesAltFire=true
	ItemName="Gas Can"
	AmmoName=class'GasCanBulletAmmoInv'
	PickupClass=class'GasCanPickup'
	AttachmentClass=class'GasCanAttachment'
	bMeleeWeapon=true

//	Mesh=Mesh'FP_Weapons.FP_Dude_GasCan'
	Mesh=Mesh'MP_Weapons.MP_LS_GasCan'

//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="GasCan"
    //PlayerViewOffset=(X=2.0000,Y=0.000000,Z=-1.0000)
	PlayerViewOffset=(X=4.0000,Y=0.000000,Z=-6.0000)
	FireOffset=(X=40.0000,Y=10.000000,Z=-1.00000)
	FireRotator=(Pitch=0,Yaw=-1500,Roll=0)

	holdstyle=WEAPONHOLDSTYLE_Pour
	switchstyle=WEAPONHOLDSTYLE_Carry
	firingstyle=WEAPONHOLDSTYLE_Pour

	aimerror=0.000000
	//shakemag=0.000000
	//shaketime=0.000000
	//shakevert=(X=0.0,Y=0.0,Z=0.00000)
	//shakespeed=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetMag=(X=1.0,Y=1.0,Z=1.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2
	ShakeRotMag=(X=50.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2

	AIRating=0.15
	AutoSwitchPriority=5
	InventoryGroup=5
	GroupOffset=1
	BobDamping=0.975000
	ReloadCount=0
	ViolenceRank=1
	bBumpStartsFight=false
	TraceAccuracy=0.9

	soundStart = Sound'WeaponSounds.GasCan_Start'
	soundLoop1 = Sound'WeaponSounds.GasCan_Loop'
	soundLoop2 = Sound'WeaponSounds.GasCan_Loop'
	soundEnd = Sound'WeaponSounds.GasCan_End'
	soundMatchStrike = Sound'WeaponSounds.Match_Light'
	RecognitionDist=900
	PlayerMeleeDist=200
	NPCMeleeDist=200.0

	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.5
	WeaponSpeedReload  = 1.5
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.2
	WeaponSpeedShoot2  = 1.0

	HudHint1="Press %KEY_AltFire% to toss a match."
	HudHint2=""
	bAllowHints=true
	bShowHints=true
	}
