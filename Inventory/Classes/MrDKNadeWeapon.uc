//TNade 2010 - MrD
class MrDKNadeWeapon extends GrenadeWeapon;



///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var MrDKNade Krotch;

simulated function PostNetBeginPlay()
{
    local PlayerController PC;
	local Pawn P;

    Super.PostNetBeginPlay();

    P  = Pawn(Owner);
	PC = PlayerController(P.Controller);

   	if (P.IsLocallyControlled() && PC!=None && (!PC.bBehindView) )
	{
        Krotch = Spawn(Class'MrDKNade');
        AttachToBone(Krotch, 'k');
    }
   	else
	{
        if(Instigator != None)
	   {
		 if(Instigator.Mesh != None)

             Krotch.Destroyed();
             Krotch = None;
	   }
	}

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
   Super.Destroyed();

  if( Krotch != None )
  {
    DetachFromBone(Krotch);
    Krotch.Destroy();
    Krotch = None;
  }
}

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
// Set here that we want to reload after each throw
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	Super.PlayFiring();
	bForceReload=true;
}
simulated function PlayAltFiring()
{
	Super.PlayAltFiring();
	bForceReload=true;
}

///////////////////////////////////////////////////////////////////////////////
// Normal projectile fire, plus check where to make the danger marker to
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function ProjectileFire()
{
	// STUB
}
///////////////////////////////////////////////////////////////////////////////
// Normal projectile fire, plus check where to make the danger marker to
// alert people of the noise.
///////////////////////////////////////////////////////////////////////////////
function ProjectileAltFire()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// WE don't throw grenades
///////////////////////////////////////////////////////////////////////////////
function ThrowGrenade()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_ThrowGrenade()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local MrDKNadeProjectile molot;

	if(P2AmmoInv(AmmoType) != None
		&& AmmoType.HasAmmo())
	{
		CalcAIChargeTime();
		// Alt-firing the grenade, drops it at your feet, and doesn't
		// arm it
		if(bAltFiring)
		{
			ChargeTime = 0.0;
			FireOffset = AltFireOffset;
		}
		else
		{
			FireOffset = default.FireOffset;
		}

		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z);
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		// Make sure we're not generating this on the other side of a thin wall
		//if(FastTrace(Instigator.Location, StartTrace))
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			if(bAltFiring)
				molot = spawn(class'MrDKNadeAltProjectile',Instigator,,StartTrace, AdjustedAim);
			else
				molot = spawn(class'MrDKNadeProjectile',Instigator,,StartTrace, AdjustedAim);

			// Only use up the shot and perform the setup if we successfully spawned
			// a cocktail
			if(molot != None)
			{
				molot.Instigator = Instigator;

				// Compensate for catnip time, if necessary. Don't do this for NPCs
				if(FPSPawn(Instigator) != None
					&& FPSPawn(Instigator).bPlayer)
					ChargeTime /= Level.TimeDilation;

				molot.SetupThrown(ChargeTime);
				P2AmmoInv(AmmoType).UseAmmoForShot();
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
					HitActor.Bump(molot);
			}
		}
	}
	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None)
		ThirdPersonActor.bHidden=true;
}

///////////////////////////////////////////////////////////////////////////////
// If you drop your weapon, and you were charging (probably when you were dying)
// then drop a molotov too.
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
    Krotch.Destroyed();

	// If you were charging, throw out a live one now
	if(IsInState('BeforeCharging')
		|| IsInState('Charging')
		|| IsInState('ChargeWaitGrenade'))
	{
		ChargeTime = ChargeTimeMinAI;
		Notify_ThrowGrenade();
	}

	Super.DropFrom(StartLocation);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     ChargeDistRatio=3200.000000
     ChargeTimeMinAI=1.700000
     WeaponSpeedCharge=1.500000
     AltHint1="Press %KEY_AltFire% to place bombs."
     AltHint2="They explode after several seconds."
     ViolenceRank=2
     RecognitionDist=500.000000
     MinRange=512.000000
     FirstPersonMeshSuffix="KrotchyNade"
     WeaponSpeedShoot1Rand=0.100000
     WeaponSpeedIdle=0.500000
     AmmoName=Class'MrDKNadeAmmoInv'
     AutoSwitchPriority=0
     TraceAccuracy=0.100000
     AIRating=0.530000
     GroupOffset=40
     PickupClass=Class'MrDKNadePickup'
     AttachmentClass=Class'MrDKNadeAttachment'
     ItemName="Krotchy Grenade"
     Mesh=SkeletalMesh'P2R_Anims_D.Weapons.MP_KGrenade'
     Skins(0)=Texture'P2R_Tex_D.Weapons.hands'
     Skins(1)=Shader'P2R_Tex_D.Weapons.fake'
     Skins(2)=Texture'WeaponSkins.jailbars'
	 PlayerViewOffset=(X=1,Y=0,Z=-14)
}
