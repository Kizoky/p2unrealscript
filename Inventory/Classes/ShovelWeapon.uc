///////////////////////////////////////////////////////////////////////////////
// ShovelWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Shovel weapon (first and third person).
//
///////////////////////////////////////////////////////////////////////////////

class ShovelWeapon extends P2BloodWeapon;

var bool bAltFiring;			

var float KActorHitAngle;

const ENHANCED_MODE_SPEED = 2.000000;				
							
replication
{
	// Functions called by server on client
	reliable if(Role == ROLE_Authority)
		ClientShovelShake;
}

///////////////////////////////////////////////////////////////////////////////
// Modify your speed based on your owners body speed
///////////////////////////////////////////////////////////////////////////////
function ChangeSpeed(float NewSpeed)
{
	WeaponSpeedLoad = default.WeaponSpeedLoad*NewSpeed;
	WeaponSpeedReload = default.WeaponSpeedReload*NewSpeed;
	WeaponSpeedHolster = default.WeaponSpeedHolster*NewSpeed;
	if (class == class'ShovelWeapon'
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
		NewSpeed *= ENHANCED_MODE_SPEED;
	WeaponSpeedShoot1 = default.WeaponSpeedShoot1*NewSpeed;
	WeaponSpeedShoot2 = default.WeaponSpeedShoot2*NewSpeed;
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

simulated function PlayFiring()
{
	Super.PlayFiring();
	if(bShowHint1)
	{
		bShowHint1=false;
		UpdateHudHints();
	}
}
simulated function PlayAltFiring()
{
	Super.PlayAltFiring();
	if(!bShowHint1)
		TurnOffHint();
}

///////////////////////////////////////////////////////////////////////////////
// Start hurting things
///////////////////////////////////////////////////////////////////////////////
function Notify_StartHit()
{
//	log(self$" notify start hit");
	DoHit( TraceAccuracy, 0, 0);
}

///////////////////////////////////////////////////////////////////////////////
// Stop hurting things
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_StopHit()
{
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
	bAltFiring = false;

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
	bAltFiring = true;

	// Same as the one in P2Weapon, but we don't do the camera shake here
	// We make it shake when he throws

	if ( Affector != None )
		Affector.FireEffect();
	PlayAltFiring();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientShovelShake(bool bHitSolid)
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

// Enhanced mode: flying shovel!
function GoFlying(vector StartTrace, vector EndTrace)
{
	local vector VelAdd, GroundTest;
	
	const FLY_MAGNITUDE = 1000;
	const CEILING = 2000;
	const MAX_AIRSPEED = 1500;
	const MIN_AIRSPEED = -1500;
	
	// Don't allow on foot, etc.
	if (class != class'ShovelWeapon')
		return;
		
	// Don't allow unless already airborne
	if (Instigator.Physics != PHYS_Falling)
		return;

	// Do a quick trace to the ground
	GroundTest = StartTrace;
	GroundTest.Z -= CEILING;
	
	VelAdd = Normal(StartTrace - EndTrace);
	
	if (bAltFiring)
	{
		VelAdd.X = 0;
		VelAdd.Y = 0;
		VelAdd.Z = 1;
	}

	VelAdd *= FLY_MAGNITUDE;

	Instigator.Velocity += VelAdd;
	
	// Cap airspeed
	// Probably not the best way to do it
	if (Instigator.Velocity.X > MAX_AIRSPEED)
		Instigator.Velocity.X = MAX_AIRSPEED;
	if (Instigator.Velocity.Y > MAX_AIRSPEED)
		Instigator.Velocity.Y = MAX_AIRSPEED;
	if (Instigator.Velocity.Z > MAX_AIRSPEED)
		Instigator.Velocity.Z = MAX_AIRSPEED;
	if (Instigator.Velocity.X < MIN_AIRSPEED)
		Instigator.Velocity.X = MIN_AIRSPEED;
	if (Instigator.Velocity.Y < MIN_AIRSPEED)
		Instigator.Velocity.Y = MIN_AIRSPEED;
	if (Instigator.Velocity.Z < MIN_AIRSPEED)
		Instigator.Velocity.Z = MIN_AIRSPEED;
	
	// Don't let them gain any more Z velocity when too high off the ground
	if (FastTrace(GroundTest, StartTrace))
		Instigator.Velocity.Z = FMin(Instigator.Velocity.Z, 0);

	if (Instigator.Physics == PHYS_Walking)
		Instigator.SetPhysics(PHYS_Falling);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function DoHit( float Accuracy, float YOffset, float ZOffset )
{
	// We don't want this to do the work. We'll do it below

	// Do a sphere test around where the shovel projects, and try to hurt stuff there
	local vector markerpos, markerpos2;
	local bool secondary;
	
	// Weapon.TraceFire (modified to save where it hit inside LastHitLocation
	local vector HitLocation, HitNormal, StartTrace, EndTrace, StraightX, X,Y,Z, HitPoint;
	local actor FirstHit;
	local actor Victims;
	local FPSPawn LivePawnHit;
	local float dist, UseTime;
	local vector dir;
	local bool bDeliverDirectDamage;
	local bool bHitSomething, bHitSolid, bHitDoor;
	
	local float MinAngle;
	local vector TargetDir;
	local KActor KActor;

//	log(self$" DoHit");
	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StraightX = X;
	StartTrace = GetFireStart(X,Y,Z); 
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
	EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	HitPoint = EndTrace + (2*UseMeleeDist * X);

	// This performs the collision but also records where it hit and records it
	FirstHit = Trace(LastHitLocation,HitNormal,HitPoint,StartTrace,True);
//	log(self$" trace returns "$FirstHit);
	if(FirstHit != None)
	{
		bDeliverDirectDamage=true;
		if(FirstHit.bStatic)
			bHitSolid=true;
		// If we hit a live pawn, record that too
		else if(FPSPawn(FirstHit) != None
			&& FPSPawn(FirstHit).Health > 0)
			LivePawnHit = FPSPawn(FirstHit);
		// If we hit a door, don't let us hurt a person who may be on the FirstHit side
		// as we kick it open, if we are indeed kicking it open. 
		else if(DoorMover(FirstHit) != None
			&& bStopAtDoor)
			bHitDoor=true;

		// Process the damage here
		AmmoType.ProcessTraceHit(self, FirstHit, LastHitLocation, HitNormal, X,Y,Z);
		bHitSomething=true;
	}

	// Hurt things halfway to the end of the trace, for the radius of the trace,
	// so the sphere is halfway along the melee weapon, hurting everything in between
	// It's a hurting line with a hurting ball covering the same area.
	HitPoint = StartTrace + (UseMeleeDist * StraightX);

	// If we don't care about hitting doors or we didn't hit one, check the
	// area around us too for a possible hit
	if(!bHitDoor)
	{
//		log(self$" VisibleCollidingActors ");
		foreach VisibleCollidingActors( class 'Actor', Victims, UseMeleeDist, HitPoint )
		{
//			log(self$" VisibleCollidingActors loop returns "$Victims);
			if( (Victims != self)
				&& (!Victims.bStatic)
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

					// If we hit something really hard, record it
					if(Victims.bStatic)
						bHitSolid=true;
					// If we hit a live pawn, record that too
					else if(LivePawnHit == None
						&& FPSPawn(Victims) != None
						&& FPSPawn(Victims).Health > 0)
						LivePawnHit = FPSPawn(Victims);

					// Check to deliver damage
					dir = Victims.Location - HitLocation;
					dist = FMax(1,VSize(dir));
					dir = dir/dist;

					AmmoType.ProcessTraceHit(self, Victims, 
									Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
									HitNormal, X,Y,Z);
					bHitSomething=true;
				}
			} 
		}
		
		// Damage KActors in a cone in front of the player
		foreach RadiusActors(class'KActor', KActor, UseMeleeDist*2, StartTrace)
		{
			TargetDir = Normal(KActor.Location - Location);
			MinAngle = 1.0f - KActorHitAngle / 180.0f;
			
			if (TargetDir dot vector(Rotation) >= MinAngle)
			{				
//				log("Kicked: " $ KActor);
				AmmoType.ProcessTraceHit(self, KActor, KActor.Location, HitNormal, X, Y, Z);
				bHitSomething = true;
			}
		}
	}

	// If we hit a pawn, don't say it was a solid hit, even if we hit other stuff
	if(LivePawnHit != None)
		bHitSolid=false;

	//log(self$" shovel hit something 0, inst "$Instigator$" hit something "$bHitSomething$" role "$Role);
	// If we hit something, only then (not when we fire) do we shake the view
	if(bHitSomething)
	{
		if ( Instigator != None)
		{
			ClientShovelShake(bHitSolid);
		}
	}
	// If we didn't hit anything, we may want to do something about it
	//  That is, we want to tell people we were swinging/kicking in mid-air
	else
		HitNothing();

	// Go flying in enhanced mode
	// But only if we don't hit a person
	if((bHitSolid || !bHitSomething)
		&& P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
		GoFlying(StartTrace, HitPoint);		
	
	// Say we just fired
	ShotCount++;
	
	// Set your enemy as the one you attacked.
	if(P2Player(Instigator.Controller) != None
		&& LivePawnHit != None)
	{
		P2Player(Instigator.Controller).Enemy = LivePawnHit;
	}

	// Only make a new danger marker if the consecutive fires were as high
	// as the max
	if(ShotCount >= ShotCountMaxForNotify
		&& Instigator.Controller != None)
		{
		// tell it we know this just happened, by recording it.
		ShotCount -= ShotCountMaxForNotify;
		
		// This is if a pawn is hit by a bullet (or hurt bad), so it's really scary
		if(LivePawnHit != None
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
				LivePawnHit.Location);
			}
		}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Classic Mode Stuff 
///////////////////////////////////////////////////////////////////////////////
function DrewBlood()
{
	if(P2GameInfoSingle(Level.Game).GetClassicMelee()
		&& Class == Class'ShovelWeapon')
		return;
		
	Super.DrewBlood();
}

// xPatch: Make sure that this gun is not extension!
function bool CanSwapHands()
{
	return (Class == Class'ShovelWeapon');
}


////////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bNoHudReticle=true
	bUsesAltFire=true
	ItemName="Shovel"
	AmmoName=class'ShovelAmmoInv'
	PickupClass=class'ShovelPickup'
	AttachmentClass=class'ShovelAttachment'

	Mesh=Mesh'MP_Weapons.MP_LS_Shovel'
	OldMesh=Mesh'FP_Weapons.FP_Dude_Shovel'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	FirstPersonMeshSuffix="Shovel"

    AmbientGlow=128

	bMeleeWeapon=true
	ShotMarkerMade=None
	BulletHitMarkerMade=None
    bDrawMuzzleFlash=false

	holdstyle=WEAPONHOLDSTYLE_Melee
	switchstyle=WEAPONHOLDSTYLE_Double
	firingstyle=WEAPONHOLDSTYLE_Melee

	PawnHitMarkerMade=class'PawnBeatenMarker'

	//shakemag=350.000000
	//shaketime=0.200000
	//shakevert=(X=0.0,Y=0.0,Z=4.00000)
	FireOffset=(X=0.000000,Y=0.00000,Z=0.00000)
	ShakeOffsetMag=(X=5.0,Y=5.0,Z=5.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=6
	ShakeRotMag=(X=50.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=6

	//FireSound=Sound'WeaponSounds.shovel_fire1'
	//AltFireSound=Sound'WeaponSounds.shovel_fire2'
	CombatRating=1.5
	AIRating=0.11
	AutoSwitchPriority=1
	InventoryGroup=1
	GroupOffset=4
//	BobDamping=0.970000
	ReloadCount=0
	TraceAccuracy=0.005
	ViolenceRank=1
	bBumpStartsFight=false

	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.0
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1  = 1.3
	WeaponSpeedShoot1Rand=0.1
	WeaponSpeedShoot2  = 1.6
	AimError=200

	bAllowHints=true
	bShowHints=true
	bShowHint1=true
	HudHint1="Press %KEY_Fire% to swing."
	HudHint2="Press %KEY_AltFire% to stab."
	bCanThrowMP=false

	PlayerMeleeDist=120
	NPCMeleeDist=80.0
	MaxRange=95
	RecognitionDist=700
	
	KActorHitAngle=45
	
	BobDamping=1.12 
	
	BloodTextures[0]=Texture'WeaponSkins_Bloody.shovel_texture_blood01'
	BloodTextures[1]=Texture'WeaponSkins_Bloody.shovel_texture_blood02'
	ThirdPersonBloodSkinIndex=0
	
	bDropInVeteranMode=1
	VeteranModeDropChance=1.00
	}
