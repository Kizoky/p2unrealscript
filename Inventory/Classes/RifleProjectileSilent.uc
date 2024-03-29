///////////////////////////////////////////////////////////////////////////////
// RifleProjectileSilent.
// by Man Chrzan
// 
// Silent version of RifleProjectile (for Cat-Silenced Rifle)
///////////////////////////////////////////////////////////////////////////////
class RifleProjectileSilent extends RifleProjectile;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Flying through the air
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Moving
{
	ignores HitWall, ProcessTouch, Touch, EncroachingOn;

	// Make it completly silent 
	function TellNPCs(Actor Other, vector HitLocation)
	{
	}
}


defaultproperties
{
	BulletHitMarkerMade = None;	
	PawnHitMarkerMade = class'PawnBeatenMarker'; 
}
