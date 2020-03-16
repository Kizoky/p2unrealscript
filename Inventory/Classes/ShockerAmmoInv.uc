///////////////////////////////////////////////////////////////////////////////
// Shocker ammo
//
// 
// In gun ammo
///////////////////////////////////////////////////////////////////////////////
class ShockerAmmoInv extends P2AmmoInv;

var Sound ShockerHit;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	// Skip the 9999 ammo in enhanced mode -- doesn't make sense for the urethra
	Super(Ammunition).PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Never switch at the end of an anim.
///////////////////////////////////////////////////////////////////////////////
simulated function bool HasAmmoFinished()
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Process a trace hitting something
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
//	local SmokeHitPuffMachineGun smoke1;
//	local DirtClodsMachineGun dirt1;
//	local SparkHitMachineGun spark1;
	local Rotator NewRot;

	if ( Other == None )
		return;

	if ( Pawn(Other) == None
		&& Other.bStatic)//Other.bWorldGeometry ) 
		{
		// randomly orient the splat on the wall (rotate around the normal)
		//NewRot = Rotator(-HitNormal);
		//NewRot.Roll=(65536*FRand());
		
		//Spawn(class'Fx.ShockerBurnSplat',,,HitLocation, NewRot);

//		smoke1 = Spawn(class'Fx.SmokeHitPuffMachineGun',,,HitLocation);
//		smoke1.FitToNormal(HitNormal);
//		if(FRand()<0.3)
//			{
//			dirt1 = Spawn(class'Fx.DirtClodsMachineGun',,,HitLocation);
//			dirt1.FitToNormal(HitNormal);
//			}
//		if(FRand()<0.3)
//			{
//			spark1 = Spawn(class'Fx.SparkHitMachineGun',,,HitLocation);
//			spark1.FitToNormal(HitNormal);
//			}
			Instigator.PlayOwnedSound(ShockerHit, SLOT_Misc, 1.0);
		}
	
	
	if ( (Other != self) && (Other != Owner) ) 
		{
		Instigator.PlayOwnedSound(ShockerHit, SLOT_Misc, 1.0);

		Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, MomentumHitMag*X, DamageTypeInflicted);
		
		if(ShockerWeapon(Pawn(Owner).Weapon) != None
			&& Pawn(Other) != None)
			{
			//ShockerWeapon(Pawn(Owner).Weapon).MakeSparks();
			ShockerWeapon(Pawn(Owner).Weapon).MakePawnLightning(Pawn(Other));
			}
		}


	//if ( Other.bWorldGeometry ) 
	//	Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	//else 
	//	if ( (Other != self) && (Other != Owner) ) 
	//	{
	//		if ( Pawn(Other) != None )
	//			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
	//		else
	//			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);	
	//		Other.TakeDamage(20,  Pawn(Owner), HitLocation, 30000.0*X, Damage);	
	//	}
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
//	ProjectileClass=Class'MachineGunBulletProj'
	bInstantHit=true
	WarnTargetPct=+0.2
	bLeadTarget=true
	RefireRate=0.990000
	MaxAmmo=30
	DamageAmount=1
	MomentumHitMag=0
	DamageTypeInflicted=class'ElectricalDamage'
	Texture=Texture'HUDPack.Icons.Icon_Weapon_Tazer'
	ShockerHit=Sound'WeaponSounds.tazer_hit'
}