class FGrenadeWeapon extends GrenadeWeapon;



var FGrenade FlashNade;

simulated function PostNetBeginPlay()
{
    local PlayerController PC;
	local Pawn P;

    Super.PostNetBeginPlay();

    P  = Pawn(Owner);
	PC = PlayerController(P.Controller);

   	if (P.IsLocallyControlled() && PC!=None && (!PC.bBehindView) )
	{
        FlashNade = Spawn(Class'FGrenade'); 
        AttachToBone(FlashNade, 'Flash');
    }
   	else
	{
        if(Instigator != None)
	   {
		 if(Instigator.Mesh != None)

             FlashNade.Destroyed();
             FlashNade = None;
	   }
	}

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
   Super.Destroyed();

  if( FlashNade != None )
  {
    DetachFromBone(FlashNade);
    FlashNade.Destroy();
    FlashNade = None;
  }
}




function ThrowGrenade()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local FGrenadeProjectile gren;

	if(P2AmmoInv(AmmoType) != None
		&& AmmoType.HasAmmo())
	{
		CalcAIChargeTime();
		FireOffset = AltFireOffset;
		// Alt-firing the grenade, drops it at your feet, and doesn't
		// arm it
		if(bAltFiring)
		{
			ChargeTime = 0.0;
			FireOffset = AltFireOffset;
		}
		else
			FireOffset = default.FireOffset;

		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z);
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		// Make sure we're not generating this on the other side of a thin wall
		// Also, bump anything along the way, so the grenade can break a window if
		// you're standing really close to one.
		//if(FastTrace(Instigator.Location, StartTrace))
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			if(!bAltFiring)
				gren = spawn(class'FGrenadeProjectile',Instigator,,StartTrace, AdjustedAim);
			else
				gren = spawn(class'FGrenadeAltProjectile',Instigator,,StartTrace, AdjustedAim);

			// Make sure it got made, it could have gotten spawned in a wall and not made
			if(gren != None)
			{
				gren.Instigator = Instigator;

				// Compensate for catnip time, if necessary. Don't do this for NPCs
				if(FPSPawn(Instigator) != None
					&& FPSPawn(Instigator).bPlayer)
					ChargeTime /= Level.TimeDilation;

				gren.SetupThrown(ChargeTime);
				//gren.AddRelativeVelocity(Instigator.Velocity);
				//P2AmmoInv(AmmoType).UseAmmoForShot();
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
				{
					HitActor.Bump(gren);
					gren.ProcessTouch(HitActor, gren.location);
				}
			}
		}
	}
	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None)
		ThirdPersonActor.bHidden=true;
}


defaultproperties
	{
	bUsesAltFire=true
	ItemName="Grenade"
	AmmoName=class'FGrenadeAmmoInv'
	PickupClass=class'FGrenadePickup'
	AttachmentClass=class'FGrenadeAttachment'

//	Mesh=Mesh'FP_Weapons.FP_Dude_Grenade'
//	Mesh=Mesh'MP_Weapons.MP_LS_Grenade'

    Mesh=Mesh'MrD_PL_Anims.MP_LS_FlashGrenade'

//	Skins[0]=Texture'WeaponSkins.Dude_Hands'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix="Grenade"
    //PlayerViewOffset=(X=1.0000,Y=0.000000,Z=-2.0000)
	//PlayerViewOffset=(X=1.0000,Y=0.000000,Z=-10.0000)
	PlayerViewOffset=(X=5.000000,Y=2.000000)
	FireOffset=(X=35.0000,Y=20.000000,Z=18.00000)
	AltFireOffset=(X=35.0000,Y=18.0000,Z=-18.0000)

    bDrawMuzzleFlash=False

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Toss
	firingstyle=WEAPONHOLDSTYLE_Toss

	//shakemag=500.000000
	//shaketime=0.300000
	//shakevert=(X=1.0,Y=0.0,Z=1.00000)
	ShakeOffsetMag=(X=1.0,Y=1.0,Z=1.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2
	ShakeRotMag=(X=50.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2

	FireSound=Sound'PL_FlashGrenadeSound.FlashGrenade_Fire'
	AIRating=0.55
	AutoSwitchPriority=6
	InventoryGroup=7
	GroupOffset=1
	BobDamping=1.12 //0.975000
	ReloadCount=0
	TraceAccuracy=0.05
	ShotCountMaxForNotify=0
	ViolenceRank=6
	bThrownByFiring=true

	WeaponSpeedIdle	   = 0.4
	WeaponSpeedHolster = 1.5
	WeaponSpeedChargeIntro  = 1.5
	WeaponSpeedCharge  = 0.75
	WeaponSpeedLoad    = 1.25
	WeaponSpeedReload  = 1.25
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.5
	WeaponSpeedShoot2  = 2.0

	AimError=500
	ChargeTimeModifier=1.5
	ChargeWaitState="ChargeWaitGrenade"
	ChargeDistRatio=1800
	ChargeTimeMaxAI=1.5

	MaxRange=2048
	MinRange=400
	RecognitionDist=600

	NoAmmoChangeState = "EmptyDownWeapon"

	HudHint1="Hold Fire %KEY_Fire%"
	HudHint2="to charge them longer."
	AltHint1="Alt Fire %KEY_AltFire% to"
	AltHint2="place unarmed grenades."
	bAllowHints=true
	bShowHints=true
	bShowMainHints=true
	ItemName="Flash Grenade"
	}
