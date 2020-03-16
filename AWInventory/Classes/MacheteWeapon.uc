///////////////////////////////////////////////////////////////////////////////
// MacheteWeapon
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Machete weapon (first and third person).
//
///////////////////////////////////////////////////////////////////////////////

class MacheteWeapon extends P2BloodWeapon;

var travel bool bShowHint1;
var bool bStopAtDoor;		// If this is set, then we care about hitting doors first and people
							// later. This is really for just the foot. Most of the time we kick doors
							// open. If we directly kick a door open, but a person was on the other side
							// we *don't* want them pissed off (attacking) because we couldn't know they	
							// we're on the other side and for the most part we didn't mean to do that.
var name Shoot1Anim;		// Based on where you first swing, it will decide from 2 downs, one left or right
							// and put the name in here to be used

var float WeaponSpeedWait, WeaponSpeedWaitRand, WeaponSpeedCatch;

var bool bRemoved;			// If it's to be removed from your inventory
var bool bBladey;
var Sound   WeaponCatchSound;


const HEAD_OFFSET	=	10.0;
const PAWN_NECK		=	'MALE01 neck';

const SHOOTDOWN1	=	'Shoot1Down1';
const SHOOTDOWN2	=	'Shoot1Down2';
const SHOOTLEFT		=	'Shoot1Left';
const SHOOTRIGHT	=	'Shoot1Right';

