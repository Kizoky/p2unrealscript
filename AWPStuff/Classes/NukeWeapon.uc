///////////////////////////////////////////////////////////////////////////////
// NukeWeapon
//
// Edited by Man Chrzan
// Added a new function -- seeking-rockets!
///////////////////////////////////////////////////////////////////////////////
class NukeWeapon extends LauncherWeapon;

var LauncherProjectile FlyingNuke;
var bool bSearchForTarget;

const KEEP_TARGET_TIME = 0.50;

///////////////////////////////////////////////////////////////////////////////
// Check to restore proper hints
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	Super.TravelPostAccept();

	if(bAllowHints)
	{
		if(!bShowMainHints)
		{
			// Swap out hints to show
			HudHint1 = AltHint1;
			HudHint2 = AltHint2;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Allow two sets of hud hints to explain primary, then alternative fire
///////////////////////////////////////////////////////////////////////////////
function TurnOffHint()
{
	if(bShowMainHints)
	{
		bShowMainHints=false;
		// Swap out hints to show
		HudHint1 = AltHint1;
		HudHint2 = AltHint2;
		UpdateHudHints();
	}
	else
		Super.TurnOffHint();
}


///////////////////////////////////////////////////////////////////////////////
// Skip the charge, go straight to the fire
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	// xPatch: Make the NPCs with Nuke Launcher fire it only if the previously launched projectile exploded already.
	// Having more than one seeking nuke rocket after our sorry ass would be just... 
	// Jesus, even I am not that sort of a sado-masochistic psychopath to allow it.
	if(!PersonPawn(Instigator).bPlayer && FlyingNuke != None)
		return;
	
	if ( AmmoType == None
		|| !AmmoType.HasAmmo() )
	{
		ClientForceFinish();
		ServerForceFinish();
		return;
	}

	bSeeking=false;
	bAltFiring=false;
	ShootIt();
	ClientShootIt();
	
	// Turn off primary-fire hint
	TurnOffHint();
}

simulated function AltFire( float Value )
{
	if ( AmmoType == None
		|| !AmmoType.HasAmmo() )
	{
		ClientForceFinish();
		ServerForceFinish();
		return;
	}
	
	bSeeking=true;
	bAltFiring=true;
	ShootIt();
	ClientShootIt();

	Instigator.PlaySound(SeekerSound, SLOT_Misc, 1.0);
	
	// Turn off alt-fire hint
	if(!bShowMainHints)
		TurnOffHint();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_ShootLauncher()
{
	local vector StartTrace, X,Y,Z, markerpos, HitNormal, HitLocation;
	local actor HitActor;
	local NukeProjectile lpro;
	local NukeSeekingProjectile lspro;
	local PersonController perc;

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
			perc = PersonController(Instigator.Controller);
			if(perc != None
				&& perc.Target != None)
			{
				if(perc.MyPawn.bAdvancedFiring)
				{
					bSeeking=true;
					Instigator.PlaySound(SeekerSound, SLOT_Misc, 1.0);
				}
			}
			
			ChargeTime=30;
			
			if(!bSeeking) // fire a normal rocket
			{
				lpro = spawn(class'NukeProjectile',Instigator,,StartTrace, AdjustedAim);
				if(lpro != None)
				{
					FlyingNuke = lpro;
					
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
			}
			else // fire a seeking rocket
			{
				lspro = spawn(class'NukeSeekingProjectile',Instigator,,StartTrace, AdjustedAim);
				if(lspro != None)
				{
					FlyingNuke = lspro;
					lspro.Instigator = Instigator;

					// if we're not aimed at anything, figure out a target
					if(CurrentTarget == None)
						lspro.DetermineTarget(ProjectedHitLoc);
					else
						lspro.SetNewTarget(CurrentTarget);

					lspro.SetupShot(SeekingChargeMultiplier*ChargeTime);

					lspro.AddRelativeVelocity(Instigator.Velocity);

					// Touch any actor that was in between, just in case.
					if(HitActor != None)
						HitActor.Bump(lspro);
				}
			}
		}

		// Clear our target regardless
		CurrentTarget = None;
		
		// If we didn't make a valid rocket, then give him his ammo back
		if(lpro != None || lspro != None)
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
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to see if we'll hit anything good
///////////////////////////////////////////////////////////////////////////////
state Idle
{
	function Tick(float DeltaTime)
	{
		local vector HitNormal, StartTrace, EndTrace, X,Y,Z;
		local Actor TestTarget;
		
		// If we're dual wielding, forget about it
		if (bDualWielding || RightWeapon != none)
			  return;

		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			if (bSearchForTarget)
			{
				if(Level.NetMode == NM_Standalone
					|| Level.NetMode == NM_ListenServer)
				{
					// Check if you're hitting a person
					// shoot a trace out and see where they are pointing.
					GetAxes(Instigator.GetViewRotation(),X,Y,Z);
					StartTrace = Instigator.Location + Instigator.EyePosition();//GetFireStart(X,Y,Z);
					EndTrace = StartTrace + TraceDist*X;
					TestTarget = Trace(ProjectedHitLoc, HitNormal, EndTrace, StartTrace, true);
					// Pick this new target. Only pick alive, non-friend people
					if(ValidTarget(FPSPawn(TestTarget)))
					{
						CurrentTargetPickTime = Level.TimeSeconds;
						CurrentTarget = TestTarget;
						SetReticleOnTarget();
					}
					// If he's not been on the target for too long, then clear it.
					else if((CurrentTargetPickTime + KEEP_TARGET_TIME) < Level.TimeSeconds)
					{
						CurrentTarget = None;
						SetReticleOffTarget();
					}
				}
			}
		}
		else if(bSearchForTarget)// server side only in MP game (not single player
		{
			// Check if you're hitting a person
			// shoot a trace out and see where they are pointing.
			GetAxes(Instigator.GetViewRotation(),X,Y,Z);
			StartTrace = Instigator.Location + Instigator.EyePosition();//GetFireStart(X,Y,Z);
			EndTrace = StartTrace + TraceDist*X;
			TestTarget = Trace(ProjectedHitLoc, HitNormal, EndTrace, StartTrace, true);
			// Pick this new target. Only pick alive, non-friend people
			if(CurrentTarget != TestTarget)
			{
				// New pawn
				if(ValidTarget(FPSPawn(TestTarget)))
				{
					CurrentTargetPickTime = Level.TimeSeconds;
					CurrentTarget = TestTarget;
					SetReticleOnTarget();
				}
			}
			else if(FPSPawn(CurrentTarget) != None) // if still centered on him, update pick time
				CurrentTargetPickTime = Level.TimeSeconds;

			if(CurrentTarget != None
				&& (CurrentTargetPickTime + KEEP_TARGET_TIME) < Level.TimeSeconds)
			{
				CurrentTarget = None;
				SetReticleOffTarget();
			}
		}
	}
}
	
defaultproperties
{
	// stay far, far away from ground zero!!!!!
	MinRange=2048
	MaxRange=4196
	ViolenceRank=15
	bUsesAltFire=True
	AmmoName=Class'NukeAmmoInv'
	FireSound=Sound'WeaponSounds.napalm_fire'
	GroupOffset=11
	PickupClass=Class'NukePickup'
	AttachmentClass=Class'NukeAttachment'
	ItemName="Mini-Nuke Launcher"
	
	bAllowHints=true
	bShowHints=true
	bShowMainHints=true
	HudHint1="Point and shoot this miniature nuke with %KEY_Fire%."
	HudHint2="Just try not to blow your dumb ass up."
	AltHint1="Press %KEY_AltFire% to shoot a target-seeking nuke-rocket."
	AltHint2=""

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
	Skins(2)=Shader'xPatchTex.Weapons.NukeLauncherFuelUnit'
	Skins(3)=Shader'xPatchTex.Weapons.NukeLauncherFuelUnit'
	
	bSearchForTarget=True
}
