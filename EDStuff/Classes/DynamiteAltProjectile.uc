//////////////////////////////////////////////////////////////////////////////
// DynamiteAltProjectile.
// New re-written class, extend DynamiteProjectile.
// Man Chrzan, 2021. 
///////////////////////////////////////////////////////////////////////////////

class DynamiteAltProjectile extends DynamiteProjectile;   

simulated function HitByMatch()
{
	bArmed=True;
	DetonateTime=5.00;
	SetupDynamite(DetonateTime);
}

defaultproperties
{
    bArmed=False
	DetonateTime=0
}
