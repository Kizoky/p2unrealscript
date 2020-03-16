///////////////////////////////////////////////////////////////////////////////
// GrenadeWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Grenades that you throw.
//
///////////////////////////////////////////////////////////////////////////////

class DynamiteWeapon extends P2Weapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var float ChargeTime;			// How long we've been charging the grenade to get ready to throw

var Sound   dynamitefusehold;


var float DetonateTime;
var float MaxDetonateTime;
var float DetonateTimeStart;
var bool bDetonateChargedTimeSaved;
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

}
simulated function PlayAltFiring()
{
	Super.PlayAltFiring();

}

///////////////////////////////////////////////////////////////////////////////
simulated function PlayChargingIntro()
{
	PlayAnim('Shoot1Prep', WeaponSpeedChargeIntro, 0.05);

    P2MocapPawn(Instigator).PlayGrenadePullPin();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event Timer()
{
	if (IsInState(ChargeWaitState) || IsInState('Charging'))
	{
		Instigator.PlaySound(dynamitefusehold, SLOT_Misc, 1.0, false, 512.0, 1.0);
		SetTimer(GetSoundDuration(dynamitefusehold), false);
	}
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
		ThrowDynamite();
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

		DetonateTime=ChargeTime;

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
function Notify_ThrowDynamite()
{
	if(!bAltFiring
		|| (Level.Game != None
			&& FPSGameInfo(Level.Game).bIsSinglePlayer))
		ThrowDynamite();


}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ThrowDynamite()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local DynamiteProjectile gren;

        ReloadCount--;

	 if (ReloadCount == 0)
        {
          bForceReload = true && ReloadCount == 10;
        }

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
				gren = spawn(class'DynamiteProjectile',Instigator,,StartTrace, AdjustedAim);
			else
				gren = spawn(class'DynamiteAltProjectile',Instigator,,StartTrace, AdjustedAim);

			// Make sure it got made, it could have gotten spawned in a wall and not made
			if(gren != None)
			{
				//dopamine set the fuse time
				gren.SetFuseTime(DetonateTime);
//log("fff"$15-detonatetime);


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
			}
		}
	}
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
		|| IsInState('ChargeWaitDynamite'))
	{
		ChargeTime = 0.0;
		ThrowDynamite();
	}

	Super.DropFrom(StartLocation);
}



function StartDetonateChargeTime()
{
	bDetonateChargedTimeSaved=false;
	// record our start time
	DetonateTimeStart = Level.TimeSeconds;
}

