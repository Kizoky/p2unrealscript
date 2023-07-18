///////////////////////////////////////////////////////////////////////////////
// Bucket Ammo.
///////////////////////////////////////////////////////////////////////////////
class BucketAmmoInv extends P2AmmoInv;

///////////////////////////////////////////////////////////////////////////////
// Doesn't check weapon/ammo readiness, just checks if you have ammo in some
// way or another.
///////////////////////////////////////////////////////////////////////////////
simulated function bool HasAmmoStrict()
{
	return true;
}
simulated function bool HasAmmo()
{
	return true;
}

defaultproperties
{
	MaxAmmo=100
	bInstantHit=true
	bShowAmmoOnHud=false
	bShowMaxAmmoOnHud=false
	Texture=Texture'MrD_PL_Tex.HUD.Bucket_HUD'
}