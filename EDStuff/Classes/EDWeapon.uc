/**
 * EDWeapon
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Ah, this old file, made years ago, and now part of an official RWS product,
 * movin' on up! Anyways this base inherits dual wielding capabilities and
 * here we also throw in selective fire capabilities
 *
 * @author Gordon Cheng
 */
class EDWeapon extends P2DualWieldWeapon
    abstract;

enum EFireMode
{
    FM_Semi,
    FM_Burst,
    FM_Auto,
};

// Accuracy based on fire mode.
var float TraceAccuracySemi;
var float TraceAccuracyBurst;
var float TraceAccuracyAuto;

var bool bDisplayFireMode;
var bool bSwitchesFireMode;
var bool bPerformsHeadshots;
var bool bThreeStageFire;
var bool bThreeStageReload;
var bool bPumpAfterReload;

var int NumberOfTraces;
var int NumberOfBursts;

var float WeaponSpeedPrepFire;
var float WeaponSpeedLoopFire;
var float WeaponSpeedEndFire;
var float WeaponSpeedPrepReload;
var float WeaponSpeedLoopReload;
var float WeaponSpeedEndReload;
var float WeaponSpeedPump;
var float WeaponSpeedSwitch;
var float WeaponSpeedBurst;

var name PrepFireAnim;
var name LoopFireAnim;
var name EndFireAnim;

var name PrepReloadAnim;
var name LoopReloadAnim;
var name EndReloadAnim;

var name PumpAnim;

var array<name> SelectAnims;
var array<name> DeselectAnims;
var array<name> FireAnims;
var array<name> IdleAnims;
var array<name> ReloadAnims;
var array<name> SwitchAnims;
var localized array<string> FireModeStrings;

var travel int MagazineCount;
var travel EFireMode FireMode;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool DoServerFireAgain(bool bForce)
{
	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
		return ((StopFiringTime > Level.TimeSeconds) || bForce
		|| Instigator.PressingFire()
		);
	else
		return ((StopFiringTime > Level.TimeSeconds) || bForce
		|| Instigator.PressingFire()
		);
}

/** Overriden to take into consideration dual wielding inputs  */
simulated function AltFire(float Value) {

    if (bSwitchesFireMode) {
        GotoState('SwitchFireMode');
        Instigator.Controller.bAltFire = 0;
    }
    else
        super.AltFire(Value);
}

function ServerFire()
{
	local int i;

    if (AmmoType == None)
	    GiveAmmo(Pawn(Owner));

	if (MagazineCount > 0
		&& AmmoType.HasAmmo())
	{
		if (FireMode == FM_Auto && bThreeStageFire)
		{
		    GotoState('PrepFire');
		    return;
        }
        else
            GotoState('NormalFire');

		if (FireMode != FM_Burst)
		{
            if (AmmoType.bInstantHit)
		    {
			    for (i=0; i<NumberOfTraces; i++)
					TraceFire(GetTraceAccuracy(), 0, 0);
		    }
		    else
			    ProjectileFire();

//		    MagazineCount--;
        }

		LocalFire();

		if (FireMode == FM_Semi || FireMode == FM_Burst)
            Instigator.Controller.bFire = 0;
	}
}

