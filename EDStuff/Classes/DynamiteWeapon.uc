///////////////////////////////////////////////////////////////////////////////
// DynamiteWeapon.uc
// by Man Chrzan for xPatch 2.0.
//
// Completly new re-written and clean code for Dynamite.
// This one extends Grenade so we can save a lot of unnecessary shit.
///////////////////////////////////////////////////////////////////////////////

class DynamiteWeapon extends GrenadeWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var Sound   DynamiteFuse;
var float DetonateTime;
var float DetonateTimeStart;
var float SaveDetonateTime;
var bool bDetonateChargedTimeSaved;

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
// Normal projectile fire, plus check where to make the danger marker to 
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function ProjectileFire()
{
	// STUB
}
///////////////////////////////////////////////////////////////////////////////
// Normal projectile fire, plus check where to make the danger marker to 
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function ProjectileAltFire()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// WE don't throw grenades
///////////////////////////////////////////////////////////////////////////////
function ThrowGrenade()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_ThrowDynamite()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local DynamiteProjectile dyn;
	local DynamiteAltProjectile dyn2;
	local float ExploTime;
	
	if(P2AmmoInv(AmmoType) != None
		&& AmmoType.HasAmmo())
	{
		CalcAIChargeTime();
		// Alt-firing the grenade, drops it at your feet, and doesn't
		// arm it
		if(bAltFiring)
		{
			ChargeTime = 0.0;
			FireOffset = AltFireOffset;
		}
		else
		{
			FireOffset = default.FireOffset;
		}

		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z); 
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
		// Make sure we're not generating this on the other side of a thin wall
		//if(FastTrace(Instigator.Location, StartTrace))
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			if(bAltFiring)
				dyn2 = spawn(class'DynamiteAltProjectile',Instigator,,StartTrace, AdjustedAim);
			else
			{
				dyn = spawn(class'DynamiteProjectile',Instigator,,StartTrace, AdjustedAim);
				
				// Reduce the projectile's explosion time depending on how long we charged the weapon.
				ExploTime = class'DynamiteProjectile'.Default.DetonateTime - SaveDetonateTime;
				dyn.SetupDynamite(ExploTime);
			}

			// Dynamite
			if(dyn != None)
			{
				dyn.Instigator = Instigator;
				
				// Compensate for catnip time, if necessary. Don't do this for NPCs
				if(FPSPawn(Instigator) != None
					&& FPSPawn(Instigator).bPlayer)
					ChargeTime /= Level.TimeDilation;

				dyn.SetupThrown(ChargeTime);
				P2AmmoInv(AmmoType).UseAmmoForShot();
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
					HitActor.Bump(dyn);
			}
			
			// Alt Dynamite
			if(dyn2 != None)
			{
				//gren2.SetFuseTime(DetonateTime);
				dyn2.Instigator = Instigator;

				// Compensate for catnip time, if necessary. Don't do this for NPCs
				if(FPSPawn(Instigator) != None
					&& FPSPawn(Instigator).bPlayer)
					ChargeTime /= Level.TimeDilation;

				dyn2.SetupThrown(ChargeTime);
				
				P2AmmoInv(AmmoType).UseAmmoForShot();
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
					HitActor.Bump(dyn2);
			}
		}
	}
	// Added by Man Chrzan: xPatch 2.0
	// Restored Dude's comment on throwing
	if(dyn != None && !bAltFiring)
		if(P2Player(Instigator.Controller) != None)
			P2Player(Instigator.Controller).CommentOnWeaponThrow();
	
	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None)
		ThirdPersonActor.bHidden=true;
}

///////////////////////////////////////////////////////////////////////////////
// If you drop your weapon, and you were charging (probably when you were dying)
// then drop a molotov too.
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
	// If you were charging, throw out a live one now
	if(IsInState('BeforeCharging')
		|| IsInState('Charging')
		|| IsInState('ChargeWaitGrenade'))
	{
		ChargeTime = ChargeTimeMinAI;
		Notify_ThrowDynamite();
	}

	Super.DropFrom(StartLocation);
}