function RecordDetonateChargeTime()
{
//	local float UseTime1;
//
//	if(!bDetonateChargedTimeSaved)
//	{
//		UseTime1 = Level.TimeSeconds;
//

		//if((UseTime1 - DetonateTime) > CHARGE_HINT_TIME)
		//	TurnOffHint();
//log("asdf"$detonateTime$"-"$usetime1);
		//DetonateTime = ChargeTimeModifier*(UseTime1 - DetonateTime)/100;
		DetonateTime = Level.TimeSeconds - DetonateTimeStart;

//	}
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
		local RocketExplosion exp;
		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			//Dopamine Save the amount of time you have held the lit dynamite
			RecordDetonateChargeTime();

			if(!Instigator.PressingFire())
			{
				// Save the time you've been charging up for, since you left before
				// ChargeWaiting. That is, we've left before the max charge time.
				// So record it here.
				RecordChargeTime();
				ThrowIt();
				ClientThrowIt();
			}

			//Dopamine fuse timer
			if (DetonateTime > class'DynamiteProjectile'.Default.DetonateTime)
			{


				bDetonateChargedTimeSaved=true;
				RecordChargeTime();
				//exp = spawn(class'RocketExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal);

				GotoState('Idle');
				exp = spawn(class'RocketExplosion',Self,,);
				//ThrowIt();
				//ClientThrowIt();
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
		Timer();

		//Dopamine Begin the self detonation timer
		StartDetonateChargeTime();
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
state ChargeWaitDynamite
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
// Play reloading
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReloading()
	{
        PlayAnim('Load', WeaponSpeedReload, 0.05);

	P2MocapPawn(Instigator).PlayWeaponSwitch(self);
	EndState();

	Instigator.PlaySound(ReloadSound, SLOT_Misc, 1.0);
	}

/* Force reloading even though clip isn't empty.  Called by player controller exec function,
and implemented in idle state */
simulated function ForceReload();

function ServerForceReload()
{
	bForceReload = true;
}

simulated function ClientForceReload()
{
	bForceReload = true;
	GotoState('Reloading');
}

simulated function bool NeedsToReload()
{
	return ( bForceReload || (Default.ReloadCount > 0) && (ReloadCount == 0) );
}

state Reloading
{
	function ServerForceReload() {}
	function ClientForceReload() {}
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire()
	{
		bForceFire = true;
	}

	function ServerAltFire()
	{
		bForceAltFire = true;
	}

	simulated function bool PutDown()
	{
		bChangeWeapon = true;
		return True;
	}

	simulated function BeginState()
	{
		if ( !bForceReload )
		{
			if ( Role < ROLE_Authority )
				ServerForceReload();
			else
				ClientForceReload();
		}
		bForceReload = false;
		PlayReloading();
	}

	simulated function AnimEnd(int Channel)
	{
		ReloadCount = Default.ReloadCount;
		if ( Role < ROLE_Authority )
			ClientFinish();
		else
			Finish();
		CheckAnimating();
	}

	function CheckAnimating()
	{
		if ( !IsAnimating() )
			warn(self$" stuck in Reloading and not animating!");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     dynamitefusehold=Sound'EDWeaponSounds.Heavy.fuse_short_loop'
     MaxDetonateTime=5.000000
     ChargeWaitState="ChargeWaitDynamite"
     ChargeTimeModifier=1.500000
     ChargeDistRatio=1800.000000
     ChargeTimeMaxAI=1.500000
     WeaponSpeedChargeIntro=0.750000
     WeaponSpeedCharge=0.380000
     AltFireOffset=(X=35.000000,Y=18.000000,Z=-18.000000)
     bShowMainHints=True
     AltHint1="Press %KEY_AltFire% to"
     AltHint2="place unarmed Dynamite."
     ViolenceRank=6
     RecognitionDist=600.000000
     ShotCountMaxForNotify=0
     holdstyle=WEAPONHOLDSTYLE_Toss
     switchstyle=WEAPONHOLDSTYLE_Toss
     firingstyle=WEAPONHOLDSTYLE_Toss
     bThrownByFiring=True
     NoAmmoChangeState="EmptyDownWeapon"
     MinRange=400.000000
     ShakeOffsetTime=2.000000
     HudHint1="Hold %KEY_Fire% to"
     HudHint2="charge them longer."
     FirstPersonMeshSuffix="FP_Dynamite"
     WeaponsPackageStr="ED_Weapons."
     WeaponSpeedLoad=1.250000
     WeaponSpeedReload=1.250000
     WeaponSpeedHolster=1.500000
     WeaponSpeedShoot1Rand=0.500000
     WeaponSpeedShoot2=2.000000
     WeaponSpeedIdle=0.400000
     AmmoName=Class'DynamiteAmmoInv'
     ReloadCount=1
     AutoSwitchPriority=6
     FireOffset=(X=35.000000,Y=20.000000,Z=18.000000)
     TraceAccuracy=0.050000
     aimerror=500.000000
     AIRating=0.550000
     MaxRange=2048.000000
     FireSound=Sound'EDWeaponSounds.Heavy.DynamiteThrow'
     InventoryGroup=6
     GroupOffset=4
     PickupClass=Class'DynamitePickup'
     //PlayerViewOffset=(X=1.000000)
     PlayerViewOffset=(X=1.000000,Y=0.00,Z=-15)
     BobDamping=0.975000
     AttachmentClass=Class'DynamiteAttachment'
     ItemName="Dynamite"
//     Texture=Texture'ED_Hud.HUDdynamite'
     Mesh=SkeletalMesh'ED_Weapons.ED_Dynamite_NEW'
     Skins(0)=Texture'ED_WeaponSkins.Melee.trippo'
     Skins(1)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     Skins(2)=Texture'ED_WeaponSkins.Launching.dynamite'
     AmbientGlow=128
}
