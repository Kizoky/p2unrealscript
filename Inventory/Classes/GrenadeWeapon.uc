///////////////////////////////////////////////////////////////////////////////
// GrenadeWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Grenades that you throw.
//
///////////////////////////////////////////////////////////////////////////////

class GrenadeWeapon extends CatableWeapon; //P2Weapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var float ChargeTime;			// How long we've been charging the grenade to get ready to throw
								// it. This corresponds to how far it will go
var bool  bChargedTimeSaved;	// If we've gotten our charge time once, don't get it again
var name  ChargeWaitState;		// Name of our charge waiting state. Extended classes of this
								// weapon must have their own, in case they extend the base Charging state
var float ChargeTimeModifier;	// Multiplier for how fast to charge
var float ChargeDistRatio;		// Ratio used to determine how long AI should make the charge time
								// for this weapon, in order to hit it's target.
var float ChargeTimeMaxAI;		// Max charge time allowed for AI characters.
var float ChargeTimeMinAI;		// Min charge time allowed for AI characters (so they're
								// less likely to hurt themselves).

var float WeaponSpeedChargeIntro;	// How fast the intro anim to the charging animation should play
var float WeaponSpeedCharge;	// How fast the charging animation should play

var vector AltFireOffset;		// Spot grenade comes out for alt fire

var travel bool bShowMainHints;		// Show the main hints
var localized string AltHint1;	// How to drop an un-armed grenade
var localized string AltHint2;

var class<AnimalPawn> CatGrenadeClass;

const CHARGE_HINT_TIME	=	0.5;
const SHAKE_Y_MOD		=	400;
const MIN_REQ_CHARGE_TIME=	0.8;
const MIN_REQ_BEFORE_TIME=	0.3;

replication
{
	// functions client sends to server
	reliable if (Role < ROLE_Authority)
		ThrowIt, RecordChargeTime, ServerStartChargeTime;
}


/*
///////////////////////////////////////////////////////////////////////////////
// Modify your speed based on your owners body speed
///////////////////////////////////////////////////////////////////////////////
function ChangeSpeed(float NewSpeed)
{
	Super.ChangeSpeed(NewSpeed);
	WeaponSpeedChargeIntro = default.WeaponSpeedChargeIntro*NewSpeed;
	WeaponSpeedCharge = default.WeaponSpeedCharge*NewSpeed;
	ChargeTimeModifier = default.ChargeTimeModifier*NewSpeed;
}
*/

