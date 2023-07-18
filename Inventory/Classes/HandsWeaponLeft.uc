///////////////////////////////////////////////////////////////////////////////
// PLHandsWeapon
// Copyright 2014, Running With Scissors, Inc.
//
// "Hands" weapon for PL dude, now with "fuck you" action!
// This is a special "overlay-only" version of the hands weapon so we can
// flip people off even while holding the photo, etc.
///////////////////////////////////////////////////////////////////////////////
class HandsWeaponLeft extends HandsWeapon;

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
	local Vector Res;
	local float Aspect;
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

	// Find the correct view model FOV
    if(!bOverrideAutoFOV)
    {
        if(ControllerFOV != PlayerOwner.DefaultFOV)
	    {
			// Approximation, the old method was pulling some weird shit in lower aspect ratios. Should be more consistent across aspects now.
	        ControllerFOV = PlayerOwner.DefaultFOV;
			
			Res = PlayerOwner.GetResolution();
			Aspect = Res.X / Res.Y;
			// 4:3 (1.333333) = Standard - 65
			// 1.6 = 72.5
			// 5:3 (1.666667) = 74
			// 16:9 (1.777778) = Widescreen - 75
			// 21:9 (2.333333) = Ultra-Widescreen - 88
			// 5.333333 = Triple-Head - 121
			
			// Approximates correct display FOV based on aspect ratio.
			if (Aspect <= 1.8)
				DisplayFOV = 23.f * Aspect + 36.333333;
			else
			{
				DisplayFOV = -99.555555/Aspect + 139.666666;
				// Push the view model down a bit on ultra-wide aspect ratios
				PlayerViewOffset.Z = Default.PlayerViewOffset.Z - 2;
			}
			//log("Aspect"@Aspect@"DisplayFOV"@DisplayFOV);
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
	Mesh=SkeletalMesh'FUArms.pl_fuckyou_arms'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="pl_fuckyou_arms"
	WeaponsPackageStr="FUArms"
	DrawScale3D=(X=-1,Y=1,Z=1)
}
