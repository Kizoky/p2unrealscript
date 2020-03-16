class NukeWeapon extends LauncherWeapon;

function bool ValidTarget(FPSPawn TestTarget)
{
	return false;
}

simulated function AltFire( float Value );
function ServerAltFire();

///////////////////////////////////////////////////////////////////////////////
// Skip the charge, go straight to the fire
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


	bAltFiring=false;
	ShootIt();
	ClientShootIt();
	//ServerFire();
}
/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerFire()
{
	PlayFiring();
	LocalFire();
	ClientPlayFiring();
	ShootIt();
	ClientShootIt();
}*/

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_ShootLauncher()
{
	local vector StartTrace, X,Y,Z, markerpos, HitNormal, HitLocation;
	local actor HitActor;
	local NukeProjectile lpro;
	//local MPNukeSeekingProjectileTrad lspro;
	local float giveback;

	if(AmmoType != None)
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z); 
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		//CalcAIChargeTime();
		ShootStyleChanger=0;
		// Make sure we're not generating this on the other side of a thin wall
		//if(FastTrace(Instigator.Location, StartTrace))
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			/*if(!bSeeking)
				// fire a normal rocket
			{*/
				lpro = spawn(class'NukeProjectile',Instigator,,StartTrace, AdjustedAim);
				if(lpro != None)
				{
					ChargeTime=30;
					lpro.Instigator = Instigator;
					// Compensate for catnip time, if necessary. Don't do this for NPCs
					if(FPSPawn(Instigator) != None
						&& FPSPawn(Instigator).bPlayer)
						ChargeTime /= Level.TimeDilation;
					lpro.SetupShot(ChargeTime);
					lpro.AddRelativeVelocity(Instigator.Velocity);
					// Touch any actor that was in between, just in case.
					if(HitActor != None)
						HitActor.Bump(lpro);
				}
			/*}
			else // fire a seeking rocket
			{
				// Shoot either a traditional seeking rocket or a new super seeker
				if(!bShootTradSeeker)
					lspro = spawn(class'MPNukeSeekingProjectile',Instigator,,StartTrace, AdjustedAim);
				else
					lspro = spawn(class'MPNukeSeekingProjectileTrad',Instigator,,StartTrace, AdjustedAim);

				if(lspro != None)
				{
					lspro.Instigator = Instigator;

					// if we're not aimed at anything, figure out a target
					if(CurrentTarget == None)
					{
						lspro.DetermineTarget(ProjectedHitLoc);
					}
					else
						lspro.SetNewTarget(CurrentTarget);

					lspro.SetupShot(SeekingChargeMultiplier*ChargeTime);

					lspro.AddRelativeVelocity(Instigator.Velocity);

					// Touch any actor that was in between, just in case.
					if(HitActor != None)
						HitActor.Bump(lspro);
				}
			}*/
		}

		// Clear our target regardless
		//CurrentTarget = None;
		// If we didn't make a valid rocket, then give him his ammo back
		if(lpro != None)
			//&& lspro == None)
		/*{
			giveback = ChargeStartAmmo - AmmoType.AmmoAmount;
			if(giveback > 0)
				AmmoType.AddAmmo(giveback);
		}
		else*/
		{
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
		// Reset the ammo you started with
		//ChargeStartAmmo = AmmoType.AmmoAmount;
	}
}

defaultproperties
{
	// stay far, far away from ground zero!!!!!
	MinRange=2048
	MaxRange=4196
	ViolenceRank=15
	bUsesAltFire=False
	AmmoName=Class'NukeAmmoInv'
	FireSound=Sound'WeaponSounds.napalm_fire'
	GroupOffset=11
	PickupClass=Class'NukePickup'
	AttachmentClass=Class'NukeAttachment'
	ItemName="Mini-Nuke Launcher"
	HudHint1="Point and shoot this miniature nuke with %KEY_Fire%."
	HudHint2="Just try not to blow your dumb ass up."

	Begin Object Class=ConstantColor Name=ConstantBlack
		Color=(R=32,G=32,B=32)
	End Object
	Begin Object Class=Combiner Name=BlackLauncher
		CombineOperation=CO_Subtract
		Material1=Texture'WeaponSkins.launcher_timb2'
		Material2=ConstantColor'ConstantBlack'
	End Object
	Begin Object Class=Shader Name=BlackLauncherShader
		Diffuse=Combiner'BlackLauncher'
		Specular=TexEnvMap'AW7Tex.Cubes.CubeShineMap'
		SpecularityMask=TexEnvMap'AW7Tex.Cubes.CubeShineMap'
	End Object

	Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins(1)=Texture'AW7Tex.Nuke.nuclear_launcher'
	Skins(2)=ConstantColor'ConstantBlack'
	Skins(3)=ConstantColor'ConstantBlack'
}
