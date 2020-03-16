/**
 * DualCatableWeapon
 * Copyright 2014, Running With Scissors, Inc.
 *
 * Basically the same weapon base as CatableWeapon only we extend from the
 * P2DualWieldWeapon instead so we can inherit the dual wielding functionality.
 *
 * @author Gordon Cheng
 */
class DualCatableWeapon extends P2DualWieldWeapon;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////

const MAX_TIME_TILL_MOAN	=	10.0;
const MAX_MOAN_SOUNDS		=	3.0;

var bool bPutCatOnGun;			// A cat is getting slapped on us
var travel int  CatOnGun;		// A cat is stuck on the end of this gun, to act as silencer
var Mesh CatMesh;				// Mesh to use with cat on gun
var Texture MFBloodTexture;		// bloody muzzle flash
var travel Texture CatSkin;		// Texture the cat on the gun has
var travel int CatAmmoLeft;		// How many shots we've taken with the cat, when this reaches
								// 0, the cat shoots off
var int StartShotsWithCat;		// total shots we get with a cat, probably 9 for 9 lives
var Sound CatFireSound;			// sound to use when cat is on gun
var Sound CatViolateSound;		// sound for when cat is first violated by the muzzle
var Sound CatMoanSound[MAX_MOAN_SOUNDS];	// it's on the gun, and it's hurt
var float TimeMoan;				// time for moans
var float TimeTillMoan;			// time till it will moan
var bool bMoaning;				// to know the time till moan means it's moaning now

var int CatSkinIndex;			// Index into all catable weapons that the cat skin goes
								// It is necessary to expand the skins array to include
								// a cat skin for weapons that use the cat, but don't currently have it, and for
								// weapons that have a cat on it (like shotgun, and shotguncat). The idea is
								// with the skin used the same, we can swap the skin out for a specific cat skin
								// for this weapon, because we have several different cat skins.
								// We couldn't easily make the cat skin be in Skins[0] becuase none of the
								// models were originaly built with this in mind.
var travel byte RepeatCatGun;	// Cheat that has this gun continually shoot off cats once it gets started
var travel byte BounceCat;		// Cheat that makes cats bounce off walls (not people) after they shoot off

const CAT_PITCH_INCREASE	=	0.03;


///////////////////////////////////////////////////////////////////////////////
// If you toss out a gun with a cat on it,
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
	local CatInv tempcat;

	// Throw out a cat with the gun if he's on it.
	if(CatOnGun == 1)
	{
		tempcat = spawn(class'CatInv');
		if(tempcat != None)
		{
			tempcat.AddAmount(1, CatSkin);
			tempcat.DropFrom(StartLocation);
			tempcat.Destroy();
		}
	}

	Super.DropFrom(StartLocation);
}

///////////////////////////////////////////////////////////////////////////////
// Swap meshes and animations appropriately for cat on gun
///////////////////////////////////////////////////////////////////////////////
function SwapCatOn()
{
	LinkMesh( CatMesh, true);

	SetLeftArmVisibility();

	if(class'P2Player'.static.BloodMode())
		MFTexture = MFBloodTexture;
	else
		MFTexture = default.MFTexture;

	// Do actual silencing!! (silencer part)
	// Turn off sounds so no one gets freaked out unless you actaully hit them
	ShotMarkerMade = None;
	BulletHitMarkerMade = None;
	// Make the way people recognize shot people be reduced to having to see
	// it happen.
	PawnHitMarkerMade = class'PawnBeatenMarker';

	// Put the correct cat skin on the gun, always in the last slot
	Skins[CatSkinIndex] = CatSkin;
}

///////////////////////////////////////////////////////////////////////////////
// Swap meshes and animations appropriately for normal shotgun
///////////////////////////////////////////////////////////////////////////////
function SwapCatOff()
{
	LinkMesh( default.Mesh);
	SetLeftArmVisibility();

	MFTexture = default.MFTexture;
	// Undo actual silencing!! (silencer part)
	// Turn sounds back on, so people freak out again
	ShotMarkerMade = default.ShotMarkerMade;
	BulletHitMarkerMade = default.BulletHitMarkerMade;
	PawnHitMarkerMade = default.PawnHitMarkerMade;
}

