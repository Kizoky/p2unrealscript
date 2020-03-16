///////////////////////////////////////////////////////////////////////////////
// SledgeWeapon
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Sledgehammer weapon (first and third person).
// Hold the fire button to pull it up and then let go to swing it,
// same for alt-fire except you throw it when you let go.
//
///////////////////////////////////////////////////////////////////////////////

class SledgeWeapon extends P2BloodWeapon;

var travel bool bShowHint1;
var bool bStopAtDoor;		// If this is set, then we care about hitting doors first and people
							// later. This is really for just the foot. Most of the time we kick doors
							// open. If we directly kick a door open, but a person was on the other side
							// we *don't* want them pissed off (attacking) because we couldn't know they	
							// we're on the other side and for the most part we didn't mean to do that.
var float AlertRadiusAlt;		// how big an area to tell people i'm going to hit about me
var bool bHulkSmash;
var bool bRemoved;			// it's been removed, once, so don't try to delete it again (after it's thrown)
var float WeaponSpeedPullBackSwing, WeaponSpeedPullBackThrow, WeaponSpeedPullBackRand;
var float WeaponSpeedThrowIdle, WeaponSpeedThrowIdleRand;


replication
{
	// functions client sends to server
	reliable if (Role < ROLE_Authority)
		ThrowIt, SwingIt;
	// Functions called by server on client
	reliable if(Role == ROLE_Authority)
		ClientHammerShake;
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
function NotifySledgeSmash()
{
	DoHit( TraceAccuracy, 0, 0);
}

///////////////////////////////////////////////////////////////////////////////
// Notify to throw the Sledge end over end, though it's not coming back
///////////////////////////////////////////////////////////////////////////////
simulated function NotifySledgeThrow()
{
	ThrowSledge();
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
simulated function ClientHammerShake(bool bHitSolid)
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
// Actually throw the hammer
///////////////////////////////////////////////////////////////////////////////
function ThrowIt()
{
	bAltFiring=true;
	GotoState('NormalFire');

//	PlayAltFiring();
}

///////////////////////////////////////////////////////////////////////////////
// Actually swing the hammer
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
	PlayAnim('PrepThrow', WeaponSpeedPullBackThrow + (WeaponSpeedPullBackRand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayPullBackSwing()
{
	PlayAnim('PrepSwing', WeaponSpeedPullBackSwing + (WeaponSpeedPullBackRand*FRand()), 0.05);
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
	PlayAnim('SwingIdle', WeaponSpeedThrowIdle + (WeaponSpeedThrowIdleRand*FRand()), 0.05);
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
	local float HealthWas;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	EndTrace = StartTrace + X*UseMeleeDist;
	ExtendTrace = EndTrace + X*UseMeleeDist;

	// This performs the collision but also records where it hit and records it
	FirstHit = Trace(LastHitLocation,HitNormal,ExtendTrace,StartTrace,true);
	//log(self$" trace returns "$FirstHit);
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
		//log(self$" VisibleCollidingActors ");
		fardist = 2*UseMeleeDist;
		foreach VisibleCollidingActors( class 'Actor', Victims, UseMeleeDist, EndTrace )
		{
			//log(self$" VisibleCollidingActors loop returns "$Victims);
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
							//log(self$" new pawn to hit "$victims);
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

	//log(self$" pawn hit "$PawnHit);
	// If we hit a pawn, don't say it was a solid hit, even if we hit other stuff
	if(PawnHit != None)
	{
		bHitSolid=false;
		bHitSomething=true;
		// Process the damage here
		HealthWas = PawnHit.Health;
		AmmoType.ProcessTraceHit(self, PawnHit, EndTrace, HitNormal, X,Y,Z);
	}

	//log(self$" shovel hit something 0, inst "$Instigator$" hit something "$bHitSomething$" role "$Role);
	// If we hit something, only then (not when we fire) do we shake the view
	if(bHitSomething)
	{
		if ( Instigator != None)
		{
			ClientHammerShake(bHitSolid);
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
			&& HealthWas > 0
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
// Throw the Sledge
///////////////////////////////////////////////////////////////////////////////
function ThrowSledge()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local SledgeProjectile sledgeproj;
	local P2Player p2p;
	
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
		bHulkSmash = True;

	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	// Throw it a little further out of your view
	StartTrace = StartTrace + X*Instigator.CollisionRadius;
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
	TurnOffHint();
	sledgeproj = spawn(class'SledgeProjectile',Instigator,,StartTrace, AdjustedAim);

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
	if(sledgeproj != None
		&& !sledgeproj.bDeleteMe
		&& !bHulkSmash)
		// you through it, now switch to another weapon with the sledge gone
	{
		GotoState('DownWeaponEmpty');
	}
	else // If not, go back to ready to throw/smash again
		GotoState('Idle');

	// Check if the projectile was made within the spawn and needs to be destroyed
	if(sledgeproj.bMadePickup)
		sledgeproj.SetupForDestroy();

	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None
		&& !bHulkSmash)
		ThirdPersonActor.bHidden=true;
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

	//log(self$" Finish get state name "$GetStateName()$" ammo amount "$AmmoType.AmmoAmount);
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
			//log(self$" stop firing, finish ");
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

		//log(self$" bchangeweapon "$bChangeWeapon$" state "$NoAmmoChangeState);
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
// PullBack -- pulling back hammer to throw, if fire is still down, it
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
// Waiting with hammer back to throw it through the air/ or swing it
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
     AlertRadiusAlt=300.000000
     WeaponSpeedPullBackSwing=1.000000
     WeaponSpeedPullBackThrow=0.300000
     WeaponSpeedPullBackRand=0.010000
     WeaponSpeedThrowIdle=1.000000
     WeaponSpeedThrowIdleRand=0.200000
     BloodTextures(0)=Texture'AWWeaponSkins.Weapons.Sledge_blood_1'
     BloodTextures(1)=Texture'AWWeaponSkins.Weapons.Sledge_blood_2'
     AlertRadius=200.000000
     bUsesAltFire=True
     ViolenceRank=1
     RecognitionDist=600.000000
     PawnHitMarkerMade=Class'Postal2Game.PawnBeatenMarker'
     switchstyle=WEAPONHOLDSTYLE_Double
     firingstyle=WEAPONHOLDSTYLE_Melee
     ShakeOffsetTime=6.000000
     PlayerMeleeDist=100.000000
     NPCMeleeDist=100.000000
     bAllowHints=True
     bShowHints=True
     HudHint1="Press %KEY_Fire% to swing."
     HudHint2="Press %KEY_AltFire% to throw."
     CombatRating=1.500000
     FirstPersonMeshSuffix="Sledge"
     WeaponSpeedHolster=1.500000
     WeaponSpeedShoot1Rand=0.010000
     AltFireSound=Sound'AWSoundFX.Sledge.hammerthrowin'
     bCanThrowMP=False
     AmmoName=Class'AWInventory.SledgeAmmoInv'
     FireOffset=(X=0.000000,Z=0.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(X=5.000000,Y=5.000000,Z=5.000000)
     TraceAccuracy=0.005000
     bMeleeWeapon=True
     aimerror=200.000000
     AIRating=0.110000
     MaxRange=95.000000
     FireSound=Sound'AWSoundFX.Sledge.hammerswingmiss'
     GroupOffset=6
     PickupClass=Class'AWInventory.SledgePickup'
     BobDamping=0.970000
     AttachmentClass=Class'AWInventory.SledgeAttachment'
     ItemName="Sledgehammer"
     Mesh=SkeletalMesh'AWWeaponAnim.LS_Sledgehammer'
     Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     Skins(1)=Texture'AWWeaponSkins.Weapons.Sledge'
     AmbientGlow=128
}
