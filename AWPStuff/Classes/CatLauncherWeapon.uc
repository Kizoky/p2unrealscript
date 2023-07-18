///////////////////////////////////////////////////////////////////////////////
// CatLauncherWeapon
// 
// by Man Chrzan for xPatch 2.0
//
// Ported from AWP and updated with new cat rockets and option 
// to change cat-mode with right mouse button.
//
///////////////////////////////////////////////////////////////////////////////

class CatLauncherWeapon extends LauncherWeapon;

var float Speed;

var Sound SwitchSound;
var localized array<string> CatModeStrings;
var bool bDisplayFireMode;

enum CFireMode
{
    FM_Cat,
	FM_CatBouncy,
    FM_CatNado,
    FM_CatGrenade,
	FM_CatGrenadeBouncy,
};

var travel CFireMode CatMode;

///////////////////////////////////////////////////////////////////////////////
// When you're sent to jail most weapons are taken. The Radar things aren't. Perhaps
// they want to do something now.
///////////////////////////////////////////////////////////////////////////////
function AfterItsTaken(P2Pawn CheckPawn)
{
	Destroy();
}

function ServerFire()
{
	bAltFiring=false;
	ShootIt();
}

function ServerAltFire()
{
	ToggleMode();
}

function ToggleMode()
{
    switch (CatMode)
    {
        case FM_Cat:    CatMode = FM_CatBouncy;
                         break;
						 
		case FM_CatBouncy:    CatMode = FM_CatNado;
                         break;

        case FM_CatNado:   CatMode = FM_CatGrenade;
                         break;

        case FM_CatGrenade:    CatMode = FM_CatGrenadeBouncy;
                         break;
		
		case FM_CatGrenadeBouncy:    CatMode = FM_Cat;
                         break;
    }
	
	Instigator.PlaySound(SwitchSound, SLOT_Misc, 1.0);
}

///////////////////////////////////////////////////////////////////////////////
// Get firing mode as string "burst" "auto" etc.
///////////////////////////////////////////////////////////////////////////////
simulated function string GetFiringMode()
{
	if (bDisplayFireMode)
		return CatModeStrings[CatMode];
}

