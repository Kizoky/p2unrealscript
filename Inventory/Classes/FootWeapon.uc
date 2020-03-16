///////////////////////////////////////////////////////////////////////////////
// FootWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Foot weapon (first and third person).
//
// Gets used when you kick
//
// This weapon is SEPERATE from the player's normal inventory. It's in
// P2Pawn::MyFoot and thus must be handled seperately.
//
// It is only to be visible during it's fire (the kick) and is handled
// seperately in P2Hud.
//
// It is like this so that the player can kick with any other weapon and
// at mostly any time.
//
///////////////////////////////////////////////////////////////////////////////

class FootWeapon extends ShovelWeapon;

var bool bDraw;			// Allow to be drawn during fire only
var class<TimedMarker> NoHitMarkerMade;
var() float CleanBloodTime;	// How long between kicks for any blood skins to clean off
var float LastKickTime;		// Last time we kicked our foot

replication
{
	reliable if(Role==ROLE_Authority)
		bDraw;
}

///////////////////////////////////////////////////////////////////////////////
// If we keep this then it checks for Fire being pressed and contines to kick
// in MP. No need for 'auto-kicking' so just go to idle.
///////////////////////////////////////////////////////////////////////////////
function Finish()
{
	GotoState('Idle');
}
simulated function ClientFinish()
{
	GotoState('Idle');
}

///////////////////////////////////////////////////////////////////////////////
// Play our proper idling animation
///////////////////////////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
}

///////////////////////////////////////////////////////////////////////////////
// Make it so things won't want to pick it
///////////////////////////////////////////////////////////////////////////////
function float RateSelf()
{
	return -2;
}

///////////////////////////////////////////////////////////////////////////////
// Change the hands and use the body skin from your owner to use as your
// changed skin
///////////////////////////////////////////////////////////////////////////////
simulated function ChangeHandTexture(Texture NewHandsTexture, Texture DefHandsTexture,
									 Texture NewFootTexture)
{
	local int i;

	for(i=0; i<Skins.Length; i++)
	{
		if(default.Skins[i] == DefHandsTexture)
			Skins[i] = NewHandsTexture;
	}

	Skins[0] = NewFootTexture;
}

///////////////////////////////////////////////////////////////////////////////
// Give this inventory item to a pawn.
///////////////////////////////////////////////////////////////////////////////
function GiveTo( pawn Other )
{
	Instigator = Other;
	//Other.AddInventory( Self );
	GotoState('');

	bTossedOut = false;

	//	GiveAmmo(Other);
	ClientWeaponSet(true);

	// Be hidden. Allow bDraw to control drawing.
	bHidden=true;

	if(bMeleeWeapon
		&& P2Pawn(Other) != None)
	{
		if(P2Player(P2Pawn(Other).Controller) != None)
			UseMeleeDist = PlayerMeleeDist;
		else
			UseMeleeDist = NPCMeleeDist;
	}
}

///////////////////////////////////////////////////////////////////////////////
// We don't want a muzzle flash and because we're always present the
// Pawn.Weapon will draw in the crosshairs, so we don't have to, so
// try to draw in the crosshairs.
// The foot is usually set to bDraw unless it's firing. If bDraw is
// set this function will short-circuit.
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local  PlayerController PlayerOwner;
	local int Hand;
	local float ControllerFOV;
    // We need something to match the controller so it's not constantly setting the fov.
	ControllerFOV = 0;

	if ( Instigator == None
		|| !bDraw)
		return;

	PlayerOwner = PlayerController(Instigator.Controller);

	if ( PlayerOwner != None )
	{
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;
		if (  Hand == 2 )
			return;
	}

	//
	// Find the correct view model FOV
    if(!bOverrideAutoFOV)
    {
        if(ControllerFOV != PlayerOwner.DefaultFOV)
	    {
            // This seems to work nicely
	        DisplayFOV = (PlayerOwner.DefaultFOV - 20);
	        ControllerFOV = PlayerOwner.DefaultFOV;
        }
    }

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
	NewRot = Instigator.GetViewRotation();

	if ( Hand == 0 )
		newRot.Roll = 2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	setRotation(newRot);

	Canvas.DrawActor(self, false, true, DisplayFOV);
}

