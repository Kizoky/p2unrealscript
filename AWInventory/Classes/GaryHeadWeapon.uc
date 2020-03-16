///////////////////////////////////////////////////////////////////////////////
// GaryHeadWeapon
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////

class GaryHeadWeapon extends P2Weapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////
var class<GaryHeadProjectile> FireProjClass;
var class<GaryHeadProjectile> AltFireProjClass;
var bool bRemoved;

const FIRE_DELAY	=	0.5;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function RemoveMe()
{
	if(!bRemoved)
	{
		Instigator.Weapon = None;
		if(P2Player(Instigator.Controller) != None)
			P2Player(Instigator.Controller).SwitchToThisWeapon(P2Pawn(Instigator).HandsClass.default.InventoryGroup, 
						P2Pawn(Instigator).HandsClass.default.GroupOffset, true);

		Instigator.DeleteInventory(self);
		bRemoved=true;
		Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	if(P2MocapPawn(Instigator) != None
		&& Bot(Instigator.Controller) == None)
	{
		ServerFire();
		if ( Role < ROLE_Authority )
		{
			PlayFiring();
			GotoState('ClientFiring');
		}
	}
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function AltFire( float Value )
{
	if(P2MocapPawn(Instigator) != None
		&& Bot(Instigator.Controller) == None)
	{
		ServerAltFire();
		if ( Role < ROLE_Authority )
		{
			PlayAltFiring();
			GotoState('ClientFiring');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	PlayAnim('Point', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}
simulated function PlayAltFiring()
{
	PlayAnim('Point', WeaponSpeedShoot2 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProjectileFire()
{
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProjectileAltFire()
{
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SpawnHead(bool bSeeking)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local GaryHeadProjectile ghp;
	local P2Player p2p;
	
	if(AmmoType != None
		&& AmmoType.HasAmmo())
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z); 
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
		if(bSeeking)
		{
			TurnOffHint();
			ghp = spawn(AltFireProjClass,Instigator,,StartTrace, AdjustedAim);
		}
		else
			ghp = spawn(FireProjClass,Instigator,,StartTrace, AdjustedAim);

		ghp.PrepVelocity(ghp.Speed*vector(AdjustedAim));
		if(GaryHeadHomingProjectile(ghp) != None)
			GaryHeadHomingProjectile(ghp).FindTarget();

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
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
Begin:
	Sleep(FIRE_DELAY);
	SpawnHead(bAltFiring);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     FireProjClass=Class'AWInventory.GaryHeadBurnProjectile'
     AltFireProjClass=Class'AWInventory.GaryHeadHomingProjectile'
     bUsesAltFire=True
     ViolenceRank=9
     bNoHudReticle=True
     ShakeOffsetTime=0.000000
     DropWeaponHint1=""
     CombatRating=0.500000
     FirstPersonMeshSuffix="Nothing"
     WeaponSpeedLoad=2.000000
     WeaponSpeedReload=1.500000
     WeaponSpeedHolster=5.000000
     WeaponSpeedShoot1=0.950000
     WeaponSpeedShoot2=0.800000
     AmmoName=Class'AWInventory.GaryHeadAmmoInv'
     bCanThrow=False
     AutoSwitchPriority=0
     ShakeRotMag=(X=0.000000,Y=0.000000,Z=0.000000)
     ShakeRotRate=(X=0.000000,Y=0.000000,Z=0.000000)
     ShakeRotTime=0.000000
     ShakeOffsetMag=(X=0.000000,Y=0.000000,Z=0.000000)
     ShakeOffsetRate=(X=0.000000,Y=0.000000,Z=0.000000)
     aimerror=0.000000
     AIRating=0.040000
     SelectSound=None
     InventoryGroup=0
     GroupOffset=5
     BobDamping=0.975000
     AttachmentClass=None
     ItemName="GaryHeadHands"
     Mesh=SkeletalMesh'MP_Weapons.MP_LS_Nothing'
     Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
}
