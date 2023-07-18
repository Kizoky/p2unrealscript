///////////////////////////////////////////////////////////////////////////////
// AWPGrenadeLauncherWeapon
// 
// by Man Chrzan for xPatch 3.0
// Grenade Launcher with auto-charging, burst-fire and other stuff.
// Based on the AWP variant but it now has completely new mechanics.
///////////////////////////////////////////////////////////////////////////////
class AWPGrenadeLauncherWeapon extends LauncherWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var() class<CatRocket> CatRocketClass;
var travel bool bShowAltHints;

var bool bWasAltFiring;

var localized array<string> FireModeStrings;
enum GLFireMode
{
    FM_Armed,
	FM_Unarmed,
};
var travel GLFireMode FireMode;

///////////////////////////////////////////////////////////////////////////////
// Get firing mode as string "burst" "auto" etc.
///////////////////////////////////////////////////////////////////////////////
simulated function string GetFiringMode()
{
	return FireModeStrings[FireMode];
}

///////////////////////////////////////////////////////////////////////////////
// Skip the charge intro (in grenade) -- go straight to charging
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	if ( AmmoType == None
		|| !AmmoType.HasAmmo() )
	{
		ClientForceFinish();
		ServerForceFinish();
		return;
	}

	// Turn off primary-fire hint
	TurnOffHint();

	bAltFiring=false;

	// No charging 
	ShootIt();

}

function ServerFire()
{
	bAltFiring=false;
	PrepCharge();
	GotoState('Charging');
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
	
	bAltFiring=true;
	bWasAltFiring=true;

	// Turn off alt-fire hint
	if(!bShowMainHints)
		TurnOffHint();

	ServerAltFire();
	if ( Role < ROLE_Authority )
	{
		PrepCharge();
		GotoState('Charging');
	}
}