replication
{
	// Functions called by server on client
	reliable if(Role == ROLE_Authority)
		ClientMacheteShake;
}

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function bool GetHints(out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bAllowHints)
	{
		if(bShowHint1)
			str1=HudHint1;
		else
			str2=HudHint2;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Allow hints again
///////////////////////////////////////////////////////////////////////////////
function RefreshHints()
{
	Super.RefreshHints();
	bShowHint1=true;
}

///////////////////////////////////////////////////////////////////////////////
// Give it back if it's in the right state
///////////////////////////////////////////////////////////////////////////////
function bool GiveBackBlade()
{
	if(IsInState('WaitingOnBlade')
		&& !bBladey)
	{
		Instigator.PlaySound(WeaponCatchSound);
		if(P2Player(Instigator.Controller) != None)
			P2Player(Instigator.Controller).CaughtMachete();
		GotoState('CatchingBlade');
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Based on about where you'll hit the pawn in front of us, pick an animation
// to play when swinging
///////////////////////////////////////////////////////////////////////////////
function name PickFireAnim()
{
	local vector StartTrace, EndTrace, X, Y, Z, HitLoc, HitNormal;
	local vector usev;
	local coords usecoords;
	local Actor HitActor;
	local int i;
	local bool bSideways;

	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	EndTrace = StartTrace + 2*X*UseMeleeDist;

	HitActor = Trace(HitLoc,HitNormal,EndTrace,StartTrace,true);
	if(PersonPawn(HitActor) != None
		&& PersonPawn(HitActor).Health > 0)
	{
		// approximate the best swing for the place you'll hit them
		usev = HitLoc - HitActor.Location;
		usecoords = HitActor.GetBoneCoords(PAWN_NECK);
		// Hit head
		if(hitloc.z > (usecoords.origin.z))
			bSideways=true;
		// hit legs
		else if(usev.z < 0)
			bSideways=true;
		if(bSideways)
		{
			if(Rand(2) != 0)
				return SHOOTLEFT;
			else
				return SHOOTRIGHT;
		}
		else // swing down
		{
			if(Rand(2) != 0)
				return SHOOTDOWN1;
			else
				return SHOOTDOWN2;
		}
	}
	else
	{
		// Hit a dead thing, or an animal, pick a random swing
		i = Rand(4);
		switch(i)
		{
			case 0:
				return SHOOTDOWN1;
			case 1:
				return SHOOTDOWN2;
			case 2:
				return SHOOTLEFT;
			case 3:
				return SHOOTRIGHT;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	// Alert anyone around you that you're swinging your big weapon
	SendSwingAlert(AlertRadius);

	// Determine hack anim to use based on where we're aiming now
	//Shoot1Anim = SHOOTDOWN1;
	Shoot1Anim = PickFireAnim();

	IncrementFlashCount();
	// Play MP sounds on everyone's computers
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(FireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else // just on yours in SP games
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
	
	PlayAnim(Shoot1Anim, WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);

	if(bShowHint1)
	{
		bShowHint1=false;
		UpdateHudHints();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
{
	Super.PlayAltFiring();
	if(!bShowHint1)
		TurnOffHint();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayBladeWait()
{
	PlayAnim('BladeWait', WeaponSpeedWait + (WeaponSpeedWaitRand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayBladeCatch()
{
	PlayAnim('BladeCatch', WeaponSpeedCatch, 0.05);
	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None)
		ThirdPersonActor.bHidden=false;
}

///////////////////////////////////////////////////////////////////////////////
// Hurt things
///////////////////////////////////////////////////////////////////////////////
function NotifyMacheteChop()
{
	DoHit( TraceAccuracy, 0, 0);
}

///////////////////////////////////////////////////////////////////////////////
// Notify to throw the machete like a boomerang
///////////////////////////////////////////////////////////////////////////////
simulated function NotifyMacheteThrow()
{
	ThrowMachete();
}

///////////////////////////////////////////////////////////////////////////////
// Throw the machete like a boomerang
///////////////////////////////////////////////////////////////////////////////
function ThrowMachete()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local MacheteProjectile macproj;
	local P2Player p2p;
	
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
		bBladey = True;
	
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	// Throw it a little further out of your view
	StartTrace = StartTrace + X*Instigator.CollisionRadius;
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
	TurnOffHint();
	macproj = spawn(class'MacheteProjectile',Instigator,,StartTrace, AdjustedAim);

	// Shake the view when you throw it
	if ( Instigator != None)
	{
		p2p = P2Player(Instigator.Controller);
		if (p2p!=None)
		{
			p2p.ClientShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime, 
						ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
		}
	}

	if(macproj != None)
		if(P2Player(Instigator.Controller) != None)
			P2Player(Instigator.Controller).ThrowMachete();
	// If we made it
	if(macproj != None
		&& !macproj.bDeleteMe
		&& !bBladey)
	{
		// Wait to catch it
		GotoState('WaitingOnBlade');
	}
	else // If not, go back to ready to throw/hack again
		GotoState('Idle');

	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None
		&& !bBladey)
		ThirdPersonActor.bHidden=true;
}

///////////////////////////////////////////////////////////////////////////////
// We didn't hit anything when we fired/swung our weapon
///////////////////////////////////////////////////////////////////////////////
function HitNothing()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Normal trace fire, plus check where to make the danger marker to 
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	// EMPTY
}

///////////////////////////////////////////////////////////////////////////////
// Called on client's side to make the gun fire
// Check here to throw out danger markers to let people know the gun has gone
// off.
///////////////////////////////////////////////////////////////////////////////
simulated function LocalFire()
	{
	local P2Player P;
	
	bPointing = true;

	// Same as the one in P2Weapon, but we don't do the camera shake here

	if ( Affector != None )
		Affector.FireEffect();
	PlayFiring();
	}		

///////////////////////////////////////////////////////////////////////////////
// Same as above.. we don't want the shake here
///////////////////////////////////////////////////////////////////////////////
simulated function LocalAltFire()
{
	local PlayerController P;

	bPointing = true;

	// Same as the one in P2Weapon, but we don't do the camera shake here
	// We make it shake when he throws

	if ( Affector != None )
		Affector.FireEffect();
	PlayAltFiring();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientMacheteShake(bool bHitSolid)
{
	local P2Player p2p;

	p2p = P2Player(Instigator.Controller);
	if (p2p!=None)
	{
		if(bHitSolid)
			p2p.ShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime, 
						ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
		else
			// Don't shake it as hard if we hit something not so solid
			p2p.ShakeView(ShakeRotMag/2, ShakeRotRate, ShakeRotTime/2,
						ShakeOffsetMag/2, ShakeOffsetRate, ShakeOffsetTime/2);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Use the distance between our guy and the HitPawn, take that magnitude
// and mult it by the direction the guy is facing, plus his aiming position in the world (startpt)
///////////////////////////////////////////////////////////////////////////////
function vector GetHitLocation(vector Xdir, vector StartPt, vector EndPt, FPSPawn HitPawn, 
							   vector hitloc, out byte SeverHit)
{
	local float usedist, aimdot, dirdot;
	local vector usev, aimcross;
	local rotator userot;
	local coords usecoords;

	if(HitPawn.Health > 0)
	{
		usev = StartPt - HitPawn.Location;
		usev.z=0;
		aimdot = Normal(usev) dot vector(Instigator.Rotation);
		aimcross = usev cross vector(Instigator.Rotation);
		dirdot = Normal(usev) dot vector(HitPawn.Rotation);

		// check to cut off head
		usecoords = HitPawn.GetBoneCoords(PAWN_NECK);

		// hit head
		if(hitloc.z > (usecoords.origin.z - HEAD_OFFSET))
		{
			SeverHit=1;
			return hitloc;
		}
		else
		{
			const DIR_DOT_MAX	=	0.8;	// angle the player is around the character
											// if he's off to the side facing the arm, this
											// allows him to chop off the arm, even though aimdot says
											// he's aiming straight at the torso (which he is, but an
											// arm is in the way)
			const LEG_Z			=	25.0;	// how much further down the torso someone's legs are
			// If it's below the legs, then let it chop off anything anyway, or if it's
			// on the sides, then chop off the arm, otherwise, hit the torso
			usev = HitPawn.Location;
			usev.z -= LEG_Z;
			if(hitloc.z < (usev.z)
				|| aimdot > -0.995
				|| (dirdot > -DIR_DOT_MAX
					&& dirdot < DIR_DOT_MAX))
			{
				// if dirdot*aimcross.z is negative, they want the pawns left side
				if(dirdot*aimcross.z < 0)
				{
					userot = HitPawn.Rotation;
					userot.Yaw-=16383;
					usev = HitPawn.Location + 2*HitPawn.CollisionRadius*vector(userot);
					hitloc.x = usev.x;
					hitloc.y = usev.y;
					SeverHit=1;
					// keep the z height the same
					return hitloc;
				}
				else // otherwise, they want the right
				{
					userot = HitPawn.Rotation;
					userot.Yaw+=16383;
					usev = HitPawn.Location + 2*HitPawn.CollisionRadius*vector(userot);
					hitloc.x = usev.x;
					hitloc.y = usev.y;
					SeverHit=1;
					// keep the z height the same
					return hitloc;
				}
			}
			else // hit middle of body, no sever
			{			
				return hitloc;
			}
		}
	}
	else // Dead pawn, use average distance forward as hit point--it's a straight
		// forward shot from the dude's aim. The pawn will figure out which 
		// bone it probably hit
	{
		SeverHit = 1;
		return EndPt;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function DoHit( float Accuracy, float YOffset, float ZOffset )
{
	// Do a sphere test around where the weapon projects, and try to hurt stuff there
	local vector markerpos, markerpos2;
	local bool secondary;
	
	local vector HitLocation, HitNormal, StartTrace, EndTrace, StraightX, X,Y,Z, ExtendTrace;
	local actor FirstHit;
	local actor Victims;
	local FPSPawn PawnHit, CheckPawn;
	local float dist, UseTime, checkdist, fardist;
	local vector dir;
	local bool bDeliverDirectDamage;
	local bool bHitSomething, bHitSolid, bHitDoor;
	local byte SeverHit;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	EndTrace = StartTrace + X*UseMeleeDist;
	ExtendTrace = EndTrace + X*UseMeleeDist;

	// This performs the collision but also records where it hit and records it
	FirstHit = Trace(LastHitLocation,HitNormal,ExtendTrace,StartTrace,true);
	if(FirstHit != None)
	{
		bDeliverDirectDamage=true;
		if(FirstHit.bStatic)
			bHitSolid=true;
		// If we hit a pawn, record that too
		else if(FPSPawn(FirstHit) != None)
			//&& FPSPawn(FirstHit).Health > 0)
			PawnHit = FPSPawn(FirstHit);
		// If we hit a door, don't let us hurt a person who may be on the FirstHit side
		// as we kick it open, if we are indeed kicking it open. 
		else if(DoorMover(FirstHit) != None
			&& bStopAtDoor)
			bHitDoor=true;

		// Handle hitting pawns later down the function
		if(PawnHit == None)
		{
			// Process the damage here
			AmmoType.ProcessTraceHit(self, FirstHit, LastHitLocation, HitNormal, X,Y,Z);
			bHitSomething=true;
		}
	}

	// If we didn't hit a door first, or a pawn, try to hit more
	if(!bHitDoor)
	{
		fardist = 2*UseMeleeDist;
		foreach VisibleCollidingActors( class 'Actor', Victims, UseMeleeDist, EndTrace )
		{
			if( (Victims != self)
				&& (!Victims.bStatic)
				&& (Victims.bCollideWorld)
				&& (Victims != Instigator) 
				&& (Victims.Role == ROLE_Authority) 
				&& (FirstHit != Victims)
				&& FastTrace(StartTrace, Victims.Location)	// Don't hit through walls, etc.
				)	// handle the straight forward hits below
			{
				// If it's friendly pawn, don't let this 'wide area collision check' hurt
				// them. Only let the above, direct check hurt them. If it's any other pawn
				// or anything else in general, hurt it. This is so it's harder to accidentally
				// hurt your friends with the wide bludgeoning attacks.
				if(FPSPawn(Victims) == None
					|| !FPSPawn(Victims).bPlayerIsFriend)
				{
					// Save the first thing we hit, so we can alert other people about the hit
					if(!bDeliverDirectDamage
						&& FirstHit == None)
					{
						FirstHit = Victims;
						LastHitLocation = Victims.Location;
					}

					if(FPSPawn(Victims) != None)
					// If we hit a pawn, record that too
					{
						checkdist = VSize(Victims.Location - EndTrace);
						if(checkdist < fardist
							&& FPSPawn(Victims) != None)
							//&& FPSPawn(Victims).Health > 0)
						{
							fardist = checkdist;
							CheckPawn = FPSPawn(Victims);
						}
					}
					else // if we hit anything else, say so
					{
						if(Victims.bStatic)
							bHitSolid=true;
						bHitSomething=true;
						// Check to deliver damage
						dir = Victims.Location - EndTrace;
						dist = FMax(1,VSize(dir));
						dir = dir/dist;

						AmmoType.ProcessTraceHit(self, Victims, 
										EndTrace,
										HitNormal, X,Y,Z);
					}
				}
			}
		}
	}
	if(CheckPawn != None)
		PawnHit = CheckPawn;

	// If we hit a pawn, don't say it was a solid hit, even if we hit other stuff
	if(PawnHit != None)
	{
		bHitSolid=false;
		bHitSomething=true;

		HitLocation = GetHitLocation(X, StartTrace, EndTrace, PawnHit, ExtendTrace, SeverHit);
		
		// Process the damage here
		if(SeverHit == 1
			&& PersonPawn(PawnHit) != None)
			MacheteAmmoInv(AmmoType).ProcessSeverHit(self, PawnHit, HitLocation, HitNormal, X,Y,Z);
		else
			AmmoType.ProcessTraceHit(self, PawnHit, HitLocation, HitNormal, X,Y,Z);
	}

	// If we hit something, only then (not when we fire) do we shake the view
	if(bHitSomething)
	{
		if ( Instigator != None)
		{
			ClientMacheteShake(bHitSolid);
		}
	}
	// If we didn't hit anything, we may want to do something about it
	//  That is, we want to tell people we were swinging/kicking in mid-air
	else
		HitNothing();
	
	// Say we just fired
	ShotCount++;
	
	// Set your enemy as the one you attacked.
	if(P2Player(Instigator.Controller) != None
		&& PawnHit != None
		&& PawnHit.Health > 0)
	{
		P2Player(Instigator.Controller).Enemy = PawnHit;
	}

	// Only make a new danger marker if the consecutive fires were as high
	// as the max
	if(ShotCount >= ShotCountMaxForNotify
		&& Instigator.Controller != None)
		{
		// tell it we know this just happened, by recording it.
		ShotCount -= ShotCountMaxForNotify;
		
		// This is if a pawn is hit by a bullet (or hurt bad), so it's really scary
		if(PawnHit != None
			&& PawnHit.Health > 0
			&& PawnHitMarkerMade != None)
			{
			PawnHitMarkerMade.static.NotifyControllersStatic(
				Level,
				PawnHitMarkerMade,
				FPSPawn(Instigator), 
				FPSPawn(Instigator), // We want the creator to be instigator also
				// because this is much more like a gunfire sort of thing, rather than a pawn hit by
				// a bullet
				PawnHitMarkerMade.default.CollisionRadius,
				PawnHit.Location);
			}
		}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function RemoveMe()
{
	if(!bRemoved)
	{
		Instigator.DeleteInventory(self);
		bRemoved=true;
		Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Waiting on the blade to return
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitingOnBlade
{
	ignores DropFrom;

	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	simulated function bool PutDown()
	{
		local name anim;
		local float frame,rate;
		GetAnimParams(0,anim,frame,rate);
		if ( bWeaponUp || (frame < 0.75) )
			GotoState('DownWeaponEmpty');
		else
			bChangeWeapon = true;
		return True;
	}
	simulated function AnimEnd(int Channel)
	{
		PlayBladeWait();
	}
Begin:
	PlayBladeWait();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Catching blade
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CatchingBlade extends Active
{
Begin:
	PlayBladeCatch();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Switching weapons while the blade is flying around
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DownWeaponEmpty extends DownWeapon
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function PlayDownAnim()
	{
		PlayAnim('HolsterEmpty', WeaponSpeedHolster, 0.05);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		Super.AnimEnd(Channel);
		RemoveMe();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		RemoveMe();
	}
}

state NormalFire
{
	simulated function Fire(float F)
	{
		CheckAnimating();
		Super.Fire(F);
	}
	simulated function AltFire(float F)
	{
		CheckAnimating();
		Super.AltFire(F);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     bShowHint1=True
     WeaponSpeedWait=1.000000
     WeaponSpeedWaitRand=0.200000
     WeaponSpeedCatch=2.000000
     WeaponCatchSound=Sound'AWSoundFX.Machete.machetebrandish2'
     BloodTextures(0)=Texture'AWWeaponSkins.Weapons.Machete_blood_1'
     BloodTextures(1)=Texture'AWWeaponSkins.Weapons.Machete_blood_2'
     AlertRadius=150.000000
     bUsesAltFire=True
     ViolenceRank=3
     RecognitionDist=600.000000
     PawnHitMarkerMade=Class'Postal2Game.PawnBeatenMarker'
     holdstyle=WEAPONHOLDSTYLE_Melee
     switchstyle=WEAPONHOLDSTYLE_Double
     firingstyle=WEAPONHOLDSTYLE_Melee
     ShakeOffsetTime=6.000000
     PlayerMeleeDist=100.000000
     NPCMeleeDist=80.000000
     bAllowHints=True
     bShowHints=True
     HudHint1="Press %KEY_Fire% to swing."
     HudHint2="Press %KEY_AltFire% to throw."
     CombatRating=1.500000
     FirstPersonMeshSuffix="Machete"
     WeaponSpeedHolster=1.500000
     WeaponSpeedShoot1Rand=0.100000
     AltFireSound=Sound'AWSoundFX.Machete.machetethrowin'
     bCanThrowMP=False
     AmmoName=Class'AWInventory.MacheteAmmoInv'
     FireOffset=(X=0.000000,Z=0.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(X=5.000000,Y=5.000000,Z=5.000000)
     TraceAccuracy=0.005000
     bMeleeWeapon=True
     aimerror=200.000000
     AIRating=0.110000
     MaxRange=95.000000
     FireSound=Sound'AWSoundFX.Machete.macheteswingmiss'
     GroupOffset=5
     PickupClass=Class'AWInventory.MachetePickup'
     BobDamping=0.970000
     AttachmentClass=Class'AWInventory.MacheteAttachment'
     ItemName="Machete"
     Mesh=SkeletalMesh'AWWeaponAnim.LS_Machete'
     Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     Skins(1)=Texture'AWWeaponSkins.Weapons.Machete_1'
     AmbientGlow=128
}
