///////////////////////////////////////////////////////////////////////////////
// If you kick or something in thin air, then tell people so they 
// can watch the crazy person
///////////////////////////////////////////////////////////////////////////////
class KickHitNothingMarker extends MeleeHitNothingMarker;

defaultproperties
{
	CollisionRadius=800
	CollisionHeight=500
	Priority=3
	bCreatorIsAttacker=false
}