function ServerAltFire()
{
	bAltFiring=true;
	bWasAltFiring=true;
	PrepCharge();
	GotoState('Charging');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

exec function Reload()
{
	ToggleMode();
}

function ToggleMode()
{
    switch (FireMode)
    {
        case FM_Armed:    FireMode = FM_Unarmed;
                         break;
						 
		case FM_Unarmed:    FireMode = FM_Armed;
                         break;
    }
	
	Instigator.PlaySound(TradSwitchSound, SLOT_Misc, 1.0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_ShootLauncher()
{
	local vector startloc, StartTrace, X,Y,Z, markerpos, HitNormal, HitLocation;
	local actor HitActor;
	local GrenadeProjectile gren;
	local float giveback;
	local int ChargedGrenades;	// How much grenades we charged to fire at once.
	local int i;


	if(AmmoType != None)
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z);
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		
		CalcChargeTime();
		CalcAIChargeTime();
		ShootStyleChanger=0;
		ChargedGrenades=1;

		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		StartLoc = StartTrace+ ((Instigator.CollisionRadius)*X);
		StartLoc.z+=(Instigator.CollisionRadius*0.5);
		
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			// Convert into Cat Launcher.
			if( bCatWasOnGun || RepeatCatGun == 1 )
			{
				PlaySound(CatViolateSound);
				SpawnCatRocket(Instigator, StartTrace, Rotator(X));
				
				bCatWasOnGun = false;
				if( RepeatCatGun == 1 )
				{
					bCatWasOnGun = true;
					CatOnGun = 1;
				}
			}
			else
			{
				if(bWasAltFiring)
					ChargedGrenades = ChargeStartAmmo - AmmoType.AmmoAmount;
					
				//PlayerController(Instigator.Controller).ClientMessage("ChargedGrenades:"@ChargedGrenades);
				
				for(i=0; i<ChargedGrenades; i++)
				{	
					if(ChargedGrenades > 1)
						StartLoc = StartTrace+(VRand()*45);
					
					if(FireMode == FM_Unarmed)
						gren = spawn(class'GrenadeAltProjectile',Instigator,,StartLoc, AdjustedAim); //Rotator(X)
					else
						gren = spawn(class'GrenadeProjectile',Instigator,,StartLoc, AdjustedAim);	//Rotator(X)
				
					if(gren != None)
					{
						gren.Instigator = Instigator;
						
						// Compensate for catnip time, if necessary. Don't do this for NPCs
						if(FPSPawn(Instigator) != None
							&& FPSPawn(Instigator).bPlayer)
							ChargeTime /= Level.TimeDilation;
						gren.SetupThrown(ChargeTime);
						gren.AddRelativeVelocity(Instigator.Velocity);
						// Touch any actor that was in between, just in case.
						if(HitActor != None)
							HitActor.Bump(gren);
					}
				}
			}
		}
		   
	}
	
	// If we didn't make a valid rocket, then give him his ammo back
	if(gren == None)
	{
		giveback = ChargeStartAmmo - AmmoType.AmmoAmount;
		if(giveback > 0)
			AmmoType.AddAmmo(giveback);
	}
	else
	{
		// Say we just fired
		ShotCount++;
		
		// Burst uses up ammo by charging
		// Auto the regular way
		if(!bWasAltFiring)
			P2AmmoInv(AmmoType).UseAmmoForShot();
		
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
	bWasAltFiring=False;
}

///////////////////////////////////////////////////////////////////////////////
// Determine by distance how far to throw/shoot projectiles
// Works similiar to CalcAIChargeTime but it's modified for the player!
///////////////////////////////////////////////////////////////////////////////
function CalcChargeTime()
{
	local P2Player p2p;
	local vector dir;
	local vector HitNormal, StartTrace, EndTrace, X,Y,Z;

	if(P2Player(Instigator.Controller) != None)
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = Instigator.Location + Instigator.EyePosition();//GetFireStart(X,Y,Z);
		EndTrace = StartTrace + TraceDist*X;
	
		Trace(LastHitLocation, HitNormal, EndTrace, StartTrace, true);

		// Find the distance to our attacker
		dir = (LastHitLocation - Instigator.Location);

		// Figure out about how long to make the charge time for it to shoot to our target
		// and factor in bad AI charging times
		ChargeTime = VSize(dir)/(ChargeDistRatio); // + ((FRand()*AimError) - AimError/2));
		if(ChargeTime > ChargeTimeMaxAI)
			ChargeTime = ChargeTimeMaxAI;
		if(ChargeTime < ChargeTimeMinAI)
			ChargeTime = ChargeTimeMinAI;
			
		//PlayerController(Instigator.Controller).ClientMessage("CalcChargeTime() / "@LastHitLocation@" / "@ChargeTime);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

function SpawnCatRocket(Pawn Instigator, Vector StartLoc, Rotator StartRot)
{
	local CatRocket CatR;
	local vector MarkerPos;

	CatR = spawn(CatRocketClass, Instigator,, StartLoc, StartRot);
	if (CatR != None)
	{
		CatR.Instigator = Instigator;
		CatR.AddRelativeVelocity(Instigator.Velocity);

		// Say we just fired
		ShotCount++;
		
		P2AmmoInv(AmmoType).UseAmmoForShot(1);

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
}

///////////////////////////////////////////////////////////////////////////////
// Pick random charge animation
///////////////////////////////////////////////////////////////////////////////
simulated function PlayCharging()
{
	if (FRand() <= 0.5)
		PlayAnim('Shoot2Prep', WeaponSpeedCharge, 0.05);
	else
		PlayAnim('Shoot1Prep', WeaponSpeedCharge, 0.05);
}

defaultproperties
{
     bUsesAltFire=True
     MinRange=1280.000000
     WeaponSpeedShoot1Rand=0.150000
     OverrideHUDIcon=Texture'xPatchTex.HUD.Icon_GLauncher'
     AmmoName=Class'Inventory.GrenadeAmmoInv'
     MaxRange=2048.000000
     FireSound=Sound'WeaponSounds.napalm_fire'
     InventoryGroup=10
     GroupOffset=154
     PickupClass=Class'AWPGrenadeLauncherPickup'
     AttachmentClass=Class'AWPGrenadeLauncherAttachment'
     ItemName="Super Grenade Launcher"
	 
	 Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	 Skins(1)=Texture'AW7Tex.Weapons.GrenadeLauncher'
	 Skins(2)=Shader'xPatchTex.Weapons.fuel_gauge_empty_unit'
	 Skins(3)=Shader'xPatchTex.Weapons.fuel_gauge_full_unit'
	 
	 AmmoUseRate=2
	 InitialAmmoCost=1
	 
	 AimError=25 //500
	 ChargeTimeModifier=1.5
	 ChargeWaitState="ChargeWaitGrenade"
	 ChargeDistRatio=1800
	 ChargeTimeMaxAI=1.2
	 ChargeTimeMinAI=0.2
	 
	 FuelingSound=Sound'WeaponSounds.launcher_fueling'
	 TradSwitchSound=Sound'MiscSounds.Radar.PluginActivate'
	 SeekerSound=None 
	 
	 FireModeStrings[0]="Armed"
	 FireModeStrings[1]="Unarmed"
	 
	 HudHint1="Press %KEY_Reload% to change firing mode." //"Press %KEY_Fire% to fire grenades, in rapid-fire fashion!"
	 HudHint2="Press and hold %KEY_AltFire% to fire multiple grenades at once!"
	 //ReloadHint1="Press %KEY_Reload% to change firing mode."
	 
	 WeaponSpeedShoot1=1.25
	 WeaponSpeedShoot2=0.25
	 WeaponSpeedCharge=1.00
	 
	 CatRocketClass=Class'CatRocketGrenade'
}
