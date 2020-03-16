///////////////////////////////////////////////////////////////////////////////
// ScytheWeapon
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Scythe weapon (first and third person).
// One that cuts wheat and people's legs
//
///////////////////////////////////////////////////////////////////////////////

class ScytheWeapon extends P2BloodWeapon;

var travel bool bShowHint1;
var bool bStopAtDoor;		// If this is set, then we care about hitting doors first and people
							// later. This is really for just the foot. Most of the time we kick doors
							// open. If we directly kick a door open, but a person was on the other side
							// we *don't* want them pissed off (attacking) because we couldn't know they	
							// we're on the other side and for the most part we didn't mean to do that.

var float WeaponSpeedPullBackSwing, WeaponSpeedPullBackThrow, WeaponSpeedPullBackRand;
var float WeaponSpeedThrowIdle, WeaponSpeedThrowIdleRand;

var bool bRemoved;			// If it's to be removed from your inventory
var bool bReaper;
var Sound   WeaponCatchSound;
var float AlertRadiusAlt;		// how big an area to tell people i'm going to hit about me


const HEAD_OFFSET	=	10.0;
const PAWN_NECK		=	'MALE01 neck';

replication
{
	// functions client sends to server
	reliable if (Role < ROLE_Authority)
		ThrowIt;
	// Functions called by server on client
	reliable if(Role == ROLE_Authority)
		ClientScytheShake;
}

///////////////////////////////////////////////////////////////////////////////
// Modify your speed based on your owners body speed
///////////////////////////////////////////////////////////////////////////////
function ChangeSpeed(float NewSpeed)
{
	Super.ChangeSpeed(NewSpeed);
	WeaponSpeedPullBackSwing = default.WeaponSpeedPullBackSwing * NewSpeed;
	WeaponSpeedPullBackThrow = default.WeaponSpeedPullBackThrow * NewSpeed;
	WeaponSpeedThrowIdle = default.WeaponSpeedPullBackThrow * NewSpeed;	
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
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	// Alert anyone around you that you're swinging your big weapon
	SendSwingAlert(AlertRadius);

	// continue
	Super.PlayFiring();
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
// Hurt things
///////////////////////////////////////////////////////////////////////////////
function NotifyScytheChop()
{
	DoHit( TraceAccuracy, 0, 0);
}

///////////////////////////////////////////////////////////////////////////////
// Notify to throw the Scythe
///////////////////////////////////////////////////////////////////////////////
simulated function NotifyScytheThrow()
{
	ThrowScythe();
}

///////////////////////////////////////////////////////////////////////////////
// Throw the Scythe
///////////////////////////////////////////////////////////////////////////////
function ThrowScythe()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local ScytheProjectile macproj;
	local P2Player p2p;
	
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
		bReaper = True;

	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	// Throw it a little further out of your view
	StartTrace = StartTrace + X*Instigator.CollisionRadius;
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
	TurnOffHint();
	macproj = spawn(class'ScytheProjectile',Instigator,,StartTrace, AdjustedAim);

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

	// If we made it
	if(macproj != None
		&& !macproj.bDeleteMe
		&& !bReaper)
		// Wait to catch it
		GotoState('DownWeaponEmpty');
	else // If not, go back to ready to throw/hack again
		GotoState('Idle');

	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None
		&& !bReaper)
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
// Actually throw the scythe
///////////////////////////////////////////////////////////////////////////////
function ThrowIt()
{
	bAltFiring=true;
	GotoState('NormalFire');

//	PlayAltFiring();
}