function TraceFire(float Accuracy, float YOffset, float ZOffset)
{
	local vector markerpos, markerpos2;
	local bool secondary;
	local BulletTracer bullt;
	local vector usev;
	local Rotator newrot;

	local vector HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
	EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (TraceDist * X);
	Other = Trace(LastHitLocation,HitNormal,EndTrace,StartTrace,True);
	AmmoType.ProcessTraceHit(self, Other, LastHitLocation, HitNormal, X,Y,Z);
	ShotCount++;

	if (bPerformsHeadshots && MpPawn(Other) != None && MpPawn(Other).IsMPHeadshot(LastHitLocation) && !MpPawn(Other).Controller.bIsPlayer)
    {
        P2Pawn(Other).ExplodeHead(LastHitLocation, 100000 * vector(Rotation));
        P2Pawn(Other).Died(Instigator.Controller, Class'BaseFX.BulletDamage', LastHitLocation);
    }

	if (P2GameInfo(Level.Game).bShowTracers)
	{
		usev = (LastHitLocation - StartTrace);

        if (Level.Game != None && FPSGameInfo(Level.Game).bIsSinglePlayer)
		{
			bullt = spawn(class'BulletTracer',Owner,,(LastHitLocation + StartTrace)/2);
			bullt.SetDirection(Normal(usev), VSize(usev));
		}
	}

	if (P2Player(Instigator.Controller) != None && FPSPawn(Other) != None)
		P2Player(Instigator.Controller).Enemy = FPSPawn(Other);

	if (ShotCount >= ShotCountMaxForNotify && Instigator.Controller != None)
	{
		ShotCount -= ShotCountMaxForNotify;
		markerpos = Instigator.Location;
		markerpos2 = LastHitLocation;
		secondary = true;

		if (ShotMarkerMade != None)
		    ShotMarkerMade.static.NotifyControllersStatic(Level, ShotMarkerMade, FPSPawn(Instigator), FPSPawn(Instigator), ShotMarkerMade.default.CollisionRadius, markerpos);

		if (P2Pawn(Other) != None && PawnHitMarkerMade != None)
			PawnHitMarkerMade.static.NotifyControllersStatic(Level, PawnHitMarkerMade, FPSPawn(Instigator), FPSPawn(Other), PawnHitMarkerMade.default.CollisionRadius, markerpos2);
		else if (secondary && BulletHitMarkerMade != None)
			BulletHitMarkerMade.static.NotifyControllersStatic(Level, BulletHitMarkerMade, FPSPawn(Instigator), None, BulletHitMarkerMade.default.CollisionRadius, markerpos2);
    }
}

simulated function float GetFireAnimRate()
{
    switch (FireMode)
    {
        case FM_Semi:    return WeaponSpeedShoot1;
        case FM_Burst:   return WeaponSpeedBurst;
        case FM_Auto:    return WeaponSpeedShoot2;
        default:         return 1.0;
    }
}

simulated function float GetTraceAccuracy()
{
	switch (FireMode)
    {
        case FM_Semi:    return TraceAccuracySemi;
        case FM_Burst:   return TraceAccuracyBurst;
        case FM_Auto:    return TraceAccuracyAuto;
        default:         return TraceAccuracy;
    }
}

simulated function bool NeedsToReload()
{
	// STUB no reloads
	return false;

//	return ( bForceReload || (Default.MagazineCount > 0) && (MagazineCount == 0) );
}

simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;

	if (!IsAnimating() || !AnimIsInGroup(0,GetPlaySelectAnim()))
		PlayAnim(SelectAnims[FireMode], WeaponSpeedLoad, 0.0);

	if (P2Player(Instigator.Controller) == None || !P2Pawn(Instigator).bPlayerStarting)
	    Instigator.PlaySound(SelectSound, SLOT_Misc, 1.0);
}

simulated function PlayDownAnim()
{
	if (FPSPawn(Instigator).MyBodyFire != None)
		PlayAnim(DeselectAnims[FireMode], 1000.0, 0.0);
	else
	{
		PlayAnim(DeselectAnims[FireMode], WeaponSpeedHolster, 0.05);
		Instigator.PlaySound(HolsterSound, SLOT_Misc, 1.0);
		P2MoCapPawn(Instigator).PlayWeaponDown();
	}
}

simulated function PlayIdleAnim()
{
	PlayAnim(IdleAnims[FireMode], WeaponSpeedIdle, 0);
}

simulated function PlayPrepFire()
{
    PlayAnim(PrepFireAnim, WeaponSpeedPrepFire);
}

