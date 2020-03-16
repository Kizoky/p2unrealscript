///////////////////////////////////////////////////////////////////////////////
// A pawn at this spot has been shot.
// People will know about this without seeing it. (Can hear it.)
///////////////////////////////////////////////////////////////////////////////
class PawnShotMarker extends TimedMarker;

defaultproperties
{
	CollisionRadius=1024
	CollisionHeight=512
//	UseLifeMax=3.0
	Priority=6
	bCreatorIsAttacker=true
}