///////////////////////////////////////////////////////////////////////////////
// Toggle between shooting cats constantly and not.
///////////////////////////////////////////////////////////////////////////////
function ToggleRepeatCatGun(bool bOn)
{
	if(bOn)
		RepeatCatGun=1;
	else
		RepeatCatGun=0;

	if(RepeatCatGun == 1)
	{
		CatAmmoLeft=1;
		if(CatOnGun==0)
		{
			SwapCatOn();
			CatOnGun=1;
			GotoState('Idle');
		}
	}
	else
	{
		if(CatOnGun == 1)
		{
			CatAmmoLeft=0;
			SwapCatOff();
			CatOnGun=0;
			GotoState('Idle');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// This gun is ready for a cat to be put on it
///////////////////////////////////////////////////////////////////////////////
function bool ReadyForCat()
{
	return (AmmoType.HasAmmo()
			&& CatOnGun==0
			&& !bPutCatOnGun
			&& IsInState('Idle'));
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the muzzle flash renders, and move it around some
///////////////////////////////////////////////////////////////////////////////
simulated function SetupMuzzleFlash()
{
	bMuzzleFlash = true;
	bSetFlashTime = false;
	// Gets turned off in weapon, in RenderOverlays
	// Slightly change colors each time
	if(IsFirstPersonView()
		&& bDrawMuzzleFlash)
	{
		PickLightValues();
		bDynamicLight=bAllowDynamicLights;
	}
}


///////////////////////////////////////////////////////////////////////////////
// Fire cat off gun, flying through the air as a rocket of sorts
///////////////////////////////////////////////////////////////////////////////
function ShootOffCat()
{
	local vector StartLoc, X,Y,Z;
	local CatRocket catr;

	GetAxes(Instigator.Rotation,X,Y,Z);
	StartLoc = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartLoc, 2*AimError);
	X = vector(AdjustedAim);
	StartLoc += ((Instigator.CollisionRadius)*X*1.5);
	StartLoc.z+=(Instigator.CollisionRadius*1);

	// Record that we killed the cat
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& P2Pawn(Instigator) != None
		&& P2Pawn(Instigator).bPlayer)
	{
		P2GameInfoSingle(Level.Game).TheGameState.CatsKilled++;
	}

	catr = spawn(class'CatRocket',Instigator,,StartLoc,Rotator(X));
	if(catr != None)
	{
		catr.Instigator = Instigator;
		catr.AddRelativeVelocity(Instigator.Velocity);
		// put the right skin on it
		catr.Skins[0] = CatSkin;
		if(BounceCat != 0)
			catr.bDoBounces=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Fire the weapon
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	local float UsePitch;
	local vector StartTrace, X,Y,Z;

	// If the cat is on the gun and we want it to fly off, then set it up to fly off,
	// by switching the animation
	if(CatOnGun==1)
		{
		// Switch to special sound
		FireSound=CatFireSound;
		// Pitch higher with each consecutive shot
		UsePitch = WeaponFirePitchStart + (CAT_PITCH_INCREASE*(StartShotsWithCat - CatAmmoLeft));

		if (CatAmmoLeft==0
			|| !AmmoType.HasAmmo())
			{
			// Remove our cat and shoot him off, unless we have a cheat set to
			// keep shooting them off
			if(RepeatCatGun == 0)
				{
				SwapCatOff();
				ShootOffCat();
				CatOnGun=0;
				}
			else // Cheat
				{
				CatAmmoLeft=1;
				ShootOffCat();
				}
			}
		}
	else
		{
		// Use normal firing sound
		FireSound=Default.FireSound;
		UsePitch = WeaponFirePitchStart + (FRand()*WeaponFirePitchRand);
		}

	// Normal playfiring for P2Weapon, but we pitch the fire sound for a cat, higher and
	// higher with each shot, if we're shooting with a cat.
	IncrementFlashCount();

	// Play it here (instead of in the attachment) in SP games
	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , UsePitch);

	PlayAnim('Shoot1', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);

	SetupMuzzleFlash();
}

///////////////////////////////////////////////////////////////////////////////
// Set the ammo for the cat and swap back to that weapon
///////////////////////////////////////////////////////////////////////////////
function SetToPutCatOnGun()
{
	local P2Player p2p;

	p2p = P2Player(Instigator.Controller);

	CatAmmoLeft = StartShotsWithCat;

	SelectSound = CatViolateSound;
	// Go back to this weapon
	p2p.SwitchToThisWeapon(default.InventoryGroup,
								default.GroupOffset);
}

///////////////////////////////////////////////////////////////////////////////
// Make sure we change our animations for each weird weapon
///////////////////////////////////////////////////////////////////////////////
simulated function BringUp()
{
	Super.BringUp();

	// For some reason even though the left weapon is being put down, the
    // AnimEnd doesn't get called, so make sure we set the left weapon
    // with a kitty as well
    if (RightWeapon != none && bPutCatOnGun) {
        log("Telling left weapon to setup kitty");
        SetToPutCatOnGun();
    }

	if(bPutCatOnGun)
	{
		bPutCatOnGun=false;
		SelectSound = default.SelectSound;
	}
}

///////////////////////////////////////////////////////////////////////////////
// set mesh
///////////////////////////////////////////////////////////////////////////////
simulated function SetRightHandedMesh()
{
	if(CatOnGun==1)
		SwapCatOn();
	else
		SwapCatOff();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ResetMoanVals()
{
	bMoaning=false;
	TimeMoan=0;
	TimeTillMoan=FRand()*MAX_TIME_TILL_MOAN;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DownWeapon
//Putting down weapon in favor of a new one.  No firing in this state
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
State DownWeapon
{
	simulated function AnimEnd(int Channel)
	{
		Super.AnimEnd(Channel);

        if (bPutCatOnGun)
			SetToPutCatOnGun();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Make the cat moan while it's on the gun
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		local int soundI;

		Super.Tick(DeltaTime);

		// if the cat is on the gun, and he's not being shot, then sometimes make him moan
		if(CatOnGun==1)
		{
			if(bMoaning)
			{
				TimeMoan-=DeltaTime;
				if(TimeMoan <= 0)
				{
					ResetMoanVals();
				}
			}
			else
			{
				// moan every once in a while
				TimeMoan+=DeltaTime;
				if(TimeMoan > TimeTillMoan)
				{
					bMoaning=true;
					// we like the moan the most, in the first slot, so use it the most
					if(FRand() <= 0.5)
						soundI = 0;
					else
						soundI = FRand()*MAX_MOAN_SOUNDS;
					Instigator.PlayOwnedSound(CatMoanSound[soundI], SLOT_Misc, 1.0, false, 1000.0, (0.96 + FRand()*0.08));
					TimeMoan = GetSoundDuration(CatMoanSound[soundI]);
				}
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		ResetMoanVals();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	CatViolateSound=Sound'AnimalSounds.Cat.CatVicious'
	CatMoanSound[0]=Sound'AnimalSounds.Cat.CatMoan1'
	CatMoanSound[1]=Sound'AnimalSounds.Cat.CatGrowl1'
	CatMoanSound[2]=Sound'AnimalSounds.Cat.CatGrowl2'
	CatSkin = Texture'AnimalSkins.Cat_Orange'
	CatSkinIndex=3

	ShotMarkerMade=class'GunfireMarker'
	BulletHitMarkerMade=class'BulletHitMarker'
	PawnHitMarkerMade=class'PawnShotMarker'
	}