///////////////////////////////////////////////////////////////////////////////
// FIX for Camera bug after holding for too long.
///////////////////////////////////////////////////////////////////////////////
function ThrowIt()
{
	local PlayerController P;
	
	GotoState('NormalFire');

	// Determine shake speeds here--they are determined by throw strength
	if(!bAltFiring)
		ShakeRotMag.y = SHAKE_Y_MOD;
	PlayFiring();
}

///////////////////////////////////////////////////////////////////////////////
// Charging
// But... dynamite explodes if hold for too long.
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
		local DynamiteExplosion exp;
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
				
				// explode, end fuse sound, take ammo, get next dynamite.
				exp = spawn(class'DynamiteExplosion',Self,,);
				Instigator.AmbientSound = None;
				P2AmmoInv(AmmoType).UseAmmoForShot();
				Instigator.Controller.bFire = 0;
				GotoState('Reloading');
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
		// play fuse sound
		Instigator.AmbientSound = DynamiteFuse;

		//Dopamine Begin the self detonation timer
		StartDetonateChargeTime();
	}
	
	simulated event EndState()
	{
		// end fuse sound
		Instigator.AmbientSound = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Keep recording our detonate time
///////////////////////////////////////////////////////////////////////////////
state ChargeWaitGrenade
{
	ignores Fire, AltFire, ServerFire, ServerAltFire;

	simulated function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);
		
		// Record it here too!
		RecordDetonateChargeTime();
	}
	
	simulated function AnimEnd(int Channel)
	{
		Super.AnimEnd(Channel);
	}

	simulated function BeginState()
	{
		Super.BeginState();
	}
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


function StartDetonateChargeTime()
{
	bDetonateChargedTimeSaved=false;
	// record our start time
	DetonateTimeStart = Level.TimeSeconds;
}

function RecordDetonateChargeTime()
{
	DetonateTime = Level.TimeSeconds - DetonateTimeStart;
	SaveDetonateTime = DetonateTime;
	
	// For Testing 
	// P2Player(Instigator.Controller).ClientMessage("Detonate Time:"@SaveDetonateTime@"/ 7.00");
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ItemName="Dynamite"
	AmmoName=Class'DynamiteAmmoInv'
	PickupClass=class'DynamitePickup'
	AttachmentClass=class'DynamiteAttachment'

    Mesh=SkeletalMesh'ED_Weapons.ED_Dynamite_NEW'
	Skins(0)=Texture'ED_WeaponSkins.Melee.trippo'
	Skins(1)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins(2)=Texture'ED_WeaponSkins.Launching.dynamite'
	FirstPersonMeshSuffix="Dynamite"
	
	PlayerViewOffset=(X=1.000000,Z=-16.000000,Y=0.000000)

    bDrawMuzzleFlash=False

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Toss
	firingstyle=WEAPONHOLDSTYLE_Toss

	FireSound=Sound'EDWeaponSounds.Heavy.DynamiteThrow'
	AIRating=0.53
	AutoSwitchPriority=6
	InventoryGroup=6
	GroupOffset=6
	ReloadCount=0
	TraceAccuracy=0.1
	ShotCountMaxForNotify=0
	ViolenceRank=2
	bThrownByFiring=true
	
	WeaponSpeedIdle	   = 0.5
	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.0
	WeaponSpeedReload  = 1.0
	WeaponSpeedChargeIntro  = 0.8
	WeaponSpeedCharge  = 0.5
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.1
	WeaponSpeedShoot2  = 1.0 

	AimError=500
	ChargeDistRatio=1600
	ChargeTimeMaxAI=1.5
	ChargeTimeMinAI=0.7

	MaxRange=2048
	MinRange=512
	RecognitionDist=500

	NoAmmoChangeState = "EmptyDownWeapon"

	AltHint1="Press %KEY_AltFire% to place unlit stick."
    AltHint2="Then shoot or ignite it at a distance to trigger."
	
	DynamiteFuse=Sound'WeaponSounds.molotov_lightloop'
	
	BobDamping=1.12 
	bAllowMiddleFinger=False
	}