///////////////////////////////////////////////////////////////////////////////
// Add a controller to our newly spawned cat
///////////////////////////////////////////////////////////////////////////////
function AddController(FPSPawn newcat)
{
	if ( newcat.Controller == None
		&& newcat.Health > 0 )
	{
		if ( (newcat.ControllerClass != None))
			newcat.Controller = spawn(newcat.ControllerClass);
		if ( newcat.Controller != None )
		{
			newcat.Controller.Possess(newcat);
			if(CatRocketPawn(newcat) != None)
				newcat.Controller.GotoState('FallingStartDervishRocket'); 
			else
				newcat.Controller.GotoState('FallingFar');
		}
		// Check for AI Script
		newcat.CheckForAIScript();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_ShootLauncher()
{
	local vector startloc, StartTrace, X,Y,Z, markerpos, HitNormal, HitLocation, Dir, UseVel;
	local actor HitActor;
	local CatRocketPawn CatNdo;
	local CatRocket CatProj;
	local float giveback;
	
	if(AmmoType != None)
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z); 
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		CalcAIChargeTime();
		ShootStyleChanger=0;
		// Make sure we're not generating this on the other side of a thin wall
		//if(FastTrace(Instigator.Location, StartTrace))
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		StartLoc = sTARTTrace+ ((Instigator.CollisionRadius)*X);
		StartLoc.z+=(Instigator.CollisionRadius*0.5);
		
		// new
		Dir = vector(Instigator.GetViewRotation());
		UseVel = Speed * Dir;
		
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			//CatNdo = spawn(class'CatRocket2',Instigator,,StartLoc, Rotator(X));
			
			if (CatMode == FM_Cat || CatMode == FM_CatBouncy)
			{
				CatProj = spawn(class'CatRocket2',Instigator,,StartLoc, Rotator(X));
			}
			if (CatMode == FM_CatNado)
			{
				//CatNdo = spawn(class'CatRocketPawn',Instigator,,StartLoc, Rotator(X));
				
				CatNdo = spawn(class'CatRocketPawn',,,StartLoc, rotator(X));
				//class'CatRocketPawn'.static.AddController(FPSPawn(CatNdo));
				CatNdo.AddVelocity(UseVel);
				AddController(CatNdo);
			}
			if (CatMode == FM_CatGrenade || CatMode == FM_CatGrenadeBouncy)
			{
				CatProj = spawn(class'CatRocket3',Instigator,,StartLoc, Rotator(X));
			}
			  
			
			if(CatProj != None)
			{
				CatProj.Instigator = Instigator;
				
				// Compensate for catnip time, if necessary. Don't do this for NPCs
				if(FPSPawn(Instigator) != None
					&& FPSPawn(Instigator).bPlayer)
					ChargeTime /= Level.TimeDilation;
					
				CatProj.AddRelativeVelocity(Instigator.Velocity);
				
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
					HitActor.Bump(CatProj);
				
				// Do Bounces in Bouncy Mode
				if (CatMode == FM_CatBouncy || CatMode == FM_CatGrenadeBouncy )
					CatProj.bDoBounces=true;
			}
			
/*		    if(CatGrn != None)
			{
				CatProj.Instigator = Instigator;
				
				// Compensate for catnip time, if necessary. Don't do this for NPCs
				if(FPSPawn(Instigator) != None
					&& FPSPawn(Instigator).bPlayer)
					ChargeTime /= Level.TimeDilation;
					
				CatProj.AddRelativeVelocity(Instigator.Velocity);
				
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
					HitActor.Bump(CatProj);
				
				// Do Bounces in Bouncy Mode
				if (CatMode == FM_CatGrenadeBouncy)
					CatGrn.bDoBounces=true;
			}	*/
		}

		// Clear our target regardless
		CurrentTarget = None;
		// If we didn't make a valid rocket, then give him his ammo back
		if(CatProj == None)
		{
			giveback = ChargeStartAmmo - AmmoType.AmmoAmount;
			if(giveback > 0)
				AmmoType.AddAmmo(giveback);
		}
		else
		{
			// Say we just fired
			ShotCount++;

			// Only make a new danger marker if the consecutive fires were as high
			// as the max
			if(ShotCount >= ShotCountMaxForNotify
				&& Instigator.Controller != None
				&& ShotMarkerMade != None)
			{
				// tell it we know this just happened, by recording it.
				ShotCount -= ShotCountMaxForNotify;
				
				// Records the first (gun fire)
				markerpos = Instigator.Location;
				
				// Primary (the gun shooting, making a loud noise)
				if(ShotMarkerMade != None)
				{
					ShotMarkerMade.static.NotifyControllersStatic(
						Level,
						ShotMarkerMade,
						FPSPawn(Instigator), 
						None, 
						ShotMarkerMade.default.CollisionRadius,
						markerpos);
				}
			}
		}
		// Reset the ammo you started with
		ChargeStartAmmo = AmmoType.AmmoAmount;
	}
}

/*
state Active
{
	function BeginState()
	{
		Super.BeginState();
		P2Player(Instigator.Controller).ClientMessage("Cat Launcher selected");
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// Disable dual wielding
///////////////////////////////////////////////////////////////////////////////
function SetupDualWielding()
{
}

simulated function BringUp()
{
	Super(P2Weapon).BringUp();
}

state ToggleDualWielding
{
	function BeginState()
	{
		GotoState('Idle');
	}
	function AnimEnd(int Channel);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     ViolenceRank=1
     ShotMarkerMade=Class'Postal2Game.FunnyThingMarker'
     AmmoName=Class'CatAmmoInv'
     FireOffset=(Y=0.000000)
     FireSound=Sound'WeaponSounds.shotgun_catfire'
     GroupOffset=155
     PickupClass=Class'CatLauncherPickup'
     AttachmentClass=Class'CatLauncherAttachment'
     ItemName="Cat Launcher"
	 
	 Speed=2000
	 
	 Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	 Skins(1)=Texture'xPatchTex.Weapons.launcher_cat'
	 Skins(2)=Texture'xPatchTex.Weapons.fuel_gauge_CAT'
	 Skins(3)=Texture'xPatchTex.Weapons.fuel_gauge_CAT'
	 
	 WeaponSpeedShoot1=3.0
	 WeaponSpeedLoad=2.000000
	 WeaponSpeedIdle=0.300000  
	 bNoHudReticle=false   
	 HudHint1="Press %KEY_AltFire% to select cats."
	 HudHint2=""
	
	 SwitchSound=Sound'AnimalSounds.Cat.CatShreak'
	 bDisplayFireMode=True
	 CatModeStrings(0)="Cat"
	 CatModeStrings(1)="Cat (Bouncy)"
     CatModeStrings(2)="Cat-Nado"
     CatModeStrings(3)="Cat-Grenade"
	 CatModeStrings(4)="Cat-Grenade (Bouncy)"
}
