///////////////////////////////////////////////////////////////////////////////
// In gun ammo
///////////////////////////////////////////////////////////////////////////////
class RifleAmmoInv extends P2AmmoInv;

var class<P2Projectile> SilentProjectileClass;
var class<DamageType> DamageTypeEnhanced;

///////////////////////////////////////////////////////////////////////////////
// Add in the instigator
///////////////////////////////////////////////////////////////////////////////
function SpawnRifleProjectile(vector Start, vector Dir)
{
	local RifleProjectile rp;

	// 1407 bug below
	//AmmoAmount -= 1;
	// Fix: use function so npc's can properly have infinite ammo and drop the proper amount on death.
	UseAmmoForShot();

	rp = RifleProjectile(spawn(ProjectileClass,Instigator,, Start));
	rp.SetVelocity(Dir);
	//log(self$" spawned rifle proj "$rp$" at "$rp.Location$" player loc "$Instigator.Location$" speed "$rp.Velocity$" rot "$Instigator.Rotation);
}

function SpawnSilentRifleProjectile(vector Start, vector Dir)
{
	local RifleProjectile rp;

	UseAmmoForShot();

	rp = RifleProjectile(spawn(SilentProjectileClass,Instigator,, Start));
	rp.SetVelocity(Dir);
	//log(self$" spawned rifle proj "$rp$" at "$rp.Location$" player loc "$Instigator.Location$" speed "$rp.Velocity$" rot "$Instigator.Rotation);
}



defaultproperties
	{
	ProjectileClass=class'RifleProjectile'
	SilentProjectileClass=class'RifleProjectileSilent'
	PickupClass=class'RifleAmmoPickup'
	bInstantHit=false
	WarnTargetPct=+0.2
	bLeadTarget=true
	RefireRate=0.990000
	MaxAmmo=40
	MaxAmmoMP=8
	DamageAmount=25
	MomentumHitMag=10000
	DamageTypeInflicted=class'RifleDamage'
	DamageTypeEnhanced=class'SuperRifleDamage'
	Texture=Texture'HUDPack.Icons.Icon_Weapon_Rifle'
	}