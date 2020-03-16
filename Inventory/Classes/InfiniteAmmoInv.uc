///////////////////////////////////////////////////////////////////////////////
// Infinite ammo in your hands or whatever
///////////////////////////////////////////////////////////////////////////////
class InfiniteAmmoInv extends P2AmmoInv;

///////////////////////////////////////////////////////////////////////////////
// Overrides old one by not deducting anything from AmmoAmount
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	//AmmoAmount -= 1;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function bool HasAmmo()
{
	if(bReadyForUse)
		return bInfinite;
	else
		return false;
}


defaultproperties
{
	AmmoAmount=0
	MaxAmmo=0
	bInfinite=true
	bShowAmmoOnHud=false
}