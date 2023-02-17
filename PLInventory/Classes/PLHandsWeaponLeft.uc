///////////////////////////////////////////////////////////////////////////////
// PLHandsWeapon
// Copyright 2014, Running With Scissors, Inc.
//
// "Hands" weapon for PL dude, now with "fuck you" action!
// This is a special "overlay-only" version of the hands weapon so we can
// flip people off even while holding the photo, etc.
///////////////////////////////////////////////////////////////////////////////
class PLHandsWeaponLeft extends HandsWeapon;

var bool bDraw;			// Allow to be drawn during fire only

replication
{
	reliable if(Role==ROLE_Authority)
		bDraw;
}

///////////////////////////////////////////////////////////////////////////////
// Make it so things won't want to pick it
///////////////////////////////////////////////////////////////////////////////
function float RateSelf()
{
	return -2;
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
	
	// Make sure we're flipped correctly
	SetDrawScale3D(Default.DrawScale3D);
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
	
	if ( Instigator == None)
		//|| !bDraw)
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
		PlayFiring();
		bDraw=true;
	}
	function EndState()
	{
		Super.EndState();
		bDraw=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	// Pom-Pom likes the single deuce.
	PlayAnim('pl_fuckyou', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}
simulated function PlayAltFiring()
{
	// Don't do the double deuce when reversed, our other hand is probably holding onto a photo or something
	PlayAnim('pl_fuckyou', WeaponSpeedShoot2 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	Mesh=SkeletalMesh'PLFUArms.pl_fuckyou_arms'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="pl_fuckyou_arms"
	WeaponsPackageStr="PLFUArms"
	DrawScale3D=(X=-1,Y=1,Z=1)
}
