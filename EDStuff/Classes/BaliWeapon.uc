//=============================================================
//   Butterfly Knife Weapon
//   Eternal Damnation
//   Dopamine / MaDJacKaL
//
//   Edited by Man Chrzan, for xPatch
//=============================================================

class BaliWeapon extends P2BloodWeapon;

var float WeaponSpeedAltIdle;	// Alternative idle animation (knife sipin) speed
const IDLE_PLAY_FREQ = 0.15;	// How often do we play it.

replication
{
	// Functions called by server on client
	reliable if(Role == ROLE_Authority)
		ClientShovelShake;
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

    // randomly pick the animation to use
    switch ( rand(4) )
	{
       case 0:
            PlayAnim('Shoot1Down1', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
            break;
       case 1:
            PlayAnim('Shoot1Down2', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
            break;
	   case 2:
            PlayAnim('Shoot1Right', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
            break;
       case 3:
            PlayAnim('Shoot1Left', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
            break;
    }
}
simulated function PlayAltFiring()
{
	Super.PlayAltFiring();
	
	if(!bShowHint1)
		TurnOffHint();
		
    // pick the fastest animations
    switch ( rand(2) )
	{
		case 0:	
			PlayAnim('Shoot1', WeaponSpeedShoot2 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
			break;
		case 1:
			PlayAnim('Shoot1Left', WeaponSpeedShoot2 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
			break;
	}
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
        //Play firing animation and sound
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
						//DrewBlood();

					// Check to deliver damage
					dir = Victims.Location - HitLocation;
					dist = FMax(1,VSize(dir));
					dir = dir/dist;


//dopamine check this for how hard you are hitting
					AmmoType.ProcessTraceHit(self, Victims,
									Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
									HitNormal, X,Y,Z);
					bHitSomething=true;
				}
			}
		}
	}

	// If we hit a pawn, don't say it was a solid hit, even if we hit other stuff
	if(LivePawnHit != None)
	{
		bHitSolid = false;
// Handled in ammoinv now - for both dead and alive 
/*		if (P2MocapPawn(LivePawnHit) == None
			|| P2MocapPawn(LivePawnHit).MyRace < RACE_Automaton)
			DrewBlood();	*/
	}	

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
// Play our proper idling animation
///////////////////////////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	if ( FRand() <= IDLE_PLAY_FREQ )
		PlayAnim('Idle', WeaponSpeedAltIdle, 0.0);
	else
		PlayAnim('Idle_Static', WeaponSpeedIdle, 0.0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	local float diffoffset;

	Super.PostBeginPlay();

	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		// On hard difficulty and above, disable the reticle 
		diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset();
		if(diffoffset > 1)
		{
			bNoHudReticle = True;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
     bShowHint1=True
     bUsesAltFire=True
     ViolenceRank=2
     RecognitionDist=700.000000
     PawnHitMarkerMade=Class'Postal2Game.PawnBeatenMarker'
     //holdstyle=WEAPONHOLDSTYLE_Melee
	 holdstyle=WEAPONHOLDSTYLE_Toss
     switchstyle=WEAPONHOLDSTYLE_Single
     firingstyle=WEAPONHOLDSTYLE_Melee
     bNoHudReticle=False
     ShakeOffsetTime=6.000000
     PlayerMeleeDist=80.000000
     NPCMeleeDist=60.000000
     bAllowHints=True
     bShowHints=True
     HudHint1="Press %KEY_Fire% to slice."
     bBumpStartsFight=False
     CombatRating=1.500000
     FirstPersonMeshSuffix="ED_ButterflyKnife_NEW"
     WeaponsPackageStr="ED_Weapons."
     WeaponSpeedLoad=0.800000
     WeaponSpeedHolster=0.700000
     WeaponSpeedShoot1=1.000000
     WeaponSpeedShoot1Rand=0.100000
     WeaponSpeedShoot2=1.2500000
     AltFireSound=Sound'EDWeaponSounds.Weapons.Meatcleaver_slash'
     bCanThrowMP=False
     AmmoName=Class'BaliAmmoInv'
     FireOffset=(X=0.000000,Z=0.000000)
     ShakeRotRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(X=3.000000,Y=3.000000,Z=3.000000)
     TraceAccuracy=0.005000
     bMeleeWeapon=True
     aimerror=200.000000
     AIRating=0.110000
     MaxRange=95.000000
     FireSound=Sound'EDWeaponSounds.Weapons.Meatcleaver_slash'
     SelectSound=Sound'EDWeaponSounds.Fight.bali_load'
     GroupOffset=5
	 InventoryGroup=1
     PickupClass=Class'BaliPickup'
//     BobDamping=0.970000
     AttachmentClass=Class'BaliAttachment'
     ItemName="Bali"
     //Texture=Texture'ED_Hud.HUDbali'
     Mesh=SkeletalMesh'ED_Weapons.ED_ButterflyKnife_NEW'
    
     Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     //Skins(1)=Texture'ED_WeaponSkins.Melee.knifedds'
	 Skins(1)=Shader'xPatchTex.Weapons.BaliShad'
	 
	 //BloodTextures(0)=Texture'ED_WeaponSkins.Melee.knifehalfbloody'
     //BloodTextures(1)=Texture'ED_WeaponSkins.Melee.knifebloody'
     //BloodTextures(2)=Texture'ED_WeaponSkins.Melee.knifebloodyfull'
	 BloodTextures(0)=Shader'xPatchTex.Weapons.Bali_BloodyShad1'
     BloodTextures(1)=Shader'xPatchTex.Weapons.Bali_BloodyShad2'
     BloodTextures(2)=Shader'xPatchTex.Weapons.Bali_BloodyShad3'

	 AmbientGlow=128
	 BobDamping=1.120000
	 ThirdPersonBloodSkinIndex=0
	 
	 WeaponSpeedAltIdle=1.0
	 bAllowMiddleFinger=True
}
