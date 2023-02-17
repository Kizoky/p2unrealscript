///////////////////////////////////////////////////////////////////////////////
// EnsmallenWeapon
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Weapon version of the Ensmallen Cure
///////////////////////////////////////////////////////////////////////////////
class EnsmallenWeapon extends P2Weapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var EnsmallenHelper MyHelper;		// Ref to our current Ensmallen shrinker
var bool bMadeContact;				// True if we hit something and we should inject them

///////////////////////////////////////////////////////////////////////////////
// Play animations
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	IncrementFlashCount();
	// Play MP sounds on everyone's computers
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(FireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else // just on yours in SP games
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
	PlayAnim('Jab', WeaponSpeedShoot1, 0.05);
}
simulated function PlayFiringMissed()
{
	PlayAnim('Jab_finish', WeaponSpeedShoot1, 0.05);
}
simulated function PlayInject()
{
	PlayAnim('Inject', WeaponSpeedShoot1, 0.05);
}
simulated function PlayInjectFinished()
{
	PlayAnim('Inject_finish', WeaponSpeedShoot1, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// Play inject
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
{
	IncrementFlashCount();
	// Play MP sounds on everyone's computers
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(AltFireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else // just on yours in SP games
		Instigator.PlaySound(AltFireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

	PlayAnim('Inject', WeaponSpeedShoot2, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// Look to see if we hit anything
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

	log(self@"dohit");
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
		else if(DoorMover(FirstHit) != None)
			bHitDoor=true;

		// Process the damage here
		AmmoType.ProcessTraceHit(self, FirstHit, LastHitLocation, HitNormal, X,Y,Z);
		bHitSomething=true;
	}

	// If we hit a pawn, don't say it was a solid hit, even if we hit other stuff
	if(LivePawnHit != None)
		bHitSolid=false;
	
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
		
	if (LivePawnHit != None)
		bMadeContact=true;
	else
		bMadeContact=false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// NormalFire
//
// Ensmallen Cure is a two-stage fire... stab then inject
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
	function AnimEnd(int Channel)
	{
		if (LastFireTimeSeconds != Level.TimeSeconds)
		{
			// Trace fire... see if we hit anything.
			DoHit(TraceAccuracy, 0, 0);
			
			// If we stabbed something, inject them with the stuff
			if (bMadeContact)
				GotoState('Inject');
			else // go back to waiting
				GotoState('Missed');
		}
	}
}

state Missed extends NormalFire
{
	function AnimEnd(int Channel)
	{
		Finish();
	}
Begin:
	PlayFiringMissed();
}

state Inject extends NormalFire
{
	function AnimEnd(int Channel)
	{
		if (LastFireTimeSeconds != Level.TimeSeconds)
		{
			// Now that we've injected them, do the shrinking
			if (MyHelper != None)
				MyHelper.GotoState('ShrinkingTarget');
			GotoState('InjectFinish');
		}
	}
Begin:
	Instigator.Acceleration = Vect(0,0,0);
	PlayInject();
}

state InjectFinish extends NormalFire
{
	function AnimEnd(int Channel)
	{
		Finish();
	}
Begin:
	PlayInjectFinished();
}

defaultproperties
{
	bNoHudReticle=true
	InventoryGroup=0
	GroupOffset=6

	bMeleeWeapon=true
	ShotMarkerMade=None
	BulletHitMarkerMade=None
    bDrawMuzzleFlash=false
	PlayerMeleeDist=120
	NPCMeleeDist=80.0
	MaxRange=95
	
	ItemName="Ensmallen Cure"
	AmmoName=class'EnsmallenAmmoInv'
	PickupClass=class'EnsmallenPickup'
	AttachmentClass=class'EnsmallenAttachment'
	holdstyle=WEAPONHOLDSTYLE_Melee
	switchstyle=WEAPONHOLDSTYLE_Melee
	firingstyle=WEAPONHOLDSTYLE_Melee
	CombatRating=0
	AIRating=0
	AutoSwitchPriority=1
	BobDamping=0.970000
	ReloadCount=0
	TraceAccuracy=0.005
	ViolenceRank=1
	bBumpStartsFight=false
	
	WeaponSpeedHolster = 4.0
	WeaponSpeedLoad    = 2.0
	WeaponSpeedReload  = 4.0
	WeaponSpeedShoot1  = 1.75
	WeaponSpeedShoot1Rand=0
	WeaponSpeedShoot2  = 1.75
	AimError=200

	Mesh=SkeletalMesh'MrD_PL_Anims.Needle_SM'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins[1]=Shader'MrD_PL_Tex.Weapons.Needle_Shader'
	Skins[2]=Shader'MrD_PL_Tex.Weapons.Needle_Goo_Yellow'
}