///////////////////////////////////////////////////////////////////////////////
// We didn't hit anything when we fired/swung our weapon
// Tell everyone about our stupid kicking, that can see us
///////////////////////////////////////////////////////////////////////////////
function HitNothing()
{
	NoHitMarkerMade.static.NotifyControllersStatic(
		Level,
		NoHitMarkerMade,
		FPSPawn(Instigator),
		FPSPawn(Instigator), // We want the creator to be instigator also because
		// this is much more like a gunfire sort of thing, rather than a pawn hit by a bullet
		NoHitMarkerMade.default.CollisionRadius,
		Instigator.Location);
}

///////////////////////////////////////////////////////////////////////////////
// Animation driven collision hit
///////////////////////////////////////////////////////////////////////////////
simulated function NotifyKickHit()
{
	DoHit(TraceAccuracy, 0, 0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function DoHit( float Accuracy, float YOffset, float ZOffset )
{
	// Automatically clean the blood off if they don't kick for a time
	//if (LastKickTime == 0 || Level.TimeSeconds - LastKickTime > CleanBloodTime)
		//CleanWeapon();
		
	LastKickTime = Level.TimeSeconds;
	
	Super.DoHit(Accuracy, YOffset, ZOffset);
}

///////////////////////////////////////////////////////////////////////////////
// Normal trace fire, plus check where to make the danger marker to
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	// STUB--driven by animation
}

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	Super.PlayFiring();

	if(P2Player(Instigator.Controller) != None)
	{
		P2MocapPawn(Instigator).PerformKick();
	}
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Weapon is up and ready to fire, but not firing.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
{
	simulated function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// NormalFire, control visibility
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
	ignores ServerFire, ServerAltFire;

	function BeginState()
	{
		Super.BeginState();
		// Don't show foot (but still allow kick) for certain weapons
		if(P2Weapon(Instigator.Weapon) == None
			|| !P2Weapon(Instigator.Weapon).bHideFoot)
			bDraw=true;
	}
	function EndState()
	{
		Super.EndState();
		bDraw=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bNoHudReticle=true
	bHidden=true
	ItemName="Foot"
	AmmoName=class'FootAmmoInv'
	PickupClass=None // make sure not to inherit from shovel

	Mesh=Mesh'FP_Weapons.FP_Dude_Foot'
	Skins[0]=Texture'ChameleonSkins.Special.Dude'
	Skins[1]=Texture'WeaponSkins.Dude_Hands'
	FirstPersonMeshSuffix="Foot"

	bCanThrow=false
	bMeleeWeapon=true
	ShotMarkerMade=None
	BulletHitMarkerMade=None

	holdstyle=WEAPONHOLDSTYLE_Melee
	switchstyle=WEAPONHOLDSTYLE_Melee
	firingstyle=WEAPONHOLDSTYLE_Melee
    bDrawMuzzleFlash=false

	NoHitMarkerMade=class'KickHitNothingMarker'

	FireOffset=(X=2.000000,Y=0.00000,Z=-1.00000)
	//shakemag=500.000000
	//shaketime=0.200000
	//shakevert=(X=0.0,Y=0.0,Z=4.00000)
	ShakeOffsetMag=(X=3.0,Y=3.0,Z=3.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=3.0
	ShakeRotMag=(X=250.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=3.0

	CombatRating=0.0
	FireSound=Sound'WeaponSounds.Foot_Fire'
	AIRating=0.0
	AutoSwitchPriority=0
	InventoryGroup=1
	GroupOffset=4
	BobDamping=0.975000
	ReloadCount=0
	TraceAccuracy=0.05
//	DrawScale3D=(X=1.5,Y=1.5,Z=1.5)
	ViolenceRank=1

	WeaponSpeedHolster = 0.6
	WeaponSpeedLoad    = 1.0
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.3
	WeaponSpeedShoot2  = 1.0
	AimError=200

	PlayerMeleeDist=135
	NPCMeleeDist=50.0
	MaxRange=95
	MaxRange=275
	bAllowHints=false
	bStopAtDoor=true
	bCannotBeStolen=true
	BloodTextures[0]=Texture'WeaponSkins_Bloody.Dude_blood01'
	BloodTextures[1]=Texture'WeaponSkins_Bloody.Dude_blood02'
	CleanBloodTime=10.0
	}
