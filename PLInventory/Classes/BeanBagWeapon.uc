class BeanBagWeapon extends P2Weapon;


const NUM_BARRELS = 4;
const BARREL_ROTATION_RATE = 2.95;

var float BarrelRotation;
var float FinalRotation;
var bool bRotateBarrel;
var() float EnhancedSpeedMult;


replication
{
	reliable if (Role == ROLE_Authority && bNetOwner) //yup
		BarrelRotation, RotateBarrel, UpdateBarrel;
}

///////////////////////////////////////////////////////////////////////////////
// Modify your speed based on your owners body speed
///////////////////////////////////////////////////////////////////////////////
function ChangeSpeed(float NewSpeed)
{
	local float EnhancedMul;
	
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
		NewSpeed = NewSpeed * EnhancedSpeedMult;
	
	WeaponSpeedLoad = default.WeaponSpeedLoad*NewSpeed;
	WeaponSpeedReload = default.WeaponSpeedReload*NewSpeed;
	WeaponSpeedHolster = default.WeaponSpeedHolster*NewSpeed;
	WeaponSpeedShoot1 = default.WeaponSpeedShoot1*NewSpeed;
	WeaponSpeedShoot2 = default.WeaponSpeedShoot2*NewSpeed;
}

simulated function RotateBarrel() //yup
{
    FinalRotation += 65535.0 / NUM_BARRELS;
    if (FinalRotation >= 65535.0)
    {
        FinalRotation -= 65535.0;
        BarrelRotation -= 65535.0;
    }
    bRotateBarrel = true;
}
simulated function UpdateBarrel(float dt) //uhh huh
{
    local Rotator R;

    BarrelRotation += dt * 65535.0 * BARREL_ROTATION_RATE / NUM_BARRELS;
    if (BarrelRotation > FinalRotation)
    {
        BarrelRotation = FinalRotation;
        bRotateBarrel = false;
    }

    R.Roll = BarrelRotation;
    SetBoneRotation('Bone_Barrel', R, 0, 1);
}
simulated function Tick(float dt)
{
	if (bRotateBarrel)
		UpdateBarrel(dt);
}
simulated function ProjectileFire()
{
	RotateBarrel();
}
simulated function ProjectileAltFire()
{
	RotateBarrel();
}


//function ProjectileFire()
//{
//	if(Level.Game == None
//		|| !Level.Game.bIsSinglePlayer)
//		|| (Instigator != None
//			&& PersonController(Instigator.Controller) != None))
//	{
//		SpawnScissors(false);
//	}
//}
simulated function PlayFiring()
{
	Super.PlayFiring();
	bForceReload=false;
}
simulated function PlayReloading()
{
	PlayAnim('Load', WeaponSpeedReload, 0.05);

	P2MocapPawn(Instigator).PlayWeaponSwitch(self);
}
simulated function LocalFire()
{
	local P2Player P;

	bPointing = true;

	// Same as the one in P2Weapon, but we don't do the camera shake here
	// We make it shake when he throws

	if ( Affector != None )
		Affector.FireEffect();
	PlayFiring();
}
function SpawnScissors(bool bMakeSpinner)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local BeanBagGunProjectile sic;
	local P2Player p2p;

	if(AmmoType != None
		&& AmmoType.HasAmmo())
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z);
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
		if(bMakeSpinner)
		{
			TurnOffHint();
			sic = spawn(class'BeanBagGunProjectile',Instigator,,StartTrace, AdjustedAim);
		}
		else
			sic = spawn(class'BeanBagGunProjectile',Instigator,,StartTrace, AdjustedAim);
		// Make sure it got made
		if(sic != None)
			P2AmmoInv(AmmoType).UseAmmoForShot();

		// Shake the view when you throw it
		if ( Instigator != None)
		{
			p2p = P2Player(Instigator.Controller);
			if (p2p!=None)
			{
				p2p.ClientShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime,
							ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
			}
		}
	}
	// Turn off the thing in his hand as it leaves
	//if(ThirdPersonActor != None)
		//ThirdPersonActor.bHidden=true;
}
simulated function Notify_ThrowBag()
	{
	if(Level.Game != None
		&& Level.Game.bIsSinglePlayer)
		{
			SpawnScissors(false);
		}
	}
state Idle
{
	function BeginState()
	{
		Super.BeginState();
		if(ThirdPersonActor != None)
			ThirdPersonActor.bHidden=false;
	}
}

defaultproperties
{
     ViolenceRank=9
     holdstyle=WEAPONHOLDSTYLE_Both
     switchstyle=WEAPONHOLDSTYLE_Both
     firingstyle=WEAPONHOLDSTYLE_Both
     bThrownByFiring=True
     ShakeOffsetTime=4.000000
     AmmoName=Class'BeanBagGunAmmoInv'
     FireOffset=(X=75.000000,Y=5.000000,Z=-20.000000)
     ShakeRotMag=(X=330.000000,Y=35.000000,Z=35.000000)
     ShakeOffsetMag=(X=3.500000,Y=2.500000,Z=2.500000)
     TraceAccuracy=53.900002
     aimerror=1500.000000
     MaxRange=900.000000
     FireSound=Sound'PL_BeanBagSounds.BeanBag_Fire'
     //SelectSound=Sound'WeaponSounds.weapon_pickup'
	 InventoryGroup=10
     GroupOffset=3
     PickupClass=Class'BeanBagGunPickup'
     PlayerViewOffset=(X=1.000000,Y=0.300000,Z=-1.300000)
     BobDamping=1.12 //0.975000
     AttachmentClass=Class'BeanBagGunAttachment'
     ItemName="Bean Bag Launcher"
     Mesh=SkeletalMesh'MrD_PL_Anims.MiniGun_D'
     Skins(0)=Texture'MrD_PL_Tex.Weapons.TestingUV'
     Skins(1)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     Skins(2)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     //AmbientGlow=128
     SoundRadius=355.000000
	 bHideFoot=false //true
	 EnhancedSpeedMult=1.5
	 
	 // Added by Man Chrzan
	 bSpawnMuzzleFlash=true
	 bMFAlwaysSpawn=true
	 MFBoneName="Motor"
	 MFClass=class'FX2.MuzzleSmoke03' 
	 MFRelativeLocation=(X=0,Y=58,Z=10)
}
