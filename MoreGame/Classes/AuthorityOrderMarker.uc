///////////////////////////////////////////////////////////////////////////////
// A cop or some other authority figure has yelled a direct order
// (like put down your weapon) so people should react and
// other cops should respond.
///////////////////////////////////////////////////////////////////////////////
class AuthorityOrderMarker extends TimedMarker;

defaultproperties
{
	CollisionRadius=1024
	CollisionHeight=500
//	UseLifeMax=4.0
	Priority=1
	bCreatorIsAttacker=false
}