///////////////////////////////////////////////////////////////////////////////
// Actually swing the scythe
///////////////////////////////////////////////////////////////////////////////
function SwingIt()
{
	GotoState('NormalFire');

//	PlayFiring();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientThrowIt()
{
	LocalAltFire();
	bAltFiring=true;
	GotoState('ClientFiring');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientSwingIt()
{
	LocalFire();
	GotoState('ClientFiring');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	bAltFiring=false;

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
		PrepSwing();
		GotoState('PullBackSwing');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function AltFire( float Value )
{
	if ( AmmoType == None
		|| !AmmoType.HasAmmo() )
	{
		ClientForceFinish();
		ServerForceFinish();
		return;
	}

	ServerAltFire();

	if ( Role < ROLE_Authority )
	{
		PrepThrow();
		GotoState('PullBackThrow');
	}
}
	
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerFire()
{
	bAltFiring=false;
	PrepSwing();
	GotoState('PullBackSwing');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerAltFire()
{
	bAltFiring=true;
	PrepThrow();
	GotoState('PullBackThrow');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PrepThrow()
{
	// Alert anyone around you that you're throwing your big weapon
	SendSwingAlert(AlertRadiusAlt);

	// play our windup anim
	PlayPullBackThrow();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PrepSwing()
{
	// Alert anyone around you that you're swinging your big weapon
	SendSwingAlert(AlertRadius);

	// play our windup anim
	PlayPullBackSwing();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayPullBackThrow()
{
	PlayAnim('prepthrow', WeaponSpeedPullBackThrow + (WeaponSpeedPullBackRand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayPullBackSwing()
{
	PlayAnim('PullBackSwing', WeaponSpeedPullBackSwing + (WeaponSpeedPullBackRand*FRand()), 0.05);
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayThrowIdle()
{
	PlayAnim('ThrowIdle', WeaponSpeedThrowIdle + (WeaponSpeedThrowIdleRand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlaySwingIdle()
{
	PlayAnim('ThrowIdle', WeaponSpeedThrowIdle + (WeaponSpeedThrowIdleRand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientScytheShake(bool bHitSolid)
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
///////////////////////////////////////////////////////////////////////////////
function DoHit( float Accuracy, float YOffset, float ZOffset )
{
	// Do a sphere test around where the weapon projects, and try to hurt stuff there
	local vector markerpos, markerpos2;
	local bool secondary;
	
	local vector HitLocation, HitNormal, StartTrace, EndTrace, StraightX, X,Y,Z, ExtendTrace;
	local actor FirstHit;
	local actor Victims;
	local FPSPawn PawnHit;
	local float dist;
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

		// Handle pawns hit within the colliding actors function
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
					{
						// Find the distance to the pawn, in line with the starting trace
						dist = VSize(Victims.Location - StartTrace);
						HitLocation = StartTrace + dist*X;
						ScytheAmmoInv(AmmoType).ProcessSeverHit(self, FPSPawn(Victims), HitLocation, vect(0,0,1), X,Y,Z);
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
										vect(0,0,1), X,Y,Z);
					}
				}
			}
		}
	}

	// If we hit a pawn, don't say it was a solid hit, even if we hit other stuff
	if(PawnHit != None)
	{
		bHitSolid=false;
		bHitSomething=true;
		// Process the damage here
		// Find the distance to the pawn, in line with the starting trace
		dist = VSize(PawnHit.Location - StartTrace);
		HitLocation = StartTrace + dist*X;
		ScytheAmmoInv(AmmoType).ProcessSeverHit(self, PawnHit, HitLocation, vect(0,0,1), X,Y,Z);
	}

	// If we hit something, only then (not when we fire) do we shake the view
	if(bHitSomething)
	{
		if ( Instigator != None)
		{
			ClientScytheShake(bHitSolid);
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
		Instigator.Weapon = None;
		if(P2Player(Instigator.Controller) != None)
			P2Player(Instigator.Controller).SwitchToThisWeapon(P2Pawn(Instigator).HandsClass.default.InventoryGroup, 
						P2Pawn(Instigator).HandsClass.default.GroupOffset, true);

		Instigator.DeleteInventory(self);
		bRemoved=true;
		Destroy();
	}
}


///////////////////////////////////////////////////////////////////////////////
// Finish a sequence
///////////////////////////////////////////////////////////////////////////////
function Finish()
{
	local bool bForce, bForceAlt;

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;
	
	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}
	
	if ( (Instigator == None) || (Instigator.Controller == None) )
	{
		GotoState('');
		return;
	}
	
	if ( !Instigator.IsHumanControlled() )
	{
		if ( !P2AmmoInv(AmmoType).HasAmmoFinished() )
		{
			// AI find it's next best weapon
			Instigator.Controller.SwitchToBestWeapon();

			if ( bChangeWeapon )
				GotoState('DownWeapon');
			else
				GotoState('Idle');
		}
/*		
		if ( Instigator.PressingFire() && (FRand() <= AmmoType.RefireRate) )
			Global.ServerFire();
		else if ( Instigator.PressingAltFire() )
			CauseAltFire();	
		else 
		{
		*/
			Instigator.Controller.StopFiring();
			GotoState('Idle');
//		}
		return;
	}

	if ( !P2AmmoInv(AmmoType).HasAmmoFinished() && Instigator.IsLocallyControlled() )
	{
		// If you autoswitch, you go to the next strongest weapon you have,
		// if not, then go back to your hands.
		if(P2Player(Instigator.Controller) != None
			&& P2Player(Instigator.Controller).bAutoSwitchOnEmpty)
			P2Player(Instigator.Controller).SwitchAfterOutOfAmmo();
		else if(P2Player(Instigator.Controller) != None)
			P2Player(Instigator.Controller).SwitchToHands(true);

		if ( bChangeWeapon )
		{
			GotoState(NoAmmoChangeState);
			return;
		}
		else
			GotoState('Idle');
	}

	GotoState('Idle');
}

///////////////////////////////////////////////////////////////////////////////
// We want you to click fire everytime you want to hit something
///////////////////////////////////////////////////////////////////////////////
simulated function ClientIdleCheckFire()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Force you to press fire every time to swing it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
{
Begin:
	bPointing=False;
	if ( NeedsToReload() && P2AmmoInv(AmmoType).HasAmmoFinished() )
		GotoState('Reloading');
	if ( !P2AmmoInv(AmmoType).HasAmmoFinished() ) 
		Instigator.Controller.SwitchToBestWeapon();  //Goto Weapon that has Ammo
	/*
	if ( Instigator.PressingFire() ) 
	{
		Fire(0.0);
	}
	if ( Instigator.PressingAltFire() ) AltFire(0.0);	
	*/
	PlayIdleAnim();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PullBackThrow -- pulling back hammer to throw, if fire is still down, it
// will go to WaitToThrow, otherwise, it will throw it
//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PullBackThrow
{
	ignores Fire, AltFire, ServerFire, ServerAltFire;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			if(!Instigator.PressingAltFire())
			{
				ThrowIt();
				ClientThrowIt();
				return;
			}
		}

		GotoState('WaitToThrow');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PullBackSwing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PullBackSwing extends PullBackThrow
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			if(!Instigator.PressingFire())
			{
				SwingIt();
				ClientSwingIt();
				return;
			}
		}

		GotoState('WaitToSwing');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Waiting with hammer back to throw it through the air
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitToThrow
{
	ignores DropFrom, PutDown, Fire, AltFire, ServerFire, ServerAltFire;

	///////////////////////////////////////////////////////////////////////////////
	// Wait till they're not pressing fire to shoot it
	///////////////////////////////////////////////////////////////////////////////
	simulated function Tick(float DeltaTime)
	{
		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			if(!Instigator.PressingAltFire())
			{
				ThrowIt();
				ClientThrowIt();
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		PlayThrowIdle();
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		PlayThrowIdle();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitToSwing 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitToSwing extends WaitToThrow
{
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
				SwingIt();
				ClientSwingIt();
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function AnimEnd(int Channel)
	{
		PlaySwingIdle();
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		PlaySwingIdle();
	}
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

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     bShowHint1=True
     WeaponSpeedPullBackSwing=0.200000
     WeaponSpeedPullBackThrow=0.300000
     WeaponSpeedPullBackRand=0.050000
     WeaponSpeedThrowIdle=1.000000
     WeaponSpeedThrowIdleRand=0.200000
     WeaponCatchSound=Sound'AWSoundFX.Scythe.scythebrandish'
     AlertRadiusAlt=300.000000
     BloodTextures(0)=Texture'AWWeaponSkins.Weapons.ScytheBlade_blood_1'
     BloodTextures(1)=Texture'AWWeaponSkins.Weapons.ScytheBlade_blood_2'
     AlertRadius=230.000000
     bUsesAltFire=True
     ViolenceRank=3
     RecognitionDist=650.000000
     PawnHitMarkerMade=Class'Postal2Game.PawnBeatenMarker'
     switchstyle=WEAPONHOLDSTYLE_Double
     firingstyle=WEAPONHOLDSTYLE_Melee
     ShakeOffsetTime=6.000000
     PlayerMeleeDist=130.000000
     NPCMeleeDist=110.000000
     bAllowHints=True
     bShowHints=True
     HudHint1="Press %KEY_Fire% to swing."
     HudHint2="Press %KEY_AltFire% to throw."
     CombatRating=1.500000
     FirstPersonMeshSuffix="Scythe"
     WeaponSpeedHolster=1.500000
     WeaponSpeedShoot1Rand=0.100000
     AltFireSound=Sound'AWSoundFX.Scythe.scythethrowin'
     bCanThrowMP=False
     AmmoName=Class'AWInventory.ScytheAmmoInv'
     FireOffset=(X=0.000000,Z=0.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(X=5.000000,Y=5.000000,Z=5.000000)
     TraceAccuracy=0.005000
     bMeleeWeapon=True
     aimerror=200.000000
     AIRating=0.110000
     MaxRange=120.000000
     FireSound=Sound'AWSoundFX.Scythe.scytheswingmiss'
     GroupOffset=7
     PickupClass=Class'AWInventory.ScythePickup'
     BobDamping=0.970000
     AttachmentClass=Class'AWInventory.ScytheAttachment'
     ItemName="Scythe"
     Mesh=SkeletalMesh'AWWeaponAnim.LS_Scythe'
     Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     Skins(1)=Texture'AWWeaponSkins.Weapons.ScytheBlade'
     AmbientGlow=128
	 PlayerViewOffset=(X=2,Y=0,Z=-7)
}