simulated function PlayFiring()
{
	IncrementFlashCount();

	// ED fire sounds are a bit too loud, tone it down here
    if(Level.Game == None || !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(FireSound,SLOT_Interact,0.5,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else
		Instigator.PlaySound(FireSound, SLOT_None, 0.5, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

    if (FireMode == FM_Auto && bThreeStageFire)
        PlayAnim(LoopFireAnim, WeaponSpeedLoopFire, 0);
    else
        PlayAnim(FireAnims[FireMode], GetFireAnimRate() + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

simulated function PlayEndFire()
{
    PlayAnim(EndFireAnim, WeaponSpeedEndFire);
}

simulated function PlayPrepReload()
{
	// STUB
//    PlayAnim(PrepReloadAnim, WeaponSpeedPrepReload);
}

simulated function PlayReloading()
{
	// STUB
	/*
	P2MocapPawn(Instigator).PlayWeaponReload(self);
	Instigator.PlaySound(ReloadSound, SLOT_Misc, 1.0);

	if (bThreeStageReload)
	    PlayAnim(LoopReloadAnim, WeaponSpeedLoopReload);
    else
        PlayAnim(ReloadAnims[FireMode], WeaponSpeedReload, 0.05);
	*/
}

simulated function PlayEndReload()
{
	// STUB
    //PlayAnim(EndReloadAnim, WeaponSpeedEndReload);
}

simulated function PlayPump()
{
    PlayAnim(PumpAnim, WeaponSpeedPump);
    P2MocapPawn(Instigator).PlayWeaponSwitch(self);
}

simulated function PlaySwitchAnim()
{
    PlayAnim(SwitchAnims[FireMode], WeaponSpeedSwitch, 0);
}

function ToggleFireMode()
{
    switch (FireMode)
    {
        // If you want to implement burst fire, change the line below to this:
        //   FM_Semi:    FireMode = FM_Burst;
        case FM_Semi:    FireMode = FM_Auto;
                         break;

        case FM_Burst:   FireMode = FM_Auto;
                         break;

        case FM_Auto:    FireMode = FM_Semi;
                         break;
    }
}

function Notify_Fire()
{
//    if (MagazineCount > 0)
//    {
        TraceFire(GetTraceAccuracy(), 0, 0);
//        MagazineCount--;

        if (Level.Game == None || !FPSGameInfo(Level.Game).bIsSinglePlayer)
            PlayOwnedSound(FireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
        else
            Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
//    }
}

function Notify_InsertShell()
{
    MagazineCount++;
    AmmoType.AmmoAmount--;
}

function Notify_skinflash_start()
{
    AmbientGlow = 400;

    if (FireMode == FM_Burst && MagazineCount > 0 && AmmoType.HasAmmo())
    {
        TraceFire(GetTraceAccuracy(), 0, 0);
//        MagazineCount--;

        if (Level.Game == None || !FPSGameInfo(Level.Game).bIsSinglePlayer)
            PlayOwnedSound(FireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
        else
            Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

        if (MagazineCount == 0)
        {
            PlayIdleAnim();
            GotoState('Idle');
        }
    }
}

function Notify_skinflash_end()
{
    AmbientGlow = 0;
}

function NoAmmo()
{
	if(P2Player(Instigator.Controller) != None && P2Player(Instigator.Controller).bAutoSwitchOnEmpty)
		P2Player(Instigator.Controller).SwitchAfterOutOfAmmo();
	else if(P2Player(Instigator.Controller) != None)
		P2Player(Instigator.Controller).SwitchToHands(true);
}

function Finish()
{
	local bool bForce, bForceAlt;

	/*
	if (NeedsToReload() && P2AmmoInv(AmmoType).HasAmmoFinished())
	{
		if (bThreeStageReload)
		    GotoState('PrepReload');
        else
            GotoState('Reloading');

		return;
	}
	*/

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if (bChangeWeapon)
	{
		GotoState('DownWeapon');
		return;
	}

	if ((Instigator == None) || (Instigator.Controller == None))
	{
		GotoState('');
		return;
	}

	if (!Instigator.IsHumanControlled())
	{
		if (MagazineCount == 0 && !P2AmmoInv(AmmoType).HasAmmoFinished())
		{
			// AI find it's next best weapon
			Instigator.Controller.SwitchToBestWeapon();

			if ( bChangeWeapon )
				GotoState('DownWeapon');
			else
				GotoState('Idle');
		}

		if (Instigator.PressingFire() && (FRand() <= AmmoType.RefireRate))
			Global.ServerFire();
		else if ( Instigator.PressingAltFire() )
			CauseAltFire();
		else
		{
			Instigator.Controller.StopFiring();
			GotoState('Idle');
		}
		return;
	}

	if (MagazineCount == 0 && !P2AmmoInv(AmmoType).HasAmmoFinished() && Instigator.IsLocallyControlled())
	{
		// If you autoswitch, you go to the next strongest weapon you have,
		// if not, then go back to your hands.
		if(P2Player(Instigator.Controller) != None && P2Player(Instigator.Controller).bAutoSwitchOnEmpty)
			P2Player(Instigator.Controller).SwitchAfterOutOfAmmo();
		else if(P2Player(Instigator.Controller) != None)
			P2Player(Instigator.Controller).SwitchToHands(true);

		if (bChangeWeapon)
		{
			GotoState(NoAmmoChangeState);
			return;
		}
		else
			GotoState('Idle');
	}

    if (Instigator.Weapon != self)
		GotoState('Idle');
	else if (DoServerFireAgain(bForce))
	{
		Global.ServerFire();
	}
	else if (DoServerAltFireAgain(bForceAlt))
		CauseAltFire();
	else
		GotoState('Idle');
}

// what is this even for
/*
simulated function ClientFinish()
{
	if ((Instigator == None) || (Instigator.Controller == None))
	{
		GotoState('');
		Log("Entered first if.");
		return;
	}

    if (
		//NeedsToReload() &&
		P2AmmoInv(AmmoType).HasAmmoFinished())
	{
		if (bThreeStageReload)
		    GotoState('PrepReload');
        else
            GotoState('Reloading');

		Log("Entered second if.");
        return;
	}

	if (MagazineCount == 0 && !P2AmmoInv(AmmoType).HasAmmoFinished())
	{
		if (P2Player(Instigator.Controller) != None && P2Player(Instigator.Controller).bAutoSwitchOnEmpty)
			Instigator.Controller.SwitchToBestWeapon();
		else if (P2Player(Instigator.Controller) != None)
			P2Player(Instigator.Controller).SwitchToHands(true);

		if (bChangeWeapon)
		{
			GotoState(NoAmmoChangeState);
			return;
		}
		else
		{
			PlayIdleAnim();
			GotoState('Idle');
			Log("Entered third if.");
			return;
		}
	}

    if (bChangeWeapon)
		GotoState('DownWeapon');
	else if (Instigator.PressingFire())
		Global.Fire(0);
	else
	{
		if (Instigator.PressingAltFire())
			Global.AltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('Idle');
			Log("Entered fourth if.");
		}
	}
}
*/

simulated function ClientForceReload()
{
	bForceReload = true;

	if (MagazineCount != default.MagazineCount && AmmoType.HasAmmo())
	{
	    if (bThreeStageReload)
	        GotoState('PrepReload');
        else
            GotoState('Reloading');
    }
}

///////////////////////////////////////////////////////////////////////////////
// Get firing mode as string "burst" "auto" etc.
///////////////////////////////////////////////////////////////////////////////
simulated function string GetFiringMode()
{
	if (bDisplayFireMode)
		return FireModeStrings[FireMode];
}

/**
 * Overriding this state's BeginState function so we enforce that both be in
 * automatic mode when they're brought up for some major carnage!
 */
state EquipDualWielding
{
    function BeginState() {
        ChangeWeaponHoldStyle();

        PlaySelect();

        FireMode = FM_Auto;

        if (bDualWielding && LeftWeapon != none) {
            LeftWeapon.BringUp();
            LeftWeapon.AttachToPawn(Instigator);

            if (EDWeapon(LeftWeapon) != none)
                EDWeapon(LeftWeapon).FireMode = FM_Auto;
        }

        SetLeftArmVisibility();
    }
}

state PrepFire
{
    simulated function Fire(float Value);
    simulated function AltFire(float Value);

    simulated function BeginState()
    {
		if (PrepFireAnim != '')
			PlayPrepFire();
		else
			GotoState('LoopFire');
    }

    simulated function AnimEnd(int Channel)
    {
        GotoState('LoopFire');
    }
}

state LoopFire
{
    simulated function Fire(float Value);
    simulated function AltFire(float Value);

    simulated function BeginState()
    {
        PlayFiring();
        TraceFire(GetTraceAccuracy(), 0, 0);

//        MagazineCount--;
    }

    simulated function AnimEnd(int Channel)
    {
        if (MagazineCount > 0 && Instigator != none && AmmoType.HasAmmo()) {
            if ((RightWeapon != none && Instigator.PressingFire()) ||
                 Instigator.PressingAltFire())
                 BeginState();
        }
        else
		{
			if (!AmmoType.HasAmmo())
			{
				ClientForceFinish();
				ServerForceFinish();
			}
            GotoState('EndFire');
		}
    }
}

state EndFire
{
    simulated function Fire(float Value);
    simulated function AltFire(float Value);

    simulated function BeginState()
    {
		if (EndFireAnim != '')
			PlayEndFire();
		else
			GotoState('Idle');
    }

    simulated function AnimEnd(int Channel)
    {
        GotoState('Idle');
    }
}

state PrepReload
{
    simulated function BeginState()
    {
        if (MagazineCount == 0)
            bPumpAfterReload = true;

        PlayPrepReload();
    }

    simulated function AnimEnd(int Channel)
    {
        GotoState('LoopReload');
    }
}

state LoopReload
{
    simulated function Fire(float Value)
    {
        if (MagazineCount > 0)
        {
            if (bPumpAfterReload)
                GotoState('EndReload');
            else
                Super.Fire(Value);
        }
    }

    simulated function BeginState()
    {
        PlayReloading();
    }

    simulated function AnimEnd(int Channel)
    {
        if (MagazineCount != default.MagazineCount && AmmoType.HasAmmo())
            BeginState();
        else
            GotoState('EndReload');
    }
}

state EndReload
{
    simulated function BeginState()
    {
        if (bPumpAfterReload)
            PlayPump();
        else
            PlayEndReload();
    }

    simulated function AnimEnd(int Channel)
    {
        if (bPumpAfterReload)
            bPumpAfterReload = false;

        GotoState('Idle');
    }
}

state SwitchFireMode
{
    simulated function Fire(float Value);
    simulated function AltFire(float Value);

    simulated function BeginState()
    {
        PlaySwitchAnim();
    }

    simulated function AnimEnd(int Channel)
    {
        ToggleFireMode();
        GotoState('Idle');
    }
}

state NormalFire
{
	simulated function Fire(float F)
	{
		if (AmmoType == None || (/*MagazineCount == 0 && */!AmmoType.HasAmmo()))
		{
			ClientForceFinish();
			ServerForceFinish();
			return;
		}
	}

	simulated function AltFire(float F)
	{
		Fire(F);
	}

	/*
	function CheckAnimating()
	{
		if (!IsAnimating())
			ForceFinish();
	}
	*/

	simulated function Beginstate()
	{
		Super.Beginstate();
	}

	function EndState()
	{
		if (Instigator != None)
			Instigator.StopPlayFiring();

		Super.EndState();
		bAltFiring = false;
	}
}

state Idle
{
	function ServerForceReload()
	{
		if (MagazineCount != default.MagazineCount && AmmoType.HasAmmo())
		{
			if (bThreeStageReload)
			    GotoState('PrepReload');
            else
                GotoState('Reloading');
		}
	}

    simulated function bool PutDown()
	{
		GotoState('DownWeapon');
		return true;
	}

	simulated function BeginState()
	{
		Super.BeginState();

		if(!Instigator.PressingFire() && FPSPawn(Instigator).bPlayer)
			ShotCountReset();
		if (Instigator.Weapon == self)
			ClientIdleCheckFire();
		if (!AmmoType.HasAmmo())
			NoAmmo();
	}

	simulated function EndState()
	{
		Super.EndState();
	}

Begin:
	bPointing = false;

	/*
    if (NeedsToReload() false && P2AmmoInv(AmmoType).HasAmmoFinished())
    {
		if (bThreeStageReload)
		    GotoState('PrepReload');
        else
            GotoState('Reloading');
    }
	*/

	if (MagazineCount == 0 && !P2AmmoInv(AmmoType).HasAmmoFinished())
		Instigator.Controller.SwitchToBestWeapon();

    HandleDualFireFromIdle();

    PlayIdleAnim();
}

state Reloading
{
    simulated function Fire(float Value);
    simulated function AltFire(float Value);

    simulated function BeginState()
    {
        if (MagazineCount != default.MagazineCount && AmmoType.HasAmmo())
            PlayReloading();
        else
            GotoState('Idle');
    }

    simulated function AnimEnd(int Channel)
    {
        local int TopUpAmount;

        TopUpAmount = Min((default.MagazineCount - MagazineCount), AmmoType.AmmoAmount);
        MagazineCount = MagazineCount + TopUpAmount;
        AmmoType.AmmoAmount = AmmoType.AmmoAmount - TopUpAmount;

        GotoState('Idle');
    }
}

defaultproperties
{
     NumberOfTraces=1
     NumberOfBursts=3
     WeaponSpeedPrepFire=1.000000
     WeaponSpeedLoopFire=1.000000
     WeaponSpeedEndFire=1.000000
     WeaponSpeedPrepReload=1.000000
     WeaponSpeedLoopReload=1.000000
     WeaponSpeedEndReload=1.000000
     WeaponSpeedPump=1.000000
     WeaponSpeedSwitch=1.000000
     WeaponSpeedBurst=1.000000
     FireModeStrings(0)="Semi"
     FireModeStrings(1)="Burst"
     FireModeStrings(2)="Auto"
}
