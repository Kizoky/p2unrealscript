///////////////////////////////////////////////////////////////////////////////
// P2WeaponStreaming
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// An extra layer for weapons that are stream-based (as opposed to
// discreet).  Pissing and flamethrowers are good examples, though it
// can be a stream of anything, not just liquid.
//
//	History:
// 4/30 Kamek - shovel achievement code
//		03/19/02 MJR	Started
//
///////////////////////////////////////////////////////////////////////////////
class P2WeaponStreaming extends P2Weapon
	abstract;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////

var Sound soundStart;
var Sound soundLoop1;
var Sound soundLoop2;
var Sound soundEnd;
var bool bRegainAmmo;		// Dynamically regains ammo based on time, when not shooting
var float AmmoRemainder;	// float remainder for when the ammo is reduced in the tick

var float AmmoUseRate;			// how fast the remainder is used up when firing
var float AmmoGainRate;			// how fast the remainder is regained when not firing

var bool bDelayedStartSound;	// If false, play the start sound in the StartStream state,
								// if not, wait and play it at the start of the Streaming state,
								// then switch over to the normal looping sound

var float WeaponSpeedPrep, WeaponSpeedEnd;

const VECTOR_RATIO	=	100;	// Maintain precision in MP replication


replication
{
	// functions client sends to server
	reliable if (Role < ROLE_Authority)
		ServerEndStreaming;
}


///////////////////////////////////////////////////////////////////////////////
// Modify your speed based on your owners body speed
///////////////////////////////////////////////////////////////////////////////
function ChangeSpeed(float NewSpeed)
{
	Super.ChangeSpeed(NewSpeed);
	WeaponSpeedPrep = default.WeaponSpeedPrep*NewSpeed;
	WeaponSpeedEnd = default.WeaponSpeedEnd*NewSpeed;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayStreamStart()
	{
		PlayAnim('Shoot1Prep', WeaponSpeedPrep, 0.05);
	}
simulated function PlayStreamEnd()
	{
		PlayAnim('Shoot1End', WeaponSpeedEnd, 0.05);
	}


///////////////////////////////////////////////////////////////////////////////
// If you're not actively peeing, set it here,
// otherwise, you'll set it, and change the pee stream
// (Urethra only)
///////////////////////////////////////////////////////////////////////////////
function MakeBloodied()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Turn you back to normal
///////////////////////////////////////////////////////////////////////////////
function MakeClean()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Reduce the real time ammo
// Only reduce it when we've gone through a single unit of fuel. 
// Then reset the remainder and start again
// This is to handle the fact that AmmoAmount is stored as an int and we want
// to steadily stream the ammo for this weapon
// True for if a unit was removed or added.. false otherwise.
///////////////////////////////////////////////////////////////////////////////
function bool ReduceAmmo(float DeltaTime)
{
	AmmoRemainder-=(AmmoUseRate*DeltaTime);
	if(AmmoRemainder < 0
		&& AmmoType.AmmoAmount > 0)
	{
		P2AmmoInv(AmmoType).UseAmmoForShot();
		AmmoRemainder=AmmoRemainder+1;
		return true;
	}
	//log("remainder ammo "$AmmoRemainder$" ammo "$AmmoType.AmmoAmount);
	return false;
}
function bool GainAmmo(float DeltaTime)
{
	AmmoRemainder+=(AmmoGainRate*DeltaTime);
	if(AmmoRemainder > 1)
	{
		AmmoType.AddAmmo(1);
		AmmoRemainder=AmmoRemainder-1;
		return true;
	}
	//log("adding ammo "$AmmoRemainder$" ammo "$AmmoType.AmmoAmount);
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PrepStreaming()
{
	// play our intro stream anim
	PlayStreamStart();
	if(!bDelayedStartSound)
		Instigator.PlaySound(soundStart, SLOT_None, 1.0, false, 1000.0, 1.0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	//log(self$" FIRING");
	if ( AmmoType == None
		|| !AmmoType.HasAmmo() )
	{
		ForceFinish();
		return;
	}

	//log(self$" FIRING made it through ammo");
	ServerFire();

	if ( Role < ROLE_Authority )
	{
		PrepStreaming();
		GotoState('StartStream');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function EndStreaming()
{
	//log(self$" client endstream ");
	GotoState('EndStream');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerEndStreaming()
{
	//log(self$" server endstream ");
	GotoState('EndStream');
}
	
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerFire()
{
	DQShovel();
	PrepStreaming();
	GotoState('StartStream');
}

///////////////////////////////////////////////////////////////////////////////
// Reports if the weapon is currently in a firing/violent state
///////////////////////////////////////////////////////////////////////////////
simulated function bool IsFiring()
{
	if(IsInState('Streaming'))
		return true;

	return Super.IsFiring();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// StartStream
//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StartStream
{
	ignores Fire, ServerFire, AltFire;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		//log(self$" going to streaming");
		GotoState('Streaming');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		//log(self$" startstream");
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Streaming
// 'Fire' this weapon in a looping fashion, till it's done
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Streaming
{
	ignores PrevWeapon, NextWeapon, WeaponChange, Fire, ServerFire, AltFire;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function bool PutDown()
	{
		bChangeWeapon = true;
		return True;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			if(Instigator.PressingFire()
				&& AmmoType.HasAmmo())
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
	///////////////////////////////////////////////////////////////////////////////
	simulated function EndState()
	{
		Instigator.AmbientSound = None;
		//log(self$" end streaming");
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set to seeking when you get to this state
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		PlayFiring();
	}
Begin:
	if(!bDelayedStartSound)
		Instigator.AmbientSound = soundLoop1;
	else
	{
		Instigator.PlaySound(soundStart, SLOT_None, 1.0, false, 1000.0, 1.0);
		Sleep(Instigator.GetSoundDuration(soundStart));
		Instigator.AmbientSound = soundLoop1;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// EndStream
//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state EndStream
{
	ignores Fire;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		GotoState('Idle');
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		// play our intro stream anim
		PlayStreamEnd();
		Instigator.PlaySound(soundEnd, SLOT_None, 1.0, false, 1000.0, 1.0);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	AmmoUseRate=1;
	FireSound = None
	WeaponSpeedPrep=3.0
	WeaponSpeedEnd=3.0
	bDelayedStartSound=false
	}