///////////////////////////////////////////////////////////////////////////////
// Check to restore proper hints
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	Super.TravelPostAccept();

	if(bAllowHints)
	{
		if(!bShowMainHints)
		{
			// Swap out hints to show
			HudHint1 = AltHint1;
			HudHint2 = AltHint2;
		}
	}
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
///////////////////////////////////////////////////////////////////////////////
simulated function PlayChargingIntro()
{
	PlayAnim('Shoot1Prep', WeaponSpeedChargeIntro, 0.05);

    P2MocapPawn(Instigator).PlayGrenadePullPin();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayCharging()
{
	PlayAnim('ShootDistance', WeaponSpeedCharge, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayChargeWait()
{
	PlayAnim('ShootDistanceMax', 1.0, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	PlayAnim('Load', WeaponSpeedReload, 0.05);

	P2MocapPawn(Instigator).PlayWeaponSwitch(self);
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
// Drop a grenade like mine at your feet, explodes on enemy touch.
//
// Only spawn them here in MP because the anim notify can't keep up
// when it plays so fast.
///////////////////////////////////////////////////////////////////////////////
function ProjectileAltFire()
{
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		ThrowGrenade();
}

///////////////////////////////////////////////////////////////////////////////
// Allow two sets of hud hints to explain primary, then alternative fire
///////////////////////////////////////////////////////////////////////////////
function TurnOffHint()
{
	if(bShowMainHints)
	{
		bShowMainHints=false;
		// Swap out hints to show
		HudHint1 = AltHint1;
		HudHint2 = AltHint2;
		UpdateHudHints();
	}
	else
		Super.TurnOffHint();
}

///////////////////////////////////////////////////////////////////////////////
// AI characters determine by distance how far to throw/shoot projectiles
///////////////////////////////////////////////////////////////////////////////
function CalcAIChargeTime()
{
	local PersonController perc;
	local vector dir;

	perc = PersonController(Instigator.Controller);

	if(perc != None
		&& perc.Target != None)
	{
		// Find the distance to our attacker
		dir = (perc.Target.Location - Instigator.Location);

		// Figure out about how long to make the charge time for it to shoot to our target
		// and factor in bad AI charging times
		ChargeTime = VSize(dir)/(ChargeDistRatio + ((FRand()*AimError) - AimError/2));
		if(ChargeTime > ChargeTimeMaxAI)
			ChargeTime = ChargeTimeMaxAI;
		if(ChargeTime < ChargeTimeMinAI)
			ChargeTime = ChargeTimeMinAI;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Throw a grenade the same in both MP and SP.
// But in MP only, don't allow this to drop the grenade, do it on the start
// of the anim
///////////////////////////////////////////////////////////////////////////////
function Notify_ThrowGrenade()
{
	if(!bAltFiring
		|| (Level.Game != None
			&& FPSGameInfo(Level.Game).bIsSinglePlayer))
		ThrowGrenade();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ThrowGrenade()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local GrenadeProjectile gren;

	if(P2AmmoInv(AmmoType) != None
		&& AmmoType.HasAmmo())
	{
		CalcAIChargeTime();
		FireOffset = AltFireOffset;
		// Alt-firing the grenade, drops it at your feet, and doesn't
		// arm it
		if(bAltFiring)
		{
			ChargeTime = 0.0;
			FireOffset = AltFireOffset;
		}
		else
			FireOffset = default.FireOffset;

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
			if(!bAltFiring)
				gren = spawn(class'GrenadeProjectile',Instigator,,StartTrace, AdjustedAim);
			else
				gren = spawn(class'GrenadeAltProjectile',Instigator,,StartTrace, AdjustedAim);

			// Make sure it got made, it could have gotten spawned in a wall and not made
			if(gren != None)
			{
				gren.Instigator = Instigator;

				// Compensate for catnip time, if necessary. Don't do this for NPCs
				if(FPSPawn(Instigator) != None
					&& FPSPawn(Instigator).bPlayer)
					ChargeTime /= Level.TimeDilation;

				gren.SetupThrown(ChargeTime);
				//gren.AddRelativeVelocity(Instigator.Velocity);
				P2AmmoInv(AmmoType).UseAmmoForShot();
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
					HitActor.Bump(gren);
				
				// Added by Man Chrzan: xPatch 2.0 (Enhanced Mode stuff) 
				if (P2GameInfoSingle(Level.Game).VerifySeqTime() 
				&& Pawn(Owner).Controller.bIsPlayer
				&& !bAltFiring)
					gren.bDoSplit = True;
			}
		}
	}
	// Added by Man Chrzan: xPatch 2.0
	// Restored Dude's comment on throwing
	if(gren != None && !bAltFiring)
		if(P2Player(Instigator.Controller) != None)
			P2Player(Instigator.Controller).CommentOnWeaponThrow();
			
	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None)
		ThirdPersonActor.bHidden=true;
}

///////////////////////////////////////////////////////////////////////////////
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

	ServerFire();

	if ( Role < ROLE_Authority )
	{
		PrepCharge();
		GotoState('BeforeCharging');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerFire()
{
	PrepCharge();
	GotoState('BeforeCharging');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PrepCharge()
{
	// play our windup anim
	PlayChargingIntro();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerAltFire()
{
	Super.ServerAltFire();

	// Turn off alt-fire hint
	if(!bShowMainHints)
		TurnOffHint();
}

///////////////////////////////////////////////////////////////////////////////
// Actually throw the projectile
///////////////////////////////////////////////////////////////////////////////
function ThrowIt()
{
	GotoState('NormalFire');

	// Determine shake speeds here--they are determined by throw strength
	if(!bAltFiring)
		ShakeRotMag.y = ChargeTime*SHAKE_Y_MOD;
	PlayFiring();
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientThrowIt()
{
	LocalFire();
	GotoState('ClientFiring');
}

///////////////////////////////////////////////////////////////////////////////
// Save how long you charged for
///////////////////////////////////////////////////////////////////////////////
function RecordChargeTime()
{
	local float UseTime;

	if(!bChargedTimeSaved)
	{
		UseTime = Level.TimeSeconds;

		bChargedTimeSaved=true;
		if((UseTime - ChargeTime) > CHARGE_HINT_TIME)
			TurnOffHint();

		ChargeTime = ChargeTimeModifier*(UseTime - ChargeTime);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Begin to record your charge time
///////////////////////////////////////////////////////////////////////////////
function StartChargeTime()
{
	bChargedTimeSaved=false;
	// record our start time
	ChargeTime = Level.TimeSeconds;
}
///////////////////////////////////////////////////////////////////////////////
// Begin to record your charge time
///////////////////////////////////////////////////////////////////////////////
function ServerStartChargeTime()
{
	StartChargeTime();
}

///////////////////////////////////////////////////////////////////////////////
// If you drop your weapon, and you were charging (probably when you were dying)
// then drop a live grenade too.
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
	// If you were charging, throw out a live one now
	if(IsInState('BeforeCharging')
		|| IsInState('Charging')
		|| IsInState('ChargeWaitGrenade'))
	{
		ChargeTime = 0.0;
		ThrowGrenade();
	}

	Super.DropFrom(StartLocation);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerAnimEnd(int Channel)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Idle
//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
{
	///////////////////////////////////////////////////////////////////////////////
	// Make sure you're attachment is visible on idle start
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		if(ThirdPersonActor != None)
			ThirdPersonActor.bHidden=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// BeforeCharging
//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state BeforeCharging
{
	ignores Fire, AltFire, ServerFire, ServerAltFire;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		// Listen server grenade skips this state if you don't give it a little leeway
		if((Level.Game != None
				&& Level.Game.bIsSinglePlayer)
			|| Level.TimeSeconds - ChargeTime > MIN_REQ_BEFORE_TIME)
		{
			// If it's the guy playing that hosts the listen server
			// or it's a typical client/stand alone game.
			if(NotDedOnServer())
			{
				if(!Instigator.PressingFire())
				{
					ServerStartChargeTime();
				}
			}
			GotoState('Charging');
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		// Simply use charge time here initially to store the time to get
		// a valid AnimEnd out of the Listen Server.
		// We don't call the real StartChargeTime function here because this isn't
		// the official charge start.
		ChargeTime = Level.TimeSeconds;
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
	ignores Fire, AltFire, ServerFire, ServerAltFire;

	///////////////////////////////////////////////////////////////////////////////
	// Switch the waiting animation. We've reached max charge capacity.
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		// Check to make sure the Rocket launcher in listenserver mode didn't just hope
		// straight from this state into fully charged if you walk across it while
		// holding fire. It takes several seconds to charge the RL/grenade fully, so a small
		// check time is sufficient.
		if(Level.TimeSeconds - ChargeTime > MIN_REQ_CHARGE_TIME)
		{
			// Save the time you've been charging up for, since you left before ChargeWaiting
			RecordChargeTime();

			GotoState(ChargeWaitState);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Wait till they're not pressing fire to shoot it
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			if(!Instigator.PressingFire())
			{
				// Save the time you've been charging up for, since you left before
				// ChargeWaiting. That is, we've left before the max charge time.
				// So record it here.
				RecordChargeTime();
				ThrowIt();
				ClientThrowIt();
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		// play our charge anim
		PlayCharging();
		StartChargeTime();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ChargeWait
// Just wait and idle till they unpress fire and let you throw it, shoot it
// A seperate function so we can extend Charging above in other weapons
// such as the Launcher
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ChargeWaitGrenade
{
	ignores Fire, AltFire, ServerFire, ServerAltFire;

	///////////////////////////////////////////////////////////////////////////////
	// Wait till they're not pressing fire to shoot it
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			if(!Instigator.PressingFire())
			{
				// Save the time you've been charging up for, since you left before
				// ChargeWaiting. That is, we've left before the max charge time.
				// So record it here.
				RecordChargeTime();
				ThrowIt();
				ClientThrowIt();
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
	// Set to seeking when you get to this state
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		PlayChargeWait();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//	NormalFire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
	ignores ServerFire, ServerAltFire, DropFrom;
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//	xPatch
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// 	The same thing as in P2Weapon.uc but with removed shake effect.
///////////////////////////////////////////////////////////////////////////////
simulated function LocalAltFire()
{
	local PlayerController P;

	bPointing = true;
	
	if ( Affector != None )
		Affector.FireEffect();
	PlayAltFiring();
}	

///////////////////////////////////////////////////////////////////////////////
// Make sure that this gun is not extension!
///////////////////////////////////////////////////////////////////////////////
function bool CanSwapHands()
{
	return (Class == Class'GrenadeWeapon');
}

///////////////////////////////////////////////////////////////////////////////
// This gun is ready for a cat to be put on it
///////////////////////////////////////////////////////////////////////////////
function bool ReadyForCat()
{
	return (AmmoType.HasAmmo()
			&& CatOnGun==0
			&& !bPutCatOnGun
			&& IsInState('Idle')
			&& Class == Class'GrenadeWeapon');
}

function SwapCatOn()
{
	DropCat();
	PlaySound(Sound'WeaponSounds.grenade_pullpin');
	//CatViolateSound
}

function DropCat()
{
	local AnimalPawn CatGrenade;
	local CatInv tempcat;
	
	if(CatGrenadeClass == None)
	{
		CatGrenadeClass = class<AnimalPawn>(DynamicLoadObject("People.CatGrenadePawn", class'Class'));
		default.CatGrenadeClass = CatGrenadeClass;
	}
	
	if(CatOnGun == 1)
	{	
		CatGrenade = spawn(CatGrenadeClass,,, Location + vect(50,0,0), Rotation);
		if(CatGrenade != None) 
		{
			//CatGrenade.AddGrenade(0.9);
			
			if( CatSkin != None )
				CatGrenade.Skins[0] = CatSkin;
				
			if ( CatGrenade.Controller == None
				&& CatGrenade.Health > 0 )
			{
				if ( (CatGrenade.ControllerClass != None))
					CatGrenade.Controller = spawn(CatGrenade.ControllerClass);
				if ( CatGrenade.Controller != None )
				{
					CatGrenade.Controller.Possess(CatGrenade);
					CatGrenade.Controller.GotoState('FallingGrenade');
				}
				// Check for AI Script
				CatGrenade.CheckForAIScript();
			}
			
			SwapCatOff();
			CatOnGun=0;
			P2AmmoInv(AmmoType).UseAmmoForShot();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bUsesAltFire=true
	ItemName="Grenade"
	AmmoName=class'GrenadeAmmoInv'
	PickupClass=class'GrenadePickup'
	AttachmentClass=class'GrenadeAttachment'

	OldMesh=Mesh'FP_Weapons.FP_Dude_Grenade'
	Mesh=Mesh'MP_Weapons.MP_LS_Grenade'

//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="Grenade"
    //PlayerViewOffset=(X=1.0000,Y=0.000000,Z=-2.0000)
	PlayerViewOffset=(X=1.0000,Y=0.000000,Z=-12.0000)
	FireOffset=(X=35.0000,Y=20.000000,Z=18.00000)
	AltFireOffset=(X=35.0000,Y=18.0000,Z=-18.0000)

    bDrawMuzzleFlash=False

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Toss
	firingstyle=WEAPONHOLDSTYLE_Toss

	//shakemag=500.000000
	//shaketime=0.300000
	//shakevert=(X=1.0,Y=0.0,Z=1.00000)
	ShakeOffsetMag=(X=1.0,Y=1.0,Z=1.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2
	ShakeRotMag=(X=50.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2

	FireSound=Sound'WeaponSounds.grenade_fire'
	AIRating=0.55
	AutoSwitchPriority=6
	InventoryGroup=6
	GroupOffset=1
//	BobDamping=0.975000
	ReloadCount=0
	TraceAccuracy=0.05
	ShotCountMaxForNotify=0
	ViolenceRank=6
	bThrownByFiring=true

	WeaponSpeedIdle	   = 0.4
	WeaponSpeedHolster = 1.5
	WeaponSpeedChargeIntro  = 1.5
	WeaponSpeedCharge  = 0.75
	WeaponSpeedLoad    = 1.25
	WeaponSpeedReload  = 1.25
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.5
	WeaponSpeedShoot2  = 2.0

	AimError=500
	ChargeTimeModifier=1.5
	ChargeWaitState="ChargeWaitGrenade"
	ChargeDistRatio=1800
	ChargeTimeMaxAI=1.5

	MaxRange=2048
	MinRange=400
	RecognitionDist=600

	NoAmmoChangeState = "EmptyDownWeapon"

	HudHint1="Hold %KEY_Fire% to"
	HudHint2="charge them longer."
	AltHint1="Press %KEY_AltFire% to"
	AltHint2="place unarmed grenades."
	bAllowHints=true
	bShowHints=true
	bShowMainHints=true
	
	BobDamping=1.12 
	bDropInVeteranMode=1
	VeteranModeDropChance=0.75
	bAllowMiddleFinger=true
	}
