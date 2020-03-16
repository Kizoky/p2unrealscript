///////////////////////////////////////////////////////////////////////////////
// MatchesWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Gas can weapon (first and third person).
//
//	History:
//		05/31/02 NPF	Started history, probably won't be updated again until
//							the pace of change slows down.
//
///////////////////////////////////////////////////////////////////////////////

class MatchesWeapon extends P2Weapon;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////

var Sound	soundMatchStrike;
var bool bAltFiring;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
	{
	// This "throw the match" animation must include a notification that
	// call Notify_LightMatch() in order for the match to actually work!
	bAltFiring = false;
	PlayAnim('Shoot1', WeaponSpeedShoot1, 0.05);
	IncrementFlashCount();
	}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
	{
	// This "throw the match" animation must include a notification that
	// call Notify_LightMatch() in order for the match to actually work!
	bAltFiring = true;
	PlayAnim('Shoot1', WeaponSpeedShoot1, 0.05);
	IncrementFlashCount();
	}

///////////////////////////////////////////////////////////////////////////////
// Stub these two out so this doesn't 'fire'
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset );
function ProjectileFire();

///////////////////////////////////////////////////////////////////////////////
// Generate a match
//
// MP don't make this simulated or it will generate two matches
///////////////////////////////////////////////////////////////////////////////
function GenerateMatch()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local FireMatch thematch;
	
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
	HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
	if(HitActor == None
		|| (!HitActor.bStatic
			&& !HitActor.bWorldGeometry))
	{
		thematch = spawn(class'FireMatch',Instigator,,StartTrace, AdjustedAim);
		if(thematch != None)
		{
			// Touch any actor that was in between, just in case.
			if(HitActor != None)
			{
				HitActor.Touch(thematch);
				thematch.Touch(HitActor);
			}
		}
	}
}
function GenerateMatches()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local FireMatch thematch;
	local int i,j;	
	const MAX = 2.0;
	const ANGLE = 2048;
	const FUZZ = 1024;
	
	for (i=0-MAX; i<=MAX; i++)
	{
		for (j=0-MAX; j<=MAX; j++)
		{
			GetAxes(Instigator.GetViewRotation(),X,Y,Z);
			StartTrace = GetFireStart(X,Y,Z); 
			AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
			AdjustedAim.Yaw = (AdjustedAim.Yaw + int(ANGLE*j/MAX) + FRand() * FUZZ - FUZZ / 2);
			AdjustedAim.Pitch = (AdjustedAim.Pitch + int(ANGLE*i/MAX) + FRand() * FUZZ - FUZZ / 2);
			HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
			if(HitActor == None
				|| (!HitActor.bStatic
					&& !HitActor.bWorldGeometry))
			{
				thematch = spawn(class'FireMatch',Instigator,,StartTrace, AdjustedAim);
				if(thematch != None)
				{
					// Touch any actor that was in between, just in case.
					if(HitActor != None)
					{
						HitActor.Touch(thematch);
						thematch.Touch(HitActor);
					}
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Animation notification called when the correct point is reached in the
// "light the match" animation.
//
// MP don't make this simulated or it will generate two matches
///////////////////////////////////////////////////////////////////////////////
function Notify_LightMatch()
	{
	// Sound is happening in the anim
	//Instigator.PlayOwnedSound(soundMatchStrike, SLOT_None, 1.0,,,GetRandPitch());
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& bAltFiring
		&& Pawn(Owner).Controller.bIsPlayer)
		GenerateMatches();
	else
		GenerateMatch();
	}


///////////////////////////////////////////////////////////////////////////////
// Return the switch priority of the weapon (normally AutoSwitchPriority, but may be
// modified by environment (or by other factors for bots)
///////////////////////////////////////////////////////////////////////////////
simulated function float SwitchPriority() 
{
	local float temp;

	//log(self$" switch priority");
	//log("Instigator "$Instigator);
	//log("AmmoType "$AmmoType);
	//log("Owner "$Owner);

	if (Instigator != None 
		&& !Instigator.IsHumanControlled() )
		return RateSelf();
	else if ( !bJustMade
		&& (AmmoType != None && !AmmoType.HasAmmo()) )
	{
		if ( Pawn(Owner).Weapon == self )
			return -0.5;
		else
			return -1;
	}
	else 
	{
		if(Instigator != None
			&& Instigator.Weapon != None
			&& Instigator.Weapon.IsA('GasCanWeapon'))
			return 1000;	// if you're a gas can,and you ran out of ammo, you definitely want
							// to switch the matches next.
		else
			return default.AutoSwitchPriority;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bUsesAltFire=true
	ItemName="Matches"
	AmmoName=class'MatchesAmmoInv'
	AttachmentClass=class'MatchesAttachment'

//	Mesh=Mesh'FP_Weapons.FP_Dude_MatchBox'
	Mesh=Mesh'MP_Weapons.MP_LS_MatchBox'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="MatchBox"

	FireOffset=(X=40.0000,Y=5.000000,Z=-10.00000)

	ViolenceRank=0
	bBumpStartsFight=false
	bArrestableWeapon=true
	bCanThrow=false

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Toss
	firingstyle=WEAPONHOLDSTYLE_Toss

	aimerror=0.000000
	//shakemag=0.000000
	//shaketime=0.000000
	//shakevert=(X=0.0,Y=0.0,Z=0.00000)
	//shakespeed=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetTime=0
	ShakeRotMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotTime=0

	AIRating=0.02
	AutoSwitchPriority=0
	InventoryGroup=5
	GroupOffset=2
	BobDamping=0.975000
	ReloadCount=0
	TraceAccuracy=0.9
	SelectSound=None

	soundMatchStrike = Sound'WeaponSounds.Match_Light'

	WeaponSpeedHolster = 2.0
	WeaponSpeedLoad    = 2.0
	WeaponSpeedReload  = 2.0
	WeaponSpeedShoot1  = 2.4
	WeaponSpeedShoot1Rand=0.6
	WeaponSpeedShoot2  = 2.4
	WeaponSpeedShoot2Rand=0.6

	DropWeaponHint1="They've seen your weapon!"
	DropWeaponHint2="Press %KEY_ThrowWeapon% to drop it."
	
	bCannotBeStolen=